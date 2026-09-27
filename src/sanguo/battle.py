"""Rance-10-style card battle engine. Pure logic, no I/O — every call returns log lines.

Flow per round:
  1. Round starts: each living enemy declares an *intent* (skill + target), visible to the player.
  2. Player spends AP: each general may act at most once per round.
  3. Player ends the turn: enemies execute their intents, statuses tick down.
Win: every enemy down. Lose: every player general down, or the turn limit runs out.
"""
from __future__ import annotations

import random
from dataclasses import dataclass, field

from .cards import CardDB, GeneralCard, Scenario, Skill

PLAYER, ENEMY = "player", "enemy"
GUARD_FACTOR = 0.5
ATK_UP_FACTOR = 1.3


@dataclass
class Unit:
    card: GeneralCard
    side: str
    hp: int
    uses_left: dict[str, int | None]
    acted: bool = False
    guard: bool = False
    stunned: bool = False  # set by a stun effect; the unit loses its next action
    dazed: bool = False  # player side: this round is lost to a stun (for display)
    atk_up: int = 0  # rounds remaining

    @property
    def name(self) -> str:
        return self.card.name

    @property
    def alive(self) -> bool:
        return self.hp > 0

    def stat(self, key: str) -> float:
        base = {"atk": self.card.atk, "int": self.card.int}[key]
        return base * ATK_UP_FACTOR if self.atk_up > 0 else base


@dataclass
class Intent:
    skill: Skill
    target: Unit | None  # None for all-target skills


