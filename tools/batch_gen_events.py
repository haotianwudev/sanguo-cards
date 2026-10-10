"""Batch generate all adventure CGs (奇遇插图) using GPT Image 2 model via AtlasCloud.
"""
from __future__ import annotations

import concurrent.futures
import json
import os
import subprocess
import sys
import threading
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "tools"))

from tools.art_gen import load_api_key, upload_media, generate_image_atlas

ALL_EVENTS = [
    {
        "key": "e_shuijing",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。竹林掩映的清幽草庐门前，慈眉善目的隐士水镜先生司马徽手抚一柄古朴青铜圆镜，笑眯眯抚须点头；少年孙策身背长弓，神情兴奋地凑上前指向主角，阳光透过翠绿竹叶在青石地面洒下斑驳光影。",
        "ref": "pics/source/generals/simahui.jpg",
    },
    {
        "key": "e_pangdegong",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。浩荡汉江之畔，苍翠岘山脚下的青翠田埂上：大隐士庞德公挽着裤腿、手拄一柄农家木锄，贤惠素雅的妻子提着竹编饭篮漫步在野花盛开的田埂边，夫妇二人相敬如宾相互躬身施礼；江风徐徐吹拂，稻浪翻滚。",
        "ref": "pics/source/generals/pangdegong.jpg",
    },
    {
        "key": "e_huangchengyan",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。沔水工坊之内，工匠器械满架、齿轮图纸堆叠：花白胡子的大名士发明家黄承彦满手沾着木屑墨汁，正蹲在一架自行走动、构造精巧的木牛木马机关兽旁调试榫卯，眼神专注痴迷，窗外流水潺潺。",
        "ref": "pics/source/generals/huangchengyan.jpg",
    },
    {
        "key": "e_ganning",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。浩渺汉水江面上，一艘挂着彩锦风帆的快船破浪疾驰：青年豪侠甘宁腰佩叮咚作响的铜铃、背负铁胎硬弓，神态张扬不羁地立于船头俯视江岸大喊；岸边红袍儒将周瑜紧握腰间钱袋与账册，神情戒备。",
        "ref": "pics/source/generals/ganning.jpg",
    },
    {
        "key": "e_snake",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。山野草丛间的爆笑闹剧：年轻主角捂着被咬的小腿单脚直蹦、龇牙咧嘴；一条娇小碧绿的竹叶青小蛇正飞快地刺溜钻入草丛溜之大吉；一旁的少年孙策与英俊周瑜笑得前仰后合、捧腹捂肚，林间阳光温暖灿烂。",
        "ref": "pics/source/generals/sunce.jpg",
    },
    {
        "key": "e_hero",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。喧闹的古朴路边酒肆中：一名豹头环眼、铁塔般魁梧粗豪的黑脸壮士勃然大怒，蒲扇般的大手猛力一掌拍碎整张结实木酒桌，木屑碎块与陶土酒碗四溅飞射，满堂酒客伙计吓得连滚带爬惊呼四散，气氛火爆。",
        "ref": None,
    },
    {
        "key": "e_refugees",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。黄土漫天、秋风萧瑟的破败官道上：成群结队、衣衫褴褛面黄肌瘦的流民百姓拖家带口艰难前行，拄着枯枝拐杖的老农跌坐道旁，年轻母亲紧紧怀抱啼哭婴儿神情绝望无助，深沉悲悯的历史苍凉感。",
        "ref": None,
    },
    {
        "key": "e_washer",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。清澈见底的山涧溪流边，卵石青苔相映：一名容貌清秀、性格爽朗健美的年轻农家浣纱女子高高挽起衣袖裙裾，赤足踩在清凉溪水中，挥舞青石捣衣木槌捶打彩锦布帛，溅起晶莹水花，脚边竹篾花篮满装衣物，青山绿水如诗如画。",
        "ref": "pics/source/soldiers/huansha.jpg",
    },
    {
        "key": "e_fruit",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。崇山峻岭的崎岖山道旁，悬崖边孤立一株苍劲古树，枝头挂满鲜红诱人、晶莹剔透却略带诡异毒斑的不知名野果；青年孙策正好奇伸手欲摘，一旁的儒雅周瑜神情警惕严肃，急忙伸手稳稳按住孙策手腕制止，山风烈烈。",
        "ref": "pics/source/generals/zhouyu.jpg",
    },
    {
        "key": "e_risk",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。江雾弥漫、水汽森然的凶险峡谷水道：江面乱石穿空、暗礁密布，浑浊湍急的激流中一叶乌篷小舟剧烈颠簸起伏；船头满脸沧桑的老船夫叼着长杆旱烟袋、手握长篙稳立船头指引航向，两岸峭壁耸立直插云霄。",
        "ref": None,
    },
    {
        "key": "e_temple",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。荒无人烟的深山密林深处，一座年久失修、屋顶半塌的古老山神庙：庙内蛛网悬挂，断了半边鼻子的泥塑山神像威严依稀，残破案几上的生锈青铜香炉中，半截线香仍散发着一缕幽微青烟，门外落叶飘零。",
        "ref": None,
    },
    {
        "key": "e_yuji",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。古道树荫之下，白衣胜雪、长须飘然的中年仙道于吉横持拂尘长杖傲然拦路，身后童子高高擎起杏黄大幡，上书朱砂大字「于吉仙师 符水度世」；道路两侧无数面容虔诚的平民百姓狂热跪伏叩首，香雾缭绕。",
        "ref": "pics/source/generals/yuji.jpg",
    },
    {
        "key": "e_merchant",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。阳光明媚的官道客栈前，一名身材富态圆润、头戴绸缎圆帽的西域行商大掌柜正满脸堆笑、热情张开双臂招徕顾客；身旁装满精致瓷器、绫罗绸缎与异域香料宝石的毛驴大车货物琳琅满目。",
        "ref": "pics/source/soldiers/shangdui.jpg",
    },
    {
        "key": "e_smith",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。路旁炉火熊熊的古旧铁匠铺内，巨大风箱呼呼作响，火炭烧得通红金黄：赤膊上身、筋肉虬结的精壮老铁匠正挥舞沉重镔铁大锤，重重砸向铁砧上一柄烧得白炽滚烫的战刀，四溅飞射出灿烂金红的火星。",
        "ref": "pics/source/soldiers/tiejiang.jpg",
    },
    {
        "key": "e_tomb",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。阴冷幽暗的苍山古林深处，半被泥土藤蔓掩埋的汉代古墓青砖石券门洞开，幽幽寒气外溢；手握长枪的青年孙策满眼放光、跃跃欲试想要入洞探险，身旁周瑜手执火把，一手按额头满脸头疼无奈。",
        "ref": "pics/source/generals/sunce.jpg",
    },
    {
        "key": "e_guanlu",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。官道老槐树浓密阴凉下，支着一顶简朴青布遮阳卦棚，挂幡墨书「管辂神算 穷究天机」：清瘦俊逸的青年术士管辂端坐竹椅，手捻三枚古朴铜钱排布龟甲爻辞，目光深邃看透命运，案前香炉青烟袅袅。",
        "ref": None,
    },
    {
        "key": "e_xushao",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。汝南名胜清幽庭院中，当代第一品评名士许劭身着锦袍羽冠、端坐青石雕花石案前，手中泥金折扇微摇，神态渊深从容品评当世人物；台阶下围聚着数十名求取一语之评的年轻士子，个个屏息凝神、翘首以盼。",
        "ref": None,
    },
    {
        "key": "e_qiao",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。皖城桃花盛开的清澈溪畔，绝色天香的大乔与小乔姐妹正在水边浅笑嬉戏：大乔温婉端庄、长发垂腰，小乔娇憨灵动、玉足轻点水波荡起涟漪；远处绿柳树荫下，身着武袍的孙策与周瑜二人彻底看傻在原地，迈出的步子僵在半空，神态极具喜剧张力。",
        "ref": "pics/source/generals/daqiao.jpg",
    },
    {
        "key": "e_drink",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。热闹非凡的军营酒肆大堂内，少年小霸王孙策豪情万丈，单脚踩在长凳上，将一大坛见底的粗瓷老酒重重拍在桌案上仰天长笑，酒珠自嘴角飞溅；满堂将士酒客群情激愤、挥拳齐声喝彩呐喊，气氛热烈奔放。",
        "ref": "pics/source/generals/sunce.jpg",
    },
    {
        "key": "e_deserters",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。秋草荒芜的山道泥洼边，几名丢盔卸甲、衣袍破损肮脏的西凉残军逃兵蜷缩在倒伏的枯树干后，面容枯槁满是污泥泪痕，正惊恐瑟缩地抓着生野草树皮往嘴里塞，眼神中满是对生死的无尽绝望。",
        "ref": None,
    },
    {
        "key": "e_storm",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。天地昏暗、乌云密布，一道惨白闪电撕裂苍穹，倾盆暴雨狂暴倾泻而下；行军队伍披着破旧蓑衣斗笠，在泥泞深陷的官道沼泽中艰难前行，狂风撕扯着军旗与树木，人马在风雨雷鸣中奋力挣扎。",
        "ref": None,
    },
    {
        "key": "e_horse",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。落日熔金的荒野驿站前，神秘的塞外贩马人披着狼皮大氅，手中紧紧勒着两匹神异非凡的绝世宝马缰绳：一匹眼泛凶光、额生白煞的照夜玉骢，另一匹毛色纯赤如火炭烈焰、筋骨如龙的赤兔神驹，嘶鸣踏蹄、扬起阵阵尘土。",
        "ref": None,
    },
    {
        "key": "e_convoy",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。太行山丘下蜿蜒的山道上，一队西凉精锐骑兵正押解着数十辆沉重的粮草辎重车队缓缓行进，车队插着黑底红字「董」字战旗，车轮在深辙中吱呀作响；山崖上方主角伏在岩石后屏息侦察。",
        "ref": None,
    },
    {
        "key": "e_surrender",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。硝烟散尽的泥泞古道上，一队残存的黄巾军士卒扔下破损的竹枪与锈刀，手中举起一面用粗布撕成的简陋白旗，浑身血迹污泥、神情悲戚绝望地双膝跪地乞求投降，细雨淅淅沥沥落下。",
        "ref": "pics/source/soldiers/huangjin.jpg",
    },
    {
        "key": "e_shanzei",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。太行山险要峡口的山道巨石后，一名独眼刀疤、满脸横肉的凶悍山贼头目手持沉重开山阔刃大斧跃出拦路，身后数名手持环首刀的山匪自松林中齐声呐喊杀出，杀气腾腾。",
        "ref": "pics/source/soldiers/bandit.jpg",
    },
    {
        "key": "e_shanzhai",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。险峻山谷中的黑山贼前哨木栅营寨门前，一面褪色的「替天行道」黑旗在山风中猎猎作响；寨内高高架起的大铁锅与火堆上烤着整只肥嫩野猪，浓烈诱人的肉香随风飘散，潜伏在灌木丛中的孙策忍不住悄悄擦了擦口水。",
        "ref": "pics/source/generals/sunce.jpg",
    },
    {
        "key": "e_jieying",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。黑夜如墨、风声鹤唳的军营夜袭战：营地四周警犬狂吠，无数带火的飞箭划破夜空如流星雨般射向营帐营栅，熊熊烈火腾空而起，黑衣刀手如鬼魅般自深邃黑夜中咆哮突袭破门而入，刀光火影激烈交织。",
        "ref": None,
    },
    {
        "key": "e_tongyao",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。洛阳残破城门外的泥泞小径上，一群梳着冲天小辫的汉代村童正拍手蹦跳欢笑着唱着神秘讽喻谶纬童谣；夕阳血红的远方地平线上，董卓巍峨暴虐、残忍巨胖的巨大黑色剪影如梦魇般笼罩残破城池。",
        "ref": None,
    },
    {
        "key": "e_zhuhou_yan",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。关东反董联军巍峨的中军大帅帐前：一名手捧精致烫金请柬的白衣使者躬身肃立奉送邀约；后方巨大明亮的中军军帐内灯火通明、旌旗密布，各路诸侯推杯换盏、金钟大鼓齐鸣，烤肉醇酒香气四溢。",
        "ref": None,
    },
    {
        "key": "e_taihang_hunter",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。大雪纷飞的太行山银白雪地中，一名背负沉重松木柴捆的山民老猎户客气让在山道旁，怀里小心护着一只五彩斑斓、拼命扑腾挣扎的肥硕锦鸡；一旁披着雪白貂裘的少女甄宓兴奋地凑上前去、双眸闪闪发亮，旁边的郭嘉裹着厚斗篷正懒洋洋打着哈欠。",
        "ref": "pics/source/generals/zhenmi.jpg",
    },
    {
        "key": "e_zhen_caravan",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。宽阔官道上，一支高悬青底「甄」字大旗的富庶商队马车驻停路旁；商队大管事翻身下马恭敬向端庄精明的张夫人躬身行礼；张夫人翻开手中的厚重账本指尖划算核对，身旁的郭嘉满面笑容好奇凑上前打量。",
        "ref": "pics/source/generals/guojia.jpg",
    },
    {
        "key": "e_hn_cangtou",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。淮南舒县城外空空荡荡的大型义仓门前：空旷的仓库内米粒皆无、蛛网尘封；高高的木门槛上坐着一位满头白发的老仓头，怀里紧抱着一把斑驳磨损的旧木算盘，枯瘦手指正一颗一颗执着拨动算珠；年轻的周瑜神情动容伫立在门外与老人相视。",
        "ref": "pics/source/generals/zhouyu.jpg",
    },
    {
        "key": "e_hn_longwang",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。浩瀚巢湖之滨，一座风雨侵蚀的古旧龙王小庙内：泥塑的龙王像身披褪色陈旧的红锦斗篷，斑驳石供桌上端放着一只装满铜钱的木制香油箱；年轻气盛的少年孙策站在庙门口望着波涛汹涌的湖水，紧张地咽着唾沫拉着主角要参拜。",
        "ref": "pics/source/generals/sunce.jpg",
    },
    {
        "key": "e_hn_qianshan",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。灊山险峻的悬崖盘山道上，一名背负柴火的老樵夫停下脚步拄着磨平的扁担歇息，一手指向远处山腰竹林间升起的滚滚炊烟，面带愤慨向主角一行诉说雷薄陈兰兵匪啸聚山林祸害乡里的恶行，天高云淡。",
        "ref": None,
    },
    {
        "key": "e_hn_shizhe",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。军营辕门大营门口，一名风尘仆仆、马靴满是尘土的洛阳信使双手恭敬奉上一只精美雕花的红木食盒；盒盖上压着一张字迹歪歪扭扭的大字条「别给嘴甜的吃」；一旁的孙策眼疾手快，笑嘻嘻地伸手揭开盒盖就要偷拿精致洛阳点心。",
        "ref": "pics/source/generals/sunce.jpg",
    },
    {
        "key": "e_xz_shiji",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。徐州下邳繁华喧嚣的青石长街市集：街道两旁鳞次栉比的各色摊铺摆满东海活鱼、彭城织锦彩缎与淮南清茶，摩肩接踵热闹非凡；绝色少女甄宓开心地紧紧拉住主角的衣袖，眼花缭乱地伸出纤纤玉指指着各种灵巧会动的民间皮影木偶与摊位。",
        "ref": "pics/source/generals/zhenmi.jpg",
    },
    {
        "key": "e_xz_shangchuan",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。烟波浩渺的泗水码头边，整齐停泊着一排水运高头大商船，白色巨帆上皆刺绣着醒目的红色「糜」字大旗；糜芳身穿华贵锦缎外袍立于首船甲板船头，满脸热情笑容向岸上的主角一行挥手致意，身后水手正搬运着沉甸甸的东海商货。",
        "ref": "pics/source/generals/mifang.jpg",
    },
    {
        "key": "e_xz_yanchang",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。东海之滨耀眼明媚的蓝天碧海下，望不到边的糜家雪白晒盐场白浪如雪：数名精赤上身、皮肤黝黑的粗壮盐工在烈日下挥动木耙翻动白盐；雍容端庄的张夫人轻撩衣摆半蹲在盐垄旁，轻轻捏起一小撮雪白晶体送入口中细细品味，海风拂动裙裾。",
        "ref": None,
    },
    {
        "key": "e_xz_shuzhai",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。徐州陈家幽雅清肃的高门书斋之内：古籍竹简与帛书如小山般整齐垒叠直抵房梁，檀香古鼎轻烟袅袅；当代大族领袖陈珪抚着花白美髯安坐红木案前，目光炯炯、面带高深笑意出题考校对席的主角，案上文房四宝笔墨纸砚齐备。",
        "ref": "pics/source/generals/chengui.jpg",
    },
    {
        "key": "e_xz_liumin",
        "prompt": "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。荒草萋萋的徐州官道旁，聚居着一群自郯城逃避兵灾的苦难流民：黄巾圣女张宁身着朴素布袍、斜跨药箱半跪在草席边，神情极其温柔慈悲地为一名高烧昏迷的稚嫩孩童切脉施药，身旁白发老翁热泪盈眶双手合十苦苦叩谢，充满感人的悲悯温情。",
        "ref": "pics/source/generals/zhangning.jpg",
    },
]

