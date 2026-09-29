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


func test_ap_starts_at_3_gains_3_caps_at_8() -> void:
	var b := new_battle()
	check_eq(b.ap, 3)
	var seen: Array = []
	for _i in 4:
		b.party_hp = b.party_max
		b.end_round()
		seen.append(b.ap)
	check_eq(seen, [6, 8, 8, 8])


func test_each_leader_acts_once_per_round() -> void:
	var b := new_battle()
	b.act(0, "tuji")
	check(not b.can_act(0), "lord already acted")


func test_cumulative_skill_costs_one_more_each_use() -> void:
	var b := new_battle("hulao", [["bingzhou"], []])  # 精兵 骑兵: has 冲锋
	var charge: Dictionary = b.db.skills["charge"]
	check_eq(b.cost(b.leaders[1], charge), 1)
	b.act(1, "charge")
	check_eq(b.cost(b.leaders[1], charge), 2)
	check_eq(b.ap, 2)


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
	var b := Battle.start("hulao", party(["bingzhou"]), 0, 1000, {"bingzhou": {"charge": 2}})
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
	check_between(win_rate("huangjin", STARTER), 0.05, 0.95, "huangjin starter")


func test_hulao_is_hard_for_naive_play() -> void:
	check_between(win_rate("hulao", REF), 0.05, 0.9, "hulao ref")


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


func test_young_sunce_strikes_for_1_ap_and_saves_xiaobawang() -> void:
	var f := GameData.get_db().build_fighter("sunce")
	check_eq(f["skills"], ["tingqiang", "xiaobawang"])
	var db := GameData.get_db()
	check(db.skills["tingqiang"]["cost"] == 1 and not db.skills["tingqiang"]["cumulative"], "挺枪: plain 1 AP")
	check(db.skills["xiaobawang"]["cumulative"], "小霸王 builds up")


func test_sunce_has_a_plain_skill_that_never_gets_dearer() -> void:
	var db := GameData.get_db()
	for cid in ["sunce", "sunce_zhong"]:
		var plain: Array = db.cards[cid]["skills"].filter(func(s): return not db.skills[s]["cumulative"] and db.skills[s]["uses"] == null)
		check(not plain.is_empty(), "%s needs a repeatable skill" % cid)


func test_fire_keeps_burning_on_the_enemy_turn() -> void:
	## 周瑜's 火攻 wears bosses down: the fire takes 10% of the enemy's full HP each turn
	var b := Battle.start("boar", party(["zhouyu"]), 5)
	var i := -1
	for k in b.leaders.size():
		if b.leaders[k]["leader"]["card"]["id"] == "zhouyu":
			i = k
	b.act(i, "yehuo")
	check(b.enemy["burn_turns"] == 3 and b.enemy["burn_dmg"] == int(round(b.enemy["max_hp"] * 0.1)), "on fire: 10% a turn")
	check_eq(b.enemy["hp"], b.enemy["max_hp"], "no damage up front")
	var before: int = b.enemy["hp"]
	b.take_events()
	b.end_round()
	var burns := b.take_events().filter(func(e): return e["t"] == "burn")
	check(burns.size() == 1 and b.enemy["hp"] < before, "burns before it acts")
	check_eq(b.enemy["burn_turns"], 2)
	check(not db_skill_cumulative("yehuo"), "火攻 can be cast again at the same cost")


func db_skill_cumulative(sid: String) -> bool:
	return GameData.get_db().skills[sid]["cumulative"]


func test_infantry_can_raise_shields() -> void:
	var db := GameData.get_db()
	check(db.build_fighter("danyang")["skills"].has("jushun"), "刀兵 troop skill")
	var b := Battle.start("boar", party(["danyang"]), 2)
	var i := b.leaders.size() - 1
	b.act(i, "jushun")
	check(is_equal_approx(b.guard_cut, 0.5), "举盾: half damage this round")


func test_every_enemy_has_a_card_and_bosses_are_rare() -> void:
	var db := GameData.get_db()
	for e in db.enemies.values():  # beasts (野猪) drop nothing
		check(e["card"] != "" or e["id"] in ["boar", "tiger"], "%s has a card" % e["id"])
	for eid in ["shuizei", "shuizei_main", "huangjin_yaodao", "huaxiong", "lvbu_hulao"]:
		check(db.cards[db.enemies[eid]["card"]]["rarity"] != "N", "%s drops a rare card" % eid)


func test_charged_moves_are_announced_then_land_through_defence() -> void:
	var b := Battle.start("hulao", party(["machao", "zhangfei"]), 11)
	b.enemy["charging"] = "天下无双"
	b.take_events()
	b.defend()
	var hits := b.take_events().filter(func(e): return e["t"] == "enemy_hit")
	check(not hits.is_empty() and hits[0]["move"] == "天下无双" and hits[0]["cut"] == 0.0, "pierces the defend")


func test_enemy_rage_heal_and_ap_drain() -> void:
	var b := Battle.start("boar", party(["machao"]), 1)
	var at0: float = b.enemy["at"]
	b.enemy["hp"] = b.enemy["max_hp"] / 3
	b.enemy["charging"] = "发狂"
	b.end_round()
	check(b.enemy["at"] > at0, "发狂 below half HP")
	var t := Battle.start("tiger", party(["machao"]), 1)
	t.enemy["charging"] = "虎啸"
	var ap_before := t.ap
	t.end_round()
	check(t.ap < ap_before + 2, "虎啸 takes AP")


