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
		use_theme("light")
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
	p.add_theme_stylebox_override("background", box(c("track"), height / 2, 0, Color.TRANSPARENT, 0))
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


static func token_icon() -> Texture2D:
	var key := "token:lord"
	if not _textures.has(key):
		var path := "res://data/art/map/token_lord.png"
		_textures[key] = load(path) if ResourceLoader.exists(path) else null
	return _textures[key]


static func icon(key: String) -> Texture2D:
	## a small UI icon: data/art/icons/<key>.png (stat_at / stat_hp / stat_ap, skill_*), or null
	var k := "icon:" + key
	if not _textures.has(k):
		var path := "res://data/art/icons/%s.png" % key
		_textures[k] = load(path) if ResourceLoader.exists(path) else null
	return _textures[k]


const SKILL_ICONS := {"attack": "phys", "magic": "magic", "burn": "magic", "heal": "heal", "guard": "guard",
	"boost": "boost", "stun": "confuse", "break": "break", "ap": "ap"}


static func skill_icon(skill: Dictionary) -> Texture2D:
	## the icon for a skill's first effect (物理 / 法术 / 回复 / 防御 / BOOST / 混乱 / 破防 / 加 AP)
	var effects: Array = skill.get("effects", [])
	if effects.is_empty():
		return null
	return icon("skill_" + SKILL_ICONS.get(effects[0]["type"], "phys"))


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
	if idx.has(card_id):
		return card_id
	var card: Dictionary = GameData.get_db().cards.get(card_id, {})
	if card.has("person") and idx.has(card["person"]):
		return card["person"]
	return ""


const ALIASES := {"吴夫人": "wuguotai", "伯符": "sunce", "孙策": "sunce", "公瑾": "zhouyu", "周瑜": "zhouyu", "文台": "sunjian", "孙坚": "sunjian", "主公": "lord",
	"左慈": "zuoci", "胡玉": "langlijiao", "唐周": "yaodao", "何仪": "heyi", "董白": "dongbai", "刘备": "liubei",
	"关羽": "guanyu", "张飞": "zhangfei", "吕布": "lvbu", "华佗": "huatuo", "于吉": "yuji", "祖茂": "zumao"}
static var _names: Dictionary = {}


static func speaker_key(raw_line: String) -> String:
	## The portrait for whoever speaks a story line: {lord}, else the first known name before the first 「 / ：.
	## "" for narration (no speech on the line) -- a name merely mentioned doesn't get a face.
	if raw_line.begins_with("{lord}"):
		return "lord"
	var cut := -1
	for mark in ["「", "："]:
		var at := raw_line.find(mark)
		if at >= 0 and (cut < 0 or at < cut):
			cut = at
	if cut < 0:
		return ""
	var head := raw_line.substr(0, cut)
	if _names.is_empty():
		for cid in GameData.get_db().cards:
			var key := portrait_key(cid)
			if key != "":
				_names[GameData.get_db().cards[cid]["name"].split("·")[0]] = key
		for n in ALIASES:
			_names[n] = ALIASES[n]
	var best := ""
	var best_at := 1 << 30
	for n in _names:
		var at := head.find(n)
		if at >= 0 and at < best_at and _portrait_index().has(_names[n]):
			best_at = at
			best = _names[n]
	return best


static func enemy_portrait_key(enemy: Dictionary) -> String:
	var key: String = enemy.get("portrait", "")
	if key == "":
		key = enemy["id"]
	return key if _portrait_index().has(key) else ""


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

static func float_text(parent: Control, at: Vector2, text: String, color: Color, size := 40) -> void:
	## A number that pops up and drifts away (damage, heals).
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	l.add_theme_constant_override("outline_size", 8)
	l.position = at - Vector2(40, 20)
	l.z_index = 50
	parent.add_child(l)
	l.pivot_offset = Vector2(40, 20)
	l.scale = Vector2(0.4, 0.4)
	var tw := l.create_tween()
	tw.tween_property(l, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK)
	tw.tween_property(l, "scale", Vector2.ONE, 0.08)
	tw.parallel().tween_property(l, "position", l.position + Vector2(randf_range(-30, 30), -70), 0.7)
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
	var tw := bar_node.create_tween()
	tw.tween_property(bar_node, "value", to, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
