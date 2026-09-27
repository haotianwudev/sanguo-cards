from sanguo import portrait
from sanguo.cards import load_db
from sanguo.quest import load_quests


def test_render_is_exactly_the_requested_size():
    text = portrait.render("sunce", 20, 8, 2.0)
    lines = text.plain.split("\n")
    assert len(lines) == 8 and all(len(line) == 20 for line in lines)


def test_variants_share_their_persons_portrait():
    db = load_db()
    assert portrait.key_for(db, "sunce_zhong") == "sunce"
    assert portrait.key_for(db, "zhouyu_chibi") == "zhouyu"
    assert portrait.key_for(db, "huangyueying") is None


def test_story_portraits_all_exist():
    db = load_db()
    keys = {k for q in load_quests(db) for s in q.squares.values() for k in s.portraits}
    assert keys and keys <= set(portrait._index())


def test_art_config_builds_every_entry(tmp_path):
    """pics/art.json is the single source: every entry ends up in the game's portrait index."""
    import json
    from pathlib import Path

    from sanguo import art

    cfg = json.loads((art.PICS / "art.json").read_text("utf-8"))["portraits"]
    index = portrait._index()
    assert set(k for k in cfg if not k.startswith("_")) == set(index)
    for k, e in cfg.items():
        if not k.startswith("_"):
            assert index[k]["face"] == e["face"] and index[k]["head"] == e["head"]
            assert (Path(art.OUT) / index[k]["file"]).exists()


def test_enemies_can_have_portraits():
    db = load_db()
    assert portrait.key_for_enemy(db.enemies["lvbu"]) == "lvbu"
    assert portrait.key_for_enemy(db.enemies["shanzeituan"]) is None
