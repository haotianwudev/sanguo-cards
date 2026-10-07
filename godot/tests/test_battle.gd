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
	check_eq(b.cost(b.leaders[1], charge), 2)
	b.act(1, "charge")
	check_eq(b.cost(b.leaders[1], charge), 3)
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
	var b := Battle.start("hulao", party(["bingzhou"]), 0, 1000, {"bingzhou": {"charge": 2}})
	check_eq(b.party_hp, b.party_max - 1000)
	check_eq(b.cost(b.leaders[1], b.db.skills["charge"]), 4)
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
		var plain: Array = db.build_fighter(cid)["skills"].filter(func(s): return not db.skills[s]["cumulative"] and db.skills[s]["uses"] == null)
		check(not plain.is_empty(), "%s needs a repeatable skill" % cid)


func test_fire_keeps_burning_on_the_enemy_turn() -> void:
	## 周瑜's 火攻 wears bosses down: the fire takes 10% of the enemy's full HP each turn
	var b := Battle.start("boar", party(["zhouyu"]), 5)
	var i := -1
	for k in b.leaders.size():
		if b.leaders[k]["leader"]["card"]["id"] == "zhouyu":
			i = k
	b.act(i, "yehuo")
	check(b.enemy["burn_turns"] == 3 and is_equal_approx(b.enemy["burn_pct"], 0.1), "on fire: 10% of what is left, a turn")
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


func test_each_troop_has_its_own_plain_move() -> void:
	## docs/skills.md §3: 骑 2 hits of 0.5, 枪 a 2 AP heavy thrust, 弓 a free single arrow, 策 gives AP (no attack),
	## 后勤 heals; the rest are a plain 1 AP strike
	var db := GameData.get_db()
	var plain := {}
	for tid in db.troops:
		plain[tid] = db.skills[db.default_kit(tid)[0]]
	check_eq(plain["cavalry"]["cost"], 1)
	check_eq(int(plain["cavalry"]["effects"][0]["hits"]), 2)
	check_eq(plain["spear"]["cost"], 2)
	check(float(plain["spear"]["effects"][0]["power"]) >= 2.0, "刺击 is the heavy one")
	check_eq(plain["archer"]["cost"], 0)
	check(plain["archer"]["effects"][0].get("pierce", false), "射击 pierces")
	check(not plain["strategist"]["effects"].any(func(e): return e["type"] in ["attack", "magic"]), "策士 plain move has no attack")
	check(plain["logistics"]["effects"][0]["type"] == "heal", "后勤 heals")
	for tid in ["infantry", "bandit"]:
		check_eq(plain[tid]["cost"], 1, tid)


func test_only_the_hero_and_archers_attack_for_free() -> void:
	var db := GameData.get_db()
	for sid in db.skills:
		var sk: Dictionary = db.skills[sid]
		if sk["cost"] == 0 and sk["effects"].any(func(e): return e["type"] in ["attack", "magic"]):
			check(sk["free"], "%s attacks for 0 AP without being marked free" % sid)
		if sk["cost"] == 0:
			check(not sk["effects"].any(func(e): return e["type"] == "ap" or (e["type"] == "boost" and e.get("target", "") == "all")),
				"%s: free AP / team boost" % sid)


func _attack_value(sk: Dictionary) -> float:
	## docs/skills.md §4: total power of an attack skill, with its riders folded into power (weights: cards.json skill_budget)
	var w: Dictionary = GameData.get_db().skill_budget["weights"]
	var v := 0.0
	for e in sk["effects"]:
		match e["type"]:
			"attack", "magic":
				v += (float(e["power"]) + float(w["combo_layers"]) * float(e.get("per_combo", 0.0))) * int(e.get("hits", 1))
			"guard":
				v += float(e["cut"]) * float(w["guard"])
			"break":
				v += float(e["amount"]) * int(e["turns"]) * float(w["break"])
			"stun":
				v += float(e["chance"]) * float(w["stun"])
			"counter":
				v += float(e["power"]) * float(w["counter"])
			"burn":
				v += float(e.get("pct", 0.0)) * int(e["turns"]) * float(w["burn_pct"]) + float(e.get("power", 0.0)) * int(e["turns"])
			"boost":
				v += float(w["boost_all"]) if e.get("target", "") == "all" else float(w["boost_self"])
			"ap":
				v += float(e["amount"]) * float(w["ap"])
	return v


