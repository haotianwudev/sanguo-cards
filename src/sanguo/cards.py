"""Load card data (troops, skills, gacha cards, enemies, scenarios) and turn cards into fighters.

Stats follow Rance X: every card has only HP and AT. A troop type (兵种) is a unit; the card chosen to
lead it gets  AT = 5 × own AT + sum of the other owned cards of that troop  (HP likewise).
"""
from __future__ import annotations

import json
from dataclasses import dataclass
from importlib import resources

RARITIES = ("N", "R", "SR", "SSR")
LORD = "lord"
EFFECTS = ("attack", "magic", "heal", "guard", "boost", "stun", "break", "ap")


@dataclass(frozen=True)
class Skill:
    id: str
    name: str
    cost: int  # base AP cost
    cumulative: bool  # 累积: cost +1 after every use this battle
    uses: int | None  # 1 = 1回制限; None = unlimited
    effects: tuple[dict, ...]


@dataclass(frozen=True)
class Troop:
    """A 兵种 / unit: base stats and the skill every card of this type gets."""
    id: str
    name: str
    short: str
    hp: int
    at: int
    skills: tuple[str, ...]


@dataclass(frozen=True)
class PlayerCard:
    """A gacha card: a troop type, optionally led by a named general whose own ability (bonus HP/AT +
    signature skills) adds on top of the troop base. N cards are plain troops with no general."""
    id: str
    name: str
    rarity: str
    troop: str
    bonus: dict[str, int]
    skills: tuple[str, ...]
    in_pool: bool = True  # False = story-only, never drawn from the gacha
    person: str = ""  # who this is; variants of one general (孙策·少年 / 孙策·中年) share it
    weight: int = 1  # soldiers only: how often a chest drops it

    @property
    def soldier(self) -> bool:
        """N cards are soldiers (兵卡): chest drops, stackable. Everything else is a unique general."""
        return self.rarity == "N"


@dataclass(frozen=True)
class Fighter:
    """One card's own stats (before any leader bonus)."""
    id: str
    name: str
    troop: str
    hp: int
    at: int
    skills: tuple[str, ...]
    rarity: str | None = None


@dataclass(frozen=True)
class Leader:
    """A card leading its troop into battle, with the rest of that troop behind it."""
    card: Fighter
    members: tuple[Fighter, ...]
    hp: int
    at: int


@dataclass(frozen=True)
class Enemy:
    id: str
    name: str
    hp: int
    at: int
    actions: int  # attacks per enemy phase
    moves: tuple[dict, ...]  # {"name", "power", "weight", optional "confuse"}
    phys_resist: float = 0.0
    magic_resist: float = 0.0
    portrait: str = ""  # art key (pics/art.json); "" = the enemy id


@dataclass(frozen=True)
class Scenario:
    id: str
    name: str
    turn_limit: int
    enemy: str


@dataclass(frozen=True)
class CardDB:
    gacha: dict
    battle: dict
    troops: dict[str, Troop]
    skills: dict[str, Skill]
    cards: dict[str, PlayerCard]
    enemies: dict[str, Enemy]
    scenarios: dict[str, Scenario]

    def pool(self, rarity: str) -> list[PlayerCard]:
        """Generals the gacha can still give at this rarity (soldiers come from chests instead)."""
        return [c for c in self.cards.values() if c.rarity == rarity and c.in_pool and not c.soldier]

    def soldiers(self) -> list[PlayerCard]:
        return [c for c in self.cards.values() if c.soldier]


def load_raw() -> dict:
    return json.loads(resources.files("sanguo.data").joinpath("cards.json").read_text("utf-8"))


