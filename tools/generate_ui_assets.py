"""Generate UI art assets for sanguo-cards:
- Troop badges (9 badges) -> godot/data/art/badges/ & pics/source/ui/badges/
- Map square icons (15 icons) -> godot/data/art/map/icons/ & pics/source/map/icons/
- Commander token (M5) -> godot/data/art/map/token_lord.png
- Relic icons (36 relics) -> godot/data/art/relics/ & pics/source/relics/
- Card back (1000x1400) -> godot/data/art/frames/card_back.png
"""
import os
import math
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageOps, ImageChops

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "godot" / "data"
ART = DATA / "art"
PICS_SRC = ROOT / "pics" / "source"
FONTS_DIR = Path("C:/Windows/Fonts")

FONT_KAITI = str(FONTS_DIR / "simkai.ttf")
FONT_HEITI = str(FONTS_DIR / "simhei.ttf")
FONT_SONGTI = str(FONTS_DIR / "simsun.ttc")

def hex_to_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)

def hex_to_rgba(h: str, alpha: int = 255) -> tuple[int, int, int, int]:
    r, g, b = hex_to_rgb(h)
    return (r, g, b, alpha)

def lerp_color(c1: tuple, c2: tuple, t: float) -> tuple:
    return tuple(int(a + (b - a) * t) for a, b in zip(c1, c2))

# ==============================================================================
# 1. TROOP BADGES (9 items, 256x256)
# ==============================================================================

BADGE_STYLES = {
    "lord": {
        "char": "主", "name": "主公", "rim_type": "gold",
        "bg_inner": "#9e1515", "bg_outer": "#400606",
        "char_color": "#fff2a8", "char_shadow": "#200303", "char_rim": "#d49b28"
    },
    "cavalry": {
        "char": "骑", "name": "骑兵", "rim_type": "silver",
        "bg_inner": "#1d4370", "bg_outer": "#0a1829",
        "char_color": "#f0f4ff", "char_shadow": "#050b12", "char_rim": "#9bb7d4"
    },
    "spear": {
        "char": "枪", "name": "枪兵", "rim_type": "bronze",
        "bg_inner": "#1b5e39", "bg_outer": "#092415",
        "char_color": "#e8f5e9", "char_shadow": "#041009", "char_rim": "#a5d6a7"
    },
    "archer": {
        "char": "弓", "name": "弓兵", "rim_type": "amber",
        "bg_inner": "#7a4613", "bg_outer": "#331b04",
        "char_color": "#fff3e0", "char_shadow": "#170c01", "char_rim": "#ffb74d"
    },
    "infantry": {
        "char": "刀", "name": "刀兵", "rim_type": "iron",
        "bg_inner": "#692323", "bg_outer": "#2b0a0a",
        "char_color": "#fce4ec", "char_shadow": "#140404", "char_rim": "#e57373"
    },
    "strategist": {
        "char": "谋", "name": "谋士", "rim_type": "gold",
        "bg_inner": "#4a1c6d", "bg_outer": "#1c072b",
        "char_color": "#f3e5f5", "char_shadow": "#0e0217", "char_rim": "#ce93d8"
    },
    "logistics": {
        "char": "勤", "name": "后勤", "rim_type": "brass",
        "bg_inner": "#5c4d1f", "bg_outer": "#241d08",
        "char_color": "#fffde7", "char_shadow": "#120e03", "char_rim": "#fff59d"
    },
    "bandit": {
        "char": "贼", "name": "贼", "rim_type": "dark_iron",
        "bg_inner": "#303236", "bg_outer": "#141517",
        "char_color": "#ffcdd2", "char_shadow": "#08080a", "char_rim": "#ef5350"
    },
    "mage": {
        "char": "法", "name": "法师", "rim_type": "gold",
        "bg_inner": "#311b6d", "bg_outer": "#12082e",
        "char_color": "#ede7f6", "char_shadow": "#0a031c", "char_rim": "#b39ddb"
    }
}

RIM_PALETTES = {
    "gold": {
        "light": (255, 240, 160), "mid": (212, 165, 54), "dark": (120, 85, 18), "shadow": (55, 38, 5)
    },
    "silver": {
        "light": (245, 250, 255), "mid": (180, 195, 215), "dark": (95, 110, 130), "shadow": (40, 50, 60)
    },
    "bronze": {
        "light": (235, 205, 140), "mid": (175, 135, 75), "dark": (95, 70, 30), "shadow": (45, 30, 10)
    },
    "amber": {
        "light": (255, 220, 140), "mid": (205, 140, 45), "dark": (115, 70, 15), "shadow": (50, 28, 5)
    },
    "iron": {
        "light": (220, 225, 235), "mid": (145, 155, 168), "dark": (75, 82, 92), "shadow": (35, 38, 44)
    },
    "brass": {
        "light": (245, 225, 150), "mid": (185, 160, 80), "dark": (105, 88, 35), "shadow": (48, 40, 12)
    },
    "dark_iron": {
        "light": (180, 110, 110), "mid": (110, 60, 60), "dark": (60, 30, 30), "shadow": (28, 14, 14)
    }
}

