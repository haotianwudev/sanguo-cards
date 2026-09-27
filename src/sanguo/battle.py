"""Rance X battle engine. Pure logic, no I/O — every call returns log lines.

One shared party HP bar (sum of the leaders' HP) against one enemy with one HP bar.
Round flow:
  1. Round start: AP += 2 (max 6); leaders that sat out 3+ rounds may get BOOST (×1.5);
     troop members may interrupt with a free attack.
  2. Player phase: spend AP on leader skills. Each leader acts at most once per round.
     累积 skills cost +1 AP after every use; 1回制限 skills can be used once per battle.
     Every hit raises the combo; each combo step adds +10% damage.
  3. End the round (or 防御: end it with a 30/50/70/90% damage cut for consecutive defends);
     the enemy attacks the shared HP bar.
Win: enemy HP 0. Lose: party HP 0, or the round limit runs out.
"""
from __future__ import annotations

import random
from dataclasses import dataclass, field

from .cards import CardDB, Enemy, Leader, Scenario, Skill


@dataclass
class LeaderUnit:
    leader: Leader
    uses_left: dict[str, int | None]
    extra_cost: dict[str, int]  # 累积 increments so far
    acted: bool = False
    idle_rounds: int = 0
    boosted: bool = False
    confused: bool = False  # loses this round's action
    confuse_next: bool = False  # hit by the enemy; will lose next round's action

    @property
    def name(self) -> str:
        return self.leader.card.name

    @property
    def at(self) -> int:
        return self.leader.at


@dataclass
class EnemyUnit:
    data: Enemy
    hp: int
    max_hp: int
    stunned: bool = False  # skips its next phase
    break_amount: float = 0.0  # extra damage taken
    break_turns: int = 0

    @property
    def name(self) -> str:
        return self.data.name


