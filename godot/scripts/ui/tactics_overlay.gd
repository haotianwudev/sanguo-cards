class_name TacticsOverlay
extends Control
## 军令 (v3): how 自动 plays. A preset for the whole party (battle.json tactics.presets: 拆招 / 猛攻 / 省技), 自动换人 on / off,
## and per card up to max_rows rules [skill, condition, 留气] tried top to bottom (AutoPlayer.plan). Kept in Game.options.tactics,
## so it holds for every save, route and lap. Opened from the battle screen (军令) — `cards` = the card dicts to edit.

var cards: Array = []
var _sel := 0
var _t: Dictionary
var _list: VBoxContainer
var _rows: VBoxContainer
var _preset_box: HBoxContainer
var _preset_desc: Label
var _swap_btn: Button


func _ready() -> void:
	z_index = 80
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var base: Dictionary = Game.options.get("tactics", {})
	_t = AutoPlayer.default_tactics()
	for k in base:
		_t[k] = base[k]
	_t = _t.duplicate(true)
	if not (_t["rows"] is Dictionary):
		_t["rows"] = {}
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 14, 3, Kit.c("gold"), 18))
	panel.position = Vector2(40, 24)
	panel.custom_minimum_size = Vector2(1200, 672)
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 16)
	var title := Kit.label("军　令", Kit.FONT_BIG, "gold")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Kit.button("完成", "gold", Kit.FONT_BODY)
	close.custom_minimum_size = Vector2(130, 50)
	close.pressed.connect(queue_free)
	head.add_child(close)
	col.add_child(head)

	_preset_box = HBoxContainer.new()
	_preset_box.add_theme_constant_override("separation", 10)
	col.add_child(_preset_box)
	_preset_desc = Kit.label("", Kit.FONT_SMALL, "muted")
	col.add_child(_preset_desc)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)
	var ls := ScrollContainer.new()
	ls.custom_minimum_size = Vector2(300, 0)
	ls.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(ls)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 6)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ls.add_child(_list)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	body.add_child(right)
	right.add_child(Kit.label("从上往下，第一条条件成立、技能能用的就放。都不成立就按默认估值出手。勾「留气」= 这条只差 AP 时，别人先别花 AP。", Kit.FONT_SMALL, "muted"))
	right.get_child(0).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 10)
	right.add_child(_rows)
	_build()


func _cfg() -> Dictionary:
	return GameData.get_db().battle.get("tactics", {})


func _save() -> void:
	Game.set_option("tactics", _t.duplicate(true))


func _build() -> void:
	for ch in _preset_box.get_children():
		ch.queue_free()
	var presets: Dictionary = _cfg().get("presets", {})
	for pid in presets:
		var p: Dictionary = presets[pid]
		var on: bool = str(_t["preset"]) == pid
		var btn := Kit.button(str(p["name"]), "gold" if on else "gray", Kit.FONT_BODY)
		btn.custom_minimum_size = Vector2(130, 48)
		btn.pressed.connect(func():
			_t["preset"] = pid
			_save()
			_build())
		_preset_box.add_child(btn)
		if on:
			_preset_desc.text = "%s：%s" % [p["name"], p.get("desc", "")]
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preset_box.add_child(spacer)
	_swap_btn = Kit.button("自动换人：%s" % ("开" if _t.get("auto_swap", false) else "关"), "purple" if _t.get("auto_swap", false) else "gray", Kit.FONT_BODY)
	_swap_btn.custom_minimum_size = Vector2(200, 48)
	_swap_btn.pressed.connect(func():
		_t["auto_swap"] = not _t.get("auto_swap", false)
		_save()
		_build())
	_preset_box.add_child(_swap_btn)

	for ch in _list.get_children():
		ch.queue_free()
	for k in cards.size():
		var c: Dictionary = cards[k]
		var n: int = _t["rows"].get(str(c["id"]), []).size()
		var btn := Kit.button("%s%s" % [_card_name(c), ("　%d 条" % n) if n > 0 else ""], "gold" if k == _sel else "gray", Kit.FONT_BODY)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.clip_text = true
		btn.custom_minimum_size = Vector2(280, 48)
		btn.pressed.connect(func():
			_sel = k
			_build())
		_list.add_child(btn)
	_build_rows()


