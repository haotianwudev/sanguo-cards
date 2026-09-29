# 出图提示词

> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。
> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。
> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，
> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。

## 下一批（交给 Gemini）

按顺序画；交付后重跑本脚本，这一条会自动消失。

**先重画**（已交付但有地方不对）：

- `inf_n` — 官军刀兵：盾牌上的鹰和回纹边是古希腊重装步兵盾的样式——换成汉军的盾（长方形或圆盾，黑红漆面，饕餮 / 云纹或素面），其他不变

1. `c2_sanying` — 虎牢关：三英战吕布（打斗 + 一排看呆的人，见提示词）（剧情 CG）
2. `huaxiong` — 汜水关·华雄（西凉铁骑重甲大刀，关口烽燧荒野）（战斗 CG）
3. `dongbai` — 董白（董卓孙女，成年女将双巨锤，被重锤砸裂碎石坑凹陷的河滩）（战斗 CG）
4. `hulao_ch1` — 追兵·吕布（虎牢关追击战，月夜残阳赤兔马方天戟）（战斗 CG）
5. `xiliang_youqi` — 西凉游骑（尘土飞扬的中原官道）（战斗 CG）
6. `guosi` — 郭汜（掠夺焚烧村落的西凉军寨）（战斗 CG）
7. `feixiong` — 飞熊军（黑甲重骑阵列）（战斗 CG）
8. `liru` — 李儒伏兵（峡谷险道两侧峭壁伏兵）（战斗 CG）
9. `lijue` — 洛阳城门·李傕（烈火焚城的洛阳门前，黑烟火星）（战斗 CG）
10. `xiliang_scout` — 截粮·西凉斥候（山脚运粮辎重车队）（战斗 CG）
11. `c2_setout` — 第二章开场：策马北上讨董（孙策跑偏、主角周瑜对视莞尔、吴夫人马车）（剧情 CG）
12. `c2_zumao` — 阵前：华雄追砍祖茂，孙策挺枪急救（剧情 CG）
13. `c2_capture` — 俘虏董白：主角扛米袋一样扛董白，孙策周瑜合力扛巨锤（爆笑）（剧情 CG）
14. `c2_captive` — 俘虏的日子：战俘帐内董白与主角猜拳，孙策帐外酸溜溜偷看（剧情 CG）
15. `c2_raid` — 吕布劫营：夜袭中军大寨，孙坚单人挡寨门（剧情 CG）
16. `c2_triple` — 联军大宴：各路诸侯向主角敬酒祝捷，袁绍让座，孙坚拍肩（剧情 CG）
17. `c2_jianhua` — 孙坚斩华雄（孙坚虎皮斗篷挥刀斩敌）（剧情 CG）
18. `c2_keep` — 吴夫人给董白梳头（董白嘴硬眼眶红，主角探头）（剧情 CG）
19. `c2_yuxi` — 洛阳枯井得玉玺（孙坚捧起微光玉玺）（剧情 CG）
20. `c2_dongbai_join` — 董白率西凉女骑正式加入（剧情 CG）
21. `e_tangji` — 破庙救唐姬（剧情 CG）
22. `e_yazhai` — 压寨夫人（胭脂虎指着主角）（剧情 CG）
23. `e_shengnv` — 黄巾圣女（张宁施符水）（剧情 CG）
24. `c3_shanfei` — 独眼匪首（第三章流民匪患）（战斗 CG）
25. `c3_qiaorui` — 城外·桥蕤（第三章南阳城外便装伏兵）（战斗 CG）
26. `c3_jiling` — 山口·纪灵（第三章大雨隘口决战）（战斗 CG）
27. `c3_leibo` — 山道追兵·雷薄（第三章清晨山道追击）（战斗 CG）
28. `c3_chenlan` — 夜袭·陈兰（第三章雨夜火把夜袭）（战斗 CG）
29. `c3_yuanshu` — 袁术（第三章金顶马车与大军）（战斗 CG）
30. `c3_leave` — 撤离洛阳（流民大队与孙家车队）（剧情 CG）
31. `c3_wenji` — 救蔡文姬（泥泞道边拾断弦琴）（剧情 CG）
32. `c3_supply` — 饥民与军粮（剧情 CG）
33. `c3_slip` — 酒肆说漏嘴（孙策拍桌吹牛，周瑜捂嘴）（剧情 CG）
34. `c3_entrust` — 托付玉玺（孙坚夜交锦盒于吴夫人）（剧情 CG）
35. `c3_warn` — 劝阻孙坚（剧情 CG）
36. `c3_raid` — 陈兰雨夜袭营（剧情 CG）
37. `c3_news` — 纪灵败退与噩耗（剧情 CG）
38. `c3_end` — 碎玺决战（吴夫人碎玉玺面袁术）（剧情 CG）
39. `liubei` — 刘备（换掉占位）（立绘）
40. `guanyu` — 关羽（换掉占位）（立绘）
41. `lvbu` — 吕布（换掉占位）（立绘）
42. `caiwenji` — 蔡文姬（立绘）
43. `yuanshu` — 袁术（立绘）
44. `jiling` — 纪灵（立绘）
45. `leibo` — 雷薄（立绘）
46. `chenlan` — 陈兰（立绘）
47. `qiaorui` — 桥蕤（立绘）

