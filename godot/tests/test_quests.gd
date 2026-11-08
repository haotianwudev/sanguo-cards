extends TestCase
## 章节与剧情流程：每章的路线、分支、入队、结局（从原来 2500 行的 test_quests.gd 按主题拆出）


func test_cannot_move_before_resolving() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	check(Quests.next_options(q, s).is_empty())
	Quests.resolve(q, s, rng(0), 0)
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["wake"])


func test_both_birthplaces_are_open() -> void:
	var opts: Array = quest(0)["squares"]["era"]["choose"]
	check(not opts[0]["locked"] and not opts[1]["locked"] and opts[0]["card"] == "")


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


func test_a_once_only_skill_stays_spent_until_a_rest() -> void:
	## 大招 are once per stretch of map, not once per battle: used up, they stay used up until a 休整 square
	var s := SaveData.create()
	s.grant_card("daqiao")
	var b := Battle.start("boar", party(["daqiao"]), 1)
	var i := -1
	for k in b.leaders.size():
		if b.leaders[k]["leader"]["card"]["id"] == "daqiao":
			i = k
	b.act(i, "guose")
	var carry := b.carry_out()
	check_eq(carry[2].get("daqiao", {}).get("guose"), 0, "国色 spent")
	var b2 := Battle.start("boar", party(["daqiao"]), 2, 0, carry[1], carry[2])
	b2.ap = 9
	var j := -1
	for k in b2.leaders.size():
		if b2.leaders[k]["leader"]["card"]["id"] == "daqiao":
			j = k
	check(not b2.usable(b2.leaders[j], GameData.get_db().skills["guose"]), "still spent in the next battle")
	var q := quest(0)
	Quests.begin(q, s)
	s.carry_uses = carry[2]
	s.square = "camp"
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check(s.carry_uses.is_empty(), "a rest brings it back")


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


func test_a_party_change_keeps_the_hp_share() -> void:
	var s := SaveData.create()
	s.damage = 50
	Quests.rescale_hp(s, 100, 150)
	check_eq(150 - s.damage, 75, "half HP stays half when the bar grows")
	Quests.rescale_hp(s, 150, 60)
	check_eq(60 - s.damage, 30, "…and when it shrinks")
	s.damage = 0
	Quests.rescale_hp(s, 60, 200)
	check_eq(s.damage, 0, "full stays full")


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


func test_chapter_one_only_gives_local_soldiers_and_prisoners() -> void:
	var q := quest(0)
	var s := SaveData.create()
	var allowed: Array = Quests.pools(q, s)["soldier_pool"]
	Quests.begin(q, s)
	for sid in ["vault", "draft"]:
		s.square = sid
		s.resolved = false
		s.offer = []
		var ids: Array = Quests.offer(q, s, rng(3)).map(func(c): return c["id"])
		if sid == "draft":
			check(ids.all(func(c): return c in q["recruit_pool"]), "征兵 only finds locals")
		var gd := GameData.get_db()
		check(not ids.is_empty() and ids.all(func(c): return c in allowed or gd.is_public(c) or gd.card_chapters[c].has(q["id"])), "%s %s" % [sid, ids])
	var chest := s.chest_after_battle(rng(1), 0.0, true, [], "", 0.0, q["id"])
	var db := GameData.get_db()
	check(chest.all(func(c): return not c["soldier"] or db.is_public(c["id"]) or db.card_chapters[c["id"]].has(q["id"]) or s.seen.has(c["id"])),
		"battle chest: public cards, this chapter's own soldiers, or what you have had")
	check_eq(q["squares"]["north"]["cards"], ["danyang"], "freed men and prisoners")


func test_every_lvbu_fight_uses_the_lose_coefficient() -> void:
	var db := GameData.get_db()
	var lose := float(db.battle["enemy_coef"]["lose"])
	var seen_fights := 0
	for q in db.quests:
		var s := SaveData.create()
		s.quest = q["id"]
		for sid in q["squares"]:
			var sq: Dictionary = q["squares"][sid]
			if sq["battle"] == "" or not db.scenarios.has(sq["battle"]):
				continue
			if str(db.enemies[db.scenarios[sq["battle"]]["enemy"]].get("card", "")) != "lvbu":
				continue
			s.square = sid
			check_eq(Quests.enemy_scale(s), lose, "%s / %s" % [q["id"], sid])
			check(sq["lose_goto"] != "", "losing to 吕布 is not the end: %s / %s carries on" % [q["id"], sid])
			seen_fights += 1
	check(seen_fights >= 3, "found the 吕布 fights (%d)" % seen_fights)


func test_each_run_deals_the_shuffle_groups_anew() -> void:
	var q := quest(0)
	var layouts := {}
	for seed_value in 12:
		var s := SaveData.create()
		Quests.begin(q, s, rng(seed_value))
		var v := Quests.view(q, s)
		var types: Array = ["reeds", "road", "ferry"].map(func(id): return v["squares"][id]["type"] + v["squares"][id]["event"])
		types.sort()
		check_eq(types, ["battle", "mystery", "mystery"], "same contents, new places")
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
	check(hp0 - b.enemy["hp"] > (hp1 - plain.enemy["hp"]) * 1.3, "七星宝刀 adds half again to the first hit")
	b.defend()
	check(b.take_events().any(func(e): return e["t"] == "defend" and e["cut"] > 0.3), "八阵图 deepens defend")


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


func test_chapter_one_ends_with_the_riverside_oath_before_heading_north() -> void:
	var q := quest(0)
	check_eq(q["squares"]["vault"]["next"], ["armor"])
	check_eq(q["squares"]["armor"]["next"], ["oath"])
	check_eq(q["squares"]["oath"]["next"], ["north"])
	check(q["squares"]["north"]["next"].is_empty(), "north is the last square")


func test_after_fuchun_you_follow_zhouyu_uphill_or_sunce_to_the_boars() -> void:
	var q := quest(0)
	check_eq(q["squares"]["village"]["next"], ["zy_hill", "sc_home"])
	check_eq(q["squares"]["zy_hill"]["next"], ["hill"])
	check_eq(q["squares"]["sc_home"]["next"], ["boar"])
	for g in q["shuffle"]:
		check(not g.has("hill") and not g.has("boar"), "the two paths keep their places")


func test_chapter_two_follows_the_dongbai_story() -> void:
	var q := quest(1)
	var sq: Dictionary = q["squares"]
	check_eq(q["start"], "set_out")
	check(sq["set_out"]["cards"].has("sunce") and sq["set_out"]["cards"].has("zhouyu"), "both brothers now")
	check_eq(sq["huaxiong"]["lose_goto"], "jian_hua")
	check(sq["huaxiong"]["boss"] and sq["huaxiong"]["beatable"], "华雄 is a boss with normal scaling; losing still brings 孙坚 in")
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
	check_eq(q["squares"]["save_zumao"]["type"], "event", "a plain story square, not a ？")
	Quests.resolve(q, s, rng(0))
	check(s.relics.has("chize") and s.resolved)
	check(s.has_card("zumao"), "祖茂 follows you")
	check(GameData.get_db().skills["yindi"]["effects"].any(func(e): return e["type"] == "guard"), "引敌 draws fire")


func test_lending_grain_to_caocao_costs_a_quarter_of_hp_and_pays_the_seven_star_blade() -> void:
	var q: Dictionary
	for x in GameData.get_db().quests:
		if x["id"] == "luoyang_n":
			q = x
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "ln_lend"
	s.resolved = false
	var top := Quests.party_max(s)
	Quests.resolve(q, s, rng(0))
	check(s.relics.has("qixing") and not s.relics.has("mengde"), "the blade, not a book written years later")
	check_eq(s.damage, int(round(top * 0.25)), "lending costs 1/4 of the party's HP")


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
	check_eq(q["squares"]["borrow"]["type"], "recruit", "a plain story square: lines, then pick one old general")
	Quests.offer(q, s, rng(0))
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
	var soldiers: Array = SaveData.create().chest_pools("taodong")["chapter"]["soldier"].map(func(c): return c["id"])
	check(soldiers.has("gongnv") and soldiers.has("xiliang_nvbing"), "both can turn up in 讨董's chests")


