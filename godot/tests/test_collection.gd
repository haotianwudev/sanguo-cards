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


func _copies_for(tier_index: int) -> int:
	## the copies a tier needs (cards.json gacha.tiers: 1 / 4 / 16 / 64)
	return int(GameData.get_db().gacha["tiers"][tier_index]["copies"])


func test_recruiting_everything_empties_the_pool() -> void:
	var s := SaveData.create()
	for r in ["R", "SR", "SSR"]:  # every general in the pool at the top tier
		for c in s.recruit_pool(r):
			s.owned.append(c["id"])
			s.dupes[c["id"]] = _copies_for(GameData.get_db().gacha["tiers"].size() - 1)
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


func test_generals_repeat_and_climb_through_the_tiers() -> void:
	var s := SaveData.create()
	s.take("ganning")
	check_eq(s.tier("ganning"), 0, "铜")
	var base: int = s.fighter("ganning")["at"]
	var last := base
	for k in range(1, GameData.get_db().gacha["tiers"].size()):
		while s.copies("ganning") < _copies_for(k) - 1:
			s.take("ganning")
		check_eq(s.tier("ganning"), k - 1, "one short of tier %d" % k)
		s.take("ganning")
		check_eq(s.tier("ganning"), k, "tier %d at %d copies" % [k, _copies_for(k)])
		var at: int = s.fighter("ganning")["at"]
		check(at > last, "every tier hits harder")
		last = at
	check(s.maxed("ganning"))
	check_eq(s.owned.count("ganning"), 1)


func test_recruit_offers_can_repeat_owned_but_not_gold_generals() -> void:
	var s := SaveData.create()
	for c in GameData.get_db().pool("R"):
		s.owned.append(c["id"])
		s.dupes[c["id"]] = _copies_for(GameData.get_db().gacha["tiers"].size() - 1)
	var r := RandomNumberGenerator.new()
	for seed_value in 20:
		r.seed = seed_value
		check(s.recruit_offer(r).all(func(c): return c["rarity"] != "R"), "top-tier R cards are out of the pool")
	s.dupes = {}
	var seen_owned := false
	for seed_value in 20:
		r.seed = seed_value
		seen_owned = seen_owned or s.recruit_offer(r).any(func(c): return s.owned.has(c["id"]))
	check(seen_owned, "owned generals can come again")


func test_upgrade_jumps_the_configured_number_of_tiers() -> void:
	var s := SaveData.create()
	s.take("lvmeng")
	s.upgrade("lvmeng", 1)
	check_eq(s.tier("lvmeng"), 1)
	s.upgrade("lvmeng", 1)
	check_eq(s.tier("lvmeng"), 2)
	check_eq(s.copies("lvmeng"), _copies_for(2))
	var top: int = GameData.get_db().gacha["tiers"].size() - 1
	var s2 := SaveData.create()
	s2.take("lvmeng")
	s2.upgrade("lvmeng")  # gacha.upgrade_levels
	check_eq(s2.tier("lvmeng"), mini(s2.upgrade_levels(), top), "点化 raises it by gacha.upgrade_levels, never past the top")
	s2.upgrade("lvmeng", 9)
	check_eq(s2.tier("lvmeng"), top)


