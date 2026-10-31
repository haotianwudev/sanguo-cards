import os
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
from scipy.ndimage import label, binary_dilation

SHEET_PATH = Path("F:/workspace/sanguo-cards/pics/inbox/ui_map_icons_sheet.png")
OUT_DIR = Path(__file__).resolve().parents[1] / "pics" / "inbox" / "_icons_preview"  # previews only, not shipped
GODOT_DIR = Path("F:/workspace/sanguo-cards/godot/data/art/map/icons")
PICS_DIR = Path("F:/workspace/sanguo-cards/pics/source/map/icons")
OUT_DIR.mkdir(parents=True, exist_ok=True)
GODOT_DIR.mkdir(parents=True, exist_ok=True)
PICS_DIR.mkdir(parents=True, exist_ok=True)

MAPPING = [
    # (row, col, key)
    (0, 0, "battle"),
    (0, 1, "elite"),
    (0, 2, "boss"),
    (0, 3, "treasure"),
    (1, 0, "recover"),
    (1, 1, "event"),
    (1, 2, "choose"),
    (1, 3, "recruit"),
    (2, 0, "mystery"),
    (2, 1, "hazard"),
    (2, 2, "glory"),
    (2, 3, "temple"),
    (3, 0, "physician"),
    (3, 1, "curse"),
    (3, 2, "red_turban"),
    (3, 3, "token_lord"),
]

sheet = Image.open(SHEET_PATH).convert("RGBA")
W, H = sheet.size
cell_w = W // 4
cell_h = H // 4

def extract_icon(cell_img: Image.Image, key: str) -> Image.Image:
    arr = np.array(cell_img, dtype=np.float32)
    rgb = arr[:, :, :3]
    h, w = arr.shape[:2]
    
    # 1. Background detection: distance from white (255, 255, 255)
    white_diff = 255.0 - rgb
    diff = np.max(white_diff, axis=2)
    
    # Flood-fill from borders
    is_bg = np.zeros((h, w), dtype=bool)
    queue = []
    
    # We allow border pixels with diff < 38 to be background seed
    for x in range(w):
        if diff[0, x] < 38:
            is_bg[0, x] = True
            queue.append((0, x))
        if diff[h - 1, x] < 38:
            is_bg[h - 1, x] = True
            queue.append((h - 1, x))
    for y in range(h):
        if diff[y, 0] < 38:
            is_bg[y, 0] = True
            queue.append((y, 0))
        if diff[y, w - 1] < 38:
            is_bg[y, w - 1] = True
            queue.append((y, w - 1))
            
    head = 0
    while head < len(queue):
        cy, cx = queue[head]
        head += 1
        for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
            if 0 <= ny < h and 0 <= nx < w and not is_bg[ny, nx]:
                if diff[ny, nx] < 30:
                    is_bg[ny, nx] = True
                    queue.append((ny, nx))
                    
    # Foreground mask
    fg = ~is_bg
    
    # Clean up small bleeds / stray marks from neighbor cells
    # Connected component analysis on fg
    labeled, num_features = label(fg)
    if num_features > 1:
        # Find sizes of components
        sizes = [np.sum(labeled == i) for i in range(1, num_features + 1)]
        max_size = max(sizes)
        # Any component that is tiny (< 1% of main or < 400 pixels) AND near the cell boundary (< 20px from edge) is a bleed
        for i, sz in enumerate(sizes, 1):
            if sz < 600:
                coords = np.where(labeled == i)
                min_y, max_y = np.min(coords[0]), np.max(coords[0])
                min_x, max_x = np.min(coords[1]), np.max(coords[1])
                # If touching or very near the border
                if min_y < 12 or max_y > h - 13 or min_x < 12 or max_x > w - 13:
                    is_bg[labeled == i] = True
                    fg[labeled == i] = False
    
    # Calculate anti-aliasing alpha
    alpha = np.ones((h, w), dtype=np.float32) * 255.0
    alpha[is_bg] = 0.0
    
    edge = binary_dilation(is_bg, iterations=2) & fg
    edge_alpha = np.clip((diff[edge] - 6.0) / 32.0, 0.0, 1.0) * 255.0
    alpha[edge] = edge_alpha
    
    arr[:, :, 3] = alpha
    result = Image.fromarray(np.uint8(arr), mode="RGBA")
    
    bbox = result.getbbox()
    if bbox:
        cropped = result.crop(bbox)
        cw, ch = cropped.size
        # Add 12% padding around icon
        side = int(max(cw, ch) * 1.15)
        square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        square.paste(cropped, ((side - cw) // 2, (side - ch) // 2), cropped)
        
        # Soft dark drop shadow under icon
        shadow = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        s_mask = square.split()[3]
        black = Image.new("RGBA", (side, side), (0, 0, 0, 175))
        shadow.paste(black, (0, int(side * 0.035)), s_mask)
        shadow = shadow.filter(ImageFilter.GaussianBlur(radius=int(side * 0.025)))
        
        final = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        final.alpha_composite(shadow)
        final.alpha_composite(square)
        return final.resize((256, 256), Image.LANCZOS)
    return result.resize((256, 256), Image.LANCZOS)

for r, c, key in MAPPING:
    box = (c * cell_w, r * cell_h, (c + 1) * cell_w, (r + 1) * cell_h)
    cell = sheet.crop(box)
    icon = extract_icon(cell, key)
    
    # Save preview
    icon.save(OUT_DIR / f"{key}.png")
    
    # Ingest directly into game assets!
    if key == "token_lord":
        icon.save(Path("F:/workspace/sanguo-cards/godot/data/art/map/token_lord.png"))
        icon.save(Path("F:/workspace/sanguo-cards/pics/source/map/token_lord.png"))
        print("Updated token_lord.png")
    else:
        icon.save(GODOT_DIR / f"{key}.png")
        icon.save(PICS_DIR / f"{key}.png")
        print(f"Updated {key}.png -> {GODOT_DIR / f'{key}.png'}")

# Also update preview grid
grid = Image.new("RGBA", (256 * 4 + 40, 256 * 4 + 40), (45, 40, 48, 255))
for r, c, key in MAPPING:
    im = Image.open(OUT_DIR / f"{key}.png")
    grid.paste(im, (20 + c * 256, 20 + r * 256), im)
grid.save(OUT_DIR / "preview_grid_clean.png")
print("Saved preview_grid_clean.png successfully!")
