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
from .battle import Battle
from .cards import LORD, RARITIES, CardDB, Fighter, Leader, Skill, build_fighter, load_db, power, power_split

RARITY_COLOR = {"N": "#8b949e", "R": "#61afef", "SR": "#c678dd", "SSR": "#f5c542", None: "#e06c75"}


def skill_desc(sk: Skill) -> str:
    """Short plain-text summary of what a skill does."""
    parts = []
    for e in sk.effects:
        t = e["type"]
        if t in ("attack", "magic"):
            hits = f" ×{e['hits']}连" if e.get("hits", 1) > 1 else ""
            parts.append(f"{'攻击' if t == 'attack' else '魔法'}{e['power']}倍{hits}")
        elif t == "heal":
            parts.append(f"回复 攻击×{e['power']}")
        elif t == "guard":
            parts.append(f"减伤{round(e['cut'] * 100)}%")
        elif t == "boost":
            parts.append("全军BOOST" if e["target"] == "all" else "自身BOOST")
        elif t == "stun":
            parts.append(f"混乱{round(e['chance'] * 100)}%")
        elif t == "break":
            parts.append(f"破防+{round(e['amount'] * 100)}%")
        elif t == "ap":
            parts.append(f"AP+{e['amount']}")
    tag = "限1次" if sk.uses == 1 else ("累积" if sk.cumulative else "")
    return f"AP{sk.cost}{' ' + tag if tag else ''}：" + "、".join(parts)


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
            f"体力 {f.hp}  攻击 {f.at}\n"
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
    table.add_columns("", "稀有", "兵种", "武将", "战力", "兵种+武将", "体力", "攻击", "技能")
    fighters = [f for f in col.owned_fighters(db, save) if troop is None or f.troop == troop]
    for f in sorted(fighters, key=lambda f: (-RARITIES.index(f.rarity), -power(f))):
        tp, gp = power_split(db, f)
        color = RARITY_COLOR[f.rarity]
        table.add_row("◆" if f.id in save.party else "", f"[{color}]{f.rarity}[/]", db.troops[f.troop].name,
                      f"[{color}]{escape(f.name)}[/]", f"[b]{power(f)}[/]", f"{tp}+{gp}",
                      f.hp, f.at, "、".join(db.skills[s].name for s in f.skills), key=f.id)


def leader_note(ld: Leader) -> str:
    backing = f"部队 {len(ld.members) + 1} 人 · " if ld.members else ""
    return f"[#e5c07b]{backing}队长 攻击{ld.at} 体力{ld.hp}[/]"


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
            enemy = app.db.enemies[sc.enemy].name
            body.mount(Static(f"即将开战：[b]{sc.name}[/]　敌军：{enemy}\n\n当前编成：", classes="story-text"))
            grid = Grid(classes="card-grid")
            body.mount(grid)
            for ld in col.party_leaders(app.db, app.save):
                grid.mount(CardView(app.db, ld.card, note=leader_note(ld)))
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
            skills = "\n".join(f"[b]{app.db.skills[s].name}[/]  {skill_desc(app.db.skills[s])}" for s in f.skills)
            ld = col.leader_for(app.db, app.save, f.id)
            detail.mount(Static(skills + "\n\n当队长时：" + leader_note(ld), classes="skill-list"))


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
        party = col.party_leaders(app.db, app.save)
        for ld in party:
            slots.mount(CardView(app.db, ld.card, note=leader_note(ld)))
        for _ in range(app.save.party_slots - len(party)):
            slots.mount(Static("\n\n空位", classes="empty-slot"))
        self.query_one("#party-power", Static).update(
            f"全军体力 [b #98c379]{sum(ld.hp for ld in party)}[/]　队长攻击合计 [b #f5c542]{sum(ld.at for ld in party)}[/]"
            "　[dim]同兵种的其他卡会自动编入该队长的部队，加成队长[/]")
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

class LeaderView(Vertical):
    """One leader in the bottom row: its stats and one button per skill (Rance X style)."""

    def __init__(self, idx: int, skill_ids: tuple[str, ...], **kw) -> None:
        super().__init__(**kw)
        self.idx = idx
        self.skill_ids = skill_ids

    def compose(self) -> ComposeResult:
        yield Static(classes="leader-info")
        for sid in self.skill_ids:
            yield Button("", name=f"{self.idx}:{sid}", classes="skill")


