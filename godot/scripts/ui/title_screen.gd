class_name TitleScreen
extends Control


var _col: VBoxContainer


func _ready() -> void:
	var art := Kit.ui_art("title")  # title picture, dimmed so the menu stays readable
	if art != null:
		var pic := TextureRect.new()
		pic.texture = art
		pic.set_anchors_preset(Control.PRESET_FULL_RECT)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		pic.modulate = Color(0.5, 0.5, 0.5)
		add_child(pic)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := VBoxContainer.new()
	_col = col
	col.add_theme_constant_override("separation", 18)
	col.custom_minimum_size = Vector2(420, 0)
	center.add_child(col)

	var title := Kit.label("重　开　三　国", Kit.FONT_TITLE + 16, "gold")
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
		var saved := SaveData.read()
		if saved != null and saved.replay != "":
			var back := Kit.button("放弃重玩，回到主线", "gray")
			back.pressed.connect(Game.back_to_story)
			col.add_child(back)
		var endings: Array = saved.flags.filter(func(f): return str(f).begins_with("结局")) if saved != null else []
		if not endings.is_empty():
			var end_l := Kit.label("已达成：" + "、".join(endings), Kit.FONT_BODY, "gold")
			end_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			col.add_child(end_l)
		if saved != null and saved.lap > 1:
			var lap_l := Kit.label("第 %d 周目" % saved.lap, Kit.FONT_BODY, "muted")
			lap_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			col.add_child(lap_l)
		if saved != null and not saved.quests_cleared.is_empty():
			var lap := Kit.button("开始第 %d 周目（继承全部卡牌）" % (saved.lap + 1), "purple", Kit.FONT_BODY)
			lap.pressed.connect(Game.new_lap)
			col.add_child(lap)
			var replay := Kit.button("重玩章节", "gold")
			replay.pressed.connect(func(): _replay_menu(col, saved))
			col.add_child(replay)

	var name_edit := LineEdit.new()
	name_edit.placeholder_text = "你的名字（留空 = 主公）"
	name_edit.custom_minimum_size = Vector2(0, 56)
	name_edit.add_theme_font_size_override("font_size", Kit.FONT_BODY)
	name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(name_edit)
	var start := Kit.button("新的旅程" if not has_save else "从零开始（清空存档）", "blue", Kit.FONT_BIG if not has_save else Kit.FONT_BODY)
	start.pressed.connect(func(): Game.new_game(name_edit.text))
	name_edit.text_submitted.connect(func(t): Game.new_game(t))
	col.add_child(start)
	if not has_save:
		Kit.focus(start)

	if OS.is_debug_build():  # QA tool: jump chapters / browse all cards & CGs / quit — never shown in a release build
		var dbg := Kit.button("测试工具", "gray", 14)
		dbg.custom_minimum_size = Vector2(0, 32)
		dbg.pressed.connect(func(): Game.root.add_child(DebugScreen.new()))
		col.add_child(dbg)


func _replay_menu(col: VBoxContainer, saved: SaveData) -> void:
	## one button per finished chapter; replays get harder with every clear (进阶)
	if col.get_node_or_null("Replays") != null:
		return
	var box := VBoxContainer.new()
	box.name = "Replays"
	box.add_theme_constant_override("separation", 8)
	col.add_child(box)
	var step := float(GameData.get_db().battle["danger_step"])
	for q in GameData.get_db().quests:
		if not saved.quests_cleared.has(q["id"]):
			continue
		var n := int(saved.clears.get(q["id"], 1))
		var b := Kit.button("%s　（通关 %d 次 · 进阶 +%d%%）" % [q["title"], n, int(round(n * step * 100))], "gold", Kit.FONT_BODY)
		b.pressed.connect(Game.replay_chapter.bind(q["id"]))
		box.add_child(b)
