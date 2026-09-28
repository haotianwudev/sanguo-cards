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
	for _i in 200:
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
	check(offer.all(func(c): return c["soldier"]))
	check(s.soldiers.is_empty(), "nothing granted before picking")
	s.take(offer[0]["id"])
	check_eq(s.soldiers, {offer[0]["id"]: 1})


func test_chest_chance_follows_overkill() -> void:
	var s := SaveData.create()
	check(not s.chest_after_battle(rng(0), 0.5, false).is_empty(), "50% overkill guarantees a chest")
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
	check_eq(Kit.speaker_key("{lord}：「夫人……」"), "lord")
	check_eq(Kit.speaker_key("孙策把枪往地上一戳：「还等什么！」"), "sunce")
	check_eq(Kit.speaker_key("周瑜摇头：「水寨易守难攻。」"), "zhouyu")
	check_eq(Kit.speaker_key("吴夫人笑眯眯地拿针尾敲了一下你的额头：「想得美。」"), "wuguotai")
	check_eq(Kit.speaker_key("孙策：「娘，凭什么他三块？」吴夫人：「他瘦。」"), "sunce", "the first speaker wins")
	check_eq(Kit.speaker_key("当夜，江上一排贼船亮起火把。"), "", "narration: nobody")
	check_eq(Kit.speaker_key("富春江边，孙家老宅。孙坚的旧大刀挂在墙上。"), "", "a name merely mentioned: no face")
	check_eq(Kit.speaker_key("吴夫人：「文台那把刀，你拿去。」"), "wuguotai", "the speaker, not who is talked about")


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
