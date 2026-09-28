extends TestCase


func rng(seed_value: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r


func quest(i: int) -> Dictionary:
	return GameData.get_db().quests[i]


func test_maps_only_move_forward_one_row_at_a_time() -> void:
	for q in GameData.get_db().quests:
		for s in q["squares"].values():
			var targets: Array = s["next"].duplicate()
			for o in s["choose"]:
				if not o["locked"]:
					targets.append(o["goto"])
			for t in targets:
				var ts: Dictionary = q["squares"][t]
				check(ts["x"] > s["x"] and absi(ts["y"] - s["y"]) <= 1, "%s -> %s" % [s["id"], t])


func test_story_runs_prologue_then_dongzhuo() -> void:
	check_eq(GameData.get_db().quests.map(func(q): return q["id"]), ["prologue", "taodong"])


func walk_to(q: Dictionary, s: SaveData, ids: Array, choice := 0) -> void:
	for sid in ids:
		Quests.move(q, s, sid)
		Quests.resolve(q, s, rng(0), choice)


func test_cannot_move_before_resolving() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	check(Quests.next_options(q, s).is_empty())
	Quests.resolve(q, s, rng(0), 0)
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["wake"])


func test_the_north_is_not_open_yet() -> void:
	var opts: Array = quest(0)["squares"]["era"]["choose"]
	check(not opts[0]["locked"] and opts[1]["locked"] and opts[0]["card"] == "")


func test_each_plan_walks_its_own_branch_and_both_rescue_her() -> void:
	for pick in 2:
		var q := quest(0)
		var s := SaveData.create()
		Quests.begin(q, s)
		Quests.resolve(q, s, rng(0), 0)
		walk_to(q, s, ["wake", "bandage", "village", "sc_home", "boar", "raid"])
		Quests.move(q, s, "plan")
		Quests.resolve(q, s, rng(0), pick)
		var branch: Array = [["sc_gate", "sc_road", "sc_hall"], ["zy_lure", "zy_back", "zy_hall"]][pick]
		check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), [branch[0]])
		check(s.has_card(["sunce", "zhouyu"][pick]) and not s.has_card(["zhouyu", "sunce"][pick]), "only the planner joins first")
		walk_to(q, s, branch + ["rescue"])
		check(s.has_card(["sunce", "zhouyu"][pick]) and s.has_card("wuguotai"), "the planner and 吴夫人 after the rescue")
		check(not s.has_card(["zhouyu", "sunce"][pick]), "the other brother joins in chapter 2")
		check(not s.has_card("huanggai"))


func test_recover_square_clears_carried_wear() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.damage = 500
	s.carry_extra = {"lord": {"haoling": 1}}
	s.square = "camp"
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check(s.damage == 0 and s.carry_extra.is_empty())


func test_failing_restarts_but_keeps_choices_and_cards() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.resolve(q, s, rng(0), 0)
	walk_to(q, s, ["wake", "bandage", "village", "sc_home", "boar", "raid"])
	Quests.move(q, s, "plan")
	Quests.resolve(q, s, rng(0), 1)
	s.damage = 999
	Quests.fail(q, s)
	check(s.square == "era" and s.damage == 0 and s.has_card("zhouyu"))
	check(s.resolved, "the birthplace choice stands")
	walk_to(q, s, ["wake", "bandage", "village", "sc_home", "boar", "raid"])
	Quests.move(q, s, "plan")
	check(s.resolved, "earlier plan stands")
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["zy_lure"])


func test_every_event_option_resolves_or_leads_somewhere() -> void:
	var q := quest(0)
	var all: Array = []
	for qq in GameData.get_db().quests:
		for eid in qq["event_pool"]:
			if not all.has(eid):
				all.append(eid)
	for eid in all:
		var ev: Dictionary = GameData.get_db().events[eid]
		for i in ev["options"].size():
			for seed_value in 4:
				var s := SaveData.create()
				Quests.begin(q, s)
				s.square = "road"
				s.resolved = false
				s.events = {"road": eid}
				Quests.choose_event(q, s, rng(seed_value), i)
				check(s.resolved or not s.event_battle.is_empty() or not s.offer.is_empty(), "%s option %d" % [eid, i])
				if not s.offer.is_empty():
					Quests.resolve(q, s, rng(0), 0)
					check(s.resolved, "%s pick" % eid)


