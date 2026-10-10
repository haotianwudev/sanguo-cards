class_name EndingsBook
extends Control
## 结局图鉴: every ending in data/endings.json — which ones this save has reached (the 结局 flags), and for the rest the hint.

signal closed

var _flags: Array = []  # the save's lasting story flags

var _scroll: ScrollContainer
var _list: VBoxContainer
var _tab_buttons: Array = []
var _cur_tab := "all"

var _dragging := false
var _touch_start := Vector2.ZERO
var _last_pos := Vector2.ZERO
var _velocity := 0.0
var _last_time := 0.0


func _ready() -> void:
	z_index = 70
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.size = size
	add_child(dim)

	var db := GameData.get_db()
	var reached: Array = db.endings_reached(_flags)
	var built: Array = db.ending_order.filter(func(id): return db.endings[id]["built"])

	var panel := PanelContainer.new()
	panel.position = Vector2(70, 20)
	panel.size = Vector2(1140, 680)
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 16, 2, Kit.c("border"), 22))
	add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)

	var title := Kit.label("结局图鉴　已打通 %d / %d（已实装 %d 个）" % [reached.size(), db.ending_order.size(), built.size()], Kit.FONT_BIG, "gold")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)

	# Tab bar for mobile quick navigation
	var south_count := db.ending_order.filter(func(id): return db.endings[id]["route"] in ["south", "both"]).size()
	var north_count := db.ending_order.filter(func(id): return db.endings[id]["route"] in ["north", "both"]).size()
	var tabs_row := HBoxContainer.new()
	tabs_row.add_theme_constant_override("separation", 12)
	tabs_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(tabs_row)

	var tab_defs: Array = [
		["all", "全　部 (%d)" % db.ending_order.size()],
		["south", "南线结局 (%d)" % south_count],
		["north", "北线结局 (%d)" % north_count],
		["got", "已达成 (%d)" % reached.size()],
	]

	for i in tab_defs.size():
		var tab_id: String = tab_defs[i][0]
		var label: String = tab_defs[i][1]
		var btn := Kit.button(label, "blue", Kit.FONT_BODY)
		btn.custom_minimum_size = Vector2(180, 42)
		btn.pressed.connect(_switch_tab.bind(tab_id))
		tabs_row.add_child(btn)
		_tab_buttons.append({"id": tab_id, "btn": btn})

	_update_tab_highlights()

	# Scroll view
	var scroll := ScrollContainer.new()
	_scroll = scroll
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.gui_input.connect(_on_scroll_input)
	col.add_child(scroll)

	var vbar := scroll.get_v_scroll_bar()
	if vbar != null:
		vbar.custom_minimum_size.x = 16

	var list := VBoxContainer.new()
	_list = list
	list.add_theme_constant_override("separation", 10)
	list.custom_minimum_size = Vector2(1080, 0)
	scroll.add_child(list)

	_populate_list()

	# Bottom controls with page-flip buttons
	var btm := HBoxContainer.new()
	btm.add_theme_constant_override("separation", 20)
	btm.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(btm)

	var prev := Kit.button("▲ 上一页", "blue", Kit.FONT_BODY)
	prev.custom_minimum_size = Vector2(160, 48)
	prev.pressed.connect(func(): _page_scroll(-1))
	btm.add_child(prev)

	var back := Kit.button("关　闭", "gray", Kit.FONT_BIG)
	back.custom_minimum_size = Vector2(240, 48)
	back.pressed.connect(_close)
	btm.add_child(back)

	var next := Kit.button("▼ 下一页", "blue", Kit.FONT_BODY)
	next.custom_minimum_size = Vector2(160, 48)
	next.pressed.connect(func(): _page_scroll(1))
	btm.add_child(next)

	Kit.focus(back)


func _process(delta: float) -> void:
	if _scroll == null:
		return
	if not _dragging and absf(_velocity) > 15.0:
		_scroll.scroll_vertical += int(_velocity * delta)
		_velocity = lerpf(_velocity, 0.0, 8.0 * delta)
	elif not _dragging:
		_velocity = 0.0


