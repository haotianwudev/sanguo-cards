# 出图提示词

> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。
> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。
> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，
> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。

## 下一批（交给 Gemini）

按顺序画；交付后重跑本脚本，这一条会自动消失。

共 7 张，按优先级分档（全部由游戏数据算出，游戏里没用到的不列）：


**第 3 档 · 主线剧情 CG（1）**

1. `c4_cimu` — 第四章 · 双凤乱太行·东莱慈母（剧情 CG）

**第 5 档 · 宝物图标（6）**

2. `longzhong` — 隆中对（宝物图标）（宝物）
3. `baima_qi` — 白马义从旗（宝物图标）（宝物）
4. `liangyinqiang` — 亮银枪（宝物图标）（宝物）
5. `chuanyang` — 穿杨箭（宝物图标）（宝物）
6. `qiangzhen` — 拒马枪阵（宝物图标）（宝物）
7. `hubendun` — 虎贲铁盾（宝物图标）（宝物）

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

### `c4_cimu`

```
横版剧情事件插画：东莱黄县海边的土屋里：太史慈（二十七八岁的东莱猛将，身形高大，卷起袖子）蹲在灶门口拿蒲扇扇火煎药；炕头靠着一位瘦削的白发老妇人，裹着旧棉袄，手里捧着一碗热鱼汤；张宁坐在炕沿给老妇人号脉，竹编药篓放在脚边；北线主角常服倚在门口笑着看；窗外是灰蓝的大海和晾着的渔网，地面为开阔坚硬平整的夯土地面。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——北线主角：二十出头的年轻男子，干净斯文，浅棕色长发，头顶挽一个小发髻，其余长发披在肩背上，额前有碎刘海（不是现代短发，不缠布巾、不戴头带），穿常服（和立绘 lord_north_casual 一样：灰蓝色交领长袍，外披雪白狐裘，不穿任何鱼鳞甲或铁甲），手里、肩上、背上都没有任何兵器，不要长枪、不要任何刀剑。）
```

参考立绘（一起上传给 Gemini，保持长相一致）：北线主角 → `pics/source/generals/lord_north_casual.jpg`；太史慈 → `pics/source/generals/taishici.jpg`；张宁 → `pics/source/generals/zhangning.jpg`

## 奇遇插图（？格事件，横版 16:9，key = e_<事件 id>，放 `pics/source/cg/`，和剧情 CG 一样登记）

## 天命图（512×512 透明 PNG，放 `godot/data/art/fates/<key>.png`；没有图时显示一个汉字）

## 词缀徽记（128×128 透明 PNG，放 `godot/data/art/affixes/<key>.png`）

## 界面大图（横版 16:9 JPG，放 `godot/data/art/ui/<key>.jpg`）

## 宝箱图（开宝箱动画用，512×512 透明 PNG，放 `godot/data/art/ui/<key>.png`）

## 章节地图底图（横版宽图，放 `pics/source/map/bg_<key>.jpg`）

## 宝物图标（256×256 透明 PNG，放 `pics/source/relics/<key>.png`；现在是程序生成的占位）