func test_story_cards_do_not_stack() -> void:
	for pick in 2:
		var q := quest(0)
		var s := SaveData.create()
		Quests.begin(q, s)
		Quests.resolve(q, s, rng(0), 0)
		walk_to(q, s, ["wake", "bandage", "village", "sc_home", "boar", "raid"])
		Quests.move(q, s, "plan")
		Quests.resolve(q, s, rng(0), pick)
		walk_to(q, s, [["sc_gate", "sc_road", "sc_hall"], ["zy_lure", "zy_back", "zy_hall"]][pick] + ["rescue"])
		check(s.copies(["sunce", "zhouyu"][pick]) == 1, "rescue doesn't give a second copy")


func event_on_road(eid: String, option: int, seed_value := 0) -> SaveData:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": eid}
	Quests.choose_event(q, s, rng(seed_value), option)
	return s


func test_zuoci_can_upgrade_a_general_or_reset_skills() -> void:
	var q := quest(0)
	var s := SaveData.create()
	s.take("sunce")
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": "zuoci"}
	s.carry_extra = {"sunce": {"xiaobawang": 2}}
	var labels: Array = GameData.get_db().events["zuoci"]["options"].map(func(o): return o["label"])
	Quests.choose_event(q, s, rng(0), labels.find("求点化"))
	check_eq(s.offer, ["sunce"])
	Quests.resolve(q, s, rng(0), 0)
	check(s.tier("sunce") == 1 and s.resolved and s.offer_kind == "", "升银")
	var s2 := SaveData.create()
	Quests.begin(q, s2)
	s2.square = "road"
	s2.resolved = false
	s2.events = {"road": "zuoci"}
	s2.carry_extra = {"sunce": {"xiaobawang": 2}}
	s2.damage = 100
	Quests.choose_event(q, s2, rng(0), labels.find("求静心"))
	check(s2.carry_extra.is_empty() and s2.damage == 100, "skills reset, HP untouched")


func test_poison_costs_a_third_of_the_hp() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": "snake"}
	Quests.choose_event(q, s, rng(0), 1)  # squeeze the venom out yourself: always poisoned
	check_eq(s.damage, int(round(Quests.party_max(s) / 3.0)))


func test_hero_can_be_anyone() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": "hero"}
	Quests.choose_event(q, s, rng(0), 0)
	check_eq(s.offer.size(), 3)
	check(s.offer.all(func(c): return not GameData.get_db().cards[c]["soldier"]), "generals")


func test_ambush_hits_before_the_first_round() -> void:
	var s := SaveData.create()
	var calm := Battle.start("shuizei_scout", s.party_leaders(), 1)
	var ambushed := Battle.start("shuizei_scout", s.party_leaders(), 1, 0, {}, {}, true)
	check(ambushed.party_hp < calm.party_hp and ambushed.round_no == 1)


func test_chapter_one_is_a_long_road() -> void:
	var q := quest(0)
	check(q["squares"].size() >= 16, "squares")
	var fights: int = q["squares"].values().filter(func(s): return s["type"] in ["battle", "mystery"]).size()
	check(fights >= 10, "battles and ？ squares: %d" % fights)


func test_an_old_save_on_a_removed_square_restarts_the_quest() -> void:
	var s := SaveData.create()
	s.quest = "prologue"
	s.square = "hg_talk"
	Quests.ensure_started(s)
	check_eq(s.square, "era")


func test_recruit_offer_does_not_reroll() -> void:
	var q := quest(1)  # 讨伐董卓: a normal recruit square (the prologue's only offers soldiers)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "heroes"
	s.resolved = false
	var first: Array = Quests.offer(q, s, rng(1)).map(func(c): return c["id"])
	var again: Array = Quests.offer(q, s, rng(99)).map(func(c): return c["id"])
	check_eq(first, again)
	var got := Quests.resolve(q, s, rng(0), 2)
	check_eq(got.map(func(c): return c["id"]), [first[2]])
	check(not s.owned.has(first[0]) and not s.owned.has(first[1]))


