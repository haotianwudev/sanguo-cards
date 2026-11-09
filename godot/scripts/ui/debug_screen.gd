class_name DebugScreen
extends Control
## QA / test tool, not for players: jump straight into any chapter (bypassing normal progress), browse every
## card or every story CG regardless of what the current save owns or has seen, or quit the app outright.
## Entry point: a small button on the title screen (debug exports only — see TitleScreen._ready()).

signal closed

var _view: Control



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
	for t in [["jump", "跳到某关"], ["cards", "查看所有卡牌"], ["cgs", "查看所有 CG"], ["bgm", "试听配乐"], ["quit", "退出游戏"]]:
		var b := Kit.button(t[1], "red" if t[0] == "quit" else "blue", Kit.FONT_BODY)
		b.custom_minimum_size = Vector2(0, 46)
		b.pressed.connect(_show.bind(t[0]))
		tabs.add_child(b)

	var bgm_lbl := Kit.label("♪ " + Bgm.current_display_text(), 14, "gold")
	bgm_lbl.position = Vector2(680, 74)
	bgm_lbl.size = Vector2(430, 30)
	bgm_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	bgm_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(bgm_lbl)
	var sync_top := func(_tid: String = "") -> void:
		if is_instance_valid(bgm_lbl):
			bgm_lbl.text = "♪ " + Bgm.current_display_text()
	Bgm.track_changed.connect(sync_top)
	tree_exiting.connect(func():
		if Bgm.track_changed.is_connected(sync_top):
			Bgm.track_changed.disconnect(sync_top))

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
		"bgm":
			_view = _bgm_panel()
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
	for jump in ChapterJumps.LIST:
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
	Game.persist_enabled = false  # a jump is a sandbox: the real save file is never overwritten
	var base: SaveData = Game.any_save()
	Game.save = ChapterJumps.jump_save(jump, base if base != null else Game.save, Game.rng)
	Game.show_screen(MapScreen.new())


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


const _POOLS := [["public", "公共招贤池"], ["recruit", "章节招贤馆"], ["story", "剧情给卡"], ["event", "事件给卡"], ["side", "小故事给卡"], ["foe", "打败敌将得"],
	["soldier", "兵卡"], ["lord", "主角卡"], ["none", "没有来路"]]  # where a card comes from; a card can come from several
const _RARITIES := ["SSR", "SR", "R", "C", "N"]
const _CHAPTERED := ["recruit", "story", "side", "foe", "event"]  # (for 事件给卡 the row lists the events)  # pools that belong to a chapter: a 章节 row opens under them
var _sources := {}  # card id -> {pool: [chapter titles]}, built once


func _card_sources() -> Dictionary:
	## every way a card reaches the player: 公共招贤池 (in the draw pool and tied to no chapter), a chapter's 招贤馆 list, a story square,
	## a ？小故事, beating that enemy (its drop), a soldier (chests), a lord card — or none of these
	if not _sources.is_empty():
		return _sources
	var db := GameData.get_db()
	var titles := {}
	for q in db.quests:
		titles[q["id"]] = str(q["title"])
	var add := func(cid: String, src: String, where: String) -> void:
		if cid == "" or not db.cards.has(cid):
			return
		if not _sources.has(cid):
			_sources[cid] = {}
		if not _sources[cid].has(src):
			_sources[cid][src] = []
		if where != "" and not _sources[cid][src].has(where):
			_sources[cid][src].append(where)
	for q in db.quests:
		var title := str(q["title"])
		for c in q["recruit_pool"]:
			add.call(c, "recruit", title)
		for o in q["pool_overrides"]:
			for c in o["recruit_pool"]:
				add.call(c, "recruit", title)
		for s in q["squares"].values():
			for c in s.get("recruit_pool", []):
				add.call(c, "recruit", title)
			for c in s["cards"]:
				add.call(c, "story", title)
			for o in s["choose"]:
				add.call(str(o.get("card", "")), "story", title)
			if s["type"] == "battle" and db.scenarios.has(s["battle"]):
				var foe: Dictionary = db.enemies[db.scenarios[s["battle"]]["enemy"]]
				if not foe.get("card_public", false):
					add.call(str(foe.get("drop", "")), "foe", title)
	for eid in db.events:  # ？ random events: a card outright, or one of an offer's picks (deep inside chance / battle branches too)
		var stack: Array = [db.events[eid]["options"]]
		while not stack.is_empty():
			var o: Variant = stack.pop_back()
			if o is Dictionary:
				if o.get("card") is String:
					add.call(str(o["card"]), "event", str(db.events[eid]["title"]))
				if o.get("offer") is Dictionary:
					for c in o["offer"].get("from", []):
						add.call(str(c), "event", str(db.events[eid]["title"]))
				stack.append_array(o.values())
			elif o is Array:
				stack.append_array(o)
	for qid in db.side_stories:
		for st in db.side_stories[qid]:
			for c in st.get("reward", {}).get("cards", []):
				add.call(c, "side", str(titles.get(qid, qid)))
	for cid in db.cards:
		var c: Dictionary = db.cards[cid]
		if SaveData.is_lord_card(cid):
			add.call(cid, "lord", "")
		elif c["soldier"]:
			add.call(cid, "soldier", "")
		elif c["in_pool"] and db.is_public(cid):
			add.call(cid, "public", "")
		if not _sources.has(cid):
			add.call(cid, "none", "")
	return _sources


