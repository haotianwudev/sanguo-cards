class_name PrepScreen
extends Control
## 前尘整备 (Rance X style 周目 perks): shown before every 周目 from the second on. 前尘点 = different endings reached (battle.json
## prep.per_ending each); they are not spent for good — every 周目 shares them out again, starting from last time's choice.
## Left: the perks (battle.json prep.perks, a 四字 name each, bought in copies up to max). Right: cards to bring along — the named
## 名将 / 名兵 (prep.cards, each with its own 四字 name and price) and the remembered ones (招兵买马 soldiers / 旧雨重逢 generals).
## 出发 applies it all (SaveData.apply_prep), opens the 开门大吉 chests, then starts the map.

var _points: Label
var _go: Button
var _rows := {}  # perk id -> {count: Label, minus: Button, plus: Button}
var _card_btns := {}  # card id -> Button
var _relic_btns := {}  # relic id -> Button


func _ready() -> void:
	var save := Game.save
	_trim(save)
	var bg := ColorRect.new()
	bg.color = Kit.c("bg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_right = -24
	root.offset_top = 16
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 24)
	root.add_child(head)
	head.add_child(Kit.label("前尘整备 · 第 %d 周目" % save.lap, Kit.FONT_TITLE, "gold"))
	_points = Kit.label("", Kit.FONT_BIG, "text")
	head.add_child(_points)
	var tip := Kit.label("每走到一个不同的结局，记起一点前尘。点数不会用掉：每个周目开始时重新分配。", 15, "muted")
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(tip)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	root.add_child(body)
	body.add_child(_perk_column(save))
	body.add_child(_card_column(save))

	var foot := HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	foot.add_theme_constant_override("separation", 16)
	root.add_child(foot)
	var clear := Kit.button("全部清空", "gray")
	clear.custom_minimum_size = Vector2(180, 56)
	clear.pressed.connect(func():
		save.perks = {}
		save.prep_cards = []
		save.prep_relics = []
		_sync())
	foot.add_child(clear)
	_go = Kit.button("出　发", "green", Kit.FONT_BIG)
	_go.custom_minimum_size = Vector2(260, 56)
	_go.pressed.connect(_depart)
	foot.add_child(_go)
	Kit.focus(_go)
	_sync()


static func _trim(save: SaveData) -> void:
	## last 周目's choice may no longer fit (or name cards no longer remembered): drop cards, then perks, until it does
	var choices := save.prep_card_choices() + save.prep_named().keys()
	save.prep_cards = save.prep_cards.filter(func(c): return choices.has(c))
	var rel := save.prep_relic_choices()
	save.prep_relics = save.prep_relics.filter(func(r): return rel.has(r))
	while save.prep_spent() > save.prep_points() and not save.prep_relics.is_empty():
		save.prep_relics.pop_back()
	var cfg: Array = save.prep_cfg().get("perks", [])
	for p in cfg:
		if save.perk(p["id"]) > int(p["max"]):
			save.perks[p["id"]] = int(p["max"])
	while save.prep_spent() > save.prep_points() and not save.prep_cards.is_empty():
		save.prep_cards.pop_back()
	for i in range(cfg.size() - 1, -1, -1):  # the dearest perks go first
		while save.prep_spent() > save.prep_points() and save.perk(cfg[i]["id"]) > 0:
			save.perks[cfg[i]["id"]] = save.perk(cfg[i]["id"]) - 1


func _panel(title: String) -> Array:
	## [panel, inner column]
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 14, 2, Kit.c("border"), 14))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)
	col.add_child(Kit.label(title, Kit.FONT_BIG, "gold"))
	return [panel, col]


func _perk_column(save: SaveData) -> Control:
	var pc := _panel("前尘特典")
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pc[1].add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 6)
	scroll.add_child(list)
	for p in save.prep_cfg().get("perks", []):
		var id: String = p["id"]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		list.add_child(row)
		var cost := Kit.label("%d 点" % int(p["cost"]), Kit.FONT_BODY, "gold")
		cost.custom_minimum_size = Vector2(56, 0)
		row.add_child(cost)
		var txt := VBoxContainer.new()
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		txt.add_theme_constant_override("separation", 0)
		row.add_child(txt)
		txt.add_child(Kit.label(p["name"], Kit.FONT_BODY + 2, "text"))
		var d := Kit.label(p["desc"], 14, "muted")
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		txt.add_child(d)
		var minus := Kit.button("−", "gray")
		minus.custom_minimum_size = Vector2(48, 44)
		minus.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		minus.pressed.connect(func():
			save.perks[id] = maxi(0, save.perk(id) - 1)
			_sync())
		row.add_child(minus)
		var count := Kit.label("", Kit.FONT_BODY, "text")
		count.custom_minimum_size = Vector2(44, 0)
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(count)
		var plus := Kit.button("+", "blue")
		plus.custom_minimum_size = Vector2(48, 44)
		plus.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		plus.pressed.connect(func():
			save.perks[id] = save.perk(id) + 1
			_sync())
		row.add_child(plus)
		_rows[id] = {"count": count, "minus": minus, "plus": plus, "cost": int(p["cost"]), "max": int(p["max"])}
	return pc[0]


