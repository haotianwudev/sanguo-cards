"""Player progress: owned cards, the party, quest position, save/load.

Two kinds of card:
  generals (R/SR/SSR) — unique; come from the gacha and the story.
  soldiers (N, 兵卡)  — stackable; come mostly from battle chests. Copies of the same soldier card back
                        their troop with diminishing returns (×0.6 per extra copy), so a *different*
                        soldier card of that troop (长沙刀兵 vs 丹阳兵) is worth more than another copy.
"""
from __future__ import annotations

import json
import random
from dataclasses import asdict, dataclass, field, fields
from pathlib import Path

from .cards import CardDB, Fighter, Leader, PlayerCard, build_fighter, build_leader, build_lord

DEFAULT_SAVE = Path.home() / ".sanguo-cards" / "save.json"


@dataclass
class Save:
    owned: list[str] = field(default_factory=list)  # general card ids, no duplicates
    soldiers: dict[str, int] = field(default_factory=dict)  # soldier card id -> copies
    party: list[str] = field(default_factory=list)  # leader card ids; the lord is implicit and always first
    cleared: list[str] = field(default_factory=list)  # scenario ids won at least once
    # quest map progress (see quest.py)
    quest: str = ""  # quest in progress ("" = none started)
    square: str = ""  # square the party stands on
    visited: list[str] = field(default_factory=list)
    resolved: bool = False  # current square done?
    damage: int = 0  # shared-HP damage carried between battles in this quest
    carry_extra: dict = field(default_factory=dict)  # card id -> {skill: 累积 increments}
    carry_uses: dict = field(default_factory=dict)  # card id -> {skill: uses left}
    choices: dict = field(default_factory=dict)  # choose-square id -> goto (remembered across retries)
    offer: list[str] = field(default_factory=list)  # generals shown on the current recruit square
    quests_cleared: list[str] = field(default_factory=list)
    lord_name: str = "主公"
    party_slots: int = 4  # including the lord
    theme: str = "light"  # UI theme: "light" | "dark"

    @classmethod
    def new(cls, db: CardDB) -> Save:
        return cls(party_slots=db.gacha["party_slots"])

    @classmethod
    def load(cls, path: Path) -> Save:
        raw = json.loads(path.read_text("utf-8"))
        known = {f.name for f in fields(cls)}
        return cls(**{k: v for k, v in raw.items() if k in known})  # older saves: drop retired fields

    def dump(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(asdict(self), ensure_ascii=False, indent=1), "utf-8")


def _sync(db: CardDB, save: Save) -> None:
    """Soldier ids found in `owned` (older saves, hand-built test saves) become soldier copies.
    Cards that no longer exist in the data (renamed / removed) are dropped."""
    if any(c not in db.cards for c in [*save.owned, *save.soldiers, *save.party]):
        save.owned = [c for c in save.owned if c in db.cards]
        save.soldiers = {c: n for c, n in save.soldiers.items() if c in db.cards}
        save.party = [c for c in save.party if c in db.cards]
    if any(db.cards[c].soldier for c in save.owned):
        for c in [c for c in save.owned if db.cards[c].soldier]:
            save.soldiers[c] = save.soldiers.get(c, 0) + 1
        save.owned = [c for c in save.owned if not db.cards[c].soldier]


def has(db: CardDB, save: Save, card_id: str) -> bool:
    _sync(db, save)
    return save.soldiers.get(card_id, 0) > 0 if db.cards[card_id].soldier else card_id in save.owned


def copies(db: CardDB, save: Save, card_id: str) -> int:
    _sync(db, save)
    return save.soldiers.get(card_id, 0) if db.cards[card_id].soldier else int(card_id in save.owned)


# ---- getting cards ---------------------------------------------------------

def pull(db: CardDB, save: Save, rng: random.Random, n: int) -> list[PlayerCard]:
    """Free, unlimited gacha for generals. Owned generals leave the pool, so there are never duplicates.
    If the rolled rarity is exhausted, roll again among rarities that still have cards."""
    _sync(db, save)
    rates = db.gacha["rates"]
    got = []
    for _ in range(n):
        pools = {r: [c for c in db.pool(r) if c.id not in save.owned] for r in db.gacha["rates"]}
        live = [r for r in db.gacha["rates"] if pools[r]]
        if not live:
            break  # every general is already owned
        rarity = rng.choices(live, weights=[rates[r] for r in live])[0]
        card = rng.choice(pools[rarity])
        save.owned.append(card.id)
        got.append(card)
    return got


def recruit_offer(db: CardDB, save: Save, rng: random.Random, n: int | None = None) -> list[PlayerCard]:
    """Recruiting shows a few unowned generals (rarity rolled per card) and the player keeps one."""
    _sync(db, save)
    n = n or db.gacha["offer_size"]
    rates = db.gacha["rates"]
    offer: list[PlayerCard] = []
    for _ in range(n):
        pools = {r: [c for c in db.pool(r) if c.id not in save.owned and c not in offer] for r in rates}
        live = [r for r in rates if pools[r]]
        if not live:
            break  # fewer generals left than slots
        rarity = rng.choices(live, weights=[rates[r] for r in live])[0]
        offer.append(rng.choice(pools[rarity]))
    return offer


def take(db: CardDB, save: Save, card_id: str) -> PlayerCard:
    """Keep the one card picked from a recruit offer (a general) or a chest (a soldier)."""
    card = db.cards[card_id]
    if not card.soldier and card_id in save.owned:
        raise ValueError(f"已经拥有 {card.name}")
    grant_card(db, save, card_id)
    return card