func test_the_dearer_the_attack_the_more_each_ap_buys() -> void:
	## the floors, 大招 multiplier and tolerance all live in cards.json skill_budget; `special` skills are exempt
	var cfg: Dictionary = GameData.get_db().skill_budget
	var tiers: Dictionary = cfg["rate_by_ap"]
	for k in range(2, tiers.size() + 1):
		check(float(tiers[str(k)]) > float(tiers[str(k - 1)]), "%d AP buys more per AP than %d AP" % [k, k - 1])
	for sid in GameData.get_db().skills:
		var sk: Dictionary = GameData.get_db().skills[sid]
		if sk["special"]:
			continue
		if not sk["effects"].any(func(e): return e["type"] in ["attack", "magic"]) or not tiers.has(str(sk["cost"])) \
				or sk["effects"].any(func(e): return int(e.get("hits", 1)) > 1):  # multi-hit skills follow multi_hit_rate
			continue
		var lo: float = float(tiers[str(sk["cost"])]) * sk["cost"] * (float(cfg["ultimate_mult"]) if sk["uses"] == 1 else 1.0) * float(cfg["tolerance"])
		check(_attack_value(sk) >= lo, "%s (%d AP) is worth %.2f, wants >= %.2f" % [sk["name"], sk["cost"], _attack_value(sk), lo])


func test_finishers_hit_harder_the_bigger_the_combo() -> void:
	var b := Battle.start("hulao", party(["cav_n"]), 3)
	b.db.battle["variance"] = 0.0
	var u: Dictionary = b.leaders[1]
	var eff := {"type": "attack", "power": 1.0, "per_combo": 0.5}
	b.combo = 0
	var hp0: int = b.enemy["hp"]
	b._apply(u, eff, 1.0)
	var d0: int = hp0 - b.enemy["hp"]
	b.combo = 4
	var hp1: int = b.enemy["hp"]
	b._apply(u, eff, 1.0)
	var d4: int = hp1 - b.enemy["hp"]
	check(d4 > d0 * 2.4, "收尾: combo 4 hits %d vs %d" % [d4, d0])
	b.db.battle["variance"] = 0.2


func test_piercing_ignores_phys_resist() -> void:
	var b := Battle.start("hulao", party(["cav_n"]), 3)
	b.db.battle["variance"] = 0.0
	b.enemy["data"]["phys_resist"] = 0.5
	var plain := b._dmg(1000, "attack")
	var pierced := b._dmg(1000, "attack", true)
	check_eq(pierced, plain * 2)
	b.db.battle["variance"] = 0.2


func test_counter_answers_every_enemy_hit_this_round() -> void:
	var b := Battle.start("hulao", party(["spear_n"]), 3)
	b.db.battle["variance"] = 0.0
	var u: Dictionary = b.leaders[1]
	b._apply(u, {"type": "counter", "power": 0.5}, 1.0)
	check_eq(b.counters.size(), 1)
	b.take_events()
	var before: int = b.enemy["hp"]
	b.end_round()
	var counters := b.take_events().filter(func(e): return e["t"] == "counter")
	check(counters.size() >= 1 and b.enemy["hp"] < before, "the enemy's blows are answered")
	check(b.counters.is_empty(), "the stance ends with the round")
	b.db.battle["variance"] = 0.2


func test_sacrifice_costs_hp_but_never_kills() -> void:
	var b := Battle.start("hulao", party(["cav_n"]), 3)
	var hp0 := b.party_hp
	b._apply(b.leaders[1], {"type": "hurt", "pct": 0.1}, 1.0)
	check_eq(b.party_hp, hp0 - int(round(b.party_max * 0.1)))
	b._apply(b.leaders[1], {"type": "hurt", "pct": 5.0}, 1.0)
	check_eq(b.party_hp, 1)


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
	check(is_equal_approx(b.enemy["burn_pct"], 0.1), "one fire at a time: still 10% a turn")
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


func test_regen_event_has_what_the_screen_reads() -> void:
	## the screen reads ev["amt"] for enemy_heal; 词缀·再生 once sent "amount" and froze the battle on a stunned enemy
	var b := Battle.start("dagu", party(["zhouyu"]), 3)
	b.enemy["regen"] = 0.04
	b.enemy["hp"] -= 1000
	b.enemy["stunned"] = true
	b.take_events()
	b.end_round()
	var heals: Array = b.take_events().filter(func(e): return e["t"] == "enemy_heal")
	check(not heals.is_empty(), "再生 heals")
	for e in heals:
		check(e.has("amt") and e.has("hp"), "enemy_heal carries amt and hp")


