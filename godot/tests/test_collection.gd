extends TestCase


func rng(seed_value: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r


func test_recruit_offers_unowned_generals_and_you_keep_one() -> void:
	var s := SaveData.create()
	s.owned = ["guanyu"]
	var offer := s.recruit_offer(rng(2))
	check_eq(offer.size(), int(GameData.get_db().gacha["offer_size"]))
	var ids := {}
	for c in offer:
		ids[c["id"]] = true
		check(not c["soldier"] and c["in_pool"] and c["id"] != "guanyu", c["id"])
	check_eq(ids.size(), offer.size(), "no duplicates in an offer")
	s.take(offer[1]["id"])
	check_eq(s.owned, ["guanyu", offer[1]["id"]])


func test_recruiting_everything_empties_the_pool() -> void:
	var s := SaveData.create()
	var r := rng(1)
	for _i in 500:  # every general up to 金
		var offer := s.recruit_offer(r)
		if offer.is_empty():
			break
		s.take(offer[0]["id"])
	check_eq(s.pool_left(), 0)
	check(s.owned.all(func(c): return GameData.get_db().cards[c]["in_pool"]), "story-only cards never offered")


func test_chest_shows_different_soldiers_and_only_the_pick_is_kept() -> void:
	var s := SaveData.create()
	var offer := s.chest_after_battle(rng(1), 0.0, true)
	check_eq(offer.size(), int(GameData.get_db().gacha["chest_cards_boss"]))
	check(offer.all(func(c): return offer.count(c) == 1), "all different")
	check(s.soldiers.is_empty() and s.owned.is_empty(), "nothing granted before picking")
	s.take(offer[0]["id"])
	check_eq(s.copies(offer[0]["id"]), 1, "only the pick is kept")


func test_chest_chance_follows_overkill() -> void:
	var s := SaveData.create()
	check_eq(s.chest_chance(0.0, false), 0.5, "50% with no overkill")
	check_eq(s.chest_chance(0.5, false), 0.75, "half of the overkill is added")
	check_eq(s.chest_chance(1.0, false), 1.0, "100% overkill guarantees a chest")
	check_eq(s.chest_chance(0.0, true), 1.0, "bosses and elites always drop")
	check_eq(s.chest_chance(0.0, false, 0.25), 0.75, "a 宝物's chest bonus counts in full")
	check(not s.chest_after_battle(rng(0), 1.0, false).is_empty(), "100% overkill: a chest")
	var drops := 0
	for i in 400:
		if not s.chest_after_battle(rng(i), 0.0, false).is_empty():
			drops += 1
	check_between(drops, 150, 250, "about half without overkill")


func test_duplicate_soldiers_decay_but_new_types_count_fully() -> void:
	var one := SaveData.new()
	one.owned = ["zhangfei"]
	var base: int = one.leader_for("zhangfei")["at"]
	var dup := SaveData.new()
	dup.owned = ["zhangfei"]
	dup.soldiers = {"spear_n": 2}
	var mix := SaveData.new()
	mix.owned = ["zhangfei"]
	mix.soldiers = {"spear_n": 1, "qingzhou": 1}
	var spear: int = GameData.get_db().build_fighter("spear_n")["at"]
	check(absi(dup.leader_for("zhangfei")["at"] - (base + int(round(spear * 1.6)))) <= 1, "second copy counts 60%")
	check(mix.leader_for("zhangfei")["at"] > dup.leader_for("zhangfei")["at"], "a new soldier type beats a copy")


func test_soldier_can_lead_and_uses_one_copy() -> void:
	var s := SaveData.new()
	s.soldiers = {"cav_n": 3}
	check_eq(s.leader_for("cav_n")["members"].size(), 2)


func test_party_rules() -> void:
	var s := SaveData.new()
	s.owned = ["machao", "guanyu", "zhangfei", "sunce", "sunce_zhong"]
	check("兵种重复" in s.validate_party(["machao", "guanyu"]))
	check("不同版本" in s.validate_party(["sunce", "sunce_zhong"]))
	check_eq(s.validate_party(["machao", "zhangfei"]), "")
	check("未拥有" in s.validate_party(["zhaoyun"]))


func test_auto_party_uses_benched_cards_as_backing() -> void:
	var s := SaveData.new()
	s.owned = ["cav_n", "madai", "guanyu", "spear_n", "archer_n", "log_n"]
	s.party = s.auto_party()
	check(s.party.has("guanyu") and not s.party.has("madai"), str(s.party))
	var leaders := s.party_leaders()
	check_eq(leaders.size(), 4)
	for ld in leaders:
		if ld["card"]["id"] == "guanyu":
			var ids := {}
			for m in ld["members"]:
				ids[m["id"]] = true
			check_eq(ids.keys().size(), 2, "cav_n + madai back 关羽 up")


func test_removed_cards_are_dropped_and_save_roundtrips() -> void:
	var d := {"owned": ["guanyu", "gone_card"], "soldiers": {"dangyang": 2.0, "cav_n": 1.0}, "party": ["gone_card"],
		"damage": 12.0, "lord_name": "阿明"}
	var s := SaveData.from_dict(d)
	check_eq(s.owned_ids(), ["guanyu", "cav_n"])
	check(s.party.is_empty())
	var again := SaveData.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))
	check_eq(again.to_dict(), s.to_dict())
	check_eq(typeof(again.damage), TYPE_INT)


