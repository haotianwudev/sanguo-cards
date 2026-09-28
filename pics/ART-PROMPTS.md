# 出图提示词

> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。
> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。
> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，
> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。

## 下一批（交给 Gemini）

按顺序画；交付后重跑本脚本，这一条会自动消失。

1. `muniu` — 木牛流马（汉代木制机巧独轮车）（宝物）
2. `beishui` — 破釜（古铜炊鼎战痕）（宝物）
3. `dingxin` — 定心丸（漆木药盒金箔丹药）（宝物）
4. `jubaopen` — 聚宝盆（汉代金铜博山纹宝盆）（宝物）
5. `chitu` — 赤兔马（赤兔金辔鞍饰）（宝物）
6. `zhangba` — 丈八蛇矛（张飞蛇形矛尖）（宝物）
7. `zhugenu` — 诸葛连弩（机关连弩箭匣）（宝物）
8. `qinglong` — 青龙偃月刀（关羽青龙偃月刀头）（宝物）
9. `mengde` — 孟德新书（曹操兵书竹简漆盒）（宝物）
10. `heishan` — 黑山令（张燕黑铁令牌）（宝物）
11. `taipingyaoshu` — 太平要术（张角黄绫天书符咒）（宝物）
12. `qingnang` — 青囊书（华佗青锦布囊医书）（宝物）
13. `huangjinfu` — 黄巾符（黄巾朱砂道符）（宝物）
14. `dilu` — 的卢（的卢白马铜辔鞍饰）（宝物）
15. `fangtian` — 方天画戟（吕布方天画戟头双月牙）（宝物）
16. `tengjia` — 藤甲（南蛮油浸老藤胸甲）（宝物）
17. `chenwu` — 陈武（R 弓兵）（立绘）
18. `jiangdong_gong` — 江东弓手（立绘）
19. `liehu` — 山中猎户（立绘）
20. `yuenv_gong` — 越女弓手（成年女性）（立绘）
21. `shanyue_nu` — 山越弩手（立绘）

交图规则：

- 每张图都用下面对应小节的**完整提示词**；图上长相/器物必须和设定对得上（见 `CARD-DESIGN.md` 第 7 节）。
- 宝物：纯中式汉代古风器物，独立透明背景（纯白背景抠图，无圆盘边框，无西式奇幻符号），日系战术卡牌 RPG 赛璐珞道具插画风。
- 女性角色一律画成成年人；董白不写年龄、不画成萝莉。
- 文件名 = key：宝物放 `pics/source/relics/<key>.png`（同时复制到 `godot/data/art/relics/<key>.png`），立绘放 `pics/source/generals/`（兵卡放 `soldiers/`）。
- 立绘在 `pics/art.json` 对应段登记；然后跑 `sanguo-art`，再跑 `python tools/art_prompts.py` 刷新本文件。
- **不要覆盖已经交付的图**；重画某张时旧图别留在 `pics/source/` 里（`backup_old/` 之类的文件夹不要提交）。
- 提交时按路径 `git add`，只提交自己的图和登记，别带上别人没提交的改动。

## 立绘（竖版 3:4）

### `chenwu` ⬜ 缺

```
A vertical character portrait of Chen Wu (陈武), a loyal Jiangdong general from Lujiang who followed Sun Ce.
Appearance: Sturdy, tanned man in his late 20s, square jaw, short beard, calm steady eyes of a marksman.
Armor & Clothing: Jiangdong red-and-brown lamellar armor, a quiver of red-fletched arrows on his back, a leather bracer.
Weapon: Drawing a large recurved war bow to full draw, arrow aimed past the viewer.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `jiangdong_gong` ⬜ 缺

```
A vertical character portrait of a Jiangdong archer (江东弓手), a common soldier of the Sun family's army.
Appearance: Young adult soldier with a sun-browned face and a focused squint, headband.
Armor & Clothing: Simple red Han tunic over light leather armor, straw sandals, quiver at the hip.
Weapon: Nocking an arrow on a plain wooden bow.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `liehu` ⬜ 缺

```
A vertical character portrait of a mountain hunter (山中猎户) from the hills around Fuchun who joined the army.
Appearance: Weathered, lean adult man in his 30s with a scruffy beard and a friendly grin.
Armor & Clothing: Fur vest over rough hemp clothes, a boar-tusk necklace, a pheasant hanging from his belt.
Weapon: A hunting bow slung ready, one arrow held between his fingers.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `yuenv_gong` ⬜ 缺

```
A vertical character portrait of a Yue woman archer (越女弓手), an adult woman of the southern Yue people serving as an archer.
Appearance: Adult woman in her 20s, confident sharp eyes, tanned skin, hair in a high braided ponytail with a red cord.
Armor & Clothing: Close-fitting indigo Yue-style tunic with embroidered hems and leather arm guards, short practical skirt over trousers.
Weapon: Drawing a slim bamboo bow, arrow at her cheek.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `shanyue_nu` ⬜ 缺