func _cards_panel() -> Control:
	## 查看所有卡牌: filter rows — 来路 (which pool), 章节 (only under a chapter pool), 稀有度, 兵种 — each one pick (全部 by default), all
	## of them together; every chip shows how many cards it would leave given the other rows (user call)
	var db := GameData.get_db()
	var src := _card_sources()
	var pick := {"pool": "public", "chapter": "", "rarity": "", "troop": ""}
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 4)
	box.add_child(rows)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 400)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var order := {"SSR": 0, "SR": 1, "R": 2, "C": 3, "N": 4}
	var troop_order: Array = db.troops.keys()

	var passes := func(cid: String, f: Dictionary, skip: String) -> bool:
		var c: Dictionary = db.cards[cid]
		if skip != "pool" and f["pool"] != "" and not src[cid].has(f["pool"]):
			return false
		if skip != "chapter" and f["chapter"] != "" and not (src[cid].has(f["pool"]) and src[cid][f["pool"]].has(f["chapter"])):
			return false
		if skip != "rarity" and f["rarity"] != "" and str(c["rarity"]) != f["rarity"]:
			return false
		if skip != "troop" and f["troop"] != "" and str(c["troop"]) != f["troop"]:
			return false
		return true

	var hold := {}  # the refresh callable, reached through this so the chips made before it existed can still call it
	var chip_row := func(title: String, key: String, opts: Array) -> void:
		## opts: [[value, label]]; "" = 全部
		var row := HFlowContainer.new()
		row.add_theme_constant_override("h_separation", 5)
		row.add_theme_constant_override("v_separation", 4)
		var head := Kit.label(title, 15, "muted")
		head.custom_minimum_size = Vector2(52, 34)
		head.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(head)
		for o in [["", "全部"]] + opts:
			var f: Dictionary = pick.duplicate()
			f[key] = o[0]
			if key == "pool":
				f["chapter"] = ""
			var n: int = src.keys().filter(func(cid): return passes.call(cid, f, "")).size()
			if n == 0 and o[0] != "" and o[0] != pick[key]:
				continue  # nothing left behind this chip: leave it out
			var b := Kit.button("%s %d" % [o[1], n], "gold" if pick[key] == o[0] else "blue", 14)
			b.custom_minimum_size = Vector2(0, 34)
			b.pressed.connect(func():
				pick[key] = o[0]
				if key == "pool":
					pick["chapter"] = ""
				hold["refresh"].call())
			row.add_child(b)
		rows.add_child(row)

	var refresh := func() -> void:
		for ch in rows.get_children():
			ch.queue_free()
		chip_row.call("来路", "pool", _POOLS)
		if pick["pool"] in _CHAPTERED:
			var chapters: Array = []  # chapter titles in story order (for 事件给卡: the event titles)
			for q in db.quests:
				chapters.append(str(q["title"]))
			var seen: Array = []
			for cid in src:
				for w in src[cid].get(pick["pool"], []):
					if not seen.has(w):
						seen.append(w)
			seen.sort_custom(func(a, b): return chapters.find(a) < chapters.find(b) if chapters.has(a) and chapters.has(b) else str(a) < str(b))
			chip_row.call("事件" if pick["pool"] == "event" else "章节", "chapter", seen.map(func(x): return [x, x]))
		chip_row.call("稀有度", "rarity", _RARITIES.map(func(x): return [x, x]))
		var troops: Array = troop_order.map(func(x): return [x, str(db.troops[x]["name"])])
		chip_row.call("兵种", "troop", troops)
		for ch in scroll.get_children():
			ch.queue_free()
		var cids: Array = src.keys().filter(func(cid): return passes.call(cid, pick, ""))
		cids.sort_custom(func(a, b):
			var ra: int = order.get(str(db.cards[a]["rarity"]), 5)
			var rb: int = order.get(str(db.cards[b]["rarity"]), 5)
			return ra < rb if ra != rb else str(a) < str(b))
		var grid := GridContainer.new()
		grid.columns = 9
		grid.add_theme_constant_override("h_separation", 6)
		grid.add_theme_constant_override("v_separation", 6)
		for cid in cids:
			var v := CardView.make(cid, Vector2(126, 176), _card_opts(cid))
			v.pressed.connect(_preview_card.bind(cid))
			grid.add_child(v)
		scroll.add_child(grid)

	hold["refresh"] = refresh
	refresh.call()
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


