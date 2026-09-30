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

状态：✅ 正式美术　🟡 占位图（清代绣像等公有领域图）　⬜ 缺

## 第一章 · 富春

地图底图 `prologue`：✅ 已有

| 状态 | key | 用在 |
|---|---|---|
| ✅ 正式 | `lord` | 主公 / 穿越者 |
| ✅ 正式 | `zuoci` | 事件「葫芦道人」 |
| ✅ 正式 | `huatuo` | 事件「游方郎中」 |
| ✅ 正式 | `yuji` | 事件「白衣道人」 |
| ✅ 正式 | `sunce` | 事件「白衣道人」 |
| ✅ 正式 | `zhouyu` | 事件「二乔」 |
| ✅ 正式 | `yanzhihu` | 事件「压寨夫人」 |
| ✅ 正式 | `zhangning` | 事件「黄巾圣女」 |
| ✅ 正式 | `wuguotai` | 剧情立绘 |

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ✅ 正式 | `shuizei_bing` | 水贼喽啰 |
| ✅ 正式 | `baie_hu` | 吊睛白额虎 |
| ✅ 正式 | `fushui_xintu` | 于吉信徒 |
| ✅ 正式 | `shanzei_bing` | 山贼 |
| ✅ 正式 | `huangjin_nanxia` | 黄巾余孽 |
| ✅ 正式 | `inf_n` | 官军 |
| ✅ 正式 | `boar` | 野猪 |
| ✅ 正式 | `langlijiao` | 「浪里蛟」胡玉 |
| ✅ 正式 | `yaodao` | 妖道唐周 |
| ✅ 正式 | `heyi` | 黄巾渠帅何仪 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ✅ 正式 | `danyang` | 丹阳兵 |
| ✅ 正式 | `changsha` | 长沙刀兵 |
| ✅ 正式 | `jiangdong_gong` | 江东弓手 |
| ✅ 正式 | `liehu` | 山中猎户 |
| ✅ 正式 | `yuenv_gong` | 越女弓手 |
| ⬜ 缺 | `huofu` | 伙夫 |
| ⬜ 缺 | `chuangong` | 江东船工 |
| ✅ 正式 | `huangjin_nvyi` | 黄巾女医 |
| ⬜ 缺 | `yahuan` | 丫鬟 |
| ⬜ 缺 | `chuniang` | 厨娘 |
| ⬜ 缺 | `xiuniang` | 绣娘 |
| ⬜ 缺 | `huansha` | 浣纱女 |
| ⬜ 缺 | `caisang` | 采桑女 |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ✅ 已有 | `shuizei_scout` | 水贼喽啰（水贼喽啰） |
| ✅ 已有 | `tiger` | 打虎（吊睛白额虎） |
| ✅ 已有 | `yuji_xintu` | 于吉信徒（于吉信徒） |
| ✅ 已有 | `shanzei_band` | 山贼（山贼） |
| ✅ 已有 | `yanzhihu` | 山寨·胭脂虎（「胭脂虎」） |
| ✅ 已有 | `huangjin_remnant` | 黄巾余孽（黄巾余孽） |
| ✅ 已有 | `guanjun` | 官军（官军） |
| ✅ 已有 | `boar` | 野猪林（野猪） |
| ✅ 已有 | `shuizei` | 水寨·胡玉（「浪里蛟」胡玉） |
| ✅ 已有 | `shuizei_guard` | 看门水贼（看门水贼） |
| ✅ 已有 | `yaodao` | 妖道唐周（妖道唐周） |
| ✅ 已有 | `shuizei_main` | 水贼大寨（黄巾渠帅何仪） |

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

| 状态 | key | 剧情格 |
|---|---|---|
| ✅ 已有 | `c1_wake` | 醒来 |
| ✅ 已有 | `c1_bandage` | 换药 |
| ✅ 已有 | `c1_raid` | 夜袭 |
| ✅ 已有 | `c1_rescue` | 救人 |
| ✅ 已有 | `c1_dinner` | 压惊宴 |
| ✅ 已有 | `c1_armor` | 旧甲 |
| ✅ 已有 | `c1_oath` | 结义 |
| ✅ 已有 | `c1_north` | 北上 |
| ✅ 已有 | `i1_sewing` | 幕间「吴夫人的针线」 |