ingest_lock = threading.Lock()


def process_one(item: dict, api_key: str, index: int, total: int) -> bool:
    key = item["key"]
    prompt = item["prompt"]
    ref = item.get("ref")

    # Check if already done
    src_jpg = ROOT / "pics" / "source" / "cg" / f"{key}.jpg"
    if src_jpg.exists():
        print(f"[{index}/{total}] Already exists, skipping: {key}")
        return True

    print(f"[{index}/{total}] Generating: {key} (ref: {ref})")
    ref_urls = None
    if ref:
        ref_path = ROOT / ref
        if ref_path.exists():
            try:
                url = upload_media(api_key, ref_path)
                ref_urls = [url]
            except Exception as e:
                print(f"[{index}/{total}] Warning: failed to upload ref {ref}: {e}")

    try:
        img_url = generate_image_atlas(
            api_key=api_key,
            prompt=prompt,
            model="gpt-image-2",
            size="1536x1024",
            ref_urls=ref_urls,
        )
    except Exception as e:
        print(f"[{index}/{total}] Generation failed for {key}: {e}")
        return False

    inbox_file = ROOT / "pics" / "inbox" / f"{key}.jpg"
    inbox_file.parent.mkdir(parents=True, exist_ok=True)

    import urllib.request
    req = urllib.request.Request(img_url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as resp, open(inbox_file, "wb") as f:
        f.write(resp.read())

    # Ingest with lock
    with ingest_lock:
        cmd = [sys.executable, str(ROOT / "tools" / "art_ingest.py"), "add", str(inbox_file), key, "--kind", "cg"]
        res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
        if res.returncode != 0:
            print(f"[{index}/{total}] Ingestion warning for {key}: {res.stderr or res.stdout}")
        else:
            print(f"[{index}/{total}] ✓ Ingested {key}")

    return True


def main():
    api_key = load_api_key()
    total = len(ALL_EVENTS)
    print(f"Starting batch generation of {total} adventure CGs using GPT Image 2 (AtlasCloud)...")

    # Run with 2 workers to balance speed and stability
    workers = 2
    success_count = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {
            executor.submit(process_one, item, api_key, i + 1, total): item["key"]
            for i, item in enumerate(ALL_EVENTS)
        }
        for future in concurrent.futures.as_completed(futures):
            key = futures[future]
            try:
                ok = future.result()
                if ok:
                    success_count += 1
            except Exception as e:
                print(f"Exception during {key}: {e}")

    print(f"\nAll tasks finished: {success_count}/{total} successful.")

    # Flush doc updates
    print("Flushing docs via art_ingest.py flush...")
    subprocess.run([sys.executable, str(ROOT / "tools" / "art_ingest.py"), "flush"])

    print("Done batch generation!")


if __name__ == "__main__":
    main()
