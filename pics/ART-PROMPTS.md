# 出图提示词

> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。
> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。
> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，
> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。

## 下一批（交给 Gemini）

按顺序画；交付后重跑本脚本，这一条会自动消失。

1. `bh_lubu` — 太行山口·吕布（北线第四章首领）（战斗 CG）
2. `c5_dongzhuo` — 未央宫前·董卓（长安首领）（战斗 CG）
3. `c6_lijue` — 函谷关·李傕（南线第四章首领）（战斗 CG）
4. `c7_jiling` — 宛城·纪灵（南线第四章首领）（战斗 CG）
5. `jx_huangzu` — 淯水·黄祖（南线第五章首领）（战斗 CG）
6. `jx_caimao_a` — 水阁·独眼蔡瑁（南线第五章首领，恨海线）（战斗 CG）
7. `jx_caimao_b` — 水阁·蔡瑁（南线第五章首领，破局线）（战斗 CG）
8. `end_hushi` — 结局四·虎噬（象征画，南线终章，尚未实装）（剧情 CG）
9. `end_zhumie` — 结局五·烛灭（象征画，北线终章，尚未实装）（剧情 CG）
10. `end_juefa` — 结局七·绝罚（象征画）（剧情 CG）
11. `end_menhou` — 结局八·门后之诛（象征画，尚未实装）（剧情 CG）
12. `end_chibi` — 南线结局·赤壁（象征画，尚未实装）（剧情 CG）
13. `end_guandu` — 北线结局·官渡（象征画，尚未实装）（剧情 CG）
14. `end_tianming` — 第十二章·天命归一（真结局，象征画，尚未实装）（剧情 CG）
15. `end_locked` — 结局图鉴「未解锁」缩略图（16:9，暗色印章问号）（剧情 CG）
16. `zhangxun` — 张勋（南线第六章）（立绘）
17. `liuxun` — 刘勋（南线第六章）（立绘）
18. `zhengbao` — 郑宝（南线第六章）（立绘）
19. `luxun_young` — 少年陆逊（十四五岁的孩子，只画孩子该有的样子）（立绘）
20. `zangba` — 臧霸（北线第七章）（立绘）
21. `shenrong` — 审荣（北线第七章）（立绘）
22. `liuyao` — 刘繇（南线第七章）（立绘）
23. `yanbaihu` — 严白虎（南线第七章）（立绘）
24. `wanglang` — 王朗（南线第七章）（立绘）
25. `zhoutai` — 周泰（南线第七章）（立绘）
26. `jiangqin` — 蒋钦（南线第七章）（立绘）
27. `mateng` — 马腾（北线第八、九章）（立绘）
28. `hansui` — 韩遂（北线第八章）（立绘）
29. `pangde` — 庞德（北线第九章）（立绘）
30. `tadun` — 蹋顿（北线第九章）（立绘）
31. `gongsunkang` — 公孙康（北线第九章）（立绘）
32. `liuzhang` — 刘璋（南线第九章）（立绘）
33. `yanyan` — 严颜（南线第九章）（立绘）
34. `zhangren` — 张任（南线第九章）（立绘）
35. `fazheng` — 法正（南线第九章）（立绘）
36. `menghuo` — 孟获（南线第九章）（立绘）
37. `luxun` — 陆逊（成年，南线第九章）（立绘）
38. `yujin` — 于禁（北线第十章）（立绘）
39. `lidian` — 李典（北线第十章）（立绘）
40. `xiahouyuan` — 夏侯渊（北线第十章）（立绘）
41. `zhanghe` — 张郃（北线第十章）（立绘）
42. `zhanglu` — 张鲁（南线第十章）（立绘）
43. `zhangwei` — 张卫（南线第十章）（立绘）
44. `xiahoumao` — 夏侯楙（南线第十章）（立绘）
45. `c5_dongzhuo` — 未央宫前·董卓（首领）（战斗 CG）
46. `c4_lvbu` — 雪中宣平门·吕布（结局二前的最后一战）（战斗 CG）
47. `c7_jiling` — 宛城西门·纪灵（首领）（战斗 CG）
48. `c6_lijue` — 函谷关·李傕（首领）（战斗 CG）
49. `c4_gaoshun` — 蔡府后门·高顺（精英）（战斗 CG）
50. `c5_niufu` — 比武·牛辅（精英）（战斗 CG）
51. `c5_hall` — 喜堂·飞熊军（精英）（战斗 CG）
52. `jx_jinfan` — 汉水渡口·锦帆贼（战斗 CG）
53. `jx_zongzei` — 新野·宗贼（战斗 CG）
54. `jx_ganning` — 汉水·甘宁（事件战）（战斗 CG）
55. `e_shuijing` — 事件·水镜先生（剧情 CG）
56. `e_pangdegong` — 事件·岘山老农（剧情 CG）
57. `e_huangchengyan` — 事件·沔南名士（剧情 CG）
58. `e_ganning` — 事件·锦帆游侠（剧情 CG）
59. `c6_jiaxu` — 绑走贾诩（五花大绑躺在粮车上还在闻酒葫芦）（剧情 CG）
60. `c6_zhangxiu` — 渭水桥·张绣（战斗 CG）
61. `c6_zhangji` — 渭水营·张济（精英）（战斗 CG）
62. `c8_shuige` — 水阁·貂蝉代饮（结局三线的关键一幕）（剧情 CG）
63. `c8_grapes` — 水阁·貂蝉要舍身，被主角一把拽回怀里（破局线的关键一幕）（剧情 CG）
64. `c8_louchuan` — 月下楼船·十指相扣、糖炒栗子（剧情 CG）
65. `c8_zupu` — 破局线·蔡家族老划掉蔡瑁、刘表撇清（略搞笑）（剧情 CG）
66. `c8_xuexi` — 恨海线·城头雨里董白「你越来越像我爷爷了」（克制，不见血）（剧情 CG）
67. `c6_jiaxu_join` — 四周目·洛阳以礼相待贾诩（红烧肉、斟酒作揖）（剧情 CG）
68. `c8_liuxian` — 留仙裙·淯水边（剧情 CG）
69. `c8_caifuren` — 蔡夫人认同宗、送明珠（剧情 CG）
70. `c8_jiayan` — 宛城家宴（剧情 CG）
71. `c8_dress` — 盛装（吴夫人给貂蝉梳头）（剧情 CG）
72. `c8_xiangxiao` — 香消（克制）（剧情 CG）
73. `c8_henhai` — 恨海·汉江冷雨（克制）（剧情 CG）
74. `jx_huangzu` — 淯水·黄祖（首领）（战斗 CG）
75. `jx_caimao_a` — 水阁·独眼蔡瑁（结局三线首领）（战斗 CG）
76. `jx_caimao_b` — 水阁·蔡瑁（破局线首领）（战斗 CG）
77. `jx_shuijun` — 水寨·荆州水军（精英）（战斗 CG）
78. `jx_bubing` — 淯水北岸·荆州步卒（战斗 CG）
79. `jx_gongshou` — 芦苇荡·荆州弓手（战斗 CG）
80. `jx_nushou` — 水阁·蔡府连弩手（战斗 CG）

交图规则：

- 每张图都用下面对应小节的**完整提示词**；图上长相/器物必须和设定对得上（见 `CARD-DESIGN.md` 第 7 节）。
- 宝物：纯中式汉代古风器物，独立透明背景（纯白背景抠图，无圆盘边框，无西式奇幻符号），日系战术卡牌 RPG 赛璐珞道具插画风。
- 女性角色一律画成成年人；董白不写年龄、不画成萝莉。
- 卡牌立绘必须带背景：背景为符合人物身份与阵营的古风场景（军营、要塞、江岸、山林、宫室等，具自然景深与环境光影，不再使用纯白/摄影棚素底）。人物半身居中，面部在上方三分之一。
- 文件名 = key：宝物放 `pics/source/relics/<key>.png`（同时复制到 `godot/data/art/relics/<key>.png`），立绘放 `pics/source/generals/`（兵卡放 `soldiers/`）。
- 战斗 CG 放 `pics/source/battles/<key>.jpg`、在 `pics/art.json` 的 battles 登记；构图：敌人大、居中、在画面中上部。
- 宝箱图：PNG 透明底 512×512，直接放 `godot/data/art/ui/<key>.png`（开宝箱动画会自动用上）。
- 立绘在 `pics/art.json` 对应段登记；然后跑 `sanguo-art`，再跑 `python tools/art_prompts.py` 刷新本文件。
- **不要覆盖已经交付的图**；重画某张时旧图别留在 `pics/source/` 里（`backup_old/` 之类的文件夹不要提交）。
- 提交时按路径 `git add`，只提交自己的图和登记，别带上别人没提交的改动。

## 立绘（竖版 3:4）

### `dongfeng` ⬜ 缺

```
董奉（R 后勤，江东名医）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：气质温和的中年郎中，浅绿道袍，站在开花的杏树下，腰挂药葫芦
武器：仪态沉稳端庄
背景：与人物身份相符的三国古风场景，柔和自然光。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Dong Feng (董奉), the Jiangdong doctor of the apricot grove legend的竖版人物立绘。
外貌：Gentle, ageless-looking man in his 30s with a serene smile.
铠甲与服饰：Simple Taoist-style physician robes in light green, a straw hat on his back.
武器：Standing under a blossoming apricot tree, a medicine gourd at his hip.
背景：与人物身份相符的古风氛围场景，柔和自然光。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zhangzhao` ⬜ 缺

```
张昭（R 后勤，孙家大管家）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：一脸严肃的中年文官，深色官服，抱着一摞账册和毛笔，不赞成地看着你
武器：仪态沉稳端庄
背景：与人物身份相符的三国古风场景，柔和自然光。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zhang Zhao (张昭), the stern chief steward of the Sun household的竖版人物立绘。
外貌：Stern, upright man in his 30s with a severe frown and a well-kept beard.
铠甲与服饰：Dark formal official robes and cap.
武器：Holding a thick stack of ledgers and a writing brush, looking disapprovingly at the viewer.
背景：与人物身份相符的古风氛围场景，柔和自然光。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `qiaoguolao` ⬜ 缺

```
乔国老（R 后勤，二乔之父）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：圆滚滚的白须老头，锦袍，抱着一箱塞满绸缎的嫁妆，又得意又舍不得（搞笑）
武器：仪态沉稳端庄
背景：与人物身份相符的三国古风场景，柔和自然光。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Qiao Guolao (乔国老), the fussy old father of the Qiao sisters的竖版人物立绘。
外貌：Plump, cheerful old man in his 60s with a long white beard and rosy cheeks.
铠甲与服饰：Rich brocade robes of a retired gentleman.
武器：Hugging a dowry chest overflowing with silks, looking both proud and reluctant.
背景：与人物身份相符的古风氛围场景，柔和自然光。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zhangxun` ⬜ 缺

```
张勋（袁术的大将，南线第六章淝水楼船）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：四十岁上下，方脸浓眉，像个正经将军，却穿着袁术赏的花哨金边甲
武器：站在楼船船头，手持长戟
背景：淝水上的楼船和水寨。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zhang Xun (张勋), Yuan Shu's chief general, commanding tower ships on the Fei River的竖版人物立绘。
外貌：Square-faced, heavy-browed man around 40 who looks like a proper general.
铠甲与服饰：Gaudy gold-trimmed armor gifted by Yuan Shu.
武器：A long ji, standing at the prow of a tower ship.
背景：tower ships and a water fort on the Fei River。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `liuxun` ⬜ 缺

```
刘勋（袁术的庐江太守，搜刮庐江大族、要押二乔去寿春，南线第六章中段首领）的竖版人物立绘。
外貌：四十岁上下，白胖贪婪，眯缝眼，手指上戴满金戒指
铠甲与服饰：华丽的官袍外套一身不合身的铠甲
武器：一手拿着选秀的名册
背景：皖城城头。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Liu Xun (刘勋), Yuan Shu's greedy governor of Lujiang的竖版人物立绘。
外貌：Pale, plump, greedy man around 40 with narrow eyes and gold rings on every finger.
铠甲与服饰：Lavish official robes under ill-fitting armor.
武器：Holding a register of girls chosen for the 'imperial' harem.
背景：the walls of Wan city。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `luxun_young` ⬜ 缺

```
少年陆逊（十四五岁，陆家的孩子，南线第六章舒县露脸——和通用池成年版 `luxun` 是同一人年轻的时候，两个 key 分开画）的竖版人物立绘。
外貌：十四五岁的少年，清瘦，眼神沉静早熟；坐在焦黑的门槛上
铠甲与服饰：素色布衣，衣角有烧焦的痕迹
武器：仪态沉稳端庄
背景：舒城陆家被烧过的旧宅。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
young Lu Xun (陆逊), a quiet boy of about fourteen from the ruined Lu family of Shu — a child, not an adult; this key is for his younger appearance only, separate from the adult `luxun` card的竖版人物立绘。
外貌：A slender boy of about fourteen with calm, old-for-his-age eyes.
铠甲与服饰：Plain cloth robes with a scorched hem.
武器：Sitting quietly on a burnt doorstep, hands on his knees, no weapon.
背景：the half-burnt old Lu family mansion in Shu county。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zhengbao` ⬜ 缺

```
郑宝（巢湖水贼头子，收过湖钱，南线第六章）的竖版人物立绘。
外貌：四十岁上下，矮壮黝黑，金牙，满身江湖气
铠甲与服饰：赤膊披一件抢来的锦袍
武器：扛一柄分水刺
背景：巢湖口的水寨。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zheng Bao (郑宝), the gold-toothed bandit boss of Lake Chao who charges a toll to cross的竖版人物立绘。
外貌：Short, stocky, sun-darkened man around 40 with a gold tooth and a swaggering grin.
铠甲与服饰：Bare-chested under a stolen brocade robe.
武器：A water-splitting trident over his shoulder.
背景：a bandit water fort at the mouth of Lake Chao。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zangba` ⬜ 缺

```
臧霸（泰山豪帅，占山口收过路钱，北线第七章精英，心里惦记曹操许的徐州刺史）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：三十多岁，豪强气派，络腮胡，眼神精明里带着算计；泰山豪帅的皮甲外披旧锦袍
武器：手持大刀，脚踩山口的拒马
背景：泰山山道上的关卡。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zang Ba (臧霸), the bandit lord of Mount Tai who taxes the mountain passes的竖版人物立绘。
外貌：Burly man in his 30s with a full beard and shrewd, calculating eyes.
铠甲与服饰：Leather armor of a local strongman under a worn brocade robe.
武器：A heavy broadsword, one boot resting on a wooden barricade.
背景：a toll barrier on a Mount Tai mountain road。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `shenrong` ⬜ 缺