```
A vertical character portrait of a Shanyue crossbowman (山越弩手), a hill-tribe fighter from the mountains of Jiangdong.
Appearance: Stocky adult man with tattooed arms and cheeks, fierce stare, hair tied up with a bone pin.
Armor & Clothing: Rattan-and-hide armor, cloth leggings, bare feet planted on a rock.
Weapon: Aiming a heavy wooden crossbow braced against his shoulder.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `liubei` 🟡 换掉占位

```
A vertical character portrait of Liu Bei (刘备), the humble, earnest leader who calls himself a descendant of the Prince of Zhongshan.
Appearance: Gentle-faced man in his early 30s with notably large earlobes and long arms, kind sincere eyes, neat short beard, a slightly awkward, eager-to-please smile.
Armor & Clothing: Modest green-and-cream Han scholar-general robe over light leather armor, a simple topknot with a cloth band.
Weapon: Holding his twin swords (双股剑) a little clumsily in both hands, as if not quite sure how to use them.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `guanyu` 🟡 换掉占位

```
A vertical character portrait of Guan Yu (关羽), the dignified god of war of the Three Kingdoms era.
Appearance: Tall imposing man in his early 30s with a deep red face, phoenix eyes half-closed in calm pride, a magnificent long flowing black beard reaching his chest.
Armor & Clothing: Green war robe over Han dynasty lamellar armor, green headscarf, a heroic cape.
Weapon: Holding the Green Dragon Crescent Blade (青龙偃月刀 - a long glaive with a dragon-headed crescent blade) upright beside him.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `lvbu` 🟡 换掉占位

```
A vertical character portrait of Lü Bu (吕布), the unrivaled, terrifying warrior of the Three Kingdoms era.
Appearance: Tall, handsome, arrogant warrior in his early 30s with a cold predatory glare and a confident smirk, overwhelming aura.
Armor & Clothing: Ornate crimson and black armor with gold trim, a helmet crowned with two long pheasant tail feathers (雉尾冠), a red cape flaring behind him.
Weapon: Holding the Sky Piercer halberd (方天画戟 - a long halberd with a crescent side blade) across his shoulders.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `zhuzhi` ⬜ 缺

```
A vertical character portrait of Zhu Zhi (朱治), Sun Jian's shrewd quartermaster general.
Appearance: Sharp, composed man in his 30s with a neat mustache and an appraising look.
Armor & Clothing: Official's robe over light armor, a sword at his waist.
Weapon: Holding a supply list scroll in one hand and a writing brush in the other.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `wujing` ⬜ 缺

```
A vertical character portrait of Wu Jing (吴景), Lady Wu's protective younger brother.
Appearance: Handsome young general in his 20s whose features resemble his sister's, a suspicious, protective frown.
Armor & Clothing: Bright silver cavalry armor and a white cape.
Weapon: Riding a white horse, gripping the reins and glaring at the viewer.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `sunben` ⬜ 缺

```
A vertical character portrait of Sun Ben (孙贲), Sun Jian's competitive nephew.
Appearance: Young spear general in his 20s with a cocky smirk, arms crossed.
Armor & Clothing: Red and bronze Sun-clan armor.
Weapon: Hugging a spear against his shoulder, looking unimpressed.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `sunjing` ⬜ 缺

```
A vertical character portrait of Sun Jing (孙静), Sun Jian's stingy younger brother who keeps the family home.
Appearance: Thin older man in his 40s with squinting eyes and a thin mustache, a miserly expression.
Armor & Clothing: Plain grey household robe and a cap.
Weapon: Flicking the beads of an abacus, peering over it suspiciously.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `shanzei_bing` ⬜ 缺

```
A vertical character portrait of a one-eyed mountain bandit (山贼).
Appearance: Scruffy bandit with an eye patch and a gap-toothed leer.
Armor & Clothing: Ragged patched clothes, a rope belt.
Weapon: Carrying a big wood axe over his shoulder.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

### `inf_n` ⬜ 缺

```
A vertical character portrait of a Han dynasty government sword-and-shield soldier (官军刀兵).
Appearance: Disciplined, stern-faced soldier in his 20s.
Armor & Clothing: Standard Han army lamellar armor and helmet.
Weapon: Sword raised behind a round shield.
Composition & Framing: Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper third of the canvas, head fully visible with margin at the top.
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, plain off-white studio background with subtle warm lighting (clean, no battlefield clutter).
```

## 战斗 CG（横版 16:9，每场战斗一张）

### `boar`

```
A horizontal battle scene illustration: a huge wild boar charging out of a muddy forest clearing full of fallen logs in the hills of Jiangdong.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `shuizei_scout`

