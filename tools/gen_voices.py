"""Battle voice lines: build godot/data/audio/voice/*.ogg from the `voices` table in godot/data/audio.json.

Where a line's audio comes from, per profile (or per line):
- edge-tts (default): voice / rate / pitch from the profile's `tts`, or the line's own;
- `"engine": "indextts"`: IndexTTS 2 run locally (checkout at INDEXTTS_DIR, default F:/workspace/tts/index-tts) — it
  speaks in the timbre of the profile's `ref` recording (audio_src/voice/) with the emotion `emo` (8 ints 0..100:
  happy, angry, sad, afraid, disgusted, melancholic, surprised, calm), the line's own `emo` winning;
- `"engine": "minimax"`: MiniMax Speech 2.6 Turbo through AtlasCloud (ATLASCLOUD_API_KEY in .env) speaking the line
  itself — `voice` (a MiniMax voice id), `emotion` (angry / happy / … / auto), `speed` and `pitch` as ints (105 = 1.05×,
  -3 semitones); a line's own `emotion` wins. Used when the local model isn't good enough (no local pass on top);
- `"src": "<file>.wav"` on a line: that recording in audio_src/voice/ as is (made elsewhere, or hand-edited).
A profile's `"tempo"` (int, 82 = 0.82× — slower, same pitch) stretches its generated lines afterwards; it joins the hash.
Every line is trimmed to its onset, peak-normalised and saved as mono OGG Vorbis. The file name is
<profile>_<moment>_<hash> over what made it (voice|rate|pitch|text, indextts|ref|emo|text or
minimax|voice|emotion|speed|pitch|text; a recording keeps its own
name) — `Sfx.voice_file` in scripts/audio/sfx.gd computes the same name, so there is no manifest: change a line, its
voice or its emotion and it gets a new file. Existing files are kept (rerunning is cheap).

    python tools/gen_voices.py            # generate whatever is missing
    python tools/gen_voices.py --check    # exit 1 if a line has no file (CI / tests)
    python tools/gen_voices.py --prune    # also delete voice files no line uses any more

Then run Godot with --import so the new .ogg files are registered.
"""
import argparse
import asyncio
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIO_JSON = ROOT / "godot/data/audio.json"
SRC_DIR = ROOT / "audio_src/voice"  # recordings and reference voices (kept out of godot/ so they don't ship)
VOICE_DIR = ROOT / "godot/data/audio/voice"
INDEXTTS_DIR = Path(os.environ.get("INDEXTTS_DIR", "F:/workspace/tts/index-tts"))
MOMENTS = ("attack", "ultimate", "heal", "roar", "intro")


def voice_lines(data: dict) -> list[tuple[str, str, str, tuple]]:
    """[(profile, moment, text, spec), ...] — spec is ("edge", voice, rate, pitch) / ("indextts", ref, emo) /
    ("minimax", voice, emotion, speed, pitch) / ("src", file)."""
    out = []
    for prof, p in data.get("voices", {}).items():
        for moment in MOMENTS:
            for line in p.get(moment, []):
                d = line if isinstance(line, dict) else {}
                text = line if isinstance(line, str) else line["text"]
                if "src" in d:
                    spec = ("src", d["src"])
                elif p.get("engine", "edge") == "minimax":
                    spec = ("minimax", p["voice"], d.get("emotion", p.get("emotion", "auto")), int(p.get("speed", 100)), int(p.get("pitch", 0)))
                elif p.get("engine", "edge") == "indextts":
                    spec = ("indextts", p["ref"], tuple(int(x) for x in d.get("emo", p.get("emo", [0] * 8))))
                else:
                    spec = ("edge", *d.get("tts", p["tts"]))
                if "src" not in d and int(p.get("tempo", 100)) != 100:
                    spec = (*spec, f"tempo{int(p['tempo'])}")
                out.append((prof, moment, text, spec))
    return out


