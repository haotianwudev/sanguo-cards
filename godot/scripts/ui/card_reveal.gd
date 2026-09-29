class_name CardReveal
extends Control
## Cards the story hands you (入队): they flip in one by one, rare ones flash; tap to go on. Emits closed.

signal closed

var title := "入　队"
var card_ids: Array = []
var _views: Array = []
var _ready_to_close := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 65
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 20)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	var t := Kit.label(title, Kit.FONT_TITLE, "gold")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 36)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(row)
	var db := GameData.get_db()
	var tiers: Array = db.gacha["tiers"]
	var big := card_ids.size() <= 3
	for cid in card_ids:
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 8)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(cell)
		var c: Dictionary = db.cards[cid]
		var v := CardView.make(cid, Vector2(220, 396) if big else Vector2(160, 300), {"count": Game.save.copies(cid) if c["soldier"] else 0})
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.modulate.a = 0.0
		cell.add_child(v)
		_views.append(v)
		var n := Game.save.copies(cid)
		var cap := "兵卡 +1" if c["soldier"] else ("新武将" if n <= 1 else "品阶：%s（%d 张）" % [tiers[Game.save.tier(cid)]["name"], n])
		var l := Kit.label(cap, Kit.FONT_BODY)
		l.add_theme_color_override("font_color", Color.WHITE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(l)
	var hint := Kit.label("点击继续", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)
	gui_input.connect(func(e):
		if _ready_to_close and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_close())
	_deal()


func _unhandled_input(e: InputEvent) -> void:
	if _ready_to_close and e.is_action_pressed("ui_accept"):
		_close()


func _deal() -> void:
	await get_tree().process_frame
	var db := GameData.get_db()
	for i in _views.size():
		var v: CardView = _views[i]
		v.pivot_offset = v.size / 2
		v.scale = Vector2(0.05, 1.0)
		var tw := v.create_tween()
		tw.tween_interval(0.18 * i)
		tw.tween_property(v, "modulate:a", 1.0, 0.05)
		tw.tween_property(v, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if str(db.cards[card_ids[i]]["rarity"]) in ["SR", "SSR"]:
			tw.tween_property(v, "modulate", Color(1.8, 1.6, 0.9), 0.08)
			tw.tween_property(v, "modulate", Color.WHITE, 0.35)
	await get_tree().create_timer(0.45 + 0.18 * _views.size()).timeout
	_ready_to_close = true


func _close() -> void:
	_ready_to_close = false
	closed.emit()
	queue_free()