奇遇插图（这一章第一次会抽到的「？」事件）

| 状态 | key | 事件 |
|---|---|---|
| ⬜ 缺 | `e_ambush` | 「芦苇埋伏」 |
| ⬜ 缺 | `e_snake` | 「竹叶青」 |
| ⬜ 缺 | `e_tiger` | 「吊睛白额虎」 |
| ⬜ 缺 | `e_zuoci` | 「葫芦道人」 |
| ⬜ 缺 | `e_chest` | 「路边铁箱」 |
| ⬜ 缺 | `e_hero` | 「路遇壮士」 |
| ⬜ 缺 | `e_refugees` | 「流民」 |
| ⬜ 缺 | `e_washer` | 「浣纱女」 |
| ⬜ 缺 | `e_dice` | 「水贼赌局」 |
| ⬜ 缺 | `e_fruit` | 「野果」 |
| ⬜ 缺 | `e_temple` | 「山神庙」 |
| ⬜ 缺 | `e_huatuo` | 「游方郎中」 |
| ⬜ 缺 | `e_yuji` | 「白衣道人」 |
| ⬜ 缺 | `e_merchant` | 「行商」 |
| ⬜ 缺 | `e_smith` | 「铁匠铺」 |
| ⬜ 缺 | `e_tomb` | 「古墓」 |
| ⬜ 缺 | `e_guanlu` | 「管辂算命」 |
| ⬜ 缺 | `e_qiao` | 「二乔」 |
| ⬜ 缺 | `e_drink` | 「斗酒」 |
| ⬜ 缺 | `e_deserters` | 「逃兵」 |
| ⬜ 缺 | `e_storm` | 「暴雨」 |
| ⬜ 缺 | `e_horse` | 「卖马人」 |
| ⬜ 缺 | `e_xushao` | 「月旦评」 |
| ⬜ 缺 | `e_surrender` | 「降卒」 |
| ⬜ 缺 | `e_shanzei` | 「山贼拦路」 |
| ⬜ 缺 | `e_yazhai` | 「压寨夫人」 |
| ⬜ 缺 | `e_shanzhai` | 「山寨」 |
| ⬜ 缺 | `e_jieying` | 「山贼劫营」 |
| ⬜ 缺 | `e_hj_camp` | 「黄巾余孽营地」 |
| ⬜ 缺 | `e_hj_medics` | 「黄巾女眷」 |
| ⬜ 缺 | `e_hj_road` | 「黄巾劫道」 |
| ⬜ 缺 | `e_shengnv` | 「黄巾圣女」 |
| ⬜ 缺 | `e_risk` | 「险滩」 |

## 第二章 · 讨伐董卓

地图底图 `taodong`：🟡 程序占位

