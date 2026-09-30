# 出图提示词

> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。
> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。
> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，
> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。

## 下一批（交给 Gemini）

按顺序画；交付后重跑本脚本，这一条会自动消失。

**先重画**（已交付但有地方不对）：

- `inf_n` — 官军刀兵：盾牌上的鹰和回纹边是古希腊重装步兵盾的样式——换成汉军的盾（长方形或圆盾，黑红漆面，饕餮 / 云纹或素面），其他不变

1. `dongzhuo` — 董卓（第三章·长安首领）（立绘）
2. `wangyun` — 王允（立绘）
3. `caiyong` — 蔡邕（立绘）
4. `xiandi` — 汉献帝（十岁左右的孩子，只画孩子该有的样子）（立绘）
5. `huangfusong` — 皇甫嵩（立绘）
6. `gaoshun` — 高顺（立绘）
7. `xunyou` — 荀攸（立绘）
8. `zhongyao` — 钟繇（立绘）
9. `xuhuang` — 徐晃（换掉占位）（立绘）
10. `huangzhong` — 黄忠（换掉占位，四十出头的军汉，不是老将）（立绘）
11. `e_tangji` — 破庙救唐姬（剧情 CG）
12. `e_yazhai` — 压寨夫人（胭脂虎指着主角）（剧情 CG）
13. `e_shengnv` — 黄巾圣女（张宁施符水）（剧情 CG）
14. `yuanshu` — 袁术（立绘）
15. `jiling` — 纪灵（立绘）
16. `leibo` — 雷薄（立绘）
17. `chenlan` — 陈兰（立绘）
18. `qiaorui` — 桥蕤（立绘）
19. `c3_shanfei` — 独眼匪首（第三章流民匪患）（战斗 CG）
20. `c3_qiaorui` — 城外·桥蕤（第三章南阳城外便装伏兵）（战斗 CG）
21. `c3_jiling` — 山口·纪灵（第三章大雨隘口决战）（战斗 CG）
22. `c3_leibo` — 山道追兵·雷薄（第三章清晨山道追击）（战斗 CG）
23. `c3_chenlan` — 夜袭·陈兰（第三章雨夜火把夜袭）（战斗 CG）
24. `c3_yuanshu` — 袁术（第三章金顶马车与大军）（战斗 CG）
25. `c3_leave` — 撤离洛阳（流民大队与孙家车队）（剧情 CG）
26. `c3_wenji` — 救蔡文姬（泥泞道边拾断弦琴）（剧情 CG）
27. `c3_supply` — 饥民与军粮（剧情 CG）
28. `c3_slip` — 酒肆说漏嘴（孙策拍桌吹牛，周瑜捂嘴）（剧情 CG）
29. `c3_entrust` — 托付玉玺（孙坚夜交锦盒于吴夫人）（剧情 CG）
30. `c3_warn` — 劝阻孙坚（剧情 CG）
31. `c3_raid` — 陈兰雨夜袭营（剧情 CG）
32. `c3_news` — 纪灵败退与噩耗（剧情 CG）
33. `c3_end` — 碎玺决战（吴夫人碎玉玺面袁术）（剧情 CG）
34. `changan` — 第三章·长安地图底图（地图）
35. `dongui` — 第四章·挟天子地图底图（地图）
36. `yuxi` — 第三章·传国玉玺地图底图（地图）
37. `c5_dongzhuo` — 未央宫前·董卓（首领）（战斗 CG）
38. `c4_lvbu` — 雪中宣平门·吕布（结局二前的最后一战）（战斗 CG）
39. `c7_jiling` — 宛城西门·纪灵（首领）（战斗 CG）
40. `c6_lijue` — 函谷关·李傕（首领）（战斗 CG）
41. `c4_gaoshun` — 蔡府后门·高顺（精英）（战斗 CG）
42. `c5_niufu` — 比武·牛辅（精英）（战斗 CG）
43. `c5_hall` — 喜堂·飞熊军（精英）（战斗 CG）
44. `end_yusui` — 结局卡·玉碎（象征画，不画人）（剧情 CG）
45. `end_tonggui` — 结局卡·同归（象征画，不画人，不见血）（剧情 CG）
46. `jiaxu` — 贾诩（毒士，长安接风宴露面、四周目第四章打败张济张绣后入队、第五章破局线核心）（立绘）
47. `zhangxiu` — 张绣（北地枪王，张济之侄）（立绘）
48. `c6_jiaxu` — 绑走贾诩（五花大绑躺在粮车上还在闻酒葫芦）（剧情 CG）
49. `c6_zhangxiu` — 渭水桥·张绣（战斗 CG）
50. `c6_zhangji` — 渭水营·张济（精英）（战斗 CG）
51. `liubiao` — 刘表（荆州牧，坐谈客）（立绘）
52. `caimao` — 蔡瑁（水军都督，骄横外戚）（立绘）
53. `kuaiyue` — 蒯越（荆襄谋主）（立绘）
54. `huangzu` — 黄祖（江夏太守）（立绘）
55. `caifuren` — 蔡夫人（荆州，成年女性）（立绘）
56. `jingzhou_gong` — 荆州弓手（兵卡）（立绘）
57. `jingzhou_shuijun` — 荆州水军（兵卡）（立绘）
58. `c8_shuige` — 水阁·貂蝉代饮（结局三线的关键一幕）（剧情 CG）
59. `c8_grapes` — 水阁·貂蝉要舍身，被主角一把拽回怀里（破局线的关键一幕）（剧情 CG）
60. `c8_louchuan` — 月下楼船·糖炒栗子（剧情 CG）
61. `c8_liuxian` — 留仙裙·淯水边（剧情 CG）
62. `c8_caifuren` — 蔡夫人认同宗、送明珠（剧情 CG）
63. `c8_jiayan` — 宛城家宴（剧情 CG）
64. `c8_dress` — 盛装（吴夫人给貂蝉梳头）（剧情 CG）
65. `c8_xiangxiao` — 香消（克制）（剧情 CG）
66. `c8_henhai` — 恨海·汉江冷雨（克制）（剧情 CG）
67. `end_henhai` — 结局卡·恨海（象征画，不画人，不见血）（剧情 CG）
68. `jx_huangzu` — 淯水·黄祖（首领）（战斗 CG）
69. `jx_caimao_a` — 水阁·独眼蔡瑁（结局三线首领）（战斗 CG）
70. `jx_caimao_b` — 水阁·蔡瑁（破局线首领）（战斗 CG）
71. `jx_shuijun` — 水寨·荆州水军（精英）（战斗 CG）
72. `jx_bubing` — 淯水北岸·荆州步卒（战斗 CG）
73. `jx_gongshou` — 芦苇荡·荆州弓手（战斗 CG）
74. `jx_nushou` — 水阁·蔡府连弩手（战斗 CG）
75. `jingxiang` — 第五章·荆襄风云地图底图（地图）

交图规则：

- 每张图都用下面对应小节的**完整提示词**；图上长相/器物必须和设定对得上（见 `CARD-DESIGN.md` 第 7 节）。
- 宝物：纯中式汉代古风器物，独立透明背景（纯白背景抠图，无圆盘边框，无西式奇幻符号），日系战术卡牌 RPG 赛璐珞道具插画风。
- 女性角色一律画成成年人；董白不写年龄、不画成萝莉。
- 卡牌立绘必须带背景：背景为符合人物身份与阵营的古风场景（军营、要塞、江岸、山林、宫室等，具自然景深与环境光影，不再使用纯白/摄影棚素底）。人物半身居中，面部在上方三分之一。
- 文件名 = key：宝物放 `pics/source/relics/<key>.png`（同时复制到 `godot/data/art/relics/<key>.png`），立绘放 `pics/source/generals/`（兵卡放 `soldiers/`）。
- 战斗 CG 放 `pics/source/battles/<key>.jpg`、在 `pics/art.json` 的 battles 登记；构图：敌人大、居中、在画面中上部，下方 30% 为干净地面。
- 宝箱图：PNG 透明底 512×512，直接放 `godot/data/art/ui/<key>.png`（开宝箱动画会自动用上）。
- 立绘在 `pics/art.json` 对应段登记；然后跑 `sanguo-art`，再跑 `python tools/art_prompts.py` 刷新本文件。
- **不要覆盖已经交付的图**；重画某张时旧图别留在 `pics/source/` 里（`backup_old/` 之类的文件夹不要提交）。
- 提交时按路径 `git add`，只提交自己的图和登记，别带上别人没提交的改动。

## 立绘（竖版 3:4）

### `huangzhong` 🟡 换掉占位

```
A vertical character portrait of Huang Zhong (黄忠), a Nanyang man in his forties and a peerless archer — not yet the old general of legend.
Appearance: Sturdy, weathered man in his early 40s with a square jaw, a short beard and steady eyes.
Armor & Clothing: Rough soldier's clothes with a leather bracer, rope marks still on his wrists.
Weapon: A heavy longbow drawn to full, an arrow nocked.
Background: a Nanyang army camp gate in summer with a broken 袁 banner pole.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `xuhuang` 🟡 换掉占位

```
A vertical character portrait of Xu Huang (徐晃), a dark-faced Hedong officer under Yang Feng who kneels to the emperor.
Appearance: Dark-skinned, stern man in his 30s with thick brows and an honest, stubborn look.
Armor & Clothing: Plain iron lamellar armor with a dusty brown cloak.
Weapon: A huge long-handled battle axe resting on his shoulder.
Background: a mountain pass east of Huayin with Yang Feng's banners.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `bingzhou` ⬜ 缺

```
A vertical character portrait of a Bingzhou wolf rider (并州狼骑), one of Lü Bu's northern cavalrymen.
Appearance: Fierce, wind-burned northern horseman in his 20s with a wolfish grin.
Armor & Clothing: Fur-trimmed leather and iron armor, a wolf tail hanging from his helmet.
Weapon: A curved saber raised as he gallops.
Background: the open northern steppe at dusk.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `xianzhen` ⬜ 缺

```
A vertical character portrait of a Trap-Breaking Camp soldier (陷阵营), Gao Shun's silent elite infantry.
Appearance: Grim, silent heavy infantryman, his face half hidden by a deep helmet.
Armor & Clothing: Heavy black lamellar armor, plain and unadorned.
Weapon: A tall rectangular black shield and a long ji.
Background: a shield wall in the dark before dawn.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `zhurong` ⬜ 缺

