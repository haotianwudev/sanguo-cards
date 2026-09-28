"""Write pics/ART-PROMPTS.md: a ready-to-paste image prompt for every piece of art the game still needs.

    python tools/art_prompts.py

Portraits, battle CGs and story CGs each follow one template (composition + style are fixed so the set stays
consistent); only the subject lines differ. Items that already have final art in pics/art.json are skipped.
Add new characters / battles / scenes to the tables below when you add them to the game.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PICS = ROOT / "pics"
NL = "\n"

HERO = "the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder"
STYLE = ("Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean "
         "ink outlines, rich vibrant colors")
PORTRAIT_COMPOSITION = ("Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper "
                        "third of the canvas, head fully visible with margin at the top.")
PORTRAIT_BG = "plain off-white studio background with subtle warm lighting (clean, no battlefield clutter)."

# key: (name line, appearance, armor & clothing, weapon / pose)
PORTRAITS = {
    "zhangfei": ("Zhang Fei (张飞), the legendary fierce powerhouse general from the Three Kingdoms era",
                 "Massive, dark-skinned muscular powerhouse warrior in his early 30s. Fierce round panther-like eyes with an intense battle glare, thick bristling black beard and mustache, roaring at the top of his lungs with explosive, terrifying battle fury (wide open mouth yelling a war cry).",
                 "Rugged Han dynasty black iron plate armor over a deep green battle tunic, heavy spiked shoulder guards, thick leather belt with a bronze tiger buckle.",
                 "Gripping his legendary Zhangba Snake Spear (丈八蛇矛 - an ancient long spear with an undulating, serpentine wavy steel spearhead) thrusting forward dynamically."),
    "liubei": ("Liu Bei (刘备), the humble, earnest leader who calls himself a descendant of the Prince of Zhongshan",
               "Gentle-faced man in his early 30s with notably large earlobes and long arms, kind sincere eyes, neat short beard, a slightly awkward, eager-to-please smile.",
               "Modest green-and-cream Han scholar-general robe over light leather armor, a simple topknot with a cloth band.",
               "Holding his twin swords (双股剑) a little clumsily in both hands, as if not quite sure how to use them."),
    "guanyu": ("Guan Yu (关羽), the dignified god of war of the Three Kingdoms era",
               "Tall imposing man in his early 30s with a deep red face, phoenix eyes half-closed in calm pride, a magnificent long flowing black beard reaching his chest.",
               "Green war robe over Han dynasty lamellar armor, green headscarf, a heroic cape.",
               "Holding the Green Dragon Crescent Blade (青龙偃月刀 - a long glaive with a dragon-headed crescent blade) upright beside him."),
    "lvbu": ("Lü Bu (吕布), the unrivaled, terrifying warrior of the Three Kingdoms era",
             "Tall, handsome, arrogant warrior in his early 30s with a cold predatory glare and a confident smirk, overwhelming aura.",
             "Ornate crimson and black armor with gold trim, a helmet crowned with two long pheasant tail feathers (雉尾冠), a red cape flaring behind him.",
             "Holding the Sky Piercer halberd (方天画戟 - a long halberd with a crescent side blade) across his shoulders."),
    "huatuo": ("Hua Tuo (华佗), the legendary wandering physician of the Three Kingdoms era",
               "Lean middle-aged man with a calm, sharp gaze, a thin goatee, sleeves rolled up like a working doctor.",
               "Plain grey-blue traveling robe, a wooden medicine chest on his back painted with the characters 沛国华佗.",
               "Holding a silver acupuncture needle between his fingers; a small hand axe peeks out of the medicine chest (his brain-surgery joke)."),
    "yuji": ("Yu Ji (于吉), the eerie Taoist priest of Jiangdong",
             "Middle-aged Taoist with a thin mustache and an unsettling, knowing smile, narrowed eyes.",
             "Flowing white Taoist robe, hair in a topknot with a wooden pin.",
             "Holding a tall cloth banner reading 「于吉仙师 符水治百病」 with a single copper coin dangling from it."),
    "fushui_xintu": ("a fanatical follower of the Taoist charm-water cult (符水信徒)",
                     "Gaunt peasant with feverish devoted eyes, a yellow paper talisman stuck on the forehead.",
                     "Ragged brown peasant clothes, a yellow cloth sash.",
                     "Holding out a bowl of murky charm water with both hands, pressing it forward insistently."),
    "baie_hu": ("a giant white-browed tiger (吊睛白额虎) from Chinese legend",
                "Enormous fierce tiger with slanted glaring eyes and a white patch on its brow, muscles rippling.",
                "Wearing a simple leather war saddle (it can be ridden as a mount).",
                "Crouched and snarling, about to pounce, claws out."),
    "boar": ("a huge wild boar (野猪)", "Massive bristly dark-brown boar with long curved tusks and small angry red eyes.",
             "No clothing; mud splashed on its flanks.", "Head lowered, charging straight at the viewer."),
    "yezhu_bing": ("a boar-rider soldier (野猪兵)", "Stocky, grinning peasant soldier in his 20s.",
                   "Patched leather armor and a straw hat.", "Riding a big wild boar and waving a short spear, charging."),
    "lijue": ("Li Jue (李傕), the brutal Xiliang general who burned Luoyang",
              "Heavy-set, cruel-faced man in his 30s with a scarred cheek, thick stubble and a sneer.",
              "Dark Xiliang iron scale armor with fur trim, a horsehair-crested helmet.",
              "A flaming torch in one hand and a saber in the other, fire and smoke behind him."),
    "chengpu": ("Cheng Pu (程普), the eldest veteran general under Sun Jian",
                "Kindly, dignified veteran in his 40s with a long beard and a warm smile.",
                "Well-worn bronze lamellar armor over a dark red tunic.", "Holding the iron-spined snake spear (铁脊蛇矛), bowing slightly with one hand raised in greeting."),
    "handang": ("Han Dang (韩当), Sun Jian's silent horse-archer general",
                "Expressionless, weathered man in his 30s with sharp hawk-like eyes and a short beard.",
                "Light leather cavalry armor, a quiver of arrows at his hip.", "Mounted on a horse, drawing a large bow."),
    "huanggai": ("Huang Gai (黄盖), Sun Jian's tough veteran general",
                 "Burly veteran in his 40s with a booming laugh, grey-streaked beard, chest covered in old scars.",
                 "Heavy armor with the robe pulled open to show off his scars.", "Holding an iron whip (铁鞭), slapping his chest proudly."),
    "zhuzhi": ("Zhu Zhi (朱治), Sun Jian's shrewd quartermaster general",
               "Sharp, composed man in his 30s with a neat mustache and an appraising look.",
               "Official's robe over light armor, a sword at his waist.", "Holding a supply list scroll in one hand and a writing brush in the other."),
    "wujing": ("Wu Jing (吴景), Lady Wu's protective younger brother",
               "Handsome young general in his 20s whose features resemble his sister's, a suspicious, protective frown.",
               "Bright silver cavalry armor and a white cape.", "Riding a white horse, gripping the reins and glaring at the viewer."),
    "sunben": ("Sun Ben (孙贲), Sun Jian's competitive nephew",
               "Young spear general in his 20s with a cocky smirk, arms crossed.", "Red and bronze Sun-clan armor.",
               "Hugging a spear against his shoulder, looking unimpressed."),
    "sunjing": ("Sun Jing (孙静), Sun Jian's stingy younger brother who keeps the family home",
                "Thin older man in his 40s with squinting eyes and a thin mustache, a miserly expression.",
                "Plain grey household robe and a cap.", "Flicking the beads of an abacus, peering over it suspiciously."),
    "tangji": ("Lady Tang (唐姬), the widowed consort of the deposed young emperor",
               "An adult woman in her twenties with graceful noble bearing, soot smudged on her cheek, steady unyielding eyes.",
               "Plain coarse cloth dress that cannot hide her dignity, hair loosely tied.", "Clutching a jade hairpin to her chest."),
    "yanzhihu": ("'Rouge Tiger' (胭脂虎), the fierce bandit queen of a mountain fort",
                 "A curvy adult woman in her thirties with a bold, teasing grin, fiery eyes and a confident swagger.",
                 "Red bandit leather vest and trousers, a sash at the waist, bangles.", "Hands on hips with twin sabers tucked in her sash, standing on a fort wall."),
    "huangjin_nvyi": ("a Yellow Turban field medic (黄巾女医)", "An adult woman in her twenties, calm and capable, sleeves rolled up.",
                      "Yellow headscarf, simple brown clothes, a medicine chest painted with Taiping Taoist charms.", "Bandaging a wounded arm, looking up at the viewer."),
    "gongnv": ("a palace maid fleeing the burning Luoyang (宫女)", "An adult woman in her twenties, frightened but resolute.",
               "Han dynasty palace dress with a soot-blackened hem.", "Holding a lantern and a small medicine box."),
    "xiliang_nvbing": ("a Xiliang female cavalry guard (西凉女亲兵)", "An adult woman in her twenties, fierce and loyal, high ponytail.",
                       "Fitted Xiliang leather armor with fur trim.", "Mounted, a curved saber raised."),
    "guosi": ("Guo Si (郭汜), the raiding Xiliang general", "Wiry, greedy-looking man in his 30s with a crooked grin.",
              "Xiliang cavalry armor with looted jewelry hanging from it.", "Holding a long lance (马槊) and a sack of loot."),
    "liru": ("Li Ru (李儒), Dong Zhuo's scheming strategist", "Pale, thin man in his 30s with cold calculating eyes and a thin smile.",
             "Dark purple scholar's robe.", "Holding a cup of poisoned wine (鸩酒) in one hand, a folding fan in the other."),
    "feixiong_bing": ("a Flying Bear elite heavy cavalryman (飞熊军) of Dong Zhuo's guard", "Massive faceless soldier behind a bear-shaped visor.",
                      "Full black heavy armor with bear-fur trim.", "Mounted on an armored warhorse, lance lowered."),
    "xiliang_bing": ("a Xiliang light cavalry raider (西凉铁骑)", "Rugged frontier horseman in his 20s with windburned skin.",
                     "Leather and iron cavalry gear, a fur hat.", "Galloping, saber drawn."),
    "shanzei_bing": ("a one-eyed mountain bandit (山贼)", "Scruffy bandit with an eye patch and a gap-toothed leer.",
                     "Ragged patched clothes, a rope belt.", "Carrying a big wood axe over his shoulder."),
    "inf_n": ("a Han dynasty government sword-and-shield soldier (官军刀兵)", "Disciplined, stern-faced soldier in his 20s.",
              "Standard Han army lamellar armor and helmet.", "Sword raised behind a round shield."),
}

# battle scenario id: the scene (the enemy in its setting, Rance X style)
BATTLES = {
    "boar": "a huge wild boar charging out of a muddy forest clearing full of fallen logs in the hills of Jiangdong",
    "shuizei_scout": "river bandits leaping out of tall riverside reeds at a broken wooden fort gate, brandishing knives",
    "shuizei": "the river bandit chief 'River Dragon' Hu Yu with his twin daggers on the plank walkways of a river fortress over dark water",
    "shuizei_guard": "bandit gate guards at a river fortress, burning boats lighting up the river behind them",
    "shuizei_main": "the Yellow Turban commander He Yi on the deck of a great river fortress, Yellow Turban and bandit banners, fire ships on the water",
    "yaodao": "the Yellow Turban sorcerer Tang Zhou at a smoking altar in front of a fortress, paper talismans swirling, kneeling followers",
    "tiger": "a giant white-browed tiger leaping from rocks on a mountain path among pine trees",
    "yuji_xintu": "fanatical cult followers surging out of a roadside shrine holding bowls of charm water",
    "shanzei_band": "mountain bandits blocking a winding mountain path below a fort wall with a tattered 替天行道 banner",
    "yanzhihu": "the bandit queen 'Rouge Tiger' with twin sabers in the great hall of her fort, decorated with red wedding silk",
    "huangjin_remnant": "Yellow Turban remnants rising up with farm tools in a smoky valley camp",
    "guanjun": "Han government soldiers storming the yard of a ruined temple",
    "xiliang_youqi": "Xiliang light cavalry galloping down a dusty Central Plains road",
    "guosi": "the raider general Guo Si on horseback in a plundered burning village",
    "feixiong": "Dong Zhuo's Flying Bear heavy cavalry in black armor lined up on an open plain",
    "liru": "the strategist Li Ru smiling from a cliff above a narrow gorge while ambushers spring out on both sides",
    "huaxiong": "the giant general Hua Xiong swinging his great blade on an open battlefield, a red headscarf lying in the dust",
    "dongbai": "Dong Bai, an adult woman general, leaping with two giant bronze hammers on a riverbank cratered by her blows",
    "hulao_ch1": "Lü Bu on the red horse Red Hare charging across a desolate plain at night, dust and moonlight",
    "lijue": "Li Jue with a torch in front of the burning gates of Luoyang, flames and smoke",
    "xiliang_scout": "Xiliang soldiers escorting a grain wagon convoy along a mountain foot road",
}

# story cg key: the scene
CGS = {
    "c1_wake": "a beautiful mature noblewoman (Lady Wu, adult) leaning over a young man with short modern hair lying in an embroidered bed, pressing a damp cloth on his forehead, lanterns, incense smoke, soft light",
    "c1_bandage": "Lady Wu sitting on the bed rewrapping a bandage on the young man's thigh, a tray with medicine and bandage rolls, the young man bright red with embarrassment, morning light (comedic, non-explicit)",
    "c1_raid": "a night raid: the grinning bandit chief Hu Yu with a headband holding up a torch, the gate of 富春山庄 in flames, river bandits and Yellow Turban men charging with tridents and sabers, a line of torch-lit boats on the river",
    "c1_rescue": "inside a river fortress: the young man holding Lady Wu's hands after untying her ropes from a pillar, Sun Ce coughing loudly behind them",
    "c1_dinner": "a warm family dinner: the young man pretending to be drunk with his head on Lady Wu's lap, Sun Ce snapping his chopsticks in two, Zhou Yu hiding a laugh (comedic)",
    "c1_armor": "Lady Wu fastening the straps of Sun Jian's old silver tiger-engraved armor on the hero, a fur-trimmed cape and a tiger pelt beside an opened camphor chest, Sun Ce gaping at the doorway, Zhou Yu with his ledger",
    "c1_oath": "three young men (the hero, Sun Ce, Zhou Yu) kneeling on a riverbank swearing brotherhood, three chopsticks stuck in the ground as incense, sunset over the river",
    "c1_north": "farewell at the village gate: Lady Wu hugging the young man goodbye, Sun Ce grinding his teeth, a bundle of hand-sewn clothes with a little tiger embroidered on it",
    "c2_zumao": "a battlefield: the veteran Zu Mao wearing a red headscarf being chased by the giant Hua Xiong, the young Sun Ce charging in with a spear",
    "c2_capture": "the hero carrying the unconscious woman general Dong Bai over his shoulder like a sack of rice, Sun Ce and Zhou Yu each struggling to carry one of her giant bronze hammers (comedic)",
    "c2_raid": "a burning army camp at night: Sun Jian alone blocking the camp gate with his sword against Lü Bu on the red horse Red Hare",
    "c2_sanying": "three heroes fighting Lü Bu: Liu Bei with twin swords, Guan Yu with the crescent blade and Zhang Fei with the snake spear circling Lü Bu, dust flying",
    "c2_fate": "the woman general Dong Bai tied on a horse glaring defiantly at the hero, an envoy of Yuan Shao waiting beside them, tense",
    "c2_setout": "setting off north on a country road: Sun Ce on a brown horse galloping ahead the wrong way, the hero on a white horse and Zhou Yu on a black horse exchanging a look, Lady Wu's carved carriage behind with a chest of ledgers tied on the back",
    "c2_jianhua": "a battlefield: Sun Jian in a tiger-pelt cape beheading the giant Hua Xiong with one sweep of his saber, the fallen hero looking up at him, dust and blood spray (not gory)",
    "c2_zumao_saved": "the hero hurling a huge broad saber that strikes the giant Hua Xiong on the back of the head, Sun Ce charging in with a spear, the wounded veteran Zu Mao pulling off his red headscarf to hand it over",
    "c2_counter": "Sun Jian's camp: the burly Sun Jian hugging Lady Wu while glaring at the hero over her shoulder, the veteran generals behind them trying not to laugh",
    "c2_borrow": "outside Sun Jian's command tent: six Sun-clan generals in a row (a long-bearded elder with a snake spear, a silent archer on horseback, a scarred veteran with an iron whip, a quartermaster with a scroll, a young general on a white horse glaring, a smirking young spearman), Sun Jian with his back turned and arms folded",
    "c2_keep": "inside a carved carriage: Lady Wu gently combing the hair of the captured woman general Dong Bai, who sits stiff-necked with reddened eyes, the hero peeking in at the curtain",
    "c2_handover": "a restrained, somber scene: the woman general Dong Bai in a prisoner cart looking back over her shoulder, the hero standing alone at the camp gate, grey sky (no gore)",
    "c2_triple": "a lavish allied lords' banquet: warlords crowding around the hero with wine cups, Yuan Shao giving up his seat, Sun Jian clapping the hero on the shoulder, Lady Wu watching from the side",
    "c2_dongbai_join": "a burning Luoyang street at night: the woman general Dong Bai striding toward the hero with her two giant bronze hammers, a line of Xiliang female cavalry guards kneeling behind her, ruined houses and refugees",
    "e_tangji": "a ruined temple: Lady Tang, an adult woman in coarse clothes with soot on her cheek, clutching a jade hairpin, looking up with unyielding eyes as the hero and Lady Wu find her",
    "e_yazhai": "a mountain bandit fort: the curvy bandit queen 'Rouge Tiger' standing hands on hips on the fort wall with twin sabers, pointing at the embarrassed hero, her chubby husband carrying a pig behind her (comedic)",
    "e_shengnv": "a forest clearing: the Yellow Turban saint Zhang Ning, an adult woman in a yellow Taoist robe with a nine-section staff, handing out bowls of charm water to kneeling ragged followers",
    "c2_yuxi": "burning Luoyang at night: Sun Jian by a well holding up the glowing Imperial Jade Seal, his face lit by five-colored light, his eyes turning ambitious",
    "i1_sewing": "night by lamplight: Lady Wu sewing a winter coat, the young man sitting beside her, Sun Ce sulking outside the window",
    "i2_yuxi": "night on a river boat: Sun Jian hugging a brocade box at the bow, Lady Wu standing at the cabin door holding a late-night snack",
    "i2_duel": "sunset riverbank: Dong Bai and Sun Ce collapsed on the ground laughing after a long duel, hammers and spear dropped beside them",
    "i2_qin": "night on the stern of a boat: Lady Tang playing a guqin, Lady Wu draping a coat over her shoulders",
}


# hand-written prompts that replace the template for a key (e.g. the owner's own prompt for a scene).
# They are also kept after the art exists, in the archive section, so a redraw starts from the same prompt.
OVERRIDES = {
    "i1_sewing": """横版 16:9 剧情CG插画，三国日系战术卡牌RPG第一章通关幕间事件图：【吴夫人的针线 · 窗里温存与窗外受气包】
