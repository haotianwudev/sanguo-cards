class_name TacticsOverlay
extends Control
## 军令 (v3): how 自动 plays, in three layers (user rule) — 整体 (a preset + 中军 rows: 防御 / 留 AP / 换人 rules),
## 兵种 (per troop: a kind of skill, matched to each leader's own), 武将 (per card: a named skill, 留气). Every row has two
## conditions that must both hold; rows are tried top to bottom (AutoPlayer.plan). Kept in Game.options.tactics (every save,
## route and lap). Opened from 整备 (全军军令 / a party slot's 军令 / a card's 军令, via focus()) and from the battle
## screen (军令) — `cards` = the card dicts the 武将 tab lists.

var cards: Array = []
var _tab := "party"
var _sel_troop := 0
var _sel_card := 0
var _t: Dictionary
var _tabs: HBoxContainer
var _body: HBoxContainer


func _ready() -> void:
	z_index = 80
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_t = AutoPlayer.with_defaults(Game.options.get("tactics", {}))
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 14, 3, Kit.c("gold"), 16))
	panel.position = Vector2(30, 20)
	panel.custom_minimum_size = Vector2(1220, 680)
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	head.add_child(Kit.label("军令", Kit.FONT_BIG, "gold"))
	_tabs = HBoxContainer.new()
	_tabs.add_theme_constant_override("separation", 8)
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_tabs)
	var close := Kit.button("完成", "gold", Kit.FONT_BODY)
	close.custom_minimum_size = Vector2(120, 48)
	close.pressed.connect(queue_free)
	head.add_child(close)
	col.add_child(head)
	col.add_child(Kit.label("顺序：先破招 → 整体（中军）→ 武将 → 兵种 → 默认估值。每条两个条件都成立、动作能做就执行。", Kit.FONT_SMALL, "muted"))
	_body = HBoxContainer.new()
	_body.add_theme_constant_override("separation", 16)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_body)
	_build()


func focus(tab: String, key := "") -> void:
	## open on a tab with one entry picked: "troop" + a troop id, "card" + a card id (callable before it is added)
	_tab = tab
	if tab == "troop" and key != "":
		_sel_troop = maxi(0, _troops().find(key))
	elif tab == "card" and key != "":
		for k in cards.size():
			if str(cards[k]["id"]) == key:
				_sel_card = k
	if is_node_ready():
		_build()


func show_tab(tab: String) -> void:
	_tab = tab
	_build()


func _cfg() -> Dictionary:
	return GameData.get_db().battle.get("tactics", {})


func _save() -> void:
	Game.set_option("tactics", _t.duplicate(true))


func _troops() -> Array:
	return GameData.get_db().troops.keys()


func _build() -> void:
	for ch in _tabs.get_children():
		ch.queue_free()
	for pair in [["party", "整体"], ["troop", "兵种"], ["card", "武将"]]:
		var on: bool = _tab == pair[0]
		var tb := Kit.button(pair[1], "gold" if on else "gray", Kit.FONT_BODY)
		tb.custom_minimum_size = Vector2(110, 48)
		tb.pressed.connect(func(): show_tab(pair[0]))
		_tabs.add_child(tb)
	for ch in _body.get_children():
		ch.queue_free()
	match _tab:
		"party":
			_build_party()
		"troop":
			_build_list(_troops().map(func(tid): return _troop_name(tid) + _count_text(_t["troop_rows"].get(tid, []))), _sel_troop, func(k):
				_sel_troop = k
				_build())
			var tid: String = _troops()[clampi(_sel_troop, 0, _troops().size() - 1)]
			_build_rows(_troop_name(tid) + "队 的军令", _rows_in(_t["troop_rows"], tid), _cfg().get("troop_acts", {}), "act", false, "放")
		"card":
			if cards.is_empty():
				return
			_build_list(cards.map(func(c): return _card_name(c) + _count_text(_t["rows"].get(str(c["id"]), []))), _sel_card, func(k):
				_sel_card = k
				_build())
			var c: Dictionary = cards[clampi(_sel_card, 0, cards.size() - 1)]
			var acts := {}
			for sid in c.get("skills", []):
				var sk: Dictionary = GameData.get_db().skills[sid]
				acts[sid] = "%s AP%d" % [sk["name"], int(sk["cost"])]
			_build_rows(_card_name(c) + " 的军令（比兵种军令先看）", _rows_in(_t["rows"], str(c["id"])), acts, "skill", true, "放")


func _rows_in(holder: Dictionary, key: String) -> Array:
	## the row list for that key, stored in the holder (so edits land in _t)
	if not holder.has(key):
		holder[key] = []
	return holder[key]


func _count_text(rows: Array) -> String:
	return ("　%d 条" % rows.size()) if not rows.is_empty() else ""


func _troop_name(tid: String) -> String:
	return "主公" if tid == "lord" else str(GameData.get_db().troops[tid]["name"])


func _card_name(c: Dictionary) -> String:
	if str(c["id"]) == "lord":
		return "主公"
	return str(c["name"]).replace("·", " ")  # versions of one person (孙策 / 孙策 小霸王) must tell apart


