class_name PickOverlay
extends Control
## Full-screen "pick one": cards flip in one by one; tap to select, confirm to keep.
## Used for the story's 三选一, chests (soldiers) and recruiting (generals).

signal picked(index: int)

var title := ""
var card_ids: Array = []
var captions: Array = []  # optional text under each card
var counts: Array = []  # optional copy counts (chests)
var _views: Array = []
var _selected := -1
var _confirm: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 22)
	add_child(col)
	var t := Kit.label(title, Kit.FONT_BIG + 4)
	t.add_theme_color_override("font_color", Color.WHITE)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 36)
	col.add_child(row)
	for i in card_ids.size():
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 10)
		row.add_child(cell)
		var v := CardView.make(card_ids[i], Vector2(220, 396), {"count": counts[i] if i < counts.size() else 0})
		v.pressed.connect(_select.bind(i))
		v.modulate.a = 0.0
		cell.add_child(v)
		_views.append(v)
		if i < captions.size() and captions[i] != "":
			var cap := Kit.label(captions[i], Kit.FONT_BODY)
			cap.add_theme_color_override("font_color", Color.WHITE)
			cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cap.custom_minimum_size = Vector2(220, 0)
			cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cell.add_child(cap)

	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(bottom)
	_confirm = Kit.button("选一张", "gold", Kit.FONT_BIG)
	_confirm.custom_minimum_size = Vector2(260, 64)
	_confirm.disabled = true
	_confirm.pressed.connect(func(): if _selected >= 0: picked.emit(_selected))
	bottom.add_child(_confirm)
	_deal()


func _deal() -> void:
	await get_tree().process_frame
	for i in _views.size():
		var v: CardView = _views[i]
		v.pivot_offset = v.size / 2
		v.scale = Vector2(0.05, 1.0)
		var tw := v.create_tween()
		tw.tween_interval(0.12 * i)
		tw.tween_property(v, "modulate:a", 1.0, 0.05)
		tw.tween_property(v, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if not _views.is_empty():
		Kit.focus(_views[0])


func _select(i: int) -> void:
	if _selected == i:
		picked.emit(i)  # second tap on the same card = confirm
		return
	_selected = i
	for j in _views.size():
		var v: CardView = _views[j]
		v.set_state(j != i, j == i)
		var tw := v.create_tween()
		tw.tween_property(v, "position:y", -18.0 if j == i else 0.0, 0.12)
	_confirm.disabled = false
	_confirm.text = "带走 " + GameData.get_db().cards[card_ids[i]]["name"]