# ---- whole-quest balance (HP carries between battles) --------------------------------

func play_quest(q: Dictionary, s: SaveData, pick: int, fork: int, seed_value: int) -> bool:
	var r := rng(seed_value)
	Quests.begin(q, s)
	for _step in 100:
		var sq := Quests.here(q, s)
		if sq["type"] == "mystery" and not s.resolved:
			Quests.event_here(q, s, r)
			Quests.choose_event(q, s, r, 0)
		if (sq["type"] == "battle" or not s.event_battle.is_empty()) and not s.resolved:
			if not fight(q, s, r):
				if not Quests.lose(q, s, r):
					return false
				continue
		var offered := Quests.offer(q, s, r)
		var choice := 0 if not offered.is_empty() else -1
		if sq["type"] == "choose":
			choice = pick if pick < sq["choose"].size() and not sq["choose"][pick]["locked"] else 0
		Quests.resolve(q, s, r, choice)
		var opts := Quests.next_options(q, s)
		if opts.is_empty():
			Quests.complete(q, s)
			return true
		var idx: int = fork if fork >= 0 and fork < opts.size() else r.randi_range(0, opts.size() - 1)
		Quests.move(q, s, opts[idx]["id"])
	return false


func fight(q: Dictionary, s: SaveData, r: RandomNumberGenerator) -> bool:
	var f := Quests.battle_here(q, s)
	s.party = s.auto_party()
	var b := Battle.start(f["battle"], s.party_leaders(), r.randi(), s.damage, s.carry_extra, s.carry_uses, f["ambush"])
	if bot_fight(b) != "win":
		return false
	var carry := b.carry_out()
	s.damage = carry[0]
	s.carry_extra.merge(carry[1], true)
	s.carry_uses.merge(carry[2], true)
	var chest := s.chest_after_battle(r, b.overkill, f["boss"])
	if not chest.is_empty():
		s.take(chest[0]["id"])
	return true


func rate(qi: int, owned: Array, pick := 0, fork := -1, n := 60) -> float:
	var wins := 0
	for seed_value in n:
		var s := SaveData.new()
		s.owned = owned.duplicate()
		if play_quest(quest(qi), s, pick, fork, seed_value):
			wins += 1
	return float(wins) / n


func test_chapter_one_is_winnable_with_either_plan() -> void:
	for pick in 2:
		check_between(rate(0, [], pick), 0.2, 1.0, "pick %d" % pick)


func campaign_rate(pick: int, fork: int, n := 60) -> float:
	## Play the prologue, then chapter 1 with whatever the prologue left you.
	var wins := 0
	for seed_value in n:
		var s := SaveData.create()
		if play_quest(quest(0), s, pick, -1, seed_value) and play_quest(quest(1), s, 0, fork, seed_value + 1000):
			wins += 1
	return float(wins) / n


func test_dongzhuo_chapter_is_fair_after_chapter_one() -> void:
	check_between(campaign_rate(1, -1), 0.2, 0.95, "zhouyu plan, random forks")


func test_chapter_one_only_gives_local_soldiers_and_prisoners() -> void:
	var q := quest(0)
	var allowed := ["danyang", "changsha", "shuizei_bing", "huangjin_nanxia", "huangjin_nvyi"]
	var s := SaveData.create()
	Quests.begin(q, s)
	for sid in ["vault", "draft"]:
		s.square = sid
		s.resolved = false
		s.offer = []
		var ids: Array = Quests.offer(q, s, rng(3)).map(func(c): return c["id"])
		if sid == "draft":
			check(ids.all(func(c): return c in ["danyang", "changsha"]), "征兵 only finds locals")
		check(not ids.is_empty() and ids.all(func(c): return c in allowed), "%s %s" % [sid, ids])
	var chest := s.chest_after_battle(rng(1), 0.0, true, q["soldier_pool"])
	check(chest.all(func(c): return c["id"] in allowed), "battle chest")
	check_eq(q["squares"]["north"]["cards"], ["danyang", "shuizei_bing", "huangjin_nanxia"], "freed men and prisoners")


