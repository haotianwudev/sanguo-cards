class_name ConfirmOverlay
extends Control
## A yes / no question over whatever is showing: `await overlay.answered` gives true / false.

signal answered(yes: bool)

var title := ""
var message := ""
var yes_text := "确定"


func _ready() -> void:
	z_index = 80
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 16, 2, Kit.c("border"), 24))
	panel.position = Vector2(340, 220)
	panel.size = Vector2(600, 0)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size = Vector2(550, 0)
	panel.add_child(box)
	var t := Kit.label(title, Kit.FONT_BIG, "gold")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var m := Kit.label(message, Kit.FONT_BODY, "muted")
	m.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	m.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(m)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	var no := Kit.button("取消", "gray", Kit.FONT_BIG)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no.pressed.connect(func(): _answer(false))
	row.add_child(no)
	var yes := Kit.button(yes_text, "red", Kit.FONT_BIG)
	yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yes.pressed.connect(func(): _answer(true))
	row.add_child(yes)
	Kit.focus(no)


func _answer(yes: bool) -> void:
	answered.emit(yes)
	queue_free()