```
A vertical character portrait of Lady Zhurong (祝融夫人), queen of the Nanzhong tribes who claims descent from the fire god — an adult woman.
Appearance: Proud, sun-bronzed adult woman around 30 with a fierce grin, wild dark hair bound with red cords, gold and bone earrings.
Armor & Clothing: Tribal queen's armor of leather and bronze plates, a leopard pelt over one shoulder, feather ornaments.
Weapon: A bandolier of throwing knives across her chest, one knife twirling between her fingers.
Background: a steaming southern jungle with a volcano glowing on the horizon.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `mayunlu` ⬜ 缺

```
A vertical character portrait of Ma Yunlu (马云騄), Ma Chao's younger sister, a Xiliang woman general — an adult woman.
Appearance: Bold, bright-eyed adult woman in her early 20s with a confident smile, long ponytail tied with a silver ring.
Armor & Clothing: Silver lamellar armor trimmed with white fur, a short white cape.
Weapon: A long lance with a white tassel, reins of a white horse in her other hand.
Background: the Xiliang frontier: dry grassland, a beacon tower and distant snowy mountains.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `wangyi` ⬜ 缺

```
A vertical character portrait of Wang Yi (王异), the Jicheng heroine who planned the city's defence — an adult woman.
Appearance: Composed adult woman in her early 30s with an unshakeable gaze, hair simply pinned, no jewelry.
Armor & Clothing: Plain dark robe with a leather belt, sleeves bound for work, a wind-torn cloak.
Weapon: A short sword at her waist, a map of city walls in her hand.
Background: a besieged frontier city wall at dusk with soldiers and smoke.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `xinxianying` ⬜ 缺

```
A vertical character portrait of Xin Xianying (辛宪英), the famously perceptive lady of the Xin family — an adult woman.
Appearance: Elegant adult woman in her 20s with clever eyes and a small knowing smile.
Armor & Clothing: Light blue scholar-lady robes with neat layered collars.
Weapon: Holding a bamboo slip in one hand and a brush in the other.
Background: a quiet study with bamboo scrolls and a window onto a plum tree.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `caifuren` ⬜ 缺

```
A vertical character portrait of Lady Cai (蔡夫人) of Jingzhou, Liu Biao's wife and the power behind the Cai clan — a scheming adult woman.
Appearance: Beautiful adult woman in her late 20s with a cold, graceful smile and calculating eyes.
Armor & Clothing: Rich purple silks with gold embroidery, an ornate phoenix hairpin.
Weapon: A round silk fan half-hiding her face.
Background: a lavish Jingzhou mansion hall with a river view through carved screens.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `jiaxu` ⬜ 缺

```
A vertical character portrait of Jia Xu (贾诩), the 'poison strategist' — a Xiliang officer who can smell a plot, and poison, in any cup.
Appearance: Thin, sallow man in his mid-40s with a sparse goatee, drooping lazy eyelids and a faint, unreadable half-smile; sharp eyes under the sleepy lids.
Armor & Clothing: A loose, faded Xiliang officer's robe that hangs off his thin frame, a plain dark cap, a gourd wine flask at his belt.
Weapon: Holding a wine cup under his nose, sniffing it before drinking; no weapon.
Background: a dim corner of a lantern-lit banquet hall in Chang'an, the feast blurred behind him.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `zhangxiu` ⬜ 缺

```
A vertical character portrait of Zhang Xiu (张绣), Zhang Ji's young nephew from Wuwei, a dazzling spearman ('the Spear King of the North').
Appearance: Handsome, cocky young man in his early 20s with sharp eyebrows, a high topknot and a fearless grin.
Armor & Clothing: Light silver-and-blue Xiliang scale armor with a short white cape, a white-tasselled helmet under his arm.
Weapon: A long spear spun into a blur of spear-tip flowers.
Background: a stone bridge over the Wei river at dawn, Xiliang cavalry with a 张 banner behind.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `liubiao` ⬜ 缺

```
A vertical character portrait of Liu Biao (刘表), Governor of Jingzhou and an imperial clansman — a scholar who talks rather than fights.
Appearance: Pale, dignified man around 50 with a long, well-kept black beard, soft hands and a mild, hesitant smile.
Armor & Clothing: Wide-sleeved dark-green scholar-official robes with a black official's cap and a jade pendant at the belt.
Weapon: Holding a half-unrolled bamboo book of the classics instead of a weapon.
Background: a quiet study in the Xiangyang governor's mansion with shelves of bamboo scrolls and the Han river beyond a lattice window.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `caimao` ⬜ 缺

```
A vertical character portrait of Cai Mao (蔡瑁), Lady Cai's younger brother and admiral of the Jingzhou navy — an arrogant, greedy in-law.
Appearance: Burly man in his 40s with a thick moustache, heavy jowls and a sneering, lecherous grin.
Armor & Clothing: An embroidered brocade robe worn over gilded scale armor, a gold belt, rings on his fingers.
Weapon: One hand on the hilt of a long sword, the other raising a gold beast-shaped wine cup.
Background: the deck of a great tiered warship on the Han river at dusk, rows of Jingzhou war boats behind.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `kuaiyue` ⬜ 缺

```
A vertical character portrait of Kuai Yue (蒯越), the far-sighted chief advisor of the Jingzhou gentry.
Appearance: Composed scholar in his early 40s with a neat short beard, a calm, measuring gaze and a faint polite smile.
Armor & Clothing: Immaculate pale-grey Confucian robe with layered collars, a simple black scholar's cap.
Weapon: Hands folded in a formal bow, a closed folding bamboo scroll tucked into his sleeve.
Background: a lamplit study at night in Xiangyang, a go board with an unfinished game on the low table.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `huangzu` ⬜ 缺

```
A vertical character portrait of Huang Zu (黄祖), the grim veteran Administrator of Jiangxia, Liu Biao's hardest general.
Appearance: Gaunt, weathered man in his 50s with a lined, sour face, grey stubble and cold narrow eyes.
Armor & Clothing: Battered dark iron lamellar armor with a river-green cape, a helmet with a short red plume.
Weapon: A heavy ghost-head broadsword (鬼头刀) held low at his side.
Background: the misty south bank of the Yu river in autumn, tall reeds and a 黄 banner.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `jingzhou_gong` ⬜ 缺

```
A vertical character portrait of a Jingzhou archer (荆州弓手), a soldier card.
Appearance: Young soldier with a sun-browned face and a steady squint.
Armor & Clothing: Light green cloth armor over a short tunic, a reed hat, a quiver of arrows at the hip.
Weapon: Drawing a longbow, crouched in reeds.
Background: a reed marsh on the Han river bank in autumn.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `jingzhou_shuijun` ⬜ 缺

```
A vertical character portrait of a Jingzhou marine (荆州水军), a soldier card.
Appearance: Broad-shouldered river sailor with a shaved head and a rough grin.
Armor & Clothing: Bare-chested under a short leather vest, a red headband, rope at the waist.
Weapon: A boarding pike and a round rattan shield.
Background: the prow of a Jingzhou war boat on the Han river, oars and flags.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `bianfuren` ⬜ 缺

```
A vertical character portrait of Lady Bian (卞夫人), a former singer of great grace and good sense — the heroine of the northern start, an adult woman.
Appearance: Graceful adult woman around 30 with warm eyes and a calm, shrewd smile.
Armor & Clothing: Elegant but modest pale rose robes, a simple jade hairpin.
Weapon: Holding a lantern in the snow, a thick cloak over one arm to share.
Background: a snowy northern plain outside the town of Qiao at night.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `yanfuren` ⬜ 缺

```
A vertical character portrait of Lady Yan (严夫人), Lü Bu's stern, practical wife — an adult woman.
Appearance: Handsome, strong-willed adult woman in her 30s with a stern frown and arms crossed.
Armor & Clothing: Sturdy dark red robes of a general's wife, sleeves tied back.
Weapon: A household ledger tucked under one arm.
Background: the courtyard of a general's residence with a halberd rack.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `liniang` ⬜ 缺

```
A vertical character portrait of Li Niang (黎娘), queen of a Shanyue mountain tribe in Jiangdong — an adult woman.
Appearance: Fierce adult woman in her mid-20s with sharp eyes, blue tribal tattoos on her arms and cheek, hair cropped at the shoulders.
Armor & Clothing: Hide and woven-bark armor, bead necklaces, bare feet wrapped in cloth.
Weapon: A bamboo bow with poison arrows, a quiver of green-fletched shafts.
Background: misty Jiangdong mountains with bamboo forests and stilt houses.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `gaoshun` ⬜ 缺

```
A vertical character portrait of Gao Shun (高顺), Lü Bu's grim, silent commander of the Trap-Breaking Camp (陷阵营).
Appearance: Stern, dark-faced man in his 30s, jaw set, eyes that never blink; utterly still.
Armor & Clothing: Heavy black lamellar armor, plain and unadorned, a tall rectangular shield.
Weapon: Standing like a post, shield planted, a long ji in his other hand.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `xunyou` ⬜ 缺

```
A vertical character portrait of Xun You (荀攸), a quiet strategist just freed from Dong Zhuo's prison.
Appearance: Lean, calm scholar in his mid-30s with a thin beard and patient, unreadable eyes.
Armor & Clothing: A worn dark-blue scholar's robe, slightly rumpled from prison, neatly tied anyway.
Weapon: Holding a single go stone between two fingers, a go board tucked under his arm.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `zhongyao` ⬜ 缺

```
A vertical character portrait of Zhong Yao (钟繇), the great calligrapher, a Gentleman of the Yellow Gate close to the boy emperor.
Appearance: Refined official in his early 40s with a neat beard and ink-stained fingertips, gentle but sharp eyes.
Armor & Clothing: Dark court robes with a black official's cap.
Weapon: Holding a large brush over an unrolled edict, the characters crisp and elegant.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `xiandi` ⬜ 缺

```
A vertical character portrait of Emperor Xian of Han (汉献帝 刘协), the boy emperor, a puppet in Dong Zhuo's hands — a child of about ten.
Appearance: A slight boy of about ten with a pale, serious face and quiet, watchful eyes older than his years.
Armor & Clothing: Black-and-red imperial robes too big for him and a heavy mianliu crown with bead curtains.
Weapon: Sitting very straight on a huge throne, small hands gripping the armrests.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `zhujun` ⬜ 缺