func _on_scroll_input(e: InputEvent) -> void:
	if e is InputEventScreenTouch:
		if e.pressed:
			_dragging = true
			_velocity = 0.0
			_touch_start = e.position
			_last_pos = e.position
			_last_time = Time.get_ticks_msec()
		else:
			_dragging = false
			var dx: float = e.position.x - _touch_start.x
			var dy: float = e.position.y - _touch_start.y
			if absf(dx) > 120.0 and absf(dx) > absf(dy) * 1.5:
				_page_scroll(1 if dx < 0 else -1)
	elif e is InputEventScreenDrag:
		_dragging = true
		_scroll.scroll_vertical -= int(e.relative.y)
		var now := Time.get_ticks_msec()
		var dt := maxf(0.001, float(now - _last_time) / 1000.0)
		_velocity = -e.relative.y / dt
		_last_pos = e.position
		_last_time = now
	elif e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				_dragging = true
				_velocity = 0.0
				_touch_start = e.position
				_last_pos = e.position
				_last_time = Time.get_ticks_msec()
			else:
				_dragging = false
				var dx: float = e.position.x - _touch_start.x
				var dy: float = e.position.y - _touch_start.y
				if absf(dx) > 120.0 and absf(dx) > absf(dy) * 1.5:
					_page_scroll(1 if dx < 0 else -1)
	elif e is InputEventMouseMotion and _dragging:
		_scroll.scroll_vertical -= int(e.relative.y)
		var now := Time.get_ticks_msec()
		var dt := maxf(0.001, float(now - _last_time) / 1000.0)
		_velocity = -e.relative.y / dt
		_last_pos = e.position
		_last_time = now


func _page_scroll(dir: int) -> void:
	if _scroll == null:
		return
	var step := int(_scroll.size.y * 0.85)
	var vbar := _scroll.get_v_scroll_bar()
	var max_val: int = int(vbar.max_value - _scroll.size.y) if vbar != null else 10000
	var target := clampi(_scroll.scroll_vertical + dir * step, 0, maxi(0, max_val))
	var tw := create_tween()
	tw.tween_property(_scroll, "scroll_vertical", target, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _switch_tab(tab_id: String) -> void:
	_cur_tab = tab_id
	_update_tab_highlights()
	_populate_list()
	if _scroll != null:
		_scroll.scroll_vertical = 0
		_velocity = 0.0


func _update_tab_highlights() -> void:
	for t in _tab_buttons:
		var btn: Button = t["btn"]
		var active: bool = (t["id"] == _cur_tab)
		btn.add_theme_color_override("font_color", Kit.c("gold") if active else Kit.c("text"))


func _populate_list() -> void:
	if _list == null:
		return
	for ch in _list.get_children():
		ch.queue_free()
	var db := GameData.get_db()
	var reached: Array = db.endings_reached(_flags)
	for id in db.ending_order:
		var e: Dictionary = db.endings[id]
		var match_tab := false
		match _cur_tab:
			"all":
				match_tab = true
			"south":
				match_tab = e["route"] in ["south", "both"]
			"north":
				match_tab = e["route"] in ["north", "both"]
			"got":
				match_tab = reached.has(id)
		if match_tab:
			_list.add_child(_row(e, reached.has(id)))


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	closed.emit()
	queue_free()


func _row(e: Dictionary, got: bool) -> Control:
	var box := PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	var bg := Kit.c("card") if got else Kit.c("card").darkened(0.45)
	box.add_theme_stylebox_override("panel", Kit.box(bg, 12, 2, Kit.c("gold") if got else Kit.c("gray"), 12))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	var pic := Kit.cg(e["cg"] if got else "end_locked")  # an unreached one shows the sealed thumbnail
	if pic != null:
		var tex := TextureRect.new()
		tex.mouse_filter = Control.MOUSE_FILTER_PASS
		tex.texture = pic
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.custom_minimum_size = Vector2(210, 118)
		row.add_child(tex)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_PASS
	col.add_theme_constant_override("separation", 4)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var route: String = {"south": "南线", "north": "北线", "both": "南北合一"}.get(e["route"], "")
	var kind: String = {"bad": "Bad End", "end": "结局", "true": "真结局"}.get(e["kind"], "")
	col.add_child(Kit.label("%s　%s · %s · %s" % [e["title"] if got else "？？？", route, e["chapter"], kind], Kit.FONT_BODY + 2, "gold" if got else "gray"))
	if got:
		col.add_child(_wrap("%s" % e["text"], "text"))
		col.add_child(_wrap("触发：%s" % e["trigger"], "muted"))
		col.add_child(_wrap("破局：%s" % e["unlock"], "muted"))
	else:
		col.add_child(_wrap("提示：%s" % e["hint"], "muted"))
		col.add_child(_wrap("关联人物：%s" % e["who"] + ("" if e["built"] else "　（尚未实装）"), "muted"))
	return box


func _wrap(text: String, color_name: String) -> Label:
	var l := Kit.label(text, 16, color_name)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(680, 0)
	return l
