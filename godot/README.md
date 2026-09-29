# 重开三国 · Godot 版

小而精的三国 roguelike 卡牌游戏：兰斯10式战斗（一条共用体力、队长 + 部队、AP、累积技能）+ 走格子的任务地图。

- 用 Godot 4.7 打开本文件夹（`project.godot`）。
- 游戏内容全在 `data/`：`cards.json`（卡牌、兵种、技能、敌人、数值）、`story.json`（任务地图）、`ui.json`（界面配置）、`portraits/`（头像）。**这里是唯一的数据源**；根目录的 Python 原型已冻结。
- 规则引擎在 `scripts/core/`（纯逻辑，不依赖节点）：`game_data.gd`、`save_data.gd`、`battle.gd`、`quests.gd`。
- 测试（含数值平衡的 bot 模拟）：
  ```
  Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/run_tests.gd
  ```
  只跑部分：设环境变量 `TEST_FILTER=关键词`。
