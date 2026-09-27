"""Player progress: owned cards, the party, story position, save/load."""
from __future__ import annotations

import json
import random
from dataclasses import asdict, dataclass, field
from pathlib import Path

from .cards import RARITIES, CardDB, Fighter, PlayerCard, build_fighter, build_lord, power

DEFAULT_SAVE = Path.home() / ".sanguo-cards" / "save.json"


@dataclass
class Save:
    owned: list[str] = field(default_factory=list)  # card ids, no duplicates
    party: list[str] = field(default_factory=list)  # card ids; the lord is implicit and always first
    cleared: list[str] = field(default_factory=list)  # scenario ids won at least once
    story_node: str = ""  # current story node ("" = the story's start)
    story_step: int = 0  # index of the next step inside that node
    story_path: list[str] = field(default_factory=list)  # branches taken, in order
    lord_name: str = "主公"
    party_slots: int = 4  # including the lord

    @classmethod
    def new(cls, db: CardDB) -> Save:
        return cls(party_slots=db.gacha["party_slots"])

    @classmethod
    def load(cls, path: Path) -> Save:
        return cls(**json.loads(path.read_text("utf-8")))

    def dump(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(asdict(self), ensure_ascii=False, indent=1), "utf-8")


# ---- gacha -------------------------------------------------------------

def pull(db: CardDB, save: Save, rng: random.Random, n: int) -> list[PlayerCard]:
    """Free, unlimited pulls. Owned cards leave the pool, so there are never duplicates.
    If the rolled rarity is exhausted, roll again among rarities that still have cards."""
    rates = db.gacha["rates"]
    got = []
    for _ in range(n):
        pools = {r: [c for c in db.pool(r) if c.id not in save.owned] for r in RARITIES}
        live = [r for r in RARITIES if pools[r]]
        if not live:
            break  # everything in the pool is already owned
        rarity = rng.choices(live, weights=[rates[r] for r in live])[0]
        card = rng.choice(pools[rarity])
        save.owned.append(card.id)
        got.append(card)
    return got


def pool_left(db: CardDB, save: Save) -> int:
    return sum(1 for c in db.cards.values() if c.in_pool and c.id not in save.owned)


# ---- party -------------------------------------------------------------

def owned_fighters(db: CardDB, save: Save) -> list[Fighter]:
    return [build_fighter(db, cid) for cid in save.owned]


def validate_party(db: CardDB, save: Save, card_ids: list[str]) -> str | None:
    """Return an error message, or None if the party is legal."""
    if len(card_ids) > save.party_slots - 1:
        return f"最多 {save.party_slots - 1} 张卡（主公固定占一位）"
    if len(set(card_ids)) != len(card_ids):
        return "同一张卡不能重复上阵"
    troops, people = set(), set()
    for cid in card_ids:
        if cid not in save.owned:
            return f"未拥有卡牌 {cid}"
        c = db.cards[cid]
        if c.person in people:
            return f"同一武将的不同版本不能同时上阵（{c.name}）"
        if c.troop in troops:
            return f"兵种重复：{db.troops[c.troop].name} 只能由一人指挥（{c.name}）"
        troops.add(c.troop)
        people.add(c.person)
    return None


def auto_party(db: CardDB, save: Save) -> list[str]:
    """Greedy: strongest cards first, skipping any whose troop type or general is already in."""
    picked: list[str] = []
    for f in sorted(owned_fighters(db, save), key=power, reverse=True):
        if len(picked) == save.party_slots - 1:
            break
        if validate_party(db, save, picked + [f.id]) is None:
            picked.append(f.id)
    return picked


def party_fighters(db: CardDB, save: Save) -> list[Fighter]:
    return [build_lord(db, save.lord_name)] + [build_fighter(db, cid) for cid in save.party]


def record_win(save: Save, scenario_id: str) -> None:
    if scenario_id not in save.cleared:
        save.cleared.append(scenario_id)


def grant_card(db: CardDB, save: Save, card_id: str) -> None:
    """Give a card outside the gacha (story). Slots it into the party if there's room for its troop."""
    if card_id not in save.owned:
        save.owned.append(card_id)
    if card_id not in save.party and validate_party(db, save, save.party + [card_id]) is None:
        save.party.append(card_id)
