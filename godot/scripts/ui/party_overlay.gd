class_name PartyOverlay
extends Control
## 部队编成: pick who goes into battle. The lord always leads; up to party_slots - 1 more leaders, one per troop.
## Tap a card below to put it in the party (it replaces whoever led the same troop), tap a leader above to take it out.
## Soldier cards and benched generals of a leader's troop fight in that leader's unit automatically.

signal closed

var _top: HBoxContainer
var _grid: GridContainer
var _msg: Label


func _ready() -> void:
	z_index = 60
	size = Vector2(1280, 720)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.size = size
	add_child(dim)
	var title := Kit.label("部队编成", Kit.FONT_BIG + 6, "gold")
	title.position = Vector2(40, 18)
	add_child(title)
	var hint := Kit.label("主公固定出战 · 每个兵种只能一人当队长 · 同兵种的兵卡和武将自动编进队长的部队", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	hint.position = Vector2(230, 26)
	add_child(hint)

	_top = HBoxContainer.new()
	_top.position = Vector2(40, 70)
	_top.add_theme_constant_override("separation", 14)
	add_child(_top)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, 330)
	scroll.size = Vector2(1200, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 9
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_grid)

	_msg = Kit.label("", Kit.FONT_BODY, "amber")
	_msg.position = Vector2(40, 650)
	_msg.size = Vector2(700, 40)
	add_child(_msg)
	var auto := Kit.button("自动编成", "blue")
	auto.position = Vector2(820, 640)
	auto.custom_minimum_size = Vector2(180, 56)
	auto.pressed.connect(func():
		Game.save.party = Game.save.auto_party()
		_msg.text = "已按战力自动编成。"
		_rebuild())
	add_child(auto)
	var done := Kit.button("完成", "green", Kit.FONT_BIG)
	done.position = Vector2(1020, 640)
	done.custom_minimum_size = Vector2(220, 56)
	done.pressed.connect(func():
		Game.persist()
		closed.emit()
		queue_free())
	add_child(done)
	Kit.focus(done)
	_rebuild()


func _rebuild() -> void:
	for ch in _top.get_children():
		ch.queue_free()
	for ch in _grid.get_children():
		ch.queue_free()
	var save := Game.save
	var db := GameData.get_db()
	# the party: the lord, then each leader with its whole unit's strength
	var lord := CardView.make("lord", Vector2(150, 240), {"leader": save.party_leaders()[0], "skills": false,
		"lord_name": save.lord_name})
	lord.focus_mode = Control.FOCUS_NONE
	_top.add_child(lord)
	for cid in save.party:
		var v := CardView.make(cid, Vector2(150, 240), {"leader": save.leader_for(cid), "skills": false,
			"note": "点击下阵"})
		v.pressed.connect(_remove.bind(cid))
		_top.add_child(v)
	for _i in save.party_slots - 1 - save.party.size():
		var empty := Label.new()
		empty.text = "空位\n\n从下面\n选一张"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.custom_minimum_size = Vector2(150, 240)
		empty.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
		empty.add_theme_stylebox_override("normal", Kit.box(Color(1, 1, 1, 0.08), 12, 2, Color(1, 1, 1, 0.3), 8))
		_top.add_child(empty)
	var total := Kit.label("全军体力 %d" % Quests.party_max(save), Kit.FONT_BIG, "gold")
	total.custom_minimum_size = Vector2(260, 240)
	total.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_top.add_child(total)
	# everything owned, strongest first
	var ids := save.owned_ids()
	ids.sort_custom(func(a, b): return SaveData.leader_power(save.leader_for(a)) > SaveData.leader_power(save.leader_for(b)))
	for cid in ids:
		var c: Dictionary = db.cards[cid]
		var v := CardView.make(cid, Vector2(124, 174), {"skills": false, "count": save.copies(cid) if c["soldier"] else 0})
		v.set_state(save.party.has(cid), false)
		v.pressed.connect(_add.bind(cid))
		_grid.add_child(v)


func _add(cid: String) -> void:
	var save := Game.save
	var db := GameData.get_db()
	if save.party.has(cid):
		_remove(cid)
		return
	var card: Dictionary = db.cards[cid]
	# whoever led the same troop (or was another version of the same person) makes way
	var next: Array = save.party.filter(func(p): return db.cards[p]["troop"] != card["troop"] and db.cards[p]["person"] != card["person"])
	var replaced: Array = save.party.filter(func(p): return not next.has(p))
	if next.size() >= save.party_slots - 1:
		_msg.text = "部队满了（最多 %d 位队长）。先点上面的卡让一位下阵。" % (save.party_slots - 1)
		return
	next.append(cid)
	var why := save.validate_party(next)
	if why != "":
		_msg.text = why
		return
	save.party = next
	_msg.text = "%s 出任%s队长%s" % [card["name"], db.troops[card["troop"]]["name"],
		"（换下 %s）" % "、".join(replaced.map(func(p): return db.cards[p]["name"])) if not replaced.is_empty() else ""]
	_rebuild()


func _remove(cid: String) -> void:
	Game.save.party.erase(cid)
	_msg.text = "%s 下阵，编进同兵种部队或留在后方。" % GameData.get_db().cards[cid]["name"]
	_rebuild()