func _build_list(names: Array, sel: int, pick: Callable) -> void:
	var ls := ScrollContainer.new()
	ls.custom_minimum_size = Vector2(250, 0)
	ls.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_body.add_child(ls)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ls.add_child(list)
	for k in names.size():
		var btn := Kit.button(str(names[k]), "gold" if k == sel else "gray", Kit.FONT_BODY)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.clip_text = true
		btn.custom_minimum_size = Vector2(236, 46)
		btn.pressed.connect(func(): pick.call(k))
		list.add_child(btn)


func _build_party() -> void:
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	_body.add_child(right)
	var pre_row := HBoxContainer.new()
	pre_row.add_theme_constant_override("separation", 10)
	pre_row.add_child(Kit.label("预设", Kit.FONT_BODY, "gold"))
	var presets: Dictionary = _cfg().get("presets", {})
	var desc := ""
	for pid in presets:
		var p: Dictionary = presets[pid]
		var on: bool = str(_t["preset"]) == pid
		var btn := Kit.button(str(p["name"]), "gold" if on else "gray", Kit.FONT_BODY)
		btn.custom_minimum_size = Vector2(110, 46)
		btn.pressed.connect(func():
			_t["preset"] = pid
			_save()
			_build())
		pre_row.add_child(btn)
		if on:
			desc = str(p.get("desc", ""))
	pre_row.add_child(Kit.label(desc, Kit.FONT_SMALL, "muted"))
	right.add_child(pre_row)
	var holder := VBoxContainer.new()
	holder.add_theme_constant_override("separation", 10)
	right.add_child(holder)
	_fill_rows(holder, "中军军令（防御 / 留 AP / 换人）", _t["party_rows"], _cfg().get("party_acts", {}), "act", false, "就")


func _build_rows(title: String, rows: Array, acts: Dictionary, key: String, reserve: bool, verb: String) -> void:
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	_body.add_child(right)
	_fill_rows(right, title, rows, acts, key, reserve, verb)


func _option(items: Dictionary, current: String, width: float, on_pick: Callable) -> OptionButton:
	var ob := OptionButton.new()
	ob.custom_minimum_size = Vector2(width, 46)
	ob.add_theme_font_size_override("font_size", Kit.FONT_SMALL)
	ob.clip_text = true
	var ids: Array = items.keys()
	for k in ids.size():
		ob.add_item(str(items[ids[k]]), k)
	ob.selected = maxi(0, ids.find(current))
	ob.item_selected.connect(func(idx): on_pick.call(ids[idx]))
	return ob


func _fill_rows(box: VBoxContainer, title: String, rows: Array, acts: Dictionary, key: String, reserve: bool, verb: String) -> void:
	box.add_child(Kit.label(title, Kit.FONT_BODY + 2, "gold"))
	var conds: Dictionary = _cfg().get("conditions", {})
	var cw := 140.0 if reserve else 160.0  # the 武将 tab has a list on the left and a 留气 box: narrower dropdowns
	var aw := 180.0 if reserve else 200.0
	for r in rows.size():
		var row: Dictionary = rows[r]
		if not acts.has(str(row.get(key, ""))) and str(row.get(key, "")) != "":
			acts = acts.duplicate()  # a saved skill this card no longer has: still show what the row says
			var gone: Dictionary = GameData.get_db().skills.get(str(row[key]), {})
			acts[str(row[key])] = "%s（无）" % str(gone.get("name", row[key]))
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 6)
		line.add_child(Kit.label("%d. 当" % (r + 1), Kit.FONT_SMALL, "muted"))
		line.add_child(_option(conds, str(row.get("cond", "always")), cw, func(v):
			row["cond"] = v
			_save()))
		line.add_child(Kit.label("且", Kit.FONT_SMALL, "muted"))
		line.add_child(_option(conds, str(row.get("cond2", "always")), cw, func(v):
			row["cond2"] = v
			_save()))
		line.add_child(Kit.label(verb, Kit.FONT_SMALL, "muted"))
		line.add_child(_option(acts, str(row.get(key, "")), aw, func(v):
			row[key] = v
			_save()))
		if reserve:
			var rv := CheckBox.new()
			rv.text = "留气"
			rv.add_theme_font_size_override("font_size", Kit.FONT_SMALL)
			rv.button_pressed = bool(row.get("reserve", false))
			rv.toggled.connect(func(on):
				row["reserve"] = on
				_save())
			line.add_child(rv)
		var up := Kit.button("↑", "gray", Kit.FONT_BODY)
		up.custom_minimum_size = Vector2(44, 46)
		up.disabled = r == 0
		up.pressed.connect(func():
			rows.remove_at(r)
			rows.insert(r - 1, row)
			_save()
			_build())
		line.add_child(up)
		var del := Kit.button("删", "red", Kit.FONT_BODY)
		del.custom_minimum_size = Vector2(52, 46)
		del.pressed.connect(func():
			rows.remove_at(r)
			_save()
			_build())
		line.add_child(del)
		box.add_child(line)
	if rows.size() < int(_cfg().get("max_rows", 4)) and not acts.is_empty():
		var add := Kit.button("＋ 加一条", "blue", Kit.FONT_BODY)
		add.custom_minimum_size = Vector2(200, 46)
		add.pressed.connect(func():
			var fresh := {"cond": "always", "cond2": "always"}
			fresh[key] = acts.keys()[0]
			if reserve:
				fresh["reserve"] = false
			rows.append(fresh)
			_save()
			_build())
		box.add_child(add)
	if rows.is_empty():
		box.add_child(Kit.label("还没有军令。", Kit.FONT_SMALL, "muted"))