func test_generals_repeat_and_climb_bronze_silver_gold() -> void:
	var s := SaveData.create()
	s.take("ganning")
	check_eq(s.tier("ganning"), 0)
	var base: int = s.fighter("ganning")["at"]
	s.take("ganning")
	check_eq(s.tier("ganning"), 1)
	check(s.fighter("ganning")["at"] > base, "silver is stronger")
	s.take("ganning")
	check_eq(s.tier("ganning"), 1)
	s.take("ganning")
	check_eq(s.tier("ganning"), 2)
	check(s.maxed("ganning"))
	check_eq(s.owned.count("ganning"), 1)


func test_recruit_offers_can_repeat_owned_but_not_gold_generals() -> void:
	var s := SaveData.create()
	for c in GameData.get_db().pool("R"):
		s.owned.append(c["id"])
		s.dupes[c["id"]] = 4
	var r := RandomNumberGenerator.new()
	for seed_value in 20:
		r.seed = seed_value
		check(s.recruit_offer(r).all(func(c): return c["rarity"] != "R"), "gold R cards are out of the pool")
	s.dupes = {}
	var seen_owned := false
	for seed_value in 20:
		r.seed = seed_value
		seen_owned = seen_owned or s.recruit_offer(r).any(func(c): return s.owned.has(c["id"]))
	check(seen_owned, "owned generals can come again")


func test_upgrade_jumps_to_the_next_tier() -> void:
	var s := SaveData.create()
	s.take("lvmeng")
	s.upgrade("lvmeng")
	check_eq(s.tier("lvmeng"), 1)
	s.upgrade("lvmeng")
	check_eq(s.tier("lvmeng"), 2)
	check_eq(s.copies("lvmeng"), 4)


func test_dupes_survive_a_save_roundtrip() -> void:
	var s := SaveData.create()
	s.take("lvmeng")
	s.take("lvmeng")
	var back := SaveData.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))
	check_eq(back.tier("lvmeng"), 1)


func test_story_lines_find_their_speaker() -> void:
	var k := Kit.speakers([
		"{lord}：「夫人……」",
		"孙策把枪往地上一戳：「还等什么！」",
		"周瑜摇头：「水寨易守难攻。」",
		"孙策：「娘，凭什么他三块？」吴夫人：「他瘦。」",
		"当夜，江上一排贼船亮起火把。",
		"浓眉少年：「我叫孙策！」",
		"「不求同年同月同日生——」孙策顿了顿",
		"「还有点烫，」她认真地说",
		"吴夫人：「文台那把刀，你拿去。」",
		"孙策的枪已经端平了：「大哥！」",
		"天亮后孙坚一身烟灰，盯着董白：「你押她走。」",
		"他转向你：「嘴甜的。」",
		"@dongbai 关押董白的帐篷里传出一声大喊：「师父！」",
	], ["wuguotai"])
	check_eq(k[0], "lord")
	check_eq(k[1], "sunce")
	check_eq(k[2], "zhouyu")
	check_eq(k[3], "sunce", "the first speaker wins")
	check_eq(k[4], "", "narration: nobody")
	check_eq(k[5], "sunce", "described before named")
	check_eq(k[6], "sunce", "the name right after an opening quote")
	check_eq(k[7], "wuguotai", "她: the latest woman, the square's cast counts")
	check_eq(k[8], "wuguotai", "the speaker, not who is talked about")
	check_eq(k[9], "sunce", "an owner opening the line speaks when nobody else acts")
	check_eq(k[10], "sunjian", "a name after a short lead-in is the subject; one further in is the object")
	check_eq(k[11], "sunjian", "他: the latest man")
	check_eq(k[12], "dongbai", "an @tag names the speaker outright")
	check_eq(Kit.strip_tag("@dongbai 「师父！」"), "「师父！」")


