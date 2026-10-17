# 第三章 · 黑山风云（`heishan`，北线）

> `python tools/chapter_docs.py` 自动生成，别手改。改剧情去改 `godot/data/story.json`。

## 概要

| 项 | 内容 |
|---|---|
| 开启条件 | 北线：班师冀州 |
| 副标题 | 初平元年夏 |
| 格数 / 列数 | 64 / 42（x 0–41） |
| 战斗 普通 / 精英 / 首领 | 18 / 4 / 3 |
| ？ 格 | 13 |
| CG 已有 / 合计 | 19 / 19 |
| 招贤池 | 严纲、邹丹 |
| 兵池 / 兵卡范围 | — / north |
| 事件范围 | north + 本章专属 |
| 洗牌组 | hs_m2、hs_bandit0；hs_em2、hs_pursuit0a |
| 结局 | 结局六 · 覆巢 |

## 地图（按列）

| x | y | 格子 | 类型 | 名字 | 条件 | 下一格 | 给什么 |
|---:|---:|---|---|---|---|---|---|
| 0 | 1 | `hs_start` | 剧情 | 真定发榜 | — | hs_bandit0、hs_m2 | — |
| 1 | 0 | `hs_bandit0` | 战斗·普通 | 城外·地痞 | — | hs_bandit1 | — |
| 1 | 2 | `hs_m2` | ？ | 小路 | — | hs_m4 | — |
| 2 | 0 | `hs_bandit1` | 战斗·普通 | 真定蟊贼 | — | hs_m6 | — |
| 2 | 2 | `hs_m4` | 宝箱 | 行商遗落 | — | hs_m6 | — |
| 3 | 1 | `hs_m6` | ？ | ？ | — | hs_xiahoulan_pre | — |
| 4 | 1 | `hs_xiahoulan_pre` | 剧情 | 兵痞惹事 | — | hs_xiahoulan_choice | — |
| 5 | 1 | `hs_xiahoulan_choice` | 选择 | 军法？ | — | →hs_junfa（请他执掌军法）、→hs_peiqian（赔钱了事） | — |
| 6 | 0 | `hs_junfa` | 剧情 | 军法如山 | — | hs_junfa_c | 入队 「铁面军法」夏侯兰；记「军纪：严明」 |
| 6 | 2 | `hs_peiqian` | 剧情 | 和稀泥 | — | hs_peiqian_c | 记「夏侯兰：打发」 |
| 7 | 0 | `hs_junfa_c` | ？ | ？ | — | hs_mountain_start | — |
| 7 | 2 | `hs_peiqian_c` | ？ | ？ | — | hs_mountain_start | — |
| 8 | 1 | `hs_mountain_start` | ？ | 进山 | — | hs_tm3、hs_tm2 | — |
| 9 | 0 | `hs_tm3` | 战斗·普通 | 太行黄巾 | — | hs_tm3b | — |
| 9 | 2 | `hs_tm2` | ？ | ？ | — | hs_tm4 | — |
| 10 | 0 | `hs_tm3b` | 战斗·普通 | 山道·黄巾游哨 | — | hs_tm7 | — |
| 10 | 2 | `hs_tm4` | 宝箱 | 采药人的行囊 | — | hs_tm7 | — |
| 11 | 1 | `hs_tm7` | ？ | ？ | — | hs_encounter | — |
| 12 | 1 | `hs_encounter` | 剧情 | 深山绝壁 | — | hs_save_choice | — |
| 13 | 1 | `hs_save_choice` | 选择 | 救人？ | — | →hs_save_fight（拔刀相助）、→hs_ignore（绕道避险） | — |
| 14 | 0 | `hs_save_fight` | 战斗·精英 | 战白骑 | — | hs_zhangyan | — |
| 14 | 2 | `hs_ignore` | 剧情 | 明哲保身 | — | hs_bad_return | 记「张宁：没救」 |
| 15 | 0 | `hs_zhangyan` | 剧情 | 黑山大寨 | — | hs_rest1 | 入队 张宁·医仙；记「张宁：救下」 |
| 15 | 2 | `hs_bad_return` | 剧情 | 空手而归 | 要：张宁：没救 | hs_bad_skip | — |
| 16 | 1 | `hs_rest1` | 休整 | 山寨休整 | — | hs_hm1、hs_hm2 | — |
| 16 | 2 | `hs_bad_skip` | 剧情 | 一年后 | 要：张宁：没救 | hs_bad_wall | — |
| 17 | 0 | `hs_hm1` | 战斗·普通 | 内营·巡哨 | — | hs_hm1b | — |
| 17 | 2 | `hs_bad_wall` | 战斗·普通 | 无极城头 | 要：张宁：没救 | hs_bad_gate | — |
| 17 | 2 | `hs_hm2` | ？ | 寨中集市 | 除非：张宁：没救 | hs_hm_camp | — |
| 18 | 0 | `hs_hm1b` | 战斗·普通 | 演武场·切磋 | — | hs_yudu | — |
| 18 | 2 | `hs_bad_gate` | 战斗·普通 | 府门·冀州步卒 | 要：张宁：没救 | hs_bad_street | — |
| 18 | 2 | `hs_hm_camp` | 招募 | 寨中招兵 | 除非：张宁：没救 | hs_yudu | — |
| 19 | 1 | `hs_yudu` | 战斗·精英 | 叛党于毒 | — | hs_alliance | — |
| 19 | 2 | `hs_bad_street` | 战斗·普通 | 街巷·冀州轻骑 | 要：张宁：没救 | hs_bad_night | — |
| 20 | 1 | `hs_alliance` | 剧情 | 黑山令 | — | hs_rest2 | 记「黑山：结盟」 |
| 20 | 2 | `hs_bad_night` | 剧情 | 最后一夜 | 要：张宁：没救 | hs_bad_hall | — |
| 21 | 1 | `hs_rest2` | 休整 | 大寨夜话 | — | hs_timeskip | — |
| 21 | 2 | `hs_bad_hall` | 战斗·首领 | 中庭·淳于琼 | 要：张宁：没救 | hs_bad_guotu、输→hs_bad_guotu | — |
| 22 | 1 | `hs_timeskip` | 剧情 | 郭图寻仇 | — | hs_escape | — |
| 22 | 2 | `hs_bad_guotu` | 战斗·首领 | 郭图亲临 | 要：张宁：没救 | hs_bad_end、输→hs_bad_end | — |
| 23 | 1 | `hs_escape` | 剧情 | 黑山秘道 | — | hs_breakout | 记「郭图：扑空」 |
| 23 | 2 | `hs_bad_end` | 剧情 | 覆巢 | 要：张宁：没救 | （终点） | 记「结局六 · 覆巢」 |
| 24 | 1 | `hs_breakout` | 战斗·普通 | 府门突围 | — | hs_guotu_fight | — |
| 25 | 1 | `hs_guotu_fight` | 战斗·精英 | 郭图拦街 | — | hs_em1 | — |
| 26 | 1 | `hs_em1` | ？ | 峡谷 | — | hs_pursuit0a、hs_em2 | — |
| 27 | 0 | `hs_pursuit0a` | 战斗·普通 | 冀州步卒·前队 | — | hs_pursuit0 | — |
| 27 | 2 | `hs_em2` | ？ | ？ | — | hs_em2b | — |
| 28 | 0 | `hs_pursuit0` | 战斗·普通 | 冀州大枪阵 | — | hs_pursuit1 | — |
| 28 | 2 | `hs_em2b` | 宝箱 | 弃置辎重 | — | hs_pursuit1 | — |
| 29 | 1 | `hs_pursuit1` | 战斗·普通 | 冀州轻骑 | — | hs_pursuit2 | — |
| 30 | 1 | `hs_pursuit2` | 战斗·普通 | 冀州强弩 | — | hs_em4 | — |
| 31 | 1 | `hs_em4` | ？ | ？ | — | hs_chunyuqiong | — |
| 32 | 1 | `hs_chunyuqiong` | 战斗·普通 | 太行山口 | — | hs_jieqiao_eve | — |
| 33 | 1 | `hs_jieqiao_eve` | 剧情 | 界桥前夜 | — | hs_jieqiao_scout、hs_jm1 | — |
| 34 | 0 | `hs_jieqiao_scout` | 战斗·普通 | 外围游骑 | — | hs_jieqiao_scout2 | — |
| 34 | 2 | `hs_jm1` | ？ | 界桥外围 | — | hs_jm_loot | — |
| 35 | 0 | `hs_jieqiao_scout2` | 战斗·普通 | 游骑·后队 | — | hs_jieqiao_archers | — |
| 35 | 2 | `hs_jm_loot` | 宝箱 | 弃营辎重 | — | hs_jieqiao_archers | — |
| 36 | 1 | `hs_jieqiao_archers` | 战斗·普通 | 冀州弓手 | — | hs_jm4 | — |
| 37 | 1 | `hs_jm4` | ？ | ？ | — | hs_rest3 | — |
| 38 | 1 | `hs_rest3` | 休整 | 战前休整 | — | hs_quyi | — |
| 39 | 1 | `hs_quyi` | 战斗·精英 | 先登死士 | — | hs_wenchou | — |
| 40 | 1 | `hs_wenchou` | 战斗·首领 | 猛将文丑 | — | hs_end | — |
| 41 | 1 | `hs_end` | 剧情 | 斑马大旗 | — | （终点） | 入队 先登死士；记「界桥：救下公孙瓒」 |