```
A horizontal battle scene illustration: river bandits leaping out of tall riverside reeds at a broken wooden fort gate, brandishing knives.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `shuizei`

```
A horizontal battle scene illustration: the river bandit chief 'River Dragon' Hu Yu with his twin daggers on the plank walkways of a river fortress over dark water.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `shuizei_guard`

```
A horizontal battle scene illustration: bandit gate guards at a river fortress, burning boats lighting up the river behind them.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `shuizei_main`

```
A horizontal battle scene illustration: the Yellow Turban commander He Yi on the deck of a great river fortress, Yellow Turban and bandit banners, fire ships on the water.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `yaodao`

```
A horizontal battle scene illustration: the Yellow Turban sorcerer Tang Zhou at a smoking altar in front of a fortress, paper talismans swirling, kneeling followers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `tiger`

```
A horizontal battle scene illustration: a giant white-browed tiger leaping from rocks on a mountain path among pine trees.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `yuji_xintu`

```
A horizontal battle scene illustration: fanatical cult followers surging out of a roadside shrine holding bowls of charm water.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `shanzei_band`

```
A horizontal battle scene illustration: mountain bandits blocking a winding mountain path below a fort wall with a tattered 替天行道 banner.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `yanzhihu`

```
A horizontal battle scene illustration: the bandit queen 'Rouge Tiger' with twin sabers in the great hall of her fort, decorated with red wedding silk.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `huangjin_remnant`

```
A horizontal battle scene illustration: Yellow Turban remnants rising up with farm tools in a smoky valley camp.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `guanjun`

```
A horizontal battle scene illustration: Han government soldiers storming the yard of a ruined temple.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `xiliang_youqi`

```
A horizontal battle scene illustration: Xiliang light cavalry galloping down a dusty Central Plains road.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `guosi`

```
A horizontal battle scene illustration: the raider general Guo Si on horseback in a plundered burning village.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `feixiong`

```
A horizontal battle scene illustration: Dong Zhuo's Flying Bear heavy cavalry in black armor lined up on an open plain.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `liru`

```
A horizontal battle scene illustration: the strategist Li Ru smiling from a cliff above a narrow gorge while ambushers spring out on both sides.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `huaxiong`

```
A horizontal battle scene illustration: the giant general Hua Xiong swinging his great blade on an open battlefield, a red headscarf lying in the dust.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `dongbai`

```
A horizontal battle scene illustration: Dong Bai, an adult woman general, leaping with two giant bronze hammers on a riverbank cratered by her blows.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `hulao_ch1`

```
A horizontal battle scene illustration: Lü Bu on the red horse Red Hare charging across a desolate plain at night, dust and moonlight.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `lijue`

