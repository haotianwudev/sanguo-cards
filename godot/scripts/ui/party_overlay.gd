class_name PartyOverlay
extends Control
## 整备 (Rance X style): the party along the top, the card pool (filter by kind / troop, sort) bottom left,
## the selected card's details on the right (big card, troop, tier, unit, skills explained, 出阵 / 下阵).
## The lord always leads; up to party_slots - 1 more leaders, one per troop. Soldier cards and benched generals
## of a leader's troop fight in that leader's unit automatically.
## Tap a card to see it; tap it again (or the button on the right) to send it out / bring it back.
## 宝物 are cards too (in the pool, and the 宝物 tab): each belongs to one troop's unit (never as its leader) and
## works while worn and that unit is out. Any card (generals, soldiers, 宝物) can also be left behind.

signal closed


var _party_row: HBoxContainer
var _summary: VBoxContainer
var _tabs: HBoxContainer
var _grid: GridContainer
var _detail: VBoxContainer
var _msg: Label
var _sort_btn: Button
var _filter := "all"  # all / general / soldier / <troop id>
var _sort := "power"  # power / rarity
var _sel := "lord"  # the card shown on the right ("lord" for the lord, "relic:<id>" for a 宝物)


func _ready() -> void:
	z_index = 60
	size = Vector2(1280, 720)
	var bg := ColorRect.new()
	bg.color = Kit.c("bg")
	bg.size = size
	add_child(bg)
	var title := Kit.label("整　备", Kit.FONT_BIG + 8, "gold")
	title.position = Vector2(28, 10)
	add_child(title)
	var hint := Kit.label("点卡查看 · 再点一次出阵 / 下阵 · 每个兵种只能一人当队长，同兵种的兵卡和武将自动编进他的部队", 15)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	hint.position = Vector2(170, 22)
	add_child(hint)

	# the party: lord + leaders, with a summary box
	var party_box := _panel(Vector2(20, 58), Vector2(850, 262))
	_party_row = HBoxContainer.new()
	_party_row.position = Vector2(14, 6)
	_party_row.add_theme_constant_override("separation", 12)
	party_box.add_child(_party_row)
	_summary = VBoxContainer.new()
	_summary.position = Vector2(662, 14)
	_summary.size = Vector2(176, 236)
	_summary.add_theme_constant_override("separation", 6)
	party_box.add_child(_summary)

	# the pool
	var pool_box := _panel(Vector2(20, 330), Vector2(850, 318))
	_tabs = HBoxContainer.new()
	_tabs.position = Vector2(12, 8)
	_tabs.add_theme_constant_override("separation", 6)
	pool_box.add_child(_tabs)
	_sort_btn = Kit.button("", "blue", 15)
	_sort_btn.position = Vector2(724, 8)
	_sort_btn.custom_minimum_size = Vector2(114, 36)
	_sort_btn.size = Vector2(114, 36)
	_sort_btn.pressed.connect(func():
		_sort = "rarity" if _sort == "power" else "power"
		_rebuild())
	pool_box.add_child(_sort_btn)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(12, 62)
	scroll.size = Vector2(830, 248)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pool_box.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 7
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_grid)

	# the detail panel
	var detail_box := _panel(Vector2(880, 58), Vector2(380, 590))
	var dscroll := ScrollContainer.new()
	dscroll.position = Vector2(14, 12)
	dscroll.size = Vector2(352, 566)
	dscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_box.add_child(dscroll)
	_detail = VBoxContainer.new()
	_detail.custom_minimum_size = Vector2(340, 0)
	_detail.add_theme_constant_override("separation", 8)
	dscroll.add_child(_detail)

	# bottom bar
	_msg = Kit.label("", Kit.FONT_BODY, "amber")
	_msg.position = Vector2(28, 664)
	_msg.size = Vector2(760, 40)
	add_child(_msg)
	var auto := Kit.button("自动编成", "blue")
	auto.position = Vector2(830, 652)
	auto.custom_minimum_size = Vector2(180, 50)
	auto.size = Vector2(180, 50)
	auto.pressed.connect(func():
		Game.save.party = Game.save.auto_party()
		_msg.text = "已按战力自动编成。"
		_rebuild())
	add_child(auto)
	var done := Kit.button("完成", "green", Kit.FONT_BODY + 4)
	done.position = Vector2(1040, 652)
	done.custom_minimum_size = Vector2(220, 50)
	done.size = Vector2(220, 50)
	done.pressed.connect(func():
		Game.persist()
		closed.emit()
		queue_free())
	add_child(done)
	Kit.focus(done)
	_rebuild()