```
审荣（审配的侄子，守邺城，北线第七章中段首领）的竖版人物立绘。
外貌：二十多岁，紧张多疑的年轻守将，额头冒汗；不合身的冀州将铠
铠甲与服饰：精致汉代古风服饰与铠甲
武器：一手按剑一手扶城垛
背景：雷雨夜的邺城城头。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Shen Rong (审荣), the nervous young nephew left to hold Ye city的竖版人物立绘。
外貌：Anxious young officer in his 20s, sweat on his brow, suspicious eyes.
铠甲与服饰：Ji province officer's armor that fits a little too loosely.
武器：One hand on his sword hilt, the other gripping a battlement.
背景：the walls of Ye city in a thunderstorm at night。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `liuyao` ⬜ 缺

```
刘繇（扬州刺史，南线第七章，被孙策赶出江东）的竖版人物立绘。
外貌：四十多岁，文雅却优柔寡断的名门官员，愁眉
铠甲与服饰：刺史官袍、进贤冠
武器：手里捏着一卷名册
背景：牛渚江岸的营寨。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Liu Yao (刘繇), the indecisive Inspector of Yang province的竖版人物立绘。
外貌：A refined but hesitant official in his 40s with a worried frown.
铠甲与服饰：Inspector's official robes and a scholar's cap.
武器：Clutching a roster scroll, no weapon.
背景：a riverside camp at Niuzhu on the Yangtze。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `yanbaihu` ⬜ 缺

```
严白虎（吴郡的土豪，自称东吴德王，南线第七章中段首领）的竖版人物立绘。
外貌：四十岁上下，粗野横蛮的地头蛇，满脸横肉，一撮白发
铠甲与服饰：披一张白虎皮，皮甲
武器：扛一柄大斧
背景：吴郡山间的土寨。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Yan Baihu (严白虎), the swaggering local warlord of Wu commandery who calls himself king的竖版人物立绘。
外貌：Brutish man around 40 with a heavy face and a streak of white in his hair.
铠甲与服饰：A white tiger pelt over leather armor.
武器：A great axe over his shoulder.
背景：a hill fort in the Wu commandery hills。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `wanglang` ⬜ 缺

```
王朗（会稽太守，文官，南线第七章首领，打不过就跑，跑之前还想辩经）的竖版人物立绘。
外貌：五十岁上下，白须儒雅、口若悬河的老文官；一手捋须一手指点江山
铠甲与服饰：宽大的太守官袍
武器：仪态沉稳端庄
背景：会稽郡府门前。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Wang Lang (王朗), the eloquent scholar-governor of Kuaiji的竖版人物立绘。
外貌：Dignified scholar around 50 with a long white beard, mid-argument.
铠甲与服饰：Wide governor's robes and an official cap.
武器：Stroking his beard with one hand and pointing as if debating, no weapon.
背景：the gate of the Kuaiji prefectural office。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zhoutai` ⬜ 缺

```
周泰（九江水寇出身，归降孙策，近卫统领，南线第七章）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：赤膊披半身江东皮甲
武器：二十多岁，沉默寡言的壮汉，脸和手臂满是刀疤；手持大刀，护在身前
背景：江面上的水寇快船。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zhou Tai (周泰), the silent ex-river-pirate who became Sun Ce's bodyguard的竖版人物立绘。
外貌：Quiet, powerfully built man in his 20s covered in scars on face and arms.
铠甲与服饰：Half-worn Jiangdong leather armor over a bare scarred chest.
武器：A broad saber held guard-ready in front of him.
背景：pirate skiffs on the Yangtze。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `jiangqin` ⬜ 缺

```
蒋钦（九江水寇出身，和周泰一起归降孙策，南线第七章）的竖版人物立绘。
外貌：二十多岁，精悍机警，晒得黝黑
铠甲与服饰：短打水靠外套皮甲
武器：手持短戟，站在船头
背景：江面。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Jiang Qin (蒋钦), Zhou Tai's sharp-eyed partner from the river pirates的竖版人物立绘。
外貌：Lean, alert, sun-darkened man in his 20s.
铠甲与服饰：Short river-fighter's clothes under leather armor.
武器：A short halberd, standing on a boat's prow.
背景：the open Yangtze。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `mateng` ⬜ 缺

```
马腾（西凉军阀，马超之父，北线第八、九章，被吕布杀害）的竖版人物立绘。
外貌：五十岁上下，高大威严的西凉老将，花白长须、高鼻深目
铠甲与服饰：西凉铁甲外披旧战袍
武器：手按佩刀
背景：黄河边的西凉营帐。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Ma Teng (马腾), the old Xiliang warlord, father of Ma Chao的竖版人物立绘。
外貌：Tall, dignified veteran around 50 with a long grey beard, high nose and deep-set eyes.
铠甲与服饰：Xiliang iron armor under an old war robe.
武器：A hand on his sword hilt.
背景：Xiliang tents beside the Yellow River。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `hansui` ⬜ 缺

```
韩遂（西凉老狐狸，北线第八章）的竖版人物立绘。
外貌：五十多岁，干瘦精明，眯眼笑，胡子稀疏；手捻胡须
铠甲与服饰：西凉皮甲外罩毛皮斗篷
武器：仪态沉稳端庄
背景：西凉营地。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Han Sui (韩遂), the wily old fox of Xiliang的竖版人物立绘。
外貌：Lean, shrewd man in his 50s with narrowed smiling eyes and a thin beard.
铠甲与服饰：Xiliang leather armor under a fur cloak.
武器：Twirling his beard, a sheathed sword at his side.
背景：a Xiliang camp on the steppe。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `pangde` ⬜ 缺

```
庞德（西凉猛将，北线第九章入队）的竖版人物立绘。
外貌：三十多岁，黝黑刚毅，络腮胡，目光如铁
铠甲与服饰：西凉重甲、深色披风
武器：手持大刀，护在身前
背景：延津营寨的火光。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Pang De (庞德), the iron-willed Xiliang champion的竖版人物立绘。
外貌：Dark, rugged man in his 30s with a full beard and an unbending stare.
铠甲与服饰：Heavy Xiliang armor and a dark cape.
武器：A great saber held across his body.
背景：the burning camps at Yanjin。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `tadun` ⬜ 缺

```
蹋顿（乌桓单于，北线第九章白狼山首领）的竖版人物立绘。
外貌：四十岁上下，彪悍的草原首领，髡头（剃发留几绺）、高颧骨；皮毛大氅、金饰
铠甲与服饰：精致汉代古风服饰与铠甲
武器：手持弯刀，骑矮壮的草原马
背景：白狼山下的草原和乌桓骑兵。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Tadun (蹋顿), the Wuhuan chieftain beyond the Great Wall的竖版人物立绘。
外貌：Fierce steppe chieftain around 40 with a shaved head except a few locks, high cheekbones.
铠甲与服饰：A heavy fur cloak with gold ornaments.
武器：A curved saber, on a sturdy steppe horse.
背景：the grasslands below White Wolf Mountain with Wuhuan riders。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `gongsunkang` ⬜ 缺

```
公孙康（辽东太守，公孙度之子，北线第九章献上袁氏兄弟的人头）的竖版人物立绘。
外貌：三十岁上下，精明冷淡的边地军阀
铠甲与服饰：辽东式皮裘、官袍
武器：双手捧一只木匣
背景：襄平城门。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Gongsun Kang (公孙康), the cool, calculating lord of Liaodong的竖版人物立绘。
外貌：Shrewd, cold-eyed man around 30.
铠甲与服饰：Liaodong fur coat over official robes.
武器：Holding a closed wooden box in both hands, no weapon.
背景：the gate of Xiangping city in Liaodong。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `liuzhang` ⬜ 缺

```
刘璋（益州牧，暗弱，南线第九章送来勒索国书）的竖版人物立绘。
外貌：四十岁上下，白胖温吞，眉眼犹豫；手里捏着一封书信
铠甲与服饰：华丽的州牧官袍
武器：仪态沉稳端庄
背景：成都州牧府。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Liu Zhang (刘璋), the soft, indecisive governor of Yi province的竖版人物立绘。
外貌：Plump, mild man around 40 with hesitant eyes.
铠甲与服饰：Lavish governor's robes.
武器：Holding a sealed letter, no weapon.
背景：the governor's hall in Chengdu。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `yanyan` ⬜ 缺

```
严颜（巴郡老将，南线第九章江州中段首领，「只有断头将军」）的竖版人物立绘。
外貌：六十多岁，白发白须，骨头硬，昂着头
铠甲与服饰：川军旧铁甲、红色披风
武器：手持大刀
背景：江州城头。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Yan Yan (严颜), the stubborn old general of Ba commandery的竖版人物立绘。
外貌：Unbending veteran in his 60s with white hair and beard, head held high.
铠甲与服饰：Old Shu iron armor and a red cape.
武器：A great saber.
背景：the walls of Jiangzhou above the river。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zhangren` ⬜ 缺

```
张任（益州名将，守雒城、金雁桥，南线第九章首领）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：川军精铁甲、青色披风
武器：三十多岁，冷峻刚烈，薄唇剑眉；手持长枪
背景：雒城外的金雁桥。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zhang Ren (张任), Yi province's most stubborn defender的竖版人物立绘。
外貌：Stern, intense man in his 30s with thin lips and sharp brows.
铠甲与服饰：Fine Shu iron armor with a teal cape.
武器：A long spear.
背景：the Golden Goose Bridge outside Luo city。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `fazheng` ⬜ 缺

```
法正（蜀中谋士，献全川地图，南线第九章入队）的竖版人物立绘。
外貌：三十岁上下，瘦削精明，嘴角一丝冷笑，眼神锐利
铠甲与服饰：深色文士袍
武器：手持一卷地图
背景：蜀道上的雾。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Fa Zheng (法正), the sharp-tongued strategist of Shu的竖版人物立绘。
外貌：Lean, clever man around 30 with a faint cold smile and piercing eyes.
铠甲与服饰：Dark scholar's robes.
武器：A rolled map of Yi province in hand.
背景：a misty Shu mountain road。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `menghuo` ⬜ 缺

```
孟获（南中蛮王，七擒七纵，南线第九章首领）的竖版人物立绘。
外貌：四十岁上下，魁梧黝黑的南中蛮王，卷发、虎牙项链
铠甲与服饰：犀皮甲、兽骨饰；扛一柄大刀，身后藤甲兵
武器：仪态沉稳端庄
背景：南中密林和盘蛇谷。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Meng Huo (孟获), the proud king of the Nanzhong tribes的竖版人物立绘。
外貌：Huge, dark-skinned king around 40 with curly hair and a tiger-tooth necklace.
铠甲与服饰：Rhinoceros-hide armor with bone ornaments.
武器：A great saber over his shoulder, rattan-armored warriors behind him.
背景：the Nanzhong jungle and Coiled Snake Valley。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `luxun` ⬜ 缺

```
陆逊（成年，十八九岁，当年舒城的少年，南线第九章入队；和 `luxun_young` 是同一人）的竖版人物立绘。
外貌：十八九岁的青年，清秀儒雅，眼神沉静
铠甲与服饰：文士袍外罩轻甲
武器：手持羽扇或长剑
背景：汉水边的营寨。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Lu Xun (陆逊), the calm young strategist of the Lu family, now a young man of about nineteen的竖版人物立绘。
外貌：Refined young man of about nineteen with calm, steady eyes.
铠甲与服饰：Scholar's robes under light armor.
武器：A long sword at his side, a fan in hand.
背景：a river camp on the Han River。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `yujin` ⬜ 缺

```
于禁（曹操的稳健名将，守官渡，北线第十章精英）的竖版人物立绘。
外貌：四十岁上下，严肃刻板，一丝不苟
铠甲与服饰：整齐的曹军黑甲
武器：手持长刀，站在拒马后面
背景：官渡的深沟高垒。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Yu Jin (于禁), Cao Cao's strict, by-the-book general的竖版人物立绘。
外貌：Severe, meticulous man around 40.
铠甲与服饰：Immaculate black Cao army armor.
武器：A long saber, standing behind a row of chevaux-de-frise.
背景：the deep trenches and ramparts of Guandu。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `lidian` ⬜ 缺

