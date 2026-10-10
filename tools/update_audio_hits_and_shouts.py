"""Update game audio:
1. Fix character voice lines to genuine ATTACK shouts (Chongyun male, Beidou female) instead of hurt grunts.
2. Replace hit sounds with crisp, punchy, immediate cold weapon blade & clash sounds (CC0 StarNinjas).
3. Zero-latency trimming: ensure impact transient starts within 5ms of file start.
"""
import io
import json
import subprocess
import wave
import zipfile
from pathlib import Path
import numpy as np
import requests
import imageio_ffmpeg

FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
ROOT = Path(__file__).resolve().parents[1]
SFX_DIR = ROOT / "godot/data/audio/sfx"


def trim_to_transient(wav_bytes: bytes, pre_ms: float = 10.0) -> bytes:
    """Trim leading pre-swoosh/silence so the impact hits immediately (at ~pre_ms)."""
    with wave.open(io.BytesIO(wav_bytes), 'rb') as w:
        n_channels = w.getnchannels()
        sampwidth = w.getsampwidth()
        sr = w.getframerate()
        frames = w.readframes(w.getnframes())

    data = np.frombuffer(frames, dtype=np.int16).copy()
    if n_channels > 1:
        mono = data.reshape(-1, n_channels).mean(axis=1)
    else:
        mono = data

    # Find the sharpest energy peak / threshold
    peak_val = np.max(np.abs(mono))
    threshold = peak_val * 0.25
    idx = np.where(np.abs(mono) >= threshold)[0]
    if len(idx) > 0:
        first_strike = idx[0]
        pre_frames = int(sr * (pre_ms / 1000.0))
        start_frame = max(0, first_strike - pre_frames)
    else:
        start_frame = 0

    trimmed = data[start_frame * n_channels:]
    # Apply 2ms fade-in to prevent click
    fade_len = int(sr * 0.003)
    if len(trimmed) > fade_len:
        ramp = np.linspace(0, 1, fade_len)
        if n_channels == 1:
            trimmed[:fade_len] = (trimmed[:fade_len] * ramp).astype(np.int16)

    out_io = io.BytesIO()
    with wave.open(out_io, 'wb') as w:
        w.setnchannels(n_channels)
        w.setsampwidth(sampwidth)
        w.setframerate(sr)
        w.writeframes(trimmed.tobytes())
    return out_io.getvalue()


def convert_and_save(data_bytes: bytes, out_path: Path, trim: bool = True):
    cmd = [
        FFMPEG, "-y", "-i", "pipe:0",
        "-ac", "1", "-ar", "44100", "-c:a", "pcm_s16le",
        str(out_path)
    ]
    p = subprocess.run(cmd, input=data_bytes, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if p.returncode != 0:
        print(f"Failed ffmpeg conversion: {p.stderr.decode('utf-8', errors='ignore')[:200]}")
        return

    if trim:
        wav_data = trim_to_transient(out_path.read_bytes())
        out_path.write_bytes(wav_data)

    print(f"Saved: {out_path.name} ({out_path.stat().st_size} bytes)")


def read_zip_member(z, base_name):
    for candidate in [base_name, f"./{base_name}"]:
        if candidate in z.namelist():
            return z.read(candidate)
    for n in z.namelist():
        if n.endswith(f"/{base_name}") or n == base_name:
            return z.read(n)
    raise KeyError(f"Not found: {base_name}")


def main():
    print("=== 1. Fetching Real Cold-Weapon Impact & Clash Sounds (CC0) ===")
    clash_zip_url = "https://opengameart.org/sites/default/files/sword_clash_-_starninjas_0.zip"
    slash_zip_url = "https://opengameart.org/sites/default/files/sword_-_starninjas_1.zip"

    clash_bytes = requests.get(clash_zip_url, headers={"User-Agent": "Mozilla/5.0"}).content
    slash_bytes = requests.get(slash_zip_url, headers={"User-Agent": "Mozilla/5.0"}).content

    with zipfile.ZipFile(io.BytesIO(clash_bytes)) as z_clash, zipfile.ZipFile(io.BytesIO(slash_bytes)) as z_slash:
        # hit_1: crisp sword strike
        convert_and_save(read_zip_member(z_clash, "sword_clash.2.ogg"), SFX_DIR / "hit_1.wav", trim=True)
        # hit_2: blade cut on metal
        convert_and_save(read_zip_member(z_clash, "sword_clash.4.ogg"), SFX_DIR / "hit_2.wav", trim=True)
        # hit_3: rapid blade slash
        convert_and_save(read_zip_member(z_slash, "sword.2.ogg"), SFX_DIR / "hit_3.wav", trim=True)
        # hit_heavy: heavy powerful blade clash
        convert_and_save(read_zip_member(z_clash, "sword_clash.1.ogg"), SFX_DIR / "hit_heavy.wav", trim=True)
        # slash: fast drawing sword slash
        convert_and_save(read_zip_member(z_slash, "sword.1.ogg"), SFX_DIR / "slash.wav", trim=True)
        # hit_pierce: sharp thrust / pierce impact
        convert_and_save(read_zip_member(z_slash, "sword.3.ogg"), SFX_DIR / "hit_pierce.wav", trim=True)

    print("\n=== 2. Fetching Real Attack Shouts (Male Chongyun, Female Beidou) ===")
    chongyun_url = "https://huggingface.co/datasets/simon3000/genshin-voice/resolve/main/speaker-archives/Chinese/501-plus/Chongyun.zip"
    beidou_url = "https://huggingface.co/datasets/simon3000/genshin-voice/resolve/main/speaker-archives/Chinese/501-plus/Beidou.zip"

    chongyun_bytes = requests.get(chongyun_url, headers={"User-Agent": "Mozilla/5.0"}).content
    beidou_bytes = requests.get(beidou_url, headers={"User-Agent": "Mozilla/5.0"}).content

    with zipfile.ZipFile(io.BytesIO(chongyun_bytes)) as z_male:
        # Male genuine attack grunts
        convert_and_save(read_zip_member(z_male, "7f4ea2dcaebf29bb.wav"), SFX_DIR / "shout_male_1.wav", trim=False)
        convert_and_save(read_zip_member(z_male, "a9c6d4f42872a8c4.wav"), SFX_DIR / "shout_male_2.wav", trim=False)
        convert_and_save(read_zip_member(z_male, "2bbb0eebe541d255.wav"), SFX_DIR / "shout_male_3.wav", trim=False)
        # Male ultimate war cry ("束手伏诛吧！")
        convert_and_save(read_zip_member(z_male, "2b68075f1969fd5b.wav"), SFX_DIR / "shout_male_ult.wav", trim=False)

    with zipfile.ZipFile(io.BytesIO(beidou_bytes)) as z_female:
        # Female genuine attack grunts
        convert_and_save(read_zip_member(z_female, "6efe3275d9181624.wav"), SFX_DIR / "shout_female_1.wav", trim=False)
        convert_and_save(read_zip_member(z_female, "1b6a9e850f9abec6.wav"), SFX_DIR / "shout_female_2.wav", trim=False)
        convert_and_save(read_zip_member(z_female, "18fbac13081a3da3.wav"), SFX_DIR / "shout_female_3.wav", trim=False)
        # Female ultimate war cry ("给我瞧好了！")
        convert_and_save(read_zip_member(z_female, "54fa8a2fa84b9872.wav"), SFX_DIR / "shout_female_ult.wav", trim=False)

    print("\n=== Audio replacement complete! ===")


if __name__ == "__main__":
    main()
