"""The one formatter for godot/data/story.json — use it instead of splicing lines or json.dump(indent=2).

    python tools/fmt_story.py            # rewrite story.json in its house style
    python tools/fmt_story.py --check    # exit 1 if it isn't (CI / tools/check.sh)

    from fmt_story import dump_story     # in a patch script: data = json.loads(...); ...; write dump_story(data)

House style: the top object, the quests list, each quest and its "squares" / the "events" map get one key (or item) per
line; everything inside one square, one event or any other value stays on a single line — so a diff shows exactly
which square or event changed.
"""
import json
import sys
from pathlib import Path

PATH = Path(__file__).resolve().parents[1] / "godot" / "data" / "story.json"
OPEN = {"": True, "quests": True, "quest": True, "squares": False, "events": False}  # which levels spread out


def _flat(v) -> str:
    return json.dumps(v, ensure_ascii=False, separators=(", ", ": "))


def _block(d, ind: int, item_open) -> str:
    """a dict or list one entry per line; item_open(key, value) says whether an entry spreads out itself"""
    pad = "  " * (ind + 1)
    if isinstance(d, dict):
        rows = ["%s%s: %s" % (pad, _flat(k), item_open(k, v, ind + 1)) for k, v in d.items()]
        return "{\n" + ",\n".join(rows) + "\n" + "  " * ind + "}"
    rows = [pad + item_open(None, v, ind + 1) for v in d]
    return "[\n" + ",\n".join(rows) + "\n" + "  " * ind + "]"


def dump_story(data: dict) -> str:
    def quest_field(k, v, ind):
        return _block(v, ind, lambda _k, x, _i: _flat(x)) if k == "squares" and v else _flat(v)

    def top_field(k, v, ind):
        if k == "quests":
            return _block(v, ind, lambda _k, q, i: _block(q, i, quest_field))
        if k == "events" and v:
            return _block(v, ind, lambda _k, x, _i: _flat(x))
        return _flat(v)

    return _block(data, 0, top_field) + "\n"


def main() -> int:
    raw = PATH.read_text("utf-8")
    out = dump_story(json.loads(raw))
    if "--check" in sys.argv:
        if out != raw:
            print("godot/data/story.json is not in house style — run: python tools/fmt_story.py")
            return 1
        print("story.json is formatted")
        return 0
    if out != raw:
        PATH.write_text(out, "utf-8", newline="\n")
    print("story.json %s" % ("rewritten" if out != raw else "already formatted"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