def load_db(raw: dict | None = None) -> CardDB:
    """Build the card DB from the bundled JSON, or from an already-parsed dict (for tuning/tests)."""
    raw = load_raw() if raw is None else raw
    skills = {
        sid: Skill(sid, s["name"], s["cost"], s.get("cumulative", False), s.get("uses"), tuple(s["effects"]))
        for sid, s in raw["skills"].items()
    }
    troops = {
        tid: Troop(tid, t["name"], t["short"], t["hp"], t["at"], tuple(t["skills"]))
        for tid, t in raw["troops"].items()
    }
    cards = {
        cid: PlayerCard(cid, c["name"], c["rarity"], c["troop"], dict(c.get("bonus", {})),
                        tuple(c.get("skills", ())), c.get("pool", True), c.get("person", cid), c.get("weight", 1))
        for cid, c in raw["cards"].items()
    }
    enemies = {
        eid: Enemy(eid, e["name"], e["hp"], e["at"], e["actions"], tuple(e["moves"]),
                   e.get("phys_resist", 0.0), e.get("magic_resist", 0.0), e.get("portrait", ""))
        for eid, e in raw["enemies"].items()
    }
    scenarios = {
        sid: Scenario(sid, s["name"], s["turn_limit"], s["enemy"])
        for sid, s in raw["scenarios"].items()
    }

    def check(owner: str, skill_ids) -> None:
        missing = [s for s in skill_ids if s not in skills]
        if missing:
            raise ValueError(f"{owner} references unknown skills {missing}")

    for sk in skills.values():
        bad = [e["type"] for e in sk.effects if e["type"] not in EFFECTS]
        if bad:
            raise ValueError(f"skill {sk.id} has unknown effects {bad}")
    for t in troops.values():
        check(f"troop {t.id}", t.skills)
    for c in cards.values():
        check(f"card {c.id}", c.skills)
        if c.troop not in troops or c.troop == LORD:
            raise ValueError(f"card {c.id} has invalid troop {c.troop}")
        if c.rarity not in RARITIES:
            raise ValueError(f"card {c.id} has invalid rarity {c.rarity}")
    for sc in scenarios.values():
        if sc.enemy not in enemies:
            raise ValueError(f"scenario {sc.id} references unknown enemy {sc.enemy}")
    if LORD not in troops:
        raise ValueError("troops must define 'lord'")
    return CardDB(raw["gacha"], raw["battle"], troops, skills, cards, enemies, scenarios)


def build_fighter(db: CardDB, card_id: str) -> Fighter:
    """兵种基础 + 武将自身能力. Skills = the troop's skill + the general's own."""
    c = db.cards[card_id]
    t = db.troops[c.troop]
    skills = tuple(dict.fromkeys(t.skills + c.skills))
    return Fighter(c.id, c.name, c.troop, t.hp + c.bonus.get("hp", 0), t.at + c.bonus.get("at", 0),
                   skills, c.rarity)


def build_lord(db: CardDB, name: str) -> Fighter:
    t = db.troops[LORD]
    return Fighter(LORD, name, LORD, t.hp, t.at, t.skills)


def build_leader(db: CardDB, card: Fighter, members: list[Fighter], weights: list[float] | None = None) -> Leader:
    """Rance X: leader stat = leader_mult × own stat + the rest of the troop's cards.
    `weights` scales each member (duplicate soldier cards count for less, see collection.troop_members)."""
    m = db.battle["leader_mult"]
    w = weights or [1.0] * len(members)
    return Leader(card, tuple(members), round(m * card.hp + sum(f.hp * k for f, k in zip(members, w))),
                  round(m * card.at + sum(f.at * k for f, k in zip(members, w))))


def _power(hp: float, at: float, n_skills: int) -> int:
    return round(hp / 5 + at + 15 * n_skills)


def power(f: Fighter) -> int:
    """Rough one-number strength (战力) of a single card, for sorting and display."""
    return _power(f.hp, f.at, len(f.skills))


def power_split(db: CardDB, f: Fighter) -> tuple[int, int]:
    """(兵种战力, 武将战力): what the troop type brings vs what the general adds on top."""
    t = db.troops[f.troop]
    troop = _power(t.hp, t.at, len(t.skills))
    return troop, power(f) - troop