## 剧本（按地图顺序）

### x0 · 剧情「真定发榜」`hs_start`

- 回到常山真定，主角拿着做赞助商赚来的家底，正式开始招兵买马。

### x4 · 剧情「兵痞惹事」`hs_xiahoulan_pre`

- 手底下新招的兵痞抢了乡亲的鸡，赵云的发小夏侯兰站出来执法，要按军法行刑。

### x5 · 选择「军法？」`hs_xiahoulan_choice`

- **选项**「请他执掌军法」→ `hs_junfa`（要：结局八 · 失律）
- **选项**「赔钱了事」→ `hs_peiqian`

### x6 · 剧情「军法如山」`hs_junfa`

- 「军中律令，擅掠百姓禽畜者，按律当笞五十，削籍充苦役！」
- 夏侯兰面冷如铁，重重一脚将抢鸡的兵痞踩在尘土里，高举戒尺便要施刑。被抢的老农紧紧搂着芦花鸡，在一旁看得目瞪口呆。
- {lord}尴尬地挠了挠头，拱手陪笑道：「执法严明，理当如此！还请夏侯兄手下留情，饶他一条狗命，往后这营中军纪，便全托付给夏侯兄了！」
- 夏侯兰收尺抱拳：「诺！既蒙主公信任，兰愿为主公肃正军纪，令行禁止！」

### x6 · 剧情「和稀泥」`hs_peiqian`

立绘：「铁面军法」夏侯兰

- 老农死死护着怀里瑟瑟发抖的母鸡，抹着眼泪敢怒不敢言。
- {lord}擦了擦冷汗，摸出沉甸甸的几串铜钱塞过去：「老丈受惊了！这鸡钱加倍赔您，算我账上！」
- 抢鸡的兵痞肩头还扎着两根鸡毛，叉着腰得意咧嘴笑，全无惧色。
- 夏侯兰在远处大树下冷眼看着，摇了摇头，抱枪转身离去。
- （你掏钱平了事，把夏侯兰打发走了。然而队伍里的兵痞习气渐长，为日后埋下了隐患……）