func test_skill_power_is_the_per_ap_rate_times_its_cost() -> void:
	## cards.json gives an attack its `rate` (power per AP); the loaded per-hit power × hits is rate × AP cost
	var db := GameData.get_db()
	var seen := 0
	for sid in db.skills:
		var sk: Dictionary = db.skills[sid]
		for e in sk["effects"]:
			if e.has("rate"):
				seen += 1
				check(absf(float(e["power"]) * int(e.get("hits", 1)) - float(e["rate"]) * sk["cost"]) < 0.0001, sid)
	check(seen > 50, "most skills are rate-based")
	var throw: Dictionary = db.skills["rengdao"]["effects"][0]
	check_eq(float(throw["power"]), float(throw["rate"]) * 3.0, "the hero's 3 AP throw")


func test_a_burn_takes_a_share_of_current_hp_and_never_kills() -> void:
	var b := Battle.start("boar", party(["zhouyu"]), 5)
	b.enemy["burn_turns"] = 3
	b.enemy["burn_pct"] = 0.1
	b.enemy["hp"] = 1000
	b.take_events()
	b.end_round()
	var burn: Dictionary = b.take_events().filter(func(e): return e["t"] == "burn")[0]
	check_eq(burn["dmg"], 100, "10% of the 1000 it has left")
	b.enemy["burn_turns"] = 2
	b.enemy["hp"] = 1
	b.end_round()
	check_eq(b.enemy["hp"], 1, "a fire leaves the last HP")


func test_a_helper_boosts_a_random_teammate_who_has_not_acted() -> void:
	var b := Battle.start("hulao", party(["liaohua", "cav_n"]), 4)
	var helper := -1
	for k in b.leaders.size():
		if b.leaders[k]["leader"]["card"]["id"] == "liaohua":
			helper = k
	b.take_events()
	b.act(helper, "jiangling")
	var boosted := b.leaders.filter(func(u): return u["boosted"])
	check_eq(boosted.size(), 1, "exactly one teammate is boosted")
	check(boosted[0] != b.leaders[helper] and not boosted[0]["acted"], "not the helper, and one who has yet to act")
	for u in b.leaders:
		u["acted"] = true
	b.leaders[helper]["boosted"] = false
	for u in b.leaders:
		u["boosted"] = false
	var log: Array = b._apply(b.leaders[helper], {"type": "boost", "target": "random_idle"}, 1.0)
	check(b.leaders.all(func(u): return not u["boosted"]), "nobody left to boost: " + str(log))


func _swap_battle() -> Battle:
	var s := SaveData.new()
	s.owned = ["machao", "madai", "mayunlu"]
	s.party = ["machao"]
	var b := Battle.start("hulao", s.party_leaders(), 1, 0, {}, {}, false, {}, s.swap_roster())
	b.round_no = b.swap_from_round()  # the first rounds are closed to swapping (see the test below)
	return b


func _slot_of(b: Battle, cid: String) -> int:
	for k in b.leaders.size():
		if b.leaders[k]["leader"]["card"]["id"] == cid:
			return k
	return -1


func test_swapping_costs_ap_and_the_card_that_left_cannot_return() -> void:
	var b := _swap_battle()
	var slot := _slot_of(b, "machao")
	b.ap = 6
	b.party_hp = b.party_max
	check(b.can_swap(slot), "AP and a same-troop card to bring in")
	var ap0 := b.ap
	var at0: int = b.leaders[slot]["leader"]["at"]
	var max0 := b.party_max
	var hp0 := b.party_hp
	b.swap(slot, "madai")
	check_eq(b.ap, ap0 - b.swap_cost(), "swap_ap")
	check_eq(b.leaders[slot]["leader"]["at"], at0, "the slot keeps its attack")
	check(b.party_max == max0 and b.party_hp == hp0, "and the shared HP is untouched")
	check_eq(b.leaders[slot]["leader"]["card"]["id"], "madai")
	check(not b.can_act(slot), "the newcomer waits for next round")
	check(not b.can_swap(slot), "one swap a round")
	b.end_round()
	b.ap = 6
	check(b.can_act(slot), "…and acts then")
	var back := b.swap_options(slot).map(func(ld): return ld["card"]["id"])
	check(back.has("mayunlu") and not back.has("machao") and not back.has("madai"), "machao is out for the battle: " + str(back))