func _card_column(save: SaveData) -> Control:
	var cfg := save.prep_cfg()
	var pc := _panel("带卡入局 · 宝物")
	var tip := Kit.label("名将 / 名兵：按标价带入（标了北线 / 南线的，选了那条线的出生地才到）。%s：记得的兵卡 %d 点 / 张　%s：记得的武将 %d 点 / 张（等级照记得的算，再加一级）" % [
		cfg.get("card_soldier_name", ""), int(cfg.get("card_soldier", 1)),
		cfg.get("card_general_name", ""), int(cfg.get("card_general", 2))], 14, "muted")
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pc[1].add_child(tip)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pc[1].add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var db := GameData.get_db()
	var named := save.prep_named()
	for soldier in [false, true]:  # 名将 / 名兵: bought at their own price, remembered or not
		var ids: Array = named.keys().filter(func(c): return db.cards[c]["soldier"] == soldier)
		if ids.is_empty():
			continue
		list.add_child(Kit.label("名兵" if soldier else "名将", Kit.FONT_BODY, "gold"))
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 6)
		flow.add_theme_constant_override("v_separation", 6)
		list.add_child(flow)
		for cid in ids:
			var sc := str(db.cards[cid].get("scope", ""))
			_card_button(flow, cid, "%s · %s%s　%d 点" % [named[cid]["name"], db.cards[cid]["name"],
				{"north": "（北线）", "south": "（南线）"}.get(sc, ""), int(named[cid]["cost"])])
	var choices := save.prep_card_choices()
	var order := ["SSR", "SR", "R", "C", "N"]
	choices.sort_custom(func(a, b): return order.find(db.cards[a]["rarity"]) < order.find(db.cards[b]["rarity"]))
	for soldier in [false, true]:
		var ids := choices.filter(func(c): return db.cards[c]["soldier"] == soldier)
		if ids.is_empty():
			continue
		list.add_child(Kit.label(cfg.get("card_soldier_name" if soldier else "card_general_name", ""), Kit.FONT_BODY, "gold"))
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 6)
		flow.add_theme_constant_override("v_separation", 6)
		list.add_child(flow)
		for cid in ids:
			_card_button(flow, cid, "%s %s" % [db.cards[cid]["name"], Kit.rarity_label(db.cards[cid]["rarity"])])
	if choices.is_empty():
		list.add_child(Kit.label("还没有记得的卡：走到结局时手上的卡才会被记住。", 15, "muted"))
	# 宝物: a few on sale, worn from the first chapter on
	var rdb := db.relics
	var rids := save.prep_relic_choices()
	if not rids.is_empty():
		list.add_child(Kit.label("宝物", Kit.FONT_BODY, "gold"))
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 6)
		flow.add_theme_constant_override("v_separation", 6)
		list.add_child(flow)
		for rid in rids:
			var b := Kit.button("%s　%d 点" % [rdb[rid]["name"], save.prep_relic_cost(rid)], "gray", 15)
			b.toggle_mode = true
			b.custom_minimum_size = Vector2(0, 40)
			b.tooltip_text = str(rdb[rid].get("desc", ""))
			b.toggled.connect(func(on):
				if on and not save.prep_relics.has(rid):
					save.prep_relics.append(rid)
				elif not on:
					save.prep_relics.erase(rid)
				_sync())
			flow.add_child(b)
			_relic_btns[rid] = b
	return pc[0]


func _card_button(flow: Control, cid: String, text: String) -> void:
	var save := Game.save
	var b := Kit.button(text, "gray", 15)
	b.toggle_mode = true
	b.custom_minimum_size = Vector2(0, 40)
	b.toggled.connect(func(on):
		if on and not save.prep_cards.has(cid):
			save.prep_cards.append(cid)
		elif not on:
			save.prep_cards.erase(cid)
		_sync())
	flow.add_child(b)
	_card_btns[cid] = b


func _depart() -> void:
	## 出发: 开门大吉 opens its chests first (pick one card each), then the story
	_go.disabled = true
	var save := Game.save
	save.apply_prep()
	for _i in save.perk("start_chest"):
		var chest := save.prep_chest(Game.rng)
		if chest.is_empty():
			break
		var o := PickOverlay.new()
		o.title = "开门大吉 —— 选一张卡带走"
		o.chest = "normal"
		o.card_ids = chest.map(func(c): return c["id"])
		o.counts = chest.map(func(c): return save.copies(c["id"]))
		o.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(o)
		var i: int = await o.picked
		save.take(chest[i]["id"])
		o.queue_free()
	Game.start_lap()


func _sync() -> void:
	var save := Game.save
	var left := save.prep_points() - save.prep_spent()
	_points.text = "前尘 %d / %d" % [left, save.prep_points()]
	for id in _rows:
		var r: Dictionary = _rows[id]
		var n := save.perk(id)
		r["count"].text = "%d/%d" % [n, r["max"]]
		r["minus"].disabled = n <= 0
		r["plus"].disabled = n >= r["max"] or r["cost"] > left
	for cid in _card_btns:
		var b: Button = _card_btns[cid]
		var on := save.prep_cards.has(cid)
		b.set_pressed_no_signal(on)
		b.modulate = Color(1.0, 0.85, 0.4) if on else Color.WHITE
		b.disabled = not on and save.prep_card_cost(cid) > left
	for rid in _relic_btns:
		var b: Button = _relic_btns[rid]
		var on := save.prep_relics.has(rid)
		b.set_pressed_no_signal(on)
		b.modulate = Color(1.0, 0.85, 0.4) if on else Color.WHITE
		b.disabled = not on and save.prep_relic_cost(rid) > left
