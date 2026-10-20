---
name: sanguo-audio
description: Manage, update, and integrate game audio (realistic Foley impact SFX, config-driven Chinese battle voices built by tools/gen_voices.py, and BGM) for 重开三国 (sanguo-cards). Covers sourcing from CC0/open-source libraries, the voices table in audio.json, format standardization via ffmpeg, Godot configuration (audio.json, bgm.gd, sfx.gd), and testing.
---

# 重开三国 Audio Pipeline & Integration Guide

《重开三国》游戏音频系统的管理、资源获取、格式规范与集成开发指南。

---

## 1. 架构总览与文件规范

游戏音频分为三大类：**战斗/交互音效 (SFX)**、**战斗配音 (Voices，配置驱动)**、**场景背景音乐 (BGM)**。

### 目录结构规范

```text
godot/data/audio/
├── sfx/            # 正式音效与叫喊素材（16-bit 单声道 WAV，低延迟并发）
│   ├── hit_1.wav   # 拟真冷兵器打击、普通攻击命中
│   ├── hit_heavy.wav # 重击 / 暴击碎甲
│   ├── hit_pierce.wav # 枪刺贯穿 / 弓箭破空命中
│   ├── slash.wav   # 锋刃斩击 / 反击
│   ├── guard.wav   # 盾牌格挡
│   ├── burn.wav    # 烈火灼烧
│   ├── enemy_hit_1.wav # 敌方打击命中（厚重破甲碎裂）
│   └── ...
├── voice/          # 战斗配音（tools/gen_voices.py 按 audio.json voices 生成的 OGG，不手改）
├── sfx/gen/        # tools/generate_sfx.py 纯算法合成的占位音（供回退，不手改）
├── bgm/            # 背景音乐（Ogg Vorbis 格式，自动循环与平滑淡入淡出）
│   ├── battle.ogg  # 战斗史诗交响 BGM
│   ├── map.ogg     # 大地图古代行军 BGM
│   └── title.ogg   # 主菜单三国风云 BGM
└── (godot/data/audio.json) # sfx：事件名 → 文件、音量偏移、音高随机；voices / voice_defaults / female_names：战斗配音
```

### 单例设计

| 单例名 | 脚本路径 | 职责 |
| :--- | :--- | :--- |
| **`Sfx`** | `godot/scripts/audio/sfx.gd` | 10 音轨并发播放器。从 `audio.json` 预加载音频流，负责打击声、兵种招式音、发招呼喝、环境音。 |
| **`Bgm`** | `godot/scripts/audio/bgm.gd` | 背景音乐播放器。支持切换曲目时的平滑淡出淡入（Tween Crossfade），控制循环。 |
| **`Game`** | `godot/scripts/game.gd` | 统一管理 `options["sfx_volume"]` 与 `options["bgm_volume"]`，在设置界面提供独立滑块。 |

---

## 2. 资源去哪里找？(Sourcing Guide)

必须优先选用 **CC0 (Public Domain)** 或可商用开放许可素材，严禁侵权音频。