```
李典（曹操的儒将，北线第十章官渡）的竖版人物立绘。
外貌：三十岁上下，文雅沉稳，像个读书人
铠甲与服饰：曹军轻甲外罩文士袍
武器：手持令旗
背景：官渡营寨的高台和重弩。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Li Dian (李典), Cao Cao's scholarly general的竖版人物立绘。
外貌：Calm, bookish man around 30.
铠甲与服饰：Light Cao army armor over a scholar's robe.
武器：A command flag in hand.
背景：a raised platform with heavy crossbows at Guandu。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `xiahouyuan` ⬜ 缺

```
夏侯渊（曹操的急行军名将，北线第十章白马坡中段首领）的竖版人物立绘。
外貌：四十岁上下，精悍迅捷，眼神如鹰
铠甲与服饰：曹军轻骑甲、深色披风
武器：在奔马上反身开弓
背景：白马坡的尘土。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Xiahou Yuan (夏侯渊), Cao Cao's lightning-fast cavalry commander的竖版人物立绘。
外貌：Lean, quick man around 40 with hawk-like eyes.
铠甲与服饰：Light cavalry armor and a dark cape.
武器：Twisting in the saddle to loose an arrow from a galloping horse.
背景：dust clouds over Baima slope。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zhanghe` ⬜ 缺

```
张郃（河北降将，北线第十章守虎牢）的竖版人物立绘。
外貌：三十多岁，英挺干练，短须
铠甲与服饰：曹军铁甲、深红披风
武器：手持长枪
背景：虎牢关城楼。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zhang He (张郃), the capable Hebei general now serving Cao Cao的竖版人物立绘。
外貌：Sharp, capable man in his 30s with a short beard.
铠甲与服饰：Cao army iron armor and a crimson cape.
武器：A long spear.
背景：the gate towers of Hulao Pass。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zhanglu` ⬜ 缺

```
张鲁（汉中五斗米道天师，南线第十章投降）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：四十多岁，清瘦温和，道冠道袍，长须
武器：手捧一只米斗
背景：汉中的义舍（施粥的棚子）。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zhang Lu (张鲁), the Celestial Master of the Five Pecks of Rice in Hanzhong的竖版人物立绘。
外貌：Gentle, lean man in his 40s with a long beard.
铠甲与服饰：Daoist cap and robes.
武器：Holding a wooden rice measure, no weapon.
背景：a free rice-kitchen shelter in Hanzhong。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `zhangwei` ⬜ 缺

```
张卫（张鲁的弟弟，守阳平关，南线第十章中段首领）的竖版人物立绘。
外貌：三十多岁，比哥哥凶狠，瞪眼
铠甲与服饰：汉中铁甲外披道袍
武器：手持长刀
背景：阳平关的关墙和秦岭绝壁。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Zhang Wei (张卫), Zhang Lu's hot-headed younger brother的竖版人物立绘。
外貌：Fierce-eyed man in his 30s, harsher than his brother.
铠甲与服饰：Hanzhong iron armor over a Daoist robe.
武器：A long saber.
背景：the walls of Yangping Pass under the Qinling cliffs。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

### `xiahoumao` ⬜ 缺

```
夏侯楙（曹操的女婿，守长安，南线第十章，一打就跑）的竖版人物立绘。
外貌：容貌端正，英气威严
铠甲与服饰：三十岁上下，白净富态，锦衣华服、神情慌张；不合身的金边甲
武器：手里抓着马缰准备跑
背景：长安城门。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
Xiahou Mao (夏侯楙), Cao Cao's pampered son-in-law left to hold Chang'an的竖版人物立绘。
外貌：Pale, well-fed man around 30 looking flustered.
铠甲与服饰：Fancy gold-trimmed armor that does not fit.
武器：Clutching a horse's reins, ready to flee.
背景：the gates of Chang'an。
构图：竖版 3:4 比例，半身像，人物居中，面部位于画面上方三分之一处。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，带氛围的环境光，景深柔和，背景有景致但服从于人物。
```
</details>

## 战斗 CG（横版 16:9，每场战斗一张）

### `bh_hj_duzhan`

```
横版战斗场景插画：北海城外的黄巾军阵后：几名手持环首刀的黄巾督战队官兵，黄巾裹头，满脸凶相，刀背抵着前面迟疑的饥民士兵向前推；背后是插满黄旗的营寨与浓烟。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_hj_qushuai`

```
横版战斗场景插画：青州乡野的田埂上：一名黄巾渠帅披着破旧的黄袍和铁肩甲，手持环刀怒吼，身后是挥舞锄头镰刀的黄巾饥民；远处是被烧毁的村庄与黑烟。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_jiang_trap`

```
横版战斗场景插画：太行山姜家寨外围的林间山道：几名山贼暗哨藏在岩石与树木之后，拉满的弓弦对准来路；脚下布满绊索、竹签与暗藏的机关木桩，气氛紧张。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_jiangqiao`

```
横版战斗场景插画：姜家寨寨门内：女首领姜巧（成年女性，干练的机关匠，头缠布巾，围着满是工具的皮围裙）手握扳机，身旁是几架上好弦的机关连弩与滑轮吊网；木制寨墙上挂满齿轮与绳索。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_jz_inf`

```
横版战斗场景插画：黄河渡口的河滩：一队冀州步卒举着方盾、持环首刀结成阵势压来，旗帜上写着冀州的「袁」字；身后是浑浊的黄河与停泊的渡船，天色阴沉。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_jz_scout`

```
横版战斗场景插画：黄河岸边的芦苇荡：几名冀州轻骑手持长矛策马冲出芦苇丛，马蹄溅起泥水，苇絮被风扬起；远处是灰蒙蒙的河面。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_jz_spear`

```
横版战斗场景插画：黄河岸边的开阔滩涂：一排冀州长枪兵端着丈二长枪列成密集枪阵，枪尖如林，齐声前压；阵后是冀州军旗和低垂的乌云。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_lubu`

```
横版战斗场景插画：太行山口的暴风雪中：暴怒的吕布（头戴三叉束发紫金冠，披锁子连环甲，红色战袍猎猎作响）骑着赤兔马，方天画戟高举，戟尖映着雪光；身后并州狼骑的剪影与翻卷的军旗。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_wolf2`

```
横版战斗场景插画：太行山口的雪地：一队并州精骑头戴狼首铁盔，披黑色重甲，骑着高头战马从雪雾中疾冲而来，马蹄扬起雪浪，长矛前指；远处隐约可见吕布的大旗。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_yanliang`

```
横版战斗场景插画：黄河渡口的战场：大将颜良（魁梧威猛，披重甲，手持一柄大刀）骑马立于阵前，身后是一排举着强弩的先登死士，弩箭对准前方；背后是奔流的黄河与插满袁字旗的营寨。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `bh_zhenghao`

```
横版战斗场景插画：郑家寨的校场：女首领郑好（成年女性，豪爽泼辣，红色束袖短打）手持两柄厚背砍刀，身后几名刀手摆开刀阵；背景是木制山寨的大门与挂满红色布幡的寨墙。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `c4_lijue_test`

```
横版战斗场景插画：洛阳官道上：李傕（西凉悍将，披重甲，满脸横肉，大笑着）率一队西凉兵拦住一支披红挂彩的迎亲车队，红绸飘飞，轿帘被长矛挑起；道路两旁是惊慌的百姓。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `hs_chunyuqiong`

```
横版战斗场景插画：太行山口的险关：冀州大将淳于琼（四十岁上下，面带傲气，披银色明光铠，手持长戟）立在关前，身后是一排排冀州军旗与举盾的士兵；山势陡峭，雪地泥泞。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `hs_jieqiao_scout`

```
横版战斗场景插画：界桥外围的原野：几名袁绍军游骑策马疾驰，手持长矛追砍四散逃命的公孙瓒散兵，尘土飞扬，折断的军旗与倒翻的辎重车散落一地；远处是界桥的轮廓。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `hs_jizhou_buzhu`

```
横版战斗场景插画：无极甄府大门外：烈焰冲天，冀州步卒举着方盾、手持环首刀潮水般压向崩塌的朱漆府门，身后是弩手列阵；木屑与火星四处飞溅，夜空被烧成橙红。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `hs_jizhou_nu`

```
横版战斗场景插画：太行秘道的狭窄峡谷：一排冀州强弩手半蹲在岩壁两侧，强弩上弦、箭簇齐指谷中；箭矢如蝗，岩壁上插满箭杆，夜色昏暗，火把照亮他们冷峻的脸。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `hs_jizhou_qiangbing`

```
横版战斗场景插画：太行秘道的狭窄山道：冀州大枪阵的长枪兵横向列成枪墙，枪尖如林封死去路；两侧是陡峭岩壁，火把摇曳，气氛压抑。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `hs_jizhou_qibing`

```
横版战斗场景插画：太行秘道的山道上：几名冀州轻骑在窄路上策马追击，手持长矛前指，披风与火把的光影在岩壁上晃动；扬起的碎石与尘雾。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `hs_quyi`

```
横版战斗场景插画：界桥战场：麹义（四十岁上下的凉州铁血老将，黑色铁叶甲外罩暗红旧战袍）率先登死士结成大盾阵，盾面满是箭痕，盾后强弩手露出弩机；身后是一面「袁」字大旗，前方是被冲垮的白马义从与折断的旗杆。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `huangjin_vanguard`

```
横版战斗场景插画：太行山道上：几名黄巾前锋头缠黄巾，持长矛与环首刀，沿着狭窄的山道摸黑前进，火把照亮他们疲惫而凶狠的面孔；路边是灌木与嶙峋的岩石。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `shanzei_scout`

```
横版战斗场景插画：真定城外的雪地：几名地痞流氓般的山贼斥候提着刀棍围住行人，缩着脖子，眼神贼溜溜；背景是被积雪覆盖的城墙与路旁枯树。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `th_patrol`

```
横版战斗场景插画：太行山道：几名太行山的巡山山贼身披兽皮与旧皮甲，手持砍刀与弓箭，在松林间的小径上拦路；晨雾弥漫，树影斑驳。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

### `c4_liumin`

```
横版战斗场景插画：洛阳废墟残垣断壁间：无数面黄肌瘦、眼眶深陷的绝望饥民流民手持锄头木棒，如狂潮般自瓦砾废墟中翻涌扑向运粮车队。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the ruins of Luoyang: a desperate mob of starving refugees with hoes and sticks surging over rubble toward the grain carts。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c5_qinbing`

```
横版战斗场景插画：荷花池夜色幽深处：吕布麾下的并州精锐亲兵手持长戟，手提灯笼在假山楼阁回廊间四处搜寻盘查。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a lotus garden at night: Lü Bu's Bingzhou guards with ji searching between the pavilions with lanterns。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c6_fubing`

```
横版战斗场景插画：黎明前清冷的长安长街：司徒王允府邸的私兵精甲列队成行，长戟如林、重弩上弦，森然封锁整条街市。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a long Chang'an street before dawn: Wang Yun's house troops in a line with ji and crossbows。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c6_xianzhen`

```
横版战斗场景插画：大雪漫天的长安宣平门广场：高顺陷阵营黑甲精锐死士在沉重高大的铁盾墙后森严列阵，黑矛林立，鸦雀无声。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the square before the Xuanping Gate in snow: black-armored Trap-Breaking Camp infantry behind tall shields。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c4_gaoshun`

```
横版战斗场景插画：黎明前火光冲天的长安名士宅邸后门处：面色冷峻黧黑的高顺如磐石般挺立在一人高的黑铁重盾阵后，长戟森冷如林，陷阵营全军肃然无声。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the back gate of a scholar's mansion in Chang'an before dawn, the house burning behind: the grim, dark-faced Gao Shun standing like a post behind a wall of tall black shields bristling with halberds, his Trap-Breaking Camp utterly silent。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c4_lvbu`

```
横版战斗场景插画：黎明时分大雪纷飞的长安宣平门外：吕布高踞在人立而起的赤兔马上，方天画戟高高举起，身后是高顺陷阵营肃杀沉寂的黑盾长戟之墙；马鞍后坐着一位裹在黑色斗篷里的成年绝色女子（貂蝉），眼神望向别处。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the great Xuanping Gate of Chang'an in falling snow at dawn: Lü Bu on the rearing Red Hare with his halberd raised high, Gao Shun's black shield wall behind him; a woman in a black cloak (Diaochan, adult) seated behind his saddle looking away。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c6_shaoka`

