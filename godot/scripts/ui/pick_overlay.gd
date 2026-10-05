class_name PickOverlay
extends Control
## Full-screen "pick one": cards flip in one by one; tap to select, confirm to keep.
## Used for the story's 三选一, chests (soldiers) and recruiting (generals).

signal picked(index: int)
signal cancelled

var title := ""
var card_ids: Array = []
var captions: Array = []  # optional text under each card
var counts: Array = []  # optional copy counts (chests)
var confirm_text := "选一张"
var cancelable := false  # a 取消 button next to the confirm one (emits cancelled)
var chest := ""  # "" = cards just flip in; "normal" / "grand" = a chest pops, bursts open and deals them face down
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
	if cancelable:
		var cancel := Kit.button("取消", "gray", Kit.FONT_BIG)
		cancel.custom_minimum_size = Vector2(200, 64)
		cancel.pressed.connect(func(): cancelled.emit())
		bottom.add_child(cancel)
	_confirm = Kit.button(confirm_text, "gold", Kit.FONT_BIG)
	_confirm.custom_minimum_size = Vector2(260, 64)
	_confirm.disabled = true
	_confirm.pressed.connect(func(): if _selected >= 0: picked.emit(_selected))
	bottom.add_child(_confirm)
	_deal()


func _deal() -> void:
	await get_tree().process_frame
	if chest != "":
		await _open_chest()
		return
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


func _open_chest() -> void:
	## the chest drops in, shakes, bursts into light; the cards fly out face down and flip one by one
	for v in _views:
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grand := chest == "grand"
	var center := size / 2 - Vector2(0, 40)
	var box := TextureRect.new()
	var art := "res://data/art/ui/chest_%s.png" % chest  # drawn chest (CARD-DESIGN §2), else the map's 宝 icon
	box.texture = load(art) if ResourceLoader.exists(art) else Kit.map_icon("treasure")
	box.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	box.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.size = Vector2(200, 200) if not grand else Vector2(250, 250)
	box.position = center - box.size / 2
	box.pivot_offset = box.size / 2
	box.scale = Vector2.ZERO
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if box.texture == null:  # no icon art: a gold 宝
		var l := Kit.label("宝", 120, "gold")
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.size = box.size
		box.add_child(l)
	add_child(box)
	var tw := box.create_tween()
	tw.tween_property(box, "scale", Vector2(1.15, 1.15), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(box, "scale", Vector2.ONE, 0.1)
	for k in (3 if not grand else 5):  # rattling
		tw.tween_property(box, "rotation", deg_to_rad(9.0 if k % 2 == 0 else -9.0), 0.07)
	tw.tween_property(box, "rotation", 0.0, 0.06)
	await tw.finished
	# burst of light
	var glow := Panel.new()
	var gc := Color(1.0, 0.85, 0.35, 0.9) if not grand else Color(1.0, 0.6, 1.0, 0.9)
	glow.add_theme_stylebox_override("panel", Kit.box(gc, 200, 0, Color.TRANSPARENT, 0))
	glow.size = Vector2(60, 60)
	glow.position = center - glow.size / 2
	glow.pivot_offset = glow.size / 2
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)
	var gt := glow.create_tween().set_parallel()
	gt.tween_property(glow, "scale", Vector2(14, 14), 0.35).set_ease(Tween.EASE_OUT)
	gt.tween_property(glow, "modulate:a", 0.0, 0.45)
	var bt := box.create_tween().set_parallel()
	bt.tween_property(box, "scale", Vector2(1.5, 1.5), 0.2)
	bt.tween_property(box, "modulate", Color(3, 3, 3, 0), 0.25)
	await get_tree().create_timer(0.2).timeout
	# the cards fly out, face down
	var backs: Array = []
	for i in _views.size():
		var v: CardView = _views[i]
		v.pivot_offset = v.size / 2
		var back := TextureRect.new()
		back.texture = Kit.card_back()
		back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		back.stretch_mode = TextureRect.STRETCH_SCALE
		back.size = Vector2(v.size.x, minf(v.size.y, v.size.x * 1.4))
		back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if back.texture == null:
			var p := Panel.new()
			p.add_theme_stylebox_override("panel", Kit.box(Kit.c("red").darkened(0.3), 12, 3, Kit.c("gold"), 0))
			p.size = back.size
			back.add_child(p)
		v.add_child(back)
		backs.append(back)
		for ch in v.get_children():  # the skill tags under the card stay hidden until it turns over
			if ch is Control and ch != back and (ch as Control).position.y >= back.size.y - 1:
				ch.visible = false
		var home := v.position
		v.position = home + (center - (v.global_position - global_position) - v.size / 2)
		v.scale = Vector2(0.3, 0.3)
		v.modulate.a = 1.0
		var ft := v.create_tween().set_parallel()
		ft.tween_property(v, "position", home, 0.35).set_delay(0.08 * i).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		ft.tween_property(v, "scale", Vector2.ONE, 0.35).set_delay(0.08 * i)
	await get_tree().create_timer(0.45 + 0.08 * _views.size()).timeout
	# flip, one by one; rare ones flash
	var db := GameData.get_db()
	for i in _views.size():
		var v: CardView = _views[i]
		var fl := v.create_tween()
		fl.tween_property(v, "scale:x", 0.0, 0.1)
		fl.tween_callback(backs[i].queue_free)
		fl.tween_callback(func():
			for ch in v.get_children():
				if ch is Control:
					ch.visible = true)
		fl.tween_property(v, "scale:x", 1.0, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var rar: String = str(db.cards[card_ids[i]]["rarity"])
		if rar in ["SR", "SSR"] or (rar == "R" and grand):
			fl.tween_property(v, "modulate", Color(1.8, 1.6, 0.9), 0.08)
			fl.tween_property(v, "modulate", Color.WHITE, 0.3)
		await get_tree().create_timer(0.22).timeout
	box.queue_free()
	glow.queue_free()
	for v in _views:
		v.mouse_filter = Control.MOUSE_FILTER_STOP
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