```
A vertical character portrait of Zhu Jun (朱儁), the veteran Han General of Chariots and Cavalry, Sun Jian's old commander.
Appearance: Upright old general in his late 50s with a grizzled grey beard, a hearty laugh and a ramrod-straight back.
Armor & Clothing: Worn but well-kept Han general's lamellar armor with a faded red cloak.
Weapon: One hand on his sword hilt, the other raised in a big, hearty wave.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `huangfusong` ⬜ 缺

```
A vertical character portrait of Huangfu Song (皇甫嵩), the great Han general who crushed the Yellow Turbans, now humiliated at Dong Zhuo's court.
Appearance: Dignified, silent old general around 60, white hair and beard neatly bound, a stern and unbending gaze.
Armor & Clothing: A plain dark court robe over armor, a general's seal cord at the waist.
Weapon: Standing perfectly straight, both hands resting on a long sword planted point-down before him.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `fanchou` ⬜ 缺

```
A vertical character portrait of Fan Chou (樊稠), a loud, brash Xiliang general.
Appearance: Burly man in his 30s with a wild beard and a mocking grin.
Armor & Clothing: Dented Xiliang lamellar armor with fur trim.
Weapon: Hefting a huge broad saber over his shoulder.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `zhangji` ⬜ 缺

```
A vertical character portrait of Zhang Ji (张济), a steady, reserved Xiliang general.
Appearance: Calm man in his 40s with a trimmed beard and patient eyes.
Armor & Clothing: Neat dark Xiliang armor.
Weapon: Holding a long spear upright, making a polite martial salute.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `niufu` ⬜ 缺

```
A vertical character portrait of Niu Fu (牛辅), Dong Zhuo's son-in-law and Dong Bai's uncle.
Appearance: Heavy-set man in his 40s with a hard, jealous glare.
Armor & Clothing: Rich Xiliang general's armor with gold studs.
Weapon: Gripping a heavy saber, pointing it at the viewer in challenge.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `huzhen` ⬜ 缺

```
A vertical character portrait of Hu Zhen (胡轸), a grim Xiliang general guarding the chancellor's inner gate.
Appearance: Grim, scarred man in his 30s.
Armor & Clothing: Black armor, a red sash.
Weapon: Barring a gate with a drawn broad saber.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `dongzhuo` ⬜ 缺

```
A vertical character portrait of Dong Zhuo (董卓), the tyrant chancellor who burned Luoyang.
Appearance: Enormously fat, heavy-jowled man in his 50s with a thick beard, small cunning eyes and a jovial smile that never reaches them.
Armor & Clothing: Extravagant purple-and-gold chancellor's robes straining over his belly, a jeweled belt.
Weapon: Holding a wine cup in one hand, the other resting on a sword hilt.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `caiyong` ⬜ 缺

```
A vertical character portrait of Cai Yong (蔡邕), the great scholar and calligrapher, Cai Wenji's father.
Appearance: Gentle, frail scholar in his late 50s with a long white beard and kind, tired eyes.
Armor & Clothing: Plain grey scholar's robe and a scholar's cap.
Weapon: Holding a guqin under his arm and a bamboo scroll.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `wangyun` ⬜ 缺

```
A vertical character portrait of Wang Yun (王允), the Minister over the Masses — outwardly righteous, secretly ambitious and cunning.
Appearance: Lean, upright old man in his 60s with neatly combed white hair; a benevolent, righteous face, but a cold, calculating glint in the eyes.
Armor & Clothing: Dark official's robe with the minister's seal cord.
Weapon: Holding a folded memorial behind his back, standing very straight.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `yahuan` ⬜ 缺

```
A vertical character portrait of a household maid (丫鬟) of the Sun family, an adult woman.
Appearance: Adult woman in her 20s with a round, cheerful face and a shy smile, hair in two simple buns.
Armor & Clothing: Plain light-green servant's dress with an apron.
Weapon: Carrying a tea tray with cups, curtsying.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `chuniang` ⬜ 缺

```
A vertical character portrait of an army cook (厨娘), an adult woman.
Appearance: Sturdy, cheerful adult woman in her 30s with rosy cheeks and strong forearms.
Armor & Clothing: Rolled sleeves, a flour-dusted apron, a cloth tied over her hair.
Weapon: Holding a big cleaver in one hand and a steaming pot of braised pork in the other.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `xiuniang` ⬜ 缺

```
A vertical character portrait of an embroiderer (绣娘) who mends armor and stitches banners, an adult woman.
Appearance: Graceful adult woman in her 20s with focused eyes and a needle held in her lips.
Armor & Clothing: Neat blue dress, a pincushion on her wrist.
Weapon: Stitching a large red banner with the character 孙 across her lap.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `huansha` ⬜ 缺

```
A vertical character portrait of a riverside washerwoman (浣纱女), an adult woman.
Appearance: Lively adult woman in her 20s with a bright laugh, sleeves rolled high.
Armor & Clothing: Simple hemp dress, barefoot by the water.
Weapon: Holding a wooden washing bat over her shoulder, a basket of cloth at her side.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `caisang` ⬜ 缺

```
A vertical character portrait of a mulberry-leaf picker (采桑女), an adult woman.
Appearance: Healthy, sun-kissed adult woman in her 20s with a gentle smile.
Armor & Clothing: Country dress with a straw hat hanging on her back.
Weapon: Carrying a bamboo basket full of mulberry leaves.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `chaniang` ⬜ 缺

```
A vertical character portrait of a Jiangdong teahouse keeper (茶娘), an adult woman.
Appearance: Sharp-eyed, confident adult woman in her 30s with a sly smile.
Armor & Clothing: Smart dark-red dress with a white apron, a jade hairpin.
Weapon: Pouring tea from a long-spouted kettle with a flourish.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `lusu` ⬜ 缺

```
A vertical character portrait of Lu Su (鲁肃), a generous, far-sighted young gentleman of Jiangdong who once gave Zhou Yu half his granary.
Appearance: Round-faced, kind man in his late 20s with a calm smile and a neat short beard.
Armor & Clothing: Fine but plain scholar-gentleman robes in deep blue, a jade pendant at the belt.
Weapon: Gesturing toward a large granary behind him, a sack of grain at his feet.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `zhangzhongjing` ⬜ 缺

```
A vertical character portrait of Zhang Zhongjing (张仲景), the Sage of Medicine, who served as governor of Changsha.
Appearance: Thin, serious man in his 40s with a long grey-streaked beard and thoughtful eyes.
Armor & Clothing: Official's robe with the sleeves rolled up, a physician's satchel across the chest.
Weapon: Holding an open bamboo-slip medical book in one hand and a bundle of herbs in the other.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `dongfeng` ⬜ 缺

```
A vertical character portrait of Dong Feng (董奉), the Jiangdong doctor of the apricot grove legend.
Appearance: Gentle, ageless-looking man in his 30s with a serene smile.
Armor & Clothing: Simple Taoist-style physician robes in light green, a straw hat on his back.
Weapon: Standing under a blossoming apricot tree, a medicine gourd at his hip.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `zhangzhao` ⬜ 缺

```
A vertical character portrait of Zhang Zhao (张昭), the stern chief steward of the Sun household.
Appearance: Stern, upright man in his 30s with a severe frown and a well-kept beard.
Armor & Clothing: Dark formal official robes and cap.
Weapon: Holding a thick stack of ledgers and a writing brush, looking disapprovingly at the viewer.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `xiaoqiao` ⬜ 缺

```
A vertical character portrait of Xiao Qiao (小乔), the younger of the famous Qiao sisters, an adult woman.
Appearance: Adult woman in her 20s, lively bright eyes and a playful smile, hair in an elegant bun with flowers.
Armor & Clothing: Pink-and-white layered Han dress with flowing sleeves.
Weapon: Playing a guqin on her lap.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `zhenmi` ⬜ 缺

```
A vertical character portrait of Zhen Mi (甄宓), the renowned beauty later celebrated as the Goddess of the Luo River, an adult woman.
Appearance: Adult woman in her 20s, graceful and melancholy, long flowing black hair.
Armor & Clothing: Flowing pale-blue silk robes with gauzy ribbons drifting as if underwater.
Weapon: Holding a jade hairpin, standing by a misty river.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `bulianshi` ⬜ 缺

```
A vertical character portrait of Bu Lianshi (步练师), a gentle, capable lady of Jiangdong, an adult woman.
Appearance: Adult woman in her 20s with a soft, kind face and calm eyes.
Armor & Clothing: Elegant lavender Han dress, a simple hairpin.
Weapon: Carrying a lacquered tray with medicine bowls and bandages.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `qiaoguolao` ⬜ 缺

```
A vertical character portrait of Qiao Guolao (乔国老), the fussy old father of the Qiao sisters.
Appearance: Plump, cheerful old man in his 60s with a long white beard and rosy cheeks.
Armor & Clothing: Rich brocade robes of a retired gentleman.
Weapon: Hugging a dowry chest overflowing with silks, looking both proud and reluctant.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `huofu` ⬜ 缺

```
A vertical character portrait of an army cook (伙夫).
Appearance: Burly, cheerful adult man with a bald head and a thick mustache.
Armor & Clothing: Stained apron over a soldier's tunic.
Weapon: Stirring a huge cauldron with a long ladle.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `chuangong` ⬜ 缺

```
A vertical character portrait of a Jiangdong boatman (江东船工).
Appearance: Wiry, sun-browned adult man with a headband and rolled trousers.
Armor & Clothing: Simple hemp clothes, barefoot.
Weapon: Carrying a long punting pole and a coil of rope over his shoulder.
Background: an atmospheric ancient Chinese scene matching the character, soft natural lighting.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `yuanshu` ⬜ 缺

```
A vertical character portrait of Yuan Shu (袁术), the arrogant warlord of Nanyang who dreams of becoming emperor.
Appearance: Plump, pale man in his 30s with a thin mustache, heavy-lidded eyes full of contempt, a self-satisfied sneer.
Armor & Clothing: Gaudy gold-embroidered imperial-yellow robes he has no right to wear, a jeweled crown, rings on every finger.
Weapon: Reaching out with one greedy hand as if for the jade seal, a cup of honey water in the other.
Background: An opulent imperial audience chamber in Nanyang with carved lacquered dragon pillars, gilded screens, hanging yellow-gold imperial tapestries, and a jade throne.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `jiling` ⬜ 缺