交图规则：

- 每张图都用下面对应小节的**完整提示词**；图上长相/器物必须和设定对得上（见 `CARD-DESIGN.md` 第 7 节）。
- 宝物：纯中式汉代古风器物，独立透明背景（纯白背景抠图，无圆盘边框，无西式奇幻符号），日系战术卡牌 RPG 赛璐珞道具插画风。
- 女性角色一律画成成年人；董白不写年龄、不画成萝莉。
- 卡牌立绘必须带背景：背景为符合人物身份与阵营的古风场景（军营、要塞、江岸、山林、宫室等，具自然景深与环境光影，不再使用纯白/摄影棚素底）。人物半身居中，面部在上方三分之一。
- 文件名 = key：宝物放 `pics/source/relics/<key>.png`（同时复制到 `godot/data/art/relics/<key>.png`），立绘放 `pics/source/generals/`（兵卡放 `soldiers/`）。
- 战斗 CG 放 `pics/source/battles/<key>.jpg`、在 `pics/art.json` 的 battles 登记；照新的战斗画面构图：敌人大、居中、在画面中上部，左上、右上两角别放重要东西（血条和战斗记录在那里），下面 45% 画简单的地面（我方卡牌半透明地压在上面）。
- 宝箱图：PNG 透明底 512×512，直接放 `godot/data/art/ui/<key>.png`（开宝箱动画会自动用上）。
- 立绘在 `pics/art.json` 对应段登记；然后跑 `sanguo-art`，再跑 `python tools/art_prompts.py` 刷新本文件。
- **不要覆盖已经交付的图**；重画某张时旧图别留在 `pics/source/` 里（`backup_old/` 之类的文件夹不要提交）。
- 提交时按路径 `git add`，只提交自己的图和登记，别带上别人没提交的改动。

## 立绘（竖版 3:4）

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

### `fengfuren` ⬜ 缺

```
A vertical character portrait of Lady Feng (冯夫人), Yuan Shu's beloved and very beautiful wife — a scheming villain, an adult woman.
Appearance: Adult woman in her late 20s of striking beauty, a sweet smile that doesn't reach her cold, calculating eyes.
Armor & Clothing: Luxurious pale-gold silk robes and a jeweled hairpin — elegant, never gaudy.
Weapon: Holding a lacquered box of homemade pastries, a small embroidered handkerchief in her other hand.
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

### `caiwenji` ⬜ 缺

```
A vertical character portrait of Cai Wenji (蔡文姬, Cai Yan), the gifted poet and musician, daughter of the scholar Cai Yong.
Appearance: Adult woman in her 20s, gentle but steady eyes with a quiet sorrow, long black hair half tied with a white ribbon.
Armor & Clothing: Plain white scholar's robe with pale blue trim, a little dusty from the road.
Weapon: Holding a guqin (古琴) to her chest; one of its strings is broken.
Background: A quiet, candlelit ancient scholar study with unrolled bamboo scrolls on low tables, a bronze incense burner emitting delicate fragrant smoke ribbons, and a painted silk partition screen.
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

### `liubei` 🟡 换掉占位

