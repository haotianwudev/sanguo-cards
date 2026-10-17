"""Generate docs/ROSTER.md: every soldier (N) and general card, where it comes from, and which soldiers each chapter can hand out.
   python tools/roster.py            # print the doc
   python tools/roster.py --write    # write docs/ROSTER.md
   python tools/roster.py --check    # exit 1 when docs/ROSTER.md is stale (pre-commit / CI)

Chest rules this mirrors (SaveData.chest_pools): a soldier is 公共 when no chapter hands it out and it has no `faction` —
it can then show up in every chapter of its route (`scope`; none = both). A soldier with a `faction`, or one a chapter hands out
(an enemy fought there drops it, a square / choice gives it, a 招贤 list names it), only comes from those chapters; a chapter's
`soldier_pool` lists (quest, square, pool_overrides) add more. Events that `offer` soldiers are listed separately."""
import json, sys
from collections import defaultdict
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from gamedata import load_cards

db = load_cards()
cards = db["cards"]
troops = db["troops"]
enemies = db["enemies"]
scenarios = db["scenarios"]
story = json.loads((ROOT / "godot/data/story.json").read_text("utf-8"))
FACTION = {"han": "汉军（刘备）", "wei": "魏军（曹操）", "yuan": "袁军（袁绍）"}
ROUTE = {"south": "南", "north": "北", "": "两线"}


def route_of(c):
    return ROUTE.get(c.get("scope", ""), c.get("scope", ""))


def troop_name(c):
    return troops.get(c["troop"], {}).get("name", c["troop"])


# ---- chapters: one row per route-chapter (第一章 is one quest with two routes, split at x 23) ----
chapters = []  # (key, title, route, quest, x-range)
for q in story["quests"]:
    if q["id"] == "prologue":
        chapters.append(("prologue_s", "第一章 · 富春", "南", q, (0, 22)))
        chapters.append(("prologue_n", "第一章 · 冀州风云", "北", q, (23, 10 ** 6)))
    else:
        chapters.append((q["id"], q["title"], "北" if q.get("event_scope") == "north" else "南", q, None))


def in_range(s, xr):
    return xr is None or xr[0] <= s.get("x", 0) <= xr[1]


src = defaultdict(lambda: defaultdict(set))  # card -> chapter key -> {how}
pool_src = defaultdict(lambda: defaultdict(set))  # soldier -> chapter key -> {place}
for key, title, rt, q, xr in chapters:
    north_override = key == "prologue_n"
    ov = [o for o in q.get("pool_overrides", [])] if north_override else []
    recruit = ov[0]["recruit_pool"] if ov and ov[0].get("recruit_pool") else q.get("recruit_pool", [])
    for c in recruit:
        src[c][key].add("招贤")
    spool = ov[0]["soldier_pool"] if ov and ov[0].get("soldier_pool") else q.get("soldier_pool", [])
    for c in spool:
        pool_src[c][key].add("本章兵池")
    for s in q["squares"].values():
        if not in_range(s, xr):
            continue
        for c in s.get("cards", []):
            src[c][key].add("剧情「%s」" % s.get("label", ""))
        for o in s.get("choose", []):
            if o.get("card"):
                src[o["card"]][key].add("选择「%s」" % o.get("label", ""))
        for c in s.get("recruit_pool", []):
            src[c][key].add("招贤「%s」" % s.get("label", ""))
        for c in s.get("soldier_pool", []):
            pool_src[c][key].add("「%s」" % s.get("label", ""))
        if s.get("type") == "battle" and s.get("battle") in scenarios:
            foe = enemies[scenarios[s["battle"]]["enemy"]]
            if not foe.get("card_public") and foe.get("card"):
                src[foe["card"]][key].add("掉落")

event_offer = defaultdict(set)


def walk(effs, eid, scope):
    for e in effs:
        if "offer" in e:
            for c in e["offer"].get("from", []):
                event_offer[c].add("%s（%s）" % (story["events"][eid].get("title", eid), scope))
        for k in ("then", "else"):
            if k in e:
                walk(e[k], eid, scope)


for eid, ev in story["events"].items():
    for o in ev.get("options", []):
        walk(o.get("effects", []), eid, ev.get("scope", ""))

ch_title = {k: t for k, t, *_ in chapters}
ch_route = {k: r for k, _, r, *_ in chapters}
order = {k: i for i, (k, *_) in enumerate(chapters)}


def where(cid, with_pool=True):
    parts = []
    keys = set(src[cid]) | (set(pool_src[cid]) if with_pool else set())
    for k in sorted(keys, key=order.get):
        how = sorted(src[cid].get(k, set()))
        if with_pool and pool_src[cid].get(k):
            how.append("兵池" + "、".join(sorted(pool_src[cid][k])) if pool_src[cid][k] != {"本章兵池"} else "本章兵池")
        parts.append("%s：%s" % (ch_title[k], "、".join(how)))
    return parts


soldiers = {k: c for k, c in cards.items() if c.get("rarity", "N") == "N"}
generals = {k: c for k, c in cards.items() if c.get("rarity", "N") != "N"}


def category(cid, c):
    if c.get("beast"):
        return "野兽（不进宝箱）"
    if c.get("faction"):
        return "阵营 · " + FACTION.get(c["faction"], c["faction"])
    if src.get(cid):
        return "章节限定（只在发它的章节出）"
    return "公共 · %s（这条线每章都可能出）" % route_of(c)


