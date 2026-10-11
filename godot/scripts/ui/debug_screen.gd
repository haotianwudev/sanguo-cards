class_name DebugScreen
extends Control
## QA / test tool, not for players: jump straight into any chapter (bypassing normal progress), browse every
## card or every story CG regardless of what the current save owns or has seen, or quit the app outright.
## Entry point: a small button on the title screen (debug exports only — see TitleScreen._ready()).

signal closed

var _view: Control

const _CHAPTER_JUMPS := [
	{"label": "第一章 · 南线（富春）", "cleared": [], "flags": []},
	{"label": "第一章 · 北线（冀州风云）", "cleared": [], "flags": ["出生：冀州无极"]},
	{"label": "第二章 · 南线（讨伐董卓）", "cleared": ["prologue"], "flags": []},
	{"label": "第二章 · 北线（洛阳烟云）", "cleared": ["prologue"], "flags": ["出生：冀州无极"]},
	{"label": "第三章 · 北线（黑山风云）", "cleared": ["prologue", "luoyang_n"], "flags": ["出生：冀州无极", "北线：班师冀州"]},
	{"label": "第四章 · 北线（双凤乱太行）", "cleared": ["prologue", "luoyang_n", "heishan"],
		"flags": ["出生：冀州无极", "北线：班师冀州", "界桥：救下公孙瓒"]},
	{"label": "第五章 · 北线（铁纪徐州，军纪严明）", "cleared": ["prologue", "luoyang_n", "heishan", "beihai"],
		"flags": ["出生：冀州无极", "北线：班师冀州", "界桥：救下公孙瓒", "郑姜：和好", "北线：北海相", "军纪：严明"]},
	{"label": "第六章 · 北线（淮南折帝旗）", "cleared": ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou"],
		"flags": ["出生：冀州无极", "北线：班师冀州", "曹操：借粮", "界桥：救下公孙瓒", "郑姜：和好", "北线：北海相", "军纪：严明",
			"夏侯惇：痛击殿后", "徐州：接任徐州牧"]},
	{"label": "第六章 · 北线（结局九 · 断桥）", "cleared": ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou"],
		"flags": ["出生：冀州无极", "北线：班师冀州", "曹操：没借", "界桥：救下公孙瓒", "郑姜：和好", "北线：北海相", "军纪：严明",
			"夏侯惇：痛击殿后", "徐州：接任徐州牧"]},
	{"label": "第三章 · 传国玉玺", "cleared": ["prologue", "taodong"], "flags": []},
	{"label": "第三章 · 驻守洛阳（第三章地图内）", "cleared": ["prologue", "taodong"], "flags": ["董白：留下"],
		"records": ["路线：守洛阳"], "at": "wenji_join"},
	{"label": "第三章 · 长安（第三章地图内）", "cleared": ["prologue", "taodong"], "flags": ["董白：留下"],
		"records": ["路线：守洛阳", "路线：长安"], "at": "lijue_test"},
	{"label": "第四章 · 挟天子", "cleared": ["prologue", "taodong", "yuxi"],
		"flags": ["董白：留下", "结局一 · 玉碎", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"]},
	{"label": "第五章 · 荆襄风云", "cleared": ["prologue", "taodong", "yuxi", "dongui"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓", "南阳：袁术东逃"]},
	{"label": "第六章 · 淮南折帝旗（南线）", "cleared": ["prologue", "taodong", "yuxi", "dongui", "jingxiang"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "结局三 · 恨海", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓",
			"南阳：袁术东逃", "贾诩：入队", "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督"]},
	{"label": "第六章 · 淮南折帝旗（南线，结局十之后：刘晔线）", "cleared": ["prologue", "taodong", "yuxi", "dongui", "jingxiang"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "结局三 · 恨海", "结局十 · 深锁", "路线：守洛阳", "路线：长安",
			"长安：吕布杀了董卓", "南阳：袁术东逃", "贾诩：入队", "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督"]},
	{"label": "第七章 · 江东小霸王（南线）", "cleared": ["prologue", "taodong", "yuxi", "dongui", "jingxiang", "huainan_s"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "结局三 · 恨海", "结局十 · 深锁", "路线：守洛阳", "路线：长安",
			"长安：吕布杀了董卓", "南阳：袁术东逃", "贾诩：入队", "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督", "庐江：刘晔调停", "庐江：双婚"]},
	{"label": "第七章 · 江东小霸王（南线，结局十一之后：收服锦帆）", "cleared": ["prologue", "taodong", "yuxi", "dongui", "jingxiang", "huainan_s"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "结局三 · 恨海", "结局十 · 深锁", "结局十一 · 匹夫", "路线：守洛阳", "路线：长安",
			"长安：吕布杀了董卓", "南阳：袁术东逃", "贾诩：入队", "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督", "庐江：刘晔调停", "庐江：双婚"]},
]


func _ready() -> void:
	z_index = 90
	size = Vector2(1280, 720)
	var bg := ColorRect.new()
	bg.color = Kit.c("bg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var title_text := "测试工具（不给玩家看）"
	if Game.save != null:
		var lvl := Game.save.effective_level()
		if Game.save.difficulty > 0:
			title_text += " | 当前难度：%d（局内 +%d）" % [lvl, Game.save.difficulty]
		else:
			title_text += " | 当前难度：%d" % lvl
	var title := Kit.label(title_text, Kit.FONT_BIG + 2, "gold")
	title.position = Vector2(28, 14)
	add_child(title)
	var done := Kit.button("关闭", "gray", Kit.FONT_BODY)
	done.position = Vector2(1130, 10)
	done.custom_minimum_size = Vector2(130, 48)
	done.pressed.connect(func():
		closed.emit()
		queue_free())
	add_child(done)

	var tabs := HBoxContainer.new()
	tabs.position = Vector2(28, 64)
	tabs.add_theme_constant_override("separation", 10)
	add_child(tabs)
	for t in [["jump", "跳到某关"], ["cards", "查看所有卡牌"], ["cgs", "查看所有 CG"], ["quit", "退出游戏"]]:
		var b := Kit.button(t[1], "red" if t[0] == "quit" else "blue", Kit.FONT_BODY)
		b.custom_minimum_size = Vector2(0, 46)
		b.pressed.connect(_show.bind(t[0]))
		tabs.add_child(b)

	_show("jump")


func _show(which: String) -> void:
	if which == "quit":
		get_tree().quit()
		return
	if _view != null:
		_view.queue_free()
		_view = null
	match which:
		"jump":
			_view = _jump_panel()
		"cards":
			_view = _cards_panel()
		"cgs":
			_view = _cgs_panel()
	_view.position = Vector2(28, 122)
	add_child(_view)


func _jump_panel() -> Control:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 580)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	col.custom_minimum_size = Vector2(1200, 0)
	scroll.add_child(col)
	for jump in _CHAPTER_JUMPS:
		var b := Kit.button(jump["label"], "gold", Kit.FONT_BODY)
		b.custom_minimum_size = Vector2(0, 52)
		b.pressed.connect(_do_jump.bind(jump))
		col.add_child(b)
	var hint := Kit.label("直接跳章节：按最常见的那条线路设置 quests_cleared / flags，不保证覆盖每一条岔路（比如董白的另一种结局）。"
		+ "想测具体某一格，跳到章节后用地图上的格子走过去，或者命令行 --demo=cg_north/ln2 --at=<格子id> 更精确。", 14, "muted")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(1180, 0)
	col.add_child(hint)
	return scroll


func _do_jump(jump: Dictionary) -> void:
	Game.persist_enabled = false
	var save := SaveData.create()
	save.quests_cleared = jump["cleared"].duplicate()
	save.flags = jump["flags"].duplicate()
	Game.save = save
	Quests.ensure_started(save, Game.rng)
	if jump.has("at"):  # a stop inside a chapter: the records so far, standing on that square
		save.run_records = jump["records"].duplicate()
		save.square = jump["at"]
		save.resolved = true
		if not save.visited.has(jump["at"]):
			save.visited.append(jump["at"])
	Game.show_screen(MapScreen.new())


const _CARD_TABS := [["SSR", "SSR"], ["SR", "SR"], ["R", "R"], ["N", "兵卡"], ["story", "剧情 / 敌方卡"]]
const _CG_GROUPS := {"c1": "第一章（南线）", "jz": "第一章（北线）", "e": "随机事件", "i": "幕间", "end": "结局"}  # prefix groups for what no quest square owns


## a gallery: a row of category tabs over a scroll area; only the picked category is built (and its art loaded)
func _gallery(tabs: Array, build: Callable) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	box.add_child(row)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 530)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var buttons: Array = []
	var pick := func(i: int) -> void:
		for ch in scroll.get_children():
			ch.queue_free()
		for j in buttons.size():
			buttons[j].add_theme_color_override("font_color", Kit.c("gold") if j == i else Kit.c("text"))
		scroll.add_child(build.call(tabs[i][0]))
	for i in tabs.size():
		var b := Kit.button(tabs[i][1], "blue", 15)
		b.custom_minimum_size = Vector2(0, 38)
		b.pressed.connect(pick.bind(i))
		row.add_child(b)
		buttons.append(b)
	if not tabs.is_empty():
		pick.call(0)
	return box


func _card_ids(tab: String) -> Array:
	var db := GameData.get_db()
	var out: Array = []
	for cid in db.cards:
		var c: Dictionary = db.cards[cid]
		if cid == "lord":
			continue
		var story: bool = not c["in_pool"]
		if (tab == "story" and story) or (not story and tab == c["rarity"]):
			out.append(cid)
	out.sort()
	return out


func _cards_panel() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 6)
	box.add_child(row1)
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 6)
	box.add_child(row2)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 484)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var db := GameData.get_db()
	var all_troops: Array = db.troops.keys()

	var buttons1: Array = []
	var buttons2: Array = []

	var build_grid = func(cids: Array) -> void:
		for ch in scroll.get_children():
			ch.queue_free()
		var grid := GridContainer.new()
		grid.columns = 9
		grid.add_theme_constant_override("h_separation", 6)
		grid.add_theme_constant_override("v_separation", 6)
		for cid in cids:
			var v := CardView.make(cid, Vector2(126, 176), {"skills": false})
			v.pressed.connect(_preview_card.bind(cid))
			grid.add_child(v)
		scroll.add_child(grid)

	var pick2 = func(i: int, cids: Array, sub_tabs: Array) -> void:
		for j in buttons2.size():
			buttons2[j].add_theme_color_override("font_color", Kit.c("gold") if j == i else Kit.c("text"))
		var troop: String = sub_tabs[i][0]
		var filter_cids := cids if troop == "all" else cids.filter(func(cid): return db.cards[cid]["troop"] == troop)
		build_grid.call(filter_cids)

	var pick1 = func(i: int) -> void:
		for j in buttons1.size():
			buttons1[j].add_theme_color_override("font_color", Kit.c("gold") if j == i else Kit.c("text"))
		
		var tab_id: String = _CARD_TABS[i][0]
		var cids := _card_ids(tab_id)
		
		for ch in row2.get_children():
			ch.queue_free()
		buttons2.clear()
		
		var troops_in_tab := {}
		for cid in cids:
			var troop: String = db.cards[cid]["troop"]
			if not troops_in_tab.has(troop):
				troops_in_tab[troop] = []
			troops_in_tab[troop].append(cid)
		var sorted_troops := troops_in_tab.keys()
		sorted_troops.sort_custom(func(a, b): return all_troops.find(a) < all_troops.find(b))
		
		var sub_tabs := [["all", "全部（%d）" % cids.size()]]
		for troop in sorted_troops:
			var count: int = troops_in_tab[troop].size()
			var tname: String = db.troops[troop]["name"] if db.troops.has(troop) else troop
			sub_tabs.append([troop, "%s（%d）" % [tname, count]])
			
		for j in sub_tabs.size():
			var b := Kit.button(sub_tabs[j][1], "blue", 15)
			b.custom_minimum_size = Vector2(0, 38)
			b.pressed.connect(pick2.bind(j, cids, sub_tabs))
			row2.add_child(b)
			buttons2.append(b)
			
		if not sub_tabs.is_empty():
			pick2.call(0, cids, sub_tabs)

	for i in _CARD_TABS.size():
		var tab_id: String = _CARD_TABS[i][0]
		var count: int = _card_ids(tab_id).size()
		var b := Kit.button("%s（%d）" % [_CARD_TABS[i][1], count], "blue", 15)
		b.custom_minimum_size = Vector2(0, 38)
		b.pressed.connect(pick1.bind(i))
		row1.add_child(b)
		buttons1.append(b)

	if not _CARD_TABS.is_empty():
		pick1.call(0)

	return box


