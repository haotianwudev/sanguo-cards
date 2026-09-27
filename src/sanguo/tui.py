"""Textual front end: panels, colours, HP bars, mouse + keyboard. Rules live in battle/collection/story;
this module only renders state and turns clicks/keys into calls on them."""
from __future__ import annotations

import argparse
import json
import random
from importlib import resources
from pathlib import Path

from rich.markup import escape
from rich.text import Text
from textual import on
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Center, Grid, Horizontal, Vertical, VerticalScroll
from textual.message import Message
from textual.screen import ModalScreen, Screen
from textual.theme import Theme
from textual.widgets import Button, DataTable, Footer, Input, Label, RichLog, Static

from . import collection as col
from . import portrait, quest
from .battle import Battle
from .cards import LORD, RARITIES, CardDB, Fighter, Leader, Skill, build_fighter, load_db, power, power_split

# Two palettes. Markup colours in Python read from C (updated in place by set_palette);
# CSS reads the same names as $sg-* theme variables.
UI = json.loads(resources.files("sanguo.data").joinpath("ui.json").read_text("utf-8"))
PALETTES: dict[str, dict[str, str]] = UI["themes"]


class _Palette:
    def use(self, name: str) -> None:
        for k, v in PALETTES[name].items():
            setattr(self, k.replace("-", "_"), v)
        RARITY_COLOR.update({(None if r == "lord" else r): PALETTES[name][c] for r, c in UI["rarity_colors"].items()})


RARITY_COLOR: dict = {}
C = _Palette()
C.use(UI["default_theme"])


def make_themes() -> list[Theme]:
    out = []
    for name, pal in PALETTES.items():
        out.append(Theme(name=f"sanguo-{name}", dark=name == "dark", primary=pal["blue"], secondary=pal["purple"],
                         accent=pal["gold"], error=pal["red"], success=pal["green"], warning=pal["amber"],
                         foreground=pal["text"], background=pal["bg"], surface=pal["card"], panel=pal["panel"],
                         variables={f"sg-{k}": v for k, v in pal.items()}))
    return out


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
    color = C.green if frac > 0.5 else C.amber if frac > 0.25 else C.red
    return f"[{color}]{'█' * filled}[/][{C.track}]{'░' * (width - filled)}[/]"


def card_body(db: CardDB, f: Fighter) -> str:
    troop_p, general_p = power_split(db, f)
    split = f"兵种 {troop_p} + 武将 {general_p}" if general_p else f"兵种 {troop_p}"
    skills = " · ".join(db.skills[s].name for s in f.skills)
    return (f"[b]{db.troops[f.troop].name}[/]  战力 [b {C.gold}]{power(f)}[/]\n"
            f"[dim]{split}[/]\n"
            f"体力 {f.hp}  攻击 {f.at}\n"
            f"[{C.muted}]{skills}[/]")


class Portrait(Static):
    """A character portrait that redraws itself to fit whatever size the layout gives it."""

    def __init__(self, key: str, heads: float = 3.0, **kw) -> None:
        super().__init__(**kw)
        self.key = key
        self.heads = heads

    def render(self):
        w, h = self.content_size.width, self.content_size.height
        if w <= 0 or h <= 0:
            return ""
        return portrait.render(self.key, w, h, self.heads)


class CardView(Vertical):
    """A card with a rarity-coloured border (and portrait, when there is art). Clicking posts CardView.Clicked."""

    class Clicked(Message):
        def __init__(self, card_id: str) -> None:
            super().__init__()
            self.card_id = card_id

    def __init__(self, db: CardDB, f: Fighter, note: str = "", show_portrait: bool = True, **kw) -> None:
        super().__init__(**kw)
        self.db, self.f, self.note, self.show_portrait = db, f, note, show_portrait
        self.card_id = f.id
        self.border_title = escape(f.name)
        self.border_subtitle = rarity_label(f.rarity)
        self.add_class(f.rarity or "lord")

    def compose(self) -> ComposeResult:
        key = portrait.key_for(self.db, self.f.id) if self.show_portrait else None
        body = Static(card_body(self.db, self.f) + (f"\n{self.note}" if self.note else ""), classes="card-body")
        if key:
            with Horizontal(classes="card-row"):
                yield Portrait(key, heads=FRAMING["card"], classes="card-portrait")
                yield body
        else:
            yield body

    def on_click(self) -> None:
        self.post_message(self.Clicked(self.card_id))


