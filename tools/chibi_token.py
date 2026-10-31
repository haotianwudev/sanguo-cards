"""Turn a generated chibi (Q版) hero on a white background into the map token and a lord-card portrait.

    python tools/chibi_token.py <chibi.png> <south|north>
      -> godot/data/art/map/token_lord_<route>.png + pics/source/map/token_lord_<route>.png   (384 px, transparent, feet on the bottom edge)
      -> pics/inbox/lord_<route>_q.jpg                                                       (3:4 card portrait on a warm / cool backdrop)
    then: python tools/art_ingest.py add pics/inbox/lord_<route>_q.jpg lord_<route>_q --kind portrait --face 0.48 0.26 --head 0.24

The chibi is generated with art_gen.py (nano-banana-2, --size 1024x1024) from the route's lord portrait plus the
current token as refs: 三头身, walking towards the right, thick dark outline, pure white background, no base / shadow / text.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
from scipy.ndimage import binary_dilation, label

ROOT = Path(__file__).resolve().parents[1]
BACKDROP = {"south": ((236, 214, 170), (178, 120, 70)), "north": ((214, 228, 240), (120, 140, 170))}


def cut(path: Path) -> Image.Image:
    """white background (connected to the border) -> transparent, soft anti-aliased edge, cropped to the figure"""
    arr = np.array(Image.open(path).convert("RGBA"), dtype=np.float32)
    diff = np.max(255.0 - arr[:, :, :3], axis=2)
    lab, _ = label(diff < 28)
    border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    bg = np.isin(lab, list(border))
    alpha = np.where(bg, 0.0, 255.0)
    edge = binary_dilation(bg, iterations=2) & ~bg
    alpha[edge] = np.clip((diff[edge] - 4.0) / 30.0, 0.0, 1.0) * 255.0
    arr[:, :, 3] = alpha
    out = Image.fromarray(arr.astype(np.uint8), "RGBA")
    return out.crop(out.getbbox())


def token(fig: Image.Image, side=384) -> Image.Image:
    k = side * 0.96 / max(fig.size)
    f = fig.resize((int(fig.width * k), int(fig.height * k)), Image.LANCZOS)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.alpha_composite(f, ((side - f.width) // 2, side - f.height))
    return canvas


def card(fig: Image.Image, top, bottom, W=1200, H=1600) -> Image.Image:
    y = np.linspace(0, 1, H)[:, None, None]
    x = np.linspace(-1, 1, W)[None, :, None]
    glow = np.clip(1.0 - np.sqrt(x ** 2 + ((y - 0.42) * 1.6) ** 2), 0, 1) ** 1.5 * 70
    base = np.clip(np.array(top) * (1 - y) + np.array(bottom) * y + glow, 0, 255).astype(np.uint8)
    bg = Image.fromarray(np.broadcast_to(base, (H, W, 3)).copy(), "RGB").convert("RGBA")
    k = min(H * 0.86 / fig.height, W * 0.94 / fig.width)
    f = fig.resize((int(fig.width * k), int(fig.height * k)), Image.LANCZOS)
    sh = Image.new("RGBA", f.size, (0, 0, 0, 0))
    sh.paste((0, 0, 0, 110), (0, 0), f.split()[3])
    sh = sh.filter(ImageFilter.GaussianBlur(14))
    px, py = (W - f.width) // 2, H - f.height - int(H * 0.04)
    bg.alpha_composite(sh, (px + 14, py + 16))
    bg.alpha_composite(f, (px, py))
    return bg.convert("RGB")


def main():
    src, route = Path(sys.argv[1]), sys.argv[2]
    fig = cut(src)
    t = token(fig)
    for d in (ROOT / "godot/data/art/map", ROOT / "pics/source/map"):
        t.save(d / f"token_lord_{route}.png")
    (ROOT / "pics/inbox").mkdir(exist_ok=True)
    out = ROOT / "pics/inbox" / f"lord_{route}_q.jpg"
    card(fig, *BACKDROP[route]).save(out, quality=92)
    print(f"token_lord_{route}.png + {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