def pool_left(db: CardDB, save: Save) -> int:
    return sum(1 for r in db.gacha["rates"] for c in db.pool(r) if c.id not in save.owned)


def chest_offer(db: CardDB, rng: random.Random, n: int) -> list[PlayerCard]:
    """A treasure chest shows n different soldier cards (weighted by how common each is); the player keeps one."""
    pool = list(db.soldiers())
    offer: list[PlayerCard] = []
    for _ in range(min(n, len(pool))):
        c = rng.choices(pool, weights=[x.weight for x in pool])[0]
        offer.append(c)
        pool.remove(c)
    return offer


def open_chest(db: CardDB, save: Save, rng: random.Random, n: int) -> list[PlayerCard]:
    """Grant n soldier cards straight away (no choice) — used by the balance simulations."""
    _sync(db, save)
    pool = db.soldiers()
    got = rng.choices(pool, weights=[c.weight for c in pool], k=n)
    for c in got:
        save.soldiers[c.id] = save.soldiers.get(c.id, 0) + 1
    return got


def grant_card(db: CardDB, save: Save, card_id: str) -> None:
    """Give a card outside the gacha (story). Slots it into the party if there's room for its troop."""
    _sync(db, save)
    if db.cards[card_id].soldier:
        save.soldiers[card_id] = save.soldiers.get(card_id, 0) + 1
    elif card_id not in save.owned:
        save.owned.append(card_id)
    if card_id not in save.party and validate_party(db, save, save.party + [card_id]) is None:
        save.party.append(card_id)


# ---- party -------------------------------------------------------------

def owned_ids(db: CardDB, save: Save) -> list[str]:
    """Every distinct card the player has: generals, then soldier types."""
    _sync(db, save)
    return list(save.owned) + [c for c, n in save.soldiers.items() if n > 0]


def owned_fighters(db: CardDB, save: Save) -> list[Fighter]:
    return [build_fighter(db, cid) for cid in owned_ids(db, save)]


def validate_party(db: CardDB, save: Save, card_ids: list[str]) -> str | None:
    """Return an error message, or None if the party is legal."""
    if len(card_ids) > save.party_slots - 1:
        return f"最多 {save.party_slots - 1} 张卡（主公固定占一位）"
    if len(set(card_ids)) != len(card_ids):
        return "同一张卡不能重复上阵"
    troops, people = set(), set()
    for cid in card_ids:
        if not has(db, save, cid):
            return f"未拥有卡牌 {cid}"
        c = db.cards[cid]
        if c.person in people:
            return f"同一武将的不同版本不能同时上阵（{c.name}）"
        if c.troop in troops:
            return f"兵种重复：{db.troops[c.troop].name} 只能由一人指挥（{c.name}）"
        troops.add(c.troop)
        people.add(c.person)
    return None


def troop_members(db: CardDB, save: Save, leader_id: str) -> tuple[list[Fighter], list[float]]:
    """Everyone else in the leader's troop, with how much each counts: other generals fully; each soldier
    card type 1, 0.6, 0.36 … per copy (a soldier leader uses up one of its own copies)."""
    _sync(db, save)
    troop = db.cards[leader_id].troop
    decay = db.gacha["soldier_decay"]
    members, weights = [], []
    for c in save.owned:
        if c != leader_id and db.cards[c].troop == troop:
            members.append(build_fighter(db, c))
            weights.append(1.0)
    for c, n in save.soldiers.items():
        if db.cards[c].troop != troop:
            continue
        n -= c == leader_id
        f = build_fighter(db, c)
        for i in range(n):
            members.append(f)
            weights.append(decay ** i)
    return members, weights


def leader_for(db: CardDB, save: Save, card_id: str) -> Leader:
    members, weights = troop_members(db, save, card_id)
    return build_leader(db, build_fighter(db, card_id), members, weights)


def leader_power(ld: Leader) -> int:
    return round(ld.at + ld.hp / 5)


def auto_party(db: CardDB, save: Save) -> list[str]:
    """Best leader per troop (the strongest card leads), then the strongest troops that fit."""
    ranked = sorted(owned_ids(db, save), key=lambda c: leader_power(leader_for(db, save, c)), reverse=True)
    picked: list[str] = []
    for cid in ranked:
        if len(picked) == save.party_slots - 1:
            break
        if validate_party(db, save, picked + [cid]) is None:
            picked.append(cid)
    return picked


def party_leaders(db: CardDB, save: Save) -> list[Leader]:
    """The lord (alone in its unit) plus one leader per chosen troop."""
    return [build_leader(db, build_lord(db, save.lord_name), [])] + \
        [leader_for(db, save, cid) for cid in save.party if has(db, save, cid)]


def record_win(save: Save, scenario_id: str) -> None:
    if scenario_id not in save.cleared:
        save.cleared.append(scenario_id)


def chest_after_battle(db: CardDB, rng: random.Random, overkill: float, boss: bool) -> list[PlayerCard]:
    """Rance X: a won battle may drop a chest. Bosses always do; otherwise 50% + overkill share
    (overkill ≥ 50% of the enemy's HP guarantees it). Returns the soldier cards shown — keep one with take()."""
    chance = 1.0 if boss else min(1.0, db.gacha["chest_base"] + overkill)
    if rng.random() >= chance:
        return []
    return chest_offer(db, rng, db.gacha["chest_cards_boss" if boss else "chest_cards"])
