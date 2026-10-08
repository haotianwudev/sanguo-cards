---
name: sanguo-art-ingest
description: Install finished art for 重开三国 (sanguo-cards) with one command — quality check, 16:9 crop, copy into pics/source, art.json entry, game build, log. Use whenever the user hands over image files (paths + names / "替换 cg", "这几张图实装"). Do NOT hand-edit art.json or regenerate the art docs per image.
---

Reply in Chinese. Run from `F:\workspace\sanguo-cards`.

**Inbox (the usual way):** the user drops images into `F:\workspace\sanguo-cards\pics\inbox\`, each named `<key>.png/jpg/webp`; run `python tools/art_ingest.py inbox`. Installed files move to `inbox/_done/`; refused ones stay (tell the user which and why; a file whose name isn't a known key says so — they rename it or you pass `--kind` via `add`).

**Portraits (立绘) work the same way** — name the file with the card / enemy / person id (`zhaoyun.png`, a soldier id…). A replacement keeps its existing framing; a brand-new portrait gets default framing and the log says so — look at the built `godot/data/portraits/<key>.jpg` and re-run `add <file> <key> --face X Y --head H` if the face is off-centre (face = face centre as fractions of width/height, head = head height / image height).

**One image:** `python tools/art_ingest.py add "<path>" <key>` — the key is the cg / battle / card id (kind is inferred — relic ids → relic (transparent PNG icon, copied to godot/data/art/relics); cards / enemies / portrait keys → portrait, scenario ids → battle, the rest of the story keys → cg; pass `--kind cg|battle|map|portrait` if it says it can't tell).
**Many:** write `<path> <key>` per line to a scratch file → `python tools/art_ingest.py batch list.txt`.

It checks quality (too small / blank = refused unless `--force`; blur / dark / odd shape = warning, still installed), crops cg / battle to 16:9 (chapter maps — ultra-wide 3200x1080 — are never cropped) (`--anchor top|bottom` keeps that side, e.g. faces near the top), keeps portraits' `face` / `head` framing (new portrait: pass `--face X Y --head H`, else defaults 0.5 0.22 / 0.22), builds the game copy, and appends one line to `pics/ART-LOG.md`.
Report only the ✓ / ✗ / ⚠ lines to the user (a ⚠ blurry / badly-cropped image is worth telling them about; offer `--force` / another crop for ✗).

**Do not** regenerate `ART-NEEDS.md` / `ART-PROMPTS.md` / `SOURCES.md` per image — that is the token cost. They are refreshed in one go by `python tools/art_ingest.py flush`, when `add` prints that 20 are waiting (or the user asks). `status` shows the count.
After a batch (only if asked): commit by path (`pics/source`, `pics/art.json`, `pics/ART-LOG.md`, `godot/data/art`, `godot/data/portraits`), pull --rebase --autostash, push.

**Art-only changes: no tests, no `--import`, no screenshots, no font rebuild** — just run the ingest command and report; commit/push only when asked.