func _cg_keys() -> Dictionary:
	## group key (the part before the first "_", i1/i2… folded into "i") -> sorted CG keys actually shipped.
	## ResourceLoader.list_directory, not DirAccess: an exported APK packs only the imported copies, so a raw
	## directory listing shows `xxx.jpg.import` and never `xxx.jpg` — the gallery came up empty on phones.
	var groups := {}
	var owners := _cg_owners()
	for f in ResourceLoader.list_directory("res://data/art/cg"):
		if not f.ends_with(".jpg"):
			continue
		var key: String = f.trim_suffix(".jpg")
		var g := key.get_slice("_", 0)
		if g.begins_with("i") and g.length() <= 2:
			g = "i"
		if owners.has(key) and owners[key] != "prologue":  # a chapter's own squares say where it belongs (south / north split by the data)
			g = "q:" + owners[key]
		if not groups.has(g):
			groups[g] = []
		groups[g].append(key)
	for g in groups:
		groups[g].sort()
	return groups


func _cg_owners() -> Dictionary:
	## CG key -> the id of the first chapter whose squares show it (story.json is the source of truth, not the file name)
	var out := {}
	for q in GameData.get_db().quests:
		for s in q["squares"].values():
			if s["cg"] != "" and not out.has(s["cg"]):
				out[s["cg"]] = q["id"]
	return out


