extends Node
## Autoload "Game": the current save, the RNG, and which screen is showing.

var save: SaveData
var rng := RandomNumberGenerator.new()
var root: Control  # the main scene; screens are its children
var persist_enabled := true
var battle_ctx: Dictionary = {}  # set while a quest battle is running


func _ready() -> void:
	rng.randomize()


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
	## 新周目: the story from the top with the collection carried over (cards ever had can all be drawn)
	save = SaveData.read().new_lap()
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
	if not q.is_empty():
		if won:
			save.run_battles += 1
			var gained := Quests.resolve(q, save, rng)
			note = "　".join(gained.map(func(c): return "获得：" + c["name"]))
		elif Quests.lose(q, save, rng):
			note = "……打不过。就在这时——"
		else:
			note = "任务失败 —— 新的一轮从头出发（卡和选择保留，宝物和险清空，格子重新洗牌）"
	persist()
	var m := MapScreen.new()
	m.toast = note
	show_screen(m)


# ---- demo states for screenshots / quick checks -----------------------------------

func demo(name: String) -> void:
	persist_enabled = false
	rng.seed = 7
	save = SaveData.create()
	save.lord_name = "阿明"
	if name.begins_with("cards:"):  # --demo=cards:id1,id2,id3 shows those cards in a pick overlay
		show_screen(TitleScreen.new())
		var o := PickOverlay.new()
		o.title = "卡牌预览"
		o.card_ids = Array(name.substr(6).split(","))
		o.set_anchors_preset(Control.PRESET_FULL_RECT)
		root.add_child(o)
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
		"ch2":  # 第二章 at 虎牢关: the 吕布 fork (win: three chests, lose: 三英战吕布)
			save.quests_cleared = ["prologue"]
			var q: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q, save, rng)
			for sid in ["road1", "youqi", "zumao", "huaxiong", "save_zumao", "counter", "borrow", "tent", "liru", "dongbai", "capture", "captive", "raid_camp"]:
				Quests.resolve(q, save, rng)
				Quests.move(q, save, sid)
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
			o.ending = GameData.get_db().quests[2]["ending"]
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
		"cg":  # standing on a story square that has a CG (醒来)
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, save)
			Quests.resolve(q, save, rng, 0)
			Quests.move(q, save, "wake")
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
		"tiers":  # 铜 / 银 / 金 frames
			save.owned = ["sunce", "zhouyu", "sunjian"]
			save.dupes = {"zhouyu": 2, "sunjian": 4}
			show_screen(TitleScreen.new())
			var o := PickOverlay.new()
			o.title = "铜 · 银 · 金"
			o.card_ids = ["sunce", "zhouyu", "sunjian"]
			o.captions = ["1 张 · 铜", "2 张 · 银", "4 张 · 金"]
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			root.add_child(o)
		"title":
			show_screen(TitleScreen.new())
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
		"battle", "fight":
			save.owned = ["sunce_zhong", "zhouyu_chibi", "wuguotai", "guanyu", "sunjian"]
			save.soldiers = {"cav_n": 2, "strat_n": 1, "log_n": 1}
			save.party = ["sunce_zhong", "zhouyu_chibi", "sunjian"]
			var b := BattleScreen.new()
			b.scenario_id = "hulao"
			show_screen(b)
			if name == "fight":  # play a few actions to exercise the animations
				await get_tree().create_timer(0.5).timeout
				await b._on_skill(1, "charge")
				await b._on_skill(0, "tuji")
				b._on_end_round()
