---
name: sanguo-voice
description: 给《重开三国》(sanguo-cards) 的角色做战斗配音——试音（先本地 IndexTTS 2，不好再 MiniMax）、写 audio.json 的 voices 配置、生成 / 清理 / 校验配音文件、接进战斗和 CG。用户说「给 XX 配音」「XX 喊一句……」「换主角的声音」「这句再凶一点」时用。
---

# 战斗配音

**原则**：配音全部由配置驱动——台词、音色、语气都写在 `godot/data/audio.json` 的 `voices` 里，战斗代码里不写任何台词。
只用我们自己生成的声音（edge-tts / MiniMax / 本地 IndexTTS 2 / 用户自己录的），**不用别家游戏、影视的配音，也不拿真人演员的声音当参考音**——仓库是公开的（以前扒过《原神》的喊声，已删）。
**先本地、不好再 MiniMax（用户定）**：先用本地 IndexTTS 2 试（参考音用免费的 edge-tts 生成）；用户觉得不好，再用 MiniMax 直接念台词——用了 MiniMax 就不要再套一层本地模型，没必要。
**用户给一段别人的录音（素材网站、游戏、影视）说「做个类似的」**：只当风格参照——转写出台词、量时长 / 节奏 / 音高走向 / 哪里加重（`faster-whisper` 用 `device="cpu"`，本机的 CUDA 库不全），再用我们自己的音色按这个风格生成。**原录音不喂给任何模型**（不当 `ref`、不当 IndexTTS 的情绪参考），也不进仓库；对比时可以把它放在第 0 个给用户听。下载的文件放在草稿目录里单独的文件夹。
新声音都要用户先听过、点头再进游戏；试音文件直接在他电脑上打开（`start "" x.wav`），一次给一个对比文件，不要一句一句开。

## 配置（`godot/data/audio.json`）

```jsonc
"voice_defaults": {"lord": "hero", "strategist": "strategist", "female": "female", "male": "male",
                   "enemy_female": "enemy_female", "enemy_male": "enemy_male"},   // 身份 → 默认声线
"troop_voices": {"spear": "spear", "cavalry": "cavalry"},                                             // 兵种 → 声线（只给男性用）
"female_names": ["貂蝉", "孙尚香", …],                                         // 判断女性用的名字片段
"voices": {
  "hero": {                                  // 一个「声线」
    "name": "主角（现代穿越者）",
    "engine": "indextts",                    // 不写 = edge-tts
    "ref": "hero_ref_unrestrained.wav",      // indextts：音色参考音，在 audio_src/voice/
    "emo": [0, 100, 0, 0, 0, 0, 0, 0],       // indextts：语气，8 个 0..100（喜 怒 哀 惧 厌恶 忧郁 惊讶 平静）
    "tempo": 82,                             // 可选：生成后变速不变调，82 = 0.82 倍（慢一点）；录音 src 不受影响
    "source": "来历：谁生成的、参考音怎么来的",
    "volume_db": 2,
    "attack":   ["你妹的！", "去你的！"],     // 普通出招
    "ultimate": ["砸不死你！"]               // 大招 / BOOST
  },
  "male":  {"tts": ["zh-CN-YunjianNeural", "+10%", "-2Hz"], "attack": […], "ultimate": […]},   // edge-tts：[音色, 语速, 音高]
  "zhangfei": {"engine": "minimax", "voice": "male-qn-badao", "emotion": "angry",    // MiniMax 直接念
               "speed": 105, "pitch": -2, "attack": […]},                             // speed / pitch 写整数：105 = 1.05 倍
  "lvbu": {
    "source": "用户用 Fish Audio 生成 …",
    "intro":    [{"text": "谁敢与我一战！", "src": "lvbu_shuigan_fish.wav"}],   // 现成录音
    "ultimate": [{"text": "谁敢与我一战！", "src": "lvbu_shuigan_fish.wav"}],
    "roar":     [{"text": "谁敢与我一战！", "src": "lvbu_shuigan_fish.wav"}],
  }
}
```

