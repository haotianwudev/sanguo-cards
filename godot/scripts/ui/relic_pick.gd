class_name RelicPick
extends Control
## Pick one 宝物: a row of plaques (icon, name, rarity, what it does). Emits picked(index).

signal picked(index: int)

var title := "选一件宝物"
var relic_ids: Array = []

const RARITY := {"common": ["普通", "blue"], "rare": ["稀有", "purple"], "curse": ["诅咒", "red"]}


func _ready() -> void:
	var db := GameData.get_db()
	z_index = 50
	size = Vector2(1280, 720)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.size = size
	add_child(dim)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 28)
	col.position = Vector2(90, 90)
	col.size = Vector2(1100, 520)
	add_child(col)
	var t := Kit.label(title, Kit.FONT_BIG + 4)
	t.add_theme_color_override("font_color", Color.WHITE)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	col.add_child(row)
	for i in relic_ids.size():
		var r: Dictionary = db.relics[relic_ids[i]]
		var rar: Array = RARITY.get(r["rarity"], ["", "gold"])
		var b := Button.new()
		b.custom_minimum_size = Vector2(300, 360)
		for st in ["normal", "hover", "pressed", "focus"]:
			var bg := Kit.c("card") if st != "hover" else Kit.c("card").lightened(0.06)
			b.add_theme_stylebox_override(st, Kit.box(bg, 16, 4 if st != "focus" else 6, Kit.c(rar[1]) if st != "focus" else Kit.c("gold"), 18))
		var box := VBoxContainer.new()
		box.set_anchors_preset(Control.PRESET_FULL_RECT)
		box.offset_left = 18
		box.offset_right = -18
		box.offset_top = 18
		box.offset_bottom = -18
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		box.add_theme_constant_override("separation", 12)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(box)
		var icon: Control
		var relic_tex: Texture2D = Kit.relic_icon(relic_ids[i])
		if relic_tex != null:
			var tr := TextureRect.new()
			tr.texture = relic_tex
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.custom_minimum_size = Vector2(112, 112)
			tr.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			icon = tr
		else:
			var lbl := Kit.label(r["icon"], 52, "gold")
			lbl.add_theme_stylebox_override("normal", Kit.box(Kit.c(rar[1]), 48, 0, Color.TRANSPARENT, 8))
			lbl.add_theme_color_override("font_color", Color.WHITE)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.custom_minimum_size = Vector2(84, 84)
			lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			icon = lbl
		var name := Kit.label(r["name"], Kit.FONT_BIG)
		name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var tag := Kit.label(rar[0], 16, rar[1])
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var desc := Kit.label(r["desc"], Kit.FONT_BODY, "muted")
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.custom_minimum_size = Vector2(260, 0)
		for n in [icon, name, tag, desc]:
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE
			box.add_child(n)
		b.pressed.connect(func(): picked.emit(i))
		row.add_child(b)
		b.scale = Vector2(0.6, 0.6)
		b.pivot_offset = b.custom_minimum_size / 2
		b.modulate.a = 0.0
		var tw := b.create_tween().set_parallel()
		tw.tween_property(b, "scale", Vector2.ONE, 0.25).set_delay(0.08 * i).set_trans(Tween.TRANS_BACK)
		tw.tween_property(b, "modulate:a", 1.0, 0.2).set_delay(0.08 * i)
		if i == 0:
			Kit.focus(b)
