---
name: sanguo-art-gen
description: Generate game art (battle CGs, story CGs, character portraits) for 重开三国 (sanguo-cards). Always tries the built-in generate_image tool first; if quota is exhausted (429) or unavailable, falls back to AtlasCloud API using the token in .env.
---

# 重开三国 Art Generation Workflow

Guidelines and toolchains for generating and ingesting art into `sanguo-cards`.

---

## 1. 核心出图原则（必须始终遵守）

1. **优先级第一：始终优先使用内置生图工具 (`generate_image`)**
   - 每次生成图像时，**必须首先调用内置的 `generate_image` 工具**。
   - 当生成涉及具名人物的战斗 CG 或剧情 CG 时，**必须在 `pics/source/generals/` 或 `pics/source/soldiers/` 查找对应人物/兵种立绘，并作为 `ImagePaths` reference 传入**，以保持长相、发型、铠甲设计的一致性。

2. **配额超限时的降级策略 (Fallback to AtlasCloud)**
   - 仅当内置 `generate_image` 报错 `429 Too Many Requests` / `RESOURCE_EXHAUSTED` 时，自动触发 AtlasCloud 降级管线。
   - AtlasCloud Token 存储在项目根目录 `.env`（`ATLASCLOUD_API_KEY`，已被 `.gitignore` 忽略）。
   - 通过 CLI 脚本 `tools/art_gen.py` 调用（自动上传本地参考图并调用对应生图端点）：
     ```bash
     python tools/art_gen.py --key <art_key> --prompt "<prompt>" [--ref <ref_image>] [--model <model_id>] --ingest
     ```

---

## 2. 外部备选模型实测账单与选型矩阵 (AtlasCloud 实测计费与画质测评)

根据后台真实账单数据与最新 Developer 模型实测对比（已在战斗CG与事件CG实测验证）：

| 模型标识 (`--model`) | 实际账单单价 | 分辨率 | 参考图支持 (`--ref`) | 实测画质与选型定位 |
| :--- | :--- | :--- | :--- | :--- |
| **`openai/gpt-image-2-developer`**<br>(带图自动转: `.../edit`) | **$0.004**<br>(Edit: $0.005) | **1672×941**<br>(或 1536×1024) | **完美支持**<br>(最多 10 张) | **【极致超低价 / 白菜价神仙模型 / 中文书法无敌】**<br>单张仅约 **¥0.028~¥0.035**。实测事件CG左慈（`e_zuoci`）与华佗（`e_huatuo`）：人物完全复刻立绘特征，剧情动作（切脉诊疗）生动准确；**汉字排版神级**（药箱「沛国华佗」、幌子「義診」、医方「藥到病除」、古碑「左慈」字迹工整优美毫无乱码）；性价比之王！ |
| **`xai/grok-imagine-image-2.0-developer`**<br>(带图自动转: `.../edit`) | **$0.014** | 1280×720<br>(或 1K) | **完美支持**<br>(`image_urls`) | **【黑白墨线张力极强 / 动态伏击战斗绝佳】**<br>单张约 ¥0.10，~10-25s 直出。实测伏击事件（`e_ambush`）：水贼破水冲锋、敲锣挥刀、水花飞溅，黑色墨线极富日漫热血张力；也支持清晰汉字牌匾。 |
| **`google/nano-banana-2-lite/text-to-image-developer`**<br>(带图自动转: `edit-developer`) | **$0.014** | 1K | **完美支持**<br>(最多 14 张) | **【日常主力 / 稳定高质】**<br>单张约 ¥0.10，速度快（~15s）。全量 33 张战斗 CG 批量生成验证 100% 成功率，光影、色彩与兰斯10赛璐珞契合度高。 |
| **`bytedance/seedream-v5.0-lite`** | **$0.0315** | **2560×1440**<br>(2.5K 超清) | 暂无图生图 | **【冲锋 / 史诗大场面首选】**<br>单张约 ¥0.22。实测樊稠（`c6_fanchou`）与张济（`c6_zhangji`）大魄力骑兵冲锋、万马齐奔、扬尘碎石极富动感与纵深。 |
| **`google/nano-banana-2/text-to-image-developer`**<br>(带图自动转: `reference-to-image-developer`) | **$0.042** (2K带参考图) | **2K** / 4K | **完美支持**<br>(最多 10 张) | **【核心首领 / 精准还原首选】**<br>单张约 ¥0.30。实测黄巾渠帅（`bh_hj_qushuai`）100% 复刻立绘道袍八卦纹、黄色头巾、雷电桃木剑，旗号「黄天当立」精准无误。 |
| **`z-image/turbo`** | **$0.005** | 1280×720 | 纯文本 | 极速超便宜（约 ¥0.03/张，3.7s 直出），画风偏扁平卡通，仅适合快速验证 prompt 构图。 |

