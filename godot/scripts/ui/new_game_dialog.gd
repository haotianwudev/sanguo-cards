class_name NewGameDialog
extends Control
## 新的旅程: asked for after the title's button is pressed — first, when a save exists, whether to wipe it ("从零开始" erases the
## endings and card levels too), then the lord's name. Nothing about the name lives on the title screen itself.

var wipes_save := false

var _box: VBoxContainer


func _ready() -> void:
	z_index = 70
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 16, 2, Kit.c("border"), 24))
	panel.position = Vector2(340, 190)
	panel.size = Vector2(600, 0)
	add_child(panel)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 14)
	_box.custom_minimum_size = Vector2(550, 0)
	panel.add_child(_box)
	if wipes_save:
		_confirm()
	else:
		_ask_name()


func _clear() -> void:
	for c in _box.get_children():
		c.queue_free()


func _confirm() -> void:
	_clear()
	var t := Kit.label("清空存档，从零开始？", Kit.FONT_BIG, "gold")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(t)
	var m := Kit.label("已打通的结局、卡的级别、曾拿到过的卡都会被清掉，不能恢复。\n只想再玩一遍的话，取消后点「新的开始」。", Kit.FONT_BODY, "muted")
	m.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	m.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(m)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	_box.add_child(row)
	var no := Kit.button("取消", "gray", Kit.FONT_BIG)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no.pressed.connect(queue_free)
	row.add_child(no)
	var yes := Kit.button("清空并继续", "red", Kit.FONT_BIG)
	yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yes.pressed.connect(_ask_name)
	row.add_child(yes)
	Kit.focus(no)


func _ask_name() -> void:
	_clear()
	var t := Kit.label("你的名字", Kit.FONT_BIG, "gold")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(t)
	var edit := LineEdit.new()
	edit.placeholder_text = "留空 = 主公"
	edit.custom_minimum_size = Vector2(0, 56)
	edit.add_theme_font_size_override("font_size", Kit.FONT_BODY)
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(edit)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	_box.add_child(row)
	var no := Kit.button("取消", "gray", Kit.FONT_BIG)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no.pressed.connect(queue_free)
	row.add_child(no)
	var go := Kit.button("出发", "blue", Kit.FONT_BIG)
	go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	go.pressed.connect(func(): Game.new_game(edit.text))
	row.add_child(go)
	edit.text_submitted.connect(func(s): Game.new_game(s))
	edit.grab_focus.call_deferred()
