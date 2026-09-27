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


def test_pull_is_free_and_never_duplicates(db, save):
    in_pool = [c for c in db.cards.values() if c.in_pool]
    got = col.pull(db, save, random.Random(1), len(in_pool) + 5)
    assert len(got) == len(in_pool)  # stops once the pool is empty
    assert len(set(save.owned)) == len(save.owned) == len(in_pool)
    assert not any(db.cards[c].in_pool is False for c in save.owned)  # story-only cards never drop


def test_rates_roughly_follow_config(db):
    counts = {"N": 0, "R": 0, "SR": 0, "SSR": 0}
    for seed in range(2000):
        s = col.Save()
        (card,) = col.pull(db, s, random.Random(seed), 1)
        counts[card.rarity] += 1
    rates = db.gacha["rates"]
    for r, c in counts.items():
        assert c / 2000 == pytest.approx(rates[r] / 100, abs=0.03)


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
    fighters = col.party_fighters(db, col.Save(owned=save.owned, party=ids))
    assert fighters[0].troop == "lord" and len(fighters) == 4


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
    col.grant_card(db, save, "cav_n")  # cavalry again: owned, but not auto-slotted
    assert save.party == ["sunce"] and "cav_n" in save.owned


def test_variants_of_one_general_cannot_share_a_party(db, save):
    save.owned = ["sunce", "sunce_zhong", "zhouyu", "zhouyu_chibi"]
    assert "不同版本" in col.validate_party(db, save, ["sunce", "sunce_zhong"])
    assert "不同版本" in col.validate_party(db, save, ["zhouyu", "zhouyu_chibi"])
    assert col.validate_party(db, save, ["sunce_zhong", "zhouyu"]) is None
    ids = col.auto_party(db, save)
    assert len({db.cards[c].person for c in ids}) == len(ids)


def test_gacha_has_variants_of_story_generals_but_not_the_story_versions(db):
    pool_ids = {c.id for r in ("N", "R", "SR", "SSR") for c in db.pool(r)}
    assert {"sunce_zhong", "zhouyu_chibi", "lvmeng"} <= pool_ids
    assert not ({"sunce", "zhouyu", "huanggai", "wuguotai"} & pool_ids)
