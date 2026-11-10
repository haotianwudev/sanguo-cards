"""Apply tools/import_policy.json to every texture .import file under godot/.

    python tools/import_policy.py --write   # rewrite the [params] that differ, then run Godot --import
    python tools/import_policy.py --check   # exit 1 if any texture strays from the policy (CI / tools/check.sh)
"""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GODOT = ROOT / "godot"
POLICY = json.loads((ROOT / "tools" / "import_policy.json").read_text("utf-8"))


def _width(rel: str) -> int:
    """pixel width of the image an .import file belongs to (0 if it can't be read)"""
    try:
        from PIL import Image
        with Image.open(GODOT / rel[: -len(".import")]) as im:
            return im.width
    except Exception:
        return 0


def rule_for(rel: str) -> dict:
    for r in POLICY["rules"]:
        if rel.startswith(r["prefix"]) and ("max_width" not in r or 0 < _width(rel) <= r["max_width"]):
            return r["params"]
    return {}


def fmt(v) -> str:
    return ("true" if v else "false") if isinstance(v, bool) else str(v)


def apply(text: str, params: dict) -> str:
    out, seen, in_params = [], set(), False
    for line in text.split("\n"):
        if line.startswith("["):
            in_params = line.strip() == "[params]"
        elif in_params and "=" in line:
            k = line.split("=", 1)[0]
            if k in params:
                line = "%s=%s" % (k, fmt(params[k]))
                seen.add(k)
        out.append(line)
    missing = [k for k in params if k not in seen]
    assert not missing, "no %s in [params]" % missing
    return "\n".join(out)


def untracked_imports() -> list:
    """committed images under godot/data whose .import isn't committed: a fresh clone (CI, a phone build) re-imports
    them with the defaults instead of the policy. [] outside a git checkout."""
    try:
        out = subprocess.run(["git", "ls-files", "godot/data"], cwd=ROOT, capture_output=True, check=True,
                             text=True, encoding="utf-8").stdout
    except (OSError, subprocess.CalledProcessError):
        return []
    files = set(out.splitlines())
    return sorted(f for f in files if f.lower().endswith((".jpg", ".jpeg", ".png", ".webp")) and f + ".import" not in files)


def main() -> int:
    write = "--write" in sys.argv
    drift = []
    for f in sorted(GODOT.rglob("*.import")):
        if ".godot" in f.parts:
            continue
        text = f.read_text("utf-8")
        if 'importer="texture"' not in text:
            continue
        rel = f.relative_to(GODOT).as_posix()
        new = apply(text, rule_for(rel))
        if new != text:
            drift.append(rel)
            if write:
                f.write_text(new, "utf-8", newline="\n")
    print("%d texture(s) %s" % (len(drift), "rewritten" if write else "off policy"))
    if not write and drift:
        print("\n".join(drift[:20]))
        return 1
    missing = untracked_imports()
    if missing and not write:
        print("%d committed image(s) without a committed .import, git add these:" % len(missing))
        print("\n".join(f + ".import" for f in missing[:20]))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
