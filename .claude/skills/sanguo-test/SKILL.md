---
name: sanguo-test
description: Run and write tests for 重开三国 (sanguo-cards) — the headless unit/route test suite, the screenshot demos, and the bot balance simulation (tests/sim_balance.gd) used to calibrate enemy strength, 一周目通关率, 埋伏, 暴击, 事件. Use after any change to story.json, cards.json, quests, battle or UI, and whenever the user asks "测一下 / 难度 / 通关率 / 平衡".
---

# 重开三国 测试 skill

Godot 路径（Git Bash）：`G="/f/workspace/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"`，所有命令在 `godot/` 目录下跑（`cd /f/workspace/sanguo-cards/godot`）。

## 1. 单元 / 路线测试（每次改完都跑）

```bash
timeout 110 "$G" --headless --path . --script res://tests/run_tests.gd > /tmp/t.log 2>&1
grep -B1 -A6 "FAIL\|passed\|SCRIPT ERROR\|Parse" /tmp/t.log | grep -v "  ok" | head -30
```

- 跑 `tests/test_*.gd` 里所有 `test_*` 方法；出现 `SCRIPT ERROR` / 断言失败也算失败。**现在约 227 项，全过才算完成。**
- 只跑一部分：`TEST_FILTER=ambush`（方法名包含的关键字）。
- 工具超时 120 秒，整套约 15 秒；不要把 `timeout` 设得比工具超时更长而不放后台。
- 新加带 `class_name` 的文件、或新美术后，先 `timeout 120 "$G" --headless --path . --import >/dev/null 2>&1`。
- 测试文件继承 `TestCase`（`check` / `check_eq` / `check_between`），`rng(seed)`、`bot_fight(b)`、`party(...)`、`quest_by_id(id)`（仅 test_routes）、`walk(q, s, prefer)`、`finish(q, s)`、`lap_save(flags, cleared)` 是现成的辅助函数。
- 常见坑：
  - 故事 / 卡牌 JSON 在 Windows 上是 CRLF，用 Python 改时要 `newline=''` 读写，多行替换前把 `\n` 换成 `\r\n`。
  - 新增中文字符不在字体里 → `test_the_bundled_font_has_every_character_the_game_prints` 失败：换个常见字，或跑 `python tools/build_fonts.py`。
  - 数值断言要和全局系数配合：`battle.attack_mult` / `hp_mult` / `enemy_hp_mult` / `scaling` 改了，依赖原始数值的测试要乘上系数。
  - 战斗里 `act` 之后读伤害用 `take_events()` 里的 `hit` 事件，不要用 `max_hp - hp`（可能有别的伤害）。
  - 改了卡牌效果后同一个 `rng` 种子下结果会变（暴击、埋伏会多消耗随机数）。

## 2. 截图（看 UI / 地图）

```bash
timeout 90 "$G" --path . --resolution 1280x720 -- --demo=<name> --shot=<scratchpad>/x.png --wait=2
```
然后用 Read 看 png。常用 demo：`fork`（第三章分叉）、`affix`（第二章地图、精英词缀）、`upgrade`（点化选卡行）、`ch4` / `ch5`（长安线）、`ch6` 等，列表见 `scripts/game.gd` 的 `demo()`；`--at=<square id>` 跳到某格。

## 3. 平衡模拟（bot 打完整周目）——调难度用

```bash
SIM_RUNS=40 SIM_LAPS=2 SIM_GIVEUP=3 SIM_ROUTE=south \
  timeout 2400 "$G" --headless --path . --script res://tests/sim_balance.gd > /tmp/sim.log 2>&1
```
- 真实流程：`Quests` 走格子、真实战斗（`bot_fight` = 每点行动力价值最高的技能，**不会防御 / 换人 / 用 BOOST，比真人弱**）、伤害跨战斗累积、宝箱拿最好的卡、章末战功全部点化、`new_lap()` 带着永久记录开下一周目。
- 环境变量：
  - `SIM_RUNS` 局数（默认 10，**至少 30–40 才不太吵**）；`SIM_LAPS` 周目数；`SIM_ROUTE=south|north`。
  - `SIM_GIVEUP` 同一格连输几次算这一局失败（口径：**3**）。
  - 临时覆盖参数，不用改 JSON：`SIM_STRENGTH`、`SIM_GROWTH`、`SIM_BASE`、`SIM_LATE`（`late_growth`）。
  - `SIM_DEBUG=1` 打印每场精英 / 首领的队伍和敌人数值。
- 输出：
  - `lap N: x of y runs cleared it` ← **通关率，主要看这个**（一周目目标约 80%）。
  - 每章每档（normal / elite / boss / showpiece=吕布类演出战）一行：`win` 每次尝试的胜率、`hp_left` 赢下时剩余体力、`wear_in` 进场前已损失体力、`turns` 用掉回合 / 回合上限、`party_hp`、`units`。
  - 最后一行 `runs given up` = 卡关的格子（谁最难）。