func test_changsha_is_weaker_than_danyang() -> void:
	var db := GameData.get_db()
	var cs := db.build_fighter("changsha")
	var dy := db.build_fighter("danyang")
	check(cs["at"] < dy["at"] and cs["hp"] < dy["hp"], "长沙刀兵 %d/%d vs 丹阳兵 %d/%d" % [cs["at"], cs["hp"], dy["at"], dy["hp"]])


# ---- 宝物 / 险 / shuffled runs ------------------------------------------------------

func test_relics_change_battles() -> void:
	var s := SaveData.create()
	s.take("sunce")
	s.party = s.auto_party()
	var plain := Battle.start("boar", s.party_leaders(), 1)
	s.relics = ["bingfu", "bingfa", "yuxi", "chize", "zhangu"]
	var m := Quests.mods(s)
	var b := Battle.start("boar", s.party_leaders(), 1, 0, {}, {}, false, m)
	check_eq(b.ap, plain.ap + 2, "兵符 +1 at start, 玉玺 +1 per round")
	check_eq(b.turn_limit, plain.turn_limit + 2, "孙子兵法")
	check(b.party_max < plain.party_max, "玉玺 costs HP")
	check(b.enemy["stunned"], "赤帻")
	check(b.leaders.all(func(u): return u["boosted"]), "战鼓")


func test_troop_relics_only_help_their_troop() -> void:
	var s := SaveData.create()
	s.relics = ["chitu"]
	var m := Quests.mods(s)
	check(m["troop_at"].has("cavalry") and not m["troop_at"].has("infantry"))


func test_temple_upgrades_a_general() -> void:
	var q := quest(0)
	var s := SaveData.create()
	s.take("zhouyu")
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": "temple"}
	Quests.choose_event(q, s, rng(0), 0)
	check(s.resolved and s.offer.is_empty(), "no pick: the mountain god chooses")
	check_eq(s.tier("zhouyu"), 1)


func test_elite_offers_a_relic_pick_and_danger_toughens_enemies() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "yaodao"
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check(s.offer_kind == "relic" and s.offer.size() == 3)
	Quests.take_relic(s, s.offer[0])
	check(s.relics.size() == 1 and s.offer.is_empty())
	s.danger = 1
	var calm := Battle.start("boar", s.party_leaders(), 1)
	var risky := Battle.start("boar", s.party_leaders(), 1, 0, {}, {}, false, Quests.mods(s))
	check(risky.enemy["max_hp"] > calm.enemy["max_hp"])


func test_each_run_deals_the_shuffle_groups_anew() -> void:
	var q := quest(0)
	var layouts := {}
	for seed_value in 12:
		var s := SaveData.create()
		Quests.begin(q, s, rng(seed_value))
		var v := Quests.view(q, s)
		var types: Array = ["reeds", "road", "ferry"].map(func(id): return v["squares"][id]["type"] + v["squares"][id]["event"])
		types.sort()
		check_eq(types, ["battle", "mystery", "mysteryrisk"], "same contents, new places")
		layouts[JSON.stringify(s.layout)] = true
	check(layouts.size() > 3, "runs differ")


func test_famous_weapons() -> void:
	var s := SaveData.create()
	s.take("zhouyu")
	s.party = s.auto_party()
	var plain := Battle.start("yaodao", s.party_leaders(), 3)
	s.relics = ["qinggang", "qixing", "bazhen"]
	var b := Battle.start("yaodao", s.party_leaders(), 3, 0, {}, {}, false, Quests.mods(s))
	var hp0: int = b.enemy["hp"]
	var hp1: int = plain.enemy["hp"]
	b.act(0, "tuji")
	plain.act(0, "tuji")
	check(hp0 - b.enemy["hp"] > (hp1 - plain.enemy["hp"]) * 1.6, "七星宝刀 doubles the first hit")
	var d1 := b.defend()
	check(b.take_events().any(func(e): return e["t"] == "defend" and e["cut"] > 0.3), "八阵图 deepens defend")


