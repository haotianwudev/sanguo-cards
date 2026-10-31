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
		check(str(p.get("name", "")).length() == 4 and str(p.get("desc", "")) != "", "四字 name: " + str(p))
		check(int(p["cost"]) > 0 and int(p["max"]) > 0, p["id"])
		check(not ids.has(p["id"]), "unique id " + p["id"])
		ids[p["id"]] = true
	check(str(cfg.get("card_soldier_name", "")).length() == 4 and str(cfg.get("card_general_name", "")).length() == 4, "the card perks are named too")
	for e in cfg["cards"]:
		check(GameData.get_db().cards.has(e["id"]), "named card exists: " + e["id"])
		check(str(e["name"]).length() == 4 and int(e["cost"]) > 0, e["id"])


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
	check(n.owned.has("sunce"), "the remembered cards are in hand")
	check(n.prep_pending.has("danyang"), "…a south-only one waits for the birthplace")
	check(not n.prep_cards.has("not_a_card"), "a card not remembered is dropped")
	check_eq(n.merit, 10, "余财 ×2")
	check_eq(n.party_slots, slots)
	n.perks["slot"] = 1
	n.party_slots = slots
	n.apply_prep()
	check_eq(n.party_slots, slots + 1, "扩编")


func test_perks_reach_the_battle_mods() -> void:
	var n := _lap2()
	var before := float(Quests.mods(n)["enemy"])
	n.perks = {"ap_max": 2, "easy": 1, "offer_extra": 1, "general_rate": 1}
	var m := Quests.mods(n)
	check_eq(int(m.get("ap_max", 0)), 2)
	check(is_equal_approx(float(m["enemy"]), before - 0.15), "化险为夷: one 难度 level easier")
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


func test_lord_bench_keeps_the_lord_off_the_field() -> void:
	var n := _lap2()
	n.owned = ["machao", "zhaoyun", "daqiao", "zhangfei"]
	n.party = ["machao", "zhaoyun", "daqiao"]
	n.lord_out = true
	check(n.lord_fields(), "no perk: the lord always fields")
	check(n.validate_party(n.party + ["guanyu"]) != "", "…and takes a place")
	n.perks["lord_bench"] = 1
	check(not n.lord_fields(), "坐镇中军: he stays in camp")
	check_eq(n.field_leaders().size(), n.party.size(), "only the generals fight")
	check(n.field_leaders().all(func(ld): return ld["card"]["troop"] != "lord"))
	n.owned.append("guanyu")
	check_eq(n.validate_party(n.party + ["guanyu"]), "", "his place goes to a general")
	n.party = []
	check(n.lord_fields(), "with nobody else out, the lord fights after all")


func test_named_cards_need_no_memory_and_cost_their_price() -> void:
	var n := _lap2()
	check(not n.prep_card_choices().has("jiangwei"), "a named card is not in the remembered list")
	check_eq(n.prep_card_cost("jiangwei"), int(n.prep_named()["jiangwei"]["cost"]))
	n.prep_cards = ["jiangwei", "wei_hubao"]
	n.apply_prep()
	check(n.owned.has("jiangwei") and n.soldiers.has("wei_hubao"), "姜维 and 虎豹骑 join without having been met")


func test_start_chest_stays_off_either_route() -> void:
	var n := _lap2()
	var r := RandomNumberGenerator.new()
	r.seed = 4
	var chest := n.prep_chest(r)
	check(not chest.is_empty(), "开门大吉 deals a chest")
	check(chest.all(func(c): return c.get("scope", "") == ""), "no route-only cards before the route is chosen")


func test_named_cards_are_not_main_story_people() -> void:
	var db := GameData.get_db()
	var story_files := {}
	for f in ["story.json", "side_stories.json", "enemies.json", "endings.json"]:
		story_files[f] = FileAccess.get_file_as_string("res://data/" + f)
	for e in db.battle["prep"]["cards"]:
		if not db.cards[e["id"]]["soldier"]:
			check(not db.card_chapters.has(e["id"]), "%s is handed out by a chapter: the main story has them" % e["id"])
			var who: String = str(db.cards[e["id"]]["name"]).split("·")[0]
			for f in story_files:
				check(not story_files[f].contains(who), "%s appears in %s: the main story has them" % [who, f])
			check_eq(db.cards[e["id"]]["rarity"], "SR", e["id"] + " is SR")
	var troops := {}
	for e in db.battle["prep"]["cards"]:
		var key := "%s/%s" % [db.cards[e["id"]]["troop"], db.cards[e["id"]]["soldier"]]
		check(not troops.has(key), "one per troop: " + key)
		troops[key] = true
		check_eq(int(e["cost"]), 1 if db.cards[e["id"]]["soldier"] else 2, e["id"])


func test_route_only_named_cards_wait_for_the_birthplace() -> void:
	var n := _lap2()
	n.prep_cards = ["danyang", "jiangwei"]  # remembered 南线 soldier / both routes
	n.apply_prep()
	check(not n.soldiers.has("danyang") and n.owned.has("jiangwei"), "a south-only card waits for the route")
	n.flags.append("出生：冀州无极")
	var got := n.route_prep_cards()
	check(not n.soldiers.has("danyang"), "the north route does not get the south one")
	check_eq(got.size(), 0)
	check(n.prep_pending.is_empty())


func test_relics_can_be_bought_and_are_worn_from_the_start() -> void:
	var db := GameData.get_db()
	var n := _lap2(8)
	var sale := n.prep_relic_choices()
	check(sale.size() <= 8 and sale.all(func(r): return n.prep_relic_cost(r) in [1, 2]), "a few 宝物, 1–2 点 each")
	check(not sale.has("jiujia"), "story 宝物 are not sold")
	var a: String = sale[0]
	var b: String = sale[-1]
	n.prep_relics = [a, b]
	check_eq(n.prep_spent(), n.prep_relic_cost(a) + n.prep_relic_cost(b))
	n.apply_prep()
	check(n.kept_relics.has(a) and n.kept_relics.has(b), "kept from the first chapter on")
	Quests.begin(db.quests[0], n)
	check(n.relics.has(b), "a chapter starts with them")
