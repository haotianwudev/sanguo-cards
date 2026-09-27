"""Headless smoke tests for the Textual UI: drive real screens with the pilot and check game state."""
import asyncio

from textual.widgets import Button, Input

from sanguo import collection as col
from sanguo.cards import load_db
from sanguo.tui import BattleScreen, GachaScreen, MenuScreen, PartyScreen, SanguoApp, StoryScreen

SIZE = (150, 44)


def run(coro):
    asyncio.run(coro)


def existing_save(tmp_path):
    path = tmp_path / "s.json"
    col.Save.new(load_db()).dump(path)
    return path


def button(app, name):
    return next(b for b in app.screen.query(Button) if b.name == name)


def test_new_game_story_battle_and_prologue(tmp_path):
    async def go():
        app = SanguoApp(tmp_path / "s.json", new=True, seed=1)
        async with app.run_test(size=SIZE) as pilot:
            await pilot.pause()
            app.screen.query_one(Input).value = "阿明"
            await pilot.press("enter")
            await pilot.pause()
            assert isinstance(app.screen, StoryScreen)
            await pilot.press("enter")  # intro text
            await pilot.pause()
            button(app, "choose-0").press()  # 孙策
            await pilot.pause()
            assert app.save.story_path == ["path_sunce"]
            await pilot.press("enter")  # path text
            await pilot.pause()
            button(app, "fight").press()
            await pilot.pause()
            assert isinstance(app.screen, BattleScreen)
            app.screen.b.enemy.hp = 1
            await pilot.press("1", "1")  # leader 1 (lord) → skill 1 (突击)
            await pilot.pause()
            await pilot.press("enter")  # result modal
            await pilot.pause()
            assert isinstance(app.screen, StoryScreen)
            for _ in range(5):
                await pilot.press("enter")
                await pilot.pause()
            assert "wuguotai" in app.save.owned and "cav_n" in app.save.owned
            assert (tmp_path / "s.json").exists()
    run(go())


def test_gacha_and_auto_party(tmp_path):
    async def go():
        app = SanguoApp(existing_save(tmp_path), seed=2)
        async with app.run_test(size=SIZE) as pilot:
            await pilot.pause()
            assert isinstance(app.screen, MenuScreen)
            await pilot.press("2")
            await pilot.pause()
            assert isinstance(app.screen, GachaScreen)
            await pilot.press("0")  # ten pulls
            await pilot.pause()
            assert len(app.save.owned) == 10
            await pilot.press("escape", "4")
            await pilot.pause()
            assert isinstance(app.screen, PartyScreen)
            await pilot.press("a")
            await pilot.pause()
            assert len(app.save.party) == 3
    run(go())


def test_battle_keyboard_flow_and_loss(tmp_path):
    async def go():
        app = SanguoApp(existing_save(tmp_path), seed=3)
        async with app.run_test(size=SIZE) as pilot:
            await pilot.pause()
            await pilot.press("5")
            await pilot.pause()
            button_ = next(b for b in app.screen.query(Button) if b.id == "sc-hulao")
            button_.press()
            await pilot.pause()
            screen = app.screen
            assert isinstance(screen, BattleScreen)
            await pilot.press("1")  # select lord
            assert screen.selected == 0
            await pilot.press("escape")
            assert screen.selected is None
            screen.b.party_hp = 1  # one shared HP bar: any hit ends it
            screen.b.enemy.stunned = False
            await pilot.press("e")
            await pilot.pause()
            assert screen.b.result == "lose"
            await pilot.press("enter")
            await pilot.pause()
            assert type(app.screen).__name__ == "ScenarioScreen"  # back to the battle list
    run(go())
