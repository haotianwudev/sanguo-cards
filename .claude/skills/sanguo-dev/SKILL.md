---
name: sanguo-dev
description: Develop 三国卡牌 (sanguo-cards), a Godot 4 Rance X-style Three Kingdoms roguelike card game. Use for any change to its cards, skills, enemies, relics, quest maps, random events, story text, UI, art pipeline, or tests — and to run its tests, demos and screenshots.
---

# 三国卡牌 development

A small, polished roguelike card game: Rance X (ランス10) battles, Rance X quest maps walked square by square,
Slay-the-Spire-style runs, a comic 三国群侠传-flavoured story. Landscape 1280×720, meant for phone and Switch.

**The owner's rules:** simple first (「简单为主」), everything config-driven, reply in Chinese, art is placeholder.
Balance is not a goal right now — don't spend turns tuning numbers unless asked; keep balance tests loose.

## Where things are

| Path | What |
|---|---|
| `godot/` | **The game** (Godot 4.7, GDScript). `project.godot`, autoload `Game` = `scripts/game.gd` |
| `godot/data/cards.json` | gacha / tiers, battle constants, troops, skills, cards, enemies (+ moves), scenarios, relics |
| `godot/data/story.json` | quests (chapters: squares, pools, shuffle groups) and random events |
| `godot/data/ui.json` | themes, map glyphs / colours, card frames, plates, badges |
| `godot/scripts/core/` | pure logic: `game_data.gd` (load + validate), `battle.gd` (engine, emits events), `quests.gd` (maps, events, runs), `save_data.gd` |
| `godot/scripts/ui/` | `map_screen`, `battle_screen`, `card_view`, `pick_overlay`, `relic_pick`, `title_screen`, `kit` (palette, helpers) |
| `godot/tests/` | `run_tests.gd` runner, `test_*.gd` (extend `TestCase`, `check`, `check_eq`, `check_between`, `bot_fight`, `party`) |
| `pics/` | raw art (`source/`), `art.json` (framing), `ART-NEEDS.md` (generated: what each chapter still lacks), `CARD-DESIGN.md` (art specs, **§7 per-character look briefs**, §8 art priorities) |
| `src/sanguo/art.py` | `sanguo-art` CLI: builds portraits + map backgrounds into `godot/data/`, regenerates ART-NEEDS / SOURCES |
| `src/sanguo/*.py`, `tests/` | the old Textual (terminal) version — frozen, don't extend it |

## Commands (Git Bash)

```bash
G=/f/workspace/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe
cd /f/workspace/sanguo-cards/godot

# tests — ALWAYS with a timeout: a GDScript parse error makes the runner hang instead of exiting
timeout 240 $G --headless --path . --script res://tests/run_tests.gd 2>&1 | grep -B1 -A4 "FAIL\|passed\|SCRIPT ERROR\|Parse"

# after adding a new file with class_name (or new art), register it first
timeout 120 $G --headless --path . --import >/dev/null 2>&1

# screenshot a demo state (then Read the png)
timeout 60 $G --path . --resolution 1280x720 -- --demo=<name> --shot=<scratchpad>/x.png --wait=1.5
```

Fonts are bundled subsets (`godot/data/fonts/body.ttf` 思源黑体, `name.ttf` 霞鹜文楷), used by `Kit.make_theme` / `Kit.name_font`.
**Story text with a rare character** (not in the common GB2312 set) shows as a box on phones until you rerun `python tools/build_fonts.py`
(it rescans `godot/data` + `godot/scripts`), then `--import`.
UI icons (badges, map squares, token, relics, card back, stat/skill icons) are generated placeholders from `tools/generate_ui_assets.py`;
once any is replaced by drawn art, don't rerun that script — it overwrites them all.

Android APK (debug, arm64; preset in `godot/export_presets.cfg`, templates in `%APPDATA%/Godot/export_templates/4.7.2.stable`,
SDK / JDK / debug keystore set in the editor settings):

```bash
timeout 900 $G --headless --path . --export-debug "Android" ../build/sanguo-cards.apk   # build/ is gitignored
/c/platform-tools/adb install -r ../build/sanguo-cards.apk                            # phone with USB debugging on
```

