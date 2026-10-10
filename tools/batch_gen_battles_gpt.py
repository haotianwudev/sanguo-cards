"""Batch generate all 15 missing battle CGs using GPT Image 2 Developer with portrait references."""
from __future__ import annotations

import concurrent.futures
import json
import subprocess
import sys
import threading
import time
import urllib.request
from pathlib import Path

ROOT = Path("F:/workspace/sanguo-cards")
sys.path.insert(0, str(ROOT / "tools"))
from art_gen import load_api_key, upload_media, generate_image_atlas

PREFIX = (
    "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG首领战立绘底图。"
    "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
)
SUFFIX = (
    "构图与透视规范：电影级横版 16:9 构图，核心敌方主将或核心战斗群体占据画面中上部对峙焦点（头脸位于画面上方 30%-40% 区域），"
    "体量巨大充满戏剧性压迫感；地面自然展现战场景观地貌，近景平整自然延伸；"
    "严禁任何UI界面、气泡框、字幕暗条或乱码文字。"
)

BATTLES = [
    {
        "key": "hn_leixu_g",
        "title": "【灊山寨 · 庐江豪帅雷绪】",
        "prompt": (
            f"{PREFIX}：【灊山寨 · 庐江豪帅雷绪】\n"
            "画面核心与敌将：核心敌将雷绪居中肃立，体魄雄壮充满压迫感；"
            "人物容貌长相、发型、深色毛边族长宽袍外罩磨损皮甲、以及手中厚重的大阔刀必须严格复刻参考图1（雷绪立绘）！"
            "面部神态冷硬倔强、风霜满面，眼神固执决绝，双手横按开刃阔刀立于阵前。\n"
            "战场军阵与环境：身后是陡峭险峻的灊山（天柱山）绝壁与粗糙巨木扎就的雷家族寨木墙营垒，山间雾气缭绕弥漫；"
            "身侧一队手持朴刀与猎叉的雷家宗族佃户部曲排开，黑色「雷」字战旗在山岚猎猎翻卷；脚下是平整坚实的盘山乱石土道，山下隐约可见蜿蜒的皖水。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/leixu.jpg"],
    },
    {
        "key": "hn_wanshui",
        "title": "【皖水之畔 · 雷家部曲阵】",
        "prompt": (
            f"{PREFIX}：【皖水之畔 · 雷家部曲阵】\n"
            "画面核心与军阵：阴沉苍茫天色下的皖水宽阔河滩，核心为一队手持雷家统发环首刀与厚木盾的雷家部曲精锐与佃户私兵结成密集战阵，"
            "士兵服饰特征参考参考图2（粗糙黑短褐、布巾裹头，眼神悍野冷酷）；"
            "战阵核心有一名骑着黄骠战马的雷家宗族管事武官（服饰风格参考图1雷绪，披旧皮甲宽袍）拔刀按鞍厉声督战指挥，身后高高挑起一面黑色粗犷「雷」字大旗。\n"
            "战场环境：浑浊的皖水江水波涛拍岸，远处薄雾中隐现高耸巍峨的灊山山影；脚下是宽阔平整的湿润泥泞河滩与河卵石地面，芦苇残破。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/generals/leixu.jpg",
            ROOT / "pics/source/soldiers/heishan_louluo.jpg",
        ],
    },
    {
        "key": "hnn_bw_gy",
        "title": "【寿春校场 · 比武关羽】",
        "prompt": (
            f"{PREFIX}：【寿春校场 · 比武关羽】\n"
            "画面核心与敌将：核心猛将关羽如天神下凡般威然屹立在校场演武台正中央，充满无可匹敌的绝对压迫感！"
            "人物容貌长相、红脸美髯凤目、标志性鹦哥绿锦战袍、华丽金色重锁子铠甲、以及手中的青龙偃月神刀，必须严格100%复刻参考图1（关羽立绘）！"
            "单手或双手傲然横持青龙偃月刀，长须随风飘拂，眼神睥睨全场，气吞山河。\n"
            "战场军阵与环境：寿春宫前的宏大阅兵校场演武高台四周，迎风密插着曹军红黑「曹」字旌旗与徐州「刘」字大旗；"
            "高台四周台阶下侍立着成排持戟校尉与观战将领，演武台边缘整齐摆放着重泥封酒坛；脚下是宽阔坚实、平整夯实的校场青砖与夯土地面。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/guanyu.jpg"],
    },
    {
        "key": "hnn_daofu",
        "title": "【寿春宫禁 · 曹军刀斧手】",
        "prompt": (
            f"{PREFIX}：【寿春宫禁 · 曹军刀斧手】\n"
            "画面核心与军阵：深夜幽暗阴森的寿春宫回廊深处，数名身形彪悍矫健的曹军精锐刀斧手如幽灵般从朱红廊柱后破门杀出！"
            "刀斧手身着统一的曹军黑甲短铠与黑色包头战巾（铠甲质感与风格参考图1夏侯惇的黑甲与参考图2步兵），手握雪亮开山重斧与冷冽环首长刀；"
            "领头的刀斧长神情冷酷嗜血，大斧高高扬起正欲劈砍，杀意刺骨。\n"
            "战场环境：金碧辉煌却危机四伏的深宫雕花朱漆长廊，宫灯剧烈摇晃投下斑驳阴影，地上滚落着打碎的青铜金尊玉杯与溅落美酒；"
            "远处重重深殿隐隐透出宴席灯火；脚下是平整光润的深宫汉白玉与青石地砖。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/generals/xiahoudun.jpg",
            ROOT / "pics/source/soldiers/inf_n.jpg",
        ],
    },
    {
        "key": "hnn_gongmen",
        "title": "【寿春宫门 · 独目悍将夏侯惇】",
        "prompt": (
            f"{PREFIX}：【寿春宫门 · 悍将夏侯惇】\n"
            "画面核心与敌将：核心名将夏侯惇一人一枪，如钢铁要塞般巍然雄踞在寿春巨大宫门的门洞正中央！"
            "人物英武硬朗的五官相貌、浓眉虎目（此时双目尚完好未瞎）、纯黑冷酷的曹军特制玄铁重铠与深色战袍披风，必须严格100%复刻参考图1（夏侯惇立绘）！"
            "神情冷峻酷烈，单手稳稳斜擎着一杆沉重的精钢战枪，枪尖寒芒四射，堵截去路，霸气纵横。\n"
            "战场军阵与环境：巨大的寿春宫阙城门洞内火把通明、宫灯狂舞，门洞两侧侍立着两排披黑甲持长戟的亲兵刀斧手；"
            "宏伟宫门城垛上猎猎飘扬着黑底红字「曹」字帅旗，身后幽深殿堂隐现夜乱火光；脚下是平整坚硬的御道青石地面，刀枪林立。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/xiahoudun.jpg"],
    },
    {
        "key": "hnn_lvbu",
        "title": "【淮水断桥 · 无双吕布】",
        "prompt": (
            f"{PREFIX}：【淮水断桥 · 无双吕布】\n"
            "画面核心与敌将：核心天下第一猛将吕布雄霸居中，骑在一匹神骏无比、燃烧如烈焰的赤兔神马之上，宛若魔神降世！"
            "头顶双凤雉尾金色发冠、身上华丽霸气的兽面吞头百花连环重金铠、手中那柄震慑天下的方天画戟，必须严格100%复刻参考图1（吕布立绘）！"
            "吕布面容英气逼人而狂傲暴烈，单手反握方天画戟横空一挥，戟刃撕裂长夜，赤兔马前蹄扬起长嘶。\n"
            "战场军阵与环境：漆黑如墨的淮河江畔，烈火熊熊的浮桥在身后被彻底斩断截裂，巨木残骸在黑水漩涡中燃烧漂浮；"
            "身后两排并州狼骑与西凉铁骑重甲肃立，手举密密麻麻的燃烧松明火把；远处淮水江面上有楼船灯影；脚下是平整开阔的湿润江岸泥土与河滩坚硬地貌。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/lvbu.jpg"],
    },
    {
        "key": "jd_niuzhu_b",
        "title": "【牛渚滩头 · 刘繇骑卒】",
        "prompt": (
            f"{PREFIX}：【牛渚滩头 · 刘繇骑卒】\n"
            "画面核心与军阵：深秋时节江东牛渚要塞江岸，一队扬州军精锐轻骑兵呼啸冲锋杀来！"
            "骑兵与战马造型服饰严格参考参考图1（江东骑卒立绘：孙氏/扬州军战术皮甲、青红战袍、手持马刀长矛、骑乘精悍江南战马）；"
            "领头的先锋骑将挥刀呐喊，马蹄飞踏踏碎江畔枯萎芦苇，战马鼻喷热气，尘土飞扬破浪而来。\n"
            "战场环境：背景中是刘繇军依山傍水的坚固牛渚大营木栅哨楼，多面青底红字「刘」字大旗在江风中猛烈飞舞，远方浩瀚长江江面上巡逻艨蟟战船帆影幢幢；"
            "脚下是开阔平整坚硬的江岸泥土与乱石马道，充满铁蹄践踏的战术冲击力。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/soldiers/jiangdong_qi.jpg"],
    },
    {
        "key": "jd_shenting",
        "title": "【神亭险岭 · 刘繇大将樊能】",
        "prompt": (
            f"{PREFIX}：【神亭险岭 · 刘繇大将樊能】\n"
            "画面核心与敌将：神亭岭险要险峰山脊之上，刘繇麾下守关大将樊能居中挺立对峙！"
            "樊能为一名四十岁上下的彪悍粗壮重装武将，身披沉重的青黑山字纹铁铠，双手横握一柄开刃厚背双手雪亮斩马大刀，面如重枣神情凶煞，立于营门正前；"
            "身后两侧是密密麻麻的精锐丹阳长枪兵列阵如林（长枪兵的坚实藤甲、铁盔与修长长枪严格参考参考图1丹阳兵与参考图2丹阳长枪兵）！\n"
            "战场环境：神亭岭连绵起伏的山岗营盘，旌旗如云，远处陡峭山脊上另有十余骑轻骑正策马疾驰冲下山坡接应；"
            "浓厚山岚随风翻涌；脚下是神亭岭平整坚硬的险山道路与干燥碎石土坪。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/soldiers/danyang.jpg",
            ROOT / "pics/source/soldiers/danyang_qiang.jpg",
        ],
    },
    {
        "key": "jd_ganning",
        "title": "【太湖锦帆 · 霸王甘宁】",
        "prompt": (
            f"{PREFIX}：【太湖锦帆 · 霸王甘宁】\n"
            "画面核心与敌将：核心锦帆水贼首领甘宁居中傲然屹立于庞大艨蟟主力快船船头正中央！"
            "人物桀骜狂放的少年英豪长相、敞开华丽蜀锦水战衣袍露出的古铜色健壮胸膛、腰间悬挂的标志性黄铜铃铛串、以及身后背负的大铁胎硬弓，必须严格100%复刻参考图1（甘宁立绘）！"
            "甘宁单手大笑挽弓欲射或按刀长啸，英姿勃发，狂气四溢，豪勇无双。\n"
            "战场军阵与环境：太湖水域烟波浩渺，甘宁脚下快船挂着艳丽的彩色锦缎风帆，船头与桅杆悬挂成排铜铃在狂风中铮铮作响；"
            "身侧立着赤膊满身伤疤的周泰与提短戟的蒋钦两位悍将，身后湖面数十艘锦帆飞舟破浪环伺，水波激荡；远方天际映照晚霞与火箭火光；"
            "脚下是平整坚实的战船甲板与太湖滩涂栈台。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/ganning.jpg"],
    },
    {
        "key": "jd_zhoutai",
        "title": "【太湖水门 · 铁壁周泰】",
        "prompt": (
            f"{PREFIX}：【太湖水门 · 铁壁周泰】\n"
            "画面核心与敌将：太湖水寨第二重险要水门前的窄险木栈桥正中央，水匪铁壁悍将周泰宛如不可逾越的铜墙铁壁独身拦关！"
            "人物那如同恶鬼般满身密密麻麻的纵横深刻刀疤、赤裸的精钢古铜色爆炸肌肉身躯、狂野发型与手中那柄巨大的厚背开山重砍刀，必须严格100%复刻参考图1（周泰立绘）！"
            "面部神态极度沉毅冷酷，双手或单手拄刀立于桥心，煞气腾腾，一夫当关万夫莫开。\n"
            "战场军阵与环境：身后是高耸险固的芦苇荡水寨重型原木闸门，闸门顶端悬挂一串巨大的锦帆彩缎铜铃；"
            "水门内停泊着数艘锦帆贼战快船与持钩索的水匪；太湖水流湍急拍击栈桥木桩，水花飞溅；脚下是平整厚重、由粗大原木拼接铺就的栈台与浮桥地面。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/zhoutai.jpg"],
    },
    {
        "key": "jd_yanbaihu",
        "title": "【太湖水寨 · 东吴德王严白虎】",
        "prompt": (
            f"{PREFIX}：【太湖水寨 · 东吴德王严白虎】\n"
            "画面核心与敌将：太湖最深处芦苇重镇水寨的高大主门楼上，自立为王的地方枭雄严白虎居中狂妄俯视！"
            "严白虎五十岁上下、满脸横肉凶煞、身穿僭越奢华的赭黄锦袍外罩精钢锁子重甲、单手高举一柄金丝虎头开山大环刀，必须严格100%复刻参考图1（严白虎立绘）！"
            "面相狂妄跋扈，张狂狞笑，彰显草莽土皇帝的威风与残暴。\n"
            "战场军阵与环境：严白虎脚下的宏伟寨门城楼正中高悬一块黑底金字的大木匾，刻有巨大醒目的「德王」二字牌匾；"
            "门楼两侧密密麻麻侍立着身穿深色严家号衣、手握强弓长矛的精锐太湖水匪私兵；水寨水面停泊着多条满载战利品与私盐的重载盐船；"
            "脚下是平整坚实的木制栈台与水寨防守平台地面。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/yanbaihu.jpg"],
    },
    {
        "key": "jd_menke",
        "title": "【丹徒密林 · 许贡门客伏击】",
        "prompt": (
            f"{PREFIX}：【丹徒密林 · 许贡门客伏击】\n"
            "画面核心与敌方伏兵：江南丹徒山清晨幽暗死寂、浓雾未散的古老原始密林中，数名效死刺客门客突然从参天古树后闪电杀出！"
            "门客死士身披便于林间穿梭的深暗色刺客紧身软甲，脸上严密蒙着黑色面巾，仅露出一双双杀机毕露的狠辣眼眸；"
            "核心刺客一人张满强弓冷箭死死瞄准前方，身侧两人各持淬毒短刃利刀与双持手弩疾步突进，身手极其敏捷矫健；"
            "其门阀私兵刺客特征与吴郡许氏风格严格呼应参考图1（许贡立绘）。\n"
            "战场环境：苍翠幽深的江南丹徒山老林，晨光透过茂密树冠投下斑驳光束，林间落叶铺地，树干上嵌着多支射空的夺命冷箭，充满步步杀机的窒息压迫感；"
            "脚下是平整开阔的林间厚厚枯叶与夯土山道。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/xugong.jpg"],
    },
    {
        "key": "jd_kuaiji",
        "title": "【会稽田陌 · 郡国守军】",
        "prompt": (
            f"{PREFIX}：【会稽田陌 · 郡国守军】\n"
            "画面核心与军阵：江南会稽山阴古道与稻田阡陌之间，一队严阵以待的会稽郡国正规守军结成坚实防线！"
            "领军统领与前排士卒身穿江南江东风格的灰褐色铁札甲与坚韧皮甲（服饰考究古朴，契合参考图1虞翻的青灰文官治军与参考图2王朗太守阵营）；"
            "前排士兵双手紧扣巨大包铁长方大橹盾，盾缝间挺出一排排森严修长的精钢长枪，后排成列的强弩手已搭箭上弦，军容整肃严正。\n"
            "战场环境：背景远处是会稽厚重青石城墙与高大角楼，城楼上「王」字太守官旗巍然飘拂，薄雾如轻纱般笼罩远处的会稽群山；"
            "脚下是开阔平整、坚硬平缓的田埂夯土驿道与泥土大地，展现古代阵地战对垒的庄严肃杀。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/generals/yufan.jpg",
            ROOT / "pics/source/generals/wanglang.jpg",
        ],
    },
    {
        "key": "jd_wanglang",
        "title": "【会稽城头 · 大儒王朗】",
        "prompt": (
            f"{PREFIX}：【会稽城头 · 大儒王朗】\n"
            "画面核心与敌将：会稽巍峨高耸的青石城墙垛口之上，太守经学大儒王朗居中扶垛而立！"
            "人物五旬开外清癯威严的当世大儒面容、飘逸潇洒的花白美髯长须、庄重非凡的汉代大儒高耸进贤冠（峨冠博带）与宽博文官长袍，必须严格100%复刻参考图1（王朗立绘）！"
            "单手端捧着一卷记录礼法经学的青玉竹简卷轴，另一手宽袖迎风微扬，神态傲岸从容，仿佛正在金戈铁马前当面讲经辨理。\n"
            "战场军阵与环境：王朗身侧的坚固城垛箭孔后，排布着数具寒光逼人的守城大型重力绞车八牛弩与满拉硬弓的城防弓手；"
            "城楼上方黑底红字「王」字太守大纛在海风中猎猎作响；脚下城楼水门泊位处整齐停列着会稽郡水军巡防重舰；"
            "脚下是平整坚实的城外开阔夯土沙场与坚硬城关平地。\n"
            f"{SUFFIX}"
        ),
        "refs": [ROOT / "pics/source/generals/wanglang.jpg"],
    },
    {
        "key": "jd_jinfan",
        "title": "【太湖芦荡 · 锦帆铜铃水贼】",
        "prompt": (
            f"{PREFIX}：【太湖芦荡 · 锦帆铜铃水贼】\n"
            "画面核心与军阵：太湖无边无际的浓密芦苇荡水系深处，数艘挂着五彩斑斓蜀锦风帆的轻捷战船破浪杀出！"
            "核心为一队精壮彪悍的锦帆贼众（造型打扮严格参考参考图1锦帆贼立绘与参考图2甘宁的锦衣水战风格）："
            "水匪精赤上身或着锦缎半敞短打，腰间系着成串黄铜铃铛，手持雪亮短刀、带刺分水刺与飞索铁钩，正借着船势飞身跳帮突袭，神情悍勇狂野而充满江湖意气！\n"
            "战场环境：战船船舷与桅杆上挂满铜铃，在疾风巨浪中铃声清脆大作；彩色锦缎在风中翻卷；"
            "水面浪花飞溅，远景隐约可见锦帆水寨原木角楼与岸边安宁的渔村水泊；脚下是平整坚实的木制栈台与近岸滩涂坚硬地面。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/soldiers/jinfan_zei.jpg",
            ROOT / "pics/source/generals/ganning.jpg",
        ],
    },
]

