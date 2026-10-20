"""Run a batch of IndexTTS 2 lines. Called by tools/gen_voices.py inside the IndexTTS environment — not run by hand:

    python -m uv run --project <INDEXTTS_DIR> python tools/indextts_job.py <job.json>

job.json: {"indextts_dir": ..., "lines": [{"text", "ref" (absolute wav), "emo" (8 floats 0..1), "out" (absolute wav)}]}.
emo order: [happy, angry, sad, afraid, disgusted, melancholic, surprised, calm]. The model loads once for the batch.
"""
import json
import os
import sys

job = json.loads(open(sys.argv[1], encoding="utf-8").read())
os.chdir(job["indextts_dir"])  # the model's config and checkpoints are relative to its checkout
sys.path.insert(0, job["indextts_dir"])
from indextts.infer_v2 import IndexTTS2  # noqa: E402

tts = IndexTTS2(cfg_path="checkpoints/config.yaml", model_dir="checkpoints", use_fp16=True, use_cuda_kernel=False)
for line in job["lines"]:
    tts.infer(spk_audio_prompt=line["ref"], text=line["text"], output_path=line["out"], emo_vector=line["emo"],
              use_random=False, verbose=False)
    print("indextts:", os.path.basename(line["out"]), line["text"], flush=True)
