class_name SettingsOverlay
extends Control
## 设置: the pause menu on the map and in a battle — resume, browse the cards you have, options, back to the title.

signal closed

var in_battle := false
var _box: VBoxContainer
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
	var home := Kit.button("回到主页", "red")
	home.pressed.connect(_confirm_home)
	col.add_child(home)
	Kit.focus(resume)


func _options() -> void:
	var col := _panel(520)
	_title(col, "选　项")
	if not OS.has_feature("mobile"):
		var fs := CheckButton.new()
		fs.text = "全屏"
		fs.button_pressed = bool(Game.options["fullscreen"])
		fs.add_theme_font_size_override("font_size", Kit.FONT_BODY)
		fs.toggled.connect(func(on): Game.set_option("fullscreen", on))
		col.add_child(fs)
	var fast := CheckButton.new()
	fast.text = "战斗加速（动画 ×1.6）"
	fast.button_pressed = bool(Game.options["fast"])
	fast.add_theme_font_size_override("font_size", Kit.FONT_BODY)
	fast.toggled.connect(func(on):
		Game.set_option("fast", on)
		Engine.time_scale = Game.battle_speed() if in_battle else 1.0)
	col.add_child(fast)
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
	var inherit := CheckButton.new()
	inherit.text = "新的开始继承全部卡牌（测试用）"
	inherit.button_pressed = bool(Game.options["inherit_all"])
	inherit.add_theme_font_size_override("font_size", Kit.FONT_BODY)
	inherit.toggled.connect(func(on): Game.set_option("inherit_all", on))
	col.add_child(inherit)
	var back := Kit.button("返回", "gray")
	back.pressed.connect(_menu)
	col.add_child(back)


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
	_clear()
	var db := GameData.get_db()
	var save := Game.save
	var generals: Array = ["lord"]
	for cid in save.owned + save.seen:
		if db.cards.has(cid) and not generals.has(cid) and not db.cards[cid]["soldier"]:
			generals.append(cid)
	var soldiers: Array = save.soldiers.keys().filter(func(c): return db.cards.has(c) and save.has_card(c))
	var wrap := Control.new()
	wrap.size = size
	add_child(wrap)
	_page = wrap
	var bg := ColorRect.new()
	bg.color = Kit.c("bg")
	bg.size = size
	wrap.add_child(bg)
	var title := Kit.label("查看卡牌（灰色 = 曾拥有，现不在手）", Kit.FONT_BIG, "gold")
	title.position = Vector2(28, 14)
	wrap.add_child(title)
	var back := Kit.button("返回", "gray")
	back.position = Vector2(1130, 10)
	back.custom_minimum_size = Vector2(130, 48)
	back.pressed.connect(_menu)
	wrap.add_child(back)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(28, 122)
	scroll.size = Vector2(1224, 580)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	wrap.add_child(scroll)
	var tabs := HBoxContainer.new()
	tabs.position = Vector2(28, 70)
	tabs.add_theme_constant_override("separation", 10)
	wrap.add_child(tabs)
	var show := func(ids: Array) -> void:
		for ch in scroll.get_children():
			ch.queue_free()
		var grid := GridContainer.new()
		grid.columns = 8
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		for cid in ids:
			var v := CardView.make(cid, Vector2(140, 196), {"skills": false})
			if not save.has_card(cid) and cid != "lord":
				v.modulate = Color(1, 1, 1, 0.45)
			v.pressed.connect(_preview.bind(cid))
			grid.add_child(v)
		scroll.add_child(grid)
	for t in [["武将（%d）" % generals.size(), generals], ["兵卡（%d）" % soldiers.size(), soldiers]]:
		var b := Kit.button(t[0], "blue", Kit.FONT_BODY)
		b.custom_minimum_size = Vector2(0, 46)
		b.pressed.connect(show.bind(t[1]))
		tabs.add_child(b)
	show.call(generals)


func _preview(cid: String) -> void:
	var overlay := Control.new()
	overlay.z_index = 10
	overlay.size = size
	var opened := Time.get_ticks_msec()
	var dim := Button.new()  # a fresh touch-down closes it (the lift of the tap that opened it must not)
	dim.size = size
	dim.focus_mode = Control.FOCUS_NONE
	for st in ["normal", "hover", "pressed", "focus"]:
		dim.add_theme_stylebox_override(st, Kit.box(Color(0, 0, 0, 0.82), 0, 0, Color.TRANSPARENT, 0))
	dim.button_down.connect(func():
		if Time.get_ticks_msec() - opened > 350:
			overlay.queue_free())
	overlay.add_child(dim)
	var v := CardView.make(cid, Vector2(320, 448), {"skills": false})
	v.position = Vector2(300, 120)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(v)
	var panel := Kit.skill_panel(v.fighter["skills"], 340)
	panel.position = Vector2(660, 130)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(panel)
	add_child(overlay)