- **时机**：`attack` 普通出招 · `ultimate` 大招（3 AP 以上 / 限 1 / special）和 BOOST · `heal` 治疗 · `roar` 敌人蓄力、狂暴、放蓄力招 · `intro` 登场（他当敌人的战斗开打时；以及**任何一张 CG 的戏里他开口的那一行**：戏里有他亲口说出这句台词（去掉标点比对）的那一行就在那一行喊，没有就在他第一次开口时喊——全自动，不用列表、不挑场景：卡牌挂了 `voice`、声线有 `intro`，就在每张有他说话的 CG 里喊。谁在说话用 `Kit.speakers` 判断，和对话框头像同一套；他不说话就不喊；一张 CG 里几个人各喊各的；地图和过场都算；同一声线 20 秒内不重复）。
- **三种引擎**（声线的 `engine`）：不写 = edge-tts（`tts`）；`indextts` = 本地模型（`ref` 参考音 + `emo` 语气）；`minimax` = MiniMax 直接念（`voice` 音色 ID、`emotion`、`speed`、`pitch`）。
- **一句台词**的写法：字符串；`{"text", "tts"}` / `{"text", "emo"}` / `{"text", "emotion"}`（单句换音色或语气）；`{"text", "src": "x.wav"}`（`audio_src/voice/` 里的现成录音，比如剪过的，游戏里叫 `x.ogg`）。
- **谁用哪个声线**：卡牌（`cards.json`）写 `"voice": "<声线>"`。我方出招按顺序找：卡牌自己的 → 兵种的（`troop_voices`，男性才用；枪兵「看枪！」）→ 按身份的默认。敌人按顺序找：自己的 `voice` → `card` 那张卡的 → 立绘那张卡的（掉并州兵卡的吕布战也是吕布）→ 按性别的默认。`game_data.gd` 把 `voice` 带进 `db.cards` 和战斗卡。
- **兜底**：缺的时机落回默认声线，顺序：治疗 `heal → (ultimate) → attack`，大招 `ultimate → attack`，敌人 `roar → attack`。所以给名将配专属，只写他有的那几句。
- **文件名**：`<声线>_<时机>_<哈希>.ogg`，哈希取「音色|语速|音高|台词」/「indextts|参考音|语气|台词」/「minimax|音色|情绪|语速|音高|台词」——改了任何一样就是新文件。`gen_voices.py` 和 `Sfx.voice_file`（`scripts/audio/sfx.gd`）各算一遍，两边规则必须一致；没有清单文件。

## 命令

```bash
cd /f/workspace/sanguo-cards
python tools/gen_voices.py            # 生成缺的（indextts 的句子一次性交给本地模型；minimax 的逐句调 API，要 .env 里的 ATLASCLOUD_API_KEY）
python tools/gen_voices.py --prune    # 再删掉没人用的旧文件（换了台词 / 音色以后一定要跑）
python tools/gen_voices.py --check    # 缺文件 exit 1
G=/f/workspace/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe
timeout 120 $G --headless --path godot --import    # 新 .ogg 要导入；.ogg 和 .ogg.import 一起提交
```
测试（`tests/test_audio.gd`）：每句都有文件、默认声线覆盖每个身份、卡牌 / 敌人的 `voice` 存在、CG 配音等到说话人第一句才喊、每句专属台词都写进了至少一场 CG 戏（剧情里真说出来，配音和字幕同时出现）、每场吕布战都解析到吕布。

## 给一个角色做配音（流程）

