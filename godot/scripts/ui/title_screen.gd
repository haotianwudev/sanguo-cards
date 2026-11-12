class_name TitleScreen
extends Control


var _col: VBoxContainer


var demo_slots := {}  # --demo=title_slot: route → save shown as if read from disk (demos never touch the real saves)

func _ready() -> void:
	Bgm.play("title")
	var art := Kit.ui_art("title")  # title picture in full colour; only the middle, behind the menu, is shaded (user rule)
	if art != null:
		var pic := TextureRect.new()
		pic.texture = art
		pic.set_anchors_preset(Control.PRESET_FULL_RECT)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(pic)
		add_child(_centre_shade())
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := VBoxContainer.new()
	_col = col
	col.add_theme_constant_override("separation", 18)
	col.custom_minimum_size = Vector2(420, 0)
	center.add_child(col)

	var title := Kit.title_label("重　开　三　国", Kit.FONT_TITLE + 24, "gold")
	Kit.calligraphy(title, Kit.FONT_TITLE + 24, 2, 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var sub := Kit.title_label("穿越三国 · 你想去哪", Kit.FONT_BIG, "muted")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	col.add_child(Control.new())

	var slots := demo_slots.duplicate()  # the two routes each keep a save of their own: both can be played side by side
	if Game.persist_enabled:
		for r in ["south", "north"]:
			var sv := SaveData.read_slot(r)
			if sv != null:
				slots[r] = sv
	var has_save := not slots.is_empty()
	if has_save:
		col.custom_minimum_size = Vector2(860, 0)
		col.add_theme_constant_override("separation", 12)
		var row := HBoxContainer.new()  # south and north side by side
		row.add_theme_constant_override("separation", 40)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_child(row)
		var first := true
		for r in ["south", "north"]:
			var vb := VBoxContainer.new()
			vb.add_theme_constant_override("separation", 8)
			vb.custom_minimum_size = Vector2(400, 0)
			row.add_child(vb)
			if slots.has(r):
				_slot_block(vb, r, slots[r], first)
				first = false
			else:  # the route with no save yet: started from its own column, so it is plain how to play the other line
				_empty_block(vb, r, slots.keys()[0])
		var any: SaveData = slots.values()[0]
		var edb := GameData.get_db()
		var books := HBoxContainer.new()
		books.add_theme_constant_override("separation", 16)
		books.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_child(books)
		var book := Kit.button("结局图鉴　%d / %d" % [any.endings_reached().size(), edb.ending_order.size()], "gold", Kit.FONT_BODY)
		book.custom_minimum_size = Vector2(300, 0)
		book.pressed.connect(func():
			var b := EndingsBook.new()
			b._flags = any.flags
			Game.root.add_child(b))
		books.add_child(book)
		var cbook := Kit.button("卡牌收藏　%d 张" % any.get_cleared_cards().size(), "blue", Kit.FONT_BODY)
		cbook.custom_minimum_size = Vector2(300, 0)
		cbook.pressed.connect(func():
			var cb := CardsBook.new()
			cb.save = any
			Game.root.add_child(cb))
		books.add_child(cbook)
	if Game.persist_enabled and FileAccess.file_exists(SaveData.PENDING_PATH):
		var pend := Kit.button("继续上次没选出生点的旅程", "gray", Kit.FONT_BODY)
		pend.pressed.connect(Game.continue_pending)
		pend.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		col.add_child(pend)

	if slots.size() < 2:  # with one save the other route starts from its own column above
		if not has_save:
			var start := Kit.button("新的旅程", "gold", Kit.FONT_BIG)
			start.pressed.connect(func(): Game.root.add_child(NewGameDialog.new()))
			col.add_child(start)
			Kit.focus(start)
	else:
		var start := Kit.button("新的旅程（选出生点后，覆盖那条线的存档）", "gray", Kit.FONT_BODY)
		start.pressed.connect(func(): Game.root.add_child(NewGameDialog.new()))
		start.custom_minimum_size = Vector2(620, 0)
		start.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		col.add_child(start)

	if OS.is_debug_build():  # QA tool: jump chapters / browse all cards & CGs / quit — never shown in a release build
		var dbg := Kit.button("测试工具", "gray", 14)
		dbg.custom_minimum_size = Vector2(0, 32)
		dbg.pressed.connect(func(): Game.root.add_child(DebugScreen.new()))
		col.add_child(dbg)


func _centre_shade() -> Control:
	## a soft dark band down the middle (behind the title and the buttons), fading out to both sides, so the two heroes keep their colour
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.3, 0.5, 0.7, 1.0])
	g.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0.03, 0.02, 0.01, 0.45), Color(0.03, 0.02, 0.01, 0.62),
		Color(0.03, 0.02, 0.01, 0.45), Color(0, 0, 0, 0)])
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 256
	gt.height = 4
	var shade := TextureRect.new()
	shade.texture = gt
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return shade


