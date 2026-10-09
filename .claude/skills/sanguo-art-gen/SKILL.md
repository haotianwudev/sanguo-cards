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
   - 仅当内置 `generate_image` 报错 `429 Too Many Requests` / `RESOURCE_EXHAUSTED`（或在无法使用原生生图工具的环境中）时，自动触发 AtlasCloud 降级管线。
   - AtlasCloud Token 存储在项目根目录 `.env`（`ATLASCLOUD_API_KEY`）。
   - 通过 CLI 脚本 `tools/art_gen.py` 调用：
     ```bash
     python tools/art_gen.py --key <art_key> --prompt "<prompt>" --model z-image/turbo --ingest
     ```
     - 极速低成本模型（默认）：`z-image/turbo`（支持 1280*720，超快 ~3.7s，纯文本生图）
     - 精准参考图模型：`google/nano-banana-2.1/reference-to-image`（带 `--ref <path>` 自动上传参考图）

---

## 2. 出图 Prompt 规则（严格遵守）

### 战斗场景 CG（首领战 / 精英战立绘底图，16:9 横构图）
- **标题格式**：`横版 16:9 战斗场景CG插画，日系三国战术卡牌RPG首领战立绘底图：【称号 · 战斗名】`
- **人物主体**：核心敌人巨大而居中，充满对峙压迫感，面部/头部位于画面上方 30%-40% 区域，详细刻画神态、盔甲、武器。
- **背景与军阵**：必须包含所属势力的战旗、阵营兵马、战场环境（城楼、山道、水寨、风雪等）与戏剧化光影。
- **地面构图**：**自然展现战斗场景地貌（如山道碎石、黄河滩涂、城关青石地砖、木台等），无需刻意留白**。
- **画风标准**：复古日系战术动漫RPG卡牌插画，兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳的厚重色彩，戏剧化战斗光影，严禁UI界面与文字。

### 角色立绘半身像（3:4 竖构图）
- **固定开头**：`角色立绘半身像，三国历史战棋视觉小说立绘，兰斯10赛璐珞厚涂风格，精致清晰的黑色墨线勾勒，华丽沉稳的厚重色彩。`
- **构图规范**：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处，头部完整且顶部留有充分余量，无边缘裁切。
- **背景规范**：必须包含古风历史氛围背景（险峻山口、要塞关隘、营寨军阵、江防水寨、荒原雪景等），禁止纯白或纯浅灰无背景。

### 剧情插画 CG（16:9 横构图）
- **固定开头**：`16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。`
- **绝对禁词**：严禁出现「预留柔和暗部供对白字幕展示」、「便于字幕展示」、「字幕留白」或任何提及「字幕/文本框/暗部」的字样，只需自然描述开阔的前景地面。

---

## 3. 标准生成与入库步骤

1. **查需求与提示词**：
   - 打开 `pics/ART-PROMPTS.md` 查看「下一批（交给 Gemini）」清单。
   - 寻找目标人物在 `pics/source/generals/<key>.jpg` 的参考原图。
2. **生图执行**：
   - **Step A**：调用内置 `generate_image`，传入 prompt、16:9（或 3:4）、`ImagePaths: ["pics/source/generals/<key>.jpg"]`。
   - **Step B（若 429 报错）**：调用 `python tools/art_gen.py --key <key> --prompt "<prompt>" --model z-image/turbo --ingest`。
3. **入库与注册**：
   - 若通过 Step A 生成，调用 `python tools/art_ingest.py add "<image_path>" <key>`。
   - 每批次生成完成后（或达到 ~20 张），运行 `python tools/art_ingest.py flush` 刷新需求文档与清单。
4. **验证与导入**：
   - 运行 Godot 导入命令：
     ```bash
     & "F:\workspace\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "godot" --import
     ```
   - 运行测试确保 100% 通过：
     ```bash
     & "F:\workspace\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "godot" --script res://tests/run_tests.gd
     ```