func _parse_cg_group(g: String) -> Array:
	if g == "c1": return ["第一章", "南线"]
	if g == "jz": return ["第一章", "北线"]
	if g.begins_with("q:"):
		for q in GameData.get_db().quests:
			if q["id"] == g.substr(2):
				var title: String = q["title"]
				var ch: String = title.split(" · ")[0] if " · " in title else title
				var rt: String = "北线" if q.get("event_scope", "") == "north" else "南线"
				return [ch, rt]
	return ["其它", _CG_GROUPS.get(g, g)]


func _cgs_panel() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 6)
	box.add_child(row1)
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 6)
	box.add_child(row2)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 484)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var groups := _cg_keys()
	var cgs_by_chap := {}
	var chap_order := []

	var ordered_g := []
	for g in ["c1", "jz"]:
		if groups.has(g): ordered_g.append(g)
	for q in GameData.get_db().quests:
		if groups.has("q:" + q["id"]): ordered_g.append("q:" + q["id"])
	for g in _CG_GROUPS.keys():
		if groups.has(g) and not ordered_g.has(g): ordered_g.append(g)
	for g in groups:
		if not ordered_g.has(g): ordered_g.append(g)

	for g in ordered_g:
		var parsed: Array = _parse_cg_group(g)
		var ch: String = parsed[0]
		var rt: String = parsed[1]
		if not cgs_by_chap.has(ch):
			cgs_by_chap[ch] = {}
			chap_order.append(ch)
		if not cgs_by_chap[ch].has(rt):
			cgs_by_chap[ch][rt] = []
		cgs_by_chap[ch][rt].append_array(groups[g])

	var buttons1: Array = []
	var buttons2: Array = []

	var build_grid = func(keys: Array) -> void:
		for child in scroll.get_children():
			child.queue_free()
		var grid := GridContainer.new()
		grid.columns = 5
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		for key in keys:
			var col := VBoxContainer.new()
			col.add_theme_constant_override("separation", 2)
			var btn := TextureButton.new()
			btn.texture_normal = Kit.cg(key)
			btn.ignore_texture_size = true
			btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
			btn.custom_minimum_size = Vector2(228, 128)
			btn.pressed.connect(_preview_cg.bind(key))
			col.add_child(btn)
			var lbl := Kit.label(key, 13, "muted")
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.custom_minimum_size = Vector2(228, 0)
			col.add_child(lbl)
			grid.add_child(col)
		scroll.add_child(grid)

	var pick2 = func(rt: String, routes_dict: Dictionary, rt_list: Array) -> void:
		for j in buttons2.size():
			buttons2[j].add_theme_color_override("font_color", Kit.c("gold") if rt_list[j] == rt else Kit.c("text"))
		build_grid.call(routes_dict[rt])

	var pick1 = func(ch: String) -> void:
		for j in buttons1.size():
			buttons1[j].add_theme_color_override("font_color", Kit.c("gold") if chap_order[j] == ch else Kit.c("text"))
		
		for child in row2.get_children():
			child.queue_free()
		buttons2.clear()
		
		var routes_dict: Dictionary = cgs_by_chap[ch]
		var rt_list: Array = routes_dict.keys()
		
		for rt in rt_list:
			var count: int = routes_dict[rt].size()
			var b := Kit.button("%s（%d）" % [rt, count], "blue", 15)
			b.custom_minimum_size = Vector2(0, 38)
			b.pressed.connect(pick2.bind(rt, routes_dict, rt_list))
			row2.add_child(b)
			buttons2.append(b)
			
		if not rt_list.is_empty():
			pick2.call(rt_list[0], routes_dict, rt_list)

	for ch in chap_order:
		var count := 0
		for rt in cgs_by_chap[ch]:
			count += cgs_by_chap[ch][rt].size()
		var b := Kit.button("%s（%d）" % [ch, count], "blue", 15)
		b.custom_minimum_size = Vector2(0, 38)
		b.pressed.connect(pick1.bind(ch))
		row1.add_child(b)
		buttons1.append(b)

	if not chap_order.is_empty():
		pick1.call(chap_order[0])

	return box


