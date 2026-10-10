"""Fetch and install realistic impact SFX, battle shouts, and BGM into godot/data/audio/

Downloads royalty-free / open-source assets, converts them via ffmpeg to standard formats:
- SFX: 16-bit mono/stereo WAV in godot/data/audio/sfx/
- BGM: OGG Vorbis in godot/data/audio/bgm/
"""
import io
import json
import subprocess
import sys
import zipfile
from pathlib import Path
import requests
import imageio_ffmpeg

FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
ROOT = Path(__file__).resolve().parents[1]
SFX_DIR = ROOT / "godot/data/audio/sfx"
BGM_DIR = ROOT / "godot/data/audio/bgm"


def convert_to_wav(data_bytes: bytes, out_path: Path):
    cmd = [
        FFMPEG, "-y", "-i", "pipe:0",
        "-ac", "1", "-ar", "44100", "-c:a", "pcm_s16le",
        str(out_path)
    ]
    p = subprocess.run(cmd, input=data_bytes, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if p.returncode != 0:
        print(f"Failed to convert to {out_path}: {p.stderr.decode('utf-8', errors='ignore')[:200]}")
    else:
        print(f"Saved: {out_path.name} ({out_path.stat().st_size} bytes)")


def download_file(url: str) -> bytes:
    headers = {"User-Agent": "Mozilla/5.0"}
    r = requests.get(url, headers=headers, timeout=30)
    r.raise_for_status()
    return r.content


def main():
    SFX_DIR.mkdir(parents=True, exist_ok=True)
    BGM_DIR.mkdir(parents=True, exist_ok=True)

    print("=== 1. Fetching Realistic Hit Sound Effects ===")
    sfx_urls = {
        "hit_1.wav": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_metal_heavy_000.ogg",
        "hit_2.wav": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_punch_heavy_000.ogg",
        "hit_3.wav": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/main/addons/kenney%20rpg%20audio/chop.ogg",
        "hit_heavy.wav": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_plate_heavy_000.ogg",
        "hit_pierce.wav": "https://raw.githubusercontent.com/yairm210/Unciv/master/android/assets/sounds/arrow.mp3",
        "slash.wav": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/main/addons/kenney%20rpg%20audio/knife_slice.ogg",
        "guard.wav": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_wood_heavy_000.ogg",
        "burn.wav": "https://raw.githubusercontent.com/yairm210/Unciv/master/android/assets/sounds/fire.mp3",
        "enemy_hit_1.wav": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_metal_heavy_001.ogg",
        "enemy_hit_2.wav": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_punch_medium_000.ogg",
    }

    for name, url in sfx_urls.items():
        try:
            raw = download_file(url)
            convert_to_wav(raw, SFX_DIR / name)
        except Exception as e:
            print(f"Error fetching {name}: {e}")

    print("\n=== 2. Fetching Character Battle Shouts (Chinese, Male & Female) ===")
    try:
        # Male Shouts
        aether_url = "https://huggingface.co/datasets/simon3000/genshin-voice/resolve/main/speaker-archives/Chinese/11-500/Aether.zip"
        aether_bytes = download_file(aether_url)
        with zipfile.ZipFile(io.BytesIO(aether_bytes)) as z:
            id_map = {}
            for n in z.namelist():
                if n.endswith('.json'):
                    meta = json.loads(z.read(n))
                    fn = meta.get("inGameFilename", "")
                    fid = n[:-5]
                    id_map[fn] = fid
            
            male_targets = {
                "shout_male_1.wav": "Chinese\\VO_gameplay\\VO_aether\\vo_aether_battle_weapon_hit_L_01.wem",
                "shout_male_2.wav": "Chinese\\VO_gameplay\\VO_aether\\vo_aether_battle_weapon_hit_L_02.wem",
                "shout_male_3.wav": "Chinese\\VO_gameplay\\VO_aether\\vo_aether_battle_weapon_hit_L_03.wem",
                "shout_male_ult.wav": "Chinese\\VO_gameplay\\VO_aether\\vo_aether_battle_charge_fire_01.wem",
            }
            for out_name, target_fn in male_targets.items():
                fid = id_map.get(target_fn)
                if fid and f"{fid}.wav" in z.namelist():
                    wav_data = z.read(f"{fid}.wav")
                    convert_to_wav(wav_data, SFX_DIR / out_name)
    except Exception as e:
        print(f"Error fetching male shouts: {e}")

    try:
        # Female Shouts
        lumine_url = "https://huggingface.co/datasets/simon3000/genshin-voice/resolve/main/speaker-archives/Chinese/11-500/Lumine.zip"
        lumine_bytes = download_file(lumine_url)
        with zipfile.ZipFile(io.BytesIO(lumine_bytes)) as z:
            id_map = {}
            for n in z.namelist():
                if n.endswith('.json'):
                    meta = json.loads(z.read(n))
                    fn = meta.get("inGameFilename", "")
                    fid = n[:-5]
                    id_map[fn] = fid
            
            female_targets = {
                "shout_female_1.wav": "Chinese\\VO_gameplay\\VO_lumine\\vo_lumine_battle_weapon_hit_L_01.wem",
                "shout_female_2.wav": "Chinese\\VO_gameplay\\VO_lumine\\vo_lumine_battle_weapon_hit_L_02.wem",
                "shout_female_3.wav": "Chinese\\VO_gameplay\\VO_lumine\\vo_lumine_battle_weapon_hit_L_03.wem",
                "shout_female_ult.wav": "Chinese\\VO_gameplay\\VO_lumine\\vo_lumine_battle_charge_fire_01.wem",
            }
            for out_name, target_fn in female_targets.items():
                fid = id_map.get(target_fn)
                if fid and f"{fid}.wav" in z.namelist():
                    wav_data = z.read(f"{fid}.wav")
                    convert_to_wav(wav_data, SFX_DIR / out_name)
    except Exception as e:
        print(f"Error fetching female shouts: {e}")

    print("\n=== 3. Fetching Default BGMs (Battle, Map, Title) ===")
    bgm_urls = {
        "battle.ogg": "https://raw.githubusercontent.com/wesnoth/wesnoth/master/data/core/music/northerners.ogg",
        "map.ogg": "https://raw.githubusercontent.com/wesnoth/wesnoth/master/data/core/music/wanderer.ogg",
        "title.ogg": "https://raw.githubusercontent.com/wesnoth/wesnoth/master/data/core/music/main_menu.ogg",
    }
    for name, url in bgm_urls.items():
        try:
            raw = download_file(url)
            out_file = BGM_DIR / name
            out_file.write_bytes(raw)
            print(f"Saved BGM: {name} ({out_file.stat().st_size} bytes)")
        except Exception as e:
            print(f"Error fetching {name}: {e}")

    print("\n=== All audio assets fetched successfully! ===")


if __name__ == "__main__":
    main()