### x12 · 剧情「深山绝壁」`hs_encounter`

立绘：张宁·医仙、zhangbaiqi

- 太行万丈绝壁之上，冷风猎猎，退路已被数十名黄巾狂徒彻底堵死。
- 一袭素白衣衫的少女背着采药竹篓，指间冷冷扣着三枚金针，立在悬崖边缘，毫无惧色。
- 为首的贼首张狂大笑，提着大刀指着她：「张宁！天师已死，黄天大势已去，你这太平道圣女还往哪儿逃？乖乖随老子回山寨！」
- 赵云一眼认了出来，勒住白马低声道：「主公，带头的是黑山黄巾渠帅张白骑！那姑娘危在旦夕！」

### x13 · 选择「救人？」`hs_save_choice`

- **选项**「拔刀相助」→ `hs_save_fight`（要：结局六 · 覆巢）
- **选项**「绕道避险」→ `hs_ignore`

### x14 · 战斗「战白骑」`hs_save_fight`

- 赵云长枪一闪：「主公，是那个张白骑！」
- {lord}拔刀：「连看病的大夫都抢，砍了他！」

### x14 · 剧情「明哲保身」`hs_ignore`

- 前路尚远，甄家的商队与全军身家压在肩头，你咬了咬牙，下令队伍悄悄后撤。
- {lord}握紧了手中的战枪，最后回望了一眼山谷深处，眼神中满是挣扎。
- 层层雾气弥漫的绝壁下，那抹素白的身影已被密密麻麻的黄巾狂徒彻底吞没。
- （你狠心避开了这场险境，退出了太行绝壁。然而乱世的因果，终究不会轻易放过任何人……）

### x15 · 剧情「黑山大寨」`hs_zhangyan`

立绘：张宁·医仙、张燕

- 素衣少女熟练地取出金针草药为负伤乡勇止血，向你敛衽一礼：「多谢仗义相救。小女子张宁……家父正是昔日大贤良师张角。」
- 话音未落，绝壁之上一声长啸！一道矫健如灵猫的身影自数十丈峭壁上凌空跃下，稳稳落在众人面前，腰间短刃泛着幽光。
- 四周千峰万壑之上，顷刻间亮起漫山遍野的猩红火把，数十万黑山军森然林立，声势震动太行！
- 那精悍汉子抱拳朗笑道：「在下黑山张燕！听闻常山出了位少年英雄，今日一见名不虚传！这黑山绝顶大寨，可敢去喝碗烈酒？」

### x15 · 剧情「空手而归」`hs_bad_return`

*要：张宁：没救*

立绘：张夫人、赵云·青年、郭嘉·青年

- 几天后你们空手回了无极。商队的粮一斗没少，可张夫人清点车队时，目光在队尾停了一下——那里本该有一个背竹篓的白衣姑娘。她什么也没问，只把账本合上了。
- 赵云一路没说话。郭嘉的酒葫芦，半个月没有打开过。
- {lord}（内心）：我没拔刀。不是不能，是算过——救她，要赔上半个商队，还要得罪黑山。算得清清楚楚，所以才睡不着。
- 太行山里的黑山军、黄巾旧部，从此没有一个人欠你们的情，也没有一个人，会在你们落难时多看你们一眼。

### x16 · 剧情「一年后」`hs_bad_skip`

*要：张宁：没救*

立绘：guotu

- 【初平二年 · 冬】一年后，韩馥让出冀州，袁绍入主邺城。
- 郭图得了势，头一件事就是翻旧账。当年在邺城州衙，他当着灾民的面被赵云落了面皮，这口气咽了整整一年；更要紧的是，甄家那万石粮仓和三条商路，他早就惦记了两年。
- 他递上一份奏本，说甄家「私通黑山匪类」——证据是甄家商队三次出入太行。袁绍连看都没看，盖了印：「查抄。」抄来的粮和银子，三成进了袁绍的军库，七成，进了郭图自己的腰包。
- 郭图亲自提兵，直扑无极。
- {lord}站在城头，看着远处滚滚而来的冀州旗号，忽然想起太行绝壁上那声冷笑。如果当初救下了那个姑娘，黑山的人，大约会替你们挡一阵。可你们谁也没去求过。

### x17 · 战斗「无极城头」`hs_bad_wall`

*要：张宁：没救*

- 冀州的强弩手在城下列成一排，弩箭一轮接一轮压上城头，垛口的砖石被射得火星四溅。
- 赵云：「主公，守不住城头也要守住一刻——让夫人和小姐先退进内院！」

### x18 · 战斗「府门·冀州步卒」`hs_bad_gate`

*要：张宁：没救*

- 强弩压住了城头，冀州步卒趁势抬着擂木撞向甄府的朱漆大门，每一下都震得门楣落灰。
- 家丁们用肩膀死死顶着门板，一个接一个倒下，又被另一个顶上去。

### x19 · 战斗「叛党于毒」`hs_yudu`

- 大寨中突生异变，黑山叛党于毒突然发难，企图挟持张燕！
- 「既然拿了你们的茶水，这活我们接了！」主角拔刀迎战于毒。

### x19 · 战斗「街巷·冀州轻骑」`hs_bad_street`

*要：张宁：没救*

- 府门终于被撞开，冀州轻骑从缺口一拥而入，在甄府的街巷里纵马砍杀，火把一路点着了屋檐。
- {lord}提枪迎了上去：「想进内院，先从我身上踏过去！」

### x20 · 剧情「黑山令」`hs_alliance`

- 帮张燕平定了叛乱，张燕递给你一面令牌：「黑山百万之众，欠你一个人情。以后太行山，就是你的后院！」

