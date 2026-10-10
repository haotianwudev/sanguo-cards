---
name: sanguo-audio
description: Manage, update, and integrate game audio (realistic Foley impact SFX, character Chinese battle shouts, and BGM) for 重开三国 (sanguo-cards). Covers sourcing from CC0/open-source libraries and voice datasets, format standardization via ffmpeg, Godot configuration (audio.json, bgm.gd, sfx.gd), and testing.
---

# 重开三国 Audio Pipeline & Integration Guide

《重开三国》游戏音频系统的管理、资源获取、格式规范与集成开发指南。

---

## 1. 架构总览与文件规范

游戏音频分为三大类：**战斗/交互音效 (SFX)**、**武将发招叫喊 (Vocal Shouts)**、**场景背景音乐 (BGM)**。

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
│   ├── shout_male_1.wav # 男武将短促出招呼喝（多变体，0ms瞬态）
│   ├── shout_male_ult.wav # 男武将大招爆发战吼
│   ├── shout_female_1.wav # 女武将短促出招呼喝（多变体，0ms瞬态）
│   ├── shout_female_ult.wav # 女武将大招爆发战吼
│   ├── shout_enemy_1.wav # 敌将出招威严喝声（多变体）
│   ├── shout_enemy_roar.wav # 敌将狂暴/蓄力暴怒战吼
│   └── ...
├── sfx/gen/        # tools/generate_sfx.py 纯算法合成的占位音（供回退，不手改）
├── bgm/            # 背景音乐（Ogg Vorbis 格式，自动循环与平滑淡入淡出）
│   ├── battle.ogg  # 战斗史诗交响 BGM
│   ├── map.ogg     # 大地图古代行军 BGM
│   └── title.ogg   # 主菜单三国风云 BGM
└── audio.json      # 音效路由表：事件名 → 对应文件列表、音量偏移、音高随机范围
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

### B. AI 人物战斗语音全套生成规范 (AI Voice Generation Pipeline)

项目内置了高保真神经语音生成与瞬态零延迟对齐工具链：
**生成脚本**：`tools/generate_all_custom_voices.py`
一键执行即可自动生成/更新全量武将与敌方语音：
```bash
python tools/generate_all_custom_voices.py
```

#### 角色声线矩阵与台词规范 (Voice Matrix)

| 角色类别 | 设定与听感 | 神经声线 (Edge/Azure) | 语速/音高参数 | 核心台词与文件 |
| :--- | :--- | :--- | :--- | :--- |
| **主角** (现代穿越者) | 现代男青年、略带吐槽冲劲、年轻生动 | `zh-CN-YunxiNeural` | rate=`+15%`<br>pitch=`+6Hz` | **普攻**：「你妹！」(`shout_hero_1.wav`)、「去你的！」(`shout_hero_2.wav`)<br>**大招**：「砸不死你！」(`shout_hero_ult.wav`) |
| **男武将** (名将) | 威风凛凛、刚猛雄浑、战场大将 | `zh-CN-YunjianNeural` | rate=`+10%`<br>pitch=`-2Hz` | **普攻**：「看招！」(`shout_male_1.wav`)、「休想跑！」(`shout_male_2.wav`)<br>**大招**：「万军莫当！」(`shout_male_ult.wav`)、「受死吧！」(`shout_male_3.wav`) |
| **女武将** (巾帼) | 英姿飒爽、清脆刚健、英气蓬勃 | `zh-CN-XiaoyiNeural` | rate=`+10%`<br>pitch=`+2Hz` | **普攻**：「看招！」(`shout_female_1.wav`)、「休想跑！」(`shout_female_2.wav`)<br>**大招**：「看我破阵！」(`shout_female_ult.wav`)、「给我瞧好了！」(`shout_female_3.wav`) |
| **军师** (谋士) | 深邃从容、儒雅沉着、谋定乾坤 | `zh-CN-YunyangNeural` | rate=`+6%`<br>pitch=`-3Hz` | **出招**：「破绽已现！」(`shout_strat_1.wav`)、「尽在掌握！」(`shout_strat_2.wav`)<br>**大招**：「计定乾坤！」(`shout_strat_ult.wav`) |
| **治疗** (医仙/女眷) | 温婉柔美、轻语抚慰、安心治愈 | `zh-CN-XiaoxiaoNeural` | rate=`-6%`<br>pitch=`+2Hz` | **治愈**：「为你疗伤……」(`voice_heal_female_1.wav`)、「别怕，安心休养……」(`voice_heal_female_2.wav`)、「伤口……好些了吗？」(`voice_heal_female_3.wav`) |
| **敌人/贼首** (反派男性) | 雄浑威严、凶悍暴戾（纯正成年大汉男声，无女声感） | `zh-CN-YunjianNeural` | rate=`+10~12%`<br>pitch=`-2~-3Hz` | **攻击**：「拿命来吧！！」(`shout_enemy_1.wav`)、「给我上！宰了他！」(`shout_enemy_2.wav`)、「拿命来！受死吧！」(`shout_enemy_3.wav`)<br>**蓄力/狂暴**：「都给我上！受死吧！」(`shout_enemy_roar.wav`) |
| **女性敌将** (极少数女头目) | 泼辣刁蛮、英气高亢 | `zh-CN-XiaoyiNeural` | rate=`+12%`<br>pitch=`+2Hz` | **攻击**：「拿命来！」(`shout_enemy_female_1.wav`)、「给我上！」(`shout_enemy_female_2.wav`)<br>**狂暴**：「都给我上！」(`shout_enemy_female_roar.wav`) |

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
- **SFX 音效与人声叫喊**：**16-bit 单声道 PCM WAV (`.wav`)**，采样率 44100Hz（解码极快，多声道并发无 CPU 瓶颈）。
- **BGM 音乐**：**Ogg Vorbis (`.ogg`)**，立体声，码率 128~192 kbps（文件小，支持流式加载与 Seamless Loop）。战斗 BGM 剪去前戏，从第 48 秒的高潮战斗交响处直奔主题，烘托紧迫感。

