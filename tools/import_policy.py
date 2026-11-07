"""Apply tools/import_policy.json to every texture .import file under godot/.

    python tools/import_policy.py --write   # rewrite the [params] that differ, then run Godot --import
    python tools/import_policy.py --check   # exit 1 if any texture strays from the policy (CI / tools/check.sh)
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GODOT = ROOT / "godot"
POLICY = json.loads((ROOT / "tools" / "import_policy.json").read_text("utf-8"))


def rule_for(rel: str) -> dict:
    for r in POLICY["rules"]:
        if rel.startswith(r["prefix"]):
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
    return 0


if __name__ == "__main__":
    sys.exit(main())