```
横版战斗场景插画：浓夜深沉的长安青明门前：火把通明成排，身着红黑战服的大汉禁卫军手持长戟横阻街道，领军校尉神情严厉展开一卷拘捕令公文。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the Qingming Gate of Chang'an at night: a row of torches, Han guards in red and black with halberds barring the road, their officer holding out a written order。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c6_fanchou`

```
横版战斗场景插画：长安以东险要的狭窄山道：粗犷高大的西凉猛将樊稠跨马挥舞沉重泼风大砍刀狂笑挑衅，山坡上西凉铁骑如决堤洪水般奔涌而下。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a narrow mountain road east of Chang'an: the loud, brash Xiliang general Fan Chou on horseback swinging a huge saber, laughing, Xiliang cavalry pouring down the slope。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c6_lijue`

```
横版战斗场景插画：残阳如血的函谷关隘前：精瘦阴残的西凉大将李傕骑在高头大马上，身后高擎巨大的「李」字战旗，长刀刃口血迹未干，后方漫山遍野的西凉铁骑填塞整条关道。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：Hangu Pass at sunset: the gaunt, cruel Li Jue on horseback before a huge 李 banner, his blade still stained, rows of Xiliang cavalry filling the pass behind him。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c7_qiaorui`

```
横版战斗场景插画：盛夏南阳袁军前哨大寨营门前：矮胖油滑的袁军大将桥蕤随手将啃光的鸡骨头扔在地上，狞笑着拔出肩扛的厚背宽刃大砍刀，大批袁兵正慌乱从帐篷中蜂拥而出。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a Yuan army camp gate in Nanyang in summer: the stout Qiao Rui tossing away a chicken bone and drawing his broad saber, Yuan soldiers scrambling out of their tents。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c7_leibo`

```
横版战斗场景插画：宛城城外崎岖的山路道中：下巴带疤的凶残骑将雷薄率领袁军轻骑兵发起狂暴冲锋，箭矢如飞蝗破空，泥浆飞溅。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a mountain road outside Wancheng: Lei Bo with a scar on his chin leading light cavalry in a charge, arrows in the air。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c7_chenlan`

```
横版战斗场景插画：南阳宛城高耸巍峨的城头：灰白胡须的袁军老将陈兰伫立在箭楼之上面色阴沉长枪下指，女墙垛口后弓弩手密集引弓，城头猎猎翻卷着「袁」字大纛。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the walls of Wancheng in Nanyang: the grey-bearded general Chen Lan on the gate tower pointing a long spear down, archers along the battlements, the 袁 banner above。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c7_jiling`

```
横版战斗场景插画：黎明时分黑烟滚滚的宛城西门处：袁术第一大将纪灵身披金甲、双手倒提三尖两刃神锋刀，单人独骑傲然堵住城门断后，身后袁术的奢华金顶车队正狼狈出城逃窜。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the west gate of Wancheng at dawn, smoke rising in the city behind: Ji Ling alone on horseback in gilded armor with his three-pointed double-edged blade, holding the gate while Yuan Shu's carriages flee behind him。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c6_zhangxiu`

```
横版战斗场景插画：渭水桥·张绣（四周目第四章）：黎明渭水石桥，张绣单枪匹马抖出枪花，身后「张」字旗；远处骡子上的贾诩闻酒葫芦。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a stone bridge over the Wei river at dawn: the cocky young Zhang Xiu alone on the bridge spinning his long spear into a blur of spear-tip flowers, Xiliang cavalry under a 张 banner behind; far back a thin man on a mule sniffing a wine gourd。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c6_zhangji`

```
横版战斗场景插画：渭水营·张济（四周目第四章，精英）：渭水边西凉营门，张济拄枪而立，鼓声大作；营门边粮车上坐着叹气的贾诩。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a Xiliang camp gate on the Wei river bank: the steady general Zhang Ji on foot with his spear planted beside him, war drums behind, soldiers pouring out; a thin man sitting on a grain cart by the gate, sighing。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_jinfan`

```
横版战斗场景插画：汉水渡口·锦帆贼：汉水渡口，锦帆快船堵住渡口，腰挂铜铃的江贼拿短刀挠钩跳上栈桥。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a ferry landing on the Han river: brocade-sailed fast boats blocking the crossing, river pirates with bells at their waists leaping onto the jetty with short blades and grappling ropes。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_zongzei`

```
横版战斗场景插画：新野·宗贼：新野城外的坞堡，宗贼和庄丁举着铡刀火把从夯土寨门冲出，寨主站在墙头。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a fortified clan village (wubao) outside Xinye: clan bandits and armed farmhands pouring out of the rammed-earth gate with cleavers and torches, their chief on the wall。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_ganning`

```
横版战斗场景插画：汉水·甘宁（事件战）：正午汉江，年轻的甘宁站在锦帆快船船头拉满大弓，腰挂铜铃，手下在后面起哄。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the Han river at noon: the young, cocky Gan Ning standing on the prow of a brocade-sailed boat drawing a great bow, bronze bells at his waist, his pirates cheering behind him。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_bubing`

```
横版战斗场景插画：淯水北岸·荆州步卒：秋天淯水北岸，刚渡河的荆州步卒列阵，圆盾画「刘」字，枪林如苇。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the north bank of the Yu river in autumn: a line of Jingzhou infantry with round shields painted 刘 and a forest of spears, having just waded across, reeds behind them。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_gongshou`

```
横版战斗场景插画：芦苇荡·荆州弓手：淯水芦苇荡，弓手藏在苇丛里隔水放箭。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a reed marsh along the Yu river: Jingzhou archers half-hidden in tall reeds loosing a volley across the water。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_huangzu`

```
横版战斗场景插画：淯水·黄祖（首领）：淯水南岸「黄」字大旗下，干瘦的老将黄祖举鬼头刀，身后荆州兵和江船。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the south bank of the Yu river under a big 黄 banner: the gaunt grey veteran Huang Zu on horseback raising his ghost-head broadsword, Jingzhou troops and river boats behind him, arrows in the air。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_shuijun`

```
横版战斗场景插画：水寨·荆州水军（精英）：汉江水寨，赤膊的水军从战船跳上栈桥，后面是巨大的楼船。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a Jingzhou river fortress on the Han river: bare-chested Jingzhou marines leaping from a line of war boats onto the jetty with pikes and rattan shields, a huge tiered flagship behind。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_nushou`

```
横版战斗场景插画：水阁·蔡府连弩手：起火冒烟的水阁里，撕破的帘子后连弩手朝浓烟乱射，翻倒的铜炉溅出炭火。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：inside a burning lakeside pavilion full of smoke: Cai family crossbowmen behind torn silk curtains shooting blindly into the haze, an overturned bronze brazier spilling embers。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_caimao_a`

```
横版战斗场景插画：水阁·独眼蔡瑁（结局三线首领）：烧了一半的水阁，蔡瑁一手捂着流血的右眼一手挥剑，死士环绕，火光浓烟。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a half-burnt banquet pavilion on a rock above the Han river: the burly Cai Mao clutching his bleeding right eye with one hand and swinging a long sword with the other, death-sworn guards around him, flames and smoke。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `jx_caimao_b`

```
横版战斗场景插画：水阁·蔡瑁（破局线首领）：月下水阁，案几翻倒，蔡瑁被逼到栏杆边拔剑，帘后的连弩全对准了他。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a moonlit banquet pavilion on a rock above the Han river, overturned tables: the burly Cai Mao in brocade over gilded armor cornered at the railing with his sword drawn, his last guards around him, crossbows now aimed at him from the curtains。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c5_fanchou`

```
横版战斗场景插画：奢华夜宴的中庭比武校场：西凉猛将樊稠呼呼抡动沉重大刀，宴席四周划拳狂饮的西凉将领们拍桌大声起哄喝彩。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a courtyard duel ring at a feast: Fan Chou swinging a huge saber, laughing Xiliang officers cheering from the tables。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c5_zhangji`

```
横版战斗场景插画：烛光通明的宴厅武斗场：沉稳严肃的西凉校尉张济长枪平端守势严密，长枪寒芒在红灯笼掩映下冷光凛然。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a courtyard duel ring at a feast: the steady Zhang Ji with his spear levelled, lantern light。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c5_niufu`

```
横版战斗场景插画：喜庆夜宴的比武擂台：董卓女婿牛辅面目狰狞挥舞沉重腰刀狂暴劈砍，董白在宴席旁猛然起立娇声娇喝，高座上的董卓眯着小眼阴鸷审视。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a courtyard duel ring at a feast: Niu Fu charging with a heavy saber, Dong Bai standing up at the table shouting, Dong Zhuo watching with narrowed eyes。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c5_huzhen`

```
横版战斗场景插画：深夜幽暗的相国府内门重地：带疤冷面将领胡轸横握厚背大刀死死挡住通道，身后两扇沉重如山的包铁巨门正缓缓合拢。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the chancellor's inner gate at night: Hu Zhen barring the way with a broad saber as the great doors swing shut behind him。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c4_guosi`

```
横版战斗场景插画：饱经劫掠焚毁的破败村道：西凉骑将郭汜高踞战马上指挥士卒哄抢劫掠老百姓最后的余粮粮车，推倒哭嚎的老农，董白手持双铜锤怒容满面一锤砸碎车轮。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a looted village road: Guo Si on horseback over captured grain carts, soldiers loading the villagers' last sacks, an old man knocked down, Dong Bai smashing a cart wheel with her twin hammers。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c5_hall`

```
横版战斗场景插画：红绸灯笼高挂的喜堂陷阱：喜宴大门轰然紧闭，黑甲重铠的西凉飞熊军凶卒从大红幕帘后蜂拥杀出，杀气腾腾。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：a wedding hall turned trap: red lanterns and silk, the doors slammed shut, black-armored Flying Bear cavalry pouring in from behind the curtains。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

### `c5_dongzhuo`

```
横版战斗场景插画：深夜相国府巍峨的白玉宫阶前：体格如黑熊般极其庞大凶悍的董卓按剑狞笑，身后黑压压挤满全副武装的飞熊军亲兵，婚宴的大红灯笼在夜风中剧烈摇曳。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版战斗场景插画：the steps before the chancellor's mansion at night: the enormous Dong Zhuo with a drawn sword among his elite black-armored guards, wedding lanterns burning behind him。
构图：横版 16:9，1920x1080，戏剧性低机位；敌人大而居中，位于画面中上部（头 / 脸距顶部约 30%–45%）。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，戏剧化战斗光影，如《兰斯10》的战斗 CG；不要文字、不要 UI。
```
</details>

## 剧情插图 CG（横版 16:9）

### `c4_escape`

```
横版剧情事件插画：太行山道上：郑好的刀手结成刀阵，姜巧的机关弩与绊索布满山道，把陷阵营的黑甲重盾兵死死拖住；主角在前方挥手招呼队伍向东撤退，山口飘着雪与烟尘。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `c4_million_hj`

```
16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。从高处俯瞰，北海城外的原野上，连绵不绝、一眼望不到头的黄巾饥民营帐，犹如黄色的汪洋。
```

### `c4_taishici_break`

```
16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。乱军之中，年轻骁将太史慈单骑突入黑压压的黄巾阵中，双戟如风，将狂热的信徒硬生生撕开一道口子，背影孤绝勇猛。
```

### `c4_porridge`

```
16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。北海城外的雪地里，架着几十口热气腾腾的大铁锅，原本凶神恶煞的黄巾军扔下了武器，捧着粗糙的陶碗喝着热粥，有人甚至激动得落泪。
```

### `c4_kongrong`

```
横版剧情事件插画：北海郡府正堂：孔融（五十岁上下，清瘦儒雅，捋着胡须，一身官服）把一方沉重的北海相印双手推向主角，案上放着几个梨；窗外是刚解围的北海城，阳光明亮。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `c4_yanliang`

```
16:9 横版故事剧情事件插画，视觉小说剧情 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，华丽沉稳色彩。黄河渡口的芦苇荡边，一员魁梧骁将（颜良）提着大刀列阵，身后是密密麻麻举着强弩的先登死士，压迫感十足。
```

### `end_hushi`

```
横版剧情事件插画：象征性结局卡插画（结局四·虎噬，南线）：洛水边雨夜的军营辕门，辕门的木门半敞着，门前泥水里横着一杆折断的方天画戟，旁边落着一副被扯断的赤兔金鞍缰辔和一只沾泥的虎头铜护腕；门外远处一匹赤色战马的剪影立在雨里，回头望着门内；冷雨、湿泥、昏黄残灯，色调萧索，不见人物，不见血。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an ending card illustration, quiet and symbolic: a half-open camp gate on a rainy night by the Luo river, a broken sky-piercer halberd in the mud, a torn red-horse saddle set and a tiger-head bracer; no people, no blood。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `end_zhumie`

