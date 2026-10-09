# 美术需求

> 本文件由 `sanguo-art` 根据游戏数据（godot/data）和 `pics/art.json` 自动生成，别手改。
> 按章节列出立绘、战斗背景、剧情 CG、奇遇插图和地图底图；宝物、天命、词缀、标题等见 `ART-PLAN.md`，出图提示词见 `ART-PROMPTS.md`。

## 怎么换图

1. 把原图放进 `pics/source/` 对应的子文件夹（generals 武将 / soldiers 兵卡 / map 地图），文件名用 key（如 `langlijiao.jpg`）。
2. 在 `pics/art.json` 的 `portraits` 里加一行：`"<key>": {"src": "source/generals/<key>.jpg", "face": [x, y], "head": h}`
   - `face`：脸中心在图里的位置（0–1，左上角是 0,0）；`head`：头高占整图高的比例（越大人物越小）
   - 换掉占位图时，把 `"placeholder": true` 删掉
3. 运行 `sanguo-art`。

规格：竖版 5:7（≥ 1000×1400），人物居中、脸在上 1/3，半身到全身，背景简单。

状态：🟡 占位图（清代绣像等公有领域图）　⬜ 缺。已到位的不列出，只在每张表下记一个数。

## 第一章 · 富春

地图底图 `prologue`：✅ 已有、`prologue_north`：✅ 已有

✅ 全部到位（19 项）

敌人（战斗界面上方；和它的卡共用一张图）

✅ 全部到位（16 项）

能拿到的卡

✅ 全部到位（7 项）

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

✅ 全部到位（19 项）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

✅ 全部到位（20 项）

奇遇插图（这一章第一次会抽到的「？」事件）

| 状态 | key | 事件 |
|---|---|---|
| ⬜ 缺 | `e_ambush` | 「芦苇埋伏」 |
| ⬜ 缺 | `e_snake` | 「竹叶青」 |
| ⬜ 缺 | `e_zuoci` | 「葫芦道人」 |
| ⬜ 缺 | `e_chest` | 「路边铁箱」 |
| ⬜ 缺 | `e_hero` | 「路遇壮士」 |
| ⬜ 缺 | `e_refugees` | 「流民」 |
| ⬜ 缺 | `e_washer` | 「浣纱女」 |
| ⬜ 缺 | `e_fruit` | 「野果」 |
| ⬜ 缺 | `e_risk` | 「险滩」 |
| ⬜ 缺 | `e_temple` | 「山神庙」 |
| ⬜ 缺 | `e_huatuo` | 「游方郎中」 |
| ⬜ 缺 | `e_yuji` | 「白衣道人」 |
| ⬜ 缺 | `e_merchant` | 「行商」 |
| ⬜ 缺 | `e_smith` | 「铁匠铺」 |
| ⬜ 缺 | `e_tomb` | 「古墓」 |
| ⬜ 缺 | `e_guanlu` | 「管辂算命」 |
| ⬜ 缺 | `e_xushao` | 「月旦评」 |
| ⬜ 缺 | `e_qiao` | 「二乔」 |
| ⬜ 缺 | `e_drink` | 「斗酒」 |
| ⬜ 缺 | `e_deserters` | 「逃兵」 |
| ⬜ 缺 | `e_storm` | 「暴雨」 |
| ⬜ 缺 | `e_horse` | 「卖马人」 |
| ⬜ 缺 | `e_convoy` | 「截粮队」 |
| ⬜ 缺 | `e_surrender` | 「降卒」 |
| ⬜ 缺 | `e_shanzei` | 「山贼拦路」 |
| ⬜ 缺 | `e_shanzhai` | 「山寨」 |
| ⬜ 缺 | `e_jieying` | 「山贼劫营」 |
| ⬜ 缺 | `e_hj_camp` | 「黄巾余孽营地」 |
| ⬜ 缺 | `e_hj_medics` | 「黄巾女眷」 |
| ⬜ 缺 | `e_hj_road` | 「黄巾劫道」 |
| ⬜ 缺 | `e_yuan_tax` | 「袁术的税吏」 |
| ⬜ 缺 | `e_black_market` | 「南阳黑市」 |
| ⬜ 缺 | `e_veterans` | 「孙家旧部」 |
| ⬜ 缺 | `e_plague` | 「疫村」 |
| ⬜ 缺 | `e_tongyao` | 「童谣」 |
| ⬜ 缺 | `e_taihang_hunter` | 「太行猎户」 |
| ⬜ 缺 | `e_zhen_caravan` | 「甄家商队」 |
| ⬜ 缺 | `e_taihang_bear` | 「黑熊挡道」 |

