class_name SettingsOverlay
extends Control
## 设置: the pause menu on the map and in a battle — resume, browse the cards you have, options, back to the title.

signal closed

var in_battle := false
var _page: Control


func _ready() -> void:
	z_index = 70
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.size = size
	add_child(dim)
	_menu()


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	closed.emit()
	queue_free()


func _clear() -> void:
	if _page != null:
		_page.queue_free()
		_page = null


func _panel(width: float) -> VBoxContainer:
	_clear()
	var center := CenterContainer.new()
	center.size = size
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 16, 2, Kit.c("border"), 22))
	center.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.custom_minimum_size = Vector2(width, 0)
	panel.add_child(col)
	add_child(center)
	_page = center
	return col


func _title(col: VBoxContainer, text: String) -> void:
	var t := Kit.label(text, Kit.FONT_BIG, "gold")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)


func _menu() -> void:
	var col := _panel(420)
	_title(col, "设　置")
	var resume := Kit.button("继续游戏", "green", Kit.FONT_BIG)
	resume.pressed.connect(_close)
	col.add_child(resume)
	var cards := Kit.button("查看卡牌", "blue")
	cards.pressed.connect(_cards)
	col.add_child(cards)
	var opts := Kit.button("选项", "blue")
	opts.pressed.connect(_options)
	col.add_child(opts)
	if Game.save != null and Game.save.prep_points() > 0:  # 前尘整备 exists from the second 周目 on
		var prep := Kit.button("查看前尘整备", "blue")
		prep.pressed.connect(_prep)
		col.add_child(prep)
	if OS.is_debug_build():
		var dbg := Kit.button("测试工具（开发者界面）", "purple")
		dbg.pressed.connect(_open_debug)
		col.add_child(dbg)
	if Game.save != null and Game.save.quest != "" and not Game.save.steps.is_empty():
		var back := Kit.button("重返上一格", "gold")
		back.pressed.connect(_confirm_step_back)
		col.add_child(back)
	if Game.save != null and Game.save.quest != "":
		var redo := Kit.button("重打这一章", "gold")
		redo.pressed.connect(_confirm_restart)
		col.add_child(redo)
	var home := Kit.button("回到主页", "red")
	home.pressed.connect(_confirm_home)
	col.add_child(home)
	Kit.focus(resume)


func _options() -> void:
	var col := _panel(520)
	_title(col, "选　项")
	if not OS.has_feature("mobile"):
		_switch(col, "全屏", bool(Game.options["fullscreen"]), func(on): Game.set_option("fullscreen", on))
	_switch(col, "战斗加速（动画 ×1.6）", bool(Game.options["fast"]), func(on):
		Game.set_option("fast", on)
		Engine.time_scale = Game.battle_speed() if in_battle else 1.0)
	# the battle re-applies it when this closes
	_switch(col, "自动战斗慢速（看清每一步）", str(Game.options.get("auto_speed", "fast")) == "slow",
		func(on): Game.set_option("auto_speed", "slow" if on else "fast"))
	_switch(col, "省电模式（30 帧，装饰动画只播一次，手机不发热）", bool(Game.options.get("power_saver", false)),
		func(on): Game.set_option("power_saver", on))
	var vol_row := HBoxContainer.new()
	vol_row.add_theme_constant_override("separation", 16)
	vol_row.add_child(Kit.label("音效音量", Kit.FONT_BODY))
	var vol := HSlider.new()
	vol.min_value = 0.0
	vol.max_value = 1.0
	vol.step = 0.05
	vol.value = float(Game.options.get("sfx_volume", 0.8))
	vol.custom_minimum_size = Vector2(280, 44)
	vol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vol.value_changed.connect(func(v): Game.set_option("sfx_volume", v))
	vol.drag_ended.connect(func(_changed): Sfx.play("hit"))  # hear the new level
	vol_row.add_child(vol)
	col.add_child(vol_row)
	var bgm_row := HBoxContainer.new()
	bgm_row.add_theme_constant_override("separation", 16)
	bgm_row.add_child(Kit.label("音乐音量", Kit.FONT_BODY))
	var bgm_vol := HSlider.new()
	bgm_vol.min_value = 0.0
	bgm_vol.max_value = 1.0
	bgm_vol.step = 0.05
	bgm_vol.value = float(Game.options.get("bgm_volume", 0.7))
	bgm_vol.custom_minimum_size = Vector2(280, 44)
	bgm_vol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bgm_vol.value_changed.connect(func(v): Game.set_option("bgm_volume", v))
	bgm_row.add_child(bgm_vol)
	col.add_child(bgm_row)
	var inherit := CheckButton.new()
	inherit.text = "新的开始继承全部卡牌（测试用）"
	inherit.button_pressed = bool(Game.options["inherit_all"])
	inherit.add_theme_font_size_override("font_size", Kit.FONT_BODY)
	inherit.toggled.connect(func(on): Game.set_option("inherit_all", on))
	col.add_child(inherit)
	if OS.is_debug_build():
		var dbg := Kit.button("测试工具（开发者界面）", "purple")
		dbg.pressed.connect(_open_debug)
		col.add_child(dbg)
	var back := Kit.button("返回", "gray")
	back.pressed.connect(_menu)
	col.add_child(back)