func test_no_swapping_in_the_first_two_rounds() -> void:
	var b := _swap_battle()
	var slot := _slot_of(b, "machao")
	b.ap = 6
	b.round_no = 1
	check(not b.can_swap(slot), "round 1")
	b.round_no = 2
	check(not b.can_swap(slot), "round 2")
	b.round_no = 3
	check(b.can_swap(slot), "round 3")


func test_swap_can_bring_in_another_troop_but_never_a_troop_already_leading() -> void:
	var s := SaveData.new()
	s.owned = ["machao", "zhaoyun", "madai", "zhangfei", "daqiao"]
	s.party = ["machao", "zhaoyun"]
	var b := Battle.start("hulao", s.party_leaders(), 1, 0, {}, {}, false, {}, s.swap_roster())
	b.round_no = b.swap_from_round()
	var slot := _slot_of(b, "machao")
	var troops := b.swap_options(slot).map(func(ld): return ld["card"]["troop"])
	check(troops.has("cavalry") and troops.has("logistics"), "another cavalry card, or a card of a troop nobody leads: " + str(troops))
	check(not troops.has("spear"), "zhaoyun already leads the spear troop")
	check_eq(b.swap_options(0).size(), 0, "the lord has no stand-in")
	b.ap = 6
	b.swap(slot, "daqiao")
	check_eq(b.leaders[slot]["leader"]["card"]["troop"], "logistics", "the slot is a logistics leader now")
	var next_troops := b.swap_options(slot).map(func(ld): return ld["card"]["troop"])
	check(next_troops.has("cavalry") and not next_troops.has("spear"), "and the cavalry slot it left can be taken again by cavalry")


func test_cleanse_lifts_confusion_fire_and_drained_ap() -> void:
	var b := Battle.start("hulao", party(["daqiao"]), 2)
	b.leaders[1]["confused"] = true
	b.leaders[0]["confuse_next"] = true
	b.party_burn = {"dmg": 100, "turns": 2}
	b.ap_drain = 2
	check(not b.can_act(1), "confused leaders cannot act")
	var log: Array = b._apply(b.leaders[1], {"type": "cleanse"}, 1.0)
	check(not b.leaders[1]["confused"] and not b.leaders[0]["confuse_next"], "confusion gone")
	check_eq(b.party_burn["turns"], 0, "fire out")
	check_eq(b.ap_drain, 0, "AP no longer drained")
	check(str(log).contains("解除"), str(log))
	check(GameData.get_db().skills["jiedu"]["effects"][0]["type"] == "cleanse", "解毒 is the cleanse skill")


func _affix_battle(afx: Dictionary) -> Battle:
	return Battle.start("hulao", party(["cav_n", "spear_n"]), 9, 0, {}, {}, false, {"affix": afx})


func test_status_affixes_put_a_status_on_us_each_enemy_turn() -> void:
	var fire := _affix_battle({"name": "炎毒", "burn_party": 0.08, "turns": 3})
	fire.end_round()
	check(fire.party_burn["turns"] > 0 and fire.party_burn["dmg"] == int(round(fire.party_max * 0.08)), "8% of the whole bar a turn")
	var drain := _affix_battle({"name": "夺气", "ap_drain": 1})
	drain.end_round()
	check(drain.ap < drain.ap_max() and drain.ap <= 3 + 3 - 1, "AP taken off the next round: %d" % drain.ap)
	var haze := _affix_battle({"name": "迷魂", "confuse": 1.0})
	haze.end_round()
	check(haze.leaders.any(func(u): return u["confused"]), "a leader is confused")
	var calm := _affix_battle({"name": "迷魂", "confuse": 1.0})
	calm.mods["calm"] = 1
	calm.end_round()
	check(not calm.leaders.any(func(u): return u["confused"]), "calm resists it")


