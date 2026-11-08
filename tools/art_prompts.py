"""Write pics/ART-PROMPTS.md: a ready-to-paste image prompt for every piece of art the game still needs.

    python tools/art_prompts.py

Portraits, battle CGs and story CGs each follow one template (composition + style are fixed so the set stays
consistent); only the subject lines differ. Items that already have final art in pics/art.json are skipped.
Add new characters / battles / scenes to the tables below when you add them to the game.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from gamedata import load_cards


ROOT = Path(__file__).resolve().parents[1]
PICS = ROOT / "pics"
NL = "\n"

DONGBAI = ("董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄长柄青铜骨朵（木柄缠皮绳，一端是圆球瓜棱形的青铜骨朵头，不是圆筒锤、不是方锤）（她已交付的立绘和 CG 都是这个样子）")
HERO = "主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的古铜鎏金旧甲（古铜色札甲、金边勾勒，胸甲与肩甲有云纹浮雕，鳞片纹甲裙与护腿，带划痕与旧锈），内衬朱红战袍，披纯黑色披风（无毛边），腰束带玉扣的皮带，肩扛孙坚的古锭刀（巨大的宽刃厚背砍刀，刀身像一整块带锈斑的铁板，刀背平直、刀尖斜削上翘，没有刀鞘；短柄缠棕色皮绳，圆形金色回纹护手，柄尾圆金属头；整个画面只有这一把刀，不要背带背刀、不要另一把剑）"
import re as _re
# the same lord without 古锭刀 on his shoulder, for scenes where he must be empty-handed (the generic line would otherwise put the broadsword back in)
HERO_NOBLADE = _re.sub(r"，?肩扛孙坚的古锭刀（.*?）(?=。|$)", "；手里、肩上、背上都没有任何兵器，不要古锭刀、不要大刀、不要任何刀剑", HERO)
NOBLADE_CGS = {"c8_fubing", "c8_qibing", "c8_caihe", "c8_zhangyun", "c8_zupu", "c8_shuige", "c9_changsha",
               "c11_hanqi", "c11_baihe_han", "c11_zhugejin", "c11_modao", "c11_liaochuang", "c12_liushou", "c12_qiqin", "c13_zhanglu",
               "s12_beifa", "s12_hushi", "s12_nanyang", "s12_sang", "s12_pangtong", "s12_kurou", "s12_dongfeng", "s12_guan", "tm_digong"}
# the same lord out of armor, for scenes whose own text says 常服 (at home, at a feast) — the armor line would otherwise put the armor and blade back
HERO_CASUAL = "主角：年轻男子，深棕近黑的短寸头（两侧推短、头顶短发微微上翘，额头露出，不要盖眉的刘海；现代发型，在汉代很扎眼），穿常服（和立绘 lord_south_casual 一样：深棕色交领长袍，青绿色镶金边的衣领与袖口，白色内衬领，黑色宽腰带；不穿任何盔甲、不披披风），手里、肩上、背上都没有任何兵器，不要古锭刀、不要任何刀剑"
HERO_NORTH_CASUAL = "北线主角：二十出头的年轻男子，干净斯文，浅棕色长发，头顶挽一个小发髻，其余长发披在肩背上，额前有碎刘海（不是现代短发，不缠布巾、不戴头带），穿常服（和立绘 lord_north_casual 一样：灰蓝色交领长袍，外披雪白狐裘，不穿任何鱼鳞甲或铁甲），手里、肩上、背上都没有任何兵器，不要长枪、不要任何刀剑"
HERO_NORTH = "北线主角：二十出头的年轻男子，干净斯文，浅棕色长发，头顶挽一个小发髻，其余长发披在肩背上，额前有碎刘海（不是现代短发，不缠布巾、不戴头带），穿甄宓亡父留下的河北式旧札甲（银灰色，不要绿色和金色），外披雪白毛领貂裘大氅（和立绘 lord_north 一样），手持白蜡杆长枪（枪头下系一个红色平安结）"
HERO_NORTH_NOBLADE = _re.sub(r"，?手持白蜡杆长枪（.*?）(?=。|$)", "；手里、肩上、背上都没有任何兵器，不要长枪、不要任何刀剑", HERO_NORTH)
NORTH_NOBLADE_CGS = {
    "n10_zhenmi", "n10_lianhuan", "n10_luoshui_bad", "n10_luoshang", "n10_huitou",
    "n11_start", "n11_beidu", "n11_huishi", "n11_qiye", "n11_kongming", "n11_yinzhang",
    "n11_nushang", "n11_xiaoxi", "n11_jin", "n11_g_xiaoxi", "n11_beimen", "n11_jianlou",
    "n11_tuishou", "n11_guanzhang", "n12_xuchang", "n12_guandu", "n12_huo", "n12_jiaozhang",
    "n12_nanzheng", "tm_xiangjian", "tm_digong",
}
HERO_SOUTH_EMPEROR = "南线主角：年轻男子，黑色短寸头（现代发型），身穿庄重华丽的汉代玄衣纁裳帝王冕服（不穿古铜旧甲），手里、肩上、背上都没有任何兵器，不要古锭刀、不要任何刀剑"
HERO_NORTH_EMPEROR = "北线主角：二十出头的年轻男子，干净斯文，头发束冠（不是现代短发），身穿庄重华丽的汉代玄衣纁裳帝王冕服（不穿鱼鳞甲、不披貂裘），手里、肩上、背上都没有任何兵器，不要长枪、不要任何刀剑"
HERO_MERGED = "归一后的主角：二十多岁的年轻男子，面容与南北线主角一致，中等长度黑发半束，身穿兼具江东古铜鎏金札甲与河北素铁鱼鳞甲特征的战甲，双手空着不拿任何兵器"
HERO_MODERN = "主角（穿越前）：三十岁的现代社畜，寸头，衬衫领带，一脸熬夜的疲惫；这时还没有穿越，不要古装、不要铠甲、不要兵器"


_NORTH_CGS: set = set()


def _north_cgs() -> set:
    ## every CG the north route shows: squares the north walks, the ？ events only the north draws, and north endings —
    ## which squares / events are the north's is the game's answer (tools/facts.py), not key prefixes or x ranges
    if not _NORTH_CGS:
        from facts import load_facts
        gd = ROOT / "godot" / "data"
        story = json.loads((gd / "story.json").read_text("utf-8"))
        quests = {q["id"]: q for q in story["quests"]}
        chapters = load_facts()["chapters"]
        drawn = {r: {e for ch in chapters if ch["route"] == r for e in ch["event_pool"]} for r in ("north", "south")}
        walked = {r: {(ch["quest"], sid) for ch in chapters if ch["route"] == r for sid in ch["squares"]} for r in ("north", "south")}
        for qid, sid in walked["north"] - walked["south"]:  # 第一章's birth square is both routes': not the north's own
            if quests[qid]["squares"][sid].get("cg"):
                _NORTH_CGS.add(quests[qid]["squares"][sid]["cg"])
        for eid in drawn["north"] - drawn["south"]:
            _NORTH_CGS.add(eid)  # an event's prompt is keyed by its id
            if story["events"][eid].get("cg"):
                _NORTH_CGS.add(story["events"][eid]["cg"])
        for e in json.loads((gd / "endings.json").read_text("utf-8"))["endings"].values():
            if e.get("cg") and e.get("route") == "north":
                _NORTH_CGS.add(e["cg"])
    return _NORTH_CGS


def _is_north_key(key: str, scene: str = "") -> bool:
    if key and (key.startswith(("jz_", "ln_", "n4_", "n5_", "n6_", "n7_", "n8_", "n9_", "n10_", "n11_", "n12_"))
                or key == "tm_xiangjian" or key.endswith("_north") or key in _north_cgs()):
        return True
    return "北线主角" in scene and "南线主角" not in scene


def hero_note(key: str, scene: str = "") -> str:
    ## which outfit line a CG gets: before the transmigration (the opening), dual-protagonist scenes, north route, or south default
    if key in ("c1_era",):
        return HERO_MODERN
    if "归一后的主角" in scene or key == "tm_end":
        return HERO_MERGED
    if "南线主角" in scene and "北线主角" in scene:
        if key in ("tm_start", "tm_jinggao"):
            return f"{HERO}。{HERO_NORTH}"
        if key == "n12_jiaozhang":
            return f"{HERO_NORTH_NOBLADE}。{HERO}"
        return f"{HERO_NOBLADE}。{HERO_NORTH_NOBLADE}"
    if "帝服" in scene or "帝王冕服" in scene:
        return HERO_NORTH_EMPEROR if _is_north_key(key, scene) else HERO_SOUTH_EMPEROR
    if _is_north_key(key, scene):
        if "常服" in scene:
            return HERO_NORTH_CASUAL
        if key in NORTH_NOBLADE_CGS or "不带长枪" in scene or "不拿长枪" in scene:
            return HERO_NORTH_NOBLADE
        return HERO_NORTH
    if "常服" in scene:
        return HERO_CASUAL
    if key in NOBLADE_CGS or "不带大刀" in scene or "不扛大刀" in scene or "不带刀" in scene:
        return HERO_NOBLADE
    return HERO
STYLE = ("复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳")
PORTRAIT_COMPOSITION = ("竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处，头部完整且顶部留有充分余量，无边缘裁切。"
                        "姿势要生动，不要呆板：禁止正面直立、双手垂在身侧、像证件照一样的站姿；"
                        "身体要有扭转和重心（侧身回眸、半步前跨、微倾或拧腰），手上要有正在做的动作（握武器、整衣、抬手、指向某处），"
                        "视线和神情随人物性格带戏，武器、披风、衣摆和发丝带出动势。")
# Backgrounds are now atmospheric and character-specific per user directive

# key: (name line, appearance, armor & clothing, weapon / pose)
# the prompt tables are data: pics/prompts/<table>.json, one entry per line (edit them there)
PROMPTS = ROOT / "pics" / "prompts"
PORTRAITS = json.loads((PROMPTS / "portraits.json").read_text("utf-8"))
BATTLES = json.loads((PROMPTS / "battles.json").read_text("utf-8"))
CGS = json.loads((PROMPTS / "cgs.json").read_text("utf-8"))
MAPS = json.loads((PROMPTS / "maps.json").read_text("utf-8"))
RELICS = json.loads((PROMPTS / "relics.json").read_text("utf-8"))
EVENTS = json.loads((PROMPTS / "events.json").read_text("utf-8"))
FATES = json.loads((PROMPTS / "fates.json").read_text("utf-8"))
AFFIXES = json.loads((PROMPTS / "affixes.json").read_text("utf-8"))
UI_ART = json.loads((PROMPTS / "ui_art.json").read_text("utf-8"))
CHESTS = json.loads((PROMPTS / "chests.json").read_text("utf-8"))
OVERRIDES = json.loads((PROMPTS / "overrides.json").read_text("utf-8"))
PORTRAITS = {k: tuple(v) for k, v in PORTRAITS.items()}

# battle scenario id: the scene (the enemy in its setting, Rance X style)

# story cg key: the scene


# hand-written prompts that replace the template for a key (e.g. the owner's own prompt for a scene).
# They stay here after the art exists (ART-PROMPTS.md only lists what is still missing), so a redraw starts from the same prompt.
# chapter map backgrounds (quest id -> what the scroll shows, left to right); the game scrolls it sideways under the squares

# relic icons (cards.json relics id -> the object itself)
# Authentic ancient Chinese items, pure cut-outs on transparent backgrounds (no western circular medallion).
# Excluded lord/protagonist relics per user instruction: jiujia, hupi, qixing, zhaoxianbang, yitian, yuxi.


# ？ event illustrations (event id -> scene); shown full-screen when the event comes up, like a story CG (key e_<id>)
# 天命 pictures (cards.json fates id -> symbol); godot/data/art/fates/<id>.png, shown on the 天命 pick
# 词缀 badges (cards.json battle.affixes id -> symbol); godot/data/art/affixes/<id>.png, shown in the battle info
# full-screen UI pictures: godot/data/art/ui/<key>.jpg


# 下一批（交给 Gemini）不再手写：每次运行都从游戏数据（cards.json / story.json / endings.json / side_stories.json）里
# 算出「游戏正在用、但还没交付」的图，按下面的优先级排。游戏里没用到的图不会出现在这里。
# 优先级（越靠前越先画）：
#   0 占位 / 缺失的立绘      —— 角色一出场就是占位图
#   1 首领战斗图             —— 首领战没图只有空底；按章节顺序
#   2 精英战斗图
#   3 主线剧情 CG            —— 格子和幕间的 CG，按章节顺序、章内按格子位置
#   4 常用战斗背景           —— 普通战斗；多个战斗共用同一张的、出现次数多的排前
#   5 宝物图标               —— 现在是文字圆章；稀有的 / 诅咒 / 主角专属排前
#   6 结局象征画             —— 已实装的结局
#   7 奇遇插图（？格事件）、小故事插图 —— 随机抽到 / 可选的，缺了只是少一张图；小故事排在奇遇前
#   8 未实装内容             —— 还没做出来的结局等
TIER_NAMES = {0: "立绘（占位 / 缺）", 1: "首领战斗图", 2: "精英战斗图", 3: "主线剧情 CG", 4: "普通战斗背景",
              5: "宝物图标", 6: "结局象征画", 7: "奇遇 / 小故事插图", 8: "未实装内容"}
EXTRA_NEXT = [("cg", "end_locked", "结局图鉴「未解锁」缩略图（16:9，暗色印章问号）", 8)]


# chapter maps already delivered but the chapter's squares changed since: redraw (key -> why). A redraw counts as done once
# art_ingest.py has logged one more delivery of that map than `seen` here.
MAP_REDO = {"tianfu": ("第九章南线雒城之后新增绵竹关 1 列、成都酒肆 2 列（法正的选择），共 44 列（第 20 列以后的列号整体 +3）", 2), "menghu": ("第八章南线开头新增 6 列丹阳深山讨伐山越，中段加 3 组岔路（南阳道、汉水北岸、白河上游），共 48 列（提示词已按新布局写好）", 1), "huainan_s": ("第六章南线开头新增 6 列荆南四郡（零陵 / 桂阳 / 长沙），结尾去掉双婚喜堂；陆家旧宅后又多了一列（陆逊的选择），共 55 列（提示词里第 17 列以后的列号要整体 +1）", 1), "jiangdong": ("第七章南线开头新增 1 列庐江喜堂（双婚），共 41 列（提示词已按新布局写好）", 1), "yuxi": ("第三章两条路线上下分层（上 B 下 A），共 61 列 6 行（提示词已按新布局写好）", 1), "huainan_n": ("第六章北线比武多一场张飞（第 28 列以后 +1）；比武之后、庆功宴之前新增 2 列寿春岔路；纪灵之后、尿遁之后各多一个下方岔路格；回下邳之前新增 3 列琅邪道泰山贼；淮河渡口之后新增 1 列渡口雪夜（第 6 列以后再 +1）；共 47 列", 1), "yecheng": ("第七章北线开头新增 1 列杜家酒坊（所有列号整体 +1）", 1)}


def map_redo() -> dict:
    log = ROOT / "pics" / "ART-LOG.md"
    text = log.read_text("utf-8") if log.exists() else ""
    return {k: why for k, (why, seen) in MAP_REDO.items() if text.count(f"map `{k}` ←") <= seen}


def build_next(delivered: dict) -> list:
    """[(kind, key, what, tier)] still missing and used by the game, in drawing order."""
    gd = ROOT / "godot" / "data"
    cards = load_cards(gd)
    story = json.loads((gd / "story.json").read_text("utf-8"))
    endings = json.loads((gd / "endings.json").read_text("utf-8"))["endings"]
    side = json.loads((gd / "side_stories.json").read_text("utf-8")) if (gd / "side_stories.json").exists() else {}
    sc, en = cards["scenarios"], cards["enemies"]
    qidx = {q["id"]: i for i, q in enumerate(story["quests"])}
    found: dict = {}  # (kind, key) -> (tier, sort tuple, what)

    def put(kind, key, tier, order, what):
        if key in delivered[kind] and not (kind == "map" and key in map_redo()) and key not in {r[0] for r in REDO}:
            return
        old = found.get((kind, key))
        if old is None or (tier, order) < (old[0], old[1]):
            found[(kind, key)] = (tier, order, what)

    uses: dict = {}  # battle art key -> number of squares / event fights using it
    for q in story["quests"]:
        for s in q["squares"].values():
            if s.get("battle"):
                k = sc[s["battle"]].get("art", s["battle"])
                uses[k] = uses.get(k, 0) + 1
    for q in story["quests"]:
        qi = qidx[q["id"]]
        for sid, s in q["squares"].items():
            x = s.get("x", 0)
            if s.get("battle"):
                scn = sc[s["battle"]]
                key = scn.get("art", s["battle"])
                who = en[scn["enemy"]]["name"]
                what = f"{q['title']}·{s.get('label', sid)}（{who}）"
                if s.get("boss"):
                    put("battle", key, 1, (qi, x), what + " 首领")
                elif s.get("elite"):
                    put("battle", key, 2, (qi, x), what + " 精英")
                else:
                    put("battle", key, 4, (-uses[key], qi, x), what)
            if s.get("cg"):
                put("cg", s["cg"], 3, (qi, x), f"{q['title']}·{s.get('label', sid)}")
            for pk in s.get("portraits", []):
                put("portrait", pk, 0, (qi, x), f"{q['title']}·{s.get('label', sid)} 里出场")
        if q.get("ending"):
            end = endings.get(q["ending"]) if isinstance(q["ending"], str) else q["ending"]
            if end and end.get("cg"):
                put("cg", end["cg"], 6, (qi,), f"结局卡·{end.get('title', '')}（象征画）")
        for pg in side.get("chapters", {}).get(q["id"], []):  # the chapter-end page's picture (also that card's portrait)
            if pg.get("cg"):
                put("cg", pg["cg"], 3, (qi, 10**6 + 1), f"{q['title']}·章末页面（过场 CG，也是卡）")
        for st in side.get("after", {}).get(q["id"], []):  # ？小故事: optional, like the 奇遇 pictures
            if st.get("cg"):
                put("cg", st["cg"], 7, (-1, qi, st["id"]), f"{q['title']}·小故事「{st.get('title', '')}」")
            for pk in st.get("portraits", []):
                put("portrait", pk, 0, (qi, 10**6), f"{q['title']}·小故事「{st.get('title', '')}」里出场")
    scope_rank = {"universal": 0}
    for eid, ev in story["events"].items():
        if ev.get("cg"):
            sco = ev.get("scope", "south")
            put("cg", ev["cg"], 7, (scope_rank.get(sco, 1), qidx.get(sco, 50), eid), f"奇遇「{ev.get('title', eid)}」")
        for o in ev.get("options", ev.get("choose", [])):
            for ef in o.get("effects", []):
                if "battle" in ef:
                    scn = sc[ef["battle"]]
                    key = scn.get("art", ef["battle"])
                    put("battle", key, 4, (-uses.get(key, 0), 99, 0), f"奇遇「{ev.get('title', eid)}」里的战斗（{en[scn['enemy']]['name']}）")
    for eid, e in endings.items():
        if e.get("cg"):
            put("cg", e["cg"], 6 if e.get("built") else 8, (list(endings).index(eid),), f"结局「{e['title']}」（象征画{'' if e.get('built') else '，尚未实装'}）")
    rank = {"story": 0, "curse": 1, "rare": 2, "common": 3}
    for i, (rid, r) in enumerate(cards["relics"].items()):
        put("relic", rid, 5, (rank.get(r.get("rarity", "common"), 3), i), f"{r['name']}（宝物图标）")
    for cid, c in cards["cards"].items():
        put("portrait", c.get("person", cid), 0, (-1, 0), f"{c['name']}（{c.get('rarity', 'N')} {cards['troops'][c['troop']]['name']}）")
    for eid, e in en.items():
        put("portrait", e.get("portrait") or eid, 0, (-1, 1), f"{e['name']}（敌人）")
    for q in story["quests"]:  # chapter maps
        for key in [q["id"]] + [o["map"] for o in q.get("map_overrides", []) if o.get("map")]:
            put("map", key, 1, (-1, qidx[q["id"]]), f"{q['title']} 地图底图")
    for kind, key, what, tier in EXTRA_NEXT:
        put(kind, key, tier, (0,), what)
    out = sorted(found.items(), key=lambda kv: (kv[1][0], kv[1][1]))
    return [(k[0], k[1], v[2], v[0]) for k, v in out]

# the chest sprites the chest-opening animation uses (godot/data/art/ui/chest_<key>.png)
# already delivered but wrong somewhere: redraw (listed above the batch)
# (key, why, seen): `seen` = how many times art_ingest.py had already logged that key; one more delivery clears the entry
REDO = [
    ("c14_beiwang", "北边的人退往许昌、不是过黄河：场景改成黄昏的邙山两面山坡，北线主角身边不再有诸葛亮（他被扣在帐里），赵云勒马回头", 1),
    ("m11_zhaoyun", "赵云殿后的地方从孟津渡口改成偃师道路口：没有河、没有渡船，义军大队沿大路往东走远", 1),
    ("m11_bei_nu", "并州弩手护着的队伍是沿大路往东撤，不是上船过河：去掉河和渡船，改成邙山东麓的坡地", 2),
    ("c8_fubing", "宴会段的主角要穿他标志性的古铜鎏金旧甲，现图穿的是素色常服", 1),
    ("c8_qibing", "宴会段（黄忠射骑兵）的主角要穿古铜鎏金旧甲，现图穿的是素色常服", 1),
    ("c8_caihe", "宴会段的主角要穿古铜鎏金旧甲，现图穿的是素色常服", 1),
    ("c8_zhangyun", "宴会段的主角要穿古铜鎏金旧甲，现图穿的是素色常服", 1),
    ("c8_zupu", "主角肩上扛着一把大刀要去掉：穿甲但双手空着，整个画面没有任何刀剑", 2),
    ("c8_shuige", "貂蝉喝酒这张主角拿着大刀要去掉：穿甲但双手空着，不拿任何兵器", 2),
    ("c6_seal", "孙坚手里捧着紫色龙纹盒子要去掉：他说不知玉玺下落，双手必须是空的，殿上也不能有任何盒子 / 锦盒 / 箱子", 2),
    ("c9_lusu", "要加上诸葛瑾：第六章居巢这一格他在场（替鲁肃管粮仓的账），站在粮囤门口捧着账册；主角肩上扛的大刀也去掉（盔甲不用改），双手空着", 2),
    ("c10_ganning", "提灯笼的主角穿成了绿色长袍：要换成他的古铜鎏金旧甲、朱红内衬、纯黑披风、短寸头", 1),
    ("c6_warn", "主角要换成常服、短寸头（现图穿甲、扛大刀、盖眉长刘海）：参考立绘 `pics/source/generals/lord_south_casual.jpg`，双手空着；画面仍只有貂蝉和主角两个人", 3),
]
NEXT_RULES = [
    "每张图都用下面对应小节的**完整提示词**；图上长相/器物必须和设定对得上（见 `CARD-DESIGN.md` 第 7 节）。",
    "宝物：纯中式汉代古风器物，独立透明背景（纯白背景抠图，无圆盘边框，无西式奇幻符号），日系战术卡牌 RPG 赛璐珞道具插画风。",
    "女性角色一律画成成年人；董白不写年龄、不画成萝莉。",
    "卡牌立绘必须带背景：背景为符合人物身份与阵营的古风场景（军营、要塞、江岸、山林、宫室等，具自然景深与环境光影，不再使用纯白/摄影棚素底）。人物半身居中，面部在上方三分之一。",
    "文件名 = key：宝物放 `pics/source/relics/<key>.png`（同时复制到 `godot/data/art/relics/<key>.png`），立绘放 `pics/source/generals/`（兵卡放 `soldiers/`）。",
    "战斗 CG 放 `pics/source/battles/<key>.jpg`、在 `pics/art.json` 的 battles 登记；构图：敌人大、居中、在画面中上部。",
    "宝箱图：PNG 透明底 512×512，直接放 `godot/data/art/ui/<key>.png`（开宝箱动画会自动用上）。",
    "立绘在 `pics/art.json` 对应段登记；然后跑 `python tools/sanguo_art.py`，再跑 `python tools/art_prompts.py` 刷新本文件。",
    "每条提示词下面的「参考立绘」列出画面里每个人物已交付的立绘文件，出图时一起上传给 Gemini；主角穿常服的场景参考 `lord_south_casual` / `lord_north_casual`，其余参考 `lord` / `lord_north`。",
    "**不要覆盖已经交付的图**；重画某张时旧图别留在 `pics/source/` 里（`backup_old/` 之类的文件夹不要提交）。",
    "提交时按路径 `git add`，只提交自己的图和登记，别带上别人没提交的改动。",
]


def map_prompt(scene: str) -> str:
    return (f"横向游戏地图插画，手绘中国山水长卷（浅绛 / 青绿山水）：{scene}。{NL}"
            f"构图：超宽全景，3200x1080（可横向滚动），斜向高空俯瞰；上 / 中 / 下三条大致水平的行进带保持干净、不放繁杂细节（地图格子落在上面），薄雾轻绕。{NL}"
            f"画风：与第一章地图（godot/data/art/map/prologue.jpg）一致：墨线勾勒，宣纸上的淡绿与赭石淡彩；"
            f"不要文字、不要 UI、不要近景人物。")


def relic_prompt(obj: str, rarity: str) -> str:
    return (f"杰作级 1:1 方形游戏道具图标：{obj}。{NL}"
            f"构图：方形 256x256（按 1024x1024 绘制），道具单件独立展示，居中，带动感的斜角摆放。{NL}"
            f"纯白底（#ffffff），干净抠图，无边框、无外框、无圆形奖章底、无符文、无西式奇幻元素。{NL}"
            f"画风：纯正的中国三国古风器物质感，复古日系动漫 RPG 战术游戏道具插画，参考《兰斯10》画风，墨线干净利落，赛璐珞上色浓郁，金属高光细腻；不要文字。")




PORTRAIT_HEAD = "角色立绘半身像，三国历史战棋视觉小说立绘，兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳的厚重色彩。"


def portrait_prompt(p: tuple, key: str = None) -> str:
    ## p = (name, look, clothes, weapon[, background]) from pics/prompts/portraits.json
    name, look, clothes, weapon = p[:4]
    bg = p[4] if len(p) >= 5 else "与人物身份相符的三国古风场景，柔和自然光"
    return (f"{PORTRAIT_HEAD}{NL}"
            f"{name}的竖版人物立绘。{NL}"
            f"外貌：{look}{NL}"
            f"铠甲与服饰：{clothes}{NL}"
            f"武器：{weapon}{NL}"
            f"背景：{bg}。{NL}"
            f"构图：{PORTRAIT_COMPOSITION}{NL}"
            f"画风：{STYLE}，带氛围的环境光，景深柔和，背景有景致但服从于人物。")


def battle_prompt(scene: str, key: str = None) -> str:
    return (f"横版战斗场景插画：{scene}。{NL}"
            f"构图：横版 16:9，1920x1080，写实临场感低机位镜头；核心敌将或敌军居中偏上（头 / 脸位于距画面顶部约 30%–45% 区域），所有参战武将、士兵、战马与战船必须脚踏实地处于同一真实物理空间，严禁在天空中画任何巨大的半透明人物虚影、背后灵或虚空浮影；前景自然延伸真实战场地面。{NL}"
            f"画风：{STYLE}，戏剧化写实战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。")


def cg_prompt(scene: str, key: str = None, is_event: bool = False) -> str:
    return (f"横版剧情事件插画：{scene}。{NL}"
            f"构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。"
            f"画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。{NL}"
            f"画风：{STYLE}，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。"
            + (f"{NL}（主角出场时——{hero_note(key, scene)}。）" if "主角" in _wanted(scene) else "")
            + (f"{NL}（{DONGBAI}。）" if ("董白" in _wanted(scene) or "Dong Bai" in scene) else ""))


_NAMES: dict = {}
import re as _re2
_NEG = _re2.compile(r"不要|没有|别画|去掉|不能|不出现")


def _wanted(text: str) -> str:
    ## the prompt minus its clauses about who/what must NOT be in the picture
    return "，".join(s for s in _re2.split(r"[，。；、,;]", text) if not _NEG.search(s))


_EARLY_NORTH = ("jz_", "ln_", "c2_ln", "c3_", "c4_", "hs_", "bh_", "xz_", "n5_", "hnn_", "n6_", "taihang_", "zhen_caravan")


def _young_zhenmi(text: str, key: str) -> bool:
    ## 甄宓 is a child until 北线第七章: an age note next to her name, or an early north scene without 成年, means the young portrait
    i = text.find("甄宓")
    near = text[i:i + 24] if i >= 0 else ""
    if "成年" in near:
        return False
    return any(w in near for w in ("十几岁", "少女", "孩子", "小姑娘", "十三", "十四")) or key.startswith(_EARLY_NORTH)


def ref_portraits(text: str, key: str) -> list[str]:
    ## the delivered portraits a scene should be drawn from: every card name the prompt mentions (clauses that say who must NOT be
    ## there are skipped) plus the lord when 主角 appears — south `lord`, north `lord_north`, none before the transmigration
    if not _NAMES:
        portraits = json.loads((PICS / "art.json").read_text("utf-8"))["portraits"]
        for cid, c in load_cards()["cards"].items():
            pk = c.get("person") or cid
            name = _re2.sub(r"「[^」]*」", "", c["name"]).split("·")[0]  # 「河北庭柱」颜良 → 颜良
            if (pk in portraits or pk in PORTRAITS) and (not c.get("soldier") or len(name) >= 3) and name not in _NAMES:
                src = portraits[pk]["src"] if pk in portraits else f"source/{'soldiers' if c.get('rarity') == 'N' else 'generals'}/{pk}.jpg"
                _NAMES[name] = (pk, src)
        for pk, brief in PORTRAITS.items():  # portraits with no card of their own (enemies such as 郭图 / 袁谭 / 审配)
            m = _re2.search(r"[（(]([一-鿿]{2,4})[)）]", brief[0] if isinstance(brief, (tuple, list)) else str(brief))
            if m and m.group(1) not in _NAMES:
                _NAMES[m.group(1)] = (pk, portraits[pk]["src"] if pk in portraits else f"source/generals/{pk}.jpg")
        _NAMES["__lord"] = {k: (k, portraits[k]["src"]) for k in ("lord", "lord_north", "lord_south_casual", "lord_north_casual") if k in portraits}
        _NAMES["__young"] = {k: portraits[k]["src"] for k in ("zhenmi_young",) if k in portraits}
    keep = _wanted(text)
    out, seen = [], set()
    if "主角" in keep and key != "c1_era":
        if "归一后的主角" in keep:
            for label, lk in (("南线主角（合并参考）", "lord"), ("北线主角（合并参考）", "lord_north")):
                if lk in _NAMES["__lord"] and lk not in seen:
                    out.append(f"{label} → `pics/{_NAMES['__lord'][lk][1]}`")
                    seen.add(lk)
            keep = keep.replace("归一后的主角", "")
        if "南线主角" in keep:
            lk = "lord_south_casual" if "常服" in keep else "lord"
            if lk in _NAMES["__lord"] and lk not in seen:
                out.append(f"南线主角 → `pics/{_NAMES['__lord'][lk][1]}`")
                seen.add(lk)
            keep = keep.replace("南线主角", "")
        if "北线主角" in keep:
            lk = "lord_north_casual" if "常服" in keep else "lord_north"
            if lk in _NAMES["__lord"] and lk not in seen:
                out.append(f"北线主角 → `pics/{_NAMES['__lord'][lk][1]}`")
                seen.add(lk)
            keep = keep.replace("北线主角", "")
        if "主角" in keep:
            north = _is_north_key(key, keep)
            lk = ("lord_north" if north else "lord") + ("_casual" if "常服" in keep else "")
            lk = {"lord_casual": "lord_south_casual"}.get(lk, lk)
            if lk in _NAMES["__lord"] and lk not in seen:
                out.append(f"主角 → `pics/{_NAMES['__lord'][lk][1]}`")
                seen.add(lk)
            keep = keep.replace("主角", "")
    for name in sorted((n for n in _NAMES if not n.startswith("__")), key=len, reverse=True):
        pk, src = _NAMES[name]
        if pk == "zhenmi" and _young_zhenmi(keep, key) and "zhenmi_young" in _NAMES["__young"]:
            pk, src = "zhenmi_young", _NAMES["__young"]["zhenmi_young"]
        if name in keep and pk not in seen:
            seen.add(pk)
            keep = keep.replace(name, "")
            out.append(f"{name} → `pics/{src}`")
    return out


def ref_lines(text: str, key: str) -> list[str]:
    refs = ref_portraits(text, key)
    return [f"参考立绘（一起上传给 Gemini，保持长相一致）：{'；'.join(refs)}", ""] if refs else []


def render_item(header: str, prompt: str) -> list[str]:
    return [header, "", "```", prompt, "```", ""]


def fate_prompt(sym: str) -> str:
    return (f"肉鸽游戏「天命」卡的方形徽记插画：{sym}。{NL}"
            f"构图：方形 512x512（按 1024x1024 绘制），图案居中，嵌在细金边的圆形玉金奖章内，透明背景（PNG）。{NL}"
            f"画风：{STYLE}，彩绘徽记，轮廓醒目，缩到 112px 仍能看清；不要文字。")


def affix_prompt(sym: str) -> str:
    return (f"游戏小徽章图标：{sym}，画成红色中式印章（朱印），图案刻在印中。{NL}"
            f"构图：方形 128x128（按 512x512 绘制），透明背景（PNG），形状粗壮简洁，缩到 28px 仍清晰。{NL}"
            f"画风：水墨与朱砂，边缘利落；不要文字。")


def ui_prompt(scene: str) -> str:
    return (f"{scene}的横版主视觉插画。{NL}"
            f"构图：横版 16:9，1920x1080；画面在菜单下方会被压暗显示。{NL}"
            f"画风：{STYLE}，史诗电影感光线，绘画感天空；不要文字、不要标志、不要 UI。{NL}"
            f"（主角——{HERO}。）")


def main() -> None:
    art = json.loads((PICS / "art.json").read_text("utf-8"))
    done = {k for k, v in art["portraits"].items() if not v.get("placeholder")}
    import re as _re0
    _log0 = ROOT / "pics" / "ART-LOG.md"  # art_ingest.py records what was delivered: a REDO entry replaced since is done
    _txt0 = _log0.read_text("utf-8") if _log0.exists() else ""
    REDO[:] = [r for r in REDO if len(_re0.findall(r"`" + r[0] + r"` ←", _txt0)) <= r[2]]
    out = ["# 出图提示词", "",
           "> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。",
           "> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。",
           "> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，",
           "> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `python tools/sanguo_art.py`（见 `CARD-DESIGN.md`）。", "",
           ]
    maps_done = {k for k, v in art.get("maps", {}).items() if "程序生成" not in v.get("license", "")}
    # the 22 icons made by generate_ui_assets.py (a gold medallion with one character) are placeholders, not delivered art:
    # pics/relic_placeholders.json lists them; `art_ingest.py` removes a key once its real icon arrives
    _ph = set(json.loads((ROOT / "pics" / "relic_placeholders.json").read_text("utf-8"))) if (ROOT / "pics" / "relic_placeholders.json").exists() else set()
    relics_done = {p.stem for p in (ROOT / "godot" / "data" / "art" / "relics").glob("*.png")} - _ph
    ui_done = {k for k in CHESTS if (ROOT / "godot" / "data" / "art" / "ui" / f"{k}.png").exists()}
    delivered = {"portrait": done, "cg": set(art.get("cgs", {})), "map": maps_done, "relic": relics_done,
                 "battle": set(art.get("battles", {})), "ui": ui_done}
    todo = build_next(delivered)
    need = {(k, key) for k, key, _, _ in todo}  # the sections below list only what the game uses and still lacks
    if todo:
        out += ["## 下一批（交给 Gemini）", "", "按顺序画；交付后重跑本脚本，这一条会自动消失。", ""]
        if REDO or map_redo():
            out += ["**先重画**（已交付但有地方不对）：", ""] + [f"- `{r[0]}` — {r[1]}" for r in REDO] + [f"- `{k}`（地图）— {why}" for k, why in map_redo().items()] + [""]
        kind_name = {'portrait': '立绘', 'cg': '剧情 CG', 'map': '地图', 'relic': '宝物', 'battle': '战斗 CG', 'ui': '界面'}
        out += [f"共 {len(todo)} 张，按优先级分档（全部由游戏数据算出，游戏里没用到的不列）：", ""]
        n = 0
        last = None
        for kind, key, what, tier in todo:
            if tier != last:
                last = tier
                cnt = sum(1 for x in todo if x[3] == tier)
                out += ["", f"**第 {tier} 档 · {TIER_NAMES[tier]}（{cnt}）**", ""]
            n += 1
            out.append(f"{n}. `{key}` — {what}（{kind_name[kind]}）")
        out += ["", "交图规则：", ""] + [f"- {r}" for r in NEXT_RULES] + [""]
    out += ["## 立绘（竖版 3:4）", ""]
    redo = {r[0] for r in REDO}
    for key, p in PORTRAITS.items():
        if key in done and key not in redo:
            continue
        if ("portrait", key) not in need:
            continue
        status = "🟡 换掉占位" if key in art["portraits"] else "⬜ 缺"
        hdr = f"### `{key}` {status}"
        if key in OVERRIDES:
            out += [hdr, "", "```", OVERRIDES[key], "```", ""]
        else:
            zh = portrait_prompt(p, key)
            out += render_item(hdr, zh)
    out += ["## 战斗 CG（横版 16:9，每场战斗一张）", ""]
    for key, scene in BATTLES.items():
        if (key in art.get("battles", {}) and key not in redo) or ("battle", key) not in need:
            continue
        hdr = f"### `{key}`"
        if key in OVERRIDES:
            out += [hdr, "", "```", OVERRIDES[key], "```", ""]
            out += ref_lines(OVERRIDES[key], key)
        else:
            zh = battle_prompt(scene, key)
            out += render_item(hdr, zh)
            out += ref_lines(zh.split(NL)[0], key)  # the scene line only: the appended outfit notes would match names
    out += ["## 剧情插图 CG（横版 16:9）", ""]
    for key, scene in CGS.items():
        if (key in art.get("cgs", {}) and key not in redo) or ("cg", key) not in need:
            continue
        hdr = f"### `{key}`"
        if key in OVERRIDES:
            out += [hdr, "", "```", OVERRIDES[key], "```", ""]
            out += ref_lines(OVERRIDES[key], key)
        else:
            zh = cg_prompt(scene, key)
            out += render_item(hdr, zh)
            out += ref_lines(zh.split(NL)[0], key)  # the scene line only: the appended outfit notes would match names
    out += ["## 奇遇插图（？格事件，横版 16:9，key = e_<事件 id>，放 `pics/source/cg/`，和剧情 CG 一样登记）", ""]
    for eid, scene in EVENTS.items():
        key = "e_" + eid
        if key in art.get("cgs", {}) or ("cg", key) not in need:
            continue
        hdr = f"### `{key}`"
        if key in OVERRIDES:
            out += [hdr, "", "```", OVERRIDES[key], "```", ""]
            out += ref_lines(OVERRIDES[key], key)
        else:
            zh = cg_prompt(scene, key, is_event=True)
            out += render_item(hdr, zh)
            out += ref_lines(zh.split(NL)[0], key)  # the scene line only: the appended outfit notes would match names
    art_dir = ROOT / "godot" / "data" / "art"
    out += ["## 天命图（512×512 透明 PNG，放 `godot/data/art/fates/<key>.png`；没有图时显示一个汉字）", ""]
    for key, sym in FATES.items():
        if (art_dir / "fates" / f"{key}.png").exists():
            continue
        out += [f"### `{key}`", "", "```", fate_prompt(sym), "```", ""]
    out += ["## 词缀徽记（128×128 透明 PNG，放 `godot/data/art/affixes/<key>.png`）", ""]
    for key, sym in AFFIXES.items():
        if (art_dir / "affixes" / f"{key}.png").exists():
            continue
        out += [f"### `{key}`", "", "```", affix_prompt(sym), "```", ""]
    out += ["## 界面大图（横版 16:9 JPG，放 `godot/data/art/ui/<key>.jpg`）", ""]
    for key, scene in UI_ART.items():
        if (art_dir / "ui" / f"{key}.jpg").exists() and key not in redo:
            continue
        out += [f"### `{key}`", "", "```", ui_prompt(scene), "```", ""]
    out += ["## 宝箱图（开宝箱动画用，512×512 透明 PNG，放 `godot/data/art/ui/<key>.png`）", ""]
    for key, obj in CHESTS.items():
        if key in ui_done:
            continue
        out += [f"### `{key}`", "", "```", f"游戏道具精灵图：{obj}。{NL}构图：方形 512x512，宝箱居中，略带四分之三视角，透明背景（PNG），不要阴影底框。{NL}"
                f"画风：{STYLE}，彩绘道具，色彩浓郁，轮廓利落；不要文字。", "```", ""]
    out += ["## 章节地图底图（横版宽图，放 `pics/source/map/bg_<key>.jpg`）", ""]
    for key, scene in MAPS.items():
        if ("map", key) not in need:
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or map_prompt(scene), "```", ""]
    rarity = {k: v.get("rarity", "common") for k, v in load_cards()["relics"].items()}
    out += ["## 宝物图标（256×256 透明 PNG，放 `pics/source/relics/<key>.png`；现在是程序生成的占位）", ""]
    for key, obj in RELICS.items():
        if key in relics_done and key not in redo:
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or relic_prompt(obj, rarity.get(key, "common")), "```", ""]
    (PICS / "ART-PROMPTS.md").write_text(NL.join(out), "utf-8", newline=NL)
    print(f"wrote {PICS / 'ART-PROMPTS.md'}")


if __name__ == "__main__":
    main()