- 一次跑很久（几分钟）：放后台 `( ... &)` 再用 `until grep -q "== sim_balance" log; do sleep 10; done` 等；可以并行跑多个参数。
- 解读：
  - 普通战斗应 ~95–100% 胜、体力剩 70–90%，首领 60–85%；整体后面章节不该比前面章节轻松。
  - `turns` 平均 1.0 说明一回合就打完——敌人太弱，加大 `strength`。
  - 一个章节战斗**场数太少**（< ~15）磨不掉体力，加强敌人只会让个别首领变拦路虎；应该加战斗场数 / 减少回复点。
  - 通关率样本小（40 局 ±7%）；调参前后要同样局数、最好同样种子。

## 4. 敌人强度只调一个旋钮

`battle.json → battle.scaling`：目标强度（血×攻×行动数）= `1e6 × strength × base × (N + offset)^exponent × 章系数`，N 取 `order`；一章的第一列落在第 N 章、最后一列落在第 N+1 章，中间线性插值，每场普通战斗直接对准这条线（不随卡牌），精英 / 首领 / 必败再乘 `enemy_coef`。**日常只改 `strength`**（或 `chapter_default`）；`exponent` 是曲线斜率，后面章节整体偏难 / 偏易时才动。
一周目通关率目标 ≈ 80%：用上面的模拟扫 `SIM_STRENGTH`（0.5 / 1 / 1.5 / 2 / 3）看曲线，再把选定的值折进 `base`，保持 `strength = 1.0`。

### 怎么校准整条难度曲线（用户给「某章开头多少」时）

曲线是一条幂函数：**第 N 章开头的强度 = `base × (N + offset)^exponent`**（`strength` 与 `chapter_default` 保持 1，不要用它们凑数），第 N 章最后一列 = 第 N+1 章开头，章内线性插值。N 是 `order`：序章 / 第一章 = 0，第二章 = 1，第三章 = 2……（南北线同序）。强度单位是 1e6，所以「第三章开头 8」就是 `curve(2) = 8`。

用户一般会给三个数：一个指数、一个起点、一个远点。三个参数刚好对上：

1. 记 `exponent = e`，起点 `curve(0) = a`，远点 `curve(m) = b`（m 是那一章的序号）。
2. `offset = m / ((b / a)^(1/e) − 1)`，`base = a / offset^e`。
3. 用下面这段脚本把每章的开头列出来，**先给用户看表确认，再改文件**：

```python
e, a, m, b = 1.4, 0.4, 2, 8          # 用户给的
r = (b / a) ** (1 / e); o = m / (r - 1); k = a / o ** e
print("offset=%.3f base=%.2f" % (o, k), [round(k * (n + o) ** e, 1) for n in range(13)])   # 第 1..13 章开头
```

- 用户给的是「几个章节的边界值」而不是指数时：幂函数只有三个参数，增量只会越来越大，**拟合不出先加快再放缓的 S 形**；扫 `(exponent, offset)`，每组把 `base` 取成最小二乘（或用两端点定 `base`）选误差最小的，再把算出来的整张表（第一章到第十二章）给用户看，后期往往会变陡，要和用户确认。
- 改 `battle.json → scaling` 的 `base` / `exponent` / `offset`，`chapter_default` 设 1，`chapter` 留空，同时更新那里的注释和 `sanguo-dev` 里「敌人强度系统」一段写的数字。
- 精英 / 首领 / 必败不在这条曲线里，在 `enemy_coef`（1.25 / 1.45 / 2）。
- 每场普通战斗**直接对准曲线**（不随卡牌），所以同一列的小兵强度一样；曲线数字就是真实的强度，用战斗里的血 × 攻 × 行动数核对。
- 曲线整体一变，机器人模拟的通关率会变：`test_chapter_one_is_winnable_with_either_plan`（0.35 起）和 `test_dongzhuo_chapter_is_fair_after_chapter_one`（0.2 起）会随第一章末尾强度变化而掉到 0；这是难度改了，不是 bug。先问用户要不要放宽这两条的下限，别自己改。

## 5. 写新测试的习惯

- 新机制至少一个测试：规则本身（边界值）+ 数据配置合法（例如每章每档强度单调、所有 ？ 格都分到事件、事件选项没有被 `needs` 全部堵死）。
- 数据驱动的断言写成「按配置算出期望值」，不要写死数字，免得改配置就要改测试。
- 剧情路线测试放 `test_routes.gd`（走完一章，检查经过的格子、入队的卡、记录、结局），战斗 / 数值放 `test_battle.gd`，任务 / 事件 / 难度放 `test_quests.gd`，卡牌收藏放 `test_collection.gd`。
- 美术只改图不改数据时，**不用跑测试 / 导入 / 截图**（见 sanguo-art-ingest）。
- 平衡有变化的提交，在提交说明里写模拟的通关率（几局、几周目、什么参数）。