```
A vertical character portrait of Ji Ling (纪灵), Yuan Shu's foremost general.
Appearance: Tall, grim man in his 30s with a hard square face, thick eyebrows and a short beard.
Armor & Clothing: Heavy gilded lamellar armor with the character 袁 on the chest plate, a red cape.
Weapon: Wielding a three-pointed double-edged glaive (三尖两刃刀).
Background: A massive army encampment with towering yellow Yuan-clan war banners fluttering in the wind, rows of wooden barracks, and spear racks.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `leibo` ⬜ 缺

```
A vertical character portrait of Lei Bo (雷薄), one of Yuan Shu's cavalry commanders.
Appearance: Wiry, sharp-nosed man in his 30s with a cruel grin and a scar across his chin.
Armor & Clothing: Light cavalry armor in Yuan yellow and black, a fur-trimmed collar.
Weapon: Mounted, swinging a curved cavalry saber, a bow on his back.
Background: A dusty frontier cavalry camp with horse corrals, yellow command flags, and camp tents under a glaring afternoon sun.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `chenlan` ⬜ 缺

```
A vertical character portrait of Chen Lan (陈兰), Yuan Shu's veteran general who leads the night raid.
Appearance: Weathered, stubborn man in his 40s with a grey-streaked beard and narrowed eyes.
Armor & Clothing: Battered iron armor under a rain cape, mud on his boots.
Weapon: Levelling a long spear, rain dripping from its tip, torchlight behind him.
Background: A rain-swept night battlefield with burning barricades, muddy palisade fences, and flickering torches in the drizzling rain.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `qiaorui` ⬜ 缺

```
A vertical character portrait of Qiao Rui (桥蕤), a stout officer of Yuan Shu who spies on the Sun household.
Appearance: Short, round-bellied man in his 30s with a sly smile and small shrewd eyes.
Armor & Clothing: Plain officer's armor over a merchant-style robe (he is in disguise), a straw hat hanging on his back.
Weapon: A heavy broad saber resting on his shoulder.
Background: A bustling ancient market street outside Nanyang city gate, with merchant carts, tiled roofs, hanging red lanterns, and market stalls.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `inf_n` 🟡 换掉占位

```
A vertical character portrait of a Han dynasty government sword-and-shield soldier (官军刀兵).
Appearance: Disciplined, stern-faced soldier in his 20s.
Armor & Clothing: Standard Han army lamellar armor and helmet.
Weapon: Sword raised behind a round shield.
Background: A Han dynasty garrison camp courtyard with earthen ramparts, wooden watchtowers, and red military flags.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

## 战斗 CG（横版 16:9，每场战斗一张）

### `c3_mitan`

```
A horizontal battle scene illustration: a tavern back alley at night: Yuan agents in plain clothes drawing short knives from their sleeves.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_qibing`

```
A horizontal battle scene illustration: a rainy night road: Yuan cavalry with spears charging out of the dark, rain slanting in the torchlight.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c4_liumin`

```
A horizontal battle scene illustration: the ruins of Luoyang: a desperate mob of starving refugees with hoes and sticks surging over rubble toward the grain carts.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_qinbing`

```
A horizontal battle scene illustration: a lotus garden at night: Lü Bu's Bingzhou guards with ji searching between the pavilions with lanterns.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c6_fubing`

```
A horizontal battle scene illustration: a long Chang'an street before dawn: Wang Yun's house troops in a line with ji and crossbows.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c6_xianzhen`

```
A horizontal battle scene illustration: the square before the Xuanping Gate in snow: black-armored Trap-Breaking Camp infantry behind tall shields.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c2_gongqi`

```
A horizontal battle scene illustration: a side path between wheat fields: Xiliang horse archers wheeling around and loosing arrows, fire arrows streaking.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_xunluo`

```
A horizontal battle scene illustration: outside a walled town in Nanyang: a Yuan army patrol with spears under a 袁 banner blocking a country road.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_gongshou`

```
A horizontal battle scene illustration: a fork in a road lined with trees: Yuan archers kneeling behind a low earth bank, bows drawn, a 袁 banner.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c4_gaoshun`

```
A horizontal battle scene illustration: the back gate of a scholar's mansion in Chang'an before dawn, the house burning behind: the grim, dark-faced Gao Shun standing like a post behind a wall of tall black shields bristling with halberds, his Trap-Breaking Camp utterly silent.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c4_langqi`

```
A horizontal battle scene illustration: a long Chang'an street at dawn, lanterns smashed: Bingzhou wolf riders in fur-trimmed armor galloping straight at the viewer, sabers raised, their leader howling.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c4_lvbu`

```
A horizontal battle scene illustration: the great Xuanping Gate of Chang'an in falling snow at dawn: Lü Bu on the rearing Red Hare with his halberd raised high, Gao Shun's black shield wall behind him; a woman in a black cloak (Diaochan, adult) seated behind his saddle looking away.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c6_shaoka`

```
A horizontal battle scene illustration: the Qingming Gate of Chang'an at night: a row of torches, Han guards in red and black with halberds barring the road, their officer holding out a written order.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c6_fanchou`

```
A horizontal battle scene illustration: a narrow mountain road east of Chang'an: the loud, brash Xiliang general Fan Chou on horseback swinging a huge saber, laughing, Xiliang cavalry pouring down the slope.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c6_lijue`

```
A horizontal battle scene illustration: Hangu Pass at sunset: the gaunt, cruel Li Jue on horseback before a huge 李 banner, his blade still stained, rows of Xiliang cavalry filling the pass behind him.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c7_qiaorui`

```
A horizontal battle scene illustration: a Yuan army camp gate in Nanyang in summer: the stout Qiao Rui tossing away a chicken bone and drawing his broad saber, Yuan soldiers scrambling out of their tents.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c7_leibo`

```
A horizontal battle scene illustration: a mountain road outside Wancheng: Lei Bo with a scar on his chin leading light cavalry in a charge, arrows in the air.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c7_chenlan`

```
A horizontal battle scene illustration: the walls of Wancheng in Nanyang: the grey-bearded general Chen Lan on the gate tower pointing a long spear down, archers along the battlements, the 袁 banner above.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c7_jiling`

```
A horizontal battle scene illustration: the west gate of Wancheng at dawn, smoke rising in the city behind: Ji Ling alone on horseback in gilded armor with his three-pointed double-edged blade, holding the gate while Yuan Shu's carriages flee behind him.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c6_zhangxiu`

```
A horizontal battle scene illustration: a stone bridge over the Wei river at dawn: the cocky young Zhang Xiu alone on the bridge spinning his long spear into a blur of spear-tip flowers, Xiliang cavalry under a 张 banner behind; far back a thin man on a mule sniffing a wine gourd.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c6_zhangji`

```
A horizontal battle scene illustration: a Xiliang camp gate on the Wei river bank: the steady general Zhang Ji on foot with his spear planted beside him, war drums behind, soldiers pouring out; a thin man sitting on a grain cart by the gate, sighing.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `jx_bubing`

```
A horizontal battle scene illustration: the north bank of the Yu river in autumn: a line of Jingzhou infantry with round shields painted 刘 and a forest of spears, having just waded across, reeds behind them.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `jx_gongshou`

```
A horizontal battle scene illustration: a reed marsh along the Yu river: Jingzhou archers half-hidden in tall reeds loosing a volley across the water.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `jx_huangzu`

```
A horizontal battle scene illustration: the south bank of the Yu river under a big 黄 banner: the gaunt grey veteran Huang Zu on horseback raising his ghost-head broadsword, Jingzhou troops and river boats behind him, arrows in the air.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `jx_shuijun`

```
A horizontal battle scene illustration: a Jingzhou river fortress on the Han river: bare-chested Jingzhou marines leaping from a line of war boats onto the jetty with pikes and rattan shields, a huge tiered flagship behind.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `jx_nushou`

```
A horizontal battle scene illustration: inside a burning lakeside pavilion full of smoke: Cai family crossbowmen behind torn silk curtains shooting blindly into the haze, an overturned bronze brazier spilling embers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `jx_caimao_a`

```
A horizontal battle scene illustration: a half-burnt banquet pavilion on a rock above the Han river: the burly Cai Mao clutching his bleeding right eye with one hand and swinging a long sword with the other, death-sworn guards around him, flames and smoke.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `jx_caimao_b`

```
A horizontal battle scene illustration: a moonlit banquet pavilion on a rock above the Han river, overturned tables: the burly Cai Mao in brocade over gilded armor cornered at the railing with his sword drawn, his last guards around him, crossbows now aimed at him from the curtains.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_fanchou`

```
A horizontal battle scene illustration: a courtyard duel ring at a feast: Fan Chou swinging a huge saber, laughing Xiliang officers cheering from the tables.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_zhangji`

```
A horizontal battle scene illustration: a courtyard duel ring at a feast: the steady Zhang Ji with his spear levelled, lantern light.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_niufu`

```
A horizontal battle scene illustration: a courtyard duel ring at a feast: Niu Fu charging with a heavy saber, Dong Bai standing up at the table shouting, Dong Zhuo watching with narrowed eyes.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_huzhen`

```
A horizontal battle scene illustration: the chancellor's inner gate at night: Hu Zhen barring the way with a broad saber as the great doors swing shut behind him.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c4_guosi`

```
A horizontal battle scene illustration: a looted village road: Guo Si on horseback over captured grain carts, soldiers loading the villagers' last sacks, an old man knocked down, Dong Bai smashing a cart wheel with her twin hammers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_hall`

```
A horizontal battle scene illustration: a wedding hall turned trap: red lanterns and silk, the doors slammed shut, black-armored Flying Bear cavalry pouring in from behind the curtains.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_dongzhuo`

```
A horizontal battle scene illustration: the steps before the chancellor's mansion at night: the enormous Dong Zhuo with a drawn sword among his elite black-armored guards, wedding lanterns burning behind him.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_shanfei`