```
A vertical character portrait of Liu Bei (刘备), the humble, earnest leader who calls himself a descendant of the Prince of Zhongshan.
Appearance: Gentle-faced man in his early 30s with notably large earlobes and long arms, kind sincere eyes, neat short beard, a slightly awkward, eager-to-please smile.
Armor & Clothing: Modest green-and-cream Han scholar-general robe over light leather armor, a simple topknot with a cloth band.
Weapon: Holding his twin swords (双股剑) a little clumsily in both hands, as if not quite sure how to use them.
Background: A modest Han military garrison headquarters with a tactical map table, candle lanterns, rolled bamboo scrolls, and straw partitions.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `guanyu` 🟡 换掉占位

```
A vertical character portrait of Guan Yu (关羽), the dignified god of war of the Three Kingdoms era.
Appearance: Tall imposing man in his early 30s with a deep red face, phoenix eyes half-closed in calm pride, a magnificent long flowing black beard reaching his chest.
Armor & Clothing: Green war robe over Han dynasty lamellar armor, green headscarf, a heroic cape.
Weapon: Holding the Green Dragon Crescent Blade (青龙偃月刀 - a long glaive with a dragon-headed crescent blade) upright beside him.
Background: A solemn military command post with green banners, heavy weapon stands, and dramatic evening clouds in the sky.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

### `lvbu` 🟡 换掉占位

```
A vertical character portrait of Lü Bu (吕布), the unrivaled, terrifying warrior of the Three Kingdoms era.
Appearance: Tall, handsome, arrogant warrior in his early 30s with a cold predatory glare and a confident smirk, overwhelming aura.
Armor & Clothing: Ornate crimson and black armor with gold trim, a helmet crowned with two long pheasant tail feathers (雉尾冠), a red cape flaring behind him.
Weapon: Holding the Sky Piercer halberd (方天画戟 - a long halberd with a crescent side blade) across his shoulders.
Background: A scorched, dust-swept battlefield under a dramatic crimson and dark sky, with broken weapons stuck in the ground and distant fortress ramparts.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.
```

## 战斗 CG（横版 16:9，每场战斗一张）

### `c4_guosi`

```
A horizontal battle scene illustration: a looted village road: Guo Si on horseback over captured grain carts, soldiers loading the villagers' last sacks, an old man knocked down, Dong Bai smashing a cart wheel with her twin hammers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_hall`

```
A horizontal battle scene illustration: a wedding hall turned trap: red lanterns and silk, the doors slammed shut, black-armored Flying Bear cavalry pouring in from behind the curtains.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c5_dongzhuo`

```
A horizontal battle scene illustration: the steps before the chancellor's mansion at night: the enormous Dong Zhuo with a drawn sword among his elite black-armored guards, wedding lanterns burning behind him.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `dagu`

```
A horizontal battle scene illustration: the Dagu pass outside Luoyang: the veteran Xiliang general Xu Rong on horseback before rows of heavy cavalry and spearmen in battle formation, dust and banners, an ambush glinting in the hills.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_shanfei`

```
A horizontal battle scene illustration: a one-eyed bandit chief on horseback dragging a woman in white onto his saddle amid fleeing refugees on a dusty road, a broken guqin on the ground.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_qiaorui`

```
A horizontal battle scene illustration: outside the Nanyang city wall at dusk: the stout officer Qiao Rui with Yuan soldiers in disguise stepping out of a market crowd, sabers drawn.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_jiling`

```
A horizontal battle scene illustration: a narrow mountain pass in heavy rain: Yuan Shu's foremost general Ji Ling in gilded armor with a three-pointed glaive, standing alone in front of a wall of spearmen, the final battle.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_leibo`

```
A horizontal battle scene illustration: a mountain trail at dawn: Lei Bo leading Yuan cavalry in pursuit, arrows flying, mud splashing.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_chenlan`

```
A horizontal battle scene illustration: a rainy night courtyard lit by torches: the grey-bearded general Chen Lan with a long spear at the gate under a 袁 banner, soldiers pouring in.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `c3_yuanshu`

```
A horizontal battle scene illustration: a rain-soaked valley mouth: Yuan Shu's golden-roofed carriage behind rows of archers and a huge 袁 banner, overwhelming numbers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `xiliang_youqi`