def card_table(db: CardDB, save: col.Save, table: DataTable, troop: str | None = None) -> None:
    table.clear(columns=True)
    table.add_columns("", "稀有", "兵种", "卡牌", "张数", "战力", "兵种+武将", "体力", "攻击", "技能")
    fighters = [f for f in col.owned_fighters(db, save) if troop is None or f.troop == troop]
    for f in sorted(fighters, key=lambda f: (-RARITIES.index(f.rarity), -power(f))):
        tp, gp = power_split(db, f)
        color = RARITY_COLOR[f.rarity]
        n = col.copies(db, save, f.id)
        table.add_row("◆" if f.id in save.party else "", f"[{color}]{rarity_label(f.rarity)}[/]",
                      db.troops[f.troop].name, f"[{color}]{escape(f.name)}[/]", f"×{n}" if db.cards[f.id].soldier else "",
                      f"[b]{power(f)}[/]", f"{tp}+{gp}", f.hp, f.at,
                      "、".join(db.skills[s].name for s in f.skills), key=f.id)


def rarity_label(rarity: str | None) -> str:
    return UI["rarity_labels"].get(rarity or "lord", rarity or "")


def leader_note(ld: Leader) -> str:
    backing = f"部队 {len(ld.members) + 1} 人 · " if ld.members else ""
    return f"[{C.amber}]{backing}队长 攻击{ld.at} 体力{ld.hp}[/]"


# ---- main menu ---------------------------------------------------------------

TITLE_ART = "[b]三　国　卡　牌[/]\n[dim]穿越江东 · 抽卡组军[/]"