1. **定台词**：**每个角色就一句**（用户定）——一句招牌台词，`intro` / `ultimate` / `roar` 都用它；普通出招不配专属台词，走兵种的（`troop_voices`）或按身份的默认。只给用户推荐一句，不列一堆备选。短、一口气喊完。台词要符合人设（主角是逗比：「你妹的！」；吕布狂：「谁敢与我一战！」）。
2. **先本地试**（免费）：
   ```bash
   python tools/voice_audition.py --ref-text "<他用自己口吻说的一段话，约 8 秒>"        --line "<台词1>" --line "<台词2>"        --voice zh-CN-YunjianNeural --voice zh-CN-YunyangNeural --voice zh-CN-YunxiNeural        --emo 0,100,0,0,0,0,0,0
   ```
   每个候选 edge-tts 音色先念参考话，再由本地 IndexTTS 2 用这个音色、这个语气念台词，拼成 `compare.wav` 自动打开。告诉用户顺序（第 1 个 = 哪个音色）。
   edge-tts 普通话男声只有四个：`zh-CN-YunjianNeural`（刚猛）、`zh-CN-YunyangNeural`（沉稳）、`zh-CN-YunxiNeural`（年轻）、`zh-CN-YunxiaNeural`（少年）；女声：`zh-CN-XiaoxiaoNeural`、`zh-CN-XiaoyiNeural`、`zh-CN-liaoning-XiaobeiNeural`（东北）、`zh-CN-shaanxi-XiaoniNeural`（陕西）。用 `edge_tts.list_voices()` 查最新的——不存在的音色报 `NoAudioReceived`。
   **不好再 MiniMax**（按字收费）：
   ```bash
   python tools/voice_audition.py --engine minimax --line "<台词>"        --voice male-qn-jingying --voice "Chinese (Mandarin)_Reliable_Executive" --emotion angry
   ```
   MiniMax 直接念台词，不套本地模型。语气还不够冲时，可以在台词前加个「哈！」生成、再剪掉，存成 `src` 录音（吕布最早那版就是这样做的，后来换成了 Fish Audio 的）。
3. **用户选定后**：本地版——把选中的 `ref_<n>.wav` 复制到 `audio_src/voice/<角色>_ref_<说明>.wav`，声线写 `engine: indextts`、`ref`、`emo`；MiniMax 版——声线写 `engine: minimax`、`voice`、`emotion`（`gen_voices.py` 会重新念一遍，MiniMax 每次结果略有不同，不满意就再跑或改用 `src` 存下试音里那条）。都写上 `source`（来历）和台词；卡牌写 `"voice"`；有 `intro` 就自动在他开口的 CG 里喊，不用再配。**再把这句台词写进剧情**：挑一场有 CG、合他身份的戏，加一行 `@<他> 「台词」`（旁白和台词分两行，`test_story_text` 管），测试 `test_every_entrance_line_is_said_in_some_cg_scene` 会查。
4. `gen_voices.py --prune` → `--import` → 跑测试 → 截一场有他的战斗看没报错（`--demo=fight --scenario=<id>`）→ 按路径 `git add`（`audio_src/voice/`、`godot/data/audio/voice/`、`audio.json`、`cards.json`）→ 提交、推送。

**用户直接给一条自己生成的 AI 语音**（Fish Audio 等）：当 `src` 录音入库——复制进 `audio_src/voice/<角色>_<说明>.wav`（先转写确认台词，剪掉头尾杂音），`source` 写清是用户用什么生成的，再按上面第 3、4 步接进游戏。这类不用再试音。

## 三种声音来源

| 来源 | 什么时候用 | 要点 |
|---|---|---|
| **edge-tts**（默认） | 通用声线（男将 / 女将 / 军师 / 杂兵）；本地模型的参考音 | 免费；没有情绪，喊不出气势。报 403 就 `pip install -U edge-tts` |
| **MiniMax Speech 2.6 Turbo**（AtlasCloud） | 本地不好时，直接念台词（`engine: minimax`） | 按字收费；只能选预设音色和 `emotion`（angry 等），不能调强度，**没有声音克隆**。AtlasCloud 文档只列英文音色，但填中文音色 ID 也能用，要加 `language_boost: Chinese`。用过的中文音色：`Chinese (Mandarin)_Reliable_Executive`（吕布）、`Chinese (Mandarin)_Unrestrained_Young_Man`（主角参考）、`male-qn-jingying`、`male-qn-qingse`、`male-qn-badao`、`male-qn-daxuesheng`、`Chinese (Mandarin)_Gentle_Youth`、`audiobook_male_2` |
| **IndexTTS 2**（本地，先试它） | 名将和主角的台词 | 免费、可复现；照参考音的音色说任何话，愤怒等语气能按 0..100 调。参考音 3～10 秒最好（太短音色会跑）。装在 `F:/workspace/tts/index-tts`（`INDEXTTS_DIR` 可改），RTX 4070 Ti 一句约 2 秒，第一次加载模型约 1 分钟 |