def generate_badge(badge_key: str, out_path: Path):
    cfg = BADGE_STYLES[badge_key]
    rim_pal = RIM_PALETTES[cfg["rim_type"]]
    
    S = 512
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    center = S / 2.0
    
    # Outer drop shadow
    shadow_img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow_img)
    sdraw.ellipse([center - 225, center - 225 + 14, center + 225, center + 225 + 14], fill=(0, 0, 0, 160))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(14))
    img.alpha_composite(shadow_img)
    
    r_outer = 230
    r_inner = 175
    
    rim_layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    rpixels = rim_layer.load()
    
    bg_inner_col = hex_to_rgb(cfg["bg_inner"])
    bg_outer_col = hex_to_rgb(cfg["bg_outer"])
    
    for y in range(S):
        dy = y - center
        for x in range(S):
            dx = x - center
            dist = math.sqrt(dx * dx + dy * dy)
            if dist > r_outer + 1:
                continue
            
            alpha = 255
            if dist > r_outer - 1:
                alpha = int(255 * (r_outer + 1 - dist) / 2.0)
                alpha = max(0, min(255, alpha))
                
            if dist >= r_inner:
                norm_d = (dist - r_inner) / (r_outer - r_inner)
                angle = math.atan2(dy, dx)
                light_factor = (math.cos(angle + math.pi * 0.75) + 1.0) / 2.0
                
                if light_factor > 0.5:
                    t = (light_factor - 0.5) * 2.0
                    base = lerp_color(rim_pal["mid"], rim_pal["light"], t)
                else:
                    t = light_factor * 2.0
                    base = lerp_color(rim_pal["dark"], rim_pal["mid"], t)
                    
                if norm_d < 0.2:
                    base = lerp_color(base, rim_pal["light"], (0.2 - norm_d) / 0.2 * 0.5)
                elif norm_d > 0.85:
                    base = lerp_color(base, rim_pal["shadow"], (norm_d - 0.85) / 0.15 * 0.7)
                    
                rpixels[x, y] = (base[0], base[1], base[2], alpha)
            else:
                glow_dx = dx + 40
                glow_dy = dy + 40
                glow_dist = math.sqrt(glow_dx * glow_dx + glow_dy * glow_dy)
                glow_norm = min(1.0, glow_dist / (r_inner * 1.5))
                
                col = lerp_color(bg_inner_col, bg_outer_col, glow_norm)
                if dist > r_inner - 18:
                    inset_t = (dist - (r_inner - 18)) / 18.0
                    col = lerp_color(col, (10, 10, 10), inset_t * 0.6)
                    
                rpixels[x, y] = (col[0], col[1], col[2], 255)
                
    img.alpha_composite(rim_layer)
    draw = ImageDraw.Draw(img)
    
    # Bead ring
    bead_radius = (r_outer + r_inner) / 2.0
    num_beads = 28
    for i in range(num_beads):
        theta = i * 2.0 * math.pi / num_beads
        bx = center + bead_radius * math.cos(theta)
        by = center + bead_radius * math.sin(theta)
        br = 7.0
        draw.ellipse([bx - br + 1, by - br + 2, bx + br + 1, by + br + 2], fill=rim_pal["shadow"] + (200,))
        draw.ellipse([bx - br, by - br, bx + br, by + br], fill=rim_pal["mid"] + (255,))
        draw.ellipse([bx - br * 0.6 - 1, by - br * 0.6 - 1, bx - br * 0.1, by - br * 0.1], fill=rim_pal["light"] + (230,))
        
    draw.ellipse([center - r_inner - 2, center - r_inner - 2, center + r_inner + 2, center + r_inner + 2],
                 outline=rim_pal["mid"] + (180,), width=3)
    draw.ellipse([center - r_inner + 8, center - r_inner + 8, center + r_inner - 8, center + r_inner - 8],
                 outline=rim_pal["light"] + (90,), width=2)
                 
    accent_r = r_inner - 20
    for ang in [math.pi * 0.25, math.pi * 0.75, math.pi * 1.25, math.pi * 1.75]:
        ax = center + accent_r * math.cos(ang)
        ay = center + accent_r * math.sin(ang)
        draw.arc([ax - 18, ay - 18, ax + 18, ay + 18], 0, 360, fill=rim_pal["light"] + (80,), width=3)
        
    # Calligraphy character
    font_size = 230
    font = ImageFont.truetype(FONT_KAITI, font_size)
    char = cfg["char"]
    bbox = font.getbbox(char)
    bw = bbox[2] - bbox[0]
    bh = bbox[3] - bbox[1]
    cx = center - bw / 2.0 - bbox[0]
    cy = center - bh / 2.0 - bbox[1] - 8
    
    char_shadow = hex_to_rgb(cfg["char_shadow"])
    char_color = hex_to_rgb(cfg["char_color"])
    char_rim = hex_to_rgb(cfg["char_rim"])
    
    for off in [(0, 6), (2, 5), (4, 4), (-2, 5), (0, 4)]:
        draw.text((cx + off[0], cy + off[1]), char, font=font, fill=char_shadow + (190,))
        
    for ox in [-3, -2, -1, 0, 1, 2, 3]:
        for oy in [-3, -2, -1, 0, 1, 2, 3]:
            if ox*ox + oy*oy <= 9 and (ox != 0 or oy != 0):
                draw.text((cx + ox, cy + oy), char, font=font, fill=char_rim + (140,))
                
    char_mask = Image.new("L", (S, S), 0)
    cdraw = ImageDraw.Draw(char_mask)
    cdraw.text((cx, cy), char, font=font, fill=255)
    
    char_grad = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    cg_pixels = char_grad.load()
    mask_pixels = char_mask.load()
    
    for y in range(S):
        for x in range(S):
            a = mask_pixels[x, y]
            if a > 0:
                t = (y - (center - bh / 2.0)) / float(bh)
                t = max(0.0, min(1.0, t))
                c = lerp_color(char_color, char_rim, t * 0.7)
                cg_pixels[x, y] = (c[0], c[1], c[2], a)
                
    img.alpha_composite(char_grad)
    draw = ImageDraw.Draw(img)
    draw.text((cx - 1, cy - 2), char, font=font, fill=(255, 255, 255, 75))
    
    final_img = img.resize((256, 256), Image.LANCZOS)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    final_img.save(out_path, format="PNG")

# ==============================================================================
# 2. MAP SQUARE ICONS (15 items, 256x256)
# ==============================================================================

MAP_ICON_STYLES = {
    "battle": {
        "glyph": "战", "name": "普通战斗", "rim": "gold",
        "bg_inner": "#c62828", "bg_outer": "#560a0a",
        "char_color": "#ffffff", "char_shadow": "#2b0404"
    },
    "boss": {
        "glyph": "将", "name": "首领战", "rim": "gold",
        "bg_inner": "#7b1fa2", "bg_outer": "#310642",
        "char_color": "#fff2a8", "char_shadow": "#1a0324"
    },
    "elite": {
        "glyph": "精", "name": "精英战", "rim": "gold",
        "bg_inner": "#d84315", "bg_outer": "#4e1402",
        "char_color": "#fff8e1", "char_shadow": "#240801"
    },
    "treasure": {
        "glyph": "宝", "name": "宝箱", "rim": "gold",
        "bg_inner": "#f57f17", "bg_outer": "#5d3004",
        "char_color": "#ffffff", "char_shadow": "#2b1401"
    },
    "recover": {
        "glyph": "休", "name": "休整", "rim": "silver",
        "bg_inner": "#1976d2", "bg_outer": "#0a2d52",
        "char_color": "#ffffff", "char_shadow": "#041527"
    },
    "event": {
        "glyph": "事", "name": "剧情", "rim": "bronze",
        "bg_inner": "#546e7a", "bg_outer": "#1f2a2f",
        "char_color": "#ffffff", "char_shadow": "#0d1315"
    },
    "choose": {
        "glyph": "选", "name": "抉择", "rim": "amber",
        "bg_inner": "#f59e0b", "bg_outer": "#664002",
        "char_color": "#ffffff", "char_shadow": "#261700"
    },
    "recruit": {
        "glyph": "募", "name": "招募", "rim": "bronze",
        "bg_inner": "#2e7d32", "bg_outer": "#0d3110",
        "char_color": "#ffffff", "char_shadow": "#051706"
    },
    "mystery": {
        "glyph": "？", "name": "奇遇", "rim": "silver",
        "bg_inner": "#0288d1", "bg_outer": "#013857",
        "char_color": "#ffffff", "char_shadow": "#001826"
    },
    "hazard": {
        "glyph": "险", "name": "险滩", "rim": "dark_iron",
        "bg_inner": "#ad1457", "bg_outer": "#440521",
        "char_color": "#ffffff", "char_shadow": "#200210"
    },
    "glory": {
        "glyph": "威", "name": "威震诸侯", "rim": "gold",
        "bg_inner": "#e65100", "bg_outer": "#591f00",
        "char_color": "#fff9c4", "char_shadow": "#290e00"
    },
    "temple": {
        "glyph": "庙", "name": "山神庙", "rim": "bronze",
        "bg_inner": "#6d4c41", "bg_outer": "#2b1c18",
        "char_color": "#ffffff", "char_shadow": "#140c0a"
    },
    "physician": {
        "glyph": "医", "name": "华佗", "rim": "silver",
        "bg_inner": "#00897b", "bg_outer": "#003b35",
        "char_color": "#ffffff", "char_shadow": "#001a17"
    },
    "curse": {
        "glyph": "凶", "name": "于吉", "rim": "dark_iron",
        "bg_inner": "#3f51b5", "bg_outer": "#131b47",
        "char_color": "#ffffff", "char_shadow": "#080b21"
    },
    "red_turban": {
        "glyph": "赤", "name": "救祖茂", "rim": "gold",
        "bg_inner": "#b71c1c", "bg_outer": "#4b0808",
        "char_color": "#ffffff", "char_shadow": "#210303"
    }
}

