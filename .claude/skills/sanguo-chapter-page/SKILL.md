---
name: sanguo-chapter-page
description: Make one chapter's chapter-end page for 重开三国 (sanguo-cards) — a warm CG of that chapter's core people (all on the left, no hero), the same picture as a playable card, and the extra ？小故事 that hands the card over once the route's next bad end has been reached. Use when the user says to do the next chapter's page / 章末 CG / 过场卡 (「北线第一章」「下一章」「好的」 after one was shown).
---

# Chapter-end page: CG + card + gift story

Read `.claude/skills/sanguo-dev/SKILL.md` first (repo rules, commands). This skill is the per-chapter recipe for the
chapter-end page (`MapScreen._complete`). One chapter per request; show the result, wait for「好的」before the next.

## What one chapter gets (user rules)

1. **A CG** `rc_<quest>` (prologue is shared: `rc_fuchun` south, `rc_wuji` north). A **warm, quiet** scene of the chapter's
   main plot and core people. **The hero never appears.** Every person sits in the **left ~40%**, drawn **small and
   full-length** (about half the picture's height); the right 60% is empty scenery (water / sky / snow window) — the menu
   sits there with **no panel behind it**.
2. **A playable card** with the same id (cards.json, `pool: false`, `scope` = route). Its portrait is the CG's left part.
3. **A gift ？小故事** `s_rc_<quest>` in that chapter's `side_stories.json` list. It is the **only** way to get the card —
   never handed over on the page. It opens only once **the bad end that belongs to the card's people** has been reached
   (user rule: 董白's card waits for 结局三 · 同归, hers — not just the route's next one), and like every story costs 5 战功. Its CG is the page's picture.

The page itself (already built — don't redo): CG full screen; right side rows with only name + 战功, no reward text:
本章回顾 (free) → that chapter's ？小故事 (5) → 抽一次卡 (5) → 点化 (10) → 进入下一章. Rewards are never shown before
opening; after a story they flip in (`SideStoryList.reveal`).

## Steps

1. **Pick the people** (table below is the plan; the user may change it). Check the chapter's own text in
   `godot/data/story.json` for who is really there and what the warm moment could be. If someone only joins by a choice,
   both the page and the story need that line (`requires`, e.g. `董白：留下`). Children appear as their young portraits
   (`sunquan_young`, `sunshangxiang_young`, `zhenmi_young`).
2. **Generate the CG** (art-gen skill / `tools/art_gen.py`, nano-banana-2, refs = the people's portraits from
   `pics/source/generals/` or `pics/source/soldiers/`). Prompt pattern (Chinese):
   `16:9 横版章节过场插画，视觉小说 CG，兰斯10赛璐珞厚涂风格，精致清晰黑色墨线勾勒，<温暖的光>，温馨宁静。<地点、时间>，中景视角，人物是完整的全身、画得比较小。<N>个人物紧紧挨在一起，全部位于画面左侧 40% 的范围内，人物高度大约占画面高度的一半：<每个人：和参考图 <id> 一样：外貌、衣着、动作、表情>。<N>个人的脸都清楚可见。画面右侧 60% 没有任何人物：<空景>，色调柔和、细节简洁。画面里只有这<N>个人物，没有<主角/男子>。服装是汉代风格，交领右衽，不要旗袍、不要立领盘扣。不要文字、不要 UI。`
   Save the prompt to the scratchpad (it goes into `OVERRIDES_ZH` later).
3. **Self-check** (the user lets me approve CGs myself): faces match the refs, nobody extra, no hero, no text, Han
   clothes (the model drifts to qipao / 盘扣 — regenerate), and the **group's width ≤ ~0.43 of the picture** (that is all
   the card can show at full height). Regenerate on any miss.
4. **Ingest**:
   ```
   python tools/art_ingest.py add pics/inbox/rc_X.jpg rc_X --kind cg
   # card portrait = the CG's left part
   python -c "from PIL import Image; im=Image.open('pics/inbox/rc_X.jpg'); w,h=im.size; im.crop((0,0,int(w*0.62),h)).save('pics/inbox/rc_X_card.jpg',quality=95)"
   python tools/art_ingest.py add pics/inbox/rc_X_card.jpg rc_X --kind portrait --face <fx> 0.42 --head 0.24
   ```
   `--head 0.24` makes the card crop the full height (card framing is 4.2 heads); `fx` = the group's centre x in the
   *cropped* file as a fraction of its width (e.g. group at 0.13–0.55 of the CG, crop 0.6 wide → fx = 0.34/0.6 ≈ 0.57).
   To re-frame later without redrawing: re-run the portrait add with `--force` and new `--face` (that is what fixed
   富春 when 孙权 was cut off).
5. **Card** in `godot/data/cards.json` (before `"zhangfuren"` is fine): name `<地名>·<一句>` (富春·慈母与儿女,
   无极·商母与幼女, 汜水·董白的剪刀), SR, troop / stats / skills from the lead person's own card (their signature skill;
   a second person's skill if two leads), `pool: false`, `scope`.
6. **Page entry** in `side_stories.json` → `chapters`: `"<quest>": [{"cg": "rc_X", "requires": ... / "unless": ...}]`
   (prologue uses `unless 出生：冀州无极` / `requires 出生：冀州无极` to split routes).
7. **Gift story** at the top of that chapter's `after` list: `{"id": "s_rc_X", "title", "portraits", "requires":
   [<the chapter's people line if any>, "<their bad end>"], "unless": <the other route's birth line if needed>,
   "reward": {"cards": ["rc_X"]}, "cg": "rc_X", "text": [...]}`. Shape used so far: the hero, in a new 周目, **dreams
   of that bad end** (an object from its ending CG — the broken seal, the doll in the puddle, the hammers in the snow); wakes; finds exactly the
   page's scene; **stands at the door / behind a tree and doesn't go in** — he wants to remember it (why he isn't in the
   picture); someone notices him and calls him over. Tie a line back to that chapter's small stories where it fits
   (甄宓's 37 pieces of candy). Keep 12–19 lines.
8. **Prompts**: add the label `"rc_X": "<线>第N章·章末（过场 CG，也是卡）"` and `OVERRIDES_ZH["rc_X"] = <prompt>` in
   `tools/art_prompts_zh.py`, and a one-line description in `tools/art_prompts.py` (next to the other `rc_*`).
9. **Test** in `godot/tests/test_quests.gd`: page cg for the route, story closed before the bad end, open after, opening
   hands over the card. Run `--import` once (new art) then the suite.
10. **Look**: `--demo=recap1` (south ch1) / `--demo=recap1 --north` / `--demo=recap` (south ch2) for the page —
    add a demo for a new chapter if needed — and `--demo=cards:rc_X,<lead>` for the card. Open both screenshots for the
    user (`start "" <png>`).
11. `python tools/art_ingest.py flush`, update the "Done so far" line in sanguo-dev's Chapter-end page bullet, commit by
    path (the pre-commit hook regenerates docs/CHAPTER-STATS / ROSTER / chapters — add them; if `index.lock` exists,
    wait and retry), push, build the APK.

## Which bad end opens the gift story

Look the card's people up in `godot/data/endings.json` (`who`): if one of them has a bad end of their own, use that
(吴夫人 → 玉碎, 张夫人 → 覆巢, 董白 → 同归, 吕玲绮 → 绝罚, 张宁 → 覆巢 / 失律, 二乔 → 深锁, 杜夫人 → 断桥, 孙策 → 匹夫,
赵云 / 糜贞 → 枯井, 周瑜 / 小乔 → 曲误, 郭嘉 / 郭照 → 遗策, 孙尚香 → 香烬, 马云騄 → 断弦, 吴苋 → 算尽, 甄宓 → 洛殇,
吕布 → 虎噬 …). Only when nobody on the card has one, fall back to the route's next bad end (table).

| 南线 | gift opens after | 北线 | gift opens after |
|---|---|---|---|
| 1 富春 | 结局一 · 玉碎 | 1 冀州风云 | 结局二 · 覆巢 |
| 2 讨伐董卓 | 结局一 · 玉碎（董白的卡用 同归） | 2 洛阳烟云 | 结局二 · 覆巢 |
| 3 传国玉玺 | 结局三 · 同归 | 3 黑山风云 | 结局四 · 绝罚 |
| 4 挟天子 | 结局五 · 恨海 | 4 双凤乱太行 | 结局六 · 失律 |
| 5 荆襄风云 | 结局七 · 深锁 | 5 铁纪徐州 | 结局八 · 断桥 |
| 6 淮南（南） | 结局九 · 匹夫 | 6 淮南（北） | 结局十 · 枯井 |
| 7 江东小霸王 | 结局十一 · 曲误 | 7 邺城惊雷 | 结局十二 · 遗策 |
| 8 猛虎之陨 | 结局十三 · 香烬 | 8 北海龙虎 | 结局十四 · 断弦 |
| 9 天府之国 | 结局十五 · 算尽 | 9 西凉喋血 | 结局十六 · 洛殇 |
| 10 奇袭关中 | 结局十七 · 虎噬 | 10 再战虎牢 | 结局十八 · 烛灭 |
| 11 洛阳天倾 | 结局十七 · 虎噬 | 11 洛阳天倾 | 结局十八 · 烛灭 |

Endings live in `godot/data/endings.json`; their titles are the flag lines (kept across 周目).

## Who is on each page

Done: 南1 `rc_fuchun` 吴夫人、孙权、孙尚香 (sewing on the 富春 porch) · 北1 `rc_wuji` 张夫人、小甄宓 (abacus, snowy
night) · 南2 `rc_taodong` 董白 + 宫女 (石头剪刀布 by the river; needs 董白：留下; gift after 结局三 · 同归, her own; dream = the 长安 snow outside the gate, her hammers and a broken-stringed 琴). · 南3 `rc_yuxi` 蔡文姬 teaching 董白 to write her name under the peach blossoms (page needs 董白：留下 + 结局一 · 玉碎 = 蔡文姬 joined; gift also 结局三 · 同归, hers). · 南4 `rc_dongui` dawn after fleeing 长安: 小皇帝 asleep on 董白's shoulder, 貂蝉 laughing on the cart shaft (page needs 结局三 · 同归 = 貂蝉 joined + 董白：留下; gift also 结局五 · 恨海, 貂蝉's). · 南5 `rc_jingxiang` 貂蝉 in the light 留仙裙 laughing on a rock while 孙策 falls in the 淯水 with a carp (page needs 结局三 · 同归; gift also 结局五 · 恨海; story: he buys her the 糖炒栗子 she never bought). · 北2 `rc_luoyang_n` 吕玲绮 practising twig chopsticks on a stone, 小甄宓 correcting her grip (甄府 back porch, autumn moon; gift after 结局四 · 绝罚, hers; dream = the fallen 斑马旗 and her 画戟 in the 太行 snow; demo `--demo=recap --north`). · 北3 `rc_heishan` 张宁 and 小甄宓 pushing an iron 药碾 together in the 甄府 herb room at sunset (page needs 张宁：救下; gift after 结局六 · 失律 — not 覆巢, which is what lets her join; dream = the 下邳 back hall, her golden needles in the blood, the 太平 pendant; demo `--demo=recap --north --heishan`).

Plan for the rest (check each against the chapter text; ask only if the chapter has no obvious warm pair):
北4 郑好、姜巧 cooking breakfast, 太史慈 ·
北5 甄宓 and 赵云 sharing a 徐州 烧饼 · 南6 大乔、小乔 before the double wedding · 北6 杜夫人 brewing, 郭嘉 sniffing ·
南7 孙策 and 大乔 · 北7 赵云 and 糜贞 · 南8 吴夫人 with grown 孙权、孙尚香 (an echo of 南1) · 北8 郭嘉 and 郭照 ·
南9 祝融、孟获 · 北9 马超、马云騄、马岱 by the horses · 南10 吴苋 · 北10 grown 甄宓 cooking for the army, 庞统 ·
南11 吕布 teaching 董白 to ride · 北11 关羽、张飞 (the beard bag).
Chapter 12 ends in an ending — no page.