static func _card_opts(cid: String) -> Dictionary:
	## the plain 主公 card is the plain lord, not whichever lord card the loaded save is using right now
	return {"skills": false, "form": ""} if cid == "lord" else {"skills": false}


func _preview_card(cid: String) -> void:
	var overlay := _overlay(0.82)
	var v := CardView.make(cid, Vector2(320, 448), _card_opts(cid))
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


func _bgm_panel() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.size = Vector2(1224, 580)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	top.custom_minimum_size = Vector2(1208, 36)
	box.add_child(top)

	var status_lbl := Kit.label("♪ 当前配乐：" + Bgm.current_display_text(), 16, "gold")
	status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top.add_child(status_lbl)

	var next_btn := Kit.button("同场合随机换一首", "gold", 14)
	next_btn.custom_minimum_size = Vector2(150, 36)
	next_btn.pressed.connect(func(): Bgm.next_in_scene())
	top.add_child(next_btn)

	var stop_btn := Kit.button("停止播放", "gray", 14)
	stop_btn.custom_minimum_size = Vector2(100, 36)
	stop_btn.pressed.connect(func(): Bgm.stop())
	top.add_child(stop_btn)

	var filter_row := HFlowContainer.new()
	filter_row.add_theme_constant_override("h_separation", 6)
	filter_row.add_theme_constant_override("v_separation", 4)
	filter_row.custom_minimum_size = Vector2(1208, 0)
	box.add_child(filter_row)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 460)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var state := {"scene": ""}
	var hold := {}
	var scene_order := ["title", "map", "battle", "boss", "ambush", "leisure", "strategy", "victory", "tragic"]

	var refresh := func() -> void:
		status_lbl.text = "♪ 当前配乐：" + Bgm.current_display_text()
		for ch in filter_row.get_children():
			ch.queue_free()
		var head := Kit.label("场合筛选", 15, "muted")
		head.custom_minimum_size = Vector2(72, 34)
		head.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		filter_row.add_child(head)

		var cur_scene: String = str(state["scene"])
		var all_btn := Kit.button("全部 %d" % Bgm.TRACKS.size(), "gold" if cur_scene == "" else "blue", 14)
		all_btn.custom_minimum_size = Vector2(0, 34)
		all_btn.pressed.connect(func():
			state["scene"] = ""
			hold["refresh"].call())
		filter_row.add_child(all_btn)

		for sc in scene_order:
			var pool: Array = Bgm.POOLS.get(sc, [])
			var sc_name: String = str(Bgm.SCENE_NAMES.get(sc, sc))
			var b := Kit.button("%s %d" % [sc_name, pool.size()], "gold" if cur_scene == sc else "blue", 14)
			b.custom_minimum_size = Vector2(0, 34)
			b.pressed.connect(func():
				state["scene"] = sc
				Bgm.play(sc, true)
				hold["refresh"].call())
			filter_row.add_child(b)

		for ch in scroll.get_children():
			ch.queue_free()
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 8)
		scroll.add_child(grid)

		var tids: Array = []
		if cur_scene != "" and Bgm.POOLS.has(cur_scene):
			tids = Bgm.POOLS[cur_scene].duplicate()
		else:
			tids = Bgm.TRACKS.keys()

		var playing_tid := Bgm.current_track_id()
		for tid_v in tids:
			var tid: String = str(tid_v)
			var info: Dictionary = Bgm.INFO.get(tid, {})
			var t_name: String = str(info.get("name", tid))
			var t_src: String = str(info.get("src", ""))
			var t_desc: String = str(info.get("desc", ""))
			var scenes_str := " / ".join(Bgm.scenes_of(tid))
			var is_playing := (tid == playing_tid)
			var label_text := "%s《%s》 (%s)  [%s]\n场合：%s  |  %s" % [
				"▶ " if is_playing else "", t_name, tid, t_src, scenes_str, t_desc
			]
			var item_btn := Kit.button(label_text, "gold" if is_playing else "gray", 13)
			item_btn.custom_minimum_size = Vector2(596, 58)
			item_btn.clip_text = true
			item_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			item_btn.pressed.connect(func():
				Bgm.play_track(tid, cur_scene))
			grid.add_child(item_btn)

	hold["refresh"] = refresh
	var on_track := func(_tid: String) -> void:
		if is_instance_valid(box):
			refresh.call()
	Bgm.track_changed.connect(on_track)
	box.tree_exiting.connect(func():
		if Bgm.track_changed.is_connected(on_track):
			Bgm.track_changed.disconnect(on_track))
	refresh.call()
	return box
