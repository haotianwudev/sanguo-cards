"""Plain-text front end: main menu (gacha, collection, party, battle). Rules live elsewhere; this only renders and reads input."""
from __future__ import annotations

import argparse
import random
from pathlib import Path

from . import collection as col
from . import story
from .battle import Battle, Unit
from .cards import RARITIES, CardDB, Fighter, build_fighter, load_db, power, power_split

TARGET_LABEL = {"enemy": "单体敌", "ally": "单体友", "self": "自身", "all_enemies": "全体敌", "all_allies": "全体友"}
RARITY_MARK = {"N": "N  ", "R": "R  ", "SR": "SR ", "SSR": "SSR"}


def ask(prompt: str, n: int, allow_back: bool = True) -> int | None:
    """Return a 0-based choice, or None for back."""
    while True:
        raw = input(prompt).strip().lower()
        if allow_back and raw in ("", "0", "b"):
            return None
        if raw in ("q", "quit"):
            raise SystemExit("已退出")
        if raw.isdigit() and 1 <= int(raw) <= n:
            return int(raw) - 1
        print("  输入无效")


def troop_tag(db: CardDB, troop: str) -> str:
    return f"〔{db.troops[troop].short}〕"


def fighter_line(db: CardDB, f: Fighter) -> str:
    rarity = RARITY_MARK[f.rarity] if f.rarity else "主公"
    troop_p, general_p = power_split(db, f)
    split = f"(兵种{troop_p}+武将{general_p})" if general_p else f"(兵种{troop_p})"
    skills = "、".join(db.skills[s].name for s in f.skills)
    return (f"{rarity} {troop_tag(db, f.troop)}{f.name:<5} 战力{power(f):>4}{split:<14} | "
            f"兵{f.hp:>4} 武{f.atk:>3} 智{f.int:>3} 统{f.def_:>3} | {skills}")


# ---- gacha ---------------------------------------------------------------

def do_pull(db: CardDB, save: col.Save, rng: random.Random, n: int) -> None:
    cards = col.pull(db, save, rng, n)
    if not cards:
        print("  所有武将都已招募！")
        return
    print(f"\n—— 招募 {len(cards)} 次 ——")
    for c in sorted(cards, key=lambda c: RARITIES.index(c.rarity), reverse=True):
        flash = " ✦✦✦" if c.rarity == "SSR" else (" ✦" if c.rarity == "SR" else "")
        print(f"  {fighter_line(db, build_fighter(db, c.id))}{flash}")
    print(f"  卡池剩余 {col.pool_left(db, save)} 张")


# ---- collection & party --------------------------------------------------

def show_collection(db: CardDB, save: col.Save) -> list[Fighter]:
    fighters = sorted(col.owned_fighters(db, save),
                      key=lambda f: (list(db.troops).index(f.troop), -power(f)))
    print(f"\n—— 卡册（{len(save.owned)}/{len(db.cards)}）——")
    troop = None
    for i, f in enumerate(fighters):
        if f.troop != troop:
            troop = f.troop
            print(f" [{db.troops[troop].name}]")
        mark = " ◆出战" if f.id in save.party else ""
        print(f"  {i + 1:>2}. {fighter_line(db, f)}{mark}")
    if not fighters:
        print("  （空）先去抽卡吧")
    return fighters


def show_party(db: CardDB, save: col.Save) -> None:
    print(f"\n—— 当前编成（{len(save.party) + 1}/{save.party_slots}）——")
    for f in col.party_fighters(db, save):
        print(f"  {fighter_line(db, f)}")


def edit_party(db: CardDB, save: col.Save) -> None:
    while True:
        show_party(db, save)
        print("\n  1. 自动编成（每个兵种取最强，再取最强的兵种）\n  2. 手动编成\n  0. 返回")
        choice = ask("选择：", 2)
        if choice is None:
            return
        if choice == 0:
            save.party = col.auto_party(db, save)
            continue
        fighters = show_collection(db, save)
        if not fighters:
            continue
        raw = input(f"输入最多 {save.party_slots - 1} 个卡册编号，空格分隔（同兵种只能一张）：").split()
        try:
            ids = [fighters[int(x) - 1].id for x in raw]
        except (ValueError, IndexError):
            print("  编号无效")
            continue
        err = col.validate_party(db, save, ids)
        if err:
            print(f"  ✗ {err}")
        else:
            save.party = ids


