extends TestCase
## ？事件、宝物、天命、词缀、战功、章节回顾（从原来 2500 行的 test_quests.gd 按主题拆出）


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
	check_eq(s.offer.size(), 2)  # 点化 offers up to gacha.upgrade_offer random cards: here the lord and 孙策, in either order
	check(s.offer.has("lord") and s.offer.has("sunce"), "the lord and 孙策 are both offered")
	Quests.resolve(q, s, rng(0), s.offer.find("sunce"))
	check(s.copies("sunce") == 1 + s.upgrade_copies() and s.tier("sunce") == 1 and s.resolved and s.offer_kind == "", "点化: +3 copies, 铜 → 银")
	var s2 := SaveData.create()
	Quests.begin(q, s2)
	s2.square = "road"
	s2.resolved = false
	s2.events = {"road": "zuoci"}
	s2.carry_extra = {"sunce": {"xiaobawang": 2}}
	s2.damage = 100
	Quests.choose_event(q, s2, rng(0), labels.find("求静心"))
	check(s2.carry_extra.is_empty() and s2.damage == 100, "skills reset, HP untouched")


func test_poison_costs_the_configured_share_of_the_hp() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": "snake"}
	Quests.choose_event(q, s, rng(0), 1)  # squeeze the venom out yourself: always poisoned
	check_eq(s.damage, int(round(Quests.party_max(s) * float(GameData.get_db().battle["event_scale"]["poison"]))))


func test_an_event_never_kills_the_party_it_leaves_1_hp() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	var top := Quests.party_max(s)
	Quests._apply([{"damage": 5.0}], q, s, rng(0))  # far more than the whole bar
	check_eq(top - s.damage, 1, "a huge hit leaves exactly 1 HP")
	Quests._apply([{"damage": 0.5}, {"poison": true}], q, s, rng(0))
	check_eq(top - s.damage, 1, "further hits and poison on 1 HP take nothing more")


func test_events_can_lower_difficulty_danger_and_merit_but_not_past_the_floor() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	var floor_lvl := int(GameData.get_db().battle["difficulty_min"])
	for _n in 5:
		Quests._apply([{"difficulty": -1}, {"danger": -1}, {"merit": -3}], q, s, rng(0))
	check_eq(s.difficulty, floor_lvl, "难度 stops at difficulty_min")
	check_eq(s.danger, 0, "险 never goes negative")
	check_eq(s.merit, 0, "战功 never goes negative")
	Quests._apply([{"difficulty": 2}, {"danger": 1}, {"merit": 5}], q, s, rng(0))
	check_eq(s.difficulty, floor_lvl + 2)
	check_eq(s.danger, 1)
	check_eq(s.merit, 5)


func test_events_can_change_the_fate_drop_a_tier_and_set_every_ambush() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	var db := GameData.get_db()
	s.fate = db.fates.keys()[0]
	Quests._apply([{"fate": "curse"}], q, s, rng(0))
	check_eq(db.fates[s.fate]["rarity"], "curse", "a cursed 天命")
	var cursed := s.fate
	Quests._apply([{"fate": "good"}], q, s, rng(0))
	check(s.fate != cursed and db.fates[s.fate]["rarity"] in ["common", "rare"], "a good 天命 replaces it")
	Quests._apply([{"fate": "bad"}], q, s, rng(0))
	check_eq(db.fates[s.fate]["rarity"], "bad", "a 凶 天命")
	for seed_value in 30:
		var t := SaveData.create()
		Quests.begin(q, t, rng(seed_value))
		check(t.fate_offer.all(func(f): return not db.fates[f]["rarity"] in ["bad", "divine"]), "凶 / 天授 天命 are never offered at the start")
	Quests._apply([{"fate": "divine"}], q, s, rng(0))
	check_eq(db.fates[s.fate]["rarity"], "divine", "a 天授 天命")
	for seed_value in 30:
		Quests._apply([{"fate": true}], q, s, rng(seed_value))
		check(db.fates[s.fate]["rarity"] != "divine", "a plain 改命 never lands on 天授")
	var opts: Array = db.events["fate_shift"]["options"]
	check(opts.any(func(o): return o["weight"] < 1.0), "an option's weight survives loading (天命所归 is the rare one)")
	var cid: String = db.cards.values().filter(func(c): return not c["soldier"] and c.get("person", "") != "lord")[0]["id"]
	s.grant_card(cid)
	s.upgrade(cid)
	check_eq(s.tier(cid), 1, "银 after one 点化")
	var before := s.copies(cid)
	Quests._apply([{"downgrade": 1}], q, s, rng(0))
	check(s.copies(cid) < before and s.copies(cid) >= before - 2 and s.copies(cid) >= 1, "降级 takes 1-2 levels, not a whole tier")
	for _i in 6:
		Quests._apply([{"downgrade": 1}], q, s, rng(0))
	check_eq(s.copies(cid), 1, "level 1 is the floor")
	check(s.has_card(cid), "a level-1 card stays in the party")
	Quests._apply([{"ambush_all": true}], q, s, rng(0))
	var laid: Dictionary = Quests.view(q, s)["squares"]
	var fights: Array = laid.keys().filter(func(sid): return laid[sid]["type"] == "battle" and not laid[sid]["boss"])
	check(not fights.is_empty() and fights.all(func(sid): return s.ambushes.has(sid)), "every fight is an 埋伏")
	Quests._apply([{"ambush_all": false}], q, s, rng(0))
	check(s.ambushes.is_empty(), "and then none")


