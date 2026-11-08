# 重开三国 (sanguo-cards)

三国题材的肉鸽卡牌游戏：战斗和走格子的战役节奏借鉴兰斯10（Rance X），武将收集借鉴三国群侠传。
你是穿越到汉末的现代社畜，南线从江东富春、北线从冀州无极出发，十二章，多个结局，多周目。

Godot 4.7（GDScript），横屏 1280×720，给手机和 Switch 做的。

## 运行

- **电脑**：用 Godot 4.7 打开 `godot/project.godot`，按 F5。
- **手机（安卓）**：
  ```bash
  cd godot
  godot --headless --path . --export-debug "Android" ../build/sanguo-cards.apk
  adb install -r ../build/sanguo-cards.apk
  ```
  导出模板和 SDK 的设置见 `.claude/skills/sanguo-dev/SKILL.md`。设置里有「省电模式」（30 帧，手机不发热）。
- **截图某个状态**：`godot --path godot -- --demo=map --shot=out.png --wait=1.5`（全部 demo 在 `godot/scripts/dev/demos.gd`）。

## 检查

```bash
sh tools/check.sh          # 格式、导入规则、每个脚本能编译、全部测试、生成的文档是最新的
```

CI（GitHub Actions）每次推送都跑同一个脚本。

## 改内容

几乎所有东西都是 `godot/data/*.json` 里的配置，改配置不用改代码；对照表见 [AGENTS.md](AGENTS.md)。
设计思路见 [docs/design.md](docs/design.md)，剧情大纲见 [docs/STORY.md](docs/STORY.md)，美术见 [pics/README.md](pics/README.md)。
Python 工具（美术流水线、文档生成、配音）在 `tools/`，依赖见 `pyproject.toml`（`uv sync`）。