def generate_map_icon(key: str, out_path: Path):
    cfg = MAP_ICON_STYLES[key]
    rim_pal = RIM_PALETTES[cfg["rim"]]
    
    S = 512
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    center = S / 2.0
    
    # Shadow
    shadow_img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow_img)
    sdraw.ellipse([center - 220, center - 220 + 16, center + 220, center + 220 + 16], fill=(0, 0, 0, 170))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(14))
    img.alpha_composite(shadow_img)
    
    r_outer = 226
    r_inner = 176
    
    rim_layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    rpixels = rim_layer.load()
    
    bg_inner_col = hex_to_rgb(cfg["bg_inner"])
    bg_outer_col = hex_to_rgb(cfg["bg_outer"])
    
    for y in range(S):
        dy = y - center
        for x in range(S):
            dx = x - center
            dist = math.sqrt(dx * dx + dy * dy)
            if dist > r_outer + 1:
                continue
                
            alpha = 255
            if dist > r_outer - 1:
                alpha = int(255 * (r_outer + 1 - dist) / 2.0)
                alpha = max(0, min(255, alpha))
                
            if dist >= r_inner:
                norm_d = (dist - r_inner) / (r_outer - r_inner)
                angle = math.atan2(dy, dx)
                light_factor = (math.cos(angle + math.pi * 0.75) + 1.0) / 2.0
                
                if light_factor > 0.5:
                    t = (light_factor - 0.5) * 2.0
                    base = lerp_color(rim_pal["mid"], rim_pal["light"], t)
                else:
                    t = light_factor * 2.0
                    base = lerp_color(rim_pal["dark"], rim_pal["mid"], t)
                    
                if norm_d < 0.2:
                    base = lerp_color(base, rim_pal["light"], (0.2 - norm_d) / 0.2 * 0.5)
                elif norm_d > 0.85:
                    base = lerp_color(base, rim_pal["shadow"], (norm_d - 0.85) / 0.15 * 0.7)
                    
                rpixels[x, y] = (base[0], base[1], base[2], alpha)
            else:
                glow_dx = dx + 35
                glow_dy = dy + 35
                glow_dist = math.sqrt(glow_dx * glow_dx + glow_dy * glow_dy)
                glow_norm = min(1.0, glow_dist / (r_inner * 1.5))
                
                col = lerp_color(bg_inner_col, bg_outer_col, glow_norm)
                if dist > r_inner - 16:
                    inset_t = (dist - (r_inner - 16)) / 16.0
                    col = lerp_color(col, (8, 8, 8), inset_t * 0.65)
                    
                rpixels[x, y] = (col[0], col[1], col[2], 255)
                
    img.alpha_composite(rim_layer)
    draw = ImageDraw.Draw(img)
    
    # Stamp inner double rings
    draw.ellipse([center - r_inner - 2, center - r_inner - 2, center + r_inner + 2, center + r_inner + 2],
                 outline=rim_pal["mid"] + (180,), width=3)
    draw.ellipse([center - r_inner + 6, center - r_inner + 6, center + r_inner - 6, center + r_inner - 6],
                 outline=rim_pal["light"] + (120,), width=2)
                 
    # 4 cardinal studs
    for ang in [0, math.pi * 0.5, math.pi, math.pi * 1.5]:
        mid_r = (r_outer + r_inner) / 2.0
        sx = center + mid_r * math.cos(ang)
        sy = center + mid_r * math.sin(ang)
        draw.ellipse([sx - 8, sy - 8, sx + 8, sy + 8], fill=rim_pal["light"] + (255,))
        draw.ellipse([sx - 8, sy - 8, sx + 8, sy + 8], outline=rim_pal["shadow"] + (220,), width=2)
        
    # Seal calligraphy glyph
    font_size = 236
    font = ImageFont.truetype(FONT_KAITI, font_size)
    char = cfg["glyph"]
    bbox = font.getbbox(char)
    bw = bbox[2] - bbox[0]
    bh = bbox[3] - bbox[1]
    cx = center - bw / 2.0 - bbox[0]
    cy = center - bh / 2.0 - bbox[1] - 8
    
    char_shadow = hex_to_rgb(cfg["char_shadow"])
    char_color = hex_to_rgb(cfg["char_color"])
    
    # Carved 3D shadow
    for off in [(0, 7), (3, 6), (5, 5), (-2, 6), (0, 5)]:
        draw.text((cx + off[0], cy + off[1]), char, font=font, fill=char_shadow + (210,))
        
    # Gold edge rim
    for ox in [-3, -2, -1, 0, 1, 2, 3]:
        for oy in [-3, -2, -1, 0, 1, 2, 3]:
            if ox*ox + oy*oy <= 9 and (ox != 0 or oy != 0):
                draw.text((cx + ox, cy + oy), char, font=font, fill=rim_pal["light"] + (110,))
                
    draw.text((cx, cy), char, font=font, fill=char_color + (255,))
    draw.text((cx - 1, cy - 2), char, font=font, fill=(255, 255, 255, 120))
    
    final_img = img.resize((256, 256), Image.LANCZOS)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    final_img.save(out_path, format="PNG")

# ==============================================================================
# 3. COMMANDER TOKEN (M5, 128x128)
# ==============================================================================

def generate_commander_token(out_path: Path):
    S = 256
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    center = S / 2.0
    
    # Drop shadow
    shadow_img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow_img)
    sdraw.ellipse([center - 110, center - 110 + 10, center + 110, center + 110 + 10], fill=(0, 0, 0, 180))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(10))
    img.alpha_composite(shadow_img)
    
    draw = ImageDraw.Draw(img)
    # Golden dragon bezel
    draw.ellipse([center - 112, center - 112, center + 112, center + 112], fill=(212, 165, 54, 255), outline=(120, 85, 18, 255), width=4)
    draw.ellipse([center - 100, center - 100, center + 100, center + 100], fill=(255, 240, 160, 255))
    draw.ellipse([center - 92, center - 92, center + 92, center + 92], fill=(160, 20, 20, 255), outline=(90, 10, 10, 255), width=3)
    
    # 8 golden studs
    for i in range(8):
        ang = i * math.pi / 4.0
        sx = center + 104 * math.cos(ang)
        sy = center + 104 * math.sin(ang)
        draw.ellipse([sx - 4, sy - 4, sx + 4, sy + 4], fill=(255, 250, 210, 255))
        
    # Commander flag/seal character "帅" or "主"
    font = ImageFont.truetype(FONT_KAITI, 128)
    char = "主"
    bbox = font.getbbox(char)
    bw = bbox[2] - bbox[0]
    bh = bbox[3] - bbox[1]
    cx = center - bw / 2.0 - bbox[0]
    cy = center - bh / 2.0 - bbox[1] - 4
    
    draw.text((cx + 2, cy + 3), char, font=font, fill=(40, 5, 5, 200))
    draw.text((cx, cy), char, font=font, fill=(255, 235, 140, 255))
    draw.text((cx - 1, cy - 1), char, font=font, fill=(255, 255, 255, 150))
    
    final_img = img.resize((128, 128), Image.LANCZOS)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    final_img.save(out_path, format="PNG")

