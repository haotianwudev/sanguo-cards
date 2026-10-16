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
sys.path.insert(0, str(ROOT / "tools"))
from gamedata import load_cards
cards = load_cards()
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
    out += ["", f"主公卡：初始那张南北各一张（南线 `lord` 寸头旧铜甲、扔刀；北线 `lord_north` 束发鱼鳞甲、夺命枪），都在卡池里——招贤 / 抽卡时以 `gacha.lord_rate`"
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

quests_by_id = {q["id"]: q for q in story["quests"] if q["id"] != "prologue"}
for _q in story["quests"]:
    if _q["id"] == "prologue":  # one quest, two routes: the north route's pool_overrides entry replaces the south settings
        quests_by_id["prologue_s"] = _q
        _n = dict(_q)
        for _o in _q.get("pool_overrides", []):
            _n.update({k: v for k, v in _o.items() if k not in ("requires", "unless") and v})
        quests_by_id["prologue_n"] = _n


def distinct_lists(q, field):
    """how many different explicit card lists a chapter uses for `field` (soldier_pool / recruit_pool): its own plus the squares' local ones"""
    found = set()
    for src in [q] + list(q["squares"].values()):
        if src.get(field):
            found.add(tuple(sorted(src[field])))
    return len(found)


def pools_cell(q) -> str:
    """兵卡池 / 招贤池 (distinct lists, local ones included) / 事件池 (events open to the chapter) / 洗牌组"""
    events = sum(1 for e in story["events"].values() if e.get("scope") in ("universal", q.get("event_scope"), q["id"]))
    soldier = distinct_lists(q, "soldier_pool") or (1 if q.get("soldier_scope") else 0)  # no explicit list: the route's scope pool counts as one
    return "%d / %d / %d / %d" % (soldier, distinct_lists(q, "recruit_pool"), events, len(q.get("shuffle", [])))


COMPARE_BEGIN, COMPARE_END ="<!-- compare:begin -->", "<!-- compare:end -->"
# chapter -> (south row key, north row key); None = that route has nothing built for the chapter yet
CHAPTERS = [
    ("第一章", "prologue_s", "prologue_n"),
    ("第二章", "taodong", "luoyang_n"),
    ("第三章", "yuxi", "heishan"),
    ("第四章", "dongui", "beihai"),
    ("第五章", "jingxiang", "xuzhou"),
    ("第六章", "huainan_s", "huainan_n"),
    ("第七章", "jiangdong", None),
    ("第八章", "menghu", None),
    ("第九章", "tianfu", None),
]
ROW_NAMES = {"prologue_s": "富春", "prologue_n": "冀州风云"}
SUM_KEYS = ("n", "normal", "elite", "boss", "forks", "cg_have", "cg_all")


def compare_section() -> str:
    titles = {q["id"]: q["title"].split(" · ", 1)[-1] for q in story["quests"]}
    titles.update(ROW_NAMES)

    def cells(key):
        if key is None:
            return ["—（未实装）", "", "", "", ""]
        r = rows[key]
        return [titles[key], str(r["n"]), "%d / %d / %d" % (r["normal"], r["elite"], r["boss"]), str(r["forks"]), "%d/%d" % (r["cg_have"], r["cg_all"])]

    out = ["## 南北线对比（`python tools/chapter_stats.py --write` 生成，别手改这一节）", "",
           "同一章的南线、北线并排；口径同下方总览（格数含互斥分支，分叉＝`choose` + `lose_goto`）。", "",
           "| 章 | 南线 | 格数 | 战斗 普/精/首 | 分叉 | CG | 北线 | 格数 | 战斗 普/精/首 | 分叉 | CG |",
           "|---|---|---:|---:|---:|---:|---|---:|---:|---:|---:|"]
    sums = {"s": dict.fromkeys(SUM_KEYS, 0), "n": dict.fromkeys(SUM_KEYS, 0)}
    for ch, s, n in CHAPTERS:
        out.append("| %s | %s | %s |" % (ch, " | ".join(cells(s)), " | ".join(cells(n))))
        for side, key in (("s", s), ("n", n)):
            if key:
                for k in SUM_KEYS:
                    sums[side][k] += rows[key][k]

    def total(side):
        d = sums[side]
        return ["", "**%d**" % d["n"], "**%d / %d / %d**" % (d["normal"], d["elite"], d["boss"]), "**%d**" % d["forks"], "**%d/%d**" % (d["cg_have"], d["cg_all"])]
    out.append("| **合计** | %s | %s |" % (" | ".join(total("s")), " | ".join(total("n"))))
    return "\n".join(out)


covered = {k for _ch, s, n in CHAPTERS for k in (s, n) if k}
uncovered = [k for k in rows if k not in covered]
if uncovered:  # a new chapter must be added to CHAPTERS or the 南北线对比 table silently misses it
    print("!! quests missing from CHAPTERS (南北线对比): %s" % ", ".join(uncovered))

if "--write" in sys.argv or "--check" in sys.argv:
    p = ROOT / "docs/CHAPTER-STATS.md"
    t = p.read_text("utf-8")
    orig = t
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
            if r and qid in quests_by_id:
                note = re.search(r"（兵卡池.*$", cells[9].strip())  # a hand-written note on which places the pools are for
                cells[9] = " " + pools_cell(quests_by_id[qid]) + (note.group(0) if note else "") + " "
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
    csec = COMPARE_BEGIN + "\n" + compare_section() + "\n" + COMPARE_END
    if COMPARE_BEGIN in t:
        t = re.sub(re.escape(COMPARE_BEGIN) + ".*?" + re.escape(COMPARE_END), lambda m: csec, t, flags=re.S)
    else:  # first run: just before the global overview
        i = t.index("## 全局总览")
        t = t[:i] + csec + "\n\n" + t[i:]
    sec = CARDS_BEGIN + "\n" + card_section() + "\n" + CARDS_END
    if CARDS_BEGIN in t:
        t = re.sub(re.escape(CARDS_BEGIN) + ".*?" + re.escape(CARDS_END), lambda m: sec, t, flags=re.S)
    else:  # first run: right after the overview table's footnote, before the first chapter
        i = t.index("\n---\n")
        t = t[:i] + "\n\n" + sec + "\n" + t[i:]
    import datetime
    t = re.sub(r"## 全局总览（\d{4}-\d{2}-\d{2}", "## 全局总览（%s" % datetime.date.today(), t, 1)
    if "--check" in sys.argv and "--write" not in sys.argv:  # CI / pre-commit: fail when the doc is stale (the date line is ignored)
        day = lambda s: re.sub(r"## 全局总览（\d{4}-\d{2}-\d{2}", "## 全局总览（DATE", s, 1)
        if day(t) != day(orig) or uncovered:
            print("docs/CHAPTER-STATS.md is stale — run: python tools/chapter_stats.py --write")
            sys.exit(1)
        print("CHAPTER-STATS.md is up to date")
    else:
        p.write_text(t, "utf-8", newline="\n")
        print("overview updated")
