"""Textual front end: panels, colours, HP bars, mouse + keyboard. Rules live in battle/collection/story;
this module only renders state and turns clicks/keys into calls on them."""
from __future__ import annotations

import argparse
import random
from pathlib import Path

from rich.markup import escape
from textual import on
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Center, Grid, Horizontal, Vertical, VerticalScroll
from textual.message import Message
from textual.screen import ModalScreen, Screen
from textual.widgets import Button, DataTable, Footer, Input, Label, RichLog, Static

from . import collection as col
from . import story
from .battle import Battle, Unit
from .cards import LORD, RARITIES, CardDB, Fighter, build_fighter, load_db, power, power_split

RARITY_COLOR = {"N": "#8b949e", "R": "#61afef", "SR": "#c678dd", "SSR": "#f5c542", None: "#e06c75"}
TARGET_LABEL = {"enemy": "单体敌", "ally": "单体友", "self": "自身", "all_enemies": "全体敌", "all_allies": "全体友"}


# ---- shared rendering ------------------------------------------------------

def hp_bar(hp: int, max_hp: int, width: int = 26) -> str:
    frac = hp / max_hp if max_hp else 0
    filled = round(width * frac)
    color = "#98c379" if frac > 0.5 else "#e5c07b" if frac > 0.25 else "#e06c75"
    return f"[{color}]{'█' * filled}[/][#3b3f4a]{'░' * (width - filled)}[/]"


def card_body(db: CardDB, f: Fighter) -> str:
    troop_p, general_p = power_split(db, f)
    split = f"兵种 {troop_p} + 武将 {general_p}" if general_p else f"兵种 {troop_p}"
    skills = " · ".join(db.skills[s].name for s in f.skills)
    return (f"[b]{db.troops[f.troop].name}[/]  战力 [b #f5c542]{power(f)}[/]\n"
            f"[dim]{split}[/]\n"
            f"兵{f.hp} 武{f.atk} 智{f.int} 统{f.def_}\n"
            f"[#abb2bf]{skills}[/]")


class CardView(Static):
    """A card with a rarity-coloured border. Clicking posts CardView.Clicked."""

    class Clicked(Message):
        def __init__(self, card_id: str) -> None:
            super().__init__()
            self.card_id = card_id

    def __init__(self, db: CardDB, f: Fighter, note: str = "", **kw) -> None:
        super().__init__(card_body(db, f) + (f"\n{note}" if note else ""), **kw)
        self.card_id = f.id
        self.border_title = escape(f.name)
        self.border_subtitle = f.rarity or "主公"
        self.add_class(f.rarity or "lord")

    def on_click(self) -> None:
        self.post_message(self.Clicked(self.card_id))


def card_table(db: CardDB, save: col.Save, table: DataTable, troop: str | None = None) -> None:
    table.clear(columns=True)
    table.add_columns("", "稀有", "兵种", "武将", "战力", "兵种+武将", "兵", "武", "智", "统", "技能")
    fighters = [f for f in col.owned_fighters(db, save) if troop is None or f.troop == troop]
    for f in sorted(fighters, key=lambda f: (-RARITIES.index(f.rarity), -power(f))):
        tp, gp = power_split(db, f)
        color = RARITY_COLOR[f.rarity]
        table.add_row("◆" if f.id in save.party else "", f"[{color}]{f.rarity}[/]", db.troops[f.troop].name,
                      f"[{color}]{escape(f.name)}[/]", f"[b]{power(f)}[/]", f"{tp}+{gp}",
                      f.hp, f.atk, f.int, f.def_, "、".join(db.skills[s].name for s in f.skills), key=f.id)


# ---- main menu ---------------------------------------------------------------

TITLE_ART = "[b]三　国　卡　牌[/]\n[dim]穿越江东 · 抽卡组军[/]"


