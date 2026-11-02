class_name RelicPick
extends Control
## Pick one 宝物 (or 天命): a row of plaques (icon, name, rarity, what it does). Like PickOverlay: a tap selects one
## (it lifts, the rest dim), 选定 — or a second tap on the same plaque — keeps it. Emits picked(index).

signal picked(index: int)

var title := "选一件宝物"
var relic_ids: Array = []
var source := "relics"  # or "fates" (天命 at the start of a run)

const RARITY := {"common": ["普通", "blue"], "rare": ["稀有", "purple"], "curse": ["诅咒", "red"]}
const FATE_RARITY := {"common": ["吉", "blue"], "rare": ["大吉", "purple"], "curse": ["险中求", "red"], "bad": ["凶", "red"], "divine": ["天授", "gold"]}

var _plaques: Array = []
var _styles: Array = []  # per plaque: [normal, selected] styleboxes
var _selected := -1
var _confirm: Button


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
	col.position = Vector2(90, 40)
	col.size = Vector2(1100, 640)
	add_child(col)
	var t := Kit.title_label(title, Kit.FONT_BIG + 6, "text")
	t.add_theme_color_override("font_color", Color.WHITE)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	col.add_child(row)
	for i in relic_ids.size():
		var r: Dictionary = db.relics[relic_ids[i]] if source == "relics" else db.fates[relic_ids[i]]
		var rar: Array = (RARITY if source == "relics" else FATE_RARITY).get(r["rarity"], ["", "gold"])
		var b := Button.new()
		b.custom_minimum_size = Vector2(300, 360)
		var plain := Kit.box(Kit.c("card"), 16, 4, Kit.c(rar[1]), 18)
		var chosen := Kit.box(Kit.c("card").lightened(0.08), 16, 7, Kit.c("gold"), 18)
		_styles.append([plain, chosen])
		for st in ["normal", "hover", "pressed", "focus"]:
			var bg := Kit.c("card") if st != "hover" else Kit.c("card").lightened(0.06)
			# focus (keyboard / pad) is a thin light edge: gold and thick means 选中, and nothing is chosen until a tap
			b.add_theme_stylebox_override(st, Kit.box(bg, 16, 4, Kit.c(rar[1]) if st != "focus" else Color(1, 1, 1, 0.55), 18))
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
		var relic_tex: Texture2D = Kit.relic_icon(relic_ids[i]) if source == "relics" else Kit.fate_icon(relic_ids[i])
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
		b.pressed.connect(_select.bind(i))
		_plaques.append(b)
		row.add_child(b)
		b.scale = Vector2(0.6, 0.6)
		b.pivot_offset = b.custom_minimum_size / 2
		b.modulate.a = 0.0
		var tw := b.create_tween().set_parallel()
		tw.tween_property(b, "scale", Vector2.ONE, 0.25).set_delay(0.08 * i).set_trans(Tween.TRANS_BACK)
		tw.tween_property(b, "modulate:a", 1.0, 0.2).set_delay(0.08 * i)
		if i == 0:
			Kit.focus(b)
	_confirm = Kit.button("选定", "gold", Kit.FONT_BIG)
	_confirm.custom_minimum_size = Vector2(260, 64)
	_confirm.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_confirm.disabled = true
	_confirm.pressed.connect(func(): if _selected >= 0: picked.emit(_selected))
	col.add_child(_confirm)


func _select(i: int) -> void:
	if _selected == i:
		picked.emit(i)  # second tap on the same plaque = confirm
		return
	_selected = i
	for j in _plaques.size():
		var b: Button = _plaques[j]
		var on := j == i
		for st in ["normal", "hover", "pressed"]:
			b.add_theme_stylebox_override(st, _styles[j][1] if on else _styles[j][0])
		var tw := b.create_tween().set_parallel()
		tw.tween_property(b, "scale", Vector2(1.06, 1.06) if on else Vector2(0.96, 0.96), 0.14).set_trans(Tween.TRANS_BACK)
		tw.tween_property(b, "modulate", Color.WHITE if on else Color(0.6, 0.6, 0.6), 0.14)
	_confirm.disabled = false
	_confirm.text = "选定：" + str((GameData.get_db().relics if source == "relics" else GameData.get_db().fates)[relic_ids[i]]["name"])
