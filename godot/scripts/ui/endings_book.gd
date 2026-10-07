class_name EndingsBook
extends Control
## 结局图鉴: every ending in data/endings.json — which ones this save has reached (the 结局 flags), and for the rest the hint.

signal closed

var _flags: Array = []  # the save's lasting story flags


func _ready() -> void:
	z_index = 70
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.size = size
	add_child(dim)
	var db := GameData.get_db()
	var reached: Array = db.endings_reached(_flags)
	var built: Array = db.ending_order.filter(func(id): return db.endings[id]["built"])
	var panel := PanelContainer.new()
	panel.position = Vector2(120, 40)
	panel.size = Vector2(1040, 640)
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 16, 2, Kit.c("border"), 22))
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	var title := Kit.label("结局图鉴　已打通 %d / %d（其中已实装 %d 个）" % [reached.size(), db.ending_order.size(), built.size()], Kit.FONT_BIG, "gold")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	list.custom_minimum_size = Vector2(980, 0)
	scroll.add_child(list)
	for id in db.ending_order:
		list.add_child(_row(db.endings[id], reached.has(id)))
	var back := Kit.button("返回", "gray", Kit.FONT_BIG)
	back.custom_minimum_size = Vector2(240, 56)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_close)
	col.add_child(back)
	Kit.focus(back)


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	closed.emit()
	queue_free()


func _row(e: Dictionary, got: bool) -> Control:
	var box := PanelContainer.new()
	var bg := Kit.c("card") if got else Kit.c("card").darkened(0.45)
	box.add_theme_stylebox_override("panel", Kit.box(bg, 12, 2, Kit.c("gold") if got else Kit.c("gray"), 12))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	var pic := Kit.cg(e["cg"] if got else "end_locked")  # an unreached one shows the sealed thumbnail (once that art exists)
	if pic != null:
		var tex := TextureRect.new()
		tex.texture = pic
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.custom_minimum_size = Vector2(200, 112)
		row.add_child(tex)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var route: String = {"south": "南线", "north": "北线", "both": "南北合一"}.get(e["route"], "")
	var kind: String = {"bad": "Bad End", "end": "结局", "true": "真结局"}.get(e["kind"], "")
	col.add_child(Kit.label("%s　%s · %s · %s" % [e["title"] if got else "？？？", route, e["chapter"], kind], Kit.FONT_BODY + 2, "gold" if got else "gray"))
	if got:
		col.add_child(_wrap("%s" % e["text"], "text"))
		col.add_child(_wrap("触发：%s" % e["trigger"], "muted"))
		col.add_child(_wrap("破局：%s" % e["unlock"], "muted"))
	else:
		col.add_child(_wrap("提示：%s" % e["hint"], "muted"))
		col.add_child(_wrap("关联人物：%s" % e["who"] + ("" if e["built"] else "　（尚未实装）"), "muted"))
	return box


func _wrap(text: String, color_name: String) -> Label:
	var l := Kit.label(text, 16, color_name)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(600, 0)
	return l