### x20 · 剧情「最后一夜」`hs_bad_night`

*要：张宁：没救*

立绘：张夫人、zhenmi_young、郭嘉·青年、赵云·青年

- 后半夜，冀州兵暂时退到了街口，等着天亮再攻。中庭里点着几盏残灯，到处是血与断了的兵刃。
- 张夫人把家里最后的人都叫到了身边，一个一个点了名，像平日里核账那样。她看着{lord}，很平静：「是我让你们南下会盟的，这笔账，算我头上。」
- 甄宓抓着她的衣袖：「娘，我不走！」张夫人替她把散开的头发抿到耳后，笑了笑：「傻丫头，娘什么时候让你吃过亏？」
- 郭嘉晃着空空的酒葫芦，苦笑：「大哥，今晚是走不掉了。太行那道门，是咱们自己关上的。」
- 赵云把枪横在膝上，一遍一遍擦着枪头：「主公，天亮之前，我送小姐出去。」
- {lord}（内心）：我算过很多账。唯独没算过，有些人，是用钱买不回来的。

### x21 · 战斗「中庭·淳于琼」`hs_bad_hall`

*要：张宁：没救*

- 天蒙蒙亮，冀州大将淳于琼提着重戟踏进中庭，身后是郭图的大旗。
- 「奉袁公令，甄家私通匪类，格杀勿论！」
- {lord}握紧了战枪：「想杀人，先问问我手里的枪。」

### x22 · 剧情「郭图寻仇」`hs_timeskip`

立绘：guotu

- 【初平二年·冬】一年后，韩馥让出冀州，袁绍入主邺城。
- 郭图得势猖狂，向袁绍进谗言诬陷甄家「私通黑山匪类」——实则眼馋甄家的万石粮仓与三条商路，顺手还要报当年被赵云落了面皮的私仇，亲自提兵直扑无极！
- 沉重的擂木轰然撞开朱漆府门，木屑横飞，府内仆役惊恐万状。
- 郭图端坐马上，轻摇羽扇阴冷嗤笑：「当年在城头落某面皮，今日便叫你甄家上下插翅难飞！」

### x22 · 战斗「郭图亲临」`hs_bad_guotu`

*要：张宁：没救*

立绘：guotu

- 淳于琼倒下的时候，郭图才摇着羽扇，不紧不慢地踱进甄府大门，一脚踩在门槛上，打量着满院的狼藉，像是在清点战利品。
- @guotu 「甄夫人，别来无恙？你们甄家的万石粮仓，三条商路，账本我都替你收着了——你只管安心上路。」
- {lord}拄着断了一半的枪站起来，一口血啐在青砖上：「你要的是钱，不是公道。」
- 郭图笑了：「公道？公道是袁公的，钱，是我的。」

### x23 · 剧情「黑山秘道」`hs_escape`

立绘：张夫人、zhenmi_young

- 烈焰撕裂夜空，无极城内火光冲天。郭图率大军猛攻甄府，城内危在旦夕！
- 危急关头，{lord}出示黑山令，张燕早已遣精锐黑山卫士备下太行秘道接应。
- 昏暗石径两侧，黑山甲士高举火把，张夫人紧紧牵着年幼的甄宓撤入漆黑洞口。
- 甄宓怀抱布偶，回望远处被大火吞没的无极家园，眼眶泛红：「娘亲，兄长他们……还能赶上来么？」
- 张夫人强忍悲痛，柔声宽慰：「莫怕，宓儿。有{lord}与子龙将军断后，定能安然杀出重围！」

### x23 · 剧情「覆巢」`hs_bad_end`

*要：张宁：没救*

- 你外无援军，内无险可守。赵云带着甄宓从后墙杀了出去，冀州的箭追着他们的白马，没有人知道他们最后逃到了哪里。
- 你力战到枪折，倒在中庭的台阶上，血把青砖染成了暗红色。
- 张夫人没有走。她站在正堂前，把那本账本抱在怀里，对着满院的冀州兵说：「甄家的账，一笔一笔，都清清楚楚。」
- 乱箭射来的时候，她回头往后墙的方向看了一眼，像是在确认什么，然后才慢慢倒下。
- 无极城头的火烧了三天三夜。

### x24 · 战斗「府门突围」`hs_breakout`

- 烈焰焚天，甄府大门轰然坍塌！郭图的冀州大军已四面合围，弩箭如蝗！
- {lord}跨上白马，手中长枪化作惊雷匹练，凌空挑飞迎面扑来的强弩甲士：「弟兄们，随我冲锋，杀出一条血路！」

### x25 · 战斗「郭图拦街」`hs_guotu_fight`

立绘：guotu、赵云·青年

- 刚杀出府门，郭图亲自策马拦在街口，身后是整队的督战弩手，火把把他那张刻薄的脸照得发亮。
- @guotu 「甄家私通匪类，粮仓、商路、账本，一件都不许带走！」他的目光越过你们，落在身后那几十辆粮车上，贪婪得毫不掩饰。
- 赵云勒住白马，冷冷一笑：「当年在州衙，我的枪没有出鞘。今天，出鞘了。」
- {lord}（内心）：原来这位「督粮官」，督的是自己的腰包。这回，不用再忍了。

### x28 · 战斗「冀州大枪阵」`hs_pursuit0`

- 刚刚钻进太行秘道，一队手持长枪的冀州兵死死咬了上来，在狭窄的山道里摆开了无法闪避的枪阵。

### x29 · 战斗「冀州轻骑」`hs_pursuit1`

- 一队冀州轻骑咬上了队尾。吕玲绮提着画戟跳下马车：「我来断后！」

### x30 · 战斗「冀州强弩」`hs_pursuit2`

- 漫天弩箭射来。赵云拨落箭雨：「主公先走！」