```
横版剧情事件插画：象征性结局卡插画（结局五·烛灭，北线）：夜色中的大帐，案几上一支白烛刚刚燃尽，只剩一缕青烟，烛台旁倒着一只青铜酒爵，酒渍洇开；案上并排放着一方帅印和一柄白羽扇，羽扇的几根羽毛被酒水浸湿；帐外隐约一串白色灵幡在风里飘动；色调冷青灰，克制哀婉，不见人物，不见血。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an ending card illustration, quiet and symbolic: a burned-out white candle, a tipped bronze wine cup, a commander's seal and a white feather fan on a tent table; no people, no blood。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `end_juefa`

```
横版剧情事件插画：象征性结局卡插画（结局七·绝罚，北线）：大雪中的太行山口，两座山寨的木栅栏门被拦腰撞断，两面山寨旗子被撕裂后胡乱缠在一起，倒伏在雪地里；寨门正前方的雪里插着一杆巨大的方天画戟，戟尖上系着一条褪色的红缨；远处山口被大雪遮得模糊；色调冷白灰蓝，凛冽肃杀，不见人物，不见血。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an ending card illustration, quiet and symbolic: two broken mountain stockade gates in snow with torn banners tangled together, a huge halberd planted in front; no people, no blood。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `end_menhou`

```
横版剧情事件插画：象征性结局卡插画（结局八·门后之诛，北线）：夜色中徐州官府的朱红大门紧闭，门缝里漏出一线温暖的灯火和模糊的丝竹声；门前台阶上散落着一排被丢弃的黑色军旗和几支折断的军法令箭，一副铁甲歪靠在门柱边；色调沉暗，红与黑为主，克制压抑，不见人物，不见血。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an ending card illustration, quiet and symbolic: a closed vermilion government gate at night with warm light through the crack, discarded black banners and broken tally arrows; no people, no blood。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `end_chibi`

```
横版剧情事件插画：象征性结局卡插画（南线结局·赤壁）：夜色中长江江面，一排连环战船烧成冲天火龙，把江水映得通红；火光边缘，一艘小船载着白色灵柩缓缓顺流向南，船头挂着一盏白灯笼，船身插着一杆白色招魂幡；对岸山峦剪影；壮烈又哀伤，不见人物，不见血。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an ending card illustration, quiet and symbolic: a line of burning chained warships on the Yangtze at night, a small boat with a white coffin drifting south; no people, no blood。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `end_guandu`

```
横版剧情事件插画：象征性结局卡插画（北线结局·官渡）：黎明前雾气弥漫的官渡河岸荒野，一杆方天画戟斜插在泥地里，戟尖上挂着一条褪色的红巾；旁边落着半截宽刃古锭刀，刀身映着微弱的晨光；远处是宽阔的大河与几缕营火的炊烟；色调冷蓝灰，肃穆苍凉，不见人物，不见血。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an ending card illustration, quiet and symbolic: a halberd planted in the mud of the Guandu riverbank at dawn mist, a faded red scarf on its tip, half a broad saber beside it; no people, no blood。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `end_tianming`

```
横版剧情事件插画：象征性结局卡插画（第十二章·天命归一，真结局）：朝阳初升的洛阳高台上，一把宽刃古锭刀和一杆白蜡杆长枪背靠背交叉插在同一块青石台基上，刀柄红巾与枪缨红结在风中缠在一起；台下远景是铺展开的中原山河与洛阳城；南北两面旗帜（红底「孙」字旗与白底旗）在同一根旗杆上并排飘扬；金色晨光，壮阔而平静，不见人物。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an ending card illustration, quiet and symbolic: a broad saber and a white-wax spear crossed back to back on one stone terrace at sunrise, the south and north banners flying side by side; no people。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `end_locked`

```
横版剧情事件插画：结局图鉴「未解锁」缩略图（16:9，会被缩小到 200x112 使用，几乎不含细节）：深色宣纸质感的底，中央一枚淡淡的朱砂圆形印章，印章里是一个大大的「？」字的剪影，四周有极淡的云纹；整体偏暗、低对比，像一张被封住的卷轴；不要具体场景，不要人物，不要文字（除印章里的问号）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a dark ink-paper thumbnail with a faint cinnabar seal containing a large question mark, almost no detail。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c5_yuexia`

```
横版剧情事件插画：司徒府后园月色，圆形月亮门：成年绝色貂蝉刚在主角半步之外止步，静默之舞刚歇，水袖仍在夜风中飘拂，台阶上倒着一只空酒杯；她的笑容撩人又难以捉摸；银蓝色的凄美月光。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a moonlit garden behind the Minister's mansion, a round moon gate: Diaochan (adult, of great beauty) finishing a silent dance half a step from the hero, long sleeves still drifting in the night wind, an empty wine cup on the stone steps; her smile teasing and unreadable; silver-blue moonlight。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c4_mangshan`

```
横版剧情事件插画：洛阳城北邙山黎明，脚下雾气弥漫：成年董白（银白高马尾、紫色毛边骑马短皮甲）骑在栗色马上，飞快亲了主角一下后策马狂奔下山，耳根通红回头望；主角骑在马上面带惊愕地轻摸脸颊；晨曦中远方灰蒙蒙的洛阳城。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：dawn on Mount Mang north of Luoyang, mist below: Dong Bai (adult, silver ponytail, purple fur-trimmed riding armor) on a chestnut horse glancing back with red ears after a quick kiss, galloping downhill; the hero on his horse behind her touching his cheek, stunned; the grey city far below in the sunrise。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c5_chuxi`

```
横版剧情事件插画：除夕夜长安太师府最高处的殿顶屋脊上：成年董白靠在主角肩头沉沉熟睡，手里还抓着半块烤焦的胡饼，主角僵直端坐不敢低头；下方长安城万家灯火、爆竹篝火冲天，屋瓦上覆盖着皑皑白雪。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：New Year's Eve on the highest roof of the chancellor's mansion in Chang'an: Dong Bai (adult) asleep on the hero's shoulder with half a burnt flatbread in her hand, the hero sitting still and not daring to look down; below, the city glowing with bonfires of crackling bamboo, snow on the tiles。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c4_xizi`

```
横版剧情事件插画：深夜小军帐内的柔和灯火：一袭白衣的成年蔡文姬俯身握着主角的手指导执笔，两人的手叠在一起，共同俯在写着歪歪扭扭字迹的宣纸上；暖黄色的微光，温柔腼腆。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：lamplight inside a small army tent at night: Cai Wenji (adult, in white) guiding the hero's hand over a brush, her hand over his, both leaning over a sheet of paper with wobbly characters; soft warm glow, tender and shy。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c5_snow`

```
横版剧情事件插画：幽静名士宅邸雪夜后廊：一袭白衣的成年蔡文姬将古琴横在膝上弹奏，雪花落在琴弦上；主角坐在一旁，身上穿着文姬刚替他试穿裁定好的大红吉服；灯笼光晕，安静而苦乐交织。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a snowy back veranda of a scholar's house at night: Cai Wenji (adult, in white) playing a guqin on her knees with snow settling on the strings, the hero sitting beside her in a red wedding robe she has just fitted on him; lantern glow, quiet and bittersweet。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c7_stars`

```
横版剧情事件插画：夏夜军营上方草木葱郁的山丘，满天低垂璀璨的繁星：一袭白衣的成年蔡文姬在膝头抚琴，主角仰卧在草丛中静静聆听。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a grassy hilltop above an army camp on a summer night under a sky full of low stars: Cai Wenji (adult, in white) playing a guqin across her knees, the short-haired hero lying back in the grass listening。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c4_zhujun`

```
横版剧情事件插画：洛阳废墟中的孙坚军营：老宿将朱儁（花白长须、腰杆笔直、豪爽大笑）亲热用力拍着魁梧孙坚的肩膀，孙坚难得一见地恭敬拱手行礼；身后少年孙策满脸憋笑憋得通红。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：Sun Jian's camp in the ruins of Luoyang: the veteran general Zhu Jun (grey-bearded, straight-backed, hearty laugh) slapping the huge Sun Jian on the shoulder, Sun Jian bowing formally for once; Sun Ce behind them red-faced trying not to laugh。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c6_yizu`

```
横版剧情事件插画：董卓死后次日长安宫廷汉白玉台阶上：成年董白麻木茫然跪倒在冰冷石阶上，主角横刀半出鞘护在她身前，白发苍苍的老将皇甫嵩按剑走到主角身侧；高高宫阶上方，年幼的汉献帝小手死死抓着殿柱。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the palace steps of Chang'an the day after Dong Zhuo's death: Dong Bai (adult) kneeling numbly on the stone, the short-haired hero standing in front of her with his blade half drawn, the white-haired Huangfu Song stepping to his side; high above, the small boy emperor clutching a pillar。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c6_warn`

```
横版剧情事件插画：长安深夜灯影轩窗：身裹黑色斗篷的成年貂蝉面色苍白却带着浅笑，就着摇曳烛光自窗外探身向主角低语预警；邻近窗户前，成年董白正气呼呼地哐当一声合上木窗板。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：night at a window in Chang'an: Diaochan (adult) in a black cloak, pale but smiling, leaning in at the hero's window by candlelight; in the neighbouring window Dong Bai slamming her shutters。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c4_siege`

```
横版剧情事件插画：黎明前火把通明的长安蔡府门前：老儒蔡邕泰然自若、毫无反抗地被甲士押走，驻足回头；白衣蔡文姬含泪伸手欲追，被主角紧紧拉住。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：before dawn, torches around a scholar's house in Chang'an: the elderly Cai Yong being led away without resisting, looking back; Cai Wenji (adult, in white) reaching after him, held back by the short-haired hero。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c4_dongjia`

```
横版剧情事件插画：黎明荒野废弃的山神破庙：残破庙门被一脚踹开，成年董白手提双铜锤英姿飒爽立在门口，身后是一众白发西凉老兵的剪影；主角从稻草堆里惊讶抬头。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a ruined roadside shrine at dawn: the door kicked open, Dong Bai (adult) standing in the doorway with her twin hammers, grey-haired veterans only as silhouettes behind her; the hero looking up from the straw。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c7_feng`

```
横版剧情事件插画：深夜灯火通明的行军大帐：绝美的冯夫人（成年）笑盈盈为主角斟酒，纤纤玉指若有若无搭在主角手腕上；帐帘处，成年董白重重将铜锤砸在地上怒目而视，一旁白衣蔡文姬抚琴绷断了琴弦，两人同时怒瞪。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a lamplit army tent at night: the beautiful Lady Feng (adult) pouring wine for the hero and resting her fingertips on his wrist; at the tent flap Dong Bai (adult) slamming a hammer down and Cai Wenji (adult, in white) with a snapped zither string, both glaring。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c6_jiaxu`

```
横版剧情事件插画：绑走贾诩（四周目第四章）：清瘦的贾诩被五花大绑，舒舒服服地躺在粮车的麻袋堆里，还在闻酒葫芦；刚绑完他的孙策扛着枪攥着绳头，主角打量他，周瑜皱眉翻账本（搞笑）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an abandoned Xiliang camp on the Wei river after a battle: the thin, sleepy-eyed strategist Jia Xu (mid-40s, loose faded officer's robe, gourd flask at his belt) tied up with rope and lounging comfortably on sacks in a grain cart, still sniffing a wine gourd; young Sun Ce, who just tied him, holding the rope end with a spear on his shoulder; the short-haired hero studying him; Zhou Yu frowning over his ledger; comic。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_xuexi`

```
横版剧情事件插画：恨海线·血洗：清晨冷雨中的襄阳城头，城下一片死寂、家家闭门；主角穿着残破银甲，站得僵直、眼神空洞；董白（成年）站在他面前，浑身发抖却一步不退；身后孙策脸色发白（克制，不见血、不画尸体）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the wall of Xiangyang in grey rain at dawn, the city below silent with gates shut: the short-haired hero standing stiff and blank-eyed in battered silver armor; Dong Bai (adult) standing before him, trembling but not stepping back, saying something bitter; behind them young Sun Ce pale and afraid; restrained and bleak, no gore, no bodies。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c8_zupu`

```
横版剧情事件插画：破局线·族谱：州牧府台阶前，一排白胡子的蔡家族老跪着，为首的提笔在摊开的族谱上划掉一个名字；刘表官帽歪着一路小跑过来冒汗；周瑜捧着献兵献钱的长单子两眼放光；主角冷眼旁观（略搞笑）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the steps of the Xiangyang governor's mansion in the morning: a row of white-bearded Cai clan elders kneeling, the eldest striking a name out of an open clan genealogy with a brush; the pale, long-bearded scholar Liu Biao hurrying up with his official cap askew, sweating; Zhou Yu reading a long list of offered troops and money with shining eyes; the short-haired hero looking on, unimpressed; a little comic。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c6_jiaxu_join`

```
横版剧情事件插画：四周目·贾诩入伙：洛阳一间屋里，贾诩面前摆着第一碗红烧肉，正闻主角刚恭敬斟上的酒；吴夫人在添菜；孙策盯着红烧肉不敢伸手（温馨搞笑）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an evening in a Luoyang house: the thin, sleepy-eyed strategist Jia Xu (mid-40s, loose faded robe, gourd flask at his belt) at a table with the first bowl of red-braised pork, sniffing a cup of wine the short-haired hero has just poured him with a respectful bow; Lady Wu (adult) setting down more dishes; young Sun Ce staring at the pork, not daring to reach; warm and comic。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_jiayan`

