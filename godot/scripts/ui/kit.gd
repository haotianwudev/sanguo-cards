class_name Kit
extends RefCounted
## Shared look: palette (from data/ui.json), styleboxes, portraits, small animation helpers.

const FONT_BODY := 22
const FONT_SMALL := 18
const FONT_BIG := 30
const FONT_TITLE := 44

static var _pal: Dictionary = {}
static var _textures: Dictionary = {}


static func pal() -> Dictionary:
	if _pal.is_empty():
		use_theme(GameData.get_db().ui.get("default_theme", "light"))
	return _pal


static func use_theme(name: String) -> void:
	var src: Dictionary = GameData.get_db().ui["themes"][name]
	_pal.clear()
	for k in src:
		_pal[k.replace("-", "_")] = Color(src[k])


static func c(name: String) -> Color:
	return pal()[name]


static func rarity_color(rarity: Variant) -> Color:
	var key: String = "lord" if rarity == null else str(rarity)
	return c(GameData.get_db().ui["rarity_colors"].get(key, "gray"))


static func rarity_label(rarity: Variant) -> String:
	var key: String = "lord" if rarity == null else str(rarity)
	return GameData.get_db().ui["rarity_labels"].get(key, key)


# ---- styles ------------------------------------------------------------------

static func box(bg: Color, radius := 12, border := 0, border_color := Color.TRANSPARENT, pad := 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(border)
	sb.border_color = border_color
	sb.set_content_margin_all(pad)
	sb.anti_aliasing = true
	return sb


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = FONT_BODY
	var body := load("res://data/fonts/body.ttf") as Font  # bundled 思源黑体: phones and the web have no CJK font
	if body != null:
		t.default_font = body
		ThemeDB.fallback_font = body
	t.set_color("font_color", "Label", c("text"))
	t.set_color("default_color", "RichTextLabel", c("text"))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var bg := c("blue")
		match state:
			"hover":
				bg = c("blue").lightened(0.12)
			"pressed":
				bg = c("blue").darkened(0.15)
			"disabled":
				bg = c("track")
		var sb := box(bg, 10, 0, Color.TRANSPARENT, 14)
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		if state == "focus":
			sb = box(Color.TRANSPARENT, 10, 3, c("gold"), 14)
		t.set_stylebox(state, "Button", sb)
	t.set_color("font_color", "Button", Color.WHITE)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_focus_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", c("dim"))
	t.set_stylebox("panel", "PanelContainer", box(c("card"), 14, 1, c("border"), 16))
	t.set_stylebox("normal", "LineEdit", box(c("card"), 10, 2, c("border"), 12))
	t.set_stylebox("focus", "LineEdit", box(c("card"), 10, 3, c("gold"), 12))
	t.set_color("font_color", "LineEdit", c("text"))
	t.set_color("font_placeholder_color", "LineEdit", c("dim"))
	t.set_color("caret_color", "LineEdit", c("text"))
	var bg := box(c("track"), 8, 0, Color.TRANSPARENT, 0)
	var fill := box(c("green"), 8, 0, Color.TRANSPARENT, 0)
	t.set_stylebox("background", "ProgressBar", bg)
	t.set_stylebox("fill", "ProgressBar", fill)
	return t


static func button(text: String, color_name := "blue", size := FONT_BODY) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	if color_name != "blue":
		var base := c(color_name)
		b.add_theme_stylebox_override("normal", box(base, 10, 0, Color.TRANSPARENT, 14))
		b.add_theme_stylebox_override("hover", box(base.lightened(0.12), 10, 0, Color.TRANSPARENT, 14))
		b.add_theme_stylebox_override("pressed", box(base.darkened(0.15), 10, 0, Color.TRANSPARENT, 14))
		if base.get_luminance() > 0.5:  # light buttons (gold) get dark text
			for st in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
				b.add_theme_color_override(st, Color(0.1, 0.07, 0.04))
	b.custom_minimum_size = Vector2(0, 56)
	return b


static func label(text: String, size := FONT_BODY, color_name := "text") -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", c(color_name))
	return l


static func bar(value: float, max_value: float, color_name := "green", height := 22) -> ProgressBar:
	var p := ProgressBar.new()
	p.max_value = max_value
	p.value = value
	p.show_percentage = false
	p.custom_minimum_size = Vector2(0, height)
	var trail := ProgressBar.new()  # damage-trail underbar: holds briefly on a hit so the chunk lost shows in bright ivory
	trail.name = "Trail"
	trail.show_behind_parent = true
	trail.set_anchors_preset(Control.PRESET_FULL_RECT)
	trail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trail.max_value = max_value
	trail.value = value
	trail.show_percentage = false
	trail.add_theme_stylebox_override("background", box(c("track"), height / 2, 0, Color.TRANSPARENT, 0))
	trail.add_theme_stylebox_override("fill", box(Color(1.0, 0.93, 0.76, 0.92), height / 2, 0, Color.TRANSPARENT, 0))
	p.add_child(trail)
	p.add_theme_stylebox_override("background", box(Color.TRANSPARENT, height / 2, 0, Color.TRANSPARENT, 0))
	p.add_theme_stylebox_override("fill", box(c(color_name), height / 2, 0, Color.TRANSPARENT, 0))
	return p


# ---- card frames ---------------------------------------------------------------

static func frame(kind: String) -> Dictionary:
	## Frame art for a rarity ("N", "R", "SR", "SSR", "lord") or "enemy":
	## {texture, window: Rect2 (fractions), plate: Rect2 (fractions)} — empty if none is configured.
	var key := "frame:" + kind
	if _textures.has(key):
		return _textures[key]
	var out := {}
	var cfg: Dictionary = GameData.get_db().ui.get("card", {})
	var name: String = cfg.get("frames", {}).get(kind, "")
	var index_path := "res://data/art/frames/frames.json"
	if name != "" and FileAccess.file_exists(index_path):
		var idx: Dictionary = GameData.read_json(index_path)
		if idx.has(name):
			var e: Dictionary = idx[name]
			var w: Array = e["window"]
			var p: Array = cfg.get("plates", {}).get(name, cfg.get("plate", [0.29, 0.875, 0.42, 0.075]))
			out = {"name": name, "texture": load("res://data/art/frames/" + e["file"]),
				"window": Rect2(w[0], w[1], w[2], w[3]), "plate": Rect2(p[0], p[1], p[2], p[3]),
				"has_plate": cfg.get("plates", {}).has(name),
				"badge": Vector2(cfg.get("badges", {}).get(name, [0.09, 0.07])[0], cfg.get("badges", {}).get(name, [0.09, 0.07])[1]),
				"badge_size": float(cfg.get("badge_size", 0.19))}
	_textures[key] = out
	return out


static func name_style(frame_name: String) -> Dictionary:
	var styles: Dictionary = GameData.get_db().ui.get("card", {}).get("name_styles", {})
	return styles.get(frame_name, styles.get("none", {"color": "#ffffff", "outline": "#000000"}))


static func name_font(size: int, spacing: int) -> Font:
	## The calligraphic font for card names: the bundled 霞鹜文楷 (tools/build_fonts.py), else the system KaiTi.
	var key := "namefont:%d:%d" % [size, spacing]
	if not _textures.has(key):
		var base := load("res://data/fonts/name.ttf") as Font
		if base == null:
			var sys := SystemFont.new()
			sys.font_names = PackedStringArray(GameData.get_db().ui.get("card", {}).get("name_font", ["KaiTi"]))
			base = sys
		var fv := FontVariation.new()
		fv.base_font = base
		fv.spacing_glyph = spacing
		fv.variation_embolden = 0.35
		_textures[key] = fv
	return _textures[key]


static func badge(troop_id: String) -> Texture2D:
	var key := "badge:" + troop_id
	if not _textures.has(key):
		var path := "res://data/art/badges/%s.png" % troop_id
		_textures[key] = load(path) if ResourceLoader.exists(path) else null
	return _textures[key]


static func relic_icon(relic_id: String) -> Texture2D:
	var key := "relic:" + relic_id
	if not _textures.has(key):
		var path := "res://data/art/relics/%s.png" % relic_id
		_textures[key] = load(path) if ResourceLoader.exists(path) else null
	return _textures[key]


static func map_icon(kind: String) -> Texture2D:
	var key := "map_icon:" + kind
	if not _textures.has(key):
		var path := "res://data/art/map/icons/%s.png" % kind
		_textures[key] = load(path) if ResourceLoader.exists(path) else null
	return _textures[key]


static func token_icon(north := false) -> Texture2D:
	## the chibi hero who walks the map: token_lord_<route>.png, else the old generic token_lord.png
	var route := "north" if north else "south"
	var key := "token:" + route
	if not _textures.has(key):
		var tex: Texture2D = null
		for path in ["res://data/art/map/token_lord_%s.png" % route, "res://data/art/map/token_lord.png"]:
			if ResourceLoader.exists(path):
				tex = load(path)
				break
		_textures[key] = tex
	return _textures[key]


static func icon(key: String) -> Texture2D:
	## a small UI icon: data/art/icons/<key>.png (stat_at / stat_hp / stat_ap, skill_*), or null
	var k := "icon:" + key
	if not _textures.has(k):
		var path := "res://data/art/icons/%s.png" % key
		_textures[k] = load(path) if ResourceLoader.exists(path) else null
	return _textures[k]


static func resist_text(e: Dictionary, bbcode := true, short := false) -> String:
	## 「物理抗性 80%　法术弱点 +100%」: a resist above 0 cuts that kind of damage, below 0 is a weakness (the enemy takes more)
	var parts: Array = []
	for k in [["phys_resist", "物理"], ["magic_resist", "法术"]]:
		var v := float(e.get(k[0], 0.0))
		if v > 0.0:
			parts.append(("%s抗 %d%%" % [k[1].left(1), int(round(v * 100))]) if short else ("%s抗性 %d%%" % [k[1], int(round(v * 100))]))
		elif v < 0.0:
			var w := "%s弱点 +%d%%" % [k[1], int(round(-v * 100))]
			parts.append(("[color=%s]%s[/color]" % [c("red").to_html(), w]) if bbcode else w)
	return (" · " if short else "　").join(parts)


const SKILL_ICONS := {"attack": "phys", "magic": "magic", "burn": "magic", "heal": "heal", "guard": "guard",
	"boost": "boost", "stun": "confuse", "break": "break", "ap": "ap",
	"counter": "guard", "hurt": "heal", "cleanse": "heal", "buff": "boost", "poison": "magic"}


static func skill_icon(skill: Dictionary) -> Texture2D:
	## the icon for a skill's first effect (物理 / 法术 / 回复 / 防御 / BOOST / 混乱 / 破防 / 加 AP)
	var effects: Array = skill.get("effects", [])
	if effects.is_empty():
		return null
	return icon("skill_" + SKILL_ICONS.get(effects[0]["type"], "phys"))


static func skill_panel(skill_ids: Array, width: float) -> VBoxContainer:
	## every skill with its icon, AP cost and what it does (the tap-to-view panel next to a big card)
	var db := GameData.get_db()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.custom_minimum_size = Vector2(width, 0)
	box.add_child(label("技　能", FONT_BODY + 2, "gold"))
	if skill_ids.is_empty():
		box.add_child(label("没有技能。", FONT_BODY, "dim"))
	for sid in skill_ids:
		var sk: Dictionary = db.skills[sid]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var ic := TextureRect.new()
		ic.texture = skill_icon(sk)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.custom_minimum_size = Vector2(24, 24)
		row.add_child(ic)
		row.add_child(label("%s　AP%d" % [sk["name"], sk["cost"]], FONT_BODY, "gold"))
		box.add_child(row)
		var d := label(skill_desc(sk), 15)
		d.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.custom_minimum_size = Vector2(width, 0)
		box.add_child(d)
	return box


static func skill_tag(sk: Dictionary) -> String:
	## the skill's type in a word, shown beside its name in battle: 每场1次 / 限N / 累积 (empty for a plain skill)
	if sk.get("per_battle", false):
		return "每场1次"
	if sk.get("uses", null) != null:
		return "限%d" % int(sk["uses"])
	if sk.get("cumulative", false):
		return "累积"
	return ""


static func skill_desc(sk: Dictionary) -> String:
	## one line on what a skill does, from its effects (for the 整备 detail panel)
	var parts: Array = []
	for e in sk.get("effects", []):
		match e["type"]:
			"attack":
				parts.append("物理攻击 ×%s%s%s%s" % [_num(e["power"]), ("，%d 连击" % int(e["hits"])) if int(e.get("hits", 1)) > 1 else "",
					("，每层连击威力 +%s（收尾）" % _num(e["per_combo"])) if e.has("per_combo") else "", "，穿甲（无视物抗）" if e.get("pierce", false) else ""])
			"magic":
				parts.append("法术攻击 ×%s%s" % [_num(e["power"]), ("（对灼烧中的敌人 ×%s）" % _num(e["burning_mult"])) if e.has("burning_mult") else ""])
			"buff":
				parts.append("战意 +1 层：全军攻击 +%d%%、受到伤害 -%d%%%s，最多 %d 层，持续 %d 回合（再用刷新）" % [int(round(float(e["atk"]) * 100)), int(round(float(e["def"]) * 100)),
					("、物理攻击附带 %d%% 法术伤害" % int(round(float(e["magic"]) * 100))) if e.has("magic") else "", int(e.get("max", 4)), int(e.get("turns", 3))])
			"poison":
				parts.append("中毒 +%d 层：每层每回合损失最大体力的 %d%%，最多 %d 层，%d 回合（吃法抗，再中刷新）" % [int(e.get("stacks", 1)), int(round(float(e["pct"]) * 100)), int(e.get("max", 5)), int(e.get("turns", 3))])
			"cleanse":
				parts.append("解除我军的异常状态（混乱、灼烧、AP 被夺）")
			"counter":
				parts.append("反击：本回合敌人每打中一次，还击 ×%s" % _num(e["power"]))
			"hurt":
				parts.append("自损全军 %d%% 体力" % int(round(float(e["pct"]) * 100)))
			"heal":
				parts.append("回复全军体力 ×%s" % _num(e["power"]))
			"guard":
				parts.append("本回合受到伤害 -%d%%" % int(round(float(e["cut"]) * 100)))
			"boost":
				parts.append({"all": "全军 BOOST", "random_idle": "随机让一个还没出手的队友 BOOST"}.get(e.get("target", ""), "自己 BOOST（下次出手 ×1.5）"))
			"stun":
				parts.append("%d%% 让敌人眩晕一回合" % int(round(float(e["chance"]) * 100)))
			"ap":
				parts.append("AP +%d" % int(e["amount"]))
			"loot":
				parts.append("战利品：每用一次，打赢后多掉一个宝箱的几率 +%d%%，宝箱里多一张可选卡的几率 +%d%%（本场累计）" % [int(round(float(e["chest"]) * 100)), int(round(float(e["card"]) * 100))])
			"burn":
				if e.has("pct"):
					parts.append("灼烧：每回合烧掉敌人现有体力的 %d%%（烧不死），%d 回合" % [int(round(float(e["pct"]) * 100)), int(e["turns"])])
				else:
					parts.append("灼烧 ×%s，%d 回合" % [_num(e["power"]), int(e["turns"])])
			"break":
				parts.append("破防：敌人受到伤害 +%d%%，%d 回合" % [int(round(float(e["amount"]) * 100)), int(e["turns"])])
	var tags: Array = []
	if sk.get("per_battle", false):
		tags.append("每场限 1 次")
	elif sk.get("uses", null) != null:
		tags.append("本章限 %d 次，到休整格才恢复" % int(sk["uses"]))
	if sk.get("cumulative", false):
		tags.append("每用一次 AP +1")
	return "；".join(parts) + (("（%s）" % "，".join(tags)) if not tags.is_empty() else "")


static func _num(x: Variant) -> String:
	var f := float(x)
	return str(int(f)) if is_equal_approx(f, round(f)) else ("%.2f" % f).rstrip("0")


static func card_back() -> Texture2D:
	var key := "card:back"
	if not _textures.has(key):
		var path := "res://data/art/frames/card_back.png"
		_textures[key] = load(path) if ResourceLoader.exists(path) else null
	return _textures[key]


# ---- portraits ---------------------------------------------------------------

static func _portrait_index() -> Dictionary:
	if not _textures.has("_index"):
		var raw: Dictionary = GameData.read_json("res://data/portraits/portraits.json")
		raw.erase("_comment")
		_textures["_index"] = raw
	return _textures["_index"]


static func portrait_key(card_id: String) -> String:
	var idx := _portrait_index()
	if card_id == "lord_north" and not idx.has("lord_north"):
		card_id = "lord"  # no north-route portrait drawn yet: fall back to the south one
	if idx.has(card_id):
		return card_id
	var card: Dictionary = GameData.get_db().cards.get(card_id, {})
	if card.has("person") and idx.has(card["person"]):
		return card["person"]
	if card_id.ends_with("_card"):
		var base := card_id.trim_suffix("_card")
		if idx.has(base):
			return base
	return ""


const ALIASES := {"吴夫人": "wuguotai", "伯符": "sunce", "孙策": "sunce", "公瑾": "zhouyu", "周瑜": "zhouyu", "文台": "sunjian", "孙坚": "sunjian", "主公": "lord",
	"左慈": "zuoci", "诸葛亮": "zhugeliang", "孔明": "zhugeliang", "诸葛瑾": "zhugejin", "子瑜": "zhugejin", "曹仁": "caoren", "夏侯惇": "xiahoudun", "胡玉": "langlijiao", "唐周": "yaodao", "何仪": "heyi", "董白": "dongbai", "刘备": "liubei",
	"关羽": "guanyu", "张飞": "zhangfei", "吕布": "lvbu", "华佗": "huatuo", "于吉": "yuji", "祖茂": "zumao",
	"王修": "wangxiu", "叔治": "wangxiu", "武安国": "wuanguo", "阎柔": "yanrou", "鲜于辅": "xianyufu", "牵招": "qianzhao", "张邈": "zhangmiao", "孟卓": "zhangmiao", "鲍信": "baoxin", "阎行": "yanxing", "彦明": "yanxing", "韩浩": "hanhao", "元嗣": "hanhao", "黄权": "huangquan", "公衡": "huangquan", "李严": "liyan", "正方": "liyan", "郭图": "guotu", "袁谭": "yuantan", "袁尚": "yuanshang", "审配": "shenpei", "曹纯": "caochun", "袁熙": "yuanxi", "辛评": "xinping", "辛毗": "xinpi", "满宠": "manchong", "黄承彦": "huangchengyan", "严舆": "yanyu", "臧洪": "zanghong", "司马徽": "simahui", "管辂": "guanlu", "程昱": "chengyu", "侯成": "houcheng", "张饶": "zhangrao", "庞德公": "pangdegong", "许劭": "xushao", "樊能": "fanneng", "杨松": "yangsong", "马良": "maliang", "许攸": "xuyou", "韩馥": "hanfu", "昌豨": "changxi", "凌操": "lingcao", "秦宜禄": "qinyilu", "公孙度": "gongsundu", "董袭": "dongxi", "徐盛": "xusheng", "潘璋": "panzhang", "孟达": "mengda", "郝萌": "haomeng", "张纮": "zhanghong", "吕范": "lvfan", "蒯良": "kuailiang", "张松": "zhangsong", "雍闿": "yongkai", "宋宪": "songxian", "田楷": "tiankai", "单经": "shanjing", "刘虞": "liuyu", "白绕": "bairao", "眭固": "suigu", "杨凤": "yangfeng", "鲍韬": "baotao", "陈容": "chenrong", "王匡": "wangkuang", "刘岱": "liudai", "孔伷": "kongzhou", "乔瑁": "qiaomao", "乐进": "yuejin", "张宝": "zhangbao_hj", "张梁": "zhangliang", "陆康": "lukang", "糜夫人": "mifuren", "曹性": "caoxing", "丁奉": "dingfeng", "戏志才": "xizhicai", "邹氏": "zoushi", "刘辟": "liupi", "龚都": "gongdu", "黄邵": "huangshao",
	# how the story first describes people before their names come up
	"美妇": "wuguotai", "浓眉少年": "sunce", "俊秀少年": "zhouyu", "瘦老头": "sunjing", "渠帅": "heyi", "孙静": "sunjing",
	"女当家": "yanzhihu", "王悦": "yanzhihu", "张宁": "zhangning", "白衣道人": "yuji", "华雄": "huaxiong", "纪灵": "jiling",
	"曹操": "caocao", "孟德": "caocao", "袁绍": "yuanshao", "袁术": "yuanshu", "冯夫人": "fengfuren", "冯氏": "fengfuren", "董卓": "dongzhuo", "蔡邕": "caiyong", "王允": "wangyun", "黑脸大汉": "zhangfei", "大耳朵": "liubei", "虎皮披风": "sunjian", "一员虎将": "sunjian", "摇羽扇的文士": "liru", "祝融": "zhurong", "吕玲绮": "lvlingqi", "马云騄": "mayunlu", "鲍三娘": "baosanniang", "王异": "wangyi", "辛宪英": "xinxianying", "蔡夫人": "caifuren", "卞夫人": "bianfuren", "严夫人": "yanfuren", "黎娘": "liniang", "严颜": "yanyan", "张任": "zhangren", "吴苋": "wuxian", "孟获": "menghuo", "刘璋": "liuzhang", "廖化": "liaohua", "关平": "guanping", "陈到": "chendao", "周仓": "zhoucang", "祖郎": "zulang", "高顺": "gaoshun", "荀攸": "xunyou", "钟繇": "zhongyao", "徐晃": "xuhuang", "黄忠": "huangzhong", "貂蝉": "diaochan", "桥蕤": "qiaorui", "雷薄": "leibo", "陈兰": "chenlan", "吴景": "wujing", "孙贲": "sunben", "汉献帝": "xiandi", "献帝": "xiandi", "小皇帝": "xiandi", "刘协": "xiandi", "朱儁": "zhujun", "朱公": "zhujun", "皇甫嵩": "huangfusong", "皇甫将军": "huangfusong", "李儒": "liru", "郭汜": "guosi", "李傕": "lijue", "樊稠": "fanchou", "张济": "zhangji", "牛辅": "niufu", "胡轸": "huzhen", "蔡文姬": "caiwenji", "唐姬": "tangji", "程普": "chengpu", "黄盖": "huanggai", "韩当": "handang", "刘表": "liubiao", "景升": "liubiao", "蔡瑁": "caimao", "德珪": "caimao", "蒯越": "kuaiyue", "黄祖": "huangzu", "文聘": "wenpin", "张允": "zhangyun", "刘磐": "liupan", "苏飞": "sufei", "贾诩": "jiaxu", "文和": "jiaxu", "张绣": "zhangxiu",
	"郭女王": "guonvwang", "郭照": "guonvwang",
	"曹洪": "caohong", "子廉": "caohong",
	"公孙瓒": "gongsunzan", "伯珪": "gongsunzan",
	"文丑": "wenchou", "颜良": "yanliang",
	"太史慈": "taishici", "子义": "taishici",
	"糜竺": "mizhu", "子仲": "mizhu",
	"糜芳": "mifang", "子方": "mifang",
	"孔融": "kongrong", "文举": "kongrong",
	"管亥": "guanhai",
	"马超": "machao", "孟起": "machao",
	"马岱": "madai",
	"乔公": "qiaoguolao", "子敬": "lusu", "甄宓": "zhenmi_young","孙尚香": "sunshangxiang", "香香": "sunshangxiang", "尚香": "sunshangxiang",  # 甄宓: young face by default; speakers() swaps in the adult `zhenmi` when the square's portraits cast her (北线第七章起)
	"吕蒙": "lvmeng_qingnian", "阿蒙": "lvmeng_qingnian", "吕子明": "lvmeng_qingnian",
	"郑大王": "zhenghao", "姜寨主": "jiangqiao"}  # 北线第四章：入队、主角起名之前只叫郑氏 / 姜氏  # the young one: the SR 吕蒙 (白衣渡江) isn't in the story yet
static func enemy_portrait_key(enemy: Dictionary) -> String:
	var key: String = enemy.get("portrait", "")
	if key == "":
		key = enemy["id"]
	return key if _portrait_index().has(key) else ""


static func fate_icon(fate_id: String) -> Texture2D:
	## a 天命 card picture (data/art/fates/<id>.png), or null (the pick shows its one-character glyph)
	var path := "res://data/art/fates/%s.png" % fate_id
	return load(path) if ResourceLoader.exists(path) else null


static func affix_icon_path(affix_id: String) -> String:
	## a 词缀 badge (data/art/affixes/<id>.png) for rich text, or "" until it's drawn
	var path := "res://data/art/affixes/%s.png" % affix_id
	return path if ResourceLoader.exists(path) else ""


static func ui_art(key: String) -> Texture2D:
	## a full-screen UI picture (data/art/ui/<key>.jpg: title, …), or null
	var path := "res://data/art/ui/%s.jpg" % key
	return load(path) if ResourceLoader.exists(path) else null


static func cg(key: String) -> Texture2D:
	## a story illustration (data/art/cg/<key>.jpg), or null until it's drawn
	var path := "res://data/art/cg/%s.jpg" % key
	return load(path) if key != "" and ResourceLoader.exists(path) else null


static func portrait(key: String, aspect: float, heads: float) -> Texture2D:
	## A crop of the portrait around the face: `aspect` = width/height of the box, `heads` = head-heights tall.
	if key == "" or not _portrait_index().has(key):  # no art yet
		return null
	var entry: Dictionary = _portrait_index()[key]
	var tex: Texture2D = _textures.get(key)
	if tex == null:
		tex = load("res://data/portraits/" + entry["file"])
		_textures[key] = tex
	var w := float(tex.get_width())
	var h := float(tex.get_height())
	var bh: float = minf(h, heads * float(entry["head"]) * h)
	var bw := bh * aspect
	if bw > w:
		bw = w
		bh = w / aspect
	var fx: float = entry["face"][0]
	var fy: float = entry["face"][1]
	var left := clampf(fx * w - bw / 2.0, 0.0, w - bw)
	var top := clampf(fy * h - 0.35 * bh, 0.0, h - bh)
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(left, top, bw, bh)
	return at


static func focus(node: Control) -> void:
	## Give keyboard / controller focus next frame, if the node is still around and focusable then.
	(func():
		if is_instance_valid(node) and node.is_inside_tree() and node.is_visible_in_tree() 				and node.focus_mode != Control.FOCUS_NONE:
			node.grab_focus()
	).call_deferred()


# ---- motion ------------------------------------------------------------------
static var _last_float_at := Vector2.ZERO
static var _last_float_ms := 0
static var _float_step := 0


static func float_text(parent: Control, at: Vector2, text: String, color: Color, size := 40) -> void:
	## A number that pops up and drifts away (damage, heals); rapid multi-hits fan out so numbers never stack on one spot.
	var now := Time.get_ticks_msec()
	if now - _last_float_ms < 320 and at.distance_to(_last_float_at) < 90.0:
		_float_step = (_float_step + 1) % 5
	else:
		_float_step = 0
	_last_float_at = at
	_last_float_ms = now
	var fan_x: float = [0.0, -48.0, 48.0, -28.0, 28.0][_float_step]
	var fan_y: float = [0.0, -18.0, -10.0, -34.0, -26.0][_float_step]
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.82))
	l.add_theme_constant_override("outline_size", 10 if size >= 52 else 8)
	l.position = at - Vector2(40, 20) + Vector2(fan_x, fan_y)
	l.z_index = 50
	parent.add_child(l)
	l.pivot_offset = Vector2(40, 20)
	var punch := 1.42 if size >= 56 else (1.24 if size >= 48 else 1.15)
	l.scale = Vector2(0.35, 0.35)
	var tw := l.create_tween()
	tw.tween_property(l, "scale", Vector2(punch, punch), 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "scale", Vector2.ONE, 0.09)
	tw.parallel().tween_property(l, "position", l.position + Vector2(fan_x * 0.35 + randf_range(-18, 18), -74), 0.72).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.25)
	tw.tween_callback(l.queue_free)


