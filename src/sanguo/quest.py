"""Rance X style quest maps. Pure logic — the UI renders squares and calls resolve()/move().

A quest is a map of squares laid out in columns (x) and rows (y). The party stands on one square,
resolves it, then steps forward to one of its `next` squares — never back.
Square types:
  event    story text (+ optional portraits, optional reward cards)
  choose   pick one card; that card joins and the path continues at the option's `goto`
  battle   must win to continue (`boss: true` marks the big one)
  treasure a random card from the gacha pool
  recover  restore the shared HP bar and reset cumulative AP costs / once-per-battle skills
Within a quest the party's damage and cumulative skill costs carry over from battle to battle
(Rance X); they reset at a recover square or when the quest ends. Losing restarts the quest,
but choices already made are remembered.
"""
from __future__ import annotations

import json
import random
from dataclasses import dataclass
from importlib import resources

from . import collection as col
from .cards import CardDB, PlayerCard

TYPES = ("event", "choose", "battle", "treasure", "recover")


@dataclass(frozen=True)
class Square:
    id: str
    x: int
    y: int
    type: str
    next: tuple[str, ...] = ()
    text: tuple[str, ...] = ()
    portraits: tuple[str, ...] = ()
    cards: tuple[str, ...] = ()  # event rewards
    choose: tuple[dict, ...] = ()  # {"card", "label", "goto"}
    battle: str | None = None
    boss: bool = False
    label: str = ""  # short name shown on the map / move buttons


@dataclass(frozen=True)
class Quest:
    id: str
    title: str
    start: str
    squares: dict[str, Square]


def load_quests(db: CardDB, raw: dict | None = None) -> list[Quest]:
    if raw is None:
        raw = json.loads(resources.files("sanguo.data").joinpath("story.json").read_text("utf-8"))
    quests = []
    for q in raw["quests"]:
        squares = {}
        for sid, s in q["squares"].items():
            squares[sid] = Square(sid, s["x"], s["y"], s["type"], tuple(s.get("next", ())), tuple(s.get("text", ())),
                                  tuple(s.get("portraits", ())), tuple(s.get("cards", ())), tuple(s.get("choose", ())),
                                  s.get("battle"), s.get("boss", False), s.get("label", ""))
        quests.append(Quest(q["id"], q["title"], q["start"], squares))
    _validate(db, quests)
    return quests


def _validate(db: CardDB, quests: list[Quest]) -> None:
    for q in quests:
        if q.start not in q.squares:
            raise ValueError(f"quest {q.id}: unknown start {q.start}")
        for s in q.squares.values():
            where = f"quest {q.id} square {s.id}"
            if s.type not in TYPES:
                raise ValueError(f"{where}: unknown type {s.type}")
            targets = list(s.next) + [o["goto"] for o in s.choose]
            for t in targets:
                if t not in q.squares:
                    raise ValueError(f"{where}: unknown next square {t}")
                if q.squares[t].x <= s.x:
                    raise ValueError(f"{where}: next square {t} must be further right (no going back)")
            if s.type == "battle" and s.battle not in db.scenarios:
                raise ValueError(f"{where}: unknown battle {s.battle}")
            if s.type == "choose" and not s.choose:
                raise ValueError(f"{where}: choose square without options")
            bad = [c for c in list(s.cards) + [o["card"] for o in s.choose] if c not in db.cards]
            if bad:
                raise ValueError(f"{where}: unknown cards {bad}")


# ---- state -------------------------------------------------------------------

def current_quest(quests: list[Quest], save: col.Save) -> Quest | None:
    return next((q for q in quests if q.id not in save.quests_cleared), None)


def ensure_started(quests: list[Quest], save: col.Save) -> Quest | None:
    """Put the party on the current quest's start square if it isn't on that quest yet."""
    q = current_quest(quests, save)
    if q is not None and save.quest != q.id:
        begin(q, save)
    return q


def begin(q: Quest, save: col.Save) -> None:
    save.quest = q.id
    save.square = q.start
    save.visited = [q.start]
    save.resolved = False
    reset_carry(save)
    _auto_resolve(q, save)


def reset_carry(save: col.Save) -> None:
    save.damage = 0
    save.carry_extra = {}
    save.carry_uses = {}


def here(q: Quest, save: col.Save) -> Square:
    return q.squares[save.square]


def next_options(q: Quest, save: col.Save) -> list[Square]:
    """Squares the party may step to (only once the current square is resolved)."""
    if not save.resolved:
        return []
    s = here(q, save)
    if s.type == "choose":
        return [q.squares[save.choices[s.id]]]
    return [q.squares[n] for n in s.next]


def finished_square(q: Quest, save: col.Save) -> bool:
    """Resolved and nowhere left to go: the quest is complete."""
    return save.resolved and not next_options(q, save)


def resolve(db: CardDB, q: Quest, save: col.Save, rng: random.Random,
            choice: int | None = None) -> list[PlayerCard]:
    """Resolve the current square (battles: call only after a win). Returns any cards gained."""
    s = here(q, save)
    gained: list[PlayerCard] = []
    if save.resolved:
        return gained
    if s.type == "event":
        for cid in s.cards:
            if cid not in save.owned:
                gained.append(db.cards[cid])
            col.grant_card(db, save, cid)
    elif s.type == "choose":
        opt = s.choose[choice]
        save.choices[s.id] = opt["goto"]
        if opt["card"] not in save.owned:
            gained.append(db.cards[opt["card"]])
        col.grant_card(db, save, opt["card"])
    elif s.type == "treasure":
        gained = col.pull(db, save, rng, 1)
    elif s.type == "recover":
        reset_carry(save)
    save.resolved = True
    return gained


def move(q: Quest, save: col.Save, square_id: str) -> None:
    if square_id not in [s.id for s in next_options(q, save)]:
        raise ValueError(f"cannot move to {square_id}")
    save.square = square_id
    save.visited.append(square_id)
    save.resolved = False
    _auto_resolve(q, save)


def _auto_resolve(q: Quest, save: col.Save) -> None:
    # a choice made on an earlier attempt of this quest stays made
    s = here(q, save)
    if s.type == "choose" and s.id in save.choices:
        save.resolved = True


def complete(q: Quest, save: col.Save) -> None:
    if q.id not in save.quests_cleared:
        save.quests_cleared.append(q.id)
    save.quest = ""
    reset_carry(save)


def fail(q: Quest, save: col.Save) -> None:
    """Lost a battle: back to the start of the quest with full HP. Cards and choices are kept."""
    begin(q, save)
