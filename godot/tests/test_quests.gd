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
				targets.append(o["goto"])
			for t in targets:
				var ts: Dictionary = q["squares"][t]
				check(ts["x"] > s["x"] and absi(ts["y"] - s["y"]) <= 1, "%s -> %s" % [s["id"], t])


func test_cannot_move_before_resolving() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	check(Quests.next_options(q, s).is_empty())
	Quests.resolve(q, s, rng(0))
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["pick"])


func test_each_choice_walks_its_own_branch() -> void:
	for pick in 3:
		var q := quest(0)
		var s := SaveData.create()
		Quests.begin(q, s)
		Quests.resolve(q, s, rng(0))
		Quests.move(q, s, "pick")
		Quests.resolve(q, s, rng(0), pick)
		var branch: String = ["sc_talk", "zy_talk", "hg_talk"][pick]
		check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), [branch])
		check(s.has_card(["sunce", "zhouyu", "huanggai"][pick]))


func test_recover_square_clears_carried_wear() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.damage = 500
	s.carry_extra = {"lord": {"haoling": 1}}
	s.square = "spring"
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check(s.damage == 0 and s.carry_extra.is_empty())


func test_failing_restarts_but_keeps_choices_and_cards() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0))
	Quests.move(q, s, "pick")
	Quests.resolve(q, s, rng(0), 1)
	s.damage = 999
	Quests.fail(q, s)
	check(s.square == "wake" and s.damage == 0 and s.has_card("zhouyu"))
	Quests.resolve(q, s, rng(0))
	Quests.move(q, s, "pick")
	check(s.resolved, "earlier choice stands")
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["zy_talk"])


func test_recruit_offer_does_not_reroll() -> void:
	var q := quest(0)
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
		Quests.resolve(q, s, r, pick if sq["type"] == "choose" else (0 if not offered.is_empty() else -1))
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


func test_prologue_is_winnable_with_any_choice() -> void:
	for pick in 3:
		check(rate(0, [], pick) > 0.7, "pick %d" % pick)


func test_huangjin_quest_is_fair_with_a_starter_collection() -> void:
	check_between(rate(1, ["zhouyu", "archer_n", "strat_n", "wuguotai", "cav_n", "spear_n", "madai", "mizhu"]),
		0.3, 0.95, "huangjin")


func test_hulao_quest_needs_a_real_party_and_rest() -> void:
	var mid := ["machao", "zhangfei", "daqiao", "madai", "cav_n", "wangping", "spear_n", "mizhu"]
	check(rate(2, ["cav_n", "spear_n", "archer_n"]) < 0.1, "weak party")
	var rest := rate(2, mid, 0, 1)
	var greedy := rate(2, mid, 0, 0)
	check_between(rest, 0.15, 0.8, "rest before 吕布")
	check(greedy < rest, "resting beats grabbing the chest (%.2f vs %.2f)" % [greedy, rest])