# ==============================================================================
# 4. RELIC ICONS (36 items, 256x256)
# ==============================================================================

RELIC_MOTIFS = {
    # id: (name, motif_type, rarity, char)
    "hupi": ("虎皮披风", "tiger_mantle", "common", "虎"),
    "shoushihe": ("首饰盒", "jewelry_box", "common", "盒"),
    "jiunang": ("酒囊", "wine_skin", "common", "酒"),
    "bingfu": ("虎符", "tiger_tally", "common", "符"),
    "hushenfu": ("平安符", "talisman", "common", "安"),
    "xiangnang": ("香囊", "sachet", "common", "香"),
    "jinfan": ("锦帆铃", "bronze_bell", "common", "铃"),
    "bingfa": ("孙子兵法", "scroll", "rare", "孙"),
    "gudingdao": ("古锭刀", "saber", "rare", "锭"),
    "yushan": ("羽扇", "feather_fan", "rare", "扇"),
    "zhangu": ("战鼓", "war_drum", "rare", "鼓"),
    "chize": ("赤帻", "red_headscarf", "rare", "帻"),
    "qinggang": ("青釭剑", "jian_sword", "rare", "釭"),
    "qixing": ("七星宝刀", "star_dagger", "rare", "星"),
    "bazhen": ("八阵图", "trigram_map", "rare", "阵"),
    "dunjia": ("遁甲天书", "mystic_scroll", "rare", "遁"),
    "muniu": ("木牛流马", "wooden_ox", "rare", "牛"),
    "beishui": ("破釜", "cauldron", "rare", "釜"),
    "dingxin": ("定心丸", "elixir_pill", "rare", "丸"),
    "jubaopen": ("聚宝盆", "treasure_bowl", "rare", "盆"),
    "zhaoxianbang": ("招贤榜", "edict_banner", "rare", "榜"),
    "yitian": ("倚天剑", "imperial_sword", "rare", "倚"),
    "chitu": ("赤兔马", "horse_crest", "rare", "赤"),
    "zhangba": ("丈八蛇矛", "serpent_spear", "common", "矛"),
    "zhugenu": ("诸葛连弩", "crossbow", "common", "弩"),
    "qinglong": ("青龙偃月刀", "crescent_blade", "rare", "龙"),
    "mengde": ("孟德新书", "book", "common", "孟"),
    "heishan": ("黑山令", "iron_token", "common", "黑"),
    "taipingyaoshu": ("太平要术", "taoist_scripture", "rare", "太"),
    "qingnang": ("青囊书", "medical_scroll", "common", "囊"),
    "yuxi": ("传国玉玺", "jade_seal", "curse", "玺"),
    "huangjinfu": ("黄巾符", "cursed_talisman", "curse", "黄"),
    "dilu": ("的卢", "cursed_steed", "curse", "卢"),
    "fangtian": ("方天画戟", "halberd", "curse", "戟"),
    "tengjia": ("藤甲", "rattan_armor", "curse", "藤"),
    "jiujia": ("孙坚旧甲", "silver_armor", "story", "甲")
}

RELIC_TIER_STYLES = {
    "common": {
        "rim": "bronze",
        "bg_inner": "#243d34",
        "bg_outer": "#0d1a15",
        "glow": (120, 200, 160, 80),
        "accent": "#9ccc65"
    },
    "rare": {
        "rim": "gold",
        "bg_inner": "#381a4e",
        "bg_outer": "#14061e",
        "glow": (220, 160, 255, 90),
        "accent": "#e040fb"
    },
    "curse": {
        "rim": "dark_iron",
        "bg_inner": "#3b0a0a",
        "bg_outer": "#160303",
        "glow": (255, 60, 60, 100),
        "accent": "#ff1744"
    },
    "story": {
        "rim": "silver",
        "bg_inner": "#1c3247",
        "bg_outer": "#08131d",
        "glow": (160, 220, 255, 90),
        "accent": "#40c4ff"
    }
}

