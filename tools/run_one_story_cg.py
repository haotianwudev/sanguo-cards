"""Generate end_tianming story CG with Gemini Developer and 2 reference images."""
from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path("F:/workspace/sanguo-cards")
sys.path.insert(0, str(ROOT / "tools"))
from art_gen import load_api_key, upload_media, generate_image_atlas

PICS = ROOT / "pics"
SRC_GEN = PICS / "source" / "generals"

def generate_end_tianming():
    api_key = load_api_key()
    key = "end_tianming"
    
    ref_files = [
        SRC_GEN / "lord.jpg",
        SRC_GEN / "lord_north.jpg",
    ]
    
    print(f"Uploading references for {key}...")
    ref_urls = []
    for f in ref_files:
        if not f.exists():
            raise FileNotFoundError(f"Reference file {f} does not exist!")
        url = upload_media(api_key, f)
        print(f"  {f.name} -> {url}")
        ref_urls.append(url)
        
    prompt = (
        "16:9 横版故事剧情事件插画，视觉小说真结局终章象征画 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。\n"
        "场景为朝阳初升的古都洛阳高台，沐浴在万道耀眼的金色晨光中。\n"
        "画面中央近景（青石台基之上）：\n"
        "1. 一柄厚重大气、刀背宽阔的古锭刀（参考图1武器），与一杆修长矫健的白蜡杆长枪（参考图2武器），背靠背交叉深深插在同一方古朴平整的青石地面上。\n"
        "2. 刀柄末端垂挂的红锦飘带与长枪颈部的鲜红缨结，在扑面而来的朝阳晨风中亲密缠绕在一起，象征南北两线宿命归一与天下大定。\n"
        "画面中远景：高台一侧的高耸旗杆上，两面战旗在晨风中并排齐平飘扬；高台下方远景是晨曦金光照耀下的万里中原山河与宏伟壮观的洛阳城宫阙城郭，壮阔、辉煌、安宁祥和。\n"
        "构图与氛围：横版 16:9，静物兵刃屹立中央，金色初升旭日照亮万里神州，不见人物，充满大一统史诗感的真结局视觉小说名场面。画面绝对纯净，严禁任何额外乱码文字、严禁英文字母、严禁拟声词、严禁气泡对话框、严禁UI界面。"
    )
    
    print("Generating with google/nano-banana-2/reference-to-image-developer...")
    img_url = generate_image_atlas(
        api_key=api_key,
        prompt=prompt,
        model="google/nano-banana-2/reference-to-image-developer",
        ref_urls=ref_urls
    )
    print(f"Generated URL: {img_url}")
    
    out_dir = Path("C:/Users/lswht/.gemini/antigravity/brain/0bba7533-88ba-474a-a155-82646904b457")
    out_path = out_dir / f"{key}_gemini.jpg"
    
    req = urllib.request.Request(img_url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as resp, open(out_path, "wb") as f:
        f.write(resp.read())
        
    print(f"Saved generated image to: {out_path}")

if __name__ == "__main__":
    generate_end_tianming()