（另有 7 项已到位）

## 第二章 · 讨伐董卓

地图底图 `taodong`：✅ 已有

✅ 全部到位（6 项）

敌人（战斗界面上方；和它的卡共用一张图）

✅ 全部到位（7 项）

能拿到的卡

✅ 全部到位（2 项）

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

✅ 全部到位（19 项）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

✅ 全部到位（16 项）

奇遇插图（这一章第一次会抽到的「？」事件）

| 状态 | key | 事件 |
|---|---|---|
| ⬜ 缺 | `e_zhuhou_yan` | 「诸侯宴」 |

（另有 1 项已到位）

## 第二章 · 洛阳烟云

地图底图 `luoyang_n`：✅ 已有

✅ 没有

敌人（战斗界面上方；和它的卡共用一张图）

✅ 全部到位（1 项）

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ⬜ 缺 | `chenglian` | 成廉 |
| ⬜ 缺 | `weixu` | 魏续 |

（另有 2 项已到位）

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

✅ 全部到位（11 项）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

✅ 全部到位（7 项）

## 第三章 · 黑山风云

地图底图 `heishan`：🟡 程序占位

✅ 全部到位（3 项）

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `shanzei_scout` | 山贼斥候 |

（另有 5 项已到位）

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ⬜ 缺 | `yangang` | 严纲 |
| ⬜ 缺 | `zoudan` | 邹丹 |
| ⬜ 缺 | `zhanghe` | 张郃 |

（另有 3 项已到位）

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `hs_jizhou_qibing` | 秘道追兵·冀州轻骑（冀州轻骑） |
| ⬜ 缺 | `hs_jizhou_nu` | 冀州强弩（冀州强弩） |
| ⬜ 缺 | `hs_chunyuqiong` | 太行山口·淳于琼（冀州大将·淳于琼） |
| ⬜ 缺 | `hs_quyi` | 界桥·麹义先登营（先登主将·麹义） |
| ⬜ 缺 | `hs_jizhou_buzhu` | 无极突围·冀州步卒（冀州步卒） |
| ⬜ 缺 | `hs_jizhou_qiangbing` | 秘道追兵·冀州枪阵（冀州大枪阵） |
| ⬜ 缺 | `hs_jieqiao_scout` | 界桥外围·游骑（冀州轻骑） |
| ⬜ 缺 | `shanzei_scout` | 山贼斥候（山贼斥候） |
| ⬜ 缺 | `huangjin_vanguard` | 黄巾前锋（黄巾前锋） |

（另有 9 项已到位）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

✅ 全部到位（19 项）

## 第三章 · 传国玉玺

地图底图 `yuxi`：🟡 程序占位

✅ 全部到位（2 项）

敌人（战斗界面上方；和它的卡共用一张图）

✅ 全部到位（6 项）

能拿到的卡

✅ 没有

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

✅ 全部到位（18 项）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

✅ 全部到位（11 项）

奇遇插图（这一章第一次会抽到的「？」事件）

| 状态 | key | 事件 |
|---|---|---|
| ⬜ 缺 | `e_jz_spy` | 「荆州细作」 |
| ⬜ 缺 | `e_yuxi_rumor` | 「玉玺流言」 |

## 第三章 · 驻守洛阳

地图底图 `shouluoyang`：🟡 程序占位

✅ 全部到位（1 项）

敌人（战斗界面上方；和它的卡共用一张图）

✅ 没有

能拿到的卡

✅ 没有

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `c4_guosi` | 劫粮·郭汜（郭汜） |
| ⬜ 缺 | `c4_liumin` | 废墟·暴动流民（暴动流民） |
| ⬜ 缺 | `c4_lijue_test` | 拦路迎亲（李傕） |

（另有 9 项已到位）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

| 状态 | key | 剧情格 |
|---|---|---|
| ⬜ 缺 | `c4_wenji` | 蔡文姬 |
| ⬜ 缺 | `c4_zhujun` | 朱儁 |
| ⬜ 缺 | `c4_xizi` | 灯下习字 |
| ⬜ 缺 | `c4_peace` | 求和 |
| ⬜ 缺 | `c4_betroth` | 定亲 |
| ⬜ 缺 | `c4_mangshan` | 邙山跑马 |

