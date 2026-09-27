import random

import pytest

from sanguo import collection as col
from sanguo.cards import build_fighter, load_db, power, power_split


@pytest.fixture
def db():
    return load_db()


@pytest.fixture
def save(db):
    return col.Save.new(db)


def test_gacha_gives_unique_generals_only(db, save):
    generals = [c for c in db.cards.values() if c.in_pool and not c.soldier]
    got = col.pull(db, save, random.Random(1), len(generals) + 5)
    assert len(got) == len(generals)  # stops once every general is owned
    assert len(set(save.owned)) == len(save.owned) == len(generals)
    assert not any(c.soldier for c in got)  # soldiers come from chests
    assert not any(db.cards[c].in_pool is False for c in save.owned)  # story-only cards never drop


def test_rates_roughly_follow_config(db):
    counts = {"R": 0, "SR": 0, "SSR": 0}
    for seed in range(2000):
        s = col.Save()
        (card,) = col.pull(db, s, random.Random(seed), 1)
        counts[card.rarity] += 1
    rates = db.gacha["rates"]
    for r, c in counts.items():
        assert c / 2000 == pytest.approx(rates[r] / sum(rates.values()), abs=0.03)


def test_party_rejects_duplicate_troops(db, save):
    save.owned = ["machao", "guanyu", "zhangfei"]  # 马超 and 关羽 are both cavalry
    assert "兵种重复" in col.validate_party(db, save, ["machao", "guanyu"])
    assert col.validate_party(db, save, ["machao", "zhangfei"]) is None


def test_party_slot_limit_counts_the_lord(db, save):
    save.owned = ["cav_n", "spear_n", "archer_n", "inf_n"]
    assert col.validate_party(db, save, save.owned) is not None  # 4 cards + lord > 4 slots
    assert col.validate_party(db, save, save.owned[:3]) is None


def test_party_must_be_owned(db, save):
    assert "未拥有" in col.validate_party(db, save, ["guanyu"])


def test_auto_party_picks_best_per_troop(db, save):
    save.owned = ["cav_n", "madai", "guanyu", "spear_n", "archer_n", "log_n"]
    ids = col.auto_party(db, save)
    assert "guanyu" in ids and "cav_n" not in ids and "madai" not in ids
    assert col.validate_party(db, save, ids) is None
    save.party = ids
    leaders = col.party_leaders(db, save)
    assert leaders[0].card.troop == "lord" and len(leaders) == 4
    cav = next(ld for ld in leaders if ld.card.id == "guanyu")
    assert {m.id for m in cav.members} == {"cav_n", "madai"}  # benched cavalry backs 关羽 up
    assert set(save.owned) == {"madai", "guanyu"} and save.soldiers["cav_n"] == 1  # N ids became soldier copies


def test_general_adds_power_on_top_of_troop(db):
    troop_n, gen_n = power_split(db, build_fighter(db, "cav_n"))
    troop_g, gen_g = power_split(db, build_fighter(db, "guanyu"))
    assert gen_n == 0 and troop_n == troop_g
    assert gen_g > 0 and power(build_fighter(db, "guanyu")) == troop_g + gen_g


def test_save_roundtrip(db, save, tmp_path):
    col.pull(db, save, random.Random(0), 5)
    save.party = col.auto_party(db, save)
    path = tmp_path / "s.json"
    save.dump(path)
    assert col.Save.load(path) == save


def test_granted_card_fills_party_when_troop_free(db, save):
    col.grant_card(db, save, "sunce")  # cavalry
    col.grant_card(db, save, "cav_n")  # cavalry again: kept, but not auto-slotted
    assert save.party == ["sunce"] and save.soldiers["cav_n"] == 1


def test_variants_of_one_general_cannot_share_a_party(db, save):
    save.owned = ["sunce", "sunce_zhong", "zhouyu", "zhouyu_chibi"]
    assert "不同版本" in col.validate_party(db, save, ["sunce", "sunce_zhong"])
    assert "不同版本" in col.validate_party(db, save, ["zhouyu", "zhouyu_chibi"])
    assert col.validate_party(db, save, ["sunce_zhong", "zhouyu"]) is None
    ids = col.auto_party(db, save)
    assert len({db.cards[c].person for c in ids}) == len(ids)


def test_gacha_has_variants_of_story_generals_but_not_the_story_versions(db):
    pool_ids = {c.id for r in ("R", "SR", "SSR") for c in db.pool(r)}
    assert {"sunce_zhong", "zhouyu_chibi", "lvmeng"} <= pool_ids
    assert not ({"sunce", "zhouyu", "huanggai", "wuguotai"} & pool_ids)


# ---- soldiers & chests -----------------------------------------------------------

def test_chests_hold_stackable_soldiers(db, save):
    got = col.open_chest(db, save, random.Random(3), 30)
    assert len(got) == 30 and all(c.soldier for c in got)
    assert sum(save.soldiers.values()) == 30
    assert max(save.soldiers.values()) > 1  # duplicates stack


def test_duplicate_soldiers_decay_but_new_types_count_fully(db):
    lead = col.Save(owned=["zhangfei"])
    one = col.leader_for(db, lead, "zhangfei").at
    dup = col.Save(owned=["zhangfei"], soldiers={"spear_n": 2})
    two_same = col.leader_for(db, dup, "zhangfei").at
    mix = col.Save(owned=["zhangfei"], soldiers={"spear_n": 1, "qingzhou": 1})
    two_kinds = col.leader_for(db, mix, "zhangfei").at
    spear = build_fighter(db, "spear_n").at
    assert two_same == one + round(spear * 1.6) or abs(two_same - (one + spear * 1.6)) <= 1
    assert two_kinds > two_same  # a different soldier card beats another copy
    many = col.Save(owned=["zhangfei"], soldiers={"spear_n": 50})
    assert col.leader_for(db, many, "zhangfei").at < one + spear / (1 - 0.6) + 1  # bounded


def test_soldier_can_lead_and_uses_one_of_its_copies(db):
    save = col.Save(soldiers={"cav_n": 3})
    ld = col.leader_for(db, save, "cav_n")
    assert len(ld.members) == 2


def test_boss_always_drops_a_chest_and_overkill_helps(db):
    rng = random.Random(0)
    assert len(col.chest_after_battle(db, col.Save(), rng, 0.0, boss=True)) == db.gacha["chest_cards_boss"]
    assert col.chest_after_battle(db, col.Save(), rng, 0.5, boss=False)  # 50% overkill: guaranteed
    drops = sum(bool(col.chest_after_battle(db, col.Save(), random.Random(i), 0.0, False)) for i in range(400))
    assert 150 < drops < 250  # ~50% without overkill
