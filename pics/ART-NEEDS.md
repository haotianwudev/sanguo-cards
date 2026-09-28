# 美术需求

> 本文件由 `sanguo-art` 根据游戏数据（godot/data）和 `pics/art.json` 自动生成，别手改。
> 卡框、地图、宝物图标等非立绘需求见 `CARD-DESIGN.md`。

## 怎么换图

1. 把原图放进 `pics/source/` 对应的子文件夹（generals 武将 / soldiers 兵卡 / map 地图），文件名用 key（如 `langlijiao.jpg`）。
2. 在 `pics/art.json` 的 `portraits` 里加一行：`"<key>": {"src": "source/generals/<key>.jpg", "face": [x, y], "head": h}`
   - `face`：脸中心在图里的位置（0–1，左上角是 0,0）；`head`：头高占整图高的比例（越大人物越小）
   - 换掉占位图时，把 `"placeholder": true` 删掉
3. 运行 `sanguo-art`。

规格：竖版 5:7（≥ 1000×1400），人物居中、脸在上 1/3，半身到全身，背景简单。

状态：✅ 正式美术　🟡 占位图（清代绣像等公有领域图）　⬜ 缺

## 第一章 · 富春

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
| ⬜ 缺 | `shanzei_bing` | 山贼 |
| ✅ 正式 | `huangjin_nanxia` | 黄巾余孽 |
| ⬜ 缺 | `inf_n` | 官军 |
| ✅ 正式 | `boar` | 野猪 |
| ✅ 正式 | `langlijiao` | 「浪里蛟」胡玉 |
| ✅ 正式 | `yaodao` | 妖道唐周 |
| ✅ 正式 | `heyi` | 黄巾渠帅何仪 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ✅ 正式 | `yezhu_bing` | 野猪兵（野猪的卡） |
| ✅ 正式 | `danyang` | 丹阳兵 |
| ✅ 正式 | `changsha` | 长沙刀兵 |
| ⬜ 缺 | `jiangdong_gong` | 江东弓手 |
| ⬜ 缺 | `liehu` | 山中猎户 |
| ⬜ 缺 | `yuenv_gong` | 越女弓手 |
| ✅ 正式 | `huangjin_nvyi` | 黄巾女医 |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `shuizei_scout` | 水贼喽啰（水贼喽啰） |
| ⬜ 缺 | `tiger` | 打虎（吊睛白额虎） |
| ⬜ 缺 | `yuji_xintu` | 于吉信徒（于吉信徒） |
| ⬜ 缺 | `shanzei_band` | 山贼（山贼） |
| ⬜ 缺 | `yanzhihu` | 山寨·胭脂虎（「胭脂虎」） |
| ⬜ 缺 | `huangjin_remnant` | 黄巾余孽（黄巾余孽） |
| ⬜ 缺 | `guanjun` | 官军（官军） |
| ⬜ 缺 | `boar` | 野猪林（野猪） |
| ⬜ 缺 | `shuizei` | 水寨·胡玉（「浪里蛟」胡玉） |
| ⬜ 缺 | `shuizei_guard` | 看门水贼（看门水贼） |
| ⬜ 缺 | `yaodao` | 妖道唐周（妖道唐周） |
| ⬜ 缺 | `shuizei_main` | 水贼大寨（黄巾渠帅何仪） |

## 第二章 · 讨伐董卓

| 状态 | key | 用在 |
|---|---|---|
| ✅ 正式 | `tangji` | 事件「落难贵人」 |
| ✅ 正式 | `zumao` | 剧情立绘 |
| ✅ 正式 | `sunjian` | 剧情立绘 |
| ✅ 正式 | `dongbai` | 剧情立绘 |
| 🟡 占位 | `lvbu` | 剧情立绘 |
| 🟡 占位 | `liubei` | 剧情立绘 |
| 🟡 占位 | `guanyu` | 剧情立绘 |
| ✅ 正式 | `zhangfei` | 剧情立绘 |

敌人（战斗界面上方；和它的卡共用一张图）

