"""Plain-text front end for a battle. All game rules live in battle.py; this only renders and reads input."""
from __future__ import annotations

import argparse

from .battle import Battle, Unit
from .cards import load_db


def bar(u: Unit, width: int = 16) -> str:
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
    print()
    print(f"═══ {b.scenario.name} · 第 {b.round}/{b.scenario.turn_limit} 回合 · 行动力 {b.ap} ═══")
    print("敌军：")
    for i, e in enumerate(b.enemy):
        if not e.alive:
            print(f"  {i + 1}. {e.name:<4} —— 败退")
            continue
        intent = b.intents.get(i)
        plan = ""
        if intent:
            tgt = intent.target.name if intent.target else \
                {"all_enemies": "我军全体", "all_allies": "敌军全体"}.get(intent.skill.target, "")
            plan = f"  ⚠ 准备【{intent.skill.name}】→ {tgt}"
        print(f"  {i + 1}. {e.name:<4} {bar(e)} {e.hp:>4}/{e.card.hp:<4} {status(e)}{plan}")
    print("我军：")
    for i, p in enumerate(b.player):
        if not p.alive:
            print(f"  {i + 1}. {p.name:<4} —— 败退")
            continue
        mark = "✓已行动" if p.acted else ""
        print(f"  {i + 1}. {p.name:<4} {bar(p)} {p.hp:>4}/{p.card.hp:<4} {status(p)} {mark}")


def ask(prompt: str, n: int, allow_back: bool = True) -> int | None:
    """Return a 0-based choice, or None for back/end."""
    while True:
        raw = input(prompt).strip().lower()
        if allow_back and raw in ("", "0", "b", "e"):
            return None
        if raw in ("q", "quit"):
            raise SystemExit("已退出")
        if raw.isdigit() and 1 <= int(raw) <= n:
            return int(raw) - 1
        print("  输入无效")


def skill_label(b: Battle, u: Unit, sid: str) -> str:
    sk = b.db.skills[sid]
    left = u.uses_left[sid]
    uses = "∞" if left is None else f"剩{left}"
    tgt = {"enemy": "单体敌", "ally": "单体友", "all_enemies": "全体敌", "all_allies": "全体友"}[sk.target]
    return f"{sk.name}（耗{sk.cost} · {uses} · {tgt}）"


def player_turn(b: Battle) -> None:
    while b.result is None:
        ready = [i for i, p in enumerate(b.player) if b.can_act(p)]
        render(b)
        if b.ap == 0 or not ready:
            input("行动力用尽 / 无人可动，回车结束回合…")
            return
        who = ask("选择武将编号（回车=结束回合，q=退出）：", len(b.player))
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


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(prog="sanguo", description="三国卡牌 · 文字版战斗")
    ap.add_argument("--scenario", default="hulao")
    ap.add_argument("--seed", type=int, default=None)
    args = ap.parse_args(argv)

    db = load_db()
    b = Battle.from_scenario(db, args.scenario, seed=args.seed)
    print(f"【{b.scenario.name}】{b.scenario.turn_limit} 回合内击败全部敌将。每回合行动力 {b.scenario.ap}，每名武将每回合限动一次。")
    while b.result is None:
        player_turn(b)
        if b.result:
            break
        for line in b.end_turn():
            print(line)
    render(b)
    print("\n★ 胜利！" if b.result == "win" else "\n✗ 战败……")


if __name__ == "__main__":
    main()