func _slot_block(col: VBoxContainer, r: String, saved: SaveData, focus_first: bool) -> void:
	## one route's save: where it stands and what can be done with it
	var route_name := "南线" if r == "south" else "北线"
	var where := ""
	for q in GameData.get_db().quests:
		if q["id"] == saved.quest:
			where = Quests.title(q, saved)
	var over: bool = saved.ended and saved.replay == ""
	var head := Kit.label("%s　%s" % [route_name, "（已有结局）" if over else where], Kit.FONT_BODY + 2, "gold")  # no 周目 number (user call)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(head)
	if over:  # an ending was reached: nothing to continue, only a new 周目
		var fresh := Kit.button("新的开始", "green", Kit.FONT_BIG)
		fresh.pressed.connect(Game.new_lap.bind(r))
		col.add_child(fresh)
		if focus_first:
			Kit.focus(fresh)
	else:
		var cont := Kit.button("继续", "green", Kit.FONT_BIG)
		cont.pressed.connect(Game.continue_game.bind(r))
		col.add_child(cont)
		if focus_first:
			Kit.focus(cont)
	if saved.replay != "":
		var back := Kit.button("放弃重玩，回到主线", "gray")
		back.pressed.connect(Game.back_to_story.bind(r))
		col.add_child(back)
	if not over:  # a new 周目 can be started at any time
		var lap := Kit.button("新周目（卡牌重置）", "purple", Kit.FONT_BODY)
		lap.pressed.connect(Game.new_lap.bind(r))
		col.add_child(lap)
	if not saved.quests_cleared.is_empty():
		var replay := Kit.button("重玩章节", "gold")
		replay.pressed.connect(func(): _replay_menu(col, saved, r))
		col.add_child(replay)


func _empty_block(col: VBoxContainer, r: String, other: String) -> void:
	## a route with no save yet, beside the one that has: 开始X线 starts a journey born on this route (its own save, the other untouched)
	var route_name := "南线" if r == "south" else "北线"
	var head := Kit.label("%s　还没有存档" % route_name, Kit.FONT_BODY + 2, "muted")
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(head)
	var go := Kit.button("开始%s" % route_name, "gold", Kit.FONT_BIG)
	go.pressed.connect(func():
		var d := NewGameDialog.new()
		d.route = r
		Game.root.add_child(d))
	col.add_child(go)
	var note := Kit.label("%s存档不受影响，两条线可以同时玩" % ("南线" if other == "south" else "北线"), Kit.FONT_BODY - 2, "muted")
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(note)


func _replay_menu(col: VBoxContainer, saved: SaveData, r: String) -> void:
	## one button per finished chapter; replays get harder with every clear (进阶)
	if col.get_node_or_null("Replays_" + r) != null:
		return
	var box := VBoxContainer.new()
	box.name = "Replays_" + r
	box.add_theme_constant_override("separation", 8)
	col.add_child(box)
	var step := float(GameData.get_db().battle["danger_step"])
	for q in GameData.get_db().quests:
		if not saved.quests_cleared.has(q["id"]):
			continue
		var n := int(saved.clears.get(q["id"], 1))
		var b := Kit.button("%s（%s）　（通关 %d 次 · 进阶 +%d%%）" % [q["title"], "北线" if q["event_scope"] == "north" else "南线", n, int(round(n * step * 100))], "gold", Kit.FONT_BODY)
		b.pressed.connect(Game.replay_chapter.bind(r, q["id"]))
		box.add_child(b)