func test_tangji_can_be_escorted_and_join() -> void:
	check(Quests.pools(quest(1), SaveData.create())["event_pool"].has("tangji"))
	var s := event_on_road("tangji", 0)
	check(not s.event_battle.is_empty(), "the pursuers attack")
	s.event_battle = s.event_battle  # won
	Quests.resolve(quest(0), s, rng(0))
	check(s.has_card("tangji"), "唐姬 joins after the fight")


func test_bandits_turn_up_everywhere() -> void:
	for qi in 2:
		var pool: Array = Quests.pools(quest(qi), SaveData.create())["event_pool"]
		for eid in ["shanzei", "yazhai", "shanzhai", "jieying"]:
			check(pool.has(eid), "chapter %d: %s" % [qi + 1, eid])


func test_beating_the_bandit_queen_brings_her_along() -> void:
	var s := event_on_road("yazhai", 1)
	check(s.event_battle.get("battle", "") == "yanzhihu")
	Quests.resolve(quest(0), s, rng(0))
	check(s.has_card("yanzhihu"))


func test_yellow_turban_remnants_and_their_medics() -> void:
	for qi in 2:
		var pool: Array = Quests.pools(quest(qi), SaveData.create())["event_pool"]
		for eid in ["hj_camp", "hj_medics", "hj_road"]:
			check(pool.has(eid), "chapter %d: %s" % [qi + 1, eid])
	var s := event_on_road("hj_medics", 1)
	check(s.damage == 0, "they patch you up")
	check_eq(GameData.get_db().cards["huangjin_nvyi"]["troop"], "logistics")


func test_finished_chapters_leave_story_flags_that_pick_the_side_stories() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	Quests.record(s, "董白：留下")
	Quests.complete(q, s)
	check(s.flags.has("董白：留下"))
	var titles: Array = Quests.side_stories(s).map(func(st): return st["title"])
	check(titles.has("玉玺") and titles.has("单挑") and not titles.has("河边"), str(titles))
	var s2 := SaveData.create()
	s2.flags = ["董白：交给袁绍"]
	s2.quests_cleared = ["taodong"]
	var t2: Array = Quests.side_stories(s2).map(func(st): return st["title"])
	check(t2.has("河边") and not t2.has("单挑"), str(t2))
	Quests.begin(quest(0), s)
	check(s.flags.has("董白：留下"), "flags outlive a new run")


func test_squares_can_depend_on_earlier_chapters() -> void:
	var s := SaveData.create()
	var gated := {"requires": "董白：留下", "unless": ""}
	var barred := {"requires": "", "unless": "董白：留下"}
	check(not Quests.is_open(gated, s) and Quests.is_open(barred, s))
	s.flags = ["董白：留下"]
	check(Quests.is_open(gated, s) and not Quests.is_open(barred, s))


func test_wu_gives_the_hero_sun_jians_old_armor() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "armor"
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check(s.relics.has("jiujia") and s.run_records.has("穿上了孙坚的旧甲"), "handed over directly, no choice to make")
	for seed_value in 20:
		check(not Quests.relic_offer(s, rng(seed_value)).has("jiujia"), "never offered at random")


func test_every_interlude_click_turns_the_page() -> void:
	# the full-screen backdrop must let clicks through to the overlay, which turns the page
	var src := FileAccess.get_file_as_string("res://scripts/ui/interlude_overlay.gd")
	check(src.contains("bg.mouse_filter = Control.MOUSE_FILTER_IGNORE"), "the backdrop doesn't swallow clicks")


func test_chapter_three_branches_on_dongbai_and_ends_in_ending_one() -> void:
	var db := GameData.get_db()
	var q: Dictionary = db.quests.filter(func(x): return x["id"] == "yuxi")[0]
	check_eq(q["id"], "yuxi")
	var kept := SaveData.create()
	kept.flags = ["董白：留下"]
	var gone := SaveData.create()
	gone.flags = ["董白：交给袁绍", "结局一 · 玉碎"]
	var again := SaveData.create()
	again.flags = ["董白：留下", "结局一 · 玉碎"]
	var sq: Dictionary = q["squares"]
	var fork: Dictionary = sq["wenji_choice"]
	check(Quests.option_locked(kept, fork["choose"][0]) and not Quests.option_locked(kept, fork["choose"][1]), "一周目: 蔡文姬 can't be saved, but she can be left to the bandits")
	check(Quests.option_locked(gone, fork["choose"][0]) and not Quests.option_locked(gone, fork["choose"][1]), "no 董白: she's taken")
	check(not Quests.option_locked(again, fork["choose"][0]) and not Quests.option_locked(again, fork["choose"][1]), "later 周目 with 董白: she can be saved, or still left behind")
	check("结局一" in Quests.option_hint(kept, fork["choose"][0]) and "董白" not in Quests.option_hint(kept, fork["choose"][0]), "the greyed option says what is missing")
	check(sq["wenji_join"]["cards"].has("caiwenji"), "saved, she joins")
	check_eq(sq["yuanshu"]["lose_goto"], "end", "袁术 can't really be beaten: losing leads on to the ending")
	check(q["ending"].get("title", "").begins_with("结局一"), "the chapter ends in 结局一")


func test_dongbai_choice_reaches_the_right_luoyang_after_the_wait() -> void:
	var db := GameData.get_db()
	var q: Dictionary = db.quests[1]
	var sq: Dictionary = q["squares"]
	check(sq["give_c"]["next"] == ["wait"] and sq["keep_c"]["next"] == ["wait"], "both choices lead to the long wait")
	check_eq(sq["fire"]["next"], ["luoyang_a", "luoyang_b"])
	var s := SaveData.create()
	Quests.record(s, "董白：留下")  # chosen in this chapter
	check(Quests.is_open(sq["luoyang_b"], s) and not Quests.is_open(sq["luoyang_a"], s), "kept her: the 洛阳 where she joins")
	var s2 := SaveData.create()
	Quests.record(s2, "董白：交给袁绍")
	check(Quests.is_open(sq["luoyang_a"], s2) and not Quests.is_open(sq["luoyang_b"], s2), "handed over: the other one")


func test_the_marriage_offer_is_dongbai_either_way() -> void:
	var sq: Dictionary = GameData.get_db().quests[1]["squares"]
	var kept := SaveData.create()
	Quests.record(kept, "董白：留下")
	check(Quests.is_open(sq["heqin_k"], kept) and not Quests.is_open(sq["heqin_g"], kept), "she's in the carriage")
	var gone := SaveData.create()
	Quests.record(gone, "董白：交给袁绍")
	check(Quests.is_open(sq["heqin_g"], gone) and not Quests.is_open(sq["heqin_k"], gone), "she's dead")
	check(sq["heqin_k"]["text"].any(func(l): return "董白" in str(l)) and sq["heqin_g"]["text"].any(func(l): return "董白" in str(l)), "the bride offered is 董白")


func test_route_b_goes_on_to_luoyang_and_changan_inside_chapter_three() -> void:
	var s := SaveData.create()
	s.quests_cleared = ["prologue", "taodong"]
	var q3: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == "yuxi")[0]
	check(q3["squares"]["wenji_join"]["next"] == ["wenji_tale"] and q3["squares"]["lijue_test"]["next"] == ["enter"], "saving her walks on to 洛阳, then 长安: same chapter")
	check(GameData.get_db().quests.all(func(x): return x["id"] not in ["shouluoyang", "changan"]), "no chapters of their own")
	check_eq(Quests.title(q3, s), "第三章 · 传国玉玺")
	s.run_records = ["路线：守洛阳"]
	check_eq(Quests.title(q3, s), "第三章 · 驻守洛阳")
	check_eq(Quests.map_key(q3, s), "yuxi", "one map for the whole chapter, like every other chapter")
	s.run_records.append("路线：长安")
	check_eq(Quests.map_key(q3, s), "yuxi")
	s.run_records = []
	s.quests_cleared.append("yuxi")
	s.flags = ["长安：吕布杀了董卓"]
	check_eq(Quests.current_quest(s)["id"], "dongui", "then 第四章 · 挟天子")


func test_chapter4_nobody_warns_you_until_ending_two() -> void:
	var q: Dictionary = GameData.get_db().quests.filter(func(x): return x["id"] == "dongui")[0]
	var sq: Dictionary = q["squares"]
	var s := SaveData.create()
	check(Quests.is_open(sq["chaohui"], s) and not Quests.is_open(sq["mimou"], s), "first time: 围府, no 貂蝉")
	check(sq["tonggui"]["record"] == q["ending"]["title"], "the trap ends in 结局三")
	s.flags = [q["ending"]["title"]]
	check(Quests.is_open(sq["mimou"], s) and not Quests.is_open(sq["chaohui"], s), "after 结局三: 貂蝉 comes")
	check(Quests.is_open(sq["dongtao"], s), "and the chapter runs on to 南阳")


