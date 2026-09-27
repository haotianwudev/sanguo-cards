extends TestCase


func rng(seed_value: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r


func quest(i: int) -> Dictionary:
	return GameData.get_db().quests[i]


func test_maps_only_move_forward_one_row_at_a_time() -> void:
	for q in GameData.get_db().quests:
		for s in q["squares"].values():
			var targets: Array = s["next"].duplicate()
			for o in s["choose"]:
				if not o["locked"]:
					targets.append(o["goto"])
			for t in targets:
				var ts: Dictionary = q["squares"][t]
				check(ts["x"] > s["x"] and absi(ts["y"] - s["y"]) <= 1, "%s -> %s" % [s["id"], t])


func test_story_runs_prologue_then_dongzhuo() -> void:
	check_eq(GameData.get_db().quests.map(func(q): return q["id"]), ["prologue", "taodong"])


func walk_to(q: Dictionary, s: SaveData, ids: Array, choice := 0) -> void:
	for sid in ids:
		Quests.move(q, s, sid)
		Quests.resolve(q, s, rng(0), choice)


func test_cannot_move_before_resolving() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	check(Quests.next_options(q, s).is_empty())
	Quests.resolve(q, s, rng(0), 0)
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["wake"])


func test_the_north_is_not_open_yet() -> void:
	var opts: Array = quest(0)["squares"]["era"]["choose"]
	check(not opts[0]["locked"] and opts[1]["locked"] and opts[0]["card"] == "")


func test_each_plan_walks_its_own_branch_and_both_rescue_her() -> void:
	for pick in 2:
		var q := quest(0)
		var s := SaveData.create()
		Quests.begin(q, s)
		Quests.resolve(q, s, rng(0), 0)
		walk_to(q, s, ["wake", "village", "raid"])
		Quests.move(q, s, "plan")
		Quests.resolve(q, s, rng(0), pick)
		var branch: Array = [["sc_gate", "sc_hall"], ["zy_lure", "zy_hall"]][pick]
		check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), [branch[0]])
		check(s.has_card(["sunce", "zhouyu"][pick]) and not s.has_card(["zhouyu", "sunce"][pick]), "only the planner joins first")
		walk_to(q, s, branch + ["rescue"])
		check(s.has_card("sunce") and s.has_card("zhouyu") and s.has_card("wuguotai"), "all three after the rescue")
		check(not s.has_card("huanggai"))


func test_recover_square_clears_carried_wear() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.damage = 500
	s.carry_extra = {"lord": {"haoling": 1}}
	s.square = "camp"
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check(s.damage == 0 and s.carry_extra.is_empty())


func test_failing_restarts_but_keeps_choices_and_cards() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0), 0)
	walk_to(q, s, ["wake", "village", "raid"])
	Quests.move(q, s, "plan")
	Quests.resolve(q, s, rng(0), 1)
	s.damage = 999
	Quests.fail(q, s)
	check(s.square == "era" and s.damage == 0 and s.has_card("zhouyu"))
	check(s.resolved, "the birthplace choice stands")
	walk_to(q, s, ["wake", "village", "raid"])
	Quests.move(q, s, "plan")
	check(s.resolved, "earlier plan stands")
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["zy_lure"])


func test_an_old_save_on_a_removed_square_restarts_the_quest() -> void:
	var s := SaveData.create()
	s.quest = "prologue"
	s.square = "hg_talk"
	Quests.ensure_started(s)
	check_eq(s.square, "era")


func test_recruit_offer_does_not_reroll() -> void:
	var q := quest(1)  # 讨伐董卓: a normal recruit square (the prologue's only offers soldiers)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "heroes"
	s.resolved = false
	var first: Array = Quests.offer(q, s, rng(1)).map(func(c): return c["id"])
	var again: Array = Quests.offer(q, s, rng(99)).map(func(c): return c["id"])
	check_eq(first, again)
	var got := Quests.resolve(q, s, rng(0), 2)
	check_eq(got.map(func(c): return c["id"]), [first[2]])
	check(not s.owned.has(first[0]) and not s.owned.has(first[1]))


