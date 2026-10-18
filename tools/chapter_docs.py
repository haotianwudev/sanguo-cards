"""Generate one review file per chapter: docs/chapters/<NN>-<南线|北线>-<章名>.md, e.g. 07-北线-邺城惊雷.md (第一章 is split into its two routes).
   python tools/chapter_docs.py            # write every file
   python tools/chapter_docs.py --check    # exit 1 when any file is stale (pre-commit / CI)

Each file holds everything needed to check a chapter without opening the JSON: the header (requires, ending, pools), the
numbers, the map square by square (x / y / type / requires / next), the full script of every square in map order, every
battle (enemy, tier, turns, moves, the card it drops, its picture), the chapter's own ？ events, who joins / is recruited,
the soldiers its chests hand out, the CGs (drawn or missing) with their prompts and reference portraits, and the ending."""
import json, sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from gamedata import load_cards
import art_prompts as AP

db = load_cards()
cards, enemies, scenarios = db["cards"], db["enemies"], db["scenarios"]
story = json.loads((ROOT / "godot/data/story.json").read_text("utf-8"))
endings = json.loads((ROOT / "godot/data/endings.json").read_text("utf-8"))["endings"]
art = json.loads((ROOT / "pics/art.json").read_text("utf-8"))
OUT = ROOT / "docs/chapters"
TYPE = {"event": "剧情", "battle": "战斗", "choose": "选择", "treasure": "宝箱", "recruit": "招募", "recover": "休整", "mystery": "？"}


def cname(cid):
    return cards[cid]["name"] if cid in cards else cid


def flags(s):
    out = []
    if s.get("requires"):
        out.append("要：" + "、".join(s["requires"] if isinstance(s["requires"], list) else [s["requires"]]))
    if s.get("unless"):
        out.append("除非：" + "、".join(s["unless"] if isinstance(s["unless"], list) else [s["unless"]]))
    return "；".join(out)


def tier(s):
    return "首领" if s.get("boss") else "精英" if s.get("elite") else "普通"


def cg_block(key, scene):
    have = key in art.get("cgs", {})
    out = ["- `%s` %s" % (key, "✅ 已有" if have else "⬜ 缺")]
    if scene:
        out.append("  - 提示：" + scene)
        refs = AP.ref_portraits(scene, key)
        out.append("  - 参考立绘：" + ("；".join(refs) if refs else "（没有可参考的立绘）"))
    else:
        out.append("  - 提示：⚠ `tools/art_prompts.py` 里还没写")
    return out


