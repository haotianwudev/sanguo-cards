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
| `godot/data/cards.json` (+ `enemies.json`, `scenarios.json`, `skills.json`, `relics.json`, `battle.json`) | the one card-data dict, split by top-level key: cards.json = gacha / tiers / troops / kits / lord_forms / cards; enemies.json = enemies (+ moves); scenarios.json = fights; skills.json = skills + budget; relics.json = relics / fates / relic_pick; battle.json = battle constants + difficulty. `GameData._load` merges them (a key may live in one file only); Python tools use `tools/gamedata.load_cards()` |
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
第四章：`--demo=ch6`（围府线，已触发前面的 badend）/ `--demo=ch6b`（报信线）/ `--demo=ch6c`（已触发「结局五 · 恨海」，渭水打张济张绣、收贾诩），加 `--at=<square id>` 直接跳到那一格截图。
第五章：`--demo=ch8`（恨海线）/ `--demo=ch8b`（通关恨海、第四章收了贾诩后的破局线），同样可加 `--at=`。
`tests/test_routes.gd` walks chapters 3–5 on every ending route (squares, records, endings, cards, which chapter follows) and checks
that no two open squares ever share a spot; keep it green when you add squares.

**存档：南线、北线各一个，可以同时玩。** `user://save_south.json` / `save_north.json`（路径见 `SaveData.slot_path`），新旅程在选完出生点前写在 `save_pending.json`，选定后 `Game.assign_slot()` 把它挪进对应路线的槽位；那条线已有存档时，`map_screen._resolve` 先弹 `ConfirmOverlay` 问要不要覆盖。结局、卡牌收藏（`SHARED_LISTS` / `SHARED_MAXES` / 结局旗标）两边共享，写在 `user://shared.json`：每次 `Game.persist()` 顺手 `write_shared()`，读档时 `apply_shared()` 合并（所以天命归一能同时看到南线赤壁、北线官渡）。旧的单存档 `save.json` 第一次启动时由 `migrate_legacy()` 搬进对应槽位。`Game.persist_enabled` 在 headless（测试）下强制为 false，测试不会碰真存档。读存档一律走 `Game.load_slot(route)` / `Game.any_save()`，别直接 `SaveData.read()`。

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
`chest` / `grand_chest` (a loot chest over the map). `firststep` (chapter one's first step: the story, then the lord card moment; `--skip` skips the story), `cardsbook` (the 卡牌收藏 on its 主角卡 tab: remembered versions in colour, the rest greyed). Add `--north` to any `--demo=` to play as the north-route
lord (appends 「出生：冀州无极」 to `run_records`) — for demos that call `Quests.begin` internally (`chest`,
`grand_chest`, the chapter forks) that reset `run_records`, append the record again after the call, same as a
real run would after walking past `era`.

**In-game QA tool** (`scripts/ui/debug_screen.gd`, `DebugScreen`): a "测试工具" button on the title screen, only
built when `OS.is_debug_build()` is true (so it never ships in a release export — the `--export-debug` builds this
repo uses for phone testing all have it). Three tabs: jump straight into any chapter (`_CHAPTER_JUMPS`, a hardcoded
table of `quests_cleared` + `flags` per chapter mirroring the exact combinations `Game.demo()`'s `"ch4"`/`"ch6"`/
`"ch8"` cases already use — doesn't cover every narrative branch, just the main line into each chapter), browse
every card in `db.cards` regardless of what the save owns, browse every delivered CG (scans
`res://data/art/cg/*.jpg` directly, so it only ever shows what's actually shipped). Both galleries are split into
category tabs (cards: SSR / SR / R / C / 兵卡 / 剧情·敌方卡 by `rarity` + `in_pool`; CGs: by the key's prefix before the first
`_`, labelled via `_CG_GROUPS`, unknown prefixes still show under their raw name) and only build/load the picked tab —
all ~160 cards or every CG at once was too heavy on a phone. Tap a card or CG for a full-screen view; that overlay
closes on a fresh touch-down only (`button_down` + a 350 ms guard), because `CardView` fires `pressed` on touch-down and
the lift from the same tap would otherwise land on the overlay and close it instantly — same fix as the battle skill
popup.
`--demo=debug` opens the tool straight away; `--at=jump|cards|cgs` picks which tab. Keep `_CHAPTER_JUMPS` in sync
by hand whenever a new chapter's gating flags change — it's deliberately a plain data table, not derived from
`Quests.current_quest()`, because the branch flags (结局/路线/...) aren't mechanically recoverable from a quest's
own `requires`/`unless` the way `quests_cleared` is.
Demos walk square ids — when you insert or rename squares, update their walks (and `walk_to` in tests).
Screenshots of overlays look washed out because the PNG keeps alpha; in the game the dim is dark.

**Stats are automated**: `git config core.hooksPath tools/hooks` (once per clone) installs a pre-commit hook that reruns `chapter_stats.py --write` and adds `docs/CHAPTER-STATS.md` whenever `story.json` / `cards.json` / `art.json` is in the commit; `python tools/chapter_stats.py --check` exits 1 when the doc is stale (use it in CI) or when a quest is missing from `CHAPTERS`. A new chapter's quest id goes into `CHAPTERS` in `tools/chapter_stats.py`.
**Soldier factions (who may turn up in a chapter's chests)**: a soldier card is either the route's own (no `faction`, no chapter hands it out — or `public: true` for a route's own troops a chapter also hands out, e.g. 黑山喽啰 — it can turn up in every chapter of its `scope`), chapter-only (no `faction`, but a chapter hands it out: an enemy drop, a square / choice, a 招贤 list — only those chapters), or a faction's (`faction`: `han` 汉军 / `wei` 魏军 / `yuan` 袁军 / `xiliang` 西凉 / `bingzhou` 并州（吕布）/ `chaoting` 洛阳朝廷 / `huangjin` 黄巾 / `zei` 山贼水贼 / `jingzhou` 荆州 / `shanyue` 山越 / `yizhou` 益州南中 / `hanzhong` 汉中 / `wuhuan` 乌桓 — never public, only from chapters that fight them or list them). A new enemy troop gets a faction; `Quests.pools()["soldier_pool"]` (event 「soldier」 / soldier offers) follows the same rule, and a test checks no chapter hands out another chapter's soldiers. `docs/ROSTER.md` shows the result per chapter (⚠ = the card's `scope` is the other route's — it never drops there; the south's 义军 enemies in 第十一章 are that on purpose).

**Generated files — never hand-edit them; change the source and rerun the generator** (the pre-commit hook in `tools/hooks/pre-commit` reruns the three docs below and stages them whenever `story` / `cards` / `enemies` / `scenarios` / `skills` / `relics` / `battle` / `endings` JSON, `pics/art.json` or one of the generator scripts is in the commit; every generator with `--check` exits 1 when its output is stale — use it in CI):

| File | Generator | What it holds |
|---|---|---|
| `docs/CHAPTER-STATS.md` (only the generated columns, the 南北线对比 table and the 卡牌种类 section; the per-chapter prose and the 入队 / 分叉点 columns are hand-written) | `python tools/chapter_stats.py --write` / `--check` | squares, battles normal / elite / boss, forks, CGs drawn / total, pools, per chapter and route |
| `docs/ROSTER.md` | `python tools/roster.py --write` / `--check` | every soldier by 阵营 / 章节限定 / 公共 with where it comes from; which soldiers each chapter's chests hand out (⚠ = card `scope` doesn't match the route); every general with where it joins / is recruited / drops; per chapter joins / 招贤 / drops |
| `docs/chapters/<NN>-<南线 or 北线>-<章名>.md` (e.g. `07-北线-邺城惊雷.md`; 第一章 split into its two routes) + `README.md` index | `python tools/chapter_docs.py` / `--check` | one review file per chapter: header (requires, ending, pools, shuffles), numbers, the map square by square (x / y / type / requires / next / what it gives), the full script in map order with choices, battles (enemy, tier, turns, drop, picture) and enemy moves, the chapter's own ？ events, joins and drops, every CG drawn or missing with its prompt and reference portraits, the ending |
| `pics/ART-PROMPTS.md` | `python tools/art_prompts.py` | prompts for every missing picture; reference portraits are derived from the card / portrait names a prompt mentions (titled names like 「河北庭柱」颜良 match 颜良, portrait-only briefs like 郭图 / 袁谭 count, young 甄宓 → `zhenmi_young` before 北线第七章, north scenes and north events → `lord_north`) |
| `pics/ART-NEEDS.md`, `pics/SOURCES.md`, `godot/data/portraits/*` + `portraits.json`, map backgrounds | `sanguo-art` (from `pics/art.json`) | what art each chapter still lacks; delivered art |
| `godot/data/fonts/body.ttf`, `name.ttf` | `python tools/build_fonts.py` | the font subset — rerun after any new text (a test fails on a missing character) |

**Roster is automated too**: `python tools/roster.py --write` regenerates `docs/ROSTER.md` (every soldier by 阵营 / 章节限定 / 公共, which soldiers each chapter can hand out — ⚠ marks a soldier whose `scope` doesn't match the chapter's route — and every general with where it joins / is recruited / drops); the pre-commit hook runs it with the stats, `--check` exits 1 when stale. Never hand-edit that file.
**"update stats"** → `python tools/chapter_stats.py --write` (refreshes squares / battles / CG columns and the date of `docs/CHAPTER-STATS.md`, plus the generated 南北线对比 table — south and north side by side per chapter; a new chapter or quest goes into `CHAPTERS` in `tools/chapter_stats.py`; the overview is split into a 南线 and a 北线 table; the pools column and text are hand-written).
**New art from the user → use the `sanguo-art-ingest` skill (`python tools/art_ingest.py add <path> <key>`): it checks, crops, installs and logs; docs are refreshed only by `flush` every ~20 images.**
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
CG mode's text box has a 「框」 tool button (next to 跳过 / 隐藏) cycling 自动 (as tall as its content — the biggest, the old behaviour) → 中 → 小
(`Game.options.dlg_size`, kept in options.cfg; `DLG_H` / `DLG_FACE` in `map_screen.gd`). 中 / 小 keep no room for options that
aren't showing yet (`_options_room`), 小 also drops the title line; when the options appear the box grows to fit them.
Screenshot with `--dlg=auto|mid|small`, and `--skip` on any map demo plays the story through to its options.
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
to regenerate `pics/ART-PROMPTS.md`. Its 「下一批」 list is computed from the game data (what the game uses and still lacks, ranked by
tier: 首领图 → 精英图 → 主线 CG → 普通战斗背景 → 宝物 → 奇遇 → 未实装), never hand-edited — wire a `cg` / battle into a square and it shows up. Keep the prompt consistent with the brief in `CARD-DESIGN.md` §7 and the story text.
**Every battle / CG / event prompt names its reference portraits**: `ref_portraits()` in `art_prompts.py` puts a 「参考立绘」 line under
the prompt in `ART-PROMPTS.md` — the delivered portrait file of every card name the scene line mentions (clauses with 不要 / 没有 / 去掉 …
are skipped, so 「不要出现董白」 doesn't ask for 董白) plus the lord when 主角 is in it. A scene whose text says **常服** gets the casual
lord: `HERO_CASUAL` / `HERO_NORTH_CASUAL` as the outfit line (the default `HERO` line is armor + 古锭刀 and overrides the scene — that's how
c6_warn came out armored twice) and `lord_south_casual` / `lord_north_casual` as the reference; otherwise `lord` / `lord_north`.
So to get the lord out of armor in a CG, write 常服 into its scene line; never just hope the picture follows the scene.
When the owner hands over a prompt of their own (often Chinese, with 【角色】 sections, a staging note and the gag),
put it in `OVERRIDES` under its key — it replaces the template and stays in `art_prompts.py` after the art exists
(`ART-PROMPTS.md` and `ART-NEEDS.md` list only what is still missing, to stay short).
When new art arrives, look at it and rewrite that scene's lines to match what's drawn.

**立绘姿势不要呆板**（用户明确要求）：新立绘一律要有动势——身体扭转、重心偏移、手上有动作，禁止正面直立、双手垂身侧的证件照站姿。这条写在 `tools/art_prompts.py` 的 `PORTRAIT_COMPOSITION` 里，每张立绘提示词都会带上；已交付的老立绘不用重画，除非用户点名。

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
- **Listing files under `res://` at runtime: use `ResourceLoader.list_directory()`, never `DirAccess`.** An exported
  APK packs only the imported copies, so `DirAccess` sees `xxx.jpg.import` and never `xxx.jpg` — it works in the
  editor and silently returns nothing on a phone (the 测试工具 CG gallery was empty on device for exactly this). To
  check, export the pack (`--export-pack "Android" <scratch>/test.pck`) and run it with `--main-pack <it> -- --demo=...`.
- Never commit with failing tests: chain `... | grep passed` checks don't stop `&&` — look at the result first.
- **A fighter dict's `"id"` is load-bearing** — `CardView.make` special-cases `card_id == "lord"`, and battle/party
  code keys collection, tier and leader lookups off it. If one card needs more than one portrait depending on save
  state (the north-route lord: own hairstyle and armor, `Kit.portrait_key` falls back to the south one until
  `lord_north` art exists), give the fighter dict a separate `"person"` field for the portrait lookup
  (`fighter.get("person", fighter["id"])` in `card_view.gd`) and leave `"id"` alone. Changing `"id"` itself breaks
  anything that does `== "lord"` elsewhere — it compiles fine and only shows up as a blank portrait or a frozen
  pick overlay (the card errors building `db.build_fighter("lord_north")`, which doesn't exist, and the rest of
  that screen's `_ready()` never finishes). **Dialogue faces are a separate code path and don't inherit this fix
  for free**: `map_screen.gd`'s `_dialog_show()` gets its speaker key from `Kit.speakers()`, which hardcodes the
  lord's clauses (`{lord}`/`你`) to the literal string `"lord"` — it has no fighter dict to read a `"person"` field
  off. Fixed by checking `Game.save.lord()["person"] == "lord_north"` right where `_dialog_show()` resolves the key,
  swapping to `"lord_north"` before calling `Kit.portrait()` (which, unlike `Kit.portrait_key()`, does its own index
  lookup and has no south fallback — only safe because `lord_north` is already a real entry in `portraits.json`).
  North's lord troop also diverges from south in combat now: `cards.json`'s `"lord"` troop carries a
  `"skills_north"` override (`tuji` stays shared, `rengdao`/扔刀 swapped for `duomingqiang`/夺命枪 — same cost/power,
  just spear-flavored instead of blade-flavored, matching the established "主角从此改用枪" north identity) that
  `build_lord(name, mult, north)` in `game_data.gd` reads via `t.get("skills_north", t["skills"]) if north else ...`.
  Any other north/south lord divergence (new portrait-keyed surface, another stat/skill split) needs the same
  pattern: don't assume the south lord's single "id" covers both routes just because `build_lord`'s `north` flag
  already threads through — check every place that reads off the lord specifically, not just the obvious ones.
- **`project.godot`'s `window/stretch/aspect` must stay `"keep"`**, not `"expand"`. `expand` gives a wider-than-16:9
  phone screen more raw canvas instead of scaling into it, and since most screens size themselves in literal 1280×720
  pixels (`size = Vector2(1280, 720)` all over `scripts/ui/`), the game ends up pinned to the top-left with a dead
  strip on the other side instead of centred. Verify any stretch-mode change with
  `$G --path . --resolution 2340x1080 -- --demo=map --shot=<file>.png --wait=1` (a tall-phone aspect) before trusting it.

## How the game is modelled (add things through data)

**Endings are config** (`godot/data/endings.json`, loaded into `GameData.endings` / `ending_order`): one entry per ending — title (= the flag a square `record`s, word for word), route, chapter, kind, who, trigger, hint, unlock, `built`, cg, text; `built: false` ones are planned (shown as ？？？ with the hint). A quest's `ending` in `story.json` is just the id. `SaveData.endings_reached()` / `GameData.endings_reached(flags)` say which ones the save has; the title screen's 结局图鉴 (`EndingsBook`, `--demo=endings`) lists them. Add an ending = add an entry (tests check every recorded `结局…` line is in the table).
**自动战斗**：战斗右下「自动」开关（`BattleScreen.auto_on`，静态，跨战斗保持），开着时每次动画播完 `_auto_step` 走一步：`AutoPlayer.next(b)`（`scripts/core/auto_player.gd`：每 AP 价值最高的可用技能，限 1 技能打折，价值为 0 的不放，不防御不换人）选不出就结束回合；`--demo=fight --auto` 看效果。
Battle visuals: `BattleFx` (scripts/ui/battle_fx.gd) draws every hit / status / buff effect procedurally — hits and one-shot effects in `BattleScreen._play`, persistent statuses reconciled in `_sync_fx`, corner badges in `_sync_badges`; `BattleFx.scale` sizes enemy-side effects to the portrait. A new status = an engine event + one case in `_play` + a want-entry in `_sync_fx` / a badge in `_sync_badges`; `--demo=fx --fx=<name>` shows one.
**Branch squares (north 2–4 pattern)**: a plain fork = a battle lane (top, y0, 2+ squares, the last often an elite) and a rogue lane (bottom, y2, 2+ squares of ？ / 宝箱 / `recruit`, no fights); story squares (with text, or `requires`/`unless`) stay on the trunk. A test enforces it for `luoyang_n` / `heishan` / `beihai`. When squares are added or removed, recompute every `x` as the longest path from the start (keep each `(x, y)` unique, rows ±1 per move); `--demo=quest --id=<quest>` opens a chapter's map.
**South and north are symmetric in structure and separate in everything else** (see `docs/design.md` 「南北线」): give every new card / event / CG / pool a route (`scope`: south / north / empty = both). Generals' `scope` filters `SaveData.recruit_pool` (and so chests and recruit squares) by `is_north()`; generals ever owned stay offered. The CG gallery groups by the chapter whose squares use the picture (story.json), new north CG files use the `n<chapter>_` prefix.
**Story unlocks come from endings, not from the lap number.** A choose option can carry `"requires": "<flag>"` (an ending that must already be in the save's lasting `flags`): until then it is greyed and the button says 「（需先触发「…」）」 (`Quests.option_locked` / `option_hint`). 夏侯兰 (「请他执掌军法」 ← 「结局六 · 失律」, chapter 5, not built yet) and 张宁 (「拔刀相助」 ← 「结局二 · 覆巢」) are gated this way — a recruit that belongs to a badend is locked behind it, not behind a lap. A branch opens because the save carries an ending flag (`结局一 · 玉碎`, `结局三 · 同归`, `结局五 · 恨海`, … — they stay in `flags` across 周目); `requires` / `unless` read those flags. `lap` only drives the difficulty head start (`battle.lap_step`) and the title screen — never write a gate as "on lap N"; name the badend that must have happened, and call content "after 结局X" in docs and comments.

- **Card** (`cards.json` cards): `name, rarity (N = soldier, C/R/SR/SSR = general; C 杂将 is the lowest, the opening trio 主公/孙策·青年/周瑜·青年 are R), troop, hp, at (face numbers, see Card stats), skills,
  person (shared portrait / one version in a party), pool (false = story or drop only), troop_skills (false = own skills
  replace the troop's)`. Every troop has two skills — a plain 1-AP move and a signature (骑 马刀/冲锋, 枪 刺击/枪阵,
  弓 射击/齐射, 刀 步战/举盾, 策 计略/献策 (+AP; 策士 took in the old 法师 troop — too few cards), 贼 劫掠/偷袭 (break), 勤 包扎/鼓舞) — soldier
  cards get only the plain move (精兵 marked `"elite": true` — 丹阳兵, 陷阵营, 白毦兵 … — get both); a general gets
  the plain move plus its own signature (or the troop's signature if it has none). Leader stat = 5 × own + troop members; soldier copies decay ×0.6; generals repeat → tiers
  铜 1 / 银 2 / 金 4 copies (`gacha.tiers`, frame `tier0/1/2` in ui.json).
  **Lord cards are cards like any other** — the only difference: the lord's team must always field one, and it can be any lord card you hold (整备 picks it, `lord_form_pick`). Every lord card has its own copies and 铜/银/金 tier: the plain lord card is id `lord` (copies = `lord_copies`), every other one is id `lord:<form id>` (`db.cards`, registered at load from `lord_forms`; copies = `form_copies`). `SaveData.copies / tier / upgrade / grant_card / take` all take these ids: a draw or 点化 raises exactly that card's level (`upgradable()` lists every lord card you hold). **The lord cards share the draw pool with the generals of their route** — each lord card has its own rarity (`rarity` in `cards.json lord_forms`, R / SR / SSR; the plain lord card = `gacha.lord_rarity` R) that scales its stats like a general's (`gacha.rarity_mult`), same `scope` (the form's route), same `fielded_chance` bias towards the card you field, same chest pool; there is no separate lord draw rate any more. The lord in the fight is scaled by the tier of the lord card in use (`lord_with_form`). Never give the plain lord a level of his own; `CardView` frames a lord card by its own tier. **周目**: `SaveData.new_lap()` restarts the story keeping every card
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
- **技能体系 v2**（设计与理由见 `docs/skills.md`）：`troops` 只管 hp/at；技能组合在 `cards.json` 的 `kits`（`normal` 普通兵种默认 / `special` 特殊兵种默认），`kit_default` 映射兵种，卡牌可写 `kit` 覆盖。攻击 / 法术 / 回复效果写 `rate`（每 AP 威力，总威力 = rate × AP）、`hit_rate`（每段 = hit_rate × AP），不写就取 `skill_budget` 的档位默认（`rate_by_ap`、`multi_hit_rate`、限 1 大招 × `ultimate_mult`）；0 AP 技能直接写 `power`，`free` 允许 0 AP 攻击，`special` 不参与预算测试。新效果：`per_combo`（收尾）、`pierce`（穿甲）、`counter`（反击）、`hurt`（自伤）、boost 目标 `random_idle`；灼烧 `pct` 烧敌人现有体力且烧不死。军师战意：`buff` 效果（atk / def 每层，max 层，turns 回合），`Battle.buff`，郭嘉 / 荀攸 / 贾诩 / 蒯越的 1 AP 技能。主角卡：`cards.json lord_forms`（grants 卡池 / forms），每章发一张（第一章：第二格 = 出生选择后的第一个剧情格，`Quests.move`；其他章：第一格，`Quests.start_grant`，由 `map_screen._grant_chapter_card` 在进章节时发）（`grant_lord_form`，第一章（每周目）发固定的默认主角卡 `lord_forms.default`（`lord_default`「主公」：普通主公、默认立绘、无加成，不在 grants 里），第二章起随机没拿过的，都有了随机任意；第一格之前没有主角卡。**所有卡通用的记忆规则**：结局时 `commit_history` 记下卡和等级（`cleared_copies` / `cleared_lord_copies` / `cleared_forms`），`new_lap` 不继承卡本身（`owned` / `lord_forms` / `dupes` 清空），主公等级 `lord_copies` 保留；之后再得到某张记得的卡（抽到或剧情）= 升一个品阶（Lv，`next_tier_copies`：1→4→16 张）且卡也拿到（`grant_card` 用 `permanent_copies`，`grant_lord_form` 看 `cleared_forms`）；`move` 返回 `[{form, dupe}]`；主公永远算上场卡：招贤（`recruit_offer`）按 `fielded_chance` 也会抽到主公本体，拿主公时（`take`）顺带拿回一张记得的、本路线没持有的主角卡版本（`_draw_lord_form`），等级本来就 +1；第一章在首格 CG 与剧情看完后由 `map_screen._pending_forms` 依次弹出 `LordReveal`，其余章踏上即弹；章节回顾不再发卡），`SaveData.lord_forms` / `lord_form()`（最新一张生效，加体力攻击与技能，`art: true` 时立绘 = 卡 id）；`SaveData.is_north()` 同时看 run_records 和 flags；demo 加 `--forms` 发齐所有主角卡。难度递进：`Quests.ramp` = 本周目已通关章数 × `battle.chapter_step` + (周目 − 1) × `battle.lap_step`，加进 `Quests.mods` 的 enemy（回放旧章不吃章节部分）。状态：`cleanse` 效果（技能「解毒」）；精英 / boss 敌人至少一个混乱 / `ap_drain` / `burn_party`（按全军体力比例掉血）招式（测试守着）；`battle.affixes` 里 `confuse` / `burn_party` / `ap_drain` 是状态词缀。战斗中换人（选卡界面 = PickOverlay）：`battle.swap_ap / swap_from_round / swap_per_round / swap_ready`，换下的人本场不能再上，位置的攻击和全军体力不变，新人下回合才能动手；`Battle.swap`、`SaveData.swap_roster`，demo `--demo=swap`（加 `--done` 执行换人）。全局 `battle.enemy_hp_mult` 只乘敌人血量。
- **Card stats are plain face numbers**: every card has `hp` and `at` (铜 values; no troop base, no bonus, no rarity multiplier), each in **40..100**
  (the plainest soldier is 40/40, full is 100/100); a fighter has `at` > `hp`, a clerk (策士 / 后勤) `hp` ≥ `at`. **Rarity is where hp + at falls**
  (`gacha.rarity_bands`): N soldier 80~99, elite soldier / C 杂将 100~124, R 125~149, SR 150~174, SSR 175~200; the opening lord is 65/60 = 125 (the weakest R).
  A test enforces it for every card and lord card. 升级 multiplies both by the tier (铜 1.0 / 银 1.3 / 金 1.75 / 神 2.4), so SR at 铜 ≈ C at 银 and
  SSR at 铜 ≈ C at 金. Soldier copies join the unit as members and fall off smoothly: copy i counts `floor + (1-floor)·decay^i` (`gacha.soldier_decay` 0.8, `soldier_decay_floor` 0.5 → 1, 0.9, 0.82, 0.76 … never below 0.5). A hero who will have several cards (`gacha.versions`: 孙策 / 周瑜 / 赵云 / 郭嘉 / 关羽 / 诸葛亮 / 曹操 …) starts at **R**; later versions climb to SR / SSR (a test checks the table). A card with `first_win` (吕布) is won only by beating its owner: the first time ever (not owned, not in `seen`) it is always in the chest; afterwards it is a normal history-pool card. A new card: pick the band for its rarity, split it
  by role, keep each number 40..100. **An enemy's hp / at come from its card** (`battle.enemy_from_card` × the card face; the enemy table has no hp / at for them — only the moves, actions and resists); a showpiece that must be hand-tuned (吕布, `lose_goto` fights, 野猪 / 老虎 without a card) writes its own `hp` / `at` in `enemies.json` and keeps them. Strength then = card × tier (普通 / 精英 / 首领) × stage (chapter curve + position + `scaling.route` for 第一章 south / north). The enemy table (`enemies`) is in the old magnitude and is converted on entry (`battle.unit` hp ÷ 9, at ÷ 1.4),
  every damage is × `battle.damage_mult` (0.1556), and enemies get one more coefficient per tier (`battle.enemy_coef`: normal 1 / elite 1.5 / boss 2,
  必败 `lose_goto` fights (and every 吕布 fight) 2.5 — for every tier alike hp takes the whole coefficient, attack only its square root (`Quests.enemy_scales`); `scaling.tier` is 1 so the two do not stack).
- **Enemy**: `hp, at, actions, resists, portrait, card (its chest may hold it: 25%, bosses/elites 50%), moves[]` — move
  `power (0 = no hit), weight (0 = only after a charge), confuse, rage, heal, ap_drain, burn_party, pierce,
  charge (wind-up announced a turn ahead), when: "half", once`. Make fights strong; make their cards modest.
- **Relic 宝物** (`cards.json` relics): found during a chapter; all carry into the next chapter (`kept_relics`), but ones found in the current chapter reset on a restart; `rarity common/rare/curse, icon, desc, mods {...}, after_win`. Mods are
  summed by `Quests.mods(save)` and passed to `Battle.start(..., ambush, mods)`. New mod ⇒ read it in `battle.gd`.
  A story square can hand one over directly on arrival with `"relics": ["<id>"]` (same shape as `"cards"`; a
  `choose` option can't do this — it only has `label/goto/record/card` — so route the option to a one-line event
  square carrying the `relics` field instead, both branches rejoining the next common square).
- **Local pools (按地点的池子)**: a `treasure` / `recruit` square can carry its own `soldier_pool` / `recruit_pool` (card ids) — `Quests.pools(q, save, sq)` lets the square's list win over the chapter's, a chest then holds only that place's soldiers (`SaveData.chest_offer`) and a recruit square shows `gacha.offer_size` random cards of its own list. They travel with a shuffle (`CONTENT`). Keep it to at most two soldier pools and two recruit pools per chapter (第五章: 宛城·汉水·新野 / 襄阳; 第三章: 鲁阳 / 洛阳·长安) — squares of one place share the same list; the stats table counts the distinct lists; a square with no list uses the chapter's pools as before. `test_a_squares_own_pools_...` checks the ids.
- **Quest** (`story.json` quests): squares `{x, y, type, label, next, text, portraits, cards, relics, choose, battle, boss,
  elite, ambush, event, lose_goto, beatable}` (beatable: a lose_goto fight that is still a real, normally scaled fight — 华雄); types `event choose battle treasure recover recruit mystery`. Moves only go right,
  one row at a time (a test checks). `soldier_pool`, `recruit_pool`, `event_pool`, `shuffle` (groups that trade
  contents each run). A run = one attempt: losing restarts it (cards, choices, 难度 kept; 宝物, 险, layout reset).
  A quest itself can carry `requires`/`unless` (checked against `save.flags` only, i.e. earlier *completed* chapters —
  not this run's own records) to gate which route opens next; `current_quest()` walks `db.quests` in array order and
  returns the first uncleared one whose `requires` holds and `unless` doesn't. Prefer `unless` over `requires` for a
  "the other branch's" chapter (e.g. `taodong`'s `unless: 出生：冀州无极`) so a save that never made that choice — most
  tests, old saves — still defaults into it, instead of needing every such save to positively declare the branch it's on.
  A quest shared by two routes can also carry `pool_overrides` (`[{requires, unless, soldier_pool, recruit_pool, event_scope}]`) so
  `treasure`/`recruit`/`mystery` squares on one route don't hand out the other route's cards/events — see `Quests.pools()`. Every
  event in `story.json` carries a `scope` (`universal` / `south` / `north`); a quest's event pool is its own small `event_pool`
  (one-off cameos exclusive to that quest) UNION every event whose scope is `universal` or matches the quest's `event_scope` —
  config-based on purpose, so a new universal/south/north event is automatically available everywhere that scope applies, instead
  of every quest hand-copying the same 30-item id list. A ？ square then draws in two steps (`Quests.pick_event`): first the pool by `battle.event_sources` weights
  (`chapter` = scope is this quest's id, `route` = north / south, `universal`; an exhausted pool drops out), then one unmet event in it. See the "Editing gotchas" note below on picking an event's scope correctly.
  Same idea for the displayed chapter name:
  `title_overrides` (`[{requires, unless, title}]`, `Quests.title(q, save)`) swaps `q["title"]` for a route that shouldn't keep
  showing the other route's chapter name on the map header/recap/toast — `prologue` has one so the north route shows "第一章 ·
  冀州风云" instead of the south-only "第一章 · 富春" it used to show throughout. And for the map background itself:
  `map_overrides` (`[{requires, unless, map}]`, `Quests.map_key(q, save)`, read by `map_screen.gd`'s `res://data/art/map/<key>.jpg`
  load instead of a bare `q["id"]`) swaps in a whole separate image file — `prologue` south keeps its own `prologue.jpg` untouched,
  the north override points at `prologue_north` (a map that doesn't exist yet, so north currently shows no background — that's
  `ResourceLoader.exists()` failing gracefully, not a bug). Tried a single stretched south+north scroll first; don't — the user
  wants two separate map images for a shared quest, one per route, matching how chapter 2's `taodong.jpg`/`luoyang_n.jpg` already
  are two separate files (they're separate *quests* so that was free; `prologue`'s two routes are one quest, hence this field).
- **Event** (`story.json` events, for ？ squares; a square with `event` is fixed): `title, glyph, color, text,
  portraits, options [{label, effects, win}]` — effects `say, damage, heal, rest, poison (−⅓ HP), card, soldier,
  offer {from | generals + rates | soldiers}, upgrade (true = pick one of `gacha.upgrade_offer` (3) random upgradable cards, the lord just one of them, no fixed option — the recap's 战功点化 does the same via `SaveData.upgrade_offer`; "random" = no pick), refresh, relic, danger (险, run),
  difficulty (whole campaign), drop_relic, lose_soldier (trades: give something up), battle + ambush, chance {then, else}`. Text uses `{lord}` for the player's name.

- **Chapter recap**: finishing a chapter shows `Quests.recap(save)` — battles won, cards gained (collection diff since the
  run began), relics picked up, and the run's key lines. Mark what matters with `record` (square, when resolved),
  `record_win` / `record_lose` (battle squares), `record` on choose options, or a `{"record": ...}` event effect —
  short lines like 「董白：留下」. These lines are also the hook for later cross-chapter branching.
- **Between chapters**: recap (战功 paid once, spent on a draw or an upgrade) → `Quests.complete` turns the run's records
  into permanent `save.flags` → interlude scenes from `godot/data/interludes.json` (keyed by the finished quest; a scene's
  `requires` / `unless` name a flag) → the next chapter's title card (with the quest's `subtitle`, e.g. 「半年后」 — the journey from 富春 to 孙坚 takes about half a year;
  孙坚 had left home well before, and he meets the hero for the first time in chapter 2). The 部队 button on the map opens the party screen.
- **重返上一格 / 重打这一章** (设置 menu, on the map and mid-battle): `Quests.move` pushes `SaveData.snapshot()` (the whole save minus
  `stash` / `chapter_start` / `steps` / `theme`) onto `save.steps` before every step; `rewind_step()` pops one, as far back as the
  chapter's first square (`fail` pops the step it already undid). The 设置 button calls `Quests.step_back`, not `rewind_step`
  directly: a choose square moves on the moment you pick, so landing on a made choice goes back once more and re-enters it
  unresolved (on a chapter's first square: `restart`) — otherwise the pick could never be changed. `Quests.begin` stores `save.chapter_start` once per chapter (not on a
  first-square loss) and clears `steps`; `Quests.restart` → `rewind()` puts every field back, dealt map included. An old save with no
  `chapter_start` gets its cards back from `run_start` and a fresh `begin`. Both fields are in `RUN_FIELDS`, so a replay parks them.
  A new save field is covered automatically (it's in `FIELDS`); only add it to the `snapshot()` erase list if a rewind must not touch it.
  Screenshots: `--demo=map --settings[=back|restart]`.
- **Replays**: the title screen replays finished chapters (`Quests.start_replay` parks the main run in `save.stash`);
  each clear adds +1 险 (`save.clears`); cards and 战功 stay, story flags don't change.

After adding content: run tests, screenshot the relevant demo, fix layout overflow (e.g. three skills shrink the
battle cards), commit, push.

## Chapter design checklist (rogue density, bosses, pools, shuffles)

What the owner asked for while 第三 / 四 / 五章 were reworked — apply it to every chapter, then compare with the other route in `docs/CHAPTER-STATS.md` 南北线对比:

- **Fights per run, not per file.** The squares count adds up mutually exclusive routes; judge a chapter by its longest path (a quick DAG walk over `next` + `choose` + `requires`/`unless`). If normal fights dominate (第三章 长安线 had ~22), turn some into `recruit` / `treasure` / `mystery` squares instead of deleting the square (keep its `next`, drop `battle`).
- **No long runs of story squares.** Three story squares in a row want a fight or a rogue stretch: add a **lane group** (2 columns: battle lane on top, rogue lane — `mystery` / `treasure` / `recruit` — below, both rejoin at a y1 trunk square; rows move ±1 per step, so a lane group must be followed by a y1 trunk square) or a **small fork** (1 column: one battle square + one treasure / mystery). Insert columns by shifting every later `x` with a script (assert unique `(x, y)` among open squares); update the fork-anchor list in `test_the_filler_forks_...` (`tests/test_quests.gd`) when you add or move a trunk square.
- **Tier mix.** More normal than elite than boss on the longest path. A plain trunk fight may be normal; lane tops end on an elite or boss.
- **Named generals as bosses.** Some early in the chapter (as the opener of a choice branch, e.g. 文聘 / 苏飞), some in the second half (张允, 蔡瑁), optional ones inside a lane (刘磐). A new enemy needs: a card (`pool: false`) + enemy with a move that confuses / drains AP / burns the party (a test checks elites and bosses) + a scenario (`art` reuses an existing battle picture) + a portrait brief in `CARD-DESIGN.md` §7 and `tools/art_prompts.py` PORTRAITS + an entry in `Kit.ALIASES` (`scripts/ui/kit.gd`). Use characters that already have a portrait when you can.
- **Share CGs between the routes.** A scene both the south and the north run through (洛阳 burning, a 诸侯 banquet, 董卓 / 吕布 moments) gets ONE route-neutral CG key shared by both routes' squares (several squares may name the same key) — draw the scene, not the lord or a route's own companions (赵云 / 郭嘉 / 孙策 / 周瑜) — a shared CG may have no people in it at all. Only moments that are really one route's (its own companions, its own lord) get a route key (`n<chapter>_…` for the north). Before writing a new CG prompt, grep `story.json` for the other route's picture of the same moment and reuse its key when it fits.
- **Lead in to every fight.** A battle right after a story beat needs lead-in `text` (who the enemy is, why they are here) and a wired `cg`; a character's first appearance gets a CG. Look at delivered art and rewrite the lines to match it.
- **Good ending = people join.** The best ending of a chapter hands over the defeated side's people (`cards` on the ending-adjacent event: 第五章 破局线 gives 蒯越, 刘表, 刘磐).
- **Pools: at most two soldier pools and two recruit pools per chapter** (see *Local pools*); same place = same list.
- **Shuffle groups: one or two per chapter** (`shuffle` in the quest). A group is a few lane-first squares of one fork family — a battle square and a `mystery` / `treasure` / `recruit` square with the same predecessor and the same `requires` / `unless`. Only `CONTENT` moves (type, label, battle, boss, elite, ambush, event, text, portraits, cg, prompt, soldier_pool, recruit_pool): never hang a `record`, `relics`, `cards`, `choose` or `lose_goto` on a shuffled square. Eight groups in one chapter (第五章 once) is too many.
- **Stats.** After touching a chapter: run the tests, then `python tools/chapter_stats.py --write` (the pre-commit hook does it when story / cards / art data is committed). Only the generated columns and sections refresh; the 入队 / 分叉点 wording and each chapter's own section are hand-written — update them.

## Story voice

Comic, mature, and frank: this is an adult game, so war, death, and adult romance/sexual tension between adult characters may be written directly, not softened or euphemised. The one hard line: nothing sexual or romantic-tinged touches a character under 18 (甄宓 before her adulthood, 孙尚香 as a child, 孙权, anyone in the 13–17 band). The hero is a 30-year-old office worker's soul in an **18-year-old** body in
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
Route B (once the badend 「结局一 · 玉碎」 has been reached — flag 「结局一 · 玉碎」 — with 董白 kept): 蔡文姬 can be saved, which ends chapter 3 early
(「路线：守洛阳」). On route B 驻守洛阳 and 长安 are NOT separate quests any more: they are squares of the `yuxi` quest (requires 「路线：守洛阳」/「路线：长安」, recorded at `wenji_join` / `lijue_test`; route A's later squares carry `unless 路线：守洛阳`), with `title_overrides` (「第三章 · 驻守洛阳」「第三章 · 长安」) and `map_overrides` {map, from} swapping the map art and the first column drawn. **Rule: a route that goes on inside the same chapter is a branch in that chapter's quest, never a new quest/chapter-start card.** (`map_from`, `InterludeOverlay.same_chapter` handle the rest.) 驻守洛阳 (quest requires that flag): 蔡文姬's story (郭汜 escorting the officials' families,
plundering), 周瑜's plan to rob his grain carts, 郭汜 fought off (no 蔡邕), 孙坚 holds 洛阳, the coalition disperses,
朱儁 (孙坚's old commander from the 黄巾 war, fled 董卓) arrives and joins, asking the hero to carry a question to 皇甫嵩; 李儒 sues for peace (周瑜 for it, the hero suggests 王允), 董白 is betrothed to the hero (wedding to be in 长安), the hero
goes to 长安 (「路线：长安」). 长安: 汉献帝 (a boy of about ten, 董卓's puppet — never anything but a child in the text or art) secretly asks the hero where he's from, where 孙坚 is and whether he can take him back to 洛阳; after 董卓 dies 王允 answers for him (「长安才是都城」); Chapter 5 长安: 董卓 greets 董白, humiliates 皇甫嵩 at the feast (he later sides with 王允, brings the palace guard at 格杀勿论 — he does NOT join here; after 董卓 dies he asks 王允 about 董白 and gets no answer), 蔡邕 reunion, 王允, 貂蝉 and the hero's 连环计 — hidden from
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
once 「结局五 · 恨海」 has been reached (flag 「结局五 · 恨海」), 第四章's escape meets 李傕's pursuers 张绣 (张济's nephew, 北地枪王, 渭水桥) and 张济 (渭水营, elite)
instead of the 司徒府 pursuers / 樊稠; 张济 withdraws to 弘农 and the hero simply has their strategist 贾诩 tied up and carried off on a grain cart (he gave
李傕 the idea to attack 长安; easygoing, he makes himself comfortable); in 洛阳 (a lap-4 休整 square) the hero unties him and treats him
with great respect — best room, first bowl of 红烧肉, clean wine — and 贾诩 shrugs 「……行吧」 and joins (「贾诩：入队」).
第四章 · 挟天子 (quest `dongui`, one map; requires 「长安：吕布杀了董卓」): 王允 rules — the hero stops the 夷三族 of 董卓's house
(the boy emperor backs him); asks 王允 to pardon the 西凉 army and bring 孙坚 into 长安 — refused; 论功: 吕布 温侯, 孙坚 吴侯,
皇甫嵩 征西将军, and the emperor insists on the hero over 王允: **富春亭侯**; recruits 荀攸 (封侯后周瑜提起天牢里的荀攸 → 「天牢·狱卒」一战 → 天牢入队 CG c6_xunyou → 「路线图」: 荀攸替陛下画长安回洛阳的路；之后逃城指北岸、北掖门亮黄门腰牌、洛阳拟《奉迎天子还都表》；钟繇和荀彧不入队，钟繇的戏份全归荀攸) — 荀攸 (天牢: reads 王允 at once; his uncle 荀彧 is six years younger) and 钟繇 (尚书台: the emperor had him draw the escape route; 钟繇's map and 荀攸's calls run the escape, 荀攸 goes to 南阳, 钟繇 stays by the emperor);
王允 plots with 吕布 to kill him. **First time through (no 「结局三 · 同归」 flag) nobody warns him** (貂蝉 is 吕布's now: she stands behind him at 封侯, no window-knock the night of 围府, rides behind him at 宣平门, and regrets it in 结局三's last lines — keep that thread): 吕布 and 高顺 surround
蔡邕's house (蔡邕 arrested for sighing over 董卓), breakouts (高顺, 并州狼骑) with 孙策 and 周瑜 fighting alongside, 董白 brings
what's left of the 董 household, 吕布 at 宣平门 (last stand, lose_goto); after it the hero holds the gap so 孙策 and 周瑜 can ride out → 结局三 · 同归 (the hero, 董白 and 蔡文姬 fall together,
restrained). The squares from x5 of the warned route require that flag; the trap squares sit on the same spots with no
requires (they're only reachable from the split). **After the badend** (flag 「结局三 · 同归」): 貂蝉 (王允's adoptive daughter) warns him; 李傕/郭汜 attack 长安, 王允 keeps 吕布 on a leash; 周瑜 (in 长安 with
his uncle 周忠) says take the emperor to 洛阳; 董白 brings 董卓's old guard, 貂蝉 comes along (both join at 北掖门), 皇甫嵩 holds the gate, then catches up and joins;
王允's checkpoint, pursuers or 樊稠, 徐晃 defects, 李傕 at 函谷关 (boss) → 洛阳, 孙坚 kneels; 长安 falls, 王允 dies
on the gate, 吕布 goes straight to 张杨 in 河内 (his old 并州 friend), 李傕 and 郭汜 hold 长安 (no infighting); 孙坚 keeps the 玉玺 and takes 大将军·录尚书事 (挟天子 — the hero notes the textbook said
曹操); the emperor has the hero made 破虏将军 (孙坚's own old title, handed down grudgingly); pushed aside, and sent against
袁术 in 南阳 because 孙坚 can't leave the emperor: 桥蕤, 黄忠 (a 南阳 soldier robbed by 袁术's men, sick son
黄叙) joins, 雷薄, 陈兰, 冯夫人's night visit, 孙坚's old men inside 宛城 (he once camped in 南阳; they know the tiger tally he gave the hero) open the east gate — 里应外合, 纪灵 (boss) holds the rear and flees east with 袁术 and 冯夫人 — where they went is left unsaid for now.
第五章 · 荆襄风云 (quest `jingxiang`, requires 「南阳：袁术东逃」, 初平四年（193）春 → 秋, ~a year after 南阳 (袁术东逃)): 吴夫人 and 蔡邕 move to 宛城 (family supper), 貂蝉 swaps
her palace robes for a light 留仙裙 and learns to 「放假」; 刘表 sends 黄祖 across the 汉水 (淯水 battles, 黄祖 mid-map boss, 休整);
刘表 sues for peace through 蒯越, the court makes 刘表 荆州牧 and the hero **镇南将军·督荆襄军事** in 襄阳; 周瑜 warns it's a 鸿门宴, 貂蝉 insists on
coming to see the 汉江; 蔡夫人 (claims 蔡文姬 as kin via a genealogy, showers 貂蝉 with pearls — 貂蝉: her eyes never smile) and her brother
蔡瑁 (水军都督, wants 貂蝉) plot a poisoned banquet at the 万山水阁. 荀攸 only appears at the 刘表来袭 war council (`jx_laixi`, a `choose`: 荀攸「示弱诱敌」 → `jx_plan_xun` gives 荀攸的黑棋 (no_ambush), 黄忠「半渡而击」 → `jx_plan_huang` gives 半渡令箭 (first_hit); both rejoin at `jx_bubing`; no cards are given, and 贾诩 is not guaranteed to have joined so the strategists are 周瑜 + 荀攸); no other 第五章 scene. Split on 「结局五 · 恨海」 + 「贾诩：入队」: **without both** (a 庆功 night, 貂蝉 pours her first cup for him) 千斤闸, 50 crossbows, 鸩羽落红 in a 金兽爵 — 貂蝉 drinks it for the hero, stabs 蔡瑁's eye with her hairpin, knocks over the brazier;
she dies in his arms (「这回，换妾身护了你一次」), he has 蔡氏, 蒯家 and 刘表 all wiped out (一个不留; 蒯越: 「蒯家没有碰过那杯酒」) (董白: 「你越来越像我爷爷了」) and is stabbed by a 荆州士族 retainer in mourning white (「蔡家、蒯家、刘家，三百一十二口」)
by the 汉江 → **结局五 · 恨海** (restrained). **With both**: the hero dreams it all and runs barefoot to 贾诩, who names the poison (鸩羽落红) at once;
贾诩 plans 联蒯灭蔡, 蒯越 turns, the hero hides
everything from 貂蝉 (吴夫人 dresses her), the 闸 never falls; 貂蝉, who knows nothing of his plan, reads the trap, takes his jokes for
obliviousness and rises to drink the cup for him (hand at her hairpin, as in 恨海) — he pulls her back into his arms; only when the
crossbows turn does she see it was all arranged (「你今晚唯一的差事，是剥橘子」 / on the 楼船: 「白费得真好」); hands her a mandarin orange (「她喝不得烈酒，免了」), offers
蔡瑁 half the cup, the poison burns the carpet, the crossbows turn; 刘表 runs over before dawn to swear he knew nothing and cuts ties with the 蔡 (「早就不甚往来」), the 蔡 elders strike 蔡瑁
out of the very genealogy 蔡夫人 used on 蔡文姬 and hand over 800 men, 30 ships and money to save themselves; only the ringleaders die — 蔡瑁, his brothers 蔡中 / 蔡和 (they placed the crossbows) and 刘表's nephew 张允 (mixed the
poison); 蔡夫人 is spared death but divorced by 刘表 on the spot, stripped of her title and confined to the 蔡洲 estate for life; 刘表 hands over the army, 蒯越 joins, the hero is
督荆襄九郡大都督; moonlit 楼船 and hot chestnuts. (未完待续)
第六章 · 淮南折帝旗（南线，quest `huainan_s`, requires 「荆襄：督荆襄九郡大都督」 — only the 破局 route goes on; 恨海 still stops the story）: three years in 襄阳 pass in one square; **荆南四郡亲征**（`hn_nan_*`，x1–x6，建安元年春）：贾诩看出四份抗命书是蔡家旧部串联，主角自己带一队人上（不带孙策周瑜）：零陵坞堡（`jx_wubao`，刘度装病）→ 桂阳山寨（`jx_zongzei`，赵范送到界碑）→ 精英长沙城门洞 魏延（`hn_nan_weiyan` / `weiyan_e`；金旋的武陵不战而降，韩玄躲府里）→ `hn_nan_weiyan` 魏延归营（`cards: weiyan`，story-only，因此不在公开招贤池）→ `hn_nan_wufuren` **吴夫人回长沙**（CG `c9_changsha`，孙坚当年做长沙太守的郡守府，柱上孙策的身高刻痕，记「荆南：收复四郡」）→ 接家书；地图新增 6 列（`MAP_REDO huainan_s` 待重画）。 为了不让剧情格连续三个，主线上另加了 4 个宝箱格：`hn_nan_fuku` 长沙府库、`hn_lu_gift` 鲁家粮囷、`hn_wan_fu` 皖城府库、`hn_bridge_t` 淮水·缴获（现在没有 3 连剧情；最长路线 58 格）。 孙坚 (大将军 in 洛阳) sends a family letter, not the edict (「嘴甜的：……——文台。」, plus the running 「别给嘴甜的吃」 note); 庐江: 周家 freed at 舒县, young 陆逊 only shows his face (`@luxun_young`), 鲁肃 gives a granary (「看看这个荆州来的人，值不值三千斛」) and joins; 皖城: boss 刘勋, 陈武 opens the gate and joins, 二乔 in the carriage (小乔 recognises 周瑜 only with 「二乔：河边初见」 from the chapter-1 event), 孙策 drops his spear, 周瑜 his ledger; 郑宝's 过湖钱, elite 雷薄陈兰 (「又是你俩！」), elite 张勋's chained tower ships (孙策: 「这船晃！」), boss 仲氏禁军 at 寿春南门; 冯夫人 left behind on the boat (later handed to 吴夫人 in 庐江 with an old winter coat); the 淮水浮桥 glimpse of the north hero (same face, longer hair, both rub their temples; a `Ping: 1ms` glitch line); 北海相 gives 淮南 to 曹操 (周瑜: 「要么是傻子，要么比你还会算」); the chapter ends on the eve of the 庐江双婚 (旧冬衣 → 庐江休整 → 东望江东, record 「庐江：喜期将近」); the wedding itself (周瑜 hands 小乔 the ledger; she forgives the bowl of porridge; 大乔 joins) is `jd_wedding`, the first square of 第七章. 甘宁 is not guaranteed to have joined — don't name him in mandatory text. **庐江士族分岔**（`hn_shizu`，画舫之后、北上之前）：刘勋逃进灊山雷家（雷家本来就是袁术的人，雷薄是族侄）。「开仓分田」（默认）烧雷家契券 → 追到灊山寨门不开、别家冷眼旁观 → 当夜急报：庐江大族怕下一把火、仗着寿春的袁术跟着雷家反了，劫二乔上灊山（全在庐江，不去寿春） → 皖水雷家部曲 → 灊山寨雷绪（打不赢）→ **结局七 · 深锁**（主角倒在寨门前，二乔被关进囚车送往寿春，刘勋大笑，CG `c9_qiuche`）。「请刘晔居中」（`requires: 结局七 · 深锁`，刘晔入队）→ 雷家的信给各家看、没人跟雷家 → 精英灊山雷绪，雷家覆灭、刘勋斩首、雷家的田分给佃户 → 北上寿春（袁术死在寿春城外江亭，蜜水 CG `c9_mishui`）→ 双婚（刘晔烧信）。巢湖以后的格子都 `unless: 庐江：开仓分田`。坏线格子 `requires: 庐江：开仓分田`，好线 `unless` 同一条。
第五章 rogue: soldier_pool = 荆州 types (荆州步卒 / 荆州弓手 / 荆州水军 / 蔡府连弩手) + 宗贼 + 锦帆贼 + own; 招贤馆 recruits 文聘 / 伊籍 / 甘宁;
extra fights 汉水渡口·锦帆贼, 新野·宗贼 (周瑜 recalls 蒯越 killing 55 宗贼 leaders at a banquet — foreshadowing), 城防·荆州步卒; ？ events
水镜先生 司马徽 (「好，好」; 「荆州的奇才都还没长大」 — only the hero thinks of 诸葛亮; he's a child in 192 and not in 荆州 yet), 岘山老农 庞德公, 沔南名士 黄承彦 (蔡瑁's brother-in-law:
「别喝金杯里的酒」), 锦帆游侠 甘宁 (on his way to 刘表).
第一章北方出生点 冀州·中山无极·甄府（张夫人收留，初平元年正月；squares live inside the `prologue` quest itself, a second branch off `era` at x ≥ 23 so the south branch's layout is untouched): 主角以现代商业手腕帮甄府清账、平粜、练护卫，甄府转亏为盈；张夫人派主角去冀州治所邺城的分号盘账卖粮，撞见常山义士赵云千里迢迢跑到邺城州衙为家乡雪灾灾民求粮（不是在真定本地——郭图这个督粮官是袁绍派来坐镇州衙的，真定县衙管不了他），被凌辱鞭打，刺史韩馥懦弱旁观；街角醉鬼郭嘉冷眼点破世道，主角出面借甄家三千石粮救常山，赵云、郭嘉就此结识主角；张夫人押粮赈灾，带着**十多岁**的甄宓（不是 5 岁——甄宓这时是半大的少女，主角待她像亲妹妹，干净的兄妹情，没有暧昧；她长大后会对主角生出爱慕，但那是后面章节的事，这一章绝不要写）同行；太行黑山贼李大目、黄巾渠帅张白骑、妖道玄机子（对标南线胡玉 / 何仪 / 唐周）伏击劫走甄宓；主角、赵云、郭嘉三人首次合作踏平黑山寨救回甄宓、灭三凶；开仓放粮，收常山铁骑 / 太行义勇为嫡系部曲（`jz_almsgiving`，无 CG）；赵云教枪，走火入魔扎穿张夫人的狐裘（`jz_training`，主角从此改用枪，不再是南线的刀/盾；无 CG）；围炉夜话看透郭图 / 韩馥 / 公孙瓒皆非明主，决意南下会盟（`jz_night`，无 CG）；张夫人取出甄宓亡父的旧鱼鳞甲——他当年领兵护商队，死在黑山贼手里，和这章的反派是一路货——给主角穿上，又赠貂裘，然后把账本一揣，骑马跟着一起南下（甄宓年纪小留在冀州，不是留守相送；告别那场戏在 `jz_end`，没单独出 CG，就是一句台词，别又拆格去凑一张）。主角性格和南线一致：遇到没名气的角色照样 `{lord}（内心）：……三国演义我不熟啊……`，逗比吐槽不断，还总爱调戏张夫人（被她一巴掌拍回去，没有暧昧，纯斗嘴）。
**对标南线调整过的结构**（南线第一章 31 格、2 个分叉点、9 张 CG 挂字段 8 张到位；北线原来 16 格、0 分叉、11 张 CG 只到位 3 张——密度差太多）：`jz_arrive`（带 `cg: jz_wake`，不变）后面新加一格纯文字的 `jz_test`（`choose` 类型，不配 CG——choose 格的回看文案走 `text`/`prompt` 两个字段，`text` 是第一次看到的台词，`prompt` 是看完之后再回来点开显示的摘要，两个都要给，不然会掉回「选一人随你同行」那句兜底文案），张夫人问「你会算账吗」，两个回答分叉出 `jz_ledger_a`/`jz_ledger_b` 两句不同的俏皮话，再汇合回 `jz_ledger`；北线第一章现在 19 格、1 个分叉点（加上开场共用的 `era` 一共 2 个）；CG 砍回 8 张，**原则是「每个角色第一次出场都要有 CG」**（`jz_wake` 张夫人、`jz_ledger` 甄宓、`jz_county` 赵云、`jz_guojia` 郭嘉）+ 黑山寨三部曲战斗（`jz_ambush` `jz_rescue` `jz_boss`）+ 结尾 `jz_end`，后来砍掉的 `jz_crowd`（放粮）、`jz_training`（教枪）、`jz_fireside`（夜话）又补回来了：用户觉得北线第一章结尾的几段戏也值得有画面。现在结尾一路是 `jz_reunite`（团聚，两个变体格 `jz_reunite` / `jz_reunite_g` 共用一张）→ `jz_alms`（放粮）→ `jz_training`（教枪，扎穿狐裘的梗）→ `jz_fireside`（夜话）→ `jz_end`（南下），一共 5 张。同一条原则回头也发现南线漏了一个：`village`（孙策/周瑜初登场）一直没有 CG，补了 `c1_village`（未交付），所以南线也从 8 张变成 9 张挂字段。对标不要求数字完全相等，但密度（CG / 格数、分叉 / 格数）不能差太远；以后再改这两章的任何一边，顺手回来看一眼另一边有没有被落下太多。格数后来又从 19 补到 22：`jz_guojia` 和 `jz_relief` 之间加了 `jz_integrity`（张夫人送礼谢赵云，赵云原物退回，立住他「正直」的人设）；`jz_relief` 和 `jz_ambush` 之间加了 `jz_curious`（甄宓一路追问现代词汇，立住她「好奇」的人设）和 `jz_zuoci`（左慈路边一瞥，「三十岁的魂，十八岁的身——不对……你们俩……哦不，是你」，这是 `docs/STORY.md` 里早就规划好的「左慈是唯一知道双线真相的人」那条线索的北线那一半，南线 `event` 池里的 `zuoci` 事件以后要在某处也补一句呼应）。这三格最初全是普通 `event`，没碰 `treasure`/`recruit`/`mystery`——`prologue` 南北共用一个 quest，`soldier_pool`/`recruit_pool`/`event_pool` 三个池子原来都只有南线口味（丹阳兵、江东弓手……），北线squares 一碰这几个字段，黑山寨宝箱就能开出丹阳兵。后来加了 `Quests.pools(q, save)`：`recruit_pool` 走 `pool_overrides`（`{requires, unless, recruit_pool, soldier_scope, event_scope}`，`_flags_hold` 按这一轮的 `run_records`——不是 `save.flags`，这发生在本章节自己跑的时候，旗子还没在 `complete()` 时转正——挑第一条匹配的覆盖），`soldier_pool`/`event_pool` 走另一套：每个 `story.json` 里的事件都带一个 `scope`，`pools()` 把「`scope` 命中 `universal`、命中这个 quest 当前的 `event_scope`（`south`/`north`），或者 `scope` 直接就是这个 quest 自己的 id」的所有事件合并成池子——最后这条就是给只该在一个章节出现的孤例用的（`qiao`/`yuji` 的 `scope` 直接写 `"prologue"`，`shuijing`/`pangdegong`/`ganning`/`huangchengyan` 写 `"jingxiang"`，`jz_spy`/`yuxi_rumor` 写 `"yuxi"`，`zhuhou_yan`/`tangji` 写 `"taodong"`——这些角色只该撞见一次，不能被 `south` 这种大池子误共享到别的章节去）。一个新事件只要打对 `scope` 标签，所有同阵营 quest 自动都能抽到，不用每章手抄一遍几十个 id——这是「rogue 需要更 organize，config based，有的也分特定章节」那次重构加的，之前北线第一章的 override 还是手写一个 3 项的 `event_pool` 数组，现在是 `event_scope: "north"`。`prologue` 基础 `event_scope: "south"`，北方出生的 override 把它换成 `"north"`；`luoyang_n` 直接就是 `event_scope: "north"`。目前 `universal` 6 个（`zuoci` `risk` `grand_chest` `huatuo` `smith` `hj_camp`），`north` 6 个（`ln_boater` `ln_wine` `lvbu_beaten_n`——这个是固定事件不走池子——加这次新写的 `taihang_hunter` `zhen_caravan` `taihang_bear`），`south` 37 个，另外 10 个按章节 id 单独 scope（`prologue` 2、`taodong` 2、`yuxi` 2、`jingxiang` 4）。新加一格 `jz_mystery1`（`jz_relief` 和 `jz_curious` 之间）用这套机制抽？事件。**给一个事件定 `scope` 之前，把它整个 JSON（包括 `options`/`effects` 里嵌套的 `say`，不止顶层 `text`）过一遍，搜「孙策/周瑜/孙坚/孙家/吴夫人/江东」这几个词，或者 `"battle"` 字段指向 `shuizei_scout`/`yaodao` 这种南线专属场景——有就是 `south`（如果角色是一次性的，就用这个 quest 自己的 id），没有才能标 `universal`/`north`**。第一遍只查顶层 `text` 时漏掉了好几个（`washer`/`horse`/`guanlu`/`chest`/`yazhai` 的南线角色台词全都藏在 `options` 里），回头用递归扫描全文本才查全；也顺手把 `luoyang_n` 原来沿用的 `hero`（提了一句「孙家」）、`deserters`/`dice`（打的是 `shuizei_scout`）摘掉了。`soldier_pool` 同一次重构也改成了 `scope` 驱动（卡片不需要「孤例」那档，南北两档就够，部队卡没有「只能遇见一次」的顾虑）：`cards.json` 里的兵卡带 `"scope": "south"/"north"`（不写就是空字符串，`pools()` 原样透传 quest 自己那份——给还没迁移、或者本来就靠「池子留空=不限兵种，见 `save_data.gd` 的 `chest_mix`/`recruit_offer` 兜底」的章节用），quest 声明 `soldier_scope`，`pools()` 用它去 `db.cards` 里筛。`prologue`/`jingxiang` 以前各抄一遍丹阳兵/江东弓手/长沙刀兵这几张重叠的南线兵卡，现在都打了 `scope: "south"`，两边都用 `soldier_scope: "south"`；`prologue` 的北方 override 和 `luoyang_n` 同理共用 `scope: "north"`（常山铁骑/太行义勇/黑山游骑/西凉铁骑）。**改完这类"池子/scope"逻辑务必全仓库搜一遍有没有别处直接读 `q["soldier_pool"]`/`q["event_pool"]` 原始字段**——这次漏了 `battle_screen.gd` 打完仗开宝箱那一行，直接读的是原始空数组，宝箱掉落完全不限兵种了，测试跑过才抓到。
战斗三档后来也对标了南线（南线一轮能撞上的是 1-2 普通 + 1 精英 `yaodao`（唐周）+ 2 首领——水寨那关一个、`lair`（何仪）一个；北线原来只有 2 普通 + 0 精英 + 1 首领，密度明显薄）：`jz_ambush`（甄宓被掳）和 `jz_plan`（定计）之间插了一格新战斗 `jz_breakout`（断后，`boss: true`，新敌人 `zhangbaiqi`——黄巾渠帅张白骑亲自带数百悍匪堵退路，呼应 `jz_ambush` 台词里他的登场，也解释了后面 `jz_boss` 里他为什么「脸都白了」不敢上手——这仗已经输过一次）；`jz_rescue`（祭坛救人，打玄机子）补了 `"elite": true`——敌人数值没变，`heishan_tan` 本来就是按精英強度配的，只是漏了打标；`jz_boss`（黑山寨，李大目）不变，仍是真正的最终首领。现在是 1 普通（`jz_fire` 上风口）+ 1 精英（`jz_rescue`）+ 2 首领（`jz_breakout` `jz_boss`），和南线同一量级。`zhangbaiqi` 的立绘（`zhangbaiqi.jpg`）、技能（复用已有的「黄天当立」`huangtian`）都是现成的，`heishan_jie` 这个新 scenario 没单独出战斗背景，`"art": "heishan_wai"` 直接复用峡谷外围那张图（同一片峡谷，省一张图）。黑山寨打完，`jz_boss`→`jz_loot`（新加的北线专属 `treasure` 格，缴获战利品）→`jz_reunite`：这是第一个真正吃 `pool_overrides` 的宝箱格，抽的是 `heishan_bing`/`changshan_tieqi`/`taihang_yiyong`，不会开出南线的丹阳兵/江东弓手。
人物基调（后面写台词时保持）：张夫人对主角是真心疼爱、带几分精明主母的宠溺；甄宓对主角是纯粹的好奇和黏人；赵云正直勇敢，认死理但重情义；郭嘉看着无所谓、实则心里一清二楚。黑山寨那一战是三人交情的起点。**定计分叉（对标南线 `plan`）**：`jz_plan` 是 `choose`——赵云「正门强攻」（`card: zhaoyun`，记「定计：赵云正门强攻」，y0：`jz_zy_gate` 战斗 → `jz_zy_road` ？ → `jz_zy_altar` 精英祭坛）/ 郭嘉「火攻疑兵」（`card: guojia`，记「定计：郭嘉火攻疑兵」，y2：`jz_fire` 放火事件 → `jz_gj_back` 伏击 → `jz_rescue` 精英祭坛（水洞）），两边在 `jz_recover` 汇合；两个祭坛格共用 CG `jz_rescue`。第一章只入队选中的那一个；`jz_reunite`（`unless` 郭嘉那条）/ `jz_reunite_g`（`requires` 郭嘉那条）同一格位各一版：选赵云——赵云「云愿追随先生，赴汤蹈火」，郭嘉嘴硬「入伙嘛——再考察考察」；选郭嘉——郭嘉「往后我跟你混了」，赵云要先回去安顿常山乡亲。没入队的那个在 `jz_night` 里松口，第二章 `ln_cross` 发 `cards: [zhaoyun, guojia]`（剧情卡不叠加），和南线 `set_out` 补另一个兄弟一样。都是并肩拼过命之后才说得出口的话，不是一见面就纳头便拜，写后续章节时这条「过命交情」要接得上。**立绘**：`lord_north` 和南线的 `lord` 共用同一张卡（`id` 都是 `"lord"`），只是发型（束发，不是南线的寸头）和甲胄（河北风格旧甲，不是南线的青金色）不同——见上面「`id` vs `person`」的坑，改这条线的立绘逻辑前先读那条。`jz_end` 不再是独立结局，直接接进第二章 `luoyang_n`（见下一段）。开场那个「账房一问」分叉（`jz_test` → `jz_ledger_a`/`jz_ledger_b`，两个回答只换一句俏皮话，没有机制差异）后来砍掉了——没必要，直接合并进 `jz_ledger`，保留「先应下来，今晚再偷偷现学」那版（张夫人那句「别熬得太狠」是立人设的台词，比「嘴甜」那版更值）。`jz_county`（州衙，衙役举棍要打赵云）后面也补了一格真·战斗 `jz_help`（拔刀相助，新敌人 `yayi`/衙役，早期杂兵强度，参照南线 `boar`：`yayi` hp1100/at90，比 `boar` 弱一档，因为是正规军杂兵不是野兽）——原来这里纯靠 `jz_guojia` 里郭嘉一张嘴把郭图说退，现在是主角自己动手打退衙役，赵云亲眼看见才服气，`jz_guojia` 的开场台词也跟着改了（郭嘉从「冷眼看着赵云挨训」改成「看完主角打架全程」，赵云的台词从「又气又急」改成「抱拳道谢」）。`jz_relief` 后面新加了一个分叉点 `jz_route`（选路）：「官道」（`jz_road_fight` 新战斗，新敌人 `heishan_sanbing`/黑山散兵，复用 `heishan_bing` 的卡和立绘，打完接共用的 `jz_mystery1`）vs「小路」（既有的 `jz_curious` 甄宓好奇心事件，接新宝箱格 `jz_loot_path`，零战斗），两边在 `jz_zuoci` 汇合——**这是「一条多战斗、一条多 rogue」分支模式的落地**，不是像 `jz_test` 那种只换台词的伪分叉；设计原则和更多例子见 `docs/design.md`「分支设计：借鉴兰斯10 + 《杀戮尖塔》」那一节，以后加新分叉点先看那节，别重新发明轮子也别加没有实际差异的伪分叉。

第二章北线 洛阳烟云（quest `luoyang_n`，紧跟在 `taodong` 后面插入，`requires: 出生：冀州无极`；`taodong` 则是 `unless: 出生：冀州无极`——两边都不用正面声明「南方出生」，没走过 `era` 选择的旧存档/测试默认落在南线，这点很重要，别改回两边都用 `requires` 正面声明，会把"没设过出生记录"的 save 导到两条线都进不去或进错线）：车队往酸枣送粮，古道上救下逃婚的吕玲绮（精英战 `ln_lvlingqi`，`record_win` 吕玲绮：救下，营地里入队）；中山甄记大旗赞助诸侯联军，诸侯宴上对袁绍的吐槽和南线一字不差（同一个人，同一个老板）；曹操借粮是个 `choose`，两个选项各 goto 一个一行小方块再合流到 `ln_zhen`，不是靠 choose 选项直接发宝物（choose 选项只认 `label/goto/record/card`，没有 `relic`）——「借」那格改用了 squares 的 `relics` 字段直接发《孟德新书》；汴水救曹操撞上徐荣（新敌人 `xurong_n`，数值比南线 `xurong` 强，因为这里是本章中段首领，南线同期只是普通战，重用 `dagu` 的战斗图）；虎牢关前劫粮营，吕布那一战赢了接 `ln_triple`（一个固定事件 + 三个宝箱的 shuffle 组，和南线 `taodong` 的 `triple`/`box1-3` 一个模式），输了接 `ln_sanying`（三英战吕布，北线视角，复用南线 CG `c2_sanying`）；车帘后牵手；黄河边看洛阳方向天烧红、联军散伙，回冀州收尾，记「北线：班师冀州」。这章才是真正的「北线 · 敬请期待」占位结局所在地（挪到了 `ln_end`）。截图走查用 `--demo=ln2`（任意 `--at=<square id>` 跳到那一格）。曹洪、吕玲绮立绘都已到位；`ln_lvlingqi`（她的战斗 CG）、`ln_langqi`（并州狼骑战斗图）、`ln_camp`/`ln_handhold`（两张剧情 CG）还缺。

第五章北线 铁纪徐州（quest `xuzhou`，`requires: 北线：北海相`，兴平元年夏 → 兴平二年冬，`ending: menhou`）：糜芳来北海求援（曹操屠徐州）→ 点兵分两版（`军纪：严明` 有：夏侯兰拔刀插案，只带三千精兵；没有：几万人全带上）→ 首领夏侯惇殿后军（两眼还在）→ 陶谦让印，刘备秒接（「说好的三让徐州呢？」）→ 糜府夜宴（糜贞敬赵云，张夫人和糜竺谈下盐铁海运）→ 张宁施针，「太平」玉佩被陈登身边的校尉认出 → 在 x13 按 `军纪：严明` 分岔：没有就是街头乱象 → 陈登告状 → 谢恩宴 → 陶府刀斧手（打不过，`lose_goto` 和 `next` 都去结局）→ **结局六 · 失律**（张宁的金针止不住血）；有就是八十军棍 → 精英曹豹家兵 → 陈家倒向主角 → 郭嘉「给吕布搬板凳」、吕玲绮给父亲带话 → 吕布暴揍刘备、刘备投曹 → 小沛合围 → 首领吕布突围（输赢都继续，他总会跑：「逆女，下回见面，我亲手取你的头」）→ 陶谦遗表、接任徐州牧 → 张辽高顺入队 → 陈宫供进「陈先生别苑」天天写骂稿 → 过年（赵云去糜府送公文，一送一下午；赵云娶糜贞挪到了第七章剿完泰山之后——第五章太挤；第六章的门槛改为「徐州：接任徐州牧」）→ 南望淮南（未完待续）。北线 CG 用 `n5_` 前缀；`art_prompts.py` 的 `hero_note` 现在按 CG 实际用在哪条线（北线 quest / 北线事件 / 北线结局）给主角长相，不再只看 key 前缀。
第六章北线 淮南折帝旗（quest `huainan_n`，`requires: 徐州：接任徐州牧`，建安元年冬 → 二年春，`ending: duanqiao`）：讨逆诏 → 曹操回信 → 杜家酒（杜夫人：秦宜禄的遗孀，第五章小沛随并州军投降、主角交给张夫人；善酿酒，「五十二度」）→ 蕲阳桥蕤 → 东门纪灵 → 城破（吕布开北门降曹）→ 煮酒论英雄（刘备掉筷子）→ 比武招亲三场（曹操说杜夫人缺一个如意郎君，替她比武挑一个；夏侯惇 / 张飞 / 关羽，主角反驳被曹操一句「赢了的人说了算」压回去；赢了以后主角用他的规矩：「赢了的说了算——那我说，让她自己选」；关羽那场打输走 `hnn_choose_b`，同样把选择还给她；杜夫人谁也不嫁）→ 庆功宴（刘备劝杀）。分线读两条**跨章**记录：第二章「曹操：借粮 / 没借」、第五章下邳城外的选择「夏侯惇：放他回兖州 / 痛击殿后」（后者是默认，「放」锁在「结局八 · 断桥」之后）。**至少一笔人情** → 曹操叙旧（`hnn_xj_a/b/c` 三个版本）、杜夫人替主角说话、关羽按刀被喝住 → 尿遁 → 浮桥一瞥 → 盟约、杜夫人入队；**两条都是坏账** → 茅房有刀斧手 → 宫门夏侯惇 → 杜夫人酒坛火墙 → 断桥吕布活捉 → 关羽曹操当堂争杜夫人、她撞柱 → 「缢之」（白门楼倒过来）→ **结局八 · 断桥**。坏账线的格子 `requires: [曹操：没借, 夏侯惇：痛击殿后]`，好线同一个列表做 `unless`。
第七章北线 邺城惊雷（quest `yecheng`，`requires: 北线：让寿春`，建安二年夏 → 建安四年春，`ending: kujing`，CG 前缀 `n7_`，战斗 `n7_`）：泰山的税（糜贞来报账，赵云站得比站岗还直）→ 泰山岔路 → **精英泰山·臧霸**（张辽诱敌，赵云绕后断路；臧霸钻进山里跑了，留给第八章）→ 提亲（糜竺的礼单垂到地上，赵云在院子里看了一个时辰的树）→ 东海岔路（海贼劫嫁妆船）→ **子龙大婚**（CG `n7_wedding`，糜贞入队、宝物「糜家海船」，记「赵云：成婚」；夏侯兰卸铁面、陈宫骂着奢靡连干三斗、成年的甄宓低头）→ 小分叉 → 易京的围（建安三年春，袁绍还在围攻易京的公孙瓒，河北的兵全调去了幽州；郭嘉：邺城是空的；主角：北上，先去太行找张燕）→ 小分叉 → **北上之前 choose**（糜贞：邺城拿下来，糜家粮船从黎阳走白沟上漳水跟上，「糜家的船，我自己押」）：「直接北上」（默认 → 誓师，别苑里陈宫还在骂）/「去别苑拜访陈宫」（`requires: 结局十 · 枯井`，记「陈宫：入队」→ 别苑：陈宫背着河北地图出门，**陈宫入队**）→ 太行岔路 → **太行合兵**（张燕带黑山义军下山，两边为一口井差点动刀，夏侯兰按住；**张燕推举主角为盟主**（「就是看中你不开会」）；黑山的旗收起来，两家只打一面旗——张宁在那面黑白条纹的**斑马旗正中写了一个「义」字**，「不求天了，求人」；斑马旗还是那面斑马旗，从此北线全军打写着「义」字的斑马旗，南线叫他们义军；**张燕入队**，记「北线：义字旗」；第二天张宁回了北海——北海闹瘟）→ **精英滏口陉·淳于琼**（他在关楼里烤火喝酒，赵云攀崖先登，他端着酒碗跑了；不入队）→ 雷雨夜（张夫人撑着油纸伞开东门，赵云第一个冲进去；郭嘉没披蓑衣，淋了半夜雨）→ **首领邺城·审荣守军** → 邺城休整（城头竖起写着「义」字的斑马旗；郭图光脚翻墙，墙外站着赵云）→ **行辕**（府库、成年的甄宓；郭图逃跑前放火烧账房灭口，**郭嘉闻着烟味踹门，把十四五岁的账房孤女郭照背了出来**；她指出郭图的账「有三成是空的」，郭嘉说「都姓郭，连姓都不用改」，收她作**义女**，她上任第一天就没收了义父的酒葫芦，**郭女王入队**；**郭图被押进行辕，郭照把账摔在他面前，主角下令斩首，头挂在邺城城门上——无极甄府那一夜的仇报了**），按「陈宫：入队」分两版： **没拜访陈宫**（`n7_guotu`，记「邺城：先稳后打」）：郭图死了、袁绍远在幽州，主角以为河北没人了，「开仓安民，先稳后打」→ 开仓（糜贞来信：粮船十日后入漳水）→ 邺城外岔路 → 袁绍回来了（这一回他听了**沮授**的：不争城，打粮船——张郃、高览围死北门；沮授的细作在黎阳盯着糜家的船，粮船一入漳水，文丑就在渡口等着）→ **精英北门·高览** → **精英漳水渡口·颜良** → 七进七出（赵云在枯井边找到中箭的糜贞）→ **首领渡口·文丑**（打不赢，输赢都 → 枯井）→ 枯井（糜贞：「你一个人，冲得出去。……谁也别管谁。」投井；赵云背靠枯井战死，脸朝着井里）→ **结局十 · 枯井**；**拜访过陈宫**（`n7_guotu_c`，记「邺城：将计就计」）：陈宫「郭图是袁本初的狗，真正会咬人的是一个他从来不听的人——沮授」「换了老夫是沮公与，不打邺城，打你的粮船」，主角让子龙去漳水边守着 → **精英漳水夜截·沮授信使** → 仿信（截下沮授给袁绍的信：不争城，打粮船，细作已伏在黎阳；主角让糜贞的船停在黎阳；**陈宫照着郭照抱出来的账簿，仿死人郭图的笔迹写了一封密报**，说粮船改走葫芦谷——「沮授会看穿。可袁本初信郭图，不信沮授」；郭嘉：「这一手，奉孝服」）→ 漳水北岸岔路 → 葫芦谷（建安三年冬：陈宫的河北地图——上游旧堤十年没人管，一锄头就开；赵云押空粮船作饵；糜贞送来香囊『你打你的仗。我在黎阳等。』；当夜**郭嘉伤寒倒下**，郭照熬药，郭嘉不让去北海请张宁：「北海的瘟还没完……为奉孝一个人，不值。」）→ **精英漳水·张郃**（看出船吃水太浅是空船，被赵云缠住）→ **精英漳水·颜良** → 决堤（陈宫抡第一锄头，郑好滚石、姜巧泼油断后路；赵云把颜良从水里拖上来，他还去摸刀，被赵云一枪扎穿大腿，**重伤活捉**）→ **首领葫芦谷·文丑**（界桥那一场） → 苍天何薄（文丑拔刀要自刎，被赵云枪杆打落，**重伤活捉**；袁绍呕血——那封「郭图密报」进帐那夜，沮授跪劝半夜、额头都磕破了，袁绍只说「公则的字，我认得」）→ 小分叉（**精英漳水·高览**断后）→ **邺城大牢 choose**（狱卒：牢门早开了，田丰不肯出来，「袁公关的我，只有袁公能放我」）：「由他去」（默认）/「去大牢请他出来」（`requires: 结局十二 · 遗策`，记「田丰：入队」，**田丰入队**：「袁公关的丰。可袁公，已经放不了任何人了。」对郭嘉：「你这病，不能再熬夜了。往后动嘴的事，丰来。」）→ **邺城招贤馆**（招募格，`recruit_pool` 颜良、文丑：两人关在后院养伤，赵云每天送饭；文丑：「界桥那一场，算你赢了。」赵云：「没打完。等你伤好了，再打。」）→ 重回无极（建安四年春，CG `n7_wuji`：张夫人带甄宓回到被郭图抄没、空了九年的甄府，账房的算盘还响；郭照带邺城账房的人来帮忙，黑山兄弟扛木头下山，夏侯兰砌院墙；府库的粮一半开粥棚、一半借给佃户当种子；新匾「甄家粮行」，门口插一面小小的义字斑马旗；甄宓：「哥哥。……家回来了。」）→ 黎阳的船（记「北线：夺邺城」；糜贞的船靠岸，「瘦了」；袁绍没熬过正月，倒在北归的车上；**陈宫劝降张郃**「老夫当年也觉得吕奉先待我不薄……别学老夫」，张郃、高览来降；被袁绍丢在漳水边的**沮授**：「授想看看，一个肯听话的主公，是什么样子。」；**田豫带易京剩下的三百白马义从来投**——袁绍回师前最后攻破易京，公孙瓒杀妻儿自焚，临死说「剩下的兄弟，去找北海那个人」，田豫：「白马义从，义字当头。这面旗，我们认。」；**张郃、高览、沮授、田豫、白马义从入队**；袁绍是气死的，**袁家分裂**：审配扶着袁尚退到袁熙的幽州，郭图死后只剩辛评、辛毗兄弟帮袁谭守青州平原，两边都说自己是袁家的主人（本章只到这里；第八章才打袁谭等人，他们打输了才逃命）；郭嘉：「河北四庭柱，两根降了，两根还在招贤馆里骂人。……邺城拿下来了，河北还没有」；陈宫的骂稿只写了一行「子龙其人，一身是胆。老夫无话可骂」，未完待续）。**每个红颜都要有自己的 Bad End，赵云、郭嘉也要有**（用户定）：第七章是赵云、糜贞（结局十 · 枯井）；第八章是郭嘉和他的义女郭女王（**郭嘉没有红颜，只有义女**；郭女王第七章邺城被郭嘉救出、认作义父）。北伐袁绍是赵云的高光章；正线（拜访过陈宫）也给陈宫高光。

第八章北线 北海龙虎（quest `longhu`，`requires: 北线：夺邺城`，建安四年夏 → 建安五年夏，`ending: yice`，CG 前缀 `n8_`，战斗 `n8_`）：袁家两头（建安四年夏：袁谭、袁尚的使者在邺城门口撞上，都想借主角的刀砍对方；郭嘉的伤寒从冬天拖到夏天）→ **议事**，按「田丰：入队」分两版：没田丰 = **郭嘉献策「分而破之」**（「袁谭、袁尚，急之则相救，缓之则相争」），为这一策熬了三夜，帕子上咳出了血；有田丰 = 郭嘉还没开口，**田丰先站起来献同一策**，郭嘉大笑「这是奉孝熬了两夜还没写完的那一卷」，把帛扔进火盆，「那奉孝，今夜睡觉」→ 青州岔路 → **精英平原城下·先登营**（城头上辛评、辛毗兄弟）→ **首领平原·袁谭** → 南皮（袁谭败走，**辛评、辛毗扶着他逃进了渤海南皮，关了城门**，青州回来了）→ 幽州岔路 → **精英渔阳·乌桓突骑**（袁尚雇的；田豫和三百白马义从：「乌桓人见了白马就跑」）→ **首领蓟城·审配** → 中山（**审配扶着袁尚、护着袁熙往南杀出去，钻进了中山卢奴城**——无极就在中山；袁家兄弟一个占南皮，一个占中山）→ 河北初定（建安四年冬，**曹操派满宠捧诏书来劝降**（满伯宁，做许县县令时连曹家亲戚都敢打板子）：「印绶交出，封列侯」；主角不交，满宠才把这三个月的事一件一件说出来：**曹操烧了寿春盟书，夏侯惇打下下邳，徐州丢了；吕布、臧霸领兵三万往北海去**；郭嘉：「先拿人家的家，再请人家去做客」，回绝了给他留的位子；满宠临走：「吕奉先的马，比你们的快」；河北不能空，总得有人留下）→ **谁留下**，按「田丰：入队」分两线： **没请田丰**（`n8_liushou`，记「北线：郭嘉留守」）：郭嘉「奉孝留下。主公，顾大局」，郭照背起药箱跟着留下，「主公，北海见」→ 南下（郭嘉三天一封信，第五封字开始歪了）→ 泰山 / 青州岔路 → 幽州来信（**郭嘉伤寒入肺，腊月初七殁于蓟城；郭照侍疾染疫，腊月十二也去了**；信里夹着郭嘉临终那封『主公亲启』，主角攥着没拆）→ **首领城东林·程昱伏兵**（打不赢，输赢都 → 流矢；林上一只鸟都不落，主角没看见）→ 流矢（主角中流矢落马，信散在雪里：『程昱必伏于城东十里林中……主公绕道西门』）→ **结局十二 · 遗策**；**请过田丰**（`n8_liushou_t`，记「北线：郭嘉随军」）：郭嘉本想自己留下，可看田丰理幽州的账、沮授收袁家旧部，觉得两人可用：**田丰、沮授、张辽、张燕留在北方**，郭嘉跟主公回去打曹操——「跟曹孟德下棋，奉孝得坐在棋盘边上」；田丰：「替丰看看，曹孟德输的时候是什么脸色」→ 随军南下（郭照守着药炉）→ 泰山 / 青州岔路 → 识破（**郭嘉病中撑起身子：林上一只鸟都不落，程昱设伏，领兵的是夏侯惇**；子龙抄后，大军走西门）→ **精英城东林·夏侯惇** → 进城（记「北线：郭嘉不死」；张宁：「伤寒入了肺，再晚三天我也救不回来……从今天起，他归我管」；留守的北海长史孔融：「这三个月给洛阳写了十七封奏章，封封骂曹孟德……写给天下人看的」；**糜竺带着徐州的士绅、工匠、商户都搬到了北海，糜竺入队**；陈登提着两坛酒也来了，「下邳那八十军棍，元龙记着」，**陈登入队**）→ 北海城外岔路（并州狼骑、魏军霹雳车营）→ **首领北海城下·吕布**（打不赢不算输）→ 赵云战吕布（三百合，戟削盔缨、枪裂马甲，糜贞换轻甲擂鼓；「天下接得住我三百戟的，你是第二个」）→ **精英北海西门·臧霸**（太史慈：「泰山那一回你跑了。今天，你跑不了」）→ 吕布退军（**太史慈斩臧霸**，吕布收兵西去，记「北线：北海守住」）→ 黄河岔路（魏军虎豹骑、西凉游骑）→ 西凉马家（建安五年夏，**平原对岸的仓亭津**——黄河上离青州最近的大渡口，北岸平原是义军，南岸是曹操的兖州；郭嘉交代来历——**曹操拿下洛阳后，借天子诏书召马腾入朝为卫尉，马腾带着一家老小进了许都，就此被软禁**；曹操撕盟后北边缺兵，**又命马超带西凉军东出守黄河、讨北海「反贼」——「马超不来，他爹就回不了家」**；营东还扎着克扣草料、说马超是「花架子」的吕布；**马云騄单骑过河点名要跟主角单挑**，主角：「单挑可以。项目我选。……比吃。」）→ **精英黄河·马云騄**（「比吃是晚上的事，先比枪」，赵云挡在前面）→ **首领黄河·马超** → 黄河两岸（河滩烤全羊，**主角和马云騄比吃**，第二只羊吃到一半她腰带松了一扣；**吕玲绮听说主公在跟西凉女将单挑，提着画戟赶来救场，看见两人满嘴是油，揪着主角的耳朵拖走了**——「回、去。」马云騄：「北海的人，都这么有意思吗？」郭嘉对马超：「你守南岸，我们守北岸」，记「北线：西凉默契」；**义军和魏军隔着黄河对峙**；当夜**郭嘉把藏在车底下的最后一个酒葫芦交给郭照：「不喝了」——病好以后戒了酒**）→ **陈登献计 choose**（给马腾写信、故意让曹营截到，「不费一兵一卒，白得一支西凉铁骑」）：「就这么办」（默认，记「北线：反间马腾」）/「不行，这会害了马家」（`requires: 结局十四 · 断弦`，记「北线：不害马家」；陈登：「元龙只算了得，没算失」），未完待续）。本章两线看第七章的「田丰：入队」（邺城大牢 choose，`requires: 结局十二 · 遗策`）。

第九章北线 西凉喋血（quest `xiliang`，`requires: 北线：西凉默契`，建安六年春 → 冬，`ending: duanxian`，CG 前缀 `n9_`，战斗 `n9_`）：两颗钉子（建安六年春：张夫人来信，审配的兵到了无极要甄家粮行的粮，甄宓：「哥哥，娘不肯走」）→ 中山岔路 → **精英无极·审配**（张夫人拿着插了箭的算盘守门楼：「甄家的粮，一半借给了佃户，一半熬了粥」）→ 卢奴（城破，**审配扶着袁尚、护着袁熙出卢龙塞投了乌桓**；甄宓：「哥哥……你又来了」）→ 渤海岔路 → **首领南皮·袁谭** → 渡海（**辛评、辛毗扶着袁谭上了辽东公孙度的船**；河北平了）→ 仓亭津（建安六年夏：马腾被曹操扣在许都做人质，马超、马云騄带西凉军守仓亭津，荀彧监军，吕布的狼骑扎在营东、克扣草料、当众说马超是「花架子」），按第八章的选择分两线： **用了反间计**（`n9_yanjin_f`，`requires: 北线：反间马腾`）：马腾被扣在许都，陈登的信往许都送了三封，回信从马超营里转来、盖着马家的印：「七月十五，夜，仓亭下游浅滩，请使君接应」（郭嘉：「一个被扣在许都的人，写信的时候手不抖？」）→ 黄河北岸岔路 → 七月十五（浅滩上等着的是**夏侯惇的重兵**：「马寿成一个月前就在许都伏法了，许仲康亲手砍的。你收到的回信，是荀令君写的」；**吕布趁机冲进马营**：「马孟起，我早看你不顺眼了！」）→ **精英仓亭津·吕布** → 救人（烧塌的帐篷边找到中箭的马云騄：「我爹在许都，回不来了，对不对？」）→ **首领渡口·夏侯惇**（打不赢，输赢都 → 断弦）→ 断弦（她射完了箭又拿主角的，第十一箭弓弦断了：「下回比吃，你让我一只羊」；两人一起死在芦苇荡里；主角：「我还在跟一个死人约日子」）→ **结局十四 · 断弦**；**没用反间计**（`n9_yanjin_p`，`requires: 北线：不害马家`）：**马超给许都的父亲写信，说北边那支义军还算仁义**——「比吃输了也不赖账」；**马腾先派庞德出了许都**，庞德见过马超，又游过黄河来见主角：马腾自己想法子脱身；**约好马腾一逃到仓亭马营，营里就点三道烽火，请使君过河接应** → 黄河北岸岔路 → 三道烽火（**马腾没逃出许都**：想从水门溜走被虎卫撞见，事情败露，**许褚把许都马家两百多口屠了满门**；**吕布收到「马腾叛逃」的军报，带狼骑来绞杀马营**；**马岱从许都跑死两匹马回营报信：马腾已经被杀，吕布也要来了——约好的是父亲到了才点烽火，父亲回不来了，马云騄立马爬上烽火台点燃三道烽火**，**庞德一看到就拔刀往河边跑**）→ **精英马营西门·并州狼骑**（西门守兵认得庞德，把门推到了底）→ 烽火台（**庞德杀到台下接住跳下来的马云騄**，马岱抱住要找吕布拼命的马超）→ **首领仓亭渡口·吕布**（「你不是锦马超吗？我早看你不顺眼了」；太史慈十三箭连珠、双戟格偏画戟，赵云杀到；打不赢不算输）→ 誓（马超：「许褚，曹操。许都马家两百多口……此生不报此仇，誓不为人」；**马超、马云騄、马岱、庞德入队**，记「北线：西凉归附」；吕玲绮远远看着，转身走了）→ 先北后南（**马超披麻要借三万兵直下许都报仇，郭嘉不同意**：「乌桓在北，辽东在东……我们一南下，他们就从背后扑过来。先把北方平了，许褚的头，奉孝替你留着」；主角：「一年。文远去打乌桓，孟起去打辽东。」）→ **乌桓（张辽）**：塞外岔路（乌桓突骑、乌桓骑射）→ 出卢龙塞（田豫带白马义从走五百里干河道）→ **精英柳城·乌桓峭王** → **首领白狼山·蹋顿** → 白狼山顶（张辽斩蹋顿；审配打到最后一个人；袁尚、袁熙逃去辽东）→ **辽东（马超）**：辽东岔路（辽东步卒、高句丽弓手）→ 辽水（**公孙康拿三车金子换了高句丽一万援兵**，许高句丽两个县；马超：「为了挡我，连地都肯割」）→ **精英辽水·高句丽援军**（西凉铁骑踏冰冲锋，庞德从上游烧营）→ **首领襄平·公孙康** → 辽东的匣子（公孙康捧着袁家三兄弟的首级跪在马前，马超不接：「我要的头，在许都」；辛评殉主、辛毗下落不明；记「北线：北方一统」；马超：「一年，到了。」郭嘉把地图摊开，手指点在南边，未完待续）。两线看第八章结尾陈登献计 choose 的记录（「北线：反间马腾」/「北线：不害马家」）。
第七章南线 江东小霸王（quest `jiangdong`，`requires: 庐江：喜期将近`，建安二年夏 → 建安四年春，`ending: pifu`）：庐江双婚（`jd_wedding`，CG `c9_wedding`）→ 东取江东（孙策晕船）→ 牛渚 → 精英神亭岭刘繇军（十三骑、太史慈彩蛋）→ 太湖两伙水匪 → 吴郡夜宴（严白虎 + 吴郡太守许贡）→ **甘宁夜访**分岔（`jd_ganning`）：「联手严白虎剿水匪」（默认）→ 太湖蒋钦 → 精英太湖周泰 → 首领太湖甘宁 → 严白虎烧锦帆贼家小 → 丹徒山打猎，许贡三个门客伏击（首领，打不赢）→ **结局九 · 匹夫**（孙策中箭，主角护着他一起死；甘宁不参与刺杀）；「收服义匪甘宁」（`requires: 结局九 · 匹夫`）→ 三场比试（蒋钦 → 精英周泰 → 精英甘宁，点到为止，`lose_goto` 下一格，输了也继续）→ 甘宁、周泰、蒋钦入队 → 精英水寨前严舆（孙策掷戟）→ 首领太湖水寨严白虎（两线首领对调）→ 精英丹徒山许贡门客（铃铛撞偏冷箭）→ 周泰身中数刀护主，许贡严白虎伏诛 → 会稽城门虞翻 → 首领会稽王朗（讲了一个时辰的书，虞翻、张昭入队）→ 小霸王（新卡 `sunce_bawang`「孙策 · 小霸王」SSR，person 仍是 sunce）→ 富春还乡（孙权、孙尚香入队，记「南线：江东平定」）。**甘宁改到第七章才入队**：第五章「锦帆游侠」事件里他不跟走，第五、六章招贤馆没有他；坏线首领甘宁掉锦帆贼兵卡，不掉甘宁本人。
第八章南线 猛虎之陨（quest `menghu`，`requires: 南线：江东平定`，建安四年冬 → 建安五年，`ending: quwu`，CG 前缀 `c11_`）：孙权、孙尚香在 `m8_start` 入队（第七章 `jd_fuchun` 只见面）→ 辕门比刀 → 丹阳山越抢粮 → 曲阿（诸葛瑾只能在第六章 `hn_lusu` 选择格「请子瑜同行」入队，该选项 `requires: 结局十一 · 曲误`，记「诸葛瑾：入队」；第七章江边 `jd_end` / `jd_end_j` 按它分两版；这里 `m8_chaimen` 柴门锁着 / `requires: 诸葛瑾：入队` 时 `m8_jin` 连夜拦下他去荆州）→ **讨伐山越**（`m8_shankou` 山口 → 竹林 / 山寨岔路 → `m8_liniang` 黎娘拦路，说出祖郎收了北方人的铜印 → 首领 `m8_zulang` 祖郎砍裂孙策马鞍 → `m8_shanmeng` 孙策松绑、孙权谈互市编户，祖郎、黎娘入队，记「丹阳：山越归附」；新兵卡山越刀客 `shanyue_daoke`）→ 洛阳凶讯（亲兵在山里找到主角，铜印原来是曹操拖住孙家的手段）→ 灯下磨刀 → 汉水（第一次见赤底「汉」字旗，CG `c11_hanqi`）→ 精英南阳道先锋廖化 → 南阳道岔路 → 首领渡口刘备（雨中边哭边追孙坚，CG `c11_liubei`）→ 猛虎托孤（孙坚中一箭伤重不治，固定悲剧，记「孙坚战死」）→ 雨夜船尾（记「易帜为吴」）→ 吴景讲洛阳一夜（曹操托玺）→ 程普、韩当讲南阳城头（诸葛亮；有诸葛瑾时 `m8_nanyang_j` 多两句）→ 襄阳 → 精英汉水北岸关平（刘备军第一战）→ 新野岔路（上路尽头精英陈到·白毦兵）→ 精英博望坡张飞 → 曲有误 → 白河：坏线 `unless: [结局十一 · 曲误, 诸葛瑾：入队]` 首领诸葛亮打不赢 → **结局十一 · 曲误**；好线 `requires` 同一列表：先火后水 → 首领诸葛亮 → 兄弟隔河（记「白河：周瑜生还」）→ 首领八阵关羽（必败，`lose_goto` 下一格）→ 周泰背出（记「汉水相持」）→ 汉水疗创（未完待续）。**第八章南线的对手只有刘备·诸葛亮集团（汉军）**——刘备是献帝认的「皇叔」，嫉妒献帝偏爱主角；曹操封他镇南将军、领荆州牧，他收印不打曹旗，只打赤底「汉」字旗（洛阳一夜、南阳城头、渡口三处交代，`m8_xiangyang` 献帝竹简「朕在等鱼」）；张飞在博望坡替刘备向孙尚香逼婚（孙刘联姻，`m8_bowang`，好线 `m8_end` 有回应，后续章节接着写）；关羽只是看主角这张脸不痛快（`m8_bazhen`，一句，不展开）；曹操只在洛阳一夜的回忆里出场，曹仁、夏侯惇是北线的敌将（他们的旧战斗图 `m8_caoren` / `m8_xiahoudun` 留着给北线）。汉军分四支，每支有副将和自己的兵：中军刘备（陈到、糜芳；白毦兵、木牛流马营）、军师诸葛亮（简雍、卧龙门生；连弩兵、卧龙门生）、关羽（关平、周仓；虎步军）、张飞（廖化先锋、王平；虎骑、无当飞军）；以后各章的刘备军照这张表排。本章专属 ？ 事件「汉军告示」（scope = menghu）。本章新兵卡：山越刀客 / 吴军弩手 / 避乱书生 / 吴军参军（南线策士、弓兵最少，枪、骑够多了，别再加）。
第九章南线 天府之国（quest `tianfu`，`requires: 汉水相持`，建安六年春 → 夏，`ending: xiangjin`，CG 前缀 `c12_`）：周瑜、孙策留守汉水（只在剧情里）→ 汉军夜袭（有陆逊时 `t9_yexi_lx` 是他的首秀）→ 三峡、夔门铁索 → 江州：黄忠和严颜对射一下午谁也没射中，城破后黄忠亲手给严颜解绑（「咱俩加起来一百三十岁了」），严颜入队，此后两个老将一路比箭（严颜知道黄叙陷在南阳，故意输半箭）→ 雒城：孙尚香冲阵挑翻张任（像她哥），张任入队、刘璋出降 → 成都：**吴苋是红颜**（像周瑜：精、会算、记账、嘴不饶人；**孙尚香像孙策**：莽、要强、冲在最前），对账、都江堰，两人谁也不让谁 → 南中：雄黄汤、**祝融不是红颜**（敬勇士，战友）→ 一擒孟获 → 盘蛇谷：**火攻是主角的馊主意**（「藤甲怕火，电视里演过」，只记得烧、不记得风），孙尚香抢着诱敌（「这回别让我」）→ 没有「陆逊：入队」：子时风转 → **结局十三 · 香烬**（「……这回，你没让我。」）；有：陆逊看风（「先烧东口，西口留给孙姑娘出来」）→ 七擒孟获（「南人不复反矣」——主角：这原来是我的台词）→ 藤甲营成军（主角的南蛮兵叫藤甲营，无当飞军是汉军的）→ 成都的夜（未完待续）。陆逊在第六章庐江 `hn_luxun` 选择格「让他跟着周瑜学」入队（`requires: 结局十三 · 香烬`），第九章由周瑜派来随军。雒城之后的成都酒肆遇见法正（`t9_fazheng` choose：一张关中图，一份「得罪过我的人」的名单）。默认「图收下，单子还给他」→ `t9_fazheng_go`，两人话不投机，法正不入队（记「法正：不和」）；「图和单子都收下，请他同行」`requires: 结局十五 · 算尽` → `t9_fazheng_take`，入队。新兵卡：东州兵 / 南蛮刀手 / 南中象兵。
第十章南线 奇袭关中（quest `guanzhong`，`requires: 南线：益州与南中`，建安七年春，`ending: suanjin`，CG 前缀 `c13_`，战斗 `m10_`）：周瑜孙策留守汉水不出场；**曹操不在长安**（他在官渡和北线的北海军打仗），长安是李傕、郭汜的西凉兵 + 曹纯的几百虎豹骑。**法正可能没来，所以军议之前全章都不许写他**（测试守着 x < 15 的格子）。汉中：精英阳平关外杨昂 → 贾诩断水 → 首领阳平关张卫（不降战死）→ 张鲁、阎圃出降入队（济世堂；杨松收长安金子被赶走）→ 汉中星夜（吴苋借笔、孙尚香烤红薯）→ 精英定军山夏侯渊（和黄忠隔谷对射中箭身亡——所以北线不能再用他）→ **南郑军议**（同一格位两版）：没有法正 `g10_junyi`（event，满堂叫好，直接记「关中：子午谷」）；有法正 `g10_junyi_f`（choose，他站出来反对，两个选项都开着，从这里起法正大放异彩）。走子午谷（魏延献计，主角「听过、觉得特别有道理」）→ 斥候跑了一个、栈道被烧、粮车全在栈道上 → 首领子午谷口李傕郭汜（`lose_goto`）→ **结局十五 · 算尽**（吴苋的最后一页账）；「听孝直的：兵分两路」（只在 `g10_junyi_f`）→ 魏延、张任走子午谷当疑兵（没走通），主力走陈仓 → 精英陈仓胡轸（放走后渭水惊马落水）→ 曹纯以为两路夹击东撤 → 精英长安西门郭汜（被部将伍习砍头）→ 徐荣开内城门入队 → 首领未央宫李傕（董白的旧账，主角了结）→ 尚书台（李儒饮鸩，贾诩送他；荀攸捡回『朕记住了』的地图）→ 精英潼关张绣（入队，张济回武威种地）→ 诸葛亮北上：荀攸声东击西 → 精英峣关王平 → 陆逊火烧蓝田连营 → 首领蓝田诸葛亮 → 贾诩「追，输了再追」→ 长安的夜（记「南线：攻取长安」，未完待续）。原大纲的洛水八阵挪到第十一章。年龄别搞错：郝昭、夏侯楙在 202 年都还太年轻，不要用。孙尚香 / 吴苋的戏要多（两人较劲又互相照顾，「羊肉粥一碗，二人合请」）。
第十一章南线 洛阳天倾（quest `luoyang_s`，`requires: 南线：攻取长安`，建安七年秋 → 冬，没有本章结局（结局十七 · 虎噬在第十二章），CG 前缀 `c14_`，战斗 `m11_`）：曹操官渡败给北线（北线的军队一律叫**义军**、打「义」字旗），退守洛阳和刘备合兵；典韦、许褚、地推食堂留给北线。东出洛阳（曹操官渡败给北海军——北海军打「义」字旗，又叫义军——退守洛阳，和刘备合兵；周瑜孙策从南阳北上）→ 弘农岔路 → **精英函谷关陈到**（说守三天就守三天）→ 南边的军报（周瑜水淹南阳，孙策单骑冲阵，刘关张弃城北走）→ 渑池小分叉 → 会师（孙策、周瑜）→ 洛阳城下（城西曹营、城东刘营、城前八阵、宫城上的「吕」字旗）→ **七天，一扇门都没破**：西郊岔路（魏军青州老兵、霹雳车营）→ **首领洛阳八阵·诸葛亮**（第一天：陆逊陷阵，甘宁身中七箭背他出来，周瑜看破阵眼）→ 城外休整 → 城东岔路 → **精英营前木桥·张飞**（第二天：孙策对张飞，`lose_goto` 输赢都是平手，两人掉进护城河，张飞把不会水的孙策拖上岸）→ 小分叉 → **精英城东南·关羽**（第三天，`lose_goto`：黄忠一箭射落盔缨；严颜替黄忠挡刀重伤；关平替父挡箭战死，关羽抱着儿子刀还横着）→ 曹营岔路（魏军虎豹骑、虎卫军）→ **精英曹营·曹仁**（第四天：魏延张绣三冲八门金锁）→ 三条计（第五天：贾诩断粮、法正离间，都被诸葛亮拆了；荀攸射进城的信射回来『朕还在等』）→ 小分叉 → **首领阵前·刘备**（第六天：孙尚香当面回绝亲事，刘备亲自冲阵）→ 第六夜（刘备进了城）→ 小分叉 → 第七夜（休整；孙尚香、吴苋）→ **同一夜**：曹营的灯（诸葛亮袖中连弩刺杀曹操，曹营大乱）→ 小分叉 → 御林军（刘备入宫，把老宦官、禁卒编成御林军；陛下：「朕在等他」）→ 上东门岔路（白毦兵死士守门）→ 护驾（三更吕布开宫城北门，刘备堵在殿门口护驾战死，陛下也没能活下来）→ **辕门 choose**（吕布带着刘备的头盔和传国玉玺来降）： 「收下吕布，进城」（默认）：**南宫·汉军御林残兵** → 南宫（吕布入队；刘备的断剑掰不开；竹简上多了一行『鱼到了没有？』；关张从北门走了）→ 荀彧（来降，**荀彧入队**，求主角出城击退北边的义军；荀攸出面说服：「陛下不在了，路还在」）→ 邙山岔路（义军常山铁骑、**精英张辽**）→ 合兵（邙山北坡和曹军残兵合兵，**夏侯惇、曹仁入队**）→ **精英黄河岸·太史慈**（孙策：「我总觉得欠他一架」）→ 孟津小分叉 → **首领孟津渡·赵云** → 河对岸（义军退回河北；北线主公不信诸葛亮，收了羽扇把人扣在帐里，没杀；吕布每夜磨戟，记「南线：入主洛阳」，未完待续——结局十七 · 虎噬在第十二章）；「斩吕布，别让他进营门」（`requires: 结局十七 · 虎噬`）：**首领洛水滩·吕布**（`lose_goto`，吕布战都这样）→ 洛水 choose（吕布：「北边那个，也是你。」张飞杀回来，城门又关上了）：  - 「围城，先看看」：上东门岔路（**精英城头卧龙门生**）→ 箭楼（义军过河，诸葛亮带北线主公、赵云进城，两个主角隔着城墙揉太阳穴）→ 伊阙小分叉（义军追兵）→ 投奔（**夏侯惇、曹仁、荀彧入队**）→ 退守南阳（记「南线：退守南阳」，未完待续）。   - 「不惜代价，强攻入城」（`requires: [南线结局 · 赤壁, 北线结局 · 官渡]`，真真结局的前置）：强攻（记「洛阳：强攻入城」），本章直接结束，进下一章。 两条线都不是 badend；只有收吕布那条在第十二章变成虎噬。义军的兵（常山铁骑、并州弩手）掉北线兵卡。
**北线接着做第八章以后之前**：先看 `docs/STORY.md` 北线各章下的「🔗 南线已定，北线实装时要接上」注释（曹操怎么死、玉玺在谁手里、夏侯渊已死、义军的路线、谁投了南线……），南线实装的剧情为准；南线再改到北线也要碰的事实，就在那里加一条。
**Long-range story direction**: `docs/STORY.md` (南北双线 through 第十二章; 第十一章洛阳 is the fork: each line has one trap choice — south 收吕布 → 结局十七 虎噬, north 信诸葛亮、交出帅印 → he poisons the hero that night and stages it as a drunken fall from the wall; the south just wins at 赤壁 (no body, no note — only an old guard muttering 「只有军师进过帐」) → 结局十八 烛灭; done right, the ending depends on the *other* line's record in the save: 南线结局 赤壁 / 北线结局 官渡, or both right → 第十二章 天命归一). It is a direction only — the game is built one chapter at a time,
the implemented chapter (`story.json`) wins, and the outline is synced afterwards. Don't build unbuilt chapters from it or change the game to match it unless asked.

## Story text rules (新写的剧情都要照这几条；`tests/test_story_text.gd` 会拦)

1. **旁白和对话分行。** 一行只写一件事：要么是旁白，要么是一句话。`她叹了口气：「走吧。」` 要拆成两行：旁白 `她叹了口气。` + 对话 `@zhangfuren 「走吧。」`。「名字：」「{lord}（内心）：」这种前缀可以留在对话行里；一行里不能有两句 `「…」`，也不能在引号后面再接旁白。
2. **每句有头像的对话都标说话人**：行首 `@<portrait key> `（key 是 `portraits.json` 里的人物 key，主角用 `@lord`，北线主角的脸由代码换）。标签不显示。主角的内心独白 `{lord}（内心）：…` 也标 `@lord`。
3. **没有头像的人**（路人、士兵、乡勇）：不标，或标 `@_ `。`@_ ` = 这一行不显示头像，旁白读起来像有人在说话时也用它（比如旁白里带了带标点的引号、或带「：」）。旁白不要写成 `X：…`，也别在旁白里放有标点的「…」引号，否则会被认成有人说话而显示头像。
4. **北线的称呼**：同伴（赵云、郭嘉、张辽、庞德、太史慈、马超、张宁、吕玲绮、郭照……）叫主角「大哥」，不叫「主公」「头儿」「先生」。别家的主公（曹操、袁绍、吕布、刘备）照常叫主公，说书人讲故事也可以。南线孙策等本来就叫大哥。UI 里的「主公」（主公卡、主公部队）指玩家这个角色，不是称呼，不改。
5. 每个有名有姓的人物首次出场，主角心里写「认出来 / 没听过」一句；见 Writing rules 下面几条。

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
  司徒府 哨卡/府兵; **汉军 (刘备·诸葛亮)**: one 高级兵 per troop type, each a famous name — 虎骑 `han_tuqi` / 白毦兵 `baier` / 连弩兵 `liannu` / 虎步军 `han_bazhen` /
  无当飞军 `wudang_feijun` / 卧龙门生 `han_shuzuo` / 木牛流马营 `han_yigong` (cards `"veteran": true, "faction": "han"`: face numbers in
  `gacha.veteran_soldier_band` 125~149, the R band). One look for all (赤红战袍、玄黑札甲、铁盔赤缨, a red 「汉」 banner — never 「刘」).
  Every soldier fight on 刘备's side, from 第八章 to the final battle, uses these and only these; `faction` keeps them out of every
  public chest (`chest_pools`, `soldier_cards`), so they come only as a 汉军 enemy's or a 刘备 general's `card` (a test guards it).
  Battle art is one picture per type, the first scenario's (`m8_han_tuqi`, `m8_han_bazhen`); later chapters point `"art"` at it. A later chapter reuses the type with stronger hp/at (its own enemy id, same name / portrait / moves), and its
  scenario shares the type's battle CG via `"art": "<scenario>"`.
  **魏军 (曹操)** is built the same way (`"faction": "wei"`, same face numbers as the 汉军 card of the same troop, hp + at = 130; one look:
  玄黑札甲、深蓝战袍、铁盔黑缨, a black 「魏」 banner): 虎豹骑 `wei_hubao` / 青州老兵 `wei_qingzhou` / 霹雳车营 `wei_pili` / 虎卫军 `wei_huwei` /
  校事府密探 `wei_xiaoshi` / 屯田兵 `wei_tuntian` / 摸金校尉 `wei_mojin`. Fights under a 曹将 use these; enemies that drop one are named
  「魏军…」 or are a 曹将's portrait (a test guards it). 第十章 fields 摸金校尉、青州老兵、虎豹骑; the other four are for later 曹军 chapters.
- **CGs have few people** (technical limit): at most four named characters in focus per story CG / event picture; unnamed
  background people (soldiers, crowds) are fine. A scene that needs many people (a row of generals, a banquet of lords) gets no CG; the text carries it.
- **CG prompt negative rule**: Never include phrases like 「预留柔和暗部供对白字幕展示」「便于字幕展示」「字幕黑条」 or any mention of 字幕 in art prompts — image generation models will hallucinate fake black subtitle bars or text artifacts! Always describe natural in-world ground (平整雪地、青石地面、硬质泥路). For battle CGs, use the established template with 「下方 35% 留白为开阔坚硬平整的[地貌]供我方出战卡牌陈列」.
- **Looks match the art.** Settled by delivered art: 董白 has a silver-white high ponytail and purple fur-trimmed armor (her 女骑 wear purple too);
  鲍三娘 wears red armor over a green skirt; 刘备 fights with twin swords. A character's appearance in the text must match their portrait — or, before the art exists,
  the brief in `CARD-DESIGN.md` §7. When you write a new character's look, add/adjust their brief there; when new art
  arrives that differs, change the text (左慈: 「独眼瘸腿」 became 白发、竹杖、冒紫烟的葫芦 to match his portrait).
- **Names.** A card name `A·B` shows **A on the name plate** and **B as the small tag** at the top of the card
  (`孙策·青年`). So the real name goes first, the nickname / version second: `胡玉·浪里蛟`, `唐周·妖道` — never
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

第六、七章补充：第六章江亭回程先打「江亭外 · 袁军溃兵」，再到「辎重车前的少年」（`hn_lvmeng` choose，两个结果格 `hn_lvmeng_take` / `hn_lvmeng_go`，后者记「吕蒙：放走」）遇吕蒙护车，一周目放他自去，达成「结局九 · 匹夫」后二周目可招入队拿 `lvmeng_qingnian`（吕蒙·青年 R，`person: lvmeng`，记「吕蒙：入队」）；第七章秣陵整军（`lm_join` 需吕蒙入队，周瑜逼其读书；无吕蒙走 `lm_rest`），甘宁夜访（无吕蒙走 `jd_ganning` 空口无凭锁死联手严白虎走向结局九；有吕蒙走 `jd_ganning_lm` 认出恩人甘宁并揭发严白虎许贡黑幕，开启收服甘宁走向好线）；二周目又放走吕蒙就只能再走一遍坏线，不做补救（用户：玩家很清楚要带吕蒙）；原 `lvmeng`（SR、白衣渡江）留给以后成年的吕蒙；章末「小霸王」（`jd_rest`）孙策拿 `sunce_bawang`、周瑜拿 `zhouyu_chibi`（赤壁）；吕蒙两张、周瑜·赤壁都是 `pool: false`，只走剧情，不进抽卡池。

卡牌张数规则：任何一次获得（抽卡、宝箱、剧情给）都只 +1 张；新周目再拿到以前通关过的卡，是「永久记录的张数 + 1」，即便已是银卡也只 +1，不会直接升一阶；只有点化（战功或事件）一次 +3 张（`gacha.upgrade_copies`）。通关结算 `commit_history` 对永久张数取最大值，不相加。

埋伏：普通战斗（非首领、非精英）每局开章时按 `battle.ambush_chance`（0.5）随机抽一半成为埋伏，结果存 `save.ambushes`（随局保存、每局不同）；格子上写死的 `ambush: true` 仍然生效（如第二章「李儒伏兵」）。

敌人强度系统（`cards.json` → `battle.scaling` / `battle.enemy_coef`，代码 `Quests.target_power` / `_scale_for` / `enemy_scale`）：强度 = 血量×攻击×行动数，**一条曲线**：第 N 章（`order` 里的序号，从 0 起，南北线同序）普通战斗的目标强度 = `strength × base × (N + offset)^exponent`（现在 base 1.6 / exponent 1.5 / offset 0.6）。强度是血×攻，血和攻各自按它的平方根走；我方队伍也在成长，所以难度（敌我之比）是前期陡、后期平；offset < 1 让序章明显更容易、第二章起涨得更陡；exponent 0.5 就是平方根曲线。代码把本章每一档战斗强度的**中位数**拉到目标，每个敌人相对中位数的强弱仍随它自己的卡牌；章内再按格子列线性递增 `in_chapter`（第一列 ×start，最后一列 ×end，prologue 除外）。精英 / 首领 / 必败（`lose_goto`，如虎牢关吕布）各再乘一个系数（`enemy_coef`：1.25 / 1.45 / 4，血和攻都乘；`scaling.tier` 现在都是 1，避免叠两次）。`strength` 整体加难度，`chapter` 是个别章节的手工微调（默认空）。周目难度、险、词缀仍叠加在后面。`tests/test_quests.gd` 有防反转测试。

难度目标：整体胜率约七成（每次战斗；普通战 ~82%、精英 ~70%、首领 ~53%，序章 ~89%、之后各章 75% → 55% 缓慢往下）。当前参数下 bot 一周目 24 局通关 17 局（71%）。想更易 / 更难：改 `strength`（或 `base`）；扫参数用 `SIM_LAPS=4 SIM_RUNS=16 SIM_ROUTE=south godot --headless --path godot --script res://tests/sim_balance.gd`，旋钮 `SIM_STRENGTH SIM_BASE SIM_EXPONENT SIM_OFFSET SIM_ELITE SIM_BOSS`；各档胜率汇总可以把输出里每行的 `n=` 与 `win=` 按档加权平均。个别敌人（如 `taodong:fire`）比同章其他敌人强得多，会拉低波动，单独压它的 hp / at。

暴击：`cards.json` → `battle.crit`（player_chance 0.12 / player_mult 1.6 / enemy_chance 0.08 / enemy_mult 1.5），每一击单独掷骰；宝物可用 `mods.crit` / `mods.crit_mult` 加我方几率和倍数（还没有宝物用）。事件 `hit` / `enemy_hit` 带 `crit`，战斗界面显示金色「暴击」飘字。想更随机：加大几率或倍数。期望伤害：我方 +7%、敌方 +4%，模拟验证一周目通关率仍约 80%。

测试与难度校准的完整流程（跑测试、截图、平衡模拟 `tests/sim_balance.gd`、`battle.scaling` 的唯一旋钮 `strength`）见 `.claude/skills/sanguo-test/SKILL.md`。
？事件：开章时就给每个 ？ 格发好事件（地图上显示事件名，每局不同，`Quests._roll_events`），到达格子时就按 `weight` 从可触发的选项里真实随机抽好一个（`Quests.rolled_option`，存在 `save.event_rolls`），格子上只有一个按钮，按钮上写的就是抽到的选项，点它执行（结果第一行写「随机到了：选项名」；不要写「听天由命」或「抽取结果」之类的按钮）（`battle.event_random`，`Quests.random_option`）；通用坏事件 14 个（`bad_*`，scope universal）。战斗手感 `battle.attack_mult` 1.1 / `hp_mult` 0.9（双方同时生效）。