```
A horizontal battle scene illustration: Xiliang light cavalry galloping down a dusty Central Plains road.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `guosi`

```
A horizontal battle scene illustration: the raider general Guo Si on horseback in a plundered burning village.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `feixiong`

```
A horizontal battle scene illustration: Dong Zhuo's Flying Bear heavy cavalry in black armor lined up on an open plain.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `liru`

```
A horizontal battle scene illustration: the strategist Li Ru smiling from a cliff above a narrow gorge while ambushers spring out on both sides.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `huaxiong`

```
A horizontal battle scene illustration: the giant general Hua Xiong swinging his great blade on an open battlefield, a red headscarf lying in the dust.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `dongbai`

```
A horizontal battle scene illustration: Dong Bai, an adult woman general, leaping with two giant bronze hammers on a riverbank cratered by her blows.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `hulao_ch1`

```
A horizontal battle scene illustration: Lü Bu on the red horse Red Hare charging across a desolate plain at night, dust and moonlight.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `lijue`

```
A horizontal battle scene illustration: Li Jue with a torch in front of the burning gates of Luoyang, flames and smoke.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `xiliang_scout`

```
A horizontal battle scene illustration: Xiliang soldiers escorting a grain wagon convoy along a mountain foot road.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the upper-middle of the frame (its head / face about 30-45% from the top), the top-left and top-right corners calm (HP bar and log sit there), the bottom 45% simple ground (our cards cover it, half see-through).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

## 剧情插图 CG（横版 16:9）

### `c5_rescue`

```
A horizontal story event illustration: a long street at night: rows of Flying Bear archers drawing their bows at the exhausted hero, who shields Dong Bai (adult, red wedding dress) behind him; from the far end Lü Bu bursts through on Red Hare with his halberd, a thousand cavalry behind him, and Diaochan (adult, torn dress, bloodied hands) riding behind him.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_wenji`

```
A horizontal story event illustration: night by a campfire in ruined Luoyang: Cai Wenji, an adult woman in white, holding her guqin with a broken string, telling her story; Dong Bai listening with folded arms, Lady Wu wrapping a cloak around Cai Wenji.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_peace`

```
A horizontal story event illustration: Sun Jian's tent in Luoyang: the envoy Li Ru with a feather fan offering peace, Sun Jian scowling, Zhou Yu whispering advice, the hero stepping forward to speak.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c4_betroth`

```
A horizontal story event illustration: a comedic betrothal: everyone in the tent turning to stare at the hero, Sun Ce leaping up in refusal, Dong Bai (an adult woman) turning away with bright red ears, Lady Wu laughing and taking her hand.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_enter`

```
A horizontal story event illustration: the gates of Chang'an: the enormous Dong Zhuo hugging his granddaughter Dong Bai, who laughs, while he eyes the hero coldly over her shoulder; Lü Bu on Red Hare standing silently behind.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_diaochan`

```
A horizontal story event illustration: a moonlit garden: Diaochan, an adult woman of great beauty, kneeling before an incense burner praying to the moon; Wang Yun and the hero watching from the garden gate.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_dress`

```
A horizontal story event illustration: a bedroom in Chang'an: Dong Bai (adult) in a red wedding dress turning happily before a bronze mirror, the hero behind her with a troubled face.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_wedding`

```
A horizontal story event illustration: the wedding trap: Dong Zhuo raising his cup with a cruel smile, doors shut, soldiers everywhere; Dong Bai in her red dress with the veil torn off, stunned; the hero pulling her behind him and drawing Sun Jian's old saber (no gore).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c5_death`

```
A horizontal story event illustration: the moment of mercy, restrained: the defeated Dong Zhuo collapsed on the palace steps; Dong Bai (adult) in her red wedding dress throws herself in front of him with her arms spread wide, tears streaming, begging; the hero's saber stopped in mid-air above them; behind the hero, Lü Bu on Red Hare with his halberd raised, Diaochan at his side (no gore).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_feng`

```
A horizontal story event illustration: a quiet veranda in Nanyang: Lady Wu sewing a winter coat and the beautiful Lady Feng embroidering a handkerchief side by side, laughing together over a plate of pastries — Lady Feng's eyes sliding toward a brocade box half-hidden under the bed inside; in the background the hero and Zhou Yu watch warily from a doorway, Zhou Yu jotting in his ledger.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_heqin`

