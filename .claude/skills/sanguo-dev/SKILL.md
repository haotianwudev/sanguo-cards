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
| `tools/sanguo_art.py` | `python tools/sanguo_art.py`: builds portraits + map backgrounds into `godot/data/`, regenerates ART-NEEDS / SOURCES |
| `tools/` | Python tools: art pipeline (`sanguo_art`, `art_gen`, `art_ingest`, `art_prompts`, `map_guide` / `map_strip`), doc generators (`chapter_stats`, `roster`, `chapter_docs` via `facts.py`), `check.sh`, `fmt_story`, `import_policy`, voices (`gen_voices`, `voice_audition`), `build_fonts` |
| `pics/prompts/*.json` | every image prompt (portraits / battles / CGs / events / overrides …), one entry per line — edit prompts here |
| `godot/scripts/dev/` | development only: `demos.gd` (`--demo=` screens), `script_check.gd` (`--check-scripts`) |
| `godot/scripts/power.gd` | the `Power` autoload: frame-rate caps (ui.json `power`) and 省电模式 |

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

## Checks and tooling (the 2026-11-07 robustness pass — use these, don't re-derive)

- **`sh tools/check.sh`** (≈40 s; `--fast` skips the Godot import) is the whole gate: story.json format → texture import
  policy → Godot import → all tests (data schema included) → every generated doc up to date. CI
  (`.github/workflows/check.yml`) runs the same script on every push to master — keep it green; `gh run list` shows it.
