# 三国卡牌 (sanguo-cards)

三国题材卡牌策略游戏，借鉴兰斯10的卡牌战斗/战役节奏与三国群侠传的武将收集。目前是**纯 Python 文字版**，零依赖。

## 运行

```bash
python -m pip install -e ".[dev]"   # 一次即可
sanguo                               # 或：python -m sanguo
sanguo --seed 7                      # 固定随机种子，复现同一局
python -m pytest                     # 规则 + 数值平衡测试
```

Windows 终端如出现中文乱码，先执行 `chcp 65001` 或设置 `PYTHONIOENCODING=utf-8`。

## 玩法（虎牢关之战）

- 每回合 3 点行动力，4 名武将每人每回合最多动一次 —— 选谁出手是核心决策。
- 敌将会在回合开始时亮出下一步动作（⚠ 准备【无双】→ 我军全体），据此决定防御还是抢攻。
- 大招有每场使用次数；10 回合内打不完就算失败。

设计说明与路线图见 [docs/design.md](docs/design.md)。