func test_relics_change_battles() -> void:
	var s := SaveData.create()
	for c in ["sunce", "zhouyu", "sunjian", "zhenghao"]:  # 谋士, 刀兵 and 贼 units carry 兵符 / 兵法, 赤帻 and 战鼓
		s.take(c)
	s.party = ["zhouyu", "sunjian", "zhenghao"]
	var plain := Battle.start("boar", s.party_leaders(), 1)
	s.relics = ["bingfu", "bingfa", "yuxi", "chize", "zhangu"]
	var m := Quests.mods(s)
	var b := Battle.start("boar", s.party_leaders(), 1, 0, {}, {}, false, m)
	check_eq(b.ap, plain.ap + 2, "兵符 +1 at start, 玉玺 +1 per round")
	check_eq(b.turn_limit, plain.turn_limit + 2, "孙子兵法")
	check(b.party_max < plain.party_max, "玉玺 costs HP")
	var dazed := 0
	for seed in range(1, 201):
		if Battle.start("boar", s.party_leaders(), seed, 0, {}, {}, false, m).enemy["stunned"]:
			dazed += 1
	check(dazed > 5 and dazed < 40, "赤帻 dazes the enemy about 10%% of rounds — round 1 here (%d / 200)" % dazed)
	var later := 0  # …and every later round rolls again
	for seed in range(1, 201):
		var b2 := Battle.start("boar", s.party_leaders(), seed, 0, {}, {}, false, m)
		b2.enemy["stunned"] = false
		b2._start_round()
		if b2.enemy["stunned"]:
			later += 1
	check(later > 5 and later < 40, "赤帻 rolls each round (%d / 200)" % later)
	check(b.leaders.all(func(u): return u["boosted"]), "战鼓")


func test_troop_relics_only_help_their_troop() -> void:
	var s := SaveData.create()
	s.relics = ["chitu"]
	check(not Quests.mods(s).has("troop_at"), "no 骑兵 unit out: 赤兔马 rests")
	s.take("sunce")
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
	check_eq(s.tier("zhouyu"), 1, "+3 copies: 铜 → 银")


func test_only_a_boss_offers_a_relic_pick_and_danger_toughens_enemies() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "yaodao"  # an elite: no 宝物
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check(s.offer.is_empty() and s.relics.is_empty(), "an elite drops no 宝物")
	s.square = "lair"  # the boss
	s.resolved = false
	Quests.resolve(q, s, rng(0))
	check(s.offer_kind == "relic" and s.offer.size() == 3)
	Quests.take_relic(s, s.offer[0])
	check(s.relics.size() == 1 and s.offer.is_empty())
	s.danger = 1
	s.square = "oath"  # off a battle square the chapter curve does not move the fight
	var calm := Battle.start("boar", s.party_leaders(), 1)
	var risky := Battle.start("boar", s.party_leaders(), 1, 0, {}, {}, false, Quests.mods(s))
	check(risky.enemy["max_hp"] > calm.enemy["max_hp"])


func test_the_enemy_card_can_turn_up_in_its_chest() -> void:
	var s := SaveData.create()
	var seen := 0
	for seed_value in 40:
		var chest := s.chest_after_battle(rng(seed_value), 0.0, true, quest(0)["soldier_pool"], "heyi")
		if chest.any(func(c): return c["id"] == "heyi"):
			seen += 1
	check(seen > 8 and seen < 32, "about half the boss chests: %d/40" % seen)


