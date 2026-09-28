"""Generate Chapter 2 (讨伐董卓) map background in traditional Chinese landscape style (浅绛/青绿山水).
Creates an atmospheric, organic scroll landscape with:
- Warm Xuan paper ground (宣纸底色)
- Layered ink mountain ridges (远山与层峦)
- Winding roads and river trails with soft organic contours
- Sishui Pass mountain defile and watchtowers
- Camp palisades and banners
- Desolate rocky wasteland of Hulao Pass
- Distant burning Luoyang with smoke and sunset ember glow
"""
import math
import random
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
OUT_SOURCE = ROOT / "pics" / "source" / "map" / "bg_taodong.jpg"
OUT_GODOT = ROOT / "godot" / "data" / "art" / "map" / "taodong.jpg"

def lerp_color(c1: tuple, c2: tuple, t: float) -> tuple:
    return tuple(int(a + (b - a) * t) for a, b in zip(c1, c2))

def build_organic_map():
    W = 3200
    H = 800
    
    # Base antique Xuan paper
    base = Image.new("RGB", (W, H), (242, 237, 222))
    
    # 1. Subtle Paper Grain & Color Washes
    wash = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    wpixels = wash.load()
    
    for y in range(H):
        ny = y / float(H)
        for x in range(W):
            nx = x / float(W)
            
            # Regional color transition
            if nx < 0.28:
                # Southern hills (faint sage & olive green wash)
                t = nx / 0.28
                col = lerp_color((210, 222, 198), (225, 220, 195), t)
            elif nx < 0.55:
                # River & Sishui valley (pale river ochre)
                t = (nx - 0.28) / 0.27
                col = lerp_color((225, 220, 195), (220, 214, 188), t)
            elif nx < 0.78:
                # Hulao dry plains (earthen bronze ochre)
                t = (nx - 0.55) / 0.23
                col = lerp_color((220, 214, 188), (225, 208, 180), t)
            else:
                # Burning Luoyang (twilight amber rose & smoke)
                t = (nx - 0.78) / 0.22
                col = lerp_color((225, 208, 180), (235, 192, 172), t)
                
            # Vertical gradient: lighter sky towards top
            v = 0.90 + 0.10 * (ny ** 0.8)
            wpixels[x, y] = (int(col[0] * v), int(col[1] * v), int(col[2] * v), 255)
            
    base.paste(wash.convert("RGB"))
    
    # 2. Layered Ink Mountains in Traditional Shanshui Style
    random.seed(184)
    shanshui = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shanshui)
    
    def generate_mountain_ridge(y_base, h_scale, freq, octaves=3):
        pts = [(0, y_base)]
        for x in range(0, W + 40, 16):
            h = 0
            amp = h_scale
            f = freq
            for o in range(octaves):
                h += math.sin(x * f + o * 1.7) * amp
                amp *= 0.45
                f *= 2.1
            pts.append((x, max(30, y_base + h)))
        pts.append((W, H))
        pts.append((0, H))
        return pts

    # Layer 1: Distant ethereal peaks (light blue-grey mist)
    sdraw.polygon(generate_mountain_ridge(140, 80, 0.0025), fill=(160, 175, 172, 70))
    # Layer 2: Middle mountain range (pale sage/olive ink)
    sdraw.polygon(generate_mountain_ridge(190, 70, 0.004), fill=(135, 150, 140, 95))
    # Layer 3: Closer ridges with distinct peaks
    sdraw.polygon(generate_mountain_ridge(240, 60, 0.006), fill=(110, 125, 110, 120))
    
    shanshui = shanshui.filter(ImageFilter.GaussianBlur(3))
    base.paste(shanshui, (0, 0), shanshui)
    
    # 3. Winding River (汜水) across x: 800 to 1250
    draw = ImageDraw.Draw(base)
    river_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    rdraw = ImageDraw.Draw(river_layer)
    
    for y in range(0, H, 12):
        # Organic curved river channel
        rx = 920 + math.sin(y * 0.007) * 90 + (y / float(H)) * 140
        rw = 65 + math.sin(y * 0.015) * 15 + (y / float(H)) * 55
        rdraw.ellipse([rx - rw/2, y - 18, rx + rw/2, y + 18], fill=(175, 198, 202, 220))
        rdraw.ellipse([rx - rw/2 + 8, y - 12, rx + rw/2 - 8, y + 12], fill=(195, 218, 222, 240))
        
    river_layer = river_layer.filter(ImageFilter.GaussianBlur(2))
    base.paste(river_layer, (0, 0), river_layer)
    draw = ImageDraw.Draw(base)
    
    # Stone arch bridge across the river at y: 440
    draw.polygon([(960, 420), (1070, 420), (1070, 465), (960, 465)], fill=(150, 145, 135, 255), outline=(90, 85, 80, 255), width=2)
    draw.pieslice([995, 435, 1035, 475], 180, 360, fill=(195, 218, 222, 255), outline=(90, 85, 80, 255), width=2)
    
    # 4. Three Organic Road Belts (Upper, Middle, Lower)
    roads_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    roaddraw = ImageDraw.Draw(roads_layer)
    
    for base_y, width, main_col, sub_col in [
        (230, 42, (220, 208, 185, 220), (200, 188, 165, 240)),
        (450, 52, (215, 202, 178, 230), (195, 182, 158, 250)),
        (650, 40, (220, 208, 185, 220), (200, 188, 165, 240))
    ]:
        road_pts = []
        for x in range(0, W, 20):
            dy = math.sin(x * 0.004) * 38 + math.cos(x * 0.011) * 14
            road_pts.append((x, base_y + dy))
        for i in range(len(road_pts) - 1):
            p1 = road_pts[i]
            p2 = road_pts[i+1]
            roaddraw.line([p1, p2], fill=main_col, width=width)
            roaddraw.line([p1, p2], fill=sub_col, width=width - 12)
            
    roads_layer = roads_layer.filter(ImageFilter.GaussianBlur(3))
    base.paste(roads_layer, (0, 0), roads_layer)
    draw = ImageDraw.Draw(base)
    
    # 5. Natural ink landscape features:
    # A) Pine groves and willow groves
    for tx, ty in [
        (120, 320), (220, 160), (320, 520), (460, 340), (280, 680), (160, 500),
        (580, 220), (680, 580), (820, 280), (740, 650),
        (1220, 340), (1280, 580), (1450, 200), (1750, 660),
        (1900, 300), (2050, 580), (2180, 220), (2320, 640)
    ]:
        for ox, oy, sz in [(0, 0, 38), (-16, 12, 30), (18, 14, 32)]:
            px, py = tx + ox, ty + oy
            draw.polygon([(px, py - sz), (px + sz*0.5, py), (px - sz*0.5, py)], fill=(45, 75, 55, 255), outline=(25, 45, 30, 255), width=1)
            draw.rectangle([px - 3, py, px + 3, py + 12], fill=(85, 55, 30, 255))
            
    # B) Sishui Pass mountain fortress (x: 1100, y: 350)
    # Natural rock walls and traditional gatehouse
    draw.polygon([(1080, 260), (1180, 260), (1160, 480), (1090, 480)], fill=(120, 115, 110, 255), outline=(65, 60, 55, 255), width=2)
    # Arch gate
    draw.pieslice([(1110, 390), (1150, 480)], 180, 360, fill=(40, 35, 30, 255))
    # Chinese tiled roof gatehouse
    draw.polygon([(1065, 260), (1195, 260), (1170, 225), (1090, 225)], fill=(130, 45, 35, 255), outline=(60, 25, 20, 255), width=2)
    draw.polygon([(1085, 225), (1175, 225), (1155, 195), (1105, 195)], fill=(150, 55, 45, 255), outline=(60, 25, 20, 255), width=2)
    
    # C) Sun Jian Camp (孙坚大营 x: 1400 to 1750)
    # Organic palisade wooden stakes
    for sx in range(1420, 1780, 18):
        sy = 300 + math.sin(sx * 0.02) * 10
        draw.line([(sx, sy), (sx, sy + 30)], fill=(110, 75, 40, 255), width=4)
        draw.polygon([(sx - 3, sy), (sx + 3, sy), (sx, sy - 8)], fill=(130, 90, 50, 255))
        
    # War tents with organic folds
    for tent_x, tent_y in [(1480, 360), (1580, 350), (1680, 370), (1520, 480), (1640, 470)]:
        draw.polygon([(tent_x - 30, tent_y + 22), (tent_x + 30, tent_y + 22), (tent_x, tent_y - 25)],
                     fill=(238, 232, 218, 255), outline=(135, 105, 75, 255), width=2)
        draw.line([(tent_x, tent_y - 25), (tent_x, tent_y + 22)], fill=(155, 45, 35, 255), width=3)
        
    # Commander Banner (Sun / Tiger red banner)
    draw.line([(1600, 340), (1600, 260)], fill=(55, 40, 25, 255), width=4)
    draw.polygon([(1600, 260), (1665, 280), (1600, 300)], fill=(210, 30, 30, 255), outline=(255, 215, 60, 255), width=2)
    
    # D) Hulao Pass barren rocks and broken spears (x: 1950 to 2400)
    for rx, ry, rw, rh in [(1980, 340, 60, 35), (2120, 480, 80, 45), (2260, 320, 90, 55), (2060, 620, 70, 40), (2220, 520, 85, 45)]:
        draw.polygon([(rx - rw/2, ry + rh/2), (rx - rw/4, ry - rh/2), (rx + rw/3, ry - rh/3), (rx + rw/2, ry + rh/2)],
                     fill=(140, 130, 120, 255), outline=(80, 75, 70, 255), width=2)
        draw.line([(rx - rw/4, ry - rh/2), (rx, ry + rh/2)], fill=(100, 95, 88, 255), width=2)
        
    # E) Burning Luoyang (x: 2650 to 3200)
    # Distant towering city walls and gates
    draw.rectangle([2700, 140, 3180, 660], fill=(115, 95, 90, 255), outline=(55, 45, 40, 255), width=4)
    # City gate
    draw.pieslice([(2760, 340), (2840, 500)], 180, 360, fill=(35, 25, 20, 255))
    draw.rectangle([2760, 420, 2840, 500], fill=(35, 25, 20, 255))
    # Multi-tier roof towers
    draw.polygon([(2720, 260), (2880, 260), (2840, 210), (2760, 210)], fill=(110, 45, 35, 255), outline=(50, 20, 15, 255), width=2)
    draw.polygon([(2740, 210), (2860, 210), (2830, 170), (2770, 170)], fill=(125, 50, 38, 255), outline=(50, 20, 15, 255), width=2)
    
    # Glowing Fire and Smoke
    fire = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    fdraw = ImageDraw.Draw(fire)
    for fx in range(2750, 3200, 30):
        fy = 170 + math.sin(fx * 0.04) * 35
        fdraw.ellipse([fx - 65, fy - 65, fx + 65, fy + 65], fill=(255, 110, 20, 130))
        fdraw.ellipse([fx - 35, fy - 35, fx + 35, fy + 35], fill=(255, 200, 50, 160))
        # Smoke pillars
        for s in range(5):
            sx = fx + s * 12 - 25
            sy = fy - 60 - s * 35
            sr = 45 + s * 16
            fdraw.ellipse([sx - sr, sy - sr, sx + sr, sy + sr], fill=(45, 35, 40, 120 - s * 20))
            
    fire = fire.filter(ImageFilter.GaussianBlur(14))
    base.paste(fire, (0, 0), fire)
    
    # 6. Chinese Cloud / Mist Vignette (top & bottom edges)
    clouds = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cdraw = ImageDraw.Draw(clouds)
    for cx in range(0, W, 70):
        cy_top = math.sin(cx * 0.007) * 28 + 35
        cdraw.ellipse([cx - 130, cy_top - 65, cx + 130, cy_top + 65], fill=(245, 241, 230, 130))
        cy_bot = H - 35 + math.cos(cx * 0.007) * 25
        cdraw.ellipse([cx - 140, cy_bot - 65, cx + 140, cy_bot + 65], fill=(245, 241, 230, 120))
        
    clouds = clouds.filter(ImageFilter.GaussianBlur(24))
    base.paste(clouds, (0, 0), clouds)
    
    OUT_SOURCE.parent.mkdir(parents=True, exist_ok=True)
    OUT_GODOT.parent.mkdir(parents=True, exist_ok=True)
    base.save(OUT_SOURCE, quality=90)
    
    game_img = base.resize((2400, 800), Image.LANCZOS)
    game_img.save(OUT_GODOT, quality=90)
    print(f"Generated organic Chapter 2 map background:\n  -> {OUT_SOURCE}\n  -> {OUT_GODOT}")

if __name__ == "__main__":
    build_organic_map()