def file_name(prof: str, moment: str, text: str, spec: tuple) -> str:
    if spec[0] == "src":  # a recording: the game file is named after it
        return Path(spec[1]).stem + ".ogg"
    if spec[0] == "indextts":
        parts = ["indextts", spec[1], ",".join(str(x) for x in spec[2]), *spec[3:]]
    elif spec[0] == "minimax":
        parts = [str(x) for x in spec]
    else:
        parts = list(spec[1:])
    h = hashlib.md5("|".join([*parts, text]).encode("utf-8")).hexdigest()[:10]
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


async def _edge(text: str, voice: str, rate: str, pitch: str) -> bytes:
    import edge_tts
    mp3 = bytearray()
    async for chunk in edge_tts.Communicate(text, voice, rate=rate, pitch=pitch).stream():
        if chunk["type"] == "audio":
            mp3.extend(chunk["data"])
    return bytes(mp3)


def _indextts(jobs: list[tuple[str, tuple, Path]]) -> None:
    ## one subprocess in IndexTTS's own environment for the whole batch (the model loads once)
    if not (INDEXTTS_DIR / "checkpoints").exists():
        sys.exit(f"IndexTTS 2 not found at {INDEXTTS_DIR} (set INDEXTTS_DIR) — needed for {len(jobs)} line(s)")
    job = {"indextts_dir": str(INDEXTTS_DIR), "lines": [
        {"text": text, "ref": str(SRC_DIR / spec[1]), "emo": [x / 100.0 for x in spec[2]], "out": str(out)} for text, spec, out in jobs]}
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8") as f:
        json.dump(job, f, ensure_ascii=False)
    try:
        subprocess.run([sys.executable, "-m", "uv", "run", "--project", str(INDEXTTS_DIR), "python",
                        str(ROOT / "tools/indextts_job.py"), f.name], check=True, cwd=str(INDEXTTS_DIR))
    finally:
        os.unlink(f.name)


def _minimax(text: str, voice: str, emotion: str, speed: int, pitch: int) -> bytes:
    import tempfile as _t
    from voice_audition import _key, minimax
    with _t.TemporaryDirectory() as tmp:
        out = Path(tmp) / "m.wav"
        minimax(text, voice, out, _key(), emotion, speed / 100.0, pitch)
        return out.read_bytes()


def _tempo(spec: tuple) -> int:
    return int(spec[-1][5:]) if isinstance(spec[-1], str) and spec[-1].startswith("tempo") else 100


def _encode(audio: bytes, text: str, out: Path, tempo: int = 100) -> None:
    import numpy as np
    ff = _ffmpeg()
    af = ["-af", f"atempo={tempo / 100.0}"] if tempo != 100 else []
    raw = subprocess.run([ff, "-y", "-i", "pipe:0", *af, "-f", "s16le", "-ac", "1", "-ar", "44100", "pipe:1"],
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
    wanted = {file_name(*l): l for l in voice_lines(data)}
    VOICE_DIR.mkdir(parents=True, exist_ok=True)
    missing = [n for n in wanted if not (VOICE_DIR / n).exists()]
    if args.check:
        for n in missing:
            print(f"missing {n}: {wanted[n][0]} / {wanted[n][1]} 「{wanted[n][2]}」")
        return 1 if missing else 0
    with tempfile.TemporaryDirectory() as tmp:
        local = [(wanted[n][2], wanted[n][3], Path(tmp) / f"{n}.wav") for n in missing if wanted[n][3][0] == "indextts"]
        if local:
            _indextts(local)
        for n in missing:
            prof, moment, text, spec = wanted[n]
            if spec[0] == "src":
                audio = (SRC_DIR / spec[1]).read_bytes()
            elif spec[0] == "indextts":
                audio = (Path(tmp) / f"{n}.wav").read_bytes()
            elif spec[0] == "minimax":
                audio = _minimax(text, *spec[1:6])
            else:
                audio = await _edge(text, *spec[1:4])
            _encode(audio, text, VOICE_DIR / n, _tempo(spec))
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