| 状态 | key | 用在 |
|---|---|---|
| ✅ 正式 | `tangji` | 事件「落难贵人」 |
| ✅ 正式 | `baosanniang` | 事件「比武招亲」 |
| ✅ 正式 | `zumao` | 剧情立绘 |
| ✅ 正式 | `sunjian` | 剧情立绘 |
| ✅ 正式 | `dongbai` | 剧情立绘 |
| ✅ 正式 | `lvbu` | 剧情立绘 |
| ✅ 正式 | `liubei` | 剧情立绘 |
| ✅ 正式 | `guanyu` | 剧情立绘 |
| ✅ 正式 | `zhangfei` | 剧情立绘 |
| ✅ 正式 | `lijue` | 剧情立绘 |

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ✅ 正式 | `xiliang_bing` | 西凉斥候 |
| ✅ 正式 | `guosi` | 郭汜 |
| ✅ 正式 | `huaxiong` | 华雄 |
| ✅ 正式 | `feixiong_bing` | 飞熊军 |
| ✅ 正式 | `liru` | 李儒 |
| ⬜ 缺 | `bingzhou` | 并州狼骑 |
| ✅ 正式 | `xurong` | 徐荣 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ✅ 正式 | `gongnv` | 宫女 |
| ✅ 正式 | `xiliang_nvbing` | 西凉女亲兵 |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ✅ 已有 | `guanjun` | 官军（官军） |
| ✅ 已有 | `shuizei_scout` | 水贼喽啰（水贼喽啰） |
| ✅ 已有 | `xiliang_scout` | 截粮（西凉斥候） |
| ✅ 已有 | `tiger` | 打虎（吊睛白额虎） |
| ✅ 已有 | `xiliang_youqi` | 西凉游骑（西凉游骑） |
| ✅ 已有 | `shanzei_band` | 山贼（山贼） |
| ✅ 已有 | `yanzhihu` | 山寨·胭脂虎（「胭脂虎」） |
| ✅ 已有 | `huangjin_remnant` | 黄巾余孽（黄巾余孽） |
| ✅ 已有 | `biwu` | 擂台·鲍三娘（鲍三娘） |
| ✅ 已有 | `guosi` | 郭汜（郭汜） |
| ✅ 已有 | `huaxiong` | 汜水关·华雄（华雄） |
| ⬜ 缺 | `c2_gongqi` | 小路·西凉弓骑（西凉弓骑） |
| ✅ 已有 | `feixiong` | 飞熊军（飞熊军） |
| ✅ 已有 | `liru` | 李儒伏兵（李儒） |
| ✅ 已有 | `dongbai` | 董白（董白） |
| ⬜ 缺 | `c4_langqi` | 长街·并州狼骑（并州狼骑） |
| ✅ 已有 | `hulao_ch1` | 追兵·吕布（吕布） |
| ✅ 已有 | `dagu` | 大谷·徐荣（徐荣） |
| ✅ 已有 | `lijue` | 洛阳城门·李傕（李傕） |

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

| 状态 | key | 剧情格 |
|---|---|---|
| ✅ 已有 | `c2_setout` | 北上 |
| ✅ 已有 | `c2_zumao` | 阵前 |
| ✅ 已有 | `c2_zumao_saved` | 救祖茂 |
| ✅ 已有 | `c2_counter` | 收拢士卒 |
| ✅ 已有 | `c2_capture` | 俘虏 |
| ✅ 已有 | `c2_captive` | 俘虏的日子 |
| ✅ 已有 | `c2_raid` | 吕布劫营 |
| ✅ 已有 | `c2_sanying` | 三英战吕布 |
| ✅ 已有 | `c2_triple` | 威震诸侯 |
| ⬜ 缺 | `c2_handover` | 交人 |
| ✅ 已有 | `c2_keep` | 藏人 |
| ✅ 已有 | `c2_heqin` | 和亲 |
| ⬜ 缺 | `c2_mixin` | 密信 |
| ✅ 已有 | `c2_dongbai_join` | 洛阳 |
| ✅ 已有 | `c2_yuxi` | 井中玉玺 |
| ⬜ 缺 | `i2_yuxi` | 幕间「玉玺」 |
| ⬜ 缺 | `i2_duel` | 幕间「单挑」 |
| ⬜ 缺 | `i2_qin` | 幕间「琴声」 |

奇遇插图（这一章第一次会抽到的「？」事件）

| 状态 | key | 事件 |
|---|---|---|
| ⬜ 缺 | `e_tongyao` | 「童谣」 |
| ⬜ 缺 | `e_zhuhou_yan` | 「诸侯宴」 |
| ⬜ 缺 | `e_convoy` | 「截粮队」 |
| ⬜ 缺 | `e_tangji` | 「落难贵人」 |
| ✅ 已有 | `e_biwu` | 「比武招亲」 |
| ⬜ 缺 | `e_grand_chest` | 「高级宝箱」 |