### x32 · 战斗「太行山口」`hs_chunyuqiong`

- 淳于琼带着冀州重兵在山口堵住了去路：「留下甄家家财，饶你们不死！」

### x33 · 剧情「界桥前夜」`hs_jieqiao_eve`

立绘：郭嘉·青年、赵云·青年、张燕

- 【初平三年·春】浴血杀出太行山口，队伍终得喘息。然而前哨飞马急报，袁绍与公孙瓒数十万大军已在界桥陈兵对峙！
- 深夜军帐之内，烛火摇曳。郭嘉手执青铜酒樽，慢条斯理地提着马鞭指向铺展在帅案上的行军舆图。
- 郭嘉微抿烈酒，唇角勾起一抹玩味的笑意：「袁绍势大，公孙瓒暴烈，两边虽非善类……但公孙伯珪若是败亡，袁本初下一步便要踏平太行。」
- 赵云按枪沉吟，张燕抱臂冷笑。郭嘉马鞭在界桥渡口重重一点：「这一局界桥死斗，合该由咱们去掀了棋盘！」

### x34 · 战斗「外围游骑」`hs_jieqiao_scout`

- 界桥外围，袁绍的游骑兵正在四处清剿公孙瓒的散兵游勇。

### x36 · 战斗「冀州弓手」`hs_jieqiao_archers`

- 外围的冀州弓弩手发现了你们的踪迹。

### x39 · 战斗「先登死士」`hs_quyi`

- 界桥前，袁绍先锋麹义带着八百「先登死士」，硬生生把白马义从冲垮了！
- 「顶住那面大盾！」主角从侧翼杀出，直取麹义。

### x40 · 战斗「猛将文丑」`hs_wenchou`

- 麹义退下，袁绍麾下猛将文丑拍马狂追而来！
- 赵云白马银枪独战文丑，主角和吕玲绮打出黑白斑马大旗，引铁骑穿插！

### x41 · 剧情「斑马大旗」`hs_end`

- 文丑败退，麹义的八百先登死士被打散。界桥的河滩上，到处是折断的长戟和丢下的大盾。
- 公孙瓒被亲兵扶下马，惊魂未定地攥住你的手：「若不是你们，伯珪今天就交代在这座桥上了！」
- 公孙瓒：「这份情，我记下了！五百匹幽州白马，你拿去！」
- {lord}（内心）：公孙瓒……「早晚被袁绍困死自焚」，那是以后的事。今天先收他的马。
- 几十个不肯退走的先登老兵放下了盾，朝{lord}单膝跪下：「麹将军不要我们了，您收下吧。」
- 郭嘉晃着酒葫芦凑过来：「主公，这一仗，袁本初的先锋断了，猛将也伤了。他不会忘的。」
- {lord}：「所以我们不在这儿等。……回太行，把山门扎紧，让他自己来啃。」
- 赵云点头，把长枪从河滩里拔了出来。
- 黑白斑马大旗在界桥的风里展开，一路向北，往太行去了。

## 战斗

| 格子 | 名字 | 档 | 敌人 | 回合 | 掉落 | 背景图 |
|---|---|---|---|---:|---|---|
| `hs_bandit0` | 山贼斥候 | 普通 | 山贼斥候（shanzei_scout） | 6 | 山贼喽啰 | `shanzei_scout` ✅ |
| `hs_bandit1` | 山贼 | 普通 | 山贼（shanzei_band） | 6 | 山贼喽啰 | `shanzei_band` ✅ |
| `hs_tm3` | 黄巾余孽 | 普通 | 黄巾余孽（huangjin_remnant） | 6 | 南下黄巾 | `huangjin_remnant` ✅ |
| `hs_tm3b` | 黄巾前锋 | 普通 | 黄巾前锋（huangjin_vanguard） | 8 | 黄巾力士 | `huangjin_vanguard` ✅ |
| `hs_save_fight` | 太行绝壁·张白骑 | 精英 | 黄巾渠帅·张白骑（zhangbaiqi_elite） | 10 | 张白骑·黄巾渠帅 | `hs_zhangbaiqi` ✅ |
| `hs_hm1` | 太行外围 · 黑山游骑 | 普通 | 黑山游骑（heishan_youji） | 6 | 黑山游骑 | `heishan_wai` ✅ |
| `hs_bad_wall` | 冀州强弩 | 普通 | 冀州强弩（jizhou_nushou） | 8 | 冀州强弩手 | `hs_jizhou_nu` ✅ |
| `hs_hm1b` | 官道 · 黑山散兵 | 普通 | 黑山散兵（heishan_sanbing） | 6 | 黑山喽啰 | `jz_road_bandits` ✅ |
| `hs_bad_gate` | 无极突围·冀州步卒 | 普通 | 冀州步卒（jizhou_buzhu） | 8 | 刀兵队 | `hs_jizhou_buzhu` ✅ |
| `hs_yudu` | 黑山大寨·于毒 | 精英 | 黑山叛贼·于毒（yudu） | 10 | 于毒·黑山叛党 | `hs_yudu` ✅ |
| `hs_bad_street` | 秘道追兵·冀州轻骑 | 普通 | 冀州轻骑（jizhou_qibing） | 8 | 冀州骑卒 | `hs_jizhou_qibing` ✅ |
| `hs_bad_hall` | 无极甄府·淳于琼 | 首领 | 冀州大将·淳于琼（chunyuqiong_boss） | 10 | 「乌巢守将」淳于琼 | `hs_bad_hall` ✅ |
| `hs_bad_guotu` | 无极城外·郭图 | 首领 | 督粮官·郭图（guotu_enemy） | 10 | 冀州长戟兵 | `hs_guotu` ✅ |
| `hs_breakout` | 无极突围·冀州步卒 | 普通 | 冀州步卒（jizhou_buzhu） | 8 | 刀兵队 | `hs_jizhou_buzhu` ✅ |
| `hs_guotu_fight` | 无极城外·郭图 | 精英 | 督粮官·郭图（guotu_enemy） | 10 | 冀州长戟兵 | `hs_guotu` ✅ |
| `hs_pursuit0a` | 无极突围·冀州步卒 | 普通 | 冀州步卒（jizhou_buzhu） | 8 | 刀兵队 | `hs_jizhou_buzhu` ✅ |
| `hs_pursuit0` | 秘道追兵·冀州枪阵 | 普通 | 冀州大枪阵（jizhou_qiangbing） | 8 | 冀州长戟兵 | `hs_jizhou_qiangbing` ✅ |
| `hs_pursuit1` | 秘道追兵·冀州轻骑 | 普通 | 冀州轻骑（jizhou_qibing） | 8 | 冀州骑卒 | `hs_jizhou_qibing` ✅ |
| `hs_pursuit2` | 冀州强弩 | 普通 | 冀州强弩（jizhou_nushou） | 8 | 冀州强弩手 | `hs_jizhou_nu` ✅ |
| `hs_chunyuqiong` | 太行山口·淳于琼 | 普通 | 冀州大将·淳于琼（chunyuqiong_enemy） | 10 | 「乌巢守将」淳于琼 | `hs_chunyuqiong` ✅ |
| `hs_jieqiao_scout` | 界桥外围·游骑 | 普通 | 冀州轻骑（jizhou_qibing） | 8 | 冀州骑卒 | `hs_jieqiao_scout` ✅ |
| `hs_jieqiao_scout2` | 秘道追兵·冀州轻骑 | 普通 | 冀州轻骑（jizhou_qibing） | 8 | 冀州骑卒 | `hs_jizhou_qibing` ✅ |
| `hs_jieqiao_archers` | 冀州强弩 | 普通 | 冀州强弩（jizhou_nushou） | 8 | 冀州强弩手 | `hs_jizhou_nu` ✅ |
| `hs_quyi` | 界桥·麹义先登营 | 精英 | 先登主将·麹义（quyi_enemy） | 12 | 「先登死士」麹义 | `hs_quyi` ✅ |
| `hs_wenchou` | 界桥血战·文丑 | 首领 | 河北庭柱·文丑（wenchou_boss） | 15 | 「河北庭柱」文丑 | `hs_wenchou` ✅ |

