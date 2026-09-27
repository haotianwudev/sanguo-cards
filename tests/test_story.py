import pytest

from sanguo import collection as col
from sanguo import story
from sanguo.cards import load_db

BRANCHES = {0: "path_sunce", 1: "path_zhouyu", 2: "path_huanggai"}


@pytest.fixture
def db():
    return load_db()


@pytest.fixture
def st(db):
    return story.load_story(db)


def play_through(db, st, save, pick):
    """Walk the whole story, taking option `pick` at every choice and treating battles as won."""
    seen = []
    while (cur := story.current(st, save)) is not None:
        node, step = cur
        seen.append(node.id)
        k = story.kind(step)
        if k == "battle":
            col.record_win(save, step["battle"])
        story.advance(db, st, save, pick if k == "choose" else None)
    return seen


def test_story_data_is_valid(db, st):
    assert st.start in st.nodes


@pytest.mark.parametrize("pick", [0, 1, 2])
def test_each_choice_takes_its_own_path_then_converges(db, st, pick):
    save = col.Save.new(db)
    seen = play_through(db, st, save, pick)
    assert BRANCHES[pick] in seen
    assert not any(b in seen for i, b in BRANCHES.items() if i != pick)
    assert seen[-1] == "wuguotai"
    assert save.story_path == [BRANCHES[pick]]
    assert "wuguotai" in save.owned
    assert story.finished(st, save)


def test_branches_give_different_cards(db, st):
    owned = []
    for pick in BRANCHES:
        save = col.Save.new(db)
        play_through(db, st, save, pick)
        owned.append(set(save.owned))
    assert owned[0] != owned[1] != owned[2] != owned[0]


def test_losing_a_battle_does_not_advance(db, st):
    save = col.Save.new(db)
    while story.kind(story.current(st, save)[1]) != "battle":
        k = story.kind(story.current(st, save)[1])
        story.advance(db, st, save, 0 if k == "choose" else None)
    before = (save.story_node, save.story_step)
    # the CLI only calls advance() after a win; without it the position is unchanged
    assert (save.story_node, save.story_step) == before
    assert story.kind(story.current(st, save)[1]) == "battle"