## 第三章 · 长安

地图底图 `changan`：🟡 程序占位

✅ 全部到位（5 项）

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `fanchou` | 樊稠 |
| ⬜ 缺 | `zhangji` | 张济 |
| ⬜ 缺 | `niufu` | 牛辅 |
| ⬜ 缺 | `huzhen` | 胡轸 |

能拿到的卡

✅ 全部到位（1 项）

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `c5_fanchou` | 比武·樊稠（樊稠） |
| ⬜ 缺 | `c5_zhangji` | 比武·张济（张济） |
| ⬜ 缺 | `c5_niufu` | 比武·牛辅（牛辅） |
| ⬜ 缺 | `c5_qinbing` | 后园·吕布亲兵（吕布亲兵） |
| ⬜ 缺 | `c5_hall` | 喜堂·飞熊军（飞熊军） |
| ⬜ 缺 | `c5_huzhen` | 内门·胡轸（胡轸） |
| ⬜ 缺 | `c5_dongzhuo` | 未央宫前·董卓（董卓） |

（另有 10 项已到位）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

| 状态 | key | 剧情格 |
|---|---|---|
| ⬜ 缺 | `c5_enter` | 入长安 |
| ⬜ 缺 | `c5_feast` | 接风宴 |
| ⬜ 缺 | `c5_garden` | 朝见 |
| ⬜ 缺 | `c5_diaochan` | 貂蝉 |
| ⬜ 缺 | `c5_yuexia` | 月下 |
| ⬜ 缺 | `c5_dance` | 献貂蝉 |
| ⬜ 缺 | `c5_fengyi` | 凤仪亭 |
| ⬜ 缺 | `c5_chuxi` | 除夕 |
| ⬜ 缺 | `c5_dress` | 大婚前夜 |
| ⬜ 缺 | `c5_snow` | 雪夜 |
| ⬜ 缺 | `c5_wedding` | 大婚 |
| ⬜ 缺 | `c5_rescue` | 格杀勿论 |
| ⬜ 缺 | `c5_death` | 董卓之死 |

## 第四章 · 双凤乱太行

地图底图 `beihai`：🟡 程序占位

✅ 全部到位（1 项）

敌人（战斗界面上方；和它的卡共用一张图）

✅ 全部到位（7 项）

能拿到的卡

✅ 全部到位（8 项）

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `bh_zhenghao` | 郑家寨（郑好） |
| ⬜ 缺 | `bh_jiangqiao` | 姜家寨（姜巧） |
| ⬜ 缺 | `c4_gaoshun` | 后门·高顺（高顺） |
| ⬜ 缺 | `bh_lubu` | 太行山口·吕布（吕布） |
| ⬜ 缺 | `huangjin_vanguard` | 黄巾前锋（黄巾前锋） |
| ⬜ 缺 | `bh_guanhai` | 北海解围（管亥） |
| ⬜ 缺 | `th_patrol` | 太行巡山兵（太行巡山兵） |
| ⬜ 缺 | `bh_jiang_trap` | 姜家寨暗哨（山贼） |
| ⬜ 缺 | `bh_wolf2` | 并州精骑（并州狼骑） |
| ⬜ 缺 | `bh_jz_inf` | 冀州步卒（冀州步卒） |
| ⬜ 缺 | `bh_jz_spear` | 冀州长枪（冀州大枪阵） |
| ⬜ 缺 | `bh_jz_scout` | 冀州游骑（冀州轻骑） |
| ⬜ 缺 | `bh_yanliang` | 渡口·颜良（颜良） |
| ⬜ 缺 | `bh_hj_qushuai` | 青州渠帅（黄巾渠帅） |
| ⬜ 缺 | `bh_hj_duzhan` | 黄巾督战队（黄巾前锋） |
| ⬜ 缺 | `shanzei_scout` | 山贼斥候（山贼斥候） |

（另有 4 项已到位）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

