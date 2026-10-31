extends TestCase
## 前尘整备: the 周目 perks bought with 前尘点 (battle.json prep)


func _lap2(endings := 3) -> SaveData:
	## a second 周目 after reaching a few different endings
	var db := GameData.get_db()
	var s := SaveData.create()
	s.grant_card("sunce")
	s.grant_card("danyang")
	s.flags = db.ending_order.slice(0, endings).map(func(id): return db.endings[id]["title"])
	s.commit_history()
	return s.new_lap()


func test_points_are_the_different_endings_reached() -> void:
	var n := _lap2(3)
	check_eq(n.prep_points(), 3 * int(n.prep_cfg().get("per_ending", 1)))
	check_eq(n.prep_spent(), 0, "nothing bought yet")
	n.perks["ap_max"] = 1
	n.prep_cards = ["danyang"]
	check_eq(n.prep_spent(), 2 + int(n.prep_cfg()["card_soldier"]))


func test_every_perk_has_a_name_and_fits_the_page() -> void:
	var cfg: Dictionary = GameData.get_db().battle["prep"]
	var ids := {}
	for p in cfg["perks"]:
		check(str(p.get("name", "")) != "" and str(p.get("desc", "")) != "", str(p))
		check(int(p["cost"]) > 0 and int(p["max"]) > 0, p["id"])
		check(not ids.has(p["id"]), "unique id " + p["id"])
		ids[p["id"]] = true
	check(str(cfg.get("card_soldier_name", "")) != "" and str(cfg.get("card_general_name", "")) != "", "the card perks are named too")


func test_public_generals_need_a_perk_from_the_second_lap() -> void:
	var db := GameData.get_db()
	var first := SaveData.create()
	check(first.public_open(), "the first 周目 has the public pool")
	var n := _lap2()
	check(not n.public_open(), "a later 周目 starts without it")
	var public_ids := func(s: SaveData) -> Array:
		var out: Array = []
		for r in db.gacha["rates"]:
			for c in s.recruit_pool(r):
				if db.is_public(c["id"]) and not s.seen.has(c["id"]):
					out.append(c["id"])
		return out
	check(public_ids.call(n).is_empty(), "no public general in the recruit pool")
	check(n.chest_pools()["public"]["general"].is_empty(), "…nor in the chests")
	n.perks["public"] = 1
	check(not public_ids.call(n).is_empty(), "广纳贤才 brings them back")


func test_all_generals_opens_story_only_ones() -> void:
	var db := GameData.get_db()
	var n := _lap2()
	n.perks["all_generals"] = 1
	var story_only := db.cards.values().filter(func(c): return not c["soldier"] and not c.get("beast", false) and not db.is_public(c["id"]) \
			and not SaveData.is_lord_card(c["id"]) and c.get("scope", "") in ["", n.route()])
	check(not story_only.is_empty(), "there are story-only generals")
	var c: Dictionary = story_only[0]
	check(n.recruit_pool(c["rarity"]).has(c), "天下英雄: %s can be recruited" % c["id"])
	check(n.chest_pools()["public"]["general"].has(c), "…and found in chests")


func test_confirming_brings_the_cards_and_pays_the_perks() -> void:
	var n := _lap2(8)
	var slots := n.party_slots
	n.prep_cards = ["sunce", "danyang", "not_a_card"]
	n.perks = {"slot": 0, "merit": 2}
	n.apply_prep()
	check(n.owned.has("sunce") and n.soldiers.has("danyang"), "the remembered cards are in hand")
	check(not n.prep_cards.has("not_a_card"), "a card not remembered is dropped")
	check_eq(n.merit, 10, "余财 ×2")
	check_eq(n.party_slots, slots)
	n.perks["slot"] = 1
	n.party_slots = slots
	n.apply_prep()
	check_eq(n.party_slots, slots + 1, "扩编")


func test_perks_reach_the_battle_mods() -> void:
	var n := _lap2()
	n.perks = {"ap_max": 2, "hp": 1, "lord_swap": 1, "offer_extra": 1, "general_rate": 1}
	var m := Quests.mods(n)
	check_eq(int(m.get("ap_max", 0)), 2)
	check(is_equal_approx(float(m.get("hp", 0.0)), 0.1), "厚积")
	check(int(m.get("lord_swap", 0)) == 1, "主公退阵")
	check_eq(n.offer_extra(), 1)
	var base := SaveData.create()
	check(n.chest_general_chance() > base.chest_general_chance(), "慧眼")


func test_pick_extra_keeps_the_offer_up_once() -> void:
	var n := _lap2()
	n.offer = ["a", "b", "c"]
	check(not n.pick_again("a"), "no perk, no second pick")
	n.perks["pick_extra"] = 1
	check(n.pick_again("a"), "兼收并蓄")
	check_eq(n.offer, ["b", "c"])
	check(not n.pick_again("b"), "only once per offer")
	check(not n.extra_pick_open)


func test_last_laps_choice_carries_over() -> void:
	var n := _lap2()
	n.perks = {"ap_max": 1}
	n.prep_cards = ["sunce"]
	var m := n.new_lap()
	check_eq(m.perk("ap_max"), 1)
	check_eq(m.prep_cards, ["sunce"])


func test_lord_swap_lets_the_lord_leave_the_field() -> void:
	var s := SaveData.new()
	s.owned = ["machao", "zhaoyun", "madai", "zhangfei", "daqiao"]
	s.party = ["machao", "zhaoyun"]
	var b := Battle.start("hulao", s.party_leaders(), 1, 0, {}, {}, false, {"lord_swap": 1}, s.swap_roster())
	b.round_no = b.swap_from_round()
	check(not b.swap_options(0).is_empty(), "主公退阵: the lord has stand-ins")
	b.ap = 6
	var cid: String = b.swap_options(0)[0]["card"]["id"]
	b.swap(0, cid)
	check_eq(b.leaders[0]["leader"]["card"]["id"], cid, "the lord is off the field")