func test_the_lord_card_can_be_drawn() -> void:
	var s := SaveData.create()
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var seen := false
	for _i in 300:
		if s.recruit_offer(rng).any(func(c): return c["id"] == "lord"):
			seen = true
			break
	check(seen, "the lord turns up in recruit offers now and then")
	s.take("lord")
	check_eq(s.tier("lord"), 1, "a second copy: 银")
	check(not s.owned.has("lord") and not s.party.has("lord"), "the lord isn't a collection card")
	s.take("lord")
	s.take("lord")
	check(s.maxed("lord"), "4 copies: 金, then it stops turning up")
	rng.seed = 5
	for _i in 100:
		check(not s.recruit_offer(rng).any(func(c): return c["id"] == "lord"))


func test_the_lord_starts_bronze_and_can_go_up() -> void:
	var s := SaveData.create()
	check_eq(s.tier("lord"), 0, "the lord's card starts 铜")
	var at0: int = s.lord()["at"]
	s.upgrade("lord")
	check_eq(s.tier("lord"), 1, "银 after one upgrade")
	check(s.lord()["at"] > at0 and s.party_leaders()[0]["card"]["at"] == s.lord()["at"], "a higher tier hits harder, in battle too")


func test_a_new_lap_keeps_the_collection_and_raises_it() -> void:
	var s := SaveData.create()
	s.lord_name = "阿明"
	s.grant_card("sunce")
	s.grant_card("danyang")
	s.quests_cleared = ["prologue"]
	s.flags = ["董白：留下"]
	s.merit = 7
	var n := s.new_lap()
	check_eq(n.lap, 2)
	check(n.owned.has("sunce") and n.soldiers.get("danyang", 0) == 1 and n.lord_name == "阿明" and n.merit == 7, "cards, name, 战功 kept")
	check(n.tier("sunce") == s.tier("sunce") and n.tier("lord") == s.tier("lord"), "tiers carried over as they are, no gifts")
	check(n.quests_cleared.is_empty() and n.flags.is_empty(), "the story starts over")
	check_eq(Quests.mods(n)["enemy"], Quests.mods(s)["enemy"], "enemies unchanged")


func test_cards_you_have_had_can_be_drawn_again() -> void:
	var s := SaveData.create()
	s.grant_card("dongbai")  # story-only: not in the normal recruit pool
	var rarity: String = GameData.get_db().cards["dongbai"]["rarity"]
	check(s.recruit_pool(rarity).any(func(c): return c["id"] == "dongbai"), "a card you've had can be drawn")
	var n := s.new_lap()
	check(n.seen.has("dongbai") and n.recruit_pool(rarity).any(func(c): return c["id"] == "dongbai"), "still drawable next 周目")


func test_relics_belong_to_a_team_and_work_while_it_is_out() -> void:
	var s := SaveData.create()
	s.grant_card("sunce")  # 骑兵 leader
	s.relics = ["chitu", "jiujia", "bingfa"]  # 骑兵队 / 主公队 / 谋士队
	check_eq(s.relic_unit("chitu"), "sunce", "赤兔马 sits in the 骑兵 unit")
	check_eq(s.relic_unit("jiujia"), "lord", "孙坚旧甲 in the lord's")
	check_eq(s.relic_unit("bingfa"), "", "no 谋士 out: 孙子兵法 rests")
	check(not Quests.mods(s).has("turns"), "a resting 宝物 does nothing")
	s.grant_card("zhouyu")  # 谋士 leader
	check_eq(s.relic_unit("bingfa"), "zhouyu")
	check(Quests.mods(s).get("turns", 0.0) > 0.0, "its team is out: it works")
	s.set_worn("bingfa", false)
	check(s.relic_unit("bingfa") == "" and not Quests.mods(s).has("turns"), "left in the pool: no effect")
	s.set_worn("bingfa", true)
	check_eq(s.relic_unit("bingfa"), "zhouyu", "worn again")
	for rid in GameData.get_db().relics:
		check(GameData.get_db().troops.has(GameData.get_db().relics[rid]["troop"]), "%s belongs to a real troop" % rid)