敌人招式：

- **山贼斥候** `shanzei_scout`：血 2200 / 攻 150 / 行动 2；乱砍
- **山贼** `shanzei_band`：血 3800 / 攻 190 / 行动 2；乱砍、扔石头、抢了就跑（heal）
- **黄巾余孽** `huangjin_remnant`：血 4200 / 攻 200 / 行动 2；黄天当立、符水（heal）、妖言（confuse）
- **黄巾前锋** `huangjin_vanguard`：血 5000 / 攻 220 / 行动 2；黄巾冲阵、呐喊
- **黄巾渠帅·张白骑** `zhangbaiqi_elite`：血 7500 / 攻 230 / 行动 2；乱刀齐下、渠帅狂怒、黄巾浪潮（ap_drain）
- **黑山游骑** `heishan_youji`：血 3000 / 攻 185 / 行动 2；乱砍、滚木落石
- **冀州强弩** `jizhou_nushou`：血 4800 / 攻 200 / 行动 2；齐射、火箭（burn_party）
- **黑山散兵** `heishan_sanbing`：血 2800 / 攻 175 / 行动 2；乱刀、偷袭
- **冀州步卒** `jizhou_buzhu`：血 5000 / 攻 180 / 行动 2；挥砍、军阵（heal）
- **黑山叛贼·于毒** `yudu`：血 8500 / 攻 260 / 行动 2；开山斧、狂暴（rage）、放火烧林（burn_party）
- **冀州轻骑** `jizhou_qibing`：血 5500 / 攻 190 / 行动 2；冲锋、游斗
- **冀州大将·淳于琼** `chunyuqiong_boss`：血 15000 / 攻 270 / 行动 2；重戟、戟扫千军（confuse）、坚甲防守（heal）、军令·围杀（ap_drain）
- **督粮官·郭图** `guotu_enemy`：血 9500 / 攻 230 / 行动 2；令箭督战、羽扇惑心（confuse）、离间军心（ap_drain）、弩阵齐射
- **冀州大枪阵** `jizhou_qiangbing`：血 6500 / 攻 190 / 行动 2；大枪突刺、枪阵逼近
- **冀州大将·淳于琼** `chunyuqiong_enemy`：血 12000 / 攻 240 / 行动 2；重戟、坚甲防守（heal）
- **先登主将·麹义** `quyi_enemy`：血 14000 / 攻 280 / 行动 2；举盾推进、强弩齐射·蓄力（charge）、强弩齐射（pierce）、先登绞杀（ap_drain）
- **河北庭柱·文丑** `wenchou_boss`：血 22000 / 攻 380 / 行动 2；长枪横扫、猛将突刺、庭柱之威（rage）、枪出如龙（ap_drain）

## 本章专属 ？ 事件（4）

### 寨中赌局 `e3_dubo`

> 黑山喽啰拉你掷骰子：赌一把，还是让夏侯兰去抓赌？

