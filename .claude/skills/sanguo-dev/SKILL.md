---
name: sanguo-dev
description: Develop 重开三国 (sanguo-cards; formerly 三国卡牌), a Godot 4 Rance X-style Three Kingdoms roguelike card game. Use for any change to its cards, skills, enemies, relics, quest maps, random events, story text, UI, art pipeline, or tests — and to run its tests, demos and screenshots.
---

# 重开三国 development

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

北线第二章：`--demo=ln2`（虎牢关前，`--at=<square id>` 跳到任意格，`--at=` 的目标必须在脚本自带的 `path` 数组里，新加格子要同步那份列表）。
第四章：`--demo=ch6`（二周目，围府线）/ `--demo=ch6b`（三周目，报信线）/ `--demo=ch6c`（四周目，渭水打张济张绣、收贾诩），加 `--at=<square id>` 直接跳到那一格截图。
第五章：`--demo=ch8`（恨海线）/ `--demo=ch8b`（通关恨海、第四章收了贾诩后的破局线），同样可加 `--at=`。
`tests/test_routes.gd` walks chapters 3–5 on every 周目 route (squares, records, endings, cards, which chapter follows) and checks
that no two open squares ever share a spot; keep it green when you add squares.

Fonts are bundled subsets (`godot/data/fonts/body.ttf` 思源黑体, `name.ttf` 霞鹜文楷), used by `Kit.make_theme` / `Kit.name_font`.
**Story text with a rare character** (not in the common GB2312 set) shows as a box on phones until you rerun `python tools/build_fonts.py`
(it rescans `godot/data` + `godot/scripts`), then `--import`. `test_the_bundled_font_has_every_character_the_game_prints` fails when you forget.
UI icons (badges, map squares, token, relics, card back, stat/skill icons) are generated placeholders from `tools/generate_ui_assets.py`;
once any is replaced by drawn art, don't rerun that script — it overwrites them all.

Android APK (debug, arm64; preset in `godot/export_presets.cfg`, templates in `%APPDATA%/Godot/export_templates/4.7.2.stable`,
SDK / JDK / debug keystore set in the editor settings):

```bash
timeout 900 $G --headless --path . --export-debug "Android" ../build/sanguo-cards.apk   # build/ is gitignored
/c/platform-tools/adb install -r ../build/sanguo-cards.apk                            # phone with USB debugging on
```

Demos (`Game.demo()` in `scripts/game.gd`): `title`, `map`, `pick`, `choose`, `event` (左慈 on a ？ square),
`relics` (宝物 pick), `tiers` (铜/银/金 frames), `ch2` (虎牢关 fork), `battle`, `fight`, `cards:id1,id2,...`,
`chest` / `grand_chest` (a loot chest over the map). Add `--north` to any `--demo=` to play as the north-route
lord (appends 「出生：冀州无极」 to `run_records`) — for demos that call `Quests.begin` internally (`chest`,
`grand_chest`, the chapter forks) that reset `run_records`, append the record again after the call, same as a
real run would after walking past `era`.
Demos walk square ids — when you insert or rename squares, update their walks (and `walk_to` in tests).
Screenshots of overlays look washed out because the PNG keeps alpha; in the game the dim is dark.

Art: put the original in `pics/source/...`, add/adjust the `pics/art.json` entry, run `sanguo-art` (from the repo root).
Framing: `face` = face centre [x, y] as fractions; `head` = head height / image height. **Bigger head ⇒ smaller figure**;
smaller face x ⇒ figure moves right; bigger face y ⇒ figure moves up. Enemies share their card's portrait key.

