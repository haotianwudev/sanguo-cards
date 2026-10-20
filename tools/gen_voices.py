"""Battle voice lines: build godot/data/audio/voice/*.ogg from the `voices` table in godot/data/audio.json.

Each line is synthesised with edge-tts (voice / rate / pitch from the profile's `tts`, or the line's own) — or, for a
line with `"src": "<file>.wav"`, taken from that recording in audio_src/voice/ (made elsewhere, e.g. MiniMax) — trimmed to
its onset, peak-normalised and saved as mono OGG Vorbis. The file name is <profile>_<moment>_<hash>, the hash taken
over voice|rate|pitch|text — `Sfx` in scripts/audio/sfx.gd computes the same name, so there is no manifest: change a
line or its voice and it gets a new file. Existing files are kept (rerunning is cheap).

    python tools/gen_voices.py            # generate whatever is missing
    python tools/gen_voices.py --check    # exit 1 if a line has no file (CI / tests)
    python tools/gen_voices.py --prune    # also delete voice files no line uses any more

Then run Godot with --import so the new .ogg files are registered.
"""
import argparse
import asyncio
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIO_JSON = ROOT / "godot/data/audio.json"
SRC_DIR = ROOT / "audio_src/voice"  # recorded / externally generated lines (kept out of godot/ so they don't ship)
VOICE_DIR = ROOT / "godot/data/audio/voice"
MOMENTS = ("attack", "ultimate", "heal", "roar", "intro")


def voice_lines(data: dict) -> list[tuple[str, str, str, list[str] | str]]:
    """[(profile, moment, text, [voice, rate, pitch] or "src.wav"), ...] for every line in the table."""
    out = []
    for prof, p in data.get("voices", {}).items():
        for moment in MOMENTS:
            for line in p.get(moment, []):
                text = line if isinstance(line, str) else line["text"]
                if isinstance(line, dict) and "src" in line:
                    out.append((prof, moment, text, line["src"]))
                    continue
                tts = p["tts"] if isinstance(line, str) else line.get("tts", p["tts"])
                out.append((prof, moment, text, list(tts)))
    return out


def file_name(prof: str, moment: str, text: str, tts: list[str] | str) -> str:
    if isinstance(tts, str):  # a recording: the game file is named after it
        return Path(tts).stem + ".ogg"
    h = hashlib.md5("|".join([*tts, text]).encode("utf-8")).hexdigest()[:10]
    return f"{prof}_{moment}_{h}.ogg"


def _ffmpeg() -> str:
    import imageio_ffmpeg
    return imageio_ffmpeg.get_ffmpeg_exe()


def _trim(pcm, sr: int = 44100):
    ## cut the silence before the onset (so the shout lands on the hit) and after the tail, peak-normalise to ~-0.8 dBFS
    import numpy as np
    peak = np.max(np.abs(pcm)) if len(pcm) else 0
    if peak == 0:
        return pcm
    idx = np.where(np.abs(pcm) >= peak * 0.05)[0]
    start, end = max(0, idx[0] - int(sr * 0.001)), min(len(pcm), idx[-1] + int(sr * 0.12))
    out = pcm[start:end].astype(np.float64) * (29500.0 / peak)
    fade = int(sr * 0.002)
    if len(out) > 2 * fade:
        out[:fade] *= np.linspace(0, 1, fade)
        out[-fade:] *= np.linspace(1, 0, fade)
    return np.clip(out, -32767, 32767).astype(np.int16)


async def _synth(text: str, tts: list[str] | str, out: Path) -> None:
    import numpy as np
    ff = _ffmpeg()
    if isinstance(tts, str):  # a recording in audio_src/voice
        audio = (SRC_DIR / tts).read_bytes()
    else:
        import edge_tts
        voice, rate, pitch = tts
        mp3 = bytearray()
        async for chunk in edge_tts.Communicate(text, voice, rate=rate, pitch=pitch).stream():
            if chunk["type"] == "audio":
                mp3.extend(chunk["data"])
        audio = bytes(mp3)
    raw = subprocess.run([ff, "-y", "-i", "pipe:0", "-f", "s16le", "-ac", "1", "-ar", "44100", "pipe:1"],
                         input=audio, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, check=True).stdout
    pcm = _trim(np.frombuffer(raw, dtype=np.int16))
    subprocess.run([ff, "-y", "-f", "s16le", "-ac", "1", "-ar", "44100", "-i", "pipe:0", "-c:a", "libvorbis", "-q:a", "5", str(out)],
                   input=pcm.tobytes(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    print(f"  {out.name}  {text}  ({len(pcm) / 44100:.2f}s)")


async def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="only report missing files; exit 1 if any")
    ap.add_argument("--prune", action="store_true", help="delete voice files that no line uses")
    args = ap.parse_args()
    data = json.loads(AUDIO_JSON.read_text(encoding="utf-8"))
    lines = voice_lines(data)
    wanted = {file_name(*l[:3], l[3]): l for l in lines}
    VOICE_DIR.mkdir(parents=True, exist_ok=True)
    missing = [n for n in wanted if not (VOICE_DIR / n).exists()]
    if args.check:
        for n in missing:
            print(f"missing {n}: {wanted[n][0]} / {wanted[n][1]} 「{wanted[n][2]}」")
        return 1 if missing else 0
    for n in missing:
        prof, moment, text, tts = wanted[n]
        await _synth(text, tts, VOICE_DIR / n)
    if args.prune:
        for f in VOICE_DIR.glob("*.ogg"):
            if f.name not in wanted:
                f.unlink()
                imp = f.with_name(f.name + ".import")
                if imp.exists():
                    imp.unlink()
                print(f"  pruned {f.name}")
    print(f"{len(wanted)} voice lines, {len(missing)} generated")
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
