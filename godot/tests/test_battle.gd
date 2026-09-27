extends TestCase

const REF := [["machao", "zhangfei", "daqiao"], ["madai", "cav_n", "wangping", "spear_n", "mizhu"]]
const STARTER := [["cav_n", "spear_n", "archer_n"], []]
const SSR := [["guanyu", "zhaoyun", "diaochan"], ["machao", "madai", "cav_n", "zhangfei", "wangping", "daqiao", "mizhu"]]


func new_battle(scenario := "hulao", comp := REF, seed_value := 0) -> Battle:
	return Battle.start(scenario, party(comp[0], comp[1]), seed_value)


func test_one_shared_hp_bar_is_the_sum_of_leaders() -> void:
	var b := new_battle()
	var total := 0
	for u in b.leaders:
		total += u["leader"]["hp"]
	check_eq(b.party_hp, total)
	check_eq(b.party_max, total)


func test_leader_stats_are_5x_own_plus_troop() -> void:
	var p := party(REF[0], REF[1])
	var cav: Dictionary = p[1]
	check_eq(cav["card"]["id"], "machao")
	var at := 5 * int(cav["card"]["at"])
	for m in cav["members"]:
		at += m["at"]
	check_eq(cav["at"], at)
	check(p[0]["members"].is_empty(), "lord leads alone")


func test_enemy_hp_scales_with_party_size() -> void:
	var small := Battle.start("hulao", party(["machao"]), 0)
	check(new_battle().enemy["max_hp"] > small.enemy["max_hp"])


func test_ap_starts_at_2_gains_2_caps_at_6() -> void:
	var b := new_battle()
	check_eq(b.ap, 2)
	var seen: Array = []
	for _i in 4:
		b.party_hp = b.party_max
		b.end_round()
		seen.append(b.ap)
	check_eq(seen, [4, 6, 6, 6])


func test_each_leader_acts_once_per_round() -> void:
	var b := new_battle()
	b.act(0, "tuji")
	check(not b.can_act(0), "lord already acted")


func test_cumulative_skill_costs_one_more_each_use() -> void:
	var b := new_battle()
	var charge: Dictionary = b.db.skills["charge"]
	check_eq(b.cost(b.leaders[1], charge), 1)
	b.act(1, "charge")
	check_eq(b.cost(b.leaders[1], charge), 2)
	check_eq(b.ap, 1)


func test_once_per_battle_skill() -> void:
	var b := new_battle()
	b.ap = 6
	b.act(1, "xiliang")
	b.party_hp = b.party_max
	b.end_round()
	check(not b.usable(b.leaders[1], b.db.skills["xiliang"]))


func test_combo_adds_ten_percent_per_hit() -> void:
	var b := new_battle()
	b.db.battle["variance"] = 0.0
	b.combo = 0
	var d0 := b._dmg(1000, "magic")
	b.combo = 5
	check_eq(b._dmg(1000, "magic"), int(round(d0 * 1.5)))
	b.db.battle["variance"] = 0.2


func test_defend_cut_grows_with_consecutive_defends() -> void:
	var b := new_battle("hulao", REF, 2)
	var lines: Array = []
	for _i in 3:
		b.party_hp = b.party_max
		lines.append(b.defend()[0])
	check("30%" in lines[0] and "50%" in lines[1] and "70%" in lines[2], str(lines))
	b.party_hp = b.party_max
	b.end_round()
	check("30%" in b.defend()[0])


func test_turn_limit_loses() -> void:
	var b := new_battle()
	while b.result == "":
		b.party_hp = b.party_max
		b.end_round()
	check_eq(b.result, "lose")
	check_eq(b.round_no, b.scenario["turn_limit"])


func test_win_when_enemy_hp_zero() -> void:
	var b := new_battle()
	b.enemy["hp"] = 1
	b.act(0, "tuji")
	check_eq(b.result, "win")


func test_carry_in_and_out() -> void:
	var b := Battle.start("hulao", party(["machao"]), 0, 1000, {"machao": {"charge": 2}})
	check_eq(b.party_hp, b.party_max - 1000)
	check_eq(b.cost(b.leaders[1], b.db.skills["charge"]), 3)
	check_eq(b.carry_out()[0], 1000)


# ---- balance -------------------------------------------------------------------

func win_rate(scenario: String, comp: Array, n := 150) -> float:
	var wins := 0
	for s in n:
		if bot_fight(new_battle(scenario, comp, s)) == "win":
			wins += 1
	return float(wins) / n


func test_bandits_are_beatable_with_any_opening_choice() -> void:
	for hero in ["sunce", "zhouyu", "huanggai"]:
		check(win_rate("shanzei", [[hero], []]) > 0.7, hero)


func test_huangjin_is_beatable_with_starter_troops() -> void:
	check_between(win_rate("huangjin", STARTER), 0.3, 0.9, "huangjin starter")


func test_hulao_is_hard_for_naive_play() -> void:
	check_between(win_rate("hulao", REF), 0.15, 0.6, "hulao ref")


func test_better_cards_win_more() -> void:
	var a := win_rate("hulao", STARTER)
	var b := win_rate("hulao", REF)
	var c := win_rate("hulao", SSR)
	check(a < b and b < c, "%.2f < %.2f < %.2f" % [a, b, c])


func test_events_describe_what_happened() -> void:
	var b := new_battle()
	b.take_events()
	b.act(0, "tuji")
	var kinds: Array = b.take_events().map(func(e): return e["t"])
	check_eq(kinds.slice(0, 2), ["act", "hit"])
	b.party_hp = b.party_max
	b.end_round()
	var ev := b.take_events()
	check_eq(ev[0]["t"], "enemy_turn")
	check(ev.any(func(e): return e["t"] == "enemy_hit"), "enemy attacked")
	check(ev.any(func(e): return e["t"] == "round" and e["n"] == 2), "next round began")


func test_sunce_has_a_plain_skill_that_never_gets_dearer() -> void:
	var db := GameData.get_db()
	for cid in ["sunce", "sunce_zhong"]:
		var plain: Array = db.cards[cid]["skills"].filter(func(s): return not db.skills[s]["cumulative"] and db.skills[s]["uses"] == null)
		check(not plain.is_empty(), "%s needs a repeatable skill" % cid)


func test_fire_keeps_burning_on_the_enemy_turn() -> void:
	var b := Battle.start("boar", party(["zhouyu"]), 5)
	var i := -1
	for k in b.leaders.size():
		if b.leaders[k]["leader"]["card"]["id"] == "zhouyu":
			i = k
	b.act(i, "yehuo")
	check(b.enemy["burn_turns"] == 3 and b.enemy["burn_dmg"] > 0, "on fire")
	var before: int = b.enemy["hp"]
	b.take_events()
	b.end_round()
	var burns := b.take_events().filter(func(e): return e["t"] == "burn")
	check(burns.size() == 1 and b.enemy["hp"] < before, "burns before it acts")
	check_eq(b.enemy["burn_turns"], 2)
	check(db_skill_cumulative("yehuo"), "火攻 can be cast again (it just costs more)")


func db_skill_cumulative(sid: String) -> bool:
	return GameData.get_db().skills[sid]["cumulative"]
