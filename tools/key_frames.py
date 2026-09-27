"""Turn card-frame JPGs with a baked-in "transparency" checkerboard into real transparent PNGs,
and measure each frame's inner window for the card layout.

    python tools/key_frames.py "pics/card frames" godot/data/art/frames

Writes frame_<name>.png (transparent inside and outside) and frames.json with the window rectangle
(where the portrait shows) as fractions of the card size.

How: checkerboard pixels are light, near-neutral (a frame's glow may tint them) and flat. We clear
(1) checker regions connected to the image border or to the centre window, then (2) scan every row and
column inward from the image edges and outward from the window edges, clearing checker pixels until we
hit frame material. The scans only ever touch the thin strips hugging the frame, so detailed frame art
(e.g. a silver frame full of white/grey highlights) is never examined.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

OUT_H = 700  # output height (5:7 → 500×700)
GAP = 6  # this many non-checker pixels in a row = frame material, stop scanning
MAX_TONE_RUN = 90  # checker squares are ~39 px: one tone running longer than this is flat frame metal


def candidates(a: np.ndarray) -> np.ndarray:
    g = a.astype(float).mean(axis=2)
    mean = ndimage.uniform_filter(g, 3)
    var = ndimage.uniform_filter(g * g, 3) - mean * mean
    mx = a.max(axis=2).astype(int)
    mn = a.min(axis=2).astype(int)
    flat = (var < 80) & (mn >= 90) & (mx - mn <= 70)
    strict = (mn >= 160) & (mx - mn <= 14)
    return ndimage.binary_closing(flat, iterations=3) | strict


def scan(line: np.ndarray, tone: np.ndarray) -> int:
    """How many leading pixels of a 1-D line are checkerboard (tolerating short seams).
    Checkerboard alternates light/dark every square; a single tone running too long is a flat
    piece of frame (brushed metal), so back up to where that run began."""
    last, gap, run_start, run_tone = 0, 0, 0, None
    for i, v in enumerate(line):
        if v:
            if tone[i] != run_tone:
                run_start, run_tone = i, tone[i]
            elif i - run_start > MAX_TONE_RUN:
                return run_start
            last, gap = i + 1, 0
        else:
            gap += 1
            if gap >= GAP:
                break
    return last


def key(path: Path) -> tuple[Image.Image, dict]:
    a = np.asarray(Image.open(path).convert("RGB"))
    h, w, _ = a.shape
    cand = candidates(a)
    tone = a.astype(int).mean(axis=2) >= 205  # light vs dark checker square (works for tinted squares too)
    labels, _ = ndimage.label(cand)

    border = set(np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))) - {0}
    clear = np.isin(labels, list(border))

    cy, cx = h // 2, w // 2
    patch = labels[cy - 60:cy + 60, cx - 60:cx + 60]
    vals, counts = np.unique(patch[patch > 0], return_counts=True)
    inside = ndimage.binary_fill_holes(labels == vals[counts.argmax()])
    ys, xs = np.nonzero(inside)
    y0, y1 = (int(v) for v in np.percentile(ys, [0.5, 99.5]))
    x0, x1 = (int(v) for v in np.percentile(xs, [0.5, 99.5]))
    clear |= inside
    clear[y0:y1 + 1, x0:x1 + 1] = True

    # (2) edge scans
    for y in range(h):
        row, tr = cand[y], tone[y]
        n = scan(row, tr)
        clear[y, :n] = True
        n = scan(row[::-1], tr[::-1])
        clear[y, w - n:] = True
        if y0 <= y <= y1:
            n = scan(row[x0::-1], tr[x0::-1])
            clear[y, x0 - n + 1:x0 + 1] = True
            n = scan(row[x1:], tr[x1:])
            clear[y, x1:x1 + n] = True
    for x in range(w):
        col, tc = cand[:, x], tone[:, x]
        n = scan(col, tc)
        clear[:n, x] = True
        n = scan(col[::-1], tc[::-1])
        clear[h - n:, x] = True
        if x0 <= x <= x1:
            n = scan(col[y0::-1], tc[y0::-1])
            clear[y0 - n + 1:y0 + 1, x] = True
            n = scan(col[y1:], tc[y1:])
            clear[y1:y1 + n, x] = True

    clear = ndimage.binary_dilation(clear, iterations=1)  # eat the anti-aliased fringe
    rgba = np.dstack([a, np.where(clear, 0, 255).astype(np.uint8)])
    out = Image.fromarray(rgba, "RGBA").resize((round(w * OUT_H / h), OUT_H), Image.LANCZOS)
    return out, {"window": [round(x0 / w, 4), round(y0 / h, 4), round((x1 - x0) / w, 4), round((y1 - y0) / h, 4)]}


def main() -> None:
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    dst.mkdir(parents=True, exist_ok=True)
    index = {}
    for f in sorted(src.iterdir()):
        if f.suffix.lower() not in (".jpg", ".jpeg", ".png"):
            continue
        name = f.stem.replace("card frame", "").strip() or f.stem
        img, meta = key(f)
        img.save(dst / f"frame_{name}.png")
        index[name] = {"file": f"frame_{name}.png", **meta}
        print(name, meta)
    (dst / "frames.json").write_text(json.dumps(index, ensure_ascii=False, indent=1), "utf-8")


if __name__ == "__main__":
    main()