def draw_relic_motif(draw: ImageDraw.Draw, motif: str, center: float, S: int, accent_rgb: tuple):
    cx, cy = center, center - 20
    ac = accent_rgb + (240,)
    gold = (255, 225, 120, 255)
    light_gold = (255, 245, 180, 255)
    steel = (210, 225, 245, 255)
    wood = (160, 100, 50, 255)
    red = (220, 40, 40, 255)
    jade = (160, 235, 195, 255)
    
    if motif == "jade_seal":
        # Imperial Jade Seal
        draw.rectangle([cx - 55, cy + 10, cx + 55, cy + 65], fill=jade, outline=(40, 120, 80, 255), width=3)
        # Gold mended corner
        draw.polygon([(cx + 30, cy + 10), (cx + 55, cy + 10), (cx + 55, cy + 35)], fill=gold)
        # Dragon handle
        draw.polygon([(cx - 45, cy + 10), (cx - 20, cy - 45), (cx + 20, cy - 45), (cx + 45, cy + 10)], fill=jade, outline=(40, 120, 80, 255), width=3)
        draw.ellipse([cx - 22, cy - 58, cx + 22, cy - 30], fill=jade, outline=(40, 120, 80, 255), width=3)
        draw.ellipse([cx - 7, cy - 52, cx - 1, cy - 46], fill=(255, 40, 40, 255))
        draw.ellipse([cx + 1, cy - 52, cx + 7, cy - 46], fill=(255, 40, 40, 255))
        
    elif motif in ("jian_sword", "imperial_sword"):
        # Straight Han sword blade
        draw.polygon([(cx, cy - 90), (cx + 14, cy + 30), (cx - 14, cy + 30)], fill=steel, outline=(100, 120, 150, 255), width=2)
        draw.line([(cx, cy - 85), (cx, cy + 30)], fill=(255, 255, 255, 230), width=2)
        # Guard
        draw.polygon([(cx - 40, cy + 30), (cx + 40, cy + 30), (cx + 25, cy + 42), (cx - 25, cy + 42)], fill=gold)
        # Hilt
        draw.rectangle([cx - 7, cy + 42, cx + 7, cy + 78], fill=(50, 40, 30, 255))
        # Pommel
        draw.ellipse([cx - 15, cy + 76, cx + 15, cy + 96], fill=gold)
        
    elif motif in ("saber", "crescent_blade"):
        # Curved saber / Guan Dao
        draw.polygon([(cx - 30, cy + 40), (cx + 35, cy - 70), (cx + 48, cy - 50), (cx - 10, cy + 40)], fill=steel)
        draw.polygon([(cx - 45, cy + 40), (cx + 10, cy + 40), (cx - 10, cy + 55)], fill=gold)
        draw.rectangle([cx - 25, cy + 55, cx - 10, cy + 90], fill=wood)
        
    elif motif == "star_dagger":
        # Seven star dagger
        draw.polygon([(cx + 35, cy - 80), (cx + 40, cy - 40), (cx - 20, cy + 30), (cx - 32, cy + 18)], fill=steel)
        # Seven colored stars
        pts = [(cx + 26, cy - 60), (cx + 18, cy - 42), (cx + 10, cy - 25), (cx + 2, cy - 8),
               (cx - 6, cy + 8), (cx - 15, cy + 20), (cx - 5, cy + 24)]
        colors = [(255, 60, 60), (255, 180, 50), (255, 255, 80), (80, 255, 120), (60, 200, 255), (160, 100, 255), (255, 120, 220)]
        for pt, col in zip(pts, colors):
            draw.ellipse([pt[0] - 4, pt[1] - 4, pt[0] + 4, pt[1] + 4], fill=col + (255,))
        # Hilt
        draw.polygon([(cx - 45, cy + 25), (cx - 15, cy + 45), (cx - 25, cy + 60), (cx - 55, cy + 35)], fill=gold)
        
    elif motif == "tiger_tally":
        # Bronze crouching tiger halves
        draw.polygon([(cx - 70, cy + 25), (cx - 50, cy - 25), (cx, cy - 45), (cx + 55, cy - 25), (cx + 70, cy + 25), (cx + 40, cy + 35), (cx - 40, cy + 35)], fill=gold, outline=(120, 80, 10, 255), width=3)
        draw.line([(cx, cy - 45), (cx, cy + 35)], fill=(60, 30, 5, 255), width=4)
        draw.ellipse([cx - 48, cy - 18, cx - 40, cy - 10], fill=(40, 20, 5, 255))
        draw.ellipse([cx + 40, cy - 18, cx + 48, cy - 10], fill=(40, 20, 5, 255))
        
    elif motif == "tiger_mantle":
        # Tiger fur pelt
        draw.polygon([(cx - 60, cy - 50), (cx + 60, cy - 50), (cx + 75, cy + 40), (cx, cy + 65), (cx - 75, cy + 40)], fill=(245, 160, 45, 255), outline=(140, 70, 10, 255), width=3)
        # Stripes
        for sy in [-25, 0, 25]:
            draw.polygon([(cx - 45, cy + sy), (cx - 20, cy + sy - 5), (cx - 40, cy + sy + 10)], fill=(30, 20, 15, 255))
            draw.polygon([(cx + 45, cy + sy), (cx + 20, cy + sy - 5), (cx + 40, cy + sy + 10)], fill=(30, 20, 15, 255))
        # Golden clasp
        draw.ellipse([cx - 20, cy - 62, cx + 20, cy - 38], fill=gold)
        
    elif motif == "wine_skin":
        # Leather wine flask
        draw.polygon([(cx - 15, cy - 65), (cx + 15, cy - 65), (cx + 55, cy + 25), (cx + 35, cy + 65), (cx - 35, cy + 65), (cx - 55, cy + 25)], fill=(160, 95, 45, 255), outline=(90, 45, 15, 255), width=3)
        draw.rectangle([cx - 12, cy - 78, cx + 12, cy - 65], fill=gold)
        draw.ellipse([cx - 10, cy - 86, cx + 10, cy - 74], fill=(180, 40, 30, 255))
        draw.line([(cx - 35, cy), (cx + 35, cy)], fill=red, width=4)
        
    elif motif == "feather_fan":
        # Zhou Yu's white crane feather fan
        for ang in [-0.5, -0.25, 0, 0.25, 0.5]:
            fx = cx + 70 * math.sin(ang)
            fy = cy - 25 - 65 * math.cos(ang)
            draw.ellipse([fx - 18, fy - 18, fx + 18, fy + 18], fill=(245, 248, 255, 240), outline=(180, 200, 220, 200), width=2)
        draw.rectangle([cx - 6, cy + 10, cx + 6, cy + 80], fill=wood)
        draw.ellipse([cx - 12, cy + 78, cx + 12, cy + 96], fill=gold)
        
    elif motif == "war_drum":
        # Red war drum
        draw.ellipse([cx - 65, cy - 45, cx + 65, cy + 45], fill=red, outline=(90, 15, 15, 255), width=3)
        draw.ellipse([cx - 50, cy - 32, cx + 50, cy + 32], fill=(245, 230, 195, 255), outline=gold, width=3)
        # Drumsticks
        draw.line([(cx - 60, cy - 55), (cx + 30, cy + 45)], fill=wood, width=8)
        draw.line([(cx + 60, cy - 55), (cx - 30, cy + 45)], fill=wood, width=8)
        
    elif motif == "red_headscarf":
        # Zu Mao's red turban
        draw.polygon([(cx - 65, cy - 15), (cx + 65, cy - 15), (cx + 50, cy + 35), (cx - 50, cy + 35)], fill=red, outline=(140, 20, 20, 255), width=3)
        draw.polygon([(cx + 30, cy + 30), (cx + 70, cy + 85), (cx + 40, cy + 85), (cx + 15, cy + 35)], fill=red)
        draw.ellipse([cx - 15, cy - 18, cx + 15, cy + 12], fill=gold)
        
    elif motif == "talisman":
        # Taoist / peace silk amulet
        draw.polygon([(cx - 35, cy - 65), (cx + 35, cy - 65), (cx + 48, cy + 45), (cx, cy + 75), (cx - 48, cy + 45)], fill=red, outline=gold, width=3)
        draw.rectangle([cx - 20, cy - 40, cx + 20, cy + 30], outline=gold, width=2)
        draw.line([(cx, cy + 75), (cx, cy + 105)], fill=gold, width=4)
        draw.ellipse([cx - 8, cy + 102, cx + 8, cy + 116], fill=jade)
        
    elif motif == "trigram_map":
        # Eight Trigrams / Bagua
        draw.ellipse([cx - 65, cy - 65, cx + 65, cy + 65], fill=(30, 25, 20, 255), outline=gold, width=4)
        # Yin yang
        draw.pieslice([cx - 45, cy - 45, cx + 45, cy + 45], -90, 90, fill=(245, 245, 245, 255))
        draw.pieslice([cx - 45, cy - 45, cx + 45, cy + 45], 90, 270, fill=(20, 20, 20, 255))
        draw.ellipse([cx - 22, cy - 45, cx + 22, cy], fill=(245, 245, 245, 255))
        draw.ellipse([cx - 22, cy, cx + 22, cy + 45], fill=(20, 20, 20, 255))
        draw.ellipse([cx - 6, cy - 28, cx + 6, cy - 16], fill=(20, 20, 20, 255))
        draw.ellipse([cx - 6, cy + 16, cx + 6, cy + 28], fill=(245, 245, 245, 255))
        
    elif motif == "cauldron":
        # Broken Cauldron (Po Fu)
        draw.polygon([(cx - 60, cy - 35), (cx + 60, cy - 35), (cx + 50, cy + 45), (cx - 50, cy + 45)], fill=(50, 52, 58, 255), outline=(180, 190, 205, 255), width=3)
        draw.line([(cx - 35, cy + 45), (cx - 45, cy + 75)], fill=(50, 52, 58, 255), width=8)
        draw.line([(cx + 35, cy + 45), (cx + 45, cy + 75)], fill=(50, 52, 58, 255), width=8)
        draw.line([(cx - 15, cy - 20), (cx + 10, cy + 25)], fill=(255, 90, 40, 255), width=4)
        
    elif motif == "elixir_pill":
        # Golden Elixir Pill
        draw.ellipse([cx - 65, cy + 10, cx + 65, cy + 55], fill=jade, outline=(50, 140, 100, 255), width=3)
        draw.ellipse([cx - 38, cy - 48, cx + 38, cy + 28], fill=gold, outline=(180, 130, 20, 255), width=3)
        draw.ellipse([cx - 20, cy - 38, cx - 2, cy - 20], fill=light_gold)
        
    elif motif == "treasure_bowl":
        # Ju Bao Pen
        draw.polygon([(cx - 65, cy - 10), (cx + 65, cy - 10), (cx + 45, cy + 55), (cx - 45, cy + 55)], fill=gold, outline=(150, 100, 10, 255), width=3)
        # Gold ingots inside
        for ox, oy in [(-25, -22), (25, -22), (0, -38)]:
            draw.ellipse([cx + ox - 20, cy + oy - 12, cx + ox + 20, cy + oy + 12], fill=light_gold, outline=(160, 110, 10, 255), width=2)
            
    elif motif == "serpent_spear":
        # Viper Spear
        draw.polygon([(cx, cy - 90), (cx + 18, cy - 55), (cx - 18, cy - 20), (cx + 16, cy + 15), (cx, cy + 40), (cx - 16, cy + 15), (cx + 18, cy - 20), (cx - 18, cy - 55)], fill=steel, outline=(100, 120, 150, 255), width=2)
        draw.rectangle([cx - 40, cy + 38, cx + 40, cy + 55], fill=red)
        draw.rectangle([cx - 7, cy + 55, cx + 7, cy + 90], fill=wood)
        
    elif motif == "crossbow":
        # Zhuge Crossbow
        draw.polygon([(cx - 75, cy - 10), (cx + 75, cy - 10), (cx + 65, cy + 8), (cx - 65, cy + 8)], fill=wood)
        draw.rectangle([cx - 18, cy - 45, cx + 18, cy + 30], fill=(80, 50, 25, 255), outline=gold, width=2)
        draw.rectangle([cx - 8, cy + 10, cx + 8, cy + 80], fill=wood)
        
    elif motif == "halberd":
        # Fang Tian Hua Ji
        draw.polygon([(cx, cy - 95), (cx + 12, cy + 15), (cx - 12, cy + 15)], fill=steel)
        # Twin crescents
        draw.arc([cx - 48, cy - 45, cx - 8, cy + 15], -90, 90, fill=steel, width=8)
        draw.arc([cx + 8, cy - 45, cx + 48, cy + 15], 90, 270, fill=steel, width=8)
        draw.rectangle([cx - 20, cy + 15, cx + 20, cy + 32], fill=red)
        draw.rectangle([cx - 6, cy + 32, cx + 6, cy + 90], fill=wood)
        
    elif motif == "silver_armor":
        # Sun Jian's Silver Armor
        draw.polygon([(cx - 60, cy - 45), (cx + 60, cy - 45), (cx + 50, cy + 55), (cx, cy + 70), (cx - 50, cy + 55)], fill=steel, outline=(140, 160, 185, 255), width=3)
        draw.ellipse([cx - 25, cy - 15, cx + 25, cy + 35], fill=(160, 180, 210, 255), outline=gold, width=3)
        draw.line([(cx - 45, cy - 45), (cx, cy - 15), (cx + 45, cy - 45)], fill=gold, width=4)
        
    elif motif == "wooden_ox":
        # Wooden Ox
        draw.polygon([(cx - 65, cy + 15), (cx - 45, cy - 35), (cx + 35, cy - 35), (cx + 65, cy - 10), (cx + 50, cy + 35), (cx - 50, cy + 35)], fill=wood, outline=(90, 50, 20, 255), width=3)
        draw.ellipse([cx - 35, cy + 30, cx - 5, cy + 60], fill=gold)
        draw.ellipse([cx + 5, cy + 30, cx + 35, cy + 60], fill=gold)
        
    elif motif in ("scroll", "mystic_scroll", "edict_banner", "taoist_scripture", "medical_scroll"):
        # Ancient Chinese scroll / scripture
        draw.rectangle([cx - 60, cy - 50, cx + 60, cy + 50], fill=(245, 235, 200, 255), outline=(160, 130, 80, 255), width=3)
        draw.line([(cx - 68, cy - 55), (cx - 68, cy + 55)], fill=wood, width=12)
        draw.line([(cx + 68, cy - 55), (cx + 68, cy + 55)], fill=wood, width=12)
        draw.line([(cx - 40, cy - 25), (cx + 40, cy - 25)], fill=(120, 90, 50, 255), width=4)
        draw.line([(cx - 40, cy), (cx + 40, cy)], fill=(120, 90, 50, 255), width=4)
        draw.line([(cx - 40, cy + 25), (cx + 40, cy + 25)], fill=(120, 90, 50, 255), width=4)
        
    else:
        # Default circular emblem with cross / star
        draw.ellipse([cx - 55, cy - 55, cx + 55, cy + 55], fill=ac, outline=gold, width=4)
        draw.polygon([(cx, cy - 45), (cx + 38, cy + 30), (cx - 38, cy + 30)], fill=gold)