Story CGs: squares, events and interlude scenes take `"cg": "<key>"`; the art goes in `pics/source/cg/<key>.jpg` +
`pics/art.json` "cgs" (→ `godot/data/art/cg/`). Like Rance X, a CG dominates: arriving at a square with one switches the map screen to CG mode (the picture fills
the screen, the text box sits over it, a top-bar tab switches back to the map); the interlude shows it full screen.
**One `cg` per square.** A square with two CG-worthy beats needs two squares: split its `text` array at the second
beat, give the tail half a new square id with the new `cg`, point `next` at it, and shift every later square's `x`
by the number you inserted (none, if it was the last square on that path). Wire a square's `cg` field as soon as you
write the prompt, even with no art yet (`Kit.cg()` returns `null` safely) — `write_needs()` only tracks a cg if the
square already names it, so an unwired prompt never shows up as missing in `ART-NEEDS.md`.
Story text plays one line per click (visual-novel style) on event / choose / ？ squares and in interludes; the
buttons appear after the last line; 跳过 shows everything, 隐藏 (CG mode) hides the text box until the next click.
Keep each story line short enough to read as one subtitle.
Never replay a scene at a choice or fork: give the square (or event) a `prompt` — one line that sums up the
options (「孙策主张正面强攻，周瑜主张调虎离山。听谁的？」) — shown beside the buttons.
A finished story square shows its prompt (or 「这一段已经看完了」), a pending pick shows only the outcome — nothing replays.
Each line shows its speaker's face via `Kit.speakers(lines, cast)` (`cast` = the square's `portraits`, seeds 她/他):
an `@key 台词` tag names the speaker outright (strip it for display with `Kit.strip_tag`); otherwise it's the subject
of the clause before the first 「 (a name at the clause start, or just after a short lead-in like 的/后/里/中/上/前/边/外/下/来/天/—/个/是);
a possessive at the clause start is a fallback owner; 你/{lord} = "lord"; 她/他 = the latest same-gender subject
(`Kit.FEMALE`); an opening-quote line takes the subject after 」, else the last speaker. `Kit.ALIASES` maps
descriptive phrases and names to keys (伯符 / 公瑾 / 文台 / 吴夫人 / 黑脸大汉 / 一员虎将 …) — add new ones here, not a new mechanism.
Write lines so the speaker's name comes first (「孙策把枪往地上一戳：……」); use an `@key ` tag only when the clause-subject
rule would get it wrong (e.g. the line opens with someone else's name as the object). Add the key and what to draw to `CARD-DESIGN.md` §8b.
Battle CGs (Rance X style: the enemy in its scene): the owner supplies one picture per battle — `pics/source/battles/<scenario id>.jpg`, registered in
`pics/art.json` "battles", built by `sanguo-art` into `godot/data/art/battle/`; the battle screen paints it (washed) when
present. For any other art a feature needs, don't wait for it: add the requirement to `CARD-DESIGN.md` (and a brief).

**Every art requirement ships with a full image prompt, written in Chinese** (the templates in `tools/art_prompts.py` and
every table entry you add are Chinese; old English entries get translated whenever you touch them). Add the subject to the tables in `tools/art_prompts.py`
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
- **A fighter dict's `"id"` is load-bearing** — `CardView.make` special-cases `card_id == "lord"`, and battle/party
  code keys collection, tier and leader lookups off it. If one card needs more than one portrait depending on save
  state (the north-route lord: own hairstyle and armor, `Kit.portrait_key` falls back to the south one until
  `lord_north` art exists), give the fighter dict a separate `"person"` field for the portrait lookup
  (`fighter.get("person", fighter["id"])` in `card_view.gd`) and leave `"id"` alone. Changing `"id"` itself breaks
  anything that does `== "lord"` elsewhere — it compiles fine and only shows up as a blank portrait or a frozen
  pick overlay (the card errors building `db.build_fighter("lord_north")`, which doesn't exist, and the rest of
  that screen's `_ready()` never finishes).
- **`project.godot`'s `window/stretch/aspect` must stay `"keep"`**, not `"expand"`. `expand` gives a wider-than-16:9
  phone screen more raw canvas instead of scaling into it, and since most screens size themselves in literal 1280×720
  pixels (`size = Vector2(1280, 720)` all over `scripts/ui/`), the game ends up pinned to the top-left with a dead
  strip on the other side instead of centred. Verify any stretch-mode change with
  `$G --path . --resolution 2340x1080 -- --demo=map --shot=<file>.png --wait=1` (a tall-phone aspect) before trusting it.

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
  `heal`, `guard {cut}`, `boost`, `stun {chance}`, `break`, `ap`, `burn {pct | power, turns}` (one fire at a time: a new one keeps the bigger and restarts the count; 周瑜's 火攻 is 10%/turn at a flat 1 AP). Once-per-battle damage
  skills (大招) cost ≥ 3 AP (a test enforces it). **Heals**: an everyday heal is cumulative (+1 AP each use); a big heal is a once-only 大招. Few generals heal (doctors, 刘备, the mother figures, 后勤 troops) — give the rest statuses (guard / boost / ap / break / stun). Tests enforce both. **Once-only skills (限1) are once per stretch of map**, not per battle: used up they stay spent until a 休整 square (or a 重置技能 event) — so players rotate cards. Put a mandatory 休整 after a chapter's mid-map boss.
- **Card stats** = (troop base + card bonus) × `gacha.rarity_mult` (N 0.8 / R 1.0 / SR 1.15 / SSR 1.35) × tier (generals only);
  the multiplier keeps every SR/SSR above any soldier of its troop (a test enforces it). Soldiers' extra copies join the unit as members.
- **Enemy**: `hp, at, actions, resists, portrait, card (its chest may hold it: 25%, bosses/elites 50%), moves[]` — move
  `power (0 = no hit), weight (0 = only after a charge), confuse, rage, heal, ap_drain, burn_party, pierce,
  charge (wind-up announced a turn ahead), when: "half", once`. Make fights strong; make their cards modest.
- **Relic 宝物** (`cards.json` relics): found during a chapter; all carry into the next chapter (`kept_relics`), but ones found in the current chapter reset on a restart; `rarity common/rare/curse, icon, desc, mods {...}, after_win`. Mods are
  summed by `Quests.mods(save)` and passed to `Battle.start(..., ambush, mods)`. New mod ⇒ read it in `battle.gd`.
  A story square can hand one over directly on arrival with `"relics": ["<id>"]` (same shape as `"cards"`; a
  `choose` option can't do this — it only has `label/goto/record/card` — so route the option to a one-line event
  square carrying the `relics` field instead, both branches rejoining the next common square).
- **Quest** (`story.json` quests): squares `{x, y, type, label, next, text, portraits, cards, relics, choose, battle, boss,
  elite, ambush, event, lose_goto}`; types `event choose battle treasure recover recruit mystery`. Moves only go right,
  one row at a time (a test checks). `soldier_pool`, `recruit_pool`, `event_pool`, `shuffle` (groups that trade
  contents each run). A run = one attempt: losing restarts it (cards, choices, 难度 kept; 宝物, 险, layout reset).
  A quest itself can carry `requires`/`unless` (checked against `save.flags` only, i.e. earlier *completed* chapters —
  not this run's own records) to gate which route opens next; `current_quest()` walks `db.quests` in array order and
  returns the first uncleared one whose `requires` holds and `unless` doesn't. Prefer `unless` over `requires` for a
  "the other branch's" chapter (e.g. `taodong`'s `unless: 出生：冀州无极`) so a save that never made that choice — most
  tests, old saves — still defaults into it, instead of needing every such save to positively declare the branch it's on.
  A quest shared by two routes can also carry `pool_overrides` (`[{requires, unless, soldier_pool, recruit_pool, event_pool}]`) so
  `treasure`/`recruit`/`mystery` squares on one route don't hand out the other route's cards/events — see `Quests.pools()`, and
  the "Editing gotchas" note below on vetting an event before adding it to any pool.
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
and you save her (she joins), otherwise bandits carry 蔡文姬 off; 袁术 starves 孙坚 out → back to 鲁阳 (孙坚's camp in 南阳郡; 袁术 sits in 宛城 — not 寿春 until 193); 孙策 blurts out the
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
**贾诩** (毒士, best at spotting poison plots): at 董卓's 接风宴 in 长安 he sits in a corner sniffing every cup (the hero knows him from 三国杀);
on the 四周目 (flag 「结局三 · 恨海」), 第四章's escape meets 李傕's pursuers 张绣 (张济's nephew, 北地枪王, 渭水桥) and 张济 (渭水营, elite)
instead of the 司徒府 pursuers / 樊稠; 张济 withdraws to 弘农 and the hero simply has their strategist 贾诩 tied up and carried off on a grain cart (he gave
李傕 the idea to attack 长安; easygoing, he makes himself comfortable); in 洛阳 (a lap-4 休整 square) the hero unties him and treats him
with great respect — best room, first bowl of 红烧肉, clean wine — and 贾诩 shrugs 「……行吧」 and joins (「贾诩：入队」).
第四章 · 挟天子 (quest `dongui`, one map; requires 「长安：吕布杀了董卓」): 王允 rules — the hero stops the 夷三族 of 董卓's house
(the boy emperor backs him); asks 王允 to pardon the 西凉 army and bring 孙坚 into 长安 — refused; 论功: 吕布 温侯, 孙坚 吴侯,
皇甫嵩 征西将军, and the emperor insists on the hero over 王允: **富春亭侯**; recruits 荀攸 (天牢: reads 王允 at once; his uncle 荀彧 is six years younger) and 钟繇 (尚书台: the emperor had him draw the escape route; 钟繇's map and 荀攸's calls run the escape, 荀攸 goes to 南阳, 钟繇 stays by the emperor);
王允 plots with 吕布 to kill him. **First time through (no 「结局二 · 同归」 flag) nobody warns him**: 吕布 and 高顺 surround
蔡邕's house (蔡邕 arrested for sighing over 董卓), breakouts (高顺, 并州狼骑) with 孙策 and 周瑜 fighting alongside, 董白 brings
what's left of the 董 household, 吕布 at 宣平门 (last stand, lose_goto); after it the hero holds the gap so 孙策 and 周瑜 can ride out → 结局二 · 同归 (the hero, 董白 and 蔡文姬 fall together,
restrained). The squares from x5 of the warned route require that flag; the trap squares sit on the same spots with no
requires (they're only reachable from the split). **Later 周目**: 貂蝉 (王允's adoptive daughter) warns him; 李傕/郭汜 attack 长安, 王允 keeps 吕布 on a leash; 周瑜 (in 长安 with
his uncle 周忠) says take the emperor to 洛阳; 董白 brings 董卓's old guard, 貂蝉 comes along, 皇甫嵩 holds the gate;
王允's checkpoint, pursuers or 樊稠, 徐晃 defects, 李傕 at 函谷关 (boss) → 洛阳, 孙坚 kneels; 长安 falls, 王允 dies
on the gate, 吕布 goes straight to 张杨 in 河内 (his old 并州 friend), 李傕 and 郭汜 hold 长安 (no infighting); 孙坚 keeps the 玉玺 and takes 大将军·录尚书事 (挟天子 — the hero notes the textbook said
曹操); the emperor has the hero made 破虏将军 (孙坚's own old title, handed down grudgingly); pushed aside, and sent against
袁术 in 南阳 because 孙坚 can't leave the emperor: 桥蕤, 黄忠 (a 南阳 soldier robbed by 袁术's men, sick son
黄叙) joins, 雷薄, 陈兰, 冯夫人's night visit, 孙坚's old men inside 宛城 (he once camped in 南阳; they know the tiger tally he gave the hero) open the east gate — 里应外合, 纪灵 (boss) holds the rear and flees east with 袁术 and 冯夫人 — where they went is left unsaid for now.
第五章 · 荆襄风云 (quest `jingxiang`, requires 「南阳：袁术东逃」, 初平四年（193）春 → 秋, ~a year after 南阳 (袁术东逃)): 吴夫人 and 蔡邕 move to 宛城 (family supper), 貂蝉 swaps
her palace robes for a light 留仙裙 and learns to 「放假」; 刘表 sends 黄祖 across the 汉水 (淯水 battles, 黄祖 mid-map boss, 休整);
刘表 sues for peace through 蒯越, the court makes 刘表 荆州牧 and the hero **镇南将军·督荆襄军事** in 襄阳; 周瑜 warns it's a 鸿门宴, 貂蝉 insists on
coming to see the 汉江; 蔡夫人 (claims 蔡文姬 as kin via a genealogy, showers 貂蝉 with pearls — 貂蝉: her eyes never smile) and her brother
蔡瑁 (水军都督, wants 貂蝉) plot a poisoned banquet at the 万山水阁. No 荀攸 in 第五章. Split on 「结局三 · 恨海」 + 「贾诩：入队」: **without both** (a 庆功 night, 貂蝉 pours her first cup for him) 千斤闸, 50 crossbows, 鸩羽落红 in a 金兽爵 — 貂蝉 drinks it for the hero, stabs 蔡瑁's eye with her hairpin, knocks over the brazier;
she dies in his arms (「这回，换妾身护了你一次」), he has 蔡氏, 蒯家 and 刘表 all wiped out (一个不留; 蒯越: 「蒯家没有碰过那杯酒」) (董白: 「你越来越像我爷爷了」) and is stabbed by a 荆州士族 retainer in mourning white (「蔡家、蒯家、刘家，三百一十二口」)
by the 汉江 → **结局三 · 恨海** (restrained). **With both**: the hero dreams it all and runs barefoot to 贾诩, who names the poison (鸩羽落红) at once;
贾诩 plans 联蒯灭蔡, 蒯越 turns, the hero hides
everything from 貂蝉 (吴夫人 dresses her), the 闸 never falls; 貂蝉, who knows nothing of his plan, reads the trap, takes his jokes for
obliviousness and rises to drink the cup for him (hand at her hairpin, as in 恨海) — he pulls her back into his arms; only when the
crossbows turn does she see it was all arranged (「你今晚唯一的差事，是剥橘子」 / on the 楼船: 「白费得真好」); hands her a mandarin orange (「她喝不得烈酒，免了」), offers
蔡瑁 half the cup, the poison burns the carpet, the crossbows turn; 刘表 runs over before dawn to swear he knew nothing and cuts ties with the 蔡 (「早就不甚往来」), the 蔡 elders strike 蔡瑁
out of the very genealogy 蔡夫人 used on 蔡文姬 and hand over 800 men, 30 ships and money to save themselves; only the ringleaders die — 蔡瑁, his brothers 蔡中 / 蔡和 (they placed the crossbows) and 刘表's nephew 张允 (mixed the
poison); 蔡夫人 is spared death but divorced by 刘表 on the spot, stripped of her title and confined to the 蔡洲 estate for life; 刘表 hands over the army, 蒯越 joins, the hero is
督荆襄九郡大都督; moonlit 楼船 and hot chestnuts. (未完待续)
第五章 rogue: soldier_pool = 荆州 types (荆州步卒 / 荆州弓手 / 荆州水军 / 蔡府连弩手) + 宗贼 + 锦帆贼 + own; 招贤馆 recruits 文聘 / 伊籍 / 甘宁;
extra fights 汉水渡口·锦帆贼, 新野·宗贼 (周瑜 recalls 蒯越 killing 55 宗贼 leaders at a banquet — foreshadowing), 城防·荆州步卒; ？ events
水镜先生 司马徽 (「好，好」; 「荆州的奇才都还没长大」 — only the hero thinks of 诸葛亮; he's a child in 192 and not in 荆州 yet), 岘山老农 庞德公, 沔南名士 黄承彦 (蔡瑁's brother-in-law:
「别喝金杯里的酒」), 锦帆游侠 甘宁 (on his way to 刘表).
第一章北方出生点 冀州·中山无极·甄府（张夫人收留，初平元年正月；squares live inside the `prologue` quest itself, a second branch off `era` at x ≥ 23 so the south branch's layout is untouched): 主角以现代商业手腕帮甄府清账、平粜、练护卫，甄府转亏为盈；张夫人派主角去冀州治所邺城的分号盘账卖粮，撞见常山义士赵云千里迢迢跑到邺城州衙为家乡雪灾灾民求粮（不是在真定本地——郭图这个督粮官是袁绍派来坐镇州衙的，真定县衙管不了他），被凌辱鞭打，刺史韩馥懦弱旁观；街角醉鬼郭嘉冷眼点破世道，主角出面借甄家三千石粮救常山，赵云、郭嘉就此结识主角；张夫人押粮赈灾，带着**十多岁**的甄宓（不是 5 岁——甄宓这时是半大的少女，主角待她像亲妹妹，干净的兄妹情，没有暧昧；她长大后会对主角生出爱慕，但那是后面章节的事，这一章绝不要写）同行；太行黑山贼李大目、黄巾渠帅张白骑、妖道玄机子（对标南线胡玉 / 何仪 / 唐周）伏击劫走甄宓；主角、赵云、郭嘉三人首次合作踏平黑山寨救回甄宓、灭三凶；开仓放粮，收常山铁骑 / 太行义勇为嫡系部曲（`jz_almsgiving`，无 CG）；赵云教枪，走火入魔扎穿张夫人的狐裘（`jz_training`，主角从此改用枪，不再是南线的刀/盾；无 CG）；围炉夜话看透郭图 / 韩馥 / 公孙瓒皆非明主，决意南下会盟（`jz_night`，无 CG）；张夫人取出甄宓亡父的旧鱼鳞甲——他当年领兵护商队，死在黑山贼手里，和这章的反派是一路货——给主角穿上，又赠貂裘，然后把账本一揣，骑马跟着一起南下（甄宓年纪小留在冀州，不是留守相送；告别那场戏在 `jz_end`，没单独出 CG，就是一句台词，别又拆格去凑一张）。主角性格和南线一致：遇到没名气的角色照样 `{lord}（内心）：……三国演义我不熟啊……`，逗比吐槽不断，还总爱调戏张夫人（被她一巴掌拍回去，没有暧昧，纯斗嘴）。
**对标南线调整过的结构**（南线第一章 31 格、2 个分叉点、9 张 CG 挂字段 8 张到位；北线原来 16 格、0 分叉、11 张 CG 只到位 3 张——密度差太多）：`jz_arrive`（带 `cg: jz_wake`，不变）后面新加一格纯文字的 `jz_test`（`choose` 类型，不配 CG——choose 格的回看文案走 `text`/`prompt` 两个字段，`text` 是第一次看到的台词，`prompt` 是看完之后再回来点开显示的摘要，两个都要给，不然会掉回「选一人随你同行」那句兜底文案），张夫人问「你会算账吗」，两个回答分叉出 `jz_ledger_a`/`jz_ledger_b` 两句不同的俏皮话，再汇合回 `jz_ledger`；北线第一章现在 19 格、1 个分叉点（加上开场共用的 `era` 一共 2 个）；CG 砍回 8 张，**原则是「每个角色第一次出场都要有 CG」**（`jz_wake` 张夫人、`jz_ledger` 甄宓、`jz_county` 赵云、`jz_guojia` 郭嘉）+ 黑山寨三部曲战斗（`jz_ambush` `jz_rescue` `jz_boss`）+ 结尾 `jz_end`，砍掉的是 `jz_crowd`（放粮）、`jz_training`（教枪）、`jz_fireside`（夜话）这三张没有角色首次登场、纯气氛的场景——这三格的剧情文字都还在，只是不配 CG 了。同一条原则回头也发现南线漏了一个：`village`（孙策/周瑜初登场）一直没有 CG，补了 `c1_village`（未交付），所以南线也从 8 张变成 9 张挂字段。对标不要求数字完全相等，但密度（CG / 格数、分叉 / 格数）不能差太远；以后再改这两章的任何一边，顺手回来看一眼另一边有没有被落下太多。格数后来又从 19 补到 22：`jz_guojia` 和 `jz_relief` 之间加了 `jz_integrity`（张夫人送礼谢赵云，赵云原物退回，立住他「正直」的人设）；`jz_relief` 和 `jz_ambush` 之间加了 `jz_curious`（甄宓一路追问现代词汇，立住她「好奇」的人设）和 `jz_zuoci`（左慈路边一瞥，「三十岁的魂，十八岁的身——不对……你们俩……哦不，是你」，这是 `docs/STORY.md` 里早就规划好的「左慈是唯一知道双线真相的人」那条线索的北线那一半，南线 `event` 池里的 `zuoci` 事件以后要在某处也补一句呼应）。这三格最初全是普通 `event`，没碰 `treasure`/`recruit`/`mystery`——`prologue` 南北共用一个 quest，`soldier_pool`/`recruit_pool`/`event_pool` 三个池子原来都只有南线口味（丹阳兵、江东弓手……），北线squares 一碰这几个字段，黑山寨宝箱就能开出丹阳兵。后来加了 `Quests.pools(q, save)`：quest 可以带一个 `pool_overrides` 数组，每项 `{requires, unless, soldier_pool, recruit_pool, event_pool}`，`_flags_hold` 按这一轮的 `run_records`（不是 `save.flags`——这发生在本章节自己跑的时候，旗子还没在 `complete()` 时转正）挑第一条匹配的覆盖，每个池子字段单独生效、留空就还是用 quest 自己的基础池。`offer()`、`？` 格抽随机事件、`_apply()` 里 `soldier`/`offer.soldiers` 两处效果，现在都走 `pools()` 而不是直接读 `q["xxx_pool"]`；`validate()` 也把每条 override 的事件 id、兵卡 id 都校验了一遍。`prologue` 现在有一条 `requires: 出生：冀州无极` 的 override：`soldier_pool` 给了 `heishan_bing`/`changshan_tieqi`/`taihang_yiyong`，`event_pool` 只放了 `huatuo`/`smith`/`hj_camp`——新加了一格 `jz_mystery1`（`jz_relief` 和 `jz_curious` 之间）用这套池子抽？事件，验证过真的抽不到南线那票事件。**往北线/南线任何一个 quest 的 `event_pool` 加事件 id 之前，先搜一下那条事件的 JSON 里有没有「孙策/周瑜/孙坚/孙家/吴夫人/江东」这几个词、或者 `"battle"` 字段指向 `shuizei_scout` 这种南线专属场景**——这次顺手连 `luoyang_n` 的池子也查了一遍，之前塞进去的 `hero`（提了一句「孙家」）、`deserters`/`dice`（打的是 `shuizei_scout`）都是漏网的，已经摘掉了。
人物基调（后面写台词时保持）：张夫人对主角是真心疼爱、带几分精明主母的宠溺；甄宓对主角是纯粹的好奇和黏人；赵云正直勇敢，认死理但重情义；郭嘉看着无所谓、实则心里一清二楚。黑山寨那一战是三人交情的起点——`jz_reunite` 里赵云说「云愿追随先生，赴汤蹈火」、郭嘉说「这趟血赚……往后我跟你混了」，都是并肩拼过命之后才说得出口的话，不是一见面就纳头便拜，写后续章节时这条「过命交情」要接得上。**立绘**：`lord_north` 和南线的 `lord` 共用同一张卡（`id` 都是 `"lord"`），只是发型（束发，不是南线的寸头）和甲胄（河北风格旧甲，不是南线的青金色）不同——见上面「`id` vs `person`」的坑，改这条线的立绘逻辑前先读那条。`jz_end` 不再是独立结局，直接接进第二章 `luoyang_n`（见下一段）。

第二章北线 洛阳烟云（quest `luoyang_n`，紧跟在 `taodong` 后面插入，`requires: 出生：冀州无极`；`taodong` 则是 `unless: 出生：冀州无极`——两边都不用正面声明「南方出生」，没走过 `era` 选择的旧存档/测试默认落在南线，这点很重要，别改回两边都用 `requires` 正面声明，会把"没设过出生记录"的 save 导到两条线都进不去或进错线）：车队往酸枣送粮，古道上救下逃婚的吕玲绮（精英战 `ln_lvlingqi`，`record_win` 吕玲绮：救下，营地里入队）；中山甄记大旗赞助诸侯联军，诸侯宴上对袁绍的吐槽和南线一字不差（同一个人，同一个老板）；曹操借粮是个 `choose`，两个选项各 goto 一个一行小方块再合流到 `ln_zhen`，不是靠 choose 选项直接发宝物（choose 选项只认 `label/goto/record/card`，没有 `relic`）——「借」那格改用了 squares 的 `relics` 字段直接发《孟德新书》；汴水救曹操撞上徐荣（新敌人 `xurong_n`，数值比南线 `xurong` 强，因为这里是本章中段首领，南线同期只是普通战，重用 `dagu` 的战斗图）；虎牢关前劫粮营，吕布那一战赢了接 `ln_triple`（一个固定事件 + 三个宝箱的 shuffle 组，和南线 `taodong` 的 `triple`/`box1-3` 一个模式），输了接 `ln_sanying`（三英战吕布，北线视角，复用南线 CG `c2_sanying`）；车帘后牵手；黄河边看洛阳方向天烧红、联军散伙，回冀州收尾，记「北线：班师冀州」。这章才是真正的「北线 · 敬请期待」占位结局所在地（挪到了 `ln_end`）。截图走查用 `--demo=ln2`（任意 `--at=<square id>` 跳到那一格）。曹洪、吕玲绮立绘都已到位；`ln_lvlingqi`（她的战斗 CG）、`ln_langqi`（并州狼骑战斗图）、`ln_camp`/`ln_handhold`（两张剧情 CG）还缺。

**Long-range story direction**: `docs/STORY.md` (南北双线 through 第十二章; 第十一章洛阳 is the fork: each line has one trap choice — south 收吕布 → 结局四 虎噬, north 信诸葛亮、交出帅印 → he poisons the hero that night and stages it as a drunken fall from the wall; the south just wins at 赤壁 (no body, no note — only an old guard muttering 「只有军师进过帐」) → 结局五 烛灭; done right, the ending depends on the *other* line's record in the save: 南线结局 赤壁 / 北线结局 官渡, or both right → 第十二章 天命归一). It is a direction only — the game is built one chapter at a time,
the implemented chapter (`story.json`) wins, and the outline is synced afterwards. Don't build unbuilt chapters from it or change the game to match it unless asked.

Writing rules:
- **Timeline** — the whole story so far spans about a year; each chapter opens with a `【年号 · 月】` line:
  ch1 富春 初平元年正月 → ch2 sets out 二月 (a month on the road), reaches 中原 in spring, two months of waiting,
  洛阳 burns in early summer → ch3 南阳 夏—秋 (冯夫人 sews winter clothes) / ch4 洛阳 夏—秋 → ch5 长安 arrives in winter,
  the wedding and 董卓's death at 初平二年正月 (「整整一年」) → 第四章: escape 二月, 洛阳 三月 (then a year of 排挤 in 洛阳), 南阳 初平三年夏 (192) → 第五章 初平四年 (193). Don't write 「小半年」「好几个月」 that break this.
- A named enemy should be introduced before you fight it: give its battle square `text` (lines play first, then
  the enemy info and 出战) rather than putting the introduction in the square after the fight.
- **The hero stays a clown (逗比)** — even in tender or tragic scenes give him one goofy beat (a bad joke, a modern word, a sound effect) before the mood lands; he goes to 王允 *because* he knows the 连环计 from TV and proposes it himself (王允 first plays the loyal servant of 董卓, then takes the credit).
- The hero is a modern man who **never read 三国演义** (「三国演义我不熟啊」) and regrets it (「早知道会穿越，当年就该把那本书
  读完」). He knows only the famous: from textbooks (周瑜 via 苏轼, 蔡文姬, 二乔), games (孙策, 吕布, 左慈) and TV (关羽,
  华佗, 黄盖's 苦肉计); most others he's never heard of. His foresight is thin: 孙坚's card blurb says only that he dies
  fighting 刘表 (no 岘山 / 黄祖 / ambush details — those he hears from others), and everyone knows 「见到吕布，跑」. When a character first appears he sizes them up in a `{lord}（内心）：` aside —
  recognised or 「没听过」, plus a modern jab that stays believable (袁绍 = the boss who loves meetings and never
  decides) — no forced office metaphors; famous people (孙坚) he simply knows. One per character; no historical detail he couldn't know; characters never cite 演义.
- **Few soldier types per enemy faction (3–5)**: 西凉 游骑/斥候/弓骑/飞熊军, 袁术 步卒/弓手/骑兵/密探, 并州 狼骑/吕布亲兵/陷阵营兵,
  司徒府 哨卡/府兵. A later chapter reuses the type with stronger hp/at (its own enemy id, same name / portrait / moves), and its
  scenario shares the type's battle CG via `"art": "<scenario>"`.
- **CGs have few people** (technical limit): at most four named characters in focus per story CG / event picture; unnamed
  background people (soldiers, crowds) are fine. A scene that needs many people (a row of generals, a banquet of lords) gets no CG; the text carries it.
- **Looks match the art.** Settled by delivered art: 董白 has a silver-white high ponytail and purple fur-trimmed armor (her 女骑 wear purple too);
  鲍三娘 wears red armor over a green skirt; 刘备 fights with twin swords. A character's appearance in the text must match their portrait — or, before the art exists,
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