```
A horizontal battle scene illustration: a one-eyed bandit chief on horseback dragging a woman in white onto his saddle amid fleeing refugees on a dusty road, a broken guqin on the ground.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_qiaorui`

```
A horizontal battle scene illustration: outside the Nanyang city wall at dusk: the stout officer Qiao Rui with Yuan soldiers in disguise stepping out of a market crowd, sabers drawn.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_jiling`

```
A horizontal battle scene illustration: a narrow mountain pass in heavy rain: Yuan Shu's foremost general Ji Ling in gilded armor with a three-pointed glaive, standing alone in front of a wall of spearmen, the final battle.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_leibo`

```
A horizontal battle scene illustration: a mountain trail at dawn: Lei Bo leading Yuan cavalry in pursuit, arrows flying, mud splashing.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_chenlan`

```
A horizontal battle scene illustration: a rainy night courtyard lit by torches: the grey-bearded general Chen Lan with a long spear at the gate under a 袁 banner, soldiers pouring in.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_yuanshu`

```
A horizontal battle scene illustration: a rain-soaked valley mouth: Yuan Shu's golden-roofed carriage behind rows of archers and a huge 袁 banner, overwhelming numbers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

## 剧情插图 CG（横版 16:9）

### `c5_yuexia`

```
A horizontal story event illustration: a moonlit garden behind the Minister's mansion, a round moon gate: Diaochan (adult, of great beauty) finishing a silent dance half a step from the hero, long sleeves still drifting in the night wind, an empty wine cup on the stone steps; her smile teasing and unreadable; silver-blue moonlight.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_mangshan`

```
A horizontal story event illustration: dawn on Mount Mang north of Luoyang, mist below: Dong Bai (adult, silver ponytail, purple fur-trimmed riding armor) on a chestnut horse glancing back with red ears after a quick kiss, galloping downhill; the hero on his horse behind her touching his cheek, stunned; the grey city far below in the sunrise.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c5_chuxi`

```
A horizontal story event illustration: New Year's Eve on the highest roof of the chancellor's mansion in Chang'an: Dong Bai (adult) asleep on the hero's shoulder with half a burnt flatbread in her hand, the hero sitting still and not daring to look down; below, the city glowing with bonfires of crackling bamboo, snow on the tiles.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c4_xizi`

```
A horizontal story event illustration: lamplight inside a small army tent at night: Cai Wenji (adult, in white) guiding the hero's hand over a brush, her hand over his, both leaning over a sheet of paper with wobbly characters; soft warm glow, tender and shy.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_snow`

```
A horizontal story event illustration: a snowy back veranda of a scholar's house at night: Cai Wenji (adult, in white) playing a guqin on her knees with snow settling on the strings, the hero sitting beside her in a red wedding robe she has just fitted on him; lantern glow, quiet and bittersweet.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c7_stars`

```
A horizontal story event illustration: a grassy hilltop above an army camp on a summer night under a sky full of low stars: Cai Wenji (adult, in white) playing a guqin across her knees, the short-haired hero lying back in the grass listening.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_zhujun`

```
A horizontal story event illustration: Sun Jian's camp in the ruins of Luoyang: the veteran general Zhu Jun (grey-bearded, straight-backed, hearty laugh) slapping the huge Sun Jian on the shoulder, Sun Jian bowing formally for once; Sun Ce behind them red-faced trying not to laugh.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c6_yizu`

```
A horizontal story event illustration: the palace steps of Chang'an the day after Dong Zhuo's death: Dong Bai (adult) kneeling numbly on the stone, the short-haired hero standing in front of her with his blade half drawn, the white-haired Huangfu Song stepping to his side; high above, the small boy emperor clutching a pillar.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c6_warn`

```
A horizontal story event illustration: night at a window in Chang'an: Diaochan (adult) in a black cloak, pale but smiling, leaning in at the hero's window by candlelight; in the neighbouring window Dong Bai slamming her shutters.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c4_siege`

```
A horizontal story event illustration: before dawn, torches around a scholar's house in Chang'an: the elderly Cai Yong being led away without resisting, looking back; Cai Wenji (adult, in white) reaching after him, held back by the short-haired hero.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_dongjia`

```
A horizontal story event illustration: a ruined roadside shrine at dawn: the door kicked open, Dong Bai (adult) standing in the doorway with her twin hammers, grey-haired veterans only as silhouettes behind her; the hero looking up from the straw.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c7_feng`

```
A horizontal story event illustration: a lamplit army tent at night: the beautiful Lady Feng (adult) pouring wine for the hero and resting her fingertips on his wrist; at the tent flap Dong Bai (adult) slamming a hammer down and Cai Wenji (adult, in white) with a snapped zither string, both glaring.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c6_jiaxu`

```
A horizontal story event illustration: an abandoned Xiliang camp on the Wei river after a battle: the thin, sleepy-eyed strategist Jia Xu (mid-40s, loose faded officer's robe, gourd flask at his belt) tied up with rope and lounging comfortably on sacks in a grain cart, still sniffing a wine gourd; young Sun Ce, who just tied him, holding the rope end with a spear on his shoulder; the short-haired hero studying him; Zhou Yu frowning over his ledger; comic.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_jiayan`

```
A horizontal story event illustration: a family supper in the courtyard of the Wancheng governor's house on an autumn evening: Lady Wu (adult) handing the short-haired hero a big bowl of chicken soup and ruffling his cropped hair; Sun Ce hanging over the edge of the pot trying to snatch meat; warm lantern light.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_liuxian`

```
A horizontal story event illustration: the bank of the Yu river at sunset: Diaochan (adult, of great beauty) in a light pale-jade southern 'liuxian' skirt sitting hugging her knees on the grass, laughing with her hand over her mouth; in the shallows Sun Ce slipping while grabbing at a fish; Zhou Yu on a rock writing in his ledger.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_caifuren`

```
A horizontal story event illustration: a lavish welcome banquet in Xiangyang: Lady Cai (adult, purple gold-embroidered silks, phoenix hairpin) holding Cai Wenji's (adult, in white) hands over an open clan genealogy book, all warm smiles; beside them Diaochan (adult) accepting a box of pearls with an equally sweet smile; the elderly scholar Cai Yong stroking his beard sceptically in the background.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_shuige`

```
A horizontal story event illustration: a lavish pavilion over the Han river, the only door sealed by a fallen iron portcullis, crossbowmen behind the curtains: Diaochan (adult) in a pale-jade skirt draining a gold beast-shaped wine cup before the burly Cai Mao, her other hand already reaching for the hairpin in her hair; the short-haired hero half-rising with his blade half drawn, shouting; tense, no gore.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_xiangxiao`

```
A horizontal story event illustration: the smoking ruin of a pavilion on a rock above the Han river at dawn: the short-haired hero kneeling, holding Diaochan (adult, pale, in a scorched pale-jade skirt) in his arms; she smiles faintly and touches his cropped hair; restrained and elegiac, no gore.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_henhai`

```
A horizontal story event illustration: a cold rainy night on the bank of the Han river: the short-haired hero alone, crouching at the water's edge washing a pale-jade woman's skirt, holding half of a broken hairpin; behind him in the rain a young man in white mourning clothes stepping closer; bleak, restrained, no gore.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_dress`

```
A horizontal story event illustration: a bedroom in the Xiangyang guesthouse in the afternoon: Diaochan (adult) at a bronze mirror in her most beautiful pale-jade skirt embroidered with water patterns; Lady Wu (adult) pinning her hair; the short-haired hero crouching beside her tucking a strand of hair behind her ear; gentle and warm.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_grapes`

```
A horizontal story event illustration: a lamplit banquet pavilion over the Han river: Diaochan (adult, pale-jade skirt) had risen and started toward the burly Cai Mao, one hand already at the hairpin in her hair, ready to drink the poison for the hero — and the short-haired hero has caught her by the waist and pulled her back into his arms, his other hand sweeping a gold beast-shaped wine cup away across the table; she looks up at him, startled; across the table Cai Mao going green in the face; tense and tender.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c8_louchuan`

```
A horizontal story event illustration: the bow of a great tiered warship on the moonlit Han river: Diaochan (adult) in a pale-jade skirt fluttering in the wind leaning on the short-haired hero's shoulder, a paper packet of hot roasted chestnuts in her hands; a huge full moon over the river, silver ripples.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `end_henhai`

```
A horizontal story event illustration: an ending card illustration, quiet and symbolic: half of a broken jade hairpin and a folded pale-jade silk skirt lying on wet pebbles at the edge of the Han river at night, cold rain on the water, a distant pavilion on a rock burnt black; muted colours, no people, no blood.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c7_flee`

```
A horizontal story event illustration: the east gate of Wancheng in a cloud of dust: Lady Feng (adult) lifting the curtain of her palanquin as it hurries away behind a few loaded carts and glancing back with a faint smile; the hero watching from the captured wall under a 孙 banner.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `end_yusui`

```
A horizontal story event illustration: an ending card illustration, quiet and symbolic: the Imperial Jade Seal broken into pieces on a wet grey stone by a rainy mountain road, its gold-mended corner lying in the mud, a woman's hairpin beside it; cold rain, muted colours, no people.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `end_tonggui`

```
A horizontal story event illustration: an ending card illustration, quiet and symbolic: three sets of footprints side by side in fresh snow before the closed Xuanping Gate of Chang'an at dawn, a pair of notched bronze hammers and a broken guqin lying together in the snow; soft falling snow, muted colours, no people, no blood.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_tonggui`

```
A horizontal story event illustration: dawn in falling snow before the closed Xuanping Gate of Chang'an, seen from behind: the short-haired hero in battered silver armor, Dong Bai (adult) with her notched twin hammers on his left, Cai Wenji (adult, in white) holding a broken guqin on his right, the three holding hands and stepping forward together; restrained and elegiac, no gore.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c6_fenghou`

```
A horizontal story event illustration: the throne hall in Chang'an: the ten-year-old boy emperor leaning forward on a huge throne, insisting in a trembling voice; below him the white-haired Wang Yun bowing with a smile that doesn't reach his eyes.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c6_escape`

