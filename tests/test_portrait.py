from sanguo import portrait
from sanguo.cards import load_db
from sanguo.story import load_story


def test_render_is_exactly_the_requested_size():
    text = portrait.render("sunce", 20, 8, 2.0)
    lines = text.plain.split("\n")
    assert len(lines) == 8 and all(len(line) == 20 for line in lines)


def test_variants_share_their_persons_portrait():
    db = load_db()
    assert portrait.key_for(db, "sunce_zhong") == "sunce"
    assert portrait.key_for(db, "zhouyu_chibi") == "zhouyu"
    assert portrait.key_for(db, "guanyu") is None


def test_story_portraits_all_exist():
    db = load_db()
    st = load_story(db)
    keys = {k for n in st.nodes.values() for step in n.steps for k in step.get("portraits", [])}
    assert keys and keys <= set(portrait._index())