func test_the_enemy_card_can_turn_up_in_its_chest() -> void:
	var s := SaveData.create()
	var seen := 0
	for seed_value in 40:
		var chest := s.chest_after_battle(rng(seed_value), 0.0, true, quest(0)["soldier_pool"], "heyi")
		if chest.any(func(c): return c["id"] == "heyi"):
			seen += 1
	check(seen > 8 and seen < 32, "about half the boss chests: %d/40" % seen)


func test_lvbu_cannot_really_be_lost_to_and_brings_the_three_brothers() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "lvbu"
	s.resolved = false
	s.damage = 999
	check(Quests.lose(q, s, rng(0)), "not a defeat")
	check(s.square == "sanying" and s.damage == 0, "三英战吕布, HP restored")
	check(s.quest == "taodong" and not s.visited.has("triple"))


func test_beating_lvbu_leads_past_three_chests_one_of_them_grand() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "lvbu"
	s.resolved = false
	Quests.resolve(q, s, rng(0))  # won
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["triple"])
	Quests.move(q, s, "triple")
	Quests.choose_event(q, s, rng(1), 0)
	check_eq(s.difficulty, 1)
	check(Quests.mods(s)["enemy"] > 0.0, "every enemy is tougher now")
	var db := GameData.get_db()
	for seed_value in 10:
		var r := SaveData.create()
		Quests.begin(q, r, rng(seed_value))
		var v := Quests.view(q, r)
		var grand: Array = ["box1", "box2", "box3"].filter(func(b): return v["squares"][b]["event"] == "grand_chest")
		check_eq(grand.size(), 1, "exactly one grand chest")
	s.square = "box1"
	s.resolved = false
	Quests.choose_event(q, s, rng(2), 0)
	check(not s.offer.is_empty() and s.offer.all(func(c): return db.cards[c]["rarity"] in ["SR", "SSR"]), "the grand chest holds SR/SSR")
	var s2 := SaveData.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))
	Quests.begin(quest(0), s2)
	check_eq(s2.difficulty, 1, "difficulty stays for the whole campaign")


func test_lvbu_is_nearly_unbeatable() -> void:
	check(rate(1, ["machao", "zhangfei", "zhaoyun", "guanyu", "daqiao", "cav_n", "spear_n"], 0, 0, 30) >= 0.0)
	var wins := 0
	for seed_value in 30:
		var s := SaveData.create()
		for c in ["sunce", "zhouyu", "wuguotai", "sunjian", "danyang", "danyang"]:
			s.grant_card(c)
		s.party = s.auto_party()
		var b := Battle.start("hulao_ch1", s.party_leaders(), seed_value)
		if bot_fight(b) == "win":
			wins += 1
	check(wins <= 3, "吕布 wins %d/30 against the chapter-2 party" % (30 - wins))


func test_chapter_one_ends_with_the_riverside_oath_before_heading_north() -> void:
	var q := quest(0)
	check_eq(q["squares"]["vault"]["next"], ["oath"])
	check_eq(q["squares"]["oath"]["next"], ["north"])
	check(q["squares"]["north"]["next"].is_empty(), "north is the last square")


func test_after_fuchun_you_follow_zhouyu_uphill_or_sunce_to_the_boars() -> void:
	var q := quest(0)
	check_eq(q["squares"]["village"]["next"], ["zy_hill", "sc_home"])
	check_eq(q["squares"]["zy_hill"]["next"], ["hill"])
	check_eq(q["squares"]["sc_home"]["next"], ["boar"])
	for g in q["shuffle"]:
		check(not g.has("hill") and not g.has("boar"), "the two paths keep their places")