func test_dupes_survive_a_save_roundtrip() -> void:
	var s := SaveData.create()
	for _i in _copies_for(1):
		s.take("lvmeng")
	var back := SaveData.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))
	check_eq(back.tier("lvmeng"), 1)
	check_eq(back.copies("lvmeng"), _copies_for(1))


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
	check_eq(Kit.speakers(["文丑败退，公孙瓒惊魂未定，当场赠五百匹幽州白马：「这份情，伯珪记下了！」"])[0], "gongsunzan", "公孙瓒 recognized")
	check_eq(Kit.speakers(["文丑大喝：「休走！」"])[0], "wenchou", "文丑 recognized")
	check_eq(Kit.speakers(["太史慈引弓如满月：「某去去就回！」"])[0], "taishici", "太史慈 recognized")
	check_eq(Kit.speakers(["糜竺拨动算盘：「东海糜家愿助玄德公一臂之力。」"])[0], "mizhu", "糜竺 recognized")
	check_eq(Kit.speakers(["糜芳满身是血踉跄而来：「曹军屠城，徐州危在旦夕！」"])[0], "mifang", "糜芳 recognized")
	check_eq(Kit.speakers(["孔融捋须：「北海百姓认你，这印，让给你。」"])[0], "kongrong", "孔融 recognized")
	check_eq(Kit.speakers(["管亥倒拖长刀而出，大喝：「谁来受死！」"])[0], "guanhai", "管亥 recognized")
	check_eq(Kit.speakers(["颜良横刀立马：「黑山余党，一个不留！」"])[0], "yanliang", "颜良 recognized")
	check_eq(Kit.speakers(["马超挺枪厉喝：「西凉锦马超在此，曹贼纳命来！」"])[0], "machao", "马超 recognized")
	check_eq(Kit.speakers(["马岱按刀沉声道：「兄长放心，后方交予末将。」"])[0], "madai", "马岱 recognized")
	check_eq(Kit.speakers(["蔡夫人慢慢剥着一颗枇杷：「急什么。朝廷的诏书在他手里，明着动他，就是造反。」"])[0], "caifuren", "蔡夫人 recognized")
	check_eq(Kit.speakers(["卞夫人手提宫灯，温言道：「风雪甚急，诸位将士且披上暖氅。」"])[0], "bianfuren", "卞夫人 recognized")
	check_eq(Kit.speakers(["严夫人夹着账册冷笑：「奉先在外征战，这徐州府库的亏空，谁来补齐？」"])[0], "yanfuren", "严夫人 recognized")
	check_eq(Kit.speakers(["马云騄勒马扬枪笑道：「西凉儿女，何惧中原豪强！」"])[0], "mayunlu", "马云騄 recognized")


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
	for _i in _copies_for(1) - 1:
		s.take("lord")
	check_eq(s.tier("lord"), 1, "enough copies: 银")
	check(not s.owned.has("lord") and not s.party.has("lord"), "the lord isn't a collection card")
	s.lord_copies = _copies_for(GameData.get_db().gacha["tiers"].size() - 1)
	check(s.maxed("lord"), "at the top tier it stops turning up")
	rng.seed = 5
	for _i in 100:
		check(not s.recruit_offer(rng).any(func(c): return c["id"] == "lord"))


func test_the_lord_starts_bronze_and_can_go_up() -> void:
	var s := SaveData.create()
	check_eq(s.tier("lord"), 0, "the lord's card starts 铜")
	var at0: int = s.lord()["at"]
	s.upgrade("lord", 1)
	check_eq(s.tier("lord"), 1, "银 after one level")
	check(s.lord()["at"] > at0 and s.party_leaders()[0]["card"]["at"] == s.lord()["at"], "a higher tier hits harder, in battle too")


func test_a_new_lap_keeps_the_collection_and_raises_it() -> void:
	var s := SaveData.create()
	s.lord_name = "阿明"
	s.grant_card("sunce")
	s.grant_card("danyang")
	s.quests_cleared = ["prologue"]
	s.flags = ["董白：留下"]
	s.merit = 7
	s.lord_copies = _copies_for(1) + 1  # 银 + 1 copy
	s.dupes["sunce"] = _copies_for(1)  # 银
	s.commit_history()  # an ending was reached with these cards in hand
	var n := s.new_lap()
	check_eq(n.lap, 2)
	check(n.owned.is_empty() and n.soldiers.is_empty() and n.party.is_empty() and n.merit == 0, "a new lap starts with nothing: no cards, no 战功")
	check(n.lord_name == "阿明" and n.seen.has("sunce") and n.seen.has("danyang"), "the name and the history of what you had are kept")
	check_eq(n.lord_copies, _copies_for(1) + 1, "the lord's level is kept: 银 + 1")
	check_eq(n.tier("lord"), 1, "…still 银")
	n.grant_card("lord")
	check_eq(n.lord_copies, _copies_for(1) + 2, "and drawing the lord again keeps levelling him")
	n.lord_copies = _copies_for(2) - 1
	n.grant_card("lord")
	check_eq(n.tier("lord"), 2, "to 金")
	n.grant_card("sunce")
	check_eq(n.tier("sunce"), 1, "a general you drew again comes back at the level he had (银), not 铜")
	n.grant_card("sunce")
	check_eq(n.tier("sunce"), 1, "and one more copy carries on from there")
	check_eq(n.copies("sunce"), _copies_for(1) + 1)
	var all := s.new_lap(true)
	check(all.owned.has("sunce") and all.soldiers.get("danyang", 0) == 1 and all.merit == 7, "the test option keeps the whole collection")
	check(n.quests_cleared.is_empty() and n.flags.is_empty(), "the story starts over")
	var bat: Dictionary = GameData.get_db().battle
	var fresh := SaveData.create()
	check_eq(Quests.mods(fresh)["enemy"], 0.0, "lap 1, first stage: no climb yet")
	check_eq(Quests.mods(n)["enemy"], 0.0, "a new lap with no new ending is not harder")
	var mid := SaveData.create()
	mid.quests_cleared = ["prologue", "taodong"]
	check(is_equal_approx(Quests.mods(mid)["enemy"], 2.0 * float(bat["chapter_step"])), "each chapter cleared makes the next stage harder")
	mid.replay = "prologue"
	check_eq(Quests.mods(mid)["enemy"], 0.0, "replaying an old chapter does not take the climb")