out = ["# 武将与士兵名单（`python tools/roster.py --write` 自动生成，别手改）", "",
       "口径：", "",
       "- **公共**：没有哪一章发、也没挂阵营的兵，按 `scope` 在这条线（或两线）**每一章的宝箱里都可能出**。",
       "- **阵营**：挂了 `faction` 的兵，永远不进公共池，只从打它们的章节（敌人掉落）或写明的兵池里出。",
       "- **章节限定**：没挂阵营，但有章节发它（敌人掉落、剧情、招贤），只在那些章节的宝箱里出。",
       "- **兵池**：章节或格子的 `soldier_pool`，那个宝箱只出列表里的兵。",
       "- 宝箱按路线过滤：卡的 `scope` 和这一章的路线不符时不会出（下面「每章能出的兵」里标 ⚠）。", ""]

# ---------------- soldiers by category ----------------
out += ["## 一、士兵（N 卡）按类别", ""]
cats = defaultdict(list)
for cid, c in soldiers.items():
    cats[category(cid, c)].append(cid)
for cat in sorted(cats, key=lambda x: (not x.startswith("阵营"), not x.startswith("章节"), x)):
    out += ["### %s（%d）" % (cat, len(cats[cat])), "", "| 卡 | 名字 | 兵种 | 路线 | 出处 | 事件 |", "|---|---|---|---|---|---|"]
    for cid in sorted(cats[cat], key=lambda k: (route_of(soldiers[k]), troop_name(soldiers[k]), k)):
        c = soldiers[cid]
        out.append("| `%s` | %s%s | %s | %s | %s | %s |" % (cid, c["name"], "（精兵）" if c.get("elite") else "", troop_name(c), route_of(c),
                                                       "<br>".join(where(cid)) or "—", "、".join(sorted(event_offer.get(cid, []))) or "—"))
    out.append("")

# ---------------- soldiers per chapter ----------------
public = {r: sorted(k for k, c in soldiers.items() if not c.get("beast") and not c.get("faction") and not src.get(k) and route_of(c) in ("两线", r))
          for r in ("南", "北")}
out += ["## 二、每章能出的兵", "",
        "「本章」= 这一章打过的敌人掉的、剧情 / 招贤给的、兵池写的；另外这条线的公共兵每章都可能出（南线 %d 张、北线 %d 张，见上面公共类）。" % (len(public["南"]), len(public["北"])), ""]
for rt in ("南", "北"):
    out += ["### %s线" % rt, "", "| 章 | 本章的兵 |", "|---|---|"]
    for key, title, r, q, xr in chapters:
        if r != rt:
            continue
        here = sorted({cid for cid in soldiers if key in src[cid] or key in pool_src[cid]}, key=lambda k: soldiers[k]["name"])
        cells = []
        for cid in here:
            c = soldiers[cid]
            bad = route_of(c) not in ("两线", rt)
            tag = "（%s）" % FACTION.get(c["faction"], c["faction"]).split("（")[0] if c.get("faction") else ""
            cells.append("%s%s%s" % ("⚠" if bad else "", c["name"], tag))
        out.append("| %s | %s |" % (title, "、".join(cells) or "—"))
    out += ["", "%s线公共兵：%s" % (rt, "、".join(soldiers[k]["name"] for k in public[rt])), ""]

# ---------------- generals ----------------
out += ["## 三、武将", "",
        "「卡池」= `pool` 不是 false（宝箱 / 抽卡能抽到）；剧情限定 = 只能靠剧情、招贤、掉落拿到。", ""]
for rt in ("南", "北", "两线"):
    gs = [k for k, c in generals.items() if route_of(c) == rt]
    out += ["### %s（%d）" % ({"南": "南线", "北": "北线", "两线": "两线通用"}[rt], len(gs)), "",
            "| 卡 | 名字 | 稀有度 | 兵种 | 卡池 | 怎么拿到 |", "|---|---|---|---|---|---|"]
    rk = {"SSR": 0, "SR": 1, "R": 2, "C": 3}
    for cid in sorted(gs, key=lambda k: (rk.get(generals[k]["rarity"], 9), min([order[x] for x in src[k]] or [99]), k)):
        c = generals[cid]
        out.append("| `%s` | %s | %s | %s | %s | %s |" % (cid, c["name"], c["rarity"], troop_name(c), "是" if c.get("pool", True) else "剧情限定",
                                                     "<br>".join(where(cid, False)) or ("卡池" if c.get("pool", True) else "—（拿不到）")))
    out.append("")

out += ["### 每章入队、招贤、掉落的武将", "", "| 章 | 剧情入队 | 招贤 | 掉落 |", "|---|---|---|---|"]
for key, title, r, q, xr in chapters:
    join, rec, drop = [], [], []
    for cid in generals:
        how = src[cid].get(key, set())
        name = generals[cid]["name"]
        if any(h.startswith("剧情") or h.startswith("选择") for h in how):
            join.append(name)
        if any(h.startswith("招贤") for h in how):
            rec.append(name)
        if "掉落" in how:
            drop.append(name)
    out.append("| %s（%s线） | %s | %s | %s |" % (title, r, "、".join(join) or "—", "、".join(rec) or "—", "、".join(drop) or "—"))
doc = "\n".join(out) + "\n"

p = ROOT / "docs/ROSTER.md"
if "--check" in sys.argv:
    if not p.exists() or p.read_text("utf-8") != doc:
        print("docs/ROSTER.md is stale — run: python tools/roster.py --write")
        sys.exit(1)
    print("ROSTER.md is up to date")
elif "--write" in sys.argv:
    p.write_text(doc, "utf-8", newline="\n")
    print("docs/ROSTER.md written")
else:
    print(doc)