@dataclass
class Battle:
    db: CardDB
    scenario: Scenario
    rng: random.Random
    leaders: list[LeaderUnit]
    enemy: EnemyUnit
    party_hp: int
    party_max: int
    round: int = 0
    ap: int = 0
    combo: int = 0
    guard_cut: float = 0.0  # from guard skills this round
    defend_streak: int = 0
    result: str | None = None  # "win" | "lose"
    overkill: float = 0.0  # excess damage on the killing blow, as a share of the enemy's max HP
    opening: list[str] = field(default_factory=list)  # log lines from the first round start

    @classmethod
    def start(cls, db: CardDB, scenario_id: str, party: list[Leader], seed: int | None = None,
              damage: int = 0, extra: dict | None = None, uses: dict | None = None) -> Battle:
        """damage / extra / uses carry a quest's wear from earlier battles (see quest.py)."""
        sc = db.scenarios[scenario_id]
        e = db.enemies[sc.enemy]
        max_hp = round(e.hp * (1 + db.battle["enemy_hp_per_extra_leader"] * (len(party) - 1)))
        extra, uses = extra or {}, uses or {}
        units = []
        for ld in party:
            cid = ld.card.id
            units.append(LeaderUnit(
                ld,
                {s: uses.get(cid, {}).get(s, db.skills[s].uses) for s in ld.card.skills},
                {s: extra.get(cid, {}).get(s, 0) for s in ld.card.skills}))
        hp = sum(ld.hp for ld in party)
        b = cls(db, sc, random.Random(seed), units, EnemyUnit(e, max_hp, max_hp), max(1, hp - damage), hp,
                ap=db.battle["ap_start"] - db.battle["ap_per_round"])
        b.opening = b._start_round()
        return b

    def carry_out(self) -> tuple[int, dict, dict]:
        """(damage taken, 累积 increments, uses left) keyed by card id — for the next battle in a quest."""
        extra = {u.leader.card.id: dict(u.extra_cost) for u in self.leaders}
        uses = {u.leader.card.id: {s: n for s, n in u.uses_left.items() if n is not None} for u in self.leaders}
        return self.party_max - self.party_hp, extra, uses

    # ---- queries -------------------------------------------------------

    def cost(self, u: LeaderUnit, sk: Skill) -> int:
        return sk.cost + u.extra_cost[sk.id]

    def skills_of(self, u: LeaderUnit) -> list[Skill]:
        return [self.db.skills[s] for s in u.leader.card.skills]

    def usable(self, u: LeaderUnit, sk: Skill) -> bool:
        return u.uses_left[sk.id] != 0 and self.cost(u, sk) <= self.ap

    def can_act(self, i: int) -> bool:
        u = self.leaders[i]
        return (self.result is None and not u.acted and not u.confused
                and any(self.usable(u, sk) for sk in self.skills_of(u)))

    # ---- player actions ------------------------------------------------

    def act(self, i: int, skill_id: str) -> list[str]:
        u = self.leaders[i]
        sk = self.db.skills[skill_id]
        if not self.can_act(i) or skill_id not in u.leader.card.skills or not self.usable(u, sk):
            raise ValueError(f"{u.name} 现在不能使用 {sk.name}")
        self.ap -= self.cost(u, sk)
        if sk.cumulative:
            u.extra_cost[sk.id] += 1
        if u.uses_left[sk.id] is not None:
            u.uses_left[sk.id] -= 1
        u.acted = True
        u.idle_rounds = 0
        mult = self.db.battle["boost_mult"] if u.boosted else 1.0
        log = [f"{u.name}【{sk.name}】" + ("（BOOST）" if u.boosted else "")]
        u.boosted = False
        for eff in sk.effects:
            log += self._apply(u, eff, mult)
        self._check_end()
        return log

    def end_round(self) -> list[str]:
        self.defend_streak = 0
        return self._enemy_phase(0.0)

    def retreat(self) -> list[str]:
        self.result = "lose"
        return ["全军撤退！"]

    def defend(self) -> list[str]:
        cuts = self.db.battle["defend_cuts"]
        cut = cuts[min(self.defend_streak, len(cuts) - 1)]
        self.defend_streak += 1
        return [f"全军防御（伤害 -{round(cut * 100)}%）"] + self._enemy_phase(cut)

    # ---- internals -----------------------------------------------------

    def _dmg(self, base: float, kind: str) -> int:
        cfg = self.db.battle
        e = self.enemy
        resist = e.data.phys_resist if kind == "attack" else e.data.magic_resist
        d = base * (1 + cfg["combo_bonus"] * self.combo) * (1 + e.break_amount) * (1 - resist)
        d *= self.rng.uniform(1 - cfg["variance"], 1 + cfg["variance"])
        return max(1, round(d))

    def _apply(self, u: LeaderUnit, eff: dict, mult: float) -> list[str]:
        kind = eff["type"]
        e = self.enemy
        if kind in ("attack", "magic"):
            log = []
            for _ in range(eff.get("hits", 1)):
                if e.hp <= 0:
                    break
                d = self._dmg(u.at * eff["power"] * mult, kind)
                if d > e.hp:
                    self.overkill = (d - e.hp) / e.max_hp
                e.hp = max(0, e.hp - d)
                self.combo += 1
                log.append(f"  {e.name} 受到 {d} 伤害（{self.combo} 连击）")
            return log
        if kind == "heal":
            amt = min(round(u.at * eff["power"] * mult), self.party_max - self.party_hp)
            self.party_hp += amt
            return [f"  体力恢复 {amt}"]
        if kind == "guard":
            self.guard_cut = 1 - (1 - self.guard_cut) * (1 - eff["cut"])
            return [f"  本回合受到伤害 -{round(self.guard_cut * 100)}%"]
        if kind == "boost":
            if eff["target"] == "all":
                for t in self.leaders:
                    if t is not u:
                        t.boosted = True
                return [f"  全军进入 BOOST（下次行动 ×{self.db.battle['boost_mult']}）"]
            u.boosted = True
            return [f"  {u.name} 进入 BOOST（下次行动 ×{self.db.battle['boost_mult']}）"]
        if kind == "stun":
            if self.rng.random() < eff["chance"]:
                e.stunned = True
                return [f"  {e.name} 陷入混乱！下回合无法行动"]
            return [f"  {e.name} 未受影响"]
        if kind == "break":
            e.break_amount = max(e.break_amount, eff["amount"])
            e.break_turns = max(e.break_turns, eff["turns"])
            return [f"  {e.name} 破防：受到伤害 +{round(eff['amount'] * 100)}%（{eff['turns']} 回合）"]
        if kind == "ap":
            self.ap = min(self.db.battle["ap_max"], self.ap + eff["amount"])
            return [f"  AP +{eff['amount']}"]
        raise ValueError(f"unknown effect {kind}")

    def _enemy_phase(self, defend_cut: float) -> list[str]:
        if self.result:
            return []
        e = self.enemy
        log = [f"—— {e.name} 的行动 ——"]
        if e.stunned:
            e.stunned = False
            log.append(f"{e.name} 混乱中，无法行动")
        else:
            cut = 1 - (1 - self.guard_cut) * (1 - defend_cut)
            var = self.db.battle["variance"]
            for _ in range(e.data.actions):
                mv = self.rng.choices(e.data.moves, weights=[m["weight"] for m in e.data.moves])[0]
                d = max(1, round(e.data.at * mv["power"] * self.rng.uniform(1 - var, 1 + var) * (1 - cut)))
                self.party_hp = max(0, self.party_hp - d)
                log.append(f"{e.name}【{mv['name']}】 我军受到 {d} 伤害" + (f"（减伤 {round(cut * 100)}%）" if cut else ""))
                if mv.get("confuse") and self.rng.random() < mv["confuse"]:
                    victim = self.rng.choice(self.leaders)
                    victim.confuse_next = True
                    log.append(f"  {victim.name} 陷入混乱，下回合无法行动")
                self._check_end()
                if self.result:
                    return log
        if e.break_turns > 0:
            e.break_turns -= 1
            if e.break_turns == 0:
                e.break_amount = 0.0
        if self.round >= self.scenario.turn_limit:
            self.result = "lose"
            log.append(f"已到第 {self.round} 回合上限 —— 撤退！")
            return log
        return log + self._start_round()

    def _start_round(self) -> list[str]:
        cfg = self.db.battle
        if self.round > 0:
            for u in self.leaders:
                if not u.acted:
                    u.idle_rounds += 1
        self.round += 1
        self.ap = min(cfg["ap_max"], self.ap + cfg["ap_per_round"])
        self.combo = 0
        self.guard_cut = 0.0
        log = [f"─── 第 {self.round} 回合 ───"]
        for u in self.leaders:
            u.acted = False
            u.confused, u.confuse_next = u.confuse_next, False
            if not u.boosted and u.idle_rounds >= cfg["boost_idle_rounds"] and self.rng.random() < cfg["boost_chance"]:
                u.boosted = True
                log.append(f"{u.name} 蓄势已久 —— BOOST！")
        for u in self.leaders:
            if u.leader.members and self.enemy.hp > 0 and self.rng.random() < cfg["interrupt_chance"]:
                m = self.rng.choice(u.leader.members)
                d = self._dmg(m.at * cfg["interrupt_power"], "attack")
                self.enemy.hp = max(0, self.enemy.hp - d)
                self.combo += 1
                log.append(f"插入！{u.name}部队的 {m.name} 突袭，造成 {d} 伤害")
        self._check_end()
        return log

    def _check_end(self) -> None:
        if self.enemy.hp <= 0:
            self.result = "win"
        elif self.party_hp <= 0:
            self.result = "lose"
