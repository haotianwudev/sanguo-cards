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
		var saved := SaveData.read()
		if saved != null and saved.ended and saved.replay == "":  # an ending was reached: nothing to continue, only a new 周目
			var fresh := Kit.button("新的开始", "green", Kit.FONT_BIG)
			fresh.pressed.connect(Game.new_lap)
			col.add_child(fresh)
			Kit.focus(fresh)
			var keep := Kit.label("测试：继承全部卡牌" if bool(Game.options["inherit_all"]) else "结局、卡的级别和曾拿到过的卡都会保留，卡牌重新来过", 14, "muted")
			keep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			col.add_child(keep)
		else:
			var cont := Kit.button("继续", "green", Kit.FONT_BIG)
			cont.pressed.connect(Game.continue_game)
			col.add_child(cont)
			Kit.focus(cont)
		if saved != null and saved.replay != "":
			var back := Kit.button("放弃重玩，回到主线", "gray")
			back.pressed.connect(Game.back_to_story)
			col.add_child(back)
		if saved != null:
			var edb := GameData.get_db()
			var book := Kit.button("结局图鉴　%d / %d" % [saved.endings_reached().size(), edb.ending_order.size()], "gold", Kit.FONT_BODY)
			book.pressed.connect(func():
				var b := EndingsBook.new()
				b._flags = saved.flags
				Game.root.add_child(b))
			col.add_child(book)
		if saved != null and not saved.quests_cleared.is_empty():
			if not (saved.ended and saved.replay == ""):  # (after an ending the 新的开始 button above is the way on)
				var lap := Kit.button("新的开始（卡牌重置，结局与卡的级别保留）", "purple", Kit.FONT_BODY)
				lap.pressed.connect(Game.new_lap)
				col.add_child(lap)
			var replay := Kit.button("重玩章节", "gold")
			replay.pressed.connect(func(): _replay_menu(col, saved))
			col.add_child(replay)

	var start := Kit.button("新的旅程" if not has_save else "从零开始（清空存档）", "blue", Kit.FONT_BIG if not has_save else Kit.FONT_BODY)
	start.pressed.connect(func():
		var d := NewGameDialog.new()
		d.wipes_save = has_save  # a save exists: ask before wiping it, then the name
		Game.root.add_child(d))
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
		var b := Kit.button("%s（%s）　（通关 %d 次 · 进阶 +%d%%）" % [q["title"], "北线" if q["event_scope"] == "north" else "南线", n, int(round(n * step * 100))], "gold", Kit.FONT_BODY)
		b.pressed.connect(Game.replay_chapter.bind(q["id"]))
		box.add_child(b)