ingest_lock = threading.Lock()
upload_cache: dict[str, str] = {}
upload_lock = threading.Lock()


def get_ref_urls(api_key: str, refs: list[Path]) -> list[str]:
    urls = []
    for p in refs:
        if not p.exists():
            print(f"Warning: reference not found: {p}")
            continue
        p_str = str(p.resolve())
        with upload_lock:
            if p_str not in upload_cache:
                print(f"Uploading ref: {p.name}...")
                upload_cache[p_str] = upload_media(api_key, p)
            urls.append(upload_cache[p_str])
    return urls


def process_task(task: dict, api_key: str, idx: int, total: int) -> bool:
    key = task["key"]
    title = task["title"]
    print(f"\n[{idx}/{total}] >>> Starting generation for {key} {title}...")

    ref_urls = get_ref_urls(api_key, task.get("refs", []))
    try:
        img_url = generate_image_atlas(
            api_key=api_key,
            prompt=task["prompt"],
            model="gpt-image-2",
            size="1536x1024",
            ref_urls=ref_urls if ref_urls else None,
        )
        print(f"[{idx}/{total}] Generated URL for {key}: {img_url}")
    except Exception as e:
        print(f"[{idx}/{total}] ERROR generating {key}: {e}")
        return False

    inbox_file = ROOT / "pics" / "inbox" / f"{key}.jpg"
    inbox_file.parent.mkdir(parents=True, exist_ok=True)

    try:
        req = urllib.request.Request(img_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as resp, open(inbox_file, "wb") as f:
            f.write(resp.read())
        print(f"[{idx}/{total}] Downloaded to: {inbox_file}")
    except Exception as e:
        print(f"[{idx}/{total}] ERROR downloading {key}: {e}")
        return False

    # Ingest into game
    with ingest_lock:
        print(f"[{idx}/{total}] Ingesting {key} via art_ingest.py...")
        cmd = [
            sys.executable,
            str(ROOT / "tools" / "art_ingest.py"),
            "add",
            str(inbox_file),
            key,
            "--kind",
            "battle",
            "--force",
        ]
        res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
        if res.returncode != 0:
            print(f"[{idx}/{total}] Ingestion warning for {key}:\n{res.stderr or res.stdout}")
        else:
            print(f"[{idx}/{total}] ✓ Successfully ingested {key}")

    return True


def main() -> None:
    api_key = load_api_key()
    total = len(BATTLES)
    print(f"=== Starting Batch Generation of {total} Battle CGs with GPT Image 2 Developer ===")

    success_count = 0
    # Use 2 concurrent workers for steady generation without hitting concurrency limits
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
        futures = {
            executor.submit(process_task, task, api_key, i + 1, total): task["key"]
            for i, task in enumerate(BATTLES)
        }
        for fut in concurrent.futures.as_completed(futures):
            key = futures[fut]
            try:
                ok = fut.result()
                if ok:
                    success_count += 1
            except Exception as e:
                print(f"Exception during {key}: {e}")

    print(f"\n=== Finished: {success_count}/{total} battle CGs generated and ingested ===")

    # Flush docs
    print("Flushing docs via art_ingest.py flush...")
    subprocess.run([sys.executable, str(ROOT / "tools" / "art_ingest.py"), "flush"])

    print("All done!")


if __name__ == "__main__":
    main()
