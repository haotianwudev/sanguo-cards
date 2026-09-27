import random

import pytest

from sanguo.battle import Battle
from sanguo.cards import build_fighter, build_lord, load_db


@pytest.fixture
def db():
    return load_db()


def party(db, *card_ids):
    return [build_lord(db, "主公")] + [build_fighter(db, c) for c in card_ids]


# a plausible party after ~20 draws: a few SRs, no SSR
REF_HULAO = ("machao", "zhangfei", "daqiao")
# the weakest legal party: plain troop cards only
STARTER = ("cav_n", "spear_n", "archer_n")


def new(db, scenario="hulao", cards=REF_HULAO, seed=0):
    return Battle.from_scenario(db, scenario, party(db, *cards), seed=seed)


def test_round_starts_with_intents_and_ap(db):
    b = new(db)
    assert b.round == 1 and b.ap == 3
    assert set(b.intents) == {0, 1, 2}


def test_each_unit_acts_once_per_round(db):
    b = new(db)
    b.act(1, "slash", 0)
    with pytest.raises(ValueError):
        b.act(1, "slash", 0)


def test_ap_limits_actions(db):
    b = new(db)
    for i in range(3):
        b.act(i, "slash", 0)
    assert b.ap == 0
    assert not b.can_act(b.player[3])


def test_ap_skill_lets_everyone_act(db):
    b = new(db, cards=("cav_n", "spear_n", "huangyueying"))
    b.act(3, "muniu")  # cost 1, +2 AP
    assert b.ap == 4
    for i in range(3):
        b.act(i, "slash", 0)


def test_limited_uses_run_out(db):
    b = new(db)
    b.act(1, "xiliang", 0)  # 马超 signature, 1 use
    b.end_turn()
    assert b.player[1].uses_left["xiliang"] == 0
    assert "xiliang" not in [s.id for s in b.usable_skills(b.player[1])]


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


def greedy_play(db, scenario, cards, seed):
    """Naive bot: ignores enemy intents; hits the weakest enemy with its biggest attack, heals when hurt."""
    b = new(db, scenario, cards, seed)
    rng = random.Random(seed)
    while b.result is None:
        while b.result is None and b.ap > 0:
            ready = [i for i, p in enumerate(b.player) if b.can_act(p)]
            if not ready:
                break
            i = rng.choice(ready)
            u = b.player[i]
            hurt = any(p.alive and p.hp < 0.4 * p.card.hp for p in b.player)

            def score(s):
                kinds = {e["type"] for e in s.effects}
                if "damage" in kinds:
                    v = sum(e["power"] for e in s.effects if e["type"] == "damage")
                    return v * (len([x for x in b.enemy if x.alive]) if s.target == "all_enemies" else 1)
                if "heal" in kinds:
                    return 2.0 if hurt else 0
                return 0.1  # guard / buffs: only when nothing better

            sk = max(b.usable_skills(u), key=score)
            tgt = None
            if b.needs_target(sk):
                pool = b.foes(u) if sk.target == "enemy" else b.friends(u)
                alive = [j for j, x in enumerate(pool) if x.alive]
                tgt = min(alive, key=lambda j: pool[j].hp / pool[j].card.hp)
            b.act(i, sk.id, tgt)
        b.end_turn()
    return b.result


def win_rate(db, scenario, cards, n=200):
    return [greedy_play(db, scenario, cards, s) for s in range(n)].count("win") / n


def test_huangjin_is_beatable_with_starter_troops(db):
    # the first battle should be winnable with only N cards, but not a free win
    assert 0.3 < win_rate(db, "huangjin", STARTER) < 0.9


def test_hulao_is_hard_for_naive_play(db):
    # leaves room for deliberate play (guarding vs 无双, focus fire) to do better
    assert 0.15 < win_rate(db, "hulao", REF_HULAO) < 0.6


def test_better_cards_win_more(db):
    ssr = ("guanyu", "zhaoyun", "diaochan")
    assert win_rate(db, "hulao", STARTER) < win_rate(db, "hulao", REF_HULAO) < win_rate(db, "hulao", ssr)