def chapter_doc(key, q, xr, route):
    sq = {k: v for k, v in q["squares"].items() if xr is None or xr[0] <= v.get("x", 0) <= xr[1]}
    order = sorted(sq, key=lambda k: (sq[k].get("x", 0), sq[k].get("y", 0), k))
    battles = [k for k in order if sq[k]["type"] == "battle"]
    nb = {t: sum(1 for k in battles if tier(sq[k]) == t) for t in ("普通", "精英", "首领")}
    cgs = []
    for k in order:
        if sq[k].get("cg") and sq[k]["cg"] not in cgs:
            cgs.append(sq[k]["cg"])
    xs = [sq[k].get("x", 0) for k in order]
    ov = q.get("pool_overrides", [{}])[0] if key == "prologue_n" else {}
    title = "第一章 · 冀州风云" if key == "prologue_n" else "第一章 · 富春" if key == "prologue_s" else q["title"]
    end = endings.get(q.get("ending", ""), {}) if key != "prologue_n" else {}
    out = ["# %s（`%s`，%s线）" % (title, q["id"], route), "", "> `python tools/chapter_docs.py` 自动生成，别手改。改剧情去改 `godot/data/story.json`。", "",
           "## 概要", "",
           "| 项 | 内容 |", "|---|---|",
           "| 开启条件 | %s |" % ("、".join(q["requires"] if isinstance(q.get("requires"), list) else [q["requires"]]) if q.get("requires") else "—"),
           "| 副标题 | %s |" % (q.get("subtitle") or "—"),
           "| 格数 / 列数 | %d / %d（x %d–%d） |" % (len(sq), max(xs) - min(xs) + 1, min(xs), max(xs)),
           "| 战斗 普通 / 精英 / 首领 | %d / %d / %d |" % (nb["普通"], nb["精英"], nb["首领"]),
           "| ？ 格 | %d |" % sum(1 for k in order if sq[k]["type"] == "mystery"),
           "| CG 已有 / 合计 | %d / %d |" % (sum(1 for c in cgs if c in art.get("cgs", {})), len(cgs)),
           "| 招贤池 | %s |" % ("、".join(cname(c) for c in (ov.get("recruit_pool") or q.get("recruit_pool", []))) or "—"),
           "| 兵池 / 兵卡范围 | %s / %s |" % ("、".join(cname(c) for c in (ov.get("soldier_pool") or q.get("soldier_pool", []))) or "—", ov.get("soldier_scope") or q.get("soldier_scope") or "—"),
           "| 事件范围 | %s + 本章专属 |" % (ov.get("event_scope") or q.get("event_scope") or "—"),
           "| 洗牌组 | %s |" % ("；".join("、".join(g) for g in q.get("shuffle", [])) or "—"),
           "| 结局 | %s |" % (end.get("title", "—")), ""]
    # ---- map ----
    out += ["## 地图（按列）", "", "| x | y | 格子 | 类型 | 名字 | 条件 | 下一格 | 给什么 |", "|---:|---:|---|---|---|---|---|---|"]
    for k in order:
        s = sq[k]
        gives = []
        if s.get("cards"):
            gives.append("入队 " + "、".join(cname(c) for c in s["cards"]))
        if s.get("relics"):
            gives.append("宝物 " + "、".join(s["relics"]))
        if s.get("record"):
            gives.append("记「%s」" % s["record"])
        if s.get("recruit_pool"):
            gives.append("招募 " + "、".join(cname(c) for c in s["recruit_pool"]))
        if s.get("soldier_pool"):
            gives.append("兵池 " + "、".join(cname(c) for c in s["soldier_pool"]))
        nxt = list(s.get("next", [])) + ["→%s（%s）" % (o["goto"], o.get("label", "")) for o in s.get("choose", [])]
        if s.get("lose_goto"):
            nxt.append("输→" + s["lose_goto"])
        typ = TYPE.get(s["type"], s["type"]) + ("·" + tier(s) if s["type"] == "battle" else "")
        out.append("| %d | %d | `%s` | %s | %s | %s | %s | %s |" % (s.get("x", 0), s.get("y", 0), k, typ, s.get("label", ""), flags(s) or "—",
                                                                 "、".join(nxt) or "（终点）", "；".join(gives) or "—"))
    out.append("")
    # ---- script ----
    out += ["## 剧本（按地图顺序）", ""]
    for k in order:
        s = sq[k]
        if not (s.get("text") or s.get("prompt") or s.get("choose")):
            continue
        head = "### x%d · %s「%s」`%s`" % (s.get("x", 0), TYPE.get(s["type"], s["type"]), s.get("label", ""), k)
        out += [head, ""]
        if flags(s):
            out += ["*%s*" % flags(s), ""]
        if s.get("portraits"):
            out += ["立绘：" + "、".join(cname(p) if p in cards else p for p in s["portraits"]), ""]
        if s.get("prompt"):
            out += ["> " + s["prompt"], ""]
        for line in s.get("text", []):
            out.append("- " + line)
        for o in s.get("choose", []):
            extra = [x for x in ("要：" + "、".join(o["requires"] if isinstance(o["requires"], list) else [o["requires"]]) if o.get("requires") else "", "记「%s」" % o["record"] if o.get("record") else "",
                                 "入队 " + cname(o["card"]) if o.get("card") else "") if x]
            out.append("- **选项**「%s」→ `%s`%s" % (o.get("label", ""), o["goto"], "（%s）" % "；".join(extra) if extra else ""))
        out.append("")
    # ---- battles ----
    out += ["## 战斗", "", "| 格子 | 名字 | 档 | 敌人 | 回合 | 掉落 | 背景图 |", "|---|---|---|---|---:|---|---|"]
    for k in battles:
        s = sq[k]
        sc = scenarios.get(s.get("battle", ""), {})
        e = enemies.get(sc.get("enemy", ""), {})
        artkey = sc.get("art", s.get("battle", ""))
        out.append("| `%s` | %s | %s | %s（%s） | %s | %s | `%s` %s |" % (k, sc.get("name", s.get("label", "")), tier(s), e.get("name", "?"), sc.get("enemy", "?"),
                                                                   sc.get("turn_limit", "—"), cname(e.get("card", "")) if e.get("card") else "—",
                                                                   artkey, "✅" if artkey in art.get("battles", {}) else "⬜"))
    out += ["", "敌人招式：", ""]
    seen = set()
    for k in battles:
        en = scenarios.get(sq[k].get("battle", ""), {}).get("enemy", "")
        if en in seen or en not in enemies:
            continue
        seen.add(en)
        e = enemies[en]
        mv = []
        for m in e.get("moves", []):
            tags = [t for t in ("confuse", "ap_drain", "burn_party", "heal", "rage", "charge", "pierce") if t in m]
            mv.append(m["name"] + ("（%s）" % "、".join(tags) if tags else ""))
        out.append("- **%s** `%s`：血 %s / 攻 %s / 行动 %s；%s" % (e.get("name"), en, e.get("hp"), e.get("at"), e.get("actions"), "、".join(mv)))
    out.append("")
    # ---- events ----
    own = {eid: ev for eid, ev in story["events"].items() if ev.get("scope") == q["id"]}
    out += ["## 本章专属 ？ 事件（%d）" % len(own), ""]
    for eid, ev in own.items():
        out += ["### %s `%s`" % (ev.get("title", eid), eid), "", "> " + ev.get("prompt", ""), ""] + ["- " + t for t in ev.get("text", [])]
        for o in ev.get("options", []):
            out.append("- **选项**「%s」：%s" % (o["label"], json.dumps(o.get("effects", []), ensure_ascii=False)))
        out.append("")
    # ---- people ----
    joins = [(k, c) for k in order for c in sq[k].get("cards", [])] + [(k, o["card"]) for k in order for o in sq[k].get("choose", []) if o.get("card")]
    drops = sorted({enemies[scenarios[sq[k]["battle"]]["enemy"]].get("card", "") for k in battles if sq[k].get("battle") in scenarios} - {""})
    out += ["## 人和兵", "",
            "- **剧情入队**：" + ("、".join("%s（`%s`）" % (cname(c), k) for k, c in joins) or "—"),
            "- **掉落（打赢可能给）**：" + ("、".join(cname(c) for c in drops) or "—"),
            "- 全书的兵卡、武将来源见 `docs/ROSTER.md`。", ""]
    # ---- CGs ----
    out += ["## CG（%d）" % len(cgs), ""]
    for c in cgs:
        scene = AP.CGS.get(c)
        out += cg_block(c, scene if isinstance(scene, str) else None)
    out.append("")
    if end:
        out += ["## 结局：%s" % end.get("title", ""), "", "- 谁：%s" % end.get("who", ""), "- 触发：%s" % end.get("trigger", ""), "- 破局：%s" % end.get("unlock", ""),
                "- 铭文：%s" % end.get("text", ""), "- 结局卡：`%s` %s" % (end.get("cg", ""), "✅" if end.get("cg") in art.get("cgs", {}) else "⬜"), ""]
    return "\n".join(out) + "\n"