@dataclass
class Battle:
    db: CardDB
    scenario: Scenario
    rng: random.Random
    player: list[Unit]
    enemy: list[Unit]
    round: int = 0
    ap: int = 0
    intents: dict[int, Intent] = field(default_factory=dict)  # enemy index -> intent
    result: str | None = None  # "win" | "lose"

    @classmethod
    def from_scenario(cls, db: CardDB, scenario_id: str, seed: int | None = None) -> Battle:
        sc = db.scenarios[scenario_id]
        b = cls(db, sc, random.Random(seed),
                [cls._unit(db, g, PLAYER) for g in sc.player],
                [cls._unit(db, g, ENEMY) for g in sc.enemy])
        b._start_round()
        return b

    @staticmethod
    def _unit(db: CardDB, gid: str, side: str) -> Unit:
        card = db.generals[gid]
        return Unit(card, side, card.hp, {s: db.skills[s].uses for s in card.skills})

    # ---- queries -------------------------------------------------------

    def side(self, side: str) -> list[Unit]:
        return self.player if side == PLAYER else self.enemy

    def foes(self, u: Unit) -> list[Unit]:
        return self.enemy if u.side == PLAYER else self.player

    def friends(self, u: Unit) -> list[Unit]:
        return self.player if u.side == PLAYER else self.enemy

    def usable_skills(self, u: Unit) -> list[Skill]:
        out = []
        for sid in u.card.skills:
            sk = self.db.skills[sid]
            if u.uses_left[sid] == 0:
                continue
            if u.side == PLAYER and sk.cost > self.ap:
                continue
            out.append(sk)
        return out

    def can_act(self, u: Unit) -> bool:
        return (self.result is None and u.side == PLAYER and u.alive and not u.acted
                and not u.stunned and bool(self.usable_skills(u)))

    @staticmethod
    def needs_target(skill: Skill) -> bool:
        return skill.target in ("enemy", "ally")

    # ---- player actions ------------------------------------------------

    def act(self, actor_idx: int, skill_id: str, target_idx: int | None = None) -> list[str]:
        u = self.player[actor_idx]
        if not self.can_act(u):
            raise ValueError(f"{u.name} 本回合无法行动")
        sk = self.db.skills[skill_id]
        if sk not in self.usable_skills(u):
            raise ValueError(f"{u.name} 不能使用 {sk.name}")
        target = None
        if self.needs_target(sk):
            pool = self.foes(u) if sk.target == "enemy" else self.friends(u)
            if target_idx is None or not (0 <= target_idx < len(pool)) or not pool[target_idx].alive:
                raise ValueError("目标无效")
            target = pool[target_idx]
        self.ap -= sk.cost
        u.acted = True
        log = self._use(u, sk, target)
        self._check_end()
        return log

    def end_turn(self) -> list[str]:
        if self.result:
            return []
        log = ["—— 敌方行动 ——"]
        for i, e in enumerate(self.enemy):
            if not e.alive or self.result:
                continue
            if e.stunned:
                log.append(f"{e.name} 陷入混乱，无法行动")
                e.stunned = False
                continue
            intent = self.intents.get(i)
            if intent is None:
                continue
            target = intent.target
            if target is not None and not target.alive:
                living = [p for p in self.player if p.alive]
                target = self.rng.choice(living) if living else None
                if target is None:
                    break
            log += self._use(e, intent.skill, target)
            self._check_end()
        if self.result is None and self.round >= self.scenario.turn_limit:
            self.result = "lose"
            log.append(f"已到第 {self.round} 回合上限 —— 敌军援兵到达，撤退！")
        if self.result is None:
            self._start_round()
        return log

    # ---- internals -----------------------------------------------------

    def _start_round(self) -> None:
        self.round += 1
        self.ap = self.scenario.ap
        for p in self.player:
            p.guard = False
        for u in self.player + self.enemy:
            if u.atk_up > 0:
                u.atk_up -= 1
        for e in self.enemy:
            e.guard = False
        # a player general stunned during the enemy phase sits out exactly this round
        for p in self.player:
            p.dazed = p.stunned
            p.acted = p.stunned
            p.stunned = False
        self.intents = {i: self._enemy_intent(e) for i, e in enumerate(self.enemy) if e.alive}

    def _enemy_intent(self, e: Unit) -> Intent:
        skills = self.usable_skills(e)
        # prefer limited-use signature skills ~40% of the time once available
        special = [s for s in skills if s.uses is not None]
        pick = self.rng.choice(special) if special and self.rng.random() < 0.4 else \
            self.rng.choice([s for s in skills if s.uses is None] or skills)
        target = None
        if pick.target == "enemy":
            target = self.rng.choice([p for p in self.player if p.alive])
        elif pick.target == "ally":
            target = min((x for x in self.enemy if x.alive), key=lambda x: x.hp / x.card.hp)
        return Intent(pick, target)

    def _use(self, u: Unit, sk: Skill, target: Unit | None) -> list[str]:
        if u.uses_left[sk.id] is not None:
            u.uses_left[sk.id] -= 1
        if sk.target == "all_enemies":
            targets = [x for x in self.foes(u) if x.alive]
        elif sk.target == "all_allies":
            targets = [x for x in self.friends(u) if x.alive]
        else:
            targets = [target]
        head = f"{u.name}【{sk.name}】"
        if len(targets) == 1 and self.needs_target(sk):
            head += f" → {targets[0].name}"
        log = [head]
        for eff in sk.effects:
            log += self._apply(u, eff, targets)
        return log

    def _apply(self, u: Unit, eff: dict, targets: list[Unit]) -> list[str]:
        kind = eff["type"]
        log = []
        if kind == "self_guard":
            u.guard = True
            return [f"  {u.name} 进入防御姿态"]
        for t in targets:
            if not t.alive:
                continue
            if kind == "damage":
                base = u.stat(eff["stat"]) * eff["power"]
                dmg = base * 100 / (100 + t.card.def_) * self.rng.uniform(0.9, 1.1)
                if t.guard:
                    dmg *= GUARD_FACTOR
                dmg = max(1, round(dmg))
                t.hp = max(0, t.hp - dmg)
                log.append(f"  {t.name} 受到 {dmg} 伤害" + ("（防御）" if t.guard else "")
                           + ("，败退！" if not t.alive else ""))
            elif kind == "heal":
                amt = round(u.stat(eff["stat"]) * eff["power"])
                amt = min(amt, t.card.hp - t.hp)
                t.hp += amt
                log.append(f"  {t.name} 恢复 {amt} 兵力")
            elif kind == "guard":
                t.guard = True
                log.append(f"  {t.name} 进入防御姿态")
            elif kind == "atk_up":
                t.atk_up = max(t.atk_up, eff["turns"] + 1)  # +1: ticks at next round start
                log.append(f"  {t.name} 士气高涨（{eff['turns']} 回合）")
            elif kind == "stun":
                if self.rng.random() < eff["chance"]:
                    t.stunned = True
                    log.append(f"  {t.name} 陷入混乱！")
                else:
                    log.append(f"  {t.name} 未受影响")
            else:
                raise ValueError(f"unknown effect {kind}")
        return log

    def _check_end(self) -> None:
        if not any(e.alive for e in self.enemy):
            self.result = "win"
        elif not any(p.alive for p in self.player):
            self.result = "lose"