Demos (`Game.demo()` in `scripts/game.gd`): `title`, `map`, `pick`, `choose`, `event` (左慈 on a ？ square),
`relics` (宝物 pick), `tiers` (铜/银/金 frames), `ch2` (虎牢关 fork), `battle`, `fight`, `cards:id1,id2,...`.
Demos walk square ids — when you insert or rename squares, update their walks (and `walk_to` in tests).
Screenshots of overlays look washed out because the PNG keeps alpha; in the game the dim is dark.

Art: put the original in `pics/source/...`, add/adjust the `pics/art.json` entry, run `sanguo-art` (from the repo root).
Framing: `face` = face centre [x, y] as fractions; `head` = head height / image height. **Bigger head ⇒ smaller figure**;
smaller face x ⇒ figure moves right; bigger face y ⇒ figure moves up. Enemies share their card's portrait key.

Story CGs: squares, events and interlude scenes take `"cg": "<key>"`; the art goes in `pics/source/cg/<key>.jpg` +
`pics/art.json` "cgs" (→ `godot/data/art/cg/`). Like Rance X, a CG dominates: arriving at a square with one switches the map screen to CG mode (the picture fills
the screen, the text box sits over it, a top-bar tab switches back to the map); the interlude shows it full screen.
Story text plays one line per click (visual-novel style) on event / choose / ？ squares and in interludes; the
buttons appear after the last line; 跳过 shows everything, 隐藏 (CG mode) hides the text box until the next click.
Keep each story line short enough to read as one subtitle.
Never replay a scene at a choice or fork: give the square (or event) a `prompt` — one line that sums up the
options (「孙策主张正面强攻，周瑜主张调虎离山。听谁的？」) — shown beside the buttons.
A finished story square shows its prompt (or 「这一段已经看完了」), a pending pick shows only the outcome — nothing replays.
Each line shows its speaker's face (`Kit.speaker_key`: {lord}, then a name before 「 / ：, then the first name in the line,
aliases like 伯符 / 公瑾 / 文台 / 吴夫人 in `Kit.ALIASES`); narration keeps the last speaker, or the square's `portraits`.
Write lines so the speaker's name comes first (「孙策把枪往地上一戳：……」). Add the key and what to draw to `CARD-DESIGN.md` §8b.
Battle CGs (Rance X style: the enemy in its scene): the owner supplies one picture per battle — `pics/source/battles/<scenario id>.jpg`, registered in
`pics/art.json` "battles", built by `sanguo-art` into `godot/data/art/battle/`; the battle screen paints it (washed) when
present. For any other art a feature needs, don't wait for it: add the requirement to `CARD-DESIGN.md` (and a brief).

**Every art requirement ships with a full image prompt.** Add the subject to the tables in `tools/art_prompts.py`
(portraits: name / appearance / armor & clothing / weapon; battles and story CGs: one scene line — composition and style
are fixed templates so the set stays consistent; women are always written as adults) and run `python tools/art_prompts.py`
to regenerate `pics/ART-PROMPTS.md`. Keep the prompt consistent with the brief in `CARD-DESIGN.md` §7 and the story text.
When the owner hands over a prompt of their own (often Chinese, with 【角色】 sections, a staging note and the gag),
put it in `OVERRIDES` under its key — it replaces the template and stays archived after the art exists.
When new art arrives, look at it and rewrite that scene's lines to match what's drawn.

