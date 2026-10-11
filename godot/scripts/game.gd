extends Node
## Autoload "Game": the current save, the RNG, and which screen is showing.

var save: SaveData
var rng := RandomNumberGenerator.new()
var root: Control  # the main scene; screens are its children
var persist_enabled := true
var battle_ctx: Dictionary = {}  # set while a quest battle is running
var options := {"fullscreen": false, "fast": false, "inherit_all": false, "sfx_volume": 0.8, "bgm_volume": 0.7}  # player options, kept in user://options.cfg (not in the save)
const OPTIONS_PATH := "user://options.cfg"


func _ready() -> void:
	rng.randomize()
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
		save.write()


func show_screen(screen: Control) -> void:
	for ch in root.get_children():
		ch.queue_free()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(screen)


func new_game(lord_name: String) -> void:
	save = SaveData.create()
	save.lord_name = lord_name if lord_name.strip_edges() != "" else "主公"
	Quests.ensure_started(save, rng)
	persist()
	show_screen(MapScreen.new())


func new_lap() -> void:
	## 新周目: the story from the top; the collection starts over (cards ever had can drop again), unless the 设置 test option keeps it
	save = SaveData.read().new_lap(bool(options["inherit_all"]))
	Quests.ensure_started(save, rng)
	persist()
	show_screen(MapScreen.new())


func continue_game() -> void:
	save = SaveData.read()
	show_screen(MapScreen.new())


func replay_chapter(quest_id: String) -> void:
	## Replay a finished chapter for cards and 战功; each clear makes it harder (进阶).
	save = SaveData.read()
	for q in GameData.get_db().quests:
		if q["id"] == quest_id:
			Quests.start_replay(q, save, rng)
	persist()
	show_screen(MapScreen.new())


func back_to_story() -> void:
	save = SaveData.read()
	Quests.stop_replay(save)
	persist()
	show_screen(MapScreen.new())


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

