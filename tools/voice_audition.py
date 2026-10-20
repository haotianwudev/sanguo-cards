"""Audition voices for a character: several candidate timbres saying the same lines, in one file to listen to.

Two modes (the owner's rule: local first; MiniMax only if local isn't good enough — and then MiniMax alone):

  --engine local (default)   each candidate is an edge-tts voice: it reads --ref-text (~8 s, in character) as the
                             reference, then IndexTTS 2 says every line in that timbre with --emo. Free.
  --engine minimax           each candidate is a MiniMax voice id (AtlasCloud, ATLASCLOUD_API_KEY in .env) saying every
                             line itself with --emotion. Paid per character; no --ref-text needed.

Everything goes to --out (default: a new temp folder), plus compare.wav — candidates in order, lines 0.6 s apart,
1.8 s between candidates — opened for listening. Nothing in the game changes. When the owner picks one, write the
profile in audio.json (see the sanguo-voice skill): local → copy its ref_<n>.wav to audio_src/voice/ and use
engine indextts; minimax → engine minimax with that voice id.

    python tools/voice_audition.py --ref-text "云自幼习枪……" --line "我乃常山赵子龙是也！" \\
        --voice zh-CN-YunjianNeural --voice zh-CN-YunxiNeural --voice zh-CN-YunyangNeural --emo 20,75,0,0,0,0,0,0
    python tools/voice_audition.py --engine minimax --line "我乃常山赵子龙是也！" \\
        --voice male-qn-jingying --voice "Chinese (Mandarin)_Gentle_Youth" --emotion angry

--emo: 8 ints 0..100 — happy, angry, sad, afraid, disgusted, melancholic, surprised, calm. --line / --voice repeat.
"""
import argparse
import asyncio
import json
import os
import subprocess
import sys
import tempfile
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
API = "https://api.atlascloud.ai/api/v1/model"


def _key() -> str:
    if os.environ.get("ATLASCLOUD_API_KEY"):
        return os.environ["ATLASCLOUD_API_KEY"].strip()
    for line in (ROOT / ".env").read_text("utf-8").splitlines():
        if line.startswith("ATLASCLOUD_API_KEY="):
            return line.split("=", 1)[1].strip().strip("'\"")
    sys.exit("ATLASCLOUD_API_KEY not in the environment or .env")


def _call(url: str, key: str, payload: dict | None = None) -> dict:
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json",
                                               "User-Agent": "Mozilla/5.0"},
                                 data=json.dumps(payload).encode() if payload else None)
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


def minimax(text: str, voice: str, out: Path, key: str, emotion: str = "auto", speed: float = 1.05, pitch: int = 0) -> None:
    ## MiniMax Speech 2.6 Turbo through AtlasCloud. Chinese voice ids work with language_boost Chinese, though the
    ## AtlasCloud schema lists only English presets; there is no voice cloning there.
    res = _call(f"{API}/generateAudio", key, {"model": "minimax/speech-2.6-turbo", "text": text, "voice": voice, "emotion": emotion,
                                             "language_boost": "Chinese", "speed": speed, "pitch": pitch, "vol": 1.5,
                                             "format": "wav", "sample_rate": 44100})
    if str(res.get("code")) != "200":
        raise RuntimeError(f"{voice}: {res}")
    pid = res["data"]["id"]
    for _ in range(45):
        time.sleep(2)
        d = _call(f"{API}/prediction/{pid}", key).get("data", {})
        if d.get("status") in ("completed", "succeeded"):
            urllib.request.urlretrieve(d["outputs"][0], str(out))
            return
        if d.get("status") == "failed":
            raise RuntimeError(f"{voice}: {d.get('error')}")
    raise TimeoutError(voice)


