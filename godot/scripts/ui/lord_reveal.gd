class_name LordReveal
extends Control
## The lord card a cleared chapter hands out (主角卡): a full-screen moment — the card spins in with a gold flash, rings and
## embers, a banner above says what it is, the stats it adds sit underneath. Tap to go on. Emits closed.

signal closed

var form := ""  # the lord_forms id just handed out
var dupe := false  # a repeat: it raised the lord's 品阶 instead of adding a new card
var _card: CardView
var _ready_to_close := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 70
	position = Vector2.ZERO
	size = Vector2(1280, 720)  # full screen (the map screen is not a container: anchors alone leave it 0×0)
	var db := GameData.get_db()
	var save := Game.save
	var info: Dictionary = db.lord_forms.get(form, {"name": "主公"} if form == "base" else {})  # "base" = the plain lord, one more copy
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.86)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 12)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	var head := Kit.label("主角卡升级！" if dupe else "获得主角卡！", Kit.FONT_TITLE + 12, "gold")
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.modulate.a = 0.0
	col.add_child(head)
	var name_l := Kit.label("「%s」" % str(info.get("name", "")), Kit.FONT_BIG + 4)
	name_l.add_theme_color_override("font_color", Color.WHITE)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.modulate.a = 0.0
	col.add_child(name_l)
	var holder := CenterContainer.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(holder)
	_card = CardView.make("lord", Vector2(250, 360), {"form": form})
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.modulate.a = 0.0
	holder.add_child(_card)
	var gain := Kit.label(_gain_text(info), Kit.FONT_BODY + 2)
	gain.add_theme_color_override("font_color", Color(1.0, 0.92, 0.6))
	gain.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gain.modulate.a = 0.0
	col.add_child(gain)
	var hint := Kit.label("点击继续", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.modulate.a = 0.0
	col.add_child(hint)
	gui_input.connect(func(e):
		if _ready_to_close and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_close())
	_play([head, name_l, gain, hint])


func _gain_text(info: Dictionary) -> String:
	var save := Game.save
	var bits: Array = []
	if dupe:
		var tiers: Array = GameData.get_db().gacha["tiers"]
		bits.append("品阶：%s（%d 张）" % [tiers[save.tier("lord")]["name"], save.copies("lord")])
	else:
		var b: Dictionary = info.get("bonus", {})
		if int(b.get("hp", 0)) != 0:
			bits.append("体力 +%d" % int(b["hp"]))
		if int(b.get("at", 0)) != 0:
			bits.append("攻击 +%d" % int(b["at"]))
		var sk: Array = info.get("skills", [])
		if not sk.is_empty():
			bits.append("新技能：" + "、".join(sk.map(func(s): return str(GameData.get_db().skills.get(s, {}).get("name", s)))))
		if bits.is_empty():
			bits.append("主角变强了")
	return "　".join(bits)


func _play(labels: Array) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var centre := _card.global_position - global_position + _card.size / 2
	_card.pivot_offset = _card.size / 2
	_card.scale = Vector2(0.05, 0.05)
	_card.rotation_degrees = -540.0
	# a slow glow behind the card the whole time
	BattleFx.embers(self, Rect2(centre - Vector2(160, 40), Vector2(320, 200)), BattleFx.GOLD, 40, 140.0, false)
	var tw := _card.create_tween().set_parallel(true)
	tw.tween_property(_card, "modulate:a", 1.0, 0.08)
	tw.tween_property(_card, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_card, "rotation_degrees", 0.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.66).timeout
	# the landing: flash + two rings + a burst of rays
	var fl := create_tween()
	fl.tween_property(_card, "modulate", Color(2.4, 2.0, 1.1), 0.07)
	fl.tween_property(_card, "modulate", Color.WHITE, 0.5)
	BattleFx.ring(self, centre, BattleFx.GOLD, 30.0, 260.0, 0.55, 8)
	BattleFx.burst(self, centre, BattleFx.GOLD, 18, 40.0, 320.0, 7.0, 0.5)
	await get_tree().create_timer(0.12).timeout
	BattleFx.ring(self, centre, Color(1, 1, 1), 20.0, 200.0, 0.45, 5)
	var lt := create_tween().set_parallel(true)
	for i in labels.size():
		lt.tween_property(labels[i], "modulate:a", 1.0, 0.3).set_delay(0.12 * i)
	# keep the card breathing so the screen stays alive until the tap
	await get_tree().create_timer(0.6).timeout
	_ready_to_close = true
	var pulse := _card.create_tween().set_loops()
	pulse.tween_property(_card, "scale", Vector2(1.03, 1.03), 0.9).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_card, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE)


func _unhandled_input(e: InputEvent) -> void:
	if _ready_to_close and e.is_action_pressed("ui_accept"):
		_close()


func _close() -> void:
	_ready_to_close = false
	closed.emit()
	queue_free()