```
横版剧情事件插画：宛城家宴：秋夜院子里，吴夫人给主角盛鸡汤、顺手摸他的寸头，孙策扒着锅沿抢肉。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a family supper in the courtyard of the Wancheng governor's house on an autumn evening: Lady Wu (adult) handing the short-haired hero a big bowl of chicken soup and ruffling his cropped hair; Sun Ce hanging over the edge of the pot trying to snatch meat; warm lantern light。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_liuxian`

```
横版剧情事件插画：留仙裙：夕阳淯水边，穿浅碧留仙裙的貂蝉抱膝坐着捂嘴笑，河里孙策抓鱼滑倒，周瑜坐在石头上记账。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the bank of the Yu river at sunset: Diaochan (adult, of great beauty) in a light pale-jade southern 'liuxian' skirt sitting hugging her knees on the grass, laughing with her hand over her mouth; in the shallows Sun Ce slipping while grabbing at a fish; Zhou Yu on a rock writing in his ledger。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_caifuren`

```
横版剧情事件插画：认同宗：襄阳接风宴，蔡夫人（紫衣凤钗）拉着蔡文姬的手翻族谱，貂蝉笑着收下一匣明珠，后面蔡邕捋须一脸怀疑。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a lavish welcome banquet in Xiangyang: Lady Cai (adult, purple gold-embroidered silks, phoenix hairpin) holding Cai Wenji's (adult, in white) hands over an open clan genealogy book, all warm smiles; beside them Diaochan (adult) accepting a box of pearls with an equally sweet smile; the elderly scholar Cai Yong stroking his beard sceptically in the background。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_shuige`

```
横版剧情事件插画：水阁·代饮（结局三线）：千斤闸落下、帘后连弩，貂蝉在蔡瑁面前举金兽爵一饮而尽，另一只手已摸向发簪；主角半起身拔刀大喊（紧张，不见血）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a lavish pavilion over the Han river, the only door sealed by a fallen iron portcullis, crossbowmen behind the curtains: Diaochan (adult) in a pale-jade skirt draining a gold beast-shaped wine cup before the burly Cai Mao, her other hand already reaching for the hairpin in her hair; the short-haired hero half-rising with his blade half drawn, shouting; tense, no gore。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_xiangxiao`

```
横版剧情事件插画：香消：黎明时烧塌半边的水阁，主角跪抱貂蝉，她脸色苍白，微笑着摸他的寸头（克制，不见血）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the smoking ruin of a pavilion on a rock above the Han river at dawn: the short-haired hero kneeling, holding Diaochan (adult, pale, in a scorched pale-jade skirt) in his arms; she smiles faintly and touches his cropped hair; restrained and elegiac, no gore。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_henhai`

```
横版剧情事件插画：恨海：冷雨夜的汉江边，主角独自蹲着洗一条浅碧留仙裙，手里攥着半截断簪；身后雨里一个披麻戴孝的年轻人走近（克制，不见血）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a cold rainy night on the bank of the Han river: the short-haired hero alone, crouching at the water's edge washing a pale-jade woman's skirt, holding half of a broken hairpin; behind him in the rain a young man in white mourning clothes stepping closer; bleak, restrained, no gore。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_dress`

```
横版剧情事件插画：盛装（破局线）：驿馆里貂蝉在铜镜前穿最美的水纹留仙裙，吴夫人给她插簪，主角蹲在一旁替她把头发别到耳后。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a bedroom in the Xiangyang guesthouse in the afternoon: Diaochan (adult) at a bronze mirror in her most beautiful pale-jade skirt embroidered with water patterns; Lady Wu (adult) pinning her hair; the short-haired hero crouching beside her tucking a strand of hair behind her ear; gentle and warm。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_grapes`

```
横版剧情事件插画：拽回怀里（破局线）：水阁宴上貂蝉已经起身走向蔡瑁、一只手摸向发簪，要替主角喝毒酒；主角一把搂住她的腰拽回怀里，另一只手把金兽爵推到桌子另一头、顺手往她手里塞了只橘子；她惊讶地抬头看他，对面蔡瑁脸都绿了（紧张又温柔）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a lamplit banquet pavilion over the Han river: Diaochan (adult, pale-jade skirt) had risen and started toward the burly Cai Mao, one hand already at the hairpin in her hair, ready to drink the poison for the hero — and the short-haired hero has caught her by the waist and pulled her back into his arms, his other hand sweeping a gold beast-shaped wine cup away across the table and pressing a mandarin orange into her hand; she looks up at him, startled; across the table Cai Mao going green in the face; tense and tender。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c8_louchuan`

```
横版剧情事件插画：月下楼船：汉江满月、两岸渔火，楼船船头貂蝉轻轻靠在主角肩上，两人十指相扣；她另一只手捧着一小包热乎乎的糖炒栗子，剥了一半；留仙裙被江风吹起（温柔、浪漫、安静）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the bow of a great tiered warship on the moonlit Han river, fishing lights receding along both banks: Diaochan (adult) in a pale-jade skirt fluttering in the wind leaning lightly on the short-haired hero's shoulder, their fingers interlaced; in her other hand a small paper packet of hot roasted chestnuts, one half-peeled; a huge full moon over the river, silver ripples; tender, romantic, quiet。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c7_flee`

```
横版剧情事件插画：宛城东门尘土漫天：冯夫人（成年）掀起疾驰马车的车帘，车队跟在几辆载满财物的辎重车后匆匆逃离，冯夫人回头露出一抹意味深长的浅笑；主角在攻下的宛城城头「孙」字大旗下凝望。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the east gate of Wancheng in a cloud of dust: Lady Feng (adult) lifting the curtain of her palanquin as it hurries away behind a few loaded carts and glancing back with a faint smile; the hero watching from the captured wall under a 孙 banner。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c4_tonggui`

```
横版剧情事件插画：结局二·同归：雪中黎明的长安城门，短发残破银甲的主角握着孙坚的大刀，左边董白（成年）双锤满是缺口，右边蔡文姬（成年）抱着断弦的琴，三人都淡淡笑着；前方赤兔马上的吕布举戟的剪影，身后高顺的黑盾墙；克制、哀婉，不见血。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：dawn in falling snow before the closed Xuanping Gate of Chang'an, seen from behind: the short-haired hero in battered silver armor, Dong Bai (adult) with her notched twin hammers on his left, Cai Wenji (adult, in white) holding a broken guqin on his right, the three holding hands and stepping forward together; restrained and elegiac, no gore。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c6_fenghou`

```
横版剧情事件插画：封侯：长安大殿，十岁的小皇帝在巨大的龙椅上前倾、声音发抖地坚持；阶下白发的王允躬身微笑、眼里没有笑意；群臣中短发银甲的主角惊讶地跪着；前排吕布得意。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the throne hall in Chang'an: the ten-year-old boy emperor leaning forward on a huge throne, insisting in a trembling voice; below him the white-haired Wang Yun bowing with a smile that doesn't reach his eyes。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c6_escape`

```
横版剧情事件插画：出长安：夜里马车冲过着火的城门；董白（成年）红衣双锤骑马，带着几百黑甲老兵；主角骑马护在车边，小皇帝抱着小包袱从车帘里探头；貂蝉（成年）坐在主角马后；远处白发的皇甫嵩带禁军守门。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：night escape from Chang'an: a covered carriage racing through a burning city gate, the boy emperor peeking out clutching a small bundle; Dong Bai (adult) riding alongside with her twin hammers; the hero riding on the other side with Diaochan (adult) behind his saddle。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c6_huihe`

```
横版剧情事件插画：会合洛阳：黎明的洛阳城门，虎皮披风的孙坚下马单膝跪在尘土里，面前是刚下破马车的小皇帝；吴夫人从人群里奔向主角；江东兵列阵。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the restored gate of Luoyang at dawn: the huge Sun Jian in his tiger-pelt cape kneeling on one knee in the dust before the small boy emperor stepping down from a battered carriage。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c6_seal`

```
横版剧情事件插画：玉玺：半毁的洛阳临时大殿，小皇帝在简陋的龙椅上轻声发问；孙坚把锦盒紧紧抱在胸前，不肯递出；周瑜低头记账；主角在群臣中沉默；吴夫人在后面看着孙坚。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a makeshift throne hall in half-ruined Luoyang: the boy emperor on a simple throne asking quietly; the huge Sun Jian clutching a brocade box against his chest, not offering it; Zhou Yu writing in his ledger with lowered eyes; Lady Wu (adult) watching Sun Jian from the back。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c7_huangzhong`

```
横版剧情事件插画：黄忠：南阳被攻下的营寨，四十来岁的壮实军汉黄忠，粗布军衣、手腕上还有绳痕，拉满一张硬弓，一箭射断远处营门上的「袁」字旗杆；孙策张大嘴，主角咧嘴笑。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a captured camp in Nanyang: Huang Zhong, a sturdy man in his 40s in rough soldier's clothes, rope marks on his wrists, drawing a heavy bow to full; his arrow snapping the banner pole with the character 袁 on the far camp gate; Sun Ce gaping, the hero grinning。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c5_garden`

```
横版剧情事件插画：朝见：长安御花园假山后，十岁的小皇帝摘了冕旒放在石头上，揉着脖子，仰头期盼地看着蹲下来与他平视的短发银甲主角；拐角处小黄门望风；温和而伤感。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：behind a rockery in the palace garden of Chang'an: the ten-year-old boy emperor, his heavy bead-curtained crown taken off and set on a stone, rubbing his neck and looking up hopefully at the short-haired hero in silver armor, who crouches to his eye level; a eunuch keeps watch at the corner; a gentle, melancholy mood。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c5_feast`

```
横版剧情事件插画：接风宴：董卓给董白剥虾，董白边吃边笑，董卓拿袖子擦眼睛；身后一排西凉将站起来盯着主角，吕布在廊下一言不发。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a lavish welcome feast in Dong Zhuo's mansion: the enormous Dong Zhuo peeling shrimp for his granddaughter Dong Bai (adult), who laughs with her mouth full; he wipes his eye with his sleeve。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c5_dance`

```
横版剧情事件插画：献貂蝉：灯火通明的宴厅，貂蝉长袖起舞，董卓看得前倾、胡子上沾着酒，主座上的王允似笑非笑。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a lantern-lit banquet hall: Diaochan, an adult woman of great beauty, dancing with long silk sleeves; the enormous Dong Zhuo leaning forward spellbound with wine in his beard; Wang Yun at the host's seat with a knowing half-smile。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c5_fengyi`

```
横版剧情事件插画：凤仪亭：荷花池边的亭子里，貂蝉靠在吕布肩上哭，身后暴怒的董卓掷出方天画戟，吕布侧身躲闪；貂蝉的眼角却瞟向画外，似笑非笑。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the Phoenix Pavilion in a lotus garden: Diaochan (adult) weeping on Lü Bu's shoulder at the railing; behind them the furious Dong Zhuo hurling Lü Bu's halberd; Lü Bu twisting away; Diaochan's eyes glancing sideways toward the viewer with the ghost of a smile。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c5_rescue`

```
横版剧情事件插画：吕布来援：长街上飞熊军弓弦拉满对着力竭的主角，他把穿嫁衣的董白护在身后；街尽头吕布骑赤兔破阵而来、戟指董卓（「诛此贼！」），身后上千骑兵，貂蝉（衣裙撕破、手上带血）骑马跟在他身后。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a long street at night: Lü Bu on the rearing Red Hare charging in with his halberd, Diaochan (adult) holding on behind his saddle with bloodied hands, shouting。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c4_wenji`

```
横版剧情事件插画：蔡文姬的往事：洛阳废墟的篝火边，蔡文姬抱着断弦的琴讲述，董白抱着胳膊听，吴夫人给她披上披风。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：night by a campfire in ruined Luoyang: Cai Wenji, an adult woman in white, holding her guqin with a broken string, telling her story; Dong Bai listening with folded arms, Lady Wu wrapping a cloak around Cai Wenji。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c4_peace`

```
横版剧情事件插画：求和：孙坚大帐里李儒摇扇求和，孙坚沉着脸，周瑜低声进言，主角站出来说话。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：Sun Jian's tent in ruined Luoyang: the envoy Li Ru waving a feather fan and offering peace with a gentle smile; the huge Sun Jian sitting with crossed arms, scowling。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c4_betroth`

```
横版剧情事件插画：定亲（搞笑）：帐里所有人齐刷刷看向主角，孙策跳起来拒绝，董白别过脸耳朵通红，吴夫人笑着拉她的手。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a comedic betrothal in a tent: the short-haired hero pointing at himself in disbelief; Dong Bai (adult) beside him looking away with bright red ears; Sun Ce leaping up in refusal; Lady Wu (adult) laughing behind her sleeve。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c5_enter`

```
横版剧情事件插画：入长安：长安城门，董卓搂着笑出声的董白，越过她肩膀冷冷打量主角，吕布骑赤兔默默站在后面。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the gates of Chang'an: the enormous Dong Zhuo hugging his granddaughter Dong Bai (adult), who laughs; over her shoulder his smiling eyes are cold; behind him Lü Bu on Red Hare, silent。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c5_diaochan`

