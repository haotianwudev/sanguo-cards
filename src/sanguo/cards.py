"""Load card data (troops, skills, gacha cards, enemies, scenarios) and turn cards into fighters."""
from __future__ import annotations

import json
from dataclasses import dataclass
from importlib import resources

RARITIES = ("N", "R", "SR", "SSR")
LORD = "lord"
TARGETS = ("enemy", "ally", "self", "all_enemies", "all_allies")


@dataclass(frozen=True)
class Skill:
    id: str
    name: str
    cost: int
    uses: int | None  # None = unlimited per battle
    target: str  # one of TARGETS
    effects: tuple[dict, ...]


@dataclass(frozen=True)
class Troop:
    """A 兵种: base stats and the skills every card of this type gets."""
    id: str
    name: str
    short: str
    hp: int
    atk: int
    int: int
    def_: int
    skills: tuple[str, ...]


@dataclass(frozen=True)
class PlayerCard:
    """A gacha card: a troop type, optionally led by a named general whose own ability (bonus stats +
    signature skills) adds on top of the troop base. N cards are plain troops with no general."""
    id: str
    name: str
    rarity: str
    troop: str
    bonus: dict[str, int]
    skills: tuple[str, ...]
    in_pool: bool = True  # False = story-only, never drawn from the gacha
    person: str = ""  # who this is; variants of one general (孙策·少年 / 孙策·中年) share it


@dataclass(frozen=True)
class Fighter:
    """Final battle-ready stats — what a Unit is built from, for both sides."""
    id: str
    name: str
    troop: str
    hp: int
    atk: int
    int: int
    def_: int
    skills: tuple[str, ...]
    rarity: str | None = None


@dataclass(frozen=True)
class Scenario:
    id: str
    name: str
    turn_limit: int
    ap: int
    enemy: tuple[str, ...]


@dataclass(frozen=True)
class CardDB:
    gacha: dict
    troops: dict[str, Troop]
    skills: dict[str, Skill]
    cards: dict[str, PlayerCard]
    enemies: dict[str, Fighter]
    scenarios: dict[str, Scenario]

    def pool(self, rarity: str) -> list[PlayerCard]:
        return [c for c in self.cards.values() if c.rarity == rarity and c.in_pool]


def load_raw() -> dict:
    return json.loads(resources.files("sanguo.data").joinpath("cards.json").read_text("utf-8"))


def load_db(raw: dict | None = None) -> CardDB:
    """Build the card DB from the bundled JSON, or from an already-parsed dict (for tuning/tests)."""
    raw = load_raw() if raw is None else raw
    skills = {
        sid: Skill(sid, s["name"], s["cost"], s["uses"], s["target"], tuple(s["effects"]))
        for sid, s in raw["skills"].items()
    }
    troops = {
        tid: Troop(tid, t["name"], t["short"], t["hp"], t["atk"], t["int"], t["def"], tuple(t["skills"]))
        for tid, t in raw["troops"].items()
    }
    cards = {
        cid: PlayerCard(cid, c["name"], c["rarity"], c["troop"], dict(c.get("bonus", {})),
                        tuple(c.get("skills", ())), c.get("pool", True), c.get("person", cid))
        for cid, c in raw["cards"].items()
    }
    enemies = {
        eid: Fighter(eid, e["name"], e["troop"], e["hp"], e["atk"], e["int"], e["def"], tuple(e["skills"]))
        for eid, e in raw["enemies"].items()
    }
    scenarios = {
        sid: Scenario(sid, s["name"], s["turn_limit"], s["ap"], tuple(s["enemy"]))
        for sid, s in raw["scenarios"].items()
    }

    def check(owner: str, skill_ids) -> None:
        missing = [s for s in skill_ids if s not in skills]
        if missing:
            raise ValueError(f"{owner} references unknown skills {missing}")

    for sk in skills.values():
        if sk.target not in TARGETS:
            raise ValueError(f"skill {sk.id} has unknown target {sk.target}")
    for t in troops.values():
        check(f"troop {t.id}", t.skills)
    for c in cards.values():
        check(f"card {c.id}", c.skills)
        if c.troop not in troops or c.troop == LORD:
            raise ValueError(f"card {c.id} has invalid troop {c.troop}")
        if c.rarity not in RARITIES:
            raise ValueError(f"card {c.id} has invalid rarity {c.rarity}")
    for e in enemies.values():
        check(f"enemy {e.id}", e.skills)
    for sc in scenarios.values():
        missing = [e for e in sc.enemy if e not in enemies]
        if missing:
            raise ValueError(f"scenario {sc.id} references unknown enemies {missing}")
    if LORD not in troops:
        raise ValueError("troops must define 'lord'")
    return CardDB(raw["gacha"], troops, skills, cards, enemies, scenarios)


def build_fighter(db: CardDB, card_id: str) -> Fighter:
    """兵种基础 + 武将自身能力. Skills = troop skills + the general's own."""
    c = db.cards[card_id]
    t = db.troops[c.troop]

    def stat(key: str, base: int) -> int:
        return base + c.bonus.get(key, 0)

    skills = tuple(dict.fromkeys(t.skills + c.skills))
    return Fighter(c.id, c.name, c.troop, stat("hp", t.hp), stat("atk", t.atk), stat("int", t.int),
                   stat("def", t.def_), skills, c.rarity)


def build_lord(db: CardDB, name: str) -> Fighter:
    t = db.troops[LORD]
    return Fighter(LORD, name, LORD, t.hp, t.atk, t.int, t.def_, t.skills)


def _power(hp: float, atk: float, int_: float, def_: float, n_skills: int) -> int:
    return round(hp / 5 + max(atk, int_) + def_ / 2 + 15 * n_skills)


def power(f: Fighter) -> int:
    """Rough one-number strength (战力) for sorting and display; skills count extra."""
    return _power(f.hp, f.atk, f.int, f.def_, len(f.skills))


def power_split(db: CardDB, f: Fighter) -> tuple[int, int]:
    """(兵种战力, 武将战力): what the troop type brings vs what the general adds on top."""
    t = db.troops[f.troop]
    troop = _power(t.hp, t.atk, t.int, t.def_, len(t.skills))
    return troop, power(f) - troop