### A. 拟真冷兵器打击音效 (Foley / Weapon Impacts)
1. **[Kenney Assets (Audio)](https://kenney.nl/assets/category:Audio)**（协议：**CC0 公有领域**，游戏行业标杆）
   - **Impact Sounds**：包含金属铠甲撞击（Metal Heavy/Medium）、重物钝击（Punch Heavy）、木板/盾牌碰撞（Wood Heavy）。
   - **RPG Audio**：包含刀刃劈斩（Chop、Knife Slice）、抽刀、布料、脚步等精细拟音。
2. **[Unciv (开源 4X 策略)](https://github.com/yairm210/Unciv)**（协议：**CC0**）
   - `android/assets/sounds/` 包含冷兵器战场拟音：弓箭（arrow）、骑兵进军（cavalry）、金属格挡（metalhit）、火攻（fire）。
3. **[OpenGameArt.org](https://opengameart.org/)**（筛选：**License = CC0**）
   - 经典包：*20 Sword Sound Effects (Attacks and Clashes)*、*Medieval Sound Effects - Weapon Impacts*。
4. **[Freesound.org](https://freesound.org/)**（筛选：**Creative Commons 0**）
   - 推荐搜索：`sword hit armor`、`flesh impact foley`、`shield block`、`spear pierce`。

### B. 战斗配音

**配音的一切（配置、三种引擎、试音、生成、接进战斗和 CG）见 `sanguo-voice` skill**（`.claude/skills/sanguo-voice/SKILL.md`，`.agents/skills/sanguo-voice/` 是同一份）。这里只留音频处理的通用规则。

#### 关键技术：统一声学通道 (Unified Acoustic Chain)、峰值标准化与纵深声场 (Soundstage Positioning)
1. **同轨高保真声学空间**：所有角色语音（主角、武将、军师、敌将）必须通过**完全相同**的纯净 ffmpeg 通道转换输出（严禁针对个别角色强加重度 EQ 或动态压缩滤镜，否则会导致声染色脱节、“不在同一个音轨”）。
2. **0ms 物理瞬态裁剪与尾部去静音**：以音频峰值 5% 能量作为门限，精确定位声波第一个瞬态波峰采样点（留 1ms 安全前导），切除前导空白并施加 2ms 渐强淡入；同时切除结尾冗余空白（保留 120ms 混响衰减尾音），杜绝音画脱节与爆音。
3. **峰值标准化 (Peak Normalization to -0.8 dBFS)**：自动将各声源峰值放大统一至 29500 左右，彻底解决某些角色“录音电平低、听感软弱偏远”的声学距离感问题。
4. **前后景混音纵深平衡 (Foreground vs Background)**：
   - 主角（第一人称近场主角）：`volume_db: 2`（大招 `3`），声音最贴耳清晰、近在咫尺；
   - 我方武将（近身战友）：`volume_db: 1`；
   - 敌方首领（远端阵地迎击）：`volume_db: -1`（狂暴 `0`），形成自然的对峙声场纵深，杜绝“敌人贴着耳朵喊、主角反而偏远”的声学失衡。

### C. 古风战棋背景音乐 (BGM)
1. **[Battle for Wesnoth](https://github.com/wesnoth/wesnoth)**（协议：**GPL / CC**）
   - `data/core/music/` 包含顶级管弦战棋战斗曲（`battle-epic.ogg`）、行军曲（`loyalists.ogg`）、英雄序曲（`main_menu.ogg`），支持无损循环。
2. **[Free Music Archive (FMA)](https://freemusicarchive.org/)** / **OpenGameArt Oriental 专区**：
   - 搜索 `guzheng`、`chinese traditional`、`erhu battle`，挑选古风琵琶战鼓管弦配乐。

---

## 3. 音频转换与格式标准化

Godot 4 对音频格式的最佳实践：
- **配音**：单声道 OGG Vorbis（`gen_voices.py` 产出）。
- **SFX 音效**：**16-bit 单声道 PCM WAV (`.wav`)**，采样率 44100Hz（解码极快，多声道并发无 CPU 瓶颈）。
- **BGM 音乐**：**Ogg Vorbis (`.ogg`)**，立体声，码率 128~192 kbps（文件小，支持流式加载与 Seamless Loop）。战斗 BGM 剪去前戏，从第 48 秒的高潮战斗交响处直奔主题，烘托紧迫感。

---

## 4. 如何集成进游戏 (Integration Steps)

### 步骤一：音效路由表 (`godot/data/audio.json` 的 `sfx`)
```json
"hit": {"files": ["sfx/hit_1.wav", "sfx/hit_2.wav", "sfx/hit_3.wav"], "volume_db": 0, "pitch": [0.92, 1.08]}
```
- `files`：相对 `godot/data/audio/` 的路径，多个时随机挑一个。`volume_db`：相对音量。`pitch`：音高随机区间。
- 代码里 `Sfx.play("<事件名>")`。配音不走这里，见上面 B。

### 步骤二：战斗配音
改 `audio.json` 的 `voices`（加台词、加声线），给卡牌 / 敌人写 `"voice"`，跑 `gen_voices.py` + `--import`。`battle_screen.gd` 不用动。出招时还会叠一声 `slash` 破风音。

### 步骤三：BGM 场景联动与平滑过渡 (`bgm.gd`)
在场景初始化时调用 `Bgm.play("<track_name>")`：
- **标题主菜单** (`title_screen.gd`): `Bgm.play("title")`
- **行军大地图** (`map_screen.gd`): `Bgm.play("map")`
- **战斗开局** (`battle_screen.gd`): `Bgm.play("battle")`
- **战斗胜利/结算** (`battle_screen.gd`): `Bgm.stop(0.6)`（留出静音展示胜利音效与战利品）

---

## 5. 校验与自动化测试 (Verification)

添加或更新任何音效后，必须执行以下三步闭环检查：

### 1. 刷新 Godot 资源导入
```bash
G=/f/workspace/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe
timeout 120 $G --headless --path godot --import
```

### 2. 运行自动化测试套件
```bash
timeout 240 $G --headless --path godot --script res://tests/run_tests.gd
```
- 测试套件包含 `test_audio.gd` 和 `test_battle.gd`。
- 会自动校验：
  - `audio.json` 中的每一个配置项对应的物理文件是否真实存在；每句配音都有生成好的文件；默认声线覆盖每个身份；卡牌 / 敌人的 `voice` 都是存在的声线。
  - 所有兵种是否有对应的动作出招音效。
  - `Bgm.TRACKS` 注册的所有配乐是否在磁盘上就绪。
  - 音量设置选项持久化与动态更新是否正常。

### 3. 真机/Demo 运行视听检查
启动 demo 场景（如 `--demo=ln2`），戴上耳机感受刀剑劈砍、盾牌格挡低频厚度、武将喝声清晰度以及 BGM 淡入淡出是否顺畅自然。