## 第三章 · 传国玉玺

地图底图 `yuxi`：⬜ 缺

| 状态 | key | 用在 |
|---|---|---|
| ✅ 正式 | `caiwenji` | 剧情立绘 |
| ✅ 正式 | `fengfuren` | 剧情立绘 |

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `qiaorui` | 桥蕤 |
| ⬜ 缺 | `chenlan` | 陈兰 |
| ⬜ 缺 | `leibo` | 雷薄 |
| ⬜ 缺 | `jiling` | 纪灵 |
| ⬜ 缺 | `yuanshu` | 袁术 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ✅ | — | 都有了 |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ✅ 已有 | `guanjun` | 官军（官军） |
| ✅ 已有 | `shuizei_scout` | 水贼喽啰（水贼喽啰） |
| ✅ 已有 | `xiliang_scout` | 截粮（西凉斥候） |
| ✅ 已有 | `tiger` | 打虎（吊睛白额虎） |
| ✅ 已有 | `shanzei_band` | 山贼（山贼） |
| ✅ 已有 | `huangjin_remnant` | 黄巾余孽（黄巾余孽） |
| ✅ 已有 | `biwu` | 擂台·鲍三娘（鲍三娘） |
| ⬜ 缺 | `c3_shanfei` | 独眼匪首（独眼匪首） |
| ⬜ 缺 | `c3_xunluo` | 城外·袁军步卒（袁军步卒） |
| ⬜ 缺 | `c3_mitan` | 酒楼外·袁军密探（袁军密探） |
| ⬜ 缺 | `c3_gongshou` | 岔路·袁军弓手（袁军弓手） |
| ⬜ 缺 | `c3_qiaorui` | 城外·桥蕤（桥蕤） |
| ⬜ 缺 | `c3_qibing` | 雨夜·袁军骑兵（袁军骑兵） |
| ⬜ 缺 | `c3_chenlan` | 夜袭·陈兰（陈兰） |
| ⬜ 缺 | `c3_leibo` | 山道追兵·雷薄（雷薄） |
| ⬜ 缺 | `c3_jiling` | 山口·纪灵（纪灵） |
| ⬜ 缺 | `c3_yuanshu` | 袁术（袁术） |

剧情 CG（`pics/source/cg/<key>.jpg`，横版 16:9）

| 状态 | key | 剧情格 |
|---|---|---|
| ⬜ 缺 | `c3_leave` | 出洛阳 |
| ⬜ 缺 | `c3_wenji` | 蔡文姬 |
| ⬜ 缺 | `c3_supply` | 断粮 |
| ⬜ 缺 | `c3_slip` | 说漏嘴 |
| ⬜ 缺 | `c3_entrust` | 托玺 |
| ⬜ 缺 | `c3_warn` | 劝阻 |
| ⬜ 缺 | `c3_feng` | 冯夫人 |
| ⬜ 缺 | `c3_raid` | 夜袭 |
| ⬜ 缺 | `c3_news` | 噩耗 |
| ⬜ 缺 | `c3_end` | 玉碎 |
| ⬜ 缺 | `end_yusui` | 结局卡「结局一 · 玉碎」 |

奇遇插图（这一章第一次会抽到的「？」事件）

| 状态 | key | 事件 |
|---|---|---|
| ⬜ 缺 | `e_yuan_tax` | 「袁术的税吏」 |
| ⬜ 缺 | `e_black_market` | 「南阳黑市」 |
| ⬜ 缺 | `e_jz_spy` | 「荆州细作」 |
| ⬜ 缺 | `e_veterans` | 「孙家旧部」 |
| ⬜ 缺 | `e_plague` | 「疫村」 |
| ⬜ 缺 | `e_yuxi_rumor` | 「玉玺流言」 |

## 第三章 · 驻守洛阳

地图底图 `shouluoyang`：⬜ 缺

