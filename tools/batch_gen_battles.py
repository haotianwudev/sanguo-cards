"""Batch generate all remaining battle CGs using Nano Banana 2 Lite with references and auto-ingest."""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import art_prompts
from art_gen import generate_image_atlas, load_api_key, upload_media

PICS = ROOT / "pics"
SRC_GEN = PICS / "source" / "generals"
SRC_SOL = PICS / "source" / "soldiers"
INBOX = PICS / "inbox"

REF_MAP = {
    "c5_qinbing": SRC_SOL / "xiliang_bing.jpg",
    "c7_chenlan": SRC_GEN / "chenlan.jpg",
    "jx_gongshou": SRC_SOL / "jingzhou_gong.jpg",
    "jx_jinfan": SRC_SOL / "jinfan_zei.jpg",
    "jx_zongzei": SRC_SOL / "zongzei.jpg",
    "jx_shuijun": SRC_SOL / "jingzhou_bu.jpg",
    "hn_leichen": SRC_GEN / "leibo.jpg",
    "hn_zhangxun": SRC_GEN / "zhangxun.jpg",
    "bh_jz_scout": SRC_SOL / "cav_n.jpg",
    "c5_zhangji": SRC_GEN / "zhangji.jpg",
    "bh_jz_inf": SRC_SOL / "inf_n.jpg",
    "huangjin_vanguard": SRC_SOL / "huangjin.jpg",
    "hs_jizhou_nu": SRC_SOL / "jizhou_nu.jpg",
    "hs_jizhou_buzhu": SRC_SOL / "inf_n.jpg",
    "hs_jizhou_qibing": SRC_SOL / "cav_n.jpg",
    "shanzei_scout": SRC_SOL / "bandit.jpg",
    "c6_xianzhen": SRC_SOL / "xianzhen.jpg",
    "jx_bubing": SRC_SOL / "jingzhou_bu.jpg",
    "hs_jizhou_qiangbing": SRC_SOL / "jizhou_ji.jpg",
    "hs_chunyuqiong": SRC_GEN / "chunyuqiong.jpg",
    "hs_jieqiao_scout": SRC_SOL / "cav_n.jpg",
    "c4_liumin": SRC_SOL / "minfu.jpg",
    "c5_fanchou": SRC_GEN / "fanchou.jpg",
    "c5_huzhen": SRC_GEN / "huzhen.jpg",
    "bh_jiang_trap": SRC_SOL / "bandit.jpg",
    "bh_jz_spear": SRC_SOL / "jizhou_ji.jpg",
    "bh_hj_duzhan": SRC_SOL / "huangjin.jpg",
    "c6_shaoka": SRC_SOL / "inf_n.jpg",
    "c6_zhangxiu": SRC_GEN / "zhangxiu.jpg",
    "c7_qiaorui": SRC_GEN / "qiaorui.jpg",
    "c7_leibo": SRC_GEN / "leibo.jpg",
    "jx_nushou": SRC_SOL / "caifu_nu.jpg",
    "jx_ganning": SRC_GEN / "ganning.jpg",
}


def build_full_prompt(key: str, desc: str) -> str:
    return (
        f"横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG首领战立绘底图：【{key}】。"
        f"参考兰斯10画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，无文字无UI。"
        f"画面核心与场景：{desc}。"
        f"构图规范：横版 16:9 比例，敌人居中高大对峙，头脸位于上方30%-40%区域，自然展现开阔战斗场景地貌，无需刻意留白。"
    )


def main() -> None:
    api_key = load_api_key()
    art_cfg = json.loads((PICS / "art.json").read_text("utf-8"))
    installed = set(art_cfg.get("battles", {}).keys())

    missing = [k for k in art_prompts.BATTLES.keys() if k not in installed]
    print(f"=== Total missing battle CGs to generate: {len(missing)} ===")

    uploaded_cache: dict[str, str] = {}
    INBOX.mkdir(parents=True, exist_ok=True)

    success_count = 0
    fail_count = 0

    import subprocess

    for idx, key in enumerate(missing, 1):
        raw_desc = art_prompts.BATTLES.get(key, "")
        prompt = build_full_prompt(key, raw_desc)
        ref_file = REF_MAP.get(key)

        ref_urls = None
        if ref_file and ref_file.exists():
            ref_str = str(ref_file)
            if ref_str not in uploaded_cache:
                print(f"[{idx}/{len(missing)}] Uploading reference: {ref_file.name}...")
                try:
                    uploaded_cache[ref_str] = upload_media(api_key, ref_file)
                except Exception as e:
                    print(f"  Warning: upload failed: {e}")
            if ref_str in uploaded_cache:
                ref_urls = [uploaded_cache[ref_str]]

        print(f"[{idx}/{len(missing)}] Generating: {key} (ref: {ref_file.name if ref_file else 'None'})...")

        retries = 2
        img_url = None
        while retries > 0:
            try:
                img_url = generate_image_atlas(
                    api_key=api_key,
                    prompt=prompt,
                    model="google/nano-banana-2-lite/edit-developer" if ref_urls else "google/nano-banana-2-lite/text-to-image-developer",
                    ref_urls=ref_urls,
                )
                break
            except Exception as e:
                print(f"  Error generating {key}: {e}")
                retries -= 1
                if retries > 0:
                    time.sleep(3)

        if not img_url:
            print(f"✗ Failed to generate {key} after retries")
            fail_count += 1
            continue

        out_path = INBOX / f"{key}.jpg"
        import urllib.request
        req = urllib.request.Request(img_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as resp, open(out_path, "wb") as f:
            f.write(resp.read())

        print(f"  Saved to {out_path.name}, ingesting into game...")
        cmd = [sys.executable, str(ROOT / "tools" / "art_ingest.py"), "add", str(out_path), key, "--kind", "battle"]
        try:
            subprocess.check_call(cmd)
            success_count += 1
        except Exception as e:
            print(f"  Ingest failed: {e}")
            fail_count += 1

        # Periodic flush every 10 images
        if success_count > 0 and success_count % 10 == 0:
            print(f"Flushing docs at {success_count} images...")
            subprocess.call([sys.executable, str(ROOT / "tools" / "art_ingest.py"), "flush"])

        time.sleep(1)

    print(f"\n=== Finished batch! Success: {success_count}, Failed: {fail_count} ===")
    print("Flushing final docs...")
    subprocess.call([sys.executable, str(ROOT / "tools" / "art_ingest.py"), "flush"])


if __name__ == "__main__":
    main()