func test_mengde_makes_strategist_skills_cheaper() -> void:
	## 策士 hardly attack, so their book cuts their skills' AP instead (never below 1)
	var b := Battle.start("boar", party(["zhouyu"]), 1, 0, {}, {}, false, {"troop_cost": {"strategist": 1}})
	var i := -1
	for k in b.leaders.size():
		if b.leaders[k]["leader"]["card"]["id"] == "zhouyu":
			i = k
	var u: Dictionary = b.leaders[i]
	var db := GameData.get_db()
	check_eq(b.cost(u, db.skills["huoshang"]), 2, "火上浇油 3 -> 2")
	check_eq(b.cost(u, db.skills["yehuo"]), 1, "火攻 stays at 1")
	var lord: Dictionary = b.leaders.filter(func(l): return l["leader"]["card"]["troop"] == "lord")[0]
	check_eq(b.cost(lord, db.skills["rengdao"]), 3, "not a 策士: no discount")


func test_lvbu_zhugeliang_and_baosanniang_are_never_drawn_the_first_time() -> void:
	## user rule: the first 吕布 / 诸葛亮 comes only from beating him (his fights drop him) or the story (he joins); 鲍三娘 only from her
	## event — never a random draw or chest. Once had, they come back through the history pool like any other card
	var db := GameData.get_db()
	for cid in ["lvbu", "zhugeliang", "baosanniang"]:
		check(not db.cards[cid]["in_pool"], cid + " is not in the public pool")
		var s := SaveData.create()
		check(not s.recruit_pool(db.cards[cid]["rarity"]).any(func(c): return c["id"] == cid), cid + " can't be drawn before you have had it")
		check(not s.chest_pools("", [])["public"]["general"].any(func(c): return c["id"] == cid), cid + " isn't in a chest before you have had it")
		s.seen = [cid]
		check(s.recruit_pool(db.cards[cid]["rarity"]).any(func(c): return c["id"] == cid), cid + " can be drawn again once you have had it")
	for cid in ["lvbu", "zhugeliang"]:
		var drops: Array = db.enemies.values().filter(func(e): return e["drop"] == cid)
		check(drops.size() >= 5, "%s drops from his own fights (%d)" % [cid, drops.size()])
	check(db.enemies["m8_kongming"]["card"] != "zhugeliang", "the fight keeps its own stats card")
	var s2 := SaveData.create()
	var got: Array = s2.chest_after_battle(RandomNumberGenerator.new(), 0.0, true, [], "zhugeliang", 0.0, "")
	check(got.any(func(c): return c["id"] == "zhugeliang"), "the first win always hands him over")


func test_each_chapter_cleared_hands_out_the_next_lord_card_for_the_route() -> void:
	var db := GameData.get_db()
	var s := SaveData.create()
	s.flags = ["出生：冀州无极"]
	check(s.is_north(), "the birth flag marks the north route in later chapters too")
	var base := db.build_lord("阿明", 1.0, true)
	check_eq(s.lord_form(), "", "no lord card yet")
	var q: Dictionary = db.quests[0]
	check_eq(Quests.grant_lord_form(q, s), "lord_north_cloak", "the first chapter clear hands out the first card of the random draw (no SSR)")
	check_eq(Quests.grant_lord_form(q, s), "", "once per chapter")
	var lord := s.lord()
	check(lord["hp"] > base["hp"] and lord["at"] > base["at"], "the card makes the lord stronger")
	check_eq(lord["person"], "lord_north_cloak", "and brings its own face")
	var south := SaveData.create()
	check_eq(Quests.grant_lord_form(q, south), "lord_south_boat", "the south route has its own card")
	check(s.new_lap().lord_forms.is_empty(), "a new lap starts without the lord cards")
	check(s.new_lap(true).lord_forms.has("lord_north_cloak"), "…unless the test option keeps the collection")


func test_the_default_lord_card_is_not_a_second_lord_in_the_party_screen() -> void:
	var s := SaveData.create()
	s.lord_forms = ["lord_default"]
	check(s.route_lord_forms().is_empty(), "only the default card: nothing but the plain lord to show")
	check_eq(s.lord_form(), "", "…and the plain lord is the one in use")
	s.lord_forms = ["lord_default", "lord_south_armor"]
	check_eq(s.route_lord_forms(), ["lord_south_armor"], "a real version joins the plain lord, the default does not count twice")


func test_the_lord_card_given_is_random_among_those_not_yet_had() -> void:
	var db := GameData.get_db()
	var q: Dictionary = db.quests[0]
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var seen := {}
	for k in 12:
		var s := SaveData.create()
		s.flags = ["出生：冀州无极"] if k % 2 == 0 else []
		var got := Quests.grant_lord_form(q, s, rng)
		check(got != "" and db.lord_forms[got]["route"] == ("north" if k % 2 == 0 else "south"), "a card of this route: " + got)
		seen[got] = true
	check(seen.size() > 2, "different cards turn up")
	check(seen.keys().any(func(k): return db.lord_forms[k]["route"] == "north") and seen.keys().any(func(k): return db.lord_forms[k]["route"] == "south"), "both routes' cards turn up")