---

## 3. 出图 Prompt 规则（严格遵守）

### 战斗场景 CG（首领战 / 精英战立绘底图，16:9 横构图）
- **标题格式**：`横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG首领战立绘底图：【称号 · 战斗名】`
- **人物主体**：核心敌人巨大而居中，充满对峙压迫感，面部/头部位于画面上方 30%-40% 区域，详细刻画神态、盔甲、武器。
- **背景与军阵**：必须包含所属势力的战旗、阵营兵马、战场环境（城楼、山道、水寨、风雪等）与戏剧化光影。
- **地面构图规范**：**自然展现战斗场景地貌（如山道碎石、黄河滩涂、城关青石地砖、宴席地毯等），无需刻意留白**。
- **画风标准**：复古日系战术动漫RPG卡牌插画，兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳的厚重色彩，戏剧化战斗光影，严禁UI界面与文字。

### 角色立绘半身像（3:4 竖构图）
- **固定开头**：`角色立绘半身像，三国历史战棋视觉小说立绘，兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳色彩。`
- **构图规范**：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处，头部完整且顶部留有充分余量，无边缘裁切。
- **背景规范**：必须包含古风历史氛围背景（险峻山口、要塞关隘、营寨军阵、江防水寨、荒原雪景等），禁止纯白或纯浅灰无背景。

### 剧情插画 CG（16:9 横构图）
- **固定开头**：`16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。`
- **绝对禁词**：严禁出现「预留柔和暗部供对白字幕展示」、「便于字幕展示」、「字幕留白」或任何提及「字幕/文本框/暗部」的字样，只需自然描述开阔的前景地面。

---

## 4. 标准生成与入库全流程

1. **查需求与参考图**：
   - 查阅 `pics/ART-PROMPTS.md` 取出目标 key 与 prompt。
   - 寻找目标人物在 `pics/source/generals/<key>.jpg` 或 `pics/source/soldiers/<key>.jpg` 的参考原图。
2. **执行生图**：
   - **优先**：调用内置 `generate_image`，传入 prompt、16:9（或 3:4）、`ImagePaths: ["pics/source/..."]`。
   - **降级极低成本主力（GPT Image 2 Developer / Nano Banana 2 Lite）**：
     ```bash
     python tools/art_gen.py --key <key> --model gpt-image-2 --ref "pics/source/generals/<key>.jpg" --prompt "<prompt>" --ingest
     # 或
     python tools/art_gen.py --key <key> --model nano-banana-2-lite --ref "pics/source/generals/<key>.jpg" --prompt "<prompt>" --ingest
     ```
   - **降级高精首领（Nano Banana 2 Developer，2K带字带图）**：
     ```bash
     python tools/art_gen.py --key <key> --model google/nano-banana-2/text-to-image-developer --ref "pics/source/generals/<key>.jpg" --prompt "<prompt>" --ingest
     ```
   - **降级史诗冲锋（Seedream 2.5K 超清户外军阵）**：
     ```bash
     python tools/art_gen.py --key <key> --model bytedance/seedream-v5.0-lite --size "2560*1440" --prompt "<prompt>" --ingest
     ```
3. **入库与同步**：
   - 每批次生成完成后（或达到 ~20 张），运行 `python tools/art_ingest.py flush` 刷新文档。
4. **导入与回归验证**：
   - 运行 Godot 资源导入：
     ```bash
     & "F:\workspace\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "godot" --import
     ```
   - 运行自动化回归测试（确保 195+ 用例全绿）：
     ```bash
     & "F:\workspace\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "godot" --script res://tests/run_tests.gd
     ```