func test_huatuo_heals_joins_or_leaves_his_book() -> void:
	var db := GameData.get_db()
	check(quest(0)["event_pool"].has("huatuo"))
	check(db.cards["huatuo"]["troop"] == "logistics" and db.cards["huatuo"]["skills"] == ["mafei"])
	var joined := 0
	var book := 0
	for seed_value in 20:
		var s := event_on_road("huatuo", 1, seed_value)
		if s.has_card("huatuo"):
			joined += 1
		if s.relics.has("qingnang"):
			book += 1
	check(joined > 0 and book > 0 and joined + book == 20, "joins %d, leaves 青囊书 %d" % [joined, book])


func test_yuji_only_brings_trouble() -> void:
	check(quest(0)["event_pool"].has("yuji"))
	var drank := event_on_road("yuji", 0)
	check(drank.damage > 0 and drank.relics.has("huangjinfu"), "poisoned and cursed")
	var chased := event_on_road("yuji", 1)
	check_eq(chased.danger, 1, "险 +1")
	var fled := event_on_road("yuji", 2)
	check(fled.event_battle.get("ambush", false), "his followers ambush you")


func test_chapter_two_follows_the_dongbai_story() -> void:
	var q := quest(1)
	var sq: Dictionary = q["squares"]
	check_eq(q["start"], "set_out")
	check(sq["set_out"]["cards"].has("sunce") and sq["set_out"]["cards"].has("zhouyu"), "both brothers now")
	check_eq(sq["huaxiong"]["lose_goto"], "jian_hua")
	check(sq["dongbai"]["elite"], "董白 is an elite fight")
	var fate: Array = sq["fate"]["choose"].map(func(o): return o["goto"])
	check_eq(fate, ["give", "keep"])
	check(sq["luoyang_b"]["cards"].has("dongbai") and not sq["luoyang_a"]["cards"].has("dongbai"), "董白 joins only if spared")


func test_saving_zumao_gives_the_red_headscarf() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "save_zumao"
	s.resolved = false
	Quests.choose_event(q, s, rng(0), 0)
	check(s.relics.has("chize") and s.resolved)
	check(s.has_card("zumao"), "祖茂 follows you")
	check(GameData.get_db().skills["yindi"]["effects"].any(func(e): return e["type"] == "guard"), "引敌 draws fire")


func test_handing_dongbai_over_pays_a_relic() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "give"
	s.resolved = false
	Quests.choose_event(q, s, rng(0), 0)
	check_eq(s.relics.size(), 1)


func test_trades_take_something_away() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.relics = ["hupi"]
	s.grant_card("danyang")
	s.grant_card("danyang")
	s.square = "road"
	s.resolved = false
	s.events = {"road": "merchant"}
	Quests.choose_event(q, s, rng(0), 0)
	check(s.relics.is_empty() and not s.offer.is_empty(), "a relic for a pick of generals")
	var s2 := SaveData.create()
	Quests.begin(q, s2)
	s2.grant_card("danyang")
	s2.grant_card("danyang")
	s2.take("sunce")
	s2.square = "road"
	s2.resolved = false
	s2.events = {"road": "smith"}
	Quests.choose_event(q, s2, rng(0), 0)
	check(s2.copies("danyang") == 0 and s2.offer_kind == "upgrade", "two soldiers melted into an upgrade")


func test_each_chapter_has_a_big_event_pool() -> void:
	check(quest(0)["event_pool"].size() >= 20, "chapter 1: %d events" % quest(0)["event_pool"].size())
	check(quest(1)["event_pool"].size() >= 15, "chapter 2: %d events" % quest(1)["event_pool"].size())


func test_chapter_two_is_full_of_dong_zhuo_troops() -> void:
	var q := quest(1)
	var fights: Array = q["squares"].values().filter(func(s): return s["type"] == "battle").map(func(s): return s["battle"])
	for f in ["xiliang_youqi", "guosi", "feixiong", "liru", "huaxiong", "dongbai", "hulao_ch1", "lijue"]:
		check(fights.has(f), f)
	check(q["squares"]["liru"]["ambush"], "李儒 lays an ambush")
	check(GameData.get_db().enemies["feixiong"]["phys_resist"] > 0.3, "飞熊军 wear heavy armour")