static func shake(node: Control, strength := 10.0, duration := 0.25) -> void:
	var origin := node.position
	var tw := node.create_tween()
	var steps := 6
	for i in steps:
		var k := 1.0 - float(i) / steps
		tw.tween_property(node, "position", origin + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * k,
			duration / steps)
	tw.tween_property(node, "position", origin, 0.03)


static func pop(node: Control, to := 1.08, duration := 0.12) -> void:
	node.pivot_offset = node.size / 2
	var tw := node.create_tween()
	tw.tween_property(node, "scale", Vector2(to, to), duration).set_trans(Tween.TRANS_BACK)
	tw.tween_property(node, "scale", Vector2.ONE, duration)


static func tween_bar(bar_node: ProgressBar, to: float, duration := 0.35) -> void:
	var trail := bar_node.get_node_or_null("Trail") as ProgressBar
	if trail != null:
		trail.max_value = bar_node.max_value
		var old_tw: Variant = trail.get_meta("trail_tw") if trail.has_meta("trail_tw") else null
		if old_tw is Tween and (old_tw as Tween).is_valid():
			(old_tw as Tween).kill()
		if to < bar_node.value:
			var ttw := trail.create_tween()
			ttw.tween_interval(0.18)
			ttw.tween_property(trail, "value", to, duration + 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			trail.set_meta("trail_tw", ttw)
			var fast_tw := bar_node.create_tween()
			fast_tw.tween_property(bar_node, "value", to, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			return
		var htw := trail.create_tween()
		htw.tween_property(trail, "value", to, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		trail.set_meta("trail_tw", htw)
	var tw := bar_node.create_tween()
	tw.tween_property(bar_node, "value", to, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# ---- faces for a whole scene ------------------------------------------------------------------------------------
const FEMALE := ["wuguotai", "wuxian", "dongbai", "caiwenji", "diaochan", "fengfuren", "tangji", "zhangning", "yanzhihu", "gongnv",
	"xiliang_nvbing", "daqiao", "xiaoqiao", "zhenmi", "sunshangxiang", "huangyueying", "bulianshi", "lvlingqi", "baosanniang",
	"zhurong", "mayunlu", "wangyi", "xinxianying", "caifuren", "bianfuren", "yanfuren", "liniang", "huangjin_nvyi", "yuenv_gong", "dufuren",
	"yahuan", "chuniang", "xiuniang", "huansha", "caisang", "chaniang", "guonvwang"]
const _CLAUSE_END := "，。；！？…」、"  # not ——: 孙贲——孙策的堂兄——在旁边 is one clause
static var _all_names: Dictionary = {}  # every name the story uses -> key (with or without art: a face only shows when drawn)


static func strip_tag(line: String) -> String:
	## "@key 台词" names the speaker outright, for back-and-forth the rules below can't read; the tag is never shown
	if line.begins_with("@"):
		var sp := line.find(" ")
		if sp > 0:
			return line.substr(sp + 1)
	return line


static func speakers(lines: Array, cast: Array = []) -> Array:
	## The speaker's key for every line of one scene ("" = narration / someone without a face). Rules, in order:
	## "@key " tag; the subject of the clause just before the first spoken 「 (a name opening a clause — 「X的…」 is skipped —
	## or 你 / {lord} = the hero); 她 / 他 = the latest subject of that gender, across lines; a line opening on a quote takes
	## the subject right after the quote, else whoever spoke last. `cast` (the square's portraits) is who 她 / 他 can mean before anyone is named.
	if _all_names.is_empty():
		for cid in GameData.get_db().cards:
			var c: Dictionary = GameData.get_db().cards[cid]
			var key := portrait_key(cid)
			_all_names[c["name"].split("·")[0]] = key if key != "" else str(c.get("person", cid))
		for n in ALIASES:
			_all_names[n] = ALIASES[n]
	var out: Array = []
	var recent: Array = cast.duplicate()
	var last := ""
	for raw in lines:
		var line := str(raw)
		if line.begins_with("@_ "):  # "@_ " = narration that must show no face (even when its words read like someone speaking)
			out.append("")
			continue
		if line.begins_with("@") and line.find(" ") > 0:
			var tag := line.substr(1, line.find(" ") - 1)
			out.append(tag)
			recent.append(tag)
			last = tag
			continue
		var q := _speech_at(line)
		if q < 0:  # narration: no face, but it still says who we're talking about
			_subjects(_unquote(line), recent)
			out.append("")
			continue
		var who := _subjects(line.substr(0, q), recent)
		if who == "" and line.substr(0, q).strip_edges() == "":  # 「……」他喃喃道 / 「白儿！」——吕布
			var close := line.find("」", q)
			if close >= 0:
				var tail := line.substr(close + 1)
				var nq := tail.find("「")
				who = _subjects(tail.substr(0, nq) if nq >= 0 else tail, recent.duplicate())
			if who == "":
				who = last
		out.append(who)
		# the rest of the line: who else acts, and who speaks last (a later 「 after 「X：」)
		var after := line.substr(q)
		var last_q := after.rfind("「")
		var seg_start := after.rfind("」", last_q) if last_q > 0 else -1
		var seg := after.substr(seg_start + 1, last_q - seg_start - 1) if last_q > 0 and seg_start >= 0 else ""
		var later := _subjects(_unquote(seg), recent) if seg != "" else ""
		last = later if later != "" else who
	# 「甄宓」 resolves to the young portrait; a square that casts the adult one (北线第七章起) means her grown-up face
	if cast.has("zhenmi") and not cast.has("zhenmi_young"):
		out = out.map(func(k): return "zhenmi" if k == "zhenmi_young" else k)
	return out


static func _speech_at(line: String) -> int:
	## the first spoken 「 (or ：): a quote at the line's start, after ：, or three characters or more — 「当」地一声 isn't speech
	var colon := line.find("：")
	var i := line.find("「")
	while i >= 0:
		var close := line.find("」", i)
		var inside := (close - i - 1) if close > i else 99
		if i == 0 or (i > 0 and line[i - 1] == "：") or inside >= 3:
			break
		i = line.find("「", i + 1)
	if i < 0:
		return colon
	return i if colon < 0 or i < colon else colon


static func _unquote(text: String) -> String:
	## quoted speech mentions names that aren't acting: blank it out
	var out := ""
	var depth := 0
	for ch in text:
		if ch == "「":
			depth += 1
			out += "。"
		elif ch == "」":
			depth = maxi(0, depth - 1)
		elif depth == 0:
			out += ch
	return out


static func _subjects(text: String, recent: Array) -> String:
	## walk the clauses: each one's subject goes onto `recent`; returns the last one found here
	var found := ""
	var start := 0
	while start < text.length():
		var end := start
		while end < text.length() and _CLAUSE_END.find(text[end]) < 0:
			end += 1
		var s := _clause_subject(text.substr(start, end - start), recent)
		if s != "":
			recent.append(s)
			found = s
		start = end + 1
	return found


static func _clause_subject(clause: String, recent: Array) -> String:
	var c := clause.strip_edges()
	if c == "":
		return ""
	if c.begins_with("{lord}") or (c.begins_with("你") and not c.begins_with("你们")):
		return "lord"
	if (c.begins_with("她") or c.begins_with("他")) and not (c.begins_with("她们") or c.begins_with("他们")):
		var female := c.begins_with("她")
		for k in range(recent.size() - 1, -1, -1):
			if recent[k] != "lord" and (recent[k] in FEMALE) == female:
				return recent[k]
		return ""
	# the subject opens the clause, or follows a short lead-in (担架上的祖茂 / 天亮后孙坚); a name further in is an object
	var best := ""
	var best_at := 1 << 30
	var best_len := 0
	var owner := ""  # 孙策的枪已经端平了: nobody else acts, so the owner does
	for n: String in _all_names:
		var at := c.find(n)
		while at >= 0:
			var lead_ok := at == 0 or (at <= 6 and "的后时里中上前边外下来天—个是".find(c[at - 1]) >= 0)
			var after: int = at + n.length()
			if lead_ok and after < c.length() and c[after] == "的":
				if owner == "":
					owner = _all_names[n]
				at = c.find(n, at + 1)
				continue
			if lead_ok and (at < best_at or (at == best_at and n.length() > best_len)):  # same spot: the longer name
				best_at = at
				best_len = n.length()
				best = _all_names[n]
			break
	return best if best != "" else owner
