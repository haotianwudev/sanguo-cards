"""Print per-chapter numbers for docs/CHAPTER-STATS.md: squares, battles (normal/elite/boss), forks, CGs (have/total), rogue pools.
   python tools/chapter_stats.py            # table
   python tools/chapter_stats.py --write    # also refresh squares / battles / CG columns of the overview table in the doc (pools and text stay hand-written)
                                            # and the generated 卡牌种类 section (generals / soldiers by rarity, troop, route)"""
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

CARDS_BEGIN, CARDS_END = "<!-- cards:begin -->", "<!-- cards:end -->"


def card_section() -> str:
    """Generals and soldier cards by rarity / troop / route (scope) and portrait coverage, as markdown."""
    cs = cards["cards"]
    troops = cards["troops"]
    drawn = {k for k, v in art["portraits"].items() if not v.get("placeholder")}
    has_art = lambda cid, c: c.get("person", cid) in drawn
    gens = {k: c for k, c in cs.items() if c.get("rarity", "N") != "N"}
    sols = {k: c for k, c in cs.items() if c.get("rarity", "N") == "N"}
    route = lambda c: {"south": "南", "north": "北"}.get(c.get("scope", ""), "通用")

    def split(group):
        n = len(group)
        pool = sum(1 for c in group.values() if c.get("pool", True))
        r = {x: sum(1 for c in group.values() if route(c) == x) for x in ("南", "北", "通用")}
        art_n = sum(1 for k, c in group.items() if has_art(k, c))
        return n, pool, n - pool, r, art_n

    out = ["## 卡牌种类（`python tools/chapter_stats.py --write` 生成，别手改这一节）", "",
           "口径：武将＝R / SR / SSR 卡，兵卡＝N 卡（精兵＝`elite: true`）。卡池＝`pool` 不是 false（宝箱 / 招贤能抽到），"
           "剧情限定＝只能靠剧情 / 掉落拿到。路线看卡的 `scope`（没写＝南北通用）。立绘＝`pics/art.json` 里有正式图（不算占位）。", "",
           "### 按稀有度", "",
           "| 稀有度 | 种类 | 卡池 / 剧情限定 | 南 / 北 / 通用 | 立绘已有 |", "|---|---:|---:|---:|---:|"]
    for rar in ("SSR", "SR", "R"):
        g = {k: c for k, c in gens.items() if c["rarity"] == rar}
        n, pool, story_only, r, art_n = split(g)
        out.append(f"| {rar} | {n} | {pool} / {story_only} | {r['南']} / {r['北']} / {r['通用']} | {art_n}/{n} |")
    for label, g in (("**武将合计**", gens), ("兵卡（N）", sols)):
        n, pool, story_only, r, art_n = split(g)
        out.append(f"| {label} | {n} | {pool} / {story_only} | {r['南']} / {r['北']} / {r['通用']} | {art_n}/{n} |")
    # 主公卡: the starting lord card (drawable: recruit offers show it at gacha.lord_rate, a copy raises its tier)
    # + the lord_forms (one dealt per cleared chapter, not in the pools)
    forms = cards.get("lord_forms", {}).get("forms", {})
    lr = {x: sum(1 for v in forms.values() if {"south": "南", "north": "北"}.get(v.get("route", ""), "通用") == x) for x in ("南", "北", "通用")}
    lr["南"] += 1  # the starting lord is one card per route: south `lord`, north `lord_north` (own look, spear skills)
    lr["北"] += 1
    l_art = int("lord" in drawn) + int("lord_north" in drawn) + sum(1 for k, v in forms.items() if v.get("art") and k in drawn)
    ln = 2 + len(forms)
    out.append(f"| 主公卡（初始南北各 1 + 通关形态 {len(forms)}） | {ln} | 2 / {len(forms)} | {lr['南']} / {lr['北']} / {lr['通用']} | {l_art}/{ln} |")
    n, pool, story_only, r, art_n = split(cs)
    n, pool, story_only, art_n = n + ln, pool + 2, story_only + len(forms), art_n + l_art
    r = {x: r[x] + lr[x] for x in r}
    out.append(f"| **全部** | **{n}** | {pool} / {story_only} | {r['南']} / {r['北']} / {r['通用']} | {art_n}/{n} |")
    out += ["", f"主公卡：初始那张南北各一张（南线 `lord` 寸头旧银甲、扔刀；北线 `lord_north` 束发鱼鳞甲、夺命枪），都在卡池里——招贤 / 抽卡时以 `gacha.lord_rate`"
            f"（{float(cards['gacha'].get('lord_rate', 0)):.0%}）出现，抽到升铜 / 银 / 金；通关形态不进卡池，每通关一章发一张，按 `lord_forms.forms` 的 `route` 分南北。"
            "立绘只算 `art: true` 且图已交付的。",
            "", "### 按兵种", "",
            "| 兵种 | 武将 SSR / SR / R | 武将合计 | 兵卡（其中精兵） | 南 / 北 / 通用（武将+兵卡） |", "|---|---:|---:|---:|---:|"]
    r_of = lambda group, x: sum(1 for c in group if route(c) == x)
    for tid, tr in troops.items():
        g = [c for c in gens.values() if c["troop"] == tid]
        s = [c for c in sols.values() if c["troop"] == tid]
        if tid == "lord":
            out.append(f"| 主公 | 主公卡 {ln} 张（不分稀有度） | {ln} | {len(s)}（亲卫：丫鬟、家丁等） | {lr['南'] + r_of(s, '南')} / {lr['北'] + r_of(s, '北')} / {lr['通用'] + r_of(s, '通用')} |")
            continue
        if not g and not s:
            continue
        by = {x: sum(1 for c in g if c["rarity"] == x) for x in ("SSR", "SR", "R")}
        elite = sum(1 for c in s if c.get("elite"))
        allc = g + s
        r = {x: sum(1 for c in allc if route(c) == x) for x in ("南", "北", "通用")}
        out.append(f"| {'主公亲卫（丫鬟、家丁等，跟主公一队）' if tid == 'lord' else tr.get('name', tid)} | {by['SSR']} / {by['SR']} / {by['R']} | {len(g)} | {len(s)}（{elite}） | {r['南']} / {r['北']} / {r['通用']} |")
    return "\n".join(out)

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
    sec = CARDS_BEGIN + "\n" + card_section() + "\n" + CARDS_END
    if CARDS_BEGIN in t:
        t = re.sub(re.escape(CARDS_BEGIN) + ".*?" + re.escape(CARDS_END), lambda m: sec, t, flags=re.S)
    else:  # first run: right after the overview table's footnote, before the first chapter
        i = t.index("\n---\n")
        t = t[:i] + "\n\n" + sec + "\n" + t[i:]
    import datetime
    t = re.sub(r"## 全局总览（\d{4}-\d{2}-\d{2}", "## 全局总览（%s" % datetime.date.today(), t, 1)
    p.write_text(t, "utf-8", newline="\n")
    print("overview updated")