| 状态 | key | 用在 |
|---|---|---|
| ⬜ 缺 | `zhujun` | 剧情立绘 |

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ✅ | — | 都有了 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ✅ | — | 都有了 |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ✅ 已有 | `shuizei_scout` | 水贼喽啰（水贼喽啰） |
| ✅ 已有 | `xiliang_scout` | 截粮（西凉斥候） |
| ✅ 已有 | `shanzei_band` | 山贼（山贼） |
| ✅ 已有 | `huangjin_remnant` | 黄巾余孽（黄巾余孽） |
| ✅ 已有 | `biwu` | 擂台·鲍三娘（鲍三娘） |
| ⬜ 缺 | `c4_guosi` | 劫粮·郭汜（郭汜） |
| ✅ 已有 | `xiliang_youqi` | 西凉游骑（西凉游骑） |
| ⬜ 缺 | `c4_liumin` | 废墟·暴动流民（暴动流民） |

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

地图底图 `changan`：⬜ 缺

| 状态 | key | 用在 |
|---|---|---|
| ⬜ 缺 | `dongzhuo` | 剧情立绘 |
| ✅ 正式 | `lvlingqi` | 剧情立绘 |
| ⬜ 缺 | `xiandi` | 剧情立绘 |
| ⬜ 缺 | `caiyong` | 剧情立绘 |
| ⬜ 缺 | `wangyun` | 剧情立绘 |
| ✅ 正式 | `diaochan` | 剧情立绘 |

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `fanchou` | 樊稠 |
| ⬜ 缺 | `zhangji` | 张济 |
| ⬜ 缺 | `niufu` | 牛辅 |
| ⬜ 缺 | `huzhen` | 胡轸 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ⬜ 缺 | `huangfusong` | 皇甫嵩 |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ✅ 已有 | `shuizei_scout` | 水贼喽啰（水贼喽啰） |
| ✅ 已有 | `xiliang_youqi` | 西凉游骑（西凉游骑） |
| ⬜ 缺 | `c5_fanchou` | 比武·樊稠（樊稠） |
| ⬜ 缺 | `c5_zhangji` | 比武·张济（张济） |
| ⬜ 缺 | `c5_niufu` | 比武·牛辅（牛辅） |
| ⬜ 缺 | `c5_qinbing` | 后园·吕布亲兵（吕布亲兵） |
| ⬜ 缺 | `c5_hall` | 喜堂·飞熊军（飞熊军） |
| ✅ 已有 | `feixiong` | 飞熊军（飞熊军） |
| ⬜ 缺 | `c5_huzhen` | 内门·胡轸（胡轸） |
| ⬜ 缺 | `c5_dongzhuo` | 未央宫前·董卓（董卓） |

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

## 第四章 · 挟天子

地图底图 `dongui`：⬜ 缺