func demo(name: String) -> void:
	persist_enabled = false
	rng.seed = 7
	save = SaveData.create()
	save.lord_name = "阿明"
	if OS.get_cmdline_user_args().has("--north"):  # any --demo, played as the north-route lord
		save.run_records.append("出生：冀州无极")
	BattleScreen.auto_on = OS.get_cmdline_user_args().has("--auto")  # any --demo, with 自动战斗 already on
	if OS.get_cmdline_user_args().has("--forms"):  # any --demo, with every lord card handed out
		save.lord_forms = GameData.get_db().lord_forms.keys()
	if name == "lordcards":  # 整备 on the 主公 tab with three lord cards handed out
		var few := OS.get_cmdline_user_args().has("--few")  # --few: only the lord, with the default card and one more
		for c in ([] if few else ["sunce", "zhouyu", "wuguotai"]):
			save.grant_card(c)
		save.lord_forms = ["lord_default", "lord_south_armor"] if few else ["lord_south_armor", "lord_south_boat", "lord_south_plate"]
		var lm := MapScreen.new()
		show_screen(lm)
		lm.call_deferred("_open_party")
		(func():
			await get_tree().process_frame
			var lo: PartyOverlay = lm.get_node("Party")
			lo._filter = "lord"
			lo._sel = "lordform:lord_south_boat"
			lo._rebuild()).call_deferred()
		return
	if name == "newgame":  # the 从零开始 confirmation (a save exists), then the name
		show_screen(TitleScreen.new())
		var d := NewGameDialog.new()
		d.wipes_save = true
		root.add_child(d)
		return
	if name == "level":  # the 难度 pick after the birthplace, with two south endings reached
		save.flags = ["结局一 · 玉碎", "结局二 · 同归"]
		show_screen(TitleScreen.new())
		var lo := LevelOverlay.new()
		lo.route = "south"
		lo.top = save.route_max_level()
		lo.reached = save.endings_reached()
		root.add_child(lo)
		return
	if name == "endings":  # the 结局图鉴 with two endings reached
		save.flags = ["结局一 · 玉碎", "结局六 · 覆巢"]
		show_screen(TitleScreen.new())
		var book := EndingsBook.new()
		book._flags = save.flags
		root.add_child(book)
		return
	if name == "firststep":  # chapter one, birth chosen: --demo=firststep steps onto the first square (its story, then the lord card moment; --skip skips the story)
		var q1: Dictionary = GameData.get_db().quests[0]
		Quests.begin(q1, save, rng)
		save.run_records.append("出生：江东富春")
		save.choices["era"] = "wake"
		save.resolved = true
		var fm := MapScreen.new()
		show_screen(fm)
		fm.call_deferred("_on_square", "wake")
		if OS.get_cmdline_user_args().has("--skip"):
			(func():
				await get_tree().create_timer(1.5).timeout
				fm._dialog_skip()).call_deferred()
		return
	if name == "cardsbook":  # the 卡牌收藏 after an ending, on the 主角卡 tab: --demo=cardsbook [--north]
		save.grant_card("sunce")
		save.lord_forms = ["lord_south_armor", "lord_north_silver"]
		save.lord_copies = 2
		save.commit_history()
		show_screen(TitleScreen.new())
		var cb := CardsBook.new()
		cb.save = save
		cb._cur_type = "lord"
		root.add_child(cb)
		if OS.get_cmdline_user_args().has("--inspect"):
			cb.call_deferred("_inspect_card", "lord", "lord_north_silver")
		return
	if name.begins_with("cards:"):  # --demo=cards:id1,id2,id3 shows those cards in a pick overlay
		show_screen(TitleScreen.new())
		var o := PickOverlay.new()
		o.title = "卡牌预览"
		o.card_ids = Array(name.substr(6).split(","))
		o.set_anchors_preset(Control.PRESET_FULL_RECT)
		root.add_child(o)
		return
	if name.begins_with("battle:"):  # --demo=battle:<scenario_id>
		save.owned = ["sunce_zhong", "sunce_bawang", "zhouyu_chibi", "wuguotai", "guanyu", "sunjian"]
		save.soldiers = {"cav_n": 2, "strat_n": 1, "log_n": 1}
		save.party = ["sunce_zhong", "zhouyu_chibi", "sunjian"]
		var b := BattleScreen.new()
		b.scenario_id = name.substr(7)
		b.ambush = OS.get_cmdline_user_args().has("--ambush")  # --ambush: the enemy strikes first
		show_screen(b)
		if OS.get_cmdline_user_args().has("--stun-end"):  # confuse the enemy, then press 回合结束
			await get_tree().create_timer(0.5).timeout
			b.b.enemy["stunned"] = true
			if OS.get_cmdline_user_args().has("--regen"):  # 词缀·再生 on a hurt enemy
				b.b.enemy["regen"] = 0.04
				b.b.enemy["hp"] -= 1000
			b._end.pressed.emit()
		return
	match name:
		"event":  # a ？ square: 左慈 on the hill
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 0)
			for sid in ["wake", "bandage", "village", "zy_hill", "hill"]:
				Quests.move(q, save, sid)
				if sid != "hill":
					Quests.resolve(q, save, rng)
			save.events = {"hill": "zuoci"}
			show_screen(MapScreen.new())
		"ch2":  # 第二章 at 虎牢关: the 吕布 fork (win: three chests, lose: 三英战吕布; --at=<id> jumps ahead)
			save.quests_cleared = ["prologue"]
			var q: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q, save, rng)
			Quests.pick_fate(save, 0)
			var at: String = "raid_camp"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					at = a.substr(5)
			var path := ["road1", "youqi", "zumao", "huaxiong", "save_zumao", "counter", "bubing2", "borrow", "spoils", "feixiong", "dongbai", "capture", "dongbai_rest", "captive", "scout2", "scout2_b", "raid_camp", "bingzhou2", "lvbu", "triple", "box1", "box2", "box3", "fate", "give"]
			for sid in path:
				Quests.resolve(q, save, rng, 0 if Quests.here(q, save)["type"] == "choose" else -1)
				Quests.move(q, save, sid)
				if sid == at:
					break
			show_screen(MapScreen.new())
		"quest":  # --demo=quest --id=<quest id>: that chapter's map at its first square (north route, earlier chapters cleared)
			var want := "luoyang_n"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--id="):
					want = a.substr(5)
			var order: Array = GameData.get_db().quests.map(func(x): return x["id"])
			save.flags = ["出生：冀州无极", "北线：班师冀州", "界桥：救下公孙瓒"]
			save.quests_cleared = order.slice(0, order.find(want))
			var q: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == want)[0]
			var need: Variant = q.get("requires", [])  # the chapter's own gate (a south chapter needs its south flag)
			for line in (need if need is Array else ([] if str(need) == "" else [str(need)])):
				if not save.flags.has(line):
					save.flags.append(line)
			Quests.begin(q, save, rng)
			Quests.pick_fate(save, 0)
			for a in OS.get_cmdline_user_args():  # --at=<square id>: start there instead (only its own text plays)
				if a.begins_with("--at="):
					save.square = a.substr(5)
					save.visited.append(save.square)
			show_screen(MapScreen.new())
		"lordreveal":  # the lord-card moment a cleared chapter gives: --demo=lordreveal [--dupe]
			save.flags = ["出生：冀州无极"]
			var rv := LordReveal.new()
			var forms: Array = save.route_lord_forms()
			rv.form = "lord_north_silver" if save.is_north() else "lord_south_armor"
			save.lord_forms.append(rv.form)
			rv.dupe = OS.get_cmdline_user_args().has("--dupe")
			show_screen(MapScreen.new())
			add_child(rv)
		"relicreveal":  # the 宝物 card moment: --demo=relicreveal [--many]
			save.flags = ["出生：冀州无极"]
			show_screen(MapScreen.new())
			var rr := RelicReveal.new()
			rr.relic_ids = ["wentai_shu", "zhou_pu", "weixi"] if OS.get_cmdline_user_args().has("--many") else ["xuzhou_yin"]
			rr.title = "获得宝物"
			add_child(rr)
		"ln2":  # 北线第二章 at 虎牢关: the 吕布 fork (lower x = earlier square via --at=<id>)
			save.flags = ["出生：冀州无极"]
			save.quests_cleared = ["prologue", "taodong"]
			var q: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == "luoyang_n")[0]
			Quests.begin(q, save, rng)
			Quests.pick_fate(save, 0)
			var at: String = "ln_lvbu"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					at = a.substr(5)
			var path := ["ln_river", "ln_charge", "ln_lvlingqi", "ln_camp", "ln_rest1", "ln_loot1", "ln_mystery1", "ln_road_loot",
				"ln_banner", "ln_feast", "ln_caocao", "ln_lend", "ln_zhen", "ln_pursuit", "ln_ambush", "ln_ambush2", "ln_xurong", "ln_rescue",
				"ln_rest2", "ln_loot2", "ln_mystery2", "ln_approach", "ln_feixiong", "ln_langqi", "ln_rest3", "ln_lvbu",
				"ln_triple", "ln_box1", "ln_box2", "ln_box3", "ln_handhold", "ln_blaze", "ln_ferry", "ln_end"]
			for sid in path:
				Quests.resolve(q, save, rng, 0 if Quests.here(q, save)["type"] == "choose" else -1)
				Quests.move(q, save, sid)
				if sid == at:
					break
			show_screen(MapScreen.new())
		"relics":  # an elite's 宝物 pick, a couple already held
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 0)
			for sid in ["wake", "bandage", "village", "sc_home", "boar", "raid"]:
				Quests.move(q, save, sid)
				Quests.resolve(q, save, rng)
			save.relics = ["hupi", "yuxi"]
			save.danger = 1
			save.offer = ["shoushihe", "bingfa", "dunjia"]
			save.offer_kind = "relic"
			show_screen(MapScreen.new())
		"recap":  # the chapter recap at the end of chapter 2
			save.quests_cleared = ["prologue"]
			var q: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q, save)
			save.grant_card("sunce")
			Quests.record(save, "华雄：亲手斩杀，救下祖茂")
			Quests.record(save, "吕布：三英战吕布")
			Quests.record(save, "董白：留下")
			save.grant_card("dongbai")
			save.grant_card("gongnv")
			save.grant_card("gongnv")
			save.run_relics = ["chize", "hupi"]
			save.relics = ["chize", "hupi"]
			save.run_battles = 7
			save.run_bosses = 3
			save.merit = 4
			save.square = "heroes"
			save.resolved = true
			var m := MapScreen.new()
			show_screen(m)
			m.call_deferred("_complete")
		"party", "party_pick":  # the 整备 screen with a mid-game collection
			for c in ["sunce", "zhouyu", "wuguotai", "sunjian", "huanggai", "chengpu", "dongbai"]:
				save.grant_card(c)
			for c in ["danyang", "danyang", "changsha", "gongnv", "xiliang_nvbing"]:
				save.grant_card(c)
			save.kept_relics = ["shoushihe", "jiunang", "bingfu", "bingfa", "gudingdao", "dunjia"]  # a run starts with these
			save.relics = save.kept_relics.duplicate()
			var m := MapScreen.new()
			show_screen(m)
			m.call_deferred("_open_party")
			if name == "party_pick":  # a general selected: the detail panel with unit and skills
				(func():
					await get_tree().process_frame
					var o: PartyOverlay = m.get_node("Party")
					o._sel = "sunce"
					o._filter = "cavalry"
					if OS.get_cmdline_user_args().has("--relics"):  # the 宝物 tab, 古锭刀 selected
						o._sel = "relic:gudingdao"
						o._filter = "relic"
					o._rebuild()).call_deferred()
		"interlude":  # after chapter 2, with 董白 spared
			save.quests_cleared = ["prologue", "taodong"]
			save.flags = ["董白：留下", "唐姬：护送"]
			show_screen(TitleScreen.new())
			var o := InterludeOverlay.new()
			o.scenes = Quests.interlude("taodong", save)
			root.add_child(o)
		"reveal":  # the 入队 overlay: 孙策 and 周瑜 join
			var m := MapScreen.new()
			show_screen(m)
			save.grant_card("sunce")
			save.grant_card("zhouyu")
			var db := GameData.get_db()
			m.call_deferred("_reveal", [db.cards["sunce"], db.cards["zhouyu"]], "入　队")
		"chest", "grand_chest":  # a chest opening over the map (use --wait to catch a moment of it)
			Quests.ensure_started(save, rng)
			save.fate = "jiangxing"
			save.fate_offer = []
			var m := MapScreen.new()
			show_screen(m)
			var o := PickOverlay.new()
			o.title = "宝箱 —— 选一张兵卡"
			o.card_ids = ["danyang", "jiangdong_gong", "xiliang_nvbing"] if name == "chest" else ["huangzhong", "danyang", "sunshangxiang"]
			o.chest = "normal" if name == "chest" else "grand"
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			m.add_child(o)
		"fate", "affix":  # a run's start: pick a 天命 / an elite square with its 词缀
			save.grant_card("sunce")
			save.grant_card("zhouyu")
			save.quests_cleared = ["prologue"]
			var q2: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q2, save, rng)
			if name == "affix":
				save.fate = save.fate_offer[0]
				save.fate_offer = []
				save.square = "dongbai"
				save.visited.append("dongbai")
				save.resolved = false
			show_screen(MapScreen.new())
		"ch4", "ch5":  # route B: 驻守洛阳 / 长安
			save.quests_cleared = ["prologue", "taodong"]
			save.flags = ["董白：留下"]
			save.grant_card("dongbai")
			Quests.ensure_started(save)
			save.run_records = ["路线：守洛阳"] + (["路线：长安"] if name == "ch5" else [])  # still inside 第三章, past the fork
			save.square = "lijue_test" if name == "ch5" else "wenji_join"
			save.resolved = true
			save.visited.append(save.square)
			show_screen(MapScreen.new())
		"ch6", "ch6b", "ch6c":  # 第四章 · 挟天子: 二周目 (nobody warns you) / 三周目 (貂蝉 comes) / 四周目 (张济 张绣, 贾诩 joins); --at=<square> jumps ahead
			save.quests_cleared = ["prologue", "taodong", "yuxi"]
			save.flags = ["董白：留下", "结局一 · 玉碎", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"]
			if name != "ch6":
				save.flags.append("结局二 · 同归")
			if name == "ch6c":
				save.flags.append("结局三 · 恨海")
			for c in ["dongbai", "caiwenji", "huangfusong", "zhujun"]:
				save.grant_card(c)
			Quests.ensure_started(save)
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					save.square = a.trim_prefix("--at=")
					save.visited.append(save.square)
					save.resolved = false
			show_screen(MapScreen.new())
		"ch8", "ch8b":  # 第五章 · 荆襄风云: first time (the banquet, 结局三) / after 结局三 with 贾诩 (he breaks it); --at=<square> jumps ahead
			save.quests_cleared = ["prologue", "taodong", "yuxi", "dongui"]
			save.flags = ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓", "南阳：袁术东逃"]
			if name == "ch8b":
				save.flags.append_array(["结局三 · 恨海", "贾诩：入队"])
				save.grant_card("jiaxu")
			for c in ["dongbai", "caiwenji", "diaochan", "xunyou", "huangzhong", "huangfusong"]:
				save.grant_card(c)
			Quests.ensure_started(save)
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					save.square = a.trim_prefix("--at=")
					save.visited.append(save.square)
					save.resolved = false
			show_screen(MapScreen.new())
		"ch2_wait":  # chapter 2 after 董白's fate (kept): the months before 洛阳 burns
			save.quests_cleared = ["prologue"]
			var q2: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q2, save)
			Quests.record(save, "董白：留下")
			save.square = "wait"
			save.visited.append("wait")
			show_screen(MapScreen.new())
		"ch3", "ch3_lost":  # chapter 3 after chapter 2 (董白 kept, or handed over)
			save.quests_cleared = ["prologue", "taodong"]
			save.flags = ["董白：留下"] if name == "ch3" else ["董白：交给袁绍"]
			if name == "ch3":
				save.grant_card("dongbai")
			Quests.ensure_started(save)
			show_screen(MapScreen.new())
		"ending":  # the 结局一 card
			show_screen(TitleScreen.new())
			var o := InterludeOverlay.new()
			o.ending = GameData.get_db().quests.filter(func(q): return q["id"] == "yuxi")[0]["ending"]
			o.scenes = []
			root.add_child(o)
		"titlecard":  # the chapter-2 title card straight away
			var o := InterludeOverlay.new()
			o.next_title = GameData.get_db().quests[1]["title"]
			o.next_subtitle = GameData.get_db().quests[1]["subtitle"]
			show_screen(TitleScreen.new())
			root.add_child(o)
		"replays":  # the title screen's 重玩章节 list
			save.quests_cleared = ["prologue", "taodong"]
			save.clears = {"prologue": 3, "taodong": 1}
			var ts := TitleScreen.new()
			show_screen(ts)
			ts.call_deferred("_replay_menu", ts._col, save)
		"cg":  # standing on a southern prologue square (醒来 by default; --at=<square id> for any other)
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 0)
			var at: String = "wake"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					at = a.substr(5)
			if at == "wake":
				Quests.move(q, save, "wake")
			else:
				var path := ["wake", "bandage", "village", "sc_home", "boar", "raid", "plan", "sc_gate", "sc_road", "sc_hall", "rescue", "dinner", "muster", "draft", "reeds", "yaodao", "isle", "lair", "vault", "armor", "oath", "north"]
				for sid in path:
					Quests.move(q, save, sid)
					if sid == at:
						break
					Quests.resolve(q, save, rng, 0 if Quests.here(q, save)["type"] == "choose" else -1)
			show_screen(MapScreen.new())
		"cg_north":  # standing on a northern prologue square (甄府醒来 by default; --at=<square id> for any other)
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 1)
			Quests.move(q, save, "jz_arrive")
			var at: String = "jz_arrive"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					at = a.substr(5)
			if at != "jz_arrive":
				# jz_route fork (官道/小路): the quiet-path branch by default; --at= on jz_road_fight walks the road
				var road: bool = at == "jz_road_fight"
				var route_branch: Array = ["jz_road_fight", "jz_mystery1"] if road else ["jz_curious", "jz_loot_path"]
				# 定计 fork: the 赵云 branch by default; --at= on a 郭嘉-only square walks the 郭嘉 branch
				var guo: bool = at in ["jz_fire", "jz_gj_back", "jz_rescue", "jz_reunite_g"]
				var branch: Array = ["jz_fire", "jz_gj_back", "jz_rescue"] if guo else ["jz_zy_gate", "jz_zy_road", "jz_zy_altar"]
				var path: Array = ["jz_ledger", "jz_county", "jz_help", "jz_guojia", "jz_integrity", "jz_relief", "jz_route"] \
					+ route_branch + ["jz_zuoci", "jz_ambush", "jz_breakout", "jz_plan"] \
					+ branch + ["jz_recover", "jz_boss", "jz_loot", "jz_reunite_g" if guo else "jz_reunite", "jz_almsgiving", "jz_training", "jz_night", "jz_end"]
				for sid in path:
					var pick: int = 0
					if Quests.here(q, save)["type"] == "choose":
						if save.square == "jz_plan":
							pick = 1 if guo else 0
						elif save.square == "jz_route":
							pick = 0 if road else 1
					else:
						pick = -1
					Quests.resolve(q, save, rng, pick)
					Quests.move(q, save, sid)
					if sid == at:
						break
			show_screen(MapScreen.new())
		"fork":  # after 富春: follow 周瑜 or 孙策
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 0)
			for sid in ["wake", "bandage", "village"]:
				Quests.move(q, save, sid)
				Quests.resolve(q, save, rng)
			show_screen(MapScreen.new())
		"era":  # the very first choice, clicked to its last line
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			var m := MapScreen.new()
			show_screen(m)
			for _i in 12:
				m.call_deferred("_on_story_click", m._fake_click())
		"cg_click":  # the same, clicked through to the last line (buttons shown)
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 0)
			Quests.move(q, save, "wake")
			var m := MapScreen.new()
			show_screen(m)
			for _i in 12:
				m.call_deferred("_on_story_click", m._fake_click())
			if OS.get_cmdline_user_args().has("--press-continue"):  # then press 继续: it should walk on to 换药
				m.get_tree().create_timer(0.5).timeout.connect(func(): m._resolve())
		"tiers":  # 铜 / 银 / 金 / 神 frames
			save.owned = ["sunce", "zhouyu", "sunjian", "guanyu"]
			save.dupes = {"zhouyu": 4, "sunjian": 16, "guanyu": 64}
			show_screen(TitleScreen.new())
			var o := PickOverlay.new()
			o.title = "铜 · 银 · 金 · 神"
			o.card_ids = ["sunce", "zhouyu", "sunjian", "guanyu"]
			o.captions = ["1 张 · 铜", "4 张 · 银", "16 张 · 金", "64 张 · 神"]
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			root.add_child(o)
		"title":
			show_screen(TitleScreen.new())
		"debug":  # --at=jump/cards/cgs picks the opening tab
			show_screen(TitleScreen.new())
			var dbg := DebugScreen.new()
			root.add_child(dbg)
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					dbg._show(a.trim_prefix("--at="))
				if a.begins_with("--card="):  # open that card's preview straight away
					dbg._preview_card(a.trim_prefix("--card="))
		"map", "pick":
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 0)
			for sid in ["wake", "bandage", "village", "sc_home", "boar", "raid", "plan"]:
				Quests.move(q, save, sid)
				Quests.resolve(q, save, rng)
			for sid in ["zy_lure", "zy_back", "zy_hall", "rescue", "dinner", "muster"]:
				Quests.move(q, save, sid)
				Quests.resolve(q, save, rng, 1)
			save.damage = 900
			if name == "pick":
				Quests.move(q, save, "draft")
			show_screen(MapScreen.new())
		"choose":
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 0)
			for sid in ["wake", "bandage", "village", "sc_home", "boar", "raid"]:
				Quests.move(q, save, sid)
				Quests.resolve(q, save, rng)
			Quests.move(q, save, "plan")
			show_screen(MapScreen.new())
		"fx":  # --demo=fx --fx=<hit|magic|pierce|boosthit|claw|counter|burn|pburn|break|stun|confuse|boost|buff|cleanse|drain>: one effect mid-flight
			save.owned = ["sunce_zhong", "sunce_bawang", "zhouyu_chibi", "wuguotai", "guanyu", "sunjian"]
			save.soldiers = {"cav_n": 2, "strat_n": 1, "log_n": 1}
			save.party = ["sunce_zhong", "zhouyu_chibi", "sunjian"]
			var fb := BattleScreen.new()
			fb.scenario_id = "hulao"
			show_screen(fb)
			await get_tree().create_timer(0.25).timeout
			var want := "hit"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--fx="):
					want = a.substr(5)
			var eng: Battle = fb.b
			BattleFx.scale = fb._enemy_fx_scale() if want in ["hit", "magic", "pierce", "boosthit", "counter", "burn", "break"] else 1.0
			match want:
				"hit":
					BattleFx.hit(fb, fb._enemy_center(), "attack", 3, 0.12)
				"magic":
					BattleFx.hit(fb, fb._enemy_center(), "magic", 1, 0.05)
				"pierce":
					BattleFx.hit(fb, fb._enemy_center(), "attack", 1, 0.05, true)
				"boosthit":
					BattleFx.hit(fb, fb._enemy_center(), "attack", 2, 0.15, false, true)
				"claw":
					BattleFx.claw(fb, fb._cards_rect().get_center(), 0.12, 0.5)
				"counter":
					BattleFx.counter(fb, fb._enemy_center())
				"burn":
					eng.enemy["burn_turns"] = 3
					eng.enemy["burn_pct"] = 0.1
					fb._refresh()
					BattleFx.flame_lick(fb, fb._enemy_rect())
				"pburn":
					eng.party_burn = {"dmg": 300, "turns": 2}
					fb._refresh()
				"break":
					eng.enemy["break_turns"] = 3
					eng.enemy["break_amount"] = 0.25
					fb._refresh()
				"stun":
					eng.enemy["stunned"] = true
					fb._refresh()
				"confuse":
					eng.leaders[1]["confused"] = true
					fb._refresh()
				"boost":
					eng.leaders[1]["boosted"] = true
					eng.leaders[2]["boosted"] = true
					fb._refresh()
					BattleFx.boost_cast(fb, fb._card_rect(1))
				"buff":
					eng.buff = {"layers": 3, "turns": 3, "atk": 0.3, "def": 0.24}
					fb._refresh()
					BattleFx.buff_cast(fb, range(fb._cards.size()).map(func(i): return fb._card_rect(i).get_center()))
				"cleanse":
					BattleFx.cleanse_wave(fb, fb._cards_rect())
				"drain":
					eng.ap_drain = 2
					fb._refresh()
					BattleFx.drain_shatter(fb, fb._ap_row.get_children().filter(func(n): return n is Panel).slice(1, 3), 2)
		"swap":  # 换人: the picker open (add --done to play the swap itself)
			save.owned = ["machao", "madai", "mayunlu", "zhangfei", "daqiao"]
			save.party = ["machao", "zhangfei", "daqiao"]
			var sb := BattleScreen.new()
			sb.scenario_id = "hulao"
			show_screen(sb)
			await get_tree().create_timer(0.5).timeout
			await sb._on_skill(1, "xiliang")
			if OS.get_cmdline_user_args().has("--done"):
				sb.b.round_no = 3
				sb.b.ap = 4
				await sb._on_swap(1, "madai")
			else:
				sb.b.round_no = 3
				sb.b.ap = 4
				sb._open_swap(1)
		"defeatflow":  # a real quest battle lost for good: the 阵亡 picture, a click, and we must land back on the map
			save.owned = ["sunce_bawang", "zhouyu_chibi", "sunjian"]
			save.party = ["sunce_bawang", "zhouyu_chibi", "sunjian"]
			Quests.ensure_started(save, rng)
			var dq: Dictionary = {}
			for qq in GameData.get_db().quests:
				if qq["id"] == "prologue":
					dq = qq
			for sid in ["jz_arrive"] if false else dq["squares"]:
				if dq["squares"][sid]["type"] == "battle" and dq["squares"][sid].get("lose_goto", "") == "" and not dq["squares"][sid].get("requires", ""):
					save.square = sid
					break
			save.resolved = false
			var bs: Dictionary = dq["squares"][save.square]
			start_quest_battle(dq, bs)
			var bsc: BattleScreen = root.get_child(root.get_child_count() - 1)
			await get_tree().create_timer(0.6).timeout
			bsc.b.result = "lose"
			bsc.b.lose_reason = "wiped"
			bsc._finish()
			await get_tree().create_timer(4.0).timeout
			var top: Node = root.get_child(root.get_child_count() - 1)
			print("DEFEATFLOW before click: ", top.get_class(), " children=", root.get_child_count())
			print("DEFEATFLOW overlay: ready_to_close=", top.get("_ready_to_close"), " filter=", top.mouse_filter, " size=", top.size, " z=", top.z_index, " script=", top.get_script().resource_path if top.get_script() else "none")
			print("DEFEATFLOW hovered at centre: ", get_viewport().gui_get_hovered_control())
			var ev := InputEventMouseButton.new()
			ev.button_index = MOUSE_BUTTON_LEFT
			ev.position = Vector2(640, 360)
			ev.global_position = ev.position
			ev.pressed = true
			Input.parse_input_event(ev)
			await get_tree().create_timer(1.5).timeout
			top = root.get_child(root.get_child_count() - 1)
			print("DEFEATFLOW after click: ", top.get_class(), " children=", root.get_child_count(), " names=", root.get_children().map(func(c): return c.get_class()))
		"battle", "fight":
			save.owned = ["sunce_zhong", "sunce_bawang", "zhouyu_chibi", "wuguotai", "guanyu", "sunjian"]
			save.soldiers = {"cav_n": 2, "strat_n": 1, "log_n": 1}
			save.party = ["sunce_zhong", "zhouyu_chibi", "sunjian"]
			var b := BattleScreen.new()
			b.scenario_id = "hulao"
			for a in OS.get_cmdline_user_args():  # --scenario=<id>: any battle, e.g. one with a battle CG
				if a.begins_with("--scenario="):
					b.scenario_id = a.trim_prefix("--scenario=")
			show_screen(b)
			if OS.get_cmdline_user_args().has("--boost"):  # a strengthened (BOOST) card must stand out
				await get_tree().create_timer(0.5).timeout
				b.b.leaders[1]["boosted"] = true
				b._refresh()
			if OS.get_cmdline_user_args().has("--endwin"):  # win with a boosted card and statuses up: nothing may stay over the 胜利 banner
				await get_tree().create_timer(0.5).timeout
				b.b.leaders[1]["boosted"] = true
				b.b.enemy["burn_turns"] = 3
				b.b.enemy["burn_pct"] = 0.1
				b.b.buff["layers"] = 2
				b._refresh()
				await get_tree().create_timer(0.8).timeout
				b.b.enemy["hp"] = 0
				b.b.result = "win"
				b._refresh()
				b._finish()
			if OS.get_cmdline_user_args().has("--longstatus"):  # every status line at once: the enemy panel must not grow
				await get_tree().create_timer(0.5).timeout
				var en: Dictionary = b.b.enemy
				en["break_turns"] = 3
				en["break_amount"] = 0.3
				en["burn_turns"] = 3
				en["burn_pct"] = 0.1
				en["charging"] = "天下无双"
				en["at"] = en["data"]["at"] * 1.6
				b.b.buff["layers"] = 3
				b.b.buff["atk"] = 0.3
				b.b.buff["def"] = 0.2
				b.b.buff["turns"] = 2
				b.b.party_burn["turns"] = 2
				b.b.party_burn["dmg"] = 120
				b.b.ap_drain = 2
				b._refresh()
			if OS.get_cmdline_user_args().has("--manyap"):  # more AP than usual + a combo: the party bar must still show them all
				await get_tree().create_timer(0.5).timeout
				b.b.mods["ap_max"] = 6
				b.b.ap = b.b.ap_max()
				b.b.combo = 5
				b.b.round_no = b.b.turn_limit
				b.b.ap_drain = 2
				b._refresh()
			if OS.get_cmdline_user_args().has("--lastround"):  # the round-limit warning: play the final round's alert
				await get_tree().create_timer(0.5).timeout
				b.b.round_no = b.b.turn_limit - 1
				await b._on_end_round()
				print("LASTROUND-DEMO result=", b.b.result, " reason=", b.b.lose_reason, " busy=", b._busy)
				await b._on_end_round()  # and play the final round out: the round limit is up, the battle is lost on turns
				print("LASTROUND-DEMO final: result=", b.b.result, " reason=", b.b.lose_reason, " busy=", b._busy)
				await get_tree().create_timer(6.0).timeout
				print("LASTROUND-DEMO after 6s: screen=", root.get_child(root.get_child_count() - 1).get_class(), " busy=", b._busy if is_instance_valid(b) else "freed")
			if OS.get_cmdline_user_args().has("--auto"):  # play the whole battle through the real UI (any skill, any round) — for hunting hangs
				await get_tree().create_timer(0.4).timeout
				for _round in 40:
					if b.b.result != "":
						break
					for i in b.b.leaders.size():
						if b.b.result != "" or not b.b.can_act(i):
							continue
						var u: Dictionary = b.b.leaders[i]
						var best := ""
						for sk in b.b.skills_of(u):
							if b.b.usable(u, sk):
								best = sk["id"]  # the last usable one: the strongest
						if best != "":
							await b._on_skill(i, best)
					if b.b.result == "":
						await b._on_end_round()
				await get_tree().create_timer(5.0).timeout
				print("AUTO-DEMO result=", b.b.result, " busy=", b._busy, " screen=", root.get_child(root.get_child_count() - 1).get_class())
			if name == "fight":  # play a few actions to exercise the animations
				await get_tree().create_timer(0.5).timeout
				await b._on_skill(1, "bawang")
				await b._on_skill(0, "tuji")
				b._on_end_round()