Adding a portrait, checklist:
1. File name = the portrait key the game looks up: a card's `person` (or its id), or an enemy's `portrait`
   (enemies reuse their card's key — check `cards.json` before inventing a new one). Generals/enemies go in
   `pics/source/generals/`, soldiers in `pics/source/soldiers/`. ≥ 900 px tall is plenty (the game keeps 640).
2. `art.json` entry with `license` (who made it, e.g. 「用户提供（Gemini 生成）」); no `placeholder` for final art.
3. Run `sanguo-art` — it builds `godot/data/portraits/`, `portraits.json`, `ART-NEEDS.md`, `SOURCES.md`. Never hand-edit
   those four. Then `--import`, and commit the new `.jpg.import` files with the jpgs (every portrait has one).
4. Screenshot it on its card (`--demo=cards:<card ids>`) and in its scene; adjust `face`/`head` until the head sits in
   the upper third and the figure isn't cropped at the frame.

## Editing gotchas (these bit us)

- **Don't put multi-line Python in bash heredocs** when the code contains `\n`, `\\`, or nested quotes — write the
  script to the scratchpad with the Write tool and run it. For one exact replacement, prefer the Edit tool.
- Patch scripts: `assert t.count(a) == 1` before every replace, and check **before** writing any file — a script that
  dies halfway leaves some files changed. Re-read what already landed before re-running.
- Write files with `newline="\n"` (repo is LF; `.gitattributes` enforces it). JSON stays valid: `json.loads` before writing.
- `story.json` / `cards.json` are hand-formatted (one entry per line). Keep that: splice lines, or re-dump with the
  per-square formatter used before (`dump_q`), never `json.dump(indent=2)` the whole file.
- GDScript: `:=` can't infer from Variant (`dict["x"]`, `array.filter(...).size()`) — write `var n: int = ...`.
  Two `var` of the same name in one function is a parse error. Lambdas can't reassign outer locals.
- **Never overwrite real art to test a display path.** To try a CG / background with a stand-in picture, use a key
  nothing uses (e.g. `test_cg`) and point a demo at it — `c1_wake.jpg` was once clobbered by a stand-in and had to be
  restored from git. Check `git status` for deleted/modified art before committing.
- Never commit with failing tests: chain `... | grep passed` checks don't stop `&&` — look at the result first.

## How the game is modelled (add things through data)

- **Card** (`cards.json` cards): `name, rarity (N = soldier, R/SR/SSR = general), troop, bonus {hp, at}, skills,
  person (shared portrait / one version in a party), pool (false = story or drop only), troop_skills (false = own skills
  replace the troop's)`. Every troop has two skills — a plain 1-AP move and a signature (骑 马刀/冲锋, 枪 刺击/枪阵,
  弓 射击/齐射, 刀 步战/举盾, 策 计略/献策 (+AP; 策士 took in the old 法师 troop — too few cards), 贼 劫掠/偷袭 (break), 勤 包扎/鼓舞) — soldier
  cards get only the plain move (精兵 marked `"elite": true` — 丹阳兵, 陷阵营, 白毦兵 … — get both); a general gets
  the plain move plus its own signature (or the troop's signature if it has none). Leader stat = 5 × own + troop members; soldier copies decay ×0.6; generals repeat → tiers
  铜 1 / 银 2 / 金 4 copies (`gacha.tiers`, frame `tier0/1/2` in ui.json).
  The lord has tiers too (`lord_copies`, starts 铜); its card (`db.cards["lord"]`, added at load, never in pools)
  turns up in recruit offers at `gacha.lord_rate`. **周目**: `SaveData.new_lap()` restarts the story keeping every card
  as it is — no gifts, no rarity shift, no other rule changes (the user wants those decided later); the only pool change
  is `recruit_pool()` adding every general ever owned via `seen`, story-only ones included.
  **难度** is shown from 1 (`SaveData.level()` = difficulty + 1; beating 虎牢关 吕布 → 2): enemies +difficulty_step per
  level, and chests (`chest_mix`: treasure squares and after battles) turn each soldier into a general with
  `gacha.chest_general` base + per_level × (难度 - 1). Event offers of soldiers stay soldiers.
  **Rogue per run** (rolled in `Quests.begin` only when given an rng — tests pass none and stay fixed): a **天命**
  (`cards.json fates`, pick one of `fate_offer` in the RelicPick overlay with `source = "fates"`; mods like relics,
  `Quests.mods` adds it) and a **词缀** on every elite / boss square (`battle.affixes`: hp / at shares, resists,
  +actions, regen; `save.affixes[square]`, `Quests.affix_here`, applied in `Battle.start` via `mods.affix` on a copy
  of the enemy data). Game.new_game / new_lap pass the rng so a chapter's first run is dealt too.
  **宝物 are cards (Rance X items)**: every relic has a fixed team (`relics.*.troop`, lord = the lord's unit); worn, it
  sits in that troop's fielded unit (never as leader, any number) and only works while that unit is out
  (`SaveData.relic_unit / active_relics`, `Quests.mods` uses active ones). The player can leave a 宝物 in the pool
  (`unworn`) and leave any card behind (`benched`: joins no unit; a leader is always brought). Both in 整备.
- **Skill**: `cost, cumulative (+1 AP per use), uses (1 = 限1), effects[]` — `attack/magic {power, hits, burning_mult}`,
  `heal`, `guard {cut}`, `boost`, `stun {chance}`, `break`, `ap`, `burn {pct | power, turns}`. Once-per-battle damage
  skills (大招) cost ≥ 3 AP (a test enforces it).
- **Enemy**: `hp, at, actions, resists, portrait, card (its chest may hold it: 25%, bosses/elites 50%), moves[]` — move
  `power (0 = no hit), weight (0 = only after a charge), confuse, rage, heal, ap_drain, burn_party, pierce,
  charge (wind-up announced a turn ahead), when: "half", once`. Make fights strong; make their cards modest.
- **Relic 宝物** (`cards.json` relics): found during a chapter; all carry into the next chapter (`kept_relics`), but ones found in the current chapter reset on a restart; `rarity common/rare/curse, icon, desc, mods {...}, after_win`. Mods are
  summed by `Quests.mods(save)` and passed to `Battle.start(..., ambush, mods)`. New mod ⇒ read it in `battle.gd`.
- **Quest** (`story.json` quests): squares `{x, y, type, label, next, text, portraits, cards, choose, battle, boss,
  elite, ambush, event, lose_goto}`; types `event choose battle treasure recover recruit mystery`. Moves only go right,
  one row at a time (a test checks). `soldier_pool`, `recruit_pool`, `event_pool`, `shuffle` (groups that trade
  contents each run). A run = one attempt: losing restarts it (cards, choices, 难度 kept; 宝物, 险, layout reset).
- **Event** (`story.json` events, for ？ squares; a square with `event` is fixed): `title, glyph, color, text,
  portraits, options [{label, effects, win}]` — effects `say, damage, heal, rest, poison (−⅓ HP), card, soldier,
  offer {from | generals + rates | soldiers}, upgrade (true = pick, "random"), refresh, relic, danger (险, run),
  difficulty (whole campaign), drop_relic, lose_soldier (trades: give something up), battle + ambush, chance {then, else}`. Text uses `{lord}` for the player's name.

- **Chapter recap**: finishing a chapter shows `Quests.recap(save)` — battles won, cards gained (collection diff since the
  run began), relics picked up, and the run's key lines. Mark what matters with `record` (square, when resolved),
  `record_win` / `record_lose` (battle squares), `record` on choose options, or a `{"record": ...}` event effect —
  short lines like 「董白：留下」. These lines are also the hook for later cross-chapter branching.
- **Between chapters**: recap (战功 paid once, spent on a draw or an upgrade) → `Quests.complete` turns the run's records
  into permanent `save.flags` → interlude scenes from `godot/data/interludes.json` (keyed by the finished quest; a scene's
  `requires` / `unless` name a flag) → the next chapter's title card (with the quest's `subtitle`, e.g. 「半年后」 — the journey from 富春 to 孙坚 takes about half a year;
  孙坚 had left home well before, and he meets the hero for the first time in chapter 2). The 部队 button on the map opens the party screen.
- **Replays**: the title screen replays finished chapters (`Quests.start_replay` parks the main run in `save.stash`);
  each clear adds +1 险 (`save.clears`); cards and 战功 stay, story flags don't change.

After adding content: run tests, screenshot the relevant demo, fix layout overflow (e.g. three skills shrink the
battle cards), commit, push.

## Story voice

Comic, a little 擦边, never explicit. The hero is a 30-year-old office worker's soul in an **18-year-old** body in
chapter 1 (富春); the body ages with the story, so later chapters show him older He carries 孙坚's old big blade (吴夫人 gives it to him in 富春; 胡玉 and 孙坚 recognise it; it's what 扔刀 throws).
He wears short modern hair (his portrait) — odd in the Han, where short hair means a convict (髡刑); 吴夫人
likes it and keeps touching it, 孙策 and 孙坚 mock it. From 旧甲 on he wears 孙坚's old silver armor (tiger-engraved shoulders),
a black cape trimmed with white fur — **not** a tiger pelt; the tiger pelt is the armor skirt's lining (孙坚 himself
wears the tiger-pelt cape). (never younger than 18 — no sexual
framing of anyone under 18). 吴夫人 (later 吴国太) treats him like a son and lets him get
away with his flirting, cluelessly maternal — that contrast is the joke. 孙策: reckless, spear first, can't swim,
sulks at being left home. After 江边三结义 (by birth: the hero is 大哥, a year older than 孙策 and two than
周瑜; 孙策 老二, 周瑜 老三): 孙策 calls him 「短毛大哥」/「大哥」, he calls 孙策 「虎子」 and 周瑜 「三弟」 (「周扒皮」 behind his
back — 周瑜 hears it and charges a coin); 周瑜 calls them 大哥 / 二哥. Keep using these after chapter 1. 周瑜: sharp (reads people, counts everything) but petty — keeps a **ledger** of what
everyone owes him. 孙坚: huge, 虎皮 + 古锭刀; sharp-tongued and mean to the hero (「嘴甜的」, sends him to the front row, mocks his
fighting) but heroic when it counts (first into the charge, holds the gate alone against 吕布, comes back for you);
after the 玉玺 his ambition shows (won't let go of it, threatens anyone who talks, heads home to 江东). Chapter 1 富春 (孙坚's hometown, during his campaign
against 董卓; only the brother whose plan you pick joins) → chapter 2 讨伐董卓 (the other brother joins; 祖茂 vs 华雄 —
win: you throw your blade and get the 赤帻, lose: 孙坚 kills 华雄; 孙坚 does NOT join (he lends you an old general instead); elite 董白; 吕布 raids the camp; 吕布's
chase is nearly unbeatable — lose: 三英战吕布, win: 难度 up + three chests; hand 董白 to 袁绍 for a relic (she's executed)
or hide her; then months of waiting while the coalition feasts (驻军 → two columns of ？ / camp → 火光 when
洛阳 burns) before 李傕 at the city gate; one 洛阳 square each way via requires / unless on 「董白：留下」 — requires /
unless also read this run's own records; a spared 董白 joins).
Chapter 3 传国玉玺 (quest `yuxi`, 初平元年夏—秋): leaving 洛阳 — with 「董白：留下」 she spots 蔡文姬 among the refugees
and you save her (she joins), otherwise bandits carry 蔡文姬 off; 袁术 starves 孙坚 out → 南阳; 孙策 blurts out the
seal in a tavern (桥蕤 overhears); 孙坚 entrusts it to 吴夫人 and marches on 刘表 though the hero warns him about 岘山;
袁术's generals come for the seal (桥蕤 spying, 陈兰's night raid, 雷薄's pursuit); 纪灵, 袁术's strongest (fought 关羽
30 rounds), is the chapter boss at the last pass and, beaten, tells 吴夫人 孙坚 fell at 岘山; 袁术 himself is an unbeatable
last stand (lose_goto, not the boss) → 结局一 · 玉碎 (吴夫人 smashes the seal on a stone and refuses capture — written restrained,
never explicit; the hero covers 孙策 and 周瑜's escape and falls). A quest `ending` {title, text} shows an ending card
and returns to the title (new 周目); reached endings stay in `flags` across 周目. Other routes are the user's call — wait.
Route B (a later 周目 — flag 「结局一 · 玉碎」 — with 董白 kept): 蔡文姬 can be saved, which ends chapter 3 early
(「路线：守洛阳」). On route B the 驻守洛阳 and 长安 maps both count as 第三章 (titles 「第三章 · 驻守洛阳」「第三章 · 长安」). 驻守洛阳 (quest requires that flag): 蔡文姬's story (郭汜 escorting the officials' families,
plundering), 周瑜's plan to rob his grain carts, 郭汜 fought off (no 蔡邕), 孙坚 holds 洛阳, the coalition disperses,
朱儁 (孙坚's old commander from the 黄巾 war, fled 董卓) arrives and joins, asking the hero to carry a question to 皇甫嵩; 李儒 sues for peace (周瑜 for it, the hero suggests 王允), 董白 is betrothed to the hero (wedding to be in 长安), the hero
goes to 长安 (「路线：长安」). 长安: 汉献帝 (a boy of about ten, 董卓's puppet — never anything but a child in the text or art) secretly asks the hero where he's from, where 孙坚 is and whether he can take him back to 洛阳; after 董卓 dies 王允 answers for him (「长安才是都城」); Chapter 5 长安: 董卓 greets 董白, humiliates 皇甫嵩 at the feast (he later sides with 王允, brings the palace guard at 格杀勿论 and joins; after 董卓 dies he asks 王允 about 董白 and gets no answer), 蔡邕 reunion, 王允, 貂蝉 and the hero's 连环计 — hidden from
董白; 李儒 sees through it, 吕布 is chained in the 相府 dungeon, 貂蝉 taken into the back court; the wedding is 董卓's
trap to kill everyone, 董白 too; break out and beat 董卓's guard, but he orders 格杀勿论 (董白 too) — then 吕布, freed from the dungeon by
貂蝉 on her own, rides in with his cavalry and 貂蝉 (「诛此贼！」) and saves them; 董白 shields him, 吕布 kills him, 董白 breaks —
she never knew, believing the marriage and the reconciliation were sincere. Running gag on route B: 蔡文姬 and 董白 (both
adults, both sweet on the hero) — 蔡文姬 sniffs at 董白's lack of learning and envies her figure, 董白 fires back that
蔡文姬 has none; keep it light banter. 王允 looks righteous but is ambitious and cunning — only hinted so far (a
merchant's appraising look, tears that come right on time, first up the steps to take charge after 董卓 dies without a
glance at 董白); the user will write where that goes. 貂蝉 (adult): clever, beautiful, brave, and
always seems to be flirting with someone — whether she means it with the hero stays unclear; 董白 doesn't like how
she looks at him. 吕布 stays a brute and selfish: he rescues nobody on purpose (「别以为我是来
救你的」), kills 董卓 over his own pupil's plea, grabs 貂蝉 and shouts for the credit.
第四章 · 挟天子 (quest `dongui`, one map; requires 「长安：吕布杀了董卓」): 王允 rules — the hero stops the 夷三族 of 董卓's house
(the boy emperor backs him); asks 王允 to pardon the 西凉 army and bring 孙坚 into 长安 — refused; 论功: 吕布 温侯, 孙坚 吴侯,
皇甫嵩 征西将军, and the emperor insists on the hero over 王允: **富春亭侯**; recruits 荀攸 (天牢) or 钟繇 (尚书台);
王允 plots with 吕布 to kill him, 貂蝉 warns him; 李傕/郭汜 attack 长安, 王允 keeps 吕布 on a leash; 周瑜 (in 长安 with
his uncle 周忠) says take the emperor to 洛阳; 董白 brings 董卓's old guard, 貂蝉 comes along, 皇甫嵩 holds the gate;
王允's checkpoint, pursuers or 樊稠, 徐晃 defects, 李傕 at 函谷关 (boss) → 洛阳, 孙坚 kneels; 长安 falls, 王允 dies
on the gate, 吕布 goes to 袁绍; 孙坚 keeps the 玉玺 and takes 大将军·录尚书事 (挟天子 — the hero notes the textbook said
曹操); the hero is pushed aside and sent against 袁术 in 南阳: 桥蕤, 黄忠 (a 南阳 soldier robbed by 袁术's men, sick son
黄叙) joins, 雷薄, 陈兰, 冯夫人's night visit, 纪灵 (boss) holds the rear while 袁术 flees east to 寿春. (未完待续)
The locked north
birthplace is 卞夫人's route. Historical women who were children in 190 (甄宓, 步练师, 张春华, 孙尚香) stay
out of the story until later chapters — as gacha cards they're fine.

Writing rules:
- **Timeline** — the whole story so far spans about a year; each chapter opens with a `【年号 · 月】` line:
  ch1 富春 初平元年正月 → ch2 sets out 二月 (a month on the road), reaches 中原 in spring, two months of waiting,
  洛阳 burns in early summer → ch3 南阳 夏—秋 (冯夫人 sews winter clothes) / ch4 洛阳 夏—秋 → ch5 长安 arrives in winter,
  the wedding and 董卓's death at 初平二年正月 (「整整一年」) → 第四章: escape 二月, 洛阳 三月, 南阳 夏. Don't write 「小半年」「好几个月」 that break this.
- A named enemy should be introduced before you fight it: give its battle square `text` (lines play first, then
  the enemy info and 出战) rather than putting the introduction in the square after the fight.
- The hero is a modern man who **never read 三国演义** (「三国演义我不熟啊」) and regrets it (「早知道会穿越，当年就该把那本书
  读完」). He knows only the famous: from textbooks (周瑜 via 苏轼, 蔡文姬, 二乔), games (孙策, 吕布, 左慈) and TV (关羽,
  华佗, 黄盖's 苦肉计); most others he's never heard of. His foresight is thin: 孙坚's card blurb says only that he dies
  fighting 刘表 (no 岘山 / 黄祖 / ambush details — those he hears from others), and everyone knows 「见到吕布，跑」. When a character first appears he sizes them up in a `{lord}（内心）：` aside —
  recognised or 「没听过」, plus a modern jab that stays believable (袁绍 = the boss who loves meetings and never
  decides) — no forced office metaphors; famous people (孙坚) he simply knows. One per character; no historical detail he couldn't know; characters never cite 演义.
- **Looks match the art.** A character's appearance in the text must match their portrait — or, before the art exists,
  the brief in `CARD-DESIGN.md` §7. When you write a new character's look, add/adjust their brief there; when new art
  arrives that differs, change the text (左慈: 「独眼瘸腿」 became 白发、竹杖、冒紫烟的葫芦 to match his portrait).
- **Names.** A card name `A·B` shows **A on the name plate** and **B as the small tag** at the top of the card
  (`孙策·少年`). So the real name goes first, the nickname / version second: `胡玉·浪里蛟`, `唐周·妖道` — never
  `浪里蛟·胡玉`. Enemy names are what the battle title and every log line print: keep them short (`「浪里蛟」胡玉`,
  `妖道唐周`, `黄巾渠帅何仪`), no double `·`.
- **Real people are welcome when they fit** — look them up first (胡玉 really was the 钱塘 pirate 孙坚 scared off at 17).
- **Continuity.** When you name, rename or add a character, grep `story.json` (squares *and* events) and `cards.json`
  for every place that talks about them or the role they replace, and update all of it. Every boss the player fights
  must be introduced in the text before the fight (who they are, why they're there).
- **Punctuation.** Dialogue in 「」, quotes inside dialogue in 『』; Chinese punctuation throughout — no ASCII or curly
  quotes (`"` `'` `‘’` `“”`).

## Git

Repo `haotianwudev/sanguo-cards` (public), branch `master`. Commit each finished change with a descriptive message,
push when done (the owner asked for pushes).

More than one agent works on this repo (Claude Code, Gemini). Before you start and again before you commit:
`git fetch && git status` — pull what others pushed, and if files you didn't touch are modified, someone else is
mid-edit: leave them alone. **Stage by path (`git add <your files>`), never `git add -A`**, so you only commit your own work.

Replacing art: overwriting `pics/source/<key>.jpg` with a new version is fine (git keeps the old one). If the new image
has no title band, drop the entry's `prep` block and point `src` at the source file; re-check the framing. Never commit art that isn't ours (the old Rance placeholder was scrubbed
from history for this reason).