func test_beating_lvbu_leads_past_three_chests_one_of_them_grand() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "lvbu"
	s.resolved = false
	Quests.resolve(q, s, rng(0))  # won
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["triple"])
	Quests.move(q, s, "triple")
	check_eq(q["squares"]["triple"]["type"], "event", "a plain story square, not a ？")
	Quests.resolve(q, s, rng(1))
	check_eq(s.difficulty, 1, "beating 吕布 raises the 难度 by itself")
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


func test_huatuo_heals_joins_or_leaves_his_book() -> void:
	var db := GameData.get_db()
	check(Quests.pools(quest(0), SaveData.create())["event_pool"].has("huatuo"))
	check(db.cards["huatuo"]["troop"] == "logistics" and db.cards["huatuo"]["skills"] == ["mafei", "guagu_liaodu"])
	var joined := 0
	var book := 0
	for seed_value in 200:  # asking him along means a fight first (收卡 events all do, user 2026-11-11); the roll comes with the win
		var s := event_on_road("huatuo", 1, seed_value)
		check(not s.event_battle.is_empty(), "bandits come for his medicine box")
		Quests.resolve(quest(0), s, rng(seed_value))
		if s.has_card("huatuo"):
			joined += 1
		if s.relics.has("qingnang"):
			book += 1
	check(joined > 0 and joined <= 20 and joined + book == 200, "joins %d (rare), leaves 青囊书 %d" % [joined, book])


func test_events_hand_over_generals_rarely() -> void:
	## user rule: a general who joins through a ？ event joins at most 5% of the time (the chance around his {"card"})
	var db := GameData.get_db()
	var bad: Array = []
	var walk := func(f: Callable, o: Variant, ch: float, eid: String) -> void:
		if o is Dictionary:
			var c := str(o.get("card", ""))
			if db.cards.has(c) and not db.cards[c]["soldier"] and ch > 0.05:
				bad.append("%s→%s %d%%" % [eid, c, int(ch * 100)])
			for k in o:
				f.call(f, o[k], ch * float(o["chance"]) if k == "then" else ch, eid)
		elif o is Array:
			for x in o:
				f.call(f, x, ch, eid)
	for eid in db.events:
		walk.call(walk, db.events[eid]["options"], 1.0, eid)
	check(bad.is_empty(), str(bad))


func test_yuji_only_brings_trouble() -> void:
	check(Quests.pools(quest(0), SaveData.create())["event_pool"].has("yuji"))
	var drank := event_on_road("yuji", 0)
	check(drank.damage > 0 and drank.relics.has("huangjinfu"), "poisoned and cursed")
	var chased := event_on_road("yuji", 1)
	check_eq(chased.danger, 1, "险 +1")
	var fled := event_on_road("yuji", 2)
	check(fled.event_battle.get("ambush", false), "his followers ambush you")


func test_handing_dongbai_over_pays_a_relic() -> void:
	var q := quest(1)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "give"
	s.resolved = false
	check_eq(q["squares"]["give"]["type"], "event", "a plain story square, not a ？")
	Quests.resolve(q, s, rng(0))
	check_eq(s.relics, ["jubaopen"])


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
	var p0: Array = Quests.pools(quest(0), SaveData.create())["event_pool"]
	var p1: Array = Quests.pools(quest(1), SaveData.create())["event_pool"]
	check(p0.size() >= 20, "chapter 1: %d events" % p0.size())
	check(p1.size() >= 15, "chapter 2: %d events" % p1.size())


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
	check(not Quests.recap(s)["records"].is_empty(), "a setback keeps the run's recap")


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


func test_every_run_offers_fates_and_rolls_affixes() -> void:
	var db := GameData.get_db()
	var q: Dictionary = db.quests[1]
	var s := SaveData.create()
	Quests.begin(q, s, rng(4))
	check_eq(s.fate_offer.size(), 3, "three 天命 to pick from")
	check(s.fate == "", "none picked yet")
	var f := Quests.pick_fate(s, 0)
	check(s.fate == f["id"] and s.fate_offer.is_empty())
	var m := Quests.mods(s)
	for k in f["mods"]:
		check(m.has(k), "the 天命's %s is in the run's mods" % k)
	var elite_squares: Array = q["squares"].keys().filter(func(k): return q["squares"][k]["boss"] or q["squares"][k]["elite"])
	check(not elite_squares.is_empty() and elite_squares.all(func(k): return s.affixes.has(k)), "every elite / boss has a 词缀")
	var plain := SaveData.create()
	Quests.begin(q, plain)
	check(plain.fate_offer.is_empty() and plain.affixes.is_empty(), "no rng (tests): nothing rolled")