| 状态 | key | 用在 |
|---|---|---|
| ⬜ 缺 | `xunyou` | 剧情立绘 |
| ⬜ 缺 | `zhongyao` | 剧情立绘 |
| ⬜ 缺 | `jiaxu` | 剧情立绘 |
| 🟡 占位 | `xuhuang` | 剧情立绘 |
| ✅ 正式 | `wujing` | 剧情立绘 |
| 🟡 占位 | `huangzhong` | 剧情立绘 |
| ⬜ 缺 | `gaoshun` | 剧情立绘 |

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `zhangxiu` | 「北地枪王」张绣 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ⬜ 缺 | `xianzhen` | 陷阵营（高顺的卡） |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ✅ 已有 | `shuizei_scout` | 水贼喽啰（水贼喽啰） |
| ✅ 已有 | `xiliang_scout` | 截粮（西凉斥候） |
| ✅ 已有 | `guanjun` | 官军（官军） |
| ✅ 已有 | `shanzei_band` | 山贼（山贼） |
| ✅ 已有 | `biwu` | 擂台·鲍三娘（鲍三娘） |
| ✅ 已有 | `xiliang_youqi` | 西凉游骑（西凉游骑） |
| ⬜ 缺 | `c6_shaoka` | 清明门·哨卡（司徒哨卡） |
| ⬜ 缺 | `c6_zhangxiu` | 渭水桥·张绣（「北地枪王」张绣） |
| ⬜ 缺 | `c6_zhangji` | 渭水营·张济（张济） |
| ⬜ 缺 | `c6_fubing` | 长街·司徒府兵（司徒府兵） |
| ⬜ 缺 | `c6_fanchou` | 山道·樊稠（樊稠） |
| ⬜ 缺 | `c6_lijue` | 函谷关·李傕（李傕） |
| ⬜ 缺 | `c3_xunluo` | 城外·袁军步卒（袁军步卒） |
| ⬜ 缺 | `c7_qiaorui` | 营寨·桥蕤（桥蕤） |
| ⬜ 缺 | `c3_gongshou` | 岔路·袁军弓手（袁军弓手） |
| ⬜ 缺 | `c7_leibo` | 山道·雷薄（雷薄） |
| ⬜ 缺 | `c7_chenlan` | 宛城城下·陈兰（陈兰） |
| ⬜ 缺 | `c7_jiling` | 宛城·纪灵（纪灵） |
| ⬜ 缺 | `c4_gaoshun` | 后门·高顺（高顺） |
| ⬜ 缺 | `c4_langqi` | 长街·并州狼骑（并州狼骑） |
| ⬜ 缺 | `c6_xianzhen` | 宣平门前·陷阵营兵（陷阵营兵） |
| ⬜ 缺 | `c4_lvbu` | 宣平门·吕布（吕布） |

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
| ⬜ 缺 | `end_tonggui` | 结局卡「结局二 · 同归」 |

## 第五章 · 荆襄风云

地图底图 `jingxiang`：⬜ 缺

