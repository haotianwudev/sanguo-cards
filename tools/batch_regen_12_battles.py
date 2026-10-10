"""Batch regenerate 12 battle CGs using GPT Image 2 model via AtlasCloud.

Addresses user feedback:
"以下战斗CG 不符合要求 大部分因为角色过大 并不是实际的视觉冲击 非常不现实 用GPT model 重新生成"
- Realistic scale and proportions (no cartoonish giant boss/heads floating in sky)
- Authentic historical battle tactical visual impact
- Model: openai/gpt-image-2-developer (gpt-image-2)
"""
from __future__ import annotations

import concurrent.futures
import json
import os
import subprocess
import sys
import threading
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "tools"))

from tools.art_gen import load_api_key, upload_media, generate_image_atlas

TASKS = [
    {
        "key": "bh_jz_inf",
        "name": "黄河渡口 · 冀州军方盾刀阵",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【黄河渡口 · 冀州军方盾刀阵】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：黄河渡口泥泞开阔的河滩鹅卵石滩上，一整队精锐严整的冀州重步兵结成森严密集的方盾刀阵稳步前推，巨大的方盾并拢如铁壁，盾缝间挺立着寒光闪闪的环首刀与短矛尖，中军树立着猎猎翻卷的鲜明「袁」字大旗；身后是浊浪滔天的浑黄黄河水与靠岸的木制战船渡船，阴沉铅云低垂，黄河水花飞溅，逼真肃杀的古代冷兵器军阵压迫感。"
            "构图与比例：电影级横版 16:9 构图，严谨真实的冷兵器战场比例与空间景深，步兵体格比例写实自然（严禁单个士兵畸形巨大或夸张特写占据全屏），突出整个军阵的战术推进与大河战场的宏大视觉冲击力。"
        ),
        "refs": ["pics/source/soldiers/inf_n.jpg"],
        # We already generated this one in test
        "pre_generated_url": "https://atlas-media.oss-us-west-1.aliyuncs.com/assetd-history/v1/a-e894954bf1a4ede106d5d201061f01d13da33623af46d4f2f42485ae5915df16/u-aa2c2c1c1cf9f3fafd249acef303b4f5dceb9f6bf5b90089cfe560f229d16f83/s-e2618586207fe13aa1222391c32f9e51cea03eb167f5fcd0758546f527fb89b2/7fb5ad212230423eb481306b55da6ca9-7bfb2ad89754ad69.png",
    },
    {
        "key": "c5_fanchou",
        "name": "长安相府 · 樊稠演武比试",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【长安相府 · 樊稠演武比试】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：董卓相国府邸内院开阔的青石宴席擂台上，西凉悍将樊稠（体魄精壮魁梧、虬髯满面、狂笑桀骜）双手狂暴拧身抡动一柄沉重锋利的厚背大砍刀，带起呼啸凌厉的刀光劲风；擂台四周长案案几旁，数名西凉军粗豪将佐手持酒爵、大口嚼肉喝酒，拍案哄笑喝彩；四周高悬喜庆却凶险的红灯笼，青铜火盆烈火熊熊，夜色与火光映照刀芒。"
            "构图与比例：电影级横版 16:9 构图，严谨真实的冷兵器院落比武比例，樊稠体态健硕敏捷，动作极具力量张力（严禁画面出现任何虚假巨大化幽灵头像或巨人，严禁人物畸形过大），生动呈现西凉军中剽悍野蛮的比武搏杀氛围。"
        ),
        "refs": ["pics/source/generals/fanchou.jpg"],
    },
    {
        "key": "c6_shaoka",
        "name": "长安清明门 · 宵禁哨卡",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【长安清明门 · 宵禁哨卡】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：长安清明门深夜沉寂森严的关口前，巍峨青砖城门半闭，两侧一排熊熊燃烧的火把与火盆照亮浓重夜雾；数名身披黑红相间汉代精铁甲胄、手持雪亮长戟的城防禁军甲士横列成队封死要道，戟尖在火光下泛着寒芒；为首的铁甲军官神色冷峻严肃，按剑高举严苛的缉捕军令文书严词盘查阻拦；路障拒马横陈在青石板官道上，城楼上隐见巡弋火把。"
            "构图与比例：电影级横版 16:9 构图，严谨真实的冷兵器城关防守比例与空间景深，守军甲士比例自然挺拔写实（严禁人物畸形巨大或夸张特写占据全屏，严禁任何巨大化幽灵头像），冷峻肃杀的汉末长安夜禁危机感。"
        ),
        "refs": ["pics/source/soldiers/inf_n.jpg"],
    },
    {
        "key": "c7_chenlan",
        "name": "南阳宛城 · 陈兰固守城垛",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【南阳宛城 · 陈兰固守城垛】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：南阳宛城高耸巍峨的青砖城楼堞口之上，花白胡须的袁术军宿将陈兰（身披铁叶鳞甲、深蓝战袍）屹立于城垛前手持长枪居高临下肃穆指挥；城垛两侧一排排袁术军弓弩手半蹲在箭垛后拉满硬弓强弩，密集冷箭呼啸射向城下；头顶上空黑色「袁」字大旗猎猎翻卷；城外平原上烽火狼烟四起，硝烟弥漫。"
            "构图与比例：电影级横版 16:9 构图，严谨真实的城墙攻守战比例与高空俯仰景深，陈兰与弓箭手依托城防工事自然分布（严禁陈兰身体畸形过大或浮夸特写，严禁任何巨大幽灵肖像），真实展现冷兵器坚城防守的铁壁压迫感。"
        ),
        "refs": ["pics/source/generals/chenlan.jpg"],
    },
    {
        "key": "hn_liuxun",
        "name": "皖城城头 · 庐江太守刘勋守城",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【皖城城头 · 庐江太守刘勋守城】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：皖城城头垛口前，一排黄色仲氏「仲」字战旗随风翻卷；四五十岁、身材微胖富态、留两撇八字胡的贪婪太守刘勋（身穿一套崭新锃亮、金漆未干透的华丽金锁子甲，腋下死死夹着一本搜刮账簿）双手紧扶城垛，神色既贪婪又惊恐慌乱地俯身指挥；身旁守军甲士正合力将巨大的滚木与沉重擂石推下城垛，城门紧闭吊桥高悬，城下战火硝烟升腾。"
            "构图与比例：电影级横版 16:9 构图，严谨真实的城防战斗比例，刘勋与守城士兵身材比例写实协调（严禁人物畸形过大或夸张特写占据全屏），真实还原城关攻防的紧张与狼狈。"
        ),
        "refs": ["pics/source/generals/liuxun.jpg"],
    },
    {
        "key": "hn_leichen",
        "name": "濡须口江面 · 雷薄与陈兰载金逃遁",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【濡须口江面 · 雷薄与陈兰载金逃遁】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：浩瀚烟波的濡须口宽阔江面上，两条吃水极深、甲板近水的大木船并排漂浮，敞开的货舱里杂乱塞满了堆积如山泛着金光的金银财宝箱与丝帛绢缎；船头甲板上，粗豪魁梧、脸带刀疤持铁枪的雷薄，与身材干瘦修长、同样紧握长枪的陈兰并肩而立，两人脸上写满了「怎么又是你」的极度晦气警惕表情；江面水雾蒸腾，江浪拍打船舷，远处灊山险峰在云雾中若隐若现。"
            "构图与比例：电影级横版 16:9 构图，严谨真实的江船对峙比例，两名武将与船舱财宝箱比例自然协调（严禁人物畸形巨大或夸张特写），戏剧生动地呈现古代水路截击的真实紧张感。"
        ),
        "refs": ["pics/source/generals/leibo.jpg", "pics/source/generals/chenlan.jpg"],
    },
    {
        "key": "hn_zhangxun",
        "name": "寿春淝水 · 张勋铁索连环楼船阵",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【寿春淝水 · 张勋铁索连环楼船阵】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：寿春城南水流湍急的淝水江面上，十几艘高达三层的巍峨重型楼船以粗大冰冷的生铁巨索横江相连，筑成一道坚不可摧的水上城墙要塞；中央最大的主楼船二层露台飞桥上，三十多岁、神情沉着庄严的袁军上将张勋（身披黄金锁甲与黄色战袍，手按佩剑）按剑迎风而立；主船及两侧连环战船的木质舷墙垛口上密布数排精锐强弩手平举强弩；滔滔江浪翻滚，远处寿春黑色的雄伟城墙巍峨耸立。"
            "构图与比例：电影级横版 16:9 构图，宏大壮阔的古代水师要塞阵线全景与中景，张勋立于楼船之上身材比例严谨自然（严禁张勋巨人化或人物畸形巨大占据屏幕），展现古代战船铁索连环要塞的震撼视觉冲击力。"
        ),
        "refs": ["pics/source/generals/zhangxun.jpg"],
    },
    {
        "key": "hs_jizhou_nu",
        "name": "太行秘道 · 冀州强弩手峡谷伏击",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【太行秘道 · 冀州强弩手峡谷伏击】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：太行山深处幽暗险峻的一线天逼仄峡谷内，两侧如刀削般陡峭的青黑岩壁与嶙峋乱石台上，一队身穿精铁皮甲的冀州强弩手矫健半蹲设伏；数架沉重的强弩皆已机括上弦，冰冷的铁箭镞在摇曳火把映照下齐齐对准谷底通道，杀机四伏；峡谷岩壁上错落插着燃烧的火把与先前激射的箭矢，夜风呼啸，冷气森森。"
            "构图与比例：电影级横版 16:9 构图，真实的峡谷险要地形与立体伏击景深，强弩手人物身材比例严谨写实、动作专业沉稳（严禁画面出现任何虚假巨大化幽灵头像或巨人，严禁人物畸形过大），极具压迫感的冷兵器险地伏击震撼。"
        ),
        "refs": ["pics/source/soldiers/jizhou_nu.jpg"],
    },
    {
        "key": "hs_jizhou_qibing",
        "name": "太行秘道 · 冀州轻骑窄路疾驰追击",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【太行秘道 · 冀州轻骑窄路疾驰追击】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：太行山逼仄险峻的山道弯道上，数名身穿甲胄的冀州精锐轻骑兵策马如飞狂暴追击；战马肌肉紧绷腾空奔驰，铁蹄重重践踏乱石激起崩碎的石屑与扬尘；领头骑兵压低身躯、手持雪亮长矛直指前方，红色战袍在狂风中猛烈翻飞；火把流光在峭壁岩石上飞速掠过，深渊与崖壁险象环生。"
            "构图与比例：电影级横版 16:9 构图，极富动态速度感与冲击力的骑兵冲锋追踪视角，战马与骑手比例严谨真实（严禁人物与战马畸形巨大或夸张特写占据全屏），还原真实的冷兵器山地追杀张力。"
        ),
        "refs": ["pics/source/soldiers/cav_n.jpg"],
    },
    {
        "key": "huangjin_vanguard",
        "name": "太行山道 · 黄巾前锋散兵夜行",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【太行山道 · 黄巾前锋散兵夜行】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：太行山黑夜崎岖陡峭的山道碎石小径上，数名头裹标志性破旧黄巾布条的黄巾军前锋散兵谨慎摸黑行军；士兵们有的双手紧攥粗糙长矛探路，有的紧握磨损锋利的环首短刀警惕张望；摇曳暗淡的松明火把照亮了他们因饥寒跋涉而枯瘦疲惫、却依然闪烁着狂热凶残光芒的面孔；身旁是嶙峋巨石与张牙舞爪的冬林枯木，夜雾笼罩。"
            "构图与比例：电影级横版 16:9 构图，严谨真实的夜行散兵小队行进比例与地貌空间（严禁人物畸形巨大或夸大特写，严禁任何幽灵虚影），真实呈现汉末流民草莽义军的危险压迫感。"
        ),
        "refs": ["pics/source/soldiers/huangjin_vanguard.jpg"],
    },
    {
        "key": "jx_shuijun",
        "name": "汉水之畔 · 荆州水军跳帮突击",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【汉水之畔 · 荆州水军跳帮突击】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：汉水江畔波涛汹涌的险要荆州水军营寨前沿，数名精赤上身、露出古铜色结实肌肉的精壮荆州水兵手持精钢长矛与坚韧藤牌圆盾，借着战船剧烈撞击的势头飞身跳帮跃向敌军水寨木制栈桥；湍急江水激起大片白色浪花飞沫；背景中高耸巍峨的双层艨蟟战舰并列停泊，青底「刘」字与水师大旗在江风中猛烈招展，水寨箭楼上哨兵急促放箭。"
            "构图与比例：电影级横版 16:9 构图，充满张力与视觉冲击力的跳帮肉搏瞬间，水兵人体解剖与动态比例协调扎实（严禁人物畸形过大或夸张大头占据全屏），震撼还原古代水军近身接舷搏杀。"
        ),
        "refs": ["pics/source/soldiers/jingzhou_shuijun.jpg"],
    },
    {
        "key": "jx_zongzei",
        "name": "新野郊外 · 豪强宗贼坞堡蜂拥杀出",
        "prompt": (
            "横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG战斗底图：【新野郊外 · 豪强宗贼坞堡蜂拥杀出】。"
            "兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩，戏剧化战斗光影，无文字无UI。"
            "画面核心与场景：新野城外苍茫平原上一座防备森严、坚固厚重的高大夯土坞堡前；沉重的包铁防撞木制寨门轰然大开，数十名凶悍桀骜的地方宗族武装分子与护院庄勇手持明晃晃的厚背朴刀、猎弓与燃烧的火把如潮水般从深邃门洞中蜂拥冲出杀向前方；夯土高墙与角楼箭垛上有宗族恶霸首领按刀怒吼指挥，警钟当当狂鸣，烟尘滚滚弥漫。"
            "构图与比例：电影级横版 16:9 构图，极具视觉冲击力的要塞冲锋出击全景与中景，武装人群与坚固坞堡比例严谨真实（严禁人物畸形巨大或夸张特写占据全屏），真实再现汉末豪强大族坞堡割据械斗的凶悍震撼。"
        ),
        "refs": ["pics/source/soldiers/zongzei.jpg"],
    },
]