func _open_debug() -> void:
	var d := DebugScreen.new()
	Game.root.add_child(d)


func _prep() -> void:
	## what this 周目 bought with 前尘点 at its start (SaveData.prep_lines), read-only
	var save := Game.save
	var col := _panel(640)
	_title(col, "前尘整备")
	col.add_child(Kit.label("本周目开局用了 %d / %d 点" % [save.prep_spent(), save.prep_points()], Kit.FONT_BODY, "gold"))
	var lines := save.prep_lines()
	var l := Kit.label("
".join(lines.map(func(x): return "· " + str(x))) if not lines.is_empty() else "这个周目开局没有用前尘点。", Kit.FONT_BODY, "text" if not lines.is_empty() else "muted")
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()  # many remembered cards brought along: the list scrolls instead of leaving the screen
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(0, minf(400.0, 38.0 * maxi(1, lines.size())))
	scroll.add_child(l)
	col.add_child(scroll)
	var back := Kit.button("返回", "gray")
	back.pressed.connect(_menu)
	col.add_child(back)
	Kit.focus(back)


func _confirm_step_back() -> void:
	var col := _panel(520)
	_title(col, "重返上一格？")
	var l := Kit.label("回到走这一步之前：上一格的结果保留，这一格拿到的卡牌、宝物、做过的选择都会退回。\n可以一格一格往回退，最远到本章第一格。",
			Kit.FONT_BODY, "muted")
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(l)
	var ok := Kit.button("重返上一格", "gold")
	ok.pressed.connect(func():
		queue_free()
		Game.step_back())
	col.add_child(ok)
	var no := Kit.button("取消", "gray")
	no.pressed.connect(_menu)
	col.add_child(no)
	Kit.focus(no)


func _confirm_restart() -> void:
	var col := _panel(520)
	_title(col, "重打这一章？")
	var l := Kit.label("回到刚进本章时的样子，从第一格重新出发。\n本章拿到的卡牌、宝物、做过的选择都会退回。",
			Kit.FONT_BODY, "muted")
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(l)
	var ok := Kit.button("重打这一章", "gold")
	ok.pressed.connect(func():
		queue_free()
		Game.restart_chapter())
	col.add_child(ok)
	var no := Kit.button("取消", "gray")
	no.pressed.connect(_menu)
	col.add_child(no)
	Kit.focus(no)


func _confirm_home() -> void:
	var col := _panel(520)
	_title(col, "回到主页？")
	var msg := "进度已自动保存，可在主页点「继续」接着玩。"
	if in_battle:
		msg += "\n这场战斗不会保存，继续后需要重新打。"
	var l := Kit.label(msg, Kit.FONT_BODY, "muted")
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(l)
	var ok := Kit.button("回到主页", "red")
	ok.pressed.connect(func():
		queue_free()
		Game.go_home())
	col.add_child(ok)
	var no := Kit.button("取消", "gray")
	no.pressed.connect(_menu)
	col.add_child(no)


# ---- card browser (read-only) ---------------------------------------------------

func _cards() -> void:
	var cb := CardsBook.new()
	cb.save = Game.save
	Game.root.add_child(cb)


func _switch(col: Control, text: String, on: bool, changed: Callable) -> CheckButton:
	## one on/off row of the 选项 page
	var b := CheckButton.new()
	b.text = text
	b.button_pressed = on
	b.add_theme_font_size_override("font_size", Kit.FONT_BODY)
	b.toggled.connect(changed)
	col.add_child(b)
	return b