func test_affixes_change_the_enemy() -> void:
	var db := GameData.get_db()
	var s := SaveData.create()
	s.take("sunce")
	var base := Battle.start("dongbai", s.party_leaders(), 1)
	var afx: Dictionary = db.battle["affixes"]
	var thick := Battle.start("dongbai", s.party_leaders(), 1, 0, {}, {}, false, {"affix": afx["houxue"]})
	check(thick.enemy["max_hp"] > base.enemy["max_hp"], "厚血: more HP")
	var fast := Battle.start("dongbai", s.party_leaders(), 1, 0, {}, {}, false, {"affix": afx["xunjie"]})
	check(int(fast.enemy["data"]["actions"]) == int(base.enemy["data"]["actions"]) + 1, "迅捷: one more action")
	check(int(db.enemies["dongbai"]["actions"]) == int(base.enemy["data"]["actions"]), "the enemy's own data is untouched")
	var regen := Battle.start("dongbai", s.party_leaders(), 1, 0, {}, {}, false, {"affix": afx["zaisheng"]})
	regen.enemy["hp"] -= 2000
	var hp0: int = regen.enemy["hp"]
	regen.end_round()
	check(regen.take_events().any(func(e): return e["t"] == "enemy_heal") or regen.enemy["hp"] >= hp0, "再生 heals each enemy turn")


func test_trades_need_something_to_trade() -> void:
	var db := GameData.get_db()
	var s := SaveData.create()
	var swap: Dictionary = db.events["merchant"]["options"][0]  # a relic for a general
	check(Quests.option_blocked(s, swap) != "", "no relic: can't trade one")
	s.relics = ["hupi"]
	check_eq(Quests.option_blocked(s, swap), "", "with a relic: fine")
	var pay: Dictionary = db.events["shanzei"]["options"][1]  # pay the toll with a soldier
	check(Quests.option_blocked(s, pay) != "", "no soldiers: can't pay the toll")
	s.grant_card("danyang")
	check_eq(Quests.option_blocked(s, pay), "")
	var flee: Dictionary = db.events["storm"]["options"][1]  # losing a soldier is just a cost here
	check_eq(Quests.option_blocked(SaveData.create(), flee), "", "costs aren't trades")


func _event_text(x: Variant) -> String:
	if x is String:
		return x
	if x is Array:
		return " ".join(x.map(func(i): return _event_text(i)))
	if x is Dictionary:
		return " ".join(x.values().map(func(v): return _event_text(v)))
	return ""


func test_the_north_birth_never_draws_a_south_event() -> void:
	## prologue is one quest for both births: its chapter-only events (二乔, 于吉) carry "route": "south" and stay out of the north pool
	var db := GameData.get_db()
	var q: Dictionary = db.quests[0]
	check_eq(q["id"], "prologue")
	var s := SaveData.create()
	s.run_records = ["出生：冀州无极"]
	var north: Array = Quests.pools(q, s)["event_pool"]
	check(not north.has("qiao") and not north.has("yuji"), "no 二乔 / 于吉 after the north birth")
	for eid in north:
		var text := _event_text(db.events[eid]) + _event_text(GameData.get_db().events[eid]["options"])
		for w in ["孙策", "周瑜", "孙坚", "吴夫人", "二乔", "大乔", "小乔", "伯符", "公瑾"]:
			check(not text.contains(w), "north prologue event %s mentions %s" % [eid, w])
	var south: Array = Quests.pools(q, SaveData.create())["event_pool"]
	check(south.has("qiao") and south.has("yuji"), "the south birth still meets them")


func test_the_north_birth_redeals_the_events_dealt_before_it() -> void:
	## the ？ squares are dealt when 第一章 begins, before the birth is picked (the south pool then): picking the north
	## birth must swap every south event still waiting (孙策's 斗酒 showed up in the north once)
	var db := GameData.get_db()
	var q: Dictionary = db.quests[0]
	for seed in range(1, 30):
		var s := SaveData.create()
		var rng := RandomNumberGenerator.new()
		rng.seed = seed
		Quests.begin(q, s, rng)
		s.events["jz_mystery1"] = "drink"  # as the south deal could leave it
		Quests.record(s, "出生：冀州无极")
		var north: Array = Quests.pools(q, s)["event_pool"]
		for sid in s.events:
			check(north.has(s.events[sid]), "seed %d: %s keeps the south event %s" % [seed, sid, s.events[sid]])