func _card_name(c: Dictionary) -> String:
	if str(c["id"]) == "lord":
		return "主公"
	return str(c["name"]).replace("·", " ")  # versions of one person (孙策 / 孙策 小霸王) must tell apart


func _build_rows() -> void:
	for ch in _rows.get_children():
		ch.queue_free()
	if cards.is_empty():
		return
	var c: Dictionary = cards[clampi(_sel, 0, cards.size() - 1)]
	var cid := str(c["id"])
	var rows: Array = _t["rows"].get(cid, [])
	var db := GameData.get_db()
	var conds: Dictionary = _cfg().get("conditions", {})
	var cond_ids: Array = conds.keys()
	_rows.add_child(Kit.label(_card_name(c) + " 的军令", Kit.FONT_BODY + 2, "gold"))
	for r in rows.size():
		var row: Dictionary = rows[r]
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 10)
		line.add_child(Kit.label("%d." % (r + 1), Kit.FONT_BODY, "muted"))
		line.add_child(Kit.label("当", Kit.FONT_BODY))
		var cb := OptionButton.new()
		cb.custom_minimum_size = Vector2(200, 48)
		cb.add_theme_font_size_override("font_size", Kit.FONT_BODY)
		for ci in cond_ids.size():
			cb.add_item(str(conds[cond_ids[ci]]), ci)
		cb.selected = maxi(0, cond_ids.find(str(row.get("cond", "always"))))
		cb.item_selected.connect(func(idx):
			row["cond"] = cond_ids[idx]
			_save())
		line.add_child(cb)
		line.add_child(Kit.label("放", Kit.FONT_BODY))
		var sb := OptionButton.new()
		sb.custom_minimum_size = Vector2(240, 48)
		sb.add_theme_font_size_override("font_size", Kit.FONT_BODY)
		var sids: Array = c.get("skills", [])
		for si in sids.size():
			var sk: Dictionary = db.skills[sids[si]]
			sb.add_item("%s AP%d" % [sk["name"], int(sk["cost"])], si)
		sb.selected = maxi(0, sids.find(str(row.get("skill", ""))))
		sb.item_selected.connect(func(idx):
			row["skill"] = sids[idx]
			_save())
		line.add_child(sb)
		var rv := CheckBox.new()
		rv.text = "留气"
		rv.add_theme_font_size_override("font_size", Kit.FONT_BODY)
		rv.button_pressed = bool(row.get("reserve", false))
		rv.toggled.connect(func(on):
			row["reserve"] = on
			_save())
		line.add_child(rv)
		var up := Kit.button("↑", "gray", Kit.FONT_BODY)
		up.custom_minimum_size = Vector2(48, 48)
		up.disabled = r == 0
		up.pressed.connect(func():
			rows.remove_at(r)
			rows.insert(r - 1, row)
			_save()
			_build())
		line.add_child(up)
		var del := Kit.button("删", "red", Kit.FONT_BODY)
		del.custom_minimum_size = Vector2(60, 48)
		del.pressed.connect(func():
			rows.remove_at(r)
			if rows.is_empty():
				_t["rows"].erase(cid)
			_save()
			_build())
		line.add_child(del)
		_rows.add_child(line)
	if rows.size() < int(_cfg().get("max_rows", 4)) and not c.get("skills", []).is_empty():
		var add := Kit.button("＋ 加一条", "blue", Kit.FONT_BODY)
		add.custom_minimum_size = Vector2(200, 48)
		add.pressed.connect(func():
			var list: Array = _t["rows"].get(cid, [])
			list.append({"skill": c["skills"][0], "cond": "always", "reserve": false})
			_t["rows"][cid] = list
			_save()
			_build())
		_rows.add_child(add)
	if rows.is_empty():
		_rows.add_child(Kit.label("还没有军令：自动时按预设和默认估值出手。", Kit.FONT_SMALL, "muted"))
