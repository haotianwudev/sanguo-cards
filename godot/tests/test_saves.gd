extends TestCase
## 存档、重返上一格、重打这一章、重玩、读旧存档（从原来 2500 行的 test_quests.gd 按主题拆出）


func test_failing_steps_back_one_square() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0), 0)
	walk_to(q, s, ["wake", "bandage", "village", "sc_home", "boar", "raid"])
	Quests.move(q, s, "plan")
	Quests.resolve(q, s, rng(0), 1)
	s.damage = 999
	Quests.fail(q, s)
	check(s.square == "raid" and s.damage == 0, "steps back to the previous square at full HP (no 1-HP retry loop)")
	check(s.resolved, "the previous square remains resolved")
	check(s.has_card("zhouyu"))
	Quests.move(q, s, "plan")
	check(s.resolved, "earlier plan stands")
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["zy_lure"])


func test_an_old_save_on_a_removed_square_restarts_the_quest() -> void:
	var s := SaveData.create()
	s.quest = "prologue"
	s.square = "hg_talk"
	Quests.ensure_started(s)
	check_eq(s.square, "era")


func test_relics_carry_into_the_next_chapter_but_new_ones_reset_on_a_restart() -> void:
	var s := SaveData.create()
	Quests.begin(quest(0), s)
	s.relics = ["hupi", "jiunang"]
	Quests.complete(quest(0), s)
	Quests.begin(quest(1), s)
	check_eq(s.relics, ["hupi", "jiunang"], "all of chapter 1's relics come along")
	s.relics.append("bingfu")
	Quests.fail(quest(1), s)
	check_eq(s.relics, ["hupi", "jiunang"], "a restart drops only what this chapter gave")


func test_replaying_a_chapter_is_harder_and_returns_to_the_story() -> void:
	var s := SaveData.create()
	Quests.begin(quest(0), s)
	Quests.complete(quest(0), s)
	Quests.begin(quest(1), s)
	s.square = "counter"
	s.damage = 123
	s.take("sunce")
	Quests.start_replay(quest(0), s, rng(0))
	check(s.quest == "prologue" and s.danger == 1, "进阶: one clear = +1 险")
	s.grant_card("danyang")
	Quests.complete(quest(0), s)
	check(s.replay == "" and s.quest == "taodong" and s.square == "counter" and s.damage == 123, "back where the story was")
	check(s.has_card("danyang"), "replay rewards stay")
	check_eq(s.clears["prologue"], 2)
	check_eq(s.quests_cleared, ["prologue"])
	Quests.start_replay(quest(0), s, rng(0))
	check_eq(s.danger, 2, "harder again")
	Quests.stop_replay(s)
	check(s.quest == "taodong" and s.square == "counter", "giving up returns to the story too")


func test_a_chapters_first_step_hands_out_its_lord_card() -> void:
	## in play (an rng given) the card comes with the first square the chapter steps onto, once per chapter; tests without one stay fixed
	## the first chapter's is the route's fixed default (every 周目); the lord has no card before it, and the next 周目 remembers them
	var db := GameData.get_db()
	var q: Dictionary = db.quests[0]
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var s := SaveData.create()
	Quests.begin(q, s)
	check(s.lord_forms.is_empty(), "no lord card before the first square")
	s.run_records.append("出生：冀州无极")  # the birth choice is made on the start square (era), before the first step
	s.choices["era"] = "jz_arrive"
	s.resolved = true
	var got := Quests.move(q, s, "jz_arrive", rng)
	check_eq(got.size(), 1, "the first step: one card")
	check_eq(got[0]["form"], "lord_default", "…the fixed default one")
	check_eq(s.lord_forms, ["lord_default"], "…and kept")
	check_eq(s.lord_form_paid, q["id"], "marked as paid for this chapter")
	s.commit_history()  # an ending was reached
	var lap2 := s.new_lap()
	check(lap2.lord_forms.is_empty(), "the next 周目 does not keep the card itself…")
	check(lap2.cleared_forms.has("lord_default"), "…but remembers it")
	Quests.begin(q, lap2)
	lap2.run_records.append("出生：冀州无极")
	lap2.choices["era"] = "jz_arrive"
	lap2.resolved = true
	var before := lap2.lord_copies
	var again := Quests.move(q, lap2, "jz_arrive", rng)
	check_eq(again[0]["form"], "lord_default", "the default card again on the next 周目's first step")
	check(again[0]["dupe"] and again[0]["fresh"], "…the card is yours again, and the lord's level goes up with it")
	check_eq(lap2.lord_copies, before + 1, "…one more copy of the lord (+1, not a whole tier)")
	check_eq(lap2.lord_forms, ["lord_default"], "…and the card is in hand")
	var fixed := SaveData.create()
	Quests.begin(q, fixed)
	fixed.run_records.append("出生：冀州无极")
	fixed.choices["era"] = "jz_arrive"
	fixed.resolved = true
	check(Quests.move(q, fixed, "jz_arrive").is_empty(), "without an rng (tests) nothing is handed out")
	check(fixed.lord_forms.is_empty(), "…and the collection stays empty")


