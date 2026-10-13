"""Read godot/data/cards.json together with the files split off it (the same merge GameData does in the game)."""
import json
from pathlib import Path

DATA = Path(__file__).resolve().parents[1] / "godot" / "data"
PARTS = ["cards.json", "enemies.json", "scenarios.json", "skills.json", "relics.json", "battle.json"]


def load_cards(data: Path = DATA) -> dict:
    out: dict = {}
    for f in PARTS:
        part = json.loads((Path(data) / f).read_text("utf-8"))
        dup = set(part) & set(out)
        assert not dup, "%s repeats %s" % (f, dup)
        out.update(part)
    return out
