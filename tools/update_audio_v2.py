"""Audio update v2:
1. Replace hit sounds with punchy, non-piercing, layered impacts (Kenney punch + blade chop/slice), trimmed to exact 0ms onset.
2. Trim all Chinese battle shouts (male & female, normal & ultimate) to exact 0ms onset (eliminating 400ms/70ms/25ms pre-silence).
3. Cut battle BGM directly to the 48.1s orchestral climax (no quiet prelude).
"""
import io
import os
import subprocess
import wave
from pathlib import Path
import numpy as np
import requests
import imageio_ffmpeg

FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
ROOT = Path(__file__).resolve().parents[1]
SFX_DIR = ROOT / "godot/data/audio/sfx"
BGM_DIR = ROOT / "godot/data/audio/bgm"


def pcm_from_raw(data_bytes: bytes, sr: int = 44100) -> np.ndarray:
    cmd = [FFMPEG, "-i", "pipe:0", "-f", "s16le", "-ac", "1", "-ar", str(sr), "pipe:1"]
    out = subprocess.run(cmd, input=data_bytes, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL).stdout
    return np.frombuffer(out, dtype=np.int16)


def trim_to_zero_latency(pcm: np.ndarray, sr: int = 44100, thresh_ratio: float = 0.12) -> np.ndarray:
    peak = np.max(np.abs(pcm))
    if peak == 0:
        return pcm
    thresh = peak * thresh_ratio
    idx = np.where(np.abs(pcm) >= thresh)[0]
    if len(idx) == 0:
        return pcm
    # Start 1ms before the threshold to catch the transient rise smoothly
    start_frame = max(0, idx[0] - int(sr * 0.001))
    trimmed = pcm[start_frame:].copy()
    # 2ms anti-click micro-ramp
    fade_len = int(sr * 0.002)
    if len(trimmed) > fade_len:
        ramp = np.linspace(0, 1, fade_len)
        trimmed[:fade_len] = (trimmed[:fade_len] * ramp).astype(np.int16)
    return trimmed


def save_wav(pcm: np.ndarray, out_path: Path, sr: int = 44100):
    with wave.open(str(out_path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.astype(np.int16).tobytes())
    print(f"Saved: {out_path.name} ({len(pcm)/sr*1000:.1f}ms, {out_path.stat().st_size} bytes)")


def mix_layers(layers, max_len=None):
    if max_len is None:
        max_len = max(len(p) for p, _ in layers)
    mix = np.zeros(max_len, dtype=np.float32)
    for pcm, vol in layers:
        l = min(len(pcm), max_len)
        mix[:l] += pcm[:l].astype(np.float32) * vol
    peak = np.max(np.abs(mix))
    if peak > 32700:
        mix = mix * (32700.0 / peak)
    return mix.astype(np.int16)


def main():
    print("=== 1. Building Non-Piercing, Zero-Latency Punchy Hit Sounds ===")
    kenney_urls = {
        "chop": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/main/addons/kenney%20rpg%20audio/chop.ogg",
        "knife_slice": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/main/addons/kenney%20rpg%20audio/knife_slice.ogg",
        "punch_0": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_punch_heavy_000.ogg",
        "punch_1": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_punch_heavy_001.ogg",
        "punch_2": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_punch_heavy_002.ogg",
        "plate_0": "https://raw.githubusercontent.com/Boyquotes/kenney-impact-sounds-for-godot/main/addons/kenney%20impact%20sounds/impact_plate_heavy_000.ogg",
    }
    headers = {"User-Agent": "Mozilla/5.0"}
    raw_pcms = {}
    for name, url in kenney_urls.items():
        raw_bytes = requests.get(url, headers=headers).content
        pcm = pcm_from_raw(raw_bytes)
        raw_pcms[name] = trim_to_zero_latency(pcm, thresh_ratio=0.12)

    chop = raw_pcms["chop"]
    knife = raw_pcms["knife_slice"]
    punch0 = raw_pcms["punch_0"]
    punch1 = raw_pcms["punch_1"]
    punch2 = raw_pcms["punch_2"]
    plate0 = raw_pcms["plate_0"]

    # hit_1: Solid blade chop + low punch (沉稳利刃入肉与破甲击打，温润有力)
    hit_1 = mix_layers([(chop, 1.0), (punch1, 0.75)])
    save_wav(hit_1, SFX_DIR / "hit_1.wav")

    # hit_2: Heavy body impact / armor crush (扎实拳肉破甲重击)
    hit_2 = mix_layers([(punch0, 1.0), (plate0, 0.45)])
    save_wav(hit_2, SFX_DIR / "hit_2.wav")

    # hit_3: Swift smooth slice (轻灵利刃划斩，无刺耳金属刮擦)
    hit_3 = mix_layers([(knife, 1.0), (chop, 0.35)])
    save_wav(hit_3, SFX_DIR / "hit_3.wav")

    # hit_heavy: Tremendous critical strike (暴击裂甲重击，震撼下潜)
    hit_heavy = mix_layers([(punch0, 1.1), (plate0, 0.7), (chop, 0.9)])
    save_wav(hit_heavy, SFX_DIR / "hit_heavy.wav")

    # slash: Clean counter slash (拔刀反击斩击)
    slash = mix_layers([(knife, 1.0), (punch2, 0.4)])
    save_wav(slash, SFX_DIR / "slash.wav")

    # hit_pierce: Snappy armor pierce (枪尖破空突刺击打)
    hit_pierce = mix_layers([(chop, 0.9), (knife, 0.6)])
    save_wav(hit_pierce, SFX_DIR / "hit_pierce.wav")

    print("\n=== 2. Trimming Voice Shouts to Exact 0ms Onset ===")
    for f in SFX_DIR.glob("shout_*.wav"):
        with wave.open(str(f), "rb") as w:
            data = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16)
            sr = w.getframerate()
        trimmed = trim_to_zero_latency(data, sr=sr, thresh_ratio=0.08)
        save_wav(trimmed, f, sr=sr)

    print("\n=== 3. Cutting Battle Music to Epic Middle Section (No Prelude) ===")
    battle_ogg_path = BGM_DIR / "battle.ogg"
    # Fetch original northerners.ogg to make a clean cut directly from 48.12s
    print("Fetching northerners.ogg for clean climax cut...")
    northerners_url = "https://raw.githubusercontent.com/wesnoth/wesnoth/master/data/core/music/northerners.ogg"
    raw_battle = requests.get(northerners_url, headers=headers).content
    tmp_in = BGM_DIR / "northerners_full.ogg"
    tmp_in.write_bytes(raw_battle)

    # Cut starting from 48.12s with 10ms smooth micro-fade-in
    cmd = [
        FFMPEG, "-y", "-ss", "48.12", "-i", str(tmp_in),
        "-af", "afade=t=in:ss=0:d=0.01",
        "-c:a", "libvorbis", "-b:a", "128k",
        str(battle_ogg_path)
    ]
    res = subprocess.run(cmd, capture_output=True)
    if res.returncode == 0:
        print(f"Saved battle.ogg directly from climax: {battle_ogg_path.stat().st_size} bytes")
    else:
        print("Error cutting battle.ogg:", res.stderr.decode("utf-8", errors="ignore")[:200])

    if tmp_in.exists():
        tmp_in.unlink()

    print("\n=== All Audio Optimization Done! ===")


if __name__ == "__main__":
    main()