# ---- whole-quest balance (HP carries between battles) --------------------------------

func play_quest(q: Dictionary, s: SaveData, pick: int, fork: int, seed_value: int) -> bool:
	var r := rng(seed_value)
	Quests.begin(q, s)
	for _step in 100:
		var sq := Quests.here(q, s)
		if sq["type"] == "battle" and not s.resolved:
			s.party = s.auto_party()
			var b := Battle.start(sq["battle"], s.party_leaders(), r.randi(), s.damage, s.carry_extra, s.carry_uses)
			if bot_fight(b) != "win":
				return false
			var carry := b.carry_out()
			s.damage = carry[0]
			s.carry_extra.merge(carry[1], true)
			s.carry_uses.merge(carry[2], true)
			var chest := s.chest_after_battle(r, b.overkill, sq["boss"])
			if not chest.is_empty():
				s.take(chest[0]["id"])
		var offered := Quests.offer(q, s, r)
		var choice := 0 if not offered.is_empty() else -1
		if sq["type"] == "choose":
			choice = pick if pick < sq["choose"].size() and not sq["choose"][pick]["locked"] else 0
		Quests.resolve(q, s, r, choice)
		var opts := Quests.next_options(q, s)
		if opts.is_empty():
			Quests.complete(q, s)
			return true
		var idx: int = fork if fork >= 0 and fork < opts.size() else r.randi_range(0, opts.size() - 1)
		Quests.move(q, s, opts[idx]["id"])
	return false


func rate(qi: int, owned: Array, pick := 0, fork := -1, n := 60) -> float:
	var wins := 0
	for seed_value in n:
		var s := SaveData.new()
		s.owned = owned.duplicate()
		if play_quest(quest(qi), s, pick, fork, seed_value):
			wins += 1
	return float(wins) / n


func test_chapter_one_is_winnable_with_either_plan() -> void:
	for pick in 2:
		check_between(rate(0, [], pick), 0.4, 0.95, "pick %d" % pick)


func campaign_rate(pick: int, fork: int, n := 60) -> float:
	## Play the prologue, then chapter 1 with whatever the prologue left you.
	var wins := 0
	for seed_value in n:
		var s := SaveData.create()
		if play_quest(quest(0), s, pick, -1, seed_value) and play_quest(quest(1), s, 0, fork, seed_value + 1000):
			wins += 1
	return float(wins) / n


func test_dongzhuo_chapter_is_fair_after_chapter_one() -> void:
	check_between(campaign_rate(1, -1), 0.3, 0.95, "zhouyu plan, random forks")


func test_dongzhuo_chapter_is_too_hard_alone() -> void:
	check(rate(1, []) < 0.1, "lord alone")


func test_chapter_one_only_gives_local_soldiers_and_prisoners() -> void:
	var q := quest(0)
	var allowed := ["danyang", "changsha", "shuizei_bing", "huangjin_nanxia"]
	var s := SaveData.create()
	Quests.begin(q, s)
	for sid in ["vault", "draft"]:
		s.square = sid
		s.resolved = false
		s.offer = []
		var ids: Array = Quests.offer(q, s, rng(3)).map(func(c): return c["id"])
		if sid == "draft":
			check(ids.all(func(c): return c in ["danyang", "changsha"]), "征兵 only finds locals")
		check(not ids.is_empty() and ids.all(func(c): return c in allowed), "%s %s" % [sid, ids])
	var chest := s.chest_after_battle(rng(1), 0.0, true, q["soldier_pool"])
	check(chest.all(func(c): return c["id"] in allowed), "battle chest")
	check_eq(q["squares"]["north"]["cards"], ["danyang", "shuizei_bing", "huangjin_nanxia"], "freed men and prisoners")


func test_changsha_is_weaker_than_danyang() -> void:
	var db := GameData.get_db()
	var cs := db.build_fighter("changsha")
	var dy := db.build_fighter("danyang")
	check(cs["at"] < dy["at"] and cs["hp"] < dy["hp"], "长沙刀兵 %d/%d vs 丹阳兵 %d/%d" % [cs["at"], cs["hp"], dy["at"], dy["hp"]])
