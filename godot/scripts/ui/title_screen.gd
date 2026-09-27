class_name TitleScreen
extends Control


func _ready() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	col.custom_minimum_size = Vector2(420, 0)
	center.add_child(col)

	var title := Kit.label("三　国　卡　牌", Kit.FONT_TITLE + 16, "gold")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var sub := Kit.label("穿越江东 · 招兵买将", Kit.FONT_BIG, "muted")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	col.add_child(Control.new())

	var has_save := FileAccess.file_exists(SaveData.SAVE_PATH) and Game.persist_enabled
	if has_save:
		var cont := Kit.button("继续", "green", Kit.FONT_BIG)
		cont.pressed.connect(Game.continue_game)
		col.add_child(cont)
		Kit.focus(cont)

	var name_edit := LineEdit.new()
	name_edit.placeholder_text = "你的名字（留空 = 主公）"
	name_edit.custom_minimum_size = Vector2(0, 56)
	name_edit.add_theme_font_size_override("font_size", Kit.FONT_BODY)
	name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(name_edit)
	var start := Kit.button("新的旅程" if not has_save else "重新开始", "blue", Kit.FONT_BIG)
	start.pressed.connect(func(): Game.new_game(name_edit.text))
	name_edit.text_submitted.connect(func(t): Game.new_game(t))
	col.add_child(start)
	if not has_save:
		Kit.focus(start)
