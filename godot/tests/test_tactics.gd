extends TestCase
## 军令 (v3): AutoPlayer.plan under a preset and per-card rows (docs/battle-v3.md)


func _charging_battle() -> Battle:
	var b := Battle.start("hulao", party(["machao", "zhouyu"]), 4, 0, {}, {}, false, {"enemy_tier": "boss"})
	b.enemy["charging"] = "天下无双"
	b._plan_intents()
	b.ap = 5
	b.party_hp = b.party_max
	return b


func test_the_smart_preset_interrupts_a_charge_first() -> void:
	var b := _charging_battle()
	var p := AutoPlayer.plan(b, {"preset": "smart", "rows": {}})
	check_eq(p["kind"], "act")
	check_eq(p.get("skill", ""), "rengdao", "扔刀 breaks the wind-up")


func test_the_aggro_preset_has_no_interrupt_rule() -> void:
	var b := _charging_battle()
	check(not AutoPlayer.preset(b, {"preset": "aggro"}).get("interrupt", true), "猛攻 does not go out of its way to break a charge")


func test_a_personal_row_wins_over_the_greedy_pick() -> void:
	var b := Battle.start("hulao", party(["machao"]), 4)
	b.ap = 8
	var rows := {"lord": [{"skill": "tuji", "cond": "always", "reserve": false}]}
	var p := AutoPlayer.plan(b, {"preset": "aggro", "rows": rows})
	check_eq([p["kind"], p.get("unit", -1), p.get("skill", "")], ["act", 0, "tuji"])


func test_a_row_waits_for_its_condition() -> void:
	var b := Battle.start("hulao", party(["machao"]), 4)
	b.ap = 8
	var rows := {"lord": [{"skill": "tuji", "cond": "enemy_stunned", "reserve": false}]}
	var p := AutoPlayer.plan(b, {"preset": "aggro", "rows": rows})
	check_eq(p, AutoPlayer.plan(b, {"preset": "aggro", "rows": {}}), "the enemy is not stunned: the row does not fire, the default pick plays")
	b.enemy["stunned"] = true
	p = AutoPlayer.plan(b, {"preset": "aggro", "rows": rows})
	check_eq(p.get("skill", ""), "tuji", "now it does")


func test_reserve_keeps_the_others_from_spending() -> void:
	var b := Battle.start("hulao", party(["machao", "zhouyu"]), 4)
	b.ap = 2
	var rows := {"lord": [{"skill": "rengdao", "cond": "always", "reserve": true}]}
	var p := AutoPlayer.plan(b, {"preset": "smart", "rows": rows})
	if p["kind"] == "act":
		var u: Dictionary = b.leaders[p["unit"]]
		check_eq(b.cost(u, b.db.skills[p["skill"]]), 0, "only free skills while saving for 扔刀: " + str(p))


func test_defends_against_a_charged_blow_it_cannot_break() -> void:
	var b := _charging_battle()
	b.leaders[0]["uses_left"]["rengdao"] = 0
	for u in b.leaders:
		u["acted"] = true
	b.ap = 4
	check(AutoPlayer.charged_blow_coming(b), "the plan opens with the charged blow")
	var p := AutoPlayer.plan(b, {"preset": "smart", "rows": {}})
	check_eq(p["kind"], "defend")
	check_eq(AutoPlayer.plan(b, {"preset": "aggro", "rows": {}})["kind"], "end", "猛攻 does not guard")


func test_auto_swap_brings_a_strategist_against_a_stance() -> void:
	var s := SaveData.new()
	s.owned = ["machao", "zhouyu"]
	s.party = ["machao"]
	var b := Battle.start("hulao", s.party_leaders(), 4, 0, {}, {}, false, {}, s.swap_roster())
	b.enemy["stance"] = {"name": "画戟架势", "power": 0.9, "turns": 1}
	b.ap = 1
	var p := AutoPlayer.plan(b, AutoPlayer.default_tactics())
	check_eq(p["kind"], "swap", "the default 中军 rows hold the 换人 rule: " + str(p))
	check_eq(p.get("card", ""), "zhouyu")
	check(AutoPlayer.plan(b, {"preset": "smart", "party_rows": [], "rows": {}})["kind"] != "swap", "no 中军 row: no swap")


func test_a_party_row_swaps_out_a_spent_leader() -> void:
	var s := SaveData.new()
	s.owned = ["machao", "zhaoyun"]
	s.party = ["machao"]
	var b := Battle.start("hulao", s.party_leaders(), 4, 0, {}, {}, false, {}, s.swap_roster())
	var slot := 1
	for sk in b.skills_of(b.leaders[slot]):
		if sk["uses"] == 1 or sk["per_battle"]:
			b.leaders[slot]["uses_left"][sk["id"]] = 0
	b.ap = 3
	var t := {"preset": "aggro", "party_rows": [{"act": "swap_fresh", "cond": "leader_spent", "cond2": "always"}], "rows": {}}
	var p := AutoPlayer.plan(b, t)
	check_eq([p["kind"], p.get("unit", -1), p.get("card", "")], ["swap", slot, "zhaoyun"])


func test_a_party_row_with_two_conditions_needs_both() -> void:
	var b := Battle.start("hulao", party(["machao"]), 4)
	b.ap = 4
	var t := {"preset": "aggro", "party_rows": [{"act": "defend", "cond": "enemy_charging", "cond2": "boss_fight"}], "rows": {}}
	b.enemy["charging"] = "天下无双"
	check(AutoPlayer.plan(b, t)["kind"] != "defend", "charging but not a boss fight")
	b.mods["enemy_tier"] = "boss"
	check_eq(AutoPlayer.plan(b, t)["kind"], "defend")