| 状态 | key | 敌人 |
|---|---|---|
| ✅ 正式 | `xiliang_bing` | 西凉斥候 |
| ✅ 正式 | `guosi` | 郭汜 |
| ✅ 正式 | `huaxiong` | 华雄 |
| ✅ 正式 | `feixiong_bing` | 飞熊军 |
| ✅ 正式 | `liru` | 李儒 |
| ✅ 正式 | `lijue` | 李傕 |

能拿到的卡

| 状态 | key | 卡 |
|---|---|---|
| ✅ 正式 | `gongnv` | 宫女 |
| ✅ 正式 | `xiliang_nvbing` | 西凉女亲兵 |

战斗背景（`pics/source/battles/<key>.jpg`，横版 16:9）

| 状态 | key | 战斗 |
|---|---|---|
| ⬜ 缺 | `shuizei_scout` | 水贼喽啰（水贼喽啰） |
| ⬜ 缺 | `xiliang_scout` | 截粮（西凉斥候） |
| ⬜ 缺 | `tiger` | 打虎（吊睛白额虎） |
| ⬜ 缺 | `xiliang_youqi` | 西凉游骑（西凉游骑） |
| ⬜ 缺 | `shanzei_band` | 山贼（山贼） |
| ⬜ 缺 | `yanzhihu` | 山寨·胭脂虎（「胭脂虎」） |
| ⬜ 缺 | `huangjin_remnant` | 黄巾余孽（黄巾余孽） |
| ⬜ 缺 | `guanjun` | 官军（官军） |
| ⬜ 缺 | `guosi` | 郭汜（郭汜） |
| ⬜ 缺 | `huaxiong` | 汜水关·华雄（华雄） |
| ⬜ 缺 | `feixiong` | 飞熊军（飞熊军） |
| ⬜ 缺 | `liru` | 李儒伏兵（李儒） |
| ⬜ 缺 | `dongbai` | 董白（董白） |
| ⬜ 缺 | `hulao_ch1` | 追兵·吕布（吕布） |
| ⬜ 缺 | `lijue` | 洛阳城门·李傕（李傕） |

## 其余武将（招募池，按需再画）

| 状态 | key | 卡 |
|---|---|---|
| 🟡 占位 | `machao` | 马超（SR） |
| 🟡 占位 | `zhangliao` | 张辽（SR） |
| 🟡 占位 | `xuhuang` | 徐晃（SR） |
| 🟡 占位 | `huangzhong` | 黄忠（SR） |
| 🟡 占位 | `ganning` | 甘宁（SR） |
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
| 🟡 占位 | `diaochan` | 貂蝉（SSR） |
| ⬜ 缺 | `xurong` | 徐荣（SR） |
| 🟡 占位 | `zhangjiao` | 张角（SSR） |
| ⬜ 缺 | `zhoucang` | 周仓（R） |
| 🟡 占位 | `liaohua` | 廖化（R） |
| 🟡 占位 | `madai` | 马岱（R） |
| ⬜ 缺 | `wangping` | 王平（R） |
| ⬜ 缺 | `lidian` | 李典（R） |
| ⬜ 缺 | `jiangqin` | 蒋钦（R） |
| ⬜ 缺 | `chenwu` | 陈武（R） |
| 🟡 占位 | `jianyong` | 简雍（R） |
| 🟡 占位 | `mizhu` | 糜竺（R） |
| ⬜ 缺 | `sunqian` | 孙乾（R） |
| ⬜ 缺 | `guanhai` | 管亥（R） |
| ⬜ 缺 | `peiyuanshao` | 裴元绍（R） |
| ✅ 正式 | `chengpu` | 程普·程公（R） |
| ✅ 正式 | `handang` | 韩当（R） |
| ⬜ 缺 | `zhuzhi` | 朱治·君理（R） |
| ⬜ 缺 | `wujing` | 吴景（R） |
| ⬜ 缺 | `sunben` | 孙贲（R） |
| ⬜ 缺 | `sunjing` | 孙静（R） |