class BattleScreen(Screen[bool]):
    BINDINGS = ([Binding(str(i), f"num({i})", show=False) for i in range(1, 10)]
                + [Binding("e", "end_round", "回合结束"), Binding("d", "defend", "防御"),
                   Binding("r", "retreat", "撤退"), Binding("escape", "cancel", "取消")])

    def __init__(self, scenario_id: str) -> None:
        super().__init__()
        self.scenario_id = scenario_id
        self.selected: int | None = None

    def compose(self) -> ComposeResult:
        app: SanguoApp = self.app  # type: ignore[assignment]
        self.b = Battle.start(app.db, self.scenario_id, col.party_leaders(app.db, app.save), seed=app.seed)
        yield Static(id="enemy-panel")
        yield RichLog(id="log", markup=True, wrap=True)
        with Horizontal(id="party-bar"):
            yield Static(id="party-status")
            yield Button("防御 (D)", id="defend", variant="primary")
            yield Button("回合结束 (E)", id="end", variant="error")
        with Horizontal(id="leaders"):
            for i, u in enumerate(self.b.leaders):
                yield LeaderView(i, u.leader.card.skills, classes="leader")
        yield Footer()

    def on_mount(self) -> None:
        b = self.b
        self.query_one("#enemy-panel", Static).border_title = escape(b.enemy.name)
        for view in self.query(LeaderView):
            u = b.leaders[view.idx]
            view.border_title = f"{view.idx + 1}. {escape(u.name)}"
            view.border_subtitle = self.app.db.troops[u.leader.card.troop].name  # type: ignore[attr-defined]
        self.log_lines([f"[b]【{b.scenario.name}】[/] {b.scenario.turn_limit} 回合内击破 {escape(b.enemy.name)}。"
                        "每位队长每回合行动一次；AP 每回合 +2，最多 6。"] + b.opening)
        self.refresh_all()

    # -- rendering

    def log_lines(self, lines: list[str]) -> None:
        log = self.query_one("#log", RichLog)
        enemy = False
        for line in lines:
            line = escape(line) if not line.startswith("[b]") else line
            if line.startswith("——"):
                enemy = True
                log.write(f"[b #e06c75]{line}[/]")
            elif line.startswith("───"):
                enemy = False
                log.write(f"[dim]{line}[/]")
            elif line.startswith("插入"):
                log.write(f"[#c678dd]{line}[/]")
            elif line.startswith("  "):
                log.write(f"[#abb2bf]{line}[/]")
            else:
                log.write(f"[#e06c75]{line}[/]" if enemy else f"[#98c379]{line}[/]")

    def refresh_all(self) -> None:
        b = self.b
        e = b.enemy
        tags = []
        if e.stunned:
            tags.append("[#c678dd]混乱：下回合无法行动[/]")
        if e.break_turns:
            tags.append(f"[#e5c07b]破防 +{round(e.break_amount * 100)}%（{e.break_turns} 回合）[/]")
        pct = 100 * e.hp / e.max_hp
        self.query_one("#enemy-panel", Static).update(
            f"{hp_bar(e.hp, e.max_hp, 64)}  [b]{e.hp}[/]/{e.max_hp}  ({pct:.0f}%)\n"
            f"[dim]攻击 {e.data.at} · 每回合行动 {e.data.actions} 次[/]   {'  '.join(tags)}")

        cfg = b.db.battle
        pips = "[#f5c542]" + "●" * b.ap + "[/][#3b3f4a]" + "○" * (cfg["ap_max"] - b.ap) + "[/]"
        extras = []
        if b.combo:
            extras.append(f"[#e5c07b]{b.combo} 连击 (+{b.combo * 10}%)[/]")
        if b.guard_cut:
            extras.append(f"[#61afef]减伤 {round(b.guard_cut * 100)}%[/]")
        self.query_one("#party-status", Static).update(
            f"体力 {hp_bar(b.party_hp, b.party_max, 40)}  [b]{b.party_hp}[/]/{b.party_max}\n"
            f"AP {pips} {b.ap}/{cfg['ap_max']}    第 [b]{b.round}[/]/{b.scenario.turn_limit} 回合    "
            + "    ".join(extras))

        for view in self.query(LeaderView):
            u = b.leaders[view.idx]
            if u.confused:
                state = "[#c678dd]混乱[/]"
            elif u.acted:
                state = "[dim]已行动[/]"
            elif b.can_act(view.idx):
                state = "[#98c379]可行动[/]"
            else:
                state = "[dim]AP 不足[/]"
            boost = "  [b #f5c542]BOOST[/]" if u.boosted else ""
            members = f" · 部队 {len(u.leader.members) + 1} 人" if u.leader.members else ""
            view.query_one(".leader-info", Static).update(f"攻击 [b]{u.at}[/]{members}\n{state}{boost}")
            view.set_class(b.can_act(view.idx), "ready")
            view.set_class(view.idx == self.selected, "selected")
            view.set_class(u.acted or u.confused, "spent")
            for n, btn in enumerate(view.query(Button)):
                sk = b.db.skills[btn.name.split(":")[1]]
                left = u.uses_left[sk.id]
                tag = "限1" if sk.uses == 1 else ("累积" if sk.cumulative else "")
                cost = b.cost(u, sk)
                btn.label = f"{n + 1} {sk.name}  AP{cost}" + (f" {tag}" if tag else "") + (" ✗" if left == 0 else "")
                btn.tooltip = skill_desc(sk)
                btn.disabled = not (b.can_act(view.idx) and b.usable(u, sk))

    # -- input

    def action_num(self, n: int) -> None:
        b = self.b
        if b.result:
            return
        i = n - 1
        if self.selected is None:
            if i < len(b.leaders) and b.can_act(i):
                self.selected = i
                self.refresh_all()
            return
        u = b.leaders[self.selected]
        skills = u.leader.card.skills
        if i < len(skills) and b.usable(u, b.db.skills[skills[i]]):
            self.fire(self.selected, skills[i])

    @on(Button.Pressed, ".skill")
    def skill_pressed(self, event: Button.Pressed) -> None:
        i, sid = event.button.name.split(":")
        self.fire(int(i), sid)

    @on(Button.Pressed, "#end")
    def end_pressed(self) -> None:
        self.action_end_round()

    @on(Button.Pressed, "#defend")
    def defend_pressed(self) -> None:
        self.action_defend()

    def fire(self, i: int, sid: str) -> None:
        self.selected = None
        self.log_lines(self.b.act(i, sid))
        self.refresh_all()
        self.check_result()

    def action_cancel(self) -> None:
        self.selected = None
        self.refresh_all()

    def action_end_round(self) -> None:
        if self.b.result:
            return
        self.selected = None
        self.log_lines(self.b.end_round())
        self.refresh_all()
        self.check_result()

    def action_retreat(self) -> None:
        if self.b.result:
            return
        self.log_lines(self.b.retreat())
        self.refresh_all()
        self.check_result()

    def action_defend(self) -> None:
        if self.b.result:
            return
        self.selected = None
        self.log_lines(self.b.defend())
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
                e = app.db.enemies[sc.enemy]
                done = " ✓" if sid in app.save.cleared else ""
                yield Button(f"{sc.name}{done}　—　{e.name}（体力 {e.hp}）", id=f"sc-{sid}", classes="scenario")
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

    #enemy-panel { height: auto; margin: 0 1; padding: 0 2; border: heavy #be5046;
                   border-title-color: #e06c75; border-title-style: bold; background: #2a1f20; }
    BattleScreen #log { height: 1fr; margin: 0 1; border: round #3b3f4a; background: #202126; }
    #party-bar { height: auto; margin: 0 1; padding: 0 1; border: round #98c379; background: #1f2622; }
    #party-status { width: 1fr; }
    #party-bar Button { margin-left: 1; min-width: 16; }
    #leaders { height: auto; padding: 0 1; }
    .leader { width: 1fr; height: auto; margin: 0 1 0 0; padding: 0 1; border: round #4b5263;
              border-title-color: #d7dae0; background: #23242a; }
    .leader.ready { border: round #98c379; }
    .leader.selected { border: heavy #f5c542; background: #2e2b22; }
    .leader.spent { background: #1d1e22; color: #5c6370; }
    .leader-info { height: 2; }
    .leader .skill { width: 100%; min-width: 10; height: 1; border: none; margin-top: 1; }

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
    args = ap.parse_args(argv)
    SanguoApp(args.save, new=args.new, seed=args.seed).run()


if __name__ == "__main__":
    main()
