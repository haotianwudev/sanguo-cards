class_name CardsBook
extends Control
## 卡牌图鉴 / 收藏: 展示此前通关结局时所持有的所有卡牌与其品阶级别。

signal closed

var save: SaveData

var _scroll: ScrollContainer
var _grid: GridContainer
var _tab_buttons: Array = []
var _cur_tab := "all"
var _cleared_ids: Array = []

var _dragging := false
var _touch_start := Vector2.ZERO
var _last_pos := Vector2.ZERO
var _velocity := 0.0
var _last_time := 0.0


func _ready() -> void:
	z_index = 75
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.size = size
	add_child(dim)

	if save == null:
		save = Game.save if Game.save != null else SaveData.read()
	if save == null:
		save = SaveData.create()

	_cleared_ids = save.get_cleared_cards()

	var panel := PanelContainer.new()
	panel.position = Vector2(70, 20)
	panel.size = Vector2(1140, 680)
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 16, 2, Kit.c("border"), 22))
	add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)

	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 2)
	col.add_child(header)

	var title := Kit.label("卡牌收藏　已通关收录 %d 张" % _cleared_ids.size(), Kit.FONT_BIG, "gold")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(title)

	var sub := Kit.label("仅收录历次通关结局时所持有的卡牌与品阶；点击卡牌可查看详细属性、专属技能与升阶进度", 14, "muted")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(sub)

	# Tabs row
	var tabs_row := HBoxContainer.new()
	tabs_row.add_theme_constant_override("separation", 12)
	tabs_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(tabs_row)

	var db := GameData.get_db()
	var ssr_count := _cleared_ids.filter(func(c): return db.cards.has(c) and db.cards[c]["rarity"] == "SSR").size()
	var sr_count := _cleared_ids.filter(func(c): return db.cards.has(c) and db.cards[c]["rarity"] == "SR").size()
	var r_count := _cleared_ids.filter(func(c): return db.cards.has(c) and db.cards[c]["rarity"] == "R").size()
	var soldier_count := _cleared_ids.filter(func(c): return db.cards.has(c) and db.cards[c]["soldier"]).size()

	var tab_defs: Array = [
		["all", "全　部 (%d)" % _cleared_ids.size()],
		["SSR", "SSR 名将 (%d)" % ssr_count],
		["SR", "SR 良将 (%d)" % sr_count],
		["R", "R 辅将 (%d)" % r_count],
		["soldier", "部　队 (%d)" % soldier_count],
	]

	for i in tab_defs.size():
		var tab_id: String = tab_defs[i][0]
		var label: String = tab_defs[i][1]
		var btn := Kit.button(label, "blue", Kit.FONT_BODY)
		btn.custom_minimum_size = Vector2(170, 42)
		btn.pressed.connect(_switch_tab.bind(tab_id))
		tabs_row.add_child(btn)
		_tab_buttons.append({"id": tab_id, "btn": btn})

	_update_tab_highlights()

	# Scroll Container
	var scroll := ScrollContainer.new()
	_scroll = scroll
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.gui_input.connect(_on_scroll_input)
	col.add_child(scroll)

	var vbar := scroll.get_v_scroll_bar()
	if vbar != null:
		vbar.custom_minimum_size.x = 16

	var grid := GridContainer.new()
	_grid = grid
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	grid.custom_minimum_size = Vector2(1080, 0)
	scroll.add_child(grid)

	_populate_grid()

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
	_populate_grid()
	if _scroll != null:
		_scroll.scroll_vertical = 0
		_velocity = 0.0


func _update_tab_highlights() -> void:
	for t in _tab_buttons:
		var btn: Button = t["btn"]
		var active: bool = (t["id"] == _cur_tab)
		btn.add_theme_color_override("font_color", Kit.c("gold") if active else Kit.c("text"))


func _populate_grid() -> void:
	if _grid == null:
		return
	for ch in _grid.get_children():
		ch.queue_free()

	var db := GameData.get_db()
	var list: Array = []
	for cid in _cleared_ids:
		var c: Dictionary = db.cards.get(cid, {})
		if c.is_empty():
			continue
		var match_tab := false
		match _cur_tab:
			"all":
				match_tab = true
			"soldier":
				match_tab = c.get("soldier", false)
			"SSR", "SR", "R":
				match_tab = (not c.get("soldier", false) and c.get("rarity", "") == _cur_tab)
		if match_tab:
			list.append(cid)

	if list.is_empty():
		var empty_lbl := Kit.label("该分类下暂无已通关收录的卡牌", 18, "muted")
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.custom_minimum_size = Vector2(1080, 180)
		_grid.add_child(empty_lbl)
		return

	for cid in list:
		_grid.add_child(_card_cell(cid))