def main() -> None:
    from gen_voices import INDEXTTS_DIR, _edge, _ffmpeg
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--engine", choices=["local", "minimax"], default="local")
    ap.add_argument("--ref-text", default="", help="local: ~8 s the character says in character, read by each edge-tts voice")
    ap.add_argument("--line", action="append", required=True, help="a battle line to audition (repeatable)")
    ap.add_argument("--voice", action="append", required=True, help="an edge-tts voice (local) or MiniMax voice id (minimax)")
    ap.add_argument("--emo", default="0,100,0,0,0,0,0,0", help="local: emotion, 8 ints 0..100 (default: full anger)")
    ap.add_argument("--emotion", default="angry", help="minimax: angry / happy / sad / surprised / calm / auto …")
    ap.add_argument("--speed", type=int, default=105, help="minimax: speed ×100 (105 = 1.05×)")
    ap.add_argument("--pitch", type=int, default=0, help="minimax: pitch in semitones (-12..12)")
    ap.add_argument("--out", default="", help="output folder (default: a new temp folder)")
    ap.add_argument("--no-open", action="store_true")
    args = ap.parse_args()
    out = Path(args.out) if args.out else Path(tempfile.mkdtemp(prefix="voice_audition_"))
    out.mkdir(parents=True, exist_ok=True)
    cand = lambda i, j: out / f"cand{i + 1}_line{j + 1}.wav"  # noqa: E731
    ff = _ffmpeg()
    if args.engine == "minimax":
        key = _key()
        jobs = [(i, j, v, t) for i, v in enumerate(args.voice) for j, t in enumerate(args.line)]
        with ThreadPoolExecutor(4) as ex:
            list(ex.map(lambda x: minimax(x[3], x[2], cand(x[0], x[1]), key, args.emotion, args.speed / 100.0, args.pitch), jobs))
    else:
        if not args.ref_text:
            sys.exit("--ref-text is needed for the local engine")
        refs = []
        for i, v in enumerate(args.voice):
            ref = out / f"ref_{i + 1}.wav"
            mp3 = asyncio.run(_edge(args.ref_text, v, "+0%", "+0Hz"))
            subprocess.run([ff, "-v", "error", "-y", "-i", "pipe:0", "-ar", "44100", "-ac", "1", str(ref)], input=mp3, check=True)
            refs.append(ref)
        emo = [int(x) / 100.0 for x in args.emo.split(",")]
        assert len(emo) == 8, "--emo needs 8 numbers"
        lines = [{"text": t, "ref": str(r), "emo": emo, "out": str(cand(i, j))} for i, r in enumerate(refs) for j, t in enumerate(args.line)]
        job = out / "job.json"
        job.write_text(json.dumps({"indextts_dir": str(INDEXTTS_DIR), "lines": lines}, ensure_ascii=False), encoding="utf-8")
        subprocess.run([sys.executable, "-m", "uv", "run", "--project", str(INDEXTTS_DIR), "python",
                        str(ROOT / "tools/indextts_job.py"), str(job)], check=True, cwd=str(INDEXTTS_DIR))
    parts = []
    for i in range(len(args.voice)):
        for j in range(len(args.line)):
            p = out / f"_p_{cand(i, j).name}"
            pad = 1.8 if j == len(args.line) - 1 else 0.6
            subprocess.run([ff, "-v", "error", "-y", "-i", str(cand(i, j)), "-af",
                            f"aresample=44100,aformat=channel_layouts=mono,loudnorm=I=-14:TP=-1,apad=pad_dur={pad}",
                            "-ar", "44100", "-ac", "1", str(p)], check=True)
            parts.append(p)
    (out / "_list.txt").write_text("".join(f"file '{p.name}'\n" for p in parts), encoding="utf-8")
    subprocess.run([ff, "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", "_list.txt", "-c", "pcm_s16le", "compare.wav"],
                   check=True, cwd=str(out))
    for p in parts:
        p.unlink()
    print("candidates:", ", ".join(f"{i + 1} = {v}" for i, v in enumerate(args.voice)))
    print("compare:", out / "compare.wav")
    if not args.no_open and sys.platform == "win32":
        os.startfile(str(out / "compare.wav"))


if __name__ == "__main__":
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    main()