```
A horizontal story event illustration: a tense army tent: Sun Jian kicking over a marriage-proposal gift box and driving his saber into the table, the envoy Li Jue backing away with a forced smile, young Sun Ce pale with shock, Zhou Yu watching calmly; outside the tent flap a carriage curtain slightly lifted.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_mixin`

```
A horizontal story event illustration: night after a battle: Zhou Yu reading a captured secret letter by torchlight, Sun Jian crushing its edge in his fist, far on the horizon the sky over Luoyang faintly red.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_leave`

```
A horizontal story event illustration: leaving the ruins of burning Luoyang: an endless column of refugees, Sun Jian riding in front hugging a brocade box, Lady Wu handing out food from her carriage.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_wenji`

```
A horizontal story event illustration: on a muddy road after a fight: Cai Wenji, an adult woman in a white robe, kneeling to pick up her guqin with a broken string, Dong Bai with her twin hammers looking away embarrassed, Lady Wu putting a cloak on Cai Wenji's shoulders.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_supply`

```
A horizontal story event illustration: night in a hungry army camp: Sun Jian alone by a campfire opening and closing a brocade box, Zhou Yu counting on his fingers, Sun Ce hiding his rice bowl behind his back.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_slip`

```
A horizontal story event illustration: a lively tavern: a tipsy Sun Ce slamming the table and bragging, Zhou Yu lunging to cover his mouth, the hero throwing coins on the table, soldiers in Yuan uniforms at the next table freezing with chopsticks in the air (comedic).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_entrust`

```
A horizontal story event illustration: lamplit room at night: Sun Jian placing the brocade box with the jade seal into Lady Wu's hands, the hero standing at the doorway, Sun Jian gruffly avoiding his eyes.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_warn`

```
A horizontal story event illustration: the night before the campaign: the hero earnestly pleading with Sun Jian, who laughs and claps him hard on the shoulder, a war banner and armor stand behind them.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_raid`

```
A horizontal story event illustration: rainy night: torches and a 袁 banner outside the courtyard wall, the grey-bearded general Chen Lan with a long spear at the gate, Lady Wu clutching the brocade box behind the hero, Sun Ce charging out with a spear.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_news`

```
A horizontal story event illustration: a rainy mountain pass: the defeated general Ji Ling kneeling in the mud leaning on his three-pointed glaive, Lady Wu sinking to her knees in the rain with the brocade box fallen beside her, Sun Ce holding her and crying, Zhou Yu's ledger lying in the mud (grief, no gore).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c3_end`

```
A horizontal story event illustration: a restrained tragic scene in the rain: Lady Wu standing tall and calm facing Yuan Shu's golden carriage, the imperial jade seal shattered on a stone at her feet, its gold-patched corner in the mud, Yuan Shu leaping from the carriage aghast, the hero stepping in front of her with Sun Jian's old saber, Sun Ce and Zhou Yu escaping on horseback in the distance (no gore, no violence shown).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_zumao`

```
A horizontal story event illustration: a battlefield: the veteran Zu Mao wearing a red headscarf being chased by the giant Hua Xiong, the young Sun Ce charging in with a spear.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_capture`

```
A horizontal story event illustration: the hero carrying the unconscious woman general Dong Bai over his shoulder like a sack of rice, Sun Ce and Zhou Yu each struggling to carry one of her giant bronze hammers (comedic).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_captive`

```
A horizontal story event illustration: inside a prisoner tent: the woman general Dong Bai, an adult woman with her arms loosely tied, playing rock-paper-scissors against the hero, her hand a split second late, a half-eaten bowl of braised pork beside her, Sun Ce peeking in enviously through the tent flap (comedic).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_raid`

```
A horizontal story event illustration: a burning army camp at night: Sun Jian alone blocking the camp gate with his sword against Lü Bu on the red horse Red Hare.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_sanying`

