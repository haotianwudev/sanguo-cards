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