```
横版剧情事件插画：貂蝉：月下花园，貂蝉跪在香炉前对月祷告，王允和主角在园门外看着。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a moonlit garden: Diaochan, an adult woman of great beauty, kneeling before an incense burner praying to the moon; Wang Yun and the hero watching from the garden gate。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `c5_dress`

```
横版剧情事件插画：试喜服：董白穿着大红嫁衣在铜镜前开心地转圈，身后主角满脸心事。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a bedroom in Chang'an: Dong Bai (adult) in a red wedding dress turning happily before a bronze mirror, the hero behind her with a troubled face。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c5_wedding`

```
横版剧情事件插画：大婚陷阱：董卓举杯冷笑，大门紧闭飞熊军四起；董白扯下盖头愣住，主角把她拉到身后拔出孙坚的旧刀（不画血腥）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the wedding trap in a hall of red lanterns: the enormous Dong Zhuo raising his cup with a cruel smile; beside him Dong Bai (adult) in a red wedding dress lifting her veil in shock, the hero pulling her behind him。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

### `c5_death`

```
横版剧情事件插画：求情（克制）：打败的董卓瘫在宫阶上，穿嫁衣的董白张开双臂扑在他身前，满脸泪水地求你别杀；主角的刀停在半空；主角身后吕布骑赤兔举着戟，貂蝉在他身边（不画血腥）。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the moment of mercy, restrained: Dong Bai (adult) in her red wedding dress kneeling with her arms spread wide to shield a fallen figure on the palace steps, looking up at Lü Bu towering on Red Hare with his halberd raised; no gore。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```
</details>

## 奇遇插图（？格事件，横版 16:9，key = e_<事件 id>，放 `pics/source/cg/`，和剧情 CG 一样登记）

### `e_borrow_general`

```
横版剧情事件插画：孙坚大帐前：孙坚指着帐外一排老将，程普、韩当、黄盖、朱治、吴景、孙贲依次站开，个个一身旧伤，眼神沉稳；主角站在帐门口，吴景的目光紧紧盯着他。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_hand_over`

```
横版剧情事件插画：盟主大营的辕门外：一辆囚车正缓缓驶出，车内的董白（成年女性）回头望了一眼，神情复杂，什么也没说；孙策站在远处沉默地看着，营门口挂着盟旗。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
（董白：成年女将，银白色长发高马尾，紫色毛边皮甲，双持两柄巨大的青铜锤（她已交付的立绘和 CG 都是这个样子）。）
```

### `e_ln_boater`

```
横版剧情事件插画：结冰的黄河渡口：一位满脸风霜的老艄公撑着小渡船，压低声音收船钱，船上堆着几袋货物；河面上漂着浮冰，天色阴沉。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_ln_wine`

```
横版剧情事件插画：酸枣大营外的酒摊：精明的摊主（四十岁上下，围着围裙）正笑眯眯地倒酒，摊上摆满酒坛，远处是诸侯各色旗帜的营帐；食客与士兵三三两两。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_lvbu_beaten`

```
横版剧情事件插画：虎牢关下：吕布退入关内，关前一片狼藉；十八路诸侯与士兵争相举杯向主角敬酒，袁绍起身让座，孙坚拍着主角的肩膀；远处一个个子不高、端着酒杯的人（曹操）捋着胡须，静静打量主角。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_lvbu_beaten_n`

```
横版剧情事件插画：酸枣大营中央：袁绍派人送来一面「义薄云天」的锦旗，诸侯们围观；曹操（个子不高，捋须）负手站在一旁，盯着那面破旧的「中山甄记」大旗；郭嘉举着酒葫芦遥遥敬了他一下。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_old_armor`

```
横版剧情事件插画：吴夫人的房间里：吴夫人打开一只樟木箱，里面是护肩刻虎纹的银甲和白毛滚边的黑披风，她亲手给主角系上甲带；孙策站在门口目瞪口呆，周瑜在一旁翻着账本。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_risk_n`

```
横版剧情事件插画：风雪弥漫的悬崖险沟前：向导缩着脖子指着狭窄陡峭的山沟，主角和同伴们勒马站在崖边，雪片遮天；险沟深处暗藏着隐约的伏兵剪影。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_taihang_bear`

```
横版剧情事件插画：太行山深林里：一头壮硕的黑熊拦在小路中间，鼻子不住地抽动；赵云抬手按住主角的肩膀，示意别动，主角腿软地缩着脖子；雪后的松林。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_taihang_hunter`

```
横版剧情事件插画：雪地里：一位背着柴火的猎户让到路边，怀里护着一只挣扎的锦鸡；甄宓（十几岁的少女）凑过去看，眼睛发亮，郭嘉在一旁打着哈欠。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_zhen_caravan`

```
横版剧情事件插画：官道上：一支挂着「甄」字旗的商队停在路边，管事下马向张夫人行礼，张夫人（成年女性，富态精明）手指在账本上划拉，郭嘉在旁笑着凑过去。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_zumao_saved`

```
横版剧情事件插画：汜水关下：华雄刚被一把飞刀击中后脑栽下马，祖茂（老将）拄刀站起，摘下头上的赤帻双手递给主角；孙策正举枪补刀高呼「华雄已死」，周瑜在后面记账。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

### `e_shuijing`

```
横版剧情事件插画：竹林草庐门口：和气的隐士司马徽手拿青铜圆镜坐在门前，笑眯眯点头「好，好」；少年孙策兴奋地凑上前指着主角。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a thatched hut in a bamboo grove: the genial hermit Sima Hui sitting at his door with a round bronze mirror, smiling and nodding 'good, good'; young Sun Ce leaning in eagerly pointing at the short-haired hero。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_pangdegong`

```
横版剧情事件插画：汉江畔岘山脚下的田埂上：大隐士庞德公拄着锄头，妻子提着饭篮走在田埂上，二人相敬如宾相互行礼；主角在一旁看着，莫名有些不安。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：fields at the foot of Mount Xian by the Han river: the old recluse Pang Degong leaning on his hoe, his wife bringing a lunch basket along the field ridge, both bowing to each other politely; the short-haired hero watching, oddly uneasy。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_huangchengyan`

```
横版剧情事件插画：沔水边的工坊内：花白胡子的发明家黄承彦蹲在一架精巧的会自动行走的木制机关车旁，手指沾着木屑墨汁；主角在一旁看得目瞪口呆。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a riverside workshop on the Mian river: the grey-bearded inventor Huang Chengyan crouching beside a little self-walking wooden cart; the short-haired hero staring at it in amazement。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_ganning`

```
横版剧情事件插画：汉水逆流而上的锦帆快船：年轻气盛的甘宁（二十岁上下、嘴角噙着桀骜不驯的坏笑、腰挂铜铃、背负铁胎大弓）站在船头冲岸上大喊，从巴郡顺江下来探查荆州虚实；岸上周瑜紧紧攥着账本和钱袋。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a brocade-sailed fast boat rowing up the Han river: the young pirate Gan Ning (early 20s, cocky grin, bronze bells at his waist, a great bow on his back) on the prow shouting at the shore, come down from Ba commandery to look Jingzhou over; Zhou Yu on the bank clutching his ledger and purse。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_ambush`

```
横版剧情事件插画：江边密密的芦苇荡中，手持破旧弯刀和铜锣的水贼突然狂呼呐喊着跃出伏击。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：river bandits bursting out of tall reeds with gongs and rusty sabers, shouting。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_snake`

```
横版剧情事件插画：滑稽喜剧场景：主角捂着小腿单脚狂跳，一条翠绿小竹叶青蛇正刺溜钻入草丛溜走，孙策和周瑜笑得前仰后合捂着肚子打滚。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：comic scene: the short-haired hero hopping on one leg clutching his thigh, a small green bamboo viper slithering away, Sun Ce and Zhou Yu doubled over laughing。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_zuoci`

```
横版剧情事件插画：白发苍苍的老道人左慈露出两颗大门牙怪笑，拄着竹杖盘坐巨石上，手中铜葫芦喷出一缕缕幽紫青烟。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a white-haired old Taoist grinning with two front teeth, sitting on a boulder with a bamboo staff, purple smoke curling from a gourd in his hand。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_chest`

```
横版剧情事件插画：路边半掩在泥土中的生锈铁宝箱，箱体上赫然刻着四个古朴小字「非礼勿开」。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a rusty iron chest half-buried by the roadside, carved with four small characters 非礼勿开。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_hero`

```
横版剧情事件插画：路边酒肆中，一名暴怒魁梧的黑脸壮汉一拳砸碎酒桌，酒碗碎屑横飞，满堂食客惊慌四散奔逃。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a burly man in a roadside tavern smashing a table with one fist, wine cups flying, drinkers scattering。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_refugees`

```
横版剧情事件插画：尘土飞扬的官道上，衣衫褴褛面黄肌瘦的流民队伍踉跄前行，倒地的老叟与怀抱啼哭婴儿伸手求助的母亲。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a column of ragged refugees on a dusty road, an old man collapsed, a mother holding a child out toward the viewer。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_washer`

```
横版剧情事件插画：清澈见底的山溪边，卷起高高衣袖的开朗少妇正挥动木槌捶洗衣服，清脆笑声回荡，身旁竹篮堆满布匹。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a cheerful adult woman washing clothes at a mountain stream, sleeves rolled up, laughing, a basket of cloth beside her。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_fruit`

```
横版剧情事件插画：空旷险峻的山道旁，一株挂满娇艳欲滴、鲜红晶莹果实的古树，周瑜严肃地抬手示意不可轻动。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a tree heavy with glossy red fruit by an empty road, Zhou Yu raising a warning finger。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_risk`

```
横版剧情事件插画：江面浓雾锁江，一叶扁舟在急流险滩前颠簸，船头老船夫蹲坐抽着长旱烟袋，前方暗礁密布。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a small boat in thick river fog, an old boatman squatting at the bow smoking a long pipe, dangerous rapids ahead。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_temple`

```
横版剧情事件插画：荒山野岭中半坍塌的残破山神庙，断了鼻子的泥塑山神像前，香炉里半炷残香仍在袅袅冒烟。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a crumbling mountain temple with a noseless earth-god statue, half a stick of incense still smoking in the censer。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_huatuo`

```
横版剧情事件插画：路边简陋义诊药摊前，面容清瘦的中年医者正凝神为村妇切脉，身旁竹编药箱墨书「沛国华佗」。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a lean middle-aged doctor treating a village woman at a roadside medicine stall, his box painted 沛国华佗。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_yuji`

```
横版剧情事件插画：白衣长袍的中年道人于吉横杖拦路，高举「于吉仙师 符水治百病」的杏黄大幡，身后信徒狂热跪拜。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a Taoist in white blocking the road, waving a banner reading 于吉仙师 符水治百病, followers kneeling。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_merchant`

```
横版剧情事件插画：官道旁富态圆脸的行商赶着装满异域奇珍的毛驴大车，眉开眼笑张开双臂热情招徕。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a plump merchant with a donkey cart piled with exotic goods, spreading his arms in welcome。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_smith`

```
横版剧情事件插画：路边叮当铁匠铺内风箱呼呼作响，赤膊精壮的老铁匠正挥舞重锤，火星四溅中锻打一把通红宝刃。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a roadside smithy with a roaring forge, a bare-chested old blacksmith hammering a glowing blade。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_tomb`

```
横版剧情事件插画：荒山幽谷中半塌陷的青砖古墓入口，阴冷阵阵，孙策两眼放光提枪欲探，周瑜在后紧皱眉头翻账本。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a half-collapsed ancient tomb in a mountain hollow, cold wind from the entrance, Sun Ce stepping in eagerly while Zhou Yu checks his ledger。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_guanlu`

```
横版剧情事件插画：古树下的青布算命卦摊前，年轻术士正凝神排卦，招牌大书「管辂神算」。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a young diviner at a fortune-telling stall under a tree, sign reading 管辂神算。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_xushao`

```
横版剧情事件插画：道旁老槐树下，当代名士许劭端坐石凳升座品鉴人物，阶下翘首以盼求得一语评语的各路士子。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：the famous critic Xu Shao holding court under a tree by the roadside, a crowd of hopeful men waiting for his one-line verdicts。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_qiao`

```
横版剧情事件插画：皖城溪畔，绝美并蒂的大乔小乔姐妹正在水边轻浣罗裙，一人温婉一人灵动，远处的孙策与周瑜看傻在原地，迈出的脚悬在半空。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：two beautiful adult sisters washing clothes by a river, one gentle and one lively, Sun Ce and Zhou Yu frozen mid-step staring。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_drink`

```
横版剧情事件插画：酒馆豪饮赌局：年轻孙策豪迈地将空酒坛重重拍在桌案上大笑，围观酒客群情激愤齐声喝彩。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a tavern drinking contest: Sun Ce slamming a wine jar on the table, a crowd of drinkers circling and cheering。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_deserters`

```
横版剧情事件插画：道旁荒草丛中，几个丢盔卸甲、面黄肌瘦的逃兵正蜷缩着啃咬树皮，惊恐万状地瑟缩发抖。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：ragged deserters without armour crouching by the road gnawing bark, shrinking back in fear。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_storm`

```
横版剧情事件插画：突如其来的倾盆暴雨将官道化为泥泞沼泽，行军队伍披蓑戴笠在大雨与惊雷中艰难跋涉。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a sudden thunderstorm turning a road into mud, the army struggling through the rain。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_horse`