func test_restarting_a_chapter_goes_back_to_how_it_began() -> void:
	var s := SaveData.create()
	Quests.begin(quest(0), s, rng(3))
	Quests.complete(quest(0), s)
	s.grant_card("danyang")
	Quests.begin(quest(1), s, rng(3))
	var before: Dictionary = s.snapshot()
	s.square = "counter"
	s.visited.append("counter")
	s.take("sunce")
	s.grant_card("danyang")
	s.relics.append("bingfu")
	s.merit += 5
	s.run_records.append("董白：留下")
	Quests.fail(quest(1), s, rng(1))  # a lost fight must not overwrite the snapshot
	Quests.restart(s, rng(9))
	check_eq(s.snapshot(), before, "every field back to the chapter's start, the dealt map included")
	check(not s.has_card("sunce") and s.copies("danyang") == 1)


func test_restarting_an_old_save_without_a_snapshot_returns_the_cards() -> void:
	var s := SaveData.create()
	Quests.begin(quest(0), s)
	s.chapter_start = {}  # a save from before the snapshot existed
	s.grant_card("danyang")
	s.take("sunce")
	Quests.restart(s, rng(0))
	check(not s.has_card("sunce") and s.copies("danyang") == 0, "cards gained this chapter are given back")
	check_eq(s.square, quest(0)["start"])


func test_stepping_back_undoes_one_square_at_a_time() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s, rng(3))
	Quests.resolve(q, s, rng(0), 0)
	var at_start: Dictionary = s.snapshot()
	Quests.move(q, s, "wake")
	Quests.resolve(q, s, rng(0), 0)
	var at_wake: Dictionary = s.snapshot()
	Quests.move(q, s, "bandage")
	Quests.resolve(q, s, rng(0), 0)
	s.grant_card("danyang")
	s.relics.append("bingfu")
	check_eq(s.steps.size(), 2)
	s.rewind_step()
	check_eq(s.snapshot(), at_wake, "back on 「wake」 as it was, before stepping on")
	s.rewind_step()
	check_eq(s.snapshot(), at_start, "and once more, to the first square")
	check(s.steps.is_empty())
	print("  snapshot size: %d bytes" % JSON.stringify(at_wake).length())


func test_stepping_back_onto_a_made_choice_lets_you_choose_again() -> void:
	## a choose square moves on by itself once picked: 重返上一格 from there lands before the pick, not on the made choice
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0), 0)
	walk_to(q, s, ["wake", "bandage", "village", "sc_home", "boar", "raid"])
	Quests.move(q, s, "plan")
	Quests.resolve(q, s, rng(0), 1)
	Quests.move(q, s, "zy_lure")
	Quests.step_back(s)
	check(s.square == "plan" and not s.resolved, "back on 「plan」 with its options open again")
	check(not s.choices.has("plan") and not s.run_records.has("定计：周瑜调虎离山"), "the old pick is undone")
	Quests.resolve(q, s, rng(0), 0)
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["sc_gate"])
	Quests.move(q, s, "sc_gate")
	Quests.step_back(s)
	check(s.square == "plan" and not s.resolved, "and again, after the other pick")
	Quests.step_back(s)
	check_eq(s.square, "raid", "once more goes past the choice to the square before it")