### IndexTTS 2 安装（换机器时）
```bash
python -m pip install -U uv
git clone --depth 1 https://github.com/index-tts/index-tts.git /f/workspace/tts/index-tts && cd /f/workspace/tts/index-tts
python -m uv sync                     # 不要 --all-extras：flash-attn 在 Windows 上要本机编 CUDA，编不过
python -m uv run hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints
```
`tools/indextts_job.py` 是 `gen_voices.py` / `voice_audition.py` 在 IndexTTS 自己的环境里调用的批处理（模型只加载一次），不手动跑。

### 现在的声线
- `hero` 主角：用户用 Fish Audio 生成的东北口音「你妹的！」「去你的！」（attack，随机）和「砸不死你！」（ultimate）（`src`，2026-10-20 替换了本地 IndexTTS 版；那版的参考音 `hero_ref_unrestrained.wav` 还留在 audio_src/voice/，上面配置示例里的 `tempo` 82 也是那版用过的）。
- `lvbu` 吕布：用户用 Fish Audio 生成的「谁敢与我一战！」（`src`，替换了原来的 MiniMax 版），intro / ultimate / roar 同一句。
- `sunce` 孙策（三张卡都挂）：Fish Audio 生成的「小霸王在此，谁敢挡我！」（中间停顿压短了），intro / ultimate / roar；普通出招还没有专属台词，暂时走骑兵的。
- `zhouyu` 周瑜（两张卡都挂）：Fish Audio 生成的「这笔账，一把火结清。」，intro / ultimate / roar；普通出招暂时走军师默认。
- `guojia` 郭嘉：Fish Audio 生成的「这一局，早就算好了。」（用的是 Fish 里周瑜的音色），intro / ultimate / roar。
- `cavalry` 骑兵（男）：Fish Audio 生成的「冲锋！」「突击！」（吕布的声音，随机挑一句），只配了 attack。
- `spear` 枪兵（男）：Fish Audio 生成的「看枪！」「刺！」（赵云的声音，随机挑一句），只配了 attack，大招落回男将默认。
- `zhaoyun` 赵云：用户自己用 **Fish Audio** 生成的「常山赵子龙在此！」（`src`，剪掉了结尾杂音），intro / ultimate / roar 同一句。
- `strategist` 策士（男）：Fish Audio 生成的「大局已定。」「谋定乾坤。」（周瑜的音色，随机挑一句），只配了 attack，大招也落到这两句。女策士（蔡文姬、黄月英）不走它，走女将默认。
- `diaochan` 貂蝉：Fish Audio 生成的「让小女为将军跳上一舞。」，attack + intro（大招、怒吼落回 attack）。没有她当敌人的战斗。
- `wuguotai` 吴夫人：Fish Audio 生成的「多大的人了，还怕疼。」（「温柔」音色），heal + intro（她只有「慈母」一招治疗）。
- `zhangfuren` 张夫人：Fish Audio 生成的「这账咱们得记着。」（「温柔」音色，剪掉结尾杂音），heal + intro（她只有「持家」一招，带治疗）。
- `lvlingqi` 吕玲绮：Fish Audio 生成的「总有一天，我要打倒父亲。」（孙尚香音色），attack + intro（大招、怒吼落回 attack）；北线单挑她那场开打时也喊。
- `female` 女将的治疗（后勤女）：Fish Audio 生成的一条「别怕，安心修养」（貂蝉音色）在停顿处剪成「别怕……」「安心休养……」两句，随机挑；女将的 attack / ultimate 还是 edge-tts。
- 其余（男将 / 女将 / 敌将）：edge-tts。

## 和配音相关的其他东西

- 大招 cut-in 演出（`battle_screen._cutin`）和配音同时触发；`skills.json` 的 `"cutin": false` 关掉某个技能的演出。
- 截图 demo 不是静音的：`--demo=fight` 在用户电脑上会出声，开打时吕布会喊登场台词——别让测试脚本立刻放大招，会和台词叠在一起（用户以为是别人喊的）。
- 自动战斗第一步会等敌人的登场台词喊完（`Sfx.voice` 返回时长）。
- 写 Python 脚本时别用 bash heredoc 塞带反斜杠 / 引号的代码，写到草稿目录再跑。
