class_name Demos
extends RefCounted
## The --demo=<name> screens (main.gd → Demos.run): a state set up straight away for a screenshot or a manual check —
## a chapter, a fight, an overlay. Development only: nothing in the game calls this; it lived inside game.gd (the Game
## autoload, 1000+ lines) until 2026-11. Each case reaches the game through the Game autoload.


static func run(name: String) -> void:
	Game.persist_enabled = false
	Game.rng.seed = 7
	Game.save = SaveData.create()
	Game.save.lord_name = "阿明"
	if OS.get_cmdline_user_args().has("--north"):  # any --demo, played as the north-route lord
		Game.save.run_records.append("出生：冀州无极")
	BattleScreen.auto_on = OS.get_cmdline_user_args().has("--auto")  # any --demo, with 自动战斗 already on
	Game.options["dlg_size"] = "auto"
	for a in OS.get_cmdline_user_args():  # any --demo: --dlg=auto|mid|small, the CG text box size (the 框 button)
		if a.begins_with("--dlg="):
			Game.options["dlg_size"] = a.trim_prefix("--dlg=")
		if a.begins_with("--perk="):  # any --demo: --perk=reroll,foresight buys those 前尘整备 perks
			for pid in a.trim_prefix("--perk=").split(","):
				Game.save.perks[pid] = 1
	if OS.get_cmdline_user_args().has("--forms"):  # any --demo, with every lord card handed out
		Game.save.lord_forms = GameData.get_db().lord_forms.keys()
	if name == "lordcards":  # 整备 on the 主公 tab with three lord cards handed out
		var few := OS.get_cmdline_user_args().has("--few")  # --few: only the lord, with the default card and one more
		for c in ([] if few else ["sunce", "zhouyu", "wuguotai"]):
			Game.save.grant_card(c)
		Game.save.lord_forms = ["lord_default", "lord_south_armor"] if few else ["lord_south_armor", "lord_south_boat", "lord_south_plate"]
		var lm := MapScreen.new()
		Game.show_screen(lm)
		lm.call_deferred("_open_party")
		(func():
			await Game.get_tree().process_frame
			var lo: PartyOverlay = lm.get_node("Party")
			lo._filter = "lord"
			lo._sel = "lordform:lord_south_boat"
			lo._rebuild()).call_deferred()
		return
	if name == "newgame":  # the 从零开始 confirmation (a save exists), then the name
		Game.show_screen(TitleScreen.new())
		var d := NewGameDialog.new()
		d.wipes_save = true
		Game.root.add_child(d)
		return
	if name == "level":  # the 难度 pick after the birthplace, with two south endings reached
		Game.save.flags = ["结局一 · 玉碎", "结局三 · 同归"]
		Game.show_screen(TitleScreen.new())
		var lo := LevelOverlay.new()
		lo.route = "south"
		lo.top = Game.save.route_max_level()
		lo.reached = Game.save.endings_reached()
		Game.root.add_child(lo)
		return
	if name == "endings":  # the 结局图鉴 with two endings reached
		Game.save.flags = ["结局一 · 玉碎", "结局二 · 覆巢"]
		Game.show_screen(TitleScreen.new())
		var book := EndingsBook.new()
		book._flags = Game.save.flags
		Game.root.add_child(book)
		return
	if name == "firststep":  # chapter one, birth chosen: --demo=firststep steps onto the first square (its story, then the lord card moment; --skip skips the story)
		var q1: Dictionary = GameData.get_db().quests[0]
		Quests.begin(q1, Game.save, Game.rng)
		Game.save.run_records.append("出生：江东富春")
		Game.save.choices["era"] = "wake"
		Game.save.resolved = true
		var fm := MapScreen.new()
		Game.show_screen(fm)
		fm.call_deferred("_on_square", "wake")
		if OS.get_cmdline_user_args().has("--skip"):
			(func():
				await Game.get_tree().create_timer(1.5).timeout
				fm._dialog_skip()).call_deferred()
		return
	if name == "cardsbook":  # the 卡牌收藏 after an ending, on the 主角卡 tab: --demo=cardsbook [--north]
		Game.save.grant_card("sunce")
		Game.save.lord_forms = ["lord_south_armor", "lord_north_silver"]
		Game.save.lord_copies = 2
		Game.save.commit_history()
		Game.show_screen(TitleScreen.new())
		var cb := CardsBook.new()
		cb.save = Game.save
		cb._cur_type = "lord"
		Game.root.add_child(cb)
		if OS.get_cmdline_user_args().has("--inspect"):
			cb.call_deferred("_inspect_card", "lord", "lord_north_silver")
		return
	if name == "glows":  # --demo=glows: one card per frame (木 / 铜 / 银 / 金 / 神) to check the auras
		Game.show_screen(TitleScreen.new())
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 60)
		row.position = Vector2(80, 200)
		Game.root.add_child(row)
		for spec in [["cav_n", 0], ["guanyu", 0], ["zhaoyun", 1], ["sunce_bawang", 2], ["lvbu", 3]]:
			row.add_child(CardView.make(spec[0], Vector2(150, 196), {"skills": false, "tier": spec[1]}))
		return
	if name.begins_with("cards:"):  # --demo=cards:id1,id2,id3 shows those cards in a pick overlay
		Game.show_screen(TitleScreen.new())
		var o := PickOverlay.new()
		o.title = "卡牌预览"
		o.card_ids = Array(name.substr(6).split(","))
		o.set_anchors_preset(Control.PRESET_FULL_RECT)
		Game.root.add_child(o)
		return
	if name.begins_with("battle:"):  # --demo=battle:<scenario_id>
		Game.save.owned = ["sunce_zhong", "sunce_bawang", "zhouyu_chibi", "wuguotai", "guanyu", "sunjian"]
		Game.save.soldiers = {"cav_n": 2, "strat_n": 1, "log_n": 1}
		Game.save.party = ["sunce_zhong", "zhouyu_chibi", "sunjian"]
		var b := BattleScreen.new()
		b.scenario_id = name.substr(7)
		b.ambush = OS.get_cmdline_user_args().has("--ambush")  # --ambush: the enemy strikes first
		if OS.get_cmdline_user_args().has("--solo"):  # --solo: the lord alone
			Game.save.party = []
		Game.show_screen(b)
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--hp="):  # --hp=<n>: start on n HP and press 回合结束 (the enemy's first blow can end it)
				await Game.get_tree().create_timer(0.5).timeout
				b.b.party_hp = int(a.substr(5))
				b._refresh()
				b._end.pressed.emit()
		if OS.get_cmdline_user_args().has("--stun-end"):  # confuse the enemy, then press 回合结束
			await Game.get_tree().create_timer(0.5).timeout
			b.b.enemy["stunned"] = true
			if OS.get_cmdline_user_args().has("--regen"):  # 词缀·再生 on a hurt enemy
				b.b.enemy["regen"] = 0.04
				b.b.enemy["hp"] -= 1000
			b._end.pressed.emit()
		return
	match name:
		"event":  # a ？ square: 左慈 on the hill
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Quests.resolve(q, Game.save, Game.rng, 0)
			for sid in ["wake", "bandage", "village", "zy_hill", "hill"]:
				Quests.move(q, Game.save, sid)
				if sid != "hill":
					Quests.resolve(q, Game.save, Game.rng)
			Game.save.events = {"hill": "zuoci"}
			Game.show_screen(MapScreen.new())
		"ch2":  # 第二章 at 虎牢关: the 吕布 fork (win: three chests, lose: 三英战吕布; --at=<id> jumps ahead)
			Game.save.quests_cleared = ["prologue"]
			var q: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q, Game.save, Game.rng)
			Quests.pick_fate(Game.save, 0)
			var at: String = "raid_camp"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					at = a.substr(5)
			var path := ["road1", "youqi", "zumao", "huaxiong", "save_zumao", "counter", "bubing2", "borrow", "spoils", "feixiong", "dongbai", "capture", "dongbai_rest", "captive", "scout2", "scout2_b", "raid_camp", "bingzhou2", "lvbu", "triple", "box1", "box2", "box3", "fate", "give"]
			for sid in path:
				Quests.resolve(q, Game.save, Game.rng, 0 if Quests.here(q, Game.save)["type"] == "choose" else -1)
				Quests.move(q, Game.save, sid)
				if sid == at:
					break
			Game.show_screen(MapScreen.new())
		"quest":  # --demo=quest --id=<quest id>: that chapter's map at its first square (north route, earlier chapters cleared)
			var want := "luoyang_n"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--id="):
					want = a.substr(5)
			var order: Array = GameData.get_db().quests.map(func(x): return x["id"])
			# --south: a south-route chapter (no north birth, or current_quest() walks back onto the north route)
			Game.save.flags = [] if OS.get_cmdline_user_args().has("--south") else ["出生：冀州无极", "北线：班师冀州", "界桥：救下公孙瓒"]
			Game.save.quests_cleared = order.slice(0, order.find(want))
			var q: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == want)[0]
			var need: Variant = q.get("requires", [])  # the chapter's own gate (a south chapter needs its south flag)
			for line in (need if need is Array else ([] if str(need) == "" else [str(need)])):
				if not Game.save.flags.has(line):
					Game.save.flags.append(line)
			Quests.begin(q, Game.save, Game.rng)
			Quests.pick_fate(Game.save, 0)
			for a in OS.get_cmdline_user_args():  # --at=<square id>: start there instead (only its own text plays)
				if a.begins_with("--at="):
					Game.save.square = a.substr(5)
					Game.save.visited.append(Game.save.square)
				if a.begins_with("--flag="):  # --flag=<line>: a story flag this run should already have (a route choice)
					Game.save.run_records.append(a.substr(7))
					if "结局" in a.substr(7):  # an ending is a lasting flag (it gates routes from save.flags)
						Game.save.flags.append(a.substr(7))
				if a.begins_with("--dmg="):  # --dmg=<n>: wear carried in from earlier fights
					Game.save.damage = int(a.substr(6))
			var qm := MapScreen.new()
			Game.show_screen(qm)
			if OS.get_cmdline_user_args().has("--skip"):  # --skip: skip that square's story lines (to see a fight's intel)
				await Game.get_tree().create_timer(1.0).timeout
				qm._dialog_skip()
			if OS.get_cmdline_user_args().has("--go"):  # --go: press 出战 on that square (the real quest-battle path)
				await Game.get_tree().create_timer(0.3).timeout
				Game.start_quest_battle(q, Quests.here(q, Game.save))
				if OS.get_cmdline_user_args().has("--end"):  # --end: then press 回合结束 once
					await Game.get_tree().create_timer(1.5).timeout
					var bs: BattleScreen = Game.root.get_children().filter(func(c): return c is BattleScreen and not c.is_queued_for_deletion())[0]
					bs._end.pressed.emit()
		"lordreveal":  # the lord-card moment a cleared chapter gives: --demo=lordreveal [--dupe]
			Game.save.flags = ["出生：冀州无极"]
			var rv := LordReveal.new()
			rv.form = "lord_north_silver" if Game.save.is_north() else "lord_south_armor"
			Game.save.lord_forms.append(rv.form)
			rv.dupe = OS.get_cmdline_user_args().has("--dupe")
			Game.show_screen(MapScreen.new())
			Game.add_child(rv)
		"relicreveal":  # the 宝物 card moment: --demo=relicreveal [--many]
			Game.save.flags = ["出生：冀州无极"]
			Game.show_screen(MapScreen.new())
			var rr := RelicReveal.new()
			rr.relic_ids = ["wentai_shu", "zhou_pu", "weixi"] if OS.get_cmdline_user_args().has("--many") else ["xuzhou_yin"]
			rr.title = "获得宝物"
			Game.add_child(rr)
		"ln2":  # 北线第二章 at 虎牢关: the 吕布 fork (lower x = earlier square via --at=<id>)
			Game.save.flags = ["出生：冀州无极"]
			Game.save.quests_cleared = ["prologue", "taodong"]
			var q: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == "luoyang_n")[0]
			Quests.begin(q, Game.save, Game.rng)
			Quests.pick_fate(Game.save, 0)
			var at: String = "ln_lvbu"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					at = a.substr(5)
			var path := ["ln_river", "ln_charge", "ln_lvlingqi", "ln_camp", "ln_rest1", "ln_mutiny_road", "ln_mutiny2",
				"ln_banner", "ln_feast", "ln_caocao", "ln_lend", "ln_lend_c", "ln_zhen", "ln_pursuit", "ln_ambush", "ln_ambush2", "ln_xurong", "ln_rescue",
				"ln_rest2", "ln_camp_raid", "ln_camp_raid2", "ln_approach", "ln_feixiong", "ln_langqi", "ln_rest3", "ln_lvbu",
				"ln_triple", "ln_box1", "ln_box2", "ln_box3", "ln_handhold", "ln_wait", "ln_blaze", "ln_cao_march", "ln_guosi",
				"ln_refugees", "ln_night_talk", "ln_rear_guard", "ln_rear_guard2", "ln_ferry", "ln_end"]
			for sid in path:
				Quests.resolve(q, Game.save, Game.rng, 0 if Quests.here(q, Game.save)["type"] == "choose" else -1)
				Quests.move(q, Game.save, sid)
				if sid == at:
					break
			Game.show_screen(MapScreen.new())
		"relics":  # an elite's 宝物 pick, a couple already held
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Quests.resolve(q, Game.save, Game.rng, 0)
			for sid in ["wake", "bandage", "village", "sc_home", "boar", "raid"]:
				Quests.move(q, Game.save, sid)
				Quests.resolve(q, Game.save, Game.rng)
			Game.save.relics = ["hupi", "yuxi"]
			Game.save.danger = 1
			Game.save.offer = ["shoushihe", "bingfa", "dunjia"]
			Game.save.offer_kind = "relic"
			var m := MapScreen.new()
			Game.show_screen(m)
			if OS.get_cmdline_user_args().has("--sel"):  # the second plaque tapped once: lifted, 选定 lit
				m.get_tree().create_timer(0.3).timeout.connect(func():
					var rp := m.get_node_or_null("RelicPick")
					if rp != null:
						rp._select(1))
		"eventfx":  # a ？ event's animated outcome (EventFx); --fx=a,b picks the sample cards (hp, diff, fate, divine, level, ambush, merit, lose)
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Game.save.fate = "jiangxing"
			Game.save.grant_card("sunce")
			Game.save.upgrade("sunce")
			Game.show_screen(MapScreen.new())
			var samples := {
				"hp": {"k": "hp", "n": -38, "left": 62, "top": 100},
				"diff": {"k": "difficulty", "from": 2, "to": 1, "pct": -30},
				"fate": {"k": "fate", "from": "jiangxing", "to": "xiongxing"},
				"divine": {"k": "fate", "from": "jiangxing", "to": "tianmingsuogui"},
				"level": {"k": "level", "card": "sunce", "lv_from": 5, "lv_to": 3},
				"ambush": {"k": "ambush", "on": true},
				"merit": {"k": "merit", "n": 5, "total": 12},
				"lose": {"k": "lose_soldier", "card": "danyang"},
			}
			var pick: Array = ["hp", "diff", "fate", "level"]
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--fx="):
					pick = Array(a.trim_prefix("--fx=").split(","))
			(func():
				await Game.get_tree().create_timer(0.3).timeout
				var o := EventFx.new()
				o.fx = pick.map(func(k): return samples[k])
				Game.root.get_child(Game.root.get_child_count() - 1).add_child(o)).call()
		"recap1":  # the chapter-end page of the south's first chapter: its picture, the menu, the picture's card
			var q1: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q1, Game.save)
			var north1 := OS.get_cmdline_user_args().has("--north")  # --north: the north's first chapter
			Quests.record(Game.save, "出生：冀州无极" if north1 else "出生：江东富春")
			Game.save.grant_card("zhaoyun" if north1 else "sunce")
			Game.save.grant_card("guojia" if north1 else "zhouyu")
			Game.save.run_battles = 6
			Game.save.run_bosses = 2
			Game.save.merit = 1
			Game.save.square = "jz_end" if north1 else "north"
			Game.save.resolved = true
			var m1 := MapScreen.new()
			Game.show_screen(m1)
			m1.call_deferred("_complete")
		"recap":  # the chapter recap at the end of chapter 2 (--north: the north's 洛阳烟云; --north --chapter=heishan|beihai|xuzhou|huainan_n|yecheng|longhu|xiliang|sanfang|tianqing: a later north chapter's page)
			Game.save.quests_cleared = ["prologue"]
			if OS.get_cmdline_user_args().has("--north"):
				# quest: [the chapters before it, the flags they left, this run's records, its last square]
				var north_pages := {
					"luoyang_n": [[], [], [], "ln_end"],
					"heishan": [["luoyang_n"], ["北线：班师冀州"], ["张宁：救下"], "hs_end"],
					"beihai": [["luoyang_n", "heishan"], ["北线：班师冀州", "界桥：救下公孙瓒"], ["张宁：救下", "郑姜：和好"], "bh_end"],
					"xuzhou": [["luoyang_n", "heishan", "beihai"], ["北线：班师冀州", "界桥：救下公孙瓒", "北线：北海相"], ["军纪：严明"], "xz_end"],
					"huainan_n": [["luoyang_n", "heishan", "beihai", "xuzhou"], ["北线：班师冀州", "界桥：救下公孙瓒", "北线：北海相", "徐州：接任徐州牧"], [], "hnn_end"],
					"yecheng": [["luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n"], ["北线：班师冀州", "界桥：救下公孙瓒", "北线：北海相", "徐州：接任徐州牧", "北线：让寿春"], ["陈宫：入队", "邺城：将计就计"], "n7_g_end"],
					"longhu": [["luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng"], ["北线：班师冀州", "界桥：救下公孙瓒", "北线：北海相", "徐州：接任徐州牧", "北线：让寿春", "北线：夺邺城"], ["田丰：入队", "北线：郭嘉随军"], "n8_g_bujian"],
					"xiliang": [["luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng", "longhu"], ["北线：班师冀州", "界桥：救下公孙瓒", "北线：北海相", "徐州：接任徐州牧", "北线：让寿春", "北线：夺邺城", "北线：西凉默契"], ["北线：不害马家", "北线：西凉归附"], "n9_g_end"],
					"sanfang": [["luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng", "longhu", "xiliang"], ["北线：班师冀州", "界桥：救下公孙瓒", "北线：北海相", "徐州：接任徐州牧", "北线：让寿春", "北线：夺邺城", "北线：西凉默契", "北线：北方一统"], ["庞统：入队", "北线：破虎牢"], "n10_g_end"],
					"tianqing": [["luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng", "longhu", "xiliang", "sanfang"], ["北线：班师冀州", "界桥：救下公孙瓒", "北线：北海相", "徐州：接任徐州牧", "北线：让寿春", "北线：夺邺城", "北线：西凉默契", "北线：北方一统", "北线：破虎牢"], ["诸葛亮：拜军师"], "n11_a_end"],
				}
				var qid := "luoyang_n"
				for a in OS.get_cmdline_user_args():
					if a.begins_with("--chapter="):
						qid = a.trim_prefix("--chapter=")
				var page: Array = north_pages[qid]
				Game.save.quests_cleared = ["prologue"] + page[0]
				Quests.begin(GameData.get_db().quests.filter(func(x): return x["id"] == qid)[0], Game.save)
				Game.save.flags = ["出生：冀州无极"] + page[1]
				for r in ["出生：冀州无极"] + page[2]:
					Quests.record(Game.save, r)
				if OS.get_cmdline_user_args().has("--ending"):  # --ending: this run reached the chapter's bad end (its settlement page)
					var qd: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == qid)[0]
					Quests.record(Game.save, qd.get("_raw", qd).get("ending", {}).get("title", ""))
				for c in ["zhaoyun", "guojia", "lvlingqi", "zhangning", "zhenghao", "jiangqiao"]:
					Game.save.grant_card(c)
				Game.save.run_battles = 7
				Game.save.run_bosses = 2
				Game.save.merit = 4
				Game.save.square = page[3]
				Game.save.resolved = true
				var mn := MapScreen.new()
				Game.show_screen(mn)
				mn.call_deferred("_complete")
				return
			var q: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q, Game.save)
			Game.save.grant_card("sunce")
			Quests.record(Game.save, "华雄：亲手斩杀，救下祖茂")
			Quests.record(Game.save, "吕布：三英战吕布")
			Quests.record(Game.save, "董白：留下")
			Game.save.grant_card("dongbai")
			Game.save.grant_card("gongnv")
			Game.save.grant_card("gongnv")
			Game.save.run_relics = ["chize", "hupi"]
			Game.save.relics = ["chize", "hupi"]
			Game.save.run_battles = 7
			Game.save.run_bosses = 3
			Game.save.merit = 4
			Game.save.square = "heroes"
			Game.save.resolved = true
			var m := MapScreen.new()
			Game.show_screen(m)
			m.call_deferred("_complete")
		"party", "party_pick":  # the 整备 screen with a mid-game collection
			for c in ["sunce", "zhouyu", "wuguotai", "sunjian", "huanggai", "chengpu", "dongbai"]:
				Game.save.grant_card(c)
			for c in ["danyang", "danyang", "changsha", "gongnv", "xiliang_nvbing"]:
				Game.save.grant_card(c)
			Game.save.kept_relics = ["shoushihe", "jiunang", "bingfu", "bingfa", "gudingdao", "dunjia"]  # a run starts with these
			Game.save.relics = Game.save.kept_relics.duplicate()
			if OS.get_cmdline_user_args().has("--manyrelics"):  # a late-run pile of 宝物 (the slots' icon rows must not widen the cards)
				for rid in GameData.get_db().relics.keys().slice(0, 16):
					if not Game.save.relics.has(rid):
						Game.save.relics.append(rid)
						Game.save.kept_relics.append(rid)
			Game.save.quests_cleared = ["prologue", "taodong"]  # the ？小故事 of those chapters are open
			Game.save.flags = ["出生：江东富春"]
			Game.save.merit = 7  # enough for one story (5), not two
			if OS.get_cmdline_user_args().has("--spent"):  # --spent: every owned card's 本章限 N 次 大招 used up (the 「大招已用」 tag)
				for cid in Game.save.owned:
					for sid in GameData.get_db().cards.get(cid, {}).get("skills", []):
						if GameData.get_db().skills[sid].get("uses", null) != null:
							Game.save.carry_uses[cid] = Game.save.carry_uses.get(cid, {})
							Game.save.carry_uses[cid][sid] = 0
			var m := MapScreen.new()
			Game.show_screen(m)
			m.call_deferred("_open_party")
			if OS.get_cmdline_user_args().has("--side"):  # --side: open the ？小故事 list (and with --read, the first story)
				(func():
					await Game.get_tree().create_timer(0.5).timeout
					var o: PartyOverlay = m.get_node("Party")
					o._side_btn.pressed.emit()
					if OS.get_cmdline_user_args().has("--reveal"):  # what a story gave, flipping in (as after reading 九九歌)
						await Game.get_tree().create_timer(0.3).timeout
						SideStoryList.reveal({"cards": ["sunce"], "relics": []}, o)
					if OS.get_cmdline_user_args().has("--read"):
						await Game.get_tree().create_timer(0.3).timeout
						for n in Game.get_tree().root.get_children():
							if n is SideStoryList:
								n._play(Quests.side_stories(Game.save)[0])).call()
			if OS.get_cmdline_user_args().has("--hurt"):  # --hurt: half HP, then the first leader steps down (the HP keeps its share)
				(func():
					await Game.get_tree().create_timer(0.5).timeout
					var o: PartyOverlay = m.get_node("Party")
					Game.save.damage = int(Quests.party_max(Game.save) / 2.0)
					o._rebuild()
					print("HURT before: ", Quests.party_max(Game.save) - Game.save.damage, " / ", Quests.party_max(Game.save))
					o._remove(Game.save.party[0])
					print("HURT after: ", Quests.party_max(Game.save) - Game.save.damage, " / ", Quests.party_max(Game.save))).call()
			if OS.get_cmdline_user_args().has("--voices"):  # tap 孙策, 吴夫人, 黄盖, a soldier and the lord: each says his line
				(func():
					await Game.get_tree().create_timer(0.5).timeout
					var o: PartyOverlay = m.get_node("Party")
					for cid in ["sunce", "wuguotai", "huanggai", "danyang", "lord"]:
						o._tap(cid)
						print("tapped ", cid)
						await Game.get_tree().create_timer(2.6).timeout).call()
			if name == "party_pick":  # a general selected: the detail panel with unit and skills
				(func():
					await Game.get_tree().process_frame
					var o: PartyOverlay = m.get_node("Party")
					o._sel = "sunce"
					o._filter = "cavalry"
					if OS.get_cmdline_user_args().has("--relics"):  # the 宝物 tab, 古锭刀 selected
						o._sel = "relic:gudingdao"
						o._filter = "relic"
					o._rebuild()
					for a in OS.get_cmdline_user_args():  # --tactics=party|troop:<troop>|card:<card id>: 军令 opened from 整备
						if a.begins_with("--tactics="):
							var v := a.trim_prefix("--tactics=").split(":")
							o._open_tactics(v[0], v[1] if v.size() > 1 else "")).call_deferred()
		"interlude":  # a ？小故事 in the reader: --id=<story id> (default the first), --line=N steps N lines in,
			# --nocg drops its picture (the portraits side by side, the speaker lit), --log opens 记录, --hide hides the text
			Game.save.quests_cleared = ["prologue", "taodong"]
			Game.save.flags = ["董白：留下", "唐姬：护送"]
			Game.show_screen(TitleScreen.new())
			var o := InterludeOverlay.new()
			var want := ""
			var steps := 0
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--id="):
					want = a.substr(5)
				elif a.begins_with("--line="):
					steps = int(a.substr(7))
			for qid in GameData.get_db().side_stories:
				for st in GameData.get_db().side_stories[qid]:
					if o.scenes.is_empty() and (want == "" or st["id"] == want):
						o.scenes = [st.duplicate()]
			if OS.get_cmdline_user_args().has("--nocg") and not o.scenes.is_empty():
				o.scenes[0]["cg"] = ""
			o.same_chapter = true
			Game.root.add_child(o)
			for _i in steps:
				o._next()
			if OS.get_cmdline_user_args().has("--log"):
				o._toggle_log()
			elif OS.get_cmdline_user_args().has("--hide"):
				o._hide_text()
		"reveal":  # the 入队 overlay: 孙策 and 周瑜 join
			var m := MapScreen.new()
			Game.show_screen(m)
			Game.save.grant_card("sunce")
			Game.save.grant_card("zhouyu")
			var db := GameData.get_db()
			m.call_deferred("_reveal", [db.cards["sunce"], db.cards["zhouyu"]], "入　队")
		"chest", "grand_chest":  # a chest opening over the map (use --wait to catch a moment of it)
			Quests.ensure_started(Game.save, Game.rng)
			Game.save.fate = "jiangxing"
			Game.save.fate_offer = []
			var m := MapScreen.new()
			Game.show_screen(m)
			var o := PickOverlay.new()
			o.title = "宝箱 —— 选一张兵卡"
			o.card_ids = ["danyang", "jiangdong_gong", "xiliang_nvbing"] if name == "chest" else ["huangzhong", "danyang", "sunshangxiang"]
			o.chest = "normal" if name == "chest" else "grand"
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			m.add_child(o)
		"upgrade":  # 点化: every card of yours on offer, the row scrolls sideways
			for c in ["sunce", "zhouyu", "huanggai", "taishici", "lvmeng", "ganning"]:
				Game.save.grant_card(c)
			Quests.ensure_started(Game.save, Game.rng)
			var m := MapScreen.new()
			Game.show_screen(m)
			var o := PickOverlay.new()
			o.title = "仙人点化 —— 选一位武将升级"
			o.card_ids = Game.save.upgradable()
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			m.add_child(o)
		"fate", "affix":  # a run's start: pick a 天命 / an elite square with its 词缀
			Game.save.grant_card("sunce")
			Game.save.grant_card("zhouyu")
			Game.save.quests_cleared = ["prologue"]
			var q2: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q2, Game.save, Game.rng)
			if name == "affix":
				Game.save.fate = Game.save.fate_offer[0]
				Game.save.fate_offer = []
				Game.save.square = "dongbai"
				Game.save.visited.append("dongbai")
				Game.save.resolved = false
			Game.show_screen(MapScreen.new())
		"fork":  # 第三章 at the 白衣抱琴 fork with 结局一 unlocked: both routes drawn
			Game.save.quests_cleared = ["prologue", "taodong"]
			Game.save.flags = ["董白：留下", "结局一 · 玉碎"]
			Game.save.grant_card("dongbai")
			Quests.ensure_started(Game.save)
			Game.save.square = "wenji_choice"
			Game.save.resolved = false
			Game.save.visited.append(Game.save.square)
			Game.show_screen(MapScreen.new())
		"ch4", "ch5":  # route B: 驻守洛阳 / 长安
			Game.save.quests_cleared = ["prologue", "taodong"]
			Game.save.flags = ["董白：留下"]
			Game.save.grant_card("dongbai")
			Quests.ensure_started(Game.save)
			Game.save.run_records = ["路线：守洛阳"] + (["路线：长安"] if name == "ch5" else [])  # still inside 第三章, past the fork
			Game.save.square = "lijue_test" if name == "ch5" else "wenji_join"
			Game.save.resolved = true
			Game.save.visited.append(Game.save.square)
			Game.show_screen(MapScreen.new())
		"ch6", "ch6b", "ch6c":  # 第四章 · 挟天子: 二周目 (nobody warns you) / 三周目 (貂蝉 comes) / 四周目 (张济 张绣, 贾诩 joins); --at=<square> jumps ahead
			Game.save.quests_cleared = ["prologue", "taodong", "yuxi"]
			Game.save.flags = ["董白：留下", "结局一 · 玉碎", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"]
			if name != "ch6":
				Game.save.flags.append("结局三 · 同归")
			if name == "ch6c":
				Game.save.flags.append("结局五 · 恨海")
			for c in ["dongbai", "caiwenji", "huangfusong", "zhujun"]:
				Game.save.grant_card(c)
			Quests.ensure_started(Game.save)
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					Game.save.square = a.trim_prefix("--at=")
					Game.save.visited.append(Game.save.square)
					Game.save.resolved = false
			Game.show_screen(MapScreen.new())
		"ch8", "ch8b":  # 第五章 · 荆襄风云: first time (the banquet, 结局五) / after 结局五 with 贾诩 (he breaks it); --at=<square> jumps ahead
			Game.save.quests_cleared = ["prologue", "taodong", "yuxi", "dongui"]
			Game.save.flags = ["董白：留下", "结局一 · 玉碎", "结局三 · 同归", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓", "南阳：袁术东逃"]
			if name == "ch8b":
				Game.save.flags.append_array(["结局五 · 恨海", "贾诩：入队"])
				Game.save.grant_card("jiaxu")
			for c in ["dongbai", "caiwenji", "diaochan", "xunyou", "huangzhong", "huangfusong"]:
				Game.save.grant_card(c)
			Quests.ensure_started(Game.save)
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					Game.save.square = a.trim_prefix("--at=")
					Game.save.visited.append(Game.save.square)
					Game.save.resolved = false
			Game.show_screen(MapScreen.new())
		"ch2_wait":  # chapter 2 after 董白's fate (kept): the months before 洛阳 burns
			Game.save.quests_cleared = ["prologue"]
			var q2: Dictionary = GameData.get_db().quests[1]
			Quests.begin(q2, Game.save)
			Quests.record(Game.save, "董白：留下")
			Game.save.square = "wait"
			Game.save.visited.append("wait")
			Game.show_screen(MapScreen.new())
		"ch3", "ch3_lost":  # chapter 3 after chapter 2 (董白 kept, or handed over)
			Game.save.quests_cleared = ["prologue", "taodong"]
			Game.save.flags = ["董白：留下"] if name == "ch3" else ["董白：交给袁绍"]
			if name == "ch3":
				Game.save.grant_card("dongbai")
			Quests.ensure_started(Game.save)
			Game.show_screen(MapScreen.new())
		"ending":  # the 结局一 card
			Game.show_screen(TitleScreen.new())
			var o := InterludeOverlay.new()
			o.ending = GameData.get_db().quests.filter(func(q): return q["id"] == "yuxi")[0]["ending"]
			o.scenes = []
			Game.root.add_child(o)
		"titlecard":  # the chapter-2 title card straight away
			var o := InterludeOverlay.new()
			o.next_title = GameData.get_db().quests[1]["title"]
			o.next_subtitle = GameData.get_db().quests[1]["subtitle"]
			Game.show_screen(TitleScreen.new())
			Game.root.add_child(o)
		"replays":  # the title screen's 重玩章节 list
			Game.save.quests_cleared = ["prologue", "taodong"]
			Game.save.clears = {"prologue": 3, "taodong": 1}
			var ts := TitleScreen.new()
			Game.show_screen(ts)
			ts.call_deferred("_replay_menu", ts._col, Game.save)
		"cg":  # standing on a southern prologue square (醒来 by default; --at=<square id> for any other)
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Quests.resolve(q, Game.save, Game.rng, 0)
			var at: String = "wake"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					at = a.substr(5)
			if at == "wake":
				Quests.move(q, Game.save, "wake")
			else:
				var path := ["wake", "bandage", "village", "sc_home", "boar", "raid", "plan", "sc_gate", "sc_road", "sc_hall", "rescue", "dinner", "muster", "draft", "reeds", "yaodao", "isle", "lair", "vault", "armor", "oath", "north"]
				for sid in path:
					Quests.move(q, Game.save, sid)
					if sid == at:
						break
					Quests.resolve(q, Game.save, Game.rng, 0 if Quests.here(q, Game.save)["type"] == "choose" else -1)
			Game.show_screen(MapScreen.new())
		"cg_north":  # standing on a northern prologue square (甄府醒来 by default; --at=<square id> for any other)
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Quests.resolve(q, Game.save, Game.rng, 1)
			Quests.move(q, Game.save, "jz_arrive")
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
				var path: Array = ["jz_ledger", "jz_road", "jz_county", "jz_help", "jz_guojia", "jz_integrity", "jz_mystery2", "jz_relief", "jz_route"] \
					+ route_branch + ["jz_zuoci", "jz_mystery3", "jz_ambush", "jz_breakout", "jz_plan"] \
					+ branch + ["jz_recover", "jz_boss", "jz_loot", "jz_reunite_g" if guo else "jz_reunite", "jz_mystery4", "jz_almsgiving", "jz_recruit", "jz_training", "jz_night", "jz_end"]
				for sid in path:
					var pick: int = 0
					if Quests.here(q, Game.save)["type"] == "choose":
						if Game.save.square == "jz_plan":
							pick = 1 if guo else 0
						elif Game.save.square == "jz_route":
							pick = 0 if road else 1
					else:
						pick = -1
					Quests.resolve(q, Game.save, Game.rng, pick)
					Quests.move(q, Game.save, sid)
					if sid == at:
						break
			Game.show_screen(MapScreen.new())
		"fork":  # after 富春: follow 周瑜 or 孙策
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Quests.resolve(q, Game.save, Game.rng, 0)
			for sid in ["wake", "bandage", "village"]:
				Quests.move(q, Game.save, sid)
				Quests.resolve(q, Game.save, Game.rng)
			Game.show_screen(MapScreen.new())
		"era":  # the very first choice, clicked to its last line
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			var m := MapScreen.new()
			Game.show_screen(m)
			for _i in 12:
				m.call_deferred("_on_story_click", m._fake_click())
		"cg_click":  # the same, clicked through to the last line (buttons shown)
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Quests.resolve(q, Game.save, Game.rng, 0)
			Quests.move(q, Game.save, "wake")
			var m := MapScreen.new()
			Game.show_screen(m)
			for _i in 12:
				m.call_deferred("_on_story_click", m._fake_click())
			if OS.get_cmdline_user_args().has("--press-continue"):  # then press 继续: it should walk on to 换药
				m.get_tree().create_timer(0.5).timeout.connect(func(): m._resolve())
		"tiers":  # 铜 / 银 / 金 / 神 frames
			Game.save.owned = ["sunce", "zhouyu", "sunjian", "guanyu"]
			Game.save.dupes = {"zhouyu": 4, "sunjian": 16, "guanyu": 64}
			Game.show_screen(TitleScreen.new())
			var o := PickOverlay.new()
			o.title = "铜 · 银 · 金 · 神"
			o.card_ids = ["sunce", "zhouyu", "sunjian", "guanyu"]
			o.captions = ["1 张 · 铜", "4 张 · 银", "16 张 · 金", "64 张 · 神"]
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			Game.root.add_child(o)
		"prep":  # 前尘整备 at the start of a second 周目: 6 endings reached, a few cards remembered
			var db := GameData.get_db()
			for cid in ["sunce", "zhouyu", "taishici", "ganning", "danyang", "jiefan"]:
				if db.cards.has(cid):
					Game.save.grant_card(cid)
			Game.save.flags = db.ending_order.slice(0, 6).map(func(id): return db.endings[id]["title"])
			Game.save.commit_history()
			Game.save = Game.save.new_lap()
			Game.save.perks = {"ap_max": 1, "public": 1, "lord_bench": 1}
			if OS.get_cmdline_user_args().has("--view"):  # 设置 → 查看前尘整备: what this 周目 bought, read back mid-run
				Game.save.perks = {"merit": 2, "start_chest": 1}
				Game.save.prep_cards = ["jiangwei", "taishici"]
				Game.save.prep_relics = ["jiunang"]
				Game.show_screen(TitleScreen.new())
				var so := SettingsOverlay.new()
				Game.root.add_child(so)
				so._prep()
			else:
				Game.show_screen(PrepScreen.new())
		"title":
			Game.show_screen(TitleScreen.new())
		"debug":  # --at=jump/cards/cgs picks the opening tab
			Game.show_screen(TitleScreen.new())
			var dbg := DebugScreen.new()
			Game.root.add_child(dbg)
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--at="):
					dbg._show(a.trim_prefix("--at="))
				if a.begins_with("--tab="):  # --at=cards --tab=<chip,chip…>: press those filter chips in turn (e.g. 章节招贤馆,R)
					for want in a.trim_prefix("--tab=").split(","):
						for btn in dbg._view.find_children("*", "Button", true, false):
							if str(btn.text).begins_with(want + " ") and not btn.is_queued_for_deletion():
								btn.pressed.emit()
								break
				if a.begins_with("--card="):  # open that card's preview straight away
					dbg._preview_card(a.trim_prefix("--card="))
		"map", "pick":
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Quests.resolve(q, Game.save, Game.rng, 0)
			for sid in ["wake", "bandage", "village", "sc_home", "boar", "raid", "plan"]:
				Quests.move(q, Game.save, sid)
				Quests.resolve(q, Game.save, Game.rng)
			for sid in ["zy_lure", "zy_back", "zy_hall", "rescue", "dinner", "muster"]:
				Quests.move(q, Game.save, sid)
				Quests.resolve(q, Game.save, Game.rng, 1)
			Game.save.damage = 900
			if name == "pick":
				Quests.move(q, Game.save, "draft")
			var ms := MapScreen.new()
			Game.show_screen(ms)
			if name == "pick" and OS.get_cmdline_user_args().has("--open"):  # --open: the 招贤 pick already up
				ms.call_deferred("_open_offer", Quests.here(Quests.ensure_started(Game.save), Game.save))
		"choose":
			var q: Dictionary = GameData.get_db().quests[0]
			Quests.begin(q, Game.save)
			Quests.resolve(q, Game.save, Game.rng, 0)
			for sid in ["wake", "bandage", "village", "sc_home", "boar", "raid"]:
				Quests.move(q, Game.save, sid)
				Quests.resolve(q, Game.save, Game.rng)
			Quests.move(q, Game.save, "plan")
			Game.show_screen(MapScreen.new())
		"fx":  # --demo=fx --fx=<hit|archer|volley|spear|cavalry|bandit|ultarrow|enemyult|swap|stance|magic|pierce|boosthit|claw|counter|burn|pburn|break|stun|confuse|boost|buff|cleanse|drain>: one effect mid-flight
			Game.save.owned = ["sunce_zhong", "sunce_bawang", "zhouyu_chibi", "wuguotai", "guanyu", "sunjian"]
			Game.save.soldiers = {"cav_n": 2, "strat_n": 1, "log_n": 1}
			Game.save.party = ["sunce_zhong", "zhouyu_chibi", "sunjian"]
			var fb := BattleScreen.new()
			fb.scenario_id = "ln_lvlingqi"  # a CG enemy: the effects at full size
			Game.show_screen(fb)
			await Game.get_tree().create_timer(0.25).timeout
			fb._busy = true
			fb._sync_skill_bars()
			var want := "hit"
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--fx="):
					want = a.substr(5)
			var eng: Battle = fb.b
			BattleFx.scale = fb._enemy_fx_scale() if want in ["hit", "magic", "thunder", "pierce", "boosthit", "counter", "burn", "break", "ultmagic", "rider", "poison", "kill", "archer", "volley", "spear", "cavalry", "bandit", "ultarrow"] else 1.0
			match want:
				"hit":
					BattleFx.hit(fb, fb._enemy_center(), "attack", 3, 0.12)
				"archer", "volley", "spear", "cavalry", "bandit":  # the troop-shaped plain blows
					BattleFx.troop_hit(fb, fb._enemy_center(), "archer" if want == "volley" else want, 5 if want == "volley" else 2)
				"ultarrow":
					BattleFx.ult_arrow(fb, fb._enemy_center())
				"enemyult":
					BattleFx.enemy_ult_slash(fb, fb._cards_rect())
				"swap":  # 换人 through the real event (slot 1 → 关羽)
					eng.round_no = eng.swap_from_round()
					eng.ap = 8
					var opts: Array = eng.swap_options(1)
					if not opts.is_empty():
						eng.swap(1, opts[0]["card"]["id"])
						fb._play(eng.take_events())
				"stance":
					eng.enemy["stance"] = {"name": "以逸待劳", "turns": 2}
					eng.party_hp = int(eng.party_max * 0.2)
					fb._refresh()
					fb._sync_fx()
				"magic":
					BattleFx.hit(fb, fb._enemy_center(), "magic", 1, 0.05)
				"thunder":  # 雷法: the jagged bolt
					BattleFx.hit(fb, fb._enemy_center(), "magic", 1, 0.05, false, false, "thunder")
				"ultmagic":
					BattleFx.ult_magic(fb, fb._enemy_center(), 1, 0.2)
					Kit.tween_bar(fb._enemy_hp, fb.b.enemy["max_hp"] * 0.6)
					Kit.float_text(fb, fb._enemy_center() + Vector2(0, -30), "暴击 2480", Kit.c("gold"), 64)
				"rider":
					BattleFx.rider_hit(fb, fb._enemy_center())
					Kit.float_text(fb, fb._enemy_center() + Vector2(54, -18), "战意 +420", Color(0.88, 0.72, 1.0), 36)
				"kill":
					BattleFx.kill_blow(fb, fb._enemy_center())
				"pierce":
					BattleFx.hit(fb, fb._enemy_center(), "attack", 1, 0.05, true)
				"boosthit":
					BattleFx.hit(fb, fb._enemy_center(), "attack", 2, 0.15, false, true)
				"claw":
					BattleFx.claw(fb, fb._cards_rect().get_center(), 0.12, 0.5)
					fb._enemy_move_tag("方天画戟")
				"counter":
					BattleFx.counter(fb, fb._enemy_center())
				"counter_on":
					eng.counters.append({"name": "孙策", "at": 100, "power": 1.0, "unit": 1})
					fb._refresh()
					BattleFx.counter_stance(fb, fb._card_rect(1))
				"burn":
					eng.enemy["burn_turns"] = 3
					eng.enemy["burn_pct"] = 0.1
					fb._refresh()
					BattleFx.flame_lick(fb, fb._enemy_rect())
				"poison":
					eng.enemy["poison"] = 3
					eng.enemy["poison_pct"] = 0.02
					eng.enemy["poison_turns"] = 3
					fb._refresh()
					BattleFx.poison_cloud(fb, fb._enemy_rect())
				"charge":
					eng.enemy["charging"] = "天下无双"
					fb._refresh()
				"heal":
					BattleFx.heal_wave(fb, fb._party_rect())
					Kit.float_text(fb, fb._party_center(), "+680", Kit.c("green"), 44)
				"shield":
					BattleFx.shield_wall(fb, fb._party_rect(), true)
					Kit.float_text(fb, fb._party_center(), "减伤 50%", Kit.c("blue"), 34)
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
			Game.save.owned = ["machao", "madai", "mayunlu", "zhangfei", "daqiao"]
			Game.save.party = ["machao", "zhangfei", "daqiao"]
			var sb := BattleScreen.new()
			sb.scenario_id = "hulao"
			Game.show_screen(sb)
			await Game.get_tree().create_timer(0.5).timeout
			await sb._on_skill(1, "xiliang")
			if OS.get_cmdline_user_args().has("--done"):
				sb.b.round_no = 3
				sb.b.ap = 4
				await sb._on_swap(1, "madai")
			else:
				sb.b.round_no = 3
				sb.b.ap = 4
				sb._open_swap(1)
				if OS.get_cmdline_user_args().has("--drop"):  # drag 马云騄 onto 张飞 (not the slot it was opened on): he comes off
					await Game.get_tree().create_timer(0.5).timeout
					var po: PartyOverlay = sb.get_children().filter(func(c): return c is PartyOverlay)[0]
					po._drop("slot:zhangfei", {"kind": "card", "id": "mayunlu", "from": "pool"})
		"defeatflow":  # a real quest battle lost for good: the 阵亡 picture, a click, and we must land back on the map
			Game.save.owned = ["sunce_bawang", "zhouyu_chibi", "sunjian"]
			Game.save.party = ["sunce_bawang", "zhouyu_chibi", "sunjian"]
			Quests.ensure_started(Game.save, Game.rng)
			var dq: Dictionary = {}
			for qq in GameData.get_db().quests:
				if qq["id"] == "prologue":
					dq = qq
			for sid in ["jz_arrive"] if false else dq["squares"]:
				if dq["squares"][sid]["type"] == "battle" and dq["squares"][sid].get("lose_goto", "") == "" and not dq["squares"][sid].get("requires", ""):
					Game.save.square = sid
					break
			Game.save.resolved = false
			var bs: Dictionary = dq["squares"][Game.save.square]
			Game.start_quest_battle(dq, bs)
			var bsc: BattleScreen = Game.root.get_child(Game.root.get_child_count() - 1)
			await Game.get_tree().create_timer(0.6).timeout
			bsc.b.result = "lose"
			bsc.b.lose_reason = "wiped"
			bsc._finish()
			await Game.get_tree().create_timer(4.0).timeout
			var top: Node = Game.root.get_child(Game.root.get_child_count() - 1)
			print("DEFEATFLOW before click: ", top.get_class(), " children=", Game.root.get_child_count())
			print("DEFEATFLOW overlay: ready_to_close=", top.get("_ready_to_close"), " filter=", top.mouse_filter, " size=", top.size, " z=", top.z_index, " script=", top.get_script().resource_path if top.get_script() else "none")
			print("DEFEATFLOW hovered at centre: ", Game.get_viewport().gui_get_hovered_control())
			var ev := InputEventMouseButton.new()
			ev.button_index = MOUSE_BUTTON_LEFT
			ev.position = Vector2(640, 360)
			ev.global_position = ev.position
			ev.pressed = true
			Input.parse_input_event(ev)
			await Game.get_tree().create_timer(1.5).timeout
			top = Game.root.get_child(Game.root.get_child_count() - 1)
			print("DEFEATFLOW after click: ", top.get_class(), " children=", Game.root.get_child_count(), " names=", Game.root.get_children().map(func(c): return c.get_class()))
		"battle", "fight":
			Game.save.owned = ["sunce_zhong", "sunce_bawang", "zhouyu_chibi", "wuguotai", "guanyu", "sunjian"]
			Game.save.soldiers = {"cav_n": 2, "strat_n": 1, "log_n": 1}
			Game.save.party = ["sunce_zhong", "zhouyu_chibi", "sunjian"]
			var b := BattleScreen.new()
			b.scenario_id = "hulao"
			for a in OS.get_cmdline_user_args():  # --scenario=<id>: any battle, e.g. one with a battle CG
				if a.begins_with("--scenario="):
					b.scenario_id = a.trim_prefix("--scenario=")
				if a.begins_with("--fate="):  # --fate=xiansheng: fight under a 天命 (its mods apply from the first frame, e.g. 开局全军 BOOST)
					Game.save.fate = a.trim_prefix("--fate=")
					b.carry = true
			Game.show_screen(b)
			if OS.get_cmdline_user_args().has("--swapui"):  # 换人: the 整备 screen in swap mode, for the second leader
				await Game.get_tree().create_timer(0.5).timeout
				b.b.round_no = b.b.swap_from_round()
				b._refresh()
				b._open_swap(0 if OS.get_cmdline_user_args().has("--lordswap") else 1)  # --lordswap (with --forms): the lord changes card
			if OS.get_cmdline_user_args().has("--boost"):  # a strengthened (BOOST) card must stand out
				await Game.get_tree().create_timer(0.5).timeout
				b.b.leaders[1]["boosted"] = true
				b._refresh()
			if OS.get_cmdline_user_args().has("--endwin"):  # win with a boosted card and statuses up: nothing may stay over the 胜利 banner
				await Game.get_tree().create_timer(0.5).timeout
				b.b.leaders[1]["boosted"] = true
				b.b.enemy["burn_turns"] = 3
				b.b.enemy["burn_pct"] = 0.1
				b.b.buff["layers"] = 2
				b._refresh()
				await Game.get_tree().create_timer(0.8).timeout
				b.b.enemy["hp"] = 0
				b.b.result = "win"
				b._refresh()
				b._finish()
			if OS.get_cmdline_user_args().has("--longstatus"):  # every status line at once: the enemy panel must not grow
				await Game.get_tree().create_timer(0.5).timeout
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
				await Game.get_tree().create_timer(0.5).timeout
				b.b.mods["ap_max"] = 6
				b.b.ap = b.b.ap_max()
				b.b.combo = 5
				b.b.round_no = b.b.turn_limit
				b.b.ap_drain = 2
				b._refresh()
			if OS.get_cmdline_user_args().has("--lastround"):  # the round-limit warning: play the final round's alert
				await Game.get_tree().create_timer(0.5).timeout
				b.b.round_no = b.b.turn_limit - 1
				await b._on_end_round()
				print("LASTROUND-DEMO result=", b.b.result, " reason=", b.b.lose_reason, " busy=", b._busy)
				await b._on_end_round()  # and play the final round out: the round limit is up, the battle is lost on turns
				print("LASTROUND-DEMO final: result=", b.b.result, " reason=", b.b.lose_reason, " busy=", b._busy)
				await Game.get_tree().create_timer(6.0).timeout
				print("LASTROUND-DEMO after 6s: screen=", Game.root.get_child(Game.root.get_child_count() - 1).get_class(), " busy=", b._busy if is_instance_valid(b) else "freed")
			if OS.get_cmdline_user_args().has("--auto"):  # play the whole battle through the real UI (any skill, any round) — for hunting hangs
				await Game.get_tree().create_timer(0.4).timeout
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
				await Game.get_tree().create_timer(5.0).timeout
				print("AUTO-DEMO result=", b.b.result, " busy=", b._busy, " screen=", Game.root.get_child(Game.root.get_child_count() - 1).get_class())
			if OS.get_cmdline_user_args().has("--tactics"):  # v3 军令 panel, with a sample rule on the lord
				await Game.get_tree().create_timer(0.5).timeout
				var tac: Dictionary = AutoPlayer.with_defaults(Game.options.get("tactics", {}))
				if not tac["rows"].has("lord"):
					tac["rows"] = {"lord": [{"skill": "rengdao", "cond": "enemy_charging", "reserve": true}, {"skill": "tuji", "cond": "always", "reserve": false}]}
				if tac["troop_rows"].is_empty():
					tac["troop_rows"] = {"logistics": [{"act": "heal", "cond": "party_low_hp"}], "cavalry": [{"act": "signature", "cond": "enemy_broken"}]}
				Game.options["tactics"] = tac
				b._open_tactics()
				for a in OS.get_cmdline_user_args():  # --tab=party|troop|card
					if a.begins_with("--tab="):
						b.get_children().filter(func(n): return n is TacticsOverlay).back().show_tab(a.trim_prefix("--tab="))
			if OS.get_cmdline_user_args().has("--guard"):  # v3: a 前卫 and a 架势 on the enemy, the planned moves shown
				await Game.get_tree().create_timer(0.5).timeout
				var gm: int = int(round(b.b.enemy["max_hp"] * 0.15))
				b.b.enemy["guard"] = {"name": "虎卫军", "hp": gm * 2 / 3, "max_hp": gm, "strike": 0.6}
				b.b.enemy["stance"] = {"name": "画戟架势", "power": 0.9, "turns": 1}
				b._refresh()
			if OS.get_cmdline_user_args().has("--mech"):  # 点名 / 护盾 / 变阵 / 封技 all on at once (the status lines, badges and the marked card)
				await Game.get_tree().create_timer(0.5).timeout
				var sm: int = int(round(b.b.enemy["max_hp"] * 0.12))
				b.b.enemy["data"]["moves"].append({"name": "画戟斩将", "power": 0, "weight": 0})
				b.b.enemy["mark"] = {"card": Battle.swap_key(b.b.leaders[1]["leader"]), "who": Battle.unit_name(b.b.leaders[1]), "move": "画戟斩将"}
				b.b.enemy["shield"] = {"name": "相国铁甲", "hp": sm * 2 / 3, "max_hp": sm}
				b.b.enemy["form"] = {"name": "八门金锁·休门", "vs": "attack", "cut": 0.6, "turns": 2}
				b.b.seal = {"name": "反间计", "kind": "ultimate", "turns": 1}
				b.b._plan_intents()
				b._refresh()
				b._sync_fx()
				b._sync_skill_bars()
				if OS.get_cmdline_user_args().has("--slain"):  # the 点名 blow lands: X cut, the card goes dark (--markon: the 「点」 stamp instead)
					await Game.get_tree().create_timer(0.3).timeout
					b.b.enemy["shield"] = {}
					b.b.enemy["form"] = {}
					b.b.seal = {}
					b._on_end_round()
				elif OS.get_cmdline_user_args().has("--markon"):
					await Game.get_tree().create_timer(0.3).timeout
					b._play([{"t": "mark_on", "unit": 1, "move": "画戟斩将"}])
			for a in OS.get_cmdline_user_args():  # --tip=intent|guard|<n>: the panel a tap on the 意图 / 前卫 / the n-th status badge opens
				if a.begins_with("--tip="):
					await Game.get_tree().create_timer(0.4).timeout
					var which := a.trim_prefix("--tip=")
					var tn: Control = b._intent_label if which == "intent" else (b._guard_row if which == "guard" else b._badges.filter(func(n): return is_instance_valid(n) and n.has_meta("tip"))[int(which)])
					var tp: Array = tn.get_meta("tip")
					b._show_info(str(tp[0]), str(tp[1]))
			if name == "fight" and OS.get_cmdline_user_args().has("--break"):  # v3 破招: the lord's 扔刀 on a wound-up enemy
				await Game.get_tree().create_timer(0.5).timeout
				b.b.enemy["charging"] = "天下无双"
				b.b._plan_intents()
				b.b.ap = 5
				b._refresh()
				await Game.get_tree().create_timer(0.3).timeout
				await b._on_skill(0, "rengdao")
			elif name == "fight" and (OS.get_cmdline_user_args().has("--guard") or OS.get_cmdline_user_args().has("--tactics")):
				pass
			elif name == "fight" and OS.get_cmdline_user_args().has("--ult-enemy"):  # the enemy's 大招 cut-in: its charged move lands now
				await Game.get_tree().create_timer(0.5).timeout
				for m in b.b.enemy["data"]["moves"]:
					if float(m.get("weight", 1.0)) <= 0.0:
						b.b.enemy["charging"] = m["name"]
						break
				await b._on_end_round()
			elif name == "fight" and OS.get_cmdline_user_args().has("--ult-lord"):  # a physical 大招: the lord's 扔刀 as the big curved cut
				await Game.get_tree().create_timer(0.5).timeout
				b.b.ap = b.b.ap_max()
				await b._on_skill(0, "rengdao")
			elif name == "fight" and OS.get_cmdline_user_args().has("--ult"):  # the 大招 cut-in: 周瑜·赤壁's 赤壁业火, AP topped up
				await Game.get_tree().create_timer(0.5).timeout
				b.b.ap = b.b.ap_max()
				await b._on_skill(2, "chibi")
			elif name == "fight" and not BattleScreen.auto_on:  # play a few actions to exercise the animations (with --auto the auto player already acts)
				await Game.get_tree().create_timer(0.5).timeout
				await b._on_skill(1, "bawang")
				await b._on_skill(0, "tuji")
				if OS.get_cmdline_user_args().has("--defend"):  # 防御: 「举盾！」
					await b._on_defend()
				b._on_end_round()