func test_cards_you_have_had_can_be_drawn_again() -> void:
	var s := SaveData.create()
	s.take("dongbai")  # drawn, not given by the story (she is story-only: not in the normal recruit pool)
	s.grant_card("zhouyu", true)  # given by a story square
	var rarity: String = GameData.get_db().cards["dongbai"]["rarity"]
	check(s.recruit_pool(rarity).any(func(c): return c["id"] == "dongbai"), "a card you hold can be drawn")
	var lost := s.new_lap()
	check(not lost.seen.has("dongbai"), "a run that never reached an ending leaves no history")
	s.commit_history()  # an ending
	check(s.seen.has("dongbai") and not s.seen.has("zhouyu"), "at an ending: what you drew joins the history, what the story gave does not")
	var n := s.new_lap()
	check(n.seen.has("dongbai") and n.recruit_pool(rarity).any(func(c): return c["id"] == "dongbai"), "still drawable next 周目")
	check(not n.owned.has("dongbai"), "…but not owned any more")


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
	check_eq(Kit.portrait_key("wenchou"), "wenchou")
	var fighter := GameData.get_db().build_fighter("xuanjizi_card")
	check_eq(fighter.get("person"), "xuanjizi")



func test_skills_come_from_kits_not_troops_and_a_card_can_name_its_own() -> void:
	var db := GameData.get_db()
	for tid in db.troops:
		check(not db.troops[tid].has("skills"), "%s: troops carry stats only" % tid)
		check(not db.default_kit(tid).is_empty() and not db.default_kit(tid, true).is_empty(), "%s: default kit" % tid)
	var before: String = db.cards["gaoshun"]["kit"]
	db.cards["gaoshun"]["kit"] = "spear"  # an infantry card drawing a spear kit
	check_eq(db.build_fighter("gaoshun")["skills"], db.kits["spear"]["special"], "the card's own kit wins over its troop's default")
	db.cards["gaoshun"]["kit"] = before
	check_eq(db.build_fighter("gaoshun")["skills"], db.default_kit("infantry", true), "back on the troop default")


func test_the_spear_troop_is_a_big_one_with_a_shared_signature() -> void:
	var db := GameData.get_db()
	var spear: Array = db.cards.values().filter(func(c): return c["troop"] == "spear")
	var soldiers: Array = spear.filter(func(c): return c["soldier"])
	var generals: Array = spear.filter(func(c): return not c["soldier"])
	check(soldiers.size() >= 15 and generals.size() >= 30, "%d soldiers, %d generals" % [soldiers.size(), generals.size()])
	for c in generals:
		if c["rarity"] in ["SR", "SSR"] and c["id"] != "xuhuang":
			var own: Array = c["skills"].filter(func(s): return s != "qiangpo")
			check(c["skills"].has("qiangpo") or c["skills"].is_empty() or c["id"] in ["zhangren", "zhanghe", "xiahoudun"], "%s shares 枪破千军" % c["id"])
			check(own.size() <= 1 and own.all(func(s): return db.skills[s]["uses"] == 1), "%s: whatever is his own is a once-only 大招" % c["id"])