- 室内温馨核心互动（暖光主舞台）：
  - 深夜的富春庄园寝房内，案几上的油灯洒下暖洋洋的橘色柔光。
  - 【吴夫人（宠溺调侃）】：三十多岁的绝色美妇身穿素雅柔顺的居家对襟襦裙，青丝微挽。膝头放着一件正缝制到一半的厚实保暖冬衣，手中捏着细长的缝衣针，正笑靥如花、极其宠溺地拿圆润的针尾轻轻敲了一下主角的额头，眼神满是亲昵与调侃。
  - 【主角（心满意足）】：青年主角坐在她身旁，微笑着伸手让夫人比量衣袖长短，桌边搁着他刚端进来的一大碗热气腾腾的枸杞鸡汤与竹编针线笸箩。
- 窗外喜剧反差神笔（画龙点睛的笑点）：
  - 透过室内敞开的雕花木窗，映出窗外清冷的青蓝月夜庭院：
  - 【可怜的孙策】：少年孙策正像个被遗弃的小狗一样，孤零零蹲在墙根底下的泥地里。手里死死抓着自己那件线头乱飞、歪歪扭扭还没缝好的烂棉袄，鼓着圆滚滚的包子脸，眼泪汪汪又咬牙切齿地透过窗户缝偷看屋里亲昵的两人，委屈酸楚溢出屏幕！
