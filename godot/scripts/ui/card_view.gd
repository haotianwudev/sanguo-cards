class_name CardView
extends Control
## A card, laid out per pics/CARD-DESIGN.md. With frame art (data/art/frames, configured in ui.json "card"):
## the portrait fills the frame's window, the name sits on the frame's plate, the troop badge rides the
## top-left corner, AT / HP sit on the bottom of the portrait, skills are listed under the card.
## Without frame art it falls back to a drawn frame.

signal pressed

var fighter: Dictionary
var leader: Dictionary = {}  # when shown as a party leader: uses leader AT/HP and troop size
var count := 0  # soldier copies (0 = hide)
var note := ""
var show_skills := true
var dimmed := false
var selected := false


static func make(card_id: String, size := Vector2(180, 252), opts := {}) -> CardView:
	var db := GameData.get_db()
	var v := CardView.new()
	v.fighter = db.build_lord(opts.get("lord_name", "主公")) if card_id == "lord" else db.build_fighter(card_id)
	v.leader = opts.get("leader", {})
	v.count = opts.get("count", 0)
	v.note = opts.get("note", "")
	v.show_skills = opts.get("skills", true)
	v.custom_minimum_size = size
	v.size = size
	return v


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	_build()
	resized.connect(_build)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func _gui_input(event: InputEvent) -> void:
	var tap: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	var accept: bool = event.is_action_pressed("ui_accept")
	if tap or accept:
		pressed.emit()
		accept_event()


func set_state(is_dimmed: bool, is_selected: bool) -> void:
	dimmed = is_dimmed
	selected = is_selected
	modulate = Color(0.55, 0.55, 0.55) if dimmed else Color.WHITE
	queue_redraw()


func _rarity_key() -> String:
	return "lord" if fighter["rarity"] == null else str(fighter["rarity"])


func _add(node: Control, pos: Vector2, sz: Vector2) -> Control:
	node.position = pos
	node.size = sz
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)
	return node


