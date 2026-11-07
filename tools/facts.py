"""What the game itself says about every chapter on every route — the doc generators read this instead of re-deriving
game rules (which squares a route walks, its title, pools, ？ events, ？小故事, which cards are chapter-only / public).

    from facts import load_facts
    facts = load_facts()   # {"routes", "chapters": [...], "card_chapters", "public_soldiers", "errors"}

It runs godot/tools/export_facts.gd headless (≈2 s) and caches the result in build/facts.json until a data file or a
script changes. The Godot binary: $SANGUO_GODOT, else the path below (the one every Runbook / skill command uses).
"""
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GODOT_DIR = ROOT / "godot"
CACHE = ROOT / "build" / "facts.json"
DEFAULT_GODOT = r"F:\workspace\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
ROUTE_CN = {"south": "南", "north": "北", "": "南北"}


def _inputs():
    yield from (GODOT_DIR / "data").glob("*.json")
    yield from (GODOT_DIR / "scripts").rglob("*.gd")
    yield GODOT_DIR / "tools" / "export_facts.gd"


def _stale() -> bool:
    if not CACHE.exists():
        return True
    built = CACHE.stat().st_mtime
    return any(p.stat().st_mtime > built for p in _inputs())


def load_facts() -> dict:
    if _stale():
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        godot = os.environ.get("SANGUO_GODOT", DEFAULT_GODOT)
        cmd = [godot, "--headless", "--path", str(GODOT_DIR), "--script", "res://tools/export_facts.gd", "--", "--out=" + str(CACHE)]
        tmp = CACHE.with_suffix(".old")
        if CACHE.exists():
            CACHE.replace(tmp)  # a failed export must not leave the old facts looking fresh
        r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=300)
        if r.returncode != 0 or not CACHE.exists():
            raise SystemExit("export_facts.gd failed (%s):\n%s" % (godot, (r.stdout + r.stderr)[-3000:]))
        tmp.unlink(missing_ok=True)
    facts = json.loads(CACHE.read_text("utf-8"))
    if facts.get("errors"):
        raise SystemExit("game data has %d schema error(s), fix them first:\n  %s" % (len(facts["errors"]), "\n  ".join(facts["errors"][:20])))
    return facts
