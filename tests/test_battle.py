import random

import pytest

from sanguo.battle import Battle
from sanguo.cards import load_db


@pytest.fixture
def db():
    return load_db()


def new(db, seed=0):
    return Battle.from_scenario(db, "hulao", seed=seed)


def test_data_loads(db):
    assert "hulao" in db.scenarios
    assert db.generals["guanyu"].name == "关羽"


def test_round_starts_with_intents_and_ap(db):
    b = new(db)
    assert b.round == 1 and b.ap == 3
    assert set(b.intents) == {0, 1, 2}


def test_each_general_acts_once_per_round(db):
    b = new(db)
    b.act(1, "slash", 0)
    with pytest.raises(ValueError):
        b.act(1, "slash", 0)


def test_ap_limits_actions(db):
    b = new(db)
    b.act(0, "slash", 0)
    b.act(1, "slash", 0)
    b.act(2, "slash", 0)
    assert b.ap == 0
    assert not b.can_act(b.player[3])


def test_limited_uses_run_out(db):
    b = new(db)
    for _ in range(2):
        b.act(1, "qinglong", 0)
        b.end_turn()
    assert b.player[1].uses_left["qinglong"] == 0
    assert "qinglong" not in [s.id for s in b.usable_skills(b.player[1])]


def test_guard_halves_damage(db):
    hits = []
    for guarded in (False, True):
        b = new(db, seed=42)
        target = b.player[1]
        target.guard = guarded
        b._use(b.enemy[1], db.skills["fangtian"], target)
        hits.append(target.card.hp - target.hp)
    assert hits[1] == pytest.approx(hits[0] / 2, abs=1)


def test_turn_limit_loses(db):
    b = new(db)
    while b.result is None:
        for p in b.player:  # keep the player alive so only the clock can end it
            p.hp = p.card.hp
        b.end_turn()
    assert b.result == "lose"
    assert b.round == b.scenario.turn_limit


def test_win_when_all_enemies_down(db):
    b = new(db)
    for e in b.enemy[1:]:
        e.hp = 0
    b.enemy[0].hp = 1
    b.act(1, "slash", 0)
    assert b.result == "win"


def greedy_play(db, seed):
    """Simple bot: guard whoever an enemy targets hardest, otherwise hit the weakest enemy hard."""
    b = new(db, seed)
    rng = random.Random(seed)
    while b.result is None:
        while b.result is None and b.ap > 0:
            ready = [i for i, p in enumerate(b.player) if b.can_act(p)]
            if not ready:
                break
            i = rng.choice(ready)
            u = b.player[i]
            skills = b.usable_skills(u)
            hurt = any(p.alive and p.hp < 0.4 * p.card.hp for p in b.player)

            def score(s):
                kinds = {e["type"] for e in s.effects}
                if "damage" in kinds:
                    v = sum(e["power"] for e in s.effects if e["type"] == "damage")
                    return v * (len([x for x in b.enemy if x.alive]) if s.target == "all_enemies" else 1)
                if "heal" in kinds:
                    return 2.0 if hurt else 0
                return 0.1  # guard / buffs: only when nothing better

            sk = max(skills, key=score)
            tgt = None
            if b.needs_target(sk):
                pool = b.foes(u) if sk.target == "enemy" else b.friends(u)
                alive = [j for j, x in enumerate(pool) if x.alive]
                tgt = min(alive, key=lambda j: pool[j].hp / pool[j].card.hp)
            b.act(i, sk.id, tgt)
        b.end_turn()
    return b.result


def test_scenario_is_winnable_but_not_trivial(db):
    results = [greedy_play(db, s) for s in range(200)]
    win_rate = results.count("win") / len(results)
    # a naive damage-first bot (ignores enemy intents) should win only sometimes;
    # this leaves room for deliberate play (guarding, focus fire) to do better
    assert 0.15 < win_rate < 0.6, win_rate