func test_every_elite_and_boss_can_put_a_status_on_us() -> void:
	## confuse, burn or AP drain: the tougher the enemy, the more it does besides hit
	var db := GameData.get_db()
	var checked := {}
	for q in db.quests:
		for sid in q["squares"]:
			var sq: Dictionary = q["squares"][sid]
			if (sq["boss"] or sq["elite"]) and sq["battle"] != "":
				var eid: String = db.scenarios[sq["battle"]]["enemy"]
				if checked.has(eid):
					continue
				checked[eid] = true
				check(db.enemies[eid]["moves"].any(func(m): return m.has("confuse") or m.has("ap_drain") or m.has("burn_party")),
					"%s (%s) has no status move" % [eid, sid])
	check(checked.size() > 30, "found the elites and bosses")


func test_a_confused_leader_cannot_be_swapped_out() -> void:
	var b := _swap_battle()
	var slot := _slot_of(b, "machao")
	b.ap = 6
	check(b.can_swap(slot), "baseline")
	b.leaders[slot]["confused"] = true
	check(not b.can_swap(slot), "confused now")
	b.leaders[slot]["confused"] = false
	b.leaders[slot]["confuse_next"] = true
	check(not b.can_swap(slot), "confused next round")


func test_war_spirit_stacks_four_layers_lifts_attack_and_cuts_damage_then_fades() -> void:
	var b := Battle.start("hulao", party(["guojia"]), 6)
	var slot := _slot_of(b, "guojia")
	var eff := {"type": "buff", "atk": 0.1, "def": 0.08, "max": 4, "turns": 3}
	for _i in 6:
		b._apply(b.leaders[slot], eff, 1.0)
	check_eq(b.buff["layers"], 4, "four layers at most")
	check(is_equal_approx(b.buff["atk"], 0.4) and is_equal_approx(b.buff["def"], 0.32), "0.4 attack, 0.32 cut")
	b.db.battle["variance"] = 0.0
	var plain := Battle.start("hulao", party(["guojia"]), 6)
	var raised: Dictionary = b.leaders[0]
	var hp_a: int = plain.enemy["hp"]
	var hp_b: int = b.enemy["hp"]
	plain._apply(plain.leaders[0], {"type": "attack", "power": 1.0}, 1.0)
	b._apply(raised, {"type": "attack", "power": 1.0}, 1.0)
	check(float(hp_b - b.enemy["hp"]) > float(hp_a - plain.enemy["hp"]) * 1.35, "the layers raise our damage")
	b.db.battle["variance"] = 0.2
	var life: int = b.party_hp
	b.end_round()
	var hit: int = life - b.party_hp
	var plain_life: int = plain.party_hp
	plain.end_round()
	check(hit < (plain_life - plain.party_hp) * 0.95 or plain_life == plain.party_hp, "and cut what we take")
	for _i in 4:
		b.end_round()
		b.party_hp = b.party_max
	check_eq(b.buff["layers"], 0, "the status wears off when it is not renewed")
	var g: Dictionary = GameData.get_db().skills["xianji"]
	check(g["cost"] == 1 and not g["cumulative"] and g["uses"] == null, "料敌先机 is a plain 1 AP skill")
	check(GameData.get_db().build_fighter("guojia")["skills"].has("xianji"), "郭嘉 has it as his skill")


func test_the_north_lord_fights_with_a_spear_not_the_blade() -> void:
	var db := GameData.get_db()
	var south := db.build_lord("阿明")
	var north := db.build_lord("阿明", 1.0, true)
	check_eq(south["skills"], ["tuji", "rengdao"])
	check_eq(north["skills"], ["tuci", "duomingqiang"])
	check(db.skills["duomingqiang"]["effects"].any(func(e): return e["type"] == "counter"), "the spear answers every blow; the thrown blade does not")
	check(not db.skills["rengdao"]["effects"].any(func(e): return e["type"] == "counter"), "the thrown blade is plain damage")
	check(db.skills["tuci"]["cost"] == 0 and db.skills["tuci"]["free"], "突刺 is the hero's free strike too")


func test_a_soldier_can_have_its_own_skills_instead_of_its_troops() -> void:
	var f := GameData.get_db().build_fighter("xiandeng_sishi")
	check_eq(f["troop"], "infantry", "a shield-bearer by troop")
	check_eq(f["skills"], ["sheji", "jushun"], "but its first skill is the archer's shot, then the shield")


func test_the_army_doctor_heals_and_cleanses() -> void:
	var f := GameData.get_db().build_fighter("junyi")
	check_eq(f["skills"], ["xinglin", "jiedu"], "杏林春暖 + 解毒")