## full-screen view over everything; tap anywhere to close (a fresh touch-down only — a card opens this on
## touch-down, so the lift from that same tap lands here and must not close it straight away)
func _overlay(alpha: float) -> Control:
	var overlay := Control.new()
	overlay.z_index = 80
	overlay.size = Vector2(1280, 720)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var opened := Time.get_ticks_msec()
	var dim := Button.new()
	dim.size = Vector2(1280, 720)
	dim.focus_mode = Control.FOCUS_NONE
	for st in ["normal", "hover", "pressed", "focus"]:
		dim.add_theme_stylebox_override(st, Kit.box(Color(0, 0, 0, alpha), 0, 0, Color.TRANSPARENT, 0))
	dim.button_down.connect(func():
		if Time.get_ticks_msec() - opened > 350:
			overlay.queue_free())
	overlay.add_child(dim)
	add_child(overlay)
	return overlay


func _preview_card(cid: String) -> void:
	var overlay := _overlay(0.82)
	var v := CardView.make(cid, Vector2(320, 448), {"skills": false})
	v.position = Vector2(300, 120)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(v)
	var panel := Kit.skill_panel(v.fighter["skills"], 340)
	panel.position = Vector2(660, 130)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(panel)
	var c: Dictionary = GameData.get_db().cards[cid]
	var troops: Dictionary = GameData.get_db().troops
	var troop: String = troops[c["troop"]]["name"] if troops.has(c["troop"]) else c["troop"]
	var tiers: Array = GameData.get_db().gacha["tiers"]
	var lv := Game.save.tier(cid) if Game.save != null and not c["soldier"] else 0
	var lbl := Kit.label("%s　·　%s　·　%s　·　%s　·　Lv.%d %s" % [c["name"], cid, c["rarity"], troop, lv + 1, tiers[lv]["name"]], Kit.FONT_BODY, "gold")
	lbl.position = Vector2(20, 14)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(lbl)


func _preview_cg(key: String) -> void:
	var overlay := _overlay(0.92)
	var pic := TextureRect.new()
	pic.texture = Kit.cg(key)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.size = Vector2(1280, 720)
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(pic)
	var lbl := Kit.label(key, Kit.FONT_BODY, "gold")
	lbl.position = Vector2(20, 14)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(lbl)