- **Data checks are config**: "this id must exist / this value must be one of these" rules live in `godot/data/schema.json`
  (path syntax `*` `**` `@keys`; kinds refs / enum / required / forbid / unique — `scripts/core/schema.gd` explains). Add a rule
  there, not an `assert` in code. `GameData.check_schema()` lists every failure at once (the tests and tools run it; game
  startup doesn't — it costs ~70 ms and shipped data never changes). A rule that matches nothing is itself an error
  (misspelt path); `"optional": true` for a field no data uses yet. Only what a path can't say stays in code (`fail_if`).
- **One requires / unless rule**: everything gated goes through `Quests.gate(entry, save)` (quests, squares, choices,
  pool / title / map overrides, ？小故事, chapter pages). `unless` with a list hides only when **every** line holds.
  `Quests.gate3(entry, truth)` is the same rule over three values (holds / doesn't / can't tell) for tools.
- **Routes are config**: `story.json` `routes` = route → birth line (`出生：江东富春` / `出生：冀州无极`); `SaveData.route()` /
  `birth_route()` / `is_north()` read it — never write the birth line literally in code.
- **Doc generators never re-implement game rules**: `godot/tools/export_facts.gd` asks the game (gate3, `Quests.pools`,
  `chest_pools`, `card_chapters`, titles, maps, endings) what every route-chapter holds; `tools/facts.py` runs it (≈2 s,
  cached in `build/facts.json` until data or scripts change; Godot from `$SANGUO_GODOT`). `chapter_stats` / `roster` /
  `chapter_docs` / `art_prompts`' north CGs / `python tools/sanguo_art.py`'s event pools all read it. A new rule a doc needs = a field in
  `export_facts.gd`, never Python logic. Route-chapter keys: the quest id, or `<quest>_s` / `<quest>_n` for one quest both
  routes play (第一章); a `universal` quest (天命归一) is one chapter with route "".
- **story.json formatting**: `python tools/fmt_story.py` (house style: one square / one event per line); patch scripts use
  `from fmt_story import dump_story`. `--check` runs in check.sh and the pre-commit hook.
- **Texture imports are config**: `tools/import_policy.json` (big pictures lossy WebP 0.85 / portraits 0.9, icons lossless; a rule may carry `max_width`: a CG / battle picture under 1100 px wide stays **lossless** — compressed again it looked blurry on a phone (user, 2026-11-09). The game copy is scaled to 720 high, so a delivered picture should be at least ~1300 wide. **The user's full-size Gemini originals are in `C:\Users\lswht\Downloads\sanguo\`** (2752×1536): the 72 old 1024-wide CGs / battle pictures were replaced from there by matching picture content (64×36 grey signature, centre-cropped to 16:9). When a picture looks low-res, look there first; never redraw it.)
  After new art: Godot `--import`, then `python tools/import_policy.py --write`, `--import` again, and **commit every
  `.jpg.import` with its jpg** (`--check` fails on an image committed without its `.import` — CI caught 15 of those).
- **Saves**: `GameData.write_json` (compact, `.tmp` then rename) / `read_user_json` (falls back to the `.tmp`) for every user
  file; `SaveData.steps` holds only the fields each step changed (`push_step` / `step_state`).
- **Heat (user priority: the phone must not get hot)**: the `Power` autoload caps the frame rate (60 while touched or
  animating — call `Kit.poke()` for anything that plays without input — 30 once still; 省电模式 = 30 + low-processor
  rendering). Never add per-frame script drawing: an endless decoration is `Kit.loop(node)` (plays once in 省电模式),
  a moving surface is a shader (card aura, map road dashes); `_process` only while something actually moves
  (`KineticScroll`). Measure with `--print-fps`.
- **Code quality gates**: project.godot treats unused variables / parameters / constants, unreachable code and
  redundant await as **errors**; `godot -- --check-scripts` compiles every script (the test runner only compiles what
  it touches and has no autoloads). `Kit` must not reference autoloads directly (tests) — pass values in.
- **Tests by topic**: `test_data` (schema, gates, map rules), `test_saves`, `test_events`, `test_balance`, `test_quests`
  (chapter flow), `test_routes`, `test_battle`, `test_collection`, `test_prep`, `test_tactics`, `test_audio`,
  `test_story_text`. Shared helpers (`rng`, `quest`, `walk_to`, `event_on_road`, the bot) live in `TestCase`.
  A check that is only "this id exists" belongs in `schema.json`, not in a test.
- **Runtime memory**: portraits are an LRU of `ui.json portrait_cache` (160); small pictures go through `Kit._kept`, big ones
  through `Kit._art` (not kept). The card aura is `scripts/ui/card_aura.gdshader` (no per-frame script drawing).
- **Where UI code went**: `scripts/ui/map/` (MapNode / MapToken / MapLines), `scripts/ui/battle_intel.gd` (the 出战 intel
  tags), `Kit.resist_parts` / `Kit.armor_of` (the one reader of resists / armor); `BattleScreen._play` dispatches each engine
  event to its own `_ev_<kind>(ev)` — a new event = one `_ev_` function + one line in `_play_one`.

北线第二章：`--demo=ln2`（虎牢关前，`--at=<square id>` 跳到任意格，`--at=` 的目标必须在脚本自带的 `path` 数组里，新加格子要同步那份列表）。
第四章：`--demo=ch6`（围府线，已触发前面的 badend）/ `--demo=ch6b`（报信线）/ `--demo=ch6c`（已触发「结局五 · 恨海」，渭水打张济张绣、收贾诩），加 `--at=<square id>` 直接跳到那一格截图。
第五章：`--demo=ch8`（恨海线）/ `--demo=ch8b`（通关恨海、第四章收了贾诩后的破局线），同样可加 `--at=`。
`tests/test_routes.gd` walks chapters 3–5 on every ending route (squares, records, endings, cards, which chapter follows) and checks
that no two open squares ever share a spot; keep it green when you add squares.

**存档：南线、北线各一个，可以同时玩。** `user://save_south.json` / `save_north.json`（路径见 `SaveData.slot_path`），新旅程在选完出生点前写在 `save_pending.json`，选定后 `Game.assign_slot()` 把它挪进对应路线的槽位；那条线已有存档时，`map_screen._resolve` 先弹 `ConfirmOverlay` 问要不要覆盖。结局、卡牌收藏（`SHARED_LISTS` / `SHARED_MAXES` / 结局旗标）两边共享，写在 `user://shared.json`：每次 `Game.persist()` 顺手 `write_shared()`，读档时 `apply_shared()` 合并（所以天命归一能同时看到南线赤壁、北线官渡）。旧的单存档 `save.json` 第一次启动时由 `migrate_legacy()` 搬进对应槽位。`Game.persist_enabled` 在 headless（测试）下强制为 false，测试不会碰真存档。读存档一律走 `Game.load_slot(route)` / `Game.any_save()`，别直接 `SaveData.read()`。**一条线的旅程只给那条线的出生点**：`save.slot_route`（某条线存档的「新周目」= `SaveData.new_lap` 记下原路线；标题上只有一条线存档时，另一条线那一栏显示「X线　还没有存档」+「开始X线」，走 `NewGameDialog.route` → `Game.new_game(name, route)`）让 `Quests.option_hidden` 藏掉另一条线的出生选项（按 story.json `routes` 认，`option_locked` 也算它）；两条线都有存档时只剩一个灰色「新的旅程（选出生点后，覆盖那条线的存档）」。截图 `--demo=title_slot [--north] [--start]`，任何 demo 加 `--slot=<route>`。

Fonts are bundled subsets (`godot/data/fonts/body.ttf` 思源黑体, `name.ttf` 霞鹜文楷), used by `Kit.make_theme` / `Kit.name_font`.
**UI material (user rule, 2026-11-01):** titles use 文楷 via `Kit.title_label` / `Kit.calligraphy` (title screen, chapter / ending /
scene titles, panel titles, the story box's square title, enemy names, card names in 整备); body text, numbers and button text stay 黑体.
Buttons are two materials only (`Kit.button_styles`): gold / green / amber → 琥珀金 plaque, red → 朱砂 plaque (both with a 2 px light
edge and a drop shadow), everything else (blue / gray / purple / plain `Button`) → dark 玄漆 with a thin dark-gold edge — don't add
new flat colours. Every `Kit.button` / `tool_button` sinks to 0.97 when pressed (`Kit.press_bounce`). `Kit.bar` carries a glaze strip
and a dark groove (children `Shine` / `Groove` above the fill). `Game.show_screen` dips through black (into a battle: steel blue),
skipped headless; full-screen CGs get `Kit.ken_burns` (1.012 → 1.0 over 2.5 s, once per square — user: 1.035 made them dizzy). The title picture is never dimmed —
only `_centre_shade()` behind the menu.
**Story text with a rare character** (not in the common GB2312 set) shows as a box on phones until you rerun `python tools/build_fonts.py`
(it rescans `godot/data` + `godot/scripts`), then `--import`. `test_the_bundled_font_has_every_character_the_game_prints` fails when you forget.
UI icons (badges, map squares, relics, card back, stat/skill icons) are generated placeholders from `tools/generate_ui_assets.py` (the map token is drawn art now, see *Map screen*);
once any is replaced by drawn art, don't rerun that script — it overwrites them all.

**Battle feedback (2026-11-02):** every mechanic event has a show in `BattleScreen._play`: `resist_down` (steel streak + 「双抗 -X%」), `loot` (gold + odds; party badge 掠 = second-chest %), `stance_off` with `broken` (「架势击破！」; plain expiry is silent), enemy badge 反 + teal glow while a stance is up, `guard_on` shield wall, hits with `guard` spark on the 前卫 bar (boss art stays still), `guard_down` shockwave, `enemy_rage` blood ring. Our poison tick is `enemy_hit` with move 「毒」 and, like 「火」, gets no move plaque / lunge / war cry (poison cloud instead). Hit events carry `vs` (the 追击 multiplier) → 「破绽追击！×N」. Crit = `BattleFx.crit_star` + 50 ms hit-stop (`_hit_stop`, Engine.time_scale, skipped headless). Magic hits take the acting skill's element (`_act_elem`: burn / 火 name → fire, poison → green). Party HP < 25% → red pulsing glow. Combo label warms at 5 / 8 / 10 (`_combo_heat`). Cut-in move names are 文楷 with sparks; no portrait → no empty frame. `_sfx_act` picks slash / heal / guard / buff by the skill's effects (magic: only its hit sound). Plain physical blows take the striker's troop shape (`BattleFx.troop_hit`, `_act_troop`): archer arrows (combo ≥ 4 = volley from above), spear thrust cone, cavalry heavy arc + speed lines, bandit shadow cross; others / pierce / BOOST / magic keep `BattleFx.hit`. Archer physical 大招 = `ult_arrow`. Enemy charged 绝招 landing = `enemy_ult_slash` (black-red cut across the line + vignette). 换人: old card sinks out, new one leaps in from below, gold ring, 「登场！」. Killing blow = `_kill_freeze` (0.15 s at 0.25× speed, enemy darkens, cracks, sinks). Win = `_victory_plaque` (文楷 lacquer plaque, gold sparks, overkill line). `--demo=fx --fx=archer|volley|spear|cavalry|bandit|ultarrow|enemyult|swap|stance` shows each.

Android APK (debug, arm64; preset in `godot/export_presets.cfg`, templates in `%APPDATA%/Godot/export_templates/4.7.2.stable`,
SDK / JDK / debug keystore set in the editor settings):

```bash
timeout 900 $G --headless --path . --export-debug "Android" ../build/sanguo-cards.apk   # build/ is gitignored
/c/platform-tools/adb install -r ../build/sanguo-cards.apk                            # phone with USB debugging on
```

Demos (`Demos.run()` in `scripts/dev/demos.gd`): `title`, `map`, `pick`, `choose`, `event` (左慈 on a ？ square),
`relics` (宝物 pick), `tiers` (铜/银/金 frames), `ch2` (虎牢关 fork), `battle`, `fight`, `cards:id1,id2,...`,
`chest` / `grand_chest` (a loot chest over the map). `firststep` (chapter one's first step: the story, then the lord card moment; `--skip` skips the story), `cardsbook` (the 卡牌收藏 on its 主角卡 tab: remembered versions in colour, the rest greyed). Add `--north` to any `--demo=` to play as the north-route
lord (appends 「出生：冀州无极」 to `run_records`) — for demos that call `Quests.begin` internally (`chest`,
`grand_chest`, the chapter forks) that reset `run_records`, append the record again after the call, same as a
real run would after walking past `era`.

**In-game QA tool** (`scripts/ui/debug_screen.gd`, `DebugScreen`): a "测试工具" button on the title screen, only
built when `OS.is_debug_build()` is true (so it never ships in a release export — the `--export-debug` builds this
repo uses for phone testing all have it). Three tabs: jump straight into any chapter (`_CHAPTER_JUMPS`, a hardcoded
table of `quests_cleared` + `flags` per chapter mirroring the exact combinations `Demos.run()`'s `"ch4"`/`"ch6"`/
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
| `docs/CHAPTER-STATS.md` (fully generated: the 南北线对比 table and the 卡牌种类 section) | `python tools/chapter_stats.py --write` / `--check` | per chapter and route: squares, how many of each of the 7 square types (事/选/战/宝/休/募/？), battles normal / elite / boss, forks, CGs drawn / total; cards by rarity / troop / route + portrait coverage |
| `docs/ROSTER.md` | `python tools/roster.py --write` / `--check` | every soldier by 阵营 / 章节限定 / 公共 with where it comes from; which soldiers each chapter's chests hand out (⚠ = card `scope` doesn't match the route); every general with where it joins / is recruited / drops; per chapter joins / 招贤 / drops |
| `docs/chapters/<NN>-<南线 or 北线>-<章名>.md` (e.g. `07-北线-邺城惊雷.md`; 第一章 split into its two routes) + `README.md` index | `python tools/chapter_docs.py` / `--check` | one review file per chapter: header (requires, ending, pools, shuffles), numbers, the map square by square (x / y / type / requires / next / what it gives), the full script in map order with choices, battles (enemy, tier, turns, drop, picture) and enemy moves, the chapter's own ？ events, joins and drops, every CG drawn or missing with its prompt and reference portraits, the ending, then every ？小故事 that opens after it (requires, price, reward, CG + prompt, full text) and the interlude scenes before the next chapter — 第一章's two births each get only their own |
| `pics/ART-PROMPTS.md` | `python tools/art_prompts.py` | prompts for every missing picture; reference portraits are derived from the card / portrait names a prompt mentions (titled names like 「河北庭柱」颜良 match 颜良, portrait-only briefs like 郭图 / 袁谭 count, young 甄宓 → `zhenmi_young` before 北线第七章, north scenes and north events → `lord_north`) |
| `pics/ART-NEEDS.md`, `pics/SOURCES.md`, `godot/data/portraits/*` + `portraits.json`, map backgrounds | `python tools/sanguo_art.py` (from `pics/art.json`) | what art each chapter still lacks; delivered art |
| `godot/data/fonts/body.ttf`, `name.ttf` | `python tools/build_fonts.py` | the font subset — rerun after any new text (a test fails on a missing character) |

**Roster is automated too**: `python tools/roster.py --write` regenerates `docs/ROSTER.md` (every soldier by 阵营 / 章节限定 / 公共, which soldiers each chapter can hand out — ⚠ marks a soldier whose `scope` doesn't match the chapter's route — and every general with where it joins / is recruited / drops); the pre-commit hook runs it with the stats, `--check` exits 1 when stale. Never hand-edit that file.
**"update stats"** → `python tools/chapter_stats.py --write` (rewrites the whole of `docs/CHAPTER-STATS.md`, nothing in it is hand-written: 南北线对比 with the per-type square counts, and 卡牌种类; a new chapter or quest goes into `CHAPTERS` in `tools/chapter_stats.py`). Per-chapter detail lives in `docs/chapters/`, where each card comes from in `docs/ROSTER.md`.
**Generating art: `python tools/art_gen.py --key <k> --prompt "<p>" --size 1536x1024 --ref <portraits / relic icon…>` — default model is `nano-banana-2` (user decision; `nano-banana-lite` only when asked, `gpt-image-2` is the fallback when the API rate-limits). Always pass the delivered portraits and any relic icon that appears in the picture as `--ref`, then open the result and check it against the prompt (no stray text, props match their icons) before showing it.**

**战斗配音是配置驱动的**：台词和声线在 `godot/data/audio.json` 的 `voices`，卡牌 / 敌人写 `"voice": "<声线>"` 用专属声线（缺的时机落回 `voice_defaults`），改完跑 `python tools/gen_voices.py` 再 `--import`；`battle_screen.gd` 里不写台词。做配音先读 **`sanguo-voice` skill**（先本地 IndexTTS 2，不好再 MiniMax；`tools/voice_audition.py` 试音）。只用自己生成的配音，不进别家游戏的素材。
**New art from the user → use the `sanguo-art-ingest` skill (`python tools/art_ingest.py add <path> <key>`): it checks, crops, installs and logs; docs are refreshed only by `flush` every ~20 images.**
**Map screen (`scripts/ui/map_screen.gd`)** — what the 2026-10-31 pass settled (user asked for each):
- **The hero walks the map as a Q版 chibi**: `token_lord_south.png` / `token_lord_north.png` in `godot/data/art/map/` (`Kit.token_icon(Game.save.is_north())`, falls back to the old generic `token_lord.png`). It stands **beside** its square (`TOKEN_FOOT`, left of the icon — never on it, it used to hide the icon), size `TOKEN` 80 px, a soft ground shadow (`MapToken`). Moving = `_walk_to`: follows the same smoothstep road curve the lines use (`MapLines._curve`), waddles (rotation) with one hop per ~38 px, squash on landing; idle = gentle breathing scale (`_bob_token`). **Facing**: both chibi pictures stride to the LEFT, so the sprite is `flip_h = true` by default (the story runs left → right) and `_walk_to` sets `flip_h = to.x > from.x` — a new chibi drawn facing right must drop that default. Redraw a route's chibi: `art_gen.py --size 1024x1024 --ref pics/source/generals/lord[_north].jpg godot/data/art/map/token_lord_<route>.png` (三头身, walking left like the existing two, thick outline, pure white background, no base / shadow / text), check it against the lord portrait, then `python tools/chibi_token.py <png> <route>` (cuts the white off → token + a 3:4 card portrait in `pics/inbox/`) and ingest the portrait.
- **主公·Q版 lord cards** (`lord_south_q` / `lord_north_q`, R 68/74, `art: true`, in `lord_forms.grants`) use that same chibi on a backdrop as their portrait.
- Only won battles get the cinnabar 「胜」 seal; story squares just grey out (no 「通」 — too noisy). Square name plates are `LABEL_FS` 15 (13 was unreadable on a phone). `MapLines` stops redrawing while the map is hidden (CG mode).
- `--demo=ln2 --at=<id>` walks 北线第二章 square by square — its `path` list must follow story.json (a stale list silently stops at the first square it can't reach); `--demo=cg_north --at=<id>` does 北线第一章.
**Chapter map backgrounds are stitched from panels** (a chapter map is 5000–9000 × ~390 px; one generated picture stretched over it came out 2–7× upscaled and mostly cropped): split the chapter into 4–7 stretches of ~6 columns by story place, generate one panel each with `art_gen.py --size 21:9` (refs: a finished panel of the same route for style; season matches the chapter; prompt says 铺满四边、不要卷轴 / 边框 — the model likes to add a scroll frame), list them in `pics/map_panels.json` (`from` = first column x), then `python tools/map_strip.py <map key>` → `art_ingest.py add pics/source/map/<key>_strip.jpg <key> --kind map` (delete the `_strip` file after). `map_screen.gd` sizes the background to the whole chapter so the strip lands column for column. **Generate with `python tools/map_guide.py <key> --gen`**: each panel gets a layout sketch at real game coordinates (roads = the links between squares, a coloured blob per `spots` entry `[square id, what to draw]`), so landmarks land under their squares; `--gen` checks every result for copied blobs (`leaked()`: solid / halo in the blob's colour, or a thin ring in a colour nature rarely paints) and redraws those up to twice — still look at the sketch-vs-result sheet: it misses faint halos, written prompt words, yurts (the prompt now says 汉代方形军帐) and day/night splits (don't write 夜里 into a spot of a daytime panel); `--check` scores existing panels, `--gen <n>` redraws one. A chapter with 4+ rows (第三章 `yuxi`: 玉碎 rows 3–5 under 守洛阳 / 长安 rows 0–2) sets `"aspect": "3:2"` and its scenes describe the top half and the bottom half separately. Screenshot any chapter's map with `--demo=quest --id=<quest> --at=<square> --map` (+ `--south` for a south chapter, `--flag=<line>` for a route; an ending line also goes into the lasting flags). **Stagger variant routes**: two flag-exclusive routes on the same squares (`requires` / `unless` the same flag) should run on different rows so the art can hold both (北五 `xuzhou` 失律 y2, 南四 `dongui` 同归一周目线 y2→y3–4 — that chapter is 5 rows, `aspect 3:2`, 南五 `jingxiang` 定策线 y2, 北六 `huainan_n` 茅房→被擒 y2 with the 尿遁 line's branches squeezed into y0/y1); `test_maps_only_move_forward_one_row_at_a_time` forbids any link that jumps more than one row, so shared predecessors limit where a branch can start — when a single square can't move, split it with ±30–40 px `map_nudge` instead. **Last mile: nudge squares onto their landmarks** in `godot/data/map_nudge.json` ({map key: {square id: [dx, dy]}}, clamped ±70 px, read by `_pos`, so icon / label / road / hero all follow; map_guide uses it too). Done: 北线 1–7 (`prologue_north` `luoyang_n` `heishan` `beihai` `xuzhou` `huainan_n` `yecheng`), 南线 1–5 (`prologue` `taodong` `yuxi` `dongui` `jingxiang`). **Seamless, accurate panels (`yecheng`, 2026-11-08):** set `"continuous": true` on the chapter and generate left to right, one at a time (`--gen 2`, `--gen 3` …): each sketch pastes the last BLEND px of the panel before it, and in a chapter whose squares use only the upper rows also paints the empty lower half, so the model paints on from the previous panel and can't move landmarks down. Then `--mend <n>` wipes a strip across the hard edge it leaves and has it painted in from both sides (an edit that only asks to remove the edge doesn't work). Check every square with `python tools/map_overlay.py <key> --out <dir> [--map <strip>]` (all routes at once, demo walks can't reach them all). A landmark still out of nudge reach: crop it, paste it onto the square, wipe its old spot to cream and have the blanks painted in ("已有的不能动，只补空白"); a second pass with a wiped ring around it clears a visible patch. Colours in `spots` follow list order: read the sketch before assuming which blob is which. A nudge that pushes a lowest-row square down cuts off its name plate (the map ends just below): row 2 of a 3-row stretch takes at most about +22. After installing, Godot `--import` before screenshots, or the game shows the old cached map. Panels without nudges yet: `longhu` `xiliang` `sanfang` `tianqing` `guandu` `dujiang` and 南线 6–12 (`huainan_s` `jiangdong` `menghu` `tianfu` `guanzhong` `luoyang_s` `beifa` `chibi`); `guiyi` keeps its one drawn picture. Spots written as short nouns (古寺, 营门) get painted on as labels: describe them (一座带佛塔的寺院). The score also fires on red autumn leaves and fire (false alarm), and passed big pale blobs (`menghu_4`). **Look at every panel, the score isn't enough:** it passed faint colour halos (`guandu_4`), and it can't see written labels (`xiliang_6`, `sanfang_4` came back with 渡口 / 军营 painted on, hence the 「不是标注图」 line in `COMMON`). Tall lines that run through a city: say so in `scene` per half and give each row its own spots, or they end up on farmland (`xuzhou` 5–6). A map is stale when its squares moved since it was installed or it is stretched past ~1.3×.
**A route with its own map (bad-end lines, 2026-11-09):** when a flag-exclusive route runs over the same columns as another and the art can't hold both, give it its own map: the quest's `map_overrides` (`{requires|unless: <line>, map: <quest>_b}`, read through `Quests.gate`, so run records switch it the moment the branch is taken) and a `pics/map_panels.json` key `<quest>_b` with `"route": [<record lines that route has>]` — `map_guide` / `map_overlay` then draw only that route's squares and roads. Its shared stretches list the same panel `src` as the main map (copy the entries), only the route's own stretches get new panels (`--gen <n>`), then `map_strip` + `art_ingest --kind map`. Done: `longhu_b` 郭嘉留守, `tianfu_b` 无陆逊, `huainan_s_b` 开仓分田, `jiangdong_b` 联手严白虎, `guanzhong_b` 子午谷. `art_ingest add` rebuilds all art per image (~1 min each): for many images use `batch`. A night panel with 8 spots kept the sketch blobs three times running: fewer spots (6) and dusk instead of night fixed it — and always look, the score passed `jiangdong_b_5` with three blobs still on it.
Art: put the original in `pics/source/...`, add/adjust the `pics/art.json` entry, run `python tools/sanguo_art.py` (from the repo root).
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
**Story box rules (2026-11-01 pass, user asked for each):** the speaker's face sits in a fixed dark-gold frame (`_make_face_slot`) —
no frame at all when nobody in the lines (nor the enemy ahead) has a portrait drawn (`_any_face` / `_enemy_has_face`); a narration line keeps the nearest speaker's face dimmed (0.55) with no name plate (`_near_speaker`; no face blinking out between lines), so the text's left edge never jumps; a name plate (`Kit.speaker_name(key)`: card name
before 「·」, else the first real `Kit.ALIASES` name, `Kit.NOT_NAMES` skips descriptions like 美妇) sits on the frame's bottom, and
记录 prefixes bare 「…」 lines with the speaker (`Kit.named_line`). The tools are `Kit.tool_button` pills (32 px, never `Kit.button`).
Options that appear after the last line fade in and ignore taps for `TAP_GUARD` 0.3 s (`_show_buttons`) — keep that for any new
option path. Full-screen picks (天命 / 宝物 / 选卡) call `_cover(o)`: the text box and tools hide under them; a pending 天命 opens
before the chapter's first square is shown at all (its CG voice waits). `RelicPick` is select + 选定 (or a second tap), like
`PickOverlay`. Before a fight the frame shows the enemy, the intel is `BattleIntel` tags (3–4 lines, no scroll) and 整备 sits beside
出战; coming back from 整备 / 部队 to a square whose lines were read (`_story_read`) shows its options, not the scene again.
`InterludeOverlay` (？小故事, endings) has the same 跳过 (this scene) / 隐藏 (CG only) / 记录, a name plate, and without a CG lights
the speaker's portrait (others 0.55). Screenshot flags: `--line=N` (N taps into a map square), `--log` (记录 open, after `--skip`
too), `--demo=interlude --id=<story> --line=N [--nocg] [--log|--hide]`, `--demo=relics --sel`, `--demo=fate`.
**战后台词（用户 2026-11-08）：** a battle square's `win_text` plays line by line once, straight after the win (`MapScreen.just_won`, set only by `Game.battle_finished`; a boss's 宝物 pick comes first), never on a reload or a step back — then its last line is the square's summary. It sums up the fight and says where the story stands, never repeats the next square's opening, follows the story text rules and moves with a shuffle (`CONTENT`). No `win_text` → the old 「已击破。」. Screenshot: `--demo=quest --id=<quest> --at=<square> --won`. When writing one, also look in the fight's own `text` and the next square's opening: lines that tell the fight's result belong in `win_text`. A `lose_goto` fight keeps its lines before the fight even if they read like aftermath: the (many) players who lose must see them too. Every battle square has one (a test guards it); a new fight needs its `win_text` in the same change.
**The face frame is never empty:** `_has_face` is the one rule — no portrait for anyone (nor the enemy ahead) → no frame; a speaker with no portrait keeps the nearest face dimmed.
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
`pics/art.json` "battles", built by `python tools/sanguo_art.py` into `godot/data/art/battle/`; the battle screen paints it (washed) when
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
3. Run `python tools/sanguo_art.py` — it builds `godot/data/portraits/`, `portraits.json`, `ART-NEEDS.md`, `SOURCES.md`. Never hand-edit
   those four. Then `--import`, `python tools/import_policy.py --write`, `--import` again, and commit the new
   `.jpg.import` files with the jpgs (every portrait has one; `import_policy.py --check` fails otherwise).
4. Screenshot it on its card (`--demo=cards:<card ids>`) and in its scene; adjust `face`/`head` until the head sits in
   the upper third and the figure isn't cropped at the frame.

## Editing gotchas (these bit us)

- **Don't put multi-line Python in bash heredocs** when the code contains `\n`, `\\`, or nested quotes — write the
  script to the scratchpad with the Write tool and run it. For one exact replacement, prefer the Edit tool.
- Patch scripts: `assert t.count(a) == 1` before every replace, and check **before** writing any file — a script that
  dies halfway leaves some files changed. Re-read what already landed before re-running.
- Write files with `newline="\n"` (repo is LF; `.gitattributes` enforces it). JSON stays valid: `json.loads` before writing.
- `story.json` / `cards.json` are hand-formatted (one entry per line). story.json: write it back with
  `tools/fmt_story.py`'s `dump_story(data)` (or run `python tools/fmt_story.py` after splicing); never `json.dump(indent=2)`.
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
  `"skills_north"` override (`tuji` stays shared, `rengdao`/扔刀 swapped for `huimaqiang`/回马枪 (named in 北线第一章 `jz_training`: 赵云 can't do it, works it out, the hero never gets the turn of the horse — only the turn-and-stab, hence the counter) — same cost/power,
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
**战斗 v3（`docs/battle-v3.md` 是全貌，先读它）**：敌人每回合开始就排好本回合的招（`enemy.intents`，`_plan_intents`，面板「意图：…」）；蓄力分杀招 / 回血（被蓄的招带 `heal`）/ 叫援（带 `summon`）/ 狂暴（带 `rage`）；**只有 `interrupt` 效果能打断蓄力**（扔刀、回马枪等 10 个技能，AP +1、敌人破防，`battle.charge_break`），普通眩晕只顺延；精英 / 首领按 `_move_weight` 读局势（防呆、`prefer`、`chain`、我方还有打断就少蓄力）；首领机制：架势 `stance`（兵刃技能被反击）、前卫 `summon`（兵刃先打前卫，谋略 / 穿甲越过）、点名 `mark`（下回合打攻击最高的队长，没换下 = 他被打倒 `slain`（变灰、本场不能行动、可换下）+ 扣体力上限 `battle.mark_pct` 1/4，`--demo=fight --mech --markon|--slain`；只给吕布 / 董卓 / 袁术这类大首领）、护盾 `shield`（最大体力 20%；打不破它的兵刃整下被挡，一下打破的那击全中，谋略越过，`Battle._through_shield`）、变阵 `formation`（挡一种伤害，眩晕破，只用于后期阵法战：八阵、曹仁八门金锁）、封技 `seal`（封大招 / 谋略 / 兵刃一回合，解状态可解）；每个精英一个机制、首领一个或多个（用户 2026-11-03，`docs/battle-v3.md` §4b，截图 `--demo=fight --mech`）；主公也能换人 = 换他的另一张主公卡（`Battle.swap_key` lordform:<form>，`--demo=battle --swapui --lordswap --forms`）；技能字段 `crit_if` / `vs`。换人 1 AP、第 1 回合起、只能换没出手的、换上当回合能出手，登场必定触发该兵种的小技（`_troop_trick` / `_raid`，算法同每回合的小概率版）。每回合的突袭（`_raid`）是兵刃伤害，**策士部队的突袭是谋略伤害**（吃谋略抗性、越过前卫，用户 2026-11-06）。
**自动战斗 + 军令**：战斗右下「自动」开关（`BattleScreen.auto_on`，静态，跨战斗保持），开着时每次动画播完 `_auto_step` 走一步：`AutoPlayer.plan(b, Game.options.tactics)`（军令三层（用户定）：整体 = 预设 + 中军军令（防御 / 留 AP / 换人规则）、兵种 = 技能类别、武将 = 具体技能，每条两个条件；顺序 破招 → 中军 → 武将 → 兵种 → 留气 → 默认估值 → 防御 / 结束；拆招 / 省技会把打断技能留到敌人蓄力；读存档里的军令一律 `AutoPlayer.with_defaults`（出厂军令在 `battle.json tactics.defaults`，三层都有、每条都带条件；兵种 / 武将按每个兵种 / 每张卡覆盖，玩家没碰过的用出厂值；军令不放价值为 0 的技能；整体页「恢复默认」；改出厂军令先跑 `SIM_BOT=tactics SIM_DEFAULTS=1` 对比，见 `docs/battle-v3.md` §7）；面板 `TacticsOverlay`：整备里三处入口（底栏「全军军令」= 整体；每个出阵队长下的小「军令」= 该兵种；卡详情里「X 的军令」= 武将，`PartyOverlay._open_tactics` + `TacticsOverlay.focus(tab, key)`，`--demo=party_pick --tactics=party|troop:<troop>|card:<id>`）（战斗里不再有军令按钮，用户 2026-11-02），`--demo=fight --tactics --tab=party|troop|card`；`AutoPlayer.next` 是旧接口）。回合上限 = 关卡 turn_limit + `battle.turn_bonus`（2，所有战斗）+ `tier_extra_turns`（精英 2 / 首领 5），`Battle.turns_for`（默认估值：每 AP 价值最高的可用技能，限 1 技能打折，价值为 0 的不放；军师 1 AP 战意 `buff` 按持续回合内全军多打的伤害 + 少挨的伤害估值，回合里还没出手的队友越多越先放，叠满层且还剩 2 回合以上就不放）选不出就结束回合——AP 已满时改为防御（`AutoPlayer.ends_with_defend`，反正下回合的 AP 也会溢出）；`--demo=fight --auto` 看效果。「自动」按钮只开 / 关（开着显示「自动中」）；快慢只在 设置 → 选项「自动战斗慢速」里调（`Game.options.auto_speed`，存在 options.cfg；战斗里关掉设置时 `_apply_speed` 重新套用，用户 2026-11-03）：慢速 = 动画按原速（无视「快速」设置）、每步之间停 1.3 秒；敌人有登场台词时，自动的第一步等台词喊完。
**大招演出**：我方放大招（`BattleScreen._is_ult`：special / 限 1 / 3 AP 以上）和敌人放蓄力招（`weight: 0` 的招式）时，先播一段慢动作 cut-in（`_cutin`：压暗、速度线、立绘带金框滑入、招式名从大砸下、闪白震屏，约 1.6 秒，我方从左红底、敌方从右黑底），再出伤害。cut-in 之后，兵刃大招（带 `attack` 效果）的每一击换成 `BattleFx.ult_slash`：两道交叉的弧形大刀光（白芯金边、红色余光）+ 全屏白闪 + 冲击波，谋略大招照旧；截图 `--demo=fight --scenario=c4_lvbu --ult-lord --wait=2.25`（有战斗 CG 的场景，特效按 CG 放大）。某个技能不要演出：`skills.json` 里写 `"cutin": false`；换音效写 `"cutin_sfx"`。截图：`--demo=fight --ult`（周瑜·赤壁业火）/ `--ult-enemy`（吕布天下无双）。点任何 `CardView` 都有 `card_tap` 音效。
**Skills on the cards**: every leader who can act shows his skills as a **vertical stack of wide buttons** (one per skill, the card's full width, icon + name + AP on one line) in his card's column, **stacked up from the card's top edge**, big enough for a thumb (72 px, 62 with a CG) — the cards keep their default place and size and stay fully visible; covering the HP bar and the enemy is fine (user rule; `BattleScreen._sync_skill_bars`, a `_skill_layer` above the row; button backgrounds are opaque so the card's own tags don't show through); 隐藏技能 (top right, next to 设置, kept as `options.hide_skill_bars`) clears them — CardView rebuilds its own children on resize, so they can't live inside it): one tap plays the skill; 大招 get a gold edge, unusable ones grey out; hidden while anything plays, in 自动 and after the result. 换人 is the column's last button; with the skills shown, tapping the card does nothing (the old popup only repeated the column — user call), with 隐藏技能 on it summons that column. Cards also carry an aura that matches their **frame** (`ui.json card.glows`, user rule: the worse the frame the smaller the aura — 木 none, 铜 a thin halo, 银 / 金 bigger and breathing, 神(ssr) a wide rainbow aura that turns like its frame, with sparkles running round the edge; `opts.glow = false` turns it off; `--demo=glows` shows one of each). A card carried in 整备 is as big as one in the line-up (`PartyOverlay.DRAG_SIZE`).
Battle visuals: `BattleFx` (scripts/ui/battle_fx.gd) draws every hit / status / buff effect procedurally — hits and one-shot effects in `BattleScreen._play`, persistent statuses reconciled in `_sync_fx`, corner badges in `_sync_badges`; `BattleFx.scale` sizes enemy-side effects to the portrait. A new status = an engine event + one case in `_play` + a want-entry in `_sync_fx` / a badge in `_sync_badges`; `--demo=fx --fx=<name>` shows one.
**Status layout (user 2026-11-08, 「状态太多显示不下」):** badges are the only status display (no text list — it repeated them and the panel clipped it away). The enemy's sit on its panel's top edge, the same way ours sit on the party bar's (user call; the panel starts at y 26 to leave them the room, so the whole width is free and they never touch the name), per card in its corner; all three go through `_lay_badges` → `_fold_badges(list, room)`: what doesn't fit folds into a 「+N」 badge whose tap lists the rest (a guard: the enemy's 11 fit). Append the enemy's in urgency order (斩 蓄 晕 first, rightmost). HP numbers are on the bars (`Kit.bar_text`), attack and 护甲 share a line, a long 意图 wraps to two lines. Worst case: `--demo=fight --noskills --longstatus --longname --mech --guard [--scenario=c4_lvbu] [--tip=<n>]`.
**HP 0 ends the fight at once (user 2026-11-08):** on every path nothing happens after the blow that took the last HP — `act` skips the skill's other effects (only `loot`, it counts towards the win), `_enemy_phase` checks right after each move's damage. `test_the_fight_ends_the_moment_either_side_has_no_hp_left` plays every scenario at low HP; a new damage path must keep it green. A fire on the enemy still never takes its last HP (stays at 1).
Every status badge / the 意图 line / the 前卫 bar / the 护甲 line explains itself (user 2026-11-07): `BattleScreen._tipped` / `_tip_on` give it a mouse tooltip and a tap panel (`_show_info`, the same panel as a held skill); the general texts are config, `battle.json` `status_help` (`status` per badge key, `intent` per 意图 word by prefix), the live numbers come from code. Skill buttons: hover tooltip, hold 0.45 s on a phone. Screenshot: `--demo=fight --guard --mech --tip=intent|guard|<badge n>`. A new badge goes through `_tipped` with a `status_help.status` entry.

**兵种克制 (`battle.troop_counter` / `counter_bonus`, user 2026-11-08; 目的是让玩家分散上场兵种):** 骑 → 贼 → 策 → 刀 → 弓 → 枪 → 骑, +25% on every number, adds up with BOOST (×1.75, `Battle.act_mult`), one way only (the enemy never gets it); 后勤 / 主公 / 野兽 neutral. An enemy's troop = its card's (`enemies[id].troop`). See `docs/battle-v3.md` §4c.
**累积 skills carry their surcharge from fight to fight (user 2026-11-08)**: `save.carry_extra`, cleared only by a 休整格 / 重置技能. 整备 shows it: `SaveData.card_note` tags the card 「累积+N」 (with 「大招已用」 on a second line), the detail page shows the real AP. `--demo=party --spent`.
**强化 BOOST (`battle.boost_mult`, user 2026-11-08) lifts every number a skill's effects have**: damage, heal, 减伤 (still capped at 90%), 破防, 破甲, 灼烧, 中毒, 反击, 战意 (this layer), AP (rounded up: 1 → 2). Not odds (眩晕 chance, 劫掠), durations, 打断's fixed reward, nor a skill's own cost (苦肉 `hurt`). A new numeric effect takes `mult` in `Battle._apply`; `test_boost_strengthens_every_number_a_skill_has` lists them.
**兵刃 / 谋略** (user 2026-11-07): the player-facing words for physical / magic (code keeps attack / magic). 弓兵 and 贼 split every blow (`battle.split_troops`, `Battle._split_blow`); 战意's attack bonus counts double on 谋略 (`battle.buff_magic_mult`); 护盾 (20% max HP) swallows a 兵刃 blow it survives; the blow that breaks it lands in full; 谋略 goes over; a shield no 兵刃 touched all round mends `battle.shield_regen` (5% of max HP) at the round end.
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
  整备 also drags (Godot's `set_drag_forwarding`, `PartyOverlay._dnd`): pool card → party row (onto a leader = take his place, `_add(cid, at)`),
  leader → pool (下阵) or onto another leader (swap), lord card → lord, 宝物 → party (装上) / pool (不装). Its cards use `CardView.tap_on_release`
  (`pressed` on lift, none after a drag) — the default fires on touch-down, and 整备 rebuilds on every tap, which would free the card before a drag could start.
  To drive it with fake mouse events, set `InputEventMouseMotion.relative` — Godot starts a drag from the accumulated relative motion.
  **Touch (phone)**: pool cards set `CardView.long_press` — on a touch screen a drag starts only after holding still 0.3 s (the card lifts),
  a plain swipe scrolls the pool (the card is `MOUSE_FILTER_PASS` and doesn't accept the press, so the ScrollContainer sees it; a press that
  wanders past `MOVE_SLOP` is never a tap). Leaders in the party row drag at once. Drag feedback: the carried card fades in place, the preview
  grows / tilts and rides 70 px above the finger on touch, the box under it lights gold (`_hover`), a leader under it grows, the dropped card
  bounces in its new place (`_pop`). The preview gets `z_index` 4000: 整备 itself is z 60, and a z 0 preview was drawn *under* it —
  invisible on every platform. The long press starts the drag itself (`CardView.held_down` → `force_drag`): Godot tries a drag only once per
  press, at the first 10 px of motion, so a finger that wobbled before the hold would otherwise never pick the card up. To screenshot a drag
  from a script, `Input.warp_mouse` along with the pushed events — the preview follows the real cursor.
- **Skill**: `cost, cumulative (+1 AP per use), uses (N = 本章限 N 次，休整格恢复), per_battle (true = 每场限 1 次，下一场自动恢复；主公的扔刀（rate 3 + 必定眩晕）/ 回马枪（rate 2.5 + 反击）), effects[]` — `attack/magic {power, hits, burning_mult}`,
  `heal`, `guard {cut}`, `boost`, `stun {chance}`, `break`, `ap`, `burn {pct | power, turns}` (one fire at a time: a new one keeps the bigger and restarts the count; 周瑜's 火攻 is 10%/turn at a flat 1 AP). Once-per-battle damage
  skills (大招) cost ≥ 3 AP (a test enforces it). **Every SR general also has three skills** (user rule; `test_every_sr_general_has_three_skills`): 1st and 2nd are usually the troop's shared moves (plain + signature; a card's own non-大招 signature may take the 2nd), the 3rd its 大招 of 3–5 AP — it may be shared (王允 uses 连环计, versions of one person share one); `build_fighter` slots the troop signature in as the 2nd whenever an SR / SSR general would have fewer than three. **Every SSR (generals and lord cards) has exactly three skills, one a once-only (`uses: 1`) 大招 of 5+ AP worth ≥ 15 power** (user rule; `test_every_ssr_has_three_skills_and_a_5_ap_ultimate`) — an SSR lord card gets its 大招 through the form's `skills` (铜甲 猛虎啸, 银甲 枪出如龙). **Heals**: every player heal (skill `heal`, 后勤 passive, relic `start_heal`) is × `battle.heal_mult` (0.667 — user cut all healing by 1/3; the skill text shows the multiplied number). An everyday heal is cumulative (+1 AP each use); a big heal is a once-only 大招. Few generals heal (doctors, 刘备, the mother figures, 后勤 troops) — give the rest statuses (guard / boost / ap / break / stun). Tests enforce both. **Once-only skills (限1) are once per stretch of map**, not per battle: used up they stay spent until a 休整 square (or a 重置技能 event) — so players rotate cards. Put a mandatory 休整 after a chapter's mid-map boss.
- **技能体系 v2**（设计与理由见 `docs/skills.md`）：`troops` 只管 hp/at；技能组合在 `cards.json` 的 `kits`（`normal` 普通兵种默认 / `special` 特殊兵种默认），`kit_default` 映射兵种，卡牌可写 `kit` 覆盖。攻击 / 谋略 / 回复效果写 `rate`（每 AP 威力，总威力 = rate × AP）、`hit_rate`（每段 = hit_rate × AP），不写就取 `skill_budget` 的档位默认（`rate_by_ap`、`multi_hit_rate`、普通技能每 AP 0.8–1.05（带附带效果再按 `rider_share` 扣，2 AP 打断 ≈ 1）、限 1 大招 × `ultimate_mult` = 1.4（敌人难度不降，`enemy_hp_mult` 1.24），多段技能按自身连击折算，见 docs/skills.md「大招强度」：普通 = 温侯画戟、强 = 方天乱舞、弱 = 每 AP 1.2，主角卡例外）；0 AP 技能直接写 `power`，`free` 允许 0 AP 攻击，`special` 不参与预算测试。新效果：`per_combo`（收尾）、`pierce`（穿甲）、`counter`（反击）、`hurt`（自伤）、boost 目标 `random_idle`；灼烧 `pct` 烧敌人现有体力且烧不死。军师战意：`buff` 效果（atk / def 每层，max 层，turns 回合），`Battle.buff`，郭嘉 / 荀攸 / 贾诩 / 蒯越的 1 AP 技能。主角卡：`cards.json lord_forms`（grants 卡池 / forms），每章发一张（第一章：第二格 = 出生选择后的第一个剧情格，`Quests.move`；其他章：第一格，`Quests.start_grant`，由 `map_screen._grant_chapter_card` 在进章节时发）（`grant_lord_form`，第一章（每周目）发固定的默认主角卡 `lord_forms.default`（`lord_default`「主公」：普通主公、默认立绘、无加成，不在 grants 里），第二章起随机没拿过的，都有了随机任意；第一格之前没有主角卡。**所有卡通用的记忆规则**：结局时 `commit_history` 记下卡和等级（`cleared_copies` / `cleared_lord_copies` / `cleared_forms`），`new_lap` 不继承卡本身（`owned` / `lord_forms` / `dupes` 清空），主公等级 `lord_copies` 保留；之后再得到某张记得的卡（抽到或剧情）= 升一个品阶（Lv，`next_tier_copies`：1→4→16 张）且卡也拿到（`grant_card` 用 `permanent_copies`，`grant_lord_form` 看 `cleared_forms`）；`move` 返回 `[{form, dupe}]`；主公永远算上场卡：招贤（`recruit_offer`）按 `fielded_chance` 也会抽到主公本体，拿主公时（`take`）顺带拿回一张记得的、本路线没持有的主角卡版本（`_draw_lord_form`），等级本来就 +1；第一章在首格 CG 与剧情看完后由 `map_screen._pending_forms` 依次弹出 `LordReveal`，其余章踏上即弹；章节回顾不再发卡），`SaveData.lord_forms` / `lord_form()`（最新一张生效，加体力攻击与技能，`art: true` 时立绘 = 卡 id）；`SaveData.is_north()` 同时看 run_records 和 flags；demo 加 `--forms` 发齐所有主角卡。难度递进：`Quests.ramp` = 本周目已通关章数 × `battle.chapter_step` + (周目 − 1) × `battle.lap_step`，加进 `Quests.mods` 的 enemy（回放旧章不吃章节部分）。状态：`cleanse` 效果（技能「解毒」）；精英 / boss 敌人至少一个混乱 / `ap_drain` / `burn_party`（按全军体力比例掉血）/ `poison_party` 招式（测试守着）；**按比例掉血是敌人的事**（用户要求，免得卡练好之后敌人太弱）：敌人招式 `pct` = 这一击另加我军最大体力的比例（吃减伤），目前只加在 boss 的蓄力大招上（0.1）；`poison_party` = 我军中毒，每中一次 +1 层（`poison_max` 默认 3），每层每回合扣最大体力的那个比例，解毒能解，目前是名字带「毒」的招式。不是每个敌人都加；`battle.affixes` 里 `confuse` / `burn_party` / `ap_drain` 是状态词缀。战斗中换人（选卡界面 = PickOverlay）：`battle.swap_ap / swap_from_round / swap_per_round / swap_ready`（v3：1 AP、第 1 回合起、只能换没出手的、新人当回合能出手、登场必触发兵种小技），换下的人本场不能再上，这一格用新人自己的攻击和他的部队，全军体力条跟着变、按比例保留（用户要求；战后回地图也按比例换算，`Quests.rescale_hp`）；`Battle.swap`、`SaveData.swap_roster`，demo `--demo=swap`（加 `--done` 执行换人，`--drop` 模拟把卡拖到另一位队长身上；换人界面里卡可以拖到任一位能换的队长身上换下他，「上场」按钮在右侧最上面）。全局 `battle.enemy_hp_mult` 只乘敌人血量。
- **前尘整备**（仿兰斯10 周目特典，用户要求）：第二周目起，`Game.new_lap` 先开 `PrepScreen`，点「出发」→ `SaveData.apply_prep` → 开门大吉的宝箱 → `Game.start_lap` 开地图（中途退出不存档）。前尘点 = 走到过的不同结局数 × `battle.json prep.per_ending`，不消耗，每周目重新分配，上周目的选择默认带上（`perks` / `prep_cards`，页面按点数裁掉放不下的）。**名字一律四字成语**（测试守着）。特典 `prep.perks`（id / name / cost / max / desc，可带 `mods` 进 `Quests.mods`）：富甲一方、开门大吉（1 点，出发先开宝箱，只出两线通用的卡）、运筹帷幄、满载而归、化险为夷（敌人 −15% = 降一级难度，难度解锁的剧情照样触发；**不放直接加属性的特典**，比如加体力，用户要求）、招贤纳士（**第二周目起公共武将默认不进招贤和宝箱**，`SaveData.public_open`）、慧眼识珠、先声夺人、多多益善（3 点，`offer_extra`）、坐镇中军（4 点，**主公可以不上场**，不是战斗中换下：`lord_out` + `lord_fields` / `field_leaders`，战斗和体力条用 `field_leaders`，整备主公详情里切换）、源源不断（10 点，每回合 AP +1，`ap_round`）、未卜先知（8 点，？事件自己选：地图 `event_random` 分支看 `perk("foresight")`）、三顾茅庐（3 点，**每个特典都得有实际效果**（用户要求）：随机摆牌的招贤格可重摆一次 —— `Quests.offer_rerollable`、`PickOverlay.reroll_text`、`offer_rerolled`；摆本章固定名单的格子（江东征兵，`Quests.fixed_list`）**不随机**，选完后同一份名单再摆一次再选一张，`resolve` 里设 `offer_rerolled` + 地图 `_resolve` 重开）、化敌为友（3 点，打赢有卡的敌将**一定**掉他的卡：`chest_after_battle` 里没掉宝箱也单给这一张，满级除外）、功成名就（5 点，`merit_earned` ×1.5）、兼收并蓄（`pick_again` + 地图 `_resolve` 重开、战后 `_pick_chest`）、猛将如云（8 点，`party_slots`）、天下归心（`all_generals`）。带卡：`prep.cards` 只挑几张（用户要求）：名将**都是 SR、一个兵种一个、2 点、只放主线里不出现的人**（剧情 / 事件 / 敌人 / 结局文字里都不出现这个名字，不只是卡 id：陆逊、吕蒙主线里有；现在只有姜维、黄月英；不要关羽张飞这种主线已有的），名兵每个兵种一个势力精兵、1 点；都有四字名，测试守着。带 scope 的（北线 / 南线）先进 `prep_pending`，出生地选定时 `route_prep_cards` 才发。记得的卡：兵 1 点、将 2 点。宝物只摆几件（`prep.relics`，1–2 点），买的进 `kept_relics`，第一章就带着；记得的卡（`cleared_cards`）分招兵买马（兵）/ 旧雨重逢（将）。测试 `tests/test_prep.gd`，截图 `--demo=prep`；任何 demo 加 `--perk=a,b` 买特典，`--demo=pick --open` 直接打开招贤。
- **Card stats are plain face numbers**: every card has `hp` and `at` (铜 values; no troop base, no bonus, no rarity multiplier), each in **40..100**
  (the plainest soldier is 40/40, full is 100/100); a fighter has `at` > `hp`, a clerk (策士 / 后勤) `hp` ≥ `at`. **Rarity is where hp + at falls**
  (`gacha.rarity_bands`): N soldier 80~99, elite soldier / C 杂将 100~124, R 125~149, SR 150~174, SSR 175~200; the opening lord is 65/60 = 125 (the weakest R).
  A test enforces it for every card and lord card. 升级 multiplies both by the tier (铜 1.0 / 银 1.3 / 金 1.75 / 神 2.4), so SR at 铜 ≈ C at 银 and
  SSR at 铜 ≈ C at 金. Soldier copies join the unit as members and fall off smoothly: copy i counts `floor + (1-floor)·decay^i` (`gacha.soldier_decay` 0.8, `soldier_decay_floor` 0.5 → 1, 0.9, 0.82, 0.76 … never below 0.5). A hero who will have several cards (`gacha.versions`: 孙策 / 周瑜 / 赵云 / 郭嘉 / 关羽 / 诸葛亮 / 曹操 …) starts at **R**; later versions climb to SR / SSR (a test checks the table). **吕布 / 诸葛亮 / 鲍三娘 are never drawn the first time** (`pool: false`): the first one comes from beating him (an enemy's `drop` names the card beating it can hand over — default its `card`, which also sets its stats, so 诸葛亮's fights keep `card: han_shuzuo` and write `drop: zhugeliang`) or from the story / her event; once had, they come back through `seen` like any card. A card with `first_win` (吕布) is won only by beating its owner: the first time ever (not owned, not in `seen`) it is always in the chest; afterwards it is a normal history-pool card. A new card: pick the band for its rarity, split it
  by role, keep each number 40..100. **An enemy's hp / at come from its card** (`battle.enemy_from_card` × the card face; the enemy table has no hp / at for them — only the moves, actions and resists); a showpiece that must be hand-tuned (吕布, `lose_goto` fights, 野猪 / 老虎 without a card) writes its own `hp` / `at` in `enemies.json` and keeps them. Strength then = card × tier (普通 / 精英 / 首领) × stage (chapter curve + position + `scaling.chapter` for 第一章, one coefficient for both routes). The enemy table (`enemies`) is in the old magnitude and is converted on entry (`battle.unit` hp ÷ 9, at ÷ 1.4),
  every damage is × `battle.damage_mult` (0.1556), and enemies get one more coefficient per tier (`battle.enemy_coef`: normal 1 / elite 1.5 / boss 2,
  必败 `lose_goto` fights (and every 吕布 fight) 2 — 普通 / 精英 / 首领: hp and attack both take the whole coefficient (必败 / 吕布: attack only its square root) (`Quests.enemy_scales`); `scaling.tier` is 1 so the two do not stack).
- **护甲 (armor)**: an enemy can write `"armor": "<id>"` instead of its own `phys_resist` / `magic_resist`; the table is `battle.json armors` (藤甲 兵刃抗性 80% / 谋略抗性 -100%, 重甲, 木器, 蛮甲, 火神, 道术, 谋士, 符水, 皮毛, 无双 = every 吕布 fight: 兵刃抗性 40% / 谋略抗性 -50% — each with a `hint`). A negative resist is a weakness (−1.0 = double damage). 灼烧 and 中毒 (贾诩's `poison`: stacking layers of % max HP a turn, up to 5, can kill) share one resist, the magic resist, taken when they tick (`Battle._dot_resist`) — user rule. **灼烧 is strong: multi-turn fire only on the real fire masters** (周瑜 火攻 / 赤壁业火, 诸葛亮 火计); anyone else gets a 1-turn fire (祝融, 孙尚香 火箭) or 中毒 instead (毒箭, 鸩酒) — don't hang a burn on an ordinary skill. **An enemy with no `armor` takes its card troop's (`battle.troop_armor`: 步兵 盾甲 兵刃抗性 30% / 谋略抗性 −30% (user rule: shield troops ≥ 25% phys, weak to magic), 枪 札甲 25 / −25, 骑 轻骑 −25 / +25, 弓 轻装 −30 / +20, 贼·后勤 布衣 −30 / 0, 策士 谋士); hand-written `phys_resist` is only for enemies outside that table (beasts, lord troops).** **Late elites / bosses** (`battle.late_armor`, user rule: from 黄忠 / 太史慈 joining — `from_x` dongui 39 / beihai 47 — and every chapter from `from_order` 4 on) without their own `armor` swap to a heavy one by troop: 步 / 枪 重甲 50 / −25, 骑 / 弓 / 后勤 精甲 40 / −40, 贼 蛮甲, 策士 谋士 (`Quests.late_armor` / `with_armor`; `mods.armor` → `Battle.start`; the map intel shows it too). 弓兵 `sheji` / `volley` carry `shred` (−8% / −12% both resists, stacking with every use and with the archer passive up to `battle.archer_resist.max` 50%, applied before the shot; a resist is never cut below `archer_resist.floor` −25% (user rule), a deeper weakness stays as it is). Archer skills never pierce (user rule) — `pierce` is left to bandits and a few lord / special moves. Make resists stand out — extremes the player has to answer by changing cards, not 10–20% everywhere. Shown in the battle intel (`map_screen._resists`, weaknesses in red) and on the battle screen next to the HP numbers (`battle_screen._armor_label`).
- **Enemy**: `hp, at, actions, resists, portrait, card (its chest may hold it: 25%, bosses/elites 50%), moves[]` — move
  `power (0 = no hit), weight (0 = only after a charge), confuse, rage, heal, ap_drain, burn_party, pierce,
  charge (wind-up announced a turn ahead), when: "half", once`. Make fights strong; make their cards modest. The charged move (`weight: 0`) hits
  **3–4× attack** (user rule: the wind-up must be worth fearing); only the test-only `hulao` 吕布 (`lvbu`) stays at 2.2 so `test_hulao_is_hard_for_naive_play` keeps its floor.
- **Relic 宝物** (`cards.json` relics): found during a chapter; all carry into the next chapter (`kept_relics`), but ones found in the current chapter reset on a restart; `rarity common/rare/curse, icon, desc, mods {...}, after_win`. Mods are
  summed by `Quests.mods(save)` and passed to `Battle.start(..., ambush, mods)`. New mod ⇒ read it in `battle.gd`.
  A story square can hand one over directly on arrival with `"relics": ["<id>"]` (same shape as `"cards"`; a
  `choose` option can't do this — it only has `label/goto/record/card` — so route the option to a one-line event
  square carrying the `relics` field instead, both branches rejoining the next common square).
- **Local pools (按地点的池子)**: a `treasure` / `recruit` square can carry its own `soldier_pool` / `recruit_pool` (card ids) — `Quests.pools(q, save, sq)` lets the square's list win over the chapter's, a chest then holds only that place's soldiers (`SaveData.chest_offer`) and a recruit square shows `gacha.offer_size` random cards of its own list. They travel with a shuffle (`CONTENT`). Keep it to at most two soldier pools and two recruit pools per chapter (第五章: 宛城·汉水·新野 / 襄阳; 第三章: 鲁阳 / 洛阳·长安) — squares of one place share the same list; the stats table counts the distinct lists; a square with no list uses the chapter's pools as before. `test_a_squares_own_pools_...` checks the ids.
- **Square types (格子种类)**: 7 种 `type`（`ui.json map.glyphs / type_names / type_colors`；`Quests.TYPES`），再加战斗的两个变体，地图上共 9 种图标：

  | type | 地图字 / 色 | 玩家看到什么 | 常用字段 |
  |---|---|---|---|
  | `event` 剧情 | 事 | 台词一行一击；`cards` / `relics` / `difficulty` 进格自动给，没有选项 | `text` `portraits` `cg` `cards` `relics` `difficulty` `record` |
  | `choose` 抉择 | 选 | 台词后选一个选项，选项的 `card` 入队，`goto` 决定走哪条路 | `choose [{label, goto, card, record}]` `prompt` |
  | `battle` 战斗 | 战（红） | 台词（可有）→ 战斗，赢了才能继续；`boss` 变「将」（紫）、`elite` 变「精」（红） | `battle` `boss` `elite` `ambush` `lose_goto` `beatable` `record_win` |
  | `treasure` 宝箱 | 宝（金） | 几张兵卡，只能拿一张；有 `soldier_pool` 就只出这个地点的兵 | `soldier_pool` |
  | `recover` 回复 | 休（蓝） | 台词（可有）→ 体力回满，累积技能 AP 加价和限 1 次技能重置 | `text` `portraits` |
  | `recruit` 招贤 | 募（绿） | 台词（可有）→ 接见豪杰，只能收一位；有 `recruit_pool` 就只出这个名单（每次随机几位），`prompt` 可改提示 | `recruit_pool` `text` `portraits` `prompt` |
  | `mystery` 奇遇 | ？（蓝） | 进格时从事件池抽一个随机事件（`event_pool` + `event_scope` + 本章 scope + universal，每次重抽，本轮不重复），事件里有选项（打架、受伤、给卡、给宝物…） | `event`（固定事件，见下） |

  `mystery` 带 `event` = 固定事件：地图上显示该事件自己的字和颜色（险 / 威 / 庙 …），**只给确实是设计好的固定入口用**——现在只剩第二章的「高级宝箱」（三个箱子里恰好一个是高级的，测试守着）。故事性的固定剧情一律用 `event` 格（`cards` / `relics` / `difficulty` 写在格子上），要选人用 `recruit` 格（借将）；其余「可有可无」的事件让它随机。一个只属于某一章的事件，`scope` 写那一章的 quest id，别写 `south` / `north`（否则别的章节也会抽到，救祖茂在第一章冒出来就是这样）。第一章 `prologue` 是南北共用的一个 quest：只属于这一章的事件还要写 `"route": "south"` / `"north"`，不然北方出生也会抽到（二乔、于吉在北线冒出来就是这样；`test_the_north_birth_never_draws_a_south_event` 守着）。
  战斗格的 `lose_goto`：输了转去的格子（吕布 / 华雄的必败戏）；`beatable` = 仍是正常强度的战斗。**打输了才走 `lose_goto`（体力归零或回合用尽都算输，用户 2026-11-08）**：主动撤退留在原格、可整备重打（`Quests.holds_unless_beaten`，`Game.battle_finished(won, beaten)`；`--demo=quest --id=<quest> --at=<square> --go --retreat`）。战败能改走好线的战斗（比武·关羽）一定写 `beatable`。`shuffle` 组只搬 `CONTENT`（type / label / battle / event / text …），不搬 `cards` / `relics` / `choose`。

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
  `battle.event_scale` (battle.json) scales every event at resolve time — `damage` / `heal` multiply the written share, `poison` is the share lost,
  `lose_soldier` multiplies the count (user: 随机事件影响过小 → 2.5 / 2.0 / 0.5 / 2). Tune impact there, not by rewriting story.json numbers.
  `difficulty` / `danger` may be negative (难度下降 floors at `battle.difficulty_min`, -1 = enemies -30%; 险 floors at 0); `merit` ±n changes 战功 (never below 0).
  The user wants big swings in ？ events: the universal `fate_star` 天象 / `fame_spread` 名声 / `war_fund` 富商 / `scout_report` 探马 / `old_general` 白发老将
  each roll between 难度 ± / 险 ± / 战功 ± / 宝物 / 点化 — add more of that kind rather than small HP nudges.
  More swing effects: `fate` ("good" / "curse" / true = any other — swaps this run's 天命), `downgrade` n (n random generals, not the lord, drop a tier),
  `ambush_all` (true: every unvisited non-boss fight this chapter is an 埋伏; false: clears the rolled ones — a square's own `ambush` stays).
  Events using them: `fate_shift` 改命 / `camp_rift` 军中失和 / `intel_leak` 军情泄露 / `fortune_teller` 算命先生 / `omen` 凶兆 (universal).
  天命 rarities (relics.json fates): common 吉 / rare 大吉 / curse 险中求 (double-edged) are offered at a chapter's start; **bad 凶** (pure drawback:
  衰弱 涣散 破甲 错失天时 断粮 凶星) and **divine 天授** (天命所归, far stronger) never are — only an event's `fate: "bad"` / `"divine"` hands them out
  (`fate: true` = any but 天授). 天命所归 is 改命's `weight: 0.25` option. An option's `weight` is kept by `GameData` since then (it used to be dropped,
  so every option was equally likely). **Event outcomes are animated** (user rule: 随机事件最终效果应尽量动画化): `_apply` returns `out["fx"]`
  (one entry per visible change: hp / difficulty / danger / merit / fate / level (升级 / 降级 shown in 级, never 阶) / lose_soldier / lose_relic / ambush / refresh / rest), and
  `MapScreen._choose_event` plays them in `EventFx` (scripts/ui/event_fx.gd) before the CardReveal / RelicReveal. A new effect = an fx entry in
  `_apply` + a case in `EventFx._one`.
  **整备 keeps the HP share** (user rule): `save.damage` is HP lost in points, so a party change in `PartyOverlay` (in / out / swap / 自动编成 /
  宝物 worn) calls `Quests.rescale_hp` from `_rebuild` — 50 % stays 50 % of the new bar; 攻击 just follows who is out. `--demo=party --hurt` checks it. **自动编成** (`SaveData.auto_party`): generals with their 大招 left first, then ones whose 大招 is spent, soldiers last — a spent general makes way for a fresh general, never for a soldier (user rule). `--demo=eventfx [--fx=hp,diff,fate,divine,level,ambush,merit,lose]` shows it. Fate emblems: 512 px transparent PNG in `godot/data/art/fates/<id>.png`, prompt via `FATES` in `art_prompts.py`.

- **Chapter recap**: finishing a chapter shows `Quests.recap(save)` — battles won, cards gained (collection diff since the
  run began), relics picked up, and the run's key lines. Mark what matters with `record` (square, when resolved),
  `record_win` / `record_lose` (battle squares), `record` on choose options, or a `{"record": ...}` event effect —
  short lines like 「董白：留下」. These lines are also the hook for later cross-chapter branching.
- **Between chapters**: recap (战功 paid once, spent on a draw or an upgrade) → `Quests.complete` turns the run's records
  into permanent `save.flags` → the chapter-end page (its ？小故事 live in `godot/data/side_stories.json`; the old
  interludes.json was merged into them) → the next chapter's title card (with the quest's `subtitle`, e.g. 「半年后」 — the journey from 富春 to 孙坚 takes about half a year;
  孙坚 had left home well before, and he meets the hero for the first time in chapter 2). The 部队 button on the map opens the party screen.
- **Chapter-end page** (user rule; `MapScreen._complete`): the chapter's own CG fills the page — a warm scene of that chapter's core people, **all on the left ~45%**, no hero, the right side left empty (sky / water) — and the menu sits straight on the picture's right side (no dark panel; title lines outlined), every option a row with only its name and 战功 cost (no reward written): 本章回顾 (free, the old recap text in a popup) and each ？小故事 (10, re-reads free) first, then 抽一次卡 (5) and 点化 (10); 进入下一章 at the bottom (user rules). The same picture is a playable card (user choice) — **not** handed over on the page: user rule, an extra ？小故事 of that chapter gives it, opening only once the route's next bad end has been reached (requires that ending's line + the route's unless; 南线第一章: 「针脚」 needs 结局一 · 玉碎, its CG the page's picture, the hero looking on from the doorway — why he is not in it). `side_stories.json` `chapters` {quest: [{cg, requires/unless}]}, the card in cards.json (pool false, scope = route), its portrait = the CG's left 55% ingested as a portrait with a wide head (`--face 0.45 0.42 --head 0.21`). Done so far: 南线第一章 `rc_fuchun` (吴夫人、孙权、孙尚香; story 针脚 after 结局一 · 玉碎), 北线第一章 `rc_wuji` (张夫人、小甄宓 at the abacus on a snowy night; story 雪夜算盘 after 结局二 · 覆巢), 南线第二章 `rc_taodong` (董白 playing 石头剪刀布 with a 宫女 by the river; page and story need 董白：留下, story also 结局三 · 同归, her own bad end — `requires` may be a list; user rule: the gift waits for the bad end of the card's own people when they have one). The whole recipe is the `sanguo-chapter-page` skill. Draw the people small and full-length inside the left 40% (the card crops the full height, ~0.43 of the CG's width, so the whole group must fit that); prompt Han clothes explicitly (交领右衽, no 旗袍 / 立领 / 盘扣) — the model drifts to qipao. `--demo=recap1` shows it.
- **？小故事** (user rule: every chapter gets one or more, Rance-style 整备 ？ events, may have nothing to do with the main plot): `godot/data/side_stories.json`, keyed by the chapter after which they open; read from the gold 「？ 小故事 (n)」 button in 整备 (top right, pulses while any are unread, hidden until a chapter is done) and in the chapter recap (`SideStoryList`, played with `InterludeOverlay`). They may also tell what the main story only mentions in passing (user rule: how 曹操 turned on the north, how 王允 died, how 马腾 died … ids `b_*`, told from the other side, often with a CG) — check the chapter's own lines so the telling agrees with them. Tiles show the story's name and price, never the reward (user rules: opening one costs 战功; the reward is only told once it is opened): after the story, what it gave flips in with the game's usual moments (`SideStoryList.reveal`: the 入队 CardReveal for 点化 / cards, then RelicReveal for 宝物). Pricing (user rule: a draw 5, a 点化 10, every ？小故事 10; chapter 1 earns 7–12 战功): the reward is 点化 of its lead +2 张, a 宝物 (common or rare), or a card the pool never offers (王允 / 程昱 / 公孙瓒 / 韩馥 / 马腾, the 幕后 stories). `Quests.open_side` pays and rewards on opening (quitting mid-story loses nothing); a 宝物 already held refunds the cost; re-reads are free; `save.side_read` remembers them for the 周目. Every story must name a reward (`upgrade` / `relics` / `cards` / `merit`). Art: every story names a `cg` — `ss_<id>` for the everyday ones (planned: prompt in `pics/prompts/overrides.json`, listed by `build_next` at tier 7 with the 奇遇 pictures; until drawn the story just shows portraits), `b_*` / `rc_*` / `sx_*` for the drawn ones; a new story gets its `ss_` key and prompt in the same change. Only people in the party by the end of that chapter; anyone who joins by a choice needs its line in `requires` (tests check portraits and that every requires/unless is a line story.json records). `--demo=party --side [--read]` shows it.
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
- **No long runs of story squares.** Three story squares in a row want a fight or a rogue stretch: add a **lane group** (2 columns: battle lane on top, rogue lane — `mystery` / `treasure` / `recruit` — below, both rejoin at a y1 trunk square; rows move ±1 per step, so a lane group must be followed by a y1 trunk square) or a **small fork** (1 column: one battle square + one treasure / mystery). Insert columns by shifting every later `x` with a script (assert unique `(x, y)` among open squares); update the fork-anchor list in `test_the_filler_forks_...` (`tests/test_data.gd`) when you add or move a trunk square.
- **Tier mix.** More normal than elite than boss on the longest path. A plain trunk fight may be normal; lane tops end on an elite or boss.
- **Named generals as bosses.** Some early in the chapter (as the opener of a choice branch, e.g. 文聘 / 苏飞), some in the second half (张允, 蔡瑁), optional ones inside a lane (刘磐). A new enemy needs: a card (`pool: false`) + enemy with a move that confuses / drains AP / burns the party (a test checks elites and bosses) + a scenario (`art` reuses an existing battle picture) + a portrait brief in `CARD-DESIGN.md` §7 and `tools/art_prompts.py` PORTRAITS + an entry in `Kit.ALIASES` (`scripts/ui/kit.gd`). Use characters that already have a portrait when you can.
- **Share CGs between the routes.** A scene both the south and the north run through (洛阳 burning, a 诸侯 banquet, 董卓 / 吕布 moments) gets ONE route-neutral CG key shared by both routes' squares (several squares may name the same key) — draw the scene, not the lord or a route's own companions (赵云 / 郭嘉 / 孙策 / 周瑜) — a shared CG may have no people in it at all. Only moments that are really one route's (its own companions, its own lord) get a route key (`n<chapter>_…` for the north). Before writing a new CG prompt, grep `story.json` for the other route's picture of the same moment and reuse its key when it fits.
- **Lead in to every fight.** A battle right after a story beat needs lead-in `text` (who the enemy is, why they are here) and a wired `cg`; a character's first appearance gets a CG. Look at delivered art and rewrite the lines to match it.
- **Good ending = people join.** The best ending of a chapter hands over the defeated side's people (`cards` on the ending-adjacent event: 第五章 破局线 gives 蒯越, 刘表, 刘磐).
- **Pools: at most two soldier pools and two recruit pools per chapter** (see *Local pools*); same place = same list.
- **Shuffle groups: one or two per chapter** (`shuffle` in the quest). A group is a few lane-first squares of one fork family — a battle square and a `mystery` / `treasure` / `recruit` square with the same predecessor and the same `requires` / `unless`. Only `CONTENT` moves (type, label, battle, boss, elite, ambush, event, text, portraits, cg, prompt, soldier_pool, recruit_pool): never hang a `record`, `relics`, `cards`, `choose` or `lose_goto` on a shuffled square. Eight groups in one chapter (第五章 once) is too many.
- **Stats.** After touching a chapter: run the tests, then `python tools/chapter_stats.py --write` (the pre-commit hook does it when story / cards / art data is committed). Only the generated columns and sections refresh; the 入队 / 分叉点 wording and each chapter's own section are hand-written — update them.

## Story voice → `story-voice.md`

The voice, the cast, the hero's quirks and what happens in every chapter (both routes) live in **`story-voice.md`** next
to this file — read it before writing or changing any story text. The rules that are never optional:
- Adult game: war, death and romance / sexual tension **between adults** may be written directly. **Nothing sexual or
  romantic-tinged ever touches a character under 18** (甄宓 before adulthood, 孙尚香 as a child, 孙权, 汉献帝, anyone 13–17).
- The hero stays a clown (逗比), never read 三国演义, knows only the famous names; each named character's first appearance
  gets one `{lord}（内心）：` aside. `docs/STORY.md` is the outline; `story.json` wins where they differ.
- **The hero remembers nothing of earlier 周目 / badends（用户 2026-11-08）.** A branch an ending unlocks stays a gate only: his lines there never say 「上一回……这一回……」 about what happened in another run. Same-run callbacks and 上辈子 (his modern life) are fine. Dreams may carry it, but veiled: a fragment and a feeling (「不知道为什么……」「好像梦见过」), never a retelling of what happened, and never the word 周目.

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

卡牌张数规则：任何一次获得（抽卡、宝箱、剧情给）都只 +1 张；新周目再拿到以前通关过的卡，是「永久记录的张数 + 1」，即便已是银卡也只 +1，不会直接升一阶；只有点化（战功或事件）一次 +3 张（`gacha.upgrade_copies`）。通关结算 `commit_history` 对永久张数取最大值，不相加。

埋伏：普通战斗（非首领、非精英）每局开章时按 `battle.ambush_chance`（0.5）随机抽一半成为埋伏，结果存 `save.ambushes`（随局保存、每局不同）；格子上写死的 `ambush: true` 仍然生效（如第二章「李儒伏兵」）。

敌人强度系统（`battle.json` → `battle.scaling` / `battle.enemy_coef`，代码 `Quests.target_power` / `_scale_for` / `enemy_scales`）：强度 = 血量×攻击×行动数，**公式只管整体难度，不管是哪张卡、精英还是首领**。第 N 章（`order` 里的序号，从 0 起，南北线同序，序章也爬）第一列的强度 = `strength × base × (N + offset)^exponent × 本章系数`（现在 base 0.1 = 第一章开头，指数每章变：exponent_first 2.06 线性降到 exponent_last 0.8（第 12 章起不再变），offset 0.206，第三章开头 9.7（第二章 3.2、第四章 18.6、第五章 29.0、第十二章 101.4；2026-10-29 用户要第三 / 四 / 五章约 9 / 18 / 30，只调了前期指数）），最后一列 = 同一公式的第 N+1 章，中间按列位置线性插值，所以一章的末尾正好是下一章的开头。每场普通战斗的血和攻各乘同一个数，把它的强度正好放到这一列的曲线上（卡牌自己的强弱不进公式）；精英 / 首领 / 必败（`lose_goto`，如虎牢关吕布）再乘 `enemy_coef`（1.25 / 1.45 / 2）。`strength` 整体加难度，`chapter` 是个别章节的手工微调，没写的章节（含序章）用 `chapter_default`（现在 1，表里的数已经是最终值）。周目难度、险、词缀仍叠加在后面。`tests/test_balance.gd` / `test_quests.gd` 有防反转 / 接缝测试。怎么按用户给的几个数校准整条曲线见 `sanguo-test` skill 第 4 节「怎么校准整条难度曲线」。

难度目标：整体胜率约七成（每次战斗；普通战 ~82%、精英 ~70%、首领 ~53%，序章 ~89%、之后各章 75% → 55% 缓慢往下）。当前参数下 bot 一周目 24 局通关 17 局（71%）。想更易 / 更难：改 `strength`（或 `base`）；扫参数用 `SIM_LAPS=4 SIM_RUNS=16 SIM_ROUTE=south godot --headless --path godot --script res://tests/sim_balance.gd`，旋钮 `SIM_STRENGTH SIM_BASE SIM_EXPONENT SIM_OFFSET SIM_ELITE SIM_BOSS`；各档胜率汇总可以把输出里每行的 `n=` 与 `win=` 按档加权平均。个别敌人（如 `taodong:fire`）比同章其他敌人强得多，会拉低波动，单独压它的 hp / at。

暴击：`cards.json` → `battle.crit`（player_chance 0.12 / player_mult 1.6 / enemy_chance 0.08 / enemy_mult 1.5），每一击单独掷骰；宝物可用 `mods.crit` / `mods.crit_mult` 加我方几率和倍数（还没有宝物用）。事件 `hit` / `enemy_hit` 带 `crit`，战斗界面显示金色「暴击」飘字。想更随机：加大几率或倍数。期望伤害：我方 +7%、敌方 +4%，模拟验证一周目通关率仍约 80%。

测试与难度校准的完整流程（跑测试、截图、平衡模拟 `tests/sim_balance.gd`、`battle.scaling` 的唯一旋钮 `strength`）见 `.claude/skills/sanguo-test/SKILL.md`。
？事件：开章时就给每个 ？ 格发好事件（地图上显示事件名，每局不同，`Quests._roll_events`），到达格子时就按 `weight` 从可触发的选项里真实随机抽好一个（`Quests.rolled_option`，存在 `save.event_rolls`），格子上只有一个按钮，按钮上写的就是抽到的选项，点它执行（结果第一行写「随机到了：选项名」；不要写「听天由命」或「抽取结果」之类的按钮）（`battle.event_random`，`Quests.random_option`）；通用坏事件 14 个（`bad_*`，scope universal）。战斗手感 `battle.attack_mult` 1.1 / `hp_mult` 0.9（双方同时生效）。

技能组合（kit）：一张卡默认用兵种的 kit（`cards.json` kits / kit_default）；卡上写 `"kit": "<id>"` 就换一套。`strategist_mage`「策士（攻）」= 第一技能计略（谋略攻击）而不是献策，给攻击型策士用（张修·妖道 `xuanjizi_card`，用户要求）。
休整分叉（用户要求，北线第二章起）：休整格不再是独路，而是**接进紧跟着的那个"打仗 / 捡宝"岔路**，不另加格子：休整 → 原来的战斗路（上，y 0）／一个宝物格（同一段剧情 + 一句开箱，可以是原来就在那儿的宝箱格）→ 原来的捡宝路（下，y 2）。两边剧情一样，只是奖励不同。后面没有战斗岔路可接（虎牢关前，紧接吕布）就不岔，照旧直接休整（用户要求）。事件 `color` 必须是调色板里有的名字（没有 yellow，用 amber），`test_every_event_colour_is_in_the_palette` 守着。
