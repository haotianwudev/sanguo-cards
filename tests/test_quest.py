import random

import pytest

from sanguo import collection as col
from sanguo import quest
from sanguo.battle import Battle
from sanguo.cards import load_db
from test_battle import expected_value


@pytest.fixture
def db():
    return load_db()


@pytest.fixture
def qs(db):
    return quest.load_quests(db)


def bot_battle(db, save, scenario, seed, boss=False):
    """Fight one quest battle with the naive bot, carrying the quest's wear in and out."""
    b = Battle.start(db, scenario, col.party_leaders(db, save), seed=seed,
                     damage=save.damage, extra=save.carry_extra, uses=save.carry_uses)
    while b.result is None:
        while b.result is None:
            options = [(i, sk) for i, u in enumerate(b.leaders) if b.can_act(i)
                       for sk in b.skills_of(u) if b.usable(u, sk)]
            if not options:
                break
            i, sk = max(options, key=lambda o: expected_value(b, b.leaders[o[0]], o[1])
                        / (b.cost(b.leaders[o[0]], o[1]) + 1))
            b.act(i, sk.id)
        if b.result is None:
            b.end_round()
    if b.result == "win":
        save.damage, extra, uses = b.carry_out()
        save.carry_extra.update(extra)
        save.carry_uses.update(uses)
        col.chest_after_battle(db, save, random.Random(seed), b.overkill, boss)
    return b.result == "win"


def play_quest(db, q, save, pick=0, fork=None, seed=0):
    """Walk a quest: choose `pick` at choose squares, take fork index `fork` (None = random),
    auto-party before every battle. Returns True if the quest was completed."""
    rng = random.Random(seed)
    quest.begin(q, save)
    steps = 0
    while True:
        steps += 1
        s = quest.here(q, save)
        if s.type == "battle" and not save.resolved:
            save.party = col.auto_party(db, save)
            if not bot_battle(db, save, s.battle, rng.randrange(10**6), s.boss):
                return False
        quest.resolve(db, q, save, rng, pick if s.type == "choose" else None)
        opts = quest.next_options(q, save)
        if not opts:
            quest.complete(q, save)
            return True
        nxt = opts[fork if fork is not None and fork < len(opts) else rng.randrange(len(opts))]
        quest.move(q, save, nxt.id)
        assert steps < 100


def test_maps_only_move_forward(qs):
    for q in qs:
        for s in q.squares.values():
            for n in list(s.next) + [o["goto"] for o in s.choose]:
                assert q.squares[n].x > s.x
                assert abs(q.squares[n].y - s.y) <= 1  # drawable: diagonals move one row


def test_cannot_move_before_resolving_or_backwards(db, qs):
    q = qs[0]
    save = col.Save.new(db)
    quest.begin(q, save)
    assert quest.next_options(q, save) == []
    with pytest.raises(ValueError):
        quest.move(q, save, "pick")
    quest.resolve(db, q, save, random.Random(0))
    quest.move(q, save, "pick")
    with pytest.raises(ValueError):
        quest.move(q, save, "wake")


@pytest.mark.parametrize("pick,branch,cards", [(0, "sc_talk", {"sunce", "cav_n"}),
                                               (1, "zy_talk", {"zhouyu", "archer_n"}),
                                               (2, "hg_talk", {"huanggai", "inf_n"})])
def test_each_choice_walks_its_own_branch(db, qs, pick, branch, cards):
    q = qs[0]
    save = col.Save.new(db)
    quest.begin(q, save)
    quest.resolve(db, q, save, random.Random(0))
    quest.move(q, save, "pick")
    quest.resolve(db, q, save, random.Random(0), pick)
    assert [s.id for s in quest.next_options(q, save)] == [branch]
    assert save.choices["pick"] == branch


def test_recover_square_clears_carried_wear(db, qs):
    q = qs[0]
    save = col.Save.new(db)
    quest.begin(q, save)
    save.damage, save.carry_extra = 500, {"lord": {"haoling": 1}}
    save.square, save.resolved = "spring", False
    quest.resolve(db, q, save, random.Random(0))
    assert save.damage == 0 and save.carry_extra == {}


def test_battle_starts_with_carried_damage_and_costs(db):
    save = col.Save(owned=["machao"], party=["machao"])
    party = col.party_leaders(db, save)
    b = Battle.start(db, "hulao", party, seed=0, damage=1000, extra={"machao": {"charge": 2}})
    assert b.party_hp == b.party_max - 1000
    assert b.cost(b.leaders[1], db.skills["charge"]) == 3


def test_failing_restarts_the_quest_but_keeps_choices_and_cards(db, qs):
    q = qs[0]
    save = col.Save.new(db)
    quest.begin(q, save)
    quest.resolve(db, q, save, random.Random(0))
    quest.move(q, save, "pick")
    quest.resolve(db, q, save, random.Random(0), 1)
    save.damage = 999
    quest.fail(q, save)
    assert save.square == "wake" and save.damage == 0 and "zhouyu" in save.owned
    quest.resolve(db, q, save, random.Random(0))
    quest.move(q, save, "pick")
    assert save.resolved  # the earlier choice stands
    assert [s.id for s in quest.next_options(q, save)] == ["zy_talk"]


def test_old_saves_still_load(tmp_path):
    path = tmp_path / "old.json"
    path.write_text('{"owned": ["cav_n"], "story_node": "x", "story_step": 2, "story_path": []}', "utf-8")
    assert col.Save.load(path).owned == ["cav_n"]


# ---- whole-quest balance (HP carries between battles) --------------------------

def rate(db, q, owned, pick=0, fork=None, n=60):
    wins = 0
    for seed in range(n):
        save = col.Save(owned=list(owned))
        wins += play_quest(db, q, save, pick, fork, seed)
    return wins / n


@pytest.mark.parametrize("pick", [0, 1, 2])
def test_prologue_is_winnable_with_any_choice(db, qs, pick):
    assert rate(db, qs[0], [], pick) > 0.7


def test_huangjin_quest_is_fair_with_a_starter_collection(db, qs):
    owned = ["zhouyu", "archer_n", "strat_n", "wuguotai", "cav_n", "spear_n", "madai", "mizhu"]
    assert 0.3 < rate(db, qs[1], owned) < 0.95


def test_hulao_quest_needs_a_real_party(db, qs):
    weak = ["cav_n", "spear_n", "archer_n"]
    mid = ["machao", "zhangfei", "daqiao", "madai", "cav_n", "wangping", "spear_n", "mizhu"]
    assert rate(db, qs[2], weak) < 0.1
    # the fork after 汜水关 matters: resting (fork 1) before 吕布 beats grabbing the treasure (fork 0)
    rest, greedy = rate(db, qs[2], mid, fork=1), rate(db, qs[2], mid, fork=0)
    assert 0.15 < rest < 0.8
    assert greedy < rest