func _panel(pos: Vector2, sz: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = sz
	p.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 10, 2, Kit.c("border"), 0))
	add_child(p)
	return p


func _rebuild() -> void:
	for box in [_party_row, _summary, _tabs, _grid, _detail]:
		for ch in box.get_children():
			ch.queue_free()
	var save := Game.save
	var db := GameData.get_db()
	if _sel.begins_with("relic:"):
		if not save.relics.has(_sel.substr(6)):
			_sel = "lord"
	elif _sel != "lord" and not save.has_card(_sel):
		_sel = "lord"

	# ---- party row
	var leaders := save.party_leaders()
	_party_row.add_child(_slot("lord", leaders[0], "主公"))
	for cid in save.party:
		_party_row.add_child(_slot(cid, save.leader_for(cid), "%s队长" % db.troops[db.cards[cid]["troop"]]["name"]))
	for _i in save.party_slots - 1 - save.party.size():
		var empty := Label.new()
		empty.text = "空　位\n\n从下面\n选一张"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.custom_minimum_size = Vector2(150, 240)
		empty.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
		empty.add_theme_stylebox_override("normal", Kit.box(Color(1, 1, 1, 0.04), 10, 2, Color(1, 1, 1, 0.22), 8))
		_party_row.add_child(empty)
	var at_sum := 0
	for ld in leaders:
		at_sum += int(ld["at"])
	_summary.add_child(_stat_line("全军体力", str(Quests.party_max(save))))
	_summary.add_child(_stat_line("攻击合计", str(at_sum)))
	_summary.add_child(_stat_line("出阵", "%d / %d 队" % [leaders.size(), save.party_slots]))
	if not save.relics.is_empty():
		_summary.add_child(_stat_line("宝物", "%d / %d 生效" % [save.active_relics().size(), save.relics.size()]))
	var used := {}
	for cid in save.party:
		used[db.cards[cid]["troop"]] = true
	var idle: Array = []
	for cid in save.owned_ids():
		var tr: String = db.cards[cid]["troop"]
		if tr == "lord":  # the lord always leads his own unit (亲卫 and servants join it)
			continue
		if not used.has(tr) and not idle.has(db.troops[tr]["name"]):
			idle.append(db.troops[tr]["name"])
	if not idle.is_empty():
		var l := Kit.label("没人带的兵种：\n" + "、".join(idle), 14)
		l.add_theme_color_override("font_color", Color(1, 0.8, 0.5, 0.85))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(176, 0)
		_summary.add_child(l)

	# ---- filter tabs + sort
	var tabs: Array = [["all", "全部"], ["general", "武将"], ["soldier", "兵卡"]]
	var troops_owned: Array = []
	for cid in save.owned_ids():
		var tr: String = db.cards[cid]["troop"]
		if not troops_owned.has(tr):
			troops_owned.append(tr)
	for tr in db.troops:
		if troops_owned.has(tr):
			tabs.append([tr, db.troops[tr]["name"]])
	if not save.relics.is_empty():
		tabs.append(["relic", "宝物"])
	for tb in tabs:
		var b := Kit.button(tb[1], "gold" if _filter == tb[0] else "blue", 15)
		b.custom_minimum_size = Vector2(64, 36)
		b.pressed.connect(func():
			_filter = tb[0]
			_rebuild())
		_tabs.add_child(b)
	_sort_btn.text = "按战力 ▼" if _sort == "power" else "按稀有度 ▼"

	# ---- pool
	if _filter == "relic":
		for rid in save.relics:
			_grid.add_child(_relic_card(rid))
		_fill_detail()
		return
	var ids: Array = save.owned_ids().filter(func(cid):
		var c: Dictionary = db.cards[cid]
		match _filter:
			"all": return true
			"general": return not c["soldier"]
			"soldier": return c["soldier"]
		return c["troop"] == _filter)
	var power := {}
	for cid in ids:
		power[cid] = SaveData.leader_power(save.leader_for(cid))
	var rank := {"SSR": 4, "SR": 3, "R": 2, "N": 1}
	ids.sort_custom(func(a, b):
		if _sort == "rarity" and rank.get(db.cards[a]["rarity"], 0) != rank.get(db.cards[b]["rarity"], 0):
			return rank.get(db.cards[a]["rarity"], 0) > rank.get(db.cards[b]["rarity"], 0)
		return power[a] > power[b])
	for cid in ids:
		var c: Dictionary = db.cards[cid]
		var v := CardView.make(cid, Vector2(108, 151), {"skills": false, "count": save.copies(cid) if c["soldier"] else 0})
		v.set_state(save.benched.has(cid), _sel == cid)  # left behind: greyed
		v.pressed.connect(_tap.bind(cid))
		_grid.add_child(v)
	if _filter == "all":  # 宝物 are in the pool too
		for rid in save.relics:
			_grid.add_child(_relic_card(rid))
	if ids.is_empty() and not (_filter == "all" and not save.relics.is_empty()):
		_grid.add_child(Kit.label("这一类还没有卡。", Kit.FONT_BODY, "dim"))

	_fill_detail()


