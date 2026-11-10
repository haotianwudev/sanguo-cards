extends TestCase
## 数据完整性：schema、gate、路线、地图规则、每个事件 / 小故事都接得上（从原来 2500 行的 test_quests.gd 按主题拆出）


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
	check_eq(GameData.get_db().quests.map(func(q): return q["id"]), ["prologue", "taodong", "luoyang_n", "heishan", "yuxi", "beihai", "xuzhou", "dongui", "jingxiang", "huainan_s", "huainan_n", "yecheng", "jiangdong", "longhu", "menghu", "xiliang", "tianfu", "guanzhong", "luoyang_s", "sanfang", "tianqing", "beifa", "chibi", "guandu", "dujiang", "guiyi"])


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
				s.relics = ["hupi", "jiunang"]  # enough to trade with (options with needs)
				s.soldiers = {"danyang": 2, "changsha": 2}
				Quests.choose_event(q, s, rng(seed_value), i)
				check(s.resolved or not s.event_battle.is_empty() or not s.offer.is_empty(), "%s option %d" % [eid, i])
				if not s.offer.is_empty():
					Quests.resolve(q, s, rng(0), 0)
					check(s.resolved, "%s pick" % eid)


func test_the_filler_forks_of_the_other_chapters_have_a_fight_lane_and_a_rogue_lane_too() -> void:
	var forks := {"taodong": ["captive"], "yuxi": ["supply", "warn", "feng", "wenji_tale", "plan", "xizi", "caiyong", "yuexia", "xian"],
		"jingxiang": ["jx_diaochan", "jx_bubing", "jx_rest", "jx_shaoka", "jx_zongzei", "jx_xiangyang", "jx_xunluo", "jx_shuijun"],
		"dongui": ["route", "tuwei", "luan", "luo_ruin", "luoyang_rest", "luoyang_rest4", "qiao7", "huangzhong", "leibo7"],
		"tianfu": ["t9_yexi", "t9_yexi_lx", "t9_jiangzhou", "t9_wuxian", "t9_xizheng", "t9_kuimen", "t9_xiuzheng", "t9_fazheng_take", "t9_fazheng_go", "t9_nanzhong", "t9_zhurong_join", "t9_yiqin", "t9_x_bujv"],
		"guanzhong": ["g10_start", "g10_xiuzheng", "g10_jishi", "g10_zw_start", "g10_zw_fire", "g10_fenbing", "g10_huzhen", "g10_xurong", "g10_kongming"],
		"yecheng": ["n7_start", "n7_tiqin", "n7_beishang", "n7_bieyuan", "n7_g_qin", "n7_b_anmin"],
		"longhu": ["n8_yishi", "n8_yishi_t", "n8_dumai", "n8_b_nan", "n8_b_deng", "n8_g_nan", "n8_g_jincheng", "n8_g_tuijun"],
		"xiliang": ["n9_start", "n9_lunu", "n9_yanjin_f", "n9_yanjin_p", "n9_g_yizheng", "n9_g_zhanta"],
		"sanfang": ["n10_start", "n10_qiandu", "n10_xiuzheng", "n10_caoren", "n10_g_shangchuan"],
		"tianqing": ["n11_start", "n11_beidu", "n11_gehe", "n11_a_xiaoxi", "n11_a_jianlou"],
		"luoyang_s": ["l11_start", "l11_chengxia", "l11_xiuzheng", "l11_yingzhan", "l11_yulin", "l11_b_xunyu", "l11_a_weicheng"],
		"menghu": ["m8_shankou", "m8_liniang", "m8_xianfeng", "m8_t_liu", "m8_bowang", "m8_xunchuan", "m8_yuye", "m8_xiangyang", "m8_t_hanshui"]}
	var db := GameData.get_db()
	for q in db.quests:
		for fid in forks.get(q["id"], []):
			var sq: Dictionary = q["squares"]
			var preds := {}
			for s in sq.values():
				for n in s["next"]:
					preds[n] = int(preds.get(n, 0)) + 1
			var fights := 0
			for first in sq[fid]["next"]:
				var lane: Array = [first]
				while sq[lane[-1]]["next"].size() == 1 and int(preds.get(sq[lane[-1]]["next"][0], 0)) == 1:
					lane.append(sq[lane[-1]]["next"][0])
				check(lane.size() >= 2, "%s/%s: lane %s is one square" % [q["id"], fid, first])
				if lane.any(func(id): return sq[id]["type"] == "battle"):
					fights += 1
					if q["id"] in ["dongui", "jingxiang"]:
						check(sq[lane[-1]].get("elite", false) or sq[lane[-1]].get("boss", false), "%s/%s: the fight lane ends on an elite (%s)" % [q["id"], fid, lane[-1]])
			check_eq(fights, 1, "%s/%s: one lane fights, the other does not" % [q["id"], fid])


