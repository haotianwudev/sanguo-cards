"""Write pics/ART-PROMPTS.md: a ready-to-paste image prompt for every piece of art the game still needs.

    python tools/art_prompts.py

Portraits, battle CGs and story CGs each follow one template (composition + style are fixed so the set stays
consistent); only the subject lines differ. Items that already have final art in pics/art.json are skipped.
Add new characters / battles / scenes to the tables below when you add them to the game.
"""
import json
from pathlib import Path

try:
    from tools.art_prompts_zh import OVERRIDES_ZH, PORTRAITS_ZH, BATTLES_ZH, CGS_ZH, EVENTS_ZH
except ImportError:
    from art_prompts_zh import OVERRIDES_ZH, PORTRAITS_ZH, BATTLES_ZH, CGS_ZH, EVENTS_ZH

ROOT = Path(__file__).resolve().parents[1]
PICS = ROOT / "pics"
NL = "\n"

DONGBAI = ("董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）")
HERO = "主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀"
HERO_NORTH = "北线主角：二十出头的年轻男子，干净斯文，头发用布巾束成发髻（不是现代短发），穿甄宓亡父留下的河北式旧鱼鳞甲（素铁色，不要绿色和金色），外披雪白貂裘，手持白蜡杆长枪（枪头下系一个红色平安结）"
HERO_MODERN = "主角（穿越前）：三十岁的现代社畜，寸头，衬衫领带，一脸熬夜的疲惫；这时还没有穿越，不要古装、不要铠甲、不要兵器"


def hero_note(key: str) -> str:
    ## which outfit line a CG gets: before the transmigration (the opening), the north route, or the south default
    if key in ("c1_era",):
        return HERO_MODERN
    if key and (key.startswith(("jz_", "ln_")) or key.endswith("_north")):
        return HERO_NORTH
    return HERO
STYLE = ("复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳")
PORTRAIT_COMPOSITION = ("竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。")
# Backgrounds are now atmospheric and character-specific per user directive