```
A horizontal story event illustration: night escape from Chang'an: a covered carriage racing through a burning city gate, the boy emperor peeking out clutching a small bundle; Dong Bai (adult) riding alongside with her twin hammers; the hero riding on the other side with Diaochan (adult) behind his saddle.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c6_huihe`

```
A horizontal story event illustration: the restored gate of Luoyang at dawn: the huge Sun Jian in his tiger-pelt cape kneeling on one knee in the dust before the small boy emperor stepping down from a battered carriage.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c6_seal`

```
A horizontal story event illustration: a makeshift throne hall in half-ruined Luoyang: the boy emperor on a simple throne asking quietly; the huge Sun Jian clutching a brocade box against his chest, not offering it; Zhou Yu writing in his ledger with lowered eyes; Lady Wu (adult) watching Sun Jian from the back.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c7_huangzhong`

```
A horizontal story event illustration: a captured camp in Nanyang: Huang Zhong, a sturdy man in his 40s in rough soldier's clothes, rope marks on his wrists, drawing a heavy bow to full; his arrow snapping the banner pole with the character 袁 on the far camp gate; Sun Ce gaping, the hero grinning.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_garden`

```
A horizontal story event illustration: behind a rockery in the palace garden of Chang'an: the ten-year-old boy emperor, his heavy bead-curtained crown taken off and set on a stone, rubbing his neck and looking up hopefully at the short-haired hero in silver armor, who crouches to his eye level; a eunuch keeps watch at the corner; a gentle, melancholy mood.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_feast`

```
A horizontal story event illustration: a lavish welcome feast in Dong Zhuo's mansion: the enormous Dong Zhuo peeling shrimp for his granddaughter Dong Bai (adult), who laughs with her mouth full; he wipes his eye with his sleeve.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c5_dance`

```
A horizontal story event illustration: a lantern-lit banquet hall: Diaochan, an adult woman of great beauty, dancing with long silk sleeves; the enormous Dong Zhuo leaning forward spellbound with wine in his beard; Wang Yun at the host's seat with a knowing half-smile.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_fengyi`

```
A horizontal story event illustration: the Phoenix Pavilion in a lotus garden: Diaochan (adult) weeping on Lü Bu's shoulder at the railing; behind them the furious Dong Zhuo hurling Lü Bu's halberd; Lü Bu twisting away; Diaochan's eyes glancing sideways toward the viewer with the ghost of a smile.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_rescue`

```
A horizontal story event illustration: a long street at night: Lü Bu on the rearing Red Hare charging in with his halberd, Diaochan (adult) holding on behind his saddle with bloodied hands, shouting.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_wenji`

```
A horizontal story event illustration: night by a campfire in ruined Luoyang: Cai Wenji, an adult woman in white, holding her guqin with a broken string, telling her story; Dong Bai listening with folded arms, Lady Wu wrapping a cloak around Cai Wenji.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c4_peace`

```
A horizontal story event illustration: Sun Jian's tent in ruined Luoyang: the envoy Li Ru waving a feather fan and offering peace with a gentle smile; the huge Sun Jian sitting with crossed arms, scowling.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_betroth`

```
A horizontal story event illustration: a comedic betrothal in a tent: the short-haired hero pointing at himself in disbelief; Dong Bai (adult) beside him looking away with bright red ears; Sun Ce leaping up in refusal; Lady Wu (adult) laughing behind her sleeve.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c5_enter`

```
A horizontal story event illustration: the gates of Chang'an: the enormous Dong Zhuo hugging his granddaughter Dong Bai (adult), who laughs; over her shoulder his smiling eyes are cold; behind him Lü Bu on Red Hare, silent.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c5_diaochan`

```
A horizontal story event illustration: a moonlit garden: Diaochan, an adult woman of great beauty, kneeling before an incense burner praying to the moon; Wang Yun and the hero watching from the garden gate.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_dress`

```
A horizontal story event illustration: a bedroom in Chang'an: Dong Bai (adult) in a red wedding dress turning happily before a bronze mirror, the hero behind her with a troubled face.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c5_wedding`

```
A horizontal story event illustration: the wedding trap in a hall of red lanterns: the enormous Dong Zhuo raising his cup with a cruel smile; beside him Dong Bai (adult) in a red wedding dress lifting her veil in shock, the hero pulling her behind him.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c5_death`

```
A horizontal story event illustration: the moment of mercy, restrained: Dong Bai (adult) in her red wedding dress kneeling with her arms spread wide to shield a fallen figure on the palace steps, looking up at Lü Bu towering on Red Hare with his halberd raised; no gore.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c3_feng`

```
A horizontal story event illustration: a quiet veranda in Luyang: Lady Wu sewing a winter coat and the beautiful Lady Feng embroidering a handkerchief side by side, laughing over a plate of pastries — Lady Feng's eyes sliding toward a brocade box half-hidden inside.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_mixin`

```
A horizontal story event illustration: night after a battle: Zhou Yu reading a captured secret letter by torchlight, Sun Jian crushing its edge in his fist, far on the horizon the sky over Luoyang faintly red.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_leave`

```
A horizontal story event illustration: leaving the ruins of burning Luoyang: Sun Jian riding in front hugging a brocade box; Lady Wu (adult) leaning from a carriage to hand bread to a child; a long column of refugees trudging behind them.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_wenji`

```
A horizontal story event illustration: on a muddy road after a fight: Cai Wenji, an adult woman in a white robe, kneeling to pick up her guqin with a broken string, Dong Bai with her twin hammers looking away embarrassed, Lady Wu putting a cloak on Cai Wenji's shoulders.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `c3_supply`

```
A horizontal story event illustration: night in a hungry army camp: Sun Jian alone by a campfire opening and closing a brocade box, Zhou Yu counting on his fingers, Sun Ce hiding his rice bowl behind his back.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_slip`

```
A horizontal story event illustration: a lively tavern full of drinkers: a tipsy Sun Ce slamming the table and bragging, Zhou Yu lunging to cover his mouth, the hero tossing coins on the table; at the next table soldiers in Yuan livery freezing mid-bite.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_entrust`

```
A horizontal story event illustration: lamplit room at night: Sun Jian placing the brocade box with the jade seal into Lady Wu's hands, the hero standing at the doorway, Sun Jian gruffly avoiding his eyes.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_warn`

```
A horizontal story event illustration: the night before the campaign: the hero earnestly pleading with Sun Jian, who laughs and claps him hard on the shoulder, a war banner and armor stand behind them.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_raid`

```
A horizontal story event illustration: a rainy night at a courtyard gate lit by torches: the grey-bearded general Chen Lan with a long spear under a 袁 banner; the short-haired hero barring the way, Lady Wu (adult) behind him clutching a brocade box.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_news`

```
A horizontal story event illustration: a rainy mountain pass: the defeated general Ji Ling kneeling in the mud, leaning on his three-pointed blade; Lady Wu (adult) slowly sinking to her knees in the rain.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_end`

```
A horizontal story event illustration: a restrained tragic scene in the rain on a mountain road: Lady Wu (adult) standing tall and calm, lifting the Imperial Jade Seal high over a grey stone, her face serene; Yuan Shu's golden-roofed carriage only a blur in the background; no gore.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_handover`

```
A horizontal story event illustration: a restrained, somber scene: the woman general Dong Bai in a prisoner cart looking back over her shoulder, the hero standing alone at the camp gate, grey sky (no gore).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `e_tangji`

```
A horizontal story event illustration: a ruined temple: Lady Tang, an adult woman in coarse clothes with soot on her cheek, clutching a jade hairpin, looking up with unyielding eyes as the hero and Lady Wu find her.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_yazhai`

```
A horizontal story event illustration: a mountain bandit fort: the curvy bandit queen 'Rouge Tiger' standing hands on hips on the fort wall with twin sabers, pointing at the embarrassed hero, her chubby husband carrying a pig behind her (comedic).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_shengnv`

```
A horizontal story event illustration: a forest clearing: the Yellow Turban saint Zhang Ning, an adult woman in a yellow Taoist robe with a nine-section staff, handing out bowls of charm water to kneeling ragged followers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `i2_yuxi`

```
A horizontal story event illustration: night on a river boat: Sun Jian hugging a brocade box at the bow, Lady Wu standing at the cabin door holding a late-night snack.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `i2_duel`

```
A horizontal story event illustration: sunset riverbank: Dong Bai and Sun Ce collapsed on the ground laughing after a long duel, hammers and spear dropped beside them.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
(Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor and two huge bronze hammers (her delivered portrait and CGs all look like this).)
```

### `i2_qin`

```
A horizontal story event illustration: night on the stern of a boat: Lady Tang playing a guqin, Lady Wu draping a coat over her shoulders.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

## 奇遇插图（？格事件，横版 16:9，key = e_<事件 id>，放 `pics/source/cg/`，和剧情 CG 一样登记）

### `e_ambush`

```
A horizontal story event illustration: river bandits bursting out of tall reeds with gongs and rusty sabers, shouting.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_snake`

```
A horizontal story event illustration: comic scene: the short-haired hero hopping on one leg clutching his thigh, a small green bamboo viper slithering away, Sun Ce and Zhou Yu doubled over laughing.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_tiger`

```
A horizontal story event illustration: a white-browed tiger lounging on a rock on a mountain road, lazily licking its paw, staring at the viewer.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_zuoci`

```
A horizontal story event illustration: a white-haired old Taoist grinning with two front teeth, sitting on a boulder with a bamboo staff, purple smoke curling from a gourd in his hand.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_chest`

```
A horizontal story event illustration: a rusty iron chest half-buried by the roadside, carved with four small characters 非礼勿开.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_hero`

```
A horizontal story event illustration: a burly man in a roadside tavern smashing a table with one fist, wine cups flying, drinkers scattering.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_refugees`

```
A horizontal story event illustration: a column of ragged refugees on a dusty road, an old man collapsed, a mother holding a child out toward the viewer.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_washer`

```
A horizontal story event illustration: a cheerful adult woman washing clothes at a mountain stream, sleeves rolled up, laughing, a basket of cloth beside her.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_dice`

```
A horizontal story event illustration: river bandits gambling with dice on a broken boat by the river, waving the viewer over.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_fruit`

```
A horizontal story event illustration: a tree heavy with glossy red fruit by an empty road, Zhou Yu raising a warning finger.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_risk`