```
A horizontal story event illustration: the legendary three heroes fighting Lü Bu in a storm of dust: Lü Bu on the rearing red horse Red Hare parrying with his crescent halberd, Guan Yu with the green-dragon crescent blade, Zhang Fei thrusting the serpent spear, Liu Bei with twin swords, sparks flying where the blades meet; in the foreground the onlookers frozen in awe — the hero sitting in the dust, Sun Ce gaping with his spear trembling, Zhou Yu's ledger fallen at his feet, Sun Jian with his arm in a sling narrowing his eyes, and the woman general Dong Bai (adult) tied across a horse staring wide-eyed.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_fate`

```
A horizontal story event illustration: the woman general Dong Bai tied on a horse glaring defiantly at the hero, an envoy of Yuan Shao waiting beside them, tense.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_setout`

```
A horizontal story event illustration: setting off north on a country road: Sun Ce on a brown horse galloping ahead the wrong way, the hero on a white horse and Zhou Yu on a black horse exchanging a look, Lady Wu's carved carriage behind with a chest of ledgers tied on the back.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_jianhua`

```
A horizontal story event illustration: a battlefield: Sun Jian in a tiger-pelt cape beheading the giant Hua Xiong with one sweep of his saber, the fallen hero looking up at him, dust and blood spray (not gory).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_zumao_saved`

```
A horizontal story event illustration: the hero hurling a huge broad saber that strikes the giant Hua Xiong on the back of the head, Sun Ce charging in with a spear, the wounded veteran Zu Mao pulling off his red headscarf to hand it over.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_counter`

```
A horizontal story event illustration: Sun Jian's camp: the burly Sun Jian hugging Lady Wu while glaring at the hero over her shoulder, the veteran generals behind them trying not to laugh.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_borrow`

```
A horizontal story event illustration: outside Sun Jian's command tent: six Sun-clan generals in a row (a long-bearded elder with a snake spear, a silent archer on horseback, a scarred veteran with an iron whip, a quartermaster with a scroll, a young general on a white horse glaring, a smirking young spearman), Sun Jian with his back turned and arms folded.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_keep`

```
A horizontal story event illustration: inside a carved carriage: Lady Wu gently combing the hair of the captured woman general Dong Bai, who sits stiff-necked with reddened eyes, the hero peeking in at the curtain.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_handover`

```
A horizontal story event illustration: a restrained, somber scene: the woman general Dong Bai in a prisoner cart looking back over her shoulder, the hero standing alone at the camp gate, grey sky (no gore).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_triple`

```
A horizontal story event illustration: a lavish allied lords' banquet: warlords crowding around the hero with wine cups, Yuan Shao giving up his seat, Sun Jian clapping the hero on the shoulder, Lady Wu watching from the side.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_dongbai_join`

```
A horizontal story event illustration: a burning Luoyang street at night: the woman general Dong Bai striding toward the hero with her two giant bronze hammers, a line of Xiliang female cavalry guards kneeling behind her, ruined houses and refugees.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_tangji`

```
A horizontal story event illustration: a ruined temple: Lady Tang, an adult woman in coarse clothes with soot on her cheek, clutching a jade hairpin, looking up with unyielding eyes as the hero and Lady Wu find her.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_yazhai`

```
A horizontal story event illustration: a mountain bandit fort: the curvy bandit queen 'Rouge Tiger' standing hands on hips on the fort wall with twin sabers, pointing at the embarrassed hero, her chubby husband carrying a pig behind her (comedic).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_shengnv`

```
A horizontal story event illustration: a forest clearing: the Yellow Turban saint Zhang Ning, an adult woman in a yellow Taoist robe with a nine-section staff, handing out bowls of charm water to kneeling ragged followers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_yuxi`

```
A horizontal story event illustration: burning Luoyang at night: Sun Jian by a well holding up the glowing Imperial Jade Seal, his face lit by five-colored light, his eyes turning ambitious.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `i2_yuxi`

```
A horizontal story event illustration: night on a river boat: Sun Jian hugging a brocade box at the bow, Lady Wu standing at the cabin door holding a late-night snack.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `i2_duel`

```
A horizontal story event illustration: sunset riverbank: Dong Bai and Sun Ce collapsed on the ground laughing after a long duel, hammers and spear dropped beside them.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `i2_qin`

```
A horizontal story event illustration: night on the stern of a boat: Lady Tang playing a guqin, Lady Wu draping a coat over her shoulders.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

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