def generate_relic(relic_id: str, out_path: Path):
    if relic_id not in RELIC_MOTIFS or relic_id in (
        "gudingdao", "shoushihe", "jiunang", "bingfu", "hushenfu",
        "xiangnang", "jinfan", "bingfa", "yushan", "zhangu",
        "chize", "qinggang", "bazhen", "dunjia",
    ):
        return
    name, motif, rarity, char = RELIC_MOTIFS[relic_id]
    cfg = RELIC_TIER_STYLES[rarity]
    rim_pal = RIM_PALETTES[cfg["rim"]]
    
    S = 512
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    center = S / 2.0
    
    # Drop shadow
    shadow_img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow_img)
    sdraw.ellipse([center - 225, center - 225 + 16, center + 225, center + 225 + 16], fill=(0, 0, 0, 180))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(14))
    img.alpha_composite(shadow_img)
    
    r_outer = 230
    r_inner = 175
    
    rim_layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    rpixels = rim_layer.load()
    
    bg_inner_col = hex_to_rgb(cfg["bg_inner"])
    bg_outer_col = hex_to_rgb(cfg["bg_outer"])
    
    for y in range(S):
        dy = y - center
        for x in range(S):
            dx = x - center
            dist = math.sqrt(dx * dx + dy * dy)
            if dist > r_outer + 1:
                continue
                
            alpha = 255
            if dist > r_outer - 1:
                alpha = int(255 * (r_outer + 1 - dist) / 2.0)
                alpha = max(0, min(255, alpha))
                
            if dist >= r_inner:
                norm_d = (dist - r_inner) / (r_outer - r_inner)
                angle = math.atan2(dy, dx)
                light_factor = (math.cos(angle + math.pi * 0.75) + 1.0) / 2.0
                
                if light_factor > 0.5:
                    t = (light_factor - 0.5) * 2.0
                    base = lerp_color(rim_pal["mid"], rim_pal["light"], t)
                else:
                    t = light_factor * 2.0
                    base = lerp_color(rim_pal["dark"], rim_pal["mid"], t)
                    
                if norm_d < 0.2:
                    base = lerp_color(base, rim_pal["light"], (0.2 - norm_d) / 0.2 * 0.5)
                elif norm_d > 0.85:
                    base = lerp_color(base, rim_pal["shadow"], (norm_d - 0.85) / 0.15 * 0.7)
                    
                rpixels[x, y] = (base[0], base[1], base[2], alpha)
            else:
                glow_dx = dx + 35
                glow_dy = dy + 35
                glow_dist = math.sqrt(glow_dx * glow_dx + glow_dy * glow_dy)
                glow_norm = min(1.0, glow_dist / (r_inner * 1.5))
                
                col = lerp_color(bg_inner_col, bg_outer_col, glow_norm)
                if dist > r_inner - 16:
                    inset_t = (dist - (r_inner - 16)) / 16.0
                    col = lerp_color(col, (8, 8, 8), inset_t * 0.65)
                    
                rpixels[x, y] = (col[0], col[1], col[2], 255)
                
    img.alpha_composite(rim_layer)
    draw = ImageDraw.Draw(img)
    
    # 28 3D Bead studs on metallic rim
    bead_radius = (r_outer + r_inner) / 2.0
    num_beads = 28
    for i in range(num_beads):
        theta = i * 2.0 * math.pi / num_beads
        bx = center + bead_radius * math.cos(theta)
        by = center + bead_radius * math.sin(theta)
        br = 7.0
        draw.ellipse([bx - br + 1, by - br + 2, bx + br + 1, by + br + 2], fill=rim_pal["shadow"] + (200,))
        draw.ellipse([bx - br, by - br, bx + br, by + br], fill=rim_pal["mid"] + (255,))
        draw.ellipse([bx - br * 0.6 - 1, by - br * 0.6 - 1, bx - br * 0.1, by - br * 0.1], fill=rim_pal["light"] + (230,))
        
    # Medallion inner concentric borders
    draw.ellipse([center - r_inner - 2, center - r_inner - 2, center + r_inner + 2, center + r_inner + 2],
                 outline=rim_pal["mid"] + (180,), width=3)
    draw.ellipse([center - r_inner + 8, center - r_inner + 8, center + r_inner - 8, center + r_inner - 8],
                 outline=rim_pal["light"] + (90,), width=2)
                 
    # 4 Corner cloud scroll brackets
    accent_r = r_inner - 22
    for ang in [math.pi * 0.25, math.pi * 0.75, math.pi * 1.25, math.pi * 1.75]:
        ax = center + accent_r * math.cos(ang)
        ay = center + accent_r * math.sin(ang)
        draw.arc([ax - 18, ay - 18, ax + 18, ay + 18], 0, 360, fill=rim_pal["light"] + (80,), width=3)
        
    # Subtle background motif watermark
    accent_rgb = hex_to_rgb(cfg["accent"])
    motif_layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    mdraw = ImageDraw.Draw(motif_layer)
    draw_relic_motif(mdraw, motif, center, S, accent_rgb)
    motif_layer = motif_layer.filter(ImageFilter.GaussianBlur(1))
    # Blend motif subtly into the background
    img = Image.alpha_composite(img, Image.blend(Image.new("RGBA", (S, S), (0, 0, 0, 0)), motif_layer, 0.45))
    draw = ImageDraw.Draw(img)
    
    # Large, bold, majestic KaiTi Calligraphy Seal Character
    font_size = 230
    font = ImageFont.truetype(FONT_KAITI, font_size)
    bbox = font.getbbox(char)
    bw = bbox[2] - bbox[0]
    bh = bbox[3] - bbox[1]
    cx = center - bw / 2.0 - bbox[0]
    cy = center - bh / 2.0 - bbox[1] - 8
    
    char_shadow = (10, 5, 5)
    char_rim = rim_pal["light"]
    char_color = (255, 255, 255) if rarity != "rare" else (255, 245, 185)
    
    # Deep etched drop shadow
    for off in [(0, 7), (3, 6), (5, 5), (-2, 6), (0, 5)]:
        draw.text((cx + off[0], cy + off[1]), char, font=font, fill=char_shadow + (220,))
        
    # Gold edge rim
    for ox in [-3, -2, -1, 0, 1, 2, 3]:
        for oy in [-3, -2, -1, 0, 1, 2, 3]:
            if ox*ox + oy*oy <= 9 and (ox != 0 or oy != 0):
                draw.text((cx + ox, cy + oy), char, font=font, fill=char_rim + (140,))
                
    # Main character body with golden/silver gradient
    char_mask = Image.new("L", (S, S), 0)
    cdraw = ImageDraw.Draw(char_mask)
    cdraw.text((cx, cy), char, font=font, fill=255)
    
    char_grad = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    cg_pixels = char_grad.load()
    mask_pixels = char_mask.load()
    
    for y in range(S):
        for x in range(S):
            a = mask_pixels[x, y]
            if a > 0:
                t = (y - (center - bh / 2.0)) / float(bh)
                t = max(0.0, min(1.0, t))
                c = lerp_color(char_color, rim_pal["mid"], t * 0.65)
                cg_pixels[x, y] = (c[0], c[1], c[2], a)
                
    img.alpha_composite(char_grad)
    draw = ImageDraw.Draw(img)
    draw.text((cx - 1, cy - 2), char, font=font, fill=(255, 255, 255, 90))
    
    final_img = img.resize((256, 256), Image.LANCZOS)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    final_img.save(out_path, format="PNG")

