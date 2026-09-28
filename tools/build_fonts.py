"""Bundle the game's Chinese fonts (phones and the web have no system CJK font).

Downloads the full fonts once into build/fonts/ (gitignored), then writes subsets into godot/data/fonts/:
  - body.ttf  Noto Sans SC (思源黑体), weight 500 -- all UI and story text
  - name.ttf  LXGW WenKai Medium (霞鹜文楷) -- card names
Both are SIL OFL 1.1. The subset keeps ASCII, CJK punctuation, the 3755 common GB2312 level-1 characters
(for names the player types) and every character in godot/data and godot/scripts.
Re-run after adding story text with rare characters:  python tools/build_fonts.py
"""
import re
import urllib.request
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = Path(__file__).resolve().parents[1]
CACHE = ROOT / "build" / "fonts"
OUT = ROOT / "godot" / "data" / "fonts"
FONTS = {
    "body.ttf": ("https://github.com/google/fonts/raw/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf", "NotoSansSC.ttf", 500),
    "name.ttf": ("https://github.com/lxgw/LxgwWenKai/releases/download/v1.520/LXGWWenKai-Medium.ttf", "LXGWWenKai-Medium.ttf", None),
}


def charset() -> str:
    chars = {chr(c) for c in range(0x20, 0x7F)}
    chars |= {chr(c) for c in range(0x3000, 0x3040)} | {chr(c) for c in range(0xFF00, 0xFFF0)}
    chars |= set("·—…‘’“”■□▲△▼▽◆◇○●★☆♥♡⚔×÷→←↑↓")
    for hi in range(0xB0, 0xD8):  # GB2312 level 1
        for lo in range(0xA1, 0xFF):
            try:
                chars.add(bytes([hi, lo]).decode("gb2312"))
            except UnicodeDecodeError:
                pass
    for folder in ("godot/data", "godot/scripts"):
        for p in (ROOT / folder).rglob("*"):
            if p.suffix in (".json", ".gd"):
                chars |= set(p.read_text(encoding="utf-8"))
    return "".join(c for c in chars if c.isprintable() or c == " ")


def main() -> None:
    CACHE.mkdir(parents=True, exist_ok=True)
    OUT.mkdir(parents=True, exist_ok=True)
    text = charset()
    for out_name, (url, cache_name, weight) in FONTS.items():
        src = CACHE / cache_name
        if not src.exists():
            print("downloading", url)
            urllib.request.urlretrieve(url, src)
        font = TTFont(src)
        if weight is not None and "fvar" in font:
            font = instancer.instantiateVariableFont(font, {"wght": weight})
        opts = subset.Options()
        opts.layout_features = ["*"]
        opts.name_IDs = ["*"]
        sub = subset.Subsetter(opts)
        sub.populate(text=text)
        sub.subset(font)
        font.save(OUT / out_name)
        print(f"{out_name}: {len(text)} chars, {(OUT / out_name).stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
