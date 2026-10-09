class_name RelicReveal
extends Control
## 宝物 the story or an event hands you: each one appears as a big card (picture, name, rarity, which troop it serves,
## what it does) that flips in with a flash, rings and sparks. Tap to go on. Emits closed.

signal closed

var relic_ids: Array = []
var title := "获得宝物"
var _cells: Array = []
var _ready_to_close := false

const RARITY := {"common": ["普通", "blue"], "rare": ["稀有", "purple"], "curse": ["诅咒", "red"], "story": ["剧情", "gold"]}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 66
	position = Vector2.ZERO
	size = Vector2(1280, 720)  # full screen (the map screen is not a container: anchors alone leave it 0×0)
	var db := GameData.get_db()
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.84)
	dim.size = size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var col := VBoxContainer.new()
	col.position = Vector2(40, 40)
	col.size = Vector2(1200, 640)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 22)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	var head := Kit.label(title, Kit.FONT_TITLE + 6, "gold")
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(head)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 30)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(row)
	var wide := relic_ids.size() <= 2
	for rid in relic_ids:
		var r: Dictionary = db.relics[rid]
		var rar: Array = RARITY.get(r["rarity"], ["", "gold"])
		var cell := PanelContainer.new()
		cell.custom_minimum_size = Vector2(380 if wide else 300, 430)
		cell.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 18, 5, Kit.c(rar[1]), 20))
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.modulate.a = 0.0
		row.add_child(cell)
		_cells.append(cell)
		var box := VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		box.add_theme_constant_override("separation", 10)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(box)
		var tex: Texture2D = Kit.relic_icon(rid)
		var icon: Control
		if tex != null:
			var tr := TextureRect.new()
			tr.texture = tex
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.custom_minimum_size = Vector2(170, 170)
			tr.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			icon = tr
		else:
			var g := Kit.label(r["icon"], 72, "gold")
			g.add_theme_stylebox_override("normal", Kit.box(Kit.c(rar[1]), 70, 0, Color.TRANSPARENT, 8))
			g.add_theme_color_override("font_color", Color.WHITE)
			g.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			g.custom_minimum_size = Vector2(130, 130)
			g.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			icon = g
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(icon)
		var nm := Kit.label(r["name"], Kit.FONT_BIG + 6)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(nm)
		var troop: String = "主公" if r.get("troop", "") == "lord" else str(db.troops.get(r.get("troop", ""), {}).get("name", ""))
		var tag := Kit.label("%s宝物　·　%s部队" % [rar[0], troop] if troop != "" else rar[0] + "宝物", Kit.FONT_BODY - 2, rar[1])
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(tag)
		var desc := Kit.label(r["desc"], Kit.FONT_BODY - 2)
		desc.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.custom_minimum_size = Vector2(320 if wide else 250, 0)
		box.add_child(desc)
	var hint := Kit.label("点击继续", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)
	gui_input.connect(func(e):
		if _ready_to_close and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_close())
	_deal()


func _deal() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for i in _cells.size():
		var c: Control = _cells[i]
		c.pivot_offset = c.size / 2
		c.scale = Vector2(0.05, 1.0)
		var tw := c.create_tween()
		tw.tween_interval(0.25 * i)
		tw.tween_property(c, "modulate:a", 1.0, 0.05)
		tw.tween_property(c, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func():
			var centre := c.global_position - global_position + c.size / 2
			BattleFx.ring(self, centre, BattleFx.GOLD, 30.0, 230.0, 0.5, 7)
			BattleFx.burst(self, centre, BattleFx.GOLD, 14, 40.0, 260.0, 6.0, 0.45)
			BattleFx.embers(self, Rect2(c.global_position - global_position, c.size), BattleFx.GOLD, 22, 90.0, false))
		tw.tween_property(c, "modulate", Color(1.8, 1.6, 0.9), 0.07)
		tw.tween_property(c, "modulate", Color.WHITE, 0.4)
	await get_tree().create_timer(0.55 + 0.25 * _cells.size()).timeout
	_ready_to_close = true


func _unhandled_input(e: InputEvent) -> void:
	if _ready_to_close and e.is_action_pressed("ui_accept"):
		_close()


func _close() -> void:
	_ready_to_close = false
	closed.emit()
	queue_free()
