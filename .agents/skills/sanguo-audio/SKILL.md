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
│   ├── enemy_hit_1.wav # 敌方打击命中
│   ├── shout_male_1.wav # 男武将短促出招呼喝（多变体）
│   ├── shout_male_ult.wav # 男武将大招爆发战吼
│   ├── shout_female_1.wav # 女武将短促出招呼喝（多变体）
│   ├── shout_female_ult.wav # 女武将大招爆发战吼
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

### B. 人物战斗叫喊 (Character Chinese Battle Shouts)
1. **开源中文游戏语音数据集**（如 Hugging Face 角色语音集）：
   - 提取角色出招发力音（Weapon Hit / Skill Cast），如主角、少年武将、英气女将的短促喝声（“哈！”、“喝！”、“接招！”）。
2. **[爱给网 (aigei.com)](https://www.aigei.com/) / [耳聆网 (earleyst.com)](https://www.earleyst.com/)**：
   - 搜索分类：`游戏人物 战斗呼喝`、`武将 战吼`、`技能 喊叫`、`释放技能 语音`。
   - 包含国内配音演员录制的游戏免版税中文战斗语音包（粗犷猛将、威严儒将、清脆女将）。
3. **AI 专属武将战吼生成**：
   - 推荐工具：**ElevenLabs Voice Design**、**MiniMax**、**CosyVoice**。
   - 提示词模板（英文后台）：
     - 猛将：`[deep raspy warrior, shouting in rage, aggressive battle cry] "哈啊！受死吧！"`
     - 儒将：`[commanding general, cold and majestic shout] "破！"`
     - 女将：`[valiant female knight, sharp fierce shout] "看剑！休走！"`

### C. 古风战棋背景音乐 (BGM)
1. **[Battle for Wesnoth](https://github.com/wesnoth/wesnoth)**（协议：**GPL / CC**）
   - `data/core/music/` 包含顶级管弦战棋战斗曲（`battle-epic.ogg`）、行军曲（`loyalists.ogg`）、英雄序曲（`main_menu.ogg`），支持无损循环。
2. **[Free Music Archive (FMA)](https://freemusicarchive.org/)** / **OpenGameArt Oriental 专区**：
   - 搜索 `guzheng`、`chinese traditional`、`erhu battle`，挑选古风琵琶战鼓管弦配乐。

---

## 3. 音频转换与格式标准化

Godot 4 对音频格式的最佳实践：
- **SFX 音效**：**16-bit 单声道 PCM WAV (`.wav`)**，采样率 44100Hz（解码极快，多声道并发无 CPU 瓶颈）。
- **BGM 音乐**：**Ogg Vorbis (`.ogg`)**，立体声，码率 128~192 kbps（文件小，支持流式加载与 Seamless Loop）。

### 自动下载与转换脚本

项目内提供了自动化拉取脚本 `tools/fetch_audio_assets.py`，依托项目已有的 `imageio_ffmpeg` 执行格式标准化：
```bash
python tools/fetch_audio_assets.py
```
如需转换任意外部音频文件（MP3 / FLAC / AIFF 等），可在 Python 中调用系统内置的 ffmpeg：
```bash
python -c "
import imageio_ffmpeg, subprocess
ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
# 转单声道 44.1kHz 16-bit WAV
subprocess.run([ffmpeg, '-y', '-i', 'input.mp3', '-ac', '1', '-ar', '44100', '-c:a', 'pcm_s16le', 'godot/data/audio/sfx/target.wav'])
"
```

---

## 4. 如何集成进游戏 (Integration Steps)

### 步骤一：配置音效路由表 (`godot/data/audio.json`)
在 `audio.json` 中的 `"sfx"` 字典中添加或修改事件：
```json
"hit": {
  "files": [
    "sfx/hit_1.wav",
    "sfx/hit_2.wav",
    "sfx/hit_3.wav"
  ],
  "volume_db": 0,
  "pitch": [0.92, 1.08]
},
"shout_male": {
  "files": [
    "sfx/shout_male_1.wav",
    "sfx/shout_male_2.wav"
  ],
  "volume_db": -1,
  "pitch": [0.96, 1.04]
}
```
- `files`：相对 `godot/data/audio/` 的路径。多文件会在触发时**自动随机抽取**，避免连续出刀听感单调。
- `volume_db`：相对基础音量的增益/衰减（负值表示调低）。
- `pitch`：音高微调随机区间，使多次触发时自然微变。

### 步骤二：武将发招叫喊接入逻辑 (`battle_screen.gd`)
在 `battle_screen.gd` 中：
1. 维护女将判定列表 `FEMALE_NAMES`。
2. 在 `_sfx_act(ev)` 中分流男女与大招/普攻：
```gdscript
func _sfx_act(ev: Dictionary) -> void:
    var skill: Dictionary = GameData.get_db().skills.get(ev.get("skill", ""), {})
    var is_ult := skill.get("uses", null) != null and int(skill["uses"]) == 1
    var leader_card: Dictionary = b.leaders[ev["unit"]].get("leader", {}).get("card", {})
    var female := _is_female(leader_card)

    if is_ult:
        Sfx.play("shout_female_ultimate" if female else "shout_male_ultimate")
        Sfx.play("act_ultimate")
        return

    Sfx.play("shout_female" if female else "shout_male")
    var troop: String = leader_card.get("troop", "infantry")
    Sfx.play("act_" + troop if Sfx.has("act_" + troop) else "act_infantry")
```

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