func test_every_chapter_of_a_route_has_a_lord_card_to_give_and_one_is_in_use() -> void:
	var db := GameData.get_db()
	var s := SaveData.create()
	s.flags = ["出生：冀州无极"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var north: int = db.lord_form_grants.filter(func(f): return db.lord_forms[f]["route"] == "north" and not f in db.lord_form_fixed.values()).size()
	for k in north:
		s.lord_form_paid = ""
		var got := Quests.grant_lord_form(db.quests[0], s, rng)
		check(got != "", "chapter %d of the north route still hands one out" % (k + 1))
		check_eq(s.lord_form(), got, "the newest card is in use until another is picked")
	check_eq(s.route_lord_forms().size(), north)
	var base := s.lord_with_form("")
	var pick := "lord_north_guard"
	s.lord_form_pick = pick
	check_eq(s.lord_form(), pick, "a card picked in 整备 is the one in use")
	var guard := s.lord()
	check_eq(int(guard["hp"]), int(s.lord_with_form(pick)["hp"]))
	check(guard["hp"] > base["hp"] and guard["at"] > base["at"], "its bonus counts")
	# stats = this card's own face numbers × the card's tier, like any general; the others do not add
	var tier_mult := float(db.gacha["tiers"][s.form_tier(pick)]["mult"])
	check(absi(int(guard["hp"]) - int(round(float(db.lord_forms[pick]["hp"]) * tier_mult))) <= 1, "and only its own, at its own tier (the others do not add)")
	check(absi(int(guard["at"]) - int(round(float(db.lord_forms[pick]["at"]) * tier_mult))) <= 1)
	s.lord_form_pick = "base"
	check_eq(s.lord_form(), "", "the plain lord can be put back")
	var held_copies := s.form_copies.duplicate()
	var lord_before := s.lord_copies
	s.lord_form_paid = ""
	var again := Quests.grant_lord_form(db.quests[0], s, rng)
	check(again != "" and s.lord_form_dupe, "all held: a random one again")
	if again == db.lord_form_default:
		check_eq(s.lord_copies, lord_before + 1, "…the plain lord card gains a level")
	else:
		check_eq(int(s.form_copies[again]), int(held_copies.get(again, 0)) + 1, "…which is one more level of that very card")
	check_eq(s.route_lord_forms().size(), north, "the card list does not grow")


func test_two_recruits_wait_for_the_badend_that_belongs_to_them() -> void:
	## 夏侯兰 can only be taken on after 「结局六 · 失律」, 张宁 only after 「结局二 · 覆巢」 (the 张夫人 badend)
	var db := GameData.get_db()
	var q: Dictionary = {}
	for x in db.quests:
		if x["id"] == "heishan":
			q = x
	var save := SaveData.create()
	var junfa: Dictionary = q["squares"]["hs_xiahoulan_choice"]["choose"][0]
	var peiqian: Dictionary = q["squares"]["hs_xiahoulan_choice"]["choose"][1]
	var rescue: Dictionary = q["squares"]["hs_save_choice"]["choose"][0]
	var ignore: Dictionary = q["squares"]["hs_save_choice"]["choose"][1]
	check(Quests.option_locked(save, junfa) and Quests.option_locked(save, rescue), "both greyed on a first run")
	check(not Quests.option_locked(save, peiqian) and not Quests.option_locked(save, ignore), "the other options stay open")
	check(Quests.option_hint(save, rescue).contains("结局二 · 覆巢"), "and the button says what is needed: " + Quests.option_hint(save, rescue))
	save.flags = ["出生：冀州无极", "结局二 · 覆巢"]
	check(not Quests.option_locked(save, rescue) and Quests.option_locked(save, junfa), "覆巢 opens 张宁's rescue only")
	save.flags = ["出生：冀州无极", "结局二 · 覆巢", "结局六 · 失律"]
	check(not Quests.option_locked(save, junfa), "失律 opens 夏侯兰's martial law")


func test_endings_are_config_and_every_story_ending_is_in_it() -> void:
	var db := GameData.get_db()
	check(db.ending_order.size() >= 11 and db.endings.size() == db.ending_order.size(), "the ending table is loaded")
	for q in db.quests:
		if not q["ending"].is_empty():
			var e: Dictionary = db.endings[q["ending"]["id"]]
			check(e["built"] and e["quest"] == q["id"] and q["ending"]["title"] == e["title"], "%s: its ending is an entry that points back at it" % q["id"])
	var titles := {}
	for id in db.ending_order:
		var e: Dictionary = db.endings[id]
		check(not titles.has(e["title"]), "unique title " + e["title"])
		titles[e["title"]] = true
		for key in ["route", "chapter", "kind", "who", "trigger", "hint", "unlock"]:
			check(str(e[key]) != "", "%s has a %s" % [id, key])
		check(not e["built"] or (str(e["text"]) != "" and e["quest"] != ""), id + ": a built ending has its text and quest")
	# the flag a square records is the ending's title, word for word
	for q in db.quests:
		for s in q["squares"].values():
			for rec in [s["record"], s["record_win"], s["record_lose"]]:
				if str(rec).begins_with("结局"):
					check(titles.has(rec), "%s records an ending that is not in the table: %s" % [s["id"], rec])


func test_the_book_tracks_which_endings_were_reached() -> void:
	var s := SaveData.create()
	check_eq(s.endings_reached(), [], "none yet")
	s.flags = ["结局二 · 覆巢", "董白：留下"]
	check_eq(s.endings_reached(), ["fuchao"])
	s.run_records = ["结局一 · 玉碎"]
	check_eq(s.endings_reached(), ["yusui", "fuchao"], "this run's own ending counts, in table order")
	var again := s.new_lap()
	check(again.endings_reached().has("fuchao"), "kept across 周目")


func test_north_chapters_two_to_four_fork_into_a_battle_lane_and_a_rogue_lane() -> void:
	## every plain fork of 洛阳烟云 / 黑山风云 / 双凤乱太行 (not a story choice, not a requires/unless split) has lanes of 2+ squares,
	## one with fights, one without (？ / 宝箱 / 招募) — so the choice is "fight for it" or "look around", never one lonely square each
	var db := GameData.get_db()
	var forks := 0
	for qid in ["luoyang_n", "heishan", "beihai", "xuzhou"]:
		var q: Dictionary = {}
		for x in db.quests:
			if x["id"] == qid:
				q = x
		var sq: Dictionary = q["squares"]
		var preds := {}
		for s in sq.values():
			for n in s["next"]:
				preds[n] = int(preds.get(n, 0)) + 1
		for s in sq.values():
			if s["type"] == "choose" or s["next"].size() < 2:
				continue
			if s["next"].any(func(n): return sq[n]["requires"] != "" or sq[n]["unless"] != ""):
				continue
			forks += 1
			var lanes: Array = []
			for first in s["next"]:
				var lane: Array = [first]
				while sq[lane[-1]]["next"].size() == 1 and int(preds.get(sq[lane[-1]]["next"][0], 0)) == 1:
					lane.append(sq[lane[-1]]["next"][0])
				lanes.append(lane)
			var with_fights := 0
			for lane in lanes:
				check(lane.size() >= 2, "%s: the lane from %s via %s is a single square" % [qid, s["id"], lane[0]])
				if lane.any(func(id): return sq[id]["type"] == "battle"):
					with_fights += 1
			check(with_fights >= 1 and with_fights < lanes.size(), "%s: the fork at %s needs a fight lane and a no-fight lane" % [qid, s["id"]])
	check(forks >= 12, "found the forks (%d)" % forks)


func test_difficulty_lasts_the_whole_lap_but_danger_is_this_chapters() -> void:
	## 难度 (what beating 吕布 raises) stays for every later chapter of the lap; 险 taken from a ？ event only lasts the chapter
	var db := GameData.get_db()
	var s := SaveData.create()
	s.difficulty = 1
	s.danger = 2
	var step := float(db.battle["difficulty_step"])
	var dstep := float(db.battle["danger_step"])
	check(is_equal_approx(float(Quests.mods(s)["enemy"]), step + 2.0 * dstep), "both count while the chapter runs")
	Quests.begin(db.quests[1], s)  # the next chapter starts
	check_eq(s.danger, 0, "险 is gone")
	check_eq(s.difficulty, 1, "难度 stays")
	check(is_equal_approx(float(Quests.mods(s)["enemy"]), step), "so later chapters keep the one and not the other")
	var lap2 := s.new_lap()
	check_eq(lap2.difficulty, 0, "a new lap starts the 难度 again — from the lap head start (battle.lap_step) instead")


func test_every_debug_chapter_jump_lands_on_a_real_square_of_its_chapter() -> void:
	for jump in ChapterJumps.LIST:
		var s := ChapterJumps.jump_save(jump)
		var q: Variant = Quests.current_quest(s)
		check(q != null, "%s: a chapter is open" % jump["label"])
		if q == null:
			continue
		check(q["squares"].has(s.square) and Quests.is_open(q["squares"][s.square], s), "%s: standing on an open square (%s)" % [jump["label"], s.square])
		check(str(jump["label"]).begins_with(Quests.title(q, s).split(" · ")[0]), "%s: the chapter number matches (%s)" % [jump["label"], Quests.title(q, s)])


func test_chapter_two_start_gives_only_the_one_not_picked_at_the_plan() -> void:
	## 第一章 定计 already hands the picked one over (孙策 or 周瑜); 第二章's first square gives the other, not both again
	var q: Dictionary = GameData.get_db().quests[1]  # 第二章 · 讨伐董卓
	var s := SaveData.create()
	s.flags = ["定计：孙策正面强攻"]
	s.grant_card("sunce", true)  # what the choice gave
	Quests.begin(q, s, rng(1))
	Quests.resolve(q, s, rng(1))
	check(s.has_card("zhouyu"), "周瑜 joins now")
	check_eq(s.copies("sunce"), 1, "孙策 is not handed over a second time")
	var s2 := SaveData.create()
	s2.flags = ["定计：周瑜调虎离山"]
	s2.grant_card("zhouyu", true)
	Quests.begin(q, s2, rng(1))
	Quests.resolve(q, s2, rng(1))
	check(s2.has_card("sunce") and s2.copies("zhouyu") == 1, "the other way round")


func test_about_half_of_the_ordinary_fights_are_a_random_ambush() -> void:
	var q: Dictionary = GameData.get_db().quests[4]  # 第三章 · 传国玉玺: lots of ordinary fights
	var s := SaveData.create()
	Quests.begin(q, s, rng(5))
	var normal := 0
	for sid in q["squares"]:
		var sq: Dictionary = q["squares"][sid]
		if sq["type"] == "battle" and not sq["boss"] and not sq["elite"]:
			normal += 1
		else:
			check(not s.ambushes.has(sid), "%s is not an ordinary fight, never rolled" % sid)
	check(s.ambushes.size() > normal / 4 and s.ambushes.size() < normal * 3 / 4, "about half of %d ordinary fights: %d" % [normal, s.ambushes.size()])
	var s2 := SaveData.create()
	Quests.begin(q, s2, rng(6))
	check(s.ambushes != s2.ambushes, "a different run rolls different ones")


func test_enemy_strength_follows_one_formula_and_never_inverts() -> void:
	## battle.scaling: a chapter's first column sits on strength × base × the chapters' growth so far (exponent easing first → last), its last column on the same formula one chapter later and the
	## columns between are interpolated, so no later column is easier than an earlier one on a route and a chapter ends where the next one begins
	var db := GameData.get_db()
	var cfg: Dictionary = db.battle["scaling"]
	var by_route := [["prologue", "taodong", "yuxi", "dongui", "jingxiang", "huainan_s", "jiangdong", "menghu"], ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng", "longhu", "xiliang", "sanfang", "tianqing", "guandu"]]
	for q in db.quests:
		var qid: String = q["id"]
		if not cfg["order"].has(qid):
			continue
		var want := float(cfg["base"])
		for k in range(1, int(cfg["order"][qid]) + 1):
			want *= pow((k + float(cfg["offset"])) / (k - 1 + float(cfg["offset"])), lerpf(float(cfg["exponent_first"]), float(cfg["exponent_last"]), minf(float(k), float(cfg["exponent_chapters"])) / float(cfg["exponent_chapters"])))
		want *= 1000000.0 * float(cfg["strength"]) * float(cfg["chapter"].get(qid, cfg["chapter_default"]))
		check(absf(Quests.target_power(qid, 0.0) - want) < 1.0, "%s starts on the formula" % qid)
		check(Quests.target_power(qid, 0.5) >= Quests.target_power(qid, 0.0) and Quests.target_power(qid, 1.0) >= Quests.target_power(qid, 0.5), "%s never gets easier along the chapter" % qid)
	for route in by_route:
		for i in range(1, route.size()):
			check(Quests.target_power(route[i], 0.0) >= Quests.target_power(route[i - 1], 0.0), "%s is not easier than %s" % [route[i], route[i - 1]])
			if route[i - 1] != "prologue" and cfg["chapter"].get(route[i], cfg["chapter_default"]) == cfg["chapter"].get(route[i - 1], cfg["chapter_default"]) and cfg["order"][route[i]] == cfg["order"][route[i - 1]] + 1:
				check(absf(Quests.target_power(route[i - 1], 1.0) - Quests.target_power(route[i], 0.0)) < 1.0, "%s ends where %s begins" % [route[i - 1], route[i]])
	check(Quests.target_power("yuxi", 0.0) > Quests.target_power("taodong", 1.0) - 1.0, "chapter 3 opens no easier than chapter 2 ends")
	var weak := Quests._scale_for("yuxi", 0.0, 1.0)
	cfg["strength"] = float(cfg["strength"]) * 2.0  # the one knob moves everything together
	var strong := Quests._scale_for("yuxi", 0.0, 1.0)
	cfg["strength"] = float(cfg["strength"]) / 2.0
	check(absf(strong / weak - sqrt(2.0)) < 0.001, "strength x2 = power x2 (hp and attack x sqrt 2)")


func test_every_chapter_levels_the_lord_card_it_hands_out_on_its_own() -> void:
	## the lord is split into many cards (cards.json lord_forms); each chapter hands one out and THAT card gains a level (a copy of its own)
	var db := GameData.get_db()
	var s := SaveData.create()
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	s.lord_form_paid = ""
	var first := Quests.grant_lord_form(db.quests[0], s, rng, true)  # chapter 1: the plain lord
	check_eq(first, db.lord_form_default)
	check_eq(s.lord_copies, 1, "the plain lord card: a new card is level 1, not a level up")
	s.lord_form_paid = ""
	var second := Quests.grant_lord_form(db.quests[1], s, rng)
	check(second != db.lord_form_default and second != "", "a new lord card")
	check_eq(s.form_copies_of(second), 1, "a new card starts at level 1 (铜)")
	check_eq(s.lord_copies, 1, "…and does not raise the plain lord")
	var lord_a := s.lord_with_form(second)
	var plain := s.lord_with_form("")
	check(lord_a["hp"] > plain["hp"] or lord_a["at"] > plain["at"], "its bonus counts (an R card may trade hp for attack)")
	# hand the same card out again: that card levels
	for _i in 3:
		s.lord_form_paid = ""
		s.form_copies[second] = int(s.form_copies[second]) + 1
	check_eq(s.form_tier(second), 1, "four copies of one card = 银, on its own")
	check_eq(s.tier("lord"), 0, "…while the plain lord is still 铜")
	var up := s.lord_with_form(second)
	check(up["hp"] > lord_a["hp"], "the card's bonus grows with its own tier")


func test_after_four_chapters_the_lord_holds_four_cards_all_level_one() -> void:
	var db := GameData.get_db()
	var s := SaveData.create()
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for k in 4:
		s.lord_form_paid = ""
		Quests.grant_lord_form(db.quests[k], s, rng, k == 0)
	check_eq(s.lord_forms.size(), 4, "four lord cards")
	for fid in s.lord_forms:
		check_eq(s.form_copies_of(fid), 1, "%s is level 1 (铜)" % fid)
		check_eq(s.form_tier(fid), 0, "…铜")


func test_second_lap_chapter_one_levels_the_default_lord_card_to_two() -> void:
	var db := GameData.get_db()
	var s := SaveData.create()
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var first := Quests.grant_lord_form(db.quests[0], s, rng, true)
	check_eq(s.form_copies_of(first), 1, "lap 1: level 1")
	s.lord_form_paid = ""
	var second := Quests.grant_lord_form(db.quests[1], s, rng)
	check_eq(s.form_copies_of(second), 1, "lap 1 chapter 2's card: level 1")
	s.commit_history()
	var n := s.new_lap()
	var again := Quests.grant_lord_form(db.quests[0], n, rng, true)
	check_eq(again, first)
	check_eq(n.form_copies_of(again), 2, "lap 2 chapter 1: the card is handed out again — level 2")
	n.lord_form_paid = ""
	for _i in 12:  # the other card comes round again in lap 2 (the pool of cards not held yet runs out of the first-lap ones last)
		n.lord_form_paid = ""
		var got := Quests.grant_lord_form(db.quests[1], n, rng)
		if got == second:
			check_eq(n.form_copies_of(got), 2, "…and so does any other card of lap 1")
			break


func test_a_chapters_soldier_pool_holds_only_soldiers() -> void:
	## the pool is picked by scope; generals share the scope but must never turn up in a soldier offer
	var db := GameData.get_db()
	var s := SaveData.create()
	for qq in db.quests:
		for c in Quests.pools(qq, s)["soldier_pool"]:
			check(db.cards[c]["soldier"] and not db.cards[c]["beast"], "%s: soldier_pool holds a soldier, not %s" % [qq["id"], c])


func test_a_chapters_lord_card_comes_with_its_first_square() -> void:
	## chapters from the second on hand their lord card out on arrival at the first square (not after the first step); once
	var db := GameData.get_db()
	var s := SaveData.create()
	s.flags = ["董白：留下"]
	var q1: Dictionary = db.quests[0]
	Quests.begin(q1, s, rng(3))
	check(Quests.start_grant(q1, s, rng(3)).is_empty(), "the first chapter's card waits for its first story square")
	var q2: Dictionary = db.quests[1]
	var s2 := SaveData.create()
	Quests.begin(q2, s2, rng(3))
	var given := Quests.start_grant(q2, s2, rng(3))
	check_eq(given.size(), 1, "chapter two's lord card comes on arrival")
	check(s2.lord_forms.has(given[0]["form"]), "…and is held")
	check(Quests.start_grant(q2, s2, rng(3)).is_empty(), "only once per chapter")


func test_the_dice_land_when_the_square_is_reached_and_stay() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": "zuoci"}
	var ev: Dictionary = GameData.get_db().events["zuoci"]
	var first := Quests.rolled_option(s, ev, rng(7))
	for seed_value in 10:
		check_eq(Quests.rolled_option(s, ev, rng(seed_value)), first, "the same option every time the square is shown")
	check(s.event_rolls.has("road"), "and it is kept in the save")


func test_the_han_army_soldiers_only_come_from_fighting_liu_bei() -> void:
	## 汉军 (刘备·诸葛亮): one 高级兵 (veteran, R-level face numbers) for every troop type, and nobody else's —
	## faction "han" keeps them out of every public chest; they come only as a 汉军 enemy's or a 刘备 general's card
	var db := GameData.get_db()
	var han: Array = db.cards.values().filter(func(c): return c.get("faction", "") == "han")
	var troops := {}
	for c in han:
		check(c["soldier"] and c["elite"] and c["veteran"], c["id"] + " is a 高级兵")
		troops[c["troop"]] = true
	check_eq(troops.keys().size(), db.troops.keys().size() - 1, "a 汉军 soldier for every troop but the lord's")
	var s := SaveData.create()
	for k in ["public", "chapter", "history"]:
		for c in s.chest_pools("taodong")[k]["soldier"]:
			check(c.get("faction", "") != "han", "%s shows up in another chapter's chest" % c["id"])
	check(db.soldier_cards().all(func(c): return c.get("faction", "") == ""), "no 汉军 card in the plain soldier list")
	for eid in db.enemies:
		var e: Dictionary = db.enemies[eid]
		var cid: String = e.get("card", "")
		if cid != "" and db.cards[cid].get("faction", "") == "han":
			check(e["name"].begins_with("汉军") or ["guanping", "chendao", "zhangfei", "guanyu", "zhugeliang", "liubei", "maliang"].has(e["portrait"]),
				"%s drops a 汉军 card but isn't 刘备's (%s)" % [eid, e["name"]])


func test_the_wei_army_soldiers_only_come_from_fighting_cao_cao() -> void:
	## 魏军 (曹操): like 汉军 — one 高级兵 per troop type, same R-level face numbers, faction "wei" keeps them out of
	## every public chest; they come only as a 魏军 enemy's or a 曹将's card
	var db := GameData.get_db()
	var wei: Array = db.cards.values().filter(func(c): return c.get("faction", "") == "wei")
	var troops := {}
	for c in wei:
		check(c["soldier"] and c["elite"] and c["veteran"], c["id"] + " is a 高级兵")
		check_eq(c["hp"] + c["at"], 130, c["id"] + " is as strong as a 汉军 soldier")
		troops[c["troop"]] = true
	check_eq(troops.keys().size(), db.troops.keys().size() - 1, "a 魏军 soldier for every troop but the lord's")
	check(db.soldier_cards().all(func(c): return c.get("faction", "") == ""), "no 魏军 card in the plain soldier list")
	for eid in db.enemies:
		var e: Dictionary = db.enemies[eid]
		var cid: String = e.get("card", "")
		if cid != "" and db.cards[cid].get("faction", "") == "wei":
			check(e["name"].begins_with("魏军") or ["xiahouyuan", "caoren", "xiahoudun", "caocao"].has(e["portrait"]),
				"%s drops a 魏军 card but isn't 曹操's (%s)" % [eid, e["name"]])


func test_the_yuan_army_soldiers_only_come_from_fighting_yuan_shao() -> void:
	## 袁军 (冀州兵、先登): faction "yuan" keeps them out of every public chest; they come only from fighting 袁绍's army
	var db := GameData.get_db()
	var yuan: Array = db.cards.values().filter(func(c): return c.get("faction", "") == "yuan")
	check_eq(yuan.map(func(c): return c["id"]).size(), 4, "冀州长戟、骑卒、强弩、先登死士")
	check(db.soldier_cards().all(func(c): return c.get("faction", "") == ""), "no 袁军 card in the plain soldier list")
	for c in yuan:
		check(not db.card_chapters.get(c["id"], []).is_empty(), c["id"] + " is handed out somewhere")
		for q in db.card_chapters.get(c["id"], []):
			check(q in ["heishan", "beihai", "yecheng", "luoyang_n", "longhu", "xiliang"], "%s comes from %s" % [c["id"], q])


func test_gongsun_zan_like_sun_jian_is_never_drawn() -> void:
	## 公孙瓒 burns himself at 易京 (北线第七章): like 孙坚 he is a story figure, no chest or 招贤 ever offers him
	var db := GameData.get_db()
	check(not db.cards["gongsunzan"]["in_pool"], "公孙瓒 is out of the public pool")
	check(db.card_chapters.get("gongsunzan", []).is_empty(), "no chapter hands 公孙瓒 out")


func test_a_chapter_hands_out_only_its_own_soldiers_and_the_routes_public_ones() -> void:
	## a soldier with a faction, or one some chapter hands out, never turns up in another chapter (chests, event 「soldier」 / offers from the pool)
	var db := GameData.get_db()
	for q in db.quests:
		var pool: Array = Quests.pools(q, SaveData.create())["soldier_pool"]
		if q["soldier_scope"] == "":
			continue
		for cid in pool:
			var c: Dictionary = db.cards[cid]
			var own: bool = db.card_chapters.get(cid, []).has(q["id"])
			check(own or (c.get("faction", "") == "" and (db.is_public(cid) or c.get("public", false))), "%s hands out %s (%s) from somewhere else" % [q["id"], cid, c.get("faction", "")])
			check(c.get("scope", "") in ["", q["soldier_scope"]], "%s hands out %s from the other route" % [q["id"], cid])


func test_heishan_louluo_is_the_north_routes_own_soldier() -> void:
	## `public: true`: handed out in 第一章 and 第三章, yet it can turn up in any north chapter's chests
	var s := SaveData.create()
	s.flags.append("出生：冀州无极")
	check(s.chest_pools("yecheng")["public"]["soldier"].any(func(c): return c["id"] == "heishan_louluo"), "黑山喽啰 in 第七章's public pool")
	check(not s.chest_pools("yecheng")["public"]["soldier"].any(func(c): return c["id"] == "zheng_daoshou"), "郑家刀手 stays with 第四章")


func test_a_bad_end_lists_no_side_stories() -> void:
	## 结局二 · 覆巢 closes the 周目: the chapter it ended is in quests_cleared, but its ？小故事 wait for the next 周目
	var s := SaveData.create()
	s.flags = ["出生：冀州无极", "北线：班师冀州"]
	s.quests_cleared = ["prologue", "luoyang_n"]
	s.run_records = ["张宁：没救", "结局二 · 覆巢"]
	Quests.complete(GameData.get_db().quests.filter(func(x): return x["id"] == "heishan")[0], s)
	check(s.ended, "the bad end closed the 周目")
	check(Quests.side_stories(s).is_empty(), "no ？小故事 after a bad end: %s" % [Quests.side_stories(s).map(func(x): return x["id"])])


func test_every_side_story_has_a_reward() -> void:
	for list in GameData.get_db().side_stories.values():
		for st in list:
			check(Quests.side_reward_text(st) != "", "%s: no reward" % st["id"])


func test_a_side_story_can_hand_over_a_card() -> void:
	var s := SaveData.create()
	s.flags = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan"]
	s.merit = 10
	check(not s.owned.has("hanfu"))
	var r := Quests.open_side(s, "b_hanfu")
	check(s.owned.has("hanfu") and str(r["got"]).contains("韩馥"), "韩馥的印 hands over 韩馥: %s" % r)
	check_eq(s.merit, 0, "every story costs 10")


func test_the_chapter_page_card_comes_from_a_story_after_the_next_bad_end() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春"]
	s.quests_cleared = ["prologue"]
	check_eq(Quests.chapter_page("prologue", s).get("cg", ""), "rc_fuchun")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	check(not ids.call().has("s_rc_fuchun"), "not before 结局一 · 玉碎")
	s.flags = ["结局一 · 玉碎"]
	check(ids.call().has("s_rc_fuchun"), "opens once 玉碎 has been reached")
	s.merit = 10
	Quests.open_side(s, "s_rc_fuchun")
	check(s.owned.has("rc_fuchun"), "针脚 hands over 富春·慈母与儿女")
	var n := SaveData.create()
	n.run_records = ["出生：冀州无极"]
	n.flags = ["结局一 · 玉碎"]
	n.quests_cleared = ["prologue"]
	check(not Quests.side_stories(n).map(func(x): return x["id"]).has("s_rc_fuchun"), "not in a north 周目")


func test_the_north_first_page_and_its_card_after_fuchao() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue"]
	check_eq(Quests.chapter_page("prologue", s).get("cg", ""), "rc_wuji")
	check(not Quests.side_stories(s).map(func(x): return x["id"]).has("s_rc_wuji"), "not before 结局二 · 覆巢")
	s.flags = ["结局二 · 覆巢"]
	s.merit = 10
	Quests.open_side(s, "s_rc_wuji")
	check(s.owned.has("rc_wuji"), "雪夜算盘 hands over 无极·商母与幼女")


func test_dongbai_page_and_card_need_her_kept_and_her_own_bad_end() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春"]
	s.quests_cleared = ["prologue", "taodong"]
	check_eq(Quests.chapter_page("taodong", s).get("cg", ""), "", "no 董白 picture when she was not kept")
	s.run_records.append("董白：留下")
	check_eq(Quests.chapter_page("taodong", s).get("cg", ""), "rc_taodong")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局一 · 玉碎"]
	check(not ids.call().has("s_rc_taodong"), "another bad end is not hers")
	s.flags = ["结局三 · 同归"]
	check(ids.call().has("s_rc_taodong"), "both lines hold: open")
	s.merit = 10
	Quests.open_side(s, "s_rc_taodong")
	check(s.owned.has("rc_taodong"))


func test_lvlingqi_page_and_card_need_her_own_bad_end() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n"]
	check_eq(Quests.chapter_page("luoyang_n", s).get("cg", ""), "rc_luoyang_n")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局二 · 覆巢"]
	check(not ids.call().has("s_rc_luoyang_n"), "another bad end is not hers")
	s.flags = ["结局四 · 绝罚"]
	check(ids.call().has("s_rc_luoyang_n"), "绝罚 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_luoyang_n")
	check(s.owned.has("rc_luoyang_n"), "树枝筷子 hands over 吕玲绮·树枝筷子")


func test_zhangning_page_and_card_need_her_saved_and_shilv() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan"]
	check_eq(Quests.chapter_page("heishan", s).get("cg", ""), "", "no 张宁 picture when she was not saved")
	s.run_records.append("张宁：救下")
	check_eq(Quests.chapter_page("heishan", s).get("cg", ""), "rc_heishan")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局二 · 覆巢"]
	check(not ids.call().has("s_rc_heishan"), "覆巢 alone is not enough: it is what lets her join")
	s.flags = ["结局二 · 覆巢", "结局六 · 失律"]
	check(ids.call().has("s_rc_heishan"), "失律 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_heishan")
	check(s.owned.has("rc_heishan"), "一起碾药 hands over 张宁·一起碾药")


func test_zhangning_joins_at_the_rest_after_her_bandage_cg_not_on_arriving() -> void:
	var q: Dictionary = {}
	for x in GameData.get_db().quests:
		if x["id"] == "heishan":
			q = x
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quest = "heishan"
	s.square = "hs_zhangyan"
	s.resolved = false
	Quests.resolve(q, s, rng(0), -1)
	check(not s.owned.has("zhangning"), "not yet on the 黑山大寨 square")
	s.square = "hs_rest1"
	s.resolved = false
	var gained := Quests.resolve(q, s, rng(0), -1)
	check(s.owned.has("zhangning") and gained.size() == 1, "she joins when you rest, after the 包扎 CG")


func test_zheng_jiang_page_and_card_need_them_reconciled_and_shilv() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极", "郑姜：和好"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan", "beihai"]
	check_eq(Quests.chapter_page("beihai", s).get("cg", ""), "rc_beihai")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局四 · 绝罚"]
	check(not ids.call().has("s_rc_beihai"), "绝罚 is what reconciles them: not enough")
	s.flags = ["结局四 · 绝罚", "结局六 · 失律"]
	check(ids.call().has("s_rc_beihai"), "失律 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_beihai")
	check(s.owned.has("rc_beihai"), "双凤早饭 hands over 郑姜·双凤早饭")


func test_zhangning_new_year_page_and_card_after_duanqiao() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou"]
	check_eq(Quests.chapter_page("xuzhou", s).get("cg", ""), "rc_xuzhou")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局二 · 覆巢", "结局四 · 绝罚", "结局六 · 失律"]
	check(not ids.call().has("s_rc_xuzhou"), "her own bad ends come before this page: not enough")
	s.flags.append("结局八 · 断桥")
	check(ids.call().has("s_rc_xuzhou"), "断桥 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_xuzhou")
	check(s.owned.has("rc_xuzhou"), "除夕香囊 hands over 张宁·除夕香囊")


func test_dufuren_page_and_card_after_her_own_duanqiao() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n"]
	check_eq(Quests.chapter_page("huainan_n", s).get("cg", ""), "rc_huainan_n")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	check(not ids.call().has("s_rc_huainan_n"), "not before 断桥")
	s.flags = ["结局八 · 断桥"]
	check(ids.call().has("s_rc_huainan_n"), "her own 断桥 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_huainan_n")
	check(s.owned.has("rc_huainan_n"), "新酒 hands over 杜夫人·新酒")


func test_zhaoyun_mizhen_page_and_card_after_yice() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng"]
	check_eq(Quests.chapter_page("yecheng", s).get("cg", ""), "rc_yecheng")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局十 · 枯井"]
	check(not ids.call().has("s_rc_yecheng"), "枯井 is what opens this page's route: not enough")
	s.flags.append("结局十二 · 遗策")
	check(ids.call().has("s_rc_yecheng"), "遗策 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_yecheng")
	check(s.owned.has("rc_yecheng"), "黎阳的船 hands over 赵云·黎阳的船")


func test_guojia_page_needs_him_alive_and_the_card_waits_for_duanxian() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng", "longhu"]
	check_eq(Quests.chapter_page("longhu", s).get("cg", ""), "", "no 郭嘉 picture on the 遗策 route")
	s.run_records.append("北线：郭嘉随军")
	check_eq(Quests.chapter_page("longhu", s).get("cg", ""), "rc_longhu")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局十二 · 遗策"]
	check(not ids.call().has("s_rc_longhu"), "遗策 is what keeps him alive: not enough")
	s.flags.append("结局十四 · 断弦")
	check(ids.call().has("s_rc_longhu"), "断弦 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_longhu")
	check(s.owned.has("rc_longhu"), "最后一个葫芦 hands over 郭嘉·最后一个葫芦")


func test_mayunlu_page_needs_the_ma_family_and_the_card_waits_for_luoshang() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng", "longhu", "xiliang"]
	check_eq(Quests.chapter_page("xiliang", s).get("cg", ""), "", "no 马云騄 picture on the 断弦 route")
	s.run_records.append("北线：西凉归附")
	check_eq(Quests.chapter_page("xiliang", s).get("cg", ""), "rc_xiliang")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局十四 · 断弦"]
	check(not ids.call().has("s_rc_xiliang"), "断弦 is what saves the 马 family: not enough")
	s.flags.append("结局十六 · 洛殇")
	check(ids.call().has("s_rc_xiliang"), "洛殇 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_xiliang")
	check(s.owned.has("rc_xiliang"), "那只羊 hands over 马云騄·那只羊")


func test_zhenmi_page_needs_hulao_broken_and_the_card_waits_for_zhumie() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng", "longhu", "xiliang", "sanfang"]
	check_eq(Quests.chapter_page("sanfang", s).get("cg", ""), "", "no 甄宓 picture on the 洛殇 route")
	s.run_records.append("北线：破虎牢")
	check_eq(Quests.chapter_page("sanfang", s).get("cg", ""), "rc_sanfang")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局十六 · 洛殇"]
	check(not ids.call().has("s_rc_sanfang"), "洛殇 is what brings 庞统: not enough")
	s.flags.append("结局十八 · 烛灭")
	check(ids.call().has("s_rc_sanfang"), "烛灭 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_sanfang")
	check(s.owned.has("rc_sanfang"), "热汤面 hands over 甄宓·热汤面")


func test_the_hero_himself_closes_the_north_and_his_lord_card_waits_for_guandu() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	s.quests_cleared = ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou", "huainan_n", "yecheng", "longhu", "xiliang", "sanfang", "tianqing"]
	check_eq(Quests.chapter_page("tianqing", s).get("cg", ""), "rc_tianqing")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	s.flags = ["结局十八 · 烛灭"]
	check(not ids.call().has("s_rc_tianqing"), "not before the north's own ending")
	s.flags.append("北线结局 · 官渡")
	check(ids.call().has("s_rc_tianqing"), "官渡 opens it")
	s.merit = 10
	Quests.open_side(s, "s_rc_tianqing")
	check(s.lord_forms.has("lord_north_snow"), "初雪 hands over the lord card 主公·初雪")


func test_wenji_page_and_card() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春", "董白：留下"]
	s.quests_cleared = ["prologue", "taodong", "yuxi"]
	check_eq(Quests.chapter_page("yuxi", s).get("cg", ""), "", "no 蔡文姬 on the first way through")
	s.flags = ["结局一 · 玉碎"]
	check_eq(Quests.chapter_page("yuxi", s).get("cg", ""), "rc_yuxi")
	check(not Quests.side_stories(s).map(func(x): return x["id"]).has("s_rc_yuxi"), "not before her own 结局三 · 同归")
	s.flags.append("结局三 · 同归")
	s.merit = 10
	Quests.open_side(s, "s_rc_yuxi")
	check(s.owned.has("rc_yuxi"))


func test_diaochan_page_and_card() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春", "董白：留下"]
	s.quests_cleared = ["prologue", "taodong", "yuxi", "dongui"]
	check_eq(Quests.chapter_page("dongui", s).get("cg", ""), "", "貂蝉 only joins after 结局三 · 同归")
	s.flags = ["结局三 · 同归"]
	check_eq(Quests.chapter_page("dongui", s).get("cg", ""), "rc_dongui")
	check(not Quests.side_stories(s).map(func(x): return x["id"]).has("s_rc_dongui"), "not before 结局五 · 恨海")
	s.flags.append("结局五 · 恨海")
	s.merit = 10
	Quests.open_side(s, "s_rc_dongui")
	check(s.owned.has("rc_dongui"))


func test_diaochan_jingxiang_page_and_card() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春"]
	s.quests_cleared = ["prologue", "taodong", "yuxi", "dongui", "jingxiang"]
	check_eq(Quests.chapter_page("jingxiang", s).get("cg", ""), "")
	s.flags = ["结局三 · 同归"]
	check_eq(Quests.chapter_page("jingxiang", s).get("cg", ""), "rc_jingxiang")
	s.flags.append("结局五 · 恨海")
	s.merit = 10
	Quests.open_side(s, "s_rc_jingxiang")
	check(s.owned.has("rc_jingxiang"))


func test_erqiao_page_and_card() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春"]
	s.quests_cleared = ["prologue", "taodong", "yuxi", "dongui", "jingxiang", "huainan_s"]
	check_eq(Quests.chapter_page("huainan_s", s).get("cg", ""), "")
	s.run_records.append("二乔：解救")
	check_eq(Quests.chapter_page("huainan_s", s).get("cg", ""), "rc_huainan_s")
	s.flags = ["结局七 · 深锁"]
	s.merit = 10
	Quests.open_side(s, "s_rc_huainan_s")
	check(s.owned.has("rc_huainan_s"))


func test_sunce_daqiao_and_zhouyu_xiaoqiao_pages_and_cards() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春"]
	s.quests_cleared = ["prologue", "jiangdong"]
	check_eq(Quests.chapter_page("jiangdong", s).get("cg", ""), "rc_ceqiao")
	check_eq(Quests.chapter_page("menghu", s).get("cg", ""), "rc_yuqiao")
	var ids := func(): return Quests.side_stories(s).map(func(x): return x["id"])
	check(ids.call().has("s_sunce_baozi"), "孙策 alone is an ordinary story now")
	check(not ids.call().has("s_rc_ceqiao"), "the pair card waits for 结局九 · 匹夫")
	s.flags = ["结局九 · 匹夫", "结局十一 · 曲误"]
	s.merit = 20
	Quests.open_side(s, "s_rc_ceqiao")
	Quests.open_side(s, "s_sunce_baozi")
	check(s.owned.has("rc_ceqiao") and s.owned.has("rc_jiangdong"))
	s.quests_cleared.append("menghu")
	s.merit = 10
	Quests.open_side(s, "s_rc_yuqiao")
	check(s.owned.has("rc_yuqiao"))


func test_shangxiang_wuxian_and_zhurong() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春"]
	s.quests_cleared = ["prologue", "tianfu"]
	check_eq(Quests.chapter_page("tianfu", s).get("cg", ""), "")
	s.flags = ["孙权、孙尚香：入队", "吴苋：入队", "祝融：入队", "结局十三 · 香烬", "结局十五 · 算尽"]
	check_eq(Quests.chapter_page("tianfu", s).get("cg", ""), "rc_tianfu")
	check_eq(Quests.chapter_page("guanzhong", s).get("cg", ""), "rc_guanzhong")
	s.merit = 20
	Quests.open_side(s, "s_rc_tianfu")
	Quests.open_side(s, "s_zhurong")
	check(s.owned.has("rc_tianfu") and s.owned.has("sx_zhurong"))
	s.quests_cleared.append("guanzhong")
	s.merit = 10
	Quests.open_side(s, "s_rc_guanzhong")
	check(s.owned.has("rc_guanzhong"))


func test_a_story_shows_in_one_chapter_only_and_stays_read_across_laps() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春"]
	s.quests_cleared = ["prologue"]
	var ids := func(sv): return Quests.side_stories(sv).map(func(x): return x["id"])
	check(ids.call(s).has("s_jiujiu"), "open after its chapter")
	s.quests_cleared.append("taodong")
	check(not ids.call(s).has("s_jiujiu"), "missed: gone once the next chapter is done")
	check(ids.call(s).has("s_zumao"))
	s.merit = 10
	Quests.open_side(s, "s_zumao")
	s.quests_cleared.append("yuxi")
	check(not ids.call(s).has("s_zumao"), "read or not, it is gone once its chapter window has passed")
	var n := s.new_lap()
	check(n.side_seen.has("s_zumao") and not n.side_read.has("s_zumao"), "remembered as 看过 in the next 周目")
	n.run_records = ["出生：江东富春"]
	n.quests_cleared = ["prologue", "taodong"]
	n.merit = 10
	check(Quests.open_side(n, "s_zumao")["got"] != "" and n.merit == 0, "back in its chapter: paid and rewarded again")


func test_south_last_page_is_the_hero_and_his_lord_card() -> void:
	var s := SaveData.create()
	s.run_records = ["出生：江东富春"]
	s.quests_cleared = ["prologue", "luoyang_s"]
	check_eq(Quests.chapter_page("luoyang_s", s).get("cg", ""), "rc_luoyang_s")
	check(not Quests.side_stories(s).map(func(x): return x["id"]).has("s_rc_luoyang_s"), "not before 南线结局 · 赤壁")
	s.flags = ["南线结局 · 赤壁"]
	s.merit = 10
	Quests.open_side(s, "s_rc_luoyang_s")
	check(s.lord_forms.has("lord_south_river"), "洛水夜船 hands over the lord card 主公·洛水夜船")


func test_upgrade_never_offers_a_soldier() -> void:
	## 点化 is for generals and lord cards: 白马义从 (handed out by the story) is a soldier card, so it never shows up on the list
	var s := SaveData.create()
	s.grant_card("sunce")
	s.grant_card("baima_yicong", true)
	check(s.soldiers.get("baima_yicong", 0) == 1, "it is a soldier copy")
	check(not s.upgradable().has("baima_yicong"), "no soldier to 点化: %s" % [s.upgradable()])
	check(s.upgradable().has("sunce"), "the general is still there")


func test_ssr_lord_cards_come_only_from_their_fixed_chapter() -> void:
	var db := GameData.get_db()
	var ssr: Array = db.lord_forms.keys().filter(func(f): return db.lord_forms[f]["rarity"] == "SSR" and f in db.lord_form_grants)
	check(not ssr.is_empty(), "there are SSR lord cards")
	var rng := RandomNumberGenerator.new()
	for k in 30:
		rng.seed = k
		var s := SaveData.create()
		s.flags = ["出生：冀州无极"] if k % 2 == 0 else []
		for qi in db.quests.size():
			var q: Dictionary = db.quests[qi]
			if db.lord_form_fixed.has(q["id"]):
				continue
			s.lord_form_paid = ""
			var got := Quests.grant_lord_form(q, s, rng)
			check(not got in ssr, "chapter %s never hands out an SSR card (%s)" % [q["id"], got])
	for qid in db.lord_form_fixed:
		var q2: Dictionary = db.quests.filter(func(x): return x["id"] == qid)[0]
		var north: bool = db.lord_forms[db.lord_form_fixed[qid]]["route"] == "north"
		var s2 := SaveData.create()
		s2.flags = ["出生：冀州无极"] if north else []
		check_eq(Quests.grant_lord_form(q2, s2, rng), db.lord_form_fixed[qid], "%s always gives its SSR card" % qid)