func test_the_lord_throws_his_blade_and_has_no_boost() -> void:
	var f := GameData.get_db().build_lord("阿明")
	check_eq(f["skills"], ["tuji", "rengdao"])


func test_oil_on_the_fire_doubles_on_a_burning_enemy() -> void:
	var cold := Battle.start("boar", party(["zhouyu"]), 7)
	var hot := Battle.start("boar", party(["zhouyu"]), 7)
	hot.enemy["burn_turns"] = 2
	hot.enemy["burn_dmg"] = 1
	var i := cold.leaders.size() - 1
	cold.ap = 6
	hot.ap = 6
	cold.act(i, "huoshang")
	hot.act(i, "huoshang")
	var dc: int = cold.enemy["max_hp"] - cold.enemy["hp"]
	var dh: int = hot.enemy["max_hp"] - hot.enemy["hp"]
	check(dh > dc * 1.8 or hot.enemy["hp"] == 0, "x2 while it burns: %d vs %d" % [dh, dc])
	check_eq(GameData.get_db().skills["huoshang"]["uses"], 1)


func test_every_ultimate_costs_at_least_3_ap() -> void:
	for s in GameData.get_db().skills.values():
		if s["uses"] == 1 and s["effects"].any(func(e): return e["type"] in ["attack", "magic"]):
			check(s["cost"] >= 3, "%s costs %d" % [s["name"], s["cost"]])


func test_a_wind_up_lands_on_the_next_enemy_turn_not_this_one() -> void:
	for seed_value in 30:
		var b := Battle.start("hulao", party(["machao", "zhangfei"]), seed_value)
		b.party_hp = 999999
		b.party_max = 999999
		for _r in 3:
			b.take_events()
			b.end_round()
			var names: Array = b.take_events().filter(func(e): return e["t"] in ["enemy_charge", "enemy_hit"]).map(
				func(e): return "charge" if e["t"] == "enemy_charge" else e["move"])
			var k := names.find("charge")
			check(k < 0 or not names.slice(k).has("天下无双"), "seed %d: %s" % [seed_value, names])


func test_troop_basic_attacks_cost_1_ap() -> void:
	var db := GameData.get_db()
	for tid in db.troops:
		if tid == "lord":
			continue
		for sid in db.troops[tid]["skills"]:
			check(db.skills[sid]["cost"] >= 1, "%s: %s" % [tid, db.skills[sid]["name"]])


func test_defend_costs_ap() -> void:
	var b := new_battle("hulao", REF, 2)
	var need: int = b.defend_cost()
	check(need > 0, "defending costs AP")
	b.ap = need - 1
	var hp: int = b.party_hp
	var r0: int = b.round_no
	check("AP 不够" in b.defend()[0] and b.party_hp == hp and b.round_no == r0, "too little AP: nothing happens")
	b.ap = need
	b.defend()
	check(b.round_no == r0 + 1, "enough AP: the round ends")


func test_fire_attack_is_free_to_repeat() -> void:
	## 周瑜's 火攻: the same 1 AP every time, as often as you like — the fire itself doesn't stack
	var sk: Dictionary = GameData.get_db().skills["yehuo"]
	check(not sk["cumulative"] and sk["uses"] == null, "no rising cost, no use limit")
	var b := Battle.start("boar", party(["zhouyu"]), 5)
	var i := -1
	for k in b.leaders.size():
		if b.leaders[k]["leader"]["card"]["id"] == "zhouyu":
			i = k
	var ap0: int = b.ap
	b.act(i, "yehuo")
	check_eq(b.ap, ap0 - 1, "costs 1 AP")
	b.ap = ap0
	b.leaders[i]["acted"] = false
	b.act(i, "yehuo")
	check_eq(b.ap, ap0 - 1, "still 1 AP the second time")
	check_eq(b.enemy["burn_dmg"], int(round(b.enemy["max_hp"] * 0.1)), "one fire at a time: still 10% a turn")
	check_eq(b.enemy["burn_turns"], 3, "casting again only restarts the count")


func test_the_hero_can_throw_his_blade_every_turn() -> void:
	## 扔刀: 3 AP every time, no once-per-battle limit
	var sk: Dictionary = GameData.get_db().skills["rengdao"]
	check_eq(sk["cost"], 3)
	check(not sk["cumulative"] and sk["uses"] == null, "no rising cost, no use limit")


func test_heals_get_dearer_or_are_a_once_only_big_heal() -> void:
	## a heal is never free to spam: an everyday heal costs 1 AP more each use, a big heal (大招) is once per battle
	for sid in GameData.get_db().skills:
		var sk: Dictionary = GameData.get_db().skills[sid]
		if sk["effects"].any(func(e): return e["type"] == "heal"):
			check(sk["cumulative"] != (sk["uses"] == 1), sid + " should be cumulative or once-only")


func test_most_people_do_not_heal() -> void:
	## healing belongs to doctors, 后勤 and a few big once-only heals; the rest give statuses
	var db := GameData.get_db()
	var healers := 0
	var generals := 0
	for cid in db.cards:
		var c: Dictionary = db.cards[cid]
		if c.get("troop", "") == "lord" or not c.has("skills"):
			continue
		generals += 1
		if c["skills"].any(func(s): return db.skills[s]["effects"].any(func(e): return e["type"] == "heal")):
			healers += 1
	check(healers * 5 < generals, "%d of %d generals heal" % [healers, generals])
