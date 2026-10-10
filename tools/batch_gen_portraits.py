"""Batch generate remaining 10 portraits using GPT Image 2 Developer."""
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
from art_gen import load_api_key, generate_image_atlas

PREFIX = "角色立绘半身像，三国历史战棋视觉小说立绘，兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳的厚重色彩。"
SUFFIX = "构图与景深规范：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处，头部完整且顶部留有充分余量，无边缘裁切。画面纯净，严禁任何UI界面、气泡框或文字乱码。"

TASKS = [
    {
        "key": "leixu",
        "name": "雷绪（R 贼）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：雷绪（庐江雷家族长，豪帅，袁术在庐江的靠山）。五十多岁的中年蛮荒豪帅，面相冷硬凶悍，饱经风霜满脸皱纹，眼神固执认死理。\n"
            "服饰与武器：身穿磨损古旧的战阵锁子皮甲，外罩一袭宽大的深色族长毛边宽袍；双手紧握一柄厚重开刃的旧铁阔刀，刀刃隐隐泛着寒光。\n"
            "背景环境：灊山险峰之上的雷家族寨木制营垒，粗糙巨木栅栏、巡逻望楼与翻滚的山口雾气，层次分明，带有苍凉野性的山寨环境光，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "xugong",
        "name": "许贡（R 策士）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：许贡（吴郡太守，老谋深算，暗通严白虎的反派）。五十多岁干瘦阴鸷的文官太守，面容削瘦刻薄，狡黠阴险，笑起来双眼眯成一条细缝。\n"
            "服饰与器物：身穿考究华贵的汉末太守暗深色刺绣官袍，头戴威仪讲究的进贤冠；一手轻轻捋着下巴上稀疏的花白胡须，另一手暗中捏着一张加盖朱印的机密请帖密信。\n"
            "背景环境：吴郡太守府庄重深沉的议事正堂，青石地砖、朱红雕花漆柱与古朴山水屏风，带有典雅阴柔的室内光影层次，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "yufan",
        "name": "虞翻（SR 策士）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：虞翻（字仲翔，王朗功曹，刚直不阿、直言敢谏的狂士文臣）。四十岁上下，身材清瘦挺拔，面容耿直坚毅，下巴线条倔强，双目如鹰隼般锐利炽热。\n"
            "服饰与器物：身穿粗糙朴素的青灰色文士麻布长袍，宽袍下摆利落地掖在腰带间，脚踏草鞋；手中紧紧拄着一杆充当拐杖的精铁长矛，气度傲岸不凡。\n"
            "背景环境：会稽古城厚重坚固的青石城门前，斑驳城墙、高悬战旗与守关兵戈林立，带有一丝坚守与悲壮的江东古城环境光，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "jiangdong_qi",
        "name": "江东骑卒（N 骑兵）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：江东骑卒（兵卡，江东轻骑兵）。二十多岁的年轻骑兵战士，皮肤晒得黝黑健朗，神情敏锐机灵，英姿勃发。\n"
            "服饰与武器：身穿孙氏江东军标志性的鲜艳红色号衣，外罩便于水网机动的轻便鱼鳞皮甲，头上紧裹红色战巾；单手握着一柄精钢马刀，身侧立着一匹矮壮结实、神采奕奕的江南战马。\n"
            "背景环境：大江之畔的繁茂水草芦苇荡与开阔渡口，江面上微波粼粼、数艘战船隐现，带有湿润明媚的江南水乡自然光影，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "jiangdong_shuzuo",
        "name": "江东书佐（N 策士）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：江东书佐（兵卡，江东基层文吏）。二十岁上下的年轻文书吏员，面容清瘦白净，目光专注敬业，神情极为认真负责。\n"
            "服饰与器物：身着一身齐整朴素的青色汉式布袍长衫，头戴端正的文吏小冠；一手稳稳抱着一叠编连整齐的竹简账册，另一手握着一杆蘸墨毛笔。\n"
            "背景环境：江东官署军幕内整齐的书案与堆叠文书卷轴，案头摆着砚台与铜灯，阳光从窗棂洒入形成柔和光斑，室内景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "xiangyang_xuezi",
        "name": "襄阳学子（N 策士）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：襄阳学子（兵卡，荆襄名士门下求学士子）。二十岁上下的青年书生，相貌文雅俊秀，朝气蓬勃，眼神清澈而略带一丝书呆子气的纯粹与执着。\n"
            "服饰与器物：身穿整洁潇洒的白色对襟儒衫长袍，腰间斜挂着一只刺绣考究的书袋；双手恭敬端捧着一卷摊开的古圣先贤典籍，身后背负一把防身防贼的青铜短剑。\n"
            "背景环境：襄阳学堂清幽雅致的木构回廊与庭院，青松翠竹掩映，古朴假山与水池，带有书香静谧的自然柔光，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "jizhou_qi",
        "name": "冀州骑卒（N 骑兵）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：冀州骑卒（兵卡，河北精锐重骑兵）。二十多岁的河北健儿，体魄高大魁梧，面容坚毅沉稳，棱角分明，眼神无畏。\n"
            "服饰与武器：身披冀州正规官军制式的暗红色坚硬铁札甲，头戴护颈厚重铁盔；单手稳稳擎着一杆寒光闪烁的长矛，身后依傍一匹身形高大神骏的河北重甲战马。\n"
            "背景环境：冀州广袤无垠的平原金色麦田与塞北苍茫天穹，风吹麦浪，远处有巍峨要塞烽火台，带有辽阔粗犷的北方战场光影，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "hebei_shuzuo",
        "name": "河北书佐（N 策士）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：河北书佐（兵卡，北方大营文吏）。二十多岁的北地文官吏员，面容白净斯文，由于北方严寒天气，鼻头与耳垂冻得微微发红，眼神严谨细腻。\n"
            "服饰与器物：身穿厚实温暖的深色加厚汉式棉袍，外罩保暖避寒的北方毛皮短裘大氅；怀中稳稳抱着一厚摞厚重军需账册、算盘与象牙算筹。\n"
            "背景环境：风雪纷飞中的幽冀官署门楼前，白雪覆盖的青黑屋檐、石狮与雪中红灯笼，漫天雪花飘舞，带有寒冷真实的风雪环境光，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "heishan_louluo",
        "name": "黑山喽啰（N 贼）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：黑山喽啰（兵卡，太行山黑山军流民山贼）。二十岁上下的太行山民草莽，身形虽有些面黄肌瘦，但眼神狂野凶狠，身手矫健敏捷如恶狼。\n"
            "服饰与武器：身穿磨损粗糙的黑色旧短褐麻布衣，头上紧裹标志性的黑布头巾；单手握着一把带有数处豁口磨损但依然锋利的粗制柴刀与山猎木短叉。\n"
            "背景环境：太行山幽暗险峻、巨石嶙峋的险道隘口，干枯冬木、悬崖峭壁与深山迷雾环绕，充满危险野性的山林乱石光影，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
    {
        "key": "taishan_zei",
        "name": "泰山贼（N 贼）",
        "prompt": (
            f"{PREFIX}\n"
            "人物主体：泰山贼（兵卡，泰山群寇草莽悍匪）。三十岁上下的彪悍山匪壮汉，满脸浓密粗硬的胡茬，神情豪横桀骜，嘴角咧开一口狂放野性的笑容。\n"
            "服饰与武器：粗犷厚重的粗制皮甲外披着一块猎获的凶猛兽皮大氅，腰间随意缠挂着几大串黄铜铜钱；单手豪迈地扛着一把沉重雪亮的开山大铁斧。\n"
            "背景环境：泰山崇山峻岭中险峻的盘道山口关隘，脚边踩着截断山道的大段拦路拒马圆木，苍松劲柏立于险峰，带有雄浑险拔的古风山寨环境光，景深柔和且服从于前景主体人物。\n"
            f"{SUFFIX}"
        ),
    },
]

ingest_lock = threading.Lock()


def process_task(task: dict, api_key: str, idx: int, total: int) -> bool:
    key = task["key"]
    name = task["name"]
    print(f"\n[{idx}/{total}] >>> Starting generation for {key} ({name})...")

    try:
        img_url = generate_image_atlas(
            api_key=api_key,
            prompt=task["prompt"],
            model="gpt-image-2",
            size="1024x1536",
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
            "--force",
        ]
        res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
        if res.returncode != 0:
            print(f"[{idx}/{total}] Ingestion error for {key}:\n{res.stderr or res.stdout}")
            return False
        else:
            print(f"[{idx}/{total}] ✓ Successfully ingested {key}")

    return True


def main() -> None:
    api_key = load_api_key()
    total = len(TASKS)
    print(f"=== Starting Batch Generation of {total} Portraits with GPT Image 2 Developer ===")

    success_count = 0
    # Use 2 workers for steady generation without hitting concurrency limits
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

    print(f"\n=== Finished: {success_count}/{total} portraits generated and ingested ===")

    # Flush docs
    print("Flushing docs via art_ingest.py flush...")
    subprocess.run([sys.executable, str(ROOT / "tools" / "art_ingest.py"), "flush"])

    print("All done!")


if __name__ == "__main__":
    main()
