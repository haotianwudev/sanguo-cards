import pytest

from sanguo import collection as col
from sanguo.battle import Battle
from sanguo.cards import load_db


@pytest.fixture
def db():
    return load_db()


def party(db, leaders, extra=()):
    """Leaders plus any extra owned cards (which back up their troop's leader)."""
    save = col.Save(owned=list(leaders) + list(extra), party=list(leaders))
    return col.party_leaders(db, save)


# mid-strength party: SR leaders, a few R/N cards behind them
REF = (("machao", "zhangfei", "daqiao"), ("madai", "cav_n", "wangping", "spear_n", "mizhu"))
# weakest legal party: plain troop cards only
STARTER = (("cav_n", "spear_n", "archer_n"), ())
SSR = (("guanyu", "zhaoyun", "diaochan"), ("machao", "madai", "cav_n", "zhangfei", "wangping", "daqiao", "mizhu"))


def new(db, scenario="hulao", comp=REF, seed=0):
    return Battle.start(db, scenario, party(db, *comp), seed=seed)


def test_one_shared_hp_bar_is_the_sum_of_leaders(db):
    b = new(db)
    assert b.party_hp == b.party_max == sum(u.leader.hp for u in b.leaders)


def test_leader_stats_are_5x_own_plus_troop(db):
    (lord, cav, *_) = party(db, *REF)
    assert cav.card.id == "machao"
    assert {m.id for m in cav.members} == {"madai", "cav_n"}
    assert cav.at == 5 * cav.card.at + sum(m.at for m in cav.members)
    assert cav.hp == 5 * cav.card.hp + sum(m.hp for m in cav.members)
    assert lord.members == ()


def test_enemy_hp_scales_with_party_size(db):
    small = Battle.start(db, "hulao", party(db, ("machao",)), seed=0)
    big = new(db)
    assert big.enemy.max_hp > small.enemy.max_hp


def test_ap_starts_at_2_gains_2_caps_at_6(db):
    b = new(db)
    assert b.ap == 2
    seen = []
    for _ in range(4):
        b.party_hp = b.party_max
        b.end_round()
        seen.append(b.ap)
    assert seen == [4, 6, 6, 6]


def test_each_leader_acts_once_per_round(db):
    b = new(db)
    b.act(0, "tuji")
    with pytest.raises(ValueError):
        b.act(0, "tuji")


def test_cumulative_skill_costs_one_more_each_use(db):
    b = new(db)
    ma = b.leaders[1]
    charge = db.skills["charge"]
    assert b.cost(ma, charge) == 1
    b.act(1, "charge")
    assert b.cost(ma, charge) == 2
    assert b.ap == 1


def test_once_per_battle_skill(db):
    b = new(db)
    b.ap = 6
    b.act(1, "xiliang")
    b.party_hp = b.party_max
    b.end_round()
    assert not b.usable(b.leaders[1], db.skills["xiliang"])


def test_combo_adds_ten_percent_per_hit(db):
    b = new(db, seed=1)
    b.rng.uniform = lambda lo, hi: 1.0  # no variance
    b.combo = 0
    d0 = b._dmg(1000, "magic")
    b.combo = 5
    assert b._dmg(1000, "magic") == round(d0 * 1.5)


def test_defend_cut_grows_with_consecutive_defends(db):
    b = new(db, seed=2)
    lines = []
    for _ in range(3):
        b.party_hp = b.party_max
        lines.append(b.defend()[0])
    assert "30%" in lines[0] and "50%" in lines[1] and "70%" in lines[2]
    b.party_hp = b.party_max
    b.end_round()
    assert "30%" in b.defend()[0]


def test_turn_limit_loses(db):
    b = new(db)
    while b.result is None:
        b.party_hp = b.party_max
        b.end_round()
    assert b.result == "lose" and b.round == b.scenario.turn_limit


def test_win_when_enemy_hp_zero(db):
    b = new(db)
    b.enemy.hp = 1
    b.act(0, "tuji")
    assert b.result == "win"


# ---- balance ---------------------------------------------------------------

def expected_value(b, u, sk):
    v = 0.0
    for e in sk.effects:
        if e["type"] in ("attack", "magic"):
            v += u.at * e["power"] * e.get("hits", 1)
        elif e["type"] == "heal":
            v += u.at * e["power"] * (1.5 if b.party_hp < 0.4 * b.party_max else 0.0)
        elif e["type"] == "stun":
            v += e["chance"] * b.enemy.data.at * 2
        else:
            v += 0.2 * u.at
    return v


def greedy_play(db, scenario, comp, seed):
    """Naive bot: spends AP on the best value-per-AP action until nothing is usable; never defends."""
    b = new(db, scenario, comp, seed)
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
    return b.result


def win_rate(db, scenario, comp, n=200):
    return [greedy_play(db, scenario, comp, s) for s in range(n)].count("win") / n


@pytest.mark.parametrize("hero", ["sunce", "zhouyu", "huanggai"])
def test_bandits_are_beatable_with_any_opening_choice(db, hero):
    assert win_rate(db, "shanzei", ((hero,), ())) > 0.7


def test_huangjin_is_beatable_with_starter_troops(db):
    assert 0.3 < win_rate(db, "huangjin", STARTER) < 0.9


def test_hulao_is_hard_for_naive_play(db):
    assert 0.15 < win_rate(db, "hulao", REF) < 0.6


def test_better_cards_win_more(db):
    assert win_rate(db, "hulao", STARTER) < win_rate(db, "hulao", REF) < win_rate(db, "hulao", SSR)