- 山道边的破庙里，一群黑山喽啰围着一只破碗掷骰子，吆喝声半里外都听得见。
- 一个缺牙的喽啰冲你招手：「那边的！来一把？输了留下一个兵，赢了，寨子里的好东西随你挑！」
- 郭嘉的眼睛亮了。夏侯兰的脸黑了。
- **选项**「赌一把」：[{"chance": 0.5, "then": [{"say": "三个六。喽啰们看着你，像看着一个妖怪。缺牙的那个把压箱底的宝贝推了过来。"}, {"relic": true}], "else": [{"say": "一二三。郭嘉在旁边叹了口气：「主公，骰子是灌了铅的。」"}, {"lose_soldier": 1}]}]
- **选项**「让夏侯兰去抓赌」：[{"say": "夏侯兰一脚踢翻了破碗。喽啰们一哄而散，跑出去老远还在骂。"}, {"say": "第二天，这一带的山寨都在传：北边来了个铁面的，见赌就踢。"}, {"upgrade": "random"}]

### 崖上老参 `e3_laoshen`

> 绝壁上长着一株五十年的老参：让赵云爬上去挖，还是记下地方，留着卖个好价？

- 绝壁上，一株老山参的叶子从石缝里探出来，红果子在风里晃。
- 张夫人眯着眼看了半天：「这一株，少说五十年。在邺城的药铺里，能换一匹好马。」
- 赵云已经在往手上缠布了。
- **选项**「让赵云爬上去挖」：[{"say": "赵云下来的时候，手上全是血口子，老参却一根须都没断。"}, {"say": "那天晚上的参汤，全队一人一碗。"}, {"heal": 0.25}]
- **选项**「记下地方，留着卖个好价」：[{"say": "张夫人在账本上画了一个只有她看得懂的记号：「等太平了，这一株，够养一营兵。」"}, {"upgrade": "random"}]

### 黄巾老卒 `e3_huangjin`

> 缺腿的老黄巾和几个后生：收留后生编进队伍，还是给点干粮就走？

- 山坳里坐着一个缺了一条腿的老汉，头上还裹着一块褪了色的黄巾。
- 他身后站着几个面黄肌瘦的后生，手里攥着木棍。
- 老汉：「天公将军死了七年了。……你们是官军，还是贼？」
- {lord}（内心）：……这个问题，我自己也想知道。
- **选项**「收留那几个后生」：[{"say": "后生们跪下磕了头。老汉没跪，只是摸着那块黄巾，说了一句「好好吃饭」。"}, {"offer": {"from": ["taihang_yiyong", "heishan_bing", "huangjin_lishi"], "n": 2}}]
- **选项**「给点干粮就走」：[{"say": "老汉接过干粮，冲你们点了点头：「不像官军。也不像贼。」"}, {"heal": 0.1}]

### 白马残兵 `e3_baima`

> 公孙瓒走散的白马义从：给他们指路，还是买下他们的马？

- 林子里拴着几匹白马。马的主人蹲在一边，白甲上全是泥，是公孙瓒走散的白马义从。
- 领头的看见你们的旗，手按在了刀上：「袁绍的人？」
- 赵云：「不是。我们也打袁绍。」
- **选项**「给他们指路，留他们吃顿饭」：[{"say": "吃完饭，有几个不想回去了：「公孙将军的仗，我们打够了。跟着你们，至少有饭吃。」"}, {"offer": {"from": ["baima_yicong"], "n": 1}}]
- **选项**「买下他们的马」：[{"say": "白马义从的马，鞍子上都烙着一个「公孙」。郭嘉摸了摸马鬃：「好马。……就是太扎眼。」"}, {"relic": true}]

## 人和兵

- **剧情入队**：「铁面军法」夏侯兰（`hs_junfa`）、张宁·医仙（`hs_zhangyan`）、先登死士（`hs_end`）
- **掉落（打赢可能给）**：「乌巢守将」淳于琼、黑山游骑、黑山喽啰、黄巾力士、南下黄巾、刀兵队、冀州长戟兵、冀州强弩手、冀州骑卒、「先登死士」麹义、山贼喽啰、「河北庭柱」文丑、于毒·黑山叛党、张白骑·黄巾渠帅
- 全书的兵卡、武将来源见 `docs/ROSTER.md`。

## CG（19）

- `c3_recruit_board` ✅ 已有
  - 提示：a recruitment board at the gate of Zhending: the hero slapping his chest proudly before a wooden notice board, Zhao Yun standing by with his silver spear, a crowd of simple villagers watching with amusement
  - 参考立绘：（没有可参考的立绘）
- `c3_xiahoulan_law` ✅ 已有
  - 提示：a village road outside Zhending: Xiahou Lan pinning a thuggish soldier to the ground with one foot, hand on his saber, raising a punishment rod high in the other hand; the hero standing nearby looking awkward
  - 参考立绘：（没有可参考的立绘）
- `c3_bribe_villager` ✅ 已有
  - 提示：a village road in Changshan: the hero awkwardly pressing copper coins into a villager's hands, a rogue soldier smirking nearby, Xiahou Lan watching coldly from a distance
  - 参考立绘：（没有可参考的立绘）
- `c3_encounter_ning` ✅ 已有
  - 提示：a cliffside in the Taihang mountains: Zhang Ning (a young woman in white with a medicine box) holding a gold needle coldly defying a mob of Yellow Turban zealots; the bandit leader Zhang Baiqi laughing and pointing at her
  - 参考立绘：（没有可参考的立绘）
- `c3_save_ning` ✅ 已有
  - 提示：a deep gorge in the Taihang mountains: the girl Zhang Ning with her medicine box cornered against a cliff by Yellow Turban bandits; the hero charging in from the side with his saber drawn to kick the leader
  - 参考立绘：（没有可参考的立绘）
- `c3_leave_ning` ✅ 已有
  - 提示：the entrance of a mountain valley: the hero leading his troops quietly away, looking back with a conflicted expression at the trapped girl in white deep in the valley
  - 参考立绘：（没有可参考的立绘）