# ---- battle --------------------------------------------------------------

def bar(u: Unit, width: int = 14) -> str:
    filled = round(width * u.hp / u.card.hp)
    return "█" * filled + "·" * (width - filled)


def status(u: Unit) -> str:
    tags = []
    if u.guard:
        tags.append("防御")
    if u.atk_up > 0:
        tags.append("士气↑")
    if u.dazed or u.stunned:
        tags.append("混乱")
    return f"[{' '.join(tags)}]" if tags else ""


def render(b: Battle) -> None:
    db = b.db
    print()
    print(f"═══ {b.scenario.name} · 第 {b.round}/{b.scenario.turn_limit} 回合 · 行动力 {b.ap} ═══")
    print("敌军：")
    for i, e in enumerate(b.enemy):
        name = f"{troop_tag(db, e.card.troop)}{e.name}"
        if not e.alive:
            print(f"  {i + 1}. {name:<7} —— 败退")
            continue
        intent = b.intents.get(i)
        plan = ""
        if intent:
            tgt = intent.target.name if intent.target else \
                {"all_enemies": "我军全体", "all_allies": "敌军全体", "self": "自身"}.get(intent.skill.target, "")
            plan = f"  ⚠ 准备【{intent.skill.name}】→ {tgt}"
        print(f"  {i + 1}. {name:<7} {bar(e)} {e.hp:>4}/{e.card.hp:<4} {status(e)}{plan}")
    print("我军：")
    for i, p in enumerate(b.player):
        name = f"{troop_tag(db, p.card.troop)}{p.name}"
        if not p.alive:
            print(f"  {i + 1}. {name:<7} —— 败退")
            continue
        mark = "✓已行动" if p.acted else ""
        print(f"  {i + 1}. {name:<7} {bar(p)} {p.hp:>4}/{p.card.hp:<4} {status(p)} {mark}")


def skill_label(b: Battle, u: Unit, sid: str) -> str:
    sk = b.db.skills[sid]
    left = u.uses_left[sid]
    uses = "∞" if left is None else f"剩{left}"
    return f"{sk.name}（耗{sk.cost} · {uses} · {TARGET_LABEL[sk.target]}）"


def player_turn(b: Battle) -> None:
    while b.result is None:
        ready = [i for i, p in enumerate(b.player) if b.can_act(p)]
        render(b)
        if b.ap == 0 or not ready:
            input("行动力用尽 / 无人可动，回车结束回合…")
            return
        who = ask("选择部队编号（回车=结束回合，q=退出）：", len(b.player))
        if who is None:
            return
        u = b.player[who]
        if who not in ready:
            print(f"  {u.name} 本回合无法行动")
            continue
        skills = b.usable_skills(u)
        for i, sk in enumerate(skills):
            print(f"    {i + 1}. {skill_label(b, u, sk.id)}")
        si = ask("  选择技能（回车=返回）：", len(skills))
        if si is None:
            continue
        sk = skills[si]
        target = None
        if b.needs_target(sk):
            pool = b.foes(u) if sk.target == "enemy" else b.friends(u)
            target = ask("  选择目标编号（回车=返回）：", len(pool))
            if target is None:
                continue
            if not pool[target].alive:
                print("  目标已败退")
                continue
        for line in b.act(who, sk.id, target):
            print(line)


def run_battle(db: CardDB, save: col.Save, scenario_id: str, seed: int | None) -> bool:
    sc = db.scenarios[scenario_id]
    b = Battle.from_scenario(db, scenario_id, col.party_fighters(db, save), seed=seed)
    print(f"\n【{sc.name}】{sc.turn_limit} 回合内击败全部敌将。每回合行动力 {sc.ap}，每支部队每回合限动一次。")
    while b.result is None:
        player_turn(b)
        if b.result:
            break
        for line in b.end_turn():
            print(line)
    render(b)
    if b.result != "win":
        print("\n✗ 战败…… 调整编成再来")
        return False
    col.record_win(save, scenario_id)
    print("\n★ 胜利！")
    return True