| 状态 | key | 用在 |
|---|---|---|
| ⬜ 缺 | `simahui` | 事件「水镜先生」 |
| ⬜ 缺 | `pangdegong` | 事件「岘山老农」 |
| ⬜ 缺 | `huangchengyan` | 事件「沔南名士」 |
| 🟡 占位 | `ganning` | 事件「锦帆游侠」 |
| ⬜ 缺 | `kuaiyue` | 剧情立绘 |
| ⬜ 缺 | `caifuren` | 剧情立绘 |
| ⬜ 缺 | `caimao` | 剧情立绘 |
| ⬜ 缺 | `liubiao` | 剧情立绘 |

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `jingzhou_gong` | 荆州弓手 |
| ⬜ 缺 | `huangzu` | 江夏太守黄祖 |
| ⬜ 缺 | `jinfan_zei` | 锦帆贼 |
| ⬜ 缺 | `zongzei` | 宗贼 |
| ⬜ 缺 | `jingzhou_bu` | 荆州步卒 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ⬜ 缺 | `jingzhou_shuijun` | 荆州水军（荆州水军的卡） |
| ⬜ 缺 | `caifu_nu` | 蔡府连弩手（蔡府连弩手的卡） |
| ⬜ 缺 | `yizhe` | 医者 |
| ⬜ 缺 | `chaniang` | 茶娘 |
| ⬜ 缺 | `wenpin` | 文聘·荆州大将 |
| ⬜ 缺 | `yiji` | 伊籍 |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `jx_ganning` | 汉水·甘宁（「锦帆游侠」甘宁） |
| ✅ 已有 | `shanzei_band` | 山贼（山贼） |
| ✅ 已有 | `biwu` | 擂台·鲍三娘（鲍三娘） |
| ⬜ 缺 | `jx_bubing` | 淯水北岸·荆州步卒（荆州步卒） |
| ⬜ 缺 | `jx_gongshou` | 芦苇荡·荆州弓手（荆州弓手） |
| ⬜ 缺 | `jx_huangzu` | 淯水·黄祖（江夏太守黄祖） |
| ⬜ 缺 | `jx_jinfan` | 汉水渡口·锦帆贼（锦帆贼） |
| ⬜ 缺 | `jx_zongzei` | 新野·宗贼（宗贼） |
| ⬜ 缺 | `jx_shuijun` | 水寨·荆州水军（荆州水军） |
| ⬜ 缺 | `jx_nushou` | 水阁·蔡府连弩手（蔡府连弩手） |
| ⬜ 缺 | `jx_caimao_a` | 水阁·独眼蔡瑁（独眼蔡瑁） |
| ⬜ 缺 | `jx_caimao_b` | 水阁·蔡瑁（水军都督蔡瑁） |

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
| ⬜ 缺 | `end_henhai` | 结局卡「结局三 · 恨海」 |

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
| ⬜ 缺 | `xiaoqiao` | 小乔（SR） |
| ⬜ 缺 | `zhenmi` | 甄宓（SR） |
| 🟡 占位 | `machao` | 马超（SR） |
| 🟡 占位 | `zhangliao` | 张辽（SR） |
| 🟡 占位 | `xuchu` | 许褚（SR） |
| 🟡 占位 | `pangtong` | 庞统（SR） |
| ⬜ 缺 | `daqiao` | 大乔（SR） |
| ⬜ 缺 | `huangyueying` | 黄月英（SR） |
| ⬜ 缺 | `zhangyan` | 张燕（SR） |
| 🟡 占位 | `zhaoyun` | 赵云（SSR） |
| 🟡 占位 | `sunshangxiang` | 孙尚香（SSR） |
| 🟡 占位 | `dianwei` | 典韦（SSR） |
| 🟡 占位 | `zhugeliang` | 诸葛亮（SSR） |
| ✅ 正式 | `huanggai` | 黄盖（SR） |
| 🟡 占位 | `lvmeng` | 吕蒙（SR） |
| 🟡 占位 | `taishici` | 太史慈（SR） |
| ⬜ 缺 | `luxun` | 陆逊（SSR） |
| ⬜ 缺 | `zhurong` | 祝融·南中女王（SSR） |
| ⬜ 缺 | `mayunlu` | 马云騄（SR） |
| ⬜ 缺 | `wangyi` | 王异（SR） |
| ⬜ 缺 | `xinxianying` | 辛宪英（SR） |
| ⬜ 缺 | `bianfuren` | 卞夫人（SR） |
| 🟡 占位 | `zhangjiao` | 张角（SSR） |
| ⬜ 缺 | `dongfeng` | 董奉（R） |
| ⬜ 缺 | `zhangzhao` | 张昭（R） |
| ⬜ 缺 | `bulianshi` | 步练师（R） |
| ⬜ 缺 | `qiaoguolao` | 乔国老（R） |
| ⬜ 缺 | `zhoucang` | 周仓（R） |
| 🟡 占位 | `liaohua` | 廖化（R） |
| 🟡 占位 | `madai` | 马岱（R） |
| ⬜ 缺 | `wangping` | 王平（R） |
| ⬜ 缺 | `lidian` | 李典（R） |
| ⬜ 缺 | `jiangqin` | 蒋钦（R） |
| ✅ 正式 | `chenwu` | 陈武（R） |
| 🟡 占位 | `jianyong` | 简雍（R） |
| 🟡 占位 | `mizhu` | 糜竺（R） |
| ⬜ 缺 | `sunqian` | 孙乾（R） |
| ⬜ 缺 | `guanhai` | 管亥（R） |
| ⬜ 缺 | `peiyuanshao` | 裴元绍（R） |
| ✅ 正式 | `chengpu` | 程普·程公（R） |
| ✅ 正式 | `handang` | 韩当（R） |
| ✅ 正式 | `zhuzhi` | 朱治·君理（R） |
| ✅ 正式 | `sunben` | 孙贲（R） |
| ✅ 正式 | `sunjing` | 孙静（R） |
| ⬜ 缺 | `yanfuren` | 严夫人（R） |
| ⬜ 缺 | `liniang` | 黎娘·山越女王（R） |