func test_cards_can_be_left_behind() -> void:
	var s := SaveData.create()
	s.grant_card("sunce")  # 骑兵 leader
	s.grant_card("xiliang_nvbing")  # 骑兵 soldiers join his unit
	var full: int = s.leader_for("sunce")["hp"]
	s.set_brought("xiliang_nvbing", false)
	check(s.leader_for("sunce")["hp"] < full, "left behind: not in the unit")
	s.set_brought("sunce", false)
	check(not s.benched.has("sunce"), "a leader is always brought")
	s.set_brought("xiliang_nvbing", true)
	check_eq(s.leader_for("sunce")["hp"], full, "brought again")


func test_soldiers_have_only_the_plain_move() -> void:
	var db := GameData.get_db()
	var cs := db.build_fighter("changsha")  # 刀兵 soldier
	check_eq(cs["skills"], db.default_kit("infantry"), "a soldier card: the troop's plain move only")
	check_eq(db.build_fighter("danyang")["skills"], db.default_kit("infantry", true), "精兵 丹阳兵: both")
	var hz := db.build_fighter("huangzhong")  # 弓兵 general with his own 百步穿杨
	check_eq(hz["skills"], db.default_kit("archer") + ["baibu"], "a general: the plain move + his own")
	var jq := db.build_fighter("jiangqin")  # no skill of his own
	check_eq(jq["skills"], db.default_kit("archer", true), "no own skill: the troop's signature instead")


func test_beast_cards_stay_out_of_drops_for_now() -> void:
	var db := GameData.get_db()
	for cid in ["yezhu", "baie_hu"]:
		check(db.cards.has(cid) and not db.cards[cid]["in_pool"], "%s exists, out of the pools" % cid)
		check(not db.soldier_cards().any(func(c): return c["id"] == cid), "%s never in a chest" % cid)
	check(not db.enemies.values().any(func(e): return e["card"] in ["yezhu", "baie_hu"]), "no enemy drops them")


func test_chests_hold_more_generals_at_a_higher_difficulty() -> void:
	var s := SaveData.create()
	check_eq(s.level(), 1, "难度 starts at 1")
	var gens := func(save: SaveData) -> int:
		var r := RandomNumberGenerator.new()
		r.seed = 9
		var n := 0
		for _i in 300:
			n += save.chest_mix(r, 3).filter(func(c): return not c["soldier"]).size()
		return n
	var low: int = gens.call(s)
	check(low > 0, "a normal chest can hold a general")
	s.difficulty = 1
	check_eq(s.level(), 2)
	check(gens.call(s) > low, "难度 2: more generals")


func test_generals_outclass_soldiers_of_their_troop() -> void:
	## every general beats the strongest soldier of the same troop in attack (a unit is 5 × its leader + members)
	var db := GameData.get_db()
	var best := {}
	for cid in db.cards:
		var c: Dictionary = db.cards[cid]
		if c["soldier"] and not c["beast"]:
			best[c["troop"]] = maxi(best.get(c["troop"], 0), db.build_fighter(cid)["at"])
	for cid in db.cards:
		var c: Dictionary = db.cards[cid]
		if not c["soldier"] and best.has(c["troop"]) and c["rarity"] in ["SR", "SSR"]:
			check(db.build_fighter(cid)["at"] > best[c["troop"]], "%s (%s) should out-hit every %s soldier" % [c["name"], c["rarity"], c["troop"]])


func test_boss_cards_and_xuanjizi_have_portraits() -> void:
	check_eq(Kit.portrait_key("xuanjizi_card"), "xuanjizi")
	check_eq(Kit.portrait_key("lidamu_card"), "lidamu")
	check_eq(Kit.portrait_key("yaodao_card"), "yaodao")
	check_eq(Kit.portrait_key("dongzhuo_card"), "dongzhuo")
	var fighter := GameData.get_db().build_fighter("xuanjizi_card")
	check_eq(fighter.get("person"), "xuanjizi")



func test_skills_come_from_kits_not_troops_and_a_card_can_name_its_own() -> void:
	var db := GameData.get_db()
	for tid in db.troops:
		check(not db.troops[tid].has("skills"), "%s: troops carry stats only" % tid)
		check(not db.default_kit(tid).is_empty() and not db.default_kit(tid, true).is_empty(), "%s: default kit" % tid)
	var before: String = db.cards["liaohua"]["kit"]
	db.cards["liaohua"]["kit"] = "spear"  # an infantry card drawing a spear kit
	check_eq(db.build_fighter("liaohua")["skills"], db.kits["spear"]["special"], "the card's own kit wins over its troop's default")
	db.cards["liaohua"]["kit"] = before
	check_eq(db.build_fighter("liaohua")["skills"], db.default_kit("infantry", true), "back on the troop default")