func _slot(cid: String, ld: Dictionary, role: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	var opts := {"leader": ld, "skills": false}
	if cid == "lord":
		opts["lord_name"] = Game.save.lord_name
	var v := CardView.make(cid, Vector2(150, 196), opts)
	v.set_state(false, _sel == cid)
	v.pressed.connect(_tap.bind(cid))
	box.add_child(v)
	var n: int = ld["members"].size()
	var l := Kit.label(role + ("  · 部队 %d" % (n + 1) if n > 0 else ""), 14, "gold")
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(150, 20)
	box.add_child(l)
	# the 宝物 this unit carries, as small icons (tap one to see it)
	var items := HBoxContainer.new()
	items.alignment = BoxContainer.ALIGNMENT_CENTER
	items.add_theme_constant_override("separation", 4)
	items.custom_minimum_size = Vector2(150, 26)
	for rid in Game.save.unit_relics(cid):
		var b := TextureButton.new()  # fixed 26px: a Button would grow to the icon's own size
		b.texture_normal = Kit.relic_icon(rid)
		b.ignore_texture_size = true
		b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		b.custom_minimum_size = Vector2(26, 26)
		b.tooltip_text = GameData.get_db().relics[rid]["name"]
		b.pressed.connect(_tap.bind("relic:" + rid))
		items.add_child(b)
	box.add_child(items)
	return box


func _relic_card(rid: String) -> Control:
	## a 宝物 as a card in the pool: icon, name, where it sits
	var save := Game.save
	var r: Dictionary = GameData.get_db().relics[rid]
	var col: String = {"rare": "purple", "curse": "red", "story": "gold"}.get(r["rarity"], "amber")
	var sel := _sel == "relic:" + rid
	var b := Button.new()
	b.custom_minimum_size = Vector2(108, 151)
	b.add_theme_stylebox_override("normal", Kit.box(Kit.c("card"), 10, 3 if sel else 2, Kit.c("gold") if sel else Kit.c(col), 6))
	b.add_theme_stylebox_override("hover", Kit.box(Kit.c("card_hover"), 10, 2, Kit.c(col), 6))
	b.add_theme_stylebox_override("pressed", Kit.box(Kit.c("card_hover"), 10, 2, Kit.c(col), 6))
	b.pressed.connect(_tap.bind("relic:" + rid))
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var ic := TextureRect.new()
	ic.texture = Kit.relic_icon(rid)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.custom_minimum_size = Vector2(0, 70)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(ic)
	var n := Kit.label(r["name"], 15)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(n)
	var unit := save.relic_unit(rid)
	var w := Kit.label(_team_name(rid) + ("（没装）" if save.unworn.has(rid) else ("" if unit != "" else "（未出阵）")), 12,
		"gold" if unit != "" else "dim")
	w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(w)
	return b


func _team_name(rid: String) -> String:
	var troop: String = GameData.get_db().relics[rid]["troop"]
	return "主公队" if troop == "lord" else GameData.get_db().troops[troop]["name"] + "队"


func _unit_name(unit: String) -> String:
	if unit == "lord":
		return Game.save.lord_name + " 队"
	return GameData.get_db().cards[unit]["name"].split("·")[0] + " 队"


func _fill_relic_detail(rid: String) -> void:
	var save := Game.save
	var db := GameData.get_db()
	var r: Dictionary = db.relics[rid]
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	_detail.add_child(top)
	var ic := TextureRect.new()
	ic.texture = Kit.relic_icon(rid)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.custom_minimum_size = Vector2(110, 110)
	top.add_child(ic)
	var info := VBoxContainer.new()
	top.add_child(info)
	info.add_child(Kit.label(r["name"], Kit.FONT_BIG + 2, "gold"))
	info.add_child(_info_line("种类", {"rare": "稀有", "curse": "诅咒", "story": "传家宝"}.get(r["rarity"], "普通")))
	var unit := save.relic_unit(rid)
	info.add_child(_info_line("属于", _team_name(rid)))
	var state := Kit.label("没装，放在卡池里" if save.unworn.has(rid) else (("生效中：在 %s" % _unit_name(unit)) if unit != ""
		else "%s没出阵，暂不生效" % _team_name(rid)), 15, "green" if unit != "" else "amber")
	state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state.custom_minimum_size = Vector2(190, 0)
	info.add_child(state)
	_detail.add_child(_heading("效　果"))
	var d := Kit.label(r["desc"], 15)
	d.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.custom_minimum_size = Vector2(340, 0)
	_detail.add_child(d)
	var hint := Kit.label("每件宝物属于固定的队伍，装上就编进那支队伍（不能当队长，件数不限），队伍出阵时生效；也可以不装，放在卡池里。", 14)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(340, 0)
	_detail.add_child(hint)
	var worn := not save.unworn.has(rid)
	var act := Kit.button("不　装（放回卡池）" if worn else "装　上", "red" if worn else "green")
	act.custom_minimum_size = Vector2(340, 50)
	act.pressed.connect(_toggle.bind("relic:" + rid))
	_detail.add_child(act)

func _stat_line(name: String, value: String) -> Control:
	var row := HBoxContainer.new()
	var a := Kit.label(name, 15)
	a.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	a.custom_minimum_size = Vector2(76, 0)
	row.add_child(a)
	row.add_child(Kit.label(value, Kit.FONT_BODY + 2, "gold"))
	return row


func _fill_detail() -> void:
	if _sel.begins_with("relic:"):
		_fill_relic_detail(_sel.substr(6))
		return
	var save := Game.save
	var db := GameData.get_db()
	var is_lord := _sel == "lord"
	var ld: Dictionary = save.party_leaders()[0] if is_lord else save.leader_for(_sel)
	var f: Dictionary = ld["card"]
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	_detail.add_child(top)
	var opts := {"skills": false}
	if is_lord:
		opts["lord_name"] = save.lord_name
	top.add_child(CardView.make(_sel, Vector2(130, 182), opts))
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 4)
	top.add_child(info)
	var name_l := Kit.label(f["name"], Kit.FONT_BIG + 2, "gold")
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.custom_minimum_size = Vector2(196, 0)
	info.add_child(name_l)
	info.add_child(_info_line("兵种", db.troops[f["troop"]]["name"]))
	if not is_lord:
		var c: Dictionary = db.cards[_sel]
		info.add_child(_info_line("稀有度", ("野兽" if c.get("beast", false) else Kit.rarity_label(c["rarity"])) + ("（精兵）" if c.get("elite", false) and not c.get("beast", false) else "")))
		if c["soldier"]:
			info.add_child(_info_line("张数", "×%d" % save.copies(_sel)))
		else:
			var tiers: Array = db.gacha["tiers"]
			var t := save.tier(_sel)
			var nxt := "（已满）" if t >= tiers.size() - 1 else "（%d 张升%s）" % [int(tiers[t + 1]["copies"]), tiers[t + 1]["name"]]
			info.add_child(_info_line("品阶", "%s %d 张%s" % [tiers[t]["name"], save.copies(_sel), nxt]))
	info.add_child(_info_line("单卡", "攻 %d · 兵 %d" % [f["at"], f["hp"]]))
	info.add_child(_info_line("当队长", "攻 %d · 兵 %d" % [ld["at"], ld["hp"]]))

	# the unit that fights under this card
	_detail.add_child(_heading("部　队"))
	var names := {}
	for m in ld["members"]:
		names[m["name"]] = names.get(m["name"], 0) + 1
	var parts: Array = []
	for n in names:
		parts.append(n + ("×%d" % names[n] if names[n] > 1 else ""))
	var where := ""
	if not is_lord and not save.party.has(_sel):
		var lead := save.relic_unit_for_troop(f["troop"])
		where = ("没带：不参战。\n" if save.benched.has(_sel) else
			("现在编在 %s 里。\n" % _unit_name(lead) if lead != "" else "这个兵种没人当队长，现在不参战。\n"))
	var unit := Kit.label(where + (("当队长时编入：" + "、".join(parts)) if not parts.is_empty()
		else ("主公单独成队。" if is_lord else "同兵种没有别的卡，一人成队。")), 15)
	unit.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	unit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unit.custom_minimum_size = Vector2(340, 0)
	_detail.add_child(unit)

	# skills, explained
	_detail.add_child(_heading("技　能"))
	for sid in f["skills"]:
		var sk: Dictionary = db.skills[sid]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var ic := TextureRect.new()
		ic.texture = Kit.skill_icon(sk)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.custom_minimum_size = Vector2(24, 24)
		row.add_child(ic)
		row.add_child(Kit.label("%s　AP%d" % [sk["name"], sk["cost"]], Kit.FONT_BODY, "gold"))
		_detail.add_child(row)
		var d := Kit.label(Kit.skill_desc(sk), 15)
		d.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.custom_minimum_size = Vector2(340, 0)
		_detail.add_child(d)

	# the actions: lead the troop / step down; bring along or leave behind
	var act: Button
	if is_lord:
		act = Kit.button("主公固定出阵", "blue")
		act.disabled = true
	elif save.party.has(_sel):
		act = Kit.button("下　阵（不当队长）", "red")
	else:
		act = Kit.button("出阵当队长", "green")
	act.custom_minimum_size = Vector2(340, 50)
	act.pressed.connect(_toggle.bind(_sel))
	_detail.add_child(act)
	if not is_lord and not save.party.has(_sel):
		var sel := _sel
		var left := save.benched.has(sel)
		var bring := Kit.button("带　上" if left else "不　带（留在卡池）", "blue" if left else "gray")
		bring.custom_minimum_size = Vector2(340, 44)
		bring.pressed.connect(func():
			save.set_brought(sel, left)
			_msg.text = ("%s 编回部队" if left else "%s 留在卡池，不参战") % db.cards[sel]["name"]
			_rebuild())
		_detail.add_child(bring)


