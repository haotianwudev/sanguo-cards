# Working in this repo (Claude Code, Gemini, Codex, …)

**重开三国** — a Godot 4.7 Three Kingdoms roguelike card game (Rance X battles, quest maps walked square by square).
Everything is data: almost any change is a JSON edit, not code.

**Before changing anything, load the `sanguo-dev` skill** (`.claude/skills/sanguo-dev/SKILL.md`): the source of truth
for the data model, commands, rules and gotchas. Load the others when the task is theirs:

| Skill (`.claude/skills/<name>/`) | When |
|---|---|
| `sanguo-dev` | always — data model, commands, editing rules, story rules, git |
| `sanguo-test` | running tests, balance / difficulty tuning, screenshots |
| `sanguo-art-gen` | generating a picture (portrait, CG, battle, map panel) |
| `sanguo-art-ingest` | the owner hands over new art |
| `sanguo-chapter-page` | a chapter's end page and its ？小故事 card |
| `sanguo-voice` / `sanguo-audio` | battle voices / sound effects and music |

## Where to change what

| To change | Edit | Then |
|---|---|---|
| cards, troops, kits, gacha, lord cards | `godot/data/cards.json` | `sh tools/check.sh --fast` |
| skills | `godot/data/skills.json` | 〃 |
| enemies / battles | `godot/data/enemies.json` / `scenarios.json` | 〃 |
| relics, 天命 | `godot/data/relics.json` | 〃 |
| battle constants, difficulty, armors, tactics, 前尘特典 | `godot/data/battle.json` | 〃 (+ `test_balance.gd`) |
| chapters, squares, story text, ？ events, routes | `godot/data/story.json` (`python tools/fmt_story.py` after) | 〃 |
| endings | `godot/data/endings.json` | 〃 |
| ？小故事, chapter end pages | `godot/data/side_stories.json` | 〃 |
| UI colours, themes, frame rate caps, caches | `godot/data/ui.json` | screenshot a `--demo` |
| voices, sounds | `godot/data/audio.json` | `python tools/gen_voices.py` |
| "this id must exist" / "one of these values" checks | `godot/data/schema.json` | — |
| art framing / new pictures | `pics/art.json`, `pics/source/…` | `python tools/sanguo_art.py` |
| image prompts | `pics/prompts/*.json` | `python tools/art_prompts.py` |
| game rules (code) | `godot/scripts/core/` (pure logic: battle, quests, save, data) | tests |
| screens (code) | `godot/scripts/ui/` | `--demo=<name> --shot=…` screenshot |

## The loop

1. Edit (data first; code only when the rule itself changes).
2. `sh tools/check.sh --fast` — story.json format, import policy, every script compiles, all tests, generated docs
   up to date (≈40 s). Without `--fast` it also re-imports art.
3. Look at it: `--demo=<name> --shot=<png>` (list in the `sanguo-dev` skill, code in `godot/scripts/dev/demos.gd`).
4. Commit straight on `master`, staging **your files by path** (never `git add -A` — other agents work here too),
   `git pull --rebase`, push. CI (`.github/workflows/check.yml`) runs the same check.sh.

## Rules that bite

- Reply to the owner in Chinese; keep it simple and config-driven; balance isn't a goal unless asked.
- One implementation per rule: requires / unless go through `Quests.gate`, doc generators read `tools/facts.py`
  (the game's own answers) — never re-derive a game rule in Python or in a second GDScript place.
- Generated files are never hand-edited: `docs/CHAPTER-STATS.md`, `docs/ROSTER.md`, `docs/chapters/`,
  `pics/ART-NEEDS.md`, `pics/ART-PROMPTS.md`, `pics/SOURCES.md`, `godot/data/portraits/*`, the font subsets.
- Story text: speaker tags `@key`, 「」 and 『』, nothing sexual near anyone under 18 — see `sanguo-dev`.
- A new image goes in with its `.jpg.import` (`python tools/import_policy.py --check` fails otherwise).