# ==============================================================================
# 5. CARD BACK (1000x1400, 5:7)
# ==============================================================================

def generate_card_back(out_path: Path):
    W, H = 1000, 1400
    img = Image.new("RGBA", (W, H), (24, 25, 30, 255))
    draw = ImageDraw.Draw(img)
    
    # Subtle Xuan paper texture gradient
    for y in range(H):
        t = y / float(H)
        c = lerp_color((20, 22, 26), (35, 38, 44), t)
        draw.line([(0, y), (W, y)], fill=c + (255,))
        
    # Gold border
    bw = 36
    draw.rectangle([bw, bw, W - bw, H - bw], outline=(212, 165, 54, 255), width=8)
    draw.rectangle([bw + 12, bw + 12, W - bw - 12, H - bw - 12], outline=(140, 100, 30, 255), width=3)
    
    # 4 Corner ornaments (traditional Chinese Ruyi cloud pattern)
    for cx, cy in [(bw + 40, bw + 40), (W - bw - 40, bw + 40), (bw + 40, H - bw - 40), (W - bw - 40, H - bw - 40)]:
        draw.ellipse([cx - 30, cy - 30, cx + 30, cy + 30], outline=(255, 225, 120, 255), width=3)
        draw.ellipse([cx - 15, cy - 15, cx + 15, cy + 15], fill=(212, 165, 54, 255))
        
    # Central Grand Medallion
    center_x, center_y = W / 2.0, H / 2.0
    r_medallion = 260
    
    draw.ellipse([center_x - r_medallion, center_y - r_medallion, center_x + r_medallion, center_y + r_medallion],
                 fill=(16, 18, 22, 255), outline=(212, 165, 54, 255), width=10)
    draw.ellipse([center_x - r_medallion + 16, center_y - r_medallion + 16, center_x + r_medallion - 16, center_y + r_medallion - 16],
                 outline=(255, 235, 140, 255), width=4)
                 
    # 24 bead studs
    for i in range(24):
        ang = i * 2.0 * math.pi / 24.0
        bx = center_x + (r_medallion - 8) * math.cos(ang)
        by = center_y + (r_medallion - 8) * math.sin(ang)
        draw.ellipse([bx - 6, by - 6, bx + 6, by + 6], fill=(255, 240, 160, 255))
        
    # Central Emblem "三国" in Seal/KaiTi calligraphy
    font_large = ImageFont.truetype(FONT_KAITI, 180)
    for idx, char in enumerate(["三", "国"]):
        bbox = font_large.getbbox(char)
        cw = bbox[2] - bbox[0]
        ch = bbox[3] - bbox[1]
        cy = center_y - 120 + idx * 170 - ch / 2.0 - bbox[1]
        cx = center_x - cw / 2.0 - bbox[0]
        draw.text((cx + 4, cy + 6), char, font=font_large, fill=(0, 0, 0, 220))
        draw.text((cx, cy), char, font=font_large, fill=(255, 225, 120, 255))
        draw.text((cx - 2, cy - 2), char, font=font_large, fill=(255, 255, 255, 140))
        
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path, format="PNG")
    print(f"Generated card back: {out_path.name}")

