# 美术需求

> 本文件由 `sanguo-art` 根据 `pics/art.json` 自动生成，别手改——改 `art.json` 然后重新运行。

## 怎么换图

1. 把图放进 `pics/`（任意尺寸，jpg / png）。
2. 在 `pics/art.json` 的 `portraits` 里改（或加）一行：
   `"<key>": {"src": "文件名.jpg", "face": [x, y], "head": h}`
   - `face`：脸中心在图里的位置（0–1，左上角是 0,0）；`head`：头高占整图高的比例（半身像约 0.2，全身像约 0.07–0.12）
   - 换掉占位图时，把 `"placeholder": true` 删掉
3. 运行 `sanguo-art`：自动缩图、更新游戏里的头像、重新生成本文件和 `SOURCES.md`。

## 图片规格

- 竖版立绘，约 3:4，最短边 ≥ 600px。界面里的头像框都是竖的：卡牌和队长卡取胸像，剧情取半身，卡册显示整张。
- 脸要清楚：终端里头像只有约 15×10 个色块，半身像、背景简单的图效果最好。
- 同一人的不同版本（孙策·少年 / 孙策·中年）默认共用一个 key；想分开就用卡牌 id 做 key（如 `sunce_zhong`）。
- ⚠️ 版权：`sun jian.png` 疑似光荣官方立绘、主公占位图是兰斯系列主角立绘，公开发布前要换掉（吴国太已换成自有图）。占位图的来源和协议见 `SOURCES.md`。

状态：✅ 正式美术　🟡 占位图（清代绣像等公有领域图，可用但风格不统一）　⬜ 缺

## 剧情人物

| 状态 | key | 卡牌 |
|---|---|---|
| 🟡 占位 | `lord` | **主公 / 穿越者**（玩家自己，现代人穿越到东汉末年） |
| 🟡 占位 | `huanggai` | 黄盖（SR·刀兵） |
| ✅ 正式 | `sunce` | 孙策·少年（SR·骑兵） / 孙策·中年（SSR·骑兵） |
| ✅ 正式 | `wuguotai` | 吴国太（SR·后勤） |
| ✅ 正式 | `zhouyu` | 周瑜·少年（SR·谋士） / 周瑜·赤壁（SSR·谋士） |

## 敌人（战斗界面上方）

| 状态 | key | 敌人 |
|---|---|---|
| ⬜ 缺 | `shanzei_scout` | 山贼斥候 |
| ⬜ 缺 | `huangjin_vanguard` | 黄巾前锋 |
| ⬜ 缺 | `huaxiong` | 华雄 |
| ⬜ 缺 | `shanzeituan` | 山贼团 |
| 🟡 占位 | `zhangjiao` | 黄巾军·张角 |
| 🟡 占位 | `lvbu` | 吕布 |

## 兵种（兵卡和没有立绘时的占位）

| 状态 | key | 兵种 |
|---|---|---|
| ⬜ 缺 | `troop_cavalry` | 骑兵 |
| ⬜ 缺 | `troop_spear` | 枪兵 |
| ⬜ 缺 | `troop_archer` | 弓兵 |
| ⬜ 缺 | `troop_infantry` | 刀兵 |
| ⬜ 缺 | `troop_strategist` | 谋士 |
| ⬜ 缺 | `troop_logistics` | 后勤 |

## SSR

| 状态 | key | 卡牌 |
|---|---|---|
| 🟡 占位 | `dianwei` | 典韦（SSR·刀兵） |
| 🟡 占位 | `diaochan` | 貂蝉（SSR·后勤） |
| 🟡 占位 | `guanyu` | 关羽（SSR·骑兵） |
| ⬜ 缺 | `luxun` | 陆逊（SSR·谋士） |
| ✅ 正式 | `sunjian` | 孙坚（SSR·刀兵） |
| 🟡 占位 | `sunshangxiang` | 孙尚香（SSR·弓兵） |
| 🟡 占位 | `zhaoyun` | 赵云（SSR·枪兵） |
| 🟡 占位 | `zhugeliang` | 诸葛亮（SSR·谋士） |

## SR

| 状态 | key | 卡牌 |
|---|---|---|
| ⬜ 缺 | `daqiao` | 大乔（SR·后勤） |
| 🟡 占位 | `ganning` | 甘宁（SR·弓兵） |
| ⬜ 缺 | `huangyueying` | 黄月英（SR·后勤） |
| 🟡 占位 | `huangzhong` | 黄忠（SR·弓兵） |
| 🟡 占位 | `liubei` | 刘备（SR·刀兵） |
| 🟡 占位 | `lvmeng` | 吕蒙（SR·刀兵） |
| 🟡 占位 | `machao` | 马超（SR·骑兵） |
| 🟡 占位 | `pangtong` | 庞统（SR·谋士） |
| 🟡 占位 | `taishici` | 太史慈（SR·弓兵） |
| 🟡 占位 | `xuchu` | 许褚（SR·刀兵） |
| 🟡 占位 | `xuhuang` | 徐晃（SR·枪兵） |
| ⬜ 缺 | `zhangfei` | 张飞（SR·枪兵） |
| 🟡 占位 | `zhangliao` | 张辽（SR·骑兵） |

## R

| 状态 | key | 卡牌 |
|---|---|---|
| ⬜ 缺 | `jiangqin` | 蒋钦（R·弓兵） |
| 🟡 占位 | `jianyong` | 简雍（R·谋士） |
| 🟡 占位 | `liaohua` | 廖化（R·刀兵） |
| ⬜ 缺 | `lidian` | 李典（R·枪兵） |
| 🟡 占位 | `madai` | 马岱（R·骑兵） |
| 🟡 占位 | `mizhu` | 糜竺（R·后勤） |
| ⬜ 缺 | `sunqian` | 孙乾（R·后勤） |
| ⬜ 缺 | `wangping` | 王平（R·枪兵） |
| ⬜ 缺 | `zhoucang` | 周仓（R·刀兵） |