```
A horizontal story event illustration: a small boat in thick river fog, an old boatman squatting at the bow smoking a long pipe, dangerous rapids ahead.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_temple`

```
A horizontal story event illustration: a crumbling mountain temple with a noseless earth-god statue, half a stick of incense still smoking in the censer.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_grand_chest`

```
A horizontal story event illustration: a big gilded chest carved with the character 袁 in an army camp, a pompous lord forcing a smile.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_huatuo`

```
A horizontal story event illustration: a lean middle-aged doctor treating a village woman at a roadside medicine stall, his box painted 沛国华佗.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_yuji`

```
A horizontal story event illustration: a Taoist in white blocking the road, waving a banner reading 于吉仙师 符水治百病, followers kneeling.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_merchant`

```
A horizontal story event illustration: a plump merchant with a donkey cart piled with exotic goods, spreading his arms in welcome.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_smith`

```
A horizontal story event illustration: a roadside smithy with a roaring forge, a bare-chested old blacksmith hammering a glowing blade.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_tomb`

```
A horizontal story event illustration: a half-collapsed ancient tomb in a mountain hollow, cold wind from the entrance, Sun Ce stepping in eagerly while Zhou Yu checks his ledger.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_guanlu`

```
A horizontal story event illustration: a young diviner at a fortune-telling stall under a tree, sign reading 管辂神算.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_xushao`

```
A horizontal story event illustration: the famous critic Xu Shao holding court under a tree by the roadside, a crowd of hopeful men waiting for his one-line verdicts.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_qiao`

```
A horizontal story event illustration: two beautiful adult sisters washing clothes by a river, one gentle and one lively, Sun Ce and Zhou Yu frozen mid-step staring.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_drink`

```
A horizontal story event illustration: a tavern drinking contest: Sun Ce slamming a wine jar on the table, a crowd of drinkers circling and cheering.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_deserters`

```
A horizontal story event illustration: ragged deserters without armour crouching by the road gnawing bark, shrinking back in fear.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_storm`

```
A horizontal story event illustration: a sudden thunderstorm turning a road into mud, the army struggling through the rain.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_horse`

```
A horizontal story event illustration: a horse dealer holding the reins of two horses — a white-faced one with an ominous look and a fiery red one.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_convoy`

```
A horizontal story event illustration: a few Xiliang soldiers escorting grain carts with sacks stamped 董 along a road below a hill.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_surrender`

```
A horizontal story event illustration: a small group of men in yellow headscarves carrying a white flag, kneeling on a road.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_shanzei`

```
A horizontal story event illustration: a one-eyed bandit with a big axe jumping out at a mountain bend, his gang behind him.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_shanzhai`

```
A horizontal story event illustration: a mountain bandit fort with a tattered 替天行道 banner, smoke of roasting meat rising, Sun Ce swallowing.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_jieying`

```
A horizontal story event illustration: a night camp raid: dogs barking, a wall of torches coming out of the dark.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_hj_camp`

```
A horizontal story event illustration: a Yellow Turban remnant camp in a valley: old people, children and women around a pot of wild greens, thin smoke.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_hj_medics`

```
A horizontal story event illustration: a ruined temple where a woman in a yellow headscarf cleans a wounded soldier's wound, a Taiping talisman on her medicine box.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_hj_road`

```
A horizontal story event illustration: Yellow Turban remnants charging out of a forest with sticks and bamboo spears, shouting.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_yuan_tax`

```
A horizontal story event illustration: a roadside toll shed where two soldiers in Yuan livery block the road with spears, demanding rice.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_black_market`

```
A horizontal story event illustration: a narrow alley at night lit by a green lantern, a masked man opening his coat full of stolen treasures.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_jz_spy`

```
A horizontal story event illustration: a suspicious peddler caught at a city gate, a map of the city defences falling out of his carrying pole.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_veterans`

```
A horizontal story event illustration: two old soldiers, one missing an arm, sunning themselves at a city gate and recognising Sun Ce with joy.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_plague`

```
A horizontal story event illustration: a village entrance hung with white cloth, an old doctor raising his hand to stop the viewer.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_yuxi_rumor`

```
A horizontal story event illustration: a crowded teahouse, everyone whispering behind their hands.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_tongyao`

```
A horizontal story event illustration: children clapping and running along a road singing, in the background the silhouette of a huge fat man.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_zhuhou_yan`

```
A horizontal story event illustration: an envoy presenting an invitation card from the allied commander's camp, banquet tents in the background.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there). At most four named characters in focus; unnamed background people (soldiers, crowds) are fine.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

## 天命图（512×512 透明 PNG，放 `godot/data/art/fates/<key>.png`；没有图时显示一个汉字）

## 词缀徽记（128×128 透明 PNG，放 `godot/data/art/affixes/<key>.png`）

## 界面大图（横版 16:9 JPG，放 `godot/data/art/ui/<key>.jpg`）

## 宝箱图（开宝箱动画用，512×512 透明 PNG，放 `godot/data/art/ui/<key>.png`）

### `chest_normal`

```
A game item sprite: a sturdy wooden treasure chest with bronze corner caps and a heavy bronze padlock, Han-dynasty style, closed.
Composition & Framing: square 512x512, the chest centred at a slight three-quarter angle, transparent background (PNG), no shadow box.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, painted prop, rich colours, crisp outline; no text.
```

### `chest_grand`

```
A game item sprite: a grand red-lacquered treasure chest painted with gold clouds and dragons, inset with jade, a faint golden glow leaking from the seam, closed.
Composition & Framing: square 512x512, the chest centred at a slight three-quarter angle, transparent background (PNG), no shadow box.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, painted prop, rich colours, crisp outline; no text.
```

## 章节地图底图（横版宽图，放 `pics/source/map/bg_<key>.jpg`）

### `yuxi`

```
A wide horizontal game map illustration, a hand-painted Chinese landscape scroll (浅绛 / 青绿山水): the road from burning Luoyang south to Luyang (in Nanyang commandery), left to right: the smoking ruins of Luoyang and a long line of refugees; hills and a starving army camp; the walled town of Luyang with a tavern street; rain-soaked farmland with a Yuan army camp; a narrow mountain pass in heavy rain at the far right.
Composition & Framing: very wide panorama, 3200x1080 (it scrolls sideways), seen from high above at an angle; keep three roughly horizontal travel bands (top / middle / bottom) free of busy detail, map squares sit on them; soft mist.
Style: match the chapter-1 map (godot/data/art/map/prologue.jpg): ink outlines, soft green and ochre washes on rice paper; no text, no UI, no people close up.
```

### `shouluoyang`

```
A wide horizontal game map illustration, a hand-painted Chinese landscape scroll (浅绛 / 青绿山水): ruined Luoyang being rebuilt, left to right: a campfire among the ashes; a road where officials' families were escorted west; a Xiliang grain convoy on a mountain foot road; the restored ancestral temple and city walls with Sun banners; a peaceful market street; at the far right the western road toward Chang'an.
Composition & Framing: very wide panorama, 3200x1080 (it scrolls sideways), seen from high above at an angle; keep three roughly horizontal travel bands (top / middle / bottom) free of busy detail, map squares sit on them; soft mist.
Style: match the chapter-1 map (godot/data/art/map/prologue.jpg): ink outlines, soft green and ochre washes on rice paper; no text, no UI, no people close up.
```

### `changan`

```
A wide horizontal game map illustration, a hand-painted Chinese landscape scroll (浅绛 / 青绿山水): Chang'an in winter, left to right: the grand city gate; Dong Zhuo's lavish mansion with a courtyard duel ring; the palace with a rockery garden; a scholar's modest house; the Minister's mansion; a lotus pond with the Phoenix Pavilion; at the far right the chancellor's mansion hung with red wedding lanterns.
Composition & Framing: very wide panorama, 3200x1080 (it scrolls sideways), seen from high above at an angle; keep three roughly horizontal travel bands (top / middle / bottom) free of busy detail, map squares sit on them; soft mist.
Style: match the chapter-1 map (godot/data/art/map/prologue.jpg): ink outlines, soft green and ochre washes on rice paper; no text, no UI, no people close up.
```

### `jingxiang`

```
A wide horizontal game map illustration, a hand-painted Chinese landscape scroll (浅绛 / 青绿山水): from Nanyang south to the Han river, left to right: the walled city of Wancheng in autumn with a courtyard kitchen; the reed-lined Yu river and its battlefield; the road south through hills; the walled city of Xiangyang on the Han river with a river fortress full of war boats; at the far right a lone pavilion on a rock above the river at Wanshan.
Composition & Framing: very wide panorama, 3200x1080 (it scrolls sideways), seen from high above at an angle; keep three roughly horizontal travel bands (top / middle / bottom) free of busy detail, map squares sit on them; soft mist.
Style: match the chapter-1 map (godot/data/art/map/prologue.jpg): ink outlines, soft green and ochre washes on rice paper; no text, no UI, no people close up.
```

### `dongui`

```
A wide horizontal game map illustration, a hand-painted Chinese landscape scroll (浅绛 / 青绿山水): one long campaign, left to right: snowy Chang'an palace and the Xuanping Gate; the Wei river road east; the mountains and Hangu Pass; half-restored Luoyang with Sun banners; the summer road south; a Yuan army camp; the walled city of Wancheng in Nanyang at the far right.
Composition & Framing: very wide panorama, 3200x1080 (it scrolls sideways), seen from high above at an angle; keep three roughly horizontal travel bands (top / middle / bottom) free of busy detail, map squares sit on them; soft mist.
Style: match the chapter-1 map (godot/data/art/map/prologue.jpg): ink outlines, soft green and ochre washes on rice paper; no text, no UI, no people close up.
```

### `taodong`

```
A wide horizontal game map illustration, a hand-painted Chinese landscape scroll (浅绛 / 青绿山水): the march north to fight Dong Zhuo, left to right: country roads and farmland leaving the south; a dusty Central-Plains highway with a burnt village; the battlefield before Sishui Pass where Hua Xiong fought (a mountain gap with a watchtower); Sun Jian's big army camp with palisades, tents and red banners; a barren windswept wasteland (Hulao Pass, where the three heroes fought Lü Bu); and at the far right the walls of Luoyang burning at dusk, smoke rising into an ember sky.
Composition & Framing: very wide panorama, 3200x1080 (it scrolls sideways), seen from high above at an angle; keep three roughly horizontal travel bands (top / middle / bottom) free of busy detail, map squares sit on them; soft mist.
Style: match the chapter-1 map (godot/data/art/map/prologue.jpg): ink outlines, soft green and ochre washes on rice paper; no text, no UI, no people close up.
```

## 宝物图标（256×256 透明 PNG，放 `pics/source/relics/<key>.png`；现在是程序生成的占位）

### `shoushihe`

```
Masterpiece 1:1 square game inventory item icon of an exquisite Han dynasty Chinese lacquer jewelry box (汉代黑红髹漆妆奁), lid slightly ajar showing delicate jade hairpins, gold tassels and pearls inside.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `jiunang`

