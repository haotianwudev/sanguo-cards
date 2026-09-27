# Working in this repo (any agent: Claude Code, Gemini, Codex, …)

Read **`.claude/skills/sanguo-dev/SKILL.md`** before changing anything. It is the single source of truth for this
project: where things are, the commands (Godot tests, demos, screenshots, `sanguo-art`), how cards / skills /
enemies / relics / quests / events are configured, the art checklist, the naming and story-writing rules, and git.

The short version:
- The game is the Godot project in `godot/`; everything is data in `godot/data/*.json`. The Python code in `src/sanguo`
  is the frozen old version, except `src/sanguo/art.py` (`sanguo-art`), which builds the game's art.
- Card names are `本名·外号/版本` (the part after `·` is the small tag on the card). Keep story continuity: grep for every
  mention when you add or rename a character. Dialogue uses 「」 and 『』.
- New art: `pics/source/…` + `pics/art.json` + run `sanguo-art`; never hand-edit its generated files.
- Run the tests (with a timeout) and look at a screenshot before committing.
