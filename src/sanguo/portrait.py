"""Character portraits drawn with half-block characters: each terminal cell shows two pixels
(▀ in the top pixel's colour on the bottom pixel's background). Works in any truecolour terminal
and in the browser via `textual serve`."""
from __future__ import annotations

import json
from functools import lru_cache
from importlib import resources

from PIL import Image
from rich.style import Style
from rich.text import Text

from .cards import CardDB


@lru_cache(maxsize=1)
def _index() -> dict[str, dict]:
    raw = json.loads(resources.files("sanguo.data.portraits").joinpath("portraits.json").read_text("utf-8"))
    return {k: v for k, v in raw.items() if not k.startswith("_")}


def key_for(db: CardDB, card_id: str) -> str | None:
    """A card-specific portrait wins; otherwise any portrait of the same person (variants share art)."""
    idx = _index()
    if card_id in idx:
        return card_id
    card = db.cards.get(card_id)
    if card and card.person in idx:
        return card.person
    return None


@lru_cache(maxsize=16)
def _image(key: str) -> Image.Image:
    entry = _index()[key]
    with resources.files("sanguo.data.portraits").joinpath(entry["file"]).open("rb") as f:
        return Image.open(f).convert("RGB")


def _crop(key: str, aspect: float, heads: float) -> Image.Image:
    """Crop a box of the given width/height aspect around the face, `heads` head-heights tall
    (≈2 = bust, ≈5 = half body, large = whole picture)."""
    img = _image(key)
    w, h = img.size
    entry = _index()[key]
    fx, fy = entry["face"]
    bh = min(h, heads * entry["head"] * h)
    bw = bh * aspect
    if bw > w:
        bw, bh = w, w / aspect
    left = min(max(0, fx * w - bw / 2), w - bw)
    top = min(max(0, fy * h - 0.35 * bh), h - bh)
    return img.crop((round(left), round(top), round(left + bw), round(top + bh)))


@lru_cache(maxsize=256)
def render(key: str, cols: int, rows: int, heads: float = 3.0) -> Text:
    """The portrait as `rows` lines of `cols` half-block cells, framed `heads` head-heights tall."""
    img = _crop(key, cols / (2 * rows), heads).resize((cols, rows * 2), Image.LANCZOS)
    px = img.load()
    text = Text(no_wrap=True, overflow="crop")
    for y in range(rows):
        for x in range(cols):
            top, bottom = px[x, 2 * y], px[x, 2 * y + 1]
            text.append("▀", Style(color=f"rgb({top[0]},{top[1]},{top[2]})",
                                   bgcolor=f"rgb({bottom[0]},{bottom[1]},{bottom[2]})"))
        if y < rows - 1:
            text.append("\n")
    return text