func test_north_chapters_one_to_three_draw_north_spear_cards() -> void:
	var db := GameData.get_db()
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	for q in db.quests:
		if q["id"] in ["prologue", "luoyang_n", "heishan"]:
			var p := Quests.pools(q, s)
			var soldier_ok: bool = p["soldier_pool"].any(func(c): return db.cards[c]["troop"] == "spear" and db.cards[c]["scope"] == "north")
			var recruit_ok: bool = p["recruit_pool"].any(func(c): return db.cards[c]["troop"] == "spear")
			check(soldier_ok, "%s: north spear soldiers in its chests" % q["id"])
			check(recruit_ok and p["recruit_pool"].all(func(c): return db.cards[c]["scope"] != "south"), "%s: its recruit squares offer spear cards, none of the south's" % q["id"])


func test_the_two_routes_recruit_from_their_own_casts() -> void:
	## 南北对称、其余分开: a general's scope keeps the 江东 cast out of the north's offers and the 河北 cast out of the south's
	var db := GameData.get_db()
	var south := SaveData.create()
	var north := SaveData.create()
	north.flags = ["出生：冀州无极"]
	for r in ["R", "SR", "SSR"]:
		for c in south.recruit_pool(r):
			check(c.get("scope", "") != "north", "south run: %s is a north general" % c["id"])
		for c in north.recruit_pool(r):
			check(c.get("scope", "") != "south", "north run: %s is a south general" % c["id"])
	var n_ids: Array = ["R", "SR", "SSR"].map(func(r): return north.recruit_pool(r).map(func(c): return c["id"])).reduce(func(a, b): return a + b)
	var s_ids: Array = ["R", "SR", "SSR"].map(func(r): return south.recruit_pool(r).map(func(c): return c["id"])).reduce(func(a, b): return a + b)
	check(n_ids.has("zhangliao") and not n_ids.has("lusu") and s_ids.has("lusu") and not s_ids.has("zhangliao"), "each side has its own: " + str(n_ids.size()))
	check(n_ids.has("guanyu") and s_ids.has("guanyu"), "the ones both stories use are in both")
	check(n_ids.size() >= 40 and s_ids.size() >= 40, "neither side is thin: %d / %d" % [n_ids.size(), s_ids.size()])
	var north_history := SaveData.create()
	north_history.flags = ["出生：冀州无极"]
	north_history.seen = ["zhaoyun"]  # given out by chapter one: not in the public pool, only in your history
	check(not north.recruit_pool("SSR").any(func(c): return c["id"] == "zhaoyun"), "a chapter's own general is not in the public pool")
	check(north_history.recruit_pool("SSR").any(func(c): return c["id"] == "zhaoyun"), "…but one you have had before can come again, on his route")
	var south_history := SaveData.create()
	south_history.seen = ["zhaoyun"]
	check(not south_history.recruit_pool("SSR").any(func(c): return c["id"] == "zhaoyun"), "and never on the other route")


func test_the_lords_unit_grows_with_his_retinue_and_servants() -> void:
	var db := GameData.get_db()
	var s := SaveData.create()
	var alone: Dictionary = s.party_leaders()[0]
	check(alone["members"].is_empty(), "a lord with nobody around is alone")
	for c in ["qinwei", "yahuan", "xiuniang"]:
		s.grant_card(c)
	var with: Dictionary = s.party_leaders()[0]
	check_eq(with["members"].size(), 3, "his retinue and the servants are his unit's members")
	check(with["at"] > alone["at"] and with["hp"] > alone["hp"], "which makes the lord stronger")
	var mult := float(db.battle["lord_member_mult"])
	var full := 0.0
	for m in with["members"]:
		full += m["at"]
	check(absf(float(with["at"]) - (float(alone["at"]) + full * mult)) < 1.5, "each counts lord_member_mult of its strength: %d vs %d" % [with["at"], int(alone["at"] + full * mult)])
	check(s.validate_party(["qinwei"]) != "", "a retinue card can never lead a unit of its own")
	for cid in ["yahuan", "xiuniang", "chuniang", "huansha", "caisang", "chaniang", "gongnv", "huofu", "qinwei"]:
		check_eq(db.cards[cid]["troop"], "lord", cid + " serves the lord")
		check(db.build_fighter(cid)["skills"].is_empty(), cid + " has no skills: it only strengthens the lord")
	var north := db.cards.values().filter(func(c): return c["troop"] == "lord" and c.get("scope", "") == "north")
	var south := db.cards.values().filter(func(c): return c["troop"] == "lord" and c.get("scope", "") == "south")
	check(north.size() >= 4 and south.size() >= 4, "both routes have their own: %d / %d" % [north.size(), south.size()])