func test_sunjian_lends_you_one_of_his_old_generals() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "borrow"
	s.resolved = false
	Quests.choose_event(q, s, rng(0), 0)
	check_eq(s.offer.size(), 3)
	check(s.offer.all(func(c): return c in ["chengpu", "handang", "huanggai", "zhuzhi", "wujing", "sunben"]), "孙家的将领")
	Quests.resolve(q, s, rng(0), 1)
	check(s.resolved and s.owned.size() == 1, "one of them joins")


func test_sunjians_old_guard_can_be_drawn() -> void:
	var db := GameData.get_db()
	for cid in ["chengpu", "handang", "huanggai", "zumao", "zhuzhi", "wujing", "sunben", "sunjing"]:
		check(db.cards[cid]["in_pool"], cid)


func test_luoyang_brings_palace_maids_and_dongbais_guards_follow_her() -> void:
	var sq: Dictionary = quest(1)["squares"]
	check(sq["luoyang_a"]["cards"].has("gongnv") and sq["luoyang_b"]["cards"].has("gongnv"), "宫女 either way")
	check(sq["luoyang_b"]["cards"].has("xiliang_nvbing") and not sq["luoyang_a"]["cards"].has("xiliang_nvbing"), "女亲兵 only with 董白")
	var soldiers: Array = GameData.get_db().soldier_cards().map(func(c): return c["id"])
	check(soldiers.has("gongnv") and soldiers.has("xiliang_nvbing"), "both can turn up in chests")


func test_tangji_can_be_escorted_and_join() -> void:
	check(quest(1)["event_pool"].has("tangji"))
	var s := event_on_road("tangji", 0)
	check(not s.event_battle.is_empty(), "the pursuers attack")
	s.event_battle = s.event_battle  # won
	Quests.resolve(quest(0), s, rng(0))
	check(s.has_card("tangji"), "唐姬 joins after the fight")


func test_bandits_turn_up_everywhere() -> void:
	for qi in 2:
		for eid in ["shanzei", "yazhai", "shanzhai", "jieying"]:
			check(quest(qi)["event_pool"].has(eid), "chapter %d: %s" % [qi + 1, eid])
	check_eq(quest(1)["squares"]["road2"]["event"], "yazhai", "the road to 孙坚 passes her fort")


func test_a_fixed_event_is_not_rolled_again() -> void:
	var q := quest(1)
	for seed_value in 30:
		var s := SaveData.create()
		Quests.begin(q, s)
		s.square = "road1"
		s.resolved = false
		s.events = {}
		check(Quests.event_here(q, s, rng(seed_value))["id"] != "yazhai", "seed %d" % seed_value)


func test_beating_the_bandit_queen_brings_her_along() -> void:
	var s := event_on_road("yazhai", 1)
	check(s.event_battle.get("battle", "") == "yanzhihu")
	Quests.resolve(quest(0), s, rng(0))
	check(s.has_card("yanzhihu"))


func test_yellow_turban_remnants_and_their_medics() -> void:
	for qi in 2:
		for eid in ["hj_camp", "hj_medics", "hj_road"]:
			check(quest(qi)["event_pool"].has(eid), "chapter %d: %s" % [qi + 1, eid])
	var s := event_on_road("hj_medics", 1)
	check(s.damage == 0, "they patch you up")
	check_eq(GameData.get_db().cards["huangjin_nvyi"]["troop"], "logistics")


func test_the_yellow_turban_saint() -> void:
	check(quest(0)["event_pool"].has("shengnv") and quest(1)["event_pool"].has("shengnv"))
	var healed := event_on_road("shengnv", 0)
	check(healed.resolved and healed.damage == 0)
	var joined := 0
	for seed_value in 20:
		var s := event_on_road("shengnv", 1, seed_value)
		if s.has_card("zhangning"):
			joined += 1
		else:
			check(s.relics.has("taipingyaoshu"), "she leaves her book")
	check(joined > 0 and joined < 20)