```
A horizontal battle scene illustration: Li Jue with a torch in front of the burning gates of Luoyang, flames and smoke.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

### `xiliang_scout`

```
A horizontal battle scene illustration: Xiliang soldiers escorting a grain wagon convoy along a mountain foot road.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy and the action fill the upper half of the frame, the bottom third is calmer ground (game UI cards sit there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, dramatic battle lighting, like a Rance X battle CG; no text, no UI.
```

## 剧情插图 CG（横版 16:9）

### `c1_armor`

```
A horizontal story event illustration: Lady Wu fastening the straps of Sun Jian's old silver tiger-engraved armor on the hero, a fur-trimmed cape and a tiger pelt beside an opened camphor chest, Sun Ce gaping at the doorway, Zhou Yu with his ledger.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_zumao`

```
A horizontal story event illustration: a battlefield: the veteran Zu Mao wearing a red headscarf being chased by the giant Hua Xiong, the young Sun Ce charging in with a spear.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_capture`

```
A horizontal story event illustration: the hero carrying the unconscious woman general Dong Bai over his shoulder like a sack of rice, Sun Ce and Zhou Yu each struggling to carry one of her giant bronze hammers (comedic).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_captive`

```
A horizontal story event illustration: inside a prisoner tent: the woman general Dong Bai, an adult woman with her arms loosely tied, playing rock-paper-scissors against the hero, her hand a split second late, a half-eaten bowl of braised pork beside her, Sun Ce peeking in enviously through the tent flap (comedic).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_raid`

```
A horizontal story event illustration: a burning army camp at night: Sun Jian alone blocking the camp gate with his sword against Lü Bu on the red horse Red Hare.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_sanying`

```
A horizontal story event illustration: three heroes fighting Lü Bu: Liu Bei with twin swords, Guan Yu with the crescent blade and Zhang Fei with the snake spear circling Lü Bu, dust flying.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_fate`

```
A horizontal story event illustration: the woman general Dong Bai tied on a horse glaring defiantly at the hero, an envoy of Yuan Shao waiting beside them, tense.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_setout`

```
A horizontal story event illustration: setting off north on a country road: Sun Ce on a brown horse galloping ahead the wrong way, the hero on a white horse and Zhou Yu on a black horse exchanging a look, Lady Wu's carved carriage behind with a chest of ledgers tied on the back.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_jianhua`

```
A horizontal story event illustration: a battlefield: Sun Jian in a tiger-pelt cape beheading the giant Hua Xiong with one sweep of his saber, the fallen hero looking up at him, dust and blood spray (not gory).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_zumao_saved`

```
A horizontal story event illustration: the hero hurling a huge broad saber that strikes the giant Hua Xiong on the back of the head, Sun Ce charging in with a spear, the wounded veteran Zu Mao pulling off his red headscarf to hand it over.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_counter`

```
A horizontal story event illustration: Sun Jian's camp: the burly Sun Jian hugging Lady Wu while glaring at the hero over her shoulder, the veteran generals behind them trying not to laugh.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_borrow`

```
A horizontal story event illustration: outside Sun Jian's command tent: six Sun-clan generals in a row (a long-bearded elder with a snake spear, a silent archer on horseback, a scarred veteran with an iron whip, a quartermaster with a scroll, a young general on a white horse glaring, a smirking young spearman), Sun Jian with his back turned and arms folded.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_keep`

```
A horizontal story event illustration: inside a carved carriage: Lady Wu gently combing the hair of the captured woman general Dong Bai, who sits stiff-necked with reddened eyes, the hero peeking in at the curtain.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_handover`

```
A horizontal story event illustration: a restrained, somber scene: the woman general Dong Bai in a prisoner cart looking back over her shoulder, the hero standing alone at the camp gate, grey sky (no gore).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_triple`

```
A horizontal story event illustration: a lavish allied lords' banquet: warlords crowding around the hero with wine cups, Yuan Shao giving up his seat, Sun Jian clapping the hero on the shoulder, Lady Wu watching from the side.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_dongbai_join`

```
A horizontal story event illustration: a burning Luoyang street at night: the woman general Dong Bai striding toward the hero with her two giant bronze hammers, a line of Xiliang female cavalry guards kneeling behind her, ruined houses and refugees.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_tangji`

```
A horizontal story event illustration: a ruined temple: Lady Tang, an adult woman in coarse clothes with soot on her cheek, clutching a jade hairpin, looking up with unyielding eyes as the hero and Lady Wu find her.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_yazhai`

```
A horizontal story event illustration: a mountain bandit fort: the curvy bandit queen 'Rouge Tiger' standing hands on hips on the fort wall with twin sabers, pointing at the embarrassed hero, her chubby husband carrying a pig behind her (comedic).
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `e_shengnv`

```
A horizontal story event illustration: a forest clearing: the Yellow Turban saint Zhang Ning, an adult woman in a yellow Taoist robe with a nine-section staff, handing out bowls of charm water to kneeling ragged followers.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `c2_yuxi`

```
A horizontal story event illustration: burning Luoyang at night: Sun Jian by a well holding up the glowing Imperial Jade Seal, his face lit by five-colored light, his eyes turning ambitious.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `i2_yuxi`

```
A horizontal story event illustration: night on a river boat: Sun Jian hugging a brocade box at the bow, Lady Wu standing at the cabin door holding a late-night snack.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `i2_duel`

```
A horizontal story event illustration: sunset riverbank: Dong Bai and Sun Ce collapsed on the ground laughing after a long duel, hammers and spear dropped beside them.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
```

### `i2_qin`

```
A horizontal story event illustration: night on the stern of a boat: Lady Tang playing a guqin, Lady Wu draping a coat over her shoulders.
Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third less busy (dialogue text sits there).
Style: Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean ink outlines, rich vibrant colors, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.
(When the hero appears — the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), green tunic under silver armor, fur-trimmed cape, carrying Sun Jian's huge old broad-bladed saber over his shoulder.)
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