ingest_lock = threading.Lock()
upload_cache: dict[str, str] = {}
upload_lock = threading.Lock()


def get_ref_urls(api_key: str, refs: list[str]) -> list[str]:
    urls = []
    for r in refs:
        p = ROOT / r
        if not p.exists():
            print(f"Warning: reference not found: {r}")
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
    name = task["name"]
    print(f"\n[{idx}/{total}] >>> Starting {key} ({name})...")

    img_url = task.get("pre_generated_url")
    if not img_url:
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

    inbox_file = ROOT / "pics" / "inbox" / f"{key}.png"
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
    total = len(TASKS)
    print(f"=== Starting Regeneration of {total} Battle CGs with GPT Image 2 Developer ===")

    # Use 2 concurrent workers for efficiency and reliability
    success_count = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
        futures = {
            executor.submit(process_task, task, api_key, i + 1, total): task["key"]
            for i, task in enumerate(TASKS)
        }
        for fut in concurrent.futures.as_completed(futures):
            key = futures[fut]
            try:
                ok = fut.result()
                if ok:
                    success_count += 1
            except Exception as e:
                print(f"Exception during {key}: {e}")

    print(f"\n=== Finished: {success_count}/{total} battle CGs regenerated and ingested ===")

    # Flush docs
    print("Flushing docs via art_ingest.py flush...")
    subprocess.run([sys.executable, str(ROOT / "tools" / "art_ingest.py"), "flush"])

    print("All done!")


if __name__ == "__main__":
    main()