func test_gate_is_one_rule_everywhere() -> void:
	## Quests.gate: requires = every line holds; unless = hidden only when every line holds (第五章 恨海 squares)
	var s := SaveData.new()
	s.flags = ["甲"]
	check(Quests.gate({"requires": "甲"}, s), "requires one line")
	check(not Quests.gate({"requires": ["甲", "乙"]}, s), "requires needs every line")
	check(not Quests.gate({"unless": "甲"}, s), "unless one line")
	check(Quests.gate({"unless": ["甲", "乙"]}, s), "unless a list hides only when all hold")
	s.run_records = ["乙"]
	check(not Quests.gate({"unless": ["甲", "乙"]}, s), "this run's records count")
	check(Quests.gate({"unless": ["甲", "乙"]}, s, false), "story flags only")
	check(Quests.gate({}, s), "no gate = open")


func test_data_has_no_schema_errors() -> void:
	## data/schema.json: every reference and enum in the game data, all failures listed at once
	var errs: Array = GameData.check_schema()
	for e in errs.slice(0, 40):
		print("  data: ", e)
	check(errs.is_empty(), "%d data error(s), see above" % errs.size())


func test_the_schema_checker_catches_each_kind_of_mistake() -> void:
	var root := {"cards": {"a": {"troop": "x", "skills": ["s1", "nope"]}}, "skills": {"s1": {}}, "troops": {"x": {}},
		"list": [{"id": 1}, {"id": 1}], "story": {"r": {"reward": {"merit": 3}}}}
	var errs := Schema.check(root, {"rules": [
		{"refs": "cards.*.skills.*", "to": "skills.@keys"},
		{"enum": "cards.*.troop", "values": ["y"]},
		{"unique": "list.*.id"},
		{"forbid": "story.*.reward.merit"},
		{"each": "cards.*", "required": "name"},
		{"refs": "cards.*.typo", "to": "skills.@keys"},
		{"refs": "cards.*.typo2", "to": "skills.@keys", "optional": true}]})
	check_eq(errs.size(), 6, "one error per rule but the optional one: %s" % str(errs))
	check(str(errs[0]).contains("cards.a.skills[1] = nope"), "the error says where: %s" % str(errs[0]))


func test_gate3_answers_maybe_only_when_it_cannot_tell() -> void:
	var known := {"甲": 1, "乙": 0}
	var truth := func(line: String) -> int: return known.get(line, -1)
	check_eq(Quests.gate3({"requires": "甲"}, truth), 1)
	check_eq(Quests.gate3({"requires": ["甲", "丙"]}, truth), -1, "one line unknown")
	check_eq(Quests.gate3({"requires": ["乙", "丙"]}, truth), 0, "one line known false decides it")
	check_eq(Quests.gate3({"unless": "乙"}, truth), 1)
	check_eq(Quests.gate3({"unless": ["甲", "丙"]}, truth), -1, "hidden only if 丙 also holds")
	check_eq(Quests.gate3({"unless": ["甲", "乙"]}, truth), 1, "乙 is known false: never hidden")
	check_eq(Quests.gate3({"requires": "丙", "unless": "甲"}, truth), 0, "known hidden beats an unknown requires")


func test_the_route_comes_from_the_birth_lines_in_story_json() -> void:
	var s := SaveData.new()
	check_eq(s.route(), "south", "no birth yet: the first route")
	s.run_records = [GameData.get_db().routes["north"]]
	check(s.is_north() and s.birth_route() == "north")


func test_a_refs_path_from_the_top_inside_each() -> void:
	## {"each": "themes.*", "refs": "/events.*.color", "to": "@keys"}: every theme must hold every event's colour
	var root := {"themes": {"ink": {"red": 1, "blue": 1}, "light": {"red": 1}}, "events": {"a": {"color": "red"}, "b": {"color": "blue"}}}
	var errs := Schema.check(root, {"rules": [{"each": "themes.*", "refs": "/events.*.color", "to": "@keys"}]})
	check_eq(errs.size(), 1, str(errs))
	check(str(errs[0]).contains("events.b.color = blue"), str(errs))
