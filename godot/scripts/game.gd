extends Node
## Autoload "Game": the current save, the RNG, and which screen is showing.

var save: SaveData
var rng := RandomNumberGenerator.new()
var root: Control  # the main scene; screens are its children
var persist_enabled := true
var save_path := ""  # the file the current save lives in: a route slot, or "" for a journey still choosing its birthplace
var battle_ctx: Dictionary = {}  # set while a quest battle is running
var options := {"fullscreen": false, "fast": false, "inherit_all": false, "sfx_volume": 0.8, "bgm_volume": 0.7, "dlg_size": "auto", "auto_speed": "fast", "power_saver": false,
	"tactics": {}}  # player options, kept in user://options.cfg (not in the save); tactics = 军令 (三层), shared by every save and lap — read it through AutoPlayer.with_defaults
const OPTIONS_PATH := "user://options.cfg"


func _ready() -> void:
	rng.randomize()
	if DisplayServer.get_name() == "headless":  # the test runner never touches the player's save files
		persist_enabled = false
	if persist_enabled:
		SaveData.migrate_legacy()
	var cfg := ConfigFile.new()
	if persist_enabled and cfg.load(OPTIONS_PATH) == OK:
		for k in options:
			options[k] = cfg.get_value("options", k, options[k])
	if not OS.has_feature("mobile") and options["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func set_option(key: String, value: Variant) -> void:
	options[key] = value
	if key == "fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)
	elif key == "power_saver":
		var pw := get_node_or_null("/root/Power")
		if pw:
			pw.apply(bool(value))
	elif key == "bgm_volume":
		var bgm = get_node_or_null("/root/Bgm")
		if bgm:
			bgm.update_volume()
	if persist_enabled:
		var cfg := ConfigFile.new()
		for k in options:
			cfg.set_value("options", k, options[k])
		cfg.save(OPTIONS_PATH)


func battle_speed() -> float:
	return 1.6 if options["fast"] else 1.0


func go_home() -> void:
	persist()
	battle_ctx = {}
	Engine.time_scale = 1.0
	show_screen(TitleScreen.new())


func persist() -> void:
	if persist_enabled and save != null:
		save.write(save_path if save_path != "" else SaveData.PENDING_PATH)
		save.write_shared()


func assign_slot() -> void:
	## the birthplace is chosen: this journey now lives in its route's slot (the pending file goes)
	if save_path != "":
		return
	save_path = SaveData.slot_path(save.route())
	if persist_enabled and FileAccess.file_exists(SaveData.PENDING_PATH):
		DirAccess.remove_absolute(SaveData.PENDING_PATH)


func load_slot(route_id: String) -> SaveData:
	save_path = SaveData.slot_path(route_id)
	return SaveData.read_slot(route_id)


func any_save() -> SaveData:
	## whichever route's save exists (the south one first): for what both share, the books
	for r in ["south", "north"]:
		var s := SaveData.read_slot(r)
		if s != null:
			return s
	return null


func show_screen(screen: Control) -> void:
	var swap := root.get_child_count() > 0  # from one screen to another (not the first one at start-up)
	for ch in root.get_children():
		ch.queue_free()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(screen)
	if swap:
		_curtain(screen is BattleScreen)


var _veil: ColorRect  # the screen-change curtain (on a CanvasLayer above everything)


func _curtain(to_battle: bool) -> void:
	## a screen change dips through black (0.18 s) instead of a hard cut; into a battle the dip is a cold steel blue.
	## Skipped headless (tests).
	if DisplayServer.get_name() == "headless":
		return
	if _veil == null:
		var layer := CanvasLayer.new()
		layer.layer = 100
		add_child(layer)
		_veil = ColorRect.new()
		_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
		_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(_veil)
	if _veil.has_meta("tw"):
		(_veil.get_meta("tw") as Tween).kill()
	_veil.color = Color(0.06, 0.09, 0.13, 1.0) if to_battle else Color(0, 0, 0, 1.0)
	var tw := _veil.create_tween()
	tw.tween_property(_veil, "color:a", 0.0, 0.28 if to_battle else 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_veil.set_meta("tw", tw)


func new_game(lord_name: String) -> void:
	save_path = ""
	save = SaveData.create()
	var shared := SaveData.create()  # the endings and the collection already earned come along into the new journey
	shared.apply_shared()
	for f in SaveData.SHARED_LISTS + SaveData.SHARED_MAXES:
		save.set(f, shared.get(f))
	save.cleared_lord_copies = shared.cleared_lord_copies
	save.flags = shared.flags.duplicate()
	save.lord_name = lord_name if lord_name.strip_edges() != "" else "主公"
	Quests.ensure_started(save, rng)
	persist()
	show_screen(MapScreen.new())


func new_lap(route_id: String) -> void:
	## 新周目: the story from the top; the collection starts over (cards ever had can drop again), unless the 设置 test option keeps it
	save = load_slot(route_id).new_lap(bool(options["inherit_all"]))
	show_screen(PrepScreen.new())  # 前尘整备 first (nothing is saved until 出发: backing out leaves the old save as it was)


func start_lap() -> void:
	## 前尘整备 → 出发 (PrepScreen has applied the perks and cards and opened its chests): the story starts
	Quests.ensure_started(save, rng)
	persist()
	show_screen(MapScreen.new())


func continue_pending() -> void:
	save_path = ""
	save = SaveData.read(SaveData.PENDING_PATH)
	show_screen(MapScreen.new())


func continue_game(route_id: String) -> void:
	save = load_slot(route_id)
	show_screen(MapScreen.new())


func replay_chapter(route_id: String, quest_id: String) -> void:
	## Replay a finished chapter for cards and 战功; each clear makes it harder (进阶).
	save = load_slot(route_id)
	for q in GameData.get_db().quests:
		if q["id"] == quest_id:
			Quests.start_replay(q, save, rng)
	persist()
	show_screen(MapScreen.new())


func back_to_story(route_id: String) -> void:
	save = load_slot(route_id)
	Quests.stop_replay(save)
	persist()
	show_screen(MapScreen.new())


func restart_chapter() -> void:
	## 设置 → 重打这一章 (on the map or mid-battle)
	battle_ctx = {}
	Engine.time_scale = 1.0
	Quests.restart(save, rng)
	persist()
	var m := MapScreen.new()
	m.toast = "这一章从头再来 —— 一切回到刚进本章时的样子"
	show_screen(m)


func step_back() -> void:
	## 设置 → 重返上一格 (on the map or mid-battle)
	battle_ctx = {}
	Engine.time_scale = 1.0
	Quests.step_back(save, rng)
	persist()
	var m := MapScreen.new()
	m.toast = "回到了上一格 —— 走这一步之后得到的、选过的都已退回"
	show_screen(m)


func start_quest_battle(q: Dictionary, sq: Dictionary) -> void:
	battle_ctx = {"quest": q, "square": sq}
	var b := BattleScreen.new()
	var fight := Quests.battle_here(q, save)
	b.scenario_id = fight["battle"]
	b.carry = true
	b.boss = fight["boss"]
	b.ambush = fight["ambush"]
	show_screen(b)


func battle_finished(won: bool) -> void:
	var q: Dictionary = battle_ctx.get("quest", {})
	battle_ctx = {}
	var note := ""
	var failed := false
	if not q.is_empty():
		if won:
			save.run_battles += 1
			var gained := Quests.resolve(q, save, rng)
			note = "　".join(gained.filter(func(c): return not c.get("relic", false)).map(func(c): return "获得：" + c["name"]))
		elif Quests.lose(q, save, rng):
			note = "……打不过。就在这时——"
		else:
			if save.resolved:
				failed = false
				note = "战斗失败 —— 已退回上一步（可更换部队重试，若仍打不过可在设置中重新开始）"
			else:
				failed = true
				note = "任务失败 —— 新的一轮从头出发（卡和选择保留，宝物和险清空，格子重新洗牌）"
	persist()
	if failed:
		await show_defeat()
	var m := MapScreen.new()
	m.toast = note
	show_screen(m)


func show_defeat() -> void:
	## 阵亡: the lord falls — a still picture per route (defeat_south / defeat_north); nothing is shown until that art exists
	var key := "defeat_north" if save.is_north() else "defeat_south"
	if Kit.cg(key) == null:
		return
	var o := DefeatOverlay.new()
	o.cg_key = key
	o.line = "%s倒在了战场上……这一轮到此为止" % save.lord_name
	root.add_child(o)
	await o.done


# ---- demo states for screenshots / quick checks -----------------------------------
