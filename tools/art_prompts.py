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

try:
    from tools.art_prompts_zh import OVERRIDES_ZH, PORTRAITS_ZH, BATTLES_ZH, CGS_ZH, EVENTS_ZH
except ImportError:
    from art_prompts_zh import OVERRIDES_ZH, PORTRAITS_ZH, BATTLES_ZH, CGS_ZH, EVENTS_ZH

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
               "s12_beifa", "s12_hushi", "s12_nanyang", "s12_sang", "s12_pangtong", "s12_kurou", "s12_guan", "tm_digong"}
# the same lord out of armor, for scenes whose own text says 常服 (at home, at a feast) — the armor line would otherwise put the armor and blade back
HERO_CASUAL = "主角：年轻男子，深棕近黑的短寸头（两侧推短、头顶短发微微上翘，额头露出，不要盖眉的刘海；现代发型，在汉代很扎眼），穿常服（和立绘 lord_south_casual 一样：深棕色交领长袍，青绿色镶金边的衣领与袖口，白色内衬领，黑色宽腰带；不穿任何盔甲、不披披风），手里、肩上、背上都没有任何兵器，不要古锭刀、不要任何刀剑"
HERO_NORTH_CASUAL = "北线主角：二十出头的年轻男子，干净斯文，棕黑色长发用布巾半束成发髻（不是现代短发），穿常服（和立绘 lord_north_casual 一样：灰蓝色交领长袍，外披雪白狐裘，不穿任何鱼鳞甲或铁甲），手里、肩上、背上都没有任何兵器，不要长枪、不要任何刀剑"
HERO_NORTH = "北线主角：二十出头的年轻男子，干净斯文，头发用布巾束成发髻（不是现代短发），穿甄宓亡父留下的河北式旧鱼鳞甲（素铁色，不要绿色和金色），外披雪白貂裘，手持白蜡杆长枪（枪头下系一个红色平安结）"
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
    ## every CG the north route shows: squares of north quests (event_scope north) and the north half of the prologue,
    ## events scoped to the north or to a north quest, and north endings — read from the game data, not from key prefixes
    if not _NORTH_CGS:
        gd = ROOT / "godot" / "data"
        story = json.loads((gd / "story.json").read_text("utf-8"))
        north_q = {q["id"] for q in story["quests"] if q.get("event_scope") == "north"}
        for q in story["quests"]:
            for sid, s in q["squares"].items():
                if s.get("cg") and (q["id"] in north_q or sid.startswith("jz_")):
                    _NORTH_CGS.add(s["cg"])
        for eid, ev in story["events"].items():
            if ev.get("scope") in north_q | {"north"}:
                _NORTH_CGS.add(eid)  # an event's prompt is keyed by its id
                if ev.get("cg"):
                    _NORTH_CGS.add(ev["cg"])
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
PORTRAITS = {
    "zhugejin": ["诸葛瑾（诸葛亮的哥哥，琅琊避乱到江东的书生，老实厚道，成年男性，南线第六章居巢入队）", "三十出头，方脸长须，眉眼宽厚温和，神情老实，略带一点憨", "洗得发白的青色儒袍，头戴布巾，腰间挂着一个算筹袋", "一手捧着一卷账册，一手提着一个刚捆好的行李包袱", "江南竹林后头的柴门小院，冬日的薄雪"],
    "wu_nushou": ["吴军弩手（兵卡，孙坚死后易帜为吴的江东弩兵，不是具名人物）", "二十多岁的江东青年，晒得黝黑，眼神专注", "孙家红色号衣外罩轻便皮甲，头裹红巾，臂上系一条白色孝布", "端着一张上好弦的木弩，腰间挂箭囊", "汉水边的芦苇荡和停泊的楼船，船上挂着「吴」字旗"],
    "bilan_shusheng": ["避乱书生（兵卡，从北方逃到江东的读书人，不是具名人物）", "二十岁上下的清瘦书生，面带风尘，眼神倔强", "打了补丁的灰布长衫，背着一只装满竹简的书箱", "手里握着一支毛笔和一卷地图", "江南的竹林小路，远处是避乱人家的茅屋"],
    "wu_canjun": ["吴军参军（精兵兵卡，孙家军中出谋划策的参军，不是具名人物）", "三十岁上下的精干文士，留着短须，目光锐利", "深青色官袍外罩一件轻便皮甲，头戴小冠，臂上系白色孝布", "一手拿令旗，一手按着摊开的汉水水图", "楼船舱里的军案，案上摆着沙盘和油灯，窗外是江面"],
    "sufei": ["苏飞（黄祖部将，江夏水战将领，成年男性，第五章前半首领）", "三十多岁，瘦削精悍，颧骨高，眼神灵活，嘴角带点嘲弄", "江夏水军的深灰色札甲，外罩被江水浸得发暗的绿披风，肩甲缠着湿绳", "一手转着一根带铁钩的长索，另一手按刀，背景是汉水雾气中的灰帆战船"],
    "liupan": ["刘磐（刘表之侄，荆州猛将，成年男性，第五章新野首领）", "二十五六岁，高大英挺，剑眉，傲气里带着几分急躁", "荆州军的深青色铁甲，红缨盔，披风上绣着「刘」字", "跨在骏马上，一杆长枪斜指，枪尖挑着一面「刘」字大旗，背景是新野城外的坞堡与暮色"],
    "zhangyun": ["张允（刘表的外甥，荆州水军督将，蔡瑁心腹，成年男性，第五章后半首领）", "三十岁上下，面色酒红，眼神浮肿带笑，一副醉醺醺又阴险的样子", "荆州水军的紫褐色锦袍外罩半身甲，腰间挂着酒壶和一串钥匙", "一手提着一只青铜酒壶，一手按着刀柄，背景是夜里襄阳城外火把照亮的江岸"],
    "caihe": ["蔡和（蔡瑁之弟，蔡家连弩统领，成年男性，第五章破局线精英）", "三十出头，眉眼阴沉，薄嘴唇，神情跋扈而急躁", "黑紫色蔡家号衣外罩轻甲，腰挂令旗", "一手高举令旗，一手架着一张连弩，背景是水阁二楼灯火与窗格"],
    "huangxu": ["黄叙（黄忠之子，南阳少年射手，成年男性，病愈不久）", "十八九岁的清瘦青年，脸色还有些苍白，眼神明亮坚定，带着病后初愈的倔强", "深褐色的南阳平民皮甲，外罩洗得发白的布袍，腰挂箭囊", "手持一张比他还高的长弓，箭搭在弦上，背景是南阳的竹林与山道"],
    "bingzhou_nu": ["并州强弩手（精兵兵卡，不是具名人物）", "三十岁上下的并州老兵，面容粗粝，眼神冷静，嘴唇干裂", "并州狼皮领的深灰色轻甲，肩背箭囊，腰系皮带", "双手端着一张沉重的强弩，弩机已上弦，瞄向前方，背景是并州塞外的黄沙营地"],
    "jiangdong_qi": ["江东骑卒（兵卡，不是具名人物）", "二十多岁的江东骑兵，晒得黝黑，神情机灵", "孙家红色号衣外套轻便皮甲，头裹红巾", "手持马刀，骑一匹矮壮的江南马", "江边的芦苇和渡口"],
    "jiangdong_shuzuo": ["江东书佐（兵卡，不是具名人物）", "二十岁上下的年轻文吏，清瘦，神情认真", "青色布袍，头戴小冠", "一手抱着竹简，一手拿笔", "江东官署的书案"],
    "xiangyang_xuezi": ["襄阳学子（兵卡，不是具名人物）", "二十岁上下的青年书生，朝气蓬勃，带点书呆子气", "白色儒衫，腰间挂着书袋", "手捧一卷书，背上背着一把短剑", "襄阳学堂的回廊"],
    "jizhou_qi": ["冀州骑卒（兵卡，不是具名人物）", "二十多岁的河北骑兵，面容坚毅", "冀州官军的暗红色札甲和铁盔", "手持长矛，骑一匹河北大马", "冀州平原上的麦田"],
    "hebei_shuzuo": ["河北书佐（兵卡，不是具名人物）", "二十多岁的文吏，面容斯文，冻得鼻头发红", "深色棉袍外罩皮裘", "抱着一摞账册和算筹", "风雪中的官署门口"],
    "heishan_louluo": ["黑山喽啰（兵卡，不是具名人物）", "二十岁上下的山民，面黄肌瘦却眼神凶狠", "破旧的黑色短褐，头裹黑布", "拿着一把豁了口的柴刀", "太行山的乱石山道"],
    "taishan_zei": ["泰山贼（兵卡，不是具名人物）", "三十岁上下的山匪，满脸胡茬，咧嘴笑", "皮甲外披兽皮，腰缠一串铜钱", "扛着一把大斧，脚踩着山道上的拦路木", "泰山的险峻山口"],
    "jizhou_nu": ["冀州强弩手（兵卡，不是具名人物）", "二十多岁的冀州兵，面容普通而专注，神情紧张", "冀州官军的暗红色札甲和铁盔，外罩号衣", "端着一张制式弩，蹲在城垛后面瞄准，背景是冀州城头的垛口与旗帜"],
    "taihang_lieshou": ["太行猎户（兵卡，不是具名人物）", "三十多岁的壮实山民，皮肤黝黑，眼神敏锐，留着短须", "粗糙的兽皮背心，裹着绑腿，腰间别着剥皮刀与箭囊", "手持一张猎弓，箭已搭弦，半蹲在雪地里的松树后，背景是太行山的雪岭"],
    "wuhuan_sheshou": ["乌桓骑射手（精兵兵卡，不是具名人物）", "二十多岁的乌桓骑兵，颧骨高耸，头发编成辫子，神情彪悍", "缀着羽毛与骨饰的皮甲，毛皮披肩，腰挂弯刀", "骑在马上回身拉满一张角弓，对着身后射箭，背景是塞外的草原与落日"],
    "loucuan_nushou": ["楼船弩手（精兵兵卡，不是具名人物）", "二十多岁的江东水兵，被江风吹得面色黝黑，眼神锐利", "青灰色的水军皮甲，肩扛一块防箭木盾，裹着头巾", "在高高的楼船船舷边端起一张连弩，对着江面瞄准，背景是长江上的楼船与风帆"],
    "bashu_nu": ["巴蜀连弩手（精兵兵卡，不是具名人物）", "三十岁上下的蜀地士兵，面容沉稳，眼神专注", "绿色与棕色相间的蜀军轻甲，头戴斗笠形铁盔，背后一捆备用箭匣", "双手端着一把木制的连弩，弩匣已装满，背景是蜀道栈道与云雾缭绕的山崖"],
    "zhangjiao": ("张角（黄巾军首领，大贤良师，自称天公将军，成年男性，SSR 卡也是黄巾首领战的敌人）", "五十岁上下的清癯老者，须发花白，面容枯瘦而眼神狂热，带着悲悯又癫狂的神情", "杏黄色的道袍，绣着太极与星斗符文，头裹黄巾，肩披黄色大氅", "左手持一根九节杖，杖头盘着金龙，右手结印，身周飘着黄色符纸与淡淡的光"),
    "pangtong": ("庞统（号凤雏，成年男性，奇才谋士，长相普通的大众脸，放在人堆里找不出来）", "三十岁上下，黑脸短须，五官平平无奇、毫不起眼，只有眼神机敏，嘴角挂着一点似笑非笑", "洗得发白的旧布袍，袖口随意卷起，头戴旧方巾", "一手拎着酒葫芦，一手捏着一张写满字的纸，随性地斜靠着"),
    "lvmeng_qingnian": ("吕蒙·青年（南线第六章淮南路上拖着长刀护粮车的少年，后来的东吴大将吕蒙）", "十五六岁的少年，脸上带泥，眼睛很亮，倔强不服输，个子不高但结实", "不合身的旧皮甲，袖子挽起，头上胡乱扎着红布带，脚穿草鞋", "双手拄着一把豁了口的长刀喘气，刀尖在地上划出一道沟"),
    "lvmeng": ("吕蒙（东吴大将，成年男性，行伍出身后发奋读书，士别三日刮目相看）", "三十岁上下，面容英挺沉稳，眼神专注，带一丝书卷气与军人的干练", "深青色东吴将军札甲，肩披红色短披风，腰系革带", "一手握着一卷兵书，另一手按在腰间佩剑上，站姿稳健"),
    "liaohua": ("廖化（蜀汉老将，成年男性，从黄巾一路追随刘备到老，资历深厚）", "五十岁上下，面容黝黑饱经风霜，须发夹杂花白，神情忠厚坚毅", "磨旧的蜀汉深绿色铁甲，头戴旧铁盔，披一件褪色的披风", "单手持一杆长枪，枪缨已旧，站得笔直"),
    "jianyong": ("简雍（刘备的老友，成年男性，言谈风趣随性，常陪刘备说客）", "四十岁上下，面容和善，眼神圆滑带笑，神情洒脱懒散，嘴角挂着打趣的笑意", "宽松随意的淡灰色文士长袍，腰带系得松垮，头戴方巾", "一手拿着一把折扇，另一手摊开做出说话的手势，姿态轻松"),
    "daotong": ("道童（兵卡，不是具名人物）", "十一二岁的小道童，圆脸，神情聪明机灵，头顶挽着两个小髻", "青灰色的小道袍，腰系布带，背着一个小竹篓", "手里捧着一卷竹简和一支毛笔", "山间道观的院子，晨雾与松树"),
    "fangshi": ("方士（精英兵卡，不是具名人物）", "四十岁上下的清瘦方士，眼神深邃，胡须稀疏，神情高深莫测", "宽大的深色道袍，绣着星象符文，头戴方巾，腰挂几个药葫芦", "一手托着罗盘，一手夹着一张朱砂符纸", "烟气缭绕的丹房，炉火与符纸"),
    "shuzuo": ("书佐（兵卡，不是具名人物）", "二十多岁的年轻文吏，面容清秀，神情拘谨认真，眼下有淡淡的黑眼圈", "青色的低级文吏袍服，黑色小冠，袖口沾着墨渍", "怀里抱着一摞竹简，耳后别着一支毛笔", "军营文书帐内，案上堆满简牍"),
    "peiyuanshao": ("裴元绍（黑山贼将领，北线，成年男性）", "三十岁上下的精悍山贼头目，目光机警狡黠，脸上有一道旧疤", "杂色皮甲外罩黑色披风，头缠黑巾，腰挂短刀", "手持一柄厚背大砍刀，扛在肩上，咧嘴笑着", "太行山的山寨寨门，黑色旗帜在风里飘动"),
    "huangyueying": ("黄月英（成年女性，机关巧匠，诸葛亮之妻）", "二十多岁的聪慧女子，面容清秀并不艳丽，目光灵动自信，发髻简单、沾着一点木屑", "朴素的浅褐色布裙，外罩工作用的皮围裙，袖口挽起，腰间挂着各式工具", "手里托着一只精巧的木牛流马模型，另一只手拿着小锤", "机关工坊，墙上挂满图纸与齿轮"),
    "sunqian": ("孙乾（刘备帐下说客，成年男性，口才出众）", "四十岁上下的儒雅文士，面容和善，目光灵活，带着得体的微笑，留着短须", "整洁的深青色文士长袍，头戴进贤冠，腰系丝绦，随身带着使节符节", "一手持着使节的符节，一手作出游说的手势", "诸侯营帐前的辕门，彩旗飘扬"),
    "wangping": ("王平（蜀汉将领，成年男性，识字不多的行伍出身）", "三十五岁上下的沉稳将领，方脸，眼神坚毅，神情谨慎", "蜀汉风格的深色札甲与皮护臂，头戴铁盔", "手持一杆长枪，枪缨暗红，稳稳立于身前", "山道关隘前，营垒与旌旗"),
    "zhoucang": ("周仓（关羽的部下，成年男性，黄巾出身）", "三十岁上下的黝黑壮汉，满脸络腮胡，豪爽憨直，嘴角带笑", "粗布短衣外罩简陋皮甲，头缠黑巾，肩头披着兽皮", "肩扛一柄沉重的大刀，另一手叉腰", "山间的小路与树林，远处是一面绿色的「关」字旗"),
    "qinwei": ("主公亲卫（兵卡，主角的贴身护卫，不是具名人物）", "三十岁上下的精悍护卫，面容沉稳，目光警觉，神情忠诚不苟言笑。", "磨得发亮的深青色亲卫铁甲，肩甲刻有简单的云纹，披一件深色短披风。", "右手按在腰间佩刀上，左手持一面圆盾。", "主公营帐门前，两侧是整齐的灯笼与旌旗"),
    "jiading": ("家丁（兵卡，宅院护卫，不是具名人物）", "三十岁上下结实的汉子，面容憨厚，神情警惕。", "深灰色短打外罩皮背心，头缠黑布巾。", "手持一根结实的齐眉木棍。", "大户宅院的青砖院墙前，灯笼挂在门楣下"),
    "shutong": ("书童（兵卡，主角身边的少年书童，不是具名人物，年满十八岁的成年人）", "十八九岁的清秀青年，神情机灵好学，眼神明亮。", "浅青色布衣，腰系布带，背着一个鼓鼓的书箱。", "怀里抱着一卷竹简和一只笔筒。", "书房窗边，案上堆着竹简，窗外有竹影"),
    "mafu": ("马夫（兵卡，不是具名人物）", "三十多岁的朴实汉子，面容黝黑，笑容憨厚。", "粗布短衣挽着袖口，腰间别着一把马刷。", "一手牵着缰绳，另一手拎着草料桶。", "营地的马厩旁，几匹战马低头吃草"),
    "shinv": ("贴身侍女（兵卡，主角身边的侍女，成年女性）", "二十岁出头的成年女子，眉目清秀，神情温顺而细心。", "淡粉色的交领襦裙，外罩素色半臂，发髻上簪着一支木簪。", "双手捧着一只托盘，上面放着茶盏。", "雅致的内室，窗边帷幔垂落，案上香炉青烟袅袅"),
    "fucong": ("扈从骑（兵卡·精兵，主角的随行骑从，不是具名人物）", "二十多岁的精悍骑士，面容英挺，目光锐利。", "深青色轻便皮甲配铜护肩，披一件短披风。", "一手握缰，另一手提着长刀。", "官道上，身后卷起淡淡尘烟，远处是低矮的山岗"),
    "jiangdong_qinwei": ("江东亲卫（兵卡，江东出身的主公亲卫，不是具名人物）", "二十多岁精壮的江东汉子，面容英气，神情忠勇。", "青色与红色相间的江东亲卫铁甲，头缠红色布条。", "腰佩环首刀，手持一面圆盾。", "江边营寨的辕门前，江风吹动红色旌旗"),
    "changshan_qinwei": ("常山亲卫（兵卡，常山出身的主公亲卫，不是具名人物）", "二十多岁精壮的北方汉子，面容坚毅，神情沉稳。", "灰蓝色的北地亲卫铁甲，披白色斗篷，头戴铁盔。", "一手持一杆长枪，另一手扶着腰间佩刀。", "常山的雪原与低矮的民居，炊烟缓缓升起"),
    "zhenfu_yahuan": ("甄府丫鬟（兵卡，甄府的侍女，成年女性）", "二十岁出头的成年女子，面容清秀，神情乖巧机灵。", "浅蓝色的交领襦裙，围着素色围裙，双丫髻系着青色发带。", "怀里抱着一摞叠好的衣物。", "甄府后院的回廊，檐下挂着灯笼，院里有一株梅树"),
    "zhenfu_xiunv": ("甄府绣娘（兵卡，甄府的绣娘，成年女性）", "二十多岁的成年女子，眉目温婉，神情专注，指尖带着针痕。", "素雅的浅紫色襦裙，袖口卷起，颈间挂着一把小剪刀。", "手里拿着一只绷好的绣架和一根银针。", "绣房的窗前，案上摆着五彩丝线与布匹"),
    "zhenfu_chuniang": ("甄府厨娘（兵卡，甄府的厨娘，成年女性）", "三十岁上下身材壮实的成年妇人，满脸红光，笑容爽朗。", "深褐色粗布短衣，系着围裙，头裹蓝布巾。", "一手拿着大铁勺，另一手端着一只冒着热气的汤盆。", "甄府的灶房，灶火通红，蒸汽缭绕"),
    "zhenfu_jiading": ("甄府家丁（兵卡，甄府的护院家丁，不是具名人物）", "三十岁上下结实的北方汉子，面容朴实，神情警觉。", "深蓝色短打外罩皮背心，头缠青布巾。", "手持一根包铁的木棍。", "甄府高大的门楼前，两盏大红灯笼"),
    "jiangwei": ("姜维（蜀汉大将，天水麒麟儿，继承诸葛亮遗志，成年男性）",
        "二十八九岁的英气青年将领，面容俊朗坚毅，目光明亮锐利，眉宇间既有书生的聪慧又有武将的刚烈，神情倔强而沉稳。",
        "素白与深青相间的蜀汉将军铠甲，肩甲刻有云纹，披一件深青色长披风，披风内衬绣着北斗七星。",
        "一杆银亮长枪，枪缨雪白，枪杆如龙，双手稳握。",
        "祁山的寒冷清晨，山道旁蜀军旌旗猎猎，远处是起伏的山脊与淡淡晨雾"),
    "chendao": ("陈到（蜀汉白毦兵统领，沉默可靠的老将，成年男性）",
        "四十多岁的沉稳老将，面容方正，神情寡言而坚定，鬓角略有风霜。",
        "纯白色羽缨装饰的头盔，银灰色厚重铠甲，披一件白色战袍，朴素而庄重。",
        "一杆长而厚重的铁枪，枪缨雪白，竖立身侧，如一座不动的山。",
        "蜀营的营门前，身后是整齐肃立、缨羽皆白的白毦精兵"),
    "weiyan": ("魏延（蜀汉猛将，豪放而桀骜，成年男性）",
        "四十岁上下的魁梧将领，棱角分明的脸庞，眉目桀骜，嘴角挂着自信乃至狂傲的笑意。",
        "暗红色重型铠甲，肩甲带兽首装饰，腰间系着红色战带，披一件深色战袍。",
        "一杆沉重的长枪，枪尖斜指前方，单手扛在肩上，姿态不羁。",
        "崎岖山谷的栈道上，远处是云雾缭绕的峰峦，旌旗在谷风中翻飞"),
    "guanping": ("关平（关羽义子，忠勇少年将领，成年男性）",
        "二十出头的青年将领，眉目清朗，神情坚定，带着一丝少年气，却已有沉稳的锋芒。",
        "青绿色轻甲，胸甲雕有简洁云纹，披绿色短披风。",
        "一杆长枪，枪缨青色，双手握持，枪尖微微下压。",
        "荆州城头，江风吹动旌旗，远处是浩荡的汉水"),
    "zhangbao": ("张苞（张飞长子，豪爽的蜀汉将领，成年男性）",
        "二十岁出头的魁梧青年，浓眉大眼，神情豪爽，笑起来很有张飞的气势。",
        "黑色厚重铠甲，肩甲带有兽头装饰，披黑色战袍。",
        "一杆蛇形长矛，矛尖寒光闪闪，单手扛在肩上。",
        "营寨前的校场，尘土飞扬，身后是整齐的蜀军长矛手"),
    "guanxing": ("关兴（关羽次子，少年英雄，成年男性）",
        "二十岁出头的青年将领，面如冠玉，丹凤眼，神情自负中带着坚韧，颇有关家风范。",
        "青绿与金边相间的轻甲，披一件绿色长披风。",
        "一杆长枪，枪缨红色，斜持在身前，姿态英挺。",
        "江边的战场，江水波光粼粼，身后是蜀军的绿色旌旗"),
    "chenglian": ("成廉（吕布麾下并州将领，沉稳的枪将，成年男性）",
        "三十岁出头的沉稳并州武将，面容黝黑棱角分明，目光冷静，神情寡言。",
        "黑色并州式重甲，肩甲带金属兽纹，披暗红短披风。",
        "一杆长而重的并州长枪，枪缨暗红，持于身侧。",
        "并州军营的辕门，身后是整齐的狼骑与枪兵，暮色里旌旗低垂"),
    "weixu": ("魏续（吕布麾下并州将领，吕布的姻亲，成年男性）",
        "三十岁出头的精明将领，面容清瘦，眼神机敏，嘴角带着一丝圆滑的笑意。",
        "深红色并州轻铠，披一件黑色披风，腰挂短刀。",
        "一杆长枪，枪缨红色，随意倚在肩头。",
        "并州营地的篝火旁，夜色里有零星的盔甲反光"),
    "lingtong": ("凌统（江东猛将，孝勇兼备，成年男性）",
        "二十五岁上下的英挺青年将领，剑眉星目，面带傲气，神情中透着年轻人的锐气。",
        "蓝色与银白相间的江东水军轻甲，披蓝色短披风。",
        "一杆长枪，枪缨蓝色，枪尖闪着水光，单手持握。",
        "江东战船的甲板上，江风鼓动战旗，远处是波光粼粼的长江"),
    "yangang": ("严纲（公孙瓒麾下大将，骁勇的幽州枪将，成年男性）",
        "三十多岁的幽州将领，面庞粗犷，眉目凌厉，神情桀骜，肩宽背厚。",
        "白色鳞甲外罩灰色战袍，肩甲带有简单金属纹饰。",
        "一杆沉重的长枪，枪缨白色，双手紧握。",
        "幽州边塞的雪原，身后是整齐的白马义从与飘扬的白色旌旗"),
    "gaolan": ("高览（袁绍麾下河北名将，枪法凌厉的大将，成年男性）",
        "三十五岁上下的精干武将，面容方正，目光冷峻，神情自信略带傲气。",
        "银蓝色河北重甲，肩甲宽阔，披蓝色披风。",
        "一杆长枪，枪缨深蓝，横握胸前，姿态稳重。",
        "河北官渡营前的原野，身后是整齐的袁军步卒方阵，旌旗成林"),
    "zoudan": ("邹丹（公孙瓒麾下将领，剽悍的幽州枪将，成年男性）",
        "三十岁出头的剽悍将领，棕色皮肤，眉毛粗黑，目光凶狠，神情带着边塞的粗野。",
        "灰白色皮甲镶嵌金属片，披白色旧战袍。",
        "一杆长枪，枪缨灰白，扛在肩头。",
        "幽州边塞的营地，帐篷连绵，远处是白雪覆盖的山岭"),
    "youzhou_qiang": ("幽州长枪兵（兵卡，不是具名人物）",
        "三十岁上下的普通边塞士兵，面容黝黑粗糙，神情沉稳坚毅。",
        "灰色皮甲与简易铁盔，披白色旧斗篷。",
        "一杆长枪，枪缨白色，双手斜握，枪尖向前。",
        "幽州边塞的雪原，身后是整齐的枪兵队列"),
    "bingzhou_qiang": ("并州枪卫（兵卡·精兵，吕布嫡系的精锐枪兵，不是具名人物）",
        "三十岁出头的精悍士兵，面容冷峻，目光锐利，神情训练有素。",
        "黑色并州式重甲，肩甲刻有狼纹，披暗红短披风。",
        "一杆长而重的铁枪，枪缨暗红，双手紧握。",
        "并州军营的辕门前，暮色低垂，身后是整齐的狼骑旗帜"),
    "changshan_qiang": ("常山枪兵（兵卡，赵云家乡的乡勇枪兵，不是具名人物）",
        "二十多岁的壮实乡勇，面容朴实坚定，神情带着为乡里而战的认真。",
        "青灰色布甲外罩简易皮甲，头缠白布巾。",
        "一杆朴素的木杆长枪，枪缨红色，双手握持。",
        "常山故里的田野，远处是炊烟和低矮的民居"),
    "jizhou_ji": ("冀州长戟兵（兵卡，不是具名人物）",
        "三十岁上下的壮硕士兵，面容憨厚而沉默，神情谨守军令。",
        "深蓝色冀州制式铁甲，头戴铁盔。",
        "一杆沉重的长戟，戟刃宽大，双手竖握于身前。",
        "冀州军营的校场，整齐的戟兵方阵在身后延伸"),
    "xiliang_maozi": ("西凉长矛手（兵卡，不是具名人物）",
        "二十多岁的剽悍羌汉混血士兵，肤色深，目光凶悍，神情桀骜。",
        "兽皮与铁片拼接的粗犷皮甲，头戴毛皮帽，披暗褐色披风。",
        "一杆细长的铁头长矛，矛缨黑色，单手握持。",
        "西凉边塞的黄沙戈壁，远处是起伏的沙丘与低垂的落日"),
    "danyang_qiang": ("丹阳枪兵（兵卡，不是具名人物）",
        "二十多岁精壮的江东山区士兵，面容朴实，神情干练。",
        "青色皮甲与竹片护甲，头缠红布条。",
        "一杆长枪，枪缨红色，双手持握。",
        "江东山林间的练兵场，晨雾缭绕"),
    "xuzhou_qiang": ("徐州枪兵（兵卡，不是具名人物）",
        "二十多岁的徐州士兵，面容温和，神情带着一点紧张。",
        "暗绿色布甲配皮护肩，头戴简易铁盔。",
        "一杆长枪，枪缨黄色，双手握持。",
        "徐州城外的麦田与官道，远处是城墙"),
    "tengjia_qiang": ("藤甲枪兵（兵卡，南中藤甲兵，不是具名人物）",
        "三十岁上下的南中士兵，肤色深褐，面容刚毅，神情沉默。",
        "整副用桐油浸泡的深褐色藤条编成的藤甲，头戴藤盔。",
        "一杆长枪，枪头以兽骨削成，双手握持。",
        "南中的茂密雨林与藤蔓，湿润的雾气弥漫"),
    "bashu_qiang": ("巴蜀长枪兵（兵卡，不是具名人物）",
        "二十多岁的蜀中士兵，面容清瘦，神情坚韧。",
        "深青色蜀军制式皮甲配铁肩甲，头戴铁盔。",
        "一杆长枪，枪缨青色，枪尖闪光，双手握持。",
        "蜀道栈桥旁，远处群山叠嶂"),
    "yulin_lang": ("羽林郎（兵卡·精兵，汉廷禁军郎官，不是具名人物）",
        "二十多岁的英挺禁军郎官，面容整洁端正，神情骄傲而克制。",
        "鲜红与金色相间的禁军铠甲，头戴插羽鹖冠。",
        "一杆金饰长枪，枪缨鲜红，竖握于身前。",
        "皇宫殿阶前，朱红宫门与金瓦屋檐在晴空下熠熠生辉"),
    "han_tuqi": ("虎骑（兵卡·高级兵，刘备·诸葛亮军团打「汉」字旗的精锐骑兵，不是具名人物）",
        "二十多岁精悍的骑兵，面容坚毅，目光锐利。",
        "赤红色战袍外罩玄黑色札甲，铁盔顶插一簇赤缨，背后斜插一面赤底黑字的「汉」字小旗。",
        "一杆长矛，骑在一匹黑马上，马头前冲，作冲锋姿态。",
        "荆北的平原麦田，远处成排的赤底「汉」字大旗"),
    "han_bazhen": ("虎步军（兵卡·高级兵，诸葛亮八阵中的盾枪步卒，打「汉」字旗，不是具名人物）",
        "三十岁上下的沉稳步卒，面容肃穆，一言不发。",
        "赤红色战袍外罩玄黑色札甲，铁盔赤缨，左臂挽一面绘着八卦纹的黑漆大盾。",
        "右手一杆短枪，枪尖从盾沿探出，半蹲作结阵姿态。",
        "汉水北岸的乱石滩，石堆之间雾气弥漫，身后成排的赤底「汉」字大旗"),
    "han_shuzuo": ("卧龙门生（兵卡·高级兵，诸葛亮门下的年轻弟子，随军出谋划策，不是具名人物）",
        "二十岁上下的清瘦书生，神情认真，眉头微蹙，像在心算。",
        "赤色长袍外罩一件玄黑短甲，头戴进贤冠，腰间挂着笔囊和竹简。",
        "一手捧着摊开的竹简军图，一手执笔，正在标注。",
        "军帐里的长案，案上铺着汉水的地图，帐外插着「汉」字旗"),
    "han_yigong": ("木牛流马营（兵卡·高级兵，诸葛亮造的木牛流马运粮队，打「汉」字旗，不是具名人物）",
        "三十多岁结实的辎重兵，神情踏实，额头带汗。",
        "赤红色布袍外罩玄黑色皮背心，头裹赤巾，腰挂水囊和工具袋。",
        "一手扶着一头木头做的机关牛（木牛流马），牛背上驮满粮袋，另一手握着控制机关的木柄。",
        "蜿蜒的山间栈道，身后一列木牛流马驮着粮袋，竖着赤底「汉」字旗"),
    "dongzhou_bing": ("东州兵（兵卡，刘璋麾下从关中逃难入蜀的流民兵，不是具名人物）",
        "三十岁上下的精瘦汉子，面容风霜，眼神里带着没有退路的狠劲。",
        "破旧的皮甲外罩一件洗得发白的关中短褐，头裹布巾。",
        "一面旧木盾和一柄环首刀，摆出死战的架势。",
        "蜀道的山口，云雾缭绕的栈道"),
    "yanpu": ("阎圃（张鲁的功曹，劝张鲁开城出降，南线第十章入队）",
        "四十岁上下的中年文士，面容温厚，眼神清醒，留着整齐的短须。",
        "汉中样式的青灰色儒服，外披一件旧道袍。",
        "一手扶着腰间的竹简，一手微微抬起，像在劝人。",
        "汉中南郑的城门口，远处是五斗米道的义舍"),
    "yang_ang": ("杨昂（张鲁的大将，守阳平关外的营寨，南线第十章精英）",
        "三十多岁的粗壮将领，浓眉方脸，一脸凶相。",
        "汉中铁甲外披一件黄色道袍，头裹黄巾。",
        "一柄长刀横在身前。",
        "阳平关外山梁上的营寨，营门挂着「杨」字旗"),
    "wudou_guizu": ("五斗米鬼卒（兵卡，张鲁五斗米道的道兵，不是具名人物）",
        "二十多岁的山民汉子，眼神狂热，嘴里念念有词。",
        "粗布短褐外罩黄色道袍，头裹黄巾，腰挂一只装米的布袋。",
        "一柄环首刀和一面画着符箓的木牌。",
        "汉中金牛道的栈道，云雾缭绕"),
    "wudou_jijiu": ("五斗米祭酒（兵卡，五斗米道的小头目，会烧符水，不是具名人物）",
        "四十岁上下，瘦削，山羊胡，神情庄重。",
        "黄色道袍，头戴道冠，袖口沾着符灰。",
        "一手捏着一张燃烧的黄符，一手端着一碗符水。",
        "汉中城外的义舍门口，大锅里熬着米粥"),
    "banshun_man": ("板楯蛮（兵卡·精兵，巴西的賨人勇士，木盾比人还高，不是具名人物）",
        "三十岁上下的黝黑壮汉，脸上画着赭红色的纹，神情剽悍。",
        "赤膊，只披一件兽皮短褂，腰系麻绳，脚穿草鞋。",
        "一面比人还高的长方形木盾，一柄短矛。",
        "巴西的山坡，一排木盾竖得像墙"),
    "wei_hubao": ("虎豹骑（兵卡·高级兵，曹操军团打「魏」字旗的最精锐骑兵，不是具名人物）",
        "二十多岁精悍的骑兵，面容冷峻，目光锐利。",
        "玄黑札甲外罩深蓝战袍，铁盔顶一簇黑缨，背后斜插一面黑底白字的「魏」字小旗；连人带马披着黑色铁甲。",
        "一杆长戟，骑在披甲的黑马上，作冲锋姿态。",
        "关中的大道，远处成排的黑底「魏」字大旗"),
    "wei_qingzhou": ("青州老兵（兵卡·高级兵，曹操起家的青州兵，打「魏」字旗，不是具名人物）",
        "四十岁上下的老兵，脸上全是老茧和刀疤，神情沉稳。",
        "玄黑札甲外罩深蓝战袍，铁盔顶一簇黑缨，背后斜插一面黑底白字的「魏」字小旗。",
        "一杆长枪竖在身前，枪尖磨得发亮。",
        "定军山脚下，一排长枪竖得整整齐齐"),
    "wei_pili": ("霹雳车营（兵卡·高级兵，曹操军团的投石车兵，打「魏」字旗，不是具名人物）",
        "三十岁上下的工兵，结实，满手老茧，眯着一只眼瞄准。",
        "玄黑札甲外罩深蓝战袍，铁盔顶一簇黑缨，背后斜插一面黑底白字的「魏」字小旗；袖子挽到手肘。",
        "身旁一架木制投石车（霹雳车），手里拉着绞索，脚边堆着石弹。",
        "黄河边的营寨，几架霹雳车排成一列"),
    "wei_huwei": ("虎卫军（兵卡·高级兵，许褚统领的曹操贴身卫队，打「魏」字旗，不是具名人物）",
        "三十岁上下的魁梧大汉，虎背熊腰，面相凶悍又憨厚。",
        "玄黑札甲外罩深蓝战袍，铁盔顶一簇黑缨，背后斜插一面黑底白字的「魏」字小旗；胸甲上錾着虎头。",
        "一柄厚背大刀和一面圆盾，站得像一堵墙。",
        "曹营中军大帐前，火盆照亮的营门"),
    "wei_xiaoshi": ("校事府密探（兵卡·高级兵，曹操手下专门刺探情报的校事，打「魏」字旗，不是具名人物）",
        "三十岁上下，面容平凡得让人记不住，眼神却很冷。",
        "深蓝便服外罩一件黑斗篷，斗篷下露出黑底「魏」字腰牌。",
        "一手捏着一卷密信，一手按着袖中的短刃。",
        "夜里的城墙阴影下，远处有一盏灯"),
    "wei_tuntian": ("屯田兵（兵卡·高级兵，曹操屯田制下种地也能打仗的兵，打「魏」字旗，不是具名人物）",
        "三十多岁的庄稼汉，晒得黝黑，憨厚结实。",
        "玄黑短甲外罩粗布短褐，裤腿卷到膝盖，背后插一面黑底「魏」字小旗。",
        "一手扛着锄头，一手提着长矛，腰间挂着粮袋。",
        "许昌城外一望无际的屯田，田埂上插着「魏」字旗"),
    "wei_mojin": ("摸金校尉（兵卡·高级兵，曹操设的挖墓取财的军官，打「魏」字旗，不是具名人物）",
        "三十岁上下的精瘦汉子，眼神贼亮，嘴角带笑，脖子上挂一枚穿山甲爪做的护身符。",
        "玄黑札甲外罩深蓝战袍，铁盔顶一簇黑缨，背后斜插一面黑底白字的「魏」字小旗；甲上沾满了泥土。",
        "一把长柄铁铲（洛阳铲）和一盏油灯。",
        "山中被挖开的古墓入口，墓道里透出幽光"),
    "nanman_dao": ("南蛮刀手（兵卡，南中蛮兵，不是具名人物）",
        "二十多岁赤膊的南中汉子，皮肤黝黑，脸上涂着白色的纹饰，神情凶悍。",
        "藤条编的护腰和兽牙项链，赤脚。",
        "一柄弯刃大刀，刀刃上抹着黑色的毒。",
        "湿热的南中雨林，白色的瘴气在树间飘"),
    "nanman_xiang": ("南中象兵（兵卡·精兵，南中蛮王的战象骑兵，不是具名人物）",
        "骑在战象背上的南中骑手，三十岁上下，神情骄傲。",
        "藤甲和兽皮，头插彩色鸟羽。",
        "手持长矛，胯下一头披着藤甲的大象正扬鼻嘶吼。",
        "泸水岸边的雨林，河面腾着水汽"),
    "zulang": ("祖郎（丹阳陵阳的山越宗帅，史实人物，曾伏击孙策砍中其马鞍，后归降）",
        "三十多岁的粗壮汉子，方脸络腮胡，额头和小臂刺着青色部族纹，眼神凶狠又憨直。",
        "兽皮短褂外罩竹片编甲，腰间挂着一颗系着新绶带的铜印，赤脚裹布。",
        "一把宽背山刀，单手拎着，刀口有缺。",
        "丹阳深山的木寨，寨墙是整根毛竹扎的，墙头挂着兽骨，远山云雾缭绕"),
    "shanyue_daoke": ("山越刀客（兵卡，江东山越部落的步战刀手，不是具名人物）",
        "二十多岁精瘦的山越汉子，皮肤黝黑，脸颊刺着青纹，神情警惕。",
        "兽皮短褂，腰缠麻绳，赤脚踩在山石上。",
        "一把弯头宽刃砍刀，刀背厚重，双手握持作势欲劈。",
        "雾气弥漫的竹林山道"),
    "wudang_feijun": ("无当飞军（兵卡·高级兵，刘备·诸葛亮军团的山地奇兵，善伏击，不是具名人物）",
        "二十多岁精悍的山地士兵，面容黝黑，目光敏锐，神情警惕。",
        "轻便的深青色皮甲配铜护肩，披迷彩般的绿褐斗篷。",
        "一杆轻巧的长枪，枪缨青色，单手握持，姿态矫健。",
        "蜀地险峻的山崖栈道，云雾在脚下翻涌"),
    "jinwei_ji": ("禁卫长戟营（兵卡·精兵，宫廷禁军，不是具名人物）",
        "三十岁上下的高大禁军士兵，面容严肃，神情肃穆。",
        "银白色禁军重甲，头戴金饰铁盔，披红色披风。",
        "一杆金边长戟，戟刃寒光，双手竖握。",
        "宫墙之下，成排的禁军沿廊道肃立，金色旌旗低垂"),
    "chunyuqiong": ("Chunyu Qiong (淳于琼), Yuan Shao's stout general in heavy armor",
                    "A broad, stout man around 30 with a thick beard and an arrogant, obstinate look.",
                    "Heavy Jizhou steel armor, very wide shoulders.",
                    "Both hands firmly gripping a heavy, sharp halberd (戟).",
                    "a steep gorge pass in the Taihang mountains, Jizhou infantry lined up behind him"),

    "yayi": ("a generic Han-dynasty county yamen guard/runner (衙役), not a named character",
             "A thuggish, sneering henchman, nothing noble about him.",
             "Short black county-guard uniform with a white sash, a red-tasseled leather cap.",
             "A water-and-fire cudgel (水火棍) held low, ready to swing.",
             "the snowy street outside Ye City's county yamen (州衙)"),
    "lord_south_boat": ("主公·水战装 (lord card variant)", "", "", "", ""),
    "lord_south_robe": ("主公·战袍 (lord card variant)", "", "", "", ""),
    "lord_south_plate": ("主公·重铠 (lord card variant)", "", "", "", ""),
    "lord_south_cloak": ("主公·披风 (lord card variant)", "", "", "", ""),
    "lord_north_cloak": ("主公·雪裘 (lord card variant)", "", "", "", ""),
    "lord_north_march": ("主公·行军装 (lord card variant)", "", "", "", ""),
    "lord_north_guard": ("主公·重甲 (lord card variant)", "", "", "", ""),
    "lord_north_banner": ("主公·披挂 (lord card variant)", "", "", "", ""),
    "lord_south_casual": ("主公·常服 (lord card variant)", "", "", "", ""),
    "lord_south_sleep": ("主公·睡衣 (lord card variant)", "", "", "", ""),
    "lord_north_casual": ("主公·常服 (lord card variant)", "", "", "", ""),
    "lord_north_sleep": ("主公·睡衣 (lord card variant)", "", "", "", ""),
    "lord_north": ("The hero's northern-route host body (北线主角) — a merchant house's account clerk turned commander, wearing the late patriarch's old armor",
                 "Clean-cut young man in his early 20s, soft unweathered hands, a composed and faintly clever half-smile.",
                 "Old fish-scale armor of the Hebei northern style, worn-in but meticulously kept (plain iron, no green or gold), hair tied in a cloth-wrapped topknot (no helmet, never short modern hair), a snow-white mink fur cloak over the armor.",
                 "A plain white-wax-wood long spear (白蜡杆长枪) held upright, a small red knotted good-luck charm tied just below the spearhead.",
                 "a snowy Hebei plain road with a column of Changshan cavalry and banners behind him, grey winter sky"),
    "xiahoulan": ("Xiahou Lan (夏侯兰), Zhao Yun's childhood friend, a county clerk of punishments who becomes the army's stern provost",
                "Lean young man around 20 with an unsmiling iron face and a vertical crease between his brows; utterly unbending.",
                "A faded blue-green county clerk's robe under worn leather armor; a bamboo scroll of statutes and a wooden punishment rod hanging at his belt.",
                "One hand resting on his saber hilt, the other holding the rod upright like a rule.",
                "the steps of the Zhending county office after snowfall"),
    "zhangyan": ("Zhang Yan (张燕), the nimble true leader of the Black Mountain army, nicknamed Flying Swallow",
               "Wiry, agile man around 30 with alert, amused eyes; looks ready to leap at any moment.",
               "Black close-fitting fighting clothes under light leather armor, leg wraps, a grappling hook coiled at his waist.",
               "Two short blades held in a reverse grip, crouched lightly on a rock.",
               "the clifftop Black Mountain stronghold in the Taihang range, clouds below"),
    "wenchou": ("Wen Chou (文丑), Yuan Shao's fiercest general",
              "Dark-faced, curly-bearded man around 40, ferocious and arrogant.",
              "Heavy Hebei iron armor with a black cloak.",
              "A long spear leveled from horseback.",
              "the dusty battlefield at Jieqiao bridge"),
    "gongsunzan": ("Gongsun Zan (公孙瓒), the proud White Horse General of Youzhou",
                 "Handsome, haughty man in his 30s with a proud chin.",
                 "Silver-white armor and a white battle robe.",
                 "A long lance, mounted on a white horse.",
                 "the Jieqiao battlefield with White Horse Volunteers' banners"),
    "caohong": ("Cao Hong (曹洪), Cao Cao's loyal younger cousin who gives up his own horse at the Bian River",
              "Rough, honest young man in his 20s, face streaked with sweat and dust.",
              "Torn light armor and a ripped cloak.",
              "Holding out the reins of his horse with one hand, a sword in the other.",
              "the chaotic riverbank of the Bian River with smoke and routed soldiers"),
    "yudu": ("Yu Du (于毒), a rebel Black Mountain chief who raids the lowlands against Zhang Yan's orders",
           "Vicious, wiry man in his 30s with a scar across his nose and a yellow-toothed grin.",
           "Black hide armor and a black headwrap, looted gold hanging at his belt.",
           "A ring-pommel broadsword.",
           "a plundered village at the foot of the Taihang mountains"),
    "quyi": ("Qu Yi (麹义), Yuan Shao's vanguard commander of the eight hundred 'first-to-climb' shield troops",
           "Hard, taciturn veteran around 40 from the western frontier, his face weathered by wind and sand.",
           "Heavy iron armor, a tall shield.",
           "A tall shield braced in one hand, a ring-pommel saber in the other, a shield wall behind him.",
           "the open plain before Jieqiao bridge"),
    "zhenghao": ("Zheng Hao (郑好), a fiery Taihang bandit chief turned the hero's bodyguard maid — an adult woman",
               "Bold adult woman around 20 with thick brows, big bright eyes and a fang-showing grin.",
               "Red short-cut fighting clothes with bound sleeves, leather bracers and a wide cloth sash.",
               "A heavy broad-backed saber over her shoulder.",
               "the palisade of a Taihang mountain bandit fort"),
    "jiangqiao": ("Jiang Qiao (姜巧), a sly Taihang bandit chief turned the hero's bodyguard maid, expert in traps and hidden weapons — an adult woman",
                "Petite, quick adult woman around 20 with fox-like eyes and a mischievous smirk.",
                "Teal close-fitting clothes, many small pouches (lime powder, caltrops) on her belt, needles hidden in her cuffs.",
                "A fan of throwing darts between her fingers.",
                "a Taihang forest path rigged with tripwires and traps"),
    "taishici": ("Taishi Ci (太史慈), the peerless archer of Donglai",
               "Tall, long-armed man in his late 20s, heroic and steady-eyed.",
               "Dark blue-black light armor and a short cape.",
               "A great bow drawn in his hands, two short iron ji crossed on his back.",
               "outside the walls of Beihai with a Yellow Turban siege army"),
    "guanhai": ("Guan Hai (管亥), the Yellow Turban chieftain besieging Beihai, leader of starving refugees",
              "Burly, heavily bearded man around 40, hard-bitten and weary.",
              "A faded yellow headscarf and patched leather armor.",
              "A heavy broadsword over his shoulder.",
              "a refugee camp of the Yellow Turbans outside Beihai"),
    "kongrong": ("Kong Rong (孔融), the scholarly Chancellor of Beihai, descendant of Confucius",
               "Refined, slender man around 40 with a long three-strand beard.",
               "Plain wide-sleeved scholar's robes and an official's cap.",
               "Holding a bamboo scroll.",
               "the study of the Beihai government hall"),
    "taoqian": ("Tao Qian (陶谦), the gravely ill Governor of Xuzhou",
              "Old man in his 60s with a sallow, sickly face but still shrewd eyes.",
              "Heavy dark official robes, a blanket over his shoulders.",
              "Propped up on a sickbed, one hand on the governor's seal ribbon.",
              "the inner chamber of the Xiapi government hall"),
    "mizhu": ("Mi Zhu (糜竺), the wealthiest merchant of Xuzhou",
            "Well-fed, gentle man in his 30s with smiling eyes and an easy, generous air.",
            "Rich brocade robes and a jade belt.",
            "Holding an account book.",
            "a Donghai harbor with merchant ships"),
    "mifang": ("Mi Fang (糜芳), Mi Zhu's younger brother, a bloodied envoy from Xuzhou",
             "Restless young man in his 20s who resembles his brother, dusty from the road.",
             "A brocade robe under light armor, spattered with blood.",
             "A sword in hand, out of breath.",
             "a refugee-choked road in Xuzhou"),
    "yufan": ("Yu Fan (虞翻), Wang Lang's outspoken registrar in Kuaiji, a scholar who fights on foot",
              "A blunt, lean scholar around 40 with a stubborn jaw and sharp eyes.",
              "A plain scholar's robe hitched up for walking, straw sandals.",
              "A long spear held like a walking staff.",
              "The Kuaiji city gate."),
    "sunce_bawang": ("Sun Ce (孙策) as the Little Conqueror of Jiangdong, now the lord of six commanderies",
                     "The same face as his younger portrait, now about 23: spiky brown hair, a confident fierce grin, more commanding.",
                     "Black-and-gold armor with golden tiger-head pauldrons over a red robe, a long crimson cloak.",
                     "A long spear held upright, the other hand on his hip.",
                     "A Jiangdong city wall over the Yangtze, red Sun banners."),
    "xugong": ("Xu Gong (许贡), the governor of Wu commandery, a thin smiling official secretly backing Yan Baihu",
               "A thin, dried-up official in his 50s whose smile narrows his eyes to slits.",
               "A dark official's robe and a governor's cap.",
               "Stroking his thin beard with one hand, a folded invitation in the other.",
               "The Wu commandery governor's hall."),
    "liuye": ("Liu Ye (刘晔), a Han-imperial-clan scholar in Lujiang, sharp and pragmatic",
             "A lean man in his mid-20s with keen narrow eyes and a faint knowing smile.",
             "A dark scholar's robe with a jade pendant of the imperial clan.",
             "A teacup in one hand, a bundle of letters under the other arm.",
             "The hall of the Lujiang governor's office."),
    "leixu": ("Lei Xu (雷绪), head of the Lei clan, a Lujiang strongman backing Yuan Shu",
              "A hard-faced man in his 50s, weathered and stubborn.",
              "Old worn armour over a clan patriarch's robe.",
              "An old broad blade.",
              "A mountain fortress gate in the Qian mountains."),
    "dufuren": ("Lady Du (杜夫人), widow of Lü Bu's officer Qin Yilu, a gifted wine-brewer — an adult woman",
             "A beautiful widow in her mid-20s, gentle but stubborn, a little tired around the eyes.",
             "Plain undyed mourning robes, sleeves rolled up, a simple wooden hairpin.",
             "Holding a wine ladle over a sealed jar.",
             "A small winery yard full of wine jars."),
    "mizhen": ("Mi Zhen (糜贞), Mi Zhu's younger sister who marries Zhao Yun — an adult woman",
             "Graceful, poised adult woman around 20, confident and warm.",
             "A red brocade dress with pearl and jade hair ornaments.",
             "Holding a white jade wine ewer with both hands.",
             "a painted screen at a Xiapi banquet hall"),
    "chendeng": ("Chen Deng (陈登), a sharp-eyed Xuzhou gentleman-official",
               "Lean man around 30 with keen, suspicious eyes.",
               "A scholar's robe with a fur mantle.",
               "Holding a jar of wine.",
               "a military camp at Xiapi by night"),
    "chengui": ("Chen Gui (陈珪), Chen Deng's shrewd old father",
              "Old man around 70 with white brows and beard and a foxlike smile.",
              "A loose home robe.",
              "Leaning on a staff, clapping his hands with delight.",
              "the Chen family study"),
    "caobao": ("Cao Bao (曹豹), a bullying Xuzhou general",
             "Coarse, overbearing man around 40 with a drinker's red nose.",
             "Grimy, ill-kept armor.",
             "A riding whip in hand.",
             "a Xiapi street"),
    "xiahoudun": ("Xiahou Dun (夏侯惇), Cao Cao's fierce general covering the retreat — both eyes still intact at this point",
                "Fierce, steady man in his 30s with heavy brows and tiger-like eyes (both eyes intact, no eyepatch).",
                "Black Cao army armor and a dark cloak.",
                "A long glaive, turning in the saddle to hold the rear.",
                "a retreating Cao army in dust outside Xiapi"),
    "xunyu": ("Xun Yu (荀彧), Cao Cao's chief strategist, the 'talent to assist a king'",
            "Gentle, upright man in his 30s with clear, calm features; every fold of his robe in place.",
            "Dark scholar's robes and an official's cap.",
            "Holding a rolled letter.",
            "a study in the Yanzhou government office"),
    "caoren": ("Cao Ren (曹仁), Cao Cao's steadfast cousin and master of defense",
             "Steady, resolute man around 30 with a square face and a short beard.",
             "Heavy Cao army iron armor and a dark cloak.",
             "A long spear, standing before a fortified wall.",
             "a Cao army camp"),
    "chengong": ("Chen Gong (陈宫), Lü Bu's stubborn strategist who refuses to surrender",
               "Gaunt, proud man in his 40s with a bristling beard and a glare.",
               "A plain scholar's robe.",
               "Arms folded, glaring.",
               "a quiet courtyard mansion in Xiapi"),
    "zhangliao": ("Zhang Liao (张辽), the composed Bingzhou general",
                "Brave, steady young man around 25 with sharp brows.",
                "Bingzhou-style iron armor and a dark cloak.",
                "A long glaive, mounted.",
                "outside the walls of Xiaopei"),
    "changshan_tieqi": ("a Changshan iron cavalryman (常山铁骑), the northern hero's first loyal troops",
                      "Sturdy Hebei horseman with a white headscarf.",
                      "Iron armor under a white surcoat.",
                      "A long spear, mounted.",
                      "a snowy Changshan plain"),
    "yunliang_bing": ("运粮兵 (后勤兵卡)", "", "", "", ""),
    "junyi": ("军医 (后勤兵卡)", "", "", "", ""),
    "danjia_bing": ("担架兵 (后勤兵卡)", "", "", "", ""),
    "tiejiang": ("随军铁匠 (后勤兵卡)", "", "", "", ""),
    "tuoma_dui": ("驮马队 (后勤兵卡)", "", "", "", ""),
    "junxu_guan": ("军需官 (后勤兵卡)", "", "", "", ""),
    "caoyun_shuishou": ("漕运水手 (后勤兵卡)", "", "", "", ""),
    "yaonong": ("太行药农 (后勤兵卡)", "", "", "", ""),
    "shangdui": ("甄家商队 (后勤兵卡)", "", "", "", ""),
    "xiandeng_sishi": ("a vanguard death-trooper (先登死士) of Qu Yi, a veteran with a huge shield", "a hard-faced northwestern veteran", "dark scale armor under a worn crimson tabard", "a body-covering iron shield and a ring-pommel saber", "the Jieqiao battlefield at dusk"),
    "taihang_yiyong": ("a Taihang volunteer (太行义勇), a mountain hunter turned soldier",
                     "Rugged mountain hunter with a weathered face.",
                     "A fur vest over coarse cloth, leg wraps.",
                     "A hunting bow or a woodsman's chopper.",
                     "the Taihang mountain forest"),
    "diaochan": ("Diaochan (貂蝉), the famed beauty and Wang Yun's adoptive daughter — clever, brave, always seeming to flirt — an adult woman",
        "Breathtakingly beautiful adult woman in her early 20s with a teasing, unreadable smile and knowing eyes.",
        "Flowing layered silk dress in moonlit blue and silver with long dancing sleeves, a jade hairpin.",
        "A round silk fan held half open, one long sleeve drifting in the air.",
        "a moonlit garden with a round moon gate and curling incense smoke"),
    "huangzhong": ("Huang Zhong (黄忠), a Nanyang man in his forties and a peerless archer — not yet the old general of legend",
        "Sturdy, weathered man in his early 40s with a square jaw, a short beard and steady eyes.",
        "Rough soldier's clothes with a leather bracer, rope marks still on his wrists.",
        "A heavy longbow drawn to full, an arrow nocked.",
        "a Nanyang army camp gate in summer with a broken 袁 banner pole"),
    "xuhuang": ("Xu Huang (徐晃), a dark-faced Hedong officer under Yang Feng who kneels to the emperor",
        "Dark-skinned, stern man in his 30s with thick brows and an honest, stubborn look.",
        "Plain iron lamellar armor with a dusty brown cloak.",
        "A huge long-handled battle axe resting on his shoulder.",
        "a mountain pass east of Huayin with Yang Feng's banners"),
    "bingzhou": ("a Bingzhou wolf rider (并州狼骑), one of Lü Bu's northern cavalrymen",
        "Fierce, wind-burned northern horseman in his 20s with a wolfish grin.",
        "Fur-trimmed leather and iron armor, a wolf tail hanging from his helmet.",
        "A curved saber raised as he gallops.",
        "the open northern steppe at dusk"),
    "xianzhen": ("a Trap-Breaking Camp soldier (陷阵营), Gao Shun's silent elite infantry",
        "Grim, silent heavy infantryman, his face half hidden by a deep helmet.",
        "Heavy black lamellar armor, plain and unadorned.",
        "A tall rectangular black shield and a long ji.",
        "a shield wall in the dark before dawn"),
    "xurong": ("Xu Rong (徐荣), Dong Zhuo's veteran general who beat Sun Jian at Liangdong",
        "Weathered, calm general in his 40s with a grey-streaked beard and a hard, measuring gaze.",
        "Well-worn Xiliang lamellar armor with a dark red cloak.",
        "A ring-pommel saber at his side, one hand pointing out an ambush.",
        "a valley outside the Dagu pass with hidden troops on the slopes"),
    "zhurong": ("Lady Zhurong (祝融夫人), queen of the Nanzhong tribes who claims descent from the fire god — an adult woman",
        "Proud, sun-bronzed adult woman around 30 with a fierce grin, wild dark hair bound with red cords, gold and bone earrings.",
        "Tribal queen's armor of leather and bronze plates, a leopard pelt over one shoulder, feather ornaments.",
        "A bandolier of throwing knives across her chest, one knife twirling between her fingers.",
        "a steaming southern jungle with a volcano glowing on the horizon"),
    "lvlingqi": ("Lü Lingqi (吕玲绮), Lü Bu's daughter who inherited his halberd — an adult woman",
        "Cool, stoic adult woman of about 20 with sharp eyes like her father's, long black hair in a high tail.",
        "Red-and-black armor echoing Lü Bu's, a helmet with two long pheasant tail plumes held under her arm.",
        "A smaller version of the Sky Piercer halberd resting on her shoulder.",
        "a windswept northern steppe at dusk with a red horse grazing behind her"),
    "mayunlu": ("Ma Yunlu (马云騄), Ma Chao's younger sister, a Xiliang woman general — an adult woman",
        "Bold, bright-eyed adult woman in her early 20s with a confident smile, long ponytail tied with a silver ring.",
        "Silver lamellar armor trimmed with white fur, a short white cape.",
        "A long lance with a white tassel, reins of a white horse in her other hand.",
        "the Xiliang frontier: dry grassland, a beacon tower and distant snowy mountains"),
    "baosanniang": ("Bao Sanniang (鲍三娘), the heroine of the Bao manor who beat every suitor — an adult woman",
        "Cheerful, athletic adult woman in her 20s with a playful grin and a braid wrapped around her head.",
        "Practical pale-green armor over a red martial robe, arm guards.",
        "A spear spun behind her back in a ready stance.",
        "a country manor's training yard with weapon racks and a few defeated suitors sitting on the ground"),
    "wangyi": ("Wang Yi (王异), the Jicheng heroine who planned the city's defence — an adult woman",
        "Composed adult woman in her early 30s with an unshakeable gaze, hair simply pinned, no jewelry.",
        "Plain dark robe with a leather belt, sleeves bound for work, a wind-torn cloak.",
        "A short sword at her waist, a map of city walls in her hand.",
        "a besieged frontier city wall at dusk with soldiers and smoke"),
    "xinxianying": ("Xin Xianying (辛宪英), the famously perceptive lady of the Xin family — an adult woman",
        "Elegant adult woman in her 20s with clever eyes and a small knowing smile.",
        "Light blue scholar-lady robes with neat layered collars.",
        "Holding a bamboo slip in one hand and a brush in the other.",
        "a quiet study with bamboo scrolls and a window onto a plum tree"),
    "caifuren": ("Lady Cai (蔡夫人) of Jingzhou, Liu Biao's wife and the power behind the Cai clan — a scheming adult woman",
        "Beautiful adult woman in her late 20s with a cold, graceful smile and calculating eyes.",
        "Rich purple silks with gold embroidery, an ornate phoenix hairpin.",
        "A round silk fan half-hiding her face.",
        "a lavish Jingzhou mansion hall with a river view through carved screens"),
    "jiaxu": ("Jia Xu (贾诩), the 'poison strategist' — a Xiliang officer who can smell a plot, and poison, in any cup",
        "Thin, sallow man in his mid-40s with a sparse goatee, drooping lazy eyelids and a faint, unreadable half-smile; sharp eyes under the sleepy lids.",
        "A loose, faded Xiliang officer's robe that hangs off his thin frame, a plain dark cap, a gourd wine flask at his belt.",
        "Holding a wine cup under his nose, sniffing it before drinking; no weapon.",
        "a dim corner of a lantern-lit banquet hall in Chang'an, the feast blurred behind him"),
    "zhangxiu": ("Zhang Xiu (张绣), Zhang Ji's young nephew from Wuwei, a dazzling spearman ('the Spear King of the North')",
        "Handsome, cocky young man in his early 20s with sharp eyebrows, a high topknot and a fearless grin.",
        "Light silver-and-blue Xiliang scale armor with a short white cape, a white-tasselled helmet under his arm.",
        "A long spear spun into a blur of spear-tip flowers.",
        "a stone bridge over the Wei river at dawn, Xiliang cavalry with a 张 banner behind"),
    "ganning": ("Gan Ning (甘宁), the young Brocade-Sail pirate chief of Ba commandery (锦帆贼), cocky and fearless",
        "Lean, sun-tanned young man in his early 20s with a wild grin, sharp eyes and a feather stuck in his tied-up hair.",
        "A bright brocade sash over a sleeveless dark jacket, bare muscular arms, a string of bronze bells at his waist.",
        "A great iron-backed bow drawn to full, a quiver of red-fletched arrows.",
        "the prow of a brocade-sailed fast boat on a river at noon"),
    "wenpin": ("Wen Pin (文聘), a loyal, steady general of Jingzhou",
        "Solid, earnest man in his early 30s with a square face, a trimmed beard and calm, dutiful eyes.",
        "Green-lacquered Jingzhou lamellar armor with a dark red cape.",
        "A long spear held upright, a round shield on his back.",
        "the walls of Xiangyang above the Han river at dawn, Jingzhou banners"),
    "yiji": ("Yi Ji (伊籍), a courteous, quick-witted Jingzhou scholar-envoy",
        "Slim, pleasant man in his early 30s with a thin moustache and a polite, clever smile.",
        "A tidy sky-blue scholar's robe and black cap.",
        "Bowing slightly with a sealed letter held in both hands.",
        "a Xiangyang street with a recruitment notice board"),
    "simahui": ("Sima Hui (司马徽), 'Master Water Mirror', a hermit scholar who answers everything with 'good, good'",
        "Genial middle-aged man in his 40s with a long beard, half-closed smiling eyes and a serene, slightly mischievous expression.",
        "A plain undyed hemp robe, straw sandals, a bamboo hat hanging on his back.",
        "Holding a round bronze mirror in one hand and a feather fan in the other.",
        "a thatched hut in a bamboo grove outside Xiangyang"),
    "pangdegong": ("Pang Degong (庞德公), the great recluse of Jingzhou who farms at the foot of Mount Xian",
        "Weathered, kindly old farmer-scholar in his 50s with a grey beard and clear, amused eyes.",
        "A patched farmer's jacket with sleeves rolled up, a straw hat.",
        "Leaning on a hoe.",
        "terraced fields at the foot of Mount Xian by the Han river"),
    "huangchengyan": ("Huang Chengyan (黄承彦), an eccentric scholar-inventor of Mian'nan and Cai Mao's brother-in-law",
        "Wiry, grey-bearded man in his 40s with ink- and sawdust-stained fingers and a curious, absent-minded look.",
        "A loose brown scholar's robe with sleeves tied back, tools tucked into his belt.",
        "Holding a small self-walking wooden cart with gears.",
        "a riverside workshop by the Mian river full of wooden contraptions"),
    "jingzhou_bu": ("a Jingzhou foot soldier (荆州步卒), a soldier card",
        "Stocky young soldier with a stubborn jaw.",
        "Green-trimmed cloth-and-leather armor, a round shield painted 刘.",
        "A broad saber raised behind the shield.",
        "the gate of Xiangyang"),
    "caifu_nu": ("a Cai household repeating-crossbowman (蔡府连弩手), an elite soldier card",
        "Cold-eyed guard with a thin face.",
        "Black-and-purple household livery over light armor, the Cai family crest.",
        "A repeating crossbow braced at the shoulder.",
        "silk curtains of a lavish pavilion, lamplight"),
    "caifu_bing": ("a Cai household infantryman (蔡家府兵), an elite soldier card",
        "Stolid guard with a square face.",
        "Black-and-purple household livery over a leather cuirass, the Cai family crest.",
        "A round shield and a short sword.",
        "the stone plank-road of a lakeside pavilion, torchlight"),
    "caifu_qi": ("a Cai household horseman (蔡家骑兵), an elite soldier card",
        "Lean rider with a hard, tanned face.",
        "Black-and-purple cloak over light armor, the Cai family crest on the shoulder.",
        "A curved saber raised, riding a dark horse.",
        "a narrow stone causeway over the river at night"),
    "zongzei": ("a clan bandit (宗贼) of Jingzhou, a soldier card",
        "Burly farmhand-turned-bandit with a scarf over his head and a sly grin.",
        "Patched peasant clothes with a leather vest, a clan tag on his belt.",
        "A heavy farm cleaver and a torch.",
        "the rammed-earth wall of a fortified village (wubao) in Jingzhou"),
    "jinfan_zei": ("a Brocade-Sail pirate (锦帆贼), Gan Ning's men, an elite soldier card",
        "Lean, tanned river pirate with a wild grin and a feather in his hair.",
        "Bright brocade sash, bare arms, a string of bronze bells at the waist.",
        "A short curved blade and a grappling rope.",
        "a fast boat with a brocade sail on the Han river"),
    "liubiao": ("Liu Biao (刘表), Governor of Jingzhou and an imperial clansman — a scholar who talks rather than fights",
        "Pale, dignified man around 50 with a long, well-kept black beard, soft hands and a mild, hesitant smile.",
        "Wide-sleeved dark-green scholar-official robes with a black official's cap and a jade pendant at the belt.",
        "Holding a half-unrolled bamboo book of the classics instead of a weapon.",
        "a quiet study in the Xiangyang governor's mansion with shelves of bamboo scrolls and the Han river beyond a lattice window"),
    "caimao": ("Cai Mao (蔡瑁), Lady Cai's younger brother and admiral of the Jingzhou navy — an arrogant, greedy in-law",
        "Burly young man of about 25 (younger than his sister) with a short trimmed moustache, a square jaw and a sneering, lecherous grin.",
        "An embroidered brocade robe worn over gilded scale armor, a gold belt, rings on his fingers.",
        "One hand on the hilt of a long sword, the other raising a gold beast-shaped wine cup.",
        "the deck of a great tiered warship on the Han river at dusk, rows of Jingzhou war boats behind"),
    "kuaiyue": ("Kuai Yue (蒯越), the far-sighted chief advisor of the Jingzhou gentry",
        "Composed scholar in his early 40s with a neat short beard, a calm, measuring gaze and a faint polite smile.",
        "Immaculate pale-grey Confucian robe with layered collars, a simple black scholar's cap.",
        "Hands folded in a formal bow, a closed folding bamboo scroll tucked into his sleeve.",
        "a lamplit study at night in Xiangyang, a go board with an unfinished game on the low table"),
    "huangzu": ("Huang Zu (黄祖), the grim veteran Administrator of Jiangxia, Liu Biao's hardest general",
        "Gaunt, weathered man in his 50s with a lined, sour face, grey stubble and cold narrow eyes.",
        "Battered dark iron lamellar armor with a river-green cape, a helmet with a short red plume.",
        "A heavy ghost-head broadsword (鬼头刀) held low at his side.",
        "the misty south bank of the Yu river in autumn, tall reeds and a 黄 banner"),
    "jingzhou_gong": ("a Jingzhou archer (荆州弓手), a soldier card",
        "Young soldier with a sun-browned face and a steady squint.",
        "Light green cloth armor over a short tunic, a reed hat, a quiver of arrows at the hip.",
        "Drawing a longbow, crouched in reeds.",
        "a reed marsh on the Han river bank in autumn"),
    "jingzhou_shuijun": ("a Jingzhou marine (荆州水军), a soldier card",
        "Broad-shouldered river sailor with a shaved head and a rough grin.",
        "Bare-chested under a short leather vest, a red headband, rope at the waist.",
        "A boarding pike and a round rattan shield.",
        "the prow of a Jingzhou war boat on the Han river, oars and flags"),
    "bianfuren": ("Lady Bian (卞夫人), a former singer of great grace and good sense, Cao Cao's wife — an adult woman",
        "Graceful adult woman around 30 with warm eyes and a calm, shrewd smile.",
        "Elegant but modest pale rose robes, a simple jade hairpin.",
        "Holding a lantern in the snow, a thick cloak over one arm to share.",
        "a snowy courtyard corridor at the Cao family house in Qiao county at night"),
    "yanfuren": ("Lady Yan (严夫人), Lü Bu's stern, practical wife — an adult woman",
        "Handsome, strong-willed adult woman in her 30s with a stern frown and arms crossed.",
        "Sturdy dark red robes of a general's wife, sleeves tied back.",
        "A household ledger tucked under one arm.",
        "the courtyard of a general's residence with a halberd rack"),
    "liniang": ("Li Niang (黎娘), queen of a Shanyue mountain tribe in Jiangdong — an adult woman",
        "Fierce adult woman in her mid-20s with sharp eyes, blue tribal tattoos on her arms and cheek, hair cropped at the shoulders.",
        "Hide and woven-bark armor, bead necklaces, bare feet wrapped in cloth.",
        "A bamboo bow with poison arrows, a quiver of green-fletched shafts.",
        "misty Jiangdong mountains with bamboo forests and stilt houses"),
    "gaoshun": ("Gao Shun (高顺), Lü Bu's grim, silent commander of the Trap-Breaking Camp (陷阵营)",
        "Stern, dark-faced man in his 30s, jaw set, eyes that never blink; utterly still.",
        "Heavy black lamellar armor, plain and unadorned, a tall rectangular shield.",
        "Standing like a post, shield planted, a long ji in his other hand."),
    "xunyou": ("Xun You (荀攸), a quiet strategist just freed from Dong Zhuo's prison",
        "Lean, calm scholar in his mid-30s with a thin beard and patient, unreadable eyes.",
        "A worn dark-blue scholar's robe, slightly rumpled from prison, neatly tied anyway.",
        "Holding a single go stone between two fingers, a go board tucked under his arm."),
    "zhongyao": ("Zhong Yao (钟繇), the great calligrapher, a Gentleman of the Yellow Gate close to the boy emperor",
        "Refined official in his early 40s with a neat beard and ink-stained fingertips, gentle but sharp eyes.",
        "Dark court robes with a black official's cap.",
        "Holding a large brush over an unrolled edict, the characters crisp and elegant."),
    "xiandi": ("Emperor Xian of Han (汉献帝 刘协), the boy emperor, a puppet in Dong Zhuo's hands — a child of about ten",
        "A slight boy of about ten with a pale, serious face and quiet, watchful eyes older than his years.",
        "Black-and-red imperial robes too big for him and a heavy mianliu crown with bead curtains.",
        "Sitting very straight on a huge throne, small hands gripping the armrests."),
    "zhujun": ("Zhu Jun (朱儁), the veteran Han General of Chariots and Cavalry, Sun Jian's old commander",
        "Upright old general in his late 50s with a grizzled grey beard, a hearty laugh and a ramrod-straight back.",
        "Worn but well-kept Han general's lamellar armor with a faded red cloak.",
        "One hand on his sword hilt, the other raised in a big, hearty wave."),
    "huangfusong": ("Huangfu Song (皇甫嵩), the great Han general who crushed the Yellow Turbans, now humiliated at Dong Zhuo's court",
        "Dignified, silent old general around 60, white hair and beard neatly bound, a stern and unbending gaze.",
        "A plain dark court robe over armor, a general's seal cord at the waist.",
        "Standing perfectly straight, both hands resting on a long sword planted point-down before him."),
    "fanchou": ("Fan Chou (樊稠), a loud, brash Xiliang general",
        "Burly man in his 30s with a wild beard and a mocking grin.",
        "Dented Xiliang lamellar armor with fur trim.",
        "Hefting a huge broad saber over his shoulder."),
    "zhangji": ("Zhang Ji (张济), a steady, reserved Xiliang general",
        "Calm man in his 40s with a trimmed beard and patient eyes.",
        "Neat dark Xiliang armor.",
        "Holding a long spear upright, making a polite martial salute."),
    "niufu": ("Niu Fu (牛辅), Dong Zhuo's son-in-law and Dong Bai's uncle",
        "Heavy-set man in his 40s with a hard, jealous glare.",
        "Rich Xiliang general's armor with gold studs.",
        "Gripping a heavy saber, pointing it at the viewer in challenge."),
    "huzhen": ("Hu Zhen (胡轸), a grim Xiliang general guarding the chancellor's inner gate",
        "Grim, scarred man in his 30s.",
        "Black armor, a red sash.",
        "Barring a gate with a drawn broad saber."),
    "dongzhuo": ("Dong Zhuo (董卓), the tyrant chancellor who burned Luoyang",
        "Enormously fat, heavy-jowled man in his 50s with a thick beard, small cunning eyes and a jovial smile that never reaches them.",
        "Extravagant purple-and-gold chancellor's robes straining over his belly, a jeweled belt.",
        "Holding a wine cup in one hand, the other resting on a sword hilt."),
    "caiyong": ("Cai Yong (蔡邕), the great scholar and calligrapher, Cai Wenji's father",
        "Gentle, frail scholar in his late 50s with a long white beard and kind, tired eyes.",
        "Plain grey scholar's robe and a scholar's cap.",
        "Holding a guqin under his arm and a bamboo scroll."),
    "wangyun": ("Wang Yun (王允), the Minister over the Masses — outwardly righteous, secretly ambitious and cunning",
        "Lean, upright old man in his 60s with neatly combed white hair; a benevolent, righteous face, but a cold, calculating glint in the eyes.",
        "Dark official's robe with the minister's seal cord.",
        "Holding a folded memorial behind his back, standing very straight."),
    "fengfuren": ("Lady Feng (冯夫人), Yuan Shu's favourite and very beautiful consort (not his wife) — a scheming villain, an adult woman",
                  "Adult woman in her late 20s of striking beauty, a sweet smile that doesn't reach her cold, calculating eyes.",
                  "Luxurious pale-gold silk robes and a jeweled hairpin — elegant, never gaudy.",
                  "Holding a lacquered box of homemade pastries, a small embroidered handkerchief in her other hand."),
    "yahuan": ("a household maid (丫鬟) of the Sun family, an adult woman",
        "Adult woman in her 20s with a round, cheerful face and a shy smile, hair in two simple buns.",
        "Plain light-green servant's dress with an apron.",
        "Carrying a tea tray with cups, curtsying."),
    "chuniang": ("an army cook (厨娘), an adult woman",
        "Sturdy, cheerful adult woman in her 30s with rosy cheeks and strong forearms.",
        "Rolled sleeves, a flour-dusted apron, a cloth tied over her hair.",
        "Holding a big cleaver in one hand and a steaming pot of braised pork in the other."),
    "xiuniang": ("an embroiderer (绣娘) who mends armor and stitches banners, an adult woman",
        "Graceful adult woman in her 20s with focused eyes and a needle held in her lips.",
        "Neat blue dress, a pincushion on her wrist.",
        "Stitching a large red banner with the character 孙 across her lap."),
    "huansha": ("a riverside washerwoman (浣纱女), an adult woman",
        "Lively adult woman in her 20s with a bright laugh, sleeves rolled high.",
        "Simple hemp dress, barefoot by the water.",
        "Holding a wooden washing bat over her shoulder, a basket of cloth at her side."),
    "caisang": ("a mulberry-leaf picker (采桑女), an adult woman",
        "Healthy, sun-kissed adult woman in her 20s with a gentle smile.",
        "Country dress with a straw hat hanging on her back.",
        "Carrying a bamboo basket full of mulberry leaves."),
    "yizhe": ("a travelling army physician (医者), a soldier card",
        "Calm, kind-faced man in his 30s with a short beard and rolled-up sleeves.",
        "A plain grey-blue robe with an apron, a medicine box on his back.",
        "Holding a roll of bandages and a bundle of herbs.",
        "a field hospital tent with herb drying racks"),
    "chaniang": ("a Jiangdong teahouse keeper (茶娘), an adult woman",
        "Sharp-eyed, confident adult woman in her 30s with a sly smile.",
        "Smart dark-red dress with a white apron, a jade hairpin.",
        "Pouring tea from a long-spouted kettle with a flourish."),
    "lusu": ("Lu Su (鲁肃), a generous, far-sighted young gentleman of Jiangdong who once gave Zhou Yu half his granary",
        "Round-faced, kind man in his late 20s with a calm smile and a neat short beard.",
        "Fine but plain scholar-gentleman robes in deep blue, a jade pendant at the belt.",
        "Gesturing toward a large granary behind him, a sack of grain at his feet."),
    "zhangzhongjing": ("Zhang Zhongjing (张仲景), the Sage of Medicine, who served as governor of Changsha",
        "Thin, serious man in his 40s with a long grey-streaked beard and thoughtful eyes.",
        "Official's robe with the sleeves rolled up, a physician's satchel across the chest.",
        "Holding an open bamboo-slip medical book in one hand and a bundle of herbs in the other."),
    "dongfeng": ("Dong Feng (董奉), the Jiangdong doctor of the apricot grove legend",
        "Gentle, ageless-looking man in his 30s with a serene smile.",
        "Simple Taoist-style physician robes in light green, a straw hat on his back.",
        "Standing under a blossoming apricot tree, a medicine gourd at his hip."),
    "zhangzhao": ("Zhang Zhao (张昭), the stern chief steward of the Sun household",
        "Stern, upright man in his 30s with a severe frown and a well-kept beard.",
        "Dark formal official robes and cap.",
        "Holding a thick stack of ledgers and a writing brush, looking disapprovingly at the viewer."),
    "daqiao": ("Da Qiao (大乔), the elder of the famous Qiao sisters, an adult woman",
        "Adult woman in her 20s, graceful gentle eyes and a calm serene smile, hair in an elegant bun with white flowers and jade hairpin.",
        "Light blue and pale cyan layered Han dress with flowing sleeves and silver embroidery.",
        "Gently holding a pink-and-white lotus blossom with both hands."),
    "xiaoqiao": ("Xiao Qiao (小乔), the younger of the famous Qiao sisters, an adult woman",
        "Adult woman in her 20s, lively bright eyes and a playful smile, hair in an elegant bun with flowers.",
        "Pink-and-white layered Han dress with flowing sleeves.",
        "Playing a guqin on her lap."),
    "zhenmi": ("Zhen Mi (甄宓), the renowned beauty later celebrated as the Goddess of the Luo River, an adult woman",
        "Adult woman in her 20s, graceful and melancholy, long flowing black hair.",
        "Flowing pale-blue silk robes with gauzy ribbons drifting as if underwater.",
        "Holding a jade hairpin, standing by a misty river."),
    "bulianshi": ("Bu Lianshi (步练师), a gentle, capable lady of Jiangdong, an adult woman",
        "Adult woman in her 20s with a soft, kind face and calm eyes.",
        "Elegant lavender Han dress, a simple hairpin.",
        "Carrying a lacquered tray with medicine bowls and bandages."),
    "qiaoguolao": ("Qiao Guolao (乔国老), the fussy old father of the Qiao sisters",
        "Plump, cheerful old man in his 60s with a long white beard and rosy cheeks.",
        "Rich brocade robes of a retired gentleman.",
        "Hugging a dowry chest overflowing with silks, looking both proud and reluctant."),
    "huofu": ("an army cook (伙夫)",
        "Burly, cheerful adult man with a bald head and a thick mustache.",
        "Stained apron over a soldier's tunic.",
        "Stirring a huge cauldron with a long ladle."),
    "chuangong": ("a Jiangdong boatman (江东船工)",
        "Wiry, sun-browned adult man with a headband and rolled trousers.",
        "Simple hemp clothes, barefoot.",
        "Carrying a long punting pole and a coil of rope over his shoulder."),
    "caiwenji": ("Cai Wenji (蔡文姬, Cai Yan), the gifted poet and musician, daughter of the scholar Cai Yong",
                 "Adult woman in her 20s, gentle but steady eyes with a quiet sorrow, long black hair half tied with a white ribbon.",
                 "Plain white scholar's robe with pale blue trim, a little dusty from the road.",
                 "Holding a guqin (古琴) to her chest; one of its strings is broken.",
                 "A quiet, candlelit ancient scholar study with unrolled bamboo scrolls on low tables, a bronze incense burner emitting delicate fragrant smoke ribbons, and a painted silk partition screen"),
    "yuanshu": ("Yuan Shu (袁术), the arrogant warlord of Nanyang and legitimate son of the prominent Yuan clan — not yet an emperor and not fat",
                "Tall, aristocratic man in his mid-30s with a neatly trimmed mustache, pale handsome face but cold, exceedingly arrogant eyes full of disdain.",
                "Sumptuous dark-purple and crimson silk robes of a Han dynasty General of the Left (后将军) over fine gilded scale armor, ornate jade belt fittings, a noble Jin-xian cap (进贤冠) with gold hairpins — authentic elite Han nobility, no dragon robes.",
                "One hand resting proudly on the jade hilt of a Han sword (玉具剑), the other gesturing with imperious disdain.",
                "An opulent Han general's command pavilion in Nanyang with lacquered pillars, bronze incense burners, deep-red tapestries, and a gilded high-backed seat"),
    "jiling": ("Ji Ling (纪灵), Yuan Shu's foremost general",
               "Tall, grim man in his 30s with a hard square face, thick eyebrows and a short beard.",
               "Heavy gilded lamellar armor with the character 袁 on the chest plate, a red cape.",
               "Wielding a three-pointed double-edged glaive (三尖两刃刀).",
               "A massive army encampment with towering yellow Yuan-clan war banners fluttering in the wind, rows of wooden barracks, and spear racks"),
    "leibo": ("Lei Bo (雷薄), one of Yuan Shu's cavalry commanders",
              "Wiry, sharp-nosed man in his 30s with a cruel grin and a scar across his chin.",
              "Light cavalry armor in Yuan yellow and black, a fur-trimmed collar.",
              "Mounted, swinging a curved cavalry saber, a bow on his back.",
              "A dusty frontier cavalry camp with horse corrals, yellow command flags, and camp tents under a glaring afternoon sun"),
    "chenlan": ("Chen Lan (陈兰), Yuan Shu's veteran general who leads the night raid",
                "Weathered, stubborn man in his 40s with a grey-streaked beard and narrowed eyes.",
                "Battered iron armor under a rain cape, mud on his boots.",
                "Levelling a long spear, rain dripping from its tip, torchlight behind him.",
                "A rain-swept night battlefield with burning barricades, muddy palisade fences, and flickering torches in the drizzling rain"),
    "qiaorui": ("Qiao Rui (桥蕤), a stout officer of Yuan Shu who spies on the Sun household",
                "Short, round-bellied man in his 30s with a sly smile and small shrewd eyes.",
                "Plain officer's armor over a merchant-style robe (he is in disguise), a straw hat hanging on his back.",
                "A heavy broad saber resting on his shoulder.",
                "A bustling ancient market street outside Nanyang city gate, with merchant carts, tiled roofs, hanging red lanterns, and market stalls"),
    "zhangxun": ("Zhang Xun (张勋), Yuan Shu's chief general, commanding tower ships on the Fei River",
               "Square-faced, heavy-browed man around 40 who looks like a proper general.",
               "Gaudy gold-trimmed armor gifted by Yuan Shu.",
               "A long ji, standing at the prow of a tower ship.",
               "tower ships and a water fort on the Fei River"),
    "liuxun": ("Liu Xun (刘勋), Yuan Shu's greedy governor of Lujiang",
             "Pale, plump, greedy man around 40 with narrow eyes and gold rings on every finger.",
             "Lavish official robes under ill-fitting armor.",
             "Holding a register of girls chosen for the 'imperial' harem.",
             "the walls of Wan city"),
    "luxun_young": ("young Lu Xun (陆逊), a quiet boy of about fourteen from the ruined Lu family of Shu — a child, not an adult; this key is for his younger appearance only, separate from the adult `luxun` card",
                  "A slender boy of about fourteen with calm, old-for-his-age eyes.",
                  "Plain cloth robes with a scorched hem.",
                  "Sitting quietly on a burnt doorstep, hands on his knees, no weapon.",
                  "the half-burnt old Lu family mansion in Shu county"),
    "zhengbao": ("Zheng Bao (郑宝), the gold-toothed bandit boss of Lake Chao who charges a toll to cross",
               "Short, stocky, sun-darkened man around 40 with a gold tooth and a swaggering grin.",
               "Bare-chested under a stolen brocade robe.",
               "A water-splitting trident over his shoulder.",
               "a bandit water fort at the mouth of Lake Chao"),
    "zangba": ("Zang Ba (臧霸), the bandit lord of Mount Tai who taxes the mountain passes",
        "Burly man in his 30s with a full beard and shrewd, calculating eyes.",
        "Leather armor of a local strongman under a worn brocade robe.",
        "A heavy broadsword, one boot resting on a wooden barricade.",
        "a toll barrier on a Mount Tai mountain road"),
    "yanliang": ("Yan Liang (颜良), Yuan Shao's fearsome champion",
        "Towering, fierce man around 40 with a ruddy face, short beard and hawk-like eyes.",
        "Heavy Hebei plate armor with a red cape.",
        "A great saber, mounted on a tall warhorse.",
        "the Zhang River valley"),
    "shenrong": ("Shen Rong (审荣), the nervous young nephew left to hold Ye city",
        "Anxious young officer in his 20s, sweat on his brow, suspicious eyes.",
        "Ji province officer's armor that fits a little too loosely.",
        "One hand on his sword hilt, the other gripping a battlement.",
        "the walls of Ye city in a thunderstorm at night"),
    "liuyao": ("Liu Yao (刘繇), the indecisive Inspector of Yang province",
        "A refined but hesitant official in his 40s with a worried frown.",
        "Inspector's official robes and a scholar's cap.",
        "Clutching a roster scroll, no weapon.",
        "a riverside camp at Niuzhu on the Yangtze"),
    "yanbaihu": ("Yan Baihu (严白虎), the swaggering local warlord of Wu commandery who calls himself king",
        "Brutish man around 40 with a heavy face and a streak of white in his hair.",
        "A white tiger pelt over leather armor.",
        "A great axe over his shoulder.",
        "a hill fort in the Wu commandery hills"),
    "wanglang": ("Wang Lang (王朗), the eloquent scholar-governor of Kuaiji",
        "Dignified scholar around 50 with a long white beard, mid-argument.",
        "Wide governor's robes and an official cap.",
        "Stroking his beard with one hand and pointing as if debating, no weapon.",
        "the gate of the Kuaiji prefectural office"),
    "zhoutai": ("Zhou Tai (周泰), the silent ex-river-pirate who became Sun Ce's bodyguard",
        "Quiet, powerfully built man in his 20s covered in scars on face and arms.",
        "Half-worn Jiangdong leather armor over a bare scarred chest.",
        "A broad saber held guard-ready in front of him.",
        "pirate skiffs on the Yangtze"),
    "jiangqin": ("Jiang Qin (蒋钦), Zhou Tai's sharp-eyed partner from the river pirates",
        "Lean, alert, sun-darkened man in his 20s.",
        "Short river-fighter's clothes under leather armor.",
        "A short halberd, standing on a boat's prow.",
        "the open Yangtze"),
    "sunquan": ("Sun Quan (孙权), Sun Jian's second son, a composed young man of about nineteen",
        "Calm young man of about nineteen with a purple-tinged beard and striking blue-green eyes, old beyond his years.",
        "Dark purple brocade robe under light armor.",
        "A ledger in one hand, the other resting on his sword.",
        "a study in the old Sun family house at Fuchun"),
    "sunshangxiang": ("Sun Shangxiang (孙尚香), Sun Jian's spirited daughter — an adult woman of about nineteen",
        "Bright, bold adult woman with strong brows and a stubborn smile.",
        "Red lamellar armor with red bound sleeves.",
        "A carved bow in hand, a short sword at her hip.",
        "a training ground beside the Fuchun River"),
    "guonvwang": ("Guo Zhao (郭照, called Nüwang), a clever Hebei orphan, Guo Jia's adopted daughter, who keeps his accounts and confiscates his wine — a teenage girl of about fifteen",
        "Calm, slender teenage girl of about fifteen with a serious face and intelligent eyes.",
        "A plain dark robe and simple hair bun, medicine stains on her sleeve.",
        "A bowl of medicine in one hand, a bundle of military reports in the other.",
        "a war tent on a snowy night in You province"),
    "tianyu": ("Tian Yu (田豫), Gongsun Zan's last White Horse officer who brings the survivors of Yijing to the hero",
        "Lean, weathered man around 30 with a steady, quiet gaze and a short beard.",
        "White lamellar armor scorched black on one side, a white cloak, white-plumed helmet under his arm.",
        "A long spear in one hand, the reins of a white horse in the other.",
        "a road in Youzhou under a grey spring sky, a few hundred white horsemen behind him"),
    "yuantan": ("Yuan Tan (袁谭), Yuan Shao's eldest son, proud and quick-tempered, who claims the family seal", "Young noble general around 30, handsome but sullen, restless proud eyes.", "Ornate Hebei armor trimmed with gold, a red cloak.", "A drawn sword raised, as if shouting orders.", "the gate of Pingyuan city in Qing province"),
    "shenpei": ("Shen Pei (审配), Yuan Shao's stubborn old general who never surrenders", "Old man in his 50s with grey hair and beard, a stern, unbending face.", "Immaculately kept Hebei lamellar armor.", "One hand on his sword hilt, standing on a city wall.", "the snowy walls of Ji city in You province"),
    "gongsunkang": ("Gongsun Kang (公孙康), the young warlord of Liaodong who calls himself King of Liaodong", "Man in his 30s with a proud but nervous face, thin moustache.", "An oversized royal robe over Liaodong armor, a fur collar.", "Standing on a snowy city wall, one hand raised to give orders.", "the walls of Xiangping in Liaodong in winter"),
    "chengyu": ("Cheng Yu (程昱), Cao Cao's cold, cunning strategist and master of ambush", "Tall, gaunt man in his 50s with a long beard and cold, narrow eyes.", "A dark scholar-official robe, a black cap.", "A feather fan in one hand, looking down from a slope.", "a winter forest at dusk with not a single bird in the trees"),
    "yanrou": ("Yan Rou (阎柔), raised among the Wuhuan since childhood, now the bridge between the steppe tribes and the north", "Weathered man in his 30s, sunburned face, sharp steppe eyes, short beard.", "A Han officer's coat worn over Wuhuan fur and leather, a fur hat.", "Holding a horse whip and the reins of a shaggy steppe horse.", "the grassland below White Wolf Mountain, Wuhuan yurts in the distance"),
    "xianyufu": ("Xianyu Fu (鲜于辅), Liu Yu's loyal old officer who brings the leaderless You province troops", "Sturdy man in his 40s, square face, grey-streaked beard, tired loyal eyes.", "Worn iron lamellar armor over a faded old You province robe.", "Holding an old banner of the late Liu Yu rolled on its pole.", "a snowy frontier fort of You province"),
    "qianzhao": ("Qian Zhao (牵招), Yuan Shang's envoy to the Wuhuan who would not run when his lord fled", "Upright man in his 30s, lean, calm stern face, neat beard.", "A dark envoy's robe with a Han tally staff, light armor beneath.", "Holding the envoy's tally staff with both hands, standing straight.", "a Wuhuan camp at dusk, braziers burning"),
    "zhangmiao": ("Zhang Miao (张邈), Cao Cao's childhood friend, the generous Governor of Chenliu who later opened Yan province to Lü Bu", "Gentle, generous-looking man in his 40s, round face, neat beard, tired regretful eyes.", "A fine but worn official's robe of a governor, a jade belt.", "Holding a wine jar in both hands as if offering it.", "a coalition camp at Suanzao, banners of many lords"),
    "baoxin": ("Bao Xin (鲍信), Chancellor of Jibei, the only lord besides Cao Cao who wanted to fight Dong Zhuo", "Upright, resolute man in his 30s, square jaw, short beard, grief in his eyes.", "Plain iron armor over a dark robe, a white mourning band on his arm.", "Holding a long spear planted in the ground.", "the banks of the Bian river at dusk, broken banners"),
    "yanxing": ("Yan Xing (阎行), Han Sui's son-in-law, the Xiliang spearman who once broke his spear on Ma Chao's neck", "Lean, hard man in his late 20s, narrow eyes, sharp cheekbones, stubble.", "Xiliang scale armor, a fur collar, a red headband.", "Holding half of a broken long spear.", "a burning Xiliang camp gate at night"),
    "huangquan": ("Huang Quan (黄权), Liu Zhang's upright registrar, the only one who would not kneel when Chengdu surrendered", "Upright, stern scholar-official in his 30s, thin face, neat long beard, unbending eyes.", "A plain dark Shu official's robe, his official cap held in one hand.", "Holding a bamboo book scroll, sitting straight.", "the gate of a recruitment hall in Chengdu, plum trees"),
    "liyan": ("Li Yan (李严), the capable, calculating commander of Mianzhu Pass who opened the gate himself", "Capable-looking man in his 30s, sharp clever eyes, trimmed beard, a faint smile.", "Shu officer's lacquered armor over a fine robe.", "One hand resting on a sword hilt, the other holding a garrison roster.", "the walls of Mianzhu Pass in the Shu mountains"),
    "yuanshang": ("袁尚（袁绍最宠爱的幼子，相貌俊美，河北的继承人）", "二十岁上下，相貌俊秀，白面，神情骄矜", "华丽的金边明光甲，锦袍", "一柄装饰华美的长剑", "邺城的宫阙"),
    "caochun": ("曹纯（曹操的从弟，虎豹骑统领）", "三十岁上下，冷峻精干，短须", "黑色重甲，黑色披风", "长槊", "黑甲黑马的虎豹骑阵列"),
    "yuanxi": ("袁熙（袁绍次子，性情温和，幽州刺史）", "二十多岁，面目温和，略显懦弱", "合身的银甲外罩青袍", "一柄长剑，握得不太稳", "幽州的城楼"),
    "xinping": ("辛评（袁谭的谋士，辛毗之兄，忠于袁家到最后）", "四十多岁，瘦削，神情忧虑，长须", "深色文官袍", "手持一卷竹简", "渤海边的船头"),
    "qiaogong": ("乔公（庐江乔家家主，大乔小乔的父亲）", "五十多岁，慈祥富态，白须", "富贵的员外袍", "手持一把团扇", "庐江乔府的庭院"),
    "xinpi": ("辛毗（辛评之弟，敢于犯颜直谏，收殓袁家三兄弟后下落不明）", "三十多岁，刚直，浓眉，短须", "朴素文官袍", "双手捧着一只木匣", "海边的南皮城"),
    "manchong": ("满宠（曹操的使者，执法严峻，面冷心细）", "三十多岁，方脸，神情冷峻", "深色官袍，腰系法曹印绶", "手持一卷诏令", "许都的官署"),
    "yanyu": ("严舆（严白虎之弟，笑里藏刀）", "三十多岁，白净，笑眯眯的", "轻甲外罩水寇锦衣", "一对短戟", "太湖的芦苇荡"),
    "zanghong": ("臧洪（东郡太守，酸枣会盟时登坛读盟辞，为义死守东武阳）", "三十多岁，清瘦，目光坚毅，长须", "旧铁甲外罩儒袍", "手持一卷盟书", "被围的东武阳城头"),
    "guanlu": ("管辂（精通卜筮的奇人）", "三十岁上下，相貌丑陋，眼神却极亮", "破旧的布衣道袍", "手持蓍草与龟甲", "星夜下的茅屋"),
    "houcheng": ("侯成（吕布部将，并州骑兵将领）", "三十多岁，粗豪，络腮胡", "并州骑兵皮甲", "长枪", "太行的雪原"),
    "zhangrao": ("张饶（青州黄巾渠帅）", "三十多岁，粗壮，满脸风霜", "黄头巾，破旧皮甲", "一柄大刀", "青州的荒原"),
    "xushao": ("许劭（月旦评主人，品评天下人物）", "四十多岁，儒雅，长须，眼神锐利", "宽袍大袖的名士装", "手持一支毛笔", "汝南的月旦评集会"),
    "fanneng": ("樊能（刘繇的大将，守神亭岭）", "三十多岁，粗壮", "丹阳兵铁甲", "长枪", "神亭岭的营垒"),
    "yangsong": ("杨松（张鲁的谋臣，出了名的贪财）", "四十多岁，肥胖，小眼睛滴溜溜转", "华贵的锦袍，满身金饰", "怀里抱着一只钱箱", "汉中的府库"),
    "maliang": ("马良（宜城马氏五常之一，白眉最良，刘备的谋士）", "二十多岁，清秀，眉中夹着几根白毛", "素雅的荆州文士袍", "手持一卷告示", "南阳汉军营寨"),
    "xuyou": ("许攸（袁绍的老朋友，贪财而自负，卖了邺城换防的时辰）", "四十多岁，瘦长脸，笑容得意", "湿透的锦袍", "手里掂着一袋金子", "雷雨夜的邺城东门"),
    "changxi": ("昌豨（泰山贼首，反复无常）", "三十多岁，精悍，眼神狡黠", "破旧的皮甲，头裹布巾", "一柄环首刀", "琅邪的山道"),
    "lingcao": ("凌操（孙策的先锋，凌统之父，豪勇）", "三十多岁，豪爽，浓眉大眼", "江东水军轻甲", "一柄长刀，站在船头", "牛渚的江面"),
    "qinyilu": ("秦宜禄（杜夫人的亡夫，吕布部下的使者，怯懦）", "三十岁上下，瘦弱，神情畏缩", "并州旧袍", "手里捏着一封信", "小沛的城门"),
    "gongsundu": ("公孙度（自封辽东王，公孙康之父）", "五十多岁，威严，花白长须", "辽东王袍外罩铁甲", "手按宝剑", "襄平的王府"),
    "dongxi": ("董袭（会稽壮士，身长八尺，水性极好）", "三十岁上下，魁梧，赤膊", "只着短褐，腰系水靠", "口咬短刀", "会稽的水门"),
    "xusheng": ("徐盛（琅邪人，逃难到江东，太湖打鱼的年轻人）", "二十岁上下，精干，晒得黝黑", "渔夫短褐外罩轻甲", "一柄长矛", "太湖边的渔村"),
    "panzhang": ("潘璋（东郡人，好酒赊账，打仗不要命）", "二十多岁，粗豪，酒糟鼻", "破旧的皮甲", "一柄大刀，腰挂酒壶", "吴郡城外的村口"),
    "mengda": ("孟达（法正的同乡，一起从关中逃进蜀）", "三十岁上下，英俊，眼神活络", "蜀中轻甲", "一杆长枪", "成都的酒肆门口"),
    "haomeng": ("郝萌（吕布部将，小沛突围时跟着吕布出逃的副将，替他牵赤兔出降）", "三十多岁，阴沉", "并州骑兵铁甲", "牵着一匹红马的缰绳", "寿春北门"),
    "zhanghong": ("张纮（广陵名士，孙策的长史）", "四十多岁，儒雅，长须", "宽袍文士装", "手持账册", "江东的府衙"),
    "lvfan": ("吕范（孙策的老友，管粮管账）", "三十多岁，端正，留短须", "整洁的官袍", "怀抱一摞账本", "会稽城外的营帐"),
    "kuailiang": ("蒯良（蒯越之兄，荆州名士）", "四十多岁，儒雅，长须", "荆州文士袍", "手持羽扇", "襄阳的府邸"),
    "zhangsong": ("张松（益州别驾，过目不忘，和法正一起画了关中的图）", "三十多岁，矮小，额头宽，相貌不扬，眼睛却很亮", "蜀锦官袍", "手持一卷地图", "成都的官署"),
    "yongkai": ("雍闿（南中豪强，起兵造反）", "三十多岁，阴鸷", "南中豪族的锦袍外罩藤甲", "弯刀", "南中的瘴林"),
    "songxian": ("宋宪（吕布部将，小沛突围时跟着吕布出逃的副将，捧印出降）", "三十多岁，木讷", "并州骑兵皮甲", "双手捧着一方大印", "寿春北门"),
    "tiankai": ("田楷（公孙瓒任命的青州刺史）", "三十多岁，好胜", "幽州骑兵铁甲，白色披风", "长枪", "界桥的大营"),
    "shanjing": ("单经（公孙瓒部将，兖州刺史）", "三十多岁，脸红脖子粗", "幽州骑兵铁甲", "长刀", "界桥的大营"),
    "liuyu": ("刘虞（幽州牧，宽厚仁德，被公孙瓒所杀）", "五十多岁，慈和，花白长须", "朴素的旧官袍，打着补丁", "手持一卷安民告示", "幽州的城门"),
    "bairao": ("白绕（黑山头领，胳膊比人腿还粗）", "三十多岁，魁梧，粗壮", "兽皮短褐", "一根大铁棒", "黑山大寨"),
    "suigu": ("眭固（黑山头领，缺两颗门牙）", "三十多岁，精瘦，笑起来缺两颗门牙", "破旧皮甲", "短刀", "黑山大寨"),
    "yangfeng": ("杨凤（黑山头领，精于算计）", "三十多岁，眼神精明", "黑山粗布袍", "手里转着两枚铜钱", "黑山大寨"),
    "baotao": ("鲍韬（鲍信之弟，战死汴水）", "二十多岁，英气", "朴素铁甲", "长枪", "汴水边的乱军"),
    "chenrong": ("陈容（臧洪的同乡，宁与臧洪同日死）", "二十多岁，清瘦书生，神情决然", "儒生布袍", "空着双手，站在堂下", "袁绍的大堂"),
    "wangkuang": ("王匡（河内太守，酸枣诸侯之一）", "四十多岁，严肃", "太守官袍外罩铁甲", "手按佩剑", "河内的军营"),
    "liudai": ("刘岱（兖州刺史，酸枣诸侯之一）", "四十多岁，富态，神情计较", "刺史官袍", "手持一张借粮单", "酸枣大营"),
    "kongzhou": ("孔伷（豫州刺史，善清谈，嘘枯吹生）", "四十多岁，名士风度，长须飘飘", "宽袍大袖", "手持麈尾", "酸枣大营的帐中"),
    "qiaomao": ("乔瑁（东郡太守，酸枣诸侯之一）", "四十多岁，瘦削", "太守官袍", "手持文书", "酸枣大营"),
    "yuejin": ("乐进（五子良将之一，个子小胆子大，每战先登）", "三十多岁，身材矮小精悍，目光凶猛", "曹军铁甲，红色披风", "一柄大刀", "北海城外的霹雳车阵"),
    "zhangbao_hj": ("张宝（张角之弟，张宁的二叔，号地公将军，会呼风唤雨）", "四十岁上下，长须，神情狂热", "黄色道袍，黄巾裹头", "手持符剑", "风雨中的祭坛"),
    "zhangliang": ("张梁（张角之弟，张宁的三叔，号人公将军，力气最大）", "三十多岁，魁梧，络腮胡", "黄巾，粗布战袍外罩皮甲", "一柄大斧", "广宗的城头"),
    "lukang": ("陆康（庐江太守，陆逊的从祖父，守城至死）", "六十多岁，清癯，白须", "朴素的太守官袍", "手持一卷书", "庐江的城头"),
    "mifuren": ("糜夫人（成年女性，温婉的大家闺秀）", "二十多岁的成年女子，温婉端庄", "素雅的锦衣", "怀抱一只妆匣", "徐州的庭院"),
    "caoxing": ("曹性（吕布部将，神射手，小沛突围时跟着吕布出逃的副将）", "三十岁上下，精瘦，眯着一只眼", "并州轻甲", "一张硬弓，回身搭箭", "夜里的小沛城门"),
    "dingfeng": ("丁奉（庐江少年，勇猛敢战，江东招贤馆）", "十七八岁的少年，精神，虎头虎脑", "江东轻甲", "一柄短刀，背一面小盾", "江东的码头"),
    "xizhicai": ("戏志才（颍川奇士，郭嘉的旧友，多病而善谋）", "三十岁上下，清瘦苍白，眼神却很锐利", "颍川书生的素袍，披着厚裘", "手持一卷兵书，袖里揣着药瓶", "北海郡府的书房"),
    "zoushi": ("邹氏（张济之妻，张绣的婶婶，成年女性，美貌而寂寞）", "二十七八岁的成年美貌妇人，眉眼含愁", "素雅的西凉妇人衣裙，外罩斗篷", "怀里抱着一只针线篮", "洛阳城外的营帐"),
    "liupi": ("刘辟（汝南黄巾渠帅，重义气）", "三十多岁，豪爽，络腮胡", "黄头巾，破旧皮甲", "大刀", "汝南的山寨"),
    "gongdu": ("龚都（汝南黄巾渠帅，刘辟的兄弟）", "三十岁上下，精瘦，眼神机警", "黄头巾，短褐", "一对短刀", "汝南的山寨"),
    "huangshao": ("黄邵（汝南黄巾渠帅，劫掠成性）", "四十岁上下，凶悍，满脸横肉", "黄头巾，抢来的锦袍", "一柄鬼头刀", "被烧的汝南村庄"),
    "hanhao": ("Han Hao (韩浩), Xiahou Dun's deputy who runs Cao Cao's military farms and once attacked kidnappers holding his own general hostage", "Weathered, square-jawed officer in his 40s, sun-darkened face, practical and unsmiling.", "Plain Wei officer's lamellar armor caked with river mud over a farmer's work robe, sleeves rolled up.", "Shouldering a wooden cheval-de-frise beam with one hand, a sword at his hip.", "the muddy Yanjin ferry on the Yellow River, rows of anti-cavalry stakes"),
    "wangxiu": ("Wang Xiu (王修), Kong Rong's upright official in Beihai who keeps the books and never bends", "Lean, grave man in his 30s with a neat short beard and steady, honest eyes.", "A plain dark official's robe, a scholar's cap, an abacus tucked in his sash.", "A ledger in one hand, a brush in the other.", "the records office of Beihai, stacks of bamboo ledgers"),
    "wuanguo": ("Wu Anguo (武安国), Kong Rong's hot-tempered champion at Beihai who fights with an iron hammer", "Burly, red-faced man in his 30s with a thick beard and a fierce scowl.", "Heavy iron armor over a dark red robe.", "A huge iron hammer resting on his shoulder.", "the gate of Beihai city with Yellow Turban tents beyond"),
    "tianfeng": ("Tian Feng (田丰), Yuan Shao's blunt, incorruptible strategist, jailed for telling the truth — he later joins the hero",
        "Gaunt, upright man around 50, beard half grey, sharp unflinching eyes, a stern mouth.",
        "A plain grey scholar's robe, a little ragged from a year in prison, straw still clinging to the hem.",
        "Hands clasped behind his back, standing very straight.",
        "the open door of a dim prison cell in Ye, morning light falling in"),
    "jushou": ("Ju Shou (沮授), Yuan Shao's loyal, far-sighted chief strategist whose advice is never heeded — he later joins the hero",
        "Lean, upright man in his 40s with a neat beard, deep-set tired eyes and a grave, stubborn dignity.",
        "A dark Hebei official's robe, a little worn, black scholar's cap.",
        "A sealed letter in one hand, a writing brush in the other, standing straight.",
        "the bank of the Zhang River at dusk, an abandoned Yuan army camp behind him"),
    "mateng": ("Ma Teng (马腾), the old Xiliang warlord, father of Ma Chao",
        "Tall, dignified veteran around 50 with a long grey beard, high nose and deep-set eyes.",
        "Xiliang iron armor under an old war robe.",
        "A hand on his sword hilt.",
        "Xiliang tents beside the Yellow River"),
    "hansui": ("Han Sui (韩遂), the wily old fox of Xiliang",
        "Lean, shrewd man in his 50s with narrowed smiling eyes and a thin beard.",
        "Xiliang leather armor under a fur cloak.",
        "Twirling his beard, a sheathed sword at his side.",
        "a Xiliang camp on the steppe"),
    "machao": ("Ma Chao (马超), the dazzling young general of Xiliang",
        "Handsome, sharp-featured young man of about 25 with fierce brows and fair skin.",
        "Silver lion-helm armor with a beast-face breastplate and a white war robe.",
        "A gold-inlaid tiger-head spear, mounted on a white horse.",
        "burning camps at the Yanjin ford of the Yellow River"),
    "madai": ("Ma Dai (马岱), Ma Chao's steady cousin",
        "Steady, alert man in his 20s, plainer than his cousin.",
        "Xiliang light armor and a brown cape.",
        "A long saber.",
        "a Xiliang cavalry camp"),
    "pangde": ("Pang De (庞德), the iron-willed Xiliang champion",
        "Dark, rugged man in his 30s with a full beard and an unbending stare.",
        "Heavy Xiliang armor and a dark cape.",
        "A great saber held across his body.",
        "the burning camps at Yanjin"),
    "tadun": ("Tadun (蹋顿), the Wuhuan chieftain beyond the Great Wall",
        "Fierce steppe chieftain around 40 with a shaved head except a few locks, high cheekbones.",
        "A heavy fur cloak with gold ornaments.",
        "A curved saber, on a sturdy steppe horse.",
        "the grasslands below White Wolf Mountain with Wuhuan riders"),
    "gongsunkang": ("Gongsun Kang (公孙康), the cool, calculating lord of Liaodong",
        "Shrewd, cold-eyed man around 30.",
        "Liaodong fur coat over official robes.",
        "Holding a closed wooden box in both hands, no weapon.",
        "the gate of Xiangping city in Liaodong"),
    "liuzhang": ("Liu Zhang (刘璋), the soft, indecisive governor of Yi province",
        "Plump, mild man around 40 with hesitant eyes.",
        "Lavish governor's robes.",
        "Holding a sealed letter, no weapon.",
        "the governor's hall in Chengdu"),
    "yanyan": ("Yan Yan (严颜), the stubborn old general of Ba commandery",
        "Unbending veteran in his 60s with white hair and beard, head held high.",
        "Old Shu iron armor and a red cape.",
        "A great saber.",
        "the walls of Jiangzhou above the river"),
    "zhangren": ("Zhang Ren (张任), Yi province's most stubborn defender",
        "Stern, intense man in his 30s with thin lips and sharp brows.",
        "Fine Shu iron armor with a teal cape.",
        "A long spear.",
        "the Golden Goose Bridge outside Luo city"),
    "fazheng": ("Fa Zheng (法正), the sharp-tongued strategist of Shu",
        "Lean, clever man around 30 with a faint cold smile and piercing eyes.",
        "Dark scholar's robes.",
        "A rolled map of Yi province in hand.",
        "a misty Shu mountain road"),
    "wuxian": ("Wu Xian (吴苋), a gentle, clever daughter of a great Shu family — an adult woman of about twenty",
        "Graceful adult woman with kind, intelligent eyes.",
        "Shu brocade robes and pearl hairpins.",
        "An account book in one hand, a writing brush in the other.",
        "the brocade markets of Chengdu"),
    "menghuo": ("Meng Huo (孟获), the proud king of the Nanzhong tribes",
        "Huge, dark-skinned king around 40 with curly hair and a tiger-tooth necklace.",
        "Rhinoceros-hide armor with bone ornaments.",
        "A great saber over his shoulder, rattan-armored warriors behind him.",
        "the Nanzhong jungle and Coiled Snake Valley"),
    "luxun": ("Lu Xun (陆逊), the calm young strategist of the Lu family, now a young man of about nineteen",
        "Refined young man of about nineteen with calm, steady eyes.",
        "Scholar's robes under light armor.",
        "A long sword at his side, a fan in hand.",
        "a river camp on the Han River"),
    "yujin": ("Yu Jin (于禁), Cao Cao's strict, by-the-book general",
        "Severe, meticulous man around 40.",
        "Immaculate black Cao army armor.",
        "A long saber, standing behind a row of chevaux-de-frise.",
        "the deep trenches and ramparts of Guandu"),
    "lidian": ("Li Dian (李典), Cao Cao's scholarly general",
        "Calm, bookish man around 30.",
        "Light Cao army armor over a scholar's robe.",
        "A command flag in hand.",
        "a raised platform with heavy crossbows at Guandu"),
    "xiahouyuan": ("Xiahou Yuan (夏侯渊), Cao Cao's lightning-fast cavalry commander",
        "Lean, quick man around 40 with hawk-like eyes.",
        "Light cavalry armor and a dark cape.",
        "Twisting in the saddle to loose an arrow from a galloping horse.",
        "dust clouds over Baima slope"),
    "xuchu": ("Xu Chu (许褚), Cao Cao's tiger-like bodyguard",
        "Massive, bear-like man in his 30s, simple-faced but ferocious, close-cropped hair.",
        "Bare-chested, his armor thrown on the ground.",
        "A huge iron broadsword over his shoulder.",
        "the dusty plain of Xingyang"),
    "zhanghe": ("Zhang He (张郃), the capable Hebei general now serving Cao Cao",
        "Sharp, capable man in his 30s with a short beard.",
        "Cao army iron armor and a crimson cape.",
        "A long spear.",
        "the gate towers of Hulao Pass"),
    "zhanglu": ("Zhang Lu (张鲁), the Celestial Master of the Five Pecks of Rice in Hanzhong",
        "Gentle, lean man in his 40s with a long beard.",
        "Daoist cap and robes.",
        "Holding a wooden rice measure, no weapon.",
        "a free rice-kitchen shelter in Hanzhong"),
    "zhangwei": ("Zhang Wei (张卫), Zhang Lu's hot-headed younger brother",
        "Fierce-eyed man in his 30s, harsher than his brother.",
        "Hanzhong iron armor over a Daoist robe.",
        "A long saber.",
        "the walls of Yangping Pass under the Qinling cliffs"),
    "xiahoumao": ("Xiahou Mao (夏侯楙), Cao Cao's pampered son-in-law left to hold Chang'an",
        "Pale, well-fed man around 30 looking flustered.",
        "Fancy gold-trimmed armor that does not fit.",
        "Clutching a horse's reins, ready to flee.",
        "the gates of Chang'an"),
    "zhugeliang": ("Zhuge Liang (诸葛亮), the brilliant, proud young strategist serving Liu Bei",
        "Handsome, proud young man of about 21 with fine features and a restrained edge in his eyes.",
        "A scholar's silk headscarf and a white crane-feather cloak.",
        "A white feather fan.",
        "an eight-trigram battle formation with repeating crossbows beside the Luo River"),
    "dianwei": ("Dian Wei (典韦), Cao Cao's giant, loyal bodyguard, called the Evil-Comer",
        "A towering, tower-like man in his 30s with a dark face, a thick curly beard, scars everywhere, fierce yet honest eyes.",
        "Battered heavy Cao army armor with one arm bare.",
        "A massive iron halberd in each hand.",
        "the south gate of Luoyang with the enemy camp and its cooking smoke below the walls"),
    "chenwu": ("Chen Wu (陈武), a loyal Jiangdong general from Lujiang who followed Sun Ce",
               "Sturdy, tanned man in his late 20s, square jaw, short beard, calm steady eyes of a marksman.",
               "Jiangdong red-and-brown lamellar armor, a quiver of red-fletched arrows on his back, a leather bracer.",
               "Drawing a large recurved war bow to full draw, arrow aimed past the viewer.",
               "A Jiangdong fortress rampart overlooking the misty Yangtze River, with red Sun-clan banners, wooden archery targets, and distant patrol boats"),
    "jiangdong_gong": ("a Jiangdong archer (江东弓手), a common soldier of the Sun family's army",
                       "Young adult soldier with a sun-browned face and a focused squint, headband.",
                       "Simple red Han tunic over light leather armor, straw sandals, quiver at the hip.",
                       "Nocking an arrow on a plain wooden bow.",
                       "A Sun family army training ground and riverside camp with red flags, wooden archery butts, weapon racks, and barracks tents"),
    "liehu": ("a mountain hunter (山中猎户) from the hills around Fuchun who joined the army",
              "Weathered, lean adult man in his 30s with a scruffy beard and a friendly grin.",
              "Fur vest over rough hemp clothes, a boar-tusk necklace, a pheasant hanging from his belt.",
              "A hunting bow slung ready, one arrow held between his fingers.",
              "A misty Fuchun mountain forest with tall pine trees, green bamboo thickets, mossy boulders, and distant layered mountain ridges"),
    "yuenv_gong": ("a Yue woman archer (越女弓手), an adult woman of the southern Yue people serving as an archer",
                   "Adult woman in her 20s, confident sharp eyes, tanned skin, hair in a high braided ponytail with a red cord.",
                   "Close-fitting indigo Yue-style tunic with embroidered hems and leather arm guards, short practical skirt over trousers.",
                   "Drawing a slim bamboo bow, arrow at her cheek.",
                   "A misty subtropical bamboo grove with a crystal mountain stream, wild mountain flowers, and steep verdant green cliffs"),
    "shanyue_nu": ("a Shanyue crossbowman (山越弩手), a hill-tribe fighter from the mountains of Jiangdong",
                   "Stocky adult man with tattooed arms and cheeks, fierce stare, hair tied up with a bone pin.",
                   "Rattan-and-hide armor, cloth leggings, bare feet planted on a rock.",
                   "Aiming a heavy wooden crossbow braced against his shoulder.",
                   "A rugged Shanyue mountain fortress with heavy timber stockades, rock crags, tribal bone totems, and mountain mist"),
    "zhangfei": ("Zhang Fei (张飞), the legendary fierce powerhouse general from the Three Kingdoms era",
                 "Massive, dark-skinned muscular powerhouse warrior in his early 30s. Fierce round panther-like eyes with an intense battle glare, thick bristling black beard and mustache, roaring at the top of his lungs with explosive, terrifying battle fury (wide open mouth yelling a war cry).",
                 "Rugged Han dynasty black iron plate armor over a deep green battle tunic, heavy spiked shoulder guards, thick leather belt with a bronze tiger buckle.",
                 "Gripping his legendary Zhangba Snake Spear (丈八蛇矛 - an ancient long spear with an undulating, serpentine wavy steel spearhead) thrusting forward dynamically.",
                 "A battle-ravaged camp with dust clouds, broken wagons, flaming braziers, and billowing war banners"),
    "liubei": ("Liu Bei (刘备), the humble, earnest leader who calls himself a descendant of the Prince of Zhongshan",
               "Gentle-faced man in his early 30s with notably large earlobes and long arms, kind sincere eyes, neat short beard, a slightly awkward, eager-to-please smile.",
               "Modest green-and-cream Han scholar-general robe over light leather armor, a simple topknot with a cloth band.",
               "Holding his twin swords (双股剑) a little clumsily in both hands, as if not quite sure how to use them.",
               "A modest Han military garrison headquarters with a tactical map table, candle lanterns, rolled bamboo scrolls, and straw partitions"),
    "guanyu": ("Guan Yu (关羽), the dignified god of war of the Three Kingdoms era",
               "Tall imposing man in his early 30s with a deep red face, phoenix eyes half-closed in calm pride, a magnificent long flowing black beard reaching his chest.",
               "Green war robe over Han dynasty lamellar armor, green headscarf, a heroic cape.",
               "Holding the Green Dragon Crescent Blade (青龙偃月刀 - a long glaive with a dragon-headed crescent blade) upright beside him.",
               "A solemn military command post with green banners, heavy weapon stands, and dramatic evening clouds in the sky"),
    "lvbu": ("Lü Bu (吕布), the unrivaled, terrifying warrior of the Three Kingdoms era",
             "Tall, handsome, arrogant warrior in his early 30s with a cold predatory glare and a confident smirk, overwhelming aura.",
             "Ornate crimson and black armor with gold trim, a helmet crowned with two long pheasant tail feathers (雉尾冠), a red cape flaring behind him.",
             "Holding the Sky Piercer halberd (方天画戟 - a long halberd with a crescent side blade) across his shoulders.",
             "A scorched, dust-swept battlefield under a dramatic crimson and dark sky, with broken weapons stuck in the ground and distant fortress ramparts"),
    "huatuo": ("Hua Tuo (华佗), the legendary wandering physician of the Three Kingdoms era",
               "Lean middle-aged man with a calm, sharp gaze, a thin goatee, sleeves rolled up like a working doctor.",
               "Plain grey-blue traveling robe, a wooden medicine chest on his back painted with the characters 沛国华佗.",
               "Holding a silver acupuncture needle between his fingers; a small hand axe peeks out of the medicine chest (his brain-surgery joke).",
               "A rustic apothecary clinic and traveling medical pavilion with hanging bundles of dried medicinal herbs, an herb-grinding mortar, and medicine drawers"),
    "zhangning": ("Zhang Ning (张宁), daughter of the Yellow Turban leader Zhang Jiao — a wandering healer, not a sorceress — an adult woman",
                  "Gentle, clear-eyed adult woman of about 19 with a calm, quietly stubborn expression, a few loose strands of hair.",
                  "Plain undyed white hemp cross-collar dress with the sleeves rolled up, hair tied up with a dark blue cloth band, a single yellow jade pendant carved with the characters 太平 at her waist (her father's keepsake, the only Taoist trace); no yellow robe, no talismans.",
                  "A bamboo medicine box slung on her back, a long gold acupuncture needle held between two fingers, the other hand checking a pulse.",
                  "a misty Taihang mountain field hospital: a straw-roofed shed with bundles of drying herbs, a clay pot of medicine steaming over a small fire"),
    "yuji": ("Yu Ji (于吉), the eerie Taoist priest of Jiangdong",
             "Middle-aged Taoist with a thin mustache and an unsettling, knowing smile, narrowed eyes.",
             "Flowing white Taoist robe, hair in a topknot with a wooden pin.",
             "Holding a tall cloth banner reading 「于吉仙师 符水治百病」 with a single copper coin dangling from it.",
             "A mystical mountain stone altar shrouded in swirling incense smoke, yellow Taoist talisman streamers fluttering in the wind, and ancient pine trees"),
    "fushui_xintu": ("a fanatical follower of the Taoist charm-water cult (符水信徒)",
                     "Gaunt peasant with feverish devoted eyes, a yellow paper talisman stuck on the forehead.",
                     "Ragged brown peasant clothes, a yellow cloth sash.",
                     "Holding out a bowl of murky charm water with both hands, pressing it forward insistently.",
                     "A rural village temple courtyard crowded with devoted peasants, incense smoke, and yellow Taoist charm banners tied to wooden poles"),
    "baie_hu": ("a giant white-browed tiger (吊睛白额虎) from Chinese legend",
                "Enormous fierce tiger with slanted glaring eyes and a white patch on its brow, muscles rippling.",
                "Wearing a simple leather war saddle (it can be ridden as a mount).",
                "Crouched and snarling, about to pounce, claws out.",
                "A wild mountain cliff among ancient twisted pine trees, jagged rocks, and swirling mountain fog"),
    "boar": ("a huge wild boar (野猪)",
             "Massive bristly dark-brown boar with long curved tusks and small angry red eyes.",
             "No clothing; mud splashed on its flanks.",
             "Head lowered, charging straight at the viewer.",
             "A deep primeval forest clearing with thick moss, muddy soil, gnarled tree roots, and tangled briars"),
    "lijue": ("Li Jue (李傕), the brutal Xiliang general who burned Luoyang",
              "Heavy-set, cruel-faced man in his 30s with a scarred cheek, thick stubble and a sneer.",
              "Dark Xiliang iron scale armor with fur trim, a horsehair-crested helmet.",
              "A flaming torch in one hand and a saber in the other, fire and smoke behind him.",
              "The burning gates and streets of Luoyang at night, with blazing imperial palaces, billowing black smoke, and glowing embers in the night sky"),
    "chengpu": ("Cheng Pu (程普), the eldest veteran general under Sun Jian",
                "Kindly, dignified veteran in his 40s with a long beard and a warm smile.",
                "Well-worn bronze lamellar armor over a dark red tunic.",
                "Holding the iron-spined snake spear (铁脊蛇矛), bowing slightly with one hand raised in greeting.",
                "A seasoned Jiangdong army headquarters with red banners, heavy wooden stockades, and Sun-clan tiger standards"),
    "handang": ("Han Dang (韩当), Sun Jian's silent horse-archer general",
                "Expressionless, weathered man in his 30s with sharp hawk-like eyes and a short beard.",
                "Light leather cavalry armor, a quiver of arrows at his hip.",
                "Mounted on a horse, drawing a large bow.",
                "An open reed marsh and riverbank along the Yangtze with grazing warhorses, wooden piers, and river mist"),
    "huanggai": ("Huang Gai (黄盖), Sun Jian's tough veteran general",
                 "Burly veteran in his 40s with a booming laugh, grey-streaked beard, chest covered in old scars.",
                 "Heavy armor with the robe pulled open to show off his scars.",
                 "Holding an iron whip (铁鞭), slapping his chest proudly.",
                 "The wooden deck of a Jiangdong war galley on the Yangtze River, with heavy ship bulwarks, coiled ropes, and rolling river waves"),
    "zhuzhi": ("Zhu Zhi (朱治), Sun Jian's shrewd quartermaster general",
               "Sharp, composed man in his 30s with a neat mustache and an appraising look.",
               "Official's robe over light armor, a sword at his waist.",
               "Holding a supply list scroll in one hand and a writing brush in the other.",
               "An orderly army granary and logistics warehouse with stacked rice sacks, supply carts, accounting scrolls, and ledger chests"),
    "wujing": ("Wu Jing (吴景), Lady Wu's protective younger brother",
               "Handsome general in his 30s whose features resemble his elder sister's, a short neat beard, a suspicious, protective frown.",
               "Bright silver cavalry armor and a white cape.",
               "Riding a white horse, gripping the reins and glaring at the viewer.",
               "A Sun family courtyard and military stable with sleek cavalry horses, wooden gates, and fluttering silk pennants"),
    "sunben": ("Sun Ben (孙贲), Sun Jian's competitive nephew",
               "Young spear general in his 20s with a cocky smirk, arms crossed.",
               "Red and bronze Sun-clan armor.",
               "Hugging a spear against his shoulder, looking unimpressed.",
               "A military training courtyard with wooden practice dummies, weapon racks, and earthen ramparts"),
    "sunjing": ("Sun Jing (孙静), Sun Jian's stingy younger brother who keeps the family home",
                "Thin older man in his 40s with squinting eyes and a thin mustache, a miserly expression.",
                "Plain grey household robe and a cap.",
                "Flicking the beads of an abacus, peering over it suspiciously.",
                "A Sun clan estate counting room and storehouse with heavy iron-bound chests, stacked bamboo tax records, and abacus desks"),
    "tangji": ("Lady Tang (唐姬), the widowed consort of the deposed young emperor",
               "An adult woman in her twenties with graceful noble bearing, soot smudged on her cheek, steady unyielding eyes.",
               "Plain coarse cloth dress that cannot hide her dignity, hair loosely tied.",
               "Clutching a jade hairpin to her chest.",
               "A desolate ruined palace hall in burned Luoyang, with blackened wooden pillars, crumbling brick walls, and moonlight shining through broken ceiling tiles"),
    "yanzhihu": ("'Rouge Tiger' (胭脂虎), the fierce bandit queen of a mountain fort",
                 "A curvy adult woman in her thirties with a bold, teasing grin, fiery eyes and a confident swagger.",
                 "Red bandit leather vest and trousers, a sash at the waist, bangles.",
                 "Hands on hips with twin sabers tucked in her sash, standing on a fort wall.",
                 "The timber watchtower and palisade gate of a mountaintop bandit fortress, with red festival lanterns, tiger pelt banners, and scenic mountain peaks"),
    "huangjin_nvyi": ("a Yellow Turban field medic (黄巾女医)",
                      "An adult woman in her twenties, calm and capable, sleeves rolled up.",
                      "Yellow headscarf, simple brown clothes, a medicine chest painted with Taiping Taoist charms.",
                      "Bandaging a wounded arm, looking up at the viewer.",
                      "A makeshift field hospital tent with straw pallets for the wounded, steaming herb cauldrons, and yellow talisman banners"),
    "gongnv": ("a palace maid fleeing the burning Luoyang (宫女)",
               "An adult woman in her twenties, frightened but resolute.",
               "Han dynasty palace dress with a soot-blackened hem.",
               "Holding a lantern and a small medicine box.",
               "A burning palace corridor during the fall of Luoyang, with collapsing gilded beams, red sparks, and smoky archways"),
    "xiliang_nvbing": ("a Xiliang female cavalry guard (西凉女亲兵)",
                       "An adult woman in her twenties, fierce and loyal, high ponytail.",
                       "Fitted Xiliang leather armor with fur trim.",
                       "Mounted, a curved saber raised.",
                       "A windswept northwestern mountain pass with rocky cliffs, Xiliang wolf-head banners, and distant desert hills"),
    "guosi": ("Guo Si (郭汜), the raiding Xiliang general",
              "Wiry, greedy-looking man in his 30s with a crooked grin.",
              "Xiliang cavalry armor with looted jewelry hanging from it.",
              "Holding a long lance (马槊) and a sack of loot.",
              "A plundered and burning frontier village with smoking wooden houses, broken fences, and Xiliang raiding flags"),
    "liru": ("Li Ru (李儒), Dong Zhuo's scheming strategist",
             "Pale, thin man in his 30s with cold calculating eyes and a thin smile.",
             "Dark purple scholar's robe.",
             "Holding a cup of poisoned wine (鸩酒) in one hand, a folding fan in the other.",
             "A dim, candlelit chancellor's inner sanctum with dark purple silk curtains, bronze incense burners, secret scrolls, and heavy shadows"),
    "feixiong_bing": ("a Flying Bear elite heavy cavalryman (飞熊军) of Dong Zhuo's guard",
                      "Massive faceless soldier behind a bear-shaped visor.",
                      "Full black heavy armor with bear-fur trim.",
                      "Mounted on an armored warhorse, lance lowered.",
                      "A grim Xiliang vanguard cavalry line on a vast windswept plain, with dark heavy banners and distant mountain ranges"),
    "xiliang_bing": ("a Xiliang light cavalry raider (西凉铁骑)",
                     "Rugged frontier horseman in his 20s with windburned skin.",
                     "Leather and iron cavalry gear, a fur hat.",
                     "Galloping, saber drawn.",
                     "A dusty frontier mountain road with dry brush, rocky cliffs, and galloping horse tracks under a pale sky"),
    "shanzei_bing": ("a one-eyed mountain bandit (山贼)",
                     "Scruffy bandit with an eye patch and a gap-toothed leer.",
                     "Ragged patched clothes, a rope belt.",
                     "Carrying a big wood axe over his shoulder.",
                     "A winding mountain pass with a rough timber stockade gate, spiked wooden barricades, and jagged rocky cliffs"),
    "inf_n": ("a Han dynasty government sword-and-shield soldier (官军刀兵)",
              "Disciplined, stern-faced soldier in his 20s.",
              "Standard Han army lamellar armor and helmet.",
              "Sword raised behind a round shield.",
              "A Han dynasty garrison camp courtyard with earthen ramparts, wooden watchtowers, and red military flags"),
    "zhangfuren": ("Lady Zhang (张夫人), the shrewd, warm matriarch of the wealthy Zhen merchant family — the heroine of the northern start, an adult woman",
                   "Graceful and composed woman in her 30s, sharp and warm eyes, an air of quiet command.",
                   "Rich dark brocade robes with full hairpins and jewelry befitting a great merchant house's mistress.",
                   "A ledger book in one hand, a silver hairpin in the other, standing straight-backed.",
                   "a granary hall at the Zhen family estate in Zhongshan, Jizhou, sacks of grain stacked in rows"),
    "guojia": ("Guo Jia (郭嘉), a brilliant, dissolute strategist from Yingchuan, rarely sober",
               "Lean young man in his 20s, eyes glazed with drink yet sharp underneath, a knowing half-smile.",
               "Thin, loosely-draped blue-grey scholar's robe, a feather fan tucked at the shoulder.",
               "A wine gourd tied with red cord at his waist, no weapon.",
               "a snowy market street in Zhending, Changshan, wine-shop banners fluttering"),
    "zhaoyun": ("Zhao Yun (赵云), a young knight-errant of Changshan, upright and fierce",
                "Young man around 20, sharp handsome features, a stern, unyielding expression.",
                "Silver-white light armor over a white war robe, hair bound under a silver helmet.",
                "A bright silver spear with a frost-rimed tip.",
                "a snowy Changshan plain, a white warhorse waiting nearby"),
    "zhenmi_young": ("young Zhen Mi (甄宓), the early-teen daughter of the Zhen family — a child, not an adult; this key is for her younger appearance only, separate from the adult `zhenmi` gacha card",
                     "A girl of about thirteen or fourteen, round cheeks, dimples when she smiles, hair in twin buns.",
                     "Pale pink embroidered robes with little rabbits stitched on the hem.",
                     "Holding a sweet pastry or a cloth doll, no weapon.",
                     "a covered walkway at the Zhen family estate in snow"),
    "sunshangxiang_young": ("young Sun Shangxiang (孙尚香), Sun Jian's daughter at about twelve or thirteen — a girl, not yet an adult; this key is for her early-teen appearance only, separate from the adult `sunshangxiang` card",
                            "A mischievous girl of twelve or thirteen, slightly round cheeks, thick brows, hair in a high ponytail, the spirited look she will grow into.",
                            "A red narrow-sleeved short jacket, dark trousers, cloth boots.",
                            "Gripping a wooden practice sword.",
                            "the courtyard of the Sun family house in Fuchun"),
    "guotu": ("Guo Tu (郭图), Yuan Shao's grain-supervising aide — petty, arrogant, a northern-route villain",
              "Man in his 30s, pale and slightly plump, a contemptuous sneer.",
              "Fine brocade official robes and an advancing-scholar's cap, a jade-studded belt.",
              "A grain-levy document in one hand, the other behind his back.",
              "the county court hall of Zhending"),
    "hanfu": ("Han Fu (韩馥), the governor of Jizhou — timid and ineffectual",
              "Man in his 50s, soft and overweight, a shrinking, nervous expression.",
              "Oversized official robes and a drooping scholar's cap.",
              "No weapon, hands fidgeting with his sleeve.",
              "a corner of the county court hall of Zhending, behind the judge's bench"),
    "lidamu": ("Li Damu (李大目), chieftain of the Black Mountain bandits — the final boss of the northern first chapter",
               "Man in his 40s, a slab of scarred muscle, one eye missing and the other narrowed, a wild beard.",
               "Ragged animal-hide vest over battered iron armor, old scars showing.",
               "A huge two-handed mountain-splitting axe.",
               "the gate of the Black Mountain stockade in the Taihang mountains, blood-red sunset"),
    "zhangbaiqi": ("Zhang Baiqi (张白骑), a Yellow Turban remnant chieftain who rides a white horse",
                   "Man in his 30s, lean and cunning-eyed.",
                   "Yellow Turban remnant garb, faded yellow cloth over leather armor.",
                   "A curved saber, riding a white horse.",
                   "a dusty Taihang mountain gorge"),
    "xuanjizi": ("Xuanjizi (玄机子), a sorcerer claiming the mantle of the Way of Peace — a fraud preying on refugees",
                 "Ageless, gaunt figure, long matted hair hiding half his face, eyes manic and cruel.",
                 "A ragged Daoist robe covered in paper talismans, bare feet.",
                 "A peachwood staff wound with charms and withered herbs.",
                 "a blood-stained mountain cave altar, smoke and talismans swirling"),
    "heishan_bing": ("a lean Black Mountain bandit scout (黑山游骑)",
                     "Wiry mountain bandit with soot smeared on his face as camouflage.",
                     "Furs and coarse cloth, mismatched scavenged gear.",
                     "A broadsword or spear, crouched warily.",
                     "the snowy forest fringe outside the Black Mountain stockade"),
}

# battle scenario id: the scene (the enemy in its setting, Rance X style)
BATTLES = {
    "m9_bashu_qiang": "三峡巫峡的栈道上，两岸绝壁高耸，江水在脚下翻滚：一排巴蜀长枪兵（川军皮甲、竹笠，长枪如林）从栈道转角探出，崖壁上挂着「刘」字小旗；下方 35% 留白为开阔坚硬平整的栈道石台供我方出战卡牌陈列",
    "m9_bashu_nu": "白帝城下的江岸，城墙依山而建：城头和岸边一排巴蜀连弩手（川军皮甲、竹笠，端着连弩）齐齐对准江面；下方 35% 留白为开阔坚硬平整的江岸硬石滩供我方出战卡牌陈列",
    "m9_kuimen": "瞿塘峡口夔门，两岸绝壁如门：江面上横着三道粗大的铁索，索上挂满铃铛，两岸水寨里巴蜀连弩手林立，江中浪涛翻滚；下方 35% 留白为开阔坚硬平整的江边硬石滩供我方出战卡牌陈列",
    "m9_dongzhou": "巴东的山口，云雾缭绕：一队东州兵（破旧皮甲、关中短褐、头裹布巾，木盾环首刀）在山口结阵死守，神情没有退路；下方 35% 留白为开阔坚硬平整的山口硬土地供我方出战卡牌陈列",
    "m9_yanyan": "江州城下，长江与嘉陵江交汇处：严颜（须发全白的老将，川军铁甲，手持大刀，背一张长弓）领着守军冲出城门，城头飘着「严」字旗；下方 35% 留白为开阔坚硬平整的城门前石板地供我方出战卡牌陈列",
    "m9_zhangren": "雒城城门前的金雁桥边：张任（三十多岁的蜀中名将，面容坚毅，银灰铁甲，横持铁枪，骑白马）立马挡在城门前，身后是严阵以待的川军；下方 35% 留白为开阔坚硬平整的城前夯土地供我方出战卡牌陈列",
    "m10_guizu": "汉中金牛道的栈道上，云雾缭绕：一群五斗米道的鬼卒（粗布短褐外罩黄色道袍，头裹黄巾，环首刀和画符的木牌）拦在路上，神情狂热，嘴里念念有词；下方 35% 留白为开阔坚硬平整的栈道前的山石平台供我方出战卡牌陈列",
    "m10_banshun": "葭萌关外的山坡上：一排板楯蛮（赤膊披兽皮，脸上画赭红色纹，手持比人还高的长方形木盾和短矛）把木盾竖成一堵墙，盾缝里伸出矛尖；下方 35% 留白为开阔坚硬平整的山坡下的硬土地供我方出战卡牌陈列",
    "m10_yangang": "阳平关外的山梁上扎着两座营寨，营门挂着「杨」字旗：杨昂（三十多岁的粗壮将领，汉中铁甲外披黄色道袍，头裹黄巾，手持长刀）立在营门前，身后是板楯蛮和黄巾道兵；下方 35% 留白为开阔坚硬平整的山梁下的硬土地供我方出战卡牌陈列",
    "m10_zhangwei": "夜里阳平关的关门大开，关墙贴着秦岭绝壁：张卫（三十多岁，比哥哥凶狠，瞪眼，汉中铁甲外披道袍，手持长刀）提刀冲在最前头，身后的道兵举着火把，关墙上挂着空水桶；下方 35% 留白为开阔坚硬平整的关前的青石地面供我方出战卡牌陈列",
    "m10_jijiu": "汉中城外的义舍门口，大锅冒着热气：几个五斗米祭酒（瘦削，山羊胡，黄色道袍、道冠）在烧黄符，把符灰撒进水碗里分给道兵，道兵端着碗仰头就喝；下方 35% 留白为开阔坚硬平整的义舍前的夯土地供我方出战卡牌陈列",
    "m10_guizu_mc": "米仓山中被挖开的古墓入口，墓道里透出幽光：几个摸金校尉（玄黑札甲沾满泥土，背插黑底白字「魏」字小旗，手持长柄铁铲和油灯）从墓道里钻出来，身后堆着挖出的青铜器；下方 35% 留白为开阔坚硬平整的墓前的山石平地供我方出战卡牌陈列",
    "m10_banshun_hs": "定军山脚下，一排青州老兵（四十岁上下，满脸刀疤，玄黑札甲外罩深蓝战袍，铁盔黑缨，背插黑底白字「魏」字小旗）的长枪竖得整整齐齐，后面是成排的黑底「魏」字大旗；下方 35% 留白为开阔坚硬平整的山脚的硬土地供我方出战卡牌陈列",
    "m10_xiahouyuan": "定军山的山谷，两侧是陡峭的山坡：夏侯渊（四十岁上下，精悍迅捷，眼神如鹰，曹军轻骑甲、深色披风）在奔马上反身开弓，箭尖指向对面山坡，身后是打黑底「魏」字旗的骑兵；下方 35% 留白为开阔坚硬平整的谷底的碎石地供我方出战卡牌陈列",
    "m10_ziwu_exit": "子夜的子午谷口，一排西凉营寨堵住了出口，营门大开像一只口袋，营寨最高的望楼上站着摇羽扇的李儒（瘦削的文士，嘴角带笑），远处山谷里烧断的栈道还在冒烟：李傕（西凉铁甲，满脸横肉，一手火把一手刀）骑在马上狞笑，郭汜在他身旁，身后是黑压压的西凉骑兵和飞熊军；下方 35% 留白为开阔坚硬平整的谷口外的硬土地供我方出战卡牌陈列",
    "m10_scout": "散关的关楼下，关楼上插着「曹」字旗：一队西凉斥候（皮甲毡帽，弯刀短弓，骑着矮壮的西凉马）在关前来回游走；下方 35% 留白为开阔坚硬平整的关前的夯土路供我方出战卡牌陈列",
    "m10_feixiong": "故道的山口，悬崖上钉着栈道：一队飞熊军（董卓旧部的重甲骑兵，黑色重甲、熊头盔饰）下了马，牵着马堵在路上，盾牌连成一排；下方 35% 留白为开阔坚硬平整的山口的碎石地供我方出战卡牌陈列",
    "m10_huzhen": "陈仓小城的城头，城墙又高又厚，竖着一面「胡」字旗：胡轸（脸上带疤的冷面将，黑甲红腰带）横刀立在城头，城下滚木礌石堆成小山；下方 35% 留白为开阔坚硬平整的城下的硬土地供我方出战卡牌陈列",
    "m10_youqi": "渭水北岸的河滩：一队西凉游骑（皮甲毡帽，手持马刀，骑着西凉马）沿河来回奔驰，马蹄溅起水花，远处是长安城的轮廓；下方 35% 留白为开阔坚硬平整的河滩上的硬沙地供我方出战卡牌陈列",
    "m10_hubao": "长安城外的大道上：一队虎豹骑（玄黑札甲外罩深蓝战袍，铁盔黑缨，连人带马披着黑色铁甲，手持长戟）列阵待冲，后面竖着黑底白字的「魏」字大旗；下方 35% 留白为开阔坚硬平整的夯土官道供我方出战卡牌陈列",
    "m10_guosi": "长安西门，吊桥收着：郭汜（西凉将，贪婪的脸）站在城头，身后的兵正把一箱箱抢来的金子往马背上捆；城墙上的箭垛后面是西凉弓兵；下方 35% 留白为开阔坚硬平整的城门前的青石地面供我方出战卡牌陈列",
    "m10_lijue": "未央宫前的长阶，宫殿宏伟却一片狼藉：李傕（西凉铁甲，满脸横肉，手持长刀）在台阶上横刀立马，身后站着一排披发念咒的巫师和飞熊军；下方 35% 留白为开阔坚硬平整的宫前的青石广场供我方出战卡牌陈列",
    "m10_zhangxiu": "潼关的关楼，黄河在关下奔流：张绣（二十出头，剑眉高髻，银蓝西凉鳞甲、短白披风，持长枪）站在关上，枪尖挑着一面「张」字旗，关门紧闭；下方 35% 留白为开阔坚硬平整的关前的夯土路供我方出战卡牌陈列",
    "m10_wangping": "峣关的山口，山石嶙峋：王平（黑瘦沉默的将领，汉军赤红战袍外罩玄黑札甲，持枪）立在山石上，身后是穿藤编轻甲的无当飞军在山石间跳跃，竖着赤底「汉」字旗；下方 35% 留白为开阔坚硬平整的山口的碎石地供我方出战卡牌陈列",
    "m10_zhugeliang": "夜里蓝田山林中的连营在燃烧，火光冲天：诸葛亮（二十岁上下，清俊高傲，纶巾、白色鹤氅，羽扇烧焦了半边）坐在四轮车上，火光里的汉军竟排出了八阵，赤底「汉」字旗在火中翻卷；下方 35% 留白为开阔坚硬平整的山道上的焦土地供我方出战卡牌陈列",
    "m11_bazhen": "洛阳城门前的平地上摆满了一堆一堆的乱石，石间插着赤底「汉」字小旗，风沙卷起，看着杂乱却暗藏阵法；远处城头上，诸葛亮（二十岁上下，清俊高傲，纶巾、白色鹤氅，手摇羽扇）居高临下；下方 35% 留白为开阔坚硬平整的阵前硬土地供我方出战卡牌陈列",
    "m11_wei_pili": "洛阳城西的曹营寨墙后，一排高大的木制霹雳车（投石车）正甩出巨石，霹雳车营的兵（玄黑札甲外罩深蓝战袍，铁盔黑缨，背插黑底白字「魏」字小旗）在推石装填；下方 35% 留白为开阔坚硬平整的营前夯土地供我方出战卡牌陈列",
    "m11_zhangfei": "张飞营门外护城河上的小木桥：张飞（黑脸虬髯的猛将，黑铁甲，丈八蛇矛）横矛立在桥中央，怒目圆睁张口大吼，身后营门紧闭，赤底「汉」字旗；下方 35% 留白为开阔坚硬平整的桥头硬土地供我方出战卡牌陈列",
    "m11_guanyu": "洛阳城东南的汉军营门前：关羽（红脸长须，丹凤眼，绿袍绿巾，青龙偃月刀）骑在马上，刀横马前，眼睛半闭，身后是一排虎步军的盾墙，赤底「汉」字旗；下方 35% 留白为开阔坚硬平整的营前硬土地供我方出战卡牌陈列",
    "m11_wei_huwei": "曹营的辕门前，一排比常人高一头的虎卫军力士（玄黑札甲外罩深蓝战袍，铁盔黑缨，背插黑底白字「魏」字小旗，手持大斧）一动不动地站成一排；下方 35% 留白为开阔坚硬平整的辕门前夯土地供我方出战卡牌陈列",
    "m11_caoren": "曹营的营墙后竖起一面「曹」字大旗：曹仁（三十岁上下，方脸短须，曹军铁甲，长枪往地上一戳）立在旗下，身后的兵按八门布阵；下方 35% 留白为开阔坚硬平整的营前夯土地供我方出战卡牌陈列",
    "m11_liubei": "洛水岸边，一排白羽盔缨的白毦兵分开一条路：刘备（四十岁上下，双耳垂肩，面容仁厚，绿袍外罩金边铠甲，双手各提一口剑）骑马而出，身后赤底「汉」字大旗；下方 35% 留白为开阔坚硬平整的河岸硬石滩供我方出战卡牌陈列",
    "m11_bei_tieqi": "洛阳北面的邙山脚下：一队义军常山铁骑（白甲，黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹），持长枪骑白马）冲下山坡；下方 35% 留白为开阔坚硬平整的山脚硬土地供我方出战卡牌陈列",
    "m11_zhangliao": "邙山的山道上：张辽（三十多岁的并州名将，冷峻，铁甲，横持长刀骑马）立马挡路，身后一队并州狼骑，竖着黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）；下方 35% 留白为开阔坚硬平整的山道硬土地供我方出战卡牌陈列",
    "m11_taishici": "黄河岸边：太史慈（三十多岁的东莱猛将，骑马挎长弓，背插两支短戟）在河岸上拍马冲来，身后插着黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）；下方 35% 留白为开阔坚硬平整的河岸硬泥地供我方出战卡牌陈列",
    "m11_bei_nu": "邙山东麓的土坡上，一排义军并州强弩手（白甲，黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹），端着强弩）蹲着放箭，身后的义军队伍正沿着大路往东撤；前景为开阔平整的坡下硬土地",
    "m11_zhaoyun": "黄昏的偃师道路口，义军大队已经往东走远：路口只剩赵云（二十多岁，白袍银甲，银枪枪尖结着白霜）一人一骑白马，横枪挡在路中，远处大路上是黑白横条旗的队伍（旗面五条宽横条、黑白黑白黑、无字）；前景为开阔平整的官道硬土地",
    "m11_lvbu": "黎明的洛水河滩，远处洛阳城门大开：吕布（高大英俊，冷笑，红黑镶金铠甲，头戴两根长雉尾，方天画戟）骑赤兔马横戟立在浅水里，脚下扔着一顶带血的金边头盔；下方 35% 留白为开阔坚硬平整的河滩硬石地供我方出战卡牌陈列",
    "m9_nanman_dao": "南中的瘴林，白色瘴气在树间飘：一群赤膊的南蛮刀手（脸涂白纹，藤编护腰，弯刃毒刀）从林子里钻出来；下方 35% 留白为开阔坚硬平整的林间硬土地供我方出战卡牌陈列",
    "m9_xiangbing": "泸水岸边的雨林，地面在抖：几头披着藤甲的战象冲出林子，象背上的南中象兵骑手挥着长矛；下方 35% 留白为开阔坚硬平整的河岸硬泥地供我方出战卡牌陈列",
    "m9_zhurong": "泸水渡口，水汽腾腾：祝融夫人（二十多岁的成年女将，南中王后，英气勃发，赤红色的藤甲战裙，背负五口飞刀，手里扣着一口）拦在渡口，身后是南蛮刀手；下方 35% 留白为开阔坚硬平整的渡口硬石滩供我方出战卡牌陈列",
    "m9_tengjia": "泸水南岸，一排藤甲枪兵（全身油亮的藤甲，藤牌长枪）结成盾阵，刀箭落在藤甲上都弹开了；下方 35% 留白为开阔坚硬平整的河岸硬泥地供我方出战卡牌陈列",
    "m9_menghuo": "盘蛇谷，夜里谷口烧起大火，火光冲天：孟获（四十岁上下的南中蛮王，魁梧粗犷，藤甲兽皮，头插雉尾，手持大刀）骑着一头披甲战象冲出火海，身后是乱成一团的藤甲枪兵与南中象兵；下方 35% 留白为开阔坚硬平整的谷口焦土地供我方出战卡牌陈列",
    "m8_han_nu": "清晨的汉水，芦苇荡外一排汉军巡船，船头插着赤底黑字的「汉」字旗：船上的连弩兵（赤红战袍、玄黑札甲、铁盔赤缨）端着方匣连弩齐齐对准前方，弩矢如雨；水面薄雾；下方 35% 留白为开阔坚硬平整的江边硬泥滩供我方出战卡牌陈列",
    "m8_han_baier": "汉水岸边的芦苇滩，一队白毦兵（白色羽缨头盔、银灰厚甲、白色战袍、长枪如林）结成枪阵缓缓推进，阵后竖着赤底「汉」字大旗；下方 35% 留白为开阔坚硬平整的河滩硬地供我方出战卡牌陈列",
    "m8_han_wudang": "南阳道旁的山林，树影里钻出一队无当飞军（深青皮甲、绿褐斗篷、青缨长枪，身手轻捷），林间插着赤底「汉」字小旗；下方 35% 留白为开阔坚硬平整的林间硬土路供我方出战卡牌陈列",
    "m8_han_muniu": "汉水岸的土路上，一列木头做的机关牛（木牛流马）驮着粮袋自己往前走，旁边是推着机关的木牛流马营兵（赤布袍、玄黑皮背心、头裹赤巾），车队插着赤底「汉」字旗；下方 35% 留白为开阔坚硬平整的夯土路供我方出战卡牌陈列",
    "m8_han_menshen": "白河边的汉军营寨，一群卧龙门生（年轻书生，赤色长袍外罩玄黑短甲、进贤冠）坐在长案后挥着令旗，案上铺着地图，营外是赤底「汉」字旗和远处的白河；下方 35% 留白为开阔坚硬平整的营前空地供我方出战卡牌陈列",
    "m8_liaohua": "南阳道的官道，初春残雪：廖化（三十多岁的壮实将领，黄巾出身，浓眉方脸，赤红战袍、玄黑札甲、铁盔赤缨，提一柄大刀）领着一支汉军先锋拦在路中，身后成排的赤底「汉」字旗；下方 35% 留白为开阔坚硬平整的夯土官道供我方出战卡牌陈列",
    "m8_liubei": "暴雨中的汉水芦苇渡口，雨幕倾斜：刘备（四十岁上下，双耳垂肩，面容仁厚却眼眶通红，绿袍外罩金边铠甲，双手各提一口剑）站在雨里，身后一队白羽盔缨的白毦兵和赤底「汉」字大旗；渡口边停着几条锦帆快船；下方 35% 留白为开阔坚硬平整的泥泞渡口河滩供我方出战卡牌陈列",
    "m8_han_tuqi": "荆北新野城外的平原，麦田被马蹄踏平：一队虎骑（赤红战袍、玄黑札甲、铁盔赤缨、手持长矛、骑黑马）迎面冲锋，队伍后方竖着成排赤底黑字的「汉」字大旗，尘土飞扬；下方 35% 留白为开阔坚硬平整的夯土官道供我方出战卡牌陈列",
    "m8_han_bazhen": "汉水北岸的乱石滩，一堆堆乱石之间雾气弥漫：一队虎步军（赤红战袍、玄黑札甲、铁盔赤缨、黑漆八卦纹大盾、短枪从盾沿探出）结成严整的盾阵，阵后竖着成排赤底黑字的「汉」字大旗；下方 35% 留白为开阔坚硬平整的碎石河滩供我方出战卡牌陈列",
    "m8_zulang": "丹阳深山的陡坡上，一座毛竹扎的山寨，寨墙挂满兽骨，云雾从谷底升起：祖郎（三十多岁的粗壮山越宗帅，方脸络腮胡，额头刺青纹，竹片编甲，腰挂一颗系新绶带的铜印，手持缺口宽背山刀）立在寨门前，身后林子里埋伏着一排举刀的山越刀客；坡下翻倒着一副裂成两半的马鞍；下方 35% 留白为开阔坚硬平整的山坡硬土地供我方出战卡牌陈列",
    "m8_guanping": "清晨的汉水北岸，芦苇被江风吹倒一片：关平（二十出头的青年将领，眉目清朗，青绿色轻甲，绿色短披风，手持青缨长枪）骑马立在岸边，身后一队汉军骑兵举着绿色「关」字旗；江面上有薄雾和几条快船的影子；下方 35% 留白为开阔坚硬平整的江岸硬泥滩供我方出战卡牌陈列",
    "m8_chendao": "新野的官道上，初夏的麦田在两侧：陈到（四十多岁的沉稳老将，方脸，白色羽缨头盔，银灰色厚甲，白色战袍，铁枪竖在身侧）立在路中，身后一排排白羽盔缨的白毦兵枪阵整齐肃立，纹丝不动；下方 35% 留白为开阔坚硬平整的夯土官道供我方出战卡牌陈列",
    "m8_caoren": "南阳道的官道上，初春的泥地还带着残雪：曹仁（三十出头的曹军大将，方脸短须，神情沉稳如山，黑色重甲，手持大刀与一面厚重的铁盾）立在路中，身后是一排曹军盾阵和「曹」字旗，远处地平线上有孙家残兵的烟尘；下方 35% 留白为开阔坚硬平整的夯土官道供我方出战卡牌陈列",
    "m8_xiahoudun": "暴雨中的汉水芦苇渡口，雨幕倾斜：夏侯惇（三十多岁的曹军猛将，双眼完好，浓眉怒目，黑色铁甲，手持长枪）骑着黑马领一队曹军骑兵冲出雨幕，马蹄踏起泥水；渡口边停着几条锦帆快船，芦苇被风雨压弯；下方 35% 留白为开阔坚硬平整的泥泞渡口河滩供我方出战卡牌陈列",
    "m8_zhangfei": "博望坡的山谷，两侧山坡的林子同时烧起大火，火光映红夜空：张飞（黑脸虬髯的猛将，环眼圆睁，黑色铁甲，挺着丈八蛇矛）从火光里冲下坡来，身后是刘备军的伏兵；地上散落着被烧断的旗杆；下方 35% 留白为开阔坚硬平整的谷底硬土路供我方出战卡牌陈列",
    "m8_kongming": "白河两岸，清晨的薄雾：上游的木闸刚刚被打开，河水翻着白浪冲下来；对岸高坡上站着诸葛亮（二十岁上下的青年，清俊高傲，纶巾布衣，手持白羽扇），身后是刘备军的伏兵和「刘」字旗；河这边岸上烧着残余的火；下方 35% 留白为开阔坚硬平整的河岸高地供我方出战卡牌陈列",
    "m8_guanyu": "汉水北岸一座由一堆堆乱石垒成的迷阵，石堆之间雾气弥漫，看不清出路：关羽（红脸长须的大将，丹凤眼半睁，绿色战袍、金色铠甲，青龙偃月刀拖在地上）站在乱石阵的出口；下方 35% 留白为开阔坚硬平整的碎石平地供我方出战卡牌陈列",
    "hs_guotu": "无极街口的夜战：督粮官郭图（四十岁上下，面容刻薄，细眼薄唇，头戴黑色文冠，身穿深紫色官袍，手摇一柄黑色羽扇）骑在马上，身后是一排举着强弩、对准前方的督战弩手，火把把他的脸照得阴冷；他脚下的街面上散落着烧焦的粮袋与倒翻的辎重车，背后是燃烧的甄府大门与冲天的火光；神情倨傲而贪婪",
    "hs_bad_hall": "无极甄府的中庭，黎明前的昏暗：冀州大将淳于琼（四十岁上下，面带傲气，披银色明光铠，手持沉重的长戟）立在满地狼藉的中庭正中，身后是郭图的冀州大旗与一排排举盾的冀州兵；青砖地上散落着断枪与折断的门板，远处的甄府正堂冒着黑烟，火光映红半边天空",
    "bh_guanhai": "北海城下的决战：身材魁梧的黄巾大首领管亥扛着一柄巨大的鬼头刀，黄袍外罩简陋的皮甲，满脸狂热；身后黄巾军旗如林，数万饥民军队黑压压铺满城外原野，远处北海城头有孔融的守军弩手",
    "bh_hj_duzhan": "北海城外的黄巾军阵后：几名手持环首刀的黄巾督战队官兵，黄巾裹头，满脸凶相，刀背抵着前面迟疑的饥民士兵向前推；背后是插满黄旗的营寨与浓烟",
    "bh_hj_qushuai": "青州乡野的田埂上：一名黄巾渠帅披着破旧的黄袍和铁肩甲，手持环刀怒吼，身后是挥舞锄头镰刀的黄巾饥民；远处是被烧毁的村庄与黑烟",
    "bh_jiang_trap": "太行山姜家寨外围的林间山道：几名山贼暗哨藏在岩石与树木之后，拉满的弓弦对准来路；脚下布满绊索、竹签与暗藏的机关木桩，气氛紧张",
    "bh_jiangqiao": "姜家寨寨门内：女首领姜巧（成年女性，干练的机关匠，头缠布巾，围着满是工具的皮围裙）手握扳机，身旁是几架上好弦的机关连弩与滑轮吊网；木制寨墙上挂满齿轮与绳索",
    "bh_jz_inf": "黄河渡口的河滩：一队冀州步卒举着方盾、持环首刀结成阵势压来，旗帜上写着冀州的「袁」字；身后是浑浊的黄河与停泊的渡船，天色阴沉",
    "bh_jz_scout": "黄河岸边的芦苇荡：几名冀州轻骑手持长矛策马冲出芦苇丛，马蹄溅起泥水，苇絮被风扬起；远处是灰蒙蒙的河面",
    "bh_jz_spear": "黄河岸边的开阔滩涂：一排冀州长枪兵端着丈二长枪列成密集枪阵，枪尖如林，齐声前压；阵后是冀州军旗和低垂的乌云",
    "bh_lubu": "太行山口的暴风雪中：暴怒的吕布（头戴三叉束发紫金冠，披锁子连环甲，红色战袍猎猎作响）骑着赤兔马，方天画戟高举，戟尖映着雪光；身后并州狼骑的剪影与翻卷的军旗",
    "bh_wolf2": "太行山口的雪地：一队并州精骑头戴狼首铁盔，披黑色重甲，骑着高头战马从雪雾中疾冲而来，马蹄扬起雪浪，长矛前指；远处隐约可见吕布的大旗",
    "bh_yanliang": "黄河渡口的战场：大将颜良（魁梧威猛，披重甲，手持一柄大刀）骑马立于阵前，身后是一排举着强弩的先登死士，弩箭对准前方；背后是奔流的黄河与插满袁字旗的营寨",
    "bh_zhenghao": "郑家寨的校场：女首领郑好（成年女性，豪爽泼辣，红色束袖短打）手持两柄厚背砍刀，身后几名刀手摆开刀阵；背景是木制山寨的大门与挂满红色布幡的寨墙",
    "c4_lijue_test": "洛阳官道上：李傕（西凉悍将，披重甲，满脸横肉，大笑着）率一队西凉兵拦住一支披红挂彩的迎亲车队，红绸飘飞，轿帘被长矛挑起；道路两旁是惊慌的百姓",
    "hs_chunyuqiong": "太行山口的险关：冀州大将淳于琼（四十岁上下，面带傲气，披银色明光铠，手持长戟）立在关前，身后是一排排冀州军旗与举盾的士兵；山势陡峭，雪地泥泞",
    "hs_jieqiao_scout": "界桥外围的原野：几名袁绍军游骑策马疾驰，手持长矛追砍四散逃命的公孙瓒散兵，尘土飞扬，折断的军旗与倒翻的辎重车散落一地；远处是界桥的轮廓",
    "hs_jizhou_buzhu": "无极甄府大门外：烈焰冲天，冀州步卒举着方盾、手持环首刀潮水般压向崩塌的朱漆府门，身后是弩手列阵；木屑与火星四处飞溅，夜空被烧成橙红",
    "hs_jizhou_nu": "太行秘道的狭窄峡谷：一排冀州强弩手半蹲在岩壁两侧，强弩上弦、箭簇齐指谷中；箭矢如蝗，岩壁上插满箭杆，夜色昏暗，火把照亮他们冷峻的脸",
    "hs_jizhou_qiangbing": "太行秘道的狭窄山道：冀州大枪阵的长枪兵横向列成枪墙，枪尖如林封死去路；两侧是陡峭岩壁，火把摇曳，气氛压抑",
    "hs_jizhou_qibing": "太行秘道的山道上：几名冀州轻骑在窄路上策马追击，手持长矛前指，披风与火把的光影在岩壁上晃动；扬起的碎石与尘雾",
    "hs_quyi": "界桥战场：麹义（四十岁上下的凉州铁血老将，黑色铁叶甲外罩暗红旧战袍）率先登死士结成大盾阵，盾面满是箭痕，盾后强弩手露出弩机；身后是一面「袁」字大旗，前方是被冲垮的白马义从与折断的旗杆",
    "hs_wenchou": "界桥血战：河北名将文丑（魁梧威猛，披金色明光甲，手持长枪）策白马疾驰，枪尖直指前方，身后铁骑如潮；黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）在远处飘扬，战场上尘土与战火翻滚",
    "hs_yudu": "黑山大寨的议事大厅外：叛党首领于毒（五十岁上下，满脸胡须，披黑色皮甲和兽皮披肩）手持一柄沉重的大斧立于台阶前，身后是持刀的叛党山贼；寨中挂着黑色旗帜与火盆",
    "hs_zhangbaiqi": "太行绝壁的悬崖栈道：黄巾渠帅张白骑（披着破旧的黄色战袍，手持环刀，身形精悍）立于窄窄的栈道上，身后是几名黄巾残兵；一侧是万丈深渊与云雾，一侧是陡峭的岩壁",
    "huangjin_vanguard": "太行山道上：几名黄巾前锋头缠黄巾，持长矛与环首刀，沿着狭窄的山道摸黑前进，火把照亮他们疲惫而凶狠的面孔；路边是灌木与嶙峋的岩石",
    "shanzei_scout": "真定城外的雪地：几名地痞流氓般的山贼斥候提着刀棍围住行人，缩着脖子，眼神贼溜溜；背景是被积雪覆盖的城墙与路旁枯树",
    "th_patrol": "太行山道：几名太行山的巡山山贼身披兽皮与旧皮甲，手持砍刀与弓箭，在松林间的小径上拦路；晨雾弥漫，树影斑驳",
    "jz_county_fight": "邺城州衙门前的雪街：几名衙役抡着水火棍围上来，背景是州衙的朱漆大门和瑟缩的灾民，雪地上已经洒了几滴血",
    "jz_road_bandits": "太行官道旁的雪林：几个衣衫混杂的黑山散兵从树后窜出拦路打劫，背景是积雪的官道和两侧稀疏的冬林",
    "ln_lvlingqi": "黄河南岸古道夜色：吕玲绮一身红黑铠甲，战马打滑前蹄跪地，她单手举着小号方天画戟，满脸泪痕，眼神凶狠又无助",
    "c3_mitan": "a tavern back alley at night: Yuan agents in plain clothes drawing short knives from their sleeves",
    "c3_qibing": "a rainy night road: Yuan cavalry with spears charging out of the dark, rain slanting in the torchlight",
    "c4_liumin": "the ruins of Luoyang: a desperate mob of starving refugees with hoes and sticks surging over rubble toward the grain carts",
    "c5_qinbing": "a lotus garden at night: Lü Bu's Bingzhou guards with ji searching between the pavilions with lanterns",
    "c6_yulin": "the dark west wall of the Chang'an palace at night: a squad of imperial guards (yulin jun) in bright armour with halberds changing watch under torches on the rampart",
    "c6_fubing": "a long Chang'an street before dawn: Wang Yun's house troops in a line with ji and crossbows",
    "c6_xianzhen": "the square before the Xuanping Gate in snow: black-armored Trap-Breaking Camp infantry behind tall shields",
    "c2_gongqi": "a side path between wheat fields: Xiliang horse archers wheeling around and loosing arrows, fire arrows streaking",
    "c3_xunluo": "outside a walled town in Nanyang: a Yuan army patrol with spears under a 袁 banner blocking a country road",
    "c3_gongshou": "a fork in a road lined with trees: Yuan archers kneeling behind a low earth bank, bows drawn, a 袁 banner",
    "biwu": "a village fighting-for-a-husband stage hung with red silk: Bao Sanniang (adult) in pale-green armor twirling her spear with a cheeky grin, a row of defeated suitors rubbing their backs at the edge, a cheering crowd below",
    "c4_gaoshun": "the back gate of a scholar's mansion in Chang'an before dawn, the house burning behind: the grim, dark-faced Gao Shun standing like a post behind a wall of tall black shields bristling with halberds, his Trap-Breaking Camp utterly silent",
    "c4_langqi": "a long Chang'an street at dawn, lanterns smashed: Bingzhou wolf riders in fur-trimmed armor galloping straight at the viewer, sabers raised, their leader howling",
    "c4_lvbu": "the great Xuanping Gate of Chang'an in falling snow at dawn: Lü Bu on the rearing Red Hare with his halberd raised high, Gao Shun's black shield wall behind him; a woman in a black cloak (Diaochan, adult) seated behind his saddle looking away",
    "c6_shaoka": "the Qingming Gate of Chang'an at night: a row of torches, Han guards in red and black with halberds barring the road, their officer holding out a written order",
    "c6_fanchou": "a narrow mountain road east of Chang'an: the loud, brash Xiliang general Fan Chou on horseback swinging a huge saber, laughing, Xiliang cavalry pouring down the slope",
    "c6_lijue": "Hangu Pass at sunset: the gaunt, cruel Li Jue on horseback before a huge 李 banner, his blade still stained, rows of Xiliang cavalry filling the pass behind him",
    "c7_qiaorui": "a Yuan army camp gate in Nanyang in summer: the stout Qiao Rui tossing away a chicken bone and drawing his broad saber, Yuan soldiers scrambling out of their tents",
    "c7_leibo": "a mountain road outside Wancheng: Lei Bo with a scar on his chin leading light cavalry in a charge, arrows in the air",
    "c7_chenlan": "the walls of Wancheng in Nanyang: the grey-bearded general Chen Lan on the gate tower pointing a long spear down, archers along the battlements, the 袁 banner above",
    "c7_fengfuren": "the street just inside the east gate of Wancheng before dawn, torches guttering: the gate swung open behind the heroes with Huang Zhong (middle-aged, stout, bow on his back) standing in the gate passage giving a nod; ahead, household servants caught mid-stride carrying jars of lamp oil toward the wall, and a sedan chair just set down in the street with Lady Feng (adult, beautiful) lifting the curtain, her round fan frozen in mid-air, startled; no portcullis, no archers yet",
    "c7_jiling": "the west gate of Wancheng at dawn, smoke rising in the city behind: Ji Ling alone on horseback in gilded armor with his three-pointed double-edged blade, holding the gate while Yuan Shu's carriages flee behind him",
    "c6_zhangxiu": "a stone bridge over the Wei river at dawn: the cocky young Zhang Xiu alone on the bridge spinning his long spear into a blur of spear-tip flowers, Xiliang cavalry under a 张 banner behind; far back a thin man on a mule sniffing a wine gourd",
    "c6_zhangji": "a Xiliang camp gate on the Wei river bank: the steady general Zhang Ji on foot with his spear planted beside him, war drums behind, soldiers pouring out; a thin man sitting on a grain cart by the gate, sighing",
    "jx_jinfan": "a ferry landing on the Han river: brocade-sailed fast boats blocking the crossing, river pirates with bells at their waists leaping onto the jetty with short blades and grappling ropes",
    "jx_zongzei": "a fortified clan village (wubao) outside Xinye: clan bandits and armed farmhands pouring out of the rammed-earth gate with cleavers and torches, their chief on the wall",
    "jx_ganning": "the Han river at noon: the young, cocky Gan Ning standing on the prow of a brocade-sailed boat drawing a great bow, bronze bells at his waist, his pirates cheering behind him",
    "jx_bubing": "the north bank of the Yu river in autumn: a line of Jingzhou infantry with round shields painted 刘 and a forest of spears, having just waded across, reeds behind them",
    "jx_gongshou": "a reed marsh along the Yu river: Jingzhou archers half-hidden in tall reeds loosing a volley across the water",
    "jx_huangzu": "the south bank of the Yu river under a big 黄 banner: the gaunt grey veteran Huang Zu on horseback raising his ghost-head broadsword, Jingzhou troops and river boats behind him, arrows in the air",
    "jx_shuijun": "a Jingzhou river fortress on the Han river: bare-chested Jingzhou marines leaping from a line of war boats onto the jetty with pikes and rattan shields, a huge tiered flagship behind",
    "jx_nushou": "inside a burning lakeside pavilion full of smoke: Cai family crossbowmen behind torn silk curtains shooting blindly into the haze, an overturned bronze brazier spilling embers",
    "jx_b_fubing": "a long stone plank-road over the Han river at night: a wall of Cai household infantry in black-and-purple livery with round shields and short swords sealing the walkway, torches on the railings, the river dark below",
    "jx_b_qibing": "the same narrow stone causeway at night: Cai household cavalry in black-and-purple cloaks galloping along it in a tight file, horses rearing at the railings, arrows dropping riders into the water",
    "jx_b_caihe": "the upper gallery of a lakeside pavilion: rows of repeating crossbows levelled through lattice windows, a commander waving a signal flag, lamps swinging, smoke drifting",
    "jx_b_zhangyun": "the river pier below a lakeside pavilion at night: a line of Jingzhou war-boats with torches nosing up to the pier, marines in purple-brown jackets scrambling ashore, a red-faced commander with a wine flask on the lead bow",
    "jx_caimao_a": "a half-burnt banquet pavilion on a rock above the Han river: the burly Cai Mao clutching his bleeding right eye with one hand and swinging a long sword with the other, death-sworn guards around him, flames and smoke",
    "jx_caimao_b": "a moonlit banquet pavilion on a rock above the Han river, overturned tables: the burly Cai Mao in brocade over gilded armor cornered at the railing with his sword drawn, his last guards around him, crossbows now aimed at him from the curtains",
    "c5_fanchou": "a courtyard duel ring at a feast: Fan Chou swinging a huge saber, laughing Xiliang officers cheering from the tables",
    "c5_zhangji": "a courtyard duel ring at a feast: the steady Zhang Ji with his spear levelled, lantern light",
    "c5_niufu": "a courtyard duel ring at a feast: Niu Fu charging with a heavy saber, Dong Bai standing up at the table shouting, Dong Zhuo watching with narrowed eyes",
    "c5_huzhen": "the chancellor's inner gate at night: Hu Zhen barring the way with a broad saber as the great doors swing shut behind him",
    "c4_guosi": "a looted village road: Guo Si on horseback over captured grain carts, soldiers loading the villagers' last sacks, an old man knocked down, Dong Bai smashing a cart wheel with her twin hammers",
    "c5_hall": "a wedding hall turned trap: red lanterns and silk, the doors slammed shut, black-armored Flying Bear cavalry pouring in from behind the curtains",
    "c5_dongzhuo": "the steps before the chancellor's mansion at night: the enormous Dong Zhuo with a drawn sword among his elite black-armored guards, wedding lanterns burning behind him",
    "dagu": "the Dagu pass outside Luoyang: the veteran Xiliang general Xu Rong on horseback before rows of heavy cavalry and spearmen in battle formation, dust and banners, an ambush glinting in the hills",
    "c3_shanfei": "a one-eyed bandit chief on horseback dragging a woman in white onto his saddle amid fleeing refugees on a dusty road, a broken guqin on the ground",
    "c3_qiaorui": "outside the Nanyang city wall at dusk: the stout officer Qiao Rui with Yuan soldiers in disguise stepping out of a market crowd, sabers drawn",
    "c3_jiling": "a narrow mountain pass in heavy rain: Yuan Shu's foremost general Ji Ling in gilded armor with a three-pointed glaive, standing alone in front of a wall of spearmen, the final battle",
    "c3_leibo": "a mountain trail at dawn: Lei Bo leading Yuan cavalry in pursuit, arrows flying, mud splashing",
    "c3_chenlan": "a rainy night courtyard lit by torches: the grey-bearded general Chen Lan with a long spear at the gate under a 袁 banner, soldiers pouring in",
    "c3_yuanshu": "a rain-soaked valley mouth: the proud, aristocratic warlord Yuan Shu (tall, not fat, in luxurious Han general's crimson robes and gilded armor, no dragon robe) on a high gilded carriage, gesturing imperiously behind rows of archers and towering yellow 袁 banners",
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
    "heishan_wai": "the snowy outer slope of a Taihang mountain pass at night: Black Mountain bandit scouts around torches, the stockade wall faint in the distance",
    "heishan_tan": "a grim cave altar stained with blood and scattered talismans: the sorcerer Xuanjizi turning with a sneer beside a bound girl",
    "heishan_zhai": "the gate of the Black Mountain stockade: Li Damu swinging his huge axe to block the gate, the stockade wall ablaze behind him",
    "hn_liuxun": "皖城城头，新插的一排黄色「仲」字旗下，庐江太守刘勋（四十多岁的贪婪官吏，大腹便便，穿一身金漆还没干透的新铠甲，腋下夹着一本搜刮来的账簿）扶着垛口指挥守城，城下滚木礌石，城门紧闭",
    "hn_leichen": "濡须口江面上两条吃水极深的破船，船舱里塞满金银箱子；雷薄（粗豪的中年武将，持长枪）与陈兰（瘦长的中年武将，持长枪）并肩站在船头，一脸「怎么又是你」的晦气表情；远处灊山云雾缭绕",
    "hn_zhangxun": "寿春城南淝水最窄处，十几条高大的楼船用铁索连成一道水上城墙，最高的楼船上站着袁术大将张勋（三十多岁、神情严整的将军，黄色战袍，手按佩剑），船舷上弩手密布，远处是寿春城墙",
    "hn_shouchun": "破晓时分的寿春南门水寨，黄色「仲」字大旗猎猎，仲氏禁军（金黄铠甲的禁卫长戟兵）在水门前列阵死守，城头倾泻火油；水门内几条载满金银箱子的快船正要冲出；远处东门北门火光冲天",
    "xz_xiahoudun": "下邳城外的山坡上，曹军殿后军列阵，「曹」字大旗下，夏侯惇（三十多岁的悍将，两眼完好，神情冷峻，黑色铠甲，单手提一杆长枪）独自立马阵前，眼神像刀子；远处是下邳城墙",
    "xz_caobao": "下邳城的街口，徐州大将曹豹（四十岁上下，满脸横肉、骄横跋扈，华丽铠甲）叉腰站在家兵中间，家兵们拔刀拦街，身后是他的府门；街边百姓躲在门后",
    "xz_lvbu": "三更天的小沛城门轰然大开，火把照亮夜色：吕布（成年猛将，雉尾金冠，红色铠甲）骑着赤兔马单骑冲出城门，方天画戟横扫，身后城头一片混乱，城外北海军的哨卡火把连成一线",
    "jd_niuzhu_b": "秋天的牛渚江岸，芦苇被马蹄踏倒：一队刘繇的骑卒（扬州军的青色号衣、轻便皮甲，手持马刀长矛，骑着瘦削的江南马）沿着江岸冲来，扬起尘土；远处是刘繇的营垒和「刘」字旗，江面上停着几条战船；下方 35% 留白为开阔坚硬平整的江岸土路供我方出战卡牌陈列",
    "jd_jinfan": "太湖的芦苇荡里，几十条挂着彩色锦帆的轻快小船穿梭，船舷上挂满铜铃；船上的锦帆贼（腰系铜铃、短打水靠、手持短刀和钩索）正要跳帮，神情悍勇却不凶恶；远处是锦帆水寨的木栅和湖边的渔村，渔民在岸上远远看着；下方 35% 留白为开阔坚硬平整的湖岸滩地供我方出战卡牌陈列",
    "jd_kuaiji": "会稽城外的稻田和山阴道，远处是会稽的城墙和城门楼，城头插着「王」字旗；一队会稽守军（江东式的灰褐札甲、长枪大盾）在田埂间列阵，身后是守城的弩手；薄雾笼罩着远处的会稽山；下方 35% 留白为开阔坚硬平整的夯土田埂供我方出战卡牌陈列",
    "hnn_daofu": "深夜的寿春宫回廊，宫灯摇晃，朱红廊柱后面冲出一排曹军刀斧手（黑色短甲、头裹黑巾，手持大斧和环首刀），地上碎着一只摔破的酒杯，远处大殿里还亮着宴席的灯火；下方 35% 留白为开阔坚硬平整的青石宫道供我方出战卡牌陈列",
    "hnn_gongmen": "深夜的寿春宫门，宫灯摇晃、火把通明：夏侯惇（三十多岁的悍将，两眼完好，浓眉虎目，曹军黑甲、深色披风，单手提长枪）一个人堵在宫门的门洞里，神情冷硬；门洞两侧是举着长戟的曹军刀斧手，身后的宫墙上插着「曹」字旗，远处殿里隐约有火光；下方 35% 留白为开阔坚硬平整的青石宫道供我方出战卡牌陈列",
    "hn_wanshui": "阴沉天色下的皖水河滩，远处是云雾里的灊山：一群穿着破旧短褐、头裹布巾的佃户被编成了阵，手里握着雷家统一发的刀和木盾，神情麻木又紧张；阵后一个骑马的雷家管事举着「雷」字旗督阵；河面上漂着几条小船；下方 35% 留白为开阔坚硬平整的泥泞河滩供我方出战卡牌陈列",
    "jd_zhoutai": "太湖水寨的第二道水门前，一条窄窄的木栈桥伸进芦苇荡：周泰（二十多岁的壮汉，赤着上身，满身纵横的刀疤，手提一把大砍刀）一个人站在栈桥正中，挡住去路，神情沉默而凶狠；身后水门上挂着锦帆和一串铜铃，远处是甘宁水寨的快船；下方 35% 留白为开阔坚硬平整的木栈台供我方出战卡牌陈列",
    "jd_shenting": "神亭岭的山坡上，刘繇的连营旌旗林立；刘繇大将樊能（四十岁上下的粗壮武将，铁甲大刀）立马营前，身后一排丹阳兵长枪如林；远处山脊上，十几骑轻骑正冲下山来；下方 35% 留白为开阔坚硬平整的山坡土地供我方出战卡牌陈列",
    "jd_yanbaihu": "太湖深处芦苇荡里的水寨，寨门上挂着「德王」两个大字的匾；严白虎（五十上下，满脸横肉，自号东吴德王，穿着僭越的赭黄锦袍外罩铁甲，提一把虎头大刀）站在寨楼上，身边是穿着严家号衣、不挂旗的水匪；水面上浮着几条盐船；下方 35% 留白为开阔坚硬平整的木栈台供我方出战卡牌陈列",
    "jd_ganning": "太湖上锦帆贼的水寨，几十条挂着锦帆、系着铜铃的快船；甘宁（二十多岁的悍勇青年，腰挂一串铜铃，背一张大铁胎弓，锦衣半敞）站在船头拉弓，身边是满脸刀疤的壮汉周泰（提刀）和包着蓝头巾、提短戟的蒋钦；远处天边有火光；下方 35% 留白为开阔坚硬平整的湖岸滩地供我方出战卡牌陈列",
    "jd_menke": "丹徒山的密林，清晨的雾气还没散，林子静得出奇；三个蒙着黑巾的门客从树后冲出，一人张弓、两人持短刀；落叶上散着几支冷箭；下方 35% 留白为开阔坚硬平整的林间土路供我方出战卡牌陈列",
    "jd_wanglang": "会稽城头，王朗（五十多岁的经学大儒，峨冠博带、长须飘飘，手捧一卷竹书）站在垛口前，仿佛在讲学；城头下是一排守城弩，城下的水门停着会稽的战船；下方 35% 留白为开阔坚硬平整的城外夯土地面供我方出战卡牌陈列",
    "hn_leixu_g": "灊山（天柱山）脚下的山道，雾气缭绕，山腰上是雷家的木寨；雷绪（五十多岁的庐江豪帅，面相冷硬，旧甲外罩族长袍，手提一把旧阔刀）站在阵前，身后是一排拿着雷家发的刀的佃户部曲，打着「雷」字旗；山下是蜿蜒的皖水；下方 35% 留白为开阔坚硬平整的山道土地供我方出战卡牌陈列",
    "hnn_bw_gy": "寿春宫前的校场上搭起比武台，四周插满「曹」字和黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）两色旗帜；台上关羽（四十岁上下的威严猛将，红脸长髯、丹凤眼微眯，绿袍金甲，手提青龙偃月刀）横刀而立，台下席间坐满观战的将领，酒坛摆了一排；下方 35% 留白为开阔坚硬平整的夯土校场地面供我方出战卡牌陈列",
    "hnn_lvbu": "深夜的淮水岸边，浮桥从中间被砍断，断木在黑水里漂着，河面映着火光；断桥头一排火把下，吕布（成年猛将，雉尾金冠、兽面吞头连环铠，手持方天画戟）骑在赤兔马上，身后是并州骑兵的剪影；远处河面上隐约一条荆州楼船的灯火；下方 35% 留白为开阔坚硬平整的泥泞河滩供我方出战卡牌陈列",
    "n7_zangba": "泰山山口的寨墙上竖着一面「臧」字旗：臧霸（三十多岁，满脸胡子，眼神精明，锦袍下面是皮甲，提环首刀）站在寨门前，身后泰山贼张弓搭箭；下方 35% 留白为开阔坚硬平整的山口碎石地供我方出战卡牌陈列",
    "n4_houcheng": "冬天的雪原上，一员并州将领侯成（三十多岁，并州铠甲，提马刀）勒马横刀拦住往东的路，身后并州骑兵；远处吕玲绮提戟走到最前面；下方 35% 留白为开阔坚硬平整的雪地硬土供我方出战卡牌陈列",
    "n5_yanxiao": "泗水码头，冬天：一伙盐枭扣着几条盐船，船工被赶到岸边；盐包堆成小山；下方 35% 留白为开阔坚硬平整的码头石板地供我方出战卡牌陈列",
    "n5_yanxiao_tou": "泗水码头的盐包堆上，盐枭头子（四十岁上下，胖，满脸横肉，手里转着一对铁胆）大剌剌地坐着，身边一群打手；下方 35% 留白为开阔坚硬平整的码头石板地供我方出战卡牌陈列",
    "n6_zhangxun": "钟离城外的大营：张勋（四十多岁，披着一身漆还没干的崭新金甲，神情倨傲）立马营门前，营门上挂着「大将军张」的大旗；下方 35% 留白为开阔坚硬平整的营前夯土地供我方出战卡牌陈列",
    "n6_leibo": "寿春城外的壕沟后：雷薄（三十多岁的粗豪将领，满脸不耐烦，提一柄大斧，骑一匹瘦马）在壕沟后面叫骂，沟里插着削尖的竹子；下方 35% 留白为开阔坚硬平整的官道硬土供我方出战卡牌陈列",
    "n9_yanxing": "夜里燃烧的西凉马营西门：阎行（二十多岁精悍的西凉将领，红抹额，持长矛）横矛立在门洞中间，身后并州狼骑的火把；马超（银甲白袍狮盔）挺枪冲来；前景为开阔平整的门前硬土地",
    "n6_chenlan": "寿春仲氏宫门前，宫门上一块「仲」字金匾：陈兰（三十多岁的实心眼将领，铠甲整齐，持长枪）带着禁军守在门前，神情决绝；下方 35% 留白为开阔坚硬平整的宫前石板地供我方出战卡牌陈列",
    "n4_wuanguo": "北海城门外，城门刚刚打开：武安国（三十多岁的魁梧猛将，红脸浓须，铁甲，扛着一柄巨大的铁锤）带着守军冲出来，怒目而视；远处黄巾营帐连片；下方 35% 留白为开阔坚硬平整的城门外夯土地供我方出战卡牌陈列",
    "n7_fukou": "太行山滏口陉最窄处，两侧悬崖夹着一道石砌关隘，关楼上飘着「淳于」字旗：淳于琼（四十多岁的矮壮老将，重甲，红鼻头，一手提大刀一手端着酒碗）站在关楼前，身后冀州守军推着滚石；崖壁上垂下一根绳子；下方 35% 留白为开阔坚硬平整的谷底硬石地供我方出战卡牌陈列",
    "n7_g_zhanghe": "冬天的漳水岸边，河里漂着几条吃水很浅的空粮船：张郃（三十岁上下的河北名将，冷静精明，河北铁甲、深色披风，持长枪骑马）勒马立在河岸，眯眼看着河里的船；下方 35% 留白为开阔坚硬平整的河岸冻土地供我方出战卡牌陈列",
    "n7_gaolan": "冬天的河北原野，远处是城墙和河：高览（三十多岁的河北名将，枪法凌厉，河北铁甲、红缨盔，持长枪骑马）横枪立马，身后冀州大枪阵枪尖如林；下方 35% 留白为开阔坚硬平整的冻硬的原野土地供我方出战卡牌陈列",
    "n7_shenrong": "雷雨夜的邺城大街，州衙前：审荣（二十多岁的紧张年轻军官，满头大汗，冀州军甲偏大、头盔往下滑）带着守军持枪堵路，闪电照亮雨幕；下方 35% 留白为开阔坚硬平整的湿漉漉的石板街供我方出战卡牌陈列",
    "n7_g_xinshi": "夜里的漳水渡口，月光下的芦苇荡：几十骑袁军轻骑护着一个怀揣密信的文士往南疾驰，前头一员骑将回身张弓；远处一个白袍银枪的身影横枪拦在渡口；下方 35% 留白为开阔坚硬平整的河岸硬泥地供我方出战卡牌陈列",
    "n7_yanliang": "冬天的漳水边，空粮船停在河里：颜良（四十岁上下的高大猛将，红脸短须，鹰眼，河北重甲、红披风，大刀扛在肩上）骑大黑马冲来，身后河北骑兵；下方 35% 留白为开阔坚硬平整的河岸冻土地供我方出战卡牌陈列",
    "n7_wenchou": "漳水葫芦谷口，谷里灌满了浑浊的河水：文丑（四十岁上下，黑脸虬髯，河北铁甲、黑披风，提长枪）立在水边，身后一面「文」字大旗；下方 35% 留白为开阔坚硬平整的谷口硬石滩供我方出战卡牌陈列",
    "n7_b_wenchou": "漳水渡口一个烧着的村子，浓烟滚滚：文丑（四十岁上下，黑脸虬髯，河北铁甲、黑披风，提长枪）骑马立在村口的黑旗下，身后河北兵围了三层；村子中间有一口枯井；下方 35% 留白为开阔坚硬平整的烧焦的村口土地供我方出战卡牌陈列",
    "n8_wuhuan": "渔阳城外的荒原，初冬：一队披着兽皮、马蹄裹布的乌桓突骑无声地冲来，领头的胡骑张弓回射；远处一面残破的白色「公孙」旧旗；下方 35% 留白为开阔坚硬平整的冻硬的荒原土地供我方出战卡牌陈列",
    "n8_yuantan": "青州平原城门外：袁谭（三十岁上下的年轻贵公子将领，盔甲镶金边，神情骄躁）骑马挺刀冲出城门，身后亲兵；城头上站着两个长得很像的文士；下方 35% 留白为开阔坚硬平整的城门外夯土地供我方出战卡牌陈列",
    "n8_shenpei": "雪中的幽州蓟城城头：审配（五十多岁的老将，须发花白，甲胄一丝不苟，神情倔强）按剑站在城垛后，守军推着滚油、架着强弩；下方 35% 留白为开阔坚硬平整的城下积雪的硬土地供我方出战卡牌陈列",
    "n8_qingzhou": "青州的官道上，冬天：一营头扎黄巾的魏军青州老兵结成长枪阵拦路，阵后竖着「曹」字旗；下方 35% 留白为开阔坚硬平整的官道冻土供我方出战卡牌陈列",
    "n8_b_chengyu": "傍晚北海城东的林子，林上一只鸟都没有：林中伏兵万箭齐发，旗上一个「程」字一个「夏侯」字；林边高坡上程昱（五十岁上下的瘦高文士，长须，摇着羽扇，目光阴冷）俯视；下方 35% 留白为开阔坚硬平整的雪地林道供我方出战卡牌陈列",
    "n8_g_xiahoudun": "北海城东的林子里，伏兵阵脚大乱：夏侯惇（独眼猛将，黑甲，持长枪）回头怒视从林子背后杀进来的白袍银枪骑兵；下方 35% 留白为开阔坚硬平整的林间雪地供我方出战卡牌陈列",
    "n8_langqi": "北海城外的雪原：并州狼骑绕城奔驰，扬起的雪雾比城墙还高；远处北海城头插着黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）；下方 35% 留白为开阔坚硬平整的雪原硬土供我方出战卡牌陈列",
    "n8_pili": "北海城外：一排魏军霹雳车把石头抛向城墙，城墙上裂开一道缝，城头有人在抢修；下方 35% 留白为开阔坚硬平整的城外冻土供我方出战卡牌陈列",
    "n8_g_lvbu": "北海城下，城门大开：吕布（头戴束发紫金冠，红锦百花袍，兽面吞头连环铠，手提方天画戟）骑赤兔马立在城下，身后魏军让开一条路；城头插着黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）；下方 35% 留白为开阔坚硬平整的城下雪地供我方出战卡牌陈列",
    "n8_g_zangba": "夜里北海西门外起了火：臧霸（三十多岁，满脸胡子，锦袍下皮甲，提环首刀）带泰山兵举火把冲向城门；城门洞里站着太史慈（三十岁上下的东莱猛将，手提双戟）；下方 35% 留白为开阔坚硬平整的城门外石板地供我方出战卡牌陈列",
    "n8_hubao": "黄河渡口，初春：魏军虎豹骑铁甲重骑沿河岸冲来，渡口插着「曹」字旗；下方 35% 留白为开阔坚硬平整的河岸硬泥地供我方出战卡牌陈列",
    "n8_g_mayunlu": "夏天的黄河北岸：马云騄（二十出头的西凉女将，红缨银盔、红甲，持银枪，英气）单骑过河，长枪指着北岸；对岸「马」字大旗；下方 35% 留白为开阔坚硬平整的河滩硬沙地供我方出战卡牌陈列",
    "n8_g_machao": "夏天的黄河河滩：马超（二十多岁，银甲白袍，狮盔兽带，持虎头湛金枪，俊美凌厉）骑马立在河滩上，身后西凉铁骑和「马」字大旗；下方 35% 留白为开阔坚硬平整的河滩硬沙地供我方出战卡牌陈列",
    "n9_shenpei": "春天的冀州无极，甄家粮行的门楼上插满了箭：审配（五十多岁的老将，须发花白，甲胄一丝不苟）在门外按剑指挥袁军；门楼上张夫人（三十多岁的雍容妇人，深色锦袍）拿着一把插着箭的算盘；下方 35% 留白为开阔坚硬平整的门前石板地供我方出战卡牌陈列",
    "n9_yuantan": "渤海南皮城头，最后一面「袁」字大旗下：袁谭（三十岁上下的年轻贵公子将领，金边掉了一半的铠甲）拔剑嘶喊；两侧站着辛评、辛毗两个文士；下方 35% 留白为开阔坚硬平整的城下夯土地供我方出战卡牌陈列",
    "n9_b_xiahoudun": "夜里仓亭下游的芦苇荡，三面站起密密麻麻的魏军重兵：夏侯惇（独眼猛将，黑甲，独眼里全是血丝）举枪指向前方；身后黄河；下方 35% 留白为开阔坚硬平整的河滩泥地供我方出战卡牌陈列",
    "n9_g_lvbu": "黎明的仓亭渡口：吕布（束发紫金冠，红锦袍，方天画戟，骑赤兔）追到岸边，冷笑着指向马超；太史慈站在摇晃的桅杆上张弓；下方 35% 留白为开阔坚硬平整的渡口木栈道供我方出战卡牌陈列",
    "n9_g_tadun": "秋天的白狼山坡：乌桓单于蹋顿（四十岁上下的胡人首领，皮帽兽皮大氅，弯刀，骑黑马）立在山坡上，身后乌桓大营望不到边，审配（花白须发的老将）站在他身边；下方 35% 留白为开阔坚硬平整的山坡草地供我方出战卡牌陈列",
    "n9_g_liucheng": "秋天的塞外柳城，乌桓王庭：营门口挂着一圈牛头，乌桓峭王（四十岁上下的胡人首领，皮帽兽皮大氅，弯刀）骑马大笑，身后骑射手；下方 35% 留白为开阔坚硬平整的草原硬土供我方出战卡牌陈列",
    "n9_liaodong": "冬天的辽东官道，风雪：一队辽东步卒持长矛结阵拦路，远处是辽西的群山；下方 35% 留白为开阔坚硬平整的积雪的硬土路供我方出战卡牌陈列",
    "n9_gaogouli_gong": "冬天辽西的山道：一队穿短甲、背长弓的高句丽弓手从山石后面探出身来放箭；下方 35% 留白为开阔坚硬平整的山道碎石地供我方出战卡牌陈列",
    "n9_g_gaogouli": "黎明结冰的辽水：对岸高句丽援军的营寨，弓手在冰面对岸齐射，箭落在冰上弹起；上游天边一片火光；下方 35% 留白为开阔坚硬平整的冰面供我方出战卡牌陈列",
    "n9_g_gongsunkang": "冬天的辽东襄平城头：公孙康（三十多岁的辽东军阀，披着过大的王袍，神情紧张又倨傲）站在城垛后指挥，守军推着滚木礌石；下方 35% 留白为开阔坚硬平整的城下积雪的硬土地供我方出战卡牌陈列",
    "n10_xiahoudun": "春天黄河南岸的官渡大营前，前后两面烟尘冲天：夏侯惇（三十多岁的曹军大将，独眼，浓眉怒目，黑色重甲，手持长枪）在乱阵中横枪死战；他马前站着副将韩浩（四十来岁，脸晒得黑，方下巴，沾满河泥的札甲），横刀护住主将；身后黑底「魏」字大旗被河风吹得猎猎作响，远处东面仓亭方向的白马银枪骑兵正席卷而来；前景为开阔平整的河滩硬沙地",
    "n10_hanhao": "黄河延津渡口的泥滩上，一排排拒马把河滩拦死：韩浩（四十来岁的曹军将领，脸晒得黑，方下巴，不苟言笑，沾满河泥的札甲外罩粗布袍，袖子挽着）正弯腰和屯田兵一起扛着拒马木桩，抬头冷冷看向河面上驶来的北军渡船；身后是举着长矛的曹军屯田兵和插在泥里的黑底「魏」字旗；前景为开阔平整的河滩泥地硬沙",
    "n11_caoren": "秋天的首阳山顶，枯草连天：曹仁（三十多岁，方脸短须，重甲长枪）和独眼的夏侯惇（黑甲，左眼蒙着眼罩，持长枪）并肩立在「曹」字大旗下，身后是层层盾车和霹雳车营，山道上全是石头砸出的坑；前景为开阔平整的山顶夯土地",
    "n11_dianwei_du": "黄河孟津渡口，浑黄的河水湍急：渡口的木栈道上，典韦（黑脸大汉，虎背熊腰，赤膊外罩破旧铁甲，两手各提一杆沉重的铁戟）叉腿站着，咧嘴笑，身后几百个魏军虎卫军力士像钉子一样钉在岸上，河心有北军的渡船正在靠近；前景为开阔平整的渡口硬沙滩",
    "n11_dianwei": "清晨的孟津渡口，雾还没散：典韦（黑脸大汉，身上插着十几支箭，铁甲破碎，两杆铁戟砍卷了刃）背靠渡口的木桩，独自面对登岸的大军，身后只剩几十个带伤的虎卫军力士，眼神凶狠却平静；前景为开阔平整的渡口硬沙滩",
    "n11_a_danyang": "秋天伊阙道的山谷里，南线的吴军丹阳兵（短褐轻甲，手持长枪，头裹青布）结着整齐的枪阵一步步后撤，身后是打着「吴」字旗的伤兵队伍，两侧是伊水边的陡峭石壁；前景为开阔平整的山谷硬土路",
    "n11_a_wunu": "伊阙关前的山坡上，一排吴军弩手（青色短衣，皮甲，蹲姿端着木弩）居高临下放箭，护着身后搀扶伤兵过关的队伍；关楼上插着「吴」字旗；前景为开阔平整的关前碎石坡地",
    "n11_a_sunce": "伊阙的关口，秋日夕阳：孙策（二十多岁的英武青年，红头巾，银甲红袍，扛着长枪）横枪立马挡在关口正中，身后只有几百个江东亲卫；对面太史慈（三十多岁，背插两支短戟，挎弓）勒马凝视他，两人神情都有点恍惚，像是在哪里见过；前景为开阔平整的关口前硬土地",
    "n11_a_huangzhong": "伊阙关楼上，白胡子老将黄忠（六十岁上下，精神矍铄，赤红战袍，拉满一张硬弓）居高临下瞄准关下；关下赵云（白袍银甲，亮银枪）勒马仰望，肩甲上已插着一支箭；前景为开阔平整的关下石板地",
    "n11_g_lvbu": "秋天的邙山山道：吕布（紫金冠，红锦百花袍，方天画戟）骑赤兔马，身后的并州狼骑打着「吴」字旗；他对面张辽（三十多岁，长刀，并州甲）横刀立马挡在路中；张辽身后远处，吕玲绮（高马尾，红色劲装）骑在马上直视父亲；吕布的目光越过张辽落在女儿身上；前景为开阔平整的山道夯土地",
    "n11_g_jiangdongqi": "邙山脚下的坡地上，吴军江东骑卒（青色轻甲，长矛，矮壮的南方马）从山坡两侧包抄上来，马蹄踏起秋草与尘土；远处山上竖着「吴」「曹」「吕」三面旗；前景为开阔平整的坡下硬草地",
    "n11_g_sunce": "黄河南岸的河滩，浑黄的河水在身后：孙策（红头巾，银甲红袍，扛长枪）率江东亲卫冲在吴军最前头；太史慈（背插两支短戟，挎弓）打马迎上，两人隔着几步勒住马对望；前景为开阔平整的河滩硬沙地",
    "n11_g_huangzhong": "邙山下的山坡上，黄忠（白胡子老将，赤红战袍，拉满硬弓）站在高处，一支箭刚钉在北军主帅的马蹄前；赵云（白袍银甲）催马挡在北线主角前面；前景为开阔平整的坡下硬土地",
    "s12w_yujin": "许昌城墙上，于禁（四十岁上下，面容严整冷峻，玄黑铁甲）立在城头指挥，滚木礌石码得整整齐齐，城头插着黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）；前景为开阔平整的城下硬土地",
    "s12w_gaoshun": "官渡道正中，高顺（沉默的中年将领，持大盾，并州旧甲）一人一盾站在路中间，身后陷阵营的大盾连成一道墙，对面吕布勒马停住；前景为开阔平整的官道硬土地",
    "s12w_zhaoyun": "黄河边官渡的土山脚下，赵云（白袍银甲，亮银枪，白马）单骑冲向一座正在燃烧的土山，身后是北军的壕沟和黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）；前景为开阔平整的土山下夯土地",
    "s12c_machao": "宛城城外，马超（二十多岁，银甲白袍，虎头湛金枪）冲在北军最前头，枪尖挑着一面白布，身后是西凉铁骑和黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）；前景为开阔平整的城外硬土地",
    "s12c_zhangliao": "长坂坡上，张辽（三十多岁，长刀，并州甲，盔上缠着白布）横刀立马，身后八百并州狼骑旗上缠着白布；前景为开阔平整的坡下硬草地",
    "s12c_lianchuan": "夜里的长江赤壁，铁索连起来的北军大船一条接一条燃起冲天大火，火顺着铁索往后蔓延，东南风把火焰吹得横着走，江面一片通红，船头并州强弩手在火海浓烟中惊慌攒射；前景为开阔平整的江边烧黑石滩",
    "s12c_zhaoyun": "火光冲天的乌林江岸，赵云（白袍银甲，亮银枪）挡在溃退的北兵前面，枪尖刺到一半停在空中，眼神惊愕；前景为开阔平整的江岸硬沙地",
    "s12c_kongming": "赤壁火海中央一艘还没烧着的大船，船头诸葛亮（二十出头，白衣，羽扇）静静站着，四面全是火，江水通红，一艘挂红头巾大旗的战船正侧面撞来；前景为开阔平整的船板甲板",
    "n12g_xiahoudun": "许昌城下，独眼的夏侯惇（黑甲，左眼蒙眼罩，持长枪）带着曹营残兵，旗却是「吴」字；城门里关羽（红脸长须，青龙刀）拖刀走出；前景为开阔平整的城门前硬土地",
    "n12g_caoren": "中牟城外，曹仁（方脸短须，重甲）再一次摆开盾车铁锁的连营大阵，旗是「吴」字；前景为开阔平整的阵前夯土地",
    "n12g_sunce": "官渡的壕沟前，孙策（红头巾，银甲红袍，扛长枪）带着江东亲卫直扑壕沟；壕沟这边太史慈（背插两支短戟）打马迎上，两人神情都有点恍惚；前景为开阔平整的壕沟前硬土地",
    "n12g_lvbu": "官渡第三道壕沟前，吕布（紫金冠，红锦百花袍，浑身是血，眼神疯狂）骑赤兔马，画戟上挂着半面撕烂的「吴」字旗，身后是没有旗没有阵的乱兵；赵云、马超一左一右冲来；前景为开阔平整的壕沟前泥地",
    "n12d_huangzhong": "宛城城头，白胡子老将黄忠（赤红战袍，拉满硬弓）居高临下；城下马超（银甲白袍）挺枪仰望；前景为开阔平整的城下硬土地",
    "n12d_ganning": "汉水江面，十几条快船横在江上，船头甘宁（精悍的年轻水军将领，赤膊披锦袍，腰挂一串铜铃，持铁胎弓）放声大笑；岸上北军望着江水发愁；前景为开阔平整的江岸硬沙地",
    "n12d_zhouyu": "长江江面上一艘大楼船压来，船头周瑜（二十多岁，俊美儒雅，青袍外罩轻甲，手里拿着一本账册）平静地看着北岸；北岸诸葛亮（白衣羽扇）坐在四轮车上遥遥相对；前景为开阔平整的江岸硬沙地",
    "tm_zhangfei": "洛阳南宫的台阶上，张飞（黑脸环眼，满身血污，丈八蛇矛）挡在殿门前，左右看着街两头，一脸茫然；前景为开阔平整的台阶下青石地",
    "tm_guanyu": "深夜太极殿前的广场，关羽（红脸长须，绿袍金甲，盔缨断了一截，青龙刀横在身前）独自站着，丹凤眼睁开，月光照在刀上；前景为开阔平整的广场青石地",
    "n10_xuchu": "许都城外的旷野，尘土飞扬：许褚（三十多岁的魁梧壮汉，虎背熊腰，脱去铁甲赤着上身，肌肉虬结，拎着一柄沉重的大砍刀）怒吼着迎战，脚边扔着卸下的重甲与头盔，身后是黑压压的曹军虎卫军；前景为开阔平整的城外夯土地",
    "n10_yujin": "许都城门前的深壕与鹿角阵后：于禁（四十岁上下，面容严整冷峻，一身玄黑铁甲一丝不苟，手按长刀）立在壕沟后的木台上指挥，五排强弩手轮番上弦，城头上插着整整齐齐的黑底「魏」字旗；前景为开阔平整的壕前硬土地",
    "n10_yuejin": "中牟道上的第一道军垒，拒马鹿角层层叠叠：乐进（三十多岁，身材短小精悍，目光凶狠，曹军黑甲红披风，手提大刀）踩在鹿角木桩上准备跃出逆袭，身后是举着圆盾的曹军精锐；前景为开阔平整的官道硬土地",
    "n10_lidian": "荥阳道的高坡望楼下，两侧排满重弩与绊马索：李典（三十岁上下的儒将，神情沉稳冷静，轻甲外罩深色儒袍，手持令旗）站在望楼木台上挥旗，弩手齐齐瞄准坡下；前景为开阔平整的坡前硬土地",
    "n10_caoren": "荥阳城外的大营前，盾车、长枪与强弩排成严丝合缝的八门金锁大阵：曹仁（三十多岁，方脸短须，沉稳如山，重甲长枪）骑马立于阵心「曹」字大旗下，阵门开合之间杀气森严；前景为开阔平整的阵前夯土地",
    "n10_hulao": "险峻陡峭的虎牢关下，高耸的关墙夹在两山之间，关门紧闭：吕布（高大威猛，头戴三叉束发紫金冠，披红锦百花袍与兽面吞头连环铠，手持方天画戟）骑赤兔马立在关前吊桥上，身后并州狼骑与黑底「吕」字大旗一字排开；前景为开阔平整的关前碎石硬地",
    "n10_luoshui_nu": "夜雾弥漫的洛水河道，水面拉起碗口粗的横江铁索：两岸芦苇与高坡上火把齐亮，高坡上曹操（四十多岁，玄黑战袍）亲自督战，成排的校事府密探与曹军强弩手居高临下挽弓齐射，火矢映红了洛水水面；前景为开阔平整的洛水浅滩石地",
    "n10_g_dukou": "洛水与黄河交汇处的巩县渡口，三十艘铁锁连环的大船熊熊燃烧着撞向木制浮桥与栈桥：曹洪（三十多岁的曹军将领，铁甲提刀，满脸烟灰）带着水寨守军在火光与浓烟中仓皇迎战，背后粮仓大火冲天；前景为开阔平整的渡口石板地",
    "jd_shuifei": "波涛汹涌的东海海面上，几艘抢掠粮船的海贼大船横向拦路：领头的东海海贼头目（身穿抢来的破旧官军刀兵皮甲，手持环首阔刀，满脸横肉）站在高耸的船头叫嚣，身后一群赤膊裹巾的山贼喽啰挥舞短刀、拉弓搭箭；前景为开阔平整的木制船头甲板",
}

# story cg key: the scene
CGS = {
    "c11_bidao": "冬日吴郡大营的辕门外，雪地：孙尚香（十九岁的成年女子，一身红甲，英气明艳）追着主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）满营跑，手里的刀举得老高；围观的士兵笑成一团，孙策（二十出头的少年将军，红袍金甲）在一旁押注起哄；远处辕门上挂着「孙」字旗",
    "c11_liniang": "冬日丹阳深山的竹林山道，薄雾：黎娘（二十五六岁的成年女子，山越女王，齐肩短发，脸颊和手臂刺着青色部族纹，兽皮树皮编甲，串珠项链，赤足裹布）挽着竹弓，刚射出的一支绿羽箭钉在竹子上；孙尚香（十九岁的成年女子，一身红甲，英气明艳）反手挥刀，把半空中的第二支箭劈成两截；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，肩扛古锭刀）站在后面，张着嘴看呆了",
    "c12_liushou": "春雨里的汉水岸边，楼船泊在江上：周瑜（二十多岁的俊美儒将，白袍银甲）摊开一张蜀道图；孙策（二十出头的英武青年，红色头巾，提长枪）把枪往地上一戳，一脸不服；孙尚香（十九岁的成年女子，一身红甲，英气明艳）已经牵着马站在后面；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛大刀）站在中间",
    "c12_tiesuo": "瞿塘峡口夔门，两岸绝壁：江面横着三道挂满铃铛的铁索，周泰（三十岁上下的魁梧猛将，满身旧伤疤）把刀咬在嘴里跃进翻滚的江水，甘宁（二十多岁的悍勇青年，腰挂铜铃）在船头拉满了弓",
    "c12_duishe": "江州城下的护城河，夕阳：城头上严颜（须发全白的老将，川军铁甲）拉满长弓，城下黄忠（四十来岁的壮实老将，背硬弓）骑马拉弓对射，两人中间的空中交错着箭，箭都射偏了；两人的嘴角都带着一点笑",
    "c12_luocheng": "雒城城门前：孙尚香（十九岁的成年女子，一身红甲，英气明艳）拍马挥刀冲阵，一刀劈翻了张任（三十多岁的蜀中名将，银灰铁甲）的战马；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，肩扛古锭刀）在后面伸手大喊，像是要拦又拦不住",
    "c12_wuxian": "成都行辕的书房，深夜，一盏油灯：吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）坐在案前，一手拨着算盘，一手按着账本，抬眼看着短发的主角（穿素色常服，不穿盔甲，双手空着、身边没有任何刀剑兵器），神情像在挑他的错；窗外院子里，孙尚香（十九岁的成年女子，一身红甲，英气明艳）在月光下练刀",
    "c12_zhurong": "泸水渡口：祝融夫人（二十多岁的成年女将，南中王后，赤红藤甲战裙，背负五口飞刀）扬手掷出一口飞刀，飞刀钉在主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，肩扛古锭刀）脚尖前的地上，他低头看着，愣住了",
    "c12_kanfeng": "盘蛇谷口，傍晚：陆逊（十八九岁的清秀青年，白袍轻甲）站在谷口，抬手试着风向，看着谷里的草和烟；孙尚香（十九岁的成年女子，一身红甲，英气明艳）在他身边，抱着刀，侧头听他说话",
    "c12_qiqin": "南中的大帐前：孟获（四十岁上下的南中蛮王，魁梧，藤甲兽皮，头插雉尾）跪在帐前，低着头；祝融夫人（成年女将，赤红藤甲战裙）在旁边拍着他的背；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛刀）坐在帐前，一脸「这句台词我听过」的表情",
    "c13_chuzheng": "成都行辕的大堂，窗外桃花盛开：荀攸（三十多岁的清瘦文士，深蓝儒服）把一张旧地图铺在案上，手指从汉中划到长安；董白（成年女将，银白色长发高马尾，紫色毛边皮甲）把骨朵往地上一顿；吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）在一旁拨着算盘；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）站在案前看地图",
    "c13_duanshui": "夜里阳平关后山的绝壁：黄忠（四十出头的精壮军汉，黄皮甲衬蓝战袍，背着弓）和甘宁（二十出头，晒得黝黑，精瘦，头发上插一根羽毛，腰上的铃铛用布缠着）带着一队兵攀着绳索往上爬；山下远处是阳平关的关墙；贾诩（四十多岁，清瘦蜡黄，眯着眼）在山脚举着火把仰头看",
    "c13_zhanglu": "汉中南郑的城门大开：张鲁（四十多岁，清瘦温和，道冠道袍，长须）没穿甲，捧着一只米斗走出来；阎圃（四十岁上下的中年文士，青灰色儒服外披旧道袍）扶着他的胳膊；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）站在城门前，双手空着，不扛大刀",
    "c13_xingye": "汉中的夜，满天星斗，一间亮着油灯的屋子：吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）坐在案前，把自己的毛笔递给穿常服的短发的主角（穿常服，不穿盔甲，双手空着、身边没有任何刀剑兵器）；门口，孙尚香（十九岁的成年女子，一身红甲，英气明艳）抱着两个烤红薯站着，看看他，又看看那支笔",
    "c13_junyi": "汉中南郑的大堂，地图铺满了一整张案子：魏延（三十岁上下，赤红脸膛，持枪）一拳砸在地图上的秦岭；甘宁（二十出头，晒得黝黑，头发上插一根羽毛）一拍大腿叫好；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）站在中间，一脸「这个我听过」的兴奋表情",
    "c13_junyi_f": "汉中南郑的大堂，满堂叫好声里：法正（三十岁上下，瘦削精明，嘴角一丝冷笑，深色文士袍）放下酒杯站起来，把一张画得密密麻麻的关中地图摊在案上，手指按着秦岭里的栈道；魏延（三十岁上下，赤红脸膛，持枪）瞪着他；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）站在两人中间，看看地图又看看法正",
    "c13_ziwu": "子午谷的栈道，钉在万丈绝壁上，一边是石壁，一边是看不见底的云雾：吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）停在栈道上，脸色发白，一把抓住主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）的袖子；后面是一长串运粮的独轮车和士兵",
    "c13_zhandaohuo": "夜里的子午谷，身后的栈道从远到近一段一段燃烧，像一条火龙：吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）把账本紧紧抱在怀里；魏延（三十岁上下，赤红脸膛，持枪）被火光映得满脸通红，回头望着火",
    "c13_canzhang": "黄昏的子午谷口，硝烟弥漫：主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛大刀）跪在地上，怀里抱着吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙，肩上搭着一件红披风）；她握着一支毛笔，在摊开的账本最后一页上写字；孙尚香（十九岁的成年女子，一身红甲）跪在一旁，攥着她的另一只手；远处是燃烧的栈道；画面克制哀伤，不画血腥",
    "c13_zhandao": "故道的悬崖栈道，云雾在脚下：主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）走在栈道正中，左边吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）脸色发白、死死抓着他的左袖，右边孙尚香（十九岁的成年女子，一身红甲，英气明艳）目不斜视、也抓着他的右袖；后面的士兵憋着笑",
    "c13_yexiao": "渭水边的军帐里，深夜，一盏油灯照着地图：穿常服的短发的主角（穿常服，不穿盔甲，双手空着、身边没有任何刀剑兵器）坐在案前；孙尚香（十九岁的成年女子，一身红甲，英气明艳）端着一碗羊肉汤，吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）端着一碗粥，两人在案前站住，互相看了一眼",
    "c13_chetui": "清晨的渭水边营地，斥候飞马回营：法正（三十岁上下，瘦削精明，嘴角一丝冷笑，深色文士袍）坐在帐前，放下茶碗，慢慢地笑了；远处的长安城东门大开，一队黑甲骑兵（黑底「魏」字旗）正往东远去",
    "c13_jiuzhang": "未央宫前的长阶，黄昏：董白（成年女将，银白色长发高马尾，紫色毛边皮甲）坐在台阶上，抱着膝盖望着远方；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）站在她身旁，古锭刀拄在地上；台阶下散落着西凉兵丢下的旗帜",
    "c13_liru": "长安尚书台的偏阁，昏暗，一只火盆烧着竹简：李儒（瘦削的文士，摇着羽扇）蹲在火盆旁；贾诩（四十多岁，清瘦蜡黄，眯着眼）坐在他对面，把火盆往他那边推了推；荀攸（三十多岁的清瘦文士，深蓝儒服）从火盆边捡起一卷没烧着的竹简",
    "c13_yushan": "长安城头，傍晚：荀攸（三十多岁的清瘦文士，深蓝儒服）把地图摊在城垛上；张绣（二十出头，剑眉高髻，银蓝西凉鳞甲、短白披风）扛着长枪站在一旁，一脸不情愿；远处南边的山口（武关方向）插满了赤底「汉」字旗",
    "c13_lianying": "傍晚，蓝田的山坡上：陆逊（十九岁上下的清秀青年，白袍轻甲）站在山坡上抬手试风，望着山下的林子里一座连一座的汉军营寨；法正（三十岁上下，瘦削精明，嘴角一丝冷笑，深色文士袍）站在他身后",
    "c13_changan": "夜里长安的城楼，城头挂满了灯：吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）坐在城楼里对账；孙尚香（十九岁的成年女子，一身红甲，英气明艳）坐在垛口上晃着腿，接过她递来的账本，笑出了声；远处东方的天边，是洛阳的方向",
    "c14_dongchu": "秋天的长安行辕，窗外柳叶发黄：荀攸（三十多岁的清瘦文士，深蓝儒服）把一张旧地图铺在案上，手指从长安划向洛阳；法正（三十岁上下，瘦削精明，嘴角一丝冷笑，深色文士袍）抱着胳膊看图；贾诩（四十多岁，清瘦蜡黄，眯着眼）坐在一旁打哈欠",
    "c14_yushui": "南阳宛城被大水泡了三尺，城墙上留着水印；城外的淯水边，周瑜（二十多岁的俊美儒将，白袍银甲）站在一道刚刚放开的水坝上翻着账本；远处孙策（二十多岁的英武青年，红色头巾，提长枪）单骑冲向弃城北走的赤底「汉」字旗队伍",
    "c14_huishi": "新安以东的谷水边，两支军队的旗插到一起：孙策（二十多岁的英武青年，红色头巾，提长枪）刚跳下马，一拳砸在主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）的肩上，两人大笑；周瑜（二十多岁的俊美儒将，白袍银甲）骑马慢慢走过来，手里拿着账本",
    "c14_chengxia": "从邙山脚下远望洛阳：城西一座插满黑底「魏」字旗的大营，城东一座插满赤底「汉」字旗的大营，城门前的平地上摆满一堆一堆的乱石阵，宫城上竖着一面「吕」字旗；画面前景是周瑜（二十多岁的俊美儒将，白袍银甲）和贾诩（四十多岁，清瘦蜡黄，眯着眼）的背影",
    "c14_zhenyan": "黄昏的乱石阵口：甘宁（二十多岁的悍勇青年，腰挂铜铃）身上插着好几支箭，背着一身尘土的陆逊（十九岁上下的清秀青年，白袍轻甲）从风沙里走出来，铜铃在晃；远处高坡上，周瑜（二十多岁的俊美儒将，白袍银甲）低头在地上画着八个圈",
    "c14_pingshou": "傍晚的护城河边，张飞（黑脸虬髯的猛将，黑铁甲，丈八蛇矛）拽着孙策（二十多岁的英武青年，红色头巾，提长枪）的后领子把他从河里拖上岸，两人浑身湿透，孙策一边吐水一边骂，张飞仰头大笑；身后的小木桥",
    "c14_yingzhan": "汉军营门前，尘土飞扬：关羽（红脸长须，丹凤眼，绿袍绿巾，青龙偃月刀）单手抱着胸口中箭的年轻将领关平，另一手的青龙刀仍然横着对向前方；对面黄忠（四十来岁的壮实老将，背硬弓）垂下长弓，手在发抖；地上躺着严颜（须发全白的老将，川军铁甲），断刀在旁；一缕红色盔缨落在地上；画面克制悲壮，不画血腥",
    "c14_zhenqian": "洛水岸边，两军阵前：刘备（四十岁上下，双耳垂肩，面容仁厚，绿袍外罩金边铠甲，双手各提一口剑）骑马挺剑；孙尚香（十九岁的成年女子，一身红甲，英气明艳）举刀拍马迎上；身后白毦兵与吴军对阵",
    "c14_cicao": "夜里曹营的中军帐，一盏油灯：曹操（四十多岁，身形不高，细长眼，头上缠着一条布，黑色锦袍）坐在案后，低头看着自己的胸口，神情平静甚至带一点笑；诸葛亮（二十岁上下，清俊高傲，纶巾、白色鹤氅，手摇羽扇）站在案前，对着他深深一揖，羽扇垂下；帐外隐约有火光；画面克制，不画血腥",
    "c14_yulin": "夜里洛阳的南宫，殿门前点着灯：刘备（四十岁上下，双耳垂肩，面容仁厚，绿袍外罩金边铠甲，双手各提一口剑）把一口剑递给一个哆哆嗦嗦的白发老宦官，身后站着一排拿着刀剑的老宦官、禁卒和白毦兵；殿里深处坐着一个二十出头的年轻天子，面容瘦削，眼睛很亮",
    "c14_hujia": "三更，火光里的南宫殿门：刘备（四十岁上下，双耳垂肩，面容仁厚，绿袍外罩金边铠甲，双手各提一口剑）浑身是伤，双剑都断了，张开双臂堵在殿门口；殿门外，吕布（高大英俊，冷笑，红黑镶金铠甲，头戴两根长雉尾，方天画戟）提着画戟逼近，身后是涌进来的并州狼骑；地上倒着拿剑的老宦官；画面悲壮克制，不画血腥",
    "c14_yuanmen": "天快亮的辕门前：吕布（高大英俊，冷笑，红黑镶金铠甲，头戴两根长雉尾，方天画戟）骑在赤兔马上，咧嘴笑着，把一顶金边头盔扔在地上，脚边散开的布包里滚出一方五龙钮玉玺；对面主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）站在辕门下沉着脸；他身后董白（成年女将，银白色长发高马尾，紫色毛边皮甲）攥紧了骨朵，贾诩（四十多岁，清瘦蜡黄，眯着眼）垂着眼；远处洛阳城门大开；画面不画血腥",
    "c14_rucheng": "清晨的南宫殿内，烧了一半的帷幔：荀攸（三十多岁的清瘦文士，深蓝儒服）跪在一张案前，把一张旧地图轻轻放在案上，案上摊着一卷竹简；殿门口吕布（高大英俊，冷笑，红黑镶金铠甲，头戴两根长雉尾，方天画戟）倚着门，用画戟拨着地上的灯；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛大刀）站在殿中，低头不语",
    "c14_xunyu": "洛阳宫城的偏殿：荀彧（三十多岁的端正文士，深色儒袍、官帽，衣冠一丝不乱）把一口剑横放在案上；荀攸（三十多岁的清瘦文士，深蓝儒服）站在他身边，手按着摊开的地图，指着北方；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛大刀）坐在案后看着两人",
    "c14_hebing": "邙山北坡一座快被冲垮的营寨：夏侯惇（三十多岁，浓眉虎目，两只眼睛都完好，黑色曹军铠甲，满身血污）举刀；曹仁（三十岁上下，方脸短须，曹军铁甲碎了一半，拄着长枪）；对面主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）带兵赶到，三面旗——「吴」「曹」「吕」——同时竖在山坡上",
    "c14_beiwang": "黄昏的邙山，两面山坡隔着一片战场：东边山坡上黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）下站着北线主角（二十出头的年轻男子，干净斯文，头发用布巾束成发髻，旧鱼鳞甲；和南线主角长着同一张脸），正抬手揉太阳穴，他身边没有诸葛亮，赵云（白袍银甲）正勒马回头；这边山坡上，主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）也正抬手揉太阳穴；他身后不远处，吕布（高大英俊，冷笑，红黑镶金铠甲，头戴两根长雉尾，方天画戟）盯着两人的脸，握紧了画戟",
    "c14_zhanlv": "黎明的洛水河滩：吕布（高大英俊，冷笑，红黑镶金铠甲，头戴两根长雉尾，方天画戟）半跪在浅水里，画戟断成两截，抬头望着主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风），嘴角带着古怪的笑；董白（成年女将，银白色长发高马尾，紫色毛边皮甲）站在一旁看着他；远处洛阳城头上，张飞（黑脸虬髯的猛将，黑铁甲，丈八蛇矛）提着蛇矛满身是血；画面不画血腥",
    "c14_qianggong": "洛阳城门下，烟尘滚滚：孙策（二十多岁的英武青年，红色头巾，提长枪）举枪第一个冲向城门，周瑜（二十多岁的俊美儒将，白袍银甲）拔剑跟上，主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）高举古锭刀，身后大军扛着撞木冲锋，城门正在被撞开",
    "c14_jianlou": "洛阳城头的箭楼上，赤底「汉」字旗旁边升起一面黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）：箭楼里站着北线主角（二十出头的年轻男子，干净斯文，头发用布巾束成发髻，旧鱼鳞甲；和南线主角长着同一张脸），抬手揉着太阳穴；他身旁是诸葛亮（二十岁上下，清俊高傲，纶巾、白色鹤氅，手摇羽扇）和赵云（二十多岁，白袍银甲，银枪枪尖结着白霜）；城下远处，主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）也抬手揉着太阳穴",
    "c14_xiang": "伊阙山口的路边，一队衣甲残破的曹军打着白旗：荀彧（三十多岁的端正文士，深色儒袍、官帽，衣冠一丝不乱）怀里抱着一口剑，夏侯惇（三十多岁，浓眉虎目，两只眼睛都完好，黑色曹军铠甲，满身血污）和曹仁（三十岁上下，方脸短须，曹军铁甲碎了一半，拄着长枪）站在他两侧；荀攸（三十多岁的清瘦文士，深蓝儒服）迎上前去，愣住了",
    "c14_nanyang": "冬日南阳宛城的城头，城墙上留着一道道水印：孙尚香（十九岁的成年女子，一身红甲，英气明艳）坐在垛口上晃着腿，吴苋（二十岁上下的成年女子，蜀中闺秀，清秀聪慧，淡青色的蜀锦衣裙）坐在她旁边对账；远处北方的天边，是洛阳的方向",
    "end_xiangjin": "象征性结局卡插画（结局十三·香烬，南线）：黎明时分盘蛇谷口焦黑的山道，残烟袅袅升起，一把刃口带缺的红缨宽背大刀斜插在焦土中，远处散落着半件烧焦的藤甲；色调苍凉肃穆，不见人物",
    "end_suanjin": "象征性结局卡插画（结局十五·算尽，南线）：黎明时分子午谷口，身后山谷里烧断的栈道还冒着残烟，一本摊开的账本落在石头上，被风翻动着书页，旁边是一支毛笔和一把散了珠子的算盘，算珠滚落在焦土里；色调苍凉肃穆，不见人物",
    "c11_hanqi": "天刚亮的汉水，薄雾：整条江面铺满了插着赤底黑字「汉」字旗的战船，一排接一排望不到头，船头站满赤红战袍、玄黑札甲的汉军连弩兵；画面前景是一条小小的锦帆快船，甘宁（二十多岁的悍勇青年，腰挂铜铃）握着船舵，孙策（二十出头的英武青年，红色头巾，提长枪）站在船头仰头看着，主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛刀）在他身后张大了嘴",
    "c11_liubei": "瓢泼大雨里的汉水芦苇渡口：刘备（四十岁上下，双耳垂肩，面容仁厚却眼眶通红，绿袍外罩金边铠甲，双手各提一口剑）立在雨中，身后一排白羽盔缨的白毦兵枪阵纹丝不动，赤底「汉」字大旗被雨打湿；画面另一侧，孙坚（四十岁的魁梧猛将，披湿透的虎皮披风，肩上插着一支断箭，满身是血）提着战刀回头怒吼，主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，肩扛古锭刀）从芦苇里冲出来挡在他身前",
    "c11_baihe_han": "白河两岸，清晨：对岸铺天盖地都是赤底黑字的「汉」字大旗和赤红战袍的汉军阵列，阵前高坡上站着诸葛亮（二十岁上下的青年，清俊高傲，纶巾白袍，手摇羽扇）；这一岸，周瑜（二十多岁的俊美儒将，白袍银甲）和主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛刀）并肩站在河边，望着对岸，脸色凝重",
    "c11_zhugejin": "夜里江南竹林后头的柴门小院，一盏灯笼照着薄雪：诸葛瑾（三十出头，方脸长须，青色儒袍，神情老实）正在捆行李；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）提着灯笼站在柴门口，伸手按住了他的包袱；鲁肃（三十岁上下的敦厚文士）站在后面",
    "c11_modao": "出兵前夜的营帐里，一盏油灯：孙尚香（十九岁的成年女子，一身红甲，英气明艳）坐在灯下，低着头，用磨刀石磨一把巨大的宽刃厚背古锭刀，刀身映着灯光；帐门口站着主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风），刚刚掀开门帘",
    "c11_tuogu": "狂风暴雨的汉水渡口，一条大船的船板上：孙坚（五十岁上下的魁梧老将，虎皮披风湿透，肩上插着一支发黑的断箭，脸色灰白）躺着，攥住主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）的手腕；孙策（少年将军）跪在一旁；一个军医跪在雨里低着头；背景是被风吹弯的芦苇",
    "c11_yuye": "雨夜的大船船尾，船上的旗刚换成一面新的「吴」字旗：孙尚香（十九岁的成年女子，一身红甲，英气明艳）把额头抵在主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）的肩上，他一动不动地站着；雨丝被船灯照亮，远处的江面一片漆黑",
    "c11_luoyang": "回忆画面，带一点褪色的暖调：雪夜的洛阳德阳殿台阶，宫门大开，火把通明；曹操（三十多岁，身材不高，精明的笑容，黑色锦袍外罩铠甲）一手扶着一个十几岁的少年天子（只画背影），一手托着发着五色光的玉玺；台阶下远处，一个披虎皮的老将被两个将领架着往外拖",
    "c11_nanyang": "回忆画面，带一点褪色的冷调：南阳城头换上了「刘」字旗，城门口站着红脸长须的关羽和黑脸虬髯的张飞；城头正中站着诸葛亮（二十岁上下的青年，清俊高傲，纶巾布衣，手持白羽扇），居高临下地指着城下；城下是满身血污的孙家残兵",
    "c11_quyou": "夜里楼船的船舱，隔着一道半透明的竹帘：小乔（成年女子，温婉灵动）在帘后弹琴，嘴角藏着笑；帘外周瑜（二十出头的俊朗谋士，白袍）放下手里的水图，第三次回过头来，终于笑了；桌上摊着他的账本",
    "c11_quwu": "白河上被洪水冲翻的战船之间，一条楼船：周瑜（二十出头的俊朗谋士，白袍染血，身中数箭）躺在小乔（成年女子）怀里，脸转向别处；小乔一边流泪一边弹琴；远处上游的闸口还在泄洪，水面漂着断桨和破帆",
    "c11_xiongdi": "清晨的白河两岸，洪水刚退：左岸诸葛瑾（三十出头，方脸长须，青色儒袍）拱手；右岸诸葛亮（二十岁上下，纶巾布衣，白羽扇垂在身侧）也拱手；两人隔着宽阔的河面遥遥相对，身后各是自己的军队；河上薄雾",
    "c11_liaochuang": "汉水南岸的营帐里，烛光：主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）赤着上身坐着，肩上一道箭伤；孙尚香（十九岁的成年女子，一身红甲，英气明艳）跪坐在他身边给他包扎，手在抖，耳根通红；帐门的帘子被掀开一条缝，露出吴夫人（慈和的中年贵妇）偷看的半张笑脸",
    "end_quwu": "an ending card illustration, quiet and symbolic: a guqin with one snapped string lying on the wet deck of a capsized tower ship, an open ledger floating in the flood water beside it, a broken arrow and a white silk sash caught on the planks; no people, no blood",
    "c3_guotu_street": "无极街口的夜里：督粮官郭图（四十岁上下，面容刻薄，细眼薄唇，黑色文冠、深紫官袍，手摇黑色羽扇）骑在马上拦住去路，身后是整队举着强弩的督战弩手，火把照亮他贪婪的目光，视线越过人群盯着身后一长串粮车；赵云（银甲白马，银枪出鞘）勒马挡在最前，主角持白蜡杆长枪（红色平安结）站在他身侧，身后是燃烧的甄府大门；对峙的紧张感，冷暖对比的火光",
    "c3_bad_guotu": "甄府大门内的中庭，黎明前：满院狼藉，断枪与碎门板，淳于琼倒在一旁；郭图（刻薄的中年官员，黑色文冠、深紫官袍）摇着羽扇不紧不慢踱进门，一脚踩在门槛上打量着战利品；断了一半战枪、满身是伤的主角拄着枪半跪着抬头怒视他，张夫人（成年女性）抱着账本站在正堂台阶前；色调阴冷",
    "c3_bad_return": "无极甄府门前，黄昏：商队空着手回来，车马停在门口；张夫人（成年女性，富态精明）站在台阶上，目光越过人群落在队尾，那里本该有一个背竹篓的白衣姑娘，她什么也没问，默默合上手里的账本；赵云低着头牵马，郭嘉抱着没打开的酒葫芦站在一旁，主角站在最前面，神情沉重；整体色调灰暗压抑",
    "c4_drink": "山寨大堂里三人豪迈对饮：主角居中举碗，左边是郑好（成年女性，红色束袖短打，豪爽大笑），右边是姜巧（成年女性，头缠布巾的机关匠，手里还转着一枚小齿轮），两人互相瞪眼不服，大堂里摆着酒坛与简陋的木桌，众山贼在后面起哄",
    "c4_escape": "太行山道上：郑好的刀手结成刀阵，姜巧的机关弩与绊索布满山道，把陷阵营的黑甲重盾兵死死拖住；主角在前方挥手招呼队伍向东撤退，山口飘着雪与烟尘",
    "c4_million_hj": "青州北海城外的原野：数以万计的黄巾饥民军黑压压围住孤零零的北海城，黄旗遮天蔽日，城头孔融守军寥寥；远处的丘陵上，主角一行人勒马眺望",
    "c4_taishici_break": "北海乱军之中：年轻骁将太史慈（二十出头，英气逼人，披银白轻甲）单枪匹马，长枪连挑数名黄巾兵，突入城门；主角挥刀从旁杀来，两人并肩冲阵，尘土与刀光",
    "c4_porridge": "北海城前的阵地上：几十口大锅一字排开，热气腾腾地熬着粥，刚刚放下兵器的黄巾饥民捧着粥碗痛哭，管亥（魁梧的黄巾首领）把鬼头刀扔在地上，主角站在锅前舀粥",
    "c4_kongrong": "北海郡府正堂：孔融（五十岁上下，清瘦儒雅，捋着胡须，一身官服）把一方沉重的北海相印双手推向主角，案上放着几个梨；窗外是刚解围的北海城，阳光明亮",
    "c4_yanliang": "黄河渡口的黎明：颜良（魁梧威猛，披重甲，手持大刀）立于阵前高声喝令，身后一排先登死士举着强弩，对准渡口对面；浑浊的黄河与寒雾",
    "end_hushi": "an ending card illustration, quiet and symbolic: a half-open camp gate on a rainy night by the Luo river, a broken sky-piercer halberd in the mud, a torn red-horse saddle set and a tiger-head bracer; no people, no blood",
    "end_zhumie": "象征性结局卡插画（结局十八·烛灭，北线）：深夜帐中的案几，一支白烛刚刚燃尽只剩一缕青烟，旁边翻倒着一只喝了一半的参汤碗，案上压着一方帅印，帅印旁放着一把白羽扇；不见人物，不画血腥",
    "end_juefa": "an ending card illustration, quiet and symbolic: two broken mountain stockade gates in snow with torn banners tangled together, a huge halberd planted in front; no people, no blood",
    "end_menhou": "an ending card illustration, quiet and symbolic: a closed vermilion government gate at night with warm light through the crack, discarded black banners and broken tally arrows; no people, no blood",
    "end_pifu": "an ending card illustration, symbolic: a hunting bow and a broken spear lying in fallen autumn leaves in a misty forest, three black face-cloths dropped on the path, an arrow stuck in a tree trunk",
    "end_shensuo": "an ending card illustration, symbolic: an empty mountain road at dawn leading north, deep wheel ruts in the mud, a torn red cloth caught on a broken wooden cage bar, a muddy account book lying open beside the ruts",
    "end_duanqiao": "an ending card illustration, quiet and symbolic: a broken pontoon bridge over a dark river at dawn, a cracked wine jar floating among the planks, a white-ribboned spear shaft caught on a broken post; no people, no blood",
    "end_kujing": "an ending card illustration, quiet and symbolic: an old dry well in a burned village at dawn, a silver spear planted beside it, a torn piece of red silk caught on the well's stone rim, a white war robe draped over the edge; no people, no blood",
    "end_yice": "an ending card illustration, quiet and symbolic: a half-opened letter lying in fresh snow on a forest road at dusk, a broken arrow beside it, an old medicine box with a wine gourd resting on its lid; bare trees with no birds above; no people, no blood",
    "end_duanxian": "an ending card illustration, quiet and symbolic: a broken bow with a snapped string lying in trampled reeds by a river at dawn, a red tassel from a silver helmet caught on a reed, scattered arrows; no people, no blood",
    "end_chibi": "an ending card illustration, quiet and symbolic: a line of burning chained warships on the Yangtze at night, a small boat with a white coffin drifting south; no people, no blood",
    "end_guandu": "an ending card illustration, quiet and symbolic: a halberd planted in the mud of the Guandu riverbank at dawn mist, a faded red scarf on its tip, half a broad saber beside it; no people, no blood",
    "end_tianming": "an ending card illustration, quiet and symbolic: a broad saber and a white-wax spear crossed back to back on one stone terrace at sunrise, the south and north banners flying side by side; no people",
    "end_locked": "a dark ink-paper thumbnail with a faint cinnabar seal containing a large question mark, almost no detail",
    "defeat_south": "the defeat card of the south route: the lord has fallen at dusk on a muddy battlefield, his huge old broadsword planted in the ground beside him, a torn red Sun banner in the wind; restrained, no blood",
    "defeat_north": "the defeat card of the north route: the lord has fallen in the snow at dusk, his white-wax spear planted upright beside him with a red knot fluttering below the blade; restrained, no blood",
    "c3_recruit_board": "a recruitment board at the gate of Zhending: the hero slapping his chest proudly before a wooden notice board, Zhao Yun standing by with his silver spear, a crowd of simple villagers watching with amusement",
    "c3_bribe_villager": "a village road in Changshan: the hero awkwardly pressing copper coins into a villager's hands, a rogue soldier smirking nearby, Xiahou Lan watching coldly from a distance",
    "c3_encounter_ning": "a cliffside in the Taihang mountains: Zhang Ning (a young woman in white with a medicine box) holding a gold needle coldly defying a mob of Yellow Turban zealots; the bandit leader Zhang Baiqi laughing and pointing at her",
    "c3_leave_ning": "the entrance of a mountain valley: the hero leading his troops quietly away, looking back with a conflicted expression at the trapped girl in white deep in the valley",
    "c3_zhangyan_meet": "the Black Mountain stronghold at the peak of Taihang: the bandit king Zhang Yan landing lightly from a high cliff before the hero; surrounding cliffs filled with thousands of bandits holding torches",
    "c3_guotu_raid": "outside the gates of the Zhen manor in Wuji: the sinister Guo Tu laughing on horseback with a fan, as heavy Jizhou infantry smash open the manor's great doors",
    "c3_secret_path": "the entrance of a secret mountain tunnel at night: Lady Zhang leading the young girl Zhen Mi into the dark cave guided by Black Mountain bandits with torches; Zhen Mi looking back at distant fires in Wuji",
    "c3_guojia_map": "inside a military tent at night: Guo Jia holding a wine cup and pointing at a campaign map with a riding crop; the hero, Zhao Yun, and Zhang Yan watching closely around the low table",
    "c3_breakout": "the burning gates of the Zhen manor: the hero leading a cavalry charge out of the fire, his spear knocking aside a Jizhou crossbowman blocking the way",
    "c3_xiahoulan_law": "a village road outside Zhending: Xiahou Lan pinning a thuggish soldier to the ground with one foot, hand on his saber, raising a punishment rod high in the other hand; the hero standing nearby looking awkward",
    "c3_save_ning": "a deep gorge in the Taihang mountains: the girl Zhang Ning with her medicine box cornered against a cliff by Yellow Turban bandits; the hero charging in from the side with his saber drawn to kick the leader",
    "c3_alliance": "a wooden hall in the Black Mountain fort: the hero and Zhang Yan sitting across a table, the hero holding a wine bowl, Zhang Yan slamming a token on the table; Lady Zhang pouring wine, Zhang Ning watching",
    "c3_banma_flag": "a high ground at the Jieqiao battlefield: the hero and Lü Lingqi side by side on horseback, Lü Lingqi holding a giant black-and-white vertically striped 'Zebra' war banner whipping in the wind",
    "c3_save_zan": "Jieqiao battlefield: Zhao Yun on a white horse clashing his silver spear against Wen Chou's heavy lance in a shower of sparks; Gongsun Zan slumped on the ground behind them looking terrified",
    "c3_quyi_camp": "Jieqiao battlefield: Yuan Shao's vanguard Qu Yi standing coldly in front of a wall of 800 soldiers holding giant black iron-bound shields and heavy crossbows, stopping a charge of white horses",
    "end_fuchao": "outside the burned gate of the Zhen manor: the hero shot full of arrows collapsed on the steps, Lady Zhang dead in a pool of blood protecting the young Zhen Mi from a hail of arrows (restrained, no gore)",

    "c1_era": "3 a.m. in a cramped modern apartment, lit only by a monitor: a worn-out 30-year-old office worker with short buzz-cut hair, loosened tie, cold coffee cups and overtime paperwork around him, leaning in toward the screen; on the monitor a game asks him to pick a birthplace, split into two glowing panels — on the left a warm misty Jiangnan river town at dusk with a graceful noblewoman's silhouette on the riverbank, on the right a snowstorm over a northern merchant caravan with a red banner; his face lit half warm, half cold by the two panels; no readable text on the screen",
    "c5_yuexia": "a moonlit garden behind the Minister's mansion, a round moon gate: Diaochan (adult, of great beauty) finishing a silent dance half a step from the hero, long sleeves still drifting in the night wind, an empty wine cup on the stone steps; her smile teasing and unreadable; silver-blue moonlight",
    "c4_mangshan": "dawn on Mount Mang north of Luoyang, mist below: Dong Bai (adult, silver ponytail, purple fur-trimmed riding armor) on a chestnut horse glancing back with red ears after a quick kiss, galloping downhill; the hero on his horse behind her touching his cheek, stunned; the grey city far below in the sunrise",
    "c5_chuxi": "New Year's Eve on the highest roof of the chancellor's mansion in Chang'an: Dong Bai (adult) asleep on the hero's shoulder with half a burnt flatbread in her hand, the hero sitting still and not daring to look down; below, the city glowing with bonfires of crackling bamboo, snow on the tiles",
    "c4_xizi": "lamplight inside a small army tent at night: Cai Wenji (adult, in white) guiding the hero's hand over a brush, her hand over his, both leaning over a sheet of paper with wobbly characters; soft warm glow, tender and shy",
    "c5_snow": "a snowy back veranda of a scholar's house at night: Cai Wenji (adult, in white) playing a guqin on her knees with snow settling on the strings, the hero sitting beside her in a red wedding robe she has just fitted on him; lantern glow, quiet and bittersweet",
    "c7_stars": "a grassy hilltop above an army camp on a summer night under a sky full of low stars: Cai Wenji (adult, in white) playing a guqin across her knees, the short-haired hero lying back in the grass listening",
    "c4_zhujun": "Sun Jian's camp in the ruins of Luoyang: the veteran general Zhu Jun (grey-bearded, straight-backed, hearty laugh) slapping the huge Sun Jian on the shoulder, Sun Jian bowing formally for once; Sun Ce behind them red-faced trying not to laugh",
    "c6_yizu": "the palace steps of Chang'an the day after Dong Zhuo's death: Dong Bai (adult) kneeling numbly on the stone, the short-haired hero standing in front of her with his blade half drawn, the white-haired Huangfu Song stepping to his side; high above, the small boy emperor clutching a pillar",
    "c6_warn": "night at a window in Chang'an: Diaochan (adult) in a black cloak, pale but smiling, leaning in at the hero's window by candlelight; the hero has a short black buzz cut and wears plain everyday robes (no armor, at home at night), hands empty, no blade anywhere; only these two people, no one else in the frame",
    "c4_siege": "before dawn, torches around a scholar's house in Chang'an: the elderly Cai Yong being led away without resisting, looking back; Cai Wenji (adult, in white) reaching after him, held back by the short-haired hero",
    "c4_dongjia": "a ruined roadside shrine at dawn: the door kicked open, Dong Bai (adult) standing in the doorway with her twin hammers, grey-haired veterans only as silhouettes behind her; the hero looking up from the straw",
    "c7_neiying": "a dark corner at the foot of the city wall at night: a middle-aged Jiangdong veteran soldier with half of one ear missing has crawled out of a dog hole and kneels in front of the hero, his face drained of colour, shoulders shaking; Huang Zhong (middle-aged, stout, bow in hand) stands at the tent flap pointing out the lie and then crouches to take the veteran's coat; Zhou Yu (teen, holding an account book) stares, startled; torches on the wall above, mud and rain",
    "c7_feng": "a lamplit army tent at night: the beautiful Lady Feng (adult) pouring wine for the hero and resting her fingertips on his wrist; at the tent flap Dong Bai (adult) slamming a hammer down and Cai Wenji (adult, in white) with a snapped zither string, both glaring",
    "c6_jiaxu": "an abandoned Xiliang camp on the Wei river after a battle: the thin, sleepy-eyed strategist Jia Xu (mid-40s, loose faded officer's robe, gourd flask at his belt) tied up with rope and lounging comfortably on sacks in a grain cart, still sniffing a wine gourd; young Sun Ce, who just tied him, holding the rope end with a spear on his shoulder; the short-haired hero studying him; Zhou Yu frowning over his ledger; comic",
    "c8_xuexi": "the wall of Xiangyang in grey rain at dawn, the city below silent with gates shut: the short-haired hero standing stiff and blank-eyed in battered silver armor; Dong Bai (adult) standing before him, trembling but not stepping back, saying something bitter; behind them young Sun Ce pale and afraid; restrained and bleak, no gore, no bodies",
    "c8_fubing": "the plank-road of the lakeside pavilion in torchlight and smoke: a wall of Cai household soldiers in black-and-purple livery surging out of the corridors with shields; Sun Ce (teen general) charging in front with his spear, Dong Bai (adult, silver ponytail, twin hammers) smashing a table beside him; the hero in his signature bronze-and-gold cloud-patterned armour with a black cape over a red robe, empty hands, no weapons",
    "c8_qibing": "the long stone causeway over the Han river at night: Cai household cavalry thundering along it in black-and-purple cloaks; at the near end Huang Zhong (middle-aged, stout, yellow leather armour with a blue war-robe, bow drawn full) picking riders off their horses; the hero in his signature bronze-and-gold cloud-patterned armour with a black cape over a red robe watching, no weapon in hand",
    "c8_caihe": "a lamplit upper gallery of the lakeside pavilion: Cai He (adult warrior in black-and-purple Cai livery, holding a signal flag in one hand and a repeating crossbow in the other) shouting as rows of crossbows are levelled through the lattice windows behind him; below, the hero in his signature bronze-and-gold cloud-patterned armour with a black cape over a red robe with empty hands looks up, Sun Ce beside him lifting his spear",
    "c8_zhangyun": "a river pier at night: a line of Jingzhou war-boats with torches against the pier; on the lead bow Zhang Yun (red-faced, bloated eyes, purple-brown brocade robe over half-armour, a bronze wine flask and a ring of keys at his belt) speaking with a smirk to the hero, who stands in the hero in his signature bronze-and-gold cloud-patterned armour with a black cape over a red robe, empty hands, Sun Ce and Huang Zhong at his sides; marines behind Zhang Yun with drawn blades",
    "c8_eve": "a lamplit window of the Xiangyang guesthouse at night: Diaochan (adult, in a pale-jade fairy skirt) tying a clumsy hand-sewn sachet to the hero's belt, her ears flushed red, a sewing basket with a half-finished piece on the table, dried osmanthus petals scattered; the hero in plain everyday robes with short hair looking down at her; warm lamp-glow, autumn night outside the paper window",
    "c8_qinggong": "the victory banquet in Wancheng, lanterns and banners: Sun Ce (teen general) standing on a table raising a bowl and shouting, Zhou Yu rubbing his temples, the hero grinning with a bowl; in the foreground Diaochan (adult, pale-jade fairy skirt) pouring a full cup of wine for the hero without spilling a drop",
    "c8_yiguan": "the kitchen window of the Xiangyang guesthouse in the afternoon: Madam Wu (the kind Sun family matriarch) stirring a pot of bream soup; at the window Diaochan (adult) trying on a new pale-jade fairy skirt and twirling; steam, warm light, a sealed invitation card lying on the table",
    "c8_zupu": "the steps of the Xiangyang governor's mansion in the morning: a row of white-bearded Cai clan elders kneeling, the eldest striking a name out of an open clan genealogy with a brush; the pale, long-bearded scholar Liu Biao hurrying up with his official cap askew, sweating; Zhou Yu reading a long list of offered troops and money with shining eyes; the hero in his signature bronze-and-gold cloud-patterned armour with a black cape over a red robe, looking on unimpressed with empty hands; NO swords, broadswords or weapons anywhere in the picture, none on his back or shoulder; the kneelers are only the elderly Cai clan elders in a neat row, not soldiers or prisoners; a little comic",
    "c6_jiaxu_join": "an evening in a Luoyang house: the thin, sleepy-eyed strategist Jia Xu (mid-40s, loose faded robe, gourd flask at his belt) at a table with the first bowl of red-braised pork, sniffing a cup of wine the short-haired hero has just poured him with a respectful bow; Lady Wu (adult) setting down more dishes; young Sun Ce staring at the pork, not daring to reach; warm and comic",
    "c8_nushou": "水阁里火墙冲天、浓烟滚滚，帘后的连弩手在烟中乱射：董白（成年，银白高马尾、紫色毛边铠甲）双锤抡着，把一张翻倒的案几砸成两截当盾牌；蔡文姬（成年，白衣）半跪着一手搂着脸色苍白的貂蝉（成年，浅碧留仙裙，裙摆沾着烟灰）、一手横着断弦的琴挡箭；短发的主角（青金色铠甲）持刀冲在最前面",
    "c8_zhashan": "水阁栈道口，被撞飞的千斤闸砸在地上、尘土飞扬：孙策（少年将军，持长枪）一枪挑飞门口的死士，站在缺口中央；黄忠（四十出头，黄皮甲蓝战袍）半跪在后面开弓搭箭；水阁深处，独眼流血的蔡瑁（魁梧，锦袍罩鎏金鳞甲）捂着右眼，被逼到栏杆边拔剑",
    "c8_lanshang": "月下的水阁栏杆边，案几翻倒、酒菜洒了一地：蔡瑁（魁梧，锦袍罩鎏金鳞甲）拔剑背靠栏杆，面容扭曲，身后是漆黑的汉江；帘后所有连弩的箭尖齐刷刷对准了他；贾诩（四十多岁，清瘦蜡黄）站在短发主角（青金色铠甲）身后，神情平静",
    "c2_luoyang_fire": "夜里的洛阳城在烈焰中崩塌：宫阙、城楼与街巷烧成一片火海，烧断的梁木带着火星坠落，浓烟遮住半边星空；城外远处是联军营地的篝火。画面中可以完全没有人物（南北线通用，不画主角和随行人物；若要有人，只能是远处看不清脸的剪影）",
    "c5_caiyong": "傍晚长安城东蔡府的小院，石桌上摆着酒壶与酒杯，一卷展开的石经拓片压在灯下：须发花白、气度儒雅的蔡邕（老年学者，深色儒袍）手按拓片，正无奈地看着面前的人；短发、穿便服的主角指着拓片上的一个字，一脸认真又满脸茫然；蔡文姬（成年，白衣）站在父亲身后用袖子掩着半张脸，忍着笑；董白（成年，银白高马尾、紫色毛边外衣）抱着双锤靠在院门边，一脸不耐烦地看向这边",
    "c5_wangyun": "夜里长安司徒府书房，烛火摇曳，房门刚被关上：清瘦的王允（老年，白发梳得一丝不乱，深色官袍）背对着门转过身来，脸上还挂着慈祥的笑，眼神却像商人在估价一样冷冷地打量着对面；短发、穿便服的主角站在案前，一手比划着，神情既认真又有点得意；蔡邕（老年学者）站在旁边一手捂着胸口、脸色发白，像随时要晕过去；案几上的茶杯刚被重重放下，茶水溅出一点",
    "c6_sneak": "夜里长安宫城的北掖门后，一条窄窄的回廊，灯笼昏黄：清瘦的荀攸（青年，文士袍）提着一盏灯在前面带路，另一手竖指按唇；十岁的小皇帝（穿着便服，抱着一个小包袱）被短发的主角（青金色铠甲）牵着手，踮着脚尖往外溜；回廊尽头的门缝外，隐约可见一队御林军的火把正在换岗，人影映在窗纸上",
    "c6_ruin": "清晨的洛阳废墟：烧黑的宫殿石柱和断梁横在地上，街边塌顶的铺子里野草齐腰；十岁的小皇帝（便服）站在一堵断墙前仰头看着，高大的孙坚（虎皮披风）立在他身后半步；孙策指着一处塌了半边的门洞比划；远处太学废墟里，蔡邕（老者）拄杖摸着一块烧裂的石碑，蔡文姬（成年，白衣）扶着他；晨光穿过焦黑的梁木，天空还带着烟色",
    "c6_rebuild": "洛阳重建的白天：江东兵脱了甲抡镐清街，孙策（少年将军）扛着巨大的房梁大喊，周瑜在后面追着记账；董白（成年，银白高马尾）叉腰站在垒了一半的砖墙上嫌弃地指点，飞熊老兵在她身后码砖；街口吴夫人架起大锅施粥，貂蝉（成年）笑着盛粥；角落里蔡文姬在屋檐下教一群孩子认字；画面前景，十岁的小皇帝吃力地抱着一块砖，摇摇晃晃，旁边孙坚伸着手不敢扶",
    "c8_laixi": "夜里宛城太守府的议事厅，烛火通明，一张摊开淯水地形的大沙盘上插满红蓝小旗：清瘦苍白的中年谋士荀攸（三十多岁，素色长袍）一手把一枚黑棋按在淯水北岸，神情平静；周瑜（青年，手里捏着账本）站在沙盘另一侧点头；黄忠（四十出头的精壮军汉，方脸短须、目光沉稳，黄皮甲外罩蓝战袍、独角兽铜兽首护肩，不是白发老人）擦着一张大弓；短发、穿青金色铠甲的主角抱臂站在沙盘旁，一脸「你们说了算」的表情",
    "c8_zhaoshu": "宛城太守府正堂，白天：荆州从事蒯越（四十出头，短须整齐，浅灰儒服、黑色儒冠）刚进门，客气地深深一揖，目光却越过手捧圣旨的天使，落在主角身上；周瑜（青年，抱着账本）站在主角身侧小声耳语；短发、穿青金色铠甲的主角一脸茫然地听着诏书",
    "c8_jinggao": "出发前一夜宛城书房，烛火摇曳：周瑜（青年）把账本「啪」地合上，神情严肃地竖起一根手指；短发的主角把孙坚的古锭大刀扛在肩上；孙策（少年将军）兴奋地一拍胸口、嘴巴张得老大；门口，貂蝉（成年，浅碧留仙裙）扶着门框微笑，眼神却很认真",
    "c8_mimou": "襄阳蔡府后堂夜里，灯下：蔡瑁（二十五六岁，魁梧、短髭方下巴，锦袍罩鎏金鳞甲）一脚踢翻案几，满脸骄横；姐姐蔡夫人（成年，紫色金线锦衣、凤钗）坐着不慌不忙地剥一颗枇杷，嘴角带笑；窗外是黑沉沉的汉江",
    "c8_plan_xun": "夜里宛城议事厅的沙盘前：荀攸（三十多岁，清瘦文士，深蓝儒服）把一枚黑色棋子轻轻放进主角摊开的手心；主角（短发、青金色铠甲）低头看着棋子；旁边周瑜（青年）捏着账本在记一笔",
    "c8_plan_huang": "清晨宛城校场，箭靶旁：黄忠（四十出头，精壮军汉，黄皮甲蓝战袍、独角兽铜兽首护肩）把一支雕着小字的令箭拍在主角手里；孙策（少年将军）凑过去探头，被黄忠斜眼瞪着；主角（短发、青金色铠甲）掂着令箭",
    "c8_meng": "天未亮的宛城客房，一盏油灯：光着脚、只穿中衣的短发主角满头冷汗地站在门口，指尖还在发抖；贾诩（四十多岁，清瘦蜡黄）坐在灯下，正把一只酒杯凑近鼻子闻，抬眼看着他的光脚，似笑非笑",
    "c8_dingce": "夜里宛城书房的案几前：贾诩（四十多岁，清瘦蜡黄，眯着眼）用手指蘸着茶水，在案上写下「蔡」「蒯」两个湿漉漉的字；手边放着一份请柬；短发的主角穿一身素色常服（青金色滚边的深色便袍，不穿盔甲），双手空着、身边没有任何刀剑兵器，盯着那两个字，若有所思",
    "c8_kuaiyue": "三更天蒯府后院的书房，一盏孤灯：蒯越（四十出头，浅灰儒服）披着外衣坐在灯下，站起身朝主角深深一揖；便服的主角（短发）站在门口；贾诩（四十多岁，清瘦蜡黄）侧立在一旁，把请柬放在案上",
    "c8_jiayan": "a family supper in the courtyard of the Wancheng governor's house on an autumn evening: Lady Wu (adult) handing the short-haired hero a big bowl of chicken soup and ruffling his cropped hair; Sun Ce hanging over the edge of the pot trying to snatch meat; warm lantern light",
    "c8_liuxian": "the bank of the Yu river at sunset: Diaochan (adult, of great beauty) in a light pale-jade southern 'liuxian' skirt sitting hugging her knees on the grass, laughing with her hand over her mouth; in the shallows Sun Ce slipping while grabbing at a fish; Zhou Yu on a rock writing in his ledger",
    "c8_caifuren": "a lavish welcome banquet in Xiangyang: Lady Cai (adult, purple gold-embroidered silks, phoenix hairpin) holding Cai Wenji's (adult, in white) hands over an open clan genealogy book, all warm smiles; beside them Diaochan (adult) accepting a box of pearls with an equally sweet smile; the elderly scholar Cai Yong stroking his beard sceptically in the background",
    "c8_shuige": "a lavish pavilion over the Han river, the only door sealed by a fallen iron portcullis, crossbowmen behind the curtains: Diaochan (adult) in a pale-jade skirt draining a gold beast-shaped wine cup before the burly Cai Mao, her other hand already reaching for the hairpin in her hair; the short-haired hero in his signature bronze-and-gold armour half-rising from his seat with EMPTY hands, one arm stretched out towards her, shouting, NO sword, sabre or broadsword in his hands or anywhere on him or in the picture; tense, no gore",
    "c8_xiangxiao": "the smoking ruin of a pavilion on a rock above the Han river at dawn: the short-haired hero kneeling, holding Diaochan (adult, pale, in a scorched pale-jade skirt) in his arms; she smiles faintly and touches his cropped hair; restrained and elegiac, no gore",
    "c8_henhai": "a cold rainy night on the bank of the Han river: the short-haired hero alone, crouching at the water's edge washing a pale-jade woman's skirt, holding half of a broken hairpin; behind him in the rain a young man in white mourning clothes stepping closer; bleak, restrained, no gore",
    "c8_dress": "a bedroom in the Xiangyang guesthouse in the afternoon: Diaochan (adult) at a bronze mirror in her most beautiful pale-jade skirt embroidered with water patterns; Lady Wu (adult) pinning her hair; the short-haired hero crouching beside her tucking a strand of hair behind her ear; gentle and warm",
    "c8_grapes": "a lamplit banquet pavilion over the Han river: Diaochan (adult, pale-jade skirt) had risen and started toward the burly Cai Mao, one hand already at the hairpin in her hair, ready to drink the poison for the hero — and the short-haired hero has caught her by the waist and pulled her back into his arms, his other hand sweeping a gold beast-shaped wine cup away across the table and pressing a mandarin orange into her hand; she looks up at him, startled; across the table Cai Mao going green in the face; tense and tender",
    "c8_louchuan": "the bow of a great tiered warship on the moonlit Han river, fishing lights receding along both banks: Diaochan (adult) in a pale-jade skirt fluttering in the wind leaning lightly on the short-haired hero's shoulder, their fingers interlaced; in her other hand a small paper packet of hot roasted chestnuts, one half-peeled; a huge full moon over the river, silver ripples; tender, romantic, quiet",
    "end_henhai": "an ending card illustration, quiet and symbolic: half of a broken jade hairpin and a folded pale-jade silk skirt lying on wet pebbles at the edge of the Han river at night, cold rain on the water, a distant pavilion on a rock burnt black; muted colours, no people, no blood",
    "c7_flee": "the east gate of Wancheng in a cloud of dust: Lady Feng (adult) lifting the curtain of her palanquin as it hurries away behind a few loaded carts and glancing back with a faint smile; the hero watching from the captured wall under a 孙 banner",
    "end_yusui": "an ending card illustration, quiet and symbolic: the Imperial Jade Seal broken into pieces on a wet grey stone by a rainy mountain road, its gold-mended corner lying in the mud, a woman's hairpin beside it; cold rain, muted colours, no people",
    "end_tonggui": "an ending card illustration, quiet and symbolic: three sets of footprints side by side in fresh snow before the closed Xuanping Gate of Chang'an at dawn, a pair of notched bronze hammers and a broken guqin lying together in the snow; soft falling snow, muted colours, no people, no blood",
    "c4_tonggui": "dawn in falling snow before the closed Xuanping Gate of Chang'an, seen from behind: the short-haired hero in battered silver armor, Dong Bai (adult) with her notched twin hammers on his left, Cai Wenji (adult, in white) holding a broken guqin on his right, the three holding hands and stepping forward together; restrained and elegiac, no gore",
    "c6_fenghou": "the throne hall in Chang'an: the ten-year-old boy emperor leaning forward on a huge throne, insisting in a trembling voice; below him the white-haired Wang Yun bowing with a smile that doesn't reach his eyes",
    "c6_xunyou": "a dim Han-dynasty prison cell in Chang'an, the iron door just swung open and torchlight pouring in: the lean, pale scholar Xun You (thirties, plain robe) sitting cross-legged on straw playing a go game alone on a board scratched on a stone slab, calmly looking up; the hero in bronze-gilt armor holding a torch in the doorway, jailers sprawled behind him",
    "c6_escape": "night escape from Chang'an: a covered carriage racing through a burning city gate, the boy emperor peeking out clutching a small bundle; Dong Bai (adult) riding alongside with her twin hammers; the hero riding on the other side with Diaochan (adult) behind his saddle",
    "c6_huihe": "the restored gate of Luoyang at dawn: the huge Sun Jian in his tiger-pelt cape kneeling on one knee in the dust before the small boy emperor stepping down from a battered carriage",
    "c6_seal": "a makeshift throne hall in half-ruined Luoyang: the boy emperor on a simple throne asking quietly; the huge Sun Jian bowing with a calm face while his hand hanging at his side is clenched white, no box anywhere in the hall; Zhou Yu writing in his ledger with lowered eyes; Lady Wu (adult) watching Sun Jian anxiously from the back",
    "c7_huangzhong": "a captured camp in Nanyang: Huang Zhong, a sturdy man in his 40s in rough soldier's clothes, rope marks on his wrists, drawing a heavy bow to full; his arrow snapping the banner pole of a big red flag on the far camp gate — the flag bears exactly ONE huge, clear, correctly written black Chinese character 袁 (Yuan) and no other text; Sun Ce gaping, the hero grinning",
    "c5_garden": "behind a rockery in the palace garden of Chang'an: the ten-year-old boy emperor, his heavy bead-curtained crown taken off and set on a stone, rubbing his neck and looking up hopefully at the short-haired hero in silver armor, who crouches to his eye level; a eunuch keeps watch at the corner; a gentle, melancholy mood",
    "c5_feast": "a lavish welcome feast in Dong Zhuo's mansion: the enormous Dong Zhuo peeling shrimp for his granddaughter Dong Bai (adult), who laughs with her mouth full; he wipes his eye with his sleeve",
    "c5_dance": "a lantern-lit banquet hall: Diaochan, an adult woman of great beauty, dancing with long silk sleeves; the enormous Dong Zhuo leaning forward spellbound with wine in his beard; Wang Yun at the host's seat with a knowing half-smile",
    "c5_fengyi": "the Phoenix Pavilion in a lotus garden: Diaochan (adult) weeping on Lü Bu's shoulder at the railing; behind them the furious Dong Zhuo hurling Lü Bu's halberd; Lü Bu twisting away; Diaochan's eyes glancing sideways toward the viewer with the ghost of a smile",
    "c5_rescue": "a long street at night: Lü Bu on the rearing Red Hare charging in with his halberd, Diaochan (adult) holding on behind his saddle with bloodied hands, shouting",
    "c4_wenji": "night by a campfire in ruined Luoyang: Cai Wenji, an adult woman in white, holding her guqin with a broken string, telling her story; Dong Bai listening with folded arms, Lady Wu wrapping a cloak around Cai Wenji",
    "c4_peace": "Sun Jian's tent in ruined Luoyang: the envoy Li Ru waving a feather fan and offering peace with a gentle smile; the huge Sun Jian sitting with crossed arms, scowling",
    "c4_betroth": "a comedic betrothal in a tent: the short-haired hero pointing at himself in disbelief; Dong Bai (adult) beside him looking away with bright red ears; Sun Ce leaping up in refusal; Lady Wu (adult) laughing behind her sleeve",
    "c5_enter": "the gates of Chang'an: the enormous Dong Zhuo hugging his granddaughter Dong Bai (adult), who laughs; over her shoulder his smiling eyes are cold; behind him Lü Bu on Red Hare, silent",
    "c5_diaochan": "a moonlit garden: Diaochan, an adult woman of great beauty, kneeling before an incense burner praying to the moon; Wang Yun and the hero watching from the garden gate",
    "c5_dress": "a bedroom in Chang'an: Dong Bai (adult) in a red wedding dress turning happily before a bronze mirror, the hero behind her with a troubled face",
    "c5_wedding": "the wedding trap in a hall of red lanterns: the enormous Dong Zhuo raising his cup with a cruel smile; beside him Dong Bai (adult) in a red wedding dress lifting her veil in shock, the hero pulling her behind him",
    "c5_death": "the moment of mercy, restrained: Dong Bai (adult) in her red wedding dress kneeling with her arms spread wide to shield a fallen figure on the palace steps, looking up at Lü Bu towering on Red Hare with his halberd raised; no gore",
    "c3_feng": "a quiet veranda in Luyang: Lady Wu sewing a winter coat and the beautiful Lady Feng embroidering a handkerchief side by side, laughing over a plate of pastries — Lady Feng's eyes sliding toward a brocade box half-hidden inside",
    "c2_heqin": "a tense army tent: Sun Jian kicking over a marriage-proposal gift box and driving his saber into the table, the envoy Li Jue backing away with a forced smile, young Sun Ce pale with shock, Zhou Yu watching calmly; outside the tent flap a carriage curtain slightly lifted",
    "c2_mixin": "night after a battle: Zhou Yu reading a captured secret letter by torchlight, Sun Jian crushing its edge in his fist, far on the horizon the sky over Luoyang faintly red",
    "c3_leave": "leaving the ruins of burning Luoyang: Sun Jian riding in front hugging a brocade box; Lady Wu (adult) leaning from a carriage to hand bread to a child; a long column of refugees trudging behind them",
    "c3_wenji": "on a muddy road after a fight: Cai Wenji, an adult woman in a white robe, kneeling to pick up her guqin with a broken string, Dong Bai with her twin hammers looking away embarrassed, Lady Wu putting a cloak on Cai Wenji's shoulders",
    "c3_supply": "night in a hungry army camp: Sun Jian alone by a campfire opening and closing a brocade box, Zhou Yu counting on his fingers, Sun Ce hiding his rice bowl behind his back",
    "c3_slip": "a lively tavern full of drinkers: a tipsy Sun Ce slamming the table and bragging, Zhou Yu lunging to cover his mouth, the hero tossing coins on the table; at the next table soldiers in Yuan livery freezing mid-bite",
    "c3_entrust": "lamplit room at night: Sun Jian placing the brocade box with the jade seal into Lady Wu's hands, the hero standing at the doorway, Sun Jian gruffly avoiding his eyes",
    "c3_warn": "the night before the campaign: the hero earnestly pleading with Sun Jian, who laughs and claps him hard on the shoulder, a war banner and armor stand behind them",
    "c3_raid": "a rainy night at a courtyard gate lit by torches: the grey-bearded general Chen Lan with a long spear under a 袁 banner; the short-haired hero barring the way, Lady Wu (adult) behind him clutching a brocade box",
    "c3_news": "a rainy mountain pass: the defeated general Ji Ling kneeling in the mud, leaning on his three-pointed blade; Lady Wu (adult) slowly sinking to her knees in the rain",
    "c3_end": "a restrained tragic scene in the rain on a mountain road: Lady Wu (adult) standing tall and calm, lifting the Imperial Jade Seal high over a grey stone, her face serene; Yuan Shu's golden-roofed carriage only a blur in the background; no gore",
    "c1_wake": "a beautiful mature noblewoman (Lady Wu, adult) leaning over a young man with short modern hair lying in an embroidered bed, pressing a damp cloth on his forehead, lanterns, incense smoke, soft light",
    "c1_bandage": "Lady Wu sitting on the bed rewrapping a bandage on the young man's thigh, a tray with medicine and bandage rolls, the young man bright red with embarrassment, morning light (comedic, non-explicit)",
    "c1_village": "a village courtyard: a bold, thick-browed young man (Sun Ce) grinning as he points a spear right at the hero's nose, while a refined young man with a feather fan (Zhou Yu) looks on with a shrewd, appraising half-smile, a small ledger tucked in his sleeve",
    "c1_raid": "a night raid: the grinning bandit chief Hu Yu with a headband holding up a torch, the gate of 富春山庄 in flames, river bandits and Yellow Turban men charging with tridents and sabers, a line of torch-lit boats on the river",
    "c1_rescue": "inside a river fortress: the young man holding Lady Wu's hands after untying her ropes from a pillar, Sun Ce coughing loudly behind them",
    "c1_dinner": "a warm family dinner: the young man pretending to be drunk with his head on Lady Wu's lap, Sun Ce snapping his chopsticks in two, Zhou Yu hiding a laugh (comedic)",
    "c1_armor": "Lady Wu fastening the straps of Sun Jian's old silver tiger-engraved armor on the hero, a black cape trimmed with white fur, and a tiger pelt sewn in as the armor skirt's lining, beside an opened camphor chest, Sun Ce gaping at the doorway, Zhou Yu with his ledger",
    "c1_oath": "three young men (the hero, Sun Ce, Zhou Yu) kneeling on a riverbank swearing brotherhood, three chopsticks stuck in the ground as incense, sunset over the river",
    "c1_north": "farewell at the village gate: Lady Wu hugging the young man goodbye, Sun Ce grinding his teeth, a bundle of hand-sewn clothes with a little tiger embroidered on it",
    "c2_zumao": "a battlefield: the veteran Zu Mao wearing a red headscarf being chased by the giant Hua Xiong, the young Sun Ce charging in with a spear",
    "c2_capture": "the hero carrying the unconscious woman general Dong Bai over his shoulder like a sack of rice, Sun Ce and Zhou Yu each struggling to carry one of her giant bronze hammers (comedic)",
    "c2_captive": "inside a prisoner tent: the woman general Dong Bai, an adult woman with her arms loosely tied, playing rock-paper-scissors against the hero, her hand a split second late, a half-eaten bowl of braised pork beside her, Sun Ce peeking in enviously through the tent flap (comedic)",
    "c2_raid": "a burning army camp at night: Sun Jian alone blocking the camp gate with his sword against Lü Bu on the red horse Red Hare",
    "c2_sanying": "the legendary three heroes fighting Lü Bu in a storm of dust: Lü Bu on the rearing red horse Red Hare parrying with his crescent halberd, Guan Yu with the green-dragon crescent blade, Zhang Fei thrusting the serpent spear, Liu Bei with twin swords, sparks flying where the blades meet; in the foreground the onlookers frozen in awe — the hero sitting in the dust, Sun Ce gaping with his spear trembling, Zhou Yu's ledger fallen at his feet, Sun Jian with his arm in a sling narrowing his eyes, and the woman general Dong Bai (adult) tied across a horse staring wide-eyed",
    "c2_setout": "setting off north on a country road: Sun Ce on a brown horse galloping ahead the wrong way; the short-haired hero and Zhou Yu on horseback exchanging a look and a smile; a covered carriage behind them",
    "c2_zumao_saved": "a battlefield: the hero hurling a huge broad saber that strikes the giant Hua Xiong on the back of his helmet; the veteran Zu Mao in a red headscarf falling from his horse, saved",
    "c2_counter": "Sun Jian's camp: the burly Sun Jian hugging Lady Wu while glaring at the hero over her shoulder; the hero grinning awkwardly",
    "c2_keep": "inside a carved carriage: Lady Wu gently combing the hair of the captured woman general Dong Bai, who sits stiff-necked with reddened eyes, the hero peeking in at the curtain",
    "c2_handover": "a restrained, somber scene: the woman general Dong Bai in a prisoner cart looking back over her shoulder, the hero standing alone at the camp gate, grey sky (no gore)",
    "c2_triple": "a lavish allied lords' banquet: warlords crowding around the hero with wine cups, Yuan Shao giving up his seat, Sun Jian clapping the hero on the shoulder, Lady Wu watching from the side",
    "c2_dongbai_join": "a burning Luoyang street at night: the woman general Dong Bai striding toward the hero with her two giant bronze hammers, a line of Xiliang female cavalry guards kneeling behind her, ruined houses and refugees",
    "e_tangji": "a ruined temple: Lady Tang, an adult woman in coarse clothes with soot on her cheek, clutching a jade hairpin, looking up with unyielding eyes as the hero and Lady Wu find her",
    "e_yazhai": "a mountain bandit fort: the curvy bandit queen 'Rouge Tiger' standing hands on hips on the fort wall with twin sabers, pointing at the embarrassed hero, her chubby husband carrying a pig behind her (comedic)",
    "c2_yuxi": "burning Luoyang at night: Sun Jian by a well holding up the glowing Imperial Jade Seal, his face lit by five-colored light, his eyes turning ambitious",
    "i1_sewing": "night by lamplight: Lady Wu sewing a winter coat, the young man sitting beside her, Sun Ce sulking outside the window",
    "i2_yuxi": "night on a river boat: Sun Jian hugging a brocade box at the bow, Lady Wu standing at the cabin door holding a late-night snack",
    "i2_duel": "sunset riverbank: Dong Bai and Sun Ce collapsed on the ground laughing after a long duel, hammers and spear dropped beside them",
    "i2_qin": "night on the stern of a boat: Lady Tang playing a guqin, Lady Wu draping a coat over her shoulders",
    "jz_wake": "铺着厚毛毡的甄府暖阁，窗外飞雪：张夫人端着药碗俯身探试主角额头体温，烛光摇曳",
    "jz_county": "邺城州衙公堂石阶前：郭图高踞台阶手持文书冷笑，挥手令衙役驱赶；赵云护着满身尘土的常山受灾乡民，横枪挺进、枪尖直指衙役，韩馥缩在柱后瑟瑟发抖",
    "jz_guojia": "邺城飘雪街头青布酒旗下：郭嘉斜倚着酒旗木柱打量主角，赵云单膝跪地抱拳，背景是冀州治所邺城",
    "jz_ambush": "雪地峡谷：玄机子纵马掠走甄宓，李大目和张白骑率众悍匪从山崖上狂暴杀出",
    "jz_ledger": "甄府账房：张夫人将半副大账本递给主角，十多岁的甄宓探头扒着桌角偷看，手里攥着点心",
    "jz_rescue": "血色祭坛洞窟前：赵云亮银枪如龙直挑玄机子，甄宓被绑在石柱上惊叫挣扎",
    "jz_boss": "黑山贼寨门前：主角横起白蜡杆长枪狼狈架住李大目沉重巨斧，赵云回枪蓄势直刺李大目咽喉，身后寨墙火光冲天",
    "c2_ln_meet": "a frozen dirt road near the Yellow River: the red-armored girl Lu Lingqi falling from her horse in tears, Zhao Yun's silver spear at her throat, the hero blocking the spear with his own just in time",
    "c2_ln_sponsor": "outside the Suanzao allied camp: Guo Jia drunkenly writing 'Zhongshan Zhen' on a huge red banner, the hero standing by proudly; in the background, dozens of carts of sheep and wine covered in red silk",
    "c2_ln_caocao": "outside a military tent in Suanzao: the short-statured Cao Cao slamming a table with red eyes in anger, turning to look at the exasperated hero to borrow grain",
    "c2_ln_bianshui": "the chaos of battle by the Bian river: Cao Cao exhausted and wounded by an arrow, Cao Hong offering him a horse, while the hero appears smiling with two large Changshan warhorses",
    "ln_camp": "夜里的马车内：主角用烈酒给吕玲绮腕上的伤口正骨包扎，张夫人掀帘探头满眼心疼，小甄宓踮脚递来一块热栗子糕",
    "ln_handhold": "虎牢关下夜袭的火光里，车厢帘缝之间：主角反手握紧吕玲绮冰凉发抖的手，十指相扣，她低着头没再看向帘外",
    "jz_end": "大雪官道上：主角身披鱼鳞甲与雪白貂裘、手握白蜡杆长枪居中，赵云银甲白马在左，郭嘉车中抿酒在右，张夫人怀抱账本骑矮脚马跟在队伍中，身后铁骑义勇新军相随",
    "c9_letter": "襄阳府中冬夜的灯下：吴夫人（成年女性，温柔慈和的中年贵妇）手捧一封字迹又大又歪的家书，看着看着笑了；少年将军孙策探头凑过来想看，周瑜站在一旁，手里的账本合着；窗外汉江上停着荆州水师的战船",
    "c9_changsha": "长沙郡守府门口的春日傍晚：吴夫人（成年女性，温柔慈和的中年贵妇，素色衣裙，手里一把油纸伞靠在门边）伸手轻轻摸着门口旧柱子上一排刀刻的身高印子，眼眶微红却带着笑；少年将军孙策站在柱子另一边，耳朵尖通红、窘迫地别过脸；主角站在她身后半步，抬手挠着自己的短发，一脸想笑又不敢笑；院里一棵老槐树，花瓣飘落；暖黄夕光，怀旧温柔；画面里没有兵器、没有士兵，主角不扛刀",
    "c9_zhoujia": "the gate of the Zhou clan manor in Shu county after a three-day siege, the gate flung open: white-haired Zhou clan elders stumbling out in tears; the stately old Lady Zhou (Zhou Yu's mother) holding the hero's hand and looking him up and down; Zhou Yu (young man in scholar robes) standing behind with an account book under his arm, a little embarrassed; a clansman presenting the family genealogy scroll whose last bamboo slip is freshly cut; boats and a granary behind the walls, besiegers' abandoned banners on the ground; the hero in plain everyday robes",
    "c9_chenwu": "the gate of Wan city at dawn swinging wide open: Chen Wu (burly Lujiang conscript in his 30s, rough patched armour, a broken saber in hand) grinning among a few dozen villagers in ragged army coats; the hero (short hair, teal-gold armour) and Sun Ce (teen general) striding in through the gate, morning light, Liu Xun's banners torn down",
    "c9_huafang": "a painted pleasure-boat on the river at dusk: Da Qiao (adult, elegant) playing the guqin; Sun Ce (teen general) sitting stock still, utterly absorbed, his wine bowl overturned over Old Qiao who is wiping his beard and smiling; at the stern Xiao Qiao (adult, lively) showing Zhou Yu how to dry a soaked account book while he listens more seriously than in battle; the hero in armour at the side, a hand over his face",
    "c9_kaicang": "the gate of Wan city in the afternoon: carts of bundled land contracts burning in a huge bonfire, peasants kneeling in rows with tears on their faces, silk-robed gentry standing silent at the edge; the hero (short hair, teal-gold armour) watching the fire; Zhou Yu frowning, Old Qiao sighing",
    "c9_jibao": "night: Wan city burning in the distance; a blood-covered old servant of the Qiao family collapsing before the hero's tent; Sun Ce frozen with his spear fallen to the ground, its red tassel missing; Zhou Yu clutching an oilcloth-wrapped account book with white knuckles; the hero in armour",
    "c9_chengtou": "a moonlit city wall: Sun Ce (teen general, ears red) holding out the red tassel torn from his spear to Da Qiao (adult, gentle) who is tying it around her wrist; below in a lamp-lit nook Xiao Qiao (adult, lively) stitching an oilcloth cover for Zhou Yu's account book while he watches wordlessly; in the distance the hero pretending to look at the moon",
    "c9_granary": "舒县周家的大粮仓前，仓门上贴着黄色的「仲」字封条；周瑜（二十出头，俊秀书生气的年轻将军）背对众人站在仓门前，手里的账本第一次合着；主角和孙策站在他身后不远处；远处是被搜刮一空的庄子",
    "c9_luxun": "舒城陆家旧宅，半边院墙被火烧得焦黑；门槛上坐着一个十四五岁的少年陆逊（清瘦的孩子，衣衫朴素，只画孩子该有的样子），一言不发地望着江上的荆州战船；门边停着一车粮食；远处船头，主角回头望着他",
    "c9_lusu": "居巢金色的稻田边，两座高大的圆形粮囤：年轻豪强鲁肃（二十多岁，宽厚老实的面相，朴素衣衫，挽着裤腿，脚上沾着泥）笑着伸手指向其中一座粮囤；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着，不拿任何兵器）一脸震惊；周瑜在一旁拿着账本，想记又停住了笔；诸葛瑾（三十出头，方脸长须，青色儒袍，神情老实）站在粮囤门口，捧着一本摊开的账册，手指点着其中一页，认真地朝周瑜那边看过来",
    "c9_qiao": "皖城江边驿馆前，一辆蒙着红布的车驾，车帘被掀开：车里坐着大乔（成年女性，二十岁上下，温婉）与小乔（成年女性，二十岁上下，灵动俏皮）；满脸是灰的少年将军孙策愣在车前，长枪掉在地上；周瑜站在后面，手中的账本正掉向江水",
    "c9_bridge": "寿春城破的夜晚，火光映红了淮水：画面左边，南线主角站在荆州战船的船头；画面右边远处，淮水浮桥的另一头，一位骑马的北军主帅（和主角同一张脸，但头发束成发髻，穿河北式旧鱼鳞甲，披雪白貂裘）正抬手揉太阳穴；两人隔着河上的烟雾遥遥相望，像镜子的两面，神秘而略带超现实感",
    "c9_coat": "庐江江边小院的黄昏：吴夫人（成年女性，慈和的中年贵妇）把一件旧冬衣递到冯夫人（成年女性，三十岁上下的美艳贵妇，华服有些凌乱）手里；冯夫人低着头抱着冬衣，脸上的笑僵住了；温暖",
    "c9_wedding": "庐江的喜堂，红烛高照：孙策（少年将军，大红喜服，手抖得把交杯酒洒了一半）与大乔（成年女性，凤冠霞帔）并肩；周瑜（大红喜服）把一本旧账本郑重地交到小乔（成年女性，凤冠霞帔，正好奇地翻看）手里；热闹喜庆，略带搞笑",
    "c10_shenting": "神亭岭：孙策只带十二骑冲向岭上刘繇大将樊能的连营。镜头在骑兵侧后方，所有人是背影或后侧面，马头都朝向画面右上方的营门（木栅营墙、望楼，旗写「刘」，营兵慌乱集结），一条上坡土路从镜头位置直通营门；孙策（二十出头的少年将军，红色战袍、金兽肩甲，长枪指向营门，回头露出桀骜兴奋的笑）冲在最前；主角（南线主角，短寸头，古铜鎏金旧甲、朱红内衬、黑披风，骑着马）紧跟在孙策侧后方，侧脸大喊、伸手想拦、古锭刀斜挎在背后；左边十几名孙家骑兵举着红底「孙」字大旗，扬起尘土",
    "c10_yeyan": "吴郡太守府的夜宴，灯火通明：严白虎（五十上下，满脸横肉，赭黄锦袍外罩铁甲）举着酒碗大笑；许贡（干瘦的中年文官，眯缝眼，笑得意味深长）坐在一旁抚须；孙策（少年将军）拍桌而起；主角坐在对面，表情有点微妙",
    "c10_ganning": "夜里的江边，一条小船靠岸，船头挂着锦帆：甘宁（二十多岁的悍勇青年，腰上一串铜铃，背一张大铁胎弓）跳上岸来，指着远处吴郡城的灯火说话；船上站着满脸刀疤的周泰和包着蓝头巾、提短戟的蒋钦；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，不是绿袍、不是书生打扮）一手提着灯笼站在岸边，周瑜站在他身后皱眉；月光照着江面",
    "c10_zhoutai": "丹徒山的林间空地上，周泰（满脸刀疤的壮汉，身上中了好几刀，血顺着旧疤往下淌，却咧嘴笑着）挡在孙策（少年将军，惊魂未定，扶着周泰）身前；树上甘宁（腰挂铜铃）的弓弦还在颤；地上倒着三个蒙面门客，散落着冷箭和一只被箭头撞瘪的铜铃",
    "c10_wanglang": "会稽太守府的大堂，王朗（五十多岁的经学大儒，峨冠博带，手捧竹书）站着滔滔不绝地讲学；孙策（少年将军）抱着枪站着睡着了；主角托着下巴一脸无奈；张昭（四十岁上下的端正文士，深色儒袍）站在门边微微颔首",
    "c10_fuchun": "春日的富春江边，老宅的柴门前：吴夫人（成年女性，慈和的中年贵妇）摸着柴门红了眼眶；孙权（十九岁，紫髯碧眼，少年老成，规规矩矩作揖）；孙尚香（十八九岁的成年女子，一身红甲，英气明艳）一头撞进主角（短寸头，古铜鎏金甲、朱红内衬、纯黑披风）怀里，手里的刀被卸在地上，红着脸跺脚；孙策在一旁笑弯了腰；十里长街站满了乡亲",
    "c10_pifu": "丹徒山的密林里，冷箭从树后射来：孙策（少年将军）脸上中了一箭，倒在落叶上；主角（短寸头，古铜鎏金旧甲、黑披风，身中数箭）跪着护在他身前；三个蒙着黑巾的门客从树后走出来，其中一个还在张弓；远处林子外，周瑜带着人正策马赶来，已经晚了；晨雾和血色",
    "c10_dujiang": "秋日的长江上，一队战船刚离开庐江的岸：孙策（二十出头的少年将军，红色战袍、金兽肩甲，长枪扛在肩上）扶着船舷弯腰晕船，脸都白了；大乔（成年女性，温婉清秀）一手扶着他的背，一手往他嘴里塞一颗酸梅；周瑜（俊秀的青年文武，白衣，手持账本）在一旁摇头；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）站在船头看着江东方向的地图，忍着笑；江面开阔，远处是江东的山",
    "c10_hongying": "秣陵军营的夜里，营帐门口透出灯光：孙策（少年将军，红色战袍）蹲在帐外，眼睛看着别处，把一缕红色盔缨塞到大乔（成年女性，温婉清秀，素色衣裙）手里；大乔低着头笑，正把红缨系在发髻上；远处营火点点，月亮很亮，温馨含蓄",
    "c10_dushu": "秣陵大营的辕门下，白天，旌旗猎猎：周瑜（俊秀的青年文武，白衣）板着脸，拿一卷竹简敲在吕蒙的头盔上；吕蒙（十五六岁的少年，个子不高但结实，不合身的旧皮甲、红布带，头盔歪了）苦着脸捧着竹简，抓耳挠腮；孙策（少年将军，红色战袍）在旁边叉腰大笑；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）抱着胳膊站在一旁看热闹；轻松搞笑",
    "c10_ganning_lm": "夜里的江边营帐外，一条挂锦帆的小船靠岸：甘宁（二十多岁的悍勇青年，腰上一串铜铃，背一张大铁胎弓）站在岸边一愣；营帐帘子被掀开，少年吕蒙（十五六岁，旧皮甲、红布带，提着长刀）冲出来，激动地指着甘宁；吕蒙另一只手把一块铁腰牌拍在营前的木案上；周瑜（白衣）低头看那块腰牌，神情冷了下来；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）提着灯笼站在一旁；船上站着满脸刀疤的周泰和包着蓝头巾、提短戟的蒋钦；月光照着江面",
    "c10_jinfan": "太湖边的比武场上，比试刚结束，大家都带着汗：甘宁（二十多岁的悍勇青年，腰上一串铜铃，背大铁胎弓）仰头大笑，铃铛乱响；满脸刀疤的周泰抱拳；包着蓝头巾、提短戟的蒋钦默默点头；周瑜（白衣）翻开账本指着一行字给甘宁看，甘宁一脸「你还记着」的表情；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）和孙策（少年将军，红色战袍）站在对面笑；湖上停着挂锦帆的船",
    "c9_qiuche": "黎明前灊山脚下的山道，雾气和火把：前景里主角（南线主角，短寸头，残破的古铜鎏金甲）倒在泥地里，手伸向前方；山道上两辆蒙着红布的木笼囚车正往北驶去，红布被风掀起一角，木笼里大乔（成年女性，温婉，红色锦裙）隔着木栏沉默地回望，小乔（成年女性，灵动，红衣）抓着木栏呼喊；刘勋（四十岁上下，白胖贪婪，眯缝眼，手指戴满金戒指，华丽官袍外套不合身的铠甲）骑马走在囚车边仰头大笑；两旁是雷家部曲和「雷」字旗；山道尽头的北方天边，隐约是寿春的方向",
    "c9_liuye": "皖城太守府的大堂，刘勋丢下的公文散了一地；刘晔（二十多岁的清瘦文士，目光锐利，深色儒袍，腰间一块汉室宗亲的玉佩）安坐在堂上喝茶，抬眼看着走进门的主角；主角身后跟着周瑜和乔公（白须老者）；午后的光从门外斜照进来",
    "c9_lvmeng": "淮南的土路边，一辆装满粮袋的牛车，地上倒着几个袁军溃兵，远处有逃散的难民：少年吕蒙（十五六岁，个子不高但结实，脸上带泥，眼神倔强凶狠，不合身的旧皮甲、红布带、草鞋，身上两道血口子）拄着一把比他个头还长的豁口大刀，挡在牛车前喘气；孙策（二十出头的少年将军，红色战袍、金兽肩甲）刚翻身下马，伸手去拎他的后领；周瑜（俊秀的青年文武，白衣）收剑站在一旁打量地上的溃兵；主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风）骑在马上低头看着这个少年；黄昏，尘土飞扬",
    "c9_mishui": "寿春城外八十里一座破败的江亭，冷风灌进来：袁术（四十多岁，面容浮肿憔悴，胡须凌乱，穿着沾满泥污、看不出颜色的黄色龙袍）瘫坐在一张破床上，手里捧着一只空碗，嘴角挂着血；亭外一个粗布厨子拎着水桶摇头；亭柱上斜靠着一面残破的「仲」字旗；天色灰暗，远处是淮南灰黄的原野",
    "n5_seal": "徐州刺史府的病房里药味浓重：病榻上的陶谦（六十多岁的老人，面如金纸）颤巍巍地伸手；刘备（三十多岁，大耳垂肩，宽厚的面相）一步跨上前长跪，双手稳稳接过徐州牧大印；张飞（黑脸虬髯的猛将）在后面摸着后脑勺一脸发懵；主角站在一旁目瞪口呆",
    "n5_mizhen": "下邳酒楼的接风宴上，红烛高照：糜贞（成年女性，二十岁上下的徐州千金，正红色织金襦裙）捧着白玉酒壶大大方方地给赵云斟酒；赵云（英俊的年轻将军，白袍银甲）端着酒杯耳根红透；郭嘉在后面捂嘴偷笑",
    "n5_needle": "徐州刺史府的内堂，烛光昏黄：张宁（成年女性，二十岁上下的清秀医女，素衣）跪坐在陶谦病榻前施针，颈间露出一块刻着「太平」二字的黄玉佩；帘后站着年轻文士陈登，他身边的校尉盯着那块玉佩，脸色发白",
    "n5_beat": "小沛城外的旷野：吕布骑着赤兔马冲出阵来，方天画戟劈向刘备的面门；刘备抱头鼠窜，鞋都跑丢了一只；关羽（红脸长髯，绿袍，青龙偃月刀）与张飞（黑脸虬髯，丈八蛇矛）拼死断后；热闹、略带搞笑",
    "n5_wedding": "下邳十里红妆的喜堂：赵云（白袍换成大红锦袍）端着交杯酒手直抖，糜贞（成年女性，凤冠霞帔）低头含笑；少女甄宓（十几岁的孩子，只画孩子该有的样子）捧着凤冠跑过；吕玲绮（成年女性，二十岁左右，长发高马尾，红黑铠甲）倚在门框上笑",
    "jz_reunite": "黑山水洞口的雪地黎明：赵云（英俊的年轻将军，白袍银甲）单膝跪地抱拳；刚被救出的少女甄宓（十几岁的孩子，哭花了脸，只画孩子该有的样子）一把扑进张夫人（成年女性，富态精明的贵妇）怀里，母女俩抱头痛哭；主角站在一旁，伸手轻轻摸着甄宓的头；背景是被攻破的黑山寨，残烟未散，温情而劫后余生",
    "jz_alms": "常山城外的雪地里架起一排冒着热气的大铁锅，几万饥民捧着热粥哭出声；黑压压的青壮、降卒和乡勇齐刷刷跪在主角马前，一个个眼含热泪；主角骑在马上，神情震动，身后是甄家的粮车；画面以人群为主，只有主角一个重点人物",
    "jz_training": "常山别院雪地的清晨：赵云（白袍银甲，难得笑出了声）抱臂站在一旁；主角（扎着马步，一脸狼狈）手里的白蜡杆长枪刚刚扎穿了晾衣架上一件雪白的狐裘；张夫人（成年女性，富态精明的贵妇）拎着裙摆追着他跑过院子；热闹搞笑",
    "jz_fireside": "常山别院的夜里，炉火正旺，三人围炉煮酒：主角（神情兴奋，指点江山）居中，赵云（白袍银甲，眉头紧锁又眼神明亮）拔剑一半，郭嘉（裹着锦裘，抱着酒葫芦，笑眯眯）举着酒葫芦；墙上挂着一张河北地图，炉火映红了三个人的脸；窗外大雪纷飞",
    "c2_ln_convoy": "初春黄河古道上，甄家的粮车队蜿蜒而行：一排排盖着「中山甄记」油布的大车，车上堆满粮袋与铁甲；张夫人（成年女性，富态精明的贵妇）掀开车帘望着滚滚黄河；赵云（白袍银甲）骑白马护在车左，郭嘉（裹着裘衣，抱着酒葫芦）缩在车右，主角骑马走在最前面",
    "c2_ln_lend": "酸枣联军大营前，曹操（三十多岁，精悍的乱世奸雄，黑色战袍，神情意外又欣赏）接过主角递来的粮单，微微一愣，随即大笑，手里递出一卷手抄的《孟德新书》竹简；主角笑着挠头；背景是堆成小山的粮车和联军营帐",
    "c2_ln_nolend": "酸枣联军大营前，主角（神情平静，摇头）挡在粮车前；曹操（三十多岁，精悍的乱世奸雄，黑色战袍）盯着他看了半晌，一言不发地拨转马头走了，背影冷峻；郭嘉在一旁摇头叹气；气氛紧张",
    "c2_ln_porridge": "洛阳废墟前的空地上，甄家的几十辆大车围成一圈，一口口大铁锅里煮着热腾腾的肉粥；逃难的洛阳百姓排着长队，捧着粗陶碗，有人喝着粥落了泪；主角挽着袖子亲自盛粥；远处，曹操带着曹洪望着这边，神情若有所思",
    "c2_ln_blaze": "夜里的洛阳城火光冲天，浓烟滚滚，宫阙在烈焰中倒塌；远处联军大营里，诸侯们（背景人群）正收拾行李，无人动身；主角、赵云、郭嘉立在营外的高坡上远眺火光，神情凝重",
    "c2_ln_march": "夜里联军营门外，曹操（三十多岁，黑色战袍，神情坚决）带着几千残兵逆着人流拔营向洛阳的火光赶去；主角挥手带着甄家的运粮队跟上，粮车在身后排成长龙；郭嘉提着酒葫芦，破天荒地一脸认真",
    "c2_ln_yuanshu": "酸枣大营里，甄家的粮车前插着一块「后将军袁」的牌子：袁术（衣着华贵，神情傲慢）骑在马上俯视；张夫人（三十多岁的雍容妇人）抱着账本站在车前，寸步不让；主角和郭嘉（清瘦青年谋士，抱酒葫芦）站在她身后",
    "c2_ln_liubei": "清晨的河滩上：刘备（大耳，温和笑脸，布衣）拉着赵云（二十岁上下，英俊，白袍银枪）的手不放；赵云抱拳婉拒；远处主角站在营门口看着",
    "c2_ln_zhangliao": "夜里劫营的火光中：一个年轻的并州将领张辽（二十岁上下，英气，持长枪）挑开马车的车帘，愣住了；车里吕玲绮（二十岁上下的成年女子，冷峻英气，红黑甲，握小号画戟）戟尖对着他；主角挡在车前；远处狼骑的火把",
    "c2_ln_home": "黄河边的渡口，一条大船即将启航：主角（站在船头，指向北方，神情豪迈）、赵云（白袍银甲，握枪立在身后）、郭嘉（抱着酒葫芦靠着桅杆）；船舱口张夫人（成年女性，富态精明）摸着少女甄宓（十几岁的孩子，只画孩子该有的样子）的头；吕玲绮（成年女性，二十岁左右，长发高马尾，红黑铠甲）挥着小画戟笑；晨光映着河面",
    "c4_bad_feud": "大雪中的太行山口，两座山寨隔着一道山沟：左边郑家寨的木栅栏已被黑盾长戟的陷阵营撞破，郑好（成年女性，红色束袖短打，厚背大刀）浑身是雪，回头朝对面山头怒吼；右边山头上，姜巧（成年女性，头缠布巾的机关匠）抱着手臂站在一排纹丝不动的弩机后面，神情倔强；两人中间是空荡荡的山沟；冷色调，紧张",
    "c4_bad_lingqi": "大雪纷飞的太行山口：吕玲绮（成年女性，二十岁左右，长发高马尾，红黑铠甲，手持画戟）张开双臂挡在倒地的主角身前，仰头直面骑在赤兔马上的吕布（成年猛将，雉尾金冠，红色铠甲）高高举起的方天画戟；吕布的手在抖，神情复杂；地上是一杆折断的白蜡杆长枪，枪头系着红色平安结，画面定格在戟落下之前",
    "n5_banquet": "徐州刺史府后堂，夜宴烛火通明，气氛却诡异安静：张宁（成年女性，清秀医女，鬓边插着一朵小白花，穿着干净的新衣裳）端坐席间，第一次被人宴请，神情羞涩欣喜；主角坐在她身旁举杯；屏风后面隐约露出刀斧手的影子和连弩的箭头；堂上悬着一口金钟；画面暖光中带着不祥的冷意",
    "n5_menhou": "徐州刺史府后堂，门窗全部落闩：主角（北线主角，持一杆折断的白蜡杆长枪）把张宁（成年女性，清秀医女，鬓边小白花）护在身后，四面屏风后连弩齐发，箭雨如织；张宁手里捏着几根金针，泪流满面，只见满地箭矢与翻倒的酒案",
    "n6_dujiu": "下邳甄府的后院酒坊，一排新封的酒坛；杜夫人（二十五六岁的成年女性，素色衣裙、袖子挽起、木簪绾发，温婉而倔强）手持酒提正在封坛，身边蹲着个五六岁的男孩偷偷拿手指蘸酒；张夫人（成年女性，精明富态的甄家主母）端着一碗酒递给主角；主角呛得直咳，表情滑稽；冬日黄昏的暖光",
    "n6_zhujiu": "寿春宫（袁术的旧宫，金碧辉煌却有些俗气）殿上摆着酒席：曹操（四十岁上下，身量不高，目光锐利，黑色锦袍）举杯看着主角；旁边刘备（三十多岁，大耳垂肩，宽厚面相）手里的筷子正掉向地面，一脸慌张；杜夫人（成年女性，素净衣裙）捧着酒坛低头斟酒；主角愣在座上；背景里关羽的身影一动不动地看着斟酒的人",
    "n6_choose": "寿春宫殿上，比武招亲刚散，满堂寂静：主角站起身，挡在杜夫人（成年女性，素净衣裙，抬头直视前方，神情平静而坚定）身前半步；主座上的曹操（四十岁上下，黑色锦袍）笑容僵了一下；阶下关羽（红脸长髯，绿袍）一口喝干杯中酒；烛火通明",
    "n6_bad_fire": "夜里的寿春宫门口，一只酒坛摔碎在地上，烈酒泼了一地，倒下的烛台点起一道熊熊火墙；火墙这边，赵云（白袍银甲）和张辽（并州武将）一左一右架着主角往外冲，主角回头伸手；火墙那边，杜夫人（成年女性，素净衣裙，发髻散乱）被几个曹兵按住，隔着火光喊他快走；火光映红宫门",
    "n6_bad_hall": "寿春宫的大殿上，烛火昏暗：主角被五花大绑跪在殿中；阶下关羽（红脸长髯，绿袍）向主座一揖到地，主座上曹操（黑色锦袍）抚须不语；殿中间的杜夫人（成年女性，素净衣裙）站起身，望着被绑的主角，神情决绝，身后是一根朱红殿柱（只画她转身的一刻）",
    "n7_wedding": "下邳城里十里红妆，糜府张灯结彩：赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）换了大红锦袍，端着交杯酒手在抖；糜贞（二十岁上下的成年女子，端庄明艳，红色锦衣，珠玉发饰）头戴凤冠；夏侯兰（二十岁上下的冷面青年，卸了铁面）红着眼拍赵云的肩；一旁陈宫（四十多岁的瘦削文士，胡子翘着）抱着酒坛；甄宓（二十出头的成年女子，乌黑长发，淡蓝衣裙）捧着凤冠站在旁边，低着头",
    "c4_zj_room": "简陋山寨的小屋门口：主角搬了把椅子坐在门口打瞌睡；屋里郑好（二十岁上下的成年女子，红色短打，厚背大刀靠在墙边）和姜巧（二十岁上下的成年女子，青绿紧身衣，腰上一串小布袋）隔着桌子互相瞪眼，桌上一只空碗",
    "c4_lubu_start": "太行山寨里，初冬第一场大雪：一个探马跌跌撞撞跑进来报信；吕玲绮（二十岁上下的成年女子，冷峻英气，黑色长发高马尾）手里的磨刀石掉在地上；郭嘉（清瘦谋士）在一旁看着她",
    "c4_lubu_rage": "雪中的太行山口：吕布（束发紫金冠，红锦百花袍，兽面吞头连环铠，骑赤兔，提方天画戟）勒马停住，脸色铁青，画戟指向主角身后的吕玲绮（二十岁上下的成年女子，冷峻英气，黑色长发高马尾，提戟）；主角一头雾水；山口满地积雪",
    "c4_flee": "暴风雪中的山道：义军的队伍顶着风雪往东走；张夫人（三十多岁的雍容妇人）把一个裹在斗篷里的小姑娘甄宓（十几岁的孩子，只画孩子该有的样子）护在怀里；张宁（素白麻布衣）给冻伤的兵扎针；吕玲绮走在最后，没有回头；远处山口浓烟",
    "c4_wuanguo": "北海城门外：武安国（魁梧红脸浓须，铁甲，扛铁锤）带着守军冲出城门，指着义军的黑白条纹旗怒吼；义军队伍里混着几个头扎黄巾的黑山弟兄；郭嘉在一旁扶额叹气",
    "c4_seal": "北海郡府门前：一辆破旧的马车，一个老宦官（宫中服饰，帽子歪了，满身尘土）刚下车，抹着眼泪捧着诏书；孔融（儒雅名士，长须）在一旁拱手；主角站在台阶上",
    "n5_qiuyuan": "北海城门口，清晨：一匹快马冲进城门，马上的糜芳（三十岁上下的富家子弟，满脸是血，锦衣破烂）滚下马跪倒在地；主角和郭嘉（清瘦谋士，醉眼，灰蓝长袍）迎出来",
    "n5_xiahoudun": "下邳城外的山坡上，曹军殿后军列阵：夏侯惇（三十多岁，双目俱全，黑甲，持长枪）独自立马阵前，眼神像刀；对面赵云（白袍银枪）和太史慈（张弓）",
    "n5_law": "下邳街头，围满了百姓：夏侯兰（二十岁上下的冷面青年，戴铁面）站在当中，两个被扒了甲的老兵趴在长凳上挨军棍；主角在一旁欲言又止；百姓们看傻了",
    "n5_chenjia": "夜里的营帐，烛火：陈登（三十岁上下的精明文士）拍开一坛酒的泥封，和主角对坐；帐外月色",
    "n5_bandeng": "下邳刺史府的侧堂：郭嘉（清瘦谋士，醉眼）晃着酒葫芦对吕玲绮（二十岁上下的成年女子，冷峻英气，黑色长发高马尾）低声说话；门外一个吕布的信使在等；吕玲绮咬着牙",
    "n5_nifu": "夜里的小沛城墙：吕玲绮（二十岁上下的成年女子，冷峻英气，黑色长发高马尾）坐在垛口上，长戟靠在身边，望着西边；主角坐在她身边，两人的手握在一起；远处夜色里一匹红马的影子",
    "n5_bingzhou": "小沛城外的降军营：张辽（二十多岁的并州将领，英挺）把刀放在地上，又蹲下给一个哭着的孩子擦鼻涕；高顺（黑脸将军）抱着盾站在后面；吕玲绮站在阵前；远处并州军的家眷们",
    "n5_chengong": "下邳一座清静的宅院：陈宫（四十多岁的瘦削文士，胡子翘着）在院子里指着天破口大骂，地上散落着骂稿；郭嘉（清瘦谋士）捧着一张骂稿读得津津有味",
    "n5_guonian": "下邳过年的院子，大雪，火堆：甄宓（十几岁的孩子，只画孩子该有的样子）往火里扔竹节吓得躲到主角身后；郑好（红色短打）和姜巧（青绿紧身衣）在案上比赛包饺子；张辽捂着腮帮子笑；张夫人（三十多岁的雍容妇人）在一旁看着；院角吕玲绮一个人看雪",
    "n6_zhaoshu": "下邳刺史府的大堂，冬天：一个洛阳来的宦官捧着黄绢诏书宣读；主角站着听；郭嘉（清瘦谋士，醉眼）晃着酒葫芦；堂下张辽（二十多岁的并州将领）听到袁术两个字皱起眉头",
    "n6_qiaorui": "蕲阳城头，一面「桥」字大旗下：桥蕤（矮胖的将领，一手提大刀，一手啃着鸡腿）站在城垛上叫阵；城下张辽提刀准备先登",
    "n6_shouchun": "寿春城外的村子，黄昏：张宁（十九岁上下的成年女子，素白麻布衣）在村口支着药箱给饿得走不动的百姓看病，主角提着灯笼站在她身旁；远处寿春城里宫殿灯火辉煌",
    "n6_beimen": "寿春北门大开：吕布（束发紫金冠，红锦袍）下马跪在曹军阵前，双手捧着方天画戟过头顶；远处城墙上吕玲绮（二十岁上下的成年女子，冷峻英气，黑色长发高马尾）远远看着，高顺（黑脸将军）挡在她身前；张辽别过脸",
    "n6_lingqi_go": "夜里的营帐外，身上落了一层霜：吕玲绮（二十岁上下的成年女子，冷峻英气，黑色长发高马尾）骑在马上回头，把手腕上的红绳亮给主角看；高顺（黑脸将军）牵着另一匹马在前面等；远处曹营灯火通明",
    "n6_biwu": "寿春宫中的比武场，满堂宾客拍桌叫好：曹操（矮个子，眼睛很亮）坐在上首；典韦（魁梧的黑大汉，双铁戟插在地上）和许褚（胖大如小山，赤膊）准备下场；杜夫人（二十多岁的素衣美丽妇人）低头斟酒；关羽（红脸长须）抚须坐直；主角站起身",
    "n6_erjiu": "夜里寿春宫的庆功宴：刘备（大耳，温和笑脸）凑到曹操（矮个子，眼睛很亮）耳边低语；曹操端着酒杯没接话；主角坐得近，听见了，脸色微变",
    "n6_beiwang": "夏天的下邳城墙：吕玲绮（二十岁上下的成年女子，冷峻英气，黑色长发高马尾，手腕系红绳）把头靠在主角肩上，闭着眼；高顺站在身后；甄宓（十几岁的孩子，只画孩子该有的样子）抱着一窝小兔子跑上城楼；郭嘉坐在城楼上喝酒望北",
    "n7_yijing": "下邳刺史府的厅堂，春天：郭嘉（二十多岁的清瘦谋士，醉眼，灰蓝长袍）把一卷探报摊在案上，探报上画着被十道壕沟和高高土山围住的易京城；赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）攥着拳头看着北方；窗外北边天上一缕烟尘",
    "n7_shishi": "下邳城东的别苑，满地揉皱的骂稿：陈宫（四十多岁的瘦削文士，胡子翘着，朴素儒袍）从案底下抽出一卷河北地图背在身上，斜眼看着站在门口拱手的主角；郭嘉（清瘦谋士，灰蓝长袍）倚着门框偷笑",
    "n7_heibing": "太行山滏口陉前的夜营，四面山梁上满是火把：张宁（十九岁上下的成年女子，素白麻布衣，袖子挽起）站在一面铺开的黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）前，刚放下手里的毛笔，旗面是干净的黑白横条，上面没有任何字；赵云（二十多岁，白袍银甲）握着旗杆准备升旗；张燕（精悍的黑山首领，短打皮甲）抱臂站在一旁；身后收起的杂色黑山旗堆在地上",
    "n7_yuye": "雷雨夜的邺城东门，闪电划破夜空：城门从里面开了一条缝，门缝里站着张夫人（三十多岁的雍容妇人，深色锦袍，撑着一把油纸伞）；城外雨中赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）第一个策马冲进门",
    "n7_xingyuan": "雨后清晨的邺城刺史行辕，府库大门一间间敞开，粟帛金银堆满库房：张夫人（三十多岁的雍容妇人，深色锦袍）在清点；甄宓（二十出头的成年女子，乌黑长发，淡蓝衣裙）站在廊下回头看着主角；库房角落里郭照（十四五岁的瘦削少女，身上披着郭嘉灰蓝色的外袍，发梢烧焦，怀里抱着一摞账簿）把郭嘉腰上的酒葫芦摘了下来，郭嘉（清瘦谋士）一脸无奈；门口赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）甲上还在滴水，抱拳请命",
    "n7_qin": "邺城行辕的书案前，烛火通明：陈宫（五十岁上下的清瘦老谋士，灰白胡须，旧儒袍）提笔伏案仿写一封书信，案上摊着一摞旧账簿；郭照（十四五岁的瘦削少女，身上披着灰蓝外袍）把一封写好的信举在烛光前对照；郭嘉（清瘦谋士，灰蓝长袍）凑过来看；赵云（二十多岁，白袍银甲）抱臂立在门边，脚下是两封拆开的密信",
    "n7_jiyi": "冬夜军帐，油灯下摊着漳水的地图：郭嘉（清瘦谋士，灰蓝长袍）手指点着葫芦谷；赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）抱着胳膊笑了一下；郑好（二十岁上下的成年女子，红色短打）拍桌子，姜巧（二十岁上下的成年女子，青绿紧身衣，腰上一串小布袋）翻白眼；案上放着一个针脚歪歪扭扭的香囊",
    "n7_juedi": "漳水葫芦谷，上游的旧堤被掘开，浑浊的河水像奔牛冲进山谷，谷口一道火墙；岸上赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）浑身湿透，揪着颜良（高大的红脸猛将，河北重甲）的甲把他从水里拖上岸；远处谷口立着一面「文」字黑旗",
    "n7_ouxue": "冬天的漳水，河里漂着破旗和断枪：近处水边赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）用枪杆打飞了文丑（黑脸虬髯，河北铁甲）手里的腰刀，文丑跪在水里；对岸高坡上，袁绍（五十岁上下，金甲华服，须发花白）仰天张口，扶着一辆车，车上溅着红；画面克制，不画血腥",
    "n7_wuji": "春天的冀州无极，一座荒了多年、正在重修的大宅门前：甄宓（二十出头的成年女子，乌黑长发，淡蓝衣裙）站在梯子上，把一块写着「甄家粮行」的新匾挂上大门，回头笑着；张夫人（三十多岁的雍容妇人，深色锦袍）在下面扶着梯子，一手擦眼睛；门口插着一面小小的、黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）；院里杂草刚割了一半，黑山的汉子扛着木头，门外排着领粥和领种子的百姓",
    "n7_end": "春天的漳水码头，糜家的粮船靠岸：糜贞（二十岁上下的成年女子，端庄明艳，红色锦衣，珠玉发饰）站在船头；赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）一步跳上船，手不知道往哪放；码头上张郃（冷静的河北名将）和高览（河北名将）卸了兵器走来；远处官道上一队甲胄烧黑了一半的白马骑兵正走过来；城头插着黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹），陈宫伏案写字",
    "n8_start": "夏天的邺城行辕：两拨使者在门口撞上了，互相瞪眼差点动手；屋里郭嘉（二十多岁的清瘦谋士，病容，裹着厚裘衣）坐在一边咳嗽，郭照（十四五岁的瘦削少女，披着灰蓝外袍）把一碗药放在他手边；主角坐在上首，一脸无奈",
    "n8_dumai": "渤海南皮城下，阴天：城门刚刚关上，城头上辛评（四十多岁的文士）冲城下作揖，身边辛毗（三十多岁的文士）和袁谭（年轻贵公子将领，盔甲镶金边，低着头）；城下赵云（二十多岁，白袍银甲）勒马停住；城头竖着「袁」字旗",
    "n8_chusai": "雪夜，中山卢奴城的城门：审配（五十多岁的老将，须发花白）一手牵着袁尚的缰绳、一手护着袁熙，带着几百骑冲进城门，回头看了一眼；城头重新竖起「袁」字旗",
    "n8_dingbei": "幽州蓟城的厅堂，雪天：曹操的使者满宠（四十岁上下，脸板得像铁，深色汉朝官服，神情冷峻）站着展开一卷黄绢诏书，身后几个羽林郎；主角站在地图前；糜贞（二十岁上下的成年女子，端庄明艳，红色锦衣）手里的茶碗摔在地上；郭嘉（清瘦病容的谋士，裹着厚裘衣）在一旁冷笑；窗外大雪",
    "n8_liushou": "雪夜的蓟城城头：郭嘉（二十多岁的清瘦谋士，病容，裹着厚裘衣）站在城头送别，裘衣被风吹得鼓起来，人显得更瘦；郭照（十四五岁的瘦削少女，披着灰蓝外袍）背着药箱站在他身边；城下大军举着火把南去；画面安静而悲伤",
    "n8_liushou_t": "蓟城的厅堂，地图摊在案上：郭嘉（清瘦病容的谋士，裹着厚裘衣）站在地图前，手指着南方，神情笃定；田丰（五十岁上下的清瘦老谋士，胡须半白，灰色儒袍）和沮授（四十多岁的端正谋士，深色官袍）并肩站着点头；张辽（三十多岁的并州名将）抱拳，张燕（精悍的黑山首领）咧嘴笑",
    "n8_b_xin": "雪中的官道，傍晚：赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）看着主角；主角坐在马上，手里攥着一封没拆的信，信封上写着「主公亲启」；马旁放着一个旧药箱，箱上搁着一个酒葫芦；画面悲伤克制",
    "n8_liushi": "雪地上的林道，黄昏：一封散开的信落在雪里，信纸上写着字；赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）跪在雪地里看着信，手在发抖；远处林子上空没有一只鸟；画面悲伤克制，不画血腥",
    "n8_shipo": "傍晚北海城东的官道：一辆马车停着，郭嘉（二十多岁的清瘦谋士，病容，裹着厚裘衣）撑着车壁坐起来，掀开车帘指着远处的林子，林子上空一只鸟都没有；郭照（十四五岁的瘦削少女，披着灰蓝外袍）扶着他；赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）勒马回头看",
    "n8_jincheng": "北海西门：张宁（十九岁上下的成年女子，素白麻布衣上全是药渍）掀开马车帘子给郭嘉（二十多岁的清瘦谋士，病容，裹着厚裘衣）搭脉，皱着眉；郭照（十四五岁的瘦削少女，披着灰蓝外袍）在一旁点头；城门里糜竺（四十多岁的胖富商，满脸是灰）带着徐州士绅、工匠和一车车家当迎出来，糜贞扑过去抱住他",
    "n8_zhanlv": "北海城下的雪原：赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）与吕布（束发紫金冠，红锦袍，方天画戟，骑赤兔）枪戟相交，雪雾飞溅，吕布的戟削落赵云的盔缨；城头上糜贞（二十岁上下的成年女子，换了轻甲）抡着鼓槌擂鼓；城头插着黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹）",
    "n8_tuijun": "清晨的北海城外：吕布骑赤兔回头望着城头，并州狼骑跟着他往西走；城头飘着黑白横条旗（旗面只有五条宽横条：黑白黑白黑，三黑加两白，条宽相等，旗面上没有任何文字、符号或图案；不是斑马纹，不要细密条纹），旗下站着主角；西门城门洞里太史慈（三十岁上下的东莱猛将）坐着擦拭双戟；画面不画首级",
    "n8_ma": "夏天的黄河，对岸扎着一座「马」字大旗的西凉大营：马云騄（二十出头的西凉女将，红缨银盔、红甲，持银枪，英气）单骑立在河中浅滩，长枪指向北岸的主角；主角一脸淡定地竖起一根手指；北岸营中郑好被姜巧按住；郭嘉（清瘦谋士）在后面笑得直咳嗽",
    "n8_end": "夏夜的黄河河滩，篝火上烤着整只羊：吕玲绮（二十岁上下的成年女子，冷峻英气，黑色长发高马尾，甲没穿整齐，方天画戟插在地上）揪着满嘴是油、怀里抱着羊腿的主角的耳朵往外拖；对面马云騄（红甲西凉女将）满嘴是油，腰带松了，愣愣地看着笑出了声；马超（银甲白袍）啃着羊腿看热闹；远处河边郭嘉把一个酒葫芦递给郭照（十四五岁的瘦削少女）；画面轻松搞笑",
    "n9_start": "春天的北海郡府：主角拿着一封信，信末一行字写得很急；郭嘉（清瘦谋士，气色红润了些，腰间没有酒葫芦）站在一旁看地图；窗外北方",
    "n9_lunu": "春天的冀州无极，甄家粮行门口：张夫人（三十多岁的雍容妇人）从门楼上下来腿一软，被主角扶住；甄宓（二十出头的成年女子，乌黑长发，淡蓝衣裙）拉着主角的袖子不松手；门楼上插满了箭，门边一面小小的义字斑马旗",
    "n9_haikou": "渤海的海边，阴天：一条挂着辽东旗号的船离了岸，船头辛评（四十多岁的文士）向岸上作揖，船尾辛毗望着南皮方向，船中袁谭低着头；岸上赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）勒马停在浪花里",
    "n9_yanjin": "夏天的北海营帐里：陈登（三十多岁的精明文士，提着酒坛）兴奋地展开一封字迹工整、盖着「马」字印的回信；郭嘉（清瘦谋士）盯着信上的字，神情凝重；窗外黄河对岸是「马」字大营，营东扎着狼骑",
    "n9_pangde": "夜里的黄河北岸营帐：庞德（三十多岁的西凉猛将，浑身是水，嘴边咬过的短刀放在一旁）单膝跪地抱拳说话；郭嘉（清瘦谋士）在听；赵云（二十多岁，白袍银甲）站在一旁；帐外遥望对岸的西凉大营和三座烽火台",
    "n9_xunyu": "七月十五夜，仓亭下游的浅滩：芦苇荡里站起一片魏军重甲，夏侯惇（独眼猛将，黑甲）举着火把冷笑；主角站在船头愣住；陈登脸色惨白；对岸的西凉大营起了火；画面克制，不画血腥",
    "n9_jiuren": "烧成一片的马营：马云騄（二十出头的西凉女将，红缨银盔、红甲，英气）肩上中了一箭，被马岱（二十多岁的西凉青年将领）背着，抬头看着主角，攥着弓；主角伸手；背景火光；画面克制",
    "n9_duanxian": "夜里的芦苇荡：马云騄（二十出头的西凉女将，红缨银盔、红甲，英气）站在主角身前拉弓，弓弦断了，她看着断弦笑了一下；远处魏军的箭雨落下；画面悲伤克制，不画血腥",
    "n9_ludi": "夜里黄河对岸的西凉大营：三座烽火台接连点燃，第三座台顶上马云騄（二十出头的西凉女将，红缨银盔、红甲）举着火把，台下吕布的狼骑在围；北岸庞德（西凉猛将）脸色发白，拔刀往河边跑；火光映在河面上",
    "n9_xuezhan": "火光中的西凉大营：烽火台下，庞德（西凉猛将，提大刀）张开手接住从台上跳下来的马云騄（二十出头的西凉女将，红缨银盔、红甲，英气）；另一边马岱（二十多岁的西凉青年将领）死死抱住红着眼要冲向吕布大旗的马超（银甲白袍）；远处赵云挑开营门；画面克制，不画血腥",
    "n9_shi": "黎明的黄河北岸河滩：马超（银甲白袍，狮盔）跪地叩首，额头沾着泥；马岱跟着跪下；庞德把大刀横放在主角脚下；马云騄（二十出头的西凉女将，红缨银盔、红甲，英气）低着头拽着主角的袖子；远处吕玲绮（黑色长发高马尾，冷峻英气）抱着胳膊看着",
    "n9_yizheng": "北海郡府的议事厅：马超（二十多岁，披着麻衣，攥着长枪，红着眼）站在厅中；郭嘉（清瘦谋士，灰蓝长袍）站起来挡在他面前，手按在地图的北边；张辽抱拳等令；门外马云騄（红甲西凉女将）看着哥哥的背影",
    "n9_zhanta": "白狼山顶，秋风：张辽（三十多岁的并州名将）提刀站在倒下的乌桓大旗旁；山坡下审配（花白须发的老将）拄刀站着，身边一圈倒下的乌桓兵；远处袁尚、袁熙骑马往东逃；画面克制，不画血腥",
    "n9_liaoshui": "冬夜结冰的辽水岸边营帐：庞德（西凉猛将）把一个高句丽俘虏按在地上；马超（银甲白袍）冷笑；马云騄指着冰面；远处对岸辽东营寨后面又扎了一座陌生旗号的营",
    "n9_lulong": "卢龙塞外的荒原，一条干涸的河道：田豫（三十岁上下的清瘦将领，白甲）带着一队白马骑兵走在最前面，张辽（三十多岁的并州名将）跟在后面，大军蜿蜒在干河道里",
    "n9_end": "冬天的辽东襄平城外：公孙康（辽东军阀，披着过大的王袍）跪在雪地里捧着一个木匣子（不画匣子里面）；马超（银甲白袍）骑在马上没有接，望着南方；马云騄（红甲西凉女将）在一旁；城头的辽东旗倒了",
    "n7_qijin": "漳水渡口烧着的村子，浓烟里赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）白袍染血，单骑在河北兵中冲杀；村子中间一口枯井边，糜贞（二十岁上下的成年女子，端庄明艳，红色锦衣，珠玉发饰）靠着井栏坐着，腿上中了一箭，抬头对他笑；村口一杆黑旗竖起；画面悲壮克制，不画血腥",
    "n7_kujing": "清晨的焦土村子，一口枯井：赵云（二十多岁，英俊刚毅，白袍外罩银白轻甲，银枪）坐在井栏上，银枪插在井边，白袍染成红色，脸朝着井里，一动不动；井栏上挂着一片红色衣角；远处郭嘉带着人跑来；画面悲伤克制，不画血腥",
    "end_luoshang": "象征性结局卡插画（结局十六·洛殇，北线）：黎明时分雾气弥漫的洛水浅滩，水面上横着一道碗口粗的黑色铁索，半截烧焦的运粮木船搁浅在鹅卵石滩上；浅水里静静漂着一方绣着小兔子的浅蓝丝帕与一支折断的白玉簪；色调苍凉凄美，不见人物，不画血腥",
    "n10_guandu": "春天黄河南岸的官渡河滩，千帆竞渡：北线主角站在领头的蒙冲大船船头，手持白蜡杆长枪指向南岸；东面仓亭方向，赵云（二十多岁，英俊刚毅，白袍银甲，持亮银枪骑白马）率白马义从席卷而来；当中曹军大将夏侯惇（三十多岁，黑甲长枪）在前后夹击中仓皇招架，黑底「魏」字大旗倒在河滩上",
    "n10_qiandu": "阴云低垂的许都西门官道，一长列皇家车驾与百官队伍正仓促向西迁往洛阳：曹操（四十多岁，身形不高，细长眼，玄黑锦袍外罩铁甲）勒马回头，脸色阴沉地望着北方天边的烟尘；荀彧（三十多岁的端正文士，深色儒袍、进贤冠）在马车旁拱手建言；城门口于禁（四十岁上下，玄黑铁甲，神情严整）正指挥士卒立起鹿角拒马",
    "n10_luoyi": "许都城外的旷野，骄阳似火，两军阵前尘土飞扬：许褚（三十多岁的魁梧壮汉，脱去铁甲赤着上身，肌肉虬结，双手抡起沉重的大砍刀）咆哮着全力劈下；对面马超（二十多岁，银甲白袍、狮盔兽带，俊美凌厉）骑白马挺虎头湛金枪迎面硬架，枪刀相撞火星四溅，许褚虎口震裂退后半步",
    "n10_pangtong": "许都辕门外，春天的上午，排着长队来投奔的人：落第书生、小吏、老兵；队伍里一个三十岁上下的书生（庞统：黑脸短须，长相普通到放在人堆里找不出来，洗得发白的旧布袍，怀里揣着一只酒葫芦），手里递着一张写满字的纸，脸上似笑非笑；马超（二十多岁，银甲白袍，英俊高傲）坐在辕门边的条案后头，头也不抬地挥手让他去后营；远处北线主角（穿灰蓝色交领长袍常服、外披雪白狐裘，不穿盔甲，双手抱着一摞兵册、身边不带任何兵器）从辕门边匆匆走过，没有回头。黑白横条旗插在辕门上。",
    "n10_zhenmi": "许都城外的颍水码头，几十艘插着「甄」字旗的平底漕船一字排开，船工正往岸上搬粮袋：甄宓（二十出头的成年女子，乌黑长发，柔美温婉，淡蓝色交领广袖衣裙）刚跳下船，一手把一本粮秣账册塞进北线主角怀里，另一手伸过去替他翻正歪了的衣领，眼神有点嗔怪；北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）愣愣地站着；一旁的赵云（白袍银甲）别过脸去看船。清新明亮的春日，温柔克制，不暧昧",
    "n10_hulao": "险峻陡峭的虎牢关下，高耸的关墙夹在两山之间：关楼上黑底「吕」字大旗猎猎，吕布（高大英俊，束发紫金冠，红锦百花袍，方天画戟）拄戟站在城垛后，目光却落在关下一个人身上，神情复杂；关前北线主角（束发，河北风格旧鱼鳞甲，手提白蜡杆长枪）、赵云（白袍银甲）与马超（银甲白袍）勒马仰望，主角身后吕玲绮（少女将军，高马尾，红色劲装外罩轻甲，握十字戟）骑在马上抬头直视父亲，没有低头；身后营帐连绵，关墙上插满攻城留下的断箭",
    "n10_luoshui_bad": "深夜浓雾弥漫的洛水河道，五十艘民船装扮的运粮船撞上横江铁索，船头燃起熊熊大火：两岸高坡上火把齐亮，曹操（四十多岁，玄黑战袍）与荀彧（端正文士，深色儒袍）立于高处俯视；甄宓（二十出头的成年女子，淡蓝衣裙）在摇晃的船头一把拉住北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）的衣袖，漫天火矢如雨落下",
    "n10_luoshang": "黎明前雾气凄迷的洛水浅滩，远处燃烧的粮船残骸顺水漂远：北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带任何兵器）半跪在浅水里，怀里紧紧抱着甄宓（二十出头的成年女子，乌黑长发散落，淡蓝色衣裙被水浸湿，脸色苍白却带着浅笑）；她抬起微颤的手，想去翻正主角歪了的衣领，只翻到一半；一方绣着小兔子的浅蓝丝帕滑落在水面上；四周只有雾和火光，没有别人；画面凄美克制，不画血腥",
    "n10_lianhuan": "夜里的虎牢关前中军大帐，油灯照着洛水与虎牢关的沙盘：庞统（三十岁上下，黑脸短须，长相普通的大众脸，洗得发白的旧布袍，酒葫芦放在案上）用一根铁链在沙盘的黄河洛水交汇处绕了一圈，嘴角带着狡黠的笑；甄宓（二十出头的成年女子，淡蓝衣裙）捧着洛水水道图站在一旁，脸微红却认真地听；郭嘉（清瘦谋士，灰蓝长袍）裹着一条厚被子缩在一旁咳嗽，却笑着；北线主角（束发，河北风格旧鱼鳞甲，双手撑着沙盘边沿、不带长枪）看着那根铁链",
    "n10_jiaji": "火光冲天的虎牢关，前后两面杀声震天：远处黄河口的巩县渡口被铁锁连环火船撞成一片火海；虎牢关西门（后方）已被赵云（白袍银甲）与马超（银甲白袍）从里面撞开，黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）插上西城头；关中吕布（紫金冠，红锦百花袍，方天画戟）骑在赤兔马上左顾右盼，神情慌乱暴躁，掉转马头往洛阳方向夺路而逃",
    "n10_huitou": "天刚亮的虎牢关西门外，乱军和烟尘里：吕布（紫金冠，红锦百花袍，方天画戟）骑着赤兔马正往西冲出关门，却勒住缰绳回头看了一眼；他回望的方向，吕玲绮（少女将军，高马尾，红色劲装外罩轻甲）站在乱军里，十字戟的戟尖垂到地上，仰脸望着父亲；她身后不远处北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）正朝她走过来；关城头上，黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）正被插上去；苍凉克制",
    "n11_start": "秋天的虎牢关楼上，西风吹着黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）：北线主角（束发，河北风格旧鱼鳞甲，手里拿着两封信、不带长枪）低头看信，一封字迹像箭一样戳出来；郭嘉（清瘦谋士，灰蓝长袍外裹厚裘衣，脸色苍白）和庞统（黑脸短须的大众脸书生，旧布袍，腰挂酒葫芦）凑过来看；吕玲绮（少女将军，高马尾，红色劲装外罩轻甲，握十字戟）站在垛口边往西眺望洛阳方向；远处西边群山之间，首阳山上的曹营炊烟点点",
    "n11_beidu": "巩县渡口的黄河岸边，几十条插着「甄」字旗的平底漕船正在把北军一船一船运过河：甄宓（二十出头的成年女子，淡蓝衣裙）站在船头指挥船工；岸上庞统（大众脸书生，旧布袍）在沙地上用树枝画出一条绕向孟津的弧线，北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）和郭嘉（裹着裘衣）低头看",
    "n11_qiye": "深夜的黄河北岸孟津，河对岸远处的洛阳城西燃起冲天大火，火光映红了半边天和河面：北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）站在岸边望着火光；他身边吕玲绮（高马尾，红色劲装）攥着十字戟，望向火光旁边的宫城方向；另一边庞统（大众脸书生）眯眼盯着火光，手里捏着酒葫芦；背后是北军的营帐和黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）",
    "n11_kongming": "天刚亮的黄河北岸，薄雾里一条小船靠岸：诸葛亮（二十出头的年轻文士，俊秀清瘦，一身白衣，头上扎着白布孝带，羽扇上溅着几点黑色的血迹）跪在泥滩上，双手高举一卷帛书；北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）站在他面前；人群后面庞统（大众脸书生，旧布袍）抱着胳膊看着他，郭嘉（裹着裘衣）站在一旁；色调冷清",
    "n11_zhanli": "正午的孟津渡口，硝烟散尽：典韦（黑脸大汉，身上插满箭，两杆卷刃的铁戟垂在手里）背靠渡口木桩站着死去，眼睛睁着望向洛阳的方向；赵云（白袍银甲）站在几步外，低头抱拳；北军将士远远围着，没有一个人上前；肃穆悲壮，不画血腥",
    "n11_xiaoxi": "黄昏的黄河岸边，河水泛着暗金色的光：吕玲绮（少女将军，高马尾，红色劲装外罩轻甲）坐在河边的石头上，十字戟插在身旁的沙地里；北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）坐在她身边，她把头靠在他肩上；远处陈宫（中年谋士，拄着拐杖）独自站着；几个跪着的并州逃兵在更远处；安静克制",
    "n11_beimen": "洛阳烧了一半的南宫：刘备（双耳垂肩，绿袍金甲）靠坐在殿门框上，眼睛还睁着，手里攥着一口断剑；张飞（黑脸大汉，满身血污）蹲在他身边用袖子给他擦脸；殿门口关羽（红脸长须，盔缨断了一截）背对众人站着；北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）和诸葛亮（白衣孝带）站在台阶下，几个士兵抬来两口棺木；肃穆悲凉，不画血腥",
    "n11_jianlou": "洛阳西城的箭楼上，秋天的午后：北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）站在箭楼上，抬手揉着太阳穴；赵云（白袍银甲）站在他身后；城外远处一座大营打着「吴」字旗，营门口站着南线主角（短发寸头，古铜色旧甲，双手空着、不带大刀），也抬手揉着太阳穴，两人隔着城墙遥遥相对（两人五官一模一样）；城头另一侧诸葛亮（白衣）手持帅印正在点将",
    "n11_yinzhang": "孟津北岸的中军大帐：诸葛亮（白衣孝带）跪在帐中，双手捧着一卷帛书；北线主角（束发，河北风格旧鱼鳞甲，双手空着、身边不带长枪）坐在案后，案上放着一方帅印，手悬在帅印上方犹豫；郭嘉（脸白如纸，被人用软榻抬进来）撑起身子伸手要那卷帛书；庞统（大众脸书生）站在一旁，眼睛死死盯着诸葛亮的右手袖口",
    "n11_zhumie": "深夜的洛阳北宫大帐里，案上一支白烛正在熄灭，青烟袅袅：案上翻倒着一只喝了一半的参汤碗，旁边放着帅印；诸葛亮（白衣素服，羽扇轻摇）坐在案对面的阴影里，神情平静，没有恨也没有得意；画面边缘只露出一只垂落的苍白手掌（不见全身与面容）；幽暗凄冷，不画血腥",
    "n11_nanzheng": "誓师前夜的北军中军大帐，油灯昏黄：诸葛亮（二十出头，白衣素服，羽扇停在半空）站在帐中，神情平静却带着审视；北线主角（穿灰蓝色交领长袍常服、外披雪白狐裘，不穿盔甲，双手空着、身边没有任何刀枪兵器）坐在案后，愣愣地抬头看他；帐门半开，帐外十万人的营火一直排到远处的洛水边",
    "n11_nushang": "孟津北岸的中军大帐：庞统（大众脸书生，旧布袍）蹲在跪着的诸葛亮（白衣孝带）面前，抓着他的右袖一抖，一具巴掌大的精巧小弩掉在地上，弩匣里少了一支箭；诸葛亮把羽扇放在地上，神情平静；郭嘉（裹着裘衣）把一卷帛书凑在鼻子底下闻墨；北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）站在案前",
    "n11_chengtou": "初冬许昌城头的第一场雪：吕玲绮（高马尾，红色劲装外罩轻甲）独自站在垛口边往西眺望；甄宓（二十出头的成年女子，淡蓝衣裙外罩斗篷）端着一碗热汤，顺手替北线主角（穿灰蓝色交领长袍常服、外披雪白狐裘，不穿盔甲，双手空着、不带任何兵器）翻正衣领；城下远处一座小帐门口站着卫兵；黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）在雪里飘；温柔又落寞",
    "n11_jin": "孟津南岸的渡口，血还没干：北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）站在渡口望着远处的洛阳，眼神里像是想起了很多不该记得的事；郭嘉（裹着裘衣）和庞统（大众脸书生）站在他身后；远处洛阳城头冒着烟",
    "s12_beifa": "初春的洛阳北宫，雪刚化：南线主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛大刀）坐在案后看地图；周瑜（青袍，账本）和荀彧（衣冠整齐的中年文士）站在两边；门框边吕布（紫金冠，红锦袍）靠着，用画戟拨着炭盆，戟刃亮得像镜子",
    "s12_meng": "深夜官渡南营的帐中，炭盆快灭了：吕布（没带戟，紫金冠，红锦袍）坐在南线主角（穿深棕色交领青绿镶金边常服，不穿盔甲，双手空着、身边没有任何刀剑兵器）对面，凑近盯着他的脸，眼神迷茫又痛苦；帐外董白（成年女将，银白色长发高马尾，持骨朵）的影子映在帐布上",
    "s12_hushi": "深夜官渡南营的中军帐，灯下摊着地图：吕布（紫金冠，红锦袍，眼神疯狂）弯腰凑近南线主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、来不及拔刀）的脸，画戟已经刺出；帐外火光冲天；画面克制，不画血腥",
    "s12_nanyang": "南阳宛城的城头，城墙上还有一道道水印：南线主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛大刀）、周瑜（青袍，账本）、法正（瘦削文士）、贾诩（老谋士）眺望北方；远处地平线上黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）连成一片，旗下一辆四轮车上坐着一个白衣人",
    "s12_sang": "夏口的江边，夜里：南线主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛大刀）独自坐在江边的石头上，一手拿着一张白纸黑字的檄文，一手抬手揉着太阳穴；对岸一片漆黑，什么都没有",
    "s12_pangtong": "夏口城外的营门口：庞统（黑脸短须的大众脸书生，袍子上全是泥，怀里揣着空酒葫芦）递出一张皱巴巴的纸条；周瑜（青袍）接过纸条，南线主角（短寸头，古铜鎏金旧甲，双手空着、不扛大刀）站在一旁",
    "s12_kurou": "南军大帐外的空地上，甘宁（赤膊，腰挂铜铃）背上鞭痕累累却咧嘴冲南线主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手空着、不扛大刀）笑；周瑜板着脸站在一旁，手里还拿着鞭子；远处江边十条船上堆满干柴和油",
    "s12_lian": "火光冲天的乌林江岸：赵云（白袍银甲）枪尖停在南线主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，手持古锭刀）胸前一寸，手在抖；一个满脸烟灰的北将（夏侯兰，铁面军法官）跪在泥里仰望南线主角；周围的北兵一个个放下了刀",
    "s12_zhui": "天快亮的赤壁江面，到处是烧黑的船板：诸葛亮（白衣，羽扇已经断了）往后仰，落向江水；孙策（红头巾）站在撞过来的船头，伸着手",
    "s12_guan": "江边营门前：赵云（白袍缟素）扶着一口打开的棺木，夏侯兰、张辽、马超人人缟素站在后面；南线主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，双手扶棺、不扛大刀）俯身看棺材里，棺中躺着北线主角（束发，穿河北风格旧鱼鳞甲，和南线主角长着同一张脸，神情平静，双手空着）",
    "s12_dufu": "重修的洛阳南宫大殿，登基大典：南线主角（短寸头，身穿庄重华丽的汉代玄衣纁裳帝王冕服，不穿盔甲，双手空着、不带任何刀剑兵器）站在殿上，殿下跪满群臣，孙策、周瑜在最前排；他独自望着殿外，神情孤寂",
    "n12_xuchang": "初春许昌城头，积雪刚化：北线主角（束发，河北风格旧鱼鳞甲，双手扶着城垛、不带长枪）望着西边的烟尘；郭嘉（裹着裘衣）被人扶着；关羽（红脸长须，绿袍，青龙刀）站在城门楼上一言不发",
    "n12_guandu": "黄河南岸的官渡，三道壕沟一字排开：甄宓（二十出头的成年女子，淡蓝衣裙）刚从运粮船上跳下，伸手替北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）翻正衣领；身后黄河上一船一船的甄家粮船",
    "n12_huo": "深夜官渡北营，三道壕沟对面的南营燃起一片大火：北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）站在壕沟边望着火光，吕玲绮（高马尾，红色劲装）手里的十字戟掉在地上；诸葛亮（素服，没有扇子）被两个兵带着站在一旁",
    "n12_lvbu_si": "官渡第三道壕沟边的泥地里：吕布（紫金冠歪斜，浑身是血，画戟断成两截）半跪着，抬头看着走过来的吕玲绮（高马尾，红色劲装），眼神第一次清明；倒下的赤兔在一旁",
    "n12_jiaozhang": "烧焦的南军中军帐只剩几根焦黑的柱子：北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）蹲在地上，面前躺着南线主角（短寸头，穿烧黑了的古铜鎏金旧甲，手握古锭刀，和北线主角长着同一张脸）；帐外赵云背对着站着；画面克制，不画血腥",
    "n12_dufu": "重修的洛阳南宫大殿，登基大典：北线主角（束发，身穿庄重华丽的汉代玄衣纁裳帝王冕服，不穿盔甲，双手空着、不带任何刀枪兵器）站在殿上，郭嘉（裹着裘衣）站在最前面笑着，诸葛亮（素服，无扇）站在角落远远一揖，甄宓在殿下悄悄比了比自己的领子；他神情孤寂",
    "n12_nanzheng": "春天洛阳城外，十万北军南下：诸葛亮（白衣羽扇）坐在四轮车上走在中军，军容整齐；北线主角（束发，河北风格旧鱼鳞甲，骑马按辔、不提长枪）骑马在旁，回头望着后面一辆遮着厚帘的车（郭嘉在里面）",
    "n12_guojia": "江陵营中的病帐，油灯昏暗：郭嘉（瘦得脱形，裹着裘衣）把一张折好的纸塞进郭照（少女，背着药箱）手里；张宁（女医仙）在一旁拔针；帐门外站着一个人的影子",
    "tm_start": "冬天的洛阳，一条长街中间：街这头黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）下站着北线主角（束发，河北风格旧鱼鳞甲，手提白蜡杆长枪），街那头「吴」字旗下站着南线主角（短寸头，古铜鎏金旧甲、朱红内衬、纯黑披风，肩扛古锭刀）；两边的兵举着兵器对峙，却没有一个人放箭，所有人都在看两个主帅一模一样的脸",
    "tm_xiangjian": "夜里北军营中，北线主角（束发，河北风格旧鱼鳞甲，双手捧着素绢、不带长枪）看着绑在响箭上的素绢，笑出了声；帐里赵云、郭嘉面面相觑；素绢上写着一行小字",
    "tm_digong": "太极殿下的青铜地宫，幽暗的长明灯下：南线主角（短寸头，穿古铜鎏金旧甲，双手空着、不带大刀）和北线主角（束发，穿河北风格旧鱼鳞甲，双手空着、不带长枪），两人长着同一张脸，扑过去紧紧抱在一起，又哭又笑",
    "tm_jinggao": "青铜地宫里，南线主角（短寸头，穿古铜鎏金旧甲，双手持古锭刀）与北线主角（束发，穿河北风格旧鱼鳞甲，双手持白蜡杆长枪）两人长着同一张脸，兵器相交，刀尖和枪尖都停在对方身前一寸；空中浮现冰冷的半透明青铜几何光幕",
    "tm_guiyi": "青铜地宫里白光盛放，两道光流交错缠绕，南线主角（短寸头，古铜鎏金旧甲）与北线主角（束发，河北风格旧鱼鳞甲）两个人的身影在光里渐渐合成一个；地上扔着一把古锭刀和一杆白蜡杆长枪",
    "tm_end": "太极殿前的台阶，清晨：青铜门里走出归一后的主角（头发比短发长一点、比束发短一点，甲胄半是古铜鎏金甲半是河北鱼鳞甲，双手空着、不带任何兵器）；殿阶上左慈（抱葫芦的老道）扬眉而笑；台阶下孙策和赵云并肩站在两支大军最前面",
    "n11_huishi": "秋天的孟津北岸，黄河边扎满营帐：张辽（三十多岁，长刀，并州甲）骑马立在河边，身后是并州兵和高顺（沉默的中年将领，持大盾）正在造的渡船；东边烟尘里太史慈（背插两支短戟）骑马冲来，跳下马一拳砸在北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）肩上，两人都在笑；黑白横条旗（旗面五条宽横条：黑白黑白黑，无字）在风里飘",
    "n11_g_xiaoxi": "邙山的山坡上，秋天的午后：吕玲绮（高马尾，红色劲装外罩轻甲，握十字戟）站在坡顶望着远处洛阳城的北门，北门正缓缓打开，门洞里冲出的第一匹马是火红的赤兔；北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）站在她身后半步；郭嘉（被抬在软榻上，裹着裘衣）和张辽在一旁看着",
    "n11_tuishou": "黄昏的邙山，两面山坡隔着一片战场：这边山坡上北线主角（束发，河北风格旧鱼鳞甲，骑马抬手揉太阳穴、不提长枪）骑在马上，赵云（白袍银甲）带着常山铁骑殿后正回头；对面山坡上同时竖着「吴」「曹」「吕」三面旗，旗下南线主角（短发寸头，古铜色旧甲，抬手揉太阳穴、不扛大刀），两人五官一模一样；北军队伍正往东撤",
    "n11_guanzhang": "许昌城门外的初冬清晨：关羽（红脸长须，绿袍金甲，盔缨断了一截）把青龙偃月刀横着放在北线主角（束发，河北风格旧鱼鳞甲，双手空着、不带长枪）面前的地上；张飞（黑脸大汉，眼睛哭肿了）站在他身后；城门口诸葛亮（素服，手里没有羽扇）站在卫兵中间；一队残兵打着赤底「汉」字旗",
}


# hand-written prompts that replace the template for a key (e.g. the owner's own prompt for a scene).
# They stay here after the art exists (ART-PROMPTS.md only lists what is still missing), so a redraw starts from the same prompt.
# chapter map backgrounds (quest id -> what the scroll shows, left to right); the game scrolls it sideways under the squares
MAPS = {
    "tianfu": "【地图共 44 列，南线第九章·天府之国】自左向右依次：①（第 0–6 列）春雨里的汉水岸边与楼船、下游的芦苇荡和渡口、长江三峡的巫峡栈道、白帝城；②（第 7–9 列）瞿塘峡口夔门的铁索与水寨、巴东的山口栈道；③（第 10–17 列）江州城（两江交汇）、城外的码头和水门、城外的营地；④（第 18–25 列）金雁桥、雒城、绵竹关、成都城里的酒肆（两列）、成都平原的田野与锦官城；⑤（第 23–27 列）都江堰、成都行辕、城西的大营和茶馆；⑥（第 28–35 列）南中的瘴林、泸水渡口、蛮洞；⑦（第 36 列以后）盘蛇谷：两侧陡崖、谷口的火光",
    "sanfang": "【地图共 28 列，北线第十章·再战虎牢】自左向右依次：①（第 0–3 列）黄河北岸的渡口与渡船、白马津滩头、延津渡口的拒马泥滩、官渡大营前的河滩；②（第 4–9 列）黄河以南的官道、许县城外返青的麦田与屯田水渠、许都北门吊桥、许都城墙与城门（于禁的「于」字旗）；③（第 10–12 列）许都辕门外排队投奔的人群、颍水码头与甄家运粮船队；④（第 13–19 列）中牟道上的鹿角营垒、荥阳山道的弩阵、曹仁的连营大阵、陡峭险峻的虎牢关与关前大营、霹雳车高坡；⑤（第 20–27 列）分上下两路：上半（火船计）是黄河与洛水交汇处的巩县渡口、铁锁连起来烧着的火船、芦苇滩边的商船、旋门山道、前后夹击火光冲天的虎牢关西门；下半（洛水偷袭）是夜雾弥漫的洛水河道、偃师峡口横江的铁索与两岸火把、黎明时分飘着薄雾的洛水浅滩（到第 24 列为止）",
    "tianqing": "【地图共 29 列，北线第十一章·洛阳天倾】自左向右依次：①（第 0–3 列）秋天的虎牢关楼、偃师道、首阳山上的曹营和霹雳车；②（第 4–7 列）巩县渡口的甄家漕船、黄河北岸的河阳城与温县谷田、孟津北岸张辽、太史慈会师的大营；③（第 8–14 列）黄河孟津渡口与对岸的北邙山、夜里对岸洛阳城西的冲天火光、晨雾里靠岸的小船、孟津北岸的中军大帐；④（第 15–17 列）孟津南岸渡口（典韦站着死去的木桩）；⑤（第 18–28 列）分上下两路：上半（交印）是洛阳北门、烧了一半的南宫、西城箭楼、伊阙道与伊阙关、夜里北宫大帐的一支残烛；下半（扣下诸葛亮）是邙山的曹军残营、邙山山道、黄河南岸的河滩、往东撤的大路、初雪的许昌城头",
    "beifa": "【地图共 14 列，南线第十二章·北伐】自左向右依次：初春雪化的洛阳北宫、偃师道、荥阳城、许昌城墙（于禁的「于」字旗）、中牟道与官渡道、官渡南营、乌巢粮仓、官渡土山与黄河边的北军壕沟、深夜的中军帐",
    "chibi": "【地图共 23 列，南线第十二章·赤壁】自左向右依次：水印未干的南阳宛城、鲁阳道与博望坡、烧着的宛城粮仓、新野与襄阳道、长坂坡、长江、夏口城与江边、乌林的北军营火、铁索连船的江面、火光冲天的赤壁、天亮后漂满焦船板的江面、重修的洛阳南宫",
    "guandu": "【地图共 20 列，北线第十二章·官渡】自左向右依次：初春的许昌城、颍水、中牟道、官渡道、黄河南岸官渡的三道壕沟与甄家粮船、壕沟对面的南营与土山、乌巢、夜里烧起来的南营、壕沟前的乱兵、烧焦的中军帐、重修的洛阳南宫",
    "dujiang": "【地图共 15 列，北线第十二章·渡江】自左向右依次：春天洛阳城外南下的大军、伊阙、鲁阳道、宛城、新野与襄阳道、汉水江面、江陵病帐、江陵江面的甄家船队、乌林江岸、长江上的楼船、渡江前夜的中军大帐",
    "guiyi": "【地图共 10 列，南北第十二章·天命归一】自左向右依次：冬天的洛阳长街（两边各一面大旗）、南宫与宫城墙头、南宫台阶、两边营地之间飞过的响箭、深夜的太极殿广场、太极殿下的青铜地宫、白光、清晨的太极殿台阶",
    "luoyang_s": "【地图共 46 列，南线第十一章·洛阳天倾】自左向右依次：①（第 0–3 列）秋天长安往东的弘农道、函谷道的窄谷与函谷关；②（第 4–7 列）渑池的山谷、新安以东谷水边的会师营地、邙山脚下远望洛阳；③（第 8–12 列）洛阳城西插黑底「魏」字旗的曹营与霹雳车、城门前的乱石八阵、城外的营地；④（第 13–19 列）白马寺、邙山古冢、城东插赤底「汉」字旗的刘营、营前护城河上的小木桥、城东南关羽的营；⑤（第 20–28 列）曹营辕门、谷水边的村子、洛水岸边、夜里的营地；⑥（第 29–35 列）着火的曹营、洛阳宫城的南宫、上东门、我军的辕门；⑦（第 36–45 列）分上下两路：上半是洛阳城内的南宫、北门外的邙山、黄河孟津渡；下半是黎明的洛水河滩、洛阳城头的箭楼、伊阙山口、冬日泡过水的南阳宛城",
    "guanzhong": "【地图共 46 列，南线第十章·奇袭关中】自左向右依次：①（第 0–2 列）春天的成都城外与金牛道的栈道、葭萌关；②（第 3–6 列）阳平关外的山梁营寨、贴着秦岭绝壁的阳平关；③（第 7–12 列）汉中盆地：南郑城、五斗米道的义舍、米仓山里被挖开的古墓；④（第 13–15 列）汉中的星夜、定军山、南郑的大堂；⑤（第 16–21 列）秦岭：上半是子午谷钉在绝壁上的栈道和谷口外的平地，下半是散关、故道的悬崖栈道和陈仓小城；⑥（第 22–28 列）渭水河滩、长安城外的大道与西门；⑦（第 29–34 列）长安城里：未央宫前的长阶、尚书台、东边的潼关和黄河；⑧（第 35 列以后）武关道、峣关、蓝田的山林连营（被火烧过）、灞水",
    "longhu": "【地图共 38 列，北线第八章·北海龙虎】自左向右依次：①（第 0–6 列）夏天的邺城行辕、青州官道与集市、平原城下、渤海南皮城下；②（第 7–12 列）易水、涿郡、渔阳的荒原、雪中的蓟城、中山卢奴城的城门、下雪的蓟城厅堂；③（第 13–19 列）雪夜的蓟城城头、南下的雪中官道、泰山道、青州驿站、北海城东的林子、北海西门；④（第 20–25 列）北海城外的雪原与霹雳车、北海城下、夜里起火的西门；⑤（第 26–31 列）夏天的黄河：渡口、渔村、盐仓、对岸的「马」字大营、河滩上的篝火",
    "xiliang": "【地图共 34 列，北线第九章·西凉喋血】自左向右依次：①（第 0–4 列）春天的北海郡府、中山的官道与村子、被围的无极甄家粮行、卢奴城；②（第 5–8 列）渤海道、盐场、南皮城、渤海的海边；③（第 9–16 列）夏天的黄河：仓亭渡口、渔村、对岸的西凉大营、夜里的芦苇荡、火光中的马营辕门、黎明的河滩；④（第 17–23 列）北海郡府的议事厅、秋天的卢龙塞、塞外荒原和干河道、柳城、白狼山；⑤（第 24–29 列）冬天的辽东：风雪官道、辽西山道、结冰的辽水、襄平城",
    "menghu": "【地图共 48 列，南线第八章·猛虎之陨】自左向右依次：①（第 0–4 列）冬天下雪的吴郡大营与辕门、吴郡南边的山道、曲阿城外的竹林和一扇柴门小院；②（第 5–12 列）丹阳的深山：云雾里的山口、毛竹林、山腰的竹寨、山坳里的谷仓、陵阳的山道和一座山神庙、猎户的木屋、山顶挂着兽骨的毛竹木寨；③（第 13–14 列）春天的吴郡大营，灯火通明，准备出兵；④（第 15–17 列）汉水的芦苇荡，锦帆快船和插赤底「汉」字旗的巡船；⑤（第 18–21 列）南阳道的官道和路边山林、一座破庙；⑥（第 22–27 列）暴雨中的汉水芦苇渡口、挂着「吴」字新旗的大船、雨后的荒村；⑦（第 28–33 列）夜里的篝火、汉水北岸的江滩、襄阳城；⑧（第 34–37 列）新野的田野、博望坡起火的山谷；⑨（第 38–43 列）白河上游的山林与营寨、白河两岸、上游的木闸；⑩（第 44–47 列）汉水北岸的乱石阵，南岸用铁索连成一排的楼船与营帐",
    "prologue_north": "winter Hebei, the road from the Zhen family's trading town to the Black Mountain bandit lair, left to "
                "right: a small stone-walled trading town under falling snow; a larger walled city with a government hall under a "
                "grey winter sky; an open snowy road through farmland with a lone wandering old Taoist glimpsed at the roadside; a "
                "narrowing mountain gorge climbing toward a firelit skirmish; at the far right the bandits' snow-wrapped cliffside "
                "stronghold on a mountain, smoke rising from its gate, with a path turning back south at its foot",
    "yuxi": "【地图共 61 列、6 行，南线第三章·传国玉玺；一张图，两条路线上下分层：上半幅（第 0–2 行）是路线 B，下半幅（第 3–5 行）是路线 A，最左端第 0–1 列是共用的洛阳废墟】自左向右：①左端洛阳废墟冒着黑烟，难民队伍南行（第 0–4 列，山匪劫道的路口）；②之后分两条路线，上下两层互不相连（分叉处用一道山岭或河流隔开）：【路线 A·鲁阳线，下半幅（第 5–30 列）】山丘间断粮的孙坚军营、鲁阳城墙与酒肆街、雨水浸透的农田与袁术军营、最右端大雨中的狭窄山口；【路线 B·洛阳与长安，上半幅（第 5–60 列）】重建中的洛阳（灰烬篝火、西行官道、红底「孙」字旗的城头、太平集市，约第 5–29 列），再向西到冬日长安（宏伟城门、董卓府邸与比武场、书生宅、司徒府、荷塘边的凤仪亭，最右端挂满红灯笼的丞相府，约第 30–60 列）",
    "jingxiang": "【地图共 31 列，第五章·荆襄风云】自南阳向南到汉水，自左向右依次：①秋日宛城，院中的灶台与河边的栗子摊；②芦苇丛生的淯水与战场；③汉水渡口，挂锦帆的战船；④新野一带的坞堡与樊城小镇；⑤汉水边的襄阳城，有兵库与停满战船的水寨；⑥种着梯田的岘山；⑦最右端万山上江边岩石上的一座孤亭",
    "dongui": "【地图共 37 列，第四章·挟天子】一条长征路，自左向右依次：①雪中的长安宫城与宣平门；②渭水东行的大道；③群山与函谷关；④插着红底「孙」字旗、半修复的洛阳；⑤向南的夏日官道；⑥袁术军营；⑦最右端南阳宛城的城墙",
    "heishan": "【地图共 40 列，北线第三章·黑山风云，三条行进带：上=战斗线，中=主线，下=奇遇线】自左向右依次：①左端（第 0–6 列）真定县城与城外小路，城墙下贴着发榜的告示，军营里一名兵痞在闹事，旁边是校场；②（第 7–14 列）进入太行山：山道、采药人的小屋、深山绝壁，一处悬崖下有白马与人影；③（第 15–22 列）黑山大寨：木寨、演武场、寨中集市，大寨议事堂挂着黑山令；④（第 23–30 列）山中秘道与狭窄的峡谷，太行山口的关卡；⑤（第 31–39 列）界桥外围的原野，河畔的营垒，最右端是插着黑白条纹大旗的战场。整体冬末春初，山色青灰",
    "beihai": "【地图共 48 列，北线第四章·双凤乱太行，三条行进带：上=战斗线，中=主线，下=奇遇线】自左向右依次：①左端（第 0–12 列）太行外围，山寨与郑家寨、姜家寨隔山相望，两寨之间是山谷；②（第 13–24 列）太行休整营地，北方来的并州狼骑在山口扬尘，吕布的旗号隐约可见；③（第 25–31 列）突围：苇荡深处的河湾，冀州军追兵的营垒，黄河渡口；④（第 32–47 列）北海城：被黄巾军围困的城墙，城外黄巾的营帐与饥民，城门前支着熬粥的大锅，最右端是北海相府。整体夏季，色调偏暖",
    "taodong": "the march north to fight Dong Zhuo, left to right: country roads and farmland leaving the south; a dusty Central-Plains "
               "highway with a burnt village; the battlefield before Sishui Pass where Hua Xiong fought (a mountain gap with a watchtower); "
               "Sun Jian's big army camp with palisades, tents and red banners; a barren windswept wasteland (Hulao Pass, where the three "
               "heroes fought Lü Bu); and at the far right the walls of Luoyang burning at dusk, smoke rising into an ember sky",
    "huainan_s": "【地图共 54 列，南线第六章·淮南折帝旗】自左向右依次：⓪（最左 6 列）荆南四郡：春日山路，零陵山口的坞堡、桂阳山林里的宗贼寨、长沙城门洞与郡守府门前的老槐树；①冬日的襄阳城与汉江水寨；②顺江东下的长江江面；③庐江舒县，周家庄园与大粮仓、半边焦黑的陆家旧宅；④居巢，鲁肃家的两座大粮仓和田埂；⑤皖城与江边驿馆、乔家的画舫；⑥皖城太守府；⑦云雾里的灊山（天柱山），山腰上的雷家木寨，山下流过皖水；⑧巢湖，湖心洲和破旧的龙王庙；⑨濡须口；⑩淝水上用铁索连起来的楼船；⑪寿春南门的水寨与淮水浮桥；⑫寿春城外荒凉的江亭；⑬回到庐江的江岸，江边挂着红绸（双婚在第七章）",
    "jiangdong": "【地图共 41 列，南线第七章·江东小霸王】自左向右依次：⓪（最左 1 列）庐江张灯结彩的喜堂；①长江口与秋天的牛渚渡口、刘繇的营垒；②神亭岭的山坡连营；③秣陵城；④浩渺的太湖，芦苇荡、被烧过的渔村、水匪的快船；⑤吴郡城与太守府；⑥太湖深处挂着铜铃的锦帆水寨和挂「德王」匾的严家水寨；⑦吴郡城外的渔村；⑧丹徒山的密林；⑨会稽城、山阴道与查渎小道；⑩春天的富春江与孙家老宅",
    "xuzhou": "【地图共 39 列，北线第五章·铁纪徐州】自左向右依次：①（第 0–4 列）夏天的北海城门、南下的官道、琅邪的山道与被屠的村子；②（第 5–13 列）下邳城外的山坡、泗水岸边、曹军后队、下邳城、刺史府；③（第 14–25 列）下邳的街巷与酒楼、糜府、泗水码头的盐船、下邳街头、陈家、陶府后堂；④（第 26–32 列）小沛城外的狼骑与陷阵营、小沛城门、下邳缟素；⑤（第 33–39 列）小沛的村子、陈先生别苑、东海道、冬天的下邳过年、城楼",
    "yecheng": "【地图共 38 列，北线第七章·邺城惊雷】自左向右依次：①（第 0–3 列）夏天的下邳城、泰山的山道与山口的「臧」字寨；②（第 4–8 列）下邳糜府、东海上的糜家船队、张灯结彩的下邳城、琅邪山道；③（第 9–14 列）春天的下邳刺史府、青州平原、北征誓师的校场与城东的别苑、太行山道；④（第 15–20 列）太行山里满山火把的合兵夜营、滏口陉的关隘与悬崖、雷雨中的邺城东门、邺城州衙与刺史行辕；⑤（第 21–35 列）漳水两岸：上半是漳水边的渡船、河北的渔村、葫芦谷与上游的旧堤、邺城的大牢、邺城招贤馆的后院、春天正在重修的无极甄府、春天的漳水码头；下半是邺城街巷、漳水渡口烧着的村子和一口枯井",
    "huainan_n": "【地图共 40 列，北线第六章·淮南折帝旗】自左向右依次：①冬日的下邳城与甄家后院的酒坊；②淮北渡口的哨卡与平原官道；③钟离城与洪泽湖的水道、糜家商船；④蕲阳城；⑤通往寿春的淮南小道；⑥寿春城下连绵的曹军营盘与东门；⑦城破后的寿春街巷与仲氏国库；⑧金碧辉煌的寿春宫与宫前的比武台；⑨淮水渡口与横跨河面的浮桥；⑩北归的官道",
}

# relic icons (cards.json relics id -> the object itself)
# Authentic ancient Chinese items, pure cut-outs on transparent backgrounds (no western circular medallion).
# Excluded lord/protagonist relics per user instruction: jiujia, hupi, qixing, zhaoxianbang, yitian, yuxi.
RELICS = {
    "jiujia": "孙坚旧甲：一副保养得一丝不苟的汉代古铜色鎏金札甲，护肩与胸甲浮雕云纹、金边勾勒，肩甲带细密的鳞片纹路，下摆内衬露出一角朱红战袍，肩甲边缘有岁月的磨损与几处旧刀痕，旁边叠着一件纯黑色披风一角",
    "hupi": "虎皮披风：一件孙坚同款的披风，整张金黄带黑纹的虎皮鞣制成披风形状，领口缀着一圈深色皮毛，用一根红色丝绳系住，边缘有磨损与缝补的针脚，披挂在木架上的样子",
    "qixing": "七星宝刀：曹操献刀用的那把短刀，汉代环首短刀，鎏金刀鞘上镶嵌着七颗排成北斗形状的宝石（红、蓝、绿相间），刀柄缠着黑色丝绳，半出鞘露出一截寒光凛凛的刀身",
    "zhaoxianbang": "招贤榜：一张贴在木板上的汉代告示，米黄色粗纸，上面是毛笔书写的大字榜文，盖着一方朱红印章，四角用铁钉固定，纸边微卷，旁边挂着一小串铜钱作为悬赏（文字用抽象的毛笔笔画表现，不要可读文字）",
    "yitian": "倚天剑：曹操的佩剑，一柄修长的汉代双刃直剑，剑身泛着青白色的寒光、带细密的云纹，鎏金剑格与剑首刻着龙纹，黑漆剑鞘配着红色丝绦，剑身上隐约有一线冷冽的光芒",
    "yuxi": "传国玉玺（诅咒）：一方青白色的玉玺，顶部盘着五条龙，缺了一角的地方用黄金镶补，印面朝上微露篆文，周身萦绕着一缕不祥的暗红色雾气，下面垫着一块旧黄绸",
    "lizigao": "一枚热腾腾的栗子糕（汉代风格的小点心）：切成方块的栗子糕，表面撒着少许糖霜与碎栗仁，放在一方折叠的浅粉色丝帕里，冒着淡淡的热气，丝帕一角绣着一个小小的甄字",
    "zhongshan_banner": "中山甄记大旗：一面略显破旧的大旗，赭红色底，中央用白色大字绣着「甄」，旗边缀着流苏与磨损的缺口，旗杆是深色的木杆，顶端带铜制矛尖",
    "shoushihe": "an exquisite Han dynasty Chinese lacquer jewelry box (汉代黑红髹漆妆奁), lid slightly ajar showing delicate jade hairpins, gold tassels and pearls inside",
    "jiunang": "an ancient Chinese gourd flask wine pouch (左慈酒葫芦/酒囊), polished leather and dried gourd with brass spout, wrapped in ceremonial red cord with a bronze coin charm",
    "shuijing": "an ancient Chinese Han dynasty round bronze mirror (汉代铜镜) with a polished face catching light, the back cast with cloud and water patterns and a knob with a silk tassel",
    "bingfu": "an authentic ancient Chinese Han dynasty bronze Tiger Tally (汉代错金铜虎符), cast in the shape of a crouching tiger with inlaid gold seal script characters on its back",
    "hushenfu": "a traditional Chinese silk protective amulet pouch (汉代朱砂平安符囊), triangular folded cinnabar red silk embroidered with gold cloud patterns, bound by silk cord with a jade bead and red tassels",
    "xiangnang": "an authentic Han dynasty Chinese embroidered scented sachet (汉代刺绣茱萸香囊), rhombus-shaped silk pouch with gold thread floral embroidery, tied with a traditional Chinese mystic knot (同心结) and dual crimson silk tassels",
    "jinfan": "Gan Ning's Brocade Sail Bells (甘宁锦帆铃), two ornate ancient Chinese bronze ringing bells with incised wave patterns, bound together with a vibrant flowing patterned brocade silk ribbon",
    "bingfa": "an ancient Chinese bamboo scroll book of Sun Tzu's Art of War (孙子兵法竹简), aged brown bamboo slips bound with leather cord, partially unrolled to reveal brush-inked clerical script calligraphy, paired with a small bamboo calligraphy brush",
    "gudingdao": "Sun Jian's ancient broad-bladed saber with a ring pommel (古锭刀), an authentic Han dynasty ring-pommel broad saber (环首刀) with brass cloud-pattern fittings and a black-lacquered wood scabbard with red tassels",
    "yushan": "Zhou Yu's crane feather fan (周瑜白鹤羽扇), pure white crane feathers neatly arranged, bound with a carved pale green jade handle and silk tassel",
    "zhangu": "a Han dynasty Chinese red-lacquered war drum (汉军战鼓), heavy cowhide drumhead, ornate dragon brass studs on the drum rim, resting beside a pair of wooden drumsticks wrapped in red cloth",
    "chize": "Sun Jian's red headscarf (祖茂/孙坚赤帻), a bold crimson silk warrior turban cloth with battle wear and scorched edges, tied with a knot",
    "qinggang": "the legendary Qinggang Sword (青釭剑), a pristine double-edged Chinese straight sword (汉剑) of tempered blue-tinted steel, intricate brass guard with dragon engravings and dark lacquered scabbard",
    "bazhen": "Zhuge Liang's Eight Trigrams Formation scroll (八阵图), an antique silk map scroll spread open showing painted bagua diagrams, stones, and tactical compass markings in vermilion and ink",
    "dunjia": "Zuo Ci's Book of Dunjia (遁甲天书), an ancient mystical Taoist silk-bound tome with archaic seals, faint golden light, and paper talismans tucked between the aged pages",
    "muniu": "the Wooden Ox (木牛流马), an ingenious ancient Chinese mechanical wooden transport in the stylized shape of a carved wooden ox with bronze gears and levers",
    "beishui": "an ancient bronze three-legged cooking cauldron (破釜) with chipped rim and battle scratches, beside a charred burning ship plank",
    "dingxin": "an ancient Chinese medicinal pill box (定心丸), carved dark cinnabar lacquer box containing a gleaming golden herb-rolled pill on yellow silk lining",
    "jubaopen": "the Treasure Basin (聚宝盆), an ornate Han dynasty bronze and gilt basin filled with sparkling sycee silver ingots (元宝), gold nuggets, and antique coins",
    "chitu": "Red Hare's ceremonial golden saddle and bridle (赤兔金鞍缰辔), an opulent warhorse saddle of crimson leather and gilded bronze fittings, with ornate brass stirrups and red plume bridle",
    "zhangba": "the blade head of Zhang Fei's Eighteen-foot Snake Spear (丈八蛇矛), undulating wavy steel spear blade shaped like a writhing serpent, with a black steel socket and crimson horsehair tassel",
    "zhugenu": "Zhuge's Repeating Crossbow (诸葛连弩), an ingenious Han dynasty wooden multi-shot crossbow with top-mounted bolt magazine and bronze firing mechanism",
    "qinglong": "the head of Guan Yu's Green Dragon Crescent Blade (青龙偃月刀), heavy steel curved glaive blade with an engraved green dragon swallowing the steel base, adorned with a brass dragon collar and crimson tassel",
    "mengde": "Cao Cao's New Book of Mengde (孟德新书), a fine silk-wrapped bamboo scroll case and unrolled bamboo slips bearing Cao Cao's military commentary and vermilion personal seal",
    "heishan": "the Black Mountain Command Token (黑山令), an imposing dark iron and bronze pass token engraved with a fierce coiled dragon and archaic Chinese characters, tied with rough braided rope",
    "taipingyaoshu": "Zhang Jue's Essential Art of Great Peace (太平要术), ancient scrolls bound in yellow silk, covered with vermilion Taoist incantations, thunder talismans, and celestial diagrams",
    "qingnang": "Hua Tuo's Green Pouch Book (青囊书), a weathered green brocade medicine scroll bundle tied with leather cords, accompanied by silver acupuncture needles and dried healing herbs",
    "huangjinfu": "a Yellow Turban Talisman (黄巾符), yellow hemp paper talisman inscribed with cinnabar red mystical Daoist spell script, singed by lightning and smoke at the corners",
    "dilu": "Hex Mark's silver stirrup and bridle (的卢辔饰), refined white leather and silver-inlaid bridle and bit with tear-shaped silver ornaments and blue tassels",
    "fangtian": "the head of Lü Bu's Sky Piercer Halberd (方天画戟), a formidable four-pointed spearhead flanked by dual polished crescent moon side blades and red battle tassels",
    "tengjia": "the Southern Rattan Armor (藤甲), woven impenetrable dried wild mountain vine breastplate, treated with oil and bound with brass rivets",
    "wentai_shu": "一封汉代家书：卷起的帛书系着一根红绳，字迹又大又歪、墨迹洇透纸背，旁边压着一块洛阳点心",
    "zhou_pu": "一卷汉代竹简族谱，用青色丝绳编连，竹简上刻着工整的家族世系，最末一片竹简颜色明显更新",
    "weixi": "一方假玉玺：通体洁白的玉印，印钮雕成盘龙，刻工极其精细，印面朱红，底座裂了一道细纹",
    "xuzhou_yin": "一方汉代徐州牧铜印，印钮为龟形，系着紫色绶带，印面朱红",
    "mijia_chuan": "一艘精致的汉代商船模型，船帆上绣着一个「糜」字，船舱里堆着盐包",
    "dujiu": "一只粗陶酒坛，坛口用红布和麻绳封着，坛身贴一张写着「杜」字的红纸，旁边一把竹酒提",
    "chen_mago": "一叠写满字的竹简与帛书草稿，字迹潦草激愤，边角卷起，被人用丝绳仔细捆好，像要裱起来收藏",
    "xunyou_qizi": "一枚汉代墨玉围棋子（荀攸的黑棋）：饱满圆润的墨黑色围棋子，表面带有细腻油润的黑玉光泽与天然石纹，斜放在一方古朴的暗黄色羊皮行军舆图残卷上",
    "bandu_lingjian": "一支汉军铁血令箭（黄忠的半渡令箭）：朱红漆木削制的汉代军中令箭，铜铸兽首箭首，箭尾插着三支凌厉鲜艳的赤红雕羽，系着朱红丝绦流苏",
}


# ？ event illustrations (event id -> scene); shown full-screen when the event comes up, like a story CG (key e_<id>)
EVENTS = {
    "m8_yufu": "汉水芦苇荡里漂着一条小渔船，船上的白发老渔夫咧嘴笑着，指着腰挂铜铃的甘宁（二十多岁的悍勇青年，背一张大铁胎弓）；船板上用炭画着三条水道",
    "m8_taobing": "路边的草堆里，一个穿曹军号衣的年轻小兵扔了枪跪着，满脸是泪；吴景（三十多岁的白马将军，短须，一脸警惕）骑在马上低头看着他",
    "m8_liumin": "汉水边挤满了从南阳逃出来的流民，拖家带口等船；黄忠（四十来岁的壮实军汉，背着硬弓）在人群里一个一个看过去，神情焦急",
    "m8_gaoshi": "荆北路边的一棵大树，树干上贴着一张赤底黑字、盖着「汉」字大印的告示，底下按着好几个红手印；孙策（二十出头的英武青年，红色头巾）伸手要撕，孙权（十八九岁的成年青年，碧眼紫髯，抱着账册）在一旁皱眉细看",
    "t9_qianfu": "三峡的江边，一群光着脊梁的纤夫弓着腰拉船，号子声震天；一个白发老纤夫回头，指着上游的滩",
    "t9_shujin": "锦官城的街上，一个蜀锦商人捧着一匹鲜红的蜀锦追着短发的主角（穿素色常服，不穿盔甲，双手空着、身边没有任何刀剑兵器）；远处孙尚香（十九岁的成年女子，一身红甲，英气明艳）和吴苋（成年女子，淡青蜀锦衣裙）一起看过来",
    "borrow_general": "孙坚大帐前：孙坚指着帐外一排老将，程普、韩当、黄盖、朱治、吴景、孙贲依次站开，个个一身旧伤，眼神沉稳；主角站在帐门口，吴景的目光紧紧盯着他",
    "hand_over": "盟主大营的辕门外：一辆囚车正缓缓驶出，车内的董白（成年女性）回头望了一眼，神情复杂，什么也没说；孙策站在远处沉默地看着，营门口挂着盟旗",
    "ln_boater": "结冰的黄河渡口：一位满脸风霜的老艄公撑着小渡船，压低声音收船钱，船上堆着几袋货物；河面上漂着浮冰，天色阴沉",
    "ln_wine": "酸枣大营外的酒摊：精明的摊主（四十岁上下，围着围裙）正笑眯眯地倒酒，摊上摆满酒坛，远处是诸侯各色旗帜的营帐；食客与士兵三三两两",
    "lvbu_beaten": "虎牢关下：吕布退入关内，关前一片狼藉；十八路诸侯与士兵争相举杯向主角敬酒，袁绍起身让座，孙坚拍着主角的肩膀；远处一个个子不高、端着酒杯的人（曹操）捋着胡须，静静打量主角",
    "lvbu_beaten_n": "酸枣大营中央：袁绍派人送来一面「义薄云天」的锦旗，诸侯们围观；曹操（个子不高，捋须）负手站在一旁，盯着那面破旧的「中山甄记」大旗；郭嘉举着酒葫芦遥遥敬了他一下",
    "old_armor": "吴夫人的房间里：吴夫人打开一只樟木箱，里面是古铜鎏金的旧甲、朱红战袍和纯黑披风，她亲手给主角系上甲带；孙策站在门口目瞪口呆，周瑜在一旁翻着账本",
    "risk_n": "风雪弥漫的悬崖险沟前：向导缩着脖子指着狭窄陡峭的山沟，主角和同伴们勒马站在崖边，雪片遮天；险沟深处暗藏着隐约的伏兵剪影",
    "taihang_bear": "太行山深林里：一头壮硕的黑熊拦在小路中间，鼻子不住地抽动；赵云抬手按住主角的肩膀，示意别动，主角腿软地缩着脖子；雪后的松林",
    "taihang_hunter": "雪地里：一位背着柴火的猎户让到路边，怀里护着一只挣扎的锦鸡；甄宓（十几岁的少女）凑过去看，眼睛发亮，郭嘉在一旁打着哈欠",
    "zhen_caravan": "官道上：一支挂着「甄」字旗的商队停在路边，管事下马向张夫人行礼，张夫人（成年女性，富态精明）手指在账本上划拉，郭嘉在旁笑着凑过去",
    "zumao_saved": "汜水关下：华雄刚被一把飞刀击中后脑栽下马，祖茂（老将）拄刀站起，摘下头上的赤帻双手递给主角；孙策正举枪补刀高呼「华雄已死」，周瑜在后面记账",
    "shuijing": "a thatched hut in a bamboo grove: the genial hermit Sima Hui sitting at his door with a round bronze mirror, smiling and nodding 'good, good'; young Sun Ce leaning in eagerly pointing at the short-haired hero",
    "pangdegong": "fields at the foot of Mount Xian by the Han river: the old recluse Pang Degong leaning on his hoe, his wife bringing a lunch basket along the field ridge, both bowing to each other politely; the short-haired hero watching, oddly uneasy",
    "huangchengyan": "a riverside workshop on the Mian river: the grey-bearded inventor Huang Chengyan crouching beside a little self-walking wooden cart; the short-haired hero staring at it in amazement",
    "ganning": "a brocade-sailed fast boat rowing up the Han river: the young pirate Gan Ning (early 20s, cocky grin, bronze bells at his waist, a great bow on his back) on the prow shouting at the shore, come down from Ba commandery to look Jingzhou over; Zhou Yu on the bank clutching his ledger and purse",
    "biwu": "a red-silk fighting stage at a village entrance with a sign 比武招亲, a cheerful adult woman in pale-green armor spinning a spear on it, defeated suitors in a row, Sun Ce rolling up his sleeves while Zhou Yu grabs his collar",
    "ambush": "river bandits bursting out of tall reeds with gongs and rusty sabers, shouting",
    "snake": "comic scene: the short-haired hero hopping on one leg clutching his thigh, a small green bamboo viper slithering away, Sun Ce and Zhou Yu doubled over laughing",
    "tiger": "a white-browed tiger lounging on a rock on a mountain road, lazily licking its paw, staring at the viewer",
    "zuoci": "a white-haired old Taoist grinning with two front teeth, sitting on a boulder with a bamboo staff, purple smoke curling from a gourd in his hand",
    "chest": "a rusty iron chest half-buried by the roadside, carved with four small characters 非礼勿开",
    "hero": "a burly man in a roadside tavern smashing a table with one fist, wine cups flying, drinkers scattering",
    "refugees": "a column of ragged refugees on a dusty road, an old man collapsed, a mother holding a child out toward the viewer",
    "washer": "a cheerful adult woman washing clothes at a mountain stream, sleeves rolled up, laughing, a basket of cloth beside her",
    "dice": "river bandits gambling with dice on a broken boat by the river, waving the viewer over",
    "fruit": "a tree heavy with glossy red fruit by an empty road, Zhou Yu raising a warning finger",
    "risk": "a small boat in thick river fog, an old boatman squatting at the bow smoking a long pipe, dangerous rapids ahead",
    "temple": "a crumbling mountain temple with a noseless earth-god statue, half a stick of incense still smoking in the censer",
    "grand_chest": "a big gilded chest carved with the character 袁 in an army camp, a pompous lord forcing a smile",
    "huangxu_sick": "a quiet army camp at dusk: Huang Zhong (middle-aged, stout, yellow leather armour with a blue war-robe) bowing deeply with both hands out, a heavy bow offered in thanks; before him Hua Tuo (lean middle-aged doctor, medicine box painted 沛国华佗) shouldering his box; in the foreground Huang Xu (a thin teen archer in a plain robe, just out of his sickbed, gripping his father's old bow) standing up from a cot, a little colour back in his face; the hero in plain everyday robes smiling",
    "huatuo": "a lean middle-aged doctor treating a village woman at a roadside medicine stall, his box painted 沛国华佗",
    "yuji": "a Taoist in white blocking the road, waving a banner reading 于吉仙师 符水治百病, followers kneeling",
    "merchant": "a plump merchant with a donkey cart piled with exotic goods, spreading his arms in welcome",
    "smith": "a roadside smithy with a roaring forge, a bare-chested old blacksmith hammering a glowing blade",
    "tomb": "a half-collapsed ancient tomb in a mountain hollow, cold wind from the entrance, Sun Ce stepping in eagerly while Zhou Yu checks his ledger",
    "guanlu": "a young diviner at a fortune-telling stall under a tree, sign reading 管辂神算",
    "xushao": "the famous critic Xu Shao holding court under a tree by the roadside, a crowd of hopeful men waiting for his one-line verdicts",
    "qiao": "two beautiful adult sisters washing clothes by a river, one gentle and one lively, Sun Ce and Zhou Yu frozen mid-step staring",
    "drink": "a tavern drinking contest: Sun Ce slamming a wine jar on the table, a crowd of drinkers circling and cheering",
    "deserters": "ragged deserters without armour crouching by the road gnawing bark, shrinking back in fear",
    "storm": "a sudden thunderstorm turning a road into mud, the army struggling through the rain",
    "horse": "a horse dealer holding the reins of two horses — a white-faced one with an ominous look and a fiery red one",
    "convoy": "a few Xiliang soldiers escorting grain carts with sacks stamped 董 along a road below a hill",
    "surrender": "a small group of men in yellow headscarves carrying a white flag, kneeling on a road",
    "shanzei": "a one-eyed bandit with a big axe jumping out at a mountain bend, his gang behind him",
    "shanzhai": "a mountain bandit fort with a tattered 替天行道 banner, smoke of roasting meat rising, Sun Ce swallowing",
    "jieying": "a night camp raid: dogs barking, a wall of torches coming out of the dark",
    "hj_camp": "a Yellow Turban remnant camp in a valley: old people, children and women around a pot of wild greens, thin smoke",
    "hj_medics": "a ruined temple where a woman in a yellow headscarf cleans a wounded soldier's wound, a Taiping talisman on her medicine box",
    "hj_road": "Yellow Turban remnants charging out of a forest with sticks and bamboo spears, shouting",
    "yuan_tax": "a roadside toll shed where two soldiers in Yuan livery block the road with spears, demanding rice",
    "black_market": "a narrow alley at night lit by a green lantern, a masked man opening his coat full of stolen treasures",
    "jz_spy": "a suspicious peddler caught at a city gate, a map of the city defences falling out of his carrying pole",
    "veterans": "two old soldiers, one missing an arm, sunning themselves at a city gate and recognising Sun Ce with joy",
    "plague": "a village entrance hung with white cloth, an old doctor raising his hand to stop the viewer",
    "yuxi_rumor": "a crowded teahouse, everyone whispering behind their hands",
    "tongyao": "children clapping and running along a road singing, in the background the silhouette of a huge fat man",
    "zhuhou_yan": "an envoy presenting an invitation card from the allied commander's camp, banquet tents in the background",
    "hn_cangtou": "舒县城外一座被搬空的义仓，满头白发的老仓头抱着一把旧算盘坐在空仓门槛上，年轻的周瑜站在他面前愣住了；地上散落着几粒谷子",
    "hn_longwang": "巢湖边一座破旧的龙王庙，香炉里青烟袅袅，泥塑的龙王披着褪色的红袍，供桌上一只装满铜钱的香油钱箱；少年将军孙策跪在蒲团上磕头，湖面雾气弥漫",
    "hn_qianshan": "灊山云雾缭绕的山道上，背着柴担的老樵夫拄着扁担，指着远处山腰上冒着炊烟的贼寨；主角顺着他指的方向望去",
    "hn_shizhe": "军帐中，一个风尘仆仆的洛阳信使捧上一只精致的食盒，盒里是洛阳点心，盒盖上压着一张字迹又大又歪的字条；少年将军孙策伸手就要拿，被主角一把拦住",
    "xz_shiji": "下邳热闹的市集，摊位上摆满东海的鱼、彭城的布、淮南的茶；少女甄宓（十几岁的孩子）拉着主角的袖子，指着一个卖泥老虎的摊子",
    "xz_shangchuan": "泗水码头上停着一排大商船，船帆上绣着「糜」字；糜芳站在船头冲岸上招手，船上堆满盐包和货箱",
    "xz_yanchang": "东海边白花花的盐场，盐工们在烈日下翻盐；张夫人（成年女性，富态精明的贵妇）蹲下来捏起一撮盐尝味道",
    "jd_yucun": "太湖边一个被烧毁的渔村，只剩几根焦黑的木桩和半截渔网；一个白发老渔翁蹲在灰里翻找东西，抬头对周瑜（年轻俊朗的谋士，手捧账本）说话；远处湖面上漂着一条不挂旗的船",
    "jd_yanchuan": "江面上漂着一条没人的盐船，船头插着一面「严」字小旗，舱里的盐包堆得比人还高；孙策（少年将军）站在岸边眼睛发亮，口水都快流下来了；主角在一旁挠头",
    "hnn_liumin": "淮北的官道边挤着一群从寿春逃出来的流民，面黄肌瘦；张宁（成年女性，素白布衣、背着竹药箱的医女）蹲下来给一个孩子把脉；远处天边是寿春城的方向",
    "hnn_shuili": "淮南的路口，一个穿着崭新官服的仲氏税吏举着一卷黄绢拦路，身边摆着一只税箱；郭嘉（醉醺醺的青年谋士，提着酒葫芦）凑过去眯着眼看黄绢上歪了的玉玺印，税吏一脸心虚",
    "xz_shuzhai": "陈家的书斋里书堆得比人还高，老人陈珪（六十多岁，精明的老狐狸，笑眯眯）坐在书堆中间，对着主角伸出一根手指出题",
    "xz_liumin": "官道边一群逃难的徐州百姓坐在路旁，张宁（成年女性，清秀医女）蹲下来给一个发烧的孩子施针，旁边的老人拉着她的衣角",
    "n10e_fuchuan": "洛水浅滩上搁浅着几条大肚木船，老船工蹲在船头抽旱烟；甄宓（二十出头的成年女子，淡蓝衣裙）站在岸边指着船身那道浸水的白印子，北线主角在一旁俯身细看",
    "n10e_yingchuan": "许都城外的官道旁，一辆陷在泥坑里的牛车上堆满竹简，一个四十来岁的颍川老学究正对着北军的布告摇头叹气；郭嘉（二十多岁的清瘦谋士，灰蓝长袍）笑吟吟地上前拱手搭话，远处几名并州游骑的影子在林边闪过",
    "n11e_baima": "秋天洛阳城外烧了一半的白马寺废墟里，一个老僧拿着扫帚扫地；断墙下埋着几坛泥封的旧酒坛；郭嘉（清瘦谋士，裹着裘衣）蹲下来闻酒坛，郭照（少女，背着药箱）在旁边叉着腰瞪他",
    "n11e_bingzhou": "邙山脚下的破庙门口，十几个饿得眼睛发绿的并州旧部蜷在庙檐下，破旧的狼骑甲胄；吕玲绮（少女将军，高马尾，红色劲装）站在庙门口，十字戟拄在地上，沉默地看着他们",
}
# 天命 pictures (cards.json fates id -> symbol); godot/data/art/fates/<id>.png, shown on the 天命 pick
FATES = {
    "jiangxing": "a brilliant general's star blazing above a Han helmet on a battlefield at night",
    "tiebi": "an iron wall of interlocking Han shields, arrows bouncing off",
    "bingduo": "a sea of banners and spears stretching to the horizon",
    "shenji": "a tactician's hand placing a black go stone on a battle map, glowing lines spreading",
    "tianshi": "a sundial and a bronze water clock under a turning sky",
    "renzhe": "a pair of hands offering a bowl of rice and a bandage to a wounded soldier",
    "caiyun": "a bronze coin tree heavy with golden coins and ingots",
    "xiansheng": "a war drum struck with a shockwave of sound, war cries",
    "jixing": "a lucky star and five-coloured auspicious clouds",
    "beishui": "broken cauldrons and a burning boat at a riverbank, soldiers facing the enemy with no way back",
    "luanshi": "a blood-red sky over burning cities, fortune favouring the bold",
    "jijin": "cavalry charging forward at full gallop in a blur of speed",
}
# 词缀 badges (cards.json battle.affixes id -> symbol); godot/data/art/affixes/<id>.png, shown in the battle info
AFFIXES = {
    "jianjia": "a heavy armour plate",
    "fayu": "a Taoist ward talisman glowing blue",
    "kuangbao": "a roaring red beast face",
    "houxue": "a thick red heart-shaped shield",
    "zaisheng": "a sprouting green herb",
    "xunjie": "a winged boot / swift wind swirl",
}
# full-screen UI pictures: godot/data/art/ui/<key>.jpg
UI_ART = {
    "title": "the title screen: a wide panoramic scene of the Three Kingdoms era at dawn — the Yangtze river in the foreground with a small boat, the young short-haired hero in bronze-gilt scale armor over a crimson robe with a plain black cloak and a huge broad-bladed sword on his shoulder (reference: pics/source/generals/lord_south_armor.jpg) standing on the bank looking north toward distant burning cities and banners; the sky split between warm sunrise and war smoke; leave the centre third of the frame calm and darker (the menu sits there)",
}


# 下一批（交给 Gemini）不再手写：每次运行都从游戏数据（cards.json / story.json / endings.json / interludes.json）里
# 算出「游戏正在用、但还没交付」的图，按下面的优先级排。游戏里没用到的图不会出现在这里。
# 优先级（越靠前越先画）：
#   0 占位 / 缺失的立绘      —— 角色一出场就是占位图
#   1 首领战斗图             —— 首领战没图只有空底；按章节顺序
#   2 精英战斗图
#   3 主线剧情 CG            —— 格子和幕间的 CG，按章节顺序、章内按格子位置
#   4 常用战斗背景           —— 普通战斗；多个战斗共用同一张的、出现次数多的排前
#   5 宝物图标               —— 现在是文字圆章；稀有的 / 诅咒 / 主角专属排前
#   6 结局象征画             —— 已实装的结局
#   7 奇遇插图（？格事件）    —— 随机抽到，缺了只是少一张图；通用事件排在章节专属事件前
#   8 未实装内容             —— 还没做出来的结局等
TIER_NAMES = {0: "立绘（占位 / 缺）", 1: "首领战斗图", 2: "精英战斗图", 3: "主线剧情 CG", 4: "普通战斗背景",
              5: "宝物图标", 6: "结局象征画", 7: "奇遇插图", 8: "未实装内容"}
EXTRA_NEXT = [("cg", "end_locked", "结局图鉴「未解锁」缩略图（16:9，暗色印章问号）", 8)]


# chapter maps already delivered but the chapter's squares changed since: redraw (key -> why). A redraw counts as done once
# art_ingest.py has logged one more delivery of that map than `seen` here.
MAP_REDO = {"tianfu": ("第九章南线雒城之后新增绵竹关 1 列、成都酒肆 2 列（法正的选择），共 44 列（第 20 列以后的列号整体 +3）", 2), "menghu": ("第八章南线开头新增 6 列丹阳深山讨伐山越，中段加 3 组岔路（南阳道、汉水北岸、白河上游），共 48 列（提示词已按新布局写好）", 1), "huainan_s": ("第六章南线开头新增 6 列荆南四郡（零陵 / 桂阳 / 长沙），结尾去掉双婚喜堂；陆家旧宅后又多了一列（陆逊的选择），共 55 列（提示词里第 17 列以后的列号要整体 +1）", 1), "jiangdong": ("第七章南线开头新增 1 列庐江喜堂（双婚），共 41 列（提示词已按新布局写好）", 1), "yuxi": ("第三章两条路线上下分层（上 B 下 A），共 61 列 6 行（提示词已按新布局写好）", 1)}


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
    inter = json.loads((gd / "interludes.json").read_text("utf-8")).get("after", {})
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
        for scene in inter.get(q["id"], []):
            if scene.get("cg"):
                put("cg", scene["cg"], 3, (qi, 10**6), f"{q['title']}·幕间「{scene.get('title', '')}」")
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
CHESTS = {
    "chest_normal": "a sturdy wooden treasure chest with bronze corner caps and a heavy bronze padlock, Han-dynasty style, closed",
    "chest_grand": "a grand red-lacquered treasure chest painted with gold clouds and dragons, inset with jade, a faint golden glow leaking from the seam, closed",
}
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
    "立绘在 `pics/art.json` 对应段登记；然后跑 `sanguo-art`，再跑 `python tools/art_prompts.py` 刷新本文件。",
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

    "c1_village": """横版 16:9 剧情CG插画，三国日系战术卡牌RPG南线第一章：【富春别院 · 初遇霸王与美周郎】
- 场景与江南水乡氛围：
  - 富春孙家乡间小院门前。粉墙黛瓦，翠竹掩映，院角一口青石水井，初春老柳抽着嫩芽，远处是青山如黛与富春江帆影，阳光明朗清新。
- 核心人物戏剧互动（剑拔弩张中透着少年喜感）：
  - 【少年孙策（浓眉小霸王）】：十五六岁的浓眉英挺少年，身穿利落朱红短战袍，黑发扎成朝气蓬勃的马尾。正带着桀骜不驯、生龙活虎的坏笑，单手将一柄长枪的枪尖笔直顶在主角鼻尖前一寸，挑衅叫嚷：「出来打一架！」
  - 【少年周瑜（雅致美周郎）】：十五六岁的偏偏绝色美少年，容貌俊美雅致，身着浅天青色交领长衫，右手轻摇一柄白羽小折扇，嘴角含着看透一切的戏谑浅笑，左手正从宽大袖袍里掏出一本薄薄的小账本，提笔准备记账（「你喝的那碗粥，米是我家的」）。
  - 【主角（现代穿越青年）】：二十岁出头短发（寸头在汉代显得怪异扎眼），身穿吴夫人拿孙策旧衣改制的大号素布衣裳，双手举起做投降状，满脸尴尬与「这俩少年怎么一个比一个怪」的逗比苦笑。
- 构图与画风：
  - 规格：横版 16:9（1920x1080），主要人物位于画面上部三分之二以上。
  - 日系经典战术卡牌RPG剧情CG风格（兰斯10赛璐珞上色带精良墨线），阳光明快，少年意气风发，神态生动鲜活，充满幽默张力；无文字无UI。""",

    "jz_wake": """横版 16:9 剧情CG插画，三国日系战术卡牌RPG北线第一章：【甄府初醒 · 主母探温】
- 场景与环境光影：
  - 冀州中山无极县甄府雅致的客舍偏房内。窗外冰天雪地、大雪纷飞；室内地面铺着厚厚的狼皮保暖毛毡，案头铜炉生着融融红炭，暖黄色的烛光驱散寒意。
- 核心人物互动：
  - 【张夫人（雍容主母）】：三十多岁雍容干练的绝色贵妇，甄家当家主母。梳着华贵高髻，插着金步摇与玉簪，身穿深紫底色、暗纹织锦的阔袖居家汉服襦裙。手中端着一碗还冒着腾腾热气的黑褐色汤药，正微微俯下身，用温润细腻的手背轻轻贴在主角的前额测试体温。嘴角带着一丝似笑非笑的精明打量，眼神中既有对救起之人的母性怜惜，又带着大商贾审视货色的锐利。
  - 【北线主角（初愈苏醒）】：二十岁出头的清秀青年，黑发束成整齐的发髻（包着干净素布巾，绝非现代短发，不戴头盔）。面色尚带一丝大病初愈的虚弱苍白，倚靠在雕花床榻的软枕锦被上，眼神清澈而机警，正有些受宠若惊地仰视着俯身的张夫人。
- 构图与画风：
  - 规格：横版 16:9（1920x1080），主要人物位于画面中上部三分之二以上。
  - 日系战术卡牌RPG剧情插画风（类似兰斯10赛璐珞上色带精良墨线），暖调烛光与窗外冷冽蓝雪形成唯美冷暖对比；无文字无UI。""",

    "jz_ledger": """横版 16:9 剧情CG插画，三国日系战术卡牌RPG北线第一章：【甄府账房 · 甩账与贪嘴小妹】
- 场景与环境：
  - 甄府明亮宽敞的账房内堂。高大的沉香木公案上整齐码放着一叠叠竹简、账册与紫檀木算盘，墙上悬挂着河北各州郡商道舆图。
- 核心人物互动（温馨搞笑）：
  - 【张夫人（甩手掌柜）】：张夫人站在桌案前，身着华丽外袍，双手叉腰，神态傲娇又大度，一只手将半副沉甸甸的甄家总账册啪地按在桌上推给主角。桌角还摆着一袭刚刚赶制出来的华美雪白狐裘长袍（作为给主角的奖赏福利）。
  - 【北线主角（从容自得）】：青年主角手握毛笔端坐在案几后，桌上散落着他绘制的复式记账法草稿纸，面带自信得体的微笑，抬头与张夫人对视。
- 喜剧反差神笔（画龙点睛）：
  - 【小甄宓（娇憨馋嘴）】：十三四岁的少女甄宓，梳着可爱的双丫髻，身穿浅粉色绣着小兔纹样的小襦裙。此时从高高的桌案侧后方悄悄探出半个小脑袋，乌溜溜的大眼睛满是崇拜好奇地偷看新来的账房哥哥，两腮鼓鼓囊囊，手里还紧紧攥着咬了半块的桂花糕，嘴角沾着点心渣！
- 构图与画风：
  - 规格：横版 16:9，日系经典战术卡牌RPG剧情CG风格，赛璐珞精细线稿，温暖明朗的室内自然采光，人物表情生动鲜明；无文字无UI。""",

    "jz_county": """横版 16:9 剧情CG插画，三国日系战术卡牌RPG北线第一章：【邺城州衙 · 子龙挺枪与官绅弄权】
- 场景与氛围：
  - 冀州治所邺城的州衙大堂与门前台阶，规制比寻常县衙更恢弘。冬日阴霾压抑的灰冷天空，威严肃杀的官府石狮与水火棍。
- 核心人物戏剧冲突：
  - 【郭图（刻薄小人）】：三十多岁白净微胖文官，头戴进贤冠，身着考究官袍，腰系玉带。高高站在台阶顶端，手持袁绍征粮文书，嘴角挂着轻蔑刻薄的冷笑，挥手示意差役驱赶乡民，一副视人命如草芥的嚣张嘴脸。
  - 【韩馥（唯唯诺诺）】：五十多岁的冀州刺史，体态臃肿虚胖，官袍松垮，躲在公堂柱子阴影里缩头缩脑，双手缩在袖子里瑟瑟发抖，不敢发一言。
  - 【赵云（挺枪护民）】：二十岁出头的俊朗英武青年赵云，白袍银甲（头戴银白轻盔），风尘仆仆像是刚从常山千里赶来。为了保护身后衣衫褴褛、面黄肌瘦的常山受灾乡民代表，他横枪在前、枪尖直指逼上来的衙役，咬紧牙关，眼眶通红，却不敢真的刺出去。
- 构图与画风：
  - 规格：横版 16:9，主要人物位于画面上部三分之二以上，微仰视构图展现阶级与权势倾轧的张力，冷峻肃杀的战乱纪实色调，赛璐珞墨线质感；无文字无UI。""",

    "jz_guojia": """横版 16:9 剧情CG插画，三国日系战术卡牌RPG北线第一章：【邺城街头 · 鬼才抱葫与子龙跪谢】
- 场景与环境：
  - 冀州治所邺城萧瑟飘雪的青石街头，远处可见州衙的飞檐轮廓。路边简陋酒肆的破旧青布酒旗在寒风中猎猎作响，街面积着薄雪。
- 核心人物站位与神态：
  - 【赵云（单膝跪谢）】：银甲白袍的年轻赵云满面震惊与难以言喻的感激，单膝重重跪在薄雪泥地中，双手抱拳向主角行郑重军礼。
  - 【北线主角（仗义疏财）】：主角束发青衫、身披雪白狐裘，面容温润和煦，正快步上前双手稳稳扶住赵云的臂膀，风度翩翩。
  - 【郭嘉（放浪形骸）】：二十多岁的青衫落魄文士郭嘉，身形消瘦高挑，衣衫单薄不修边幅，肩头插着羽扇。他正吊儿郎当斜靠在酒肆木柱旁，单脚踏着台阶，怀里抱着一只系着鲜艳红绳的大酒葫芦，半眯着醉眼斜睨主角，嘴角扬起一抹看破玄机又玩世不恭的戏谑坏笑。
- 构图与画风：
  - 规格：横版 16:9，主要人物位于画面上部三分之二以上，日系RPG风云际会的名场面构图，雪花飘洒，青布酒旗、银甲战袍与酒葫芦形成鲜明视觉符号；无文字无UI。""",

    "jz_boss": """横版 16:9 战斗剧情CG插画，三国日系战术卡牌RPG北线第一章：【黑山寨门 · 长枪横架与穿喉一击】
- 场景与战场动态：
  - 太行山黑山贼大寨的正门隘口。巨大的粗木栅栏寨门正在熊熊烈火中崩塌坍陷，黑烟滚滚，火星四溅，地面泥泞染血。
- 生死一瞬的戏剧定格：
  - 【李大目（凶煞巨寇）】：四十多岁、宛如黑铁塔般的凶蛮山贼首领，半身赤裸披着染血兽皮，面上一道贯穿左眼的狰狞刀疤，独眼血红暴突，狂怒嘶吼着将一柄沉重巨大的开山双刃阔斧从半空狂暴劈下！
  - 【北线主角（狼狈硬接）】：主角咬紧牙关，双手横握一杆白蜡杆长枪向上死命死架（姿势狼狈僵硬宛如顶门杠），粗壮的白蜡枪杆被巨斧劈得弯曲如弓，交击处迸溅出耀眼的火星电芒！
  - 【赵云（一枪绝杀）】：赵云身如白龙穿云，一身银甲在火光中泛着冷冽寒芒，如闪电般从侧翼低空掠出，手中亮银枪化作一道无可匹敌的璀璨匹练，枪尖寒星直贯李大目咽喉破绽！
- 构图与画风：
  - 规格：横版 16:9，主要人物位于画面上部三分之二以上，极具压迫感与速度感的战斗动作定格抓拍，烈火照耀的炽热对比光影，赛璐珞风格动作特效；无文字无UI。""",



}
OVERRIDES.update(OVERRIDES_ZH)


PORTRAIT_HEAD = "角色立绘半身像，三国历史战棋视觉小说立绘，兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳的厚重色彩。"


def portrait_prompt(p: tuple, key: str = None) -> tuple[str, str]:
    if len(p) >= 5:
        name, look, clothes, weapon, bg = p[:5]
    else:
        name, look, clothes, weapon = p
        bg = "与人物身份相符的古风氛围场景，柔和自然光"
    en_prompt = (f"{PORTRAIT_HEAD}{NL}"
                 f"{name}的竖版人物立绘。{NL}"
                 f"外貌：{look}{NL}"
                 f"铠甲与服饰：{clothes}{NL}"
                 f"武器：{weapon}{NL}"
                 f"背景：{bg}。{NL}"
                 f"构图：{PORTRAIT_COMPOSITION}{NL}"
                 f"画风：{STYLE}，带氛围的环境光，景深柔和，背景有景致但服从于人物。")

    p_zh = PORTRAITS_ZH.get(key)
    if p_zh:
        if len(p_zh) >= 5:
            name_z, look_z, clothes_z, weapon_z, bg_z = p_zh[:5]
        else:
            name_z, look_z, clothes_z, weapon_z = p_zh
            bg_z = "与人物身份相符的三国古风场景，柔和自然光"
        zh_prompt = (f"{PORTRAIT_HEAD}{NL}"
                     f"{name_z}的竖版人物立绘。{NL}"
                     f"外貌：{look_z}{NL}"
                     f"铠甲与服饰：{clothes_z}{NL}"
                     f"武器：{weapon_z}{NL}"
                     f"背景：{bg_z}。{NL}"
                     f"构图：{PORTRAIT_COMPOSITION}{NL}"
                     f"画风：{STYLE}，带氛围的环境光，景深柔和，背景有景致但服从于人物。")
    else:
        zh_prompt = en_prompt
    return zh_prompt, en_prompt


def battle_prompt(scene: str, key: str = None) -> tuple[str, str]:
    en_prompt = (f"横版战斗场景插画：{scene}。{NL}"
                 f"构图：横版 16:9，1920x1080，写实临场感低机位镜头；核心敌将或敌军居中偏上（头 / 脸位于距画面顶部约 30%–45% 区域），所有参战武将、士兵、战马与战船必须脚踏实地处于同一真实物理空间，严禁在天空中画任何巨大的半透明人物虚影、背后灵或虚空浮影；前景自然延伸真实战场地面。{NL}"
                 f"画风：{STYLE}，戏剧化写实战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。")
    scene_zh = BATTLES_ZH.get(key, scene)
    zh_prompt = (f"横版战斗场景插画：{scene_zh}。{NL}"
                 f"构图：横版 16:9，1920x1080，写实临场感低机位镜头；核心敌将或敌军居中偏上（头 / 脸位于距画面顶部约 30%–45% 区域），所有参战武将、士兵、战马与战船必须脚踏实地处于同一真实物理空间，严禁在天空中画任何巨大的半透明人物虚影、背后灵或虚空浮影；前景自然延伸真实战场地面。{NL}"
                 f"画风：{STYLE}，戏剧化写实战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。")
    return zh_prompt, en_prompt


def cg_prompt(scene: str, key: str = None, is_event: bool = False) -> tuple[str, str]:
    en_prompt = (f"横版剧情事件插画：{scene}。{NL}"
                 f"构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。"
                 f"画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。{NL}"
                 f"画风：{STYLE}，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。"
                 + (f"{NL}（主角出场时——{hero_note(key, scene)}。）" if ("主角" in _wanted(scene) or "hero" in scene.lower()) else "")
                 + (f"{NL}（{DONGBAI}。）" if ("董白" in scene or "Dong Bai" in scene) else ""))

    if is_event:
        eid = key[2:] if key and key.startswith("e_") else key
        scene_zh = EVENTS_ZH.get(eid, scene)
    else:
        scene_zh = CGS_ZH.get(key, scene)

    zh_prompt = (f"横版剧情事件插画：{scene_zh}。{NL}"
                 f"构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。"
                 f"画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。{NL}"
                 f"画风：{STYLE}，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。"
                 + (f"{NL}（主角出场时——{hero_note(key, scene_zh)}。）" if "主角" in _wanted(scene_zh) else "")
                 + (f"{NL}（{DONGBAI}。）" if ("董白" in _wanted(scene_zh) or "Dong Bai" in scene_zh) else ""))
    return zh_prompt, en_prompt


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


def render_item(header: str, zh_prompt: str, en_prompt: str = None) -> list[str]:
    # Chinese only: the English fallback was dropped to keep ART-PROMPTS.md short
    return [header, "", "```", zh_prompt, "```", ""]


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
           "> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。", "",
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
            zh, en = portrait_prompt(p, key)
            out += render_item(hdr, zh, en)
    out += ["## 战斗 CG（横版 16:9，每场战斗一张）", ""]
    for key, scene in BATTLES.items():
        if (key in art.get("battles", {}) and key not in redo) or ("battle", key) not in need:
            continue
        hdr = f"### `{key}`"
        if key in OVERRIDES:
            out += [hdr, "", "```", OVERRIDES[key], "```", ""]
            out += ref_lines(OVERRIDES[key], key)
        else:
            zh, en = battle_prompt(scene, key)
            out += render_item(hdr, zh, en)
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
            zh, en = cg_prompt(scene, key)
            out += render_item(hdr, zh, en)
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
            zh, en = cg_prompt(scene, key, is_event=True)
            out += render_item(hdr, zh, en)
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
