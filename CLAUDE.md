@AGENTS.md

## Claude Code specifics

- The skills listed above are in `.claude/skills/` and load with the Skill tool — load `sanguo-dev` first, every session.
- Godot: `F:\workspace\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe` (Git Bash path and test /
  screenshot commands in `sanguo-dev`). Always run Godot with a `timeout`.
- Write multi-line patch scripts to the scratchpad and run them (heredocs mangle `\n` and quotes); assert every
  replacement matches exactly once before writing.
- Don't build the Android APK after every change — only when the owner asks for a phone build.