docs = {}
for q in story["quests"]:
    if q["id"] == "prologue":
        docs["prologue_s"] = chapter_doc("prologue_s", q, (0, 22), "南")
        docs["prologue_n"] = chapter_doc("prologue_n", q, (23, 10 ** 6), "北")
    else:
        docs[q["id"]] = chapter_doc(q["id"], q, None, {"north": "北", "universal": "南北"}.get(q.get("event_scope"), "南"))
CN = {"一": 1, "二": 2, "三": 3, "四": 4, "五": 5, "六": 6, "七": 7, "八": 8, "九": 9, "十": 10}


def chapter_number(cn: str) -> int:
    ## 七 → 7, 十 → 10, 十一 → 11, 二十 → 20
    if len(cn) == 1:
        return CN[cn]
    if cn.startswith("十"):
        return 10 + CN[cn[1]]
    return CN[cn[0]] * 10 + (CN[cn[2]] if len(cn) > 2 else 0)


def file_name(doc: str) -> str:
    ## 「07-北线-邺城惊雷」: the chapter number first so the folder sorts in reading order, then the route and the chapter name
    head = doc.split("\n", 1)[0].lstrip("# ")  # 第七章 · 邺城惊雷（`yecheng`，北线）
    title, rest = head.split("（", 1)
    num, name = title.split(" · ", 1)
    return "%02d-%s-%s" % (chapter_number(num.strip("第章")), "南北" if "南北线" in rest else "北线" if "北线" in rest else "南线", name.strip())


docs = {file_name(d): d for d in docs.values()}
index = ["# 每章检查文件（`python tools/chapter_docs.py` 自动生成，别手改）", "", "| 文件 | 章 |", "|---|---|"]
for k in sorted(docs):
    index.append("| [%s](%s.md) | %s |" % (k, k, docs[k].split("\n", 1)[0].lstrip("# ")))
docs["README"] = "\n".join(index) + "\n"

if "--check" in sys.argv:
    stale = [k for k, d in docs.items() if not (OUT / (k + ".md")).exists() or (OUT / (k + ".md")).read_text("utf-8") != d]
    extra = [p.stem for p in OUT.glob("*.md") if p.stem not in docs] if OUT.exists() else []
    if stale or extra:
        print("docs/chapters is stale (%s) — run: python tools/chapter_docs.py" % ", ".join(stale + extra))
        sys.exit(1)
    print("docs/chapters is up to date")
else:
    OUT.mkdir(parents=True, exist_ok=True)
    for p in OUT.glob("*.md"):
        if p.stem not in docs:
            p.unlink()
    for k, d in docs.items():
        (OUT / (k + ".md")).write_text(d, "utf-8", newline="\n")
    print("wrote %d files to docs/chapters" % len(docs))