func test_a_troop_row_picks_the_leaders_own_skill_of_that_kind() -> void:
	var b := Battle.start("hulao", party(["machao"]), 4)
	b.ap = 8
	var troop: String = b.leaders[1]["leader"]["card"]["troop"]
	var t := {"preset": "aggro", "troop_rows": {troop: [{"act": "basic", "cond": "always"}]}, "rows": {}}
	var p := AutoPlayer.plan(b, t)
	check_eq(p.get("unit", -1), 1, str(p))
	check(AutoPlayer.skill_kind(b.db.skills[p["skill"]]).has("basic"), "a 普通技")
	var t2 := {"preset": "aggro", "troop_rows": {troop: [{"act": "basic", "cond": "always"}]},
		"rows": {str(b.leaders[1]["leader"]["card"]["id"]): [{"skill": b.leaders[1]["leader"]["card"]["skills"][-1], "cond": "always"}]}}
	b.ap = 8
	check_eq(AutoPlayer.plan(b, t2).get("skill", ""), b.leaders[1]["leader"]["card"]["skills"][-1], "the card's own row comes before its troop's")


func test_every_condition_and_preset_is_known() -> void:
	var cfg: Dictionary = GameData.get_db().battle["tactics"]
	var b := Battle.start("hulao", party(["machao"]), 1)
	for cond in cfg["conditions"]:
		AutoPlayer.cond_holds(b, cond)  # (no crash; an unknown id would always be false)
	check(cfg["conditions"].has("always") and cfg["presets"].has("smart"), "the defaults exist")
	for pid in cfg["presets"]:
		for key in ["name", "interrupt", "defend_charge", "reserve", "ults"]:
			check(cfg["presets"][pid].has(key), "%s has %s" % [pid, key])


func test_a_whole_fight_under_tactics_ends() -> void:
	var b := Battle.start("hulao", party(["machao", "zhouyu", "zhaoyun"]), 9, 0, {}, {}, false, {"enemy_tier": "boss"})
	var t := AutoPlayer.default_tactics()
	t["rows"] = {"lord": [{"skill": "rengdao", "cond": "enemy_charging", "reserve": true}]}
	var guard := 0
	while b.result == "" and guard < 600:
		guard += 1
		var p := AutoPlayer.plan(b, t)
		match str(p["kind"]):
			"act":
				b.act(p["unit"], p["skill"])
			"swap":
				b.swap(p["unit"], p["card"])
			"defend":
				b.defend()
			_:
				b.end_round()
	check(b.result != "", "the fight ends by itself")


func test_the_default_tactics_are_valid() -> void:
	## battle.json tactics.defaults (user call: main characters, troops and the whole army): every row names a known condition
	## and act, a 武将 row names one of that card's own skills, and no default row is unconditional (the preset plays ordinary turns)
	var db := GameData.get_db()
	var cfg: Dictionary = db.battle["tactics"]
	var d := AutoPlayer.default_tactics()
	check(d["party_rows"].size() <= int(cfg["max_rows"]), "中军 fits")
	for row in d["party_rows"]:
		check(cfg["party_acts"].has(row["act"]), "中军 act %s" % row["act"])
		check(cfg["conditions"].has(row["cond"]) and cfg["conditions"].has(row["cond2"]), "中军 conds %s" % str(row))
		check(row["cond"] != "always", "中军 row has a condition")
	for tid in d["troop_rows"]:
		check(db.troops.has(tid), "troop %s" % tid)
		check(d["troop_rows"][tid].size() <= int(cfg["max_rows"]), "%s fits" % tid)
		for row in d["troop_rows"][tid]:
			check(cfg["troop_acts"].has(row["act"]), "%s act %s" % [tid, row["act"]])
			check(cfg["conditions"].has(row["cond"]) and cfg["conditions"].has(row["cond2"]), "%s conds" % tid)
			check(row["cond"] != "always", "%s row has a condition" % tid)
	check(d["rows"].size() >= 10, "the main characters have rows")
	for cid in d["rows"]:
		check(db.cards.has(cid), "card %s" % cid)
		for row in d["rows"][cid]:
			check(db.cards[cid]["skills"].has(row["skill"]), "%s owns %s" % [cid, row["skill"]])
			check(cfg["conditions"].has(row["cond"]) and cfg["conditions"].has(row["cond2"]), "%s conds" % cid)
			check(row["cond"] != "always", "%s row has a condition" % cid)


func test_saved_tactics_win_over_the_defaults_per_troop_and_card() -> void:
	var d := AutoPlayer.default_tactics()
	var saved := {"preset": "aggro", "troop_rows": {"logistics": []}, "rows": {"machao": [{"skill": "xiliang", "cond": "boss_fight", "cond2": "always"}]}}
	var t := AutoPlayer.with_defaults(saved)
	check_eq(t["preset"], "aggro", "the saved preset")
	check(t["troop_rows"]["logistics"].is_empty(), "a troop the player cleared stays cleared")
	check_eq(t["troop_rows"]["strategist"], d["troop_rows"]["strategist"], "an untouched troop keeps its default")
	check_eq(t["rows"]["machao"][0]["cond"], "boss_fight", "the player's own card row")
	check_eq(t["rows"]["zhaoyun"], d["rows"]["zhaoyun"], "an untouched card keeps its default")
	check_eq(t["party_rows"], d["party_rows"], "no saved 中军 = the default 中军")