def choose_battle(db: CardDB, save: col.Save, seed: int | None) -> None:
    ids = list(db.scenarios)
    for i, sid in enumerate(ids):
        sc = db.scenarios[sid]
        done = "✓已通关" if sid in save.cleared else "未通关"
        enemies = "、".join(db.enemies[e].name for e in sc.enemy)
        print(f"  {i + 1}. {sc.name:<6} 敌：{enemies}  （{done}）")
    pick = ask("选择战役（回车=返回）：", len(ids))
    if pick is not None:
        run_battle(db, save, ids[pick], seed)


# ---- story ---------------------------------------------------------------

def play_story(db: CardDB, st: story.Story, save: col.Save, seed: int | None) -> None:
    """Run story steps until a battle is lost, the player backs out, or the story runs out."""
    last_node = None
    while (cur := story.current(st, save)) is not None:
        node, step = cur
        if node.id != last_node:
            print(f"\n━━━━ {node.title} ━━━━")
            last_node = node.id
        k = story.kind(step)
        if k == "text":
            for line in step["text"]:
                print("  " + line.format(lord=save.lord_name))
            input("  （回车继续）")
        elif k == "choose":
            opts = step["choose"]
            for i, opt in enumerate(opts):
                print(f"  {i + 1}. {opt['label']}")
                print(f"       {fighter_line(db, build_fighter(db, opt['card']))}")
            pick = ask("做出选择：", len(opts), allow_back=False)
            story.advance(db, st, save, pick)
            print(f"  → {db.cards[opts[pick]['card']].name} 加入！")
            continue
        elif k == "give":
            give = step["give"]
            for cid in give.get("cards", []):
                print(f"  获得卡牌：{fighter_line(db, build_fighter(db, cid))}")
        elif k == "battle":
            show_party(db, save)
            go = ask(f"  即将开战【{db.scenarios[step['battle']].name}】 1=出战  回车=先回主菜单（调整编成/招募）：", 1)
            if go is None:
                return
            if not run_battle(db, save, step["battle"], seed):
                return
        story.advance(db, st, save)
    print("\n（剧情暂时到此为止）")


# ---- main ----------------------------------------------------------------

def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(prog="sanguo", description="三国卡牌 · 文字版")
    ap.add_argument("--save", type=Path, default=col.DEFAULT_SAVE, help=f"存档路径（默认 {col.DEFAULT_SAVE}）")
    ap.add_argument("--new", action="store_true", help="忽略旧存档，重新开始")
    ap.add_argument("--seed", type=int, default=None, help="固定随机种子（抽卡与战斗）")
    args = ap.parse_args(argv)

    db = load_db()
    st = story.load_story(db)
    rng = random.Random(args.seed)
    if args.save.exists() and not args.new:
        save = col.Save.load(args.save)
        print(f"读取存档：{args.save}")
    else:
        save = col.Save.new(db)
        name = input("请输入你的名字（回车=主公）：").strip()
        save.lord_name = name or "主公"
        play_story(db, st, save, args.seed)
        save.dump(args.save)

    try:
        while True:
            cur = story.current(st, save)
            story_label = f"剧情：{cur[0].title}" if cur else "剧情（暂无新章节）"
            print(f"\n══ {save.lord_name} · 卡册 {len(save.owned)}/{len(db.cards)} ══")
            print(f"  1. {story_label}\n  2. 招募 1 次\n  3. 招募 10 次\n  4. 卡册\n  5. 编成\n  6. 自由出战\n  0. 保存并退出")
            choice = ask("选择：", 6)
            if choice is None:
                break
            if choice == 0:
                play_story(db, st, save, args.seed)
            elif choice == 1:
                do_pull(db, save, rng, 1)
            elif choice == 2:
                do_pull(db, save, rng, 10)
            elif choice == 3:
                show_collection(db, save)
            elif choice == 4:
                edit_party(db, save)
            elif choice == 5:
                choose_battle(db, save, args.seed)
            save.dump(args.save)
    finally:
        save.dump(args.save)
        print(f"已保存到 {args.save}")


if __name__ == "__main__":
    main()