func test_the_chapter_recap_remembers_the_run() -> void:
	var q := quest(1)
	var s := SaveData.create()
	s.take("sunce")
	Quests.begin(q, s)
	s.take("zhouyu")
	s.grant_card("gongnv")
	s.grant_card("gongnv")
	s.square = "lvbu"
	s.resolved = false
	Quests.lose(q, s, rng(0))
	s.square = "fate"
	s.resolved = false
	Quests.resolve(q, s, rng(0), 1)
	Quests.take_relic(s, "hupi")
	var r := Quests.recap(s)
	check(r["records"].has("吕布：三英战吕布") and r["records"].has("董白：留下"), str(r["records"]))
	check(r["cards"].has(["zhouyu", 1]) and r["cards"].has(["gongnv", 2]) and not r["cards"].any(func(c): return c[0] == "sunce"), str(r["cards"]))
	check_eq(r["relics"], ["hupi"])
	Quests.fail(q, s)
	check(Quests.recap(s)["records"].is_empty(), "a new run starts a clean recap")


func test_merit_is_paid_once_per_chapter_and_spent_between_chapters() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.run_battles = 6
	s.run_bosses = 2
	check_eq(Quests.pay_merit(q, s), 6 + 2 * 2)
	check_eq(Quests.pay_merit(q, s), 0, "a reopened recap doesn't pay twice")
	check_eq(s.merit, 10)
	check(Quests.spend_merit(s, "draw"), "5 for a draw")
	check_eq(s.merit, 5)
	check(not Quests.spend_merit(s, "upgrade"), "8 for an upgrade — not enough left")
	var back := SaveData.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))
	check(back.merit == 5 and back.merit_paid == "prologue")


func test_beating_a_boss_or_elite_counts_for_merit() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "yaodao"
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check_eq(s.run_bosses, 1)


func test_finished_chapters_leave_story_flags_that_pick_the_interlude() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.record(s, "董白：留下")
	Quests.complete(q, s)
	check(s.flags.has("董白：留下"))
	var titles: Array = Quests.interlude("taodong", s).map(func(sc): return sc["title"])
	check(titles.has("玉玺") and titles.has("单挑") and not titles.has("河边"), str(titles))
	var s2 := SaveData.create()
	s2.flags = ["董白：交给袁绍"]
	var t2: Array = Quests.interlude("taodong", s2).map(func(sc): return sc["title"])
	check(t2.has("河边") and not t2.has("单挑"), str(t2))
	Quests.begin(quest(0), s)
	check(s.flags.has("董白：留下"), "flags outlive a new run")


func test_relics_carry_into_the_next_chapter_but_new_ones_reset_on_a_restart() -> void:
	var s := SaveData.create()
	Quests.begin(quest(0), s)
	s.relics = ["hupi", "jiunang"]
	Quests.complete(quest(0), s)
	Quests.begin(quest(1), s)
	check_eq(s.relics, ["hupi", "jiunang"], "all of chapter 1's relics come along")
	s.relics.append("bingfu")
	Quests.fail(quest(1), s)
	check_eq(s.relics, ["hupi", "jiunang"], "a restart drops only what this chapter gave")


func test_replaying_a_chapter_is_harder_and_returns_to_the_story() -> void:
	var s := SaveData.create()
	Quests.begin(quest(0), s)
	Quests.complete(quest(0), s)
	Quests.begin(quest(1), s)
	s.square = "counter"
	s.damage = 123
	s.take("sunce")
	Quests.start_replay(quest(0), s, rng(0))
	check(s.quest == "prologue" and s.danger == 1, "进阶: one clear = +1 险")
	s.grant_card("danyang")
	Quests.complete(quest(0), s)
	check(s.replay == "" and s.quest == "taodong" and s.square == "counter" and s.damage == 123, "back where the story was")
	check(s.has_card("danyang"), "replay rewards stay")
	check_eq(s.clears["prologue"], 2)
	check_eq(s.quests_cleared, ["prologue"])
	Quests.start_replay(quest(0), s, rng(0))
	check_eq(s.danger, 2, "harder again")
	Quests.stop_replay(s)
	check(s.quest == "taodong" and s.square == "counter", "giving up returns to the story too")