---

## 4. 如何集成进游戏 (Integration Steps)

### 步骤一：配置音效路由表 (`godot/data/audio.json`)
在 `audio.json` 中的 `"sfx"` 字典中添加或修改事件：
```json
"shout_hero": {
  "files": ["sfx/shout_hero_1.wav", "sfx/shout_hero_2.wav"],
  "volume_db": 1,
  "pitch": [0.98, 1.02]
},
"shout_hero_ult": {
  "files": ["sfx/shout_hero_ult.wav"],
  "volume_db": 2,
  "pitch": [1.0, 1.0]
},
"shout_enemy": {
  "files": ["sfx/shout_enemy_1.wav", "sfx/shout_enemy_2.wav", "sfx/shout_enemy_3.wav"],
  "volume_db": 1,
  "pitch": [0.96, 1.04]
},
"voice_heal_female": {
  "files": ["sfx/voice_heal_female_1.wav", "sfx/voice_heal_female_2.wav", "sfx/voice_heal_female_3.wav"],
  "volume_db": 1,
  "pitch": [0.98, 1.02]
}
```
- `files`：相对 `godot/data/audio/` 的路径。多文件会在触发时**自动随机抽取**，避免连续出刀听感单调。
- `volume_db`：相对基础音量的增益/衰减（负值表示调低）。
- `pitch`：音高微调随机区间，使多次触发时自然微变。

### 步骤二：武将出招叫喊与角色声线分流 (`battle_screen.gd`)
在 `battle_screen.gd` 中：
1. 维护女将判定列表 `FEMALE_NAMES`，使用 `cname.contains(f)` 全面覆盖所有名将、女眷与亲随。
2. 在 `_sfx_act(ev)` 中对执行卡牌进行身份判定分流：
   - **女性治疗技能**：优先触发柔和医仙声线 `Sfx.play("voice_heal_female")`。
   - **主角 (troop == "lord")**：大招触发 `shout_hero_ult`（「砸不死你！」），普攻触发 `shout_hero`（「你妹！」/「去你的！」）。
   - **军师 (troop == "strategist")**：大招触发 `shout_strategist_ultimate`（「计定乾坤！」），普攻触发 `shout_strategist`（「破绽已现！」/「尽在掌握！」）。
   - **女武将**：大招触发 `shout_female_ultimate`，普攻触发 `shout_female`（「看招！」/「休想跑！」）。
   - **男武将**：大招触发 `shout_male_ultimate`，普攻触发 `shout_male`（「看招！」/「休想跑！」）。
   - 同步叠加 `Sfx.play("slash")` 刀剑破风拟真音，增强动作力量感。
3. 敌将行动时（`enemy_hit` / `enemy_charge`），自动触发狡黠狡猾声线的「拿命来！」和「给我上！」。

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
  - `audio.json` 中的每一个配置项对应的物理文件是否真实存在。
  - 所有兵种是否有对应的动作出招音效。
  - `Bgm.TRACKS` 注册的所有配乐是否在磁盘上就绪。
  - 音量设置选项持久化与动态更新是否正常。

### 3. 真机/Demo 运行视听检查
启动 demo 场景（如 `--demo=ln2`），戴上耳机感受刀剑劈砍、盾牌格挡低频厚度、武将喝声清晰度以及 BGM 淡入淡出是否顺畅自然。