func test_chests_draw_from_the_public_pool_the_chapters_soldiers_and_your_history() -> void:
	var db := GameData.get_db()
	check(db.is_public("cav_n") and not db.is_public("danyang") and not db.is_public("zhaoyun"), "a card some chapter hands out is not public")
	var s := SaveData.create()
	var q := "prologue"
	var pools := s.chest_pools(q)
	check(pools["public"]["soldier"].all(func(c): return db.is_public(c["id"])), "public soldiers belong to no chapter")
	check(pools["public"]["general"].all(func(c): return db.is_public(c["id"])), "nor do public generals")
	check(pools["chapter"]["soldier"].all(func(c): return db.card_chapters[c["id"]].has(q)), "chapter soldiers are this chapter's")
	check(pools["history"]["soldier"].is_empty() and pools["history"]["general"].is_empty(), "no history on a fresh save")
	var all: Array = pools["public"]["soldier"] + pools["chapter"]["soldier"] + pools["public"]["general"] + pools["history"]["general"]
	check(all.all(func(c): return c.get("scope", "") != "north"), "the south never sees a north card")
	var north := SaveData.create()
	north.flags = ["出生：冀州无极"]
	north.seen = ["danyang", "zhaoyun", "sunjian"]
	var hist: Dictionary = north.chest_pools(q)["history"]
	var ids: Array = (hist["soldier"] + hist["general"]).map(func(c): return c["id"])
	check(ids.has("zhaoyun") and not ids.has("sunjian"), "history keeps to the route: " + str(ids))
	# a chest really draws from all three
	var seen_src := {"public": false, "chapter": false, "history": false}
	for seed_value in 80:
		var chest := north.chest_mix(rng(seed_value), 3, [], q)
		for c in chest:
			if db.is_public(c["id"]):
				seen_src["public"] = true
			elif db.card_chapters[c["id"]].has(q):
				seen_src["chapter"] = true
			if north.seen.has(c["id"]) and not db.is_public(c["id"]):
				seen_src["history"] = true
	check(seen_src["public"] and seen_src["chapter"] and seen_src["history"], "all three sources turn up: " + str(seen_src))


func test_difficulty_levels_are_unlocked_by_endings_and_each_route_counts_apart() -> void:
	var db := GameData.get_db()
	var step := float(db.battle["ending_step"])
	var fresh := SaveData.create()
	check_eq(fresh.route_max_level(), 1, "a new save offers difficulty 1 only")
	var south := SaveData.create()
	south.flags = ["结局一 · 玉碎", "结局六 · 覆巢"]
	check_eq(south.route_max_level(), 2, "south: 玉碎 opens 2 (覆巢 is the north's)")
	var north := SaveData.create()
	north.flags = ["出生：冀州无极", "结局一 · 玉碎", "结局六 · 覆巢", "结局七 · 绝罚"]
	check_eq(north.route_max_level(), 3, "north: 覆巢 and 绝罚 open 3 (玉碎 is the south's)")
	south.play_level = 2
	check(is_equal_approx(Quests.mods(south)["enemy"], step), "difficulty 2: +ending_step")
	south.play_level = 9
	check_eq(south.effective_level(), 2, "never above what the route has unlocked")
	south.play_level = 1
	check(is_equal_approx(Quests.mods(south)["enemy"], 0.0), "difficulty 1 adds nothing")


func test_playing_below_the_level_an_ending_opens_keeps_its_story_shut() -> void:
	var db := GameData.get_db()
	var q: Dictionary = {}
	for x in db.quests:
		if x["id"] == "heishan":
			q = x
	var rescue: Dictionary = q["squares"]["hs_save_choice"]["choose"][0]  # needs 「结局六 · 覆巢」 (level 2)
	var s := SaveData.create()
	s.flags = ["出生：冀州无极", "结局六 · 覆巢"]
	s.play_level = 1
	check(Quests.option_locked(s, rescue), "chosen difficulty 1: the flag is there but the story it opens does not run — the same badend again")
	s.play_level = 2
	check(not Quests.option_locked(s, rescue), "difficulty 2: it does")
	s.play_level = 1
	s.run_records = ["结局六 · 覆巢"]
	Quests.complete(db.quests[0], s)
	check(s.flags.has("结局六 · 覆巢"), "the badend is recorded either way")