func _build() -> void:
	for ch in get_children():
		ch.queue_free()
	var w := size.x
	var db := GameData.get_db()
	var troop: Dictionary = db.troops[fighter["troop"]]
	var rc := Kit.rarity_color(fighter["rarity"])
	var small := w < 150
	var fr := Kit.frame(_rarity_key())
	var card_h := minf(size.y, w * 1.4)  # the framed card itself is 5:7; anything below is the skills area

	# portrait window
	var win := Rect2(6, 6, w - 12, card_h * 0.68)
	if not fr.is_empty():
		var r: Rect2 = fr["window"]
		win = Rect2(r.position.x * w, r.position.y * card_h, r.size.x * w, r.size.y * card_h)
	else:
		var panel := Panel.new()
		panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 12, 4, rc, 0))
		_add(panel, Vector2.ZERO, Vector2(w, card_h))
	var key := Kit.portrait_key(fighter["id"])
	var tex := Kit.portrait(key, win.size.x / win.size.y, 3.4) if key != "" else null
	if tex != null:
		var art := TextureRect.new()
		art.texture = tex
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_add(art, win.position, win.size)
	else:
		var ph := ColorRect.new()
		ph.color = Kit.c("panel")
		_add(ph, win.position, win.size)
		var pl := Kit.label(troop["short"], int(win.size.y * 0.42), "dim")
		pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_add(pl, win.position, win.size)

	# stats strip on the bottom of the portrait
	var at: int = leader.get("at", fighter["at"])
	var hp: int = leader.get("hp", fighter["hp"])
	var strip_h := 26.0 if not small else 20.0
	var strip := ColorRect.new()
	strip.color = Color(0, 0, 0, 0.55)
	_add(strip, Vector2(win.position.x, win.end.y - strip_h), Vector2(win.size.x, strip_h))
	var stats := Kit.label("攻%d  兵%d" % [at, hp], 16 if not small else 13)
	stats.add_theme_color_override("font_color", Color.WHITE)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_add(stats, strip.position, strip.size)
	if leader.has("members") and not leader["members"].is_empty():
		var troop_l := Label.new()
		troop_l.text = "部队%d" % (leader["members"].size() + 1)
		troop_l.add_theme_font_size_override("font_size", 14)
		troop_l.add_theme_color_override("font_color", Color.WHITE)
		troop_l.add_theme_stylebox_override("normal", Kit.box(Color(0, 0, 0, 0.55), 6, 0, Color.TRANSPARENT, 3))
		_add(troop_l, Vector2(win.end.x - 62, win.position.y + 4), Vector2(58, 22))

	# frame art on top of the portrait
	if not fr.is_empty():
		var frame := TextureRect.new()
		frame.texture = fr["texture"]
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame.stretch_mode = TextureRect.STRETCH_SCALE
		_add(frame, Vector2.ZERO, Vector2(w, card_h))

	# name, engraved on the frame's plate (style per frame in ui.json); a variant (孙策·中年) gets a tag
	var full: String = fighter["name"]
	var parts := full.split("·", true, 1)
	var main_name: String = parts[0]
	var plate := Rect2(win.position.x, win.end.y + 2, win.size.x, 30)
	var style := Kit.name_style("none")
	if not fr.is_empty():
		var p: Rect2 = fr["plate"]
		plate = Rect2(p.position.x * w, p.position.y * card_h, p.size.x * w, p.size.y * card_h)
		if fr["has_plate"]:
			style = Kit.name_style(fr["name"])
		else:
			var band := ColorRect.new()
			band.color = Color(0, 0, 0, 0.6)
			_add(band, plate.position, plate.size)
	var fs := clampi(int(plate.size.y * 0.86), 14, 30)
	if main_name.length() >= 4:
		fs = int(fs * 0.85)
	var spacing := int(fs * 0.18) if main_name.length() <= 3 else 0
	var nm := Label.new()
	nm.text = main_name
	nm.add_theme_font_override("font", Kit.name_font(fs, spacing))
	nm.add_theme_font_size_override("font_size", fs)
	nm.add_theme_color_override("font_color", Color(style["color"]))
	if style.has("outline"):
		nm.add_theme_color_override("font_outline_color", Color(style["outline"]))
		nm.add_theme_constant_override("outline_size", maxi(3, fs / 5))
	if style.has("shadow"):
		nm.add_theme_color_override("font_shadow_color", Color(style["shadow"], 0.85))
		nm.add_theme_constant_override("shadow_offset_x", 0)
		nm.add_theme_constant_override("shadow_offset_y", 1)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_add(nm, plate.position - Vector2(8, 2), plate.size + Vector2(16, 4))
	if parts.size() > 1:
		var tag := Label.new()
		tag.text = parts[1]
		tag.add_theme_font_override("font", Kit.name_font(14, 1))
		tag.add_theme_font_size_override("font_size", 14 if not small else 12)
		tag.add_theme_color_override("font_color", Color("#ffe7a0"))
		tag.add_theme_stylebox_override("normal", Kit.box(Color(0.1, 0.06, 0.02, 0.78), 6, 1, Color("#c9a14a"), 3))
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var tw := 18.0 * parts[1].length() + 14
		_add(tag, Vector2(win.position.x + (win.size.x - tw) / 2, win.position.y + 4), Vector2(tw, 22))

	# troop badge (top-left corner) and, without frame art, the rarity gem
	var bs := 40.0 if not small else 30.0
	var badge := Panel.new()
	badge.add_theme_stylebox_override("panel", Kit.box(Kit.c("bg"), int(bs / 2), 3, rc, 0))
	_add(badge, Vector2(win.position.x - bs * 0.35, win.position.y - bs * 0.35), Vector2(bs, bs))
	var bl := Kit.label(troop["short"], int(bs * 0.5))
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bl.size = badge.size
	badge.add_child(bl)
	if fr.is_empty():
		var gem := Label.new()
		gem.text = Kit.rarity_label(fighter["rarity"])
		gem.add_theme_font_size_override("font_size", 15)
		gem.add_theme_color_override("font_color", Color.WHITE)
		gem.add_theme_stylebox_override("normal", Kit.box(rc, 8, 0, Color.TRANSPARENT, 4))
		gem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_add(gem, Vector2(w - 52, 4), Vector2(46, 22))

	# skills under the card
	var y := card_h + 4
	if show_skills:
		for sid in fighter["skills"]:
			if y + 22 > size.y:
				break
			var sk: Dictionary = db.skills[sid]
			var chip := Label.new()
			chip.text = "%s  AP%d" % [sk["name"], sk["cost"]]
			chip.add_theme_font_size_override("font_size", 14)
			chip.add_theme_color_override("font_color", Kit.c("text"))
			chip.add_theme_stylebox_override("normal", Kit.box(Kit.c("card"), 6, 1, Kit.c("border"), 3))
			chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			chip.clip_text = true
			_add(chip, Vector2(8, y), Vector2(w - 16, 22))
			y += 26
	if note != "":
		var n := Kit.label(note, 15, "gold")
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_add(n, Vector2(0, size.y - 22), Vector2(w, 22))
	if count > 0:
		var cnt := Label.new()
		cnt.text = "×%d" % count
		cnt.add_theme_font_size_override("font_size", 18)
		cnt.add_theme_color_override("font_color", Color.WHITE)
		cnt.add_theme_stylebox_override("normal", Kit.box(Kit.c("gold"), 10, 0, Color.TRANSPARENT, 4))
		_add(cnt, Vector2(w - 46, card_h - 34), Vector2(44, 28))


func _draw() -> void:
	var card_h := minf(size.y, size.x * 1.4)
	if selected:
		draw_rect(Rect2(Vector2(-5, -5), Vector2(size.x + 10, card_h + 10)), Kit.c("gold"), false, 5.0)
	elif has_focus():
		draw_rect(Rect2(Vector2(-4, -4), Vector2(size.x + 8, card_h + 8)), Kit.c("amber"), false, 3.0)