class MenuScreen(Screen):
    BINDINGS = [Binding(str(i), f"go({i})", show=False) for i in range(1, 7)] + [
        Binding("t", "toggle_theme", "亮/暗主题"), Binding("q", "app.quit", "退出")]

    def action_toggle_theme(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        app.save.theme = "dark" if app.save.theme == "light" else "light"
        app.apply_theme(app.save.theme)
        app.persist()
        self.refresh_status()

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
        cur = quest.current_quest(app.quests, app.save)
        chapter = cur.title if cur else "暂无新章节"
        self.query_one("#status", Static).update(
            f"[b]{escape(app.save.lord_name)}[/]   卡册 {len(app.save.owned)}/{len(app.db.cards)}"
            f"   编成 {len(app.save.party) + 1}/{app.save.party_slots}\n[dim]剧情：{chapter}[/]")

    @on(Button.Pressed)
    def pressed(self, event: Button.Pressed) -> None:
        self.action_go(int(event.button.id[1:]))

    def action_go(self, n: int) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        screens = {1: QuestScreen, 2: GachaScreen, 3: CollectionScreen, 4: PartyScreen, 5: ScenarioScreen}
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


# ---- quest map ---------------------------------------------------------------

SQUARE_GLYPH: dict[str, str] = UI["map"]["glyphs"]
TYPE_NAME: dict[str, str] = UI["map"]["type_names"]
CELL: int = UI["map"]["cell"]  # map columns per square: 4 for the square, the rest for the link
FRAMING: dict[str, float] = UI["portrait_framing"]


def _glyph(s: quest.Square) -> str:
    return SQUARE_GLYPH["boss"] if s.boss else SQUARE_GLYPH[s.type]


def _type_color(s: quest.Square) -> str:
    return getattr(C, UI["map"]["type_colors"]["boss" if s.boss else s.type].replace("-", "_"))


def map_text(q: quest.Quest, save: col.Save) -> Text:
    """Draw the quest map: squares on rows 0-2, links between neighbouring columns."""
    width = (max(s.x for s in q.squares.values()) + 1) * CELL
    lines = 3 * 3 - 1
    grid: list[list[tuple[str, str] | None]] = [[(" ", "")] * width for _ in range(lines)]
    visited = set(save.visited)
    reachable = {s.id for s in quest.next_options(q, save)}
    path_pairs = set(zip(save.visited, save.visited[1:]))

    def put(line: int, col_: int, text: str, style: str) -> None:
        for ch in text:
            wide = ord(ch) > 0x2E80
            grid[line][col_] = (ch, style)
            if wide:
                grid[line][col_ + 1] = None
                col_ += 2
            else:
                col_ += 1

    for s in q.squares.values():
        targets = list(s.next) + [o["goto"] for o in s.choose]
        for t in targets:
            ts = q.squares[t]
            on_path = (s.id, t) in path_pairs
            if not on_path and s.type == "choose" and s.id in save.choices and save.choices[s.id] != t:
                style = C.border
            else:
                style = f"bold {C.gold}" if on_path else C.track
            base = s.x * CELL
            if ts.y == s.y:
                put(3 * s.y, base + 4, "────", style)
            elif ts.y == s.y + 1:
                put(3 * s.y + 1, base + 5, "╲", style)
                put(3 * s.y + 2, base + 6, "╲", style)
            else:
                put(3 * s.y - 1, base + 5, "╱", style)
                put(3 * s.y - 2, base + 6, "╱", style)
    for s in q.squares.values():
        if s.id == save.square:
            style = f"bold {C.bg} on {C.gold}"
        elif s.id in reachable:
            style = f"bold {C.bg} on {C.green}"
        elif s.id in visited:
            style = f"{C.dim} on {C.track}"
        else:
            style = f"bold {_type_color(s)} on {C.panel}"
        put(3 * s.y, s.x * CELL, f" {_glyph(s)} ", style)
        label = (s.label or TYPE_NAME[s.type])[:2]
        put(3 * s.y + 1, s.x * CELL, label, C.muted if s.id not in visited else C.dim)

    text = Text(no_wrap=True, overflow="crop")
    for i, row in enumerate(grid):
        for cell in row:
            if cell is not None:
                text.append(cell[0], cell[1] or None)
        if i < lines - 1:
            text.append("\n")
    return text


class QuestScreen(Screen):
    BINDINGS = ([Binding("escape", "app.pop_screen", "回主菜单"), Binding("enter", "primary", "继续")]
                + [Binding(str(i), f"step({i})", show=False) for i in range(1, 4)])

    def compose(self) -> ComposeResult:
        yield Static(id="quest-head")
        yield Static(id="quest-map")
        yield Static(id="quest-legend")
        yield VerticalScroll(id="quest-body")
        yield Horizontal(id="quest-actions")
        yield Footer()

    def on_mount(self) -> None:
        self.render_all()

    def on_screen_resume(self) -> None:
        self.render_all()

    # -- rendering

    def render_all(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        body = self.query_one("#quest-body", VerticalScroll)
        actions = self.query_one("#quest-actions", Horizontal)
        body.remove_children()
        actions.remove_children()
        q = quest.ensure_started(app.quests, app.save)
        app.persist()
        if q is None:
            self.query_one("#quest-head", Static).update("剧情")
            self.query_one("#quest-map", Static).update("")
            self.query_one("#quest-legend", Static).update("")
            body.mount(Static("剧情暂时到此为止。去招募、编成，或者自由出战吧。", classes="story-text"))
            actions.mount(Button("返回主菜单", name="back"))
            return
        s = quest.here(q, app.save)
        party = col.party_leaders(app.db, app.save)
        hp_max = sum(ld.hp for ld in party)
        hp = max(1, hp_max - app.save.damage)
        worn = sum(n for d in app.save.carry_extra.values() for n in d.values())
        wear = f"　[{C.amber}]累积技能已加价 +{worn}[/]" if worn else ""
        self.query_one("#quest-head", Static).update(
            f"[b {C.gold}]{q.title}[/]　　体力 {hp_bar(hp, hp_max, 30)} {hp}/{hp_max}{wear}\n"
            f"[dim]任务中体力不会自动回满，只有「休」格能回复；输掉战斗要从任务开头重来。[/]")
        self.query_one("#quest-map", Static).update(map_text(q, app.save))
        self.query_one("#quest-legend", Static).update(
            f"[{C.gold}]■[/] 当前　[{C.green}]■[/] 可前往　"
            f"[{C.red}]战[/] 战斗　[{C.purple}]将[/] 首领　[{C.gold}]宝[/] 宝箱　[{C.blue}]休[/] 回复　事 剧情　[{C.amber}]选[/] 抉择")
        self.render_square(q, s, body, actions)

    def render_square(self, q: quest.Quest, s: quest.Square, body: VerticalScroll, actions: Horizontal) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        lord = escape(app.save.lord_name)
        title = f"[b]{_glyph(s)} {s.label or TYPE_NAME[s.type]}[/]　[dim]{TYPE_NAME[s.type]}[/]"
        body.mount(Static(title, classes="square-title"))
        if s.type == "event" and s.text:
            text = "\n\n".join(escape(line).replace("{lord}", f"[b {C.red}]{lord}[/]") for line in s.text)
            keys = [k for k in s.portraits if k in portrait._index()]
            if keys:
                row = Horizontal(classes="story-row")
                body.mount(row)
                for k in keys:
                    row.mount(Portrait(k, heads=FRAMING["story"], classes="story-portrait"))
                row.mount(Static(text, classes="story-text story-side"))
            else:
                body.mount(Static(text, classes="story-text"))
        if not app.save.resolved:
            if s.type in ("event",):
                actions.mount(Button("继续 ▶ (Enter)", name="resolve", variant="primary"))
            elif s.type == "choose":
                row = Horizontal(classes="choice-row")
                body.mount(row)
                for i, opt in enumerate(s.choose):
                    col_ = Vertical(classes="choice")
                    row.mount(col_)
                    col_.mount(CardView(app.db, build_fighter(app.db, opt["card"])))
                    col_.mount(Button(f"{i + 1}. {opt['label']}", name=f"choose-{i}", variant="warning"))
            elif s.type == "battle":
                sc = app.db.scenarios[s.battle]
                e = app.db.enemies[sc.enemy]
                boss = f"[b {C.purple}]首领战[/]　" if s.boss else ""
                body.mount(Static(f"{boss}敌军：[b]{e.name}[/]　体力 {e.hp}　攻击 {e.at}　每回合 {e.actions} 次行动　"
                                  f"{sc.turn_limit} 回合内击破\n\n当前编成：", classes="story-text"))
                grid = Grid(classes="card-grid")
                body.mount(grid)
                for ld in col.party_leaders(app.db, app.save):
                    grid.mount(CardView(app.db, ld.card, note=leader_note(ld)))
                actions.mount(Button("⚔ 出战 (Enter)", name="fight", variant="error"))
                actions.mount(Button("先去整备（回主菜单）", name="back"))
            elif s.type in ("treasure", "recruit"):
                cards = quest.offer(app.db, q, app.save, app.rng)
                app.persist()
                if s.type == "treasure":
                    msg = "宝箱里有几张兵卡，只能拿一张。同种兵卡越多部队越强，但重复的会衰减——缺什么拿什么。"
                else:
                    msg = "闻名而来的豪杰，只能收下一位。"
                body.mount(Static(msg, classes="story-text"))
                if cards:
                    self.call_later(mount_offer, body, app.db, cards)
                else:
                    actions.mount(Button("空空如也，继续 (Enter)", name="resolve", variant="primary"))
            elif s.type == "recover":
                body.mount(Static("可以在这里休整：体力回满，累积技能的 AP 加价和限 1 次技能全部重置。", classes="story-text"))
                actions.mount(Button("休整 (Enter)", name="resolve", variant="primary"))
            return
        # resolved: where to next?
        if s.type == "choose":
            chosen = next(o for o in s.choose if o["goto"] == app.save.choices[s.id])
            body.mount(Static(f"已选择：{chosen['label']}", classes="story-text"))
        elif s.type == "battle":
            body.mount(Static(f"[{C.green}]已击破。[/]", classes="story-text"))
        elif s.type == "recover":
            body.mount(Static(f"[{C.blue}]休整完毕，体力全满。[/]", classes="story-text"))
        if self._gained:
            body.mount(Static("获得卡牌：", classes="story-text"))
            grid = Grid(classes="card-grid")
            body.mount(grid)
            for c in self._gained:
                grid.mount(CardView(app.db, build_fighter(app.db, c.id), note=f"[b {C.gold}]✦ NEW[/]"))
        opts = quest.next_options(q, app.save)
        if not opts:
            actions.mount(Button("完成任务 ▶ (Enter)", name="complete", variant="success"))
            return
        for i, n in enumerate(opts):
            actions.mount(Button(f"{i + 1}. 前往 {_glyph(n)} {n.label or TYPE_NAME[n.type]}", name=f"move-{n.id}",
                                 variant="primary" if i == 0 else "default"))

    _gained: list = []

    # -- actions

    def action_primary(self) -> None:
        names = [b.name for b in self.query_one("#quest-actions", Horizontal).query(Button)]
        for name in ("resolve", "fight", "complete"):
            if name in names:
                self.do(name)
                return
        moves = [n for n in names if n and n.startswith("move-")]
        if len(moves) == 1:
            self.do(moves[0])

    def action_step(self, n: int) -> None:
        names = [b.name for b in self.query(Button)
                 if b.name and b.name.split("-")[0] in ("move", "choose", "pick")]
        if n - 1 < len(names):
            self.do(names[n - 1])

    @on(Button.Pressed)
    def pressed(self, event: Button.Pressed) -> None:
        if event.button.name:
            self.do(event.button.name)

    def do(self, name: str) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        q = quest.current_quest(app.quests, app.save)
        if name == "back" or q is None:
            app.pop_screen()
            return
        s = quest.here(q, app.save)
        if name == "resolve":
            self._gained = quest.resolve(app.db, q, app.save, app.rng)
        elif name.startswith("choose-") or name.startswith("pick-"):
            self._gained = quest.resolve(app.db, q, app.save, app.rng, int(name.split("-")[1]))
        elif name.startswith("move-"):
            self._gained = []
            quest.move(q, app.save, name[5:])
        elif name == "complete":
            self._gained = []
            quest.complete(q, app.save)
            self.notify(f"「{q.title}」完成！", title="任务")
        elif name == "fight":
            def after(won: bool | None) -> None:
                if won:
                    self._gained = quest.resolve(app.db, q, app.save, app.rng)
                else:
                    quest.fail(q, app.save)
                    self.notify("任务失败 —— 从任务开头重新出发（已获得的卡和做过的选择保留）", severity="warning", timeout=6)
                app.persist()
                self.render_all()

            app.push_screen(BattleScreen(s.battle, carry=True, boss=s.boss), after)
            return
        app.persist()
        self.render_all()


# ---- gacha -------------------------------------------------------------------

async def mount_offer(parent, db: CardDB, cards: list, name_prefix: str = "pick") -> None:
    row = Horizontal(classes="choice-row")
    await parent.mount(row)
    for i, c in enumerate(cards):
        col_ = Vertical(classes="choice")
        await row.mount(col_)
        await col_.mount(CardView(db, build_fighter(db, c.id)))
        await col_.mount(Button(f"{i + 1}. 选这张", name=f"{name_prefix}-{i}", variant="warning"))


class GachaScreen(Screen):
    """招募: a few unowned generals are shown; keep one. Unlimited."""
    BINDINGS = [Binding("escape", "app.pop_screen", "返回"), Binding("enter", "roll", "招募")] + \
        [Binding(str(i), f"pick({i})", show=False) for i in range(1, 6)]

    def compose(self) -> ComposeResult:
        yield Static("招募　[dim]每次亮出几位武将，只能带走一位[/]", classes="screen-title")
        with Horizontal(id="gacha-actions"):
            yield Button("招募 (Enter)", id="roll", variant="primary")
            yield Static(id="pool-left")
        yield VerticalScroll(id="gacha-results")
        yield Footer()

    def on_mount(self) -> None:
        self.offer: list = []
        self.update_left()

    def update_left(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        self.query_one("#pool-left", Static).update(f"尚未招募的武将 {col.pool_left(app.db, app.save)} 位")

    @on(Button.Pressed, "#roll")
    async def roll_pressed(self) -> None:
        await self.action_roll()

    async def action_roll(self) -> None:
        app: SanguoApp = self.app  # type: ignore[assignment]
        self.offer = col.recruit_offer(app.db, app.save, app.rng)
        box = self.query_one("#gacha-results", VerticalScroll)
        await box.remove_children()
        if not self.offer:
            self.notify("所有武将都已招募！", severity="warning")
            return
        await box.mount(Static("选一位带走：", classes="story-text"))
        await mount_offer(box, app.db, self.offer)
        if any(c.rarity == "SSR" for c in self.offer):
            self.notify("✦✦✦ 有 SSR！", title="招募")

    async def action_pick(self, n: int) -> None:
        if not self.offer or n - 1 >= len(self.offer):
            return
        app: SanguoApp = self.app  # type: ignore[assignment]
        card = col.take(app.db, app.save, self.offer[n - 1].id)
        self.offer = []
        app.persist()
        box = self.query_one("#gacha-results", VerticalScroll)
        await box.remove_children()
        await box.mount(Static(f"[b {C.gold}]{escape(card.name)}[/] 加入！　按 Enter 再招募", classes="story-text"))
        grid = Grid(classes="card-grid")
        await box.mount(grid)
        await grid.mount(CardView(app.db, build_fighter(app.db, card.id), note=f"[b {C.gold}]✦ NEW[/]"))
        self.update_left()

    @on(Button.Pressed)
    async def picked(self, event: Button.Pressed) -> None:
        if event.button.name and event.button.name.startswith("pick-"):
            await self.action_pick(int(event.button.name.split("-")[1]) + 1)


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
            key = portrait.key_for(app.db, f.id)
            if key:
                detail.mount(Portrait(key, heads=FRAMING["collection"], classes="big-portrait"))
            detail.mount(CardView(app.db, f, show_portrait=False))
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
            f"全军体力 [b {C.green}]{sum(ld.hp for ld in party)}[/]　队长攻击合计 [b {C.gold}]{sum(ld.at for ld in party)}[/]"
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

    def __init__(self, idx: int, skill_ids: tuple[str, ...], card_id: str, placeholder: str, **kw) -> None:
        super().__init__(**kw)
        self.idx = idx
        self.skill_ids = skill_ids
        self.card_id = card_id
        self.placeholder = placeholder

    def compose(self) -> ComposeResult:
        key = portrait.key_for(self.app.db, self.card_id)  # type: ignore[attr-defined]
        with Horizontal(classes="leader-row"):
            if key:
                yield Portrait(key, heads=FRAMING["leader"], classes="leader-portrait")
            else:
                yield Static(self.placeholder, classes="leader-portrait no-portrait")
            with Vertical(classes="leader-side"):
                yield Static(classes="leader-info")
                for sid in self.skill_ids:
                    yield Button("", name=f"{self.idx}:{sid}", classes="skill")


class BattleScreen(Screen[bool]):
    BINDINGS = ([Binding(str(i), f"num({i})", show=False) for i in range(1, 10)]
                + [Binding("e", "end_round", "回合结束"), Binding("d", "defend", "防御"),
                   Binding("r", "retreat", "撤退"), Binding("escape", "cancel", "取消")])

    def __init__(self, scenario_id: str, carry: bool = False, boss: bool = False) -> None:
        super().__init__()
        self.scenario_id = scenario_id
        self.boss = boss
        self.carry = carry  # quest battle: start with the quest's wear, hand it back afterwards
        self.selected: int | None = None

    def compose(self) -> ComposeResult:
        app: SanguoApp = self.app  # type: ignore[assignment]
        sv = app.save
        wear = dict(damage=sv.damage, extra=sv.carry_extra, uses=sv.carry_uses) if self.carry else {}
        self.b = Battle.start(app.db, self.scenario_id, col.party_leaders(app.db, sv), seed=app.seed, **wear)
        e = self.b.enemy.data
        key = portrait.key_for_enemy(e)
        with Horizontal(id="enemy-panel"):
            if key:
                yield Portrait(key, heads=FRAMING["enemy"], classes="enemy-portrait")
            yield Static(id="enemy-info")
        yield RichLog(id="log", markup=True, wrap=True)
        with Horizontal(id="party-bar"):
            yield Static(id="party-status")
            yield Button("防御 (D)", id="defend", variant="primary")
            yield Button("回合结束 (E)", id="end", variant="error")
        with Horizontal(id="leaders"):
            for i, u in enumerate(self.b.leaders):
                troop = app.db.troops[u.leader.card.troop]
                yield LeaderView(i, u.leader.card.skills, u.leader.card.id, f"\n\n\n〔{troop.name}〕",
                                 classes="leader")
        yield Footer()

    def on_mount(self) -> None:
        b = self.b
        self.query_one("#enemy-panel", Horizontal).border_title = escape(b.enemy.name)
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
                log.write(f"[b {C.red}]{line}[/]")
            elif line.startswith("───"):
                enemy = False
                log.write(f"[dim]{line}[/]")
            elif line.startswith("插入"):
                log.write(f"[{C.purple}]{line}[/]")
            elif line.startswith("  "):
                log.write(f"[{C.muted}]{line}[/]")
            else:
                log.write(f"[{C.red}]{line}[/]" if enemy else f"[{C.green}]{line}[/]")

    def refresh_all(self) -> None:
        b = self.b
        e = b.enemy
        tags = []
        if e.stunned:
            tags.append(f"[{C.purple}]混乱：下回合无法行动[/]")
        if e.break_turns:
            tags.append(f"[{C.amber}]破防 +{round(e.break_amount * 100)}%（{e.break_turns} 回合）[/]")
        pct = 100 * e.hp / e.max_hp
        self.query_one("#enemy-info", Static).update(
            f"{hp_bar(e.hp, e.max_hp, 64)}  [b]{e.hp}[/]/{e.max_hp}  ({pct:.0f}%)\n"
            f"[dim]攻击 {e.data.at} · 每回合行动 {e.data.actions} 次[/]   {'  '.join(tags)}")

        cfg = b.db.battle
        pips = f"[{C.gold}]" + "●" * b.ap + f"[/][{C.track}]" + "○" * (cfg["ap_max"] - b.ap) + "[/]"
        extras = []
        if b.combo:
            extras.append(f"[{C.amber}]{b.combo} 连击 (+{b.combo * 10}%)[/]")
        if b.guard_cut:
            extras.append(f"[{C.blue}]减伤 {round(b.guard_cut * 100)}%[/]")
        self.query_one("#party-status", Static).update(
            f"体力 {hp_bar(b.party_hp, b.party_max, 40)}  [b]{b.party_hp}[/]/{b.party_max}\n"
            f"AP {pips} {b.ap}/{cfg['ap_max']}    第 [b]{b.round}[/]/{b.scenario.turn_limit} 回合    "
            + "    ".join(extras))

        for view in self.query(LeaderView):
            u = b.leaders[view.idx]
            if u.confused:
                state = f"[{C.purple}]混乱[/]"
            elif u.acted:
                state = "[dim]已行动[/]"
            elif b.can_act(view.idx):
                state = f"[{C.green}]可行动[/]"
            else:
                state = "[dim]AP 不足[/]"
            boost = f"  [b {C.gold}]BOOST[/]" if u.boosted else ""
            members = f"部队 {len(u.leader.members) + 1} 人" if u.leader.members else "[dim]独自一人[/]"
            view.query_one(".leader-info", Static).update(f"攻击 [b]{u.at}[/]\n{members}\n{state}{boost}")
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
        chest: list = []
        if won:
            col.record_win(app.save, self.scenario_id)
            if self.carry:
                app.save.damage, extra, uses = self.b.carry_out()
                app.save.carry_extra.update(extra)
                app.save.carry_uses.update(uses)
            chest = col.chest_after_battle(app.db, app.rng, self.b.overkill, self.boss)
            app.persist()
        # dismiss on the next tick: dismissing from inside another screen's dismiss callback deadlocks
        app.push_screen(ResultModal(won, chest, self.b.overkill),
                        lambda _: self.app.call_later(self.dismiss, won))


class ResultModal(ModalScreen[None]):
    BINDINGS = [Binding("enter", "close", "确定"), Binding("escape", "close", show=False)] + \
        [Binding(str(i), f"pick({i})", show=False) for i in range(1, 6)]

    def __init__(self, won: bool, chest: list | None = None, overkill: float = 0.0) -> None:
        super().__init__()
        self.won = won
        self.chest = chest or []
        self.overkill = overkill

    def compose(self) -> ComposeResult:
        app: SanguoApp = self.app  # type: ignore[assignment]
        with Vertical(id="dialog", classes=("win" if self.won else "lose") + (" wide" if self.chest else "")):
            yield Static("★  胜 利  ★" if self.won else "✗  战 败", id="result-text")
            if not self.won:
                yield Static("[dim]调整编成或去招募，再来一次[/]")
                yield Button("确定", id="ok", variant="primary")
                return
            ok = f"　过量伤害 {round(self.overkill * 100)}%" if self.overkill else ""
            if not self.chest:
                yield Static(f"[dim]没有掉落宝箱{ok}（过量伤害越高越容易掉）[/]")
                yield Button("确定", id="ok", variant="primary")
                return
            yield Static(f"[{C.gold}]宝箱！[/]{ok}　选一张兵卡带走：")
            with Horizontal(classes="choice-row"):
                for i, c in enumerate(self.chest):
                    with Vertical(classes="choice"):
                        yield CardView(app.db, build_fighter(app.db, c.id),
                                       note=f"已有 ×{col.copies(app.db, app.save, c.id)}")
                        yield Button(f"{i + 1}. 拿这张", name=f"pick-{i}", variant="warning")

    def action_pick(self, n: int) -> None:
        if not self.chest or n - 1 >= len(self.chest):
            return
        app: SanguoApp = self.app  # type: ignore[assignment]
        card = col.take(app.db, app.save, self.chest[n - 1].id)
        app.persist()
        self.notify(f"获得兵卡：{card.name}", title="宝箱")
        self.dismiss(None)

    @on(Button.Pressed)
    def pressed(self, event: Button.Pressed) -> None:
        if event.button.name and event.button.name.startswith("pick-"):
            self.action_pick(int(event.button.name.split("-")[1]) + 1)
        elif event.button.id == "ok":
            self.dismiss(None)

    def action_close(self) -> None:
        if not self.chest:  # a chest must be picked from (Enter takes the first card)
            self.dismiss(None)
        else:
            self.action_pick(1)


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
    Screen { background: $sg-bg; }
    Footer { background: $sg-panel; }
    .screen-title { height: 3; padding: 1 2 0 2; text-style: bold; color: $sg-gold; }

    #menu-wrap { height: 1fr; align: center middle; }
    #menu { width: 44; height: auto; align-horizontal: center; }
    #title { color: $sg-gold; border: double $sg-gold; text-align: center; padding: 1 0; margin-bottom: 1; }
    #status { padding: 0 0 1 0; color: $sg-muted; text-align: center; width: 100%; }
    #menu Button { width: 100%; margin: 0 0 1 0; }

    CardView { border: round $sg-gray; border-title-align: left; border-subtitle-align: right;
               padding: 0 1; height: auto; min-height: 7; width: 1fr; min-width: 28; background: $sg-card; }
    CardView:hover { background: $sg-card-hover; }
    CardView.N { border: round $sg-gray; border-title-color: $sg-gray; }
    CardView.R { border: round $sg-blue; border-title-color: $sg-blue; }
    CardView.SR { border: round $sg-purple; border-title-color: $sg-purple; }
    CardView.SSR { border: heavy $sg-gold; border-title-color: $sg-gold; background: $sg-card-ssr; }
    CardView.lord { border: round $sg-red; border-title-color: $sg-red; }
    .card-grid { grid-size: 4; grid-gutter: 1 2; height: auto; padding: 0 2; }
    #gacha-results { grid-size: 4; }
    .card-row { height: auto; }
    CardView .card-portrait { width: 12; height: 8; margin-right: 1; }
    .card-body { width: 1fr; }
    .big-portrait { width: 30; height: 20; margin-bottom: 1; }
    .story-row { height: auto; }
    .story-portrait { width: 26; height: 16; margin-right: 2; }
    .story-side { width: 1fr; }
    .leader-row { height: auto; }
    .leader-portrait { width: 15; height: 10; }
    .leader-side { width: 1fr; height: auto; padding-left: 1; }
    .no-portrait { content-align: center middle; color: $sg-dim; background: $sg-spent; }
    #quest-head { height: auto; padding: 1 2 0 2; }
    #quest-map { height: auto; margin: 1 2; padding: 1 2; border: round $sg-border; background: $sg-card; }
    #quest-legend { height: auto; padding: 0 2; color: $sg-muted; }
    #quest-body { padding: 1 4; }
    .square-title { padding: 0 0 1 0; }
    #quest-actions { height: auto; padding: 0 4 1 4; }
    #quest-actions Button { margin-right: 2; }
    .empty-slot { border: dashed $sg-track; width: 1fr; height: 9; content-align: center middle; color: $sg-dim; }

    #story-title { height: 3; padding: 1 2 0 2; text-style: bold; color: $sg-gold; }
    #story-body { padding: 1 4; }
    .story-text { padding: 0 0 1 0; color: $sg-text; }
    .choice-row { height: auto; }
    .choice { width: 1fr; height: auto; padding: 0 1; }
    .choice Button { width: 100%; }
    .choice CardView { height: 12; }
    #story-actions { height: auto; padding: 0 4 1 4; }
    #story-actions Button { margin-right: 2; }

    #gacha-actions { height: auto; padding: 0 2 1 2; }
    #gacha-actions Button { margin-right: 2; }
    #pool-left { padding: 1 2; color: $sg-muted; }

    #filters { height: auto; padding: 0 2; }
    .filter { min-width: 8; margin-right: 1; }
    #collection { height: 1fr; padding: 1 2; }
    #collection DataTable { width: 1fr; }
    #detail { width: 40; padding-left: 2; }
    .skill-list { padding: 1 0; color: $sg-muted; }

    #slots { height: auto; padding: 0 2; }
    #party-actions { height: auto; padding: 1 2; }
    #party-power { padding: 1 2; }
    PartyScreen DataTable { height: 1fr; margin: 0 2; }

    .enemy-portrait { width: 9; height: 6; margin-right: 2; }
    #enemy-info { width: 1fr; height: auto; }
    #enemy-panel { height: auto; margin: 0 1; padding: 0 2; border: heavy $sg-enemy-border;
                   border-title-color: $sg-red; border-title-style: bold; background: $sg-enemy-bg; }
    BattleScreen #log { height: 1fr; margin: 0 1; border: round $sg-track; background: $sg-log-bg; }
    #party-bar { height: auto; margin: 0 1; padding: 0 1; border: round $sg-green; background: $sg-party-bg; }
    #party-status { width: 1fr; }
    #party-bar Button { margin-left: 1; min-width: 16; }
    #leaders { height: auto; padding: 0 1; }
    .leader { width: 1fr; height: auto; margin: 0 1 0 0; padding: 0 1; border: round $sg-border;
              border-title-color: $sg-text; background: $sg-card; }
    .leader.ready { border: round $sg-green; }
    .leader.selected { border: heavy $sg-gold; background: $sg-sel-bg; }
    .leader.spent { background: $sg-spent; color: $sg-dim; }
    .leader-info { height: 3; }
    .leader .skill { width: 100%; min-width: 10; height: 1; border: none; margin-top: 1; }

    #scenarios { padding: 1 4; height: auto; }
    .scenario { width: 100%; margin-bottom: 1; }

    ModalScreen { align: center middle; background: $sg-bg 70%; }
    #dialog { width: 50; height: auto; padding: 1 2; border: heavy $sg-gold; background: $sg-card; }
    #dialog.lose { border: heavy $sg-red; }
    #dialog.wide { width: 110; }
    #dialog Button { width: 100%; margin-top: 1; }
    #result-text { text-align: center; text-style: bold; color: $sg-gold; padding: 1 0; }
    #dialog.lose #result-text { color: $sg-red; }
    """

    def __init__(self, save_path: Path, new: bool = False, seed: int | None = None) -> None:
        super().__init__()
        self.db = load_db()
        self.quests = quest.load_quests(self.db)
        self.save_path = save_path
        self.seed = seed
        self.rng = random.Random(seed)
        self.fresh = new or not save_path.exists()
        self.save = col.Save.new(self.db) if self.fresh else col.Save.load(save_path)
        for theme in make_themes():
            self.register_theme(theme)
        self.apply_theme(self.save.theme)

    def apply_theme(self, name: str) -> None:
        C.use(name)
        self.theme = f"sanguo-{name}"

    def persist(self) -> None:
        self.save.dump(self.save_path)

    def on_mount(self) -> None:
        self.push_screen(MenuScreen())
        if self.fresh:
            def named(name: str | None) -> None:
                self.save.lord_name = name or "主公"
                self.persist()
                self.push_screen(QuestScreen())
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