func _card_cell(cid: String) -> Control:
	var cell := VBoxContainer.new()
	cell.add_theme_constant_override("separation", 6)
	cell.alignment = BoxContainer.ALIGNMENT_CENTER

	var tier_val := save.permanent_tier(cid)
	var card_view := CardView.make(cid, Vector2(160, 224), {"skills": false, "tier": tier_val})
	card_view.pressed.connect(_inspect_card.bind(cid))
	cell.add_child(card_view)

	var info := save.card_level_info(cid)
	var badge_box := PanelContainer.new()
	var tier_color: Color = Kit.c("gray")
	if not info["soldier"]:
		match info["tier"]:
			0: tier_color = Color(0.85, 0.55, 0.2)  # 铜
			1: tier_color = Color(0.8, 0.9, 1.0)   # 银
			2: tier_color = Kit.c("gold")          # 金
			_: tier_color = Kit.c("purple")

	badge_box.add_theme_stylebox_override("panel", Kit.box(Color(0, 0, 0, 0.65), 6, 1, tier_color, 4))
	var badge_col := VBoxContainer.new()
	badge_col.add_theme_constant_override("separation", 1)
	badge_box.add_child(badge_col)

	var t_text := "%s　%d 张" % [info["tier_name"], info["copies"]]
	var t_lbl := Kit.label(t_text, 13)
	t_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t_lbl.add_theme_color_override("font_color", tier_color)
	badge_col.add_child(t_lbl)

	cell.add_child(badge_box)
	return cell


func _inspect_card(cid: String) -> void:
	var db := GameData.get_db()
	var overlay := Control.new()
	overlay.z_index = 85
	overlay.size = size
	add_child(overlay)

	var dim := Button.new()
	dim.size = size
	dim.focus_mode = Control.FOCUS_NONE
	for st in ["normal", "hover", "pressed", "focus"]:
		dim.add_theme_stylebox_override(st, Kit.box(Color(0, 0, 0, 0.85), 0, 0, Color.TRANSPARENT, 0))
	dim.button_down.connect(func(): overlay.queue_free())
	overlay.add_child(dim)

	var modal := PanelContainer.new()
	modal.position = Vector2(230, 90)
	modal.size = Vector2(820, 540)
	modal.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 16, 2, Kit.c("gold"), 22))
	overlay.add_child(modal)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	modal.add_child(hbox)

	var tier_val := save.permanent_tier(cid)
	var big_card := CardView.make(cid, Vector2(280, 392), {"skills": false, "tier": tier_val})
	big_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(big_card)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 12)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(right)

	var c: Dictionary = db.cards[cid]
	var troop: Dictionary = db.troops.get(c["troop"], {})
	var info := save.card_level_info(cid)

	var title_lbl := Kit.label("%s　%s · %s" % [c["name"], troop.get("name", ""), c.get("rarity", "")], Kit.FONT_BIG, "gold")
	right.add_child(title_lbl)

	# Level progression panel
	var prog_panel := PanelContainer.new()
	prog_panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 10, 1, Kit.c("border"), 12))
	var prog_col := VBoxContainer.new()
	prog_col.add_theme_constant_override("separation", 6)
	prog_panel.add_child(prog_col)

	var t_row := Kit.label("当前品阶：%s（持有副本 %d 张，属性倍率 ×%.1f）" % [info["tier_name"], info["copies"], info["mult"]], Kit.FONT_BODY, "gold")
	prog_col.add_child(t_row)

	if not info["soldier"]:
		if info["maxed"]:
			var max_l := Kit.label("★ 已达到最高品阶（金阶），享受满额战力加成！", 14, "green")
			prog_col.add_child(max_l)
		else:
			var need: int = info["next_copies"] - info["copies"]
			var next_l := Kit.label("升至 %s 还需 %d 张（达成目标需要 %d 张）" % [info["next_tier_name"], need, info["next_copies"]], 14, "muted")
			prog_col.add_child(next_l)
			var bar := Kit.bar(info["copies"], info["next_copies"], "gold", 16)
			prog_col.add_child(bar)
	else:
		var sol_l := Kit.label("部队基础兵种，战斗中同兵种可换人登场", 14, "muted")
		prog_col.add_child(sol_l)

	right.add_child(prog_panel)

	# Skill panel
	var fighter: Dictionary = big_card.fighter
	var skills: Array = fighter.get("skills", [])
	if not skills.is_empty():
		right.add_child(Kit.label("专属技能：", Kit.FONT_BODY, "text"))
		var spanel := Kit.skill_panel(skills, 440)
		right.add_child(spanel)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	right.add_child(btn_row)

	var close_btn := Kit.button("返　回", "gray", Kit.FONT_BODY)
	close_btn.custom_minimum_size = Vector2(140, 42)
	close_btn.pressed.connect(func(): overlay.queue_free())
	btn_row.add_child(close_btn)


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	closed.emit()
	queue_free()