```
Masterpiece 1:1 square game inventory item icon of an ancient Chinese gourd flask wine pouch (左慈酒葫芦/酒囊), polished leather and dried gourd with brass spout, wrapped in ceremonial red cord with a bronze coin charm.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `bingfu`

```
Masterpiece 1:1 square game inventory item icon of an authentic ancient Chinese Han dynasty bronze Tiger Tally (汉代错金铜虎符), cast in the shape of a crouching tiger with inlaid gold seal script characters on its back.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `hushenfu`

```
Masterpiece 1:1 square game inventory item icon of a traditional Chinese silk protective amulet pouch (汉代朱砂平安符囊), triangular folded cinnabar red silk embroidered with gold cloud patterns, bound by silk cord with a jade bead and red tassels.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `xiangnang`

```
Masterpiece 1:1 square game inventory item icon of an authentic Han dynasty Chinese embroidered scented sachet (汉代刺绣茱萸香囊), rhombus-shaped silk pouch with gold thread floral embroidery, tied with a traditional Chinese mystic knot (同心结) and dual crimson silk tassels.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `jinfan`

```
Masterpiece 1:1 square game inventory item icon of Gan Ning's Brocade Sail Bells (甘宁锦帆铃), two ornate ancient Chinese bronze ringing bells with incised wave patterns, bound together with a vibrant flowing patterned brocade silk ribbon.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `bingfa`

```
Masterpiece 1:1 square game inventory item icon of an ancient Chinese bamboo scroll book of Sun Tzu's Art of War (孙子兵法竹简), aged brown bamboo slips bound with leather cord, partially unrolled to reveal brush-inked clerical script calligraphy, paired with a small bamboo calligraphy brush.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `gudingdao`

```
Masterpiece 1:1 square game inventory item icon of Sun Jian's ancient broad-bladed saber with a ring pommel (古锭刀), an authentic Han dynasty ring-pommel broad saber (环首刀) with brass cloud-pattern fittings and a black-lacquered wood scabbard with red tassels.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `yushan`

```
Masterpiece 1:1 square game inventory item icon of Zhou Yu's crane feather fan (周瑜白鹤羽扇), pure white crane feathers neatly arranged, bound with a carved pale green jade handle and silk tassel.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `zhangu`

```
Masterpiece 1:1 square game inventory item icon of a Han dynasty Chinese red-lacquered war drum (汉军战鼓), heavy cowhide drumhead, ornate dragon brass studs on the drum rim, resting beside a pair of wooden drumsticks wrapped in red cloth.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `chize`

```
Masterpiece 1:1 square game inventory item icon of Sun Jian's red headscarf (祖茂/孙坚赤帻), a bold crimson silk warrior turban cloth with battle wear and scorched edges, tied with a knot.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `qinggang`

```
Masterpiece 1:1 square game inventory item icon of the legendary Qinggang Sword (青釭剑), a pristine double-edged Chinese straight sword (汉剑) of tempered blue-tinted steel, intricate brass guard with dragon engravings and dark lacquered scabbard.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `bazhen`

```
Masterpiece 1:1 square game inventory item icon of Zhuge Liang's Eight Trigrams Formation scroll (八阵图), an antique silk map scroll spread open showing painted bagua diagrams, stones, and tactical compass markings in vermilion and ink.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `dunjia`

```
Masterpiece 1:1 square game inventory item icon of Zuo Ci's Book of Dunjia (遁甲天书), an ancient mystical Taoist silk-bound tome with archaic seals, faint golden light, and paper talismans tucked between the aged pages.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `muniu`

```
Masterpiece 1:1 square game inventory item icon of the Wooden Ox (木牛流马), an ingenious ancient Chinese mechanical wooden transport in the stylized shape of a carved wooden ox with bronze gears and levers.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `beishui`

```
Masterpiece 1:1 square game inventory item icon of an ancient bronze three-legged cooking cauldron (破釜) with chipped rim and battle scratches, beside a charred burning ship plank.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `dingxin`

```
Masterpiece 1:1 square game inventory item icon of an ancient Chinese medicinal pill box (定心丸), carved dark cinnabar lacquer box containing a gleaming golden herb-rolled pill on yellow silk lining.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `jubaopen`

```
Masterpiece 1:1 square game inventory item icon of the Treasure Basin (聚宝盆), an ornate Han dynasty bronze and gilt basin filled with sparkling sycee silver ingots (元宝), gold nuggets, and antique coins.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `chitu`

```
Masterpiece 1:1 square game inventory item icon of Red Hare's ceremonial golden saddle and bridle (赤兔金鞍缰辔), an opulent warhorse saddle of crimson leather and gilded bronze fittings, with ornate brass stirrups and red plume bridle.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `zhangba`

```
Masterpiece 1:1 square game inventory item icon of the blade head of Zhang Fei's Eighteen-foot Snake Spear (丈八蛇矛), undulating wavy steel spear blade shaped like a writhing serpent, with a black steel socket and crimson horsehair tassel.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `zhugenu`

```
Masterpiece 1:1 square game inventory item icon of Zhuge's Repeating Crossbow (诸葛连弩), an ingenious Han dynasty wooden multi-shot crossbow with top-mounted bolt magazine and bronze firing mechanism.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `qinglong`

```
Masterpiece 1:1 square game inventory item icon of the head of Guan Yu's Green Dragon Crescent Blade (青龙偃月刀), heavy steel curved glaive blade with an engraved green dragon swallowing the steel base, adorned with a brass dragon collar and crimson tassel.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `mengde`

```
Masterpiece 1:1 square game inventory item icon of Cao Cao's New Book of Mengde (孟德新书), a fine silk-wrapped bamboo scroll case and unrolled bamboo slips bearing Cao Cao's military commentary and vermilion personal seal.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `heishan`

```
Masterpiece 1:1 square game inventory item icon of the Black Mountain Command Token (黑山令), an imposing dark iron and bronze pass token engraved with a fierce coiled dragon and archaic Chinese characters, tied with rough braided rope.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `taipingyaoshu`

```
Masterpiece 1:1 square game inventory item icon of Zhang Jue's Essential Art of Great Peace (太平要术), ancient scrolls bound in yellow silk, covered with vermilion Taoist incantations, thunder talismans, and celestial diagrams.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `qingnang`

```
Masterpiece 1:1 square game inventory item icon of Hua Tuo's Green Pouch Book (青囊书), a weathered green brocade medicine scroll bundle tied with leather cords, accompanied by silver acupuncture needles and dried healing herbs.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `huangjinfu`

```
Masterpiece 1:1 square game inventory item icon of a Yellow Turban Talisman (黄巾符), yellow hemp paper talisman inscribed with cinnabar red mystical Daoist spell script, singed by lightning and smoke at the corners.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `dilu`

```
Masterpiece 1:1 square game inventory item icon of Hex Mark's silver stirrup and bridle (的卢辔饰), refined white leather and silver-inlaid bridle and bit with tear-shaped silver ornaments and blue tassels.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `fangtian`

```
Masterpiece 1:1 square game inventory item icon of the head of Lü Bu's Sky Piercer Halberd (方天画戟), a formidable four-pointed spearhead flanked by dual polished crescent moon side blades and red battle tassels.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

### `tengjia`

```
Masterpiece 1:1 square game inventory item icon of the Southern Rattan Armor (藤甲), woven impenetrable dried wild mountain vine breastplate, treated with oil and bound with brass rivets.
Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.
Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.
Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.
```

## 已出图的提示词存档（重画时从这里开始）

### `i1_sewing` ✅

```
横版 16:9 剧情CG插画，三国日系战术卡牌RPG第一章通关幕间事件图：【吴夫人的针线 · 窗里温存与窗外受气包】
- 室内温馨核心互动（暖光主舞台）：
  - 深夜的富春庄园寝房内，案几上的油灯洒下暖洋洋的橘色柔光。
  - 【吴夫人（宠溺调侃）】：三十多岁的绝色美妇身穿素雅柔顺的居家对襟襦裙，青丝微挽。膝头放着一件正缝制到一半的厚实保暖冬衣，手中捏着细长的缝衣针，正笑靥如花、极其宠溺地拿圆润的针尾轻轻敲了一下主角的额头，眼神满是亲昵与调侃。
  - 【主角（心满意足）】：青年主角坐在她身旁，微笑着伸手让夫人比量衣袖长短，桌边搁着他刚端进来的一大碗热气腾腾的枸杞鸡汤与竹编针线笸箩。
- 窗外喜剧反差神笔（画龙点睛的笑点）：
  - 透过室内敞开的雕花木窗，映出窗外清冷的青蓝月夜庭院：
  - 【可怜的孙策】：少年孙策正像个被遗弃的小狗一样，孤零零蹲在墙根底下的泥地里。手里死死抓着自己那件线头乱飞、歪歪扭扭还没缝好的烂棉袄，鼓着圆滚滚的包子脸，眼泪汪汪又咬牙切齿地透过窗户缝偷看屋里亲昵的两人，委屈酸楚溢出屏幕！
- 构图光影与画风：
  - 极富戏剧魅力的双重冷暖光影：屋内是充满熏香、热汤与针线温情的金黄暖光，屋外是照着委屈孙策的清冷月光。
  - 规格：横版 16:9 比例，日系经典战术卡牌RPG剧情CG插画风（赛璐珞上色带精良墨线，类似兰斯10经典幕间短剧插画），人物神态极其生动鲜活，温馨甜蜜中带着无厘头爆笑！
```
