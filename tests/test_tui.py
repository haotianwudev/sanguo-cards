"""Headless smoke tests for the Textual UI: drive real screens with the pilot and check game state."""
import asyncio

from textual.widgets import Button, Input

from sanguo import collection as col
from sanguo.cards import load_db
from sanguo.tui import BattleScreen, GachaScreen, MenuScreen, PartyScreen, QuestScreen, SanguoApp

SIZE = (150, 44)


def run(coro):
    asyncio.run(coro)


def existing_save(tmp_path):
    path = tmp_path / "s.json"
    col.Save.new(load_db()).dump(path)
    return path


def button(app, name):
    return next(b for b in app.screen.query(Button) if b.name == name)


def test_new_game_walks_the_prologue_map(tmp_path):
    async def go():
        app = SanguoApp(tmp_path / "s.json", new=True, seed=1)
        async with app.run_test(size=SIZE) as pilot:
            await pilot.pause()
            app.screen.query_one(Input).value = "阿明"
            await pilot.press("enter")
            await pilot.pause()
            assert isinstance(app.screen, QuestScreen)
            assert app.save.square == "wake"
            await pilot.press("enter")  # read the intro
            await pilot.press("enter")  # step to the only next square
            await pilot.pause()
            assert app.save.square == "pick"
            await pilot.press("1")  # 孙策
            await pilot.pause()
            assert app.save.choices["pick"] == "sc_talk" and "sunce" in app.save.owned
            await pilot.press("enter", "enter", "enter")  # to the square, read, move on to the battle
            await pilot.pause()
            assert app.save.square == "sc_fight"
            await pilot.press("enter")  # 出战
            await pilot.pause()
            assert isinstance(app.screen, BattleScreen)
            app.screen.b.enemy.hp = 1
            app.screen.b.party_hp -= 500  # this damage must follow us to the next battle
            await pilot.press("1", "1")
            await pilot.pause()
            await pilot.press("enter")  # result modal
            await pilot.pause()
            assert isinstance(app.screen, QuestScreen)
            assert app.save.resolved and app.save.damage >= 500
            await pilot.press("enter", "enter")  # to the loot square and take it
            await pilot.pause()
            assert app.save.soldiers.get("cav_n") == 1
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
            for _ in range(3):  # recruit three times: each shows 3 generals, keep one
                await pilot.press("enter")
                await pilot.pause()
                await pilot.press("2")
                await pilot.pause()
            assert len(app.save.owned) == 3
            await pilot.press("escape", "4")
            await pilot.pause()
            assert isinstance(app.screen, PartyScreen)
            await pilot.press("a")
            await pilot.pause()
            assert len(app.save.party) == 3
    run(go())


def test_battle_chest_lets_you_pick_one_soldier(tmp_path):
    async def go():
        app = SanguoApp(existing_save(tmp_path), seed=5)
        async with app.run_test(size=SIZE) as pilot:
            await pilot.pause()
            await pilot.press("5")
            await pilot.pause()
            next(b for b in app.screen.query(Button) if b.id == "sc-shanzei").press()
            await pilot.pause()
            screen = app.screen
            screen.boss = True  # guarantee a chest
            screen.b.enemy.hp = 1
            await pilot.press("1", "1")
            await pilot.pause()
            chest = app.screen.chest
            assert len(chest) == app.db.gacha["chest_cards_boss"]
            await pilot.press("3")  # keep the third card
            await pilot.pause()
            assert app.save.soldiers == {chest[2].id: 1}
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
