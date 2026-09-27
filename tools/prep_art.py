"""Prepare a generated illustration for a card: cut off a title band at the top and pad the canvas with
the paper colour, so the figure can be framed smaller inside a portrait card window.

Normally you don't run this by hand: give the art.json entry a "prep" block and `sanguo-art` does it.
    "danyang": {"src": "processed/danyang_card.jpg",
                "prep": {"from": "source/soldiers/danyang.jpg", "cut_top": 0.15, "figure": 0.70}, ...}

By hand:
    python tools/prep_art.py <in.jpg> <out.jpg> [--cut-top 0.15] [--figure 0.70]

--cut-top  fraction of the image height to remove from the top (the title text)
--figure   how much of the card height the figure should fill (smaller = smaller figure)

The original file is never modified. Padding uses the paper colour of the image's own top / bottom edge,
feathered into it so there is no seam.
"""
import argparse
from pathlib import Path

import numpy as np
from PIL import Image


def prep(src: Path, dst: Path, cut_top: float = 0.15, figure: float = 0.70) -> tuple[int, int]:
    im = Image.open(src).convert("RGB")
    w, h = im.size
    body = np.asarray(im.crop((0, int(h * cut_top), w, h))).astype(float)
    bh = body.shape[0]
    # the figure spans roughly the remaining height; pad so it fills `figure` of the new canvas
    target_h = int(bh / figure)
    top_pad = (target_h - bh) // 2
    # pad with the paper colour of each edge (per column, so a vignette carries on), then feather the seam
    top_row = body[:12].mean(axis=0)
    bot_row = body[-12:].mean(axis=0)
    canvas = np.empty((target_h, w, 3))
    canvas[:top_pad] = top_row
    canvas[top_pad + bh:] = bot_row
    canvas[top_pad:top_pad + bh] = body
    feather = 60
    for i in range(feather):
        t = i / feather
        canvas[top_pad + i] = canvas[top_pad + i] * t + top_row * (1 - t)
        canvas[top_pad + bh - 1 - i] = canvas[top_pad + bh - 1 - i] * t + bot_row * (1 - t)
    dst.parent.mkdir(parents=True, exist_ok=True)
    out = Image.fromarray(canvas.clip(0, 255).astype(np.uint8))
    out.save(dst, quality=92)
    return out.size


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--cut-top", type=float, default=0.15)
    ap.add_argument("--figure", type=float, default=0.70)
    args = ap.parse_args()
    size = prep(Path(args.src), Path(args.dst), args.cut_top, args.figure)
    print(f"{args.dst}: {size}")


if __name__ == "__main__":
    main()