| 状态 | key | 剧情格 |
|---|---|---|
| ⬜ 缺 | `c4_drink` | 收服双凤 |
| ⬜ 缺 | `end_juefa` | 结局七 |
| ⬜ 缺 | `c4_escape` | 金蝉脱壳 |
| ⬜ 缺 | `c4_yanliang` | 渡口·颜良 |
| ⬜ 缺 | `c4_million_hj` | 北海之围 |
| ⬜ 缺 | `c4_taishici_break` | 太史慈 |
| ⬜ 缺 | `c4_porridge` | 阵前熬粥 |
| ⬜ 缺 | `c4_kongrong` | 让北海 |

## 第四章 · 挟天子

地图底图 `dongui`：🟡 程序占位

| 状态 | key | 用在 |
|---|---|---|
| ⬜ 缺 | `xunyou` | 剧情立绘 |
| ⬜ 缺 | `zhongyao` | 剧情立绘 |

（另有 4 项已到位）

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `zhangxiu` | 「北地枪王」张绣 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ⬜ 缺 | `jiangqin` | 蒋钦 |
| ⬜ 缺 | `lingtong` | 凌统 |

（另有 2 项已到位）

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `c6_shaoka` | 清明门·哨卡（司徒哨卡） |
| ⬜ 缺 | `c6_zhangxiu` | 渭水桥·张绣（「北地枪王」张绣） |
| ⬜ 缺 | `c6_zhangji` | 渭水营·张济（张济） |
| ⬜ 缺 | `c6_fubing` | 长街·司徒府兵（司徒府兵） |
| ⬜ 缺 | `c6_fanchou` | 山道·樊稠（樊稠） |
| ⬜ 缺 | `c6_lijue` | 函谷关·李傕（李傕） |
| ⬜ 缺 | `c7_qiaorui` | 营寨·桥蕤（桥蕤） |
| ⬜ 缺 | `c7_leibo` | 山道·雷薄（雷薄） |
| ⬜ 缺 | `c7_chenlan` | 宛城城下·陈兰（陈兰） |
| ⬜ 缺 | `c7_jiling` | 宛城·纪灵（纪灵） |
| ⬜ 缺 | `c4_gaoshun` | 后门·高顺（高顺） |
| ⬜ 缺 | `c6_xianzhen` | 宣平门前·陷阵营兵（陷阵营兵） |
| ⬜ 缺 | `c4_lvbu` | 宣平门·吕布（吕布） |
| ⬜ 缺 | `c5_qinbing` | 后园·吕布亲兵（吕布亲兵） |

（另有 12 项已到位）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

| 状态 | key | 剧情格 |
|---|---|---|
| ⬜ 缺 | `c6_yizu` | 夷族 |
| ⬜ 缺 | `c6_fenghou` | 封侯 |
| ⬜ 缺 | `c6_warn` | 报信（三周目） |
| ⬜ 缺 | `c4_siege` | 围府（二周目） |
| ⬜ 缺 | `c6_escape` | 北掖门（三周目） |
| ⬜ 缺 | `c4_dongjia` | 董家（二周目） |
| ⬜ 缺 | `c6_jiaxu` | 绑走贾诩 |
| ⬜ 缺 | `c4_tonggui` | 同归（二周目） |
| ⬜ 缺 | `c6_huihe` | 洛阳（三周目） |
| ⬜ 缺 | `c6_jiaxu_join` | 洛阳休整 |
| ⬜ 缺 | `c6_seal` | 玉玺（三周目） |
| ⬜ 缺 | `c7_huangzhong` | 黄忠（三周目） |
| ⬜ 缺 | `c7_stars` | 星夜（三周目） |
| ⬜ 缺 | `c7_feng` | 冯夫人（三周目） |
| ⬜ 缺 | `c7_flee` | 袁术东逃（三周目） |

（另有 1 项已到位）

## 第五章 · 荆襄风云

地图底图 `jingxiang`：🟡 程序占位

| 状态 | key | 用在 |
|---|---|---|
| ⬜ 缺 | `kuaiyue` | 剧情立绘 |
| ⬜ 缺 | `caimao` | 剧情立绘 |

（另有 6 项已到位）

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `huangzu` | 江夏太守黄祖 |

（另有 4 项已到位）

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ⬜ 缺 | `wenpin` | 文聘·荆州大将 |
| ⬜ 缺 | `yiji` | 伊籍 |

