"""Player progress: 招募令 (draws), owned cards, the party, save/load."""
from __future__ import annotations

import json
import random
from dataclasses import asdict, dataclass, field
from pathlib import Path

from .cards import RARITIES, CardDB, Fighter, PlayerCard, build_fighter, build_lord, power

DEFAULT_SAVE = Path.home() / ".sanguo-cards" / "save.json"


@dataclass
class Save:
    draws: int = 0  # 招募令, one per pull
    owned: list[str] = field(default_factory=list)  # card ids, no duplicates
    party: list[str] = field(default_factory=list)  # card ids; the lord is implicit and always first
    cleared: list[str] = field(default_factory=list)  # scenario ids won at least once
    lord_name: str = "主公"
    party_slots: int = 4  # including the lord

    @classmethod
    def new(cls, db: CardDB) -> Save:
        return cls(draws=db.gacha["start_draws"], party_slots=db.gacha["party_slots"])

    @classmethod
    def load(cls, path: Path) -> Save:
        return cls(**json.loads(path.read_text("utf-8")))

    def dump(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(asdict(self), ensure_ascii=False, indent=1), "utf-8")


# ---- gacha -------------------------------------------------------------

def pull(db: CardDB, save: Save, rng: random.Random, n: int) -> list[PlayerCard]:
    """Spend n 招募令. Owned cards leave the pool, so there are never duplicates.
    If the rolled rarity is exhausted, roll again among rarities that still have cards."""
    if n > save.draws:
        raise ValueError(f"招募令不足：需要 {n}，现有 {save.draws}")
    rates = db.gacha["rates"]
    got = []
    for _ in range(n):
        pools = {r: [c for c in db.pool(r) if c.id not in save.owned] for r in RARITIES}
        live = [r for r in RARITIES if pools[r]]
        if not live:
            break  # everything available is already owned; unspent draws are kept
        rarity = rng.choices(live, weights=[rates[r] for r in live])[0]
        card = rng.choice(pools[rarity])
        save.owned.append(card.id)
        save.draws -= 1
        got.append(card)
    return got


def pool_left(db: CardDB, save: Save) -> int:
    return sum(1 for c in db.cards.values() if c.id not in save.owned)


# ---- party -------------------------------------------------------------

def owned_fighters(db: CardDB, save: Save) -> list[Fighter]:
    return [build_fighter(db, cid) for cid in save.owned]


def validate_party(db: CardDB, save: Save, card_ids: list[str]) -> str | None:
    """Return an error message, or None if the party is legal."""
    if len(card_ids) > save.party_slots - 1:
        return f"最多 {save.party_slots - 1} 张卡（主公固定占一位）"
    if len(set(card_ids)) != len(card_ids):
        return "同一张卡不能重复上阵"
    seen = set()
    for cid in card_ids:
        if cid not in save.owned:
            return f"未拥有卡牌 {cid}"
        t = db.cards[cid].troop
        if t in seen:
            return f"兵种重复：{db.troops[t].name} 只能由一人指挥（{db.cards[cid].name}）"
        seen.add(t)
    return None


def auto_party(db: CardDB, save: Save) -> list[str]:
    """Strongest card of each troop type, then the strongest troop types that fit."""
    best: dict[str, Fighter] = {}
    for f in owned_fighters(db, save):
        if f.troop not in best or power(f) > power(best[f.troop]):
            best[f.troop] = f
    ranked = sorted(best.values(), key=power, reverse=True)
    return [f.id for f in ranked[: save.party_slots - 1]]


def party_fighters(db: CardDB, save: Save) -> list[Fighter]:
    return [build_lord(db, save.lord_name)] + [build_fighter(db, cid) for cid in save.party]


def record_win(db: CardDB, save: Save, scenario_id: str) -> int:
    """Every win pays out 招募令 (story will take over handing these out later)."""
    if scenario_id not in save.cleared:
        save.cleared.append(scenario_id)
    save.draws += db.gacha["draws_on_win"]
    return db.gacha["draws_on_win"]