func test_stepping_back_reopens_the_xunyou_or_huangzhong_choice() -> void:
	## 第五章 刘表来袭: 听荀攸 / 听黄忠 — the pick (and its 宝物) is undone and can be made the other way
	var q: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == "jingxiang")[0]
	var s := SaveData.create()
	s.replay = "jingxiang"  # so current_quest finds this chapter without the earlier ones' flags
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0), 0)
	walk_to(q, s, ["jx_diaochan", "t_jx1", "t_jx1_b", "jx_laixi"])
	walk_to(q, s, ["jx_plan_xun"])
	check(s.relics.has("xunyou_qizi"))
	Quests.step_back(s)
	check(s.square == "jx_laixi" and not s.resolved, "one step back reopens the choice")
	check(not s.relics.has("xunyou_qizi") and not s.run_records.has("议事：荀攸示弱诱敌"))
	Quests.resolve(q, s, rng(0), 1)
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["jx_plan_huang"])


func test_a_save_left_on_a_made_choice_can_reopen_it() -> void:
	## an older build stepped back onto the made pick and saved there: the map's 「重新选择」 reopens it
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0), 0)
	walk_to(q, s, ["wake", "bandage", "village", "sc_home", "boar", "raid"])
	Quests.move(q, s, "plan")
	Quests.resolve(q, s, rng(0), 1)
	Quests.move(q, s, "zy_lure")
	s.rewind_step()  # the old 重返上一格
	check(s.square == "plan" and s.resolved, "sitting on the made choice")
	Quests.reopen_choice(s)
	check(s.square == "plan" and not s.resolved, "its options are open again")
	check(not s.run_records.has("定计：周瑜调虎离山"), "the old pick is undone")


func test_stepping_back_onto_the_first_square_choice_restarts_it() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0), 0)
	Quests.move(q, s, "wake")
	Quests.step_back(s)
	check(s.square == "era" and not s.resolved, "the birth choice is open again")


func test_a_lost_fight_drops_its_step() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0), 0)
	walk_to(q, s, ["wake", "bandage", "village", "sc_home", "boar"])
	var n := s.steps.size()
	Quests.fail(q, s)
	check_eq(s.steps.size(), n - 1, "fail already stepped back: one step fewer to undo")


func test_a_chapters_events_and_outcomes_stay_the_same_when_it_is_restarted() -> void:
	var q: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == "prologue")[0]
	var s := SaveData.create()
	Quests.begin(q, s, rng(1))
	var events: Dictionary = s.events.duplicate()
	check(not events.is_empty(), "the chapter has ？ squares with events")
	for seed_value in [2, 3, 4]:
		Quests.begin(q, s, rng(seed_value))
		check_eq(s.events, events, "restarting deals the same events")
	var sid: String = events.keys()[0]
	var ev: Dictionary = GameData.get_db().events[events[sid]]
	s.square = sid
	var a := Quests.rolled_option(s, ev, rng(10))
	s.event_rolls = {}
	check_eq(Quests.rolled_option(s, ev, rng(99)), a, "…and the dice land the same")


func test_steps_store_only_what_changed_and_survive_a_save_file() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s, rng(3))
	Quests.resolve(q, s, rng(0), 0)
	var before: Array = []
	for i in 12:
		var opts: Array = Quests.next_options(Quests.view(q, s), s)
		if opts.is_empty():
			break
		before.append(_plain(s.snapshot()))
		Quests.move(q, s, opts[0]["id"])
		Quests.resolve(q, s, rng(0), 0)
	var full := JSON.stringify(before[0]).length() * before.size()
	var kept := JSON.stringify(s.steps).length()
	check(before.size() >= 8, "walked %d squares" % before.size())
	check(kept * 4 < full, "steps keep only the changes: %d bytes vs %d for whole snapshots" % [kept, full])
	var path := "user://test_steps.json"
	s.write(path)
	var back := SaveData.read(path)
	DirAccess.remove_absolute(path)
	for i in range(before.size() - 1, -1, -1):
		back.rewind_step()
		check_eq(_plain(back.snapshot()), before[i], "step %d back, after a save file" % i)
	check(back.steps.is_empty())


func test_a_cut_off_save_falls_back_to_its_tmp() -> void:
	var s := SaveData.create()
	s.merit = 7
	var path := "user://test_cut.json"
	s.write(path)
	DirAccess.rename_absolute(path, path + ".tmp")  # as if the game died between writing the .tmp and renaming it
	var back := SaveData.read(path)
	DirAccess.remove_absolute(path + ".tmp")
	check(back != null and back.merit == 7, "the .tmp is read when the save itself is missing")