（另有 2 项已到位）

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `jx_ganning` | 汉水·甘宁（「锦帆游侠」甘宁） |
| ⬜ 缺 | `jx_bubing` | 淯水北岸·荆州步卒（荆州步卒） |
| ⬜ 缺 | `jx_gongshou` | 芦苇荡·荆州弓手（荆州弓手） |
| ⬜ 缺 | `jx_huangzu` | 淯水·黄祖（江夏太守黄祖） |
| ⬜ 缺 | `jx_jinfan` | 汉水渡口·锦帆贼（锦帆贼） |
| ⬜ 缺 | `jx_zongzei` | 新野·宗贼（宗贼） |
| ⬜ 缺 | `jx_shuijun` | 水寨·荆州水军（荆州水军） |
| ⬜ 缺 | `jx_nushou` | 水阁·蔡府连弩手（蔡府连弩手） |
| ⬜ 缺 | `jx_caimao_a` | 水阁·独眼蔡瑁（独眼蔡瑁） |
| ⬜ 缺 | `jx_caimao_b` | 水阁·蔡瑁（水军都督蔡瑁） |

（另有 9 项已到位）

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

| 状态 | key | 剧情格 |
|---|---|---|
| ⬜ 缺 | `c8_jiayan` | 宛城小聚 |
| ⬜ 缺 | `c8_liuxian` | 留仙裙 |
| ⬜ 缺 | `c8_caifuren` | 襄阳 |
| ⬜ 缺 | `c8_shuige` | 万山水阁 |
| ⬜ 缺 | `c8_dress` | 盛装 |
| ⬜ 缺 | `c8_xiangxiao` | 香消 |
| ⬜ 缺 | `c8_grapes` | 万山水阁 |
| ⬜ 缺 | `c8_xuexi` | 血洗 |
| ⬜ 缺 | `c8_henhai` | 恨海 |
| ⬜ 缺 | `c8_zupu` | 明正典刑 |
| ⬜ 缺 | `c8_louchuan` | 月下楼船 |

（另有 1 项已到位）

奇遇插图（这一章第一次会抽到的「？」事件）

| 状态 | key | 事件 |
|---|---|---|
| ⬜ 缺 | `e_shuijing` | 「水镜先生」 |
| ⬜ 缺 | `e_pangdegong` | 「岘山老农」 |
| ⬜ 缺 | `e_huangchengyan` | 「沔南名士」 |
| ⬜ 缺 | `e_ganning` | 「锦帆游侠」 |

## 其余武将（招募池，按需再画）

| 状态 | key | 卡 |
|---|---|---|
| ⬜ 缺 | `lusu` | 鲁肃（SR） |
| ⬜ 缺 | `zhangzhongjing` | 张仲景（SR） |
| 🟡 占位 | `xuchu` | 许褚（SR） |
| 🟡 占位 | `pangtong` | 庞统（SR） |
| 🟡 占位 | `dianwei` | 典韦（SSR） |
| 🟡 占位 | `zhugeliang` | 诸葛亮（SSR） |
| 🟡 占位 | `lvmeng` | 吕蒙（SR） |
| ⬜ 缺 | `luxun` | 陆逊（SSR） |
| 🟡 占位 | `zhangjiao` | 张角（SSR） |
| ⬜ 缺 | `jiangwei` | 姜维（SSR） |
| ⬜ 缺 | `zhangren` | 张任（SR） |
| ⬜ 缺 | `chendao` | 陈到（SR） |
| ⬜ 缺 | `weiyan` | 魏延（SR） |
| ⬜ 缺 | `xiahoudun` | 夏侯惇（SR） |
| ⬜ 缺 | `dongfeng` | 董奉（R） |
| ⬜ 缺 | `zhangzhao` | 张昭（R） |
| ⬜ 缺 | `qiaoguolao` | 乔国老（R） |
| ⬜ 缺 | `zhoucang` | 周仓（R） |
| 🟡 占位 | `liaohua` | 廖化（R） |
| ⬜ 缺 | `wangping` | 王平（R） |
| ⬜ 缺 | `lidian` | 李典（R） |
| 🟡 占位 | `jianyong` | 简雍（R） |
| ⬜ 缺 | `guanping` | 关平（R） |
| ⬜ 缺 | `zhangbao` | 张苞（R） |
| ⬜ 缺 | `guanxing` | 关兴（R） |
| ⬜ 缺 | `yanyan` | 严颜（R） |

（另有 25 项已到位）