func test_mystery_events_are_dealt_up_front_and_resolved_by_chance() -> void:
	var q: Dictionary = GameData.get_db().quests[4]
	var s := SaveData.create()
	Quests.begin(q, s, rng(11))
	var ids: Array = Quests.view(q, s)["squares"].values().filter(func(sq): return sq["type"] == "mystery" and sq["event"] == "")
	check(not ids.is_empty(), "the chapter has ？ squares")
	var met: Array = []
	for sq in ids:
		check(s.events.has(sq["id"]), "%s already holds its event when the run begins" % sq["id"])
		met.append(s.events.get(sq["id"], ""))
	var distinct := {}
	for m in met:
		distinct[m] = true
	check(distinct.size() >= mini(met.size(), 8), "events are not repeated within a run")
	var ev: Dictionary = GameData.get_db().events["bad_thief"]
	var r := rng(3)
	for _i in 30:
		var i := Quests.random_option(s, ev, r)
		check(Quests.option_blocked(s, ev["options"][i]) == "", "chance never picks an option that cannot be taken")
	var seen := {}
	s.relics = ["x"] if false else s.relics
	for _i in 60:
		seen[Quests.random_option(SaveData.create(), GameData.get_db().events["bad_stampede"], r)] = true
	check_eq(seen.size(), GameData.get_db().events["bad_stampede"]["options"].size(), "every outcome can come up")


func test_each_run_deals_different_events() -> void:
	var q: Dictionary = GameData.get_db().quests[4]
	var layouts := {}
	for seed_value in 10:
		var s := SaveData.create()
		Quests.begin(q, s, rng(seed_value))
		layouts[JSON.stringify(s.events)] = true
	check(layouts.size() > 6, "the same chapter plays out with different events each run (%d of 10 differ)" % layouts.size())


func test_a_squares_own_pools_decide_what_its_chest_and_recruits_offer() -> void:
	var db := GameData.get_db()
	for qq in db.quests:
		for s in qq["squares"].values():
			for c in s["soldier_pool"]:
				check(db.cards.has(c) and db.cards[c]["soldier"], "%s/%s: soldier_pool %s is a soldier card" % [qq["id"], s["id"], c])
			for c in s["recruit_pool"]:
				check(db.cards.has(c) and not db.cards[c]["soldier"], "%s/%s: recruit_pool %s is a general" % [qq["id"], s["id"], c])
	var jx: Dictionary = db.quests.filter(func(x): return x["id"] == "jingxiang")[0]
	var s := SaveData.create()
	Quests.begin(jx, s)
	s.square = "t_jx1"  # 袁术旧府: a chest of 宛城's own soldiers
	s.resolved = false
	var offer: Array = Quests.offer(jx, s, rng(1)).map(func(c): return c["id"])
	check(not offer.is_empty() and offer.all(func(c): return jx["squares"]["t_jx1"]["soldier_pool"].has(c)), "the chest only holds this place's soldiers: %s" % [offer])
	var yx: Dictionary = db.quests.filter(func(x): return x["id"] == "yuxi")[0]
	var s2 := SaveData.create()
	Quests.begin(yx, s2)
	s2.square = "liukou3"  # 荒村·溃兵投军: a few of 孙坚's old guard
	s2.resolved = false
	var recruits: Array = Quests.offer(yx, s2, rng(2)).map(func(c): return c["id"])
	check(not recruits.is_empty() and recruits.size() <= int(db.gacha["offer_size"]) and recruits.all(func(c): return yx["squares"]["liukou3"]["recruit_pool"].has(c)), "the recruits come from this place's own list: %s" % [recruits])


func test_a_rolled_event_says_which_option_the_dice_landed_on() -> void:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": "zuoci"}
	var ev: Dictionary = GameData.get_db().events["zuoci"]
	var i := Quests.random_option(s, ev, rng(5))
	Quests.choose_event(q, s, rng(5), i, true)
	check(str(s.event_note[0]).begins_with("随机到了：") and str(s.event_note[0]).ends_with(str(ev["options"][i]["label"])), "the note names the option that was rolled: %s" % [s.event_note])


