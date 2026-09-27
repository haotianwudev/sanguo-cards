# pics/ —— 美术素材

```
pics/
  art.json          美术配置：每张头像用哪张图、脸在哪、多大（唯一需要手改的文件）
  ART-NEEDS.md      还缺哪些图（sanguo-art 自动生成）
  SOURCES.md        每张图的来源和协议（sanguo-art 自动生成）
  CARD-DESIGN.md    卡牌版式和美术规格
  source/           原图：只放原始文件，工具永远不改它们
    generals/       武将立绘（含主公 lord）
    soldiers/       兵卡立绘
    frames/         卡框（frame_bronze / silver / gold / ssr / wood / iron / other）
    public-domain/  维基共享资源下载的公有领域占位图（清代绣像等）
  processed/        工具从原图生成的中间图（可随时重新生成，删掉也没关系）
```

游戏实际使用的是缩小后的版本，在 `godot/data/portraits/`（头像）和 `godot/data/art/frames/`（抠成透明的卡框）。

## 常用操作

- **加 / 换一张立绘**：把原图放进 `source/generals/` 或 `source/soldiers/`，文件名用 key（卡牌 id 或人物 id，如 `huanggai.jpg`），
  在 `art.json` 里改那一行的 `src`、`face`、`head`，然后运行 `sanguo-art`。
- **换卡框**：放进 `source/frames/`（文件名 `frame_<名字>.jpg`），运行
  `python tools/key_frames.py pics/source/frames godot/data/art/frames`（自动抠掉棋盘格背景）。
- **原图注意**：`source/generals/sunce.jpg`、`zhouyu.jpg`、`sunjian.jpg` 的原图丢失了，现在是游戏里保留的 640px 版本；
  有高清原图直接替换同名文件即可。