func _info_line(k: String, v: String) -> Control:
	var l := Kit.label("%s　%s" % [k, v], 15)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(176, 0)
	return l


func _heading(text: String) -> Control:
	var l := Kit.label(text, Kit.FONT_BODY, "gold")
	l.add_theme_stylebox_override("normal", Kit.box(Color(0, 0, 0, 0.25), 6, 0, Color.TRANSPARENT, 4))
	return l


func _tap(cid: String) -> void:
	if _sel == cid and cid != "lord":
		_toggle(cid)
		return
	_sel = cid
	_msg.text = ""
	_rebuild()


func _toggle(cid: String) -> void:
	if cid == "lord":
		return
	if cid.begins_with("relic:"):  # 装上 / 不装
		var rid := cid.substr(6)
		var on: bool = Game.save.unworn.has(rid)
		Game.save.set_worn(rid, on)
		var r: Dictionary = GameData.get_db().relics[rid]
		_msg.text = ("%s 装进了%s" % [r["name"], _team_name(rid)]) if on else ("%s 放回卡池，不生效" % r["name"])
		_rebuild()
		return
	if Game.save.party.has(cid):
		_remove(cid)
	else:
		_add(cid)


func _add(cid: String) -> void:
	var save := Game.save
	var db := GameData.get_db()
	var card: Dictionary = db.cards[cid]
	# whoever led the same troop (or was another version of the same person) makes way
	var next: Array = save.party.filter(func(p): return db.cards[p]["troop"] != card["troop"] and db.cards[p]["person"] != card["person"])
	var replaced: Array = save.party.filter(func(p): return not next.has(p))
	if next.size() >= save.party_slots - 1:
		_msg.text = "部队满了（最多 %d 位队长）。先让一位下阵。" % (save.party_slots - 1)
		return
	next.append(cid)
	var why := save.validate_party(next)
	if why != "":
		_msg.text = why
		return
	save.party = next
	save.set_brought(cid, true)  # a leader is always brought
	_msg.text = "%s 出任%s队长%s" % [card["name"], db.troops[card["troop"]]["name"],
		"（换下 %s）" % "、".join(replaced.map(func(p): return db.cards[p]["name"])) if not replaced.is_empty() else ""]
	_rebuild()


func _remove(cid: String) -> void:
	Game.save.party.erase(cid)
	_msg.text = "%s 下阵，编进同兵种部队或留在后方。" % GameData.get_db().cards[cid]["name"]
	_rebuild()