```
横版剧情事件插画：神秘马贩手中牵着两匹神驹的缰绳——一匹面带煞气白额的凶骏，另一匹浑身如火炭烈焰的赤兔神驹。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a horse dealer holding the reins of two horses — a white-faced one with an ominous look and a fiery red one。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_convoy`

```
横版剧情事件插画：山丘下蜿蜒的山道上，几名西凉军骑兵正押解着印有「董」字戳记的粮草辎重车队前行。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a few Xiliang soldiers escorting grain carts with sacks stamped 董 along a road below a hill。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_surrender`

```
横版剧情事件插画：黄巾残部的小队士兵手持简陋白旗，神情彷徨绝望地跪倒在泥泞道路中央乞降。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a small group of men in yellow headscarves carrying a white flag, kneeling on a road。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_shanzei`

```
横版剧情事件插画：山道险要拐角处，独眼刀疤悍匪手持阔刃开山大斧猛然跃出，身后伏兵呐喊四起。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a one-eyed bandit with a big axe jumping out at a mountain bend, his gang behind him。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_shanzhai`

```
横版剧情事件插画：太行山脚下的山贼前哨大寨，破旧的「替天行道」旗帜猎猎，寨内飘出烤野猪肉的浓烈香气，孙策暗咽口水。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a mountain bandit fort with a tattered 替天行道 banner, smoke of roasting meat rising, Sun Ce swallowing。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_jieying`

```
横版剧情事件插画：漆黑如墨的深夜偷袭营寨：营犬狂吠，漫天火箭与火把如火龙般自黑夜深处席卷冲杀而来。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a night camp raid: dogs barking, a wall of torches coming out of the dark。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_hj_camp`

```
横版剧情事件插画：隐秘山谷深处的黄巾余孽难民营地：老弱妇孺围坐在一口煮着野菜苦汤的残破瓦罐旁，青烟寥寥。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a Yellow Turban remnant camp in a valley: old people, children and women around a pot of wild greens, thin smoke。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_hj_medics`

```
横版剧情事件插画：残破古庙内，裹着黄头巾的温婉医女正细心为伤卒清洗包扎刀伤，身旁药箱绘有太平道符文。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a ruined temple where a woman in a yellow headscarf cleans a wounded soldier's wound, a Taiping talisman on her medicine box。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_hj_road`

```
横版剧情事件插画：密林深处，手持削尖竹竿与柴刀的黄巾残部伏兵怒吼着冲下山坡拦截去路。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：Yellow Turban remnants charging out of a forest with sticks and bamboo spears, shouting。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_yuan_tax`

```
横版剧情事件插画：官道路口简陋的袁家收税哨所，两名持枪袁军士卒蛮横拦住去路，敲诈盘剥过往行商米粮。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a roadside toll shed where two soldiers in Yuan livery block the road with spears, demanding rice。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_black_market`

```
横版剧情事件插画：深夜暗巷深处一盏摇曳的幽绿灯笼下，神秘蒙面客敞开挂满各色违禁珍宝的宽大斗篷。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a narrow alley at night lit by a green lantern, a masked man opening his coat full of stolen treasures。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_jz_spy`

```
横版剧情事件插画：真定城门口，行迹可疑的货郎挑担被守门校尉当场拿获，扁担暗格中滑落出一卷泛黄的城防机密布阵图。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a suspicious peddler caught at a city gate, a map of the city defences falling out of his carrying pole。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_veterans`

```
横版剧情事件插画：城门口向阳墙根下，两位断臂伤残的解甲老兵正晒着暖阳，忽见孙策走近，惊喜万状地挣扎欲拜。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：two old soldiers, one missing an arm, sunning themselves at a city gate and recognising Sun Ce with joy。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_plague`

```
横版剧情事件插画：悬挂白布招魂的寂静村落入口前，白发老医官神情严峻地高抬手臂，厉声喝止过路人入村。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a village entrance hung with white cloth, an old doctor raising his hand to stop the viewer。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_yuxi_rumor`

```
横版剧情事件插画：人声鼎沸、茶香四溢的茶楼大堂内，三教九流食客纷纷交头接耳，手掩嘴角窃窃私语传国玉玺秘闻。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：a crowded teahouse, everyone whispering behind their hands。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_tongyao`

```
横版剧情事件插画：乡间泥径上，扎着冲天辫的稚嫩孩童们拍手蹦跳传唱神秘谶纬童谣，远方地平线上矗立着董卓巨胖凶残的巍峨剪影。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：children clapping and running along a road singing, in the background the silhouette of a huge fat man。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

### `e_zhuhou_yan`

```
横版剧情事件插画：联军中军大帐前，白衣使者双手恭敬奉上一封烫金请柬，后方联军连绵帅帐中金鼓齐鸣、酒肉飘香。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```

<details>
<summary>English Prompt (英文备用)</summary>

```
横版剧情事件插画：an envoy presenting an invitation card from the allied commander's camp, banquet tents in the background。
构图：横版 16:9，1920x1080，主要人物位于画面上部三分之二以上。画面中重点人物最多四位；无名的背景人物（士兵、人群）不限。
画风：复古日系战术动漫 RPG 卡牌插画，参考《兰斯10》画风，赛璐珞上色，墨线干净利落，色彩浓郁鲜艳，视觉小说事件 CG，表情生动，暖色电影感光线；不要文字、不要 UI。
（主角出场时——主角：年轻男子，黑色短发（现代发型，在汉代很扎眼），穿孙坚留下的旧银甲（肩甲刻虎纹），内衬绿色战袍，披黑色白毛边斗篷（不是虎皮），铠甲下摆露出虎皮内衬，肩扛孙坚的巨大宽刃古锭刀。）
```
</details>

## 天命图（512×512 透明 PNG，放 `godot/data/art/fates/<key>.png`；没有图时显示一个汉字）

## 词缀徽记（128×128 透明 PNG，放 `godot/data/art/affixes/<key>.png`）

## 界面大图（横版 16:9 JPG，放 `godot/data/art/ui/<key>.jpg`）

## 宝箱图（开宝箱动画用，512×512 透明 PNG，放 `godot/data/art/ui/<key>.png`）

## 章节地图底图（横版宽图，放 `pics/source/map/bg_<key>.jpg`）

### `yuxi`

```
横向游戏地图插画，手绘中国山水长卷（浅绛 / 青绿山水）：【地图共 27 列，南线第三章·传国玉玺】自焚毁的洛阳向南到南阳鲁阳，自左向右依次：①左端洛阳废墟冒着黑烟，长长的难民队伍南行；②山丘间断粮的孙坚军营，炊烟稀薄；③鲁阳城墙与酒肆街，街口有行人与酒旗；④雨水浸透的农田，袁术军营连绵；⑤最右端大雨中的狭窄山口。
构图：超宽全景，3200x1080（可横向滚动），斜向高空俯瞰；上 / 中 / 下三条大致水平的行进带保持干净、不放繁杂细节（地图格子落在上面），薄雾轻绕。
画风：与第一章地图（godot/data/art/map/prologue.jpg）一致：墨线勾勒，宣纸上的淡绿与赭石淡彩；不要文字、不要 UI、不要近景人物。
```

### `shouluoyang`

```
横向游戏地图插画，手绘中国山水长卷（浅绛 / 青绿山水）：【地图共 22 列，南线第三章·收洛阳】重建中的洛阳，自左向右依次：①灰烬中的一堆篝火；②官眷被护送向西的官道；③山脚小路上的西凉粮队；④修复的宗庙与城墙，城头插着红底「孙」字旗；⑤太平的集市街；⑥最右端通向长安的西行大道。
构图：超宽全景，3200x1080（可横向滚动），斜向高空俯瞰；上 / 中 / 下三条大致水平的行进带保持干净、不放繁杂细节（地图格子落在上面），薄雾轻绕。
画风：与第一章地图（godot/data/art/map/prologue.jpg）一致：墨线勾勒，宣纸上的淡绿与赭石淡彩；不要文字、不要 UI、不要近景人物。
```

### `changan`

```
横向游戏地图插画，手绘中国山水长卷（浅绛 / 青绿山水）：【地图共 31 列，第三章·长安】冬日长安，自左向右依次：①宏伟的城门；②董卓华丽的府邸与庭院里的比武场；③带假山花园的宫殿；④朴素的书生宅；⑤司徒府；⑥荷塘边的凤仪亭；⑦最右端挂满红色喜庆灯笼的丞相府。
构图：超宽全景，3200x1080（可横向滚动），斜向高空俯瞰；上 / 中 / 下三条大致水平的行进带保持干净、不放繁杂细节（地图格子落在上面），薄雾轻绕。
画风：与第一章地图（godot/data/art/map/prologue.jpg）一致：墨线勾勒，宣纸上的淡绿与赭石淡彩；不要文字、不要 UI、不要近景人物。
```

### `jingxiang`

```
横向游戏地图插画，手绘中国山水长卷（浅绛 / 青绿山水）：【地图共 31 列，第五章·荆襄风云】自南阳向南到汉水，自左向右依次：①秋日宛城，院中的灶台与河边的栗子摊；②芦苇丛生的淯水与战场；③汉水渡口，挂锦帆的战船；④新野一带的坞堡与樊城小镇；⑤汉水边的襄阳城，有兵库与停满战船的水寨；⑥种着梯田的岘山；⑦最右端万山上江边岩石上的一座孤亭。
构图：超宽全景，3200x1080（可横向滚动），斜向高空俯瞰；上 / 中 / 下三条大致水平的行进带保持干净、不放繁杂细节（地图格子落在上面），薄雾轻绕。
画风：与第一章地图（godot/data/art/map/prologue.jpg）一致：墨线勾勒，宣纸上的淡绿与赭石淡彩；不要文字、不要 UI、不要近景人物。
```

### `dongui`

```
横向游戏地图插画，手绘中国山水长卷（浅绛 / 青绿山水）：【地图共 37 列，第四章·挟天子】一条长征路，自左向右依次：①雪中的长安宫城与宣平门；②渭水东行的大道；③群山与函谷关；④插着红底「孙」字旗、半修复的洛阳；⑤向南的夏日官道；⑥袁术军营；⑦最右端南阳宛城的城墙。
构图：超宽全景，3200x1080（可横向滚动），斜向高空俯瞰；上 / 中 / 下三条大致水平的行进带保持干净、不放繁杂细节（地图格子落在上面），薄雾轻绕。
画风：与第一章地图（godot/data/art/map/prologue.jpg）一致：墨线勾勒，宣纸上的淡绿与赭石淡彩；不要文字、不要 UI、不要近景人物。
```

### `heishan`

```
横向游戏地图插画，手绘中国山水长卷（浅绛 / 青绿山水）：【地图共 40 列，北线第三章·黑山风云，三条行进带：上=战斗线，中=主线，下=奇遇线】自左向右依次：①左端（第 0–6 列）真定县城与城外小路，城墙下贴着发榜的告示，军营里一名兵痞在闹事，旁边是校场；②（第 7–14 列）进入太行山：山道、采药人的小屋、深山绝壁，一处悬崖下有白马与人影；③（第 15–22 列）黑山大寨：木寨、演武场、寨中集市，大寨议事堂挂着黑山令；④（第 23–30 列）山中秘道与狭窄的峡谷，太行山口的关卡；⑤（第 31–39 列）界桥外围的原野，河畔的营垒，最右端是插着斑马大旗的战场。整体冬末春初，山色青灰。
构图：超宽全景，3200x1080（可横向滚动），斜向高空俯瞰；上 / 中 / 下三条大致水平的行进带保持干净、不放繁杂细节（地图格子落在上面），薄雾轻绕。
画风：与第一章地图（godot/data/art/map/prologue.jpg）一致：墨线勾勒，宣纸上的淡绿与赭石淡彩；不要文字、不要 UI、不要近景人物。
```

### `beihai`

```
横向游戏地图插画，手绘中国山水长卷（浅绛 / 青绿山水）：【地图共 48 列，北线第四章·双凤乱太行，三条行进带：上=战斗线，中=主线，下=奇遇线】自左向右依次：①左端（第 0–12 列）太行外围，山寨与郑家寨、姜家寨隔山相望，两寨之间是山谷；②（第 13–24 列）太行休整营地，北方来的并州狼骑在山口扬尘，吕布的旗号隐约可见；③（第 25–31 列）突围：苇荡深处的河湾，冀州军追兵的营垒，黄河渡口；④（第 32–47 列）北海城：被黄巾军围困的城墙，城外黄巾的营帐与饥民，城门前支着熬粥的大锅，最右端是北海相府。整体夏季，色调偏暖。
构图：超宽全景，3200x1080（可横向滚动），斜向高空俯瞰；上 / 中 / 下三条大致水平的行进带保持干净、不放繁杂细节（地图格子落在上面），薄雾轻绕。
画风：与第一章地图（godot/data/art/map/prologue.jpg）一致：墨线勾勒，宣纸上的淡绿与赭石淡彩；不要文字、不要 UI、不要近景人物。
```

## 宝物图标（256×256 透明 PNG，放 `pics/source/relics/<key>.png`；现在是程序生成的占位）