- 构图光影与画风：
  - 极富戏剧魅力的双重冷暖光影：屋内是充满熏香、热汤与针线温情的金黄暖光，屋外是照着委屈孙策的清冷月光。
  - 规格：横版 16:9 比例，日系经典战术卡牌RPG剧情CG插画风（赛璐珞上色带精良墨线，类似兰斯10经典幕间短剧插画），人物神态极其生动鲜活，温馨甜蜜中带着无厘头爆笑！""",
}

def portrait_prompt(p: tuple) -> str:
    name, look, clothes, weapon = p
    return (f"A vertical character portrait of {name}.{NL}Appearance: {look}{NL}Armor & Clothing: {clothes}{NL}"
            f"Weapon: {weapon}{NL}Composition & Framing: {PORTRAIT_COMPOSITION}{NL}Style: {STYLE}, {PORTRAIT_BG}")


def battle_prompt(scene: str) -> str:
    return (f"A horizontal battle scene illustration: {scene}.{NL}"
            f"Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the "
            f"upper half of the frame, the bottom third is calmer ground (game UI cards sit there).{NL}"
            f"Style: {STYLE}, dramatic battle lighting, like a Rance X battle CG; no text, no UI.")


def cg_prompt(scene: str) -> str:
    return (f"A horizontal story event illustration: {scene}.{NL}"
            f"Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third "
            f"less busy (dialogue text sits there).{NL}"
            f"Style: {STYLE}, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.{NL}"
            f"(When the hero appears — {HERO}.)")


def main() -> None:
    art = json.loads((PICS / "art.json").read_text("utf-8"))
    done = {k for k, v in art["portraits"].items() if not v.get("placeholder")}
    out = ["# 出图提示词", "",
           "> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。",
           "> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。",
           "> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，",
           "> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。", "",
           "## 立绘（竖版 3:4）", ""]
    for key, p in PORTRAITS.items():
        if key in done:
            continue
        status = "🟡 换掉占位" if key in art["portraits"] else "⬜ 缺"
        out += [f"### `{key}` {status}", "", "```", OVERRIDES.get(key) or portrait_prompt(p), "```", ""]
    out += ["## 战斗 CG（横版 16:9，每场战斗一张）", ""]
    for key, scene in BATTLES.items():
        if key in art.get("battles", {}):
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or battle_prompt(scene), "```", ""]
    out += ["## 剧情插图 CG（横版 16:9）", ""]
    for key, scene in CGS.items():
        if key in art.get("cgs", {}):
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or cg_prompt(scene), "```", ""]
    done_overrides = [k for k in OVERRIDES if k in art.get("cgs", {}) or k in art.get("battles", {}) or k in done]
    if done_overrides:
        out += ["## 已出图的提示词存档（重画时从这里开始）", ""]
        for key in done_overrides:
            out += [f"### `{key}` ✅", "", "```", OVERRIDES[key], "```", ""]
    (PICS / "ART-PROMPTS.md").write_text(NL.join(out), "utf-8", newline=NL)
    print(f"wrote {PICS / 'ART-PROMPTS.md'}")


if __name__ == "__main__":
    main()
