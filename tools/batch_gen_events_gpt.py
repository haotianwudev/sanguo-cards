"""Batch generate 4 encounter / event CGs using GPT Image 2 Developer with portrait references."""
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
    "16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。"
)
SUFFIX = (
    "构图与透视规范：横版 16:9 比例，视觉小说剧情名场面，生动传神的人物微表情与肢体互动，戏剧化冷暖环境光影；"
    "前景地面自然开阔延伸，严禁任何UI界面、气泡框、字幕暗部渐变或乱码文字。"
)

EVENTS = [
    {
        "key": "e_jd_yucun",
        "title": "【奇遇 · 烧过的渔村】",
        "prompt": (
            f"{PREFIX}：【太湖水畔 · 烧过的渔村】\n"
            "画面核心与人物角色：太湖边一个刚被洗劫烧毁的残破渔村残骸中，数个身影正在废墟中对话。\n"
            "1. 周瑜（核心人物1，严格复刻参考图1周瑜立绘）：年轻俊朗、面容秀雅文弱却神采内敛的英俊白衣儒将，一手捧着摊开的军略账簿竹卷，正微微蹙眉凝视老渔翁，眼中闪烁着冷冽决断。\n"
            "2. 主角（核心人物2，参考图2南线主角）：二十岁年轻将领，身穿孙坚留下的旧银甲、内衬绿锦战袍，肩扛宽刃古锭刀，在周瑜身侧神色沉重地观察周围。\n"
            "3. 老渔翁：白发苍苍、衣衫褴褛的老农渔民，满手黑灰蹲在焦黑灰烬与破碎渔网中翻找用物，抬头向周瑜悲痛诉说。\n"
            "场景与环境：太湖水畔满目疮痍，残存数根被大火烧得乌黑焦炭的木桩，断裂的残破渔网与碎瓦；远方水面微波粼粼，隐约浮着一条不挂旗帜的神秘盐贼快船；"
            "天色薄暮，夕阳余晖洒在残破水村，带着凄凉沉郁的历史沧桑氛围；脚下是平整自然的焦黑泥土与杂草湖滩。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/generals/zhouyu.jpg",
            ROOT / "pics/source/generals/lord.jpg",
        ],
    },
    {
        "key": "e_jd_yanchuan",
        "title": "【奇遇 · 严家盐船】",
        "prompt": (
            f"{PREFIX}：【大江之畔 · 截获严家盐船】\n"
            "画面核心与人物角色：江南江畔水草丛中，一条巨大的重载商船搁浅停泊，岸边两位年轻将领正兴奋打量。\n"
            "1. 孙策（核心人物1，严格复刻参考图1孙策立绘）：浓眉大眼、身披霸气红色精甲、英气勃发如猛虎下山的少年小霸王孙策！此时他站在岸边大石上，双眼冒着狂喜兴奋的光芒，甚至激动得差点流出口水，双手叉腰哈哈大笑。\n"
            "2. 主角（核心人物2，参考图2南线主角）：身穿银甲战袍、肩扛宽刃古锭刀的年轻主帅，站在孙策身边一脸哭笑不得地抬手挠头，既震惊又好笑。\n"
            "场景与环境：江面芦苇荡边漂浮着一条庞大平稳的实木盐船，船头迎风插着一面写有「严」字的小旗；船舱内满满当当堆叠着无数雪白沉重的粗盐麻包，堆得比人还高、几乎要溢出船舷；"
            "阳光明媚照耀在白花花的盐包与清澈江面上，江风吹拂芦苇摇曳；脚下是平整坚实的江岸青草地与泥土水滩。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/generals/sunce.jpg",
            ROOT / "pics/source/generals/lord.jpg",
        ],
    },
    {
        "key": "e_hnn_liumin",
        "title": "【奇遇 · 淮北流民】",
        "prompt": (
            f"{PREFIX}：【淮北官道 · 逃亡流民与义诊】\n"
            "画面核心与人物角色：寒风呼啸的淮北荒凉官道驿路旁，一群从寿春饥荒中逃离的难民在此歇脚。\n"
            "1. 张宁（核心人物1，严格复刻参考图1张宁立绘）：成年黄巾圣女医仙，神情温柔悲悯，身穿素白如雪的布衣裙袍，身侧立着一只小巧精细的黄花梨木行医竹药箱；她正轻柔地半蹲在冰冷路边，双指为一名骨瘦如柴、高烧不退的难民孩童细心切脉搭诊。\n"
            "2. 北线主角（核心人物2，参考图2北线主角）：年轻斯文的白袍儒将，外披雪白貂裘，手持挂着红色平安结的白蜡杆长枪，在一旁庄重守卫并俯身关切探视。\n"
            "场景与环境：官道枯树枯草下，几名衣衫褴褛、面黄肌瘦的流民老者携老扶幼蜷缩在破席草堆间，眼眶噙泪神情感激；"
            "远方苍茫地平线天际隐隐泛着寿春城破的淡灰色硝烟雾气；冬日冷冽阳光穿透云层投下丝丝暖光；脚下是平整坚硬的冬日冻土官道路面。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/generals/zhangning.jpg",
            ROOT / "pics/source/generals/lord_north.jpg",
        ],
    },
    {
        "key": "e_hnn_shuili",
        "title": "【奇遇 · 仲氏税吏】",
        "prompt": (
            f"{PREFIX}：【淮南驿道 · 盘剥税吏与辨伪】\n"
            "画面核心与人物角色：淮南乡野岔路口的破旧关卡哨卡前，一出荒诞幽默的对峙正在上演。\n"
            "1. 郭嘉（核心人物1，严格复刻参考图1郭嘉立绘）：面容极其俊逸潇洒的青年谋士郭奉孝，身穿深青宽袖长袍，一手拎着标志性朱砂红酒葫芦，神态微醺轻佻；他斜着醉眼凑到诏书前，指着诏书上的大印讥讽轻笑。\n"
            "2. 仲氏税吏：一名身材矮胖滑稽的小吏，身上穿着不合体、松松垮垮的新缝制金黄色「仲氏王朝」劣质官服，双手高高举着一卷明黄绢帛新诏书，满头冷汗、眼神心虚闪烁畏缩，脚边放着一只沉重的大木税箱。\n"
            "3. 北线主角（参考图2北线主角）：手持白蜡杆长枪的青年主帅立于一旁，冷眼旁观。\n"
            "场景与环境：泥土关隘路口，税吏的粗糙木栅栏与粗木矮桌，黄绢上的朱红传国玉玺印记赫然盖得歪歪扭扭；"
            "淮南田园秋景，古道秋风，充满戏剧性荒诞讽刺的视觉小说名场面；脚下是平整坚实的乡间泥土大道。\n"
            f"{SUFFIX}"
        ),
        "refs": [
            ROOT / "pics/source/generals/guojia.jpg",
            ROOT / "pics/source/generals/lord_north.jpg",
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
            "cg",
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
    total = len(EVENTS)
    print(f"=== Starting Batch Generation of {total} Encounter CGs with GPT Image 2 Developer ===")

    success_count = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
        futures = {
            executor.submit(process_task, task, api_key, i + 1, total): task["key"]
            for i, task in enumerate(EVENTS)
        }
        for fut in concurrent.futures.as_completed(futures):
            key = futures[fut]
            try:
                ok = fut.result()
                if ok:
                    success_count += 1
            except Exception as e:
                print(f"Exception during {key}: {e}")

    print(f"\n=== Finished: {success_count}/{total} encounter CGs generated and ingested ===")

    # Flush docs
    print("Flushing docs via art_ingest.py flush...")
    subprocess.run([sys.executable, str(ROOT / "tools" / "art_ingest.py"), "flush"])

    print("All done!")


if __name__ == "__main__":
    main()
