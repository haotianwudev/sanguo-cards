class_name CardView
extends Control
## A card, laid out per pics/CARD-DESIGN.md: framed full art, troop badge, rarity gem, name plate,
## AT / HP, skill chips, copy count. Everything is drawn procedurally until frame/icon art exists.

signal pressed

var fighter: Dictionary
var leader: Dictionary = {}  # when shown as a party leader: uses leader AT/HP and troop size
var count := 0  # soldier copies (0 = hide)
var note := ""
var show_skills := true
var dimmed := false
var selected := false

var _frame: Panel
var _art: TextureRect
var _placeholder: Label


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
	_style_frame()


func _style_frame() -> void:
	if _frame == null:
		return
	var rc := Kit.rarity_color(fighter["rarity"])
	var border := Kit.c("gold") if selected else rc
	var sb := Kit.box(Kit.c("card"), 12, 5 if (selected or fighter["rarity"] == "SSR") else 4, border, 0)
	if fighter["rarity"] == "SSR":
		sb.shadow_color = Color(Kit.c("gold"), 0.45)
		sb.shadow_size = 8
	if selected:
		sb.shadow_color = Color(Kit.c("gold"), 0.6)
		sb.shadow_size = 12
	_frame.add_theme_stylebox_override("panel", sb)


func _build() -> void:
	for ch in get_children():
		ch.queue_free()
	var w := size.x
	var h := size.y
	var db := GameData.get_db()
	var troop: Dictionary = db.troops[fighter["troop"]]
	var rc := Kit.rarity_color(fighter["rarity"])
	var small := w < 150

	_frame = Panel.new()
	_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_style_frame()

	# art (top ~62%)
	var pad := 6.0
	var art_h := h * (0.56 if show_skills else 0.68)
	var art_rect := Rect2(pad, pad, w - 2 * pad, art_h)
	var key := Kit.portrait_key(fighter["id"])
	var tex := Kit.portrait(key, art_rect.size.x / art_rect.size.y, 3.2) if key != "" else null
	if tex != null:
		_art = TextureRect.new()
		_art.texture = tex
		_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_art.position = art_rect.position
		_art.size = art_rect.size
		_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_art)
	else:
		var ph := ColorRect.new()
		ph.color = Kit.c("panel")
		ph.position = art_rect.position
		ph.size = art_rect.size
		ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(ph)
		_placeholder = Kit.label(troop["short"], int(art_h * 0.45), "dim")
		_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_placeholder.position = art_rect.position
		_placeholder.size = art_rect.size
		add_child(_placeholder)

	# name plate over the bottom of the art
	var plate_h := 30.0 if not small else 24.0
	var plate := ColorRect.new()
	plate.color = Color(0, 0, 0, 0.62)
	plate.position = Vector2(pad, pad + art_h - plate_h)
	plate.size = Vector2(w - 2 * pad, plate_h)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(plate)
	var nm := Kit.label(fighter["name"], Kit.FONT_SMALL if not small else 15)
	nm.add_theme_color_override("font_color", Color.WHITE)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nm.clip_text = true
	nm.position = plate.position
	nm.size = plate.size
	add_child(nm)

	# troop badge (top-left) and rarity gem (top-right)
	var bs := 38.0 if not small else 30.0
	var badge := Panel.new()
	badge.add_theme_stylebox_override("panel", Kit.box(Kit.c("bg"), int(bs / 2), 3, rc, 0))
	badge.position = Vector2(-4, -4)
	badge.size = Vector2(bs, bs)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(badge)
	var bl := Kit.label(troop["short"], int(bs * 0.5))
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bl.size = badge.size
	badge.add_child(bl)
	var gem := Label.new()
	gem.text = Kit.rarity_label(fighter["rarity"])
	gem.add_theme_font_size_override("font_size", 15)
	gem.add_theme_color_override("font_color", Color.WHITE)
	gem.add_theme_stylebox_override("normal", Kit.box(rc, 8, 0, Color.TRANSPARENT, 4))
	gem.position = Vector2(w - 52, 4)
	gem.size = Vector2(46, 22)
	gem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(gem)

	# stats
	var at: int = leader.get("at", fighter["at"])
	var hp: int = leader.get("hp", fighter["hp"])
	var y := pad + art_h + 4
	var stats := Kit.label("攻 %d   兵 %d" % [at, hp], Kit.FONT_SMALL if not small else 14)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.position = Vector2(0, y)
	stats.size = Vector2(w, 26)
	add_child(stats)
	y += 26
	if leader.has("members") and not leader["members"].is_empty():
		var troop_l := Kit.label("部队 %d 人" % (leader["members"].size() + 1), 14, "muted")
		troop_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		troop_l.position = Vector2(0, y)
		troop_l.size = Vector2(w, 20)
		add_child(troop_l)
		y += 20

	# skills
	if show_skills:
		for sid in fighter["skills"]:
			var sk: Dictionary = db.skills[sid]
			var chip := Label.new()
			chip.text = "%s  AP%d" % [sk["name"], sk["cost"]]
			chip.add_theme_font_size_override("font_size", 14)
			chip.add_theme_color_override("font_color", Kit.c("text"))
			chip.add_theme_stylebox_override("normal", Kit.box(Kit.c("panel"), 6, 0, Color.TRANSPARENT, 3))
			chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			chip.clip_text = true
			chip.position = Vector2(10, y + 2)
			chip.size = Vector2(w - 20, 22)
			add_child(chip)
			y += 26

	if note != "":
		var n := Kit.label(note, 15, "gold")
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		n.position = Vector2(0, h - 26)
		n.size = Vector2(w, 22)
		add_child(n)
	if count > 0:
		var cnt := Label.new()
		cnt.text = "×%d" % count
		cnt.add_theme_font_size_override("font_size", 18)
		cnt.add_theme_color_override("font_color", Color.WHITE)
		cnt.add_theme_stylebox_override("normal", Kit.box(Kit.c("gold"), 10, 0, Color.TRANSPARENT, 4))
		cnt.position = Vector2(w - 44, h - 30)
		cnt.size = Vector2(44, 28)
		add_child(cnt)
	for ch in get_children():
		if ch is Control:
			ch.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	if has_focus():
		draw_rect(Rect2(Vector2(-4, -4), size + Vector2(8, 8)), Kit.c("gold"), false, 3.0)