- `c3_zhangyan_meet` ✅ 已有
  - 提示：the Black Mountain stronghold at the peak of Taihang: the bandit king Zhang Yan landing lightly from a high cliff before the hero; surrounding cliffs filled with thousands of bandits holding torches
  - 参考立绘：（没有可参考的立绘）
- `c3_bad_return` ✅ 已有
  - 提示：无极甄府门前，黄昏：商队空着手回来，车马停在门口；张夫人（成年女性，富态精明）站在台阶上，目光越过人群落在队尾，那里本该有一个背竹篓的白衣姑娘，她什么也没问，默默合上手里的账本；赵云低着头牵马，郭嘉抱着没打开的酒葫芦站在一旁，主角站在最前面，神情沉重；整体色调灰暗压抑
  - 参考立绘：主角 → `pics/source/generals/lord_north.jpg`；张夫人 → `pics/source/generals/zhangfuren.jpg`；赵云 → `pics/source/generals/zhaoyun.jpg`；郭嘉 → `pics/source/generals/guojia.jpg`
- `c3_guotu_raid` ✅ 已有
  - 提示：outside the gates of the Zhen manor in Wuji: the sinister Guo Tu laughing on horseback with a fan, as heavy Jizhou infantry smash open the manor's great doors
  - 参考立绘：（没有可参考的立绘）
- `c3_alliance` ✅ 已有
  - 提示：a wooden hall in the Black Mountain fort: the hero and Zhang Yan sitting across a table, the hero holding a wine bowl, Zhang Yan slamming a token on the table; Lady Zhang pouring wine, Zhang Ning watching
  - 参考立绘：（没有可参考的立绘）
- `c3_bad_guotu` ✅ 已有
  - 提示：甄府大门内的中庭，黎明前：满院狼藉，断枪与碎门板，淳于琼倒在一旁；郭图（刻薄的中年官员，黑色文冠、深紫官袍）摇着羽扇不紧不慢踱进门，一脚踩在门槛上打量着战利品；断了一半战枪、满身是伤的主角拄着枪半跪着抬头怒视他，张夫人（成年女性）抱着账本站在正堂台阶前；色调阴冷
  - 参考立绘：主角 → `pics/source/generals/lord_north.jpg`；张夫人 → `pics/source/generals/zhangfuren.jpg`；淳于琼 → `pics/source/generals/chunyuqiong.jpg`；郭图 → `pics/source/generals/guotu.jpg`
- `c3_secret_path` ✅ 已有
  - 提示：the entrance of a secret mountain tunnel at night: Lady Zhang leading the young girl Zhen Mi into the dark cave guided by Black Mountain bandits with torches; Zhen Mi looking back at distant fires in Wuji
  - 参考立绘：（没有可参考的立绘）
- `end_fuchao` ✅ 已有
  - 提示：outside the burned gate of the Zhen manor: the hero shot full of arrows collapsed on the steps, Lady Zhang dead in a pool of blood protecting the young Zhen Mi from a hail of arrows (restrained, no gore)
  - 参考立绘：（没有可参考的立绘）
- `c3_breakout` ✅ 已有
  - 提示：the burning gates of the Zhen manor: the hero leading a cavalry charge out of the fire, his spear knocking aside a Jizhou crossbowman blocking the way
  - 参考立绘：（没有可参考的立绘）
- `c3_guotu_street` ✅ 已有
  - 提示：无极街口的夜里：督粮官郭图（四十岁上下，面容刻薄，细眼薄唇，黑色文冠、深紫官袍，手摇黑色羽扇）骑在马上拦住去路，身后是整队举着强弩的督战弩手，火把照亮他贪婪的目光，视线越过人群盯着身后一长串粮车；赵云（银甲白马，银枪出鞘）勒马挡在最前，主角持白蜡杆长枪（红色平安结）站在他身侧，身后是燃烧的甄府大门；对峙的紧张感，冷暖对比的火光
  - 参考立绘：主角 → `pics/source/generals/lord_north.jpg`；赵云 → `pics/source/generals/zhaoyun.jpg`；郭图 → `pics/source/generals/guotu.jpg`
- `c3_guojia_map` ✅ 已有
  - 提示：inside a military tent at night: Guo Jia holding a wine cup and pointing at a campaign map with a riding crop; the hero, Zhao Yun, and Zhang Yan watching closely around the low table
  - 参考立绘：（没有可参考的立绘）
- `c3_quyi_camp` ✅ 已有
  - 提示：Jieqiao battlefield: Yuan Shao's vanguard Qu Yi standing coldly in front of a wall of 800 soldiers holding giant black iron-bound shields and heavy crossbows, stopping a charge of white horses
  - 参考立绘：（没有可参考的立绘）
- `c3_save_zan` ✅ 已有
  - 提示：Jieqiao battlefield: Zhao Yun on a white horse clashing his silver spear against Wen Chou's heavy lance in a shower of sparks; Gongsun Zan slumped on the ground behind them looking terrified
  - 参考立绘：（没有可参考的立绘）
- `c3_banma_flag` ✅ 已有
  - 提示：a high ground at the Jieqiao battlefield: the hero and Lü Lingqi side by side on horseback, Lü Lingqi holding a giant black-and-white vertically striped 'Zebra' war banner whipping in the wind
  - 参考立绘：（没有可参考的立绘）

## 结局：结局六 · 覆巢

- 谁：张夫人、张宁
- 触发：太行山里见死不救：选了「绕道避险」，没救张宁，一年后郭图带冀州兵围了无极甄府
- 破局：再来一周目：去太行山下救下背药箱的姑娘，才能「拔刀相助」收张宁
- 铭文：覆巢之下，安有完卵。你以为不趟浑水就能保住甄家，可乱世里，没有人是旁观者。……也许下一周目，你会拔刀。
- 结局卡：`end_fuchao` ✅

