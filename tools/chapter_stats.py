"""Print per-chapter numbers for docs/CHAPTER-STATS.md: squares, battles (normal/elite/boss), forks, CGs (have/total), rogue pools.
   python tools/chapter_stats.py            # table
   python tools/chapter_stats.py --write    # also refresh squares / battles / CG columns of the overview table in the doc (pools and text stay hand-written)"""
import io, json, re, sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[1]
story = json.loads((ROOT / "godot/data/story.json").read_text("utf-8"))
art = json.loads((ROOT / "pics/art.json").read_text("utf-8"))
have_cg = set(art["cgs"])
cards = json.loads((ROOT / "godot/data/cards.json").read_text("utf-8"))
shuffle = lambda q: len(q.get("shuffle", []))


def stats(q, xs=None):
    sq = {k: v for k, v in q["squares"].items() if xs is None or xs[0] <= v.get("x", 0) <= xs[1]}
    n = len(sq)
    b = [v for v in sq.values() if v["type"] == "battle"]
    boss = sum(1 for v in b if v.get("boss"))
    elite = sum(1 for v in b if v.get("elite") and not v.get("boss"))
    normal = len(b) - boss - elite
    forks = sum(1 for v in sq.values() if v["type"] == "choose" or v.get("lose_goto"))
    cgs = {v["cg"] for v in sq.values() if v.get("cg")}
    return dict(n=n, normal=normal, elite=elite, boss=boss, forks=forks, cg_have=len(cgs & have_cg), cg_all=len(cgs),
                pools="%d / %d / %d / %d" % (len(q.get("soldier_pool", [])), len(q.get("recruit_pool", [])), len(q.get("event_pool", [])), shuffle(q)))


rows = {}
for q in story["quests"]:
    if q["id"] == "prologue":
        rows["prologue_s"] = stats(q, (0, 22))
        rows["prologue_n"] = stats(q, (23, 10**6))
    else:
        rows[q["id"]] = stats(q)
tot = dict(n=0, normal=0, elite=0, boss=0, cg_have=0, cg_all=0)
for r in rows.values():
    for k in tot:
        tot[k] += r[k]
for k, r in rows.items():
    print(k.ljust(12), r)
print("TOTAL", tot, "battles", tot["normal"] + tot["elite"] + tot["boss"])

if "--write" in sys.argv:
    p = ROOT / "docs/CHAPTER-STATS.md"
    t = p.read_text("utf-8")
    ids = {"prologue_s": "第一章 · 富春（南线）", "prologue_n": "第一章 · 冀州风云（北线）"}
    out = []
    for line in t.split("\n"):
        cells = line.split("|")
        if len(cells) >= 11 and cells[1].strip().startswith("第") and cells[1].strip().find("·") > 0:
            name = cells[1].strip()
            qid = None
            for k, v in ids.items():
                if name.startswith(v):
                    qid = k
            if qid is None:
                m = re.search(r"`?(\w+)`?", cells[2])
                qid = m.group(1) if m else None
            r = rows.get(qid)
            if r:
                cells[4] = " %d%s " % (r["n"], "*" if cells[4].strip().endswith("*") else "")
                cells[5] = " %d / %d / %d " % (r["normal"], r["elite"], r["boss"])
                cells[8] = " %d/%d " % (r["cg_have"], r["cg_all"])
                line = "|".join(cells)
        elif line.startswith("| **合计"):
            cells[4] = " **%d** " % tot["n"]
            cells[5] = " **%d / %d / %d**（共 %d 场战斗） " % (tot["normal"], tot["elite"], tot["boss"], tot["normal"] + tot["elite"] + tot["boss"])
            cells[8] = " **%d/%d** " % (tot["cg_have"], tot["cg_all"])
            line = "|".join(cells)
        out.append(line)
    t = "\n".join(out)
    import datetime
    t = re.sub(r"## 全局总览（\d{4}-\d{2}-\d{2}", "## 全局总览（%s" % datetime.date.today(), t, 1)
    p.write_text(t, "utf-8", newline="\n")
    print("overview updated")