class MenuScreen(Screen):
    BINDINGS = [Binding(str(i), f"go({i})", show=False) for i in range(1, 7)] + [Binding("q", "app.quit", "退出")]

    def compose(self) -> ComposeResult:
        with Center(id="menu-wrap"):
            with Vertical(id="menu"):
                yield Static(TITLE_ART, id="title")
                yield Static(id="status")
                yield Button("1  剧情", id="m1", variant="primary")
                yield Button("2  招募", id="m2")
                yield Button("3  卡册", id="m3")
                yield Button("4  编成", id="m4")
                yield Button("5  自由出战", id="m5")
                yield Button("6  保存并退出", id="m6", variant="error")
        yield Footer()

    def on_screen_resume(self) -> None:
        self.refresh_status()

    def on_mount(self) -> None:
        self.refresh_status()

    def refresh_status(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        cur = story.current(app.st, app.save)
        chapter = cur[0].title if cur else "暂无新章节"
        self.query_one("#status", Static).update(
            f"[b]{escape(app.save.lord_name)}[/]   卡册 {len(app.save.owned)}/{len(app.db.cards)}"
            f"   编成 {len(app.save.party) + 1}/{app.save.party_slots}\n[dim]剧情：{chapter}[/]")

    @on(Button.Pressed)
    def pressed(self, event: Button.Pressed) -> None:
        self.action_go(int(event.button.id[1:]))

    def action_go(self, n: int) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        screens = {1: StoryScreen, 2: GachaScreen, 3: CollectionScreen, 4: PartyScreen, 5: ScenarioScreen}
        if n == 6:
            app.exit()
        else:
            app.push_screen(screens[n]())


class NameModal(ModalScreen[str]):
    def compose(self) -> ComposeResult:
        with Vertical(id="dialog"):
            yield Label("一道白光……你是谁？")
            yield Input(placeholder="输入你的名字（回车=主公）", id="name")
            yield Button("醒来", id="ok", variant="primary")

    @on(Input.Submitted)
    @on(Button.Pressed, "#ok")
    def name_done(self) -> None:
        self.dismiss(self.query_one("#name", Input).value.strip() or "主公")


# ---- story -------------------------------------------------------------------

class StoryScreen(Screen):
    BINDINGS = [Binding("escape", "app.pop_screen", "返回主菜单"), Binding("enter", "next", "继续")]

    def compose(self) -> ComposeResult:
        yield Static(id="story-title")
        yield VerticalScroll(id="story-body")
        yield Horizontal(id="story-actions")
        yield Footer()

    def on_mount(self) -> None:
        self.render_step()

    def render_step(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        body = self.query_one("#story-body", VerticalScroll)
        actions = self.query_one("#story-actions", Horizontal)
        body.remove_children()
        actions.remove_children()
        cur = story.current(app.st, app.save)
        if cur is None:
            self.query_one("#story-title", Static).update("剧情")
            body.mount(Static("剧情暂时到此为止。去招募、编成，或者自由出战吧。", classes="story-text"))
            actions.mount(Button("返回主菜单", name="back"))
            return
        node, step = cur
        self.query_one("#story-title", Static).update(f"━━  {node.title}  ━━")
        kind = story.kind(step)
        lord = escape(app.save.lord_name)
        if kind == "text":
            text = "\n\n".join(escape(line).replace("{lord}", f"[b #e06c75]{lord}[/]") for line in step["text"])
            body.mount(Static(text, classes="story-text"))
            actions.mount(Button("继续 ▶", name="next", variant="primary"))
        elif kind == "choose":
            body.mount(Static("选择一人随你同行：", classes="story-text"))
            row = Horizontal(classes="choice-row")
            body.mount(row)
            for i, opt in enumerate(step["choose"]):
                col_ = Vertical(classes="choice")
                row.mount(col_)
                col_.mount(CardView(app.db, build_fighter(app.db, opt["card"])))
                col_.mount(Button(opt["label"], name=f"choose-{i}", variant="warning"))
        elif kind == "give":
            body.mount(Static("获得卡牌：", classes="story-text"))
            grid = Grid(classes="card-grid")
            body.mount(grid)
            for cid in step["give"].get("cards", []):
                grid.mount(CardView(app.db, build_fighter(app.db, cid)))
            actions.mount(Button("继续 ▶", name="next", variant="primary"))
        elif kind == "battle":
            sc = app.db.scenarios[step["battle"]]
            enemies = "、".join(app.db.enemies[e].name for e in sc.enemy)
            body.mount(Static(f"即将开战：[b]{sc.name}[/]　敌军：{enemies}\n\n当前编成：", classes="story-text"))
            grid = Grid(classes="card-grid")
            body.mount(grid)
            for f in col.party_fighters(app.db, app.save):
                grid.mount(CardView(app.db, f))
            actions.mount(Button("⚔ 出战", name="fight", variant="error"))
            actions.mount(Button("先去整备（回主菜单）", name="back"))

    def action_next(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        cur = story.current(app.st, app.save)
        if cur and story.kind(cur[1]) in ("text", "give"):
            story.advance(app.db, app.st, app.save)
            app.persist()
            self.render_step()

    @on(Button.Pressed)
    def pressed(self, event: Button.Pressed) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        bid = event.button.name or ""
        if bid == "next":
            self.action_next()
        elif bid == "back":
            app.pop_screen()
        elif bid.startswith("choose-"):
            story.advance(app.db, app.st, app.save, int(bid.split("-")[1]))
            app.persist()
            self.render_step()
        elif bid == "fight":
            scenario = story.current(app.st, app.save)[1]["battle"]

            def after(won: bool | None) -> None:
                if won:
                    story.advance(app.db, app.st, app.save)
                    app.persist()
                self.render_step()

            app.push_screen(BattleScreen(scenario), after)


# ---- gacha -------------------------------------------------------------------

class GachaScreen(Screen):
    BINDINGS = [Binding("escape", "app.pop_screen", "返回"), Binding("1", "pull(1)", "招募 1 次"),
                Binding("0", "pull(10)", "招募 10 次")]

    def compose(self) -> ComposeResult:
        yield Static("招募", classes="screen-title")
        with Horizontal(id="gacha-actions"):
            yield Button("招募 1 次", id="p1", variant="primary")
            yield Button("招募 10 次", id="p10", variant="warning")
            yield Static(id="pool-left")
        yield VerticalScroll(Grid(id="gacha-results", classes="card-grid"))
        yield Footer()

    def on_mount(self) -> None:
        self.update_left()

    def update_left(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        self.query_one("#pool-left", Static).update(f"卡池剩余 {col.pool_left(app.db, app.save)} 张")

    @on(Button.Pressed, "#p1")
    def one(self) -> None:
        self.action_pull(1)

    @on(Button.Pressed, "#p10")
    def ten(self) -> None:
        self.action_pull(10)

    def action_pull(self, n: int) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        cards = col.pull(app.db, app.save, app.rng, n)
        grid = self.query_one("#gacha-results", Grid)
        grid.remove_children()
        if not cards:
            self.notify("卡池里的武将已经全部招募！", severity="warning")
            return
        for c in sorted(cards, key=lambda c: RARITIES.index(c.rarity), reverse=True):
            grid.mount(CardView(app.db, build_fighter(app.db, c.id), note="[b #f5c542]✦ NEW[/]"))
        best = max(cards, key=lambda c: RARITIES.index(c.rarity))
        if best.rarity == "SSR":
            self.notify(f"✦✦✦ SSR {best.name}！", title="招募")
        app.persist()
        self.update_left()


# ---- collection & party ------------------------------------------------------

class CollectionScreen(Screen):
    BINDINGS = [Binding("escape", "app.pop_screen", "返回")]

    def compose(self) -> ComposeResult:
        app: SanguoApp = self.app  # type: ignore[assignment]
        yield Static("卡册", classes="screen-title")
        with Horizontal(id="filters"):
            yield Button("全部", id="f-all", classes="filter")
            for tid, t in app.db.troops.items():
                if tid != LORD:
                    yield Button(t.name, id=f"f-{tid}", classes="filter")
        with Horizontal(id="collection"):
            yield DataTable(id="cards", cursor_type="row", zebra_stripes=True)
            yield Vertical(id="detail")
        yield Footer()

    def on_mount(self) -> None:
        self.fill(None)

    def fill(self, troop: str | None) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        card_table(app.db, app.save, self.query_one("#cards", DataTable), troop)

    @on(Button.Pressed, ".filter")
    def filter_troop(self, event: Button.Pressed) -> None:
        tid = event.button.id[2:]
        self.fill(None if tid == "all" else tid)

    @on(DataTable.RowHighlighted)
    def show_detail(self, event: DataTable.RowHighlighted) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        detail = self.query_one("#detail", Vertical)
        detail.remove_children()
        if event.row_key and event.row_key.value:
            f = build_fighter(app.db, event.row_key.value)
            detail.mount(CardView(app.db, f))
            skills = "\n".join(f"[b]{app.db.skills[s].name}[/] 耗{app.db.skills[s].cost} · "
                               f"{'∞' if app.db.skills[s].uses is None else f'{app.db.skills[s].uses}次'} · "
                               f"{TARGET_LABEL[app.db.skills[s].target]}" for s in f.skills)
            detail.mount(Static(skills, classes="skill-list"))


class PartyScreen(Screen):
    BINDINGS = [Binding("escape", "app.pop_screen", "返回"), Binding("a", "auto", "自动编成")]

    def compose(self) -> ComposeResult:
        yield Static("编成　[dim]下方选卡加入（同兵种会替换）· 点上方卡片移出 · 主公固定[/]", classes="screen-title")
        yield Horizontal(id="slots")
        with Horizontal(id="party-actions"):
            yield Button("自动编成", id="auto", variant="primary")
            yield Static(id="party-power")
        yield DataTable(id="cards", cursor_type="row", zebra_stripes=True)
        yield Footer()

    def on_mount(self) -> None:
        self.refresh_all()

    def refresh_all(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        slots = self.query_one("#slots", Horizontal)
        slots.remove_children()
        party = col.party_fighters(app.db, app.save)
        for f in party:
            slots.mount(CardView(app.db, f))
        for _ in range(app.save.party_slots - len(party)):
            slots.mount(Static("\n\n空位", classes="empty-slot"))
        self.query_one("#party-power", Static).update(f"编成总战力 [b #f5c542]{sum(power(f) for f in party)}[/]")
        table = self.query_one("#cards", DataTable)
        row = table.cursor_row
        card_table(app.db, app.save, table)
        if table.row_count:
            table.move_cursor(row=min(row, table.row_count - 1))

    def action_auto(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        app.save.party = col.auto_party(app.db, app.save)
        app.persist()
        self.refresh_all()

    @on(Button.Pressed, "#auto")
    def auto_pressed(self) -> None:
        self.action_auto()

    @on(CardView.Clicked)
    def remove_card(self, event: CardView.Clicked) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        if event.card_id in app.save.party:
            app.save.party.remove(event.card_id)
            app.persist()
            self.refresh_all()

    @on(DataTable.RowSelected)
    def add_card(self, event: DataTable.RowSelected) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        cid = event.row_key.value
        party = app.save.party
        if cid in party:
            party.remove(cid)
        else:
            card = app.db.cards[cid]
            clash = [p for p in party if app.db.cards[p].troop == card.troop or app.db.cards[p].person == card.person]
            for p in clash:
                party.remove(p)
            if len(party) >= app.save.party_slots - 1:
                self.notify("编成已满 —— 先点上方卡片移出一张", severity="warning")
                party.extend(clash)
                return
            party.append(cid)
        app.persist()
        self.refresh_all()


# ---- battle ------------------------------------------------------------------

class UnitView(Static):
    class Clicked(Message):
        def __init__(self, side: str, idx: int) -> None:
            super().__init__()
            self.side, self.idx = side, idx

    def __init__(self, side: str, idx: int, **kw) -> None:
        super().__init__(**kw)
        self.side, self.idx = side, idx

    def on_click(self) -> None:
        self.post_message(self.Clicked(self.side, self.idx))


class BattleScreen(Screen[bool]):
    BINDINGS = ([Binding(str(i), f"num({i})", show=False) for i in range(1, 10)]
                + [Binding("e", "end_turn", "结束回合"), Binding("escape", "cancel", "取消选择")])

    def __init__(self, scenario_id: str) -> None:
        super().__init__()
        self.scenario_id = scenario_id
        self.selected: int | None = None
        self.pending: str | None = None  # skill waiting for a target

    def compose(self) -> ComposeResult:
        app: SanguoApp = self.app  # type: ignore[assignment]
        self.b = Battle.from_scenario(app.db, self.scenario_id, col.party_fighters(app.db, app.save), seed=app.seed)
        yield Static(id="battle-head")
        yield Label("敌军", classes="side-label enemy-label")
        with Horizontal(id="enemies"):
            for i in range(len(self.b.enemy)):
                yield UnitView("enemy", i, classes="unit enemy")
        yield Label("我军", classes="side-label")
        with Horizontal(id="players"):
            for i in range(len(self.b.player)):
                yield UnitView("player", i, classes="unit player")
        with Horizontal(id="battle-bottom"):
            with Vertical(id="controls"):
                yield Static(id="prompt")
                yield Vertical(id="skills")
                yield Button("结束回合 (E)", id="end", variant="error")
            yield RichLog(id="log", markup=True, wrap=True)
        yield Footer()

    def on_mount(self) -> None:
        sc = self.b.scenario
        self.log_lines([f"[b]【{sc.name}】[/] {sc.turn_limit} 回合内击败全部敌将。"
                        f"每回合行动力 {sc.ap}，每支部队每回合限动一次。"])
        self.refresh_all()

    # -- rendering

    def log_lines(self, lines: list[str], enemy: bool = False) -> None:
        log = self.query_one("#log", RichLog)
        for line in lines:
            if line.startswith("——"):
                enemy = True
                log.write(f"[b #e06c75]{line}[/]")
            elif line.startswith("  "):
                log.write(f"[dim]{line}[/]")
            else:
                log.write(f"[#e06c75]{line}[/]" if enemy else f"[#98c379]{line}[/]")

    def unit_text(self, u: Unit, idx: int) -> str:
        db = self.b.db
        tags = []
        if u.guard:
            tags.append("[#61afef]防御[/]")
        if u.atk_up > 0:
            tags.append("[#e5c07b]士气↑[/]")
        if u.dazed or u.stunned:
            tags.append("[#c678dd]混乱[/]")
        lines = [f"[b]{idx + 1}. {escape(u.name)}[/] [dim]{db.troops[u.card.troop].name}[/]",
                 hp_bar(u.hp, u.card.hp), f"{u.hp}/{u.card.hp}  {' '.join(tags)}"]
        if not u.alive:
            return f"[b]{idx + 1}. {escape(u.name)}[/]\n\n[dim]—— 败退 ——[/]"
        if u.side == "enemy":
            intent = self.b.intents.get(idx)
            if intent:
                tgt = intent.target.name if intent.target else \
                    {"all_enemies": "我军全体", "all_allies": "敌军全体", "self": "自身"}[intent.skill.target]
                lines.append(f"[#e5c07b]⚠ {intent.skill.name} → {escape(tgt)}[/]")
        else:
            lines.append("[dim]已行动[/]" if u.acted else "[#98c379]可行动[/]")
        return "\n".join(lines)

    def refresh_all(self) -> None:
        b = self.b
        pips = "●" * b.ap + "○" * max(0, b.scenario.ap - b.ap)
        self.query_one("#battle-head", Static).update(
            f"[b]{b.scenario.name}[/]　第 [b]{b.round}[/]/{b.scenario.turn_limit} 回合　行动力 [b #f5c542]{pips}[/] {b.ap}")
        targets = self.target_pool()
        for view in self.query(UnitView):
            units = b.enemy if view.side == "enemy" else b.player
            u = units[view.idx]
            view.update(self.unit_text(u, view.idx))
            view.set_class(not u.alive, "dead")
            view.set_class(view.side == "player" and b.can_act(u), "ready")
            view.set_class(view.side == "player" and view.idx == self.selected, "selected")
            view.set_class(targets is not None and units is targets and u.alive, "targetable")
        self.refresh_controls()

    def target_pool(self) -> list[Unit] | None:
        if self.pending is None or self.selected is None:
            return None
        sk = self.b.db.skills[self.pending]
        return self.b.enemy if sk.target == "enemy" else self.b.player

    def refresh_controls(self) -> None:
        b = self.b
        prompt = self.query_one("#prompt", Static)
        skills = self.query_one("#skills", Vertical)
        skills.remove_children()
        if b.result:
            prompt.update("")
            return
        if self.selected is None:
            ready = [i + 1 for i, p in enumerate(b.player) if b.can_act(p)]
            prompt.update(f"选择出手部队：点击我军或按 {'/'.join(map(str, ready))}" if ready and b.ap
                          else "行动力用尽 —— 按 E 结束回合")
            return
        u = b.player[self.selected]
        if self.pending:
            sk = b.db.skills[self.pending]
            who = "敌将" if sk.target == "enemy" else "友军"
            prompt.update(f"[b]{escape(u.name)}[/]【{sk.name}】→ 选择目标{who}（点击或按数字，Esc 取消）")
            return
        prompt.update(f"[b]{escape(u.name)}[/] 使用：（按数字或点击，Esc 取消）")
        for i, sk in enumerate(b.usable_skills(u)):
            left = u.uses_left[sk.id]
            uses = "∞" if left is None else f"剩{left}"
            skills.mount(Button(f"{i + 1}. {sk.name}  耗{sk.cost}·{uses}·{TARGET_LABEL[sk.target]}",
                                name=sk.id, classes="skill"))

    # -- input

    def action_num(self, n: int) -> None:
        b = self.b
        i = n - 1
        if b.result:
            return
        if self.pending:
            pool = self.target_pool()
            if pool is not None and i < len(pool) and pool[i].alive:
                self.fire(i)
        elif self.selected is not None:
            usable = b.usable_skills(b.player[self.selected])
            if i < len(usable):
                self.pick_skill(usable[i].id)
        elif i < len(b.player) and b.can_act(b.player[i]):
            self.selected = i
            self.refresh_all()

    @on(UnitView.Clicked)
    def unit_clicked(self, event: UnitView.Clicked) -> None:
        b = self.b
        pool = self.target_pool()
        if pool is not None:
            units = b.enemy if event.side == "enemy" else b.player
            if units is pool and pool[event.idx].alive:
                self.fire(event.idx)
        elif event.side == "player" and b.can_act(b.player[event.idx]):
            self.selected = event.idx
            self.refresh_all()

    @on(Button.Pressed, ".skill")
    def skill_pressed(self, event: Button.Pressed) -> None:
        self.pick_skill(event.button.name)

    @on(Button.Pressed, "#end")
    def end_pressed(self) -> None:
        self.action_end_turn()

    def pick_skill(self, sid: str) -> None:
        if self.b.needs_target(self.b.db.skills[sid]):
            self.pending = sid
            self.refresh_all()
        else:
            self.pending = sid
            self.fire(None)

    def fire(self, target: int | None) -> None:
        lines = self.b.act(self.selected, self.pending, target)
        self.selected = self.pending = None
        self.log_lines(lines)
        self.refresh_all()
        self.check_result()

    def action_cancel(self) -> None:
        if self.pending:
            self.pending = None
        else:
            self.selected = None
        self.refresh_all()

    def action_end_turn(self) -> None:
        if self.b.result:
            return
        self.selected = self.pending = None
        self.log_lines(self.b.end_turn())
        if self.b.result is None:
            self.query_one("#log", RichLog).write(f"[dim]─── 第 {self.b.round} 回合 ───[/]")
        self.refresh_all()
        self.check_result()

    def check_result(self) -> None:
        if self.b.result is None:
            return
        app: SanguoApp = self.app  # type: ignore[assignment]
        won = self.b.result == "win"
        if won:
            col.record_win(app.save, self.scenario_id)
            app.persist()
        # dismiss on the next tick: dismissing from inside another screen's dismiss callback deadlocks
        app.push_screen(ResultModal(won), lambda _: self.app.call_later(self.dismiss, won))


class ResultModal(ModalScreen[None]):
    BINDINGS = [Binding("enter", "close", "确定"), Binding("escape", "close", show=False)]

    def __init__(self, won: bool) -> None:
        super().__init__()
        self.won = won

    def compose(self) -> ComposeResult:
        with Vertical(id="dialog", classes="win" if self.won else "lose"):
            yield Static("★  胜 利  ★" if self.won else "✗  战 败", id="result-text")
            yield Static("" if self.won else "[dim]调整编成或去招募，再来一次[/]")
            yield Button("确定", id="ok", variant="primary")

    @on(Button.Pressed, "#ok")
    def action_close(self) -> None:
        self.dismiss(None)


# ---- free battle -------------------------------------------------------------

class ScenarioScreen(Screen):
    BINDINGS = [Binding("escape", "app.pop_screen", "返回")]

    def compose(self) -> ComposeResult:
        app: SanguoApp = self.app  # type: ignore[assignment]
        yield Static("自由出战", classes="screen-title")
        with Vertical(id="scenarios"):
            for sid, sc in app.db.scenarios.items():
                enemies = "、".join(app.db.enemies[e].name for e in sc.enemy)
                done = " ✓" if sid in app.save.cleared else ""
                yield Button(f"{sc.name}{done}　—　{enemies}", id=f"sc-{sid}", classes="scenario")
        yield Footer()

    def on_screen_resume(self) -> None:
        self.refresh(recompose=True)  # update ✓ marks after a battle

    @on(Button.Pressed, ".scenario")
    def go_scenario(self, event: Button.Pressed) -> None:
        self.app.push_screen(BattleScreen(event.button.id[3:]))


# ---- app ---------------------------------------------------------------------

class SanguoApp(App):
    TITLE = "三国卡牌"
    CSS = """
    Screen { background: #1b1c21; }
    Footer { background: #25262c; }
    .screen-title { height: 3; padding: 1 2 0 2; text-style: bold; color: #f5c542; }

    #menu-wrap { height: 1fr; align: center middle; }
    #menu { width: 44; height: auto; align-horizontal: center; }
    #title { color: #f5c542; border: double #f5c542; text-align: center; padding: 1 0; margin-bottom: 1; }
    #status { padding: 0 0 1 0; color: #abb2bf; text-align: center; width: 100%; }
    #menu Button { width: 100%; margin: 0 0 1 0; }

    CardView { border: round #8b949e; border-title-align: left; border-subtitle-align: right;
               padding: 0 1; height: auto; min-height: 7; width: 1fr; min-width: 28; background: #23242a; }
    CardView:hover { background: #2c2e36; }
    CardView.N { border: round #8b949e; border-title-color: #8b949e; }
    CardView.R { border: round #61afef; border-title-color: #61afef; }
    CardView.SR { border: round #c678dd; border-title-color: #c678dd; }
    CardView.SSR { border: heavy #f5c542; border-title-color: #f5c542; background: #2a2720; }
    CardView.lord { border: round #e06c75; border-title-color: #e06c75; }
    .card-grid { grid-size: 4; grid-gutter: 1 2; height: auto; padding: 0 2; }
    #gacha-results { grid-size: 5; }
    .empty-slot { border: dashed #3b3f4a; width: 1fr; height: 9; content-align: center middle; color: #5c6370; }

    #story-title { height: 3; padding: 1 2 0 2; text-style: bold; color: #f5c542; }
    #story-body { padding: 1 4; }
    .story-text { padding: 0 0 1 0; color: #d7dae0; }
    .choice-row { height: auto; }
    .choice { width: 1fr; height: auto; padding: 0 1; }
    .choice Button { width: 100%; }
    #story-actions { height: auto; padding: 0 4 1 4; }
    #story-actions Button { margin-right: 2; }

    #gacha-actions { height: auto; padding: 0 2 1 2; }
    #gacha-actions Button { margin-right: 2; }
    #pool-left { padding: 1 2; color: #abb2bf; }

    #filters { height: auto; padding: 0 2; }
    .filter { min-width: 8; margin-right: 1; }
    #collection { height: 1fr; padding: 1 2; }
    #collection DataTable { width: 1fr; }
    #detail { width: 40; padding-left: 2; }
    .skill-list { padding: 1 0; color: #abb2bf; }

    #slots { height: auto; padding: 0 2; }
    #party-actions { height: auto; padding: 1 2; }
    #party-power { padding: 1 2; }
    PartyScreen DataTable { height: 1fr; margin: 0 2; }

    #battle-head { height: 1; padding: 0 2; background: #25262c; }
    .side-label { padding: 0 2; color: #98c379; text-style: bold; }
    .enemy-label { color: #e06c75; }
    #enemies, #players { height: auto; padding: 0 1; }
    .unit { border: round #4b5263; width: 1fr; height: 7; padding: 0 1; margin: 0 1; background: #23242a; }
    .unit.enemy { border: round #be5046; }
    .unit.ready { border: round #98c379; }
    .unit.selected { border: heavy #f5c542; background: #2e2b22; }
    .unit.targetable { border: heavy #e5c07b; background: #2e2b22; }
    .unit.dead { border: round #2f323b; color: #5c6370; background: #1b1c21; }
    #battle-bottom { height: 1fr; padding: 0 1; }
    #controls { width: 52; padding: 0 1; }
    #prompt { height: auto; padding: 1 0; color: #e5c07b; }
    #skills { height: auto; }
    .skill { width: 100%; margin-bottom: 0; }
    #end { width: 100%; margin-top: 1; }
    #log { width: 1fr; border: round #3b3f4a; background: #202126; }

    #scenarios { padding: 1 4; height: auto; }
    .scenario { width: 100%; margin-bottom: 1; }

    ModalScreen { align: center middle; background: rgba(0,0,0,0.6); }
    #dialog { width: 50; height: auto; padding: 1 2; border: heavy #f5c542; background: #23242a; }
    #dialog.lose { border: heavy #e06c75; }
    #dialog Button { width: 100%; margin-top: 1; }
    #result-text { text-align: center; text-style: bold; color: #f5c542; padding: 1 0; }
    #dialog.lose #result-text { color: #e06c75; }
    """

    def __init__(self, save_path: Path, new: bool = False, seed: int | None = None) -> None:
        super().__init__()
        self.db = load_db()
        self.st = story.load_story(self.db)
        self.save_path = save_path
        self.seed = seed
        self.rng = random.Random(seed)
        self.fresh = new or not save_path.exists()
        self.save = col.Save.new(self.db) if self.fresh else col.Save.load(save_path)

    def persist(self) -> None:
        self.save.dump(self.save_path)

    def on_mount(self) -> None:
        self.push_screen(MenuScreen())
        if self.fresh:
            def named(name: str | None) -> None:
                self.save.lord_name = name or "主公"
                self.persist()
                self.push_screen(StoryScreen())
            self.push_screen(NameModal(), named)

    def on_unmount(self) -> None:
        self.persist()


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(prog="sanguo", description="三国卡牌")
    ap.add_argument("--save", type=Path, default=col.DEFAULT_SAVE, help=f"存档路径（默认 {col.DEFAULT_SAVE}）")
    ap.add_argument("--new", action="store_true", help="忽略旧存档，重新开始")
    ap.add_argument("--seed", type=int, default=None, help="固定随机种子（抽卡与战斗）")
    ap.add_argument("--plain", action="store_true", help="纯文字模式（不用终端界面）")
    args = ap.parse_args(argv)
    if args.plain:
        from . import cli
        rest = ["--save", str(args.save)] + (["--new"] if args.new else []) + \
               (["--seed", str(args.seed)] if args.seed is not None else [])
        cli.main(rest)
        return
    SanguoApp(args.save, new=args.new, seed=args.seed).run()


if __name__ == "__main__":
    main()