# key: (name line, appearance, armor & clothing, weapon / pose)
PORTRAITS = {
    "zhangjiao": ("张角（黄巾军首领，大贤良师，自称天公将军，成年男性，SSR 卡也是黄巾首领战的敌人）", "五十岁上下的清癯老者，须发花白，面容枯瘦而眼神狂热，带着悲悯又癫狂的神情", "杏黄色的道袍，绣着太极与星斗符文，头裹黄巾，肩披黄色大氅", "左手持一根九节杖，杖头盘着金龙，右手结印，身周飘着黄色符纸与淡淡的光"),
    "pangtong": ("庞统（号凤雏，成年男性，奇才谋士，相貌丑陋却才华横溢）", "三十岁上下，浓眉掀鼻，短须，相貌粗犷不俊，眼神却机敏锐利，嘴角带着不羁的笑", "朴素的深褐色文士长袍，袖口随意卷起，头戴旧方巾", "手里把玩一片竹简，另一手执一把羽扇，随性地斜靠着"),
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
    "wudang_feijun": ("无当飞军（兵卡·精兵，蜀汉山地精锐，不是具名人物）",
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
    "guonvwang": ("Guo Zhao (郭照, called Nüwang), a clever Hebei orphan who nurses Guo Jia and sorts his reports — an adult woman of about twenty",
        "Calm, graceful adult woman with intelligent eyes.",
        "A plain dark robe and simple hair bun, medicine stains on her sleeve.",
        "A bowl of medicine in one hand, a bundle of military reports in the other.",
        "a war tent on a snowy night in You province"),
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
    "hs_wenchou": "界桥血战：河北名将文丑（魁梧威猛，披金色明光甲，手持长枪）策白马疾驰，枪尖直指前方，身后铁骑如潮；黑白斑马大旗在远处飘扬，战场上尘土与战火翻滚",
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
}

# story cg key: the scene
CGS = {
    "c3_guotu_street": "无极街口的夜里：督粮官郭图（四十岁上下，面容刻薄，细眼薄唇，黑色文冠、深紫官袍，手摇黑色羽扇）骑在马上拦住去路，身后是整队举着强弩的督战弩手，火把照亮他贪婪的目光，视线越过人群盯着身后一长串粮车；赵云（银甲白马，银枪出鞘）勒马挡在最前，主角持白蜡杆长枪（红色平安结）站在他身侧，身后是燃烧的甄府大门；对峙的紧张感，冷暖对比的火光",
    "c3_bad_guotu": "甄府大门内的中庭，黎明前：满院狼藉，断枪与碎门板，淳于琼倒在一旁；郭图（刻薄的中年官员，黑色文冠、深紫官袍）摇着羽扇不紧不慢踱进门，一脚踩在门槛上打量着战利品；断了一半战枪、满身是伤的主角拄着枪半跪着抬头怒视他，张夫人（成年女性）抱着账本站在正堂台阶前；色调阴冷，克制，不见血",
    "c3_bad_return": "无极甄府门前，黄昏：商队空着手回来，车马停在门口；张夫人（成年女性，富态精明）站在台阶上，目光越过人群落在队尾，那里本该有一个背竹篓的白衣姑娘，她什么也没问，默默合上手里的账本；赵云低着头牵马，郭嘉抱着没打开的酒葫芦站在一旁，主角站在最前面，神情沉重；整体色调灰暗压抑",
    "c4_drink": "山寨大堂里三人豪迈对饮：主角居中举碗，左边是郑好（成年女性，红色束袖短打，豪爽大笑），右边是姜巧（成年女性，头缠布巾的机关匠，手里还转着一枚小齿轮），两人互相瞪眼不服，大堂里摆着酒坛与简陋的木桌，众山贼在后面起哄",
    "c4_escape": "太行山道上：郑好的刀手结成刀阵，姜巧的机关弩与绊索布满山道，把陷阵营的黑甲重盾兵死死拖住；主角在前方挥手招呼队伍向东撤退，山口飘着雪与烟尘",
    "c4_million_hj": "青州北海城外的原野：数以万计的黄巾饥民军黑压压围住孤零零的北海城，黄旗遮天蔽日，城头孔融守军寥寥；远处的丘陵上，主角一行人勒马眺望",
    "c4_taishici_break": "北海乱军之中：年轻骁将太史慈（二十出头，英气逼人，披银白轻甲）单枪匹马，长枪连挑数名黄巾兵，突入城门；主角挥刀从旁杀来，两人并肩冲阵，尘土与刀光",
    "c4_porridge": "北海城前的阵地上：几十口大锅一字排开，热气腾腾地熬着粥，刚刚放下兵器的黄巾饥民捧着粥碗痛哭，管亥（魁梧的黄巾首领）把鬼头刀扔在地上，主角站在锅前舀粥",
    "c4_kongrong": "北海郡府正堂：孔融（五十岁上下，清瘦儒雅，捋着胡须，一身官服）把一方沉重的北海相印双手推向主角，案上放着几个梨；窗外是刚解围的北海城，阳光明亮",
    "c4_yanliang": "黄河渡口的黎明：颜良（魁梧威猛，披重甲，手持大刀）立于阵前高声喝令，身后一排先登死士举着强弩，对准渡口对面；浑浊的黄河与寒雾",
    "end_hushi": "an ending card illustration, quiet and symbolic: a half-open camp gate on a rainy night by the Luo river, a broken sky-piercer halberd in the mud, a torn red-horse saddle set and a tiger-head bracer; no people, no blood",
    "end_zhumie": "an ending card illustration, quiet and symbolic: a burned-out white candle, a tipped bronze wine cup, a commander's seal and a white feather fan on a tent table; no people, no blood",
    "end_juefa": "an ending card illustration, quiet and symbolic: two broken mountain stockade gates in snow with torn banners tangled together, a huge halberd planted in front; no people, no blood",
    "end_menhou": "an ending card illustration, quiet and symbolic: a closed vermilion government gate at night with warm light through the crack, discarded black banners and broken tally arrows; no people, no blood",
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
    "c6_warn": "night at a window in Chang'an: Diaochan (adult) in a black cloak, pale but smiling, leaning in at the hero's window by candlelight; in the neighbouring window Dong Bai slamming her shutters",
    "c4_siege": "before dawn, torches around a scholar's house in Chang'an: the elderly Cai Yong being led away without resisting, looking back; Cai Wenji (adult, in white) reaching after him, held back by the short-haired hero",
    "c4_dongjia": "a ruined roadside shrine at dawn: the door kicked open, Dong Bai (adult) standing in the doorway with her twin hammers, grey-haired veterans only as silhouettes behind her; the hero looking up from the straw",
    "c7_feng": "a lamplit army tent at night: the beautiful Lady Feng (adult) pouring wine for the hero and resting her fingertips on his wrist; at the tent flap Dong Bai (adult) slamming a hammer down and Cai Wenji (adult, in white) with a snapped zither string, both glaring",
    "c6_jiaxu": "an abandoned Xiliang camp on the Wei river after a battle: the thin, sleepy-eyed strategist Jia Xu (mid-40s, loose faded officer's robe, gourd flask at his belt) tied up with rope and lounging comfortably on sacks in a grain cart, still sniffing a wine gourd; young Sun Ce, who just tied him, holding the rope end with a spear on his shoulder; the short-haired hero studying him; Zhou Yu frowning over his ledger; comic",
    "c8_xuexi": "the wall of Xiangyang in grey rain at dawn, the city below silent with gates shut: the short-haired hero standing stiff and blank-eyed in battered silver armor; Dong Bai (adult) standing before him, trembling but not stepping back, saying something bitter; behind them young Sun Ce pale and afraid; restrained and bleak, no gore, no bodies",
    "c8_zupu": "the steps of the Xiangyang governor's mansion in the morning: a row of white-bearded Cai clan elders kneeling, the eldest striking a name out of an open clan genealogy with a brush; the pale, long-bearded scholar Liu Biao hurrying up with his official cap askew, sweating; Zhou Yu reading a long list of offered troops and money with shining eyes; the short-haired hero looking on, unimpressed; a little comic",
    "c6_jiaxu_join": "an evening in a Luoyang house: the thin, sleepy-eyed strategist Jia Xu (mid-40s, loose faded robe, gourd flask at his belt) at a table with the first bowl of red-braised pork, sniffing a cup of wine the short-haired hero has just poured him with a respectful bow; Lady Wu (adult) setting down more dishes; young Sun Ce staring at the pork, not daring to reach; warm and comic",
    "c8_jiayan": "a family supper in the courtyard of the Wancheng governor's house on an autumn evening: Lady Wu (adult) handing the short-haired hero a big bowl of chicken soup and ruffling his cropped hair; Sun Ce hanging over the edge of the pot trying to snatch meat; warm lantern light",
    "c8_liuxian": "the bank of the Yu river at sunset: Diaochan (adult, of great beauty) in a light pale-jade southern 'liuxian' skirt sitting hugging her knees on the grass, laughing with her hand over her mouth; in the shallows Sun Ce slipping while grabbing at a fish; Zhou Yu on a rock writing in his ledger",
    "c8_caifuren": "a lavish welcome banquet in Xiangyang: Lady Cai (adult, purple gold-embroidered silks, phoenix hairpin) holding Cai Wenji's (adult, in white) hands over an open clan genealogy book, all warm smiles; beside them Diaochan (adult) accepting a box of pearls with an equally sweet smile; the elderly scholar Cai Yong stroking his beard sceptically in the background",
    "c8_shuige": "a lavish pavilion over the Han river, the only door sealed by a fallen iron portcullis, crossbowmen behind the curtains: Diaochan (adult) in a pale-jade skirt draining a gold beast-shaped wine cup before the burly Cai Mao, her other hand already reaching for the hairpin in her hair; the short-haired hero half-rising with his blade half drawn, shouting; tense, no gore",
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
    "c6_escape": "night escape from Chang'an: a covered carriage racing through a burning city gate, the boy emperor peeking out clutching a small bundle; Dong Bai (adult) riding alongside with her twin hammers; the hero riding on the other side with Diaochan (adult) behind his saddle",
    "c6_huihe": "the restored gate of Luoyang at dawn: the huge Sun Jian in his tiger-pelt cape kneeling on one knee in the dust before the small boy emperor stepping down from a battered carriage",
    "c6_seal": "a makeshift throne hall in half-ruined Luoyang: the boy emperor on a simple throne asking quietly; the huge Sun Jian clutching a brocade box against his chest, not offering it; Zhou Yu writing in his ledger with lowered eyes; Lady Wu (adult) watching Sun Jian from the back",
    "c7_huangzhong": "a captured camp in Nanyang: Huang Zhong, a sturdy man in his 40s in rough soldier's clothes, rope marks on his wrists, drawing a heavy bow to full; his arrow snapping the banner pole with the character 袁 on the far camp gate; Sun Ce gaping, the hero grinning",
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
    "jz_county": "邺城州衙公堂石阶前：赵云护着满身尘土的常山受灾乡民后退，郭图高踞堂上冷笑，韩馥缩在一旁瑟瑟发抖",
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
}


# hand-written prompts that replace the template for a key (e.g. the owner's own prompt for a scene).
# They stay here after the art exists (ART-PROMPTS.md only lists what is still missing), so a redraw starts from the same prompt.
# chapter map backgrounds (quest id -> what the scroll shows, left to right); the game scrolls it sideways under the squares
MAPS = {
    "prologue_north": "winter Hebei, the road from the Zhen family's trading town to the Black Mountain bandit lair, left to "
                "right: a small stone-walled trading town under falling snow; a larger walled city with a government hall under a "
                "grey winter sky; an open snowy road through farmland with a lone wandering old Taoist glimpsed at the roadside; a "
                "narrowing mountain gorge climbing toward a firelit skirmish; at the far right the bandits' snow-wrapped cliffside "
                "stronghold on a mountain, smoke rising from its gate, with a path turning back south at its foot",
    "yuxi": "【地图共 27 列，南线第三章·传国玉玺】自焚毁的洛阳向南到南阳鲁阳，自左向右依次：①左端洛阳废墟冒着黑烟，长长的难民队伍南行；②山丘间断粮的孙坚军营，炊烟稀薄；③鲁阳城墙与酒肆街，街口有行人与酒旗；④雨水浸透的农田，袁术军营连绵；⑤最右端大雨中的狭窄山口",
    "shouluoyang": "【地图共 22 列，南线第三章·收洛阳】重建中的洛阳，自左向右依次：①灰烬中的一堆篝火；②官眷被护送向西的官道；③山脚小路上的西凉粮队；④修复的宗庙与城墙，城头插着红底「孙」字旗；⑤太平的集市街；⑥最右端通向长安的西行大道",
    "changan": "【地图共 31 列，第三章·长安】冬日长安，自左向右依次：①宏伟的城门；②董卓华丽的府邸与庭院里的比武场；③带假山花园的宫殿；④朴素的书生宅；⑤司徒府；⑥荷塘边的凤仪亭；⑦最右端挂满红色喜庆灯笼的丞相府",
    "jingxiang": "【地图共 31 列，第五章·荆襄风云】自南阳向南到汉水，自左向右依次：①秋日宛城，院中的灶台与河边的栗子摊；②芦苇丛生的淯水与战场；③汉水渡口，挂锦帆的战船；④新野一带的坞堡与樊城小镇；⑤汉水边的襄阳城，有兵库与停满战船的水寨；⑥种着梯田的岘山；⑦最右端万山上江边岩石上的一座孤亭",
    "dongui": "【地图共 37 列，第四章·挟天子】一条长征路，自左向右依次：①雪中的长安宫城与宣平门；②渭水东行的大道；③群山与函谷关；④插着红底「孙」字旗、半修复的洛阳；⑤向南的夏日官道；⑥袁术军营；⑦最右端南阳宛城的城墙",
    "heishan": "【地图共 40 列，北线第三章·黑山风云，三条行进带：上=战斗线，中=主线，下=奇遇线】自左向右依次：①左端（第 0–6 列）真定县城与城外小路，城墙下贴着发榜的告示，军营里一名兵痞在闹事，旁边是校场；②（第 7–14 列）进入太行山：山道、采药人的小屋、深山绝壁，一处悬崖下有白马与人影；③（第 15–22 列）黑山大寨：木寨、演武场、寨中集市，大寨议事堂挂着黑山令；④（第 23–30 列）山中秘道与狭窄的峡谷，太行山口的关卡；⑤（第 31–39 列）界桥外围的原野，河畔的营垒，最右端是插着斑马大旗的战场。整体冬末春初，山色青灰",
    "beihai": "【地图共 48 列，北线第四章·双凤乱太行，三条行进带：上=战斗线，中=主线，下=奇遇线】自左向右依次：①左端（第 0–12 列）太行外围，山寨与郑家寨、姜家寨隔山相望，两寨之间是山谷；②（第 13–24 列）太行休整营地，北方来的并州狼骑在山口扬尘，吕布的旗号隐约可见；③（第 25–31 列）突围：苇荡深处的河湾，冀州军追兵的营垒，黄河渡口；④（第 32–47 列）北海城：被黄巾军围困的城墙，城外黄巾的营帐与饥民，城门前支着熬粥的大锅，最右端是北海相府。整体夏季，色调偏暖",
    "taodong": "the march north to fight Dong Zhuo, left to right: country roads and farmland leaving the south; a dusty Central-Plains "
               "highway with a burnt village; the battlefield before Sishui Pass where Hua Xiong fought (a mountain gap with a watchtower); "
               "Sun Jian's big army camp with palisades, tents and red banners; a barren windswept wasteland (Hulao Pass, where the three "
               "heroes fought Lü Bu); and at the far right the walls of Luoyang burning at dusk, smoke rising into an ember sky",
}

# relic icons (cards.json relics id -> the object itself)
# Authentic ancient Chinese items, pure cut-outs on transparent backgrounds (no western circular medallion).
# Excluded lord/protagonist relics per user instruction: jiujia, hupi, qixing, zhaoxianbang, yitian, yuxi.
RELICS = {
    "jiujia": "孙坚旧甲：一副保养得一丝不苟的汉代银色札甲，护肩上刻着虎纹，胸甲带细密的鳞片纹路，下摆内衬露出一角虎皮，肩甲边缘有岁月的磨损与几处旧刀痕，旁边叠着一件白毛滚边的黑色披风一角",
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
}


# ？ event illustrations (event id -> scene); shown full-screen when the event comes up, like a story CG (key e_<id>)
EVENTS = {
    "borrow_general": "孙坚大帐前：孙坚指着帐外一排老将，程普、韩当、黄盖、朱治、吴景、孙贲依次站开，个个一身旧伤，眼神沉稳；主角站在帐门口，吴景的目光紧紧盯着他",
    "hand_over": "盟主大营的辕门外：一辆囚车正缓缓驶出，车内的董白（成年女性）回头望了一眼，神情复杂，什么也没说；孙策站在远处沉默地看着，营门口挂着盟旗",
    "ln_boater": "结冰的黄河渡口：一位满脸风霜的老艄公撑着小渡船，压低声音收船钱，船上堆着几袋货物；河面上漂着浮冰，天色阴沉",
    "ln_wine": "酸枣大营外的酒摊：精明的摊主（四十岁上下，围着围裙）正笑眯眯地倒酒，摊上摆满酒坛，远处是诸侯各色旗帜的营帐；食客与士兵三三两两",
    "lvbu_beaten": "虎牢关下：吕布退入关内，关前一片狼藉；十八路诸侯与士兵争相举杯向主角敬酒，袁绍起身让座，孙坚拍着主角的肩膀；远处一个个子不高、端着酒杯的人（曹操）捋着胡须，静静打量主角",
    "lvbu_beaten_n": "酸枣大营中央：袁绍派人送来一面「义薄云天」的锦旗，诸侯们围观；曹操（个子不高，捋须）负手站在一旁，盯着那面破旧的「中山甄记」大旗；郭嘉举着酒葫芦遥遥敬了他一下",
    "old_armor": "吴夫人的房间里：吴夫人打开一只樟木箱，里面是护肩刻虎纹的银甲和白毛滚边的黑披风，她亲手给主角系上甲带；孙策站在门口目瞪口呆，周瑜在一旁翻着账本",
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
    "title": "the title screen: a wide panoramic scene of the Three Kingdoms era at dawn — the Yangtze river in the foreground with a small boat, the young short-haired hero in silver armor with a cape standing on the bank looking north toward distant burning cities and banners; the sky split between warm sunrise and war smoke; leave the centre third of the frame calm and darker (the menu sits there)",
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


def build_next(delivered: dict) -> list:
    """[(kind, key, what, tier)] still missing and used by the game, in drawing order."""
    gd = ROOT / "godot" / "data"
    cards = json.loads((gd / "cards.json").read_text("utf-8"))
    story = json.loads((gd / "story.json").read_text("utf-8"))
    endings = json.loads((gd / "endings.json").read_text("utf-8"))["endings"]
    inter = json.loads((gd / "interludes.json").read_text("utf-8")).get("after", {})
    sc, en = cards["scenarios"], cards["enemies"]
    qidx = {q["id"]: i for i, q in enumerate(story["quests"])}
    found: dict = {}  # (kind, key) -> (tier, sort tuple, what)

    def put(kind, key, tier, order, what):
        if key in delivered[kind]:
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
REDO = [
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

    "jz_county": """横版 16:9 剧情CG插画，三国日系战术卡牌RPG北线第一章：【邺城州衙 · 子龙隐忍与官绅弄权】
- 场景与氛围：
  - 冀州治所邺城的州衙大堂与门前台阶，规制比寻常县衙更恢弘。冬日阴霾压抑的灰冷天空，威严肃杀的官府石狮与水火棍。
- 核心人物戏剧冲突：
  - 【郭图（刻薄小人）】：三十多岁白净微胖文官，头戴进贤冠，身着考究官袍，腰系玉带。高高站在台阶顶端，手持袁绍征粮文书，嘴角挂着轻蔑刻薄的冷笑，挥手示意差役驱赶乡民，一副视人命如草芥的嚣张嘴脸。
  - 【韩馥（唯唯诺诺）】：五十多岁的冀州刺史，体态臃肿虚胖，官袍松垮，躲在公堂柱子阴影里缩头缩脑，双手缩在袖子里瑟瑟发抖，不敢发一言。
  - 【赵云（隐忍护民）】：二十岁出头的俊朗英武青年赵云，白袍银甲（头戴银白轻盔），长枪尚在鞘中横于胸前，风尘仆仆像是刚从常山千里赶来。为了保护身后衣衫褴褛、面黄肌瘦的常山受灾乡民代表，他以身相护缓缓后退，手臂已被衙役水火棍打中衣袍撕裂，剑眉倒竖，牙关紧咬，眼眶因悲愤而泛红，满腔怒火却顾全大局强行克制。
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


def portrait_prompt(p: tuple, key: str = None) -> tuple[str, str]:
    if len(p) >= 5:
        name, look, clothes, weapon, bg = p[:5]
    else:
        name, look, clothes, weapon = p
        bg = "与人物身份相符的古风氛围场景，柔和自然光"
    en_prompt = (f"{name}的竖版人物立绘。{NL}"
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
        zh_prompt = (f"{name_z}的竖版人物立绘。{NL}"
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
                 f"构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。{NL}"
                 f"画风：{STYLE}，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。")
    scene_zh = BATTLES_ZH.get(key, scene)
    zh_prompt = (f"横版战斗场景插画：{scene_zh}。{NL}"
                 f"构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。{NL}"
                 f"画风：{STYLE}，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。")
    return zh_prompt, en_prompt


def cg_prompt(scene: str, key: str = None, is_event: bool = False) -> tuple[str, str]:
    en_prompt = (f"横版剧情事件插画：{scene}。{NL}"
                 f"构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。"
                 f"画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。{NL}"
                 f"画风：{STYLE}，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。{NL}"
                 f"（主角出场时——{hero_note(key)}。）" + (f"{NL}（{DONGBAI}。）" if ("董白" in scene or "Dong Bai" in scene) else ""))

    if is_event:
        eid = key[2:] if key and key.startswith("e_") else key
        scene_zh = EVENTS_ZH.get(eid, scene)
    else:
        scene_zh = CGS_ZH.get(key, scene)

    zh_prompt = (f"横版剧情事件插画：{scene_zh}。{NL}"
                 f"构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。"
                 f"画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。{NL}"
                 f"画风：{STYLE}，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。{NL}"
                 f"（主角出场时——{hero_note(key)}。）" + (f"{NL}（{DONGBAI}。）" if ("董白" in scene_zh or "Dong Bai" in scene_zh) else ""))
    return zh_prompt, en_prompt


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
        if REDO:
            out += ["**先重画**（已交付但有地方不对）：", ""] + [f"- `{k}` — {why}" for k, why in REDO] + [""]
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
    import re as _re
    _log = ROOT / "pics" / "ART-LOG.md"  # art_ingest.py records what was delivered: a REDO entry replaced since is done
    ingested = set(_re.findall(r"`(\w+)` ←", _log.read_text("utf-8"))) if _log.exists() else set()
    REDO[:] = [(k, w) for k, w in REDO if k not in ingested]
    redo = {k for k, _ in REDO}
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
        if key in art.get("battles", {}) or ("battle", key) not in need:
            continue
        hdr = f"### `{key}`"
        if key in OVERRIDES:
            out += [hdr, "", "```", OVERRIDES[key], "```", ""]
        else:
            zh, en = battle_prompt(scene, key)
            out += render_item(hdr, zh, en)
    out += ["## 剧情插图 CG（横版 16:9）", ""]
    for key, scene in CGS.items():
        if (key in art.get("cgs", {}) and key not in redo) or ("cg", key) not in need:
            continue
        hdr = f"### `{key}`"
        if key in OVERRIDES:
            out += [hdr, "", "```", OVERRIDES[key], "```", ""]
        else:
            zh, en = cg_prompt(scene, key)
            out += render_item(hdr, zh, en)
    out += ["## 奇遇插图（？格事件，横版 16:9，key = e_<事件 id>，放 `pics/source/cg/`，和剧情 CG 一样登记）", ""]
    for eid, scene in EVENTS.items():
        key = "e_" + eid
        if key in art.get("cgs", {}) or ("cg", key) not in need:
            continue
        hdr = f"### `{key}`"
        if key in OVERRIDES:
            out += [hdr, "", "```", OVERRIDES[key], "```", ""]
        else:
            zh, en = cg_prompt(scene, key, is_event=True)
            out += render_item(hdr, zh, en)
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
        if (art_dir / "ui" / f"{key}.jpg").exists():
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
    rarity = {k: v.get("rarity", "common") for k, v in json.loads((ROOT / "godot/data/cards.json").read_text("utf-8"))["relics"].items()}
    out += ["## 宝物图标（256×256 透明 PNG，放 `pics/source/relics/<key>.png`；现在是程序生成的占位）", ""]
    for key, obj in RELICS.items():
        if key in relics_done:
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or relic_prompt(obj, rarity.get(key, "common")), "```", ""]
    (PICS / "ART-PROMPTS.md").write_text(NL.join(out), "utf-8", newline=NL)
    print(f"wrote {PICS / 'ART-PROMPTS.md'}")


if __name__ == "__main__":
    main()