# ==============================================================================
# 6. STAT & SKILL ICONS (11 items, 128x128)
# ==============================================================================

ICON_STYLES = {
    "stat_at": ("攻", "#d32f2f", "#5f0909", "swords"),
    "stat_hp": ("兵", "#388e3c", "#144217", "heart"),
    "stat_ap": ("令", "#f57c00", "#5d2d00", "coin"),
    "skill_phys": ("斩", "#c62828", "#4e0d0d", "slash"),
    "skill_magic": ("术", "#6a1b9a", "#28073d", "magic"),
    "skill_heal": ("愈", "#2e7d32", "#0f3b13", "heal"),
    "skill_guard": ("御", "#1565c0", "#082b54", "guard"),
    "skill_boost": ("进", "#fbc02d", "#5a4305", "boost"),
    "skill_confuse": ("乱", "#7b1fa2", "#2d063d", "confuse"),
    "skill_break": ("破", "#d84315", "#4a1403", "break"),
    "skill_ap": ("筹", "#ef6c00", "#542400", "ap_gain")
}

def generate_small_icon(key: str, out_path: Path):
    char, inner_col, outer_col, motif = ICON_STYLES[key]
    S = 256
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    center = S / 2.0
    
    # Shadow
    sdraw = ImageDraw.Draw(img)
    sdraw.ellipse([center - 110, center - 110 + 10, center + 110, center + 110 + 10], fill=(0, 0, 0, 160))
    img = img.filter(ImageFilter.GaussianBlur(8))
    draw = ImageDraw.Draw(img)
    
    # Gold rim
    draw.ellipse([center - 112, center - 112, center + 112, center + 112], fill=(212, 165, 54, 255), outline=(120, 85, 18, 255), width=3)
    draw.ellipse([center - 100, center - 100, center + 100, center + 100], fill=(255, 235, 140, 255))
    
    # Inner colored disc
    bg_inner = hex_to_rgb(inner_col)
    bg_outer = hex_to_rgb(outer_col)
    disc = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    dpixels = disc.load()
    r_disc = 92
    for y in range(S):
        dy = y - center
        for x in range(S):
            dx = x - center
            dist = math.sqrt(dx * dx + dy * dy)
            if dist <= r_disc:
                t = min(1.0, dist / r_disc)
                col = lerp_color(bg_inner, bg_outer, t)
                dpixels[x, y] = (col[0], col[1], col[2], 255)
    img.alpha_composite(disc)
    draw = ImageDraw.Draw(img)
    
    # Character in gold leaf KaiTi
    font = ImageFont.truetype(FONT_KAITI, 120)
    bbox = font.getbbox(char)
    bw = bbox[2] - bbox[0]
    bh = bbox[3] - bbox[1]
    cx = center - bw / 2.0 - bbox[0]
    cy = center - bh / 2.0 - bbox[1] - 4
    
    draw.text((cx + 2, cy + 3), char, font=font, fill=(0, 0, 0, 210))
    draw.text((cx, cy), char, font=font, fill=(255, 245, 190, 255))
    draw.text((cx - 1, cy - 1), char, font=font, fill=(255, 255, 255, 130))
    
    final_img = img.resize((128, 128), Image.LANCZOS)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    final_img.save(out_path, format="PNG")

# ==============================================================================
# MAIN RUNNER
# ==============================================================================

def main():
    print("Generating UI Art Assets...")
    
    # 1. Badges
    print("\n--- 1. Troop Badges ---")
    badge_godot = ART / "badges"
    badge_pics = PICS_SRC / "ui" / "badges"
    for k in BADGE_STYLES:
        generate_badge(k, badge_godot / f"{k}.png")
        generate_badge(k, badge_pics / f"{k}.png")
    print(f"Built 9 badges -> {badge_godot}")
    
    # 2. Map Icons
    print("\n--- 2. Map Square Icons ---")
    map_godot = ART / "map" / "icons"
    map_pics = PICS_SRC / "map" / "icons"
    for k in MAP_ICON_STYLES:
        generate_map_icon(k, map_godot / f"{k}.png")
        generate_map_icon(k, map_pics / f"{k}.png")
    print(f"Built 15 map icons -> {map_godot}")
    
    # 3. Commander Token
    print("\n--- 3. Commander Token ---")
    token_godot = ART / "map" / "token_lord.png"
    token_pics = PICS_SRC / "map" / "token_lord.png"
    generate_commander_token(token_godot)
    generate_commander_token(token_pics)
    print(f"Built commander token -> {token_godot}")
    
    # 4. Relics
    print("\n--- 4. Relic Icons ---")
    relic_godot = ART / "relics"
    relic_pics = PICS_SRC / "relics"
    for k in RELIC_MOTIFS:
        generate_relic(k, relic_godot / f"{k}.png")
        generate_relic(k, relic_pics / f"{k}.png")
    print(f"Built 36 relic icons -> {relic_godot}")
    
    # 5. Card Back
    print("\n--- 5. Card Back ---")
    back_godot = ART / "frames" / "card_back.png"
    back_pics = PICS_SRC / "frames" / "card_back.png"
    generate_card_back(back_godot)
    generate_card_back(back_pics)
    print(f"Built card back -> {back_godot}")
    
    # 6. Stat & Skill Icons
    print("\n--- 6. Stat & Skill Icons ---")
    icons_godot = ART / "icons"
    icons_pics = PICS_SRC / "ui" / "icons"
    for k in ICON_STYLES:
        generate_small_icon(k, icons_godot / f"{k}.png")
        generate_small_icon(k, icons_pics / f"{k}.png")
    print(f"Built 11 stat & skill icons -> {icons_godot}")

if __name__ == "__main__":
    main()
