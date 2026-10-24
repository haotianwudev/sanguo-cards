# 出图提示词

> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。
> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。
> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，
> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。

## 下一批（交给 Gemini）

按顺序画；交付后重跑本脚本，这一条会自动消失。

共 1 张，按优先级分档（全部由游戏数据算出，游戏里没用到的不列）：


**第 3 档 · 主线剧情 CG（1）**

1. `c3_home` — 第三章 · 黑山风云·回到无极（剧情 CG）

交图规则：

- 每张图都用下面对应小节的**完整提示词**；图上长相/器物必须和设定对得上（见 `CARD-DESIGN.md` 第 7 节）。
- 宝物：纯中式汉代古风器物，独立透明背景（纯白背景抠图，无圆盘边框，无西式奇幻符号），日系战术卡牌 RPG 赛璐珞道具插画风。
- 女性角色一律画成成年人；董白不写年龄、不画成萝莉。
- 卡牌立绘必须带背景：背景为符合人物身份与阵营的古风场景（军营、要塞、江岸、山林、宫室等，具自然景深与环境光影，不再使用纯白/摄影棚素底）。人物半身居中，面部在上方三分之一。
- 文件名 = key：宝物放 `pics/source/relics/<key>.png`（同时复制到 `godot/data/art/relics/<key>.png`），立绘放 `pics/source/generals/`（兵卡放 `soldiers/`）。
- 战斗 CG 放 `pics/source/battles/<key>.jpg`、在 `pics/art.json` 的 battles 登记；构图：敌人大、居中、在画面中上部。
- 宝箱图：PNG 透明底 512×512，直接放 `godot/data/art/ui/<key>.png`（开宝箱动画会自动用上）。
- 立绘在 `pics/art.json` 对应段登记；然后跑 `sanguo-art`，再跑 `python tools/art_prompts.py` 刷新本文件。
- 每条提示词下面的「参考立绘」列出画面里每个人物已交付的立绘文件，出图时一起上传给 Gemini；主角穿常服的场景参考 `lord_south_casual` / `lord_north_casual`，其余参考 `lord` / `lord_north`。
- **不要覆盖已经交付的图**；重画某张时旧图别留在 `pics/source/` 里（`backup_old/` 之类的文件夹不要提交）。
- 提交时按路径 `git add`，只提交自己的图和登记，别带上别人没提交的改动。

## 立绘（竖版 3:4）

## 战斗 CG（横版 16:9，每场战斗一张）

## 剧情插图 CG（横版 16:9）

### `c3_home`

```
16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，温暖柔和的色彩。春日细雨中的无极城，甄府大门敞开，门口青石台阶湿漉漉的。少女甄宓（十多岁的半大女孩，乌黑长发，淡蓝衣裙，光着脚）扑进北线主角（二十出头的年轻男子，干净斯文，头发用布巾束成发髻，旧鱼鳞甲外披斗篷）的怀里，主角笑着接住她；张夫人（三十多岁的雍容妇人，深色锦袍，手里拿着账本）站在门口，目光越过他们望向队尾；队尾远处，张宁（成年女子，素白麻布衣，背着竹编药篓）一个人站在雨里，有些局促，没有往前走。背景是停在街上的商队粮车。构图：横版 16:9，主要人物位于画面上部三分之二以上。不要文字、不要 UI。
```

参考立绘（一起上传给 Gemini，保持长相一致）：北线主角 → `pics/source/generals/lord_north.jpg`；张夫人 → `pics/source/generals/zhangfuren.jpg`；甄宓 → `pics/source/generals/zhenmi_young.jpg`；张宁 → `pics/source/generals/zhangning.jpg`

## 奇遇插图（？格事件，横版 16:9，key = e_<事件 id>，放 `pics/source/cg/`，和剧情 CG 一样登记）

## 天命图（512×512 透明 PNG，放 `godot/data/art/fates/<key>.png`；没有图时显示一个汉字）

## 词缀徽记（128×128 透明 PNG，放 `godot/data/art/affixes/<key>.png`）

## 界面大图（横版 16:9 JPG，放 `godot/data/art/ui/<key>.jpg`）

## 宝箱图（开宝箱动画用，512×512 透明 PNG，放 `godot/data/art/ui/<key>.png`）

## 章节地图底图（横版宽图，放 `pics/source/map/bg_<key>.jpg`）

## 宝物图标（256×256 透明 PNG，放 `pics/source/relics/<key>.png`；现在是程序生成的占位）