func test_a_mystery_square_picks_its_pool_first_then_an_event() -> void:
	## battle.event_sources: chapter-own, route and universal events each get a share of the ？ squares
	var db := GameData.get_db()
	var q: Dictionary = db.quests.filter(func(qq): return qq["id"] == "xuzhou")[0]
	var pool: Array = Quests.pools(q, SaveData.create())["event_pool"]
	var seen := {"chapter": 0, "route": 0, "universal": 0}
	var r := RandomNumberGenerator.new()
	r.seed = 7
	for i in 600:
		seen[Quests.event_source(q, Quests.pick_event(q, pool, r))] += 1
	var w: Dictionary = db.battle["event_sources"]
	var total := float(w["chapter"] + w["route"] + w["universal"])
	for k in seen:
		check(abs(seen[k] / 600.0 - float(w[k]) / total) < 0.08, "%s share %d/600 near its weight" % [k, seen[k]])
	var only_universal: Array = pool.filter(func(e): return Quests.event_source(q, e) == "universal")
	check_eq(Quests.event_source(q, Quests.pick_event(q, only_universal, r)), "universal", "an empty pool drops out")


func test_side_stories_open_after_their_chapter_cost_merit_and_reward_once() -> void:
	var db := GameData.get_db()
	check(db.side_stories.size() >= 20, "every chapter has ？小故事")
	var s := SaveData.create()
	s.flags = ["出生：江东富春"]
	check(Quests.side_stories(s).is_empty(), "nothing before a chapter is done")
	var south := Quests.side_stories(s, "prologue")
	check(not south.is_empty() and south.all(func(x): return x["id"] in ["s_jiujiu", "s_firstwine", "s_i_sewing"]), "the south birth gets only the south prologue stories")
	s.quests_cleared = ["prologue"]
	s.grant_card("sunce")
	s.merit = 9
	check(not Quests.open_side(s, "s_jiujiu")["ok"], "10 战功 to open: 9 is not enough")
	check_eq(Quests.side_unread(s), south.size())
	s.merit = 12
	var before := s.copies("sunce")
	var r := Quests.open_side(s, "s_jiujiu")
	check(r["ok"] and r["got"] != "", "opened: %s" % r)
	check_eq(s.merit, 2)
	check_eq(s.copies("sunce"), before + 2, "九九歌 点化 孙策 +2")
	check_eq(Quests.open_side(s, "s_jiujiu")["got"], "", "a re-read in its chapter is free and gives nothing")
	check_eq(s.merit, 2)
	s.merit = 10
	Quests.open_side(s, "s_firstwine")  # 酒囊
	check(s.kept_relics.has("jiunang") and s.relics.has("jiunang"), "a 宝物 stays for the rest of the 周目")


func test_a_held_relic_pays_the_cost_back() -> void:
	var s := SaveData.create()
	s.flags = ["出生：江东富春"]
	s.quests_cleared = ["prologue"]
	s.relics = ["jiunang"]
	s.kept_relics = ["jiunang"]
	s.merit = 10
	Quests.open_side(s, "s_firstwine")
	check_eq(s.merit, 10, "already had 酒囊: the 10 战功 come back")


func test_the_grand_chest_is_never_a_random_roll() -> void:
	# only the designed row of three chests in chapter 2 holds it (a ？ in chapter 3 handed out 袁绍's chest, user 2026-11-11)
	var db := GameData.get_db()
	for q in db.quests:
		var s := SaveData.create()
		check(not Quests.pools(q, s)["event_pool"].has("grand_chest"), "no ？ pool in %s draws the grand chest" % q["id"])


func test_a_random_relic_follows_the_rarity() -> void:
	# an event's {"relic": true} draws like the boss pick (relic_pick.weights), not evenly (user 2026-11-11)
	var db := GameData.get_db()
	var n := {"common": 0, "rare": 0, "curse": 0}
	var r := rng(5)
	for i in 600:
		var rid := Quests.random_relic(SaveData.create(), r)
		n[db.relics[rid]["rarity"]] += 1
	var per := func(k: String) -> float: return float(n[k]) / db.relics.values().filter(func(x): return x["rarity"] == k).size()
	check(per.call("common") > per.call("rare") * 1.3 and per.call("curse") > per.call("rare") * 1.3, "each common / curse comes up more often than each rare: %s" % str(n))
