import os
from pathlib import Path
from PIL import Image, ImageFilter
import numpy as np
from scipy.ndimage import label, binary_dilation

BOSS_INPUT = Path("F:/workspace/sanguo-cards/pics/inbox/ui_map_icon_boss.png")
GODOT_BOSS = Path("F:/workspace/sanguo-cards/godot/data/art/map/icons/boss.png")
PICS_BOSS = Path("F:/workspace/sanguo-cards/pics/source/map/icons/boss.png")
PREVIEW_OUT = Path("C:/Users/lswht/.gemini/antigravity/brain/bf8bf3b1-0945-4ff8-a79c-7122d8ed5099/scratch/boss_clean.png")

img = Image.open(BOSS_INPUT).convert("RGBA")
arr = np.array(img, dtype=np.float32)
rgb = arr[:, :, :3]
h, w = arr.shape[:2]

# Measure distance from white
white_diff = 255.0 - rgb
diff = np.max(white_diff, axis=2)

is_bg = np.zeros((h, w), dtype=bool)
queue = []

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

fg = ~is_bg

# Clean up small border artifacts if any
labeled, num_features = label(fg)
if num_features > 1:
    sizes = [np.sum(labeled == i) for i in range(1, num_features + 1)]
    max_size = max(sizes)
    for i, sz in enumerate(sizes, 1):
        if sz < 400:
            coords = np.where(labeled == i)
            min_y, max_y = np.min(coords[0]), np.max(coords[0])
            min_x, max_x = np.min(coords[1]), np.max(coords[1])
            if min_y < 12 or max_y > h - 13 or min_x < 12 or max_x > w - 13:
                is_bg[labeled == i] = True
                fg[labeled == i] = False

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
    side = int(max(cw, ch) * 1.14)
    square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    square.paste(cropped, ((side - cw) // 2, (side - ch) // 2), cropped)
    
    # Soft dark drop shadow
    shadow = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    s_mask = square.split()[3]
    black = Image.new("RGBA", (side, side), (0, 0, 0, 180))
    shadow.paste(black, (0, int(side * 0.035)), s_mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=int(side * 0.025)))
    
    final = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    final.alpha_composite(shadow)
    final.alpha_composite(square)
    final_icon = final.resize((256, 256), Image.LANCZOS)
    
    final_icon.save(GODOT_BOSS)
    final_icon.save(PICS_BOSS)
    final_icon.save(PREVIEW_OUT)
    print(f"Saved boss icon to {GODOT_BOSS} and {PICS_BOSS}")
