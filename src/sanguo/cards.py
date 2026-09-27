"""Load card data (skills, generals, scenarios) from the bundled JSON."""
from __future__ import annotations

import json
from dataclasses import dataclass
from importlib import resources


@dataclass(frozen=True)
class Skill:
    id: str
    name: str
    cost: int
    uses: int | None  # None = unlimited per battle
    target: str  # enemy | ally | all_enemies | all_allies
    effects: tuple[dict, ...]


@dataclass(frozen=True)
class GeneralCard:
    id: str
    name: str
    faction: str
    hp: int
    atk: int
    int: int
    def_: int
    skills: tuple[str, ...]


@dataclass(frozen=True)
class Scenario:
    id: str
    name: str
    turn_limit: int
    ap: int
    player: tuple[str, ...]
    enemy: tuple[str, ...]


@dataclass(frozen=True)
class CardDB:
    skills: dict[str, Skill]
    generals: dict[str, GeneralCard]
    scenarios: dict[str, Scenario]


def load_raw() -> dict:
    return json.loads(resources.files("sanguo.data").joinpath("cards.json").read_text("utf-8"))


def load_db(raw: dict | None = None) -> CardDB:
    """Build the card DB from the bundled JSON, or from an already-parsed dict (for tuning/tests)."""
    raw = load_raw() if raw is None else raw
    skills = {
        sid: Skill(sid, s["name"], s["cost"], s["uses"], s["target"], tuple(s["effects"]))
        for sid, s in raw["skills"].items()
    }
    generals = {
        gid: GeneralCard(gid, g["name"], g["faction"], g["hp"], g["atk"], g["int"], g["def"],
                         tuple(g["skills"]))
        for gid, g in raw["generals"].items()
    }
    scenarios = {
        sid: Scenario(sid, s["name"], s["turn_limit"], s["ap"], tuple(s["player"]), tuple(s["enemy"]))
        for sid, s in raw["scenarios"].items()
    }
    for g in generals.values():
        missing = [s for s in g.skills if s not in skills]
        if missing:
            raise ValueError(f"{g.id} references unknown skills {missing}")
    for sc in scenarios.values():
        missing = [g for g in sc.player + sc.enemy if g not in generals]
        if missing:
            raise ValueError(f"scenario {sc.id} references unknown generals {missing}")
    return CardDB(skills, generals, scenarios)
