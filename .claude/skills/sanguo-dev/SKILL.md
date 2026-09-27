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
| `pics/` | raw art (`source/`), `art.json` (framing), `ART-NEEDS.md` (generated), `CARD-DESIGN.md` (art specs) |
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

Demos (`Game.demo()` in `scripts/game.gd`): `title`, `map`, `pick`, `choose`, `event` (左慈 on a ？ square),
`relics` (宝物 pick), `tiers` (铜/银/金 frames), `ch2` (虎牢关 fork), `battle`, `fight`, `cards:id1,id2,...`.
Demos walk square ids — when you insert or rename squares, update their walks (and `walk_to` in tests).
Screenshots of overlays look washed out because the PNG keeps alpha; in the game the dim is dark.

Art: put the original in `pics/source/...`, add/adjust the `pics/art.json` entry, run `sanguo-art` (from the repo root).
Framing: `face` = face centre [x, y] as fractions; `head` = head height / image height. **Bigger head ⇒ smaller figure**;
smaller face x ⇒ figure moves right; bigger face y ⇒ figure moves up. Enemies share their card's portrait key.

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
- Never commit with failing tests: chain `... | grep passed` checks don't stop `&&` — look at the result first.

## How the game is modelled (add things through data)

- **Card** (`cards.json` cards): `name, rarity (N = soldier, R/SR/SSR = general), troop, bonus {hp, at}, skills,
  person (shared portrait / one version in a party), pool (false = story or drop only), troop_skills (false = own skills
  replace the troop's)`. Leader stat = 5 × own + troop members; soldier copies decay ×0.6; generals repeat → tiers
  铜 1 / 银 2 / 金 4 copies (`gacha.tiers`, frame `tier0/1/2` in ui.json).
- **Skill**: `cost, cumulative (+1 AP per use), uses (1 = 限1), effects[]` — `attack/magic {power, hits, burning_mult}`,
  `heal`, `guard {cut}`, `boost`, `stun {chance}`, `break`, `ap`, `burn {pct | power, turns}`. Once-per-battle damage
  skills (大招) cost ≥ 3 AP (a test enforces it).
- **Enemy**: `hp, at, actions, resists, portrait, card (its chest may hold it: 25%, bosses/elites 50%), moves[]` — move
  `power (0 = no hit), weight (0 = only after a charge), confuse, rage, heal, ap_drain, burn_party, pierce,
  charge (wind-up announced a turn ahead), when: "half", once`. Make fights strong; make their cards modest.
- **Relic 宝物** (`cards.json` relics): per run; `rarity common/rare/curse, icon, desc, mods {...}, after_win`. Mods are
  summed by `Quests.mods(save)` and passed to `Battle.start(..., ambush, mods)`. New mod ⇒ read it in `battle.gd`.
- **Quest** (`story.json` quests): squares `{x, y, type, label, next, text, portraits, cards, choose, battle, boss,
  elite, ambush, event, lose_goto}`; types `event choose battle treasure recover recruit mystery`. Moves only go right,
  one row at a time (a test checks). `soldier_pool`, `recruit_pool`, `event_pool`, `shuffle` (groups that trade
  contents each run). A run = one attempt: losing restarts it (cards, choices, 难度 kept; 宝物, 险, layout reset).
- **Event** (`story.json` events, for ？ squares; a square with `event` is fixed): `title, glyph, color, text,
  portraits, options [{label, effects, win}]` — effects `say, damage, heal, rest, poison (−⅓ HP), card, soldier,
  offer {from | generals + rates | soldiers}, upgrade (true = pick, "random"), refresh, relic, danger (险, run),
  difficulty (whole campaign), battle + ambush, chance {then, else}`. Text uses `{lord}` for the player's name.

After adding content: run tests, screenshot the relevant demo, fix layout overflow (e.g. three skills shrink the
battle cards), commit, push.

## Story voice

Comic, a little 擦边, never explicit. The hero is a 30-year-old office worker's soul in an **18-year-old** body in
chapter 1 (富春); the body ages with the story, so later chapters show him older (never younger than 18 — no sexual
framing of anyone under 18). 吴夫人 (later 吴国太) treats him like a son and lets him get
away with his flirting, cluelessly maternal — that contrast is the joke. 孙策: reckless, spear first, can't swim,
sulks at being left home. 周瑜: sharp (reads people, counts everything) but petty — keeps a **ledger** of what
everyone owes him. 孙坚: huge, jealous-ish, 虎皮 + 古锭刀. Chapter 1 富春 (孙坚's hometown, during his campaign
against 董卓; only the brother whose plan you pick joins) → chapter 2 讨伐董卓 (the other brother joins; 祖茂 vs 华雄 —
win: you throw your blade and get the 赤帻, lose: 孙坚 kills 华雄; 孙坚 joins; elite 董白; 吕布 raids the camp; 吕布's
chase is nearly unbeatable — lose: 三英战吕布, win: 难度 up + three chests; hand 董白 to 袁绍 for a relic (she's executed)
or hide her; 李傕 at the burning 洛阳; a spared 董白 joins).
董白: 董卓's granddaughter, a grown woman general (years of fighting in 西凉) with two hammers, loves a fight, a
striking figure (身材火辣). The text gives no number for her age, but she is always clearly an adult — never a 萝莉;
no groping of anyone unconscious or captive; comedy comes from her temper, her love of duels and the others' reactions.

Writing rules:
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
