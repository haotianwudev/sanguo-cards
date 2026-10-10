"""Generate art using AtlasCloud API fallback when built-in generator is unavailable or exhausted.

Usage:
    python tools/art_gen.py --key <art_key> --prompt "<prompt>" [--model z-image/turbo] [--size 1280*720] [--ingest]

Reads ATLASCLOUD_API_KEY from .env in project root.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENV_FILE = ROOT / ".env"
INBOX_DIR = ROOT / "pics" / "inbox"


def load_api_key() -> str:
    key = os.environ.get("ATLASCLOUD_API_KEY")
    if key:
        return key.strip()
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text("utf-8").splitlines():
            line = line.strip()
            if line.startswith("ATLASCLOUD_API_KEY="):
                return line.split("=", 1)[1].strip().strip("\"'")
    raise RuntimeError("ATLASCLOUD_API_KEY not found in environment or .env file.")


def upload_media(api_key: str, file_path: Path) -> str:
    """Upload reference media to AtlasCloud to get an image URL."""
    url = "https://api.atlascloud.ai/api/v1/model/uploadMedia"
    boundary = "----WebKitFormBoundary" + hex(int(time.time() * 1000))[2:]

    data = bytearray()
    data.extend(f"--{boundary}\r\n".encode("utf-8"))
    data.extend(
        f'Content-Disposition: form-data; name="file"; filename="{file_path.name}"\r\n'.encode("utf-8")
    )
    data.extend(b"Content-Type: image/jpeg\r\n\r\n")
    data.extend(file_path.read_bytes())
    data.extend(f"\r\n--{boundary}--\r\n".encode("utf-8"))

    req = urllib.request.Request(
        url,
        data=bytes(data),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": f"multipart/form-data; boundary={boundary}",
            "User-Agent": "Mozilla/5.0",
        },
    )
    with urllib.request.urlopen(req) as resp:
        res = json.loads(resp.read().decode("utf-8"))
        data = res.get("data", {})
        if "download_url" in data:
            return data["download_url"]
        if "url" in data:
            return data["url"]
        if "url" in res:
            return res["url"]
        raise RuntimeError(f"Failed to upload media: {res}")


def generate_image_atlas(
    api_key: str,
    prompt: str,
    model: str = "z-image/turbo",
    size: str = "1280*720",
    ref_urls: list[str] | None = None,
) -> str:
    """Submit generation request to AtlasCloud and return output image URL."""
    url = "https://api.atlascloud.ai/api/v1/model/generateImage"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0",
    }

    if "lite" in model and "banana" in model:
        model = "google/nano-banana-2-lite/edit-developer" if ref_urls else "google/nano-banana-2-lite/text-to-image-developer"
    elif ("developer" in model and "banana" in model) or model in ("nano-banana", "nano-banana-2"):
        model = "google/nano-banana-2/reference-to-image-developer" if ref_urls else "google/nano-banana-2/text-to-image-developer"
    elif "banana-2.1" in model or "google/nano-banana-2.1" in model:
        model = "google/nano-banana-2.1/edit" if ref_urls else "google/nano-banana-2.1/text-to-image"
    elif "gpt-image" in model:
        model = "openai/gpt-image-2-developer/edit" if ref_urls else "openai/gpt-image-2-developer/text-to-image"
    elif "grok" in model:
        model = "xai/grok-imagine-image-2.0-developer/edit" if ref_urls else "xai/grok-imagine-image-2.0-developer/text-to-image"

    is_seedream = "seedream" in model
    is_nano = "nano-banana" in model
    is_gpt = "gpt-image" in model
    is_grok = "grok" in model
    payload = {
        "model": model,
        "prompt": prompt,
    }
    if not is_seedream and not is_nano and not is_gpt and not is_grok:
        payload["enable_sync_mode"] = True
    else:
        payload["enable_sync_mode"] = False

    if "z-image" in model:
        payload["size"] = size
    elif is_seedream:
        payload["size"] = "2560*1440" if size == "1280*720" else size
    elif is_gpt:
        payload["size"] = "1536x1024" if size in ("1280*720", "1280x720") else size
        if ref_urls:
            payload["images"] = ref_urls
    elif is_grok:
        payload["aspect_ratio"] = "16:9"
        payload["resolution"] = "1k"
        if ref_urls:
            payload["image_urls"] = ref_urls
    elif is_nano:
        payload["aspect_ratio"] = "16:9"
        payload["resolution"] = "1k" if "lite" in model else "2k"
        if ref_urls:
            payload["images"] = ref_urls
            payload["reference_images"] = ref_urls

    req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            res = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"AtlasCloud API HTTP {e.code}: {body}") from e

    data = res.get("data", res)
    outputs = data.get("outputs")
    if outputs and len(outputs) > 0:
        return outputs[0]

    # Poll prediction endpoint if not sync finished
    pred_id = data.get("id")
    if not pred_id:
        raise RuntimeError(f"No output or prediction ID returned: {res}")

    poll_url = f"https://api.atlascloud.ai/api/v1/model/prediction/{pred_id}"
    poll_req = urllib.request.Request(poll_url, headers=headers)
    for _ in range(60):
        time.sleep(2)
        with urllib.request.urlopen(poll_req) as resp:
            poll_res = json.loads(resp.read().decode("utf-8"))
            p_data = poll_res.get("data", poll_res)
            status = p_data.get("status")
            if status == "completed":
                p_outs = p_data.get("outputs", [])
                if p_outs:
                    return p_outs[0]
                raise RuntimeError(f"Completed with no outputs: {poll_res}")
            if status in ("failed", "error"):
                raise RuntimeError(f"Prediction failed: {p_data.get('error', poll_res)}")

    raise TimeoutError(f"Generation timed out after 120s: {pred_id}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate art using AtlasCloud")
    parser.add_argument("--key", required=True, help="Art key (e.g. c6_fanchou)")
    parser.add_argument("--prompt", required=True, help="Text prompt")
    parser.add_argument("--model", default="gpt-image-2", help="Model ID (default: gpt-image-2)")
    parser.add_argument("--size", default="1280*720", help="Output size for z-image (default: 1280*720)")
    parser.add_argument("--ref", nargs="+", help="Optional local path(s) to reference image(s)")
    parser.add_argument("--out", help="Output local image path (default: pics/inbox/<key>.jpg)")
    parser.add_argument("--kind", help="Art kind (e.g. battle, cg, portrait)")
    parser.add_argument("--ingest", action="store_true", help="Auto ingest via tools/art_ingest.py after generation")
    args = parser.parse_args()

    api_key = load_api_key()
    print(f"Generating for key: {args.key} using model: {args.model}")

    ref_urls = []
    if args.ref:
        for r in args.ref:
            ref_path = Path(r)
            if ref_path.exists():
                print(f"Uploading reference image: {ref_path}")
                url = upload_media(api_key, ref_path)
                ref_urls.append(url)
                print(f"Reference uploaded: {url}")
            else:
                print(f"Warning: reference image not found: {r}")

    img_url = generate_image_atlas(api_key, args.prompt, model=args.model, size=args.size, ref_urls=ref_urls)
    print(f"Generated URL: {img_url}")

    INBOX_DIR.mkdir(parents=True, exist_ok=True)
    out_path = Path(args.out) if args.out else INBOX_DIR / f"{args.key}.jpg"

    req = urllib.request.Request(img_url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as resp, open(out_path, "wb") as f:
        f.write(resp.read())
    print(f"Saved image to: {out_path}")

    if args.ingest:
        import subprocess

        print(f"Ingesting into game...")
        cmd = [sys.executable, str(ROOT / "tools" / "art_ingest.py"), "add", str(out_path), args.key]
        if args.kind:
            cmd.extend(["--kind", args.kind])
        subprocess.check_call(cmd)


if __name__ == "__main__":
    main()
