extends TestCase
## Chapters 3 to 5 walked end to end on every 周目 route: which squares come up, what gets recorded,
## which chapter follows, which ending (if any) the run reaches.

const E1 := "结局一 · 玉碎"
const E2 := "结局三 · 同归"
const E3 := "结局五 · 恨海"
const JX := "贾诩：入队"
const E10 := "结局七 · 深锁"
const E11 := "结局九 · 匹夫"


func rng(seed_value: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r


func quest_by_id(id: String) -> Dictionary:
	return GameData.get_db().quests.filter(func(q): return q["id"] == id)[0]


func walk(q: Dictionary, s: SaveData, prefer: Array, seed_value := 1, pick_offer := 0, choose_idx := -1) -> Array:
	## Play a quest square by square as if every fight were won; at a fork take the first square
	## listed in `prefer`, else the first open one. Returns the squares visited, in order.
	var r := rng(seed_value)
	Quests.begin(q, s, r)
	var path: Array = [s.square]
	for _step in 200:
		var sq := Quests.here(q, s)
		if sq["type"] == "mystery" and not s.resolved:
			var ev := Quests.event_here(q, s, r)
			var ok: Array = range(ev["options"].size()).filter(func(i): return Quests.option_blocked(s, ev["options"][i]) == "")
			var keep: Array = ok.filter(func(i): return not JSON.stringify(ev["options"][i]).contains("drop_relic"))
			Quests.choose_event(q, s, r, (keep if not keep.is_empty() else ok)[0])  # a 小偷 taking a story 宝物 would fail the relic checks by chance
		Quests.offer(q, s, r)
		var c := choose_idx
		if sq["type"] == "choose" and c < 0:
			c = sq["choose"].size() + c  # -1 = the last option, as an Array index
		if sq["type"] == "choose" and Quests.option_locked(s, sq["choose"][c]):
			c = range(sq["choose"].size()).filter(func(i): return not Quests.option_locked(s, sq["choose"][i]))[0]  # a gated option (居巢 诸葛瑾) falls back to the first open one
		Quests.resolve(q, s, r, c if sq["type"] == "choose" else (pick_offer if not s.offer.is_empty() else -1))
		s.offer = []
		s.resolved = true
		var opts := Quests.next_options(q, s)
		if opts.is_empty():
			return path
		var pick: Dictionary = opts[0]
		for o in opts:
			if prefer.has(o["id"]):
				pick = o
				break
		Quests.move(q, s, pick["id"])
		path.append(pick["id"])
	check(false, "quest %s never ended" % q["id"])
	return path


func finish(q: Dictionary, s: SaveData) -> void:
	Quests.complete(q, s)


func lap_save(flags: Array, cleared: Array) -> SaveData:
	var s := SaveData.create()
	s.flags = flags.duplicate()
	s.quests_cleared = cleared.duplicate()
	for c in ["sunce", "zhouyu", "dongbai"]:
		s.grant_card(c)
	return s


# ---- 一周目 ------------------------------------------------------------------------------

func test_lap1_chapter3_ends_in_ending_one_and_the_story_stops() -> void:
	var s := lap_save(["董白：留下"], ["prologue", "taodong"])
	var q := quest_by_id("yuxi")
	check_eq(Quests.current_quest(s)["id"], "yuxi")
	var path := walk(q, s, [])
	check(path.has("wenji_taken") and not path.has("wenji_seen"), "一周目: 蔡文姬 is carried off")
	for sid in ["supply", "nanyang", "slip", "entrust", "warn", "feng", "raid", "pass", "news", "yuanshu", "end"]:
		check(path.has(sid), "一周目 passes " + sid)
	check_eq(path[-1], "end")
	check(s.run_records.has(E1), "the run reaches 结局一")
	finish(q, s)
	check(s.flags.has(E1), "结局一 becomes a lasting flag")
	check(Quests.current_quest(s) == null, "no chapter follows 结局一")
	s.new_lap()
	check(s.flags.has(E1), "a new 周目 keeps the ending")


func test_losing_to_yuanshu_still_reaches_the_ending() -> void:
	var s := lap_save(["董白：留下"], ["prologue", "taodong"])
	var q := quest_by_id("yuxi")
	Quests.begin(q, s)
	s.square = "yuanshu"
	s.resolved = false
	Quests.lose(q, s)
	check_eq(s.square, "end", "袁术 is a last stand: losing walks on to 玉碎")


# ---- 二周目: route B, nobody warns you ------------------------------------------------

func test_lap2_route_b_runs_through_luoyang_and_changan_to_ending_two() -> void:
	var s := lap_save(["董白：留下", E1], ["prologue", "taodong"])
	var yuxi := quest_by_id("yuxi")
	var p3 := walk(yuxi, s, [], 1, 0, 0)
	check(p3.has("wenji_seen") and p3.has("wenji_fight"), "二周目: 董白 spots 蔡文姬")
	check(s.has_card("caiwenji"), "蔡文姬 joins")
	check(not s.run_records.has(E1), "no 玉碎 on this road")
	for sid in ["wenji_join", "wenji_tale", "plan", "guosi4", "grain", "settle", "zhujun", "xizi", "peace", "betroth", "mangshan", "farewell"]:
		check(p3.has(sid), "驻守洛阳 passes " + sid)
	check(s.has_card("zhujun"), "朱儁 joins")
	for sid in ["enter", "feast", "bw3", "passed", "chaojian", "caiyong", "wangyun", "diaochan", "xuhun", "yuexia", "xian",
			"fengyi", "chuxi", "eve", "xueye", "wedding", "hall", "huzhen", "dongzhuo5", "kill_all", "death"]:
		check(p3.has(sid), "长安 passes " + sid)
	check(not p3.has("supply") and not p3.has("road_fight"), "the bandit road stays behind")
	check(not s.has_card("huangfusong"), "皇甫嵩 arrives at 格杀勿论 but does not join")
	finish(yuxi, s)
	check(s.flags.has("路线：守洛阳") and s.flags.has("路线：长安"))
	check(s.flags.has("长安：吕布杀了董卓"))

	var d := quest_by_id("dongui")
	check_eq(Quests.current_quest(s)["id"], "dongui", "then 第四章")
	var p6 := walk(d, s, [])
	for sid in ["yizu", "qingsun", "fenghou", "jail", "xunyou", "route", "chaohui", "gaoshun4", "tuwei", "langqi4", "pozi",
			"dongjia", "lvbu4", "tonggui"]:
		check(p6.has(sid), "二周目 passes " + sid)
	for sid in ["mimou", "luan", "gong", "huihe", "dongtao"]:
		check(not p6.has(sid), "二周目 never reaches " + sid)
	check(s.has_card("xunyou") and not s.has_card("zhongyao") and not s.has_card("xunyu"), "荀攸 joins; 钟繇 and 荀彧 do not")
	check(s.run_records.has(E2), "the run reaches 结局三")
	finish(d, s)
	check(s.flags.has(E2))
	check(Quests.current_quest(s) == null, "the story stops at 结局三")
	s.new_lap()
	check(s.flags.has(E1) and s.flags.has(E2), "both endings survive into the next 周目")


func test_lap2_losing_to_lvbu_still_reaches_ending_two() -> void:
	var s := lap_save(["董白：留下", E1, "长安：吕布杀了董卓"], ["prologue", "taodong", "yuxi"])
	var d := quest_by_id("dongui")
	Quests.begin(d, s)
	s.square = "lvbu4"
	s.resolved = false
	Quests.lose(d, s)
	check_eq(s.square, "tonggui")


# ---- 三周目: 貂蝉 warns you ----------------------------------------------------------------

func test_lap3_chapter4_escapes_with_the_emperor_and_takes_nanyang() -> void:
	for fork in [["zhuibing", "m1", "m2", "m7a"], ["fanchou6", "t1", "rest", "t7"]]:
		var s := lap_save(["董白：留下", E1, E2, "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"],
				["prologue", "taodong", "yuxi"])
		var d := quest_by_id("dongui")
		check_eq(Quests.current_quest(s)["id"], "dongui")
		var p := walk(d, s, fork)
		for sid in ["yizu", "fenghou", "jail", "xunyou", "route", "mimou", "luan", "gong", "shaoka", fork[0], "xuhuang", "lijue6",
				"huihe", "luo_ruin", "luoyang_rest", "luo_rebuild", "fall", "seal", "paichi", "chuzheng", "qiao7", "huangzhong", "leibo7", "xingye", "chenlan7", "feng7",
				"jiling7", "dongtao"]:
			check(p.has(sid), "三周目 passes %s (fork %s)" % [sid, fork[0]])
		for sid in ["chaohui", "tuwei", "dongjia", "lvbu4", "tonggui"]:
			check(not p.has(sid), "三周目 never reaches " + sid)
		for c in ["diaochan", "xuhuang", "huangzhong"]:
			check(s.has_card(c), c + " joins")
		check(s.run_records.has("长安：带陛下出城") and s.run_records.has("南阳：袁术东逃"))
		check(not s.run_records.has(E2), "no ending on this road")
		finish(d, s)
		check_eq(Quests.current_quest(s)["id"], "jingxiang", "第五章 follows 南阳")


# ---- every map, every flag combination ----------------------------------------------------

func reachable(q: Dictionary, s: SaveData) -> Dictionary:
	var sq: Dictionary = q["squares"]
	var seen := {}
	var todo: Array = [q["start"]]
	while not todo.is_empty():
		var id: String = todo.pop_back()
		if seen.has(id) or not Quests.is_open(sq[id], s):
			continue
		seen[id] = true
		var nexts: Array = []
		if sq[id].get("next") != null:
			nexts = sq[id]["next"].duplicate()
		if sq[id].get("lose_goto", "") != "":
			nexts.append(sq[id]["lose_goto"])
		if sq[id].get("type") == "choose":
			for c in sq[id].get("choose", []):
				if "goto" in c:
					nexts.append(c["goto"])
		todo.append_array(nexts)
	return seen


func test_every_square_is_reachable_on_some_route_and_open_squares_never_overlap() -> void:
	for id in ["yuxi", "beihai", "xuzhou", "dongui", "jingxiang", "huainan_s"]:
		var q := quest_by_id(id)
		var sq: Dictionary = q["squares"]
		var lines := {}
		for s in sq.values():
			for v in [s["requires"], s["unless"]]:
				for line in (v if v is Array else ([] if str(v) == "" else [str(v)])):
					lines[line] = true
		var keys: Array = lines.keys()
		var covered := {}
		for mask in 1 << keys.size():
			var s := SaveData.create()
			for i in keys.size():
				if mask & (1 << i):
					s.flags.append(keys[i])
			var seen := reachable(q, s)
			covered.merge(seen)
			var spots := {}
			for sid in seen:
				var at := Vector2i(sq[sid]["x"], sq[sid]["y"])
				check(not spots.has(at), "%s %s: %s and %s both open at %s" % [id, s.flags, sid, spots.get(at, ""), at])
				spots[at] = sid
			var mid_route := s.flags.any(func(f): return str(f).begins_with("路线："))  # a route already taken inside the chapter: its flag is a record made on the way
			for sid in seen:  # no square leads only into hidden squares
				var nexts: Array = sq[sid]["next"].filter(func(n): return Quests.is_open(sq[n], s))
				var opens_by_record: bool = sq[sid]["record"] != "" and sq[sid]["next"].any(func(n): return Quests._as_list(sq[n]["requires"]).has(sq[sid]["record"]))
				if mid_route or opens_by_record:
					continue
				check(not (nexts.is_empty() and not sq[sid]["next"].is_empty()), "%s %s: stuck at %s" % [id, s.flags, sid])
		for sid in sq:
			check(covered.has(sid), "%s: square %s is never reachable" % [id, sid])


# ---- real fights: the 三周目 chapter 4 plays through without script errors ---------------------

func test_lap3_chapter4_plays_with_real_fights() -> void:
	var s := lap_save(["董白：留下", E1, E2, "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"],
			["prologue", "taodong", "yuxi"])
	for c in ["caiwenji", "huangfusong", "zhujun", "sunjian", "chengpu", "huanggai", "handang"]:
		if GameData.get_db().cards.has(c):
			s.grant_card(c)
	var q := quest_by_id("dongui")
	var r := rng(7)
	Quests.begin(q, s, r)
	var fights := 0
	for _step in 200:
		var sq := Quests.here(q, s)
		if sq["type"] == "mystery" and not s.resolved:
			var ev := Quests.event_here(q, s, r)
			var ok: Array = range(ev["options"].size()).filter(func(i): return Quests.option_blocked(s, ev["options"][i]) == "")
			var keep: Array = ok.filter(func(i): return not JSON.stringify(ev["options"][i]).contains("drop_relic"))
			Quests.choose_event(q, s, r, (keep if not keep.is_empty() else ok)[0])  # a 小偷 taking a story 宝物 would fail the relic checks by chance
		if (sq["type"] == "battle" or not s.event_battle.is_empty()) and not s.resolved:
			var f := Quests.battle_here(q, s)
			s.party = s.auto_party()
			var b := Battle.start(f["battle"], s.party_leaders(), r.randi(), s.damage, s.carry_extra, s.carry_uses, f["ambush"])
			bot_fight(b)
			fights += 1
			s.damage = 0  # carry on as if won: this checks the road, not the balance
		Quests.offer(q, s, r)
		Quests.resolve(q, s, r, 0 if not s.offer.is_empty() else -1)
		s.offer = []
		s.resolved = true
		var opts := Quests.next_options(q, s)
		if opts.is_empty():
			break
		Quests.move(q, s, opts[0]["id"])
	check_eq(s.square, "dongtao", "reached the end of 第四章")
	check(fights >= 8, "fought the chapter's battles (%d)" % fights)


func test_the_bundled_font_has_every_character_the_game_prints() -> void:
	## the font is a subset: new story text with a rare character needs `python tools/build_fonts.py`
	var font: FontFile = load("res://data/fonts/body.ttf")
	var missing := {}
	for f in ["story.json", "cards.json", "enemies.json", "scenarios.json", "skills.json", "relics.json", "battle.json", "side_stories.json", "ui.json"]:
		var text := FileAccess.get_file_as_string("res://data/" + f)
		for i in text.length():
			var c := text.unicode_at(i)
			if c >= 0x3400 and not font.has_char(c):
				missing[String.chr(c)] = f
	check(missing.is_empty(), "not in the font (run tools/build_fonts.py): %s" % str(missing))


# ---- 第五章 · 荆襄风云: first time the banquet kills 貂蝉 (结局五); after it, 贾诩 (met in 长安, recruited in 第四章) breaks it ----

func ch5_save(flags: Array) -> SaveData:
	var s := lap_save(["董白：留下", E1, E2, "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓", "南阳：袁术东逃"] + flags,
			["prologue", "taodong", "yuxi", "dongui"])
	for c in ["diaochan", "xunyou", "huangzhong", "caiwenji"]:
		s.grant_card(c)
	return s


func test_chapter5_first_time_the_banquet_ends_in_ending_three() -> void:
	for fork in [["jx_gongshou", "m_jx1", "m_jx3"], ["m_jx2", "t_jx1", "t_jx3"]]:
		var s := ch5_save([])
		var q := quest_by_id("jingxiang")
		check_eq(Quests.current_quest(s)["id"], "jingxiang")
		var p := walk(q, s, fork)
		for sid in ["jx_wan", "jx_diaochan", "jx_laixi", "jx_bubing", fork[0], "jx_huangzu", "jx_rest", "jx_tianshi", "jx_qinggong",
				"jx_jinggao", "jx_xiangyang", "jx_mimou", "jx_shuijun", "jx_yiguan", "jx_a_fuyan", "jx_a_nushou", "jx_a_caimao",
				"jx_a_xiangxiao", "jx_a_xuexi", "jx_a_henhai"]:
			check(p.has(sid), "恨海 route passes %s (fork %s)" % [sid, fork[0]])
		for sid in ["jx_meng", "jx_b_dingce", "jx_b_kuaiyue", "jx_b_shuige", "jx_b_dianxing", "jx_b_louchuan"]:
			check(not p.has(sid), "恨海 route never reaches " + sid)
		check_eq(p[-1], "jx_a_henhai")
		check(s.run_records.has(E3), "the run reaches 结局五")
		check(not s.has_card("kuaiyue"), "蒯越 never joins")
		finish(q, s)
		check(s.flags.has(E3))
		check(Quests.current_quest(s) == null, "the story stops at 结局五")


func test_chapter5_after_ending_three_jiaxu_breaks_the_banquet() -> void:
	var s := ch5_save([E3, JX])
	s.grant_card("jiaxu")
	var q := quest_by_id("jingxiang")
	var p := walk(q, s, [])
	for sid in ["jx_tianshi", "jx_meng", "jx_jinggao", "jx_yiguan", "jx_b_dingce", "jx_b_kuaiyue", "jx_b_dress", "jx_b_shuige",
			"jx_b_caimao", "jx_b_dianxing", "jx_b_louchuan"]:
		check(p.has(sid), "破局 route passes " + sid)
	for sid in ["jx_qinggong", "jx_a_fuyan", "jx_a_xiangxiao", "jx_a_henhai"]:
		check(not p.has(sid), "破局 route never reaches " + sid)
	check_eq(p[-1], "jx_b_louchuan")
	check(s.has_card("kuaiyue"), "蒯越 joins")
	check(s.run_records.has("荆襄：联蒯灭蔡") and s.run_records.has("貂蝉：全员生还"))
	finish(q, s)
	check_eq(Quests.current_quest(s)["id"], "huainan_s", "破局 route goes on to 第六章 · 淮南折帝旗")


func test_chapter5_plays_with_real_fights_on_both_routes() -> void:
	for flags in [[], [E3, JX]]:
		var s := ch5_save(flags)
		var q := quest_by_id("jingxiang")
		var r := rng(5)
		Quests.begin(q, s, r)
		var fights := 0
		for _step in 200:
			var sq := Quests.here(q, s)
			if sq["type"] == "mystery" and not s.resolved:
				var ev := Quests.event_here(q, s, r)
				var ok: Array = range(ev["options"].size()).filter(func(i): return Quests.option_blocked(s, ev["options"][i]) == "")
				Quests.choose_event(q, s, r, ok[0])
			if (sq["type"] == "battle" or not s.event_battle.is_empty()) and not s.resolved:
				var f := Quests.battle_here(q, s)
				s.party = s.auto_party()
				var b := Battle.start(f["battle"], s.party_leaders(), r.randi(), s.damage, s.carry_extra, s.carry_uses, f["ambush"])
				bot_fight(b)
				fights += 1
				s.damage = 0
			Quests.offer(q, s, r)
			Quests.resolve(q, s, r, 0 if not s.offer.is_empty() else -1)
			s.offer = []
			s.resolved = true
			var opts := Quests.next_options(q, s)
			if opts.is_empty():
				break
			Quests.move(q, s, opts[0]["id"])
		check_eq(s.square, "jx_b_louchuan" if flags.has(E3) else "jx_a_henhai", "reached the end of 第五章 %s" % str(flags))
		check(fights >= 5, "fought the chapter's battles (%d)" % fights)


func test_chapter5_without_jiaxu_the_banquet_still_ends_in_ending_three() -> void:
	var s := ch5_save([E3])  # 结局五 reached, but 贾诩 was passed by in 第四章
	var p := walk(quest_by_id("jingxiang"), s, [])
	check(p.has("jx_qinggong") and p.has("jx_a_fuyan") and not p.has("jx_meng") and not p.has("jx_b_dingce"), "no 贾诩, no way out")
	check_eq(p[-1], "jx_a_henhai")


# ---- 南线第六章 · 淮南折帝旗 ---------------------------------------------------------------

func ch6s_save() -> SaveData:
	var s := ch5_save([E3, JX, "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督", "貂蝉：全员生还"])
	s.quests_cleared.append("jingxiang")
	for c in ["jiaxu", "kuaiyue"]:  # 甘宁 only joins in 第七章 now
		s.grant_card(c)
	return s


func test_south_chapter6_follows_the_good_jingxiang_ending_only() -> void:
	check_eq(Quests.current_quest(ch6s_save())["id"], "huainan_s")
	var bad := ch5_save([E3])
	bad.quests_cleared.append("jingxiang")
	check(Quests.current_quest(bad) == null, "恨海 stops the story: no 第六章")


func test_south_chapter6_walks_from_xiangyang_to_the_eve_of_the_double_wedding() -> void:
	## after 「结局七 · 深锁」: 刘晔 settles 庐江's clans, 雷家 is cut off and runs west, the wedding date is set (the wedding itself opens 第七章)
	for fork in [[], ["hn_m1", "hn_m2", "hn_m3", "hn_m4"]]:
		var s := ch6s_save()
		s.flags.append(E10)
		var q := quest_by_id("huainan_s")
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["hn_years", "hn_letter", "hn_shu", "hn_zhoujia", "hn_luxun", "hn_lusu", "hn_liuxun", "hn_wan_rest",
				"hn_chenwu", "hn_qiao", "hn_huafang", "hn_shizu", "hn_liuye", "hn_qs", "hn_leixu", "hn_fuzhu", "hn_zhengbao",
				"hn_leichen", "hn_zhangxun", "hn_shouchun", "hn_feng", "hn_bridge", "hn_jiangting", "hn_t_kuibing", "hn_lvmeng", "hn_lvmeng_go", "hn_feng2", "hn_feast", "hn_end"]:
			check(p.has(sid), "第六章 passes %s (forks %s)" % [sid, str(fork)])
		check_eq(p[-1], "hn_end")
		for sid in ["hn_kaicang", "hn_kc_chase", "hn_kc_gate", "hn_jibao", "hn_wanshui", "hn_qs_bad", "hn_shensuo"]:
			check(not p.has(sid), "刘晔 route never reaches " + sid)
		for c in ["lusu", "chenwu", "liuye"]:
			check(s.has_card(c), "%s joins in 第六章" % c)
		check(not s.has_card("zhugejin"), "诸葛瑾 can't be asked along before 结局十一")
		check(not s.has_card("lvmeng_qingnian"), "吕蒙 can't be recruited before 结局九")
		check(not s.has_card("daqiao") and not p.has("hn_wedding"), "the double wedding (and 大乔) wait for 第七章")
		for r in ["wentai_shu", "zhou_pu", "weixi"]:
			check(s.relics.has(r), "第六章 hands over the 宝物 " + r)
		for line in ["南线：家书讨袁", "周家：解围", "鲁肃：指囷相赠", "陈武：入队", "二乔：解救", "冯夫人：交给吴夫人",
				"南线：浮桥一瞥", "庐江：刘晔调停", "庐江：雷家覆灭", "庐江：喜期将近"]:
			check(s.run_records.has(line), "第六章 records " + line)
		finish(q, s)
		check_eq(Quests.current_quest(s)["id"], "jiangdong", "庐江：喜期将近 → 第七章 · 江东小霸王")


func test_south_chapter6_recruiting_lvmeng_after_ending_eleven() -> void:
	var s := ch6s_save()
	s.flags.append(E10)
	s.flags.append(E11)
	var q := quest_by_id("huainan_s")
	var p := walk(q, s, [], 1, 0, 0)
	for sid in ["hn_t_kuibing", "hn_lvmeng", "hn_lvmeng_take"]:
		check(p.has(sid), "passes " + sid)
	check(not p.has("hn_lvmeng_go"), "the 面饼 scene is only for sending him off")
	check(s.has_card("lvmeng_qingnian"), "吕蒙 joins after 结局九")
	check(s.run_records.has("吕蒙：入队"))


func test_south_chapter6_xiaoqiao_remembers_the_river_only_if_they_met_in_chapter1() -> void:
	var met := ch6s_save()
	met.flags.append("二乔：河边初见")
	var p := walk(quest_by_id("huainan_s"), met, [])
	check(p.has("hn_qiao_b") and not p.has("hn_qiao"), "met at the river in 第一章: 小乔 knows 周瑜")
	var fresh := walk(quest_by_id("huainan_s"), ch6s_save(), [])
	check(fresh.has("hn_qiao") and not fresh.has("hn_qiao_b"), "never met: a first meeting")


func test_a_square_that_hands_over_a_relic_reports_it_for_the_reveal() -> void:
	## the map screen shows a 宝物 card moment for every gained entry marked relic
	var s := ch6s_save()
	var q := quest_by_id("huainan_s")
	Quests.begin(q, s, rng(2))
	s.square = "hn_zhoujia"
	var gained := Quests.resolve(q, s, rng(2), -1)
	var relics: Array = gained.filter(func(c): return c.get("relic", false))
	check_eq(relics.map(func(c): return c["id"]), ["zhou_pu"], "周家 hands over the 周家族谱 and says so")
	check(s.relics.has("zhou_pu"))


func test_south_chapter6_plays_with_real_fights() -> void:
	var s := ch6s_save()
	var q := quest_by_id("huainan_s")
	var r := rng(6)
	Quests.begin(q, s, r)
	var fights := 0
	for _step in 200:
		var sq := Quests.here(q, s)
		if sq["type"] == "mystery" and not s.resolved:
			var ev := Quests.event_here(q, s, r)
			var ok: Array = range(ev["options"].size()).filter(func(i): return Quests.option_blocked(s, ev["options"][i]) == "")
			var keep: Array = ok.filter(func(i): return not JSON.stringify(ev["options"][i]).contains("drop_relic"))
			Quests.choose_event(q, s, r, (keep if not keep.is_empty() else ok)[0])  # a 小偷 taking a story 宝物 would fail the relic checks by chance
		if (sq["type"] == "battle" or not s.event_battle.is_empty()) and not s.resolved:
			var f := Quests.battle_here(q, s)
			s.party = s.auto_party()
			var b := Battle.start(f["battle"], s.party_leaders(), r.randi(), s.damage, s.carry_extra, s.carry_uses, f["ambush"])
			bot_fight(b)
			fights += 1
			s.damage = 0
		Quests.offer(q, s, r)
		Quests.resolve(q, s, r, 0 if not s.offer.is_empty() else -1)
		s.offer = []
		s.resolved = true
		var opts := Quests.next_options(q, s)
		if opts.is_empty():
			break
		Quests.move(q, s, opts[0]["id"])
	check_eq(s.square, "hn_shensuo", "the default (开仓分田) route plays through to 结局七")
	check(fights >= 8, "fought the chapter's battles (%d)" % fights)


func test_lap4_chapter4_beats_zhang_ji_and_zhang_xiu_and_jiaxu_joins() -> void:
	for flags in [[E3], []]:
		for fork in [["m2"], ["rest"]]:
			var s := lap_save(["董白：留下", E1, E2, "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"] + flags,
					["prologue", "taodong", "yuxi"])
			var p := walk(quest_by_id("dongui"), s, fork, 1, 0, 0)
			for sid in ["zhangxiu6", "zhangji6", "jiaxu6"]:
				check_eq(p.has(sid), not flags.is_empty(), "%s only on 四周目 %s %s" % [sid, str(flags), fork[0]])
			if not flags.is_empty():
				check(not p.has("zhuibing") and not p.has("fanchou6"), "四周目 meets 张家 instead of the old pursuers")
			check_eq(s.has_card("jiaxu"), not flags.is_empty())
			check_eq(s.run_records.has(JX), not flags.is_empty())
			check(p.has(fork[0]) and p.has("shaoka") and p.has("xuhuang") and p[-1] == "dongtao", "reaches 南阳 via " + fork[0])


func test_lap4_chapter4_jiaxu_can_be_let_go_instead_of_bound() -> void:
	var s := lap_save(["董白：留下", E1, E2, "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓", E3],
			["prologue", "taodong", "yuxi"])
	var p := walk(quest_by_id("dongui"), s, ["m2"], 1, 0, 1)
	check(p.has("jiaxu6") and p.has("jiaxu6_free") and not p.has("jiaxu6_bind"), "放走 takes the free branch")
	check(not s.has_card("jiaxu") and not s.run_records.has(JX), "a freed 贾诩 never joins")
	check(p.has("luoyang_rest") and not p.has("luoyang_rest4"), "and the Luoyang rest is the plain one")


# ---- 北线第四章 · 双凤乱太行 -----------------------------------------------------------------
func beihai_save() -> SaveData:
	var s := lap_save(["出生：冀州无极", "界桥：救下公孙瓒"], ["prologue", "luoyang_n", "heishan"])
	check_eq(Quests.current_quest(s)["id"], "beihai")
	return s


# ---- 北线第五章 · 铁纪徐州 ---------------------------------------------------------------

func xuzhou_save(flags: Array) -> SaveData:
	var s := lap_save(["出生：冀州无极", "界桥：救下公孙瓒", "郑姜：和好", "北线：北海相"] + flags,
			["prologue", "luoyang_n", "heishan", "beihai"])
	for c in ["zhaoyun", "guojia", "taishici", "lvlingqi", "zhangning", "zhenghao", "jiangqiao"]:
		s.grant_card(c)
	if flags.has("军纪：严明"):
		s.grant_card("xiahoulan")
	return s


func test_north_chapter5_follows_beihai() -> void:
	check_eq(Quests.current_quest(xuzhou_save([]))["id"], "xuzhou", "北海相 → 第五章 · 铁纪徐州")


func test_north_chapter5_without_military_law_ends_in_ending_eight() -> void:
	var s := xuzhou_save([])
	var q := quest_by_id("xuzhou")
	var p := walk(q, s, [])
	for sid in ["xz_start", "xz_muster", "xz_youqi", "xz_xiahoudun", "xz_rest1", "xz_seal", "xz_mifu", "xz_needle", "xz_chaos",
			"xz_accuse", "xz_banquet", "xz_daofu", "xz_menhou"]:
		check(p.has(sid), "失律 route passes " + sid)
	for sid in ["xz_muster_j", "xz_law", "xz_caobao", "xz_lvbu", "xz_wedding"]:
		check(not p.has(sid), "失律 route never reaches " + sid)
	check_eq(p[-1], "xz_menhou")
	check(s.run_records.has("结局六 · 失律"), "the run reaches 结局六")
	finish(q, s)
	check(s.flags.has("结局六 · 失律"))
	check(Quests.current_quest(s) == null, "the story stops at 结局六")


func test_north_chapter5_losing_the_banquet_fight_is_ending_eight_too() -> void:
	var s := xuzhou_save([])
	var q := quest_by_id("xuzhou")
	Quests.begin(q, s, rng(3))
	s.square = "xz_daofu"
	check(Quests.lose(q, s, rng(3)), "the 刀斧手 fight carries on into the ending")
	check_eq(s.square, "xz_menhou")


func test_north_chapter5_with_military_law_takes_xuzhou() -> void:
	for fork in [[], ["xz_m1", "xz_m2", "xz_m3"]]:
		var s := xuzhou_save(["军纪：严明"])
		var q := quest_by_id("xuzhou")
		var p := walk(q, s, fork)
		for sid in ["xz_muster_j", "xz_xiahoudun", "xz_seal", "xz_needle", "xz_law", "xz_caobao", "xz_chendeng", "xz_lvbu_come",
				"xz_beat", "xz_fu", "xz_langqi", "xz_xianzhen", "xz_lvbu", "xz_will", "xz_bingzhou", "xz_chengong", "xz_feast", "xz_end"]:
			check(p.has(sid), "铁纪 route passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["xz_muster", "xz_chaos", "xz_banquet", "xz_menhou"]:
			check(not p.has(sid), "铁纪 route never reaches " + sid)
		check_eq(p[-1], "xz_end")
		for c in ["zhangliao", "gaoshun"]:
			check(s.has_card(c), "%s joins in 第五章" % c)
		for r in ["xuzhou_yin", "chen_mago"]:
			check(s.relics.has(r), "第五章 hands over the 宝物 " + r)
		for line in ["刘备：秒接徐州印", "陈家：倒向主角", "刘备：投曹", "徐州：接任徐州牧", "张辽高顺：入队", "陈宫：供起来了"]:
			check(s.run_records.has(line), "第五章 records " + line)
		check(not s.run_records.has("结局六 · 失律"))
		finish(q, s)
		check_eq(Quests.current_quest(s)["id"], "huainan_n", "徐州：接任徐州牧 → 第六章 · 淮南折帝旗")


func test_north_chapter5_plays_with_real_fights() -> void:
	for flags in [[], ["军纪：严明"]]:
		var s := xuzhou_save(flags)
		var q := quest_by_id("xuzhou")
		var r := rng(7)
		Quests.begin(q, s, r)
		var fights := 0
		for _step in 200:
			var sq := Quests.here(q, s)
			if sq["type"] == "mystery" and not s.resolved:
				var ev := Quests.event_here(q, s, r)
				var ok: Array = range(ev["options"].size()).filter(func(i): return Quests.option_blocked(s, ev["options"][i]) == "")
				Quests.choose_event(q, s, r, ok[0])
			if (sq["type"] == "battle" or not s.event_battle.is_empty()) and not s.resolved:
				var f := Quests.battle_here(q, s)
				s.party = s.auto_party()
				var b := Battle.start(f["battle"], s.party_leaders(), r.randi(), s.damage, s.carry_extra, s.carry_uses, f["ambush"])
				bot_fight(b)
				fights += 1
				s.damage = 0
			Quests.offer(q, s, r)
			Quests.resolve(q, s, r, 0 if not s.offer.is_empty() else -1)
			s.offer = []
			s.resolved = true
			var opts := Quests.next_options(q, s)
			if opts.is_empty():
				break
			Quests.move(q, s, opts[0]["id"])
		check_eq(s.square, "xz_end" if flags.has("军纪：严明") else "xz_menhou", "reached the end of 第五章 %s" % str(flags))
		check(fights >= 5, "fought the chapter's battles (%d)" % fights)


func test_beihai_peace_is_locked_until_ending_seven_has_happened() -> void:
	## 第一次走第四章，调解双凤是灰的：只能放任她们内讧，走到「结局四 · 绝罚」才会解锁和好
	var q := quest_by_id("beihai")
	var first := beihai_save()
	var choose: Dictionary = q["squares"]["bh_zj_choose"]
	var peace: Dictionary = choose["choose"][0]
	check(Quests.option_locked(first, peace), "第一次：调解双凤被锁住")
	check(not Quests.option_locked(first, choose["choose"][1]), "第一次：随她们去可选")
	var again := beihai_save()
	again.flags.append("结局四 · 绝罚")
	check(not Quests.option_locked(again, peace), "吃过结局四之后：调解双凤解锁")


func test_beihai_peace_route_wins_through_to_beihai() -> void:
	var s := beihai_save()
	s.flags.append("结局四 · 绝罚")  # peace needs ending seven first
	var q := quest_by_id("beihai")
	var path := walk(q, s, [], 1, 0, 0)
	for sid in ["bh_zheng", "bh_jiang", "bh_zj_peace", "bh_zj_join", "bh_lubu", "bh_flee", "bh_guanhai", "bh_porridge", "bh_end"]:
		check(path.has(sid), "passes " + sid)
	check(not path.has("bh_escape") and not path.has("bh_bad_end"), "winning against 吕布 skips the retreat scenes")
	for c in ["zhenghao", "jiangqiao", "taishici", "beihai_tuntian", "kongrong"]:
		check(s.has_card(c), "got " + c)
	check(not path.has("bh_zj_apart") and not path.has("bh_zj_fight"), "和好线不经过内讧那一格")
	var j := beihai_save()
	Quests.begin(q, j)
	j.square = "bh_zj_join"
	j.resolved = false
	Quests.resolve(q, j, rng(1), -1)
	check(j.has_card("zheng_daoshou") and j.has_card("jiang_jiguanshou"), "the two soldier cards come with the two women")
	finish(q, s)
	check(s.flags.has("北线：北海相") and s.flags.has("郑姜：和好"), "records become flags")


func test_beihai_losing_to_lvbu_after_peace_escapes() -> void:
	var s := beihai_save()
	var q := quest_by_id("beihai")
	Quests.begin(q, s)
	Quests.record(s, "郑姜：和好")
	s.square = "bh_lubu"
	s.resolved = false
	check(Quests.lose(q, s), "the story carries on")
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), [])
	Quests.resolve(q, s, rng(1), -1)
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["bh_escape"])


func test_beihai_after_a_feud_ending_seven_comes_whether_you_win_or_lose_to_lvbu() -> void:
	var s := beihai_save()
	var q := quest_by_id("beihai")
	var path := walk(q, s, [], 1, 0, 1)
	check(path.has("bh_zj_fight") and path.has("bh_win_feud") and path.has("bh_bad_end") and path.has("bh_bad_lingqi"), "内讧线打赢吕布也守不住：照样走结局四")
	check(not path.has("bh_flee") and not path.has("bh_end"), "内讧线到不了千里突围和后面的章节")
	check_eq(path[-1], "bh_bad_lingqi")
	check(s.run_records.has("结局四 · 绝罚"), "打赢了也记结局四")
	check(path.has("bh_zj_apart") and not path.has("bh_zj_join") and not path.has("bh_zj_peace"), "内讧线不经过和好 / 收服那两格")
	for c in ["zhenghao", "jiangqiao", "zheng_daoshou", "jiang_jiguanshou"]:
		check(not s.has_card(c), "内讧线收不到 " + c)
	Quests.begin(q, s)
	s.square = "bh_lubu"
	s.resolved = false
	Quests.lose(q, s)
	Quests.resolve(q, s, rng(1), -1)
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["bh_bad_end"])
	Quests.move(q, s, "bh_bad_end")
	Quests.resolve(q, s, rng(1), -1)
	check(not s.run_records.has("结局四 · 绝罚"), "the feud scene comes first")
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["bh_bad_lingqi"])
	Quests.move(q, s, "bh_bad_lingqi")
	Quests.resolve(q, s, rng(1), -1)
	check(s.run_records.has("结局四 · 绝罚"), "ending seven recorded")
	check_eq(q["ending"]["title"], "结局四 · 绝罚")
	check(Quests.next_options(q, s).is_empty(), "the story stops")


func test_beihai_fights_all_run_to_a_result() -> void:
	var s := beihai_save()
	for c in ["zhaoyun", "taishici", "zhenghao", "jiangqiao"]:
		s.grant_card(c)
	s.party = s.auto_party()
	for sc in ["bh_zhenghao", "bh_jiangqiao", "bh_lubu", "bh_guanhai"]:
		var b := Battle.start(sc, s.party_leaders(), 3)
		check(bot_fight(b) in ["win", "lose"], sc + " ends")


func test_north_chapter3_turning_your_back_plays_out_the_siege_before_ending_six() -> void:
	## 绕道避险 → a year on, 郭图 besieges 无极: four fights, a last night, 淳于琼 in the courtyard, then 覆巢
	var s := lap_save(["出生：冀州无极", "北线：班师冀州"], ["prologue", "luoyang_n"])
	var q := quest_by_id("heishan")
	var path := walk(q, s, [], 1, 0, 1)
	for sid in ["hs_save_choice", "hs_ignore", "hs_bad_return", "hs_bad_skip", "hs_bad_wall", "hs_bad_gate", "hs_bad_street",
			"hs_bad_night", "hs_bad_hall", "hs_bad_guotu", "hs_bad_end"]:
		check(path.has(sid), "覆巢 line passes " + sid)
	for sid in ["hs_zhangyan", "hs_yudu", "hs_hm2"]:
		check(not path.has(sid), "and never reaches " + sid)
	check(s.run_records.has("结局二 · 覆巢"), "the run reaches 结局二")
	var s2 := lap_save(["出生：冀州无极", "北线：班师冀州"], ["prologue", "luoyang_n"])
	Quests.begin(q, s2)
	s2.run_records.append("张宁：没救")
	s2.square = "hs_bad_hall"
	s2.resolved = false
	check(Quests.lose(q, s2), "losing the last stand is not a failed run: the story goes on")
	check_eq(s2.square, "hs_bad_guotu", "…to 郭图 himself")
	s2.resolved = false
	check(Quests.lose(q, s2), "and losing to him is not a failed run either")
	check_eq(s2.square, "hs_bad_end", "…the ending")


func test_north_chapter3_郭图_stands_in_the_way_of_the_escape_too() -> void:
	var s := lap_save(["出生：冀州无极", "北线：班师冀州", "结局二 · 覆巢"], ["prologue", "luoyang_n"])  # 覆巢 seen once: the rescue option is open
	var q := quest_by_id("heishan")
	var r := rng(1)
	Quests.begin(q, s, r)
	var path: Array = [s.square]
	for _step in 200:
		var sq := Quests.here(q, s)
		if sq["type"] == "mystery" and not s.resolved:
			var ev := Quests.event_here(q, s, r)
			var ok: Array = range(ev["options"].size()).filter(func(i): return Quests.option_blocked(s, ev["options"][i]) == "")
			var keep: Array = ok.filter(func(i): return not JSON.stringify(ev["options"][i]).contains("drop_relic"))
			Quests.choose_event(q, s, r, (keep if not keep.is_empty() else ok)[0])  # a 小偷 taking a story 宝物 would fail the relic checks by chance
		Quests.offer(q, s, r)
		var pick_idx := -1
		if sq["type"] == "choose":  # the first option that is not locked (救人 → 拔刀相助)
			for i in sq["choose"].size():
				if not Quests.option_locked(s, sq["choose"][i]):
					pick_idx = i
					break
		Quests.resolve(q, s, r, pick_idx if sq["type"] == "choose" else (0 if not s.offer.is_empty() else -1))
		s.offer = []
		s.resolved = true
		var opts := Quests.next_options(q, s)
		if opts.is_empty():
			break
		Quests.move(q, s, opts[0]["id"])
		path.append(opts[0]["id"])
	for sid in ["hs_timeskip", "hs_guotu", "hs_breakout", "hs_guotu_fight", "hs_em1"]:
		check(path.has(sid), "the rescue line passes " + sid)


func test_north_chapter5_sparing_xiahoudun_waits_for_ending_nine() -> void:
	## 下邳城外「放他回兖州」is greyed until 「结局八 · 断桥」; 咬住尾巴 is always open and is the default
	var q := quest_by_id("xuzhou")
	var opts: Array = q["squares"]["xz_xiapi"]["choose"]
	var s := xuzhou_save(["军纪：严明"])
	check(Quests.option_locked(s, opts[0]), "放他回兖州 greyed on a first run")
	check(not Quests.option_locked(s, opts[1]), "咬住尾巴 open")
	var p := walk(q, s, [])
	check(p.has("xz_bite") and p.has("xz_xiahoudun") and p.has("xz_rest1"), "the default bites the rear guard")
	check(s.run_records.has("夏侯惇：痛击殿后"))
	var s2 := xuzhou_save(["军纪：严明", "结局八 · 断桥"])
	check(not Quests.option_locked(s2, opts[0]), "断桥 opens 放他回兖州")
	var p2 := walk(q, s2, [], 1, 0, 0)
	for sid in ["xz_spare", "xz_xiahoudun_f", "xz_rest1_f", "xz_end"]:
		check(p2.has(sid), "the spare route passes " + sid)
	check(not p2.has("xz_xiahoudun") and not p2.has("xz_bite"))
	check(s2.run_records.has("夏侯惇：放他回兖州"))


# ---- 北线第六章 · 淮南折帝旗 ---------------------------------------------------------------

func huainan_n_save(flags: Array) -> SaveData:
	var s := xuzhou_save(["军纪：严明", "徐州：接任徐州牧"] + flags)
	s.quests_cleared.append("xuzhou")
	for c in ["zhangliao", "gaoshun", "xiahoulan"]:
		s.grant_card(c)
	return s


func test_north_chapter6_follows_xuzhou() -> void:
	check_eq(Quests.current_quest(huainan_n_save(["曹操：借粮", "夏侯惇：痛击殿后"]))["id"], "huainan_n", "徐州：接任徐州牧 → 第六章 · 淮南折帝旗")


func test_north_chapter6_a_debt_of_gratitude_lets_you_walk_out() -> void:
	var cases := {"hnn_xj_a": ["曹操：借粮", "夏侯惇：放他回兖州"], "hnn_xj_b": ["曹操：借粮", "夏侯惇：痛击殿后"],
		"hnn_xj_c": ["曹操：没借", "夏侯惇：放他回兖州"]}
	for xj in cases:
		for fork in [[], ["hnn_m1", "hnn_m2", "hnn_m3"]]:
			var s := huainan_n_save(cases[xj])
			var q := quest_by_id("huainan_n")
			var p := walk(q, s, fork)
			for sid in ["hnn_start", "hnn_letter", "hnn_jiu", "hnn_qiaorui", "hnn_jiling", "hnn_cheng", "hnn_zhujiu", "hnn_bw1",
					"hnn_bw2", "hnn_bw3", "hnn_choose", "hnn_feast", xj, "hnn_du", "hnn_niaodun", "hnn_bridge", "hnn_news", "hnn_end"]:
				check(p.has(sid), "%s: passes %s (forks %s)" % [xj, sid, str(fork)])
			for sid in ["hnn_letter_bad", "hnn_trap", "hnn_gongmen", "hnn_duanqiao", "hnn_bad_end"]:
				check(not p.has(sid), "%s: never reaches %s" % [xj, sid])
			check_eq(p[-1], "hnn_end")
			check(s.has_card("dufuren"), "杜夫人 joins")
			for r in ["weixi", "dujiu"]:
				check(s.relics.has(r), "第六章 hands over " + r)
			for line in ["北线：奉诏讨袁", "吕布：降曹", "杜夫人：随军", "北线：浮桥一瞥", "北线：让寿春"]:
				check(s.run_records.has(line), "第六章 records " + line)
			check(not s.run_records.has("结局八 · 断桥"))
			finish(q, s)
			check_eq(Quests.current_quest(s)["id"], "yecheng", "北线：让寿春 → 第七章 · 邺城惊雷")


func test_north_chapter6_no_grain_and_a_mauled_rear_guard_end_at_the_broken_bridge() -> void:
	var s := huainan_n_save(["曹操：没借", "夏侯惇：痛击殿后"])
	var q := quest_by_id("huainan_n")
	var p := walk(q, s, [])
	for sid in ["hnn_letter_bad", "hnn_zhujiu", "hnn_bw3", "hnn_feast", "hnn_trap", "hnn_maofang", "hnn_daofu", "hnn_gongmen",
			"hnn_fire", "hnn_duanqiao", "hnn_caught", "hnn_bad_end"]:
		check(p.has(sid), "断桥 route passes " + sid)
	for sid in ["hnn_letter", "hnn_xj_a", "hnn_xj_b", "hnn_xj_c", "hnn_du", "hnn_bridge", "hnn_news", "hnn_end"]:
		check(not p.has(sid), "断桥 route never reaches " + sid)
	check_eq(p[-1], "hnn_bad_end")
	check(not s.has_card("dufuren"), "杜夫人 never joins on this route")
	finish(q, s)
	check(s.flags.has("结局八 · 断桥"))
	check(Quests.current_quest(s) == null, "the story stops at 结局八")


func test_north_chapter6_lost_fights_carry_the_story_on() -> void:
	for pair in [["hnn_bw3", "hnn_choose_b", ["曹操：借粮", "夏侯惇：放他回兖州"]], ["hnn_gongmen", "hnn_fire", ["曹操：没借", "夏侯惇：痛击殿后"]],
			["hnn_duanqiao", "hnn_caught", ["曹操：没借", "夏侯惇：痛击殿后"]]]:
		var s := huainan_n_save(pair[2])
		var q := quest_by_id("huainan_n")
		Quests.begin(q, s, rng(3))
		s.square = pair[0]
		check(Quests.lose(q, s, rng(3)), "losing %s is not a restart" % pair[0])
		check_eq(s.square, pair[1])


func test_north_chapter6_sparring_generals_drop_their_own_cards_and_stay_public() -> void:
	## 比武 典韦 / 许褚 / 关羽 drop their own card (card_public): it doesn't make them chapter-only, both routes still recruit them
	var db := GameData.get_db()
	for pair in [["hnn_bw_dw", "dianwei"], ["hnn_bw_xc", "xuchu"], ["hnn_bw_gy", "guanyu"]]:
		check_eq(db.enemies[db.scenarios[pair[0]]["enemy"]]["card"], pair[1], "%s drops %s" % pair)
		check(db.is_public(pair[1]), "%s stays in the public pool" % pair[1])


func test_south_chapter6_burning_the_clans_deeds_ends_in_ending_ten() -> void:
	## 「请刘晔居中」 is greyed until 「结局七 · 深锁」; 开仓分田 turns 庐江's clans to 袁术 and 雷家 carries off the 二乔
	var q := quest_by_id("huainan_s")
	var opts: Array = q["squares"]["hn_shizu"]["choose"]
	var s := ch6s_save()
	check(Quests.option_locked(s, opts[0]), "请刘晔居中 greyed on a first run")
	check(Quests.option_hint(s, opts[0]).contains("结局七 · 深锁"))
	check(not Quests.option_locked(s, opts[1]), "开仓分田 open")
	var p := walk(q, s, [])
	for sid in ["hn_shizu", "hn_kaicang", "hn_kc_chase", "hn_kc_gate", "hn_jibao", "hn_wanshui", "hn_qs_bad", "hn_shensuo"]:
		check(p.has(sid), "深锁 route passes " + sid)
	for sid in ["hn_liuye", "hn_qs", "hn_leixu", "hn_fuzhu", "hn_zhengbao", "hn_shouchun", "hn_bridge", "hn_jiangting", "hn_feng2", "hn_end"]:
		check(not p.has(sid), "深锁 route never reaches " + sid)
	check_eq(p[-1], "hn_shensuo")
	check(not s.has_card("liuye"), "刘晔 walks out")
	finish(q, s)
	check(s.flags.has(E10))
	check(Quests.current_quest(s) == null, "the story stops at 结局七")
	var s2 := ch6s_save()
	s2.flags.append(E10)
	check(not Quests.option_locked(s2, opts[0]), "深锁 opens 请刘晔居中")


func test_south_chapter6_losing_at_qianshan_is_ending_ten_too() -> void:
	var s := ch6s_save()
	var q := quest_by_id("huainan_s")
	Quests.begin(q, s, rng(3))
	s.run_records.append("庐江：开仓分田")
	s.square = "hn_qs_bad"
	check(Quests.lose(q, s, rng(3)), "the 灊山寨 fight carries on into the ending")
	check_eq(s.square, "hn_shensuo")


# ---- 南线第七章 · 江东小霸王 ---------------------------------------------------------------

func ch7s_save(flags := []) -> SaveData:
	var s := ch6s_save()
	s.flags += [E10, "庐江：刘晔调停", "庐江：雷家覆灭", "庐江：喜期将近"] + flags
	s.quests_cleared.append("huainan_s")
	for c in ["liuye", "lusu", "chenwu"]:
		s.grant_card(c)
	if s.flags.has("吕蒙：入队"):
		s.grant_card("lvmeng_qingnian")
	return s


func test_south_chapter7_follows_the_double_wedding() -> void:
	check_eq(Quests.current_quest(ch7s_save())["id"], "jiangdong")


func test_south_chapter7_opens_with_the_double_wedding() -> void:
	var s := ch7s_save()
	var q := quest_by_id("jiangdong")
	var r := rng(1)
	Quests.begin(q, s, r)
	check_eq(s.square, "jd_wedding")
	Quests.resolve(q, s, r, -1)
	check(s.has_card("daqiao"), "大乔 joins at the wedding")
	check(s.run_records.has("庐江：双婚"), "第七章 records the wedding")
	check_eq(Quests.next_options(q, s).map(func(o): return o["id"]), ["jd_start"])


func test_south_chapter7_siding_with_yan_baihu_ends_in_ending_eleven() -> void:
	## 「收服义匪甘宁」 is greyed until 「吕蒙：入队」; siding with 严白虎 against 锦帆贼 gets 孙策 shot by 许贡's men and 甘宁
	var q := quest_by_id("jiangdong")
	var opts: Array = q["squares"]["jd_ganning"]["choose"]
	var s := ch7s_save()
	check(Quests.option_locked(s, opts[0]), "收服义匪甘宁 greyed on a first run")
	check(Quests.option_hint(s, opts[0]).contains("吕蒙：入队"))
	check(not Quests.option_locked(s, opts[1]), "联手严白虎 open")
	var p := walk(q, s, [])
	for sid in ["jd_start", "jd_shenting", "jd_moling", "lm_rest", "jd_yeyan", "jd_ganning", "jd_b_ally", "jd_b_road", "jd_b_zt", "jd_b_gan", "jd_b_rest",
			"jd_b_hunt", "jd_b_menke", "jd_pifu"]:
		check(p.has(sid), "匹夫 route passes " + sid)
	for sid in ["lm_join", "jd_ganning_lm", "jd_g_meet", "jd_g_gn", "jd_g_join", "jd_g_yan", "jd_g_zhoutai", "jd_wanglang", "jd_fuchun", "jd_end"]:
		check(not p.has(sid), "匹夫 route never reaches " + sid)
	check_eq(p[-1], "jd_pifu")
	check(not s.has_card("ganning"), "甘宁 never joins on this route")
	finish(q, s)
	check(s.flags.has(E11))
	check(Quests.current_quest(s) == null, "the story stops at 结局九")
	check(not Quests.option_locked(ch7s_save(["吕蒙：入队"]), opts[0]), "吕蒙入队 opens 收服义匪甘宁")


func test_south_chapter7_with_the_jinfan_men_takes_jiangdong() -> void:
	for fork in [[], ["jd_n_m", "jd_s_m", "jd_k_m"]]:
		var s := ch7s_save([E11, "吕蒙：入队"])
		var q := quest_by_id("jiangdong")
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["jd_start", "jd_shenting", "lm_fight", "lm_join", "jd_yeyan", "jd_ganning_lm", "jd_g_meet", "jd_g_jq", "jd_g_zt", "jd_g_gn", "jd_g_join", "jd_g_road", "jd_g_yanyu", "jd_g_yan", "jd_g_rest", "jd_g_hunt",
				"jd_g_menke", "jd_g_zhoutai", "jd_kuaiji", "jd_yufan", "jd_wanglang", "jd_wanglang_go", "jd_fuchun", "jd_end"]:
			check(p.has(sid), "江东 route passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["jd_b_ally", "jd_b_zt", "jd_b_gan", "jd_b_menke", "jd_pifu"]:
			check(not p.has(sid), "江东 route never reaches " + sid)
		check_eq(p[-1], "jd_end")
		for c in ["ganning", "zhoutai", "jiangqin", "zhangzhao", "yufan", "sunce_bawang", "zhouyu_chibi", "lvmeng_qingnian"]:
			check(s.has_card(c), "%s joins in 第七章" % c)
		check(not s.has_card("sunquan") and not s.has_card("sunshangxiang"), "孙权、孙尚香 wait for 第八章")
		for line in ["南线：东取江东", "江东：收服锦帆", "甘宁：入队", "江东：周泰护主", "江东：会稽平定", "南线：江东平定"]:
			check(s.run_records.has(line), "第七章 records " + line)
		finish(q, s)
		check_eq(Quests.current_quest(s)["id"], "menghu", "南线：江东平定 → 第八章 · 猛虎之陨")


func test_south_chapter7_losing_at_dantu_is_ending_eleven_too() -> void:
	var s := ch7s_save()
	var q := quest_by_id("jiangdong")
	Quests.begin(q, s, rng(3))
	s.run_records.append("江东：联手严白虎")
	s.square = "jd_b_menke"
	check(Quests.lose(q, s, rng(3)), "the 丹徒山 ambush carries on into the ending")
	check_eq(s.square, "jd_pifu")


# ---- 南线第八章 · 猛虎之陨 ----------------------------------------------------------------

const E12 := "结局十一 · 曲误"


func ch8s_save(flags := []) -> SaveData:
	var s := ch7s_save([E11])
	s.flags += ["江东：收服锦帆", "甘宁：入队", "江东：会稽平定", "南线：江东平定"] + flags
	s.quests_cleared.append("jiangdong")
	for c in ["ganning", "zhoutai", "jiangqin", "zhangzhao", "yufan", "lvmeng_qingnian"]:
		s.grant_card(c)
	return s


func test_south_chapter8_follows_jiangdong_and_hands_over_sunquan_and_sunshangxiang() -> void:
	var s := ch8s_save()
	var q := quest_by_id("menghu")
	check_eq(Quests.current_quest(s)["id"], "menghu")
	var r := rng(1)
	Quests.begin(q, s, r)
	check_eq(s.square, "m8_start")
	Quests.resolve(q, s, r, -1)
	check(s.has_card("sunquan") and s.has_card("sunshangxiang"), "孙权、孙尚香 join at the start of 第八章")


func test_south_chapter8_without_zhugejin_ends_in_ending_twelve() -> void:
	## first time through: the door at 曲阿 is locked, nobody reads 诸葛亮's 「先火后水」, 周瑜 dies at 白河
	for fork in [[], ["m8_q_m1", "m8_h_m1", "m8_d_m1", "m8_x_m1"]]:
		var s := ch8s_save()
		var q := quest_by_id("menghu")
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["m8_start", "m8_bidao", "m8_qua", "m8_chaimen", "m8_shankou", "m8_liniang", "m8_zulang", "m8_shanmeng", "m8_news", "m8_modao", "m8_xianfeng", "m8_zhuibing", "m8_tuogu", "m8_yuye",
				"m8_luoyang", "m8_nanyang", "m8_xiangyang", "m8_bowang", "m8_quyou", "m8_baihe_bad", "m8_quwu"]:
			check(p.has(sid), "曲误 route passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["m8_jin", "m8_nanyang_j", "m8_jin_read", "m8_baihe", "m8_xiongdi", "m8_bazhen", "m8_end"]:
			check(not p.has(sid), "曲误 route never reaches " + sid)
		check_eq(p[-1], "m8_quwu")
		check(not s.run_records.has("诸葛瑾：入队"), "诸葛瑾 goes off to 荆州 and misses 白河")
		check(s.has_card("zulang") and s.has_card("liniang"), "祖郎、黎娘 join after the 山越")
		for line in ["丹阳：山越归附", "南线：洛阳陷落", "孙坚战死", "易帜为吴", E12]:
			check(s.run_records.has(line), "第八章 records " + line)
		finish(q, s)
		check(s.flags.has(E12))
		check(Quests.current_quest(s) == null, "the story stops at 结局十一")


func test_south_chapter8_losing_at_baihe_is_ending_twelve_too() -> void:
	var s := ch8s_save()
	var q := quest_by_id("menghu")
	Quests.begin(q, s, rng(3))
	s.square = "m8_baihe_bad"
	check(Quests.lose(q, s, rng(3)), "the 白河 fight carries on into the ending")
	check_eq(s.square, "m8_quwu")


func test_south_chapter8_after_ending_twelve_zhugejin_saves_zhouyu() -> void:
	for fork in [[], ["m8_q_m1", "m8_h_m1", "m8_d_m1", "m8_x_m1", "m8_b_m1"]]:
		var s := ch8s_save([E12, "诸葛瑾：入队"])
		s.grant_card("zhugejin")
		var q := quest_by_id("menghu")
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["m8_start", "m8_jin", "m8_shankou", "m8_zulang", "m8_shanmeng", "m8_tuogu", "m8_luoyang", "m8_nanyang_j", "m8_bowang", "m8_quyou", "m8_jin_read", "m8_baihe",
				"m8_xiongdi", "m8_youcuo", "m8_bazhen", "m8_zhoutai", "m8_end"]:
			check(p.has(sid), "白河 good route passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["m8_chaimen", "m8_nanyang", "m8_baihe_bad", "m8_quwu"]:
			check(not p.has(sid), "good route never reaches " + sid)
		check_eq(p[-1], "m8_end")
		for line in ["孙坚战死", "易帜为吴", "白河：周瑜生还", "汉水相持"]:
			check(s.run_records.has(line), "第八章 records " + line)
		finish(q, s)
		check_eq(Quests.current_quest(s)["id"], "tianfu", "第九章 follows the good 第八章")


func test_south_chapter8_the_bazhen_fight_is_lost_and_carries_on() -> void:
	var s := ch8s_save([E12, "诸葛瑾：入队"])
	var q := quest_by_id("menghu")
	Quests.begin(q, s, rng(3))
	s.square = "m8_bazhen"
	check(Quests.lose(q, s, rng(3)), "八阵 is a retreat, not a restart")
	check_eq(s.square, "m8_zhoutai")


func test_ganning_no_longer_joins_in_chapter5() -> void:
	## 甘宁 moved to 第七章: the 荆襄 event's 「劝他跟你走」 no longer offers his card, and no 招贤 list before 第七章 has him
	var ev: Dictionary = GameData.get_db().events["ganning"]
	check(not JSON.stringify(ev["options"][0]["effects"]).contains("offer"), "劝他跟你走 says goodbye instead")
	for id in ["jingxiang", "huainan_s"]:
		check(not quest_by_id(id)["recruit_pool"].has("ganning"), "%s 招贤 has no 甘宁" % id)


func test_south_chapter7_the_jinfan_trials_can_be_lost() -> void:
	## 收服锦帆: 蒋钦, 周泰, 甘宁 one by one — 点到为止, losing one still moves on and they join all the same
	var s := ch7s_save([E11])
	var q := quest_by_id("jiangdong")
	Quests.begin(q, s, rng(3))
	s.run_records.append("江东：收服锦帆")
	for pair in [["jd_g_jq", "jd_g_zt"], ["jd_g_zt", "jd_g_gn"], ["jd_g_gn", "jd_g_join"]]:
		s.square = pair[0]
		check(Quests.lose(q, s, rng(3)), "losing %s is not a restart" % pair[0])
		check_eq(s.square, pair[1])


func test_third_chapter_unchosen_route_is_drawn_ghosted_only_when_unlocked() -> void:
	## 第三章 draws both routes in their own row bands: the route not taken shows greyed, but a player who never opened
	## 驻守洛阳 (no 结局一) sees only the 南阳 route
	var q := quest_by_id("yuxi")
	var tale: Dictionary = q["squares"]["wenji_tale"]
	var supply: Dictionary = q["squares"]["supply"]
	var s := SaveData.new()
	Quests.begin(q, s, rng(3))
	check(not Quests.is_ghost(tale, s), "locked-out route stays hidden")
	check(Quests.is_open(supply, s), "南阳 route is open")
	s.flags = ["董白：留下", "结局一 · 玉碎"]
	check(Quests.is_ghost(tale, s), "unlocked route drawn greyed")
	s.run_records.append("路线：守洛阳")
	check(not Quests.is_ghost(tale, s) and Quests.is_open(tale, s), "taken route is open")
	check(Quests.is_ghost(supply, s), "南阳 route greyed once 守洛阳 is taken")


func test_choosing_to_save_蔡文姬_takes_the_route_at_once() -> void:
	## the map must show the chosen line solid and the other greyed right after the choice, not only once 蔡文姬 has joined
	var q := quest_by_id("yuxi")
	var s := SaveData.new()
	s.flags = ["董白：留下", "结局一 · 玉碎"]
	Quests.begin(q, s, rng(3))
	s.square = "wenji_choice"
	s.resolved = false
	Quests.resolve(q, s, rng(3), 0)  # 出手相救
	check(s.run_records.has("路线：守洛阳"), "the line is recorded at the choice")
	check(Quests.is_open(q["squares"]["wenji_tale"], s) and Quests.is_ghost(q["squares"]["supply"], s), "the 蔡文姬 line is solid, the other greyed")


func test_south_chapter6_zhugejin_can_be_asked_along_only_after_ending_twelve() -> void:
	var q := quest_by_id("huainan_s")
	var opts: Array = q["squares"]["hn_lusu"]["choose"]
	var first := ch6s_save()
	check(Quests.option_locked(first, opts[0]), "first time through: 请子瑜同行 is greyed")
	check(not Quests.option_locked(first, opts[1]))
	var s := ch6s_save()
	s.flags += [E10, "结局十一 · 曲误"]
	check(not Quests.option_locked(s, opts[0]), "after 结局十一 the option opens")
	var p := walk(q, s, [], 1, 0, 0)
	check(p.has("hn_lusu") and p[-1] == "hn_end")
	check(s.has_card("zhugejin") and s.has_card("lusu"), "诸葛瑾 joins with 鲁肃")
	finish(q, s)
	check(s.flags.has("诸葛瑾：入队"), "and 第八章 will know he came along")


# ---- 第九章 · 天府之国（南线）------------------------------------------------------------

const E13 := "结局十三 · 香烬"


func ch9s_save(flags := []) -> SaveData:
	var s := ch8s_save([E12, "诸葛瑾：入队"])
	s.flags += ["孙权、孙尚香：入队", "丹阳：山越归附", "南线：洛阳陷落", "孙坚战死", "易帜为吴", "白河：周瑜生还", "汉水相持"] + flags
	s.quests_cleared.append("menghu")
	for c in ["sunquan", "sunshangxiang", "zhugejin", "zulang", "liniang"]:
		s.grant_card(c)
	return s


func test_south_chapter9_follows_the_good_menghu_ending_only() -> void:
	check_eq(Quests.current_quest(ch9s_save())["id"], "tianfu")
	var s := ch8s_save()
	s.flags += ["孙坚战死", "易帜为吴", E12]
	s.quests_cleared.append("menghu")
	check(Quests.current_quest(s) == null, "结局十一 stops the story: no 第九章")


func test_south_chapter9_without_luxun_ends_in_ending_thirteen() -> void:
	for fork in [[], ["t9_a_m1", "t9_c_m1", "t9_e_m1", "t9_g_m1"]]:
		var s := ch9s_save()
		var q := quest_by_id("tianfu")
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["t9_start", "t9_yexi", "t9_kuimen", "t9_yanyan", "t9_yanyan_join", "t9_luocheng", "t9_wuxian", "t9_zhurong", "t9_maoshi", "t9_panshe_bad", "t9_xiangjin"]:
			check(p.has(sid), "香烬 route passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["t9_yexi_lx", "t9_kanfeng", "t9_panshe", "t9_qiqin", "t9_end"]:
			check(not p.has(sid), "香烬 route never reaches " + sid)
		check_eq(p[-1], "t9_xiangjin")
		for c in ["yanyan", "zhangren", "wuxian", "zhurong"]:
			check(s.has_card(c), c + " joins on the way")
		check(s.run_records.has(E13))
		finish(q, s)
		check(s.flags.has(E13))
		check(Quests.current_quest(s) == null, "the story stops at 结局十三")


func test_south_chapter9_losing_in_the_valley_is_ending_thirteen_too() -> void:
	var s := ch9s_save()
	var q := quest_by_id("tianfu")
	Quests.begin(q, s, rng(3))
	s.square = "t9_panshe_bad"
	check(Quests.lose(q, s, rng(3)), "the 盘蛇谷 fire carries on into the ending")
	check_eq(s.square, "t9_xiangjin")


func test_south_chapter9_after_ending_thirteen_luxun_reads_the_wind() -> void:
	for fork in [[], ["t9_b_m1", "t9_d_m1", "t9_f_m1"]]:
		var s := ch9s_save([E13, "陆逊：入队"])
		s.grant_card("luxun_young")
		var q := quest_by_id("tianfu")
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["t9_yexi_lx", "t9_kanfeng", "t9_panshe", "t9_qiqin", "t9_end"]:
			check(p.has(sid), "good route passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["t9_yexi", "t9_panshe_bad", "t9_xiangjin"]:
			check(not p.has(sid), "good route never reaches " + sid)
		check_eq(p[-1], "t9_end")
		check(s.has_card("menghuo"))
		check(s.run_records.has("南线：益州与南中") and not s.run_records.has(E13))


func test_chapter6_luxun_can_only_study_under_zhouyu_after_ending_thirteen() -> void:
	var opts: Array = quest_by_id("huainan_s")["squares"]["hn_luxun"]["choose"]
	check_eq(opts[0]["requires"], E13)
	check_eq(opts[0]["card"], "luxun_young")
	var s := SaveData.create()
	check(Quests.option_locked(s, opts[0]), "greyed until 结局十三")
	s.flags.append(E13)
	check(not Quests.option_locked(s, opts[0]))


func test_south_chapter9_fazheng_only_comes_along_after_ending_fourteen() -> void:
	var opts: Array = quest_by_id("tianfu")["squares"]["t9_fazheng"]["choose"]
	check(Quests.option_locked(ch9s_save(), opts[0]), "first time through: 请他同行 is greyed")
	var s := ch9s_save()
	var p := walk(quest_by_id("tianfu"), s, [], 1, 0, 0)
	check(p.has("t9_fazheng_go") and not s.has_card("fazheng"), "first time through 法正 walks off")
	s = ch9s_save([E13, "陆逊：入队", "结局十五 · 算尽"])
	p = walk(quest_by_id("tianfu"), s, [], 1, 0, 0)
	check(p.has("t9_fazheng_take") and s.has_card("fazheng"), "after 结局十五 法正 joins")
	check(s.run_records.has("法正：入队"))


# ---- 第十章 · 奇袭关中（南线）------------------------------------------------------------

const E14 := "结局十五 · 算尽"


func ch10s_save(flags := []) -> SaveData:
	var s := ch9s_save([E13, "陆逊：入队"])
	s.flags += ["严颜：入队", "张任：入队", "吴苋：入队", "祝融：入队", "南线：益州与南中"] + flags
	s.quests_cleared.append("tianfu")
	for c in ["luxun_young", "yanyan", "zhangren", "wuxian", "zhurong", "menghuo"]:
		s.grant_card(c)
	if s.flags.has("法正：入队"):
		s.grant_card("fazheng")
	return s


func test_south_chapter10_follows_the_good_tianfu_ending_only() -> void:
	check_eq(Quests.current_quest(ch10s_save())["id"], "guanzhong")
	var s := ch9s_save([E13])
	s.quests_cleared.append("tianfu")
	check(Quests.current_quest(s) == null, "结局十三 stops the story: no 第十章")


func test_south_chapter10_first_time_the_ziwu_valley_ends_in_ending_fourteen() -> void:
	var q := quest_by_id("guanzhong")
	for sq in q["squares"].values():  # 法正 may not have come along: nothing before the 军议 may need him
		if sq["x"] < 15:
			check(not JSON.stringify(sq).contains("法正") and not sq.get("portraits", []).has("fazheng"), "%s needs 法正" % sq["id"])
	for fork in [[], ["g10_a_m1", "g10_c_m1", "g10_zw_m1"]]:
		var s := ch10s_save(["法正：不和"])
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["g10_start", "g10_yangang", "g10_zhangwei", "g10_zhanglu", "g10_xingye", "g10_dingjun", "g10_junyi", "g10_zw_start", "g10_zw_night", "g10_zw_fire", "g10_zw_liang", "g10_zw_exit", "g10_duanzhan"]:
			check(p.has(sid), "子午谷 route passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["g10_junyi_f", "g10_fenbing", "g10_chencang", "g10_lijue", "g10_zhuge", "g10_end"]:
			check(not p.has(sid), "子午谷 route never reaches " + sid)
		check_eq(p[-1], "g10_duanzhan")
		check(s.has_card("zhanglu") and s.has_card("yanpu"), "张鲁、阎圃 join in 汉中")
		check(s.run_records.has(E14))
		finish(q, s)
		check(Quests.current_quest(s) == null, "the story stops at 结局十五")


func test_south_chapter10_losing_at_the_valley_mouth_is_ending_fourteen_too() -> void:
	var s := ch10s_save()
	var q := quest_by_id("guanzhong")
	Quests.begin(q, s, rng(3))
	s.run_records.append("关中：子午谷")
	s.square = "g10_zw_exit"
	check(Quests.lose(q, s, rng(3)), "the 谷口 fight carries on into the ending")
	check_eq(s.square, "g10_duanzhan")


func test_south_chapter10_with_fazheng_the_valley_is_still_a_choice() -> void:
	var s := ch10s_save([E14, "法正：入队"])
	var p := walk(quest_by_id("guanzhong"), s, [], 1, 0, 1)
	check(p.has("g10_junyi_f") and not p.has("g10_junyi"), "法正 speaks up at the 军议")
	check_eq(p[-1], "g10_duanzhan", "and the player can still overrule him")


func test_south_chapter10_after_ending_fourteen_fazheng_splits_the_army() -> void:
	for fork in [[], ["g10_b_m1", "g10_fb_m1", "g10_d_m1", "g10_e_m1", "g10_f_m1"]]:
		var s := ch10s_save([E14, "法正：入队"])
		var q := quest_by_id("guanzhong")
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["g10_junyi_f", "g10_fenbing", "g10_chencang", "g10_huzhen", "g10_chetui", "g10_guosi", "g10_xurong", "g10_lijue", "g10_lijue_end", "g10_liru",
				"g10_tongguan", "g10_zhangxiu", "g10_kongming", "g10_wangping", "g10_lianying", "g10_zhuge", "g10_zhuiji", "g10_zhuiji2", "g10_end"]:
			check(p.has(sid), "兵分两路 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["g10_zw_start", "g10_zw_exit", "g10_duanzhan"]:
			check(not p.has(sid), "兵分两路 never reaches " + sid)
		check_eq(p[-1], "g10_end")
		for c in ["zhanglu", "yanpu", "xurong_card", "zhangxiu"]:
			check(s.has_card(c), c + " joins on the way")
		check(s.run_records.has("南线：攻取长安") and not s.run_records.has(E14))


# ---- 第十一章 · 洛阳天倾（南线）------------------------------------------------------------

const E4 := "结局十七 · 虎噬"


func ch11s_save(flags := []) -> SaveData:
	var s := ch10s_save([E14, "法正：入队"])
	s.flags += ["关中：兵分两路", "张绣：入队", "南线：攻取长安"] + flags
	s.quests_cleared.append("guanzhong")
	for c in ["zhanglu", "yanpu", "xurong_card", "zhangxiu"]:
		s.grant_card(c)
	return s


func test_south_chapter11_follows_the_good_guanzhong_ending_only() -> void:
	check_eq(Quests.current_quest(ch11s_save())["id"], "luoyang_s")
	var s := ch10s_save([E14])
	s.quests_cleared.append("guanzhong")
	check(Quests.current_quest(s) == null, "结局十五 stops the story: no 第十一章")


func test_south_chapter11_first_time_lu_bu_opens_the_gate_and_you_drive_the_north_back() -> void:
	for fork in [[], ["l11_h_m1", "l11_w_m1", "l11_c_m1", "l11_e_m1", "l11_g_m1", "l11_b_m1"]]:
		var s := ch11s_save()
		var q := quest_by_id("luoyang_s")
		var p := walk(q, s, fork, 1, 0, 0)
		for sid in ["l11_start", "l11_hangu", "l11_huishi", "l11_bazhen", "l11_zhangfei", "l11_guanyu", "l11_caoren", "l11_liubei", "l11_cicao", "l11_yulin",
				"l11_shijun", "l11_yuanmen", "l11_b_gong", "l11_b_rucheng", "l11_b_xunyu", "l11_b_hebing", "l11_b_taishici", "l11_b_zhaoyun", "l11_b_end"]:
			check(p.has(sid), "收下吕布 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["l11_a_luoshui", "l11_a_zhanlv", "l11_a_qianggong", "l11_a_end"]:
			check(not p.has(sid), "收下吕布 never reaches " + sid)
		check_eq(p[-1], "l11_b_end")
		for c in ["lvbu", "xunyu", "xiahoudun", "caoren"]:
			check(s.has_card(c), c + " joins")
		check(s.run_records.has("洛阳：收下吕布") and s.run_records.has("南线：入主洛阳"))


func test_south_chapter11_the_gate_and_the_bridge_are_fights_you_may_lose() -> void:
	var sq: Dictionary = quest_by_id("luoyang_s")["squares"]
	check_eq(sq["l11_zhangfei"]["lose_goto"], "l11_pingshou", "孙策 and 张飞 end even either way")
	check_eq(sq["l11_guanyu"]["lose_goto"], "l11_yingzhan", "the 关羽 fight goes on to 关平 either way")
	var opts: Array = sq["l11_yuanmen"]["choose"]
	check(Quests.option_locked(ch11s_save(), opts[1]), "斩吕布 is shut before 结局十七")


func test_south_chapter11_after_ending_four_you_kill_lu_bu_and_fall_back_to_nanyang() -> void:
	for fork in [[], ["l11_a_m1", "l11_a_s_t"]]:
		var s := ch11s_save([E4])
		var q := quest_by_id("luoyang_s")
		var p := walk(q, s, fork, 1, 0, -1)
		for sid in ["l11_yuanmen", "l11_a_luoshui", "l11_a_zhanlv", "l11_a_weicheng", "l11_a_jianlou", "l11_a_xiang", "l11_a_end"]:
			check(p.has(sid), "斩吕布 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["l11_b_gong", "l11_b_end", "l11_a_qianggong"]:
			check(not p.has(sid), "斩吕布 never reaches " + sid)
		check_eq(p[-1], "l11_a_end")
		for c in ["xunyu", "xiahoudun", "caoren"]:
			check(s.has_card(c), c + " joins at 伊阙")
		check(s.run_records.has("南线：退守南阳") and not s.run_records.has("洛阳：强攻入城"))


func test_south_chapter11_with_both_true_endings_you_storm_the_city() -> void:
	var s := ch11s_save([E4, "南线结局 · 赤壁", "北线结局 · 官渡"])
	var p := walk(quest_by_id("luoyang_s"), s, [], 1, 0, -1)
	check_eq(p[-1], "l11_a_qianggong", "不惜代价，强攻入城 ends the chapter")
	check(s.run_records.has("洛阳：强攻入城"))
	check(not p.has("l11_a_weicheng") and not p.has("l11_a_end"))


# ---- 北线第七章 · 邺城惊雷 ---------------------------------------------------------------

const E15 := "结局十 · 枯井"


func yecheng_save(flags := []) -> SaveData:
	var s := huainan_n_save(["曹操：借粮", "夏侯惇：痛击殿后", "北线：奉诏讨袁", "吕布：降曹", "杜夫人：随军", "北线：浮桥一瞥", "北线：让寿春"] + flags)
	s.quests_cleared.append("huainan_n")
	s.grant_card("dufuren")
	return s


func test_north_chapter7_follows_huainan_n() -> void:
	check_eq(Quests.current_quest(yecheng_save())["id"], "yecheng", "北线：让寿春 → 第七章 · 邺城惊雷")


func test_north_chapter7_without_chen_gong_guo_tu_gets_away_and_zhao_yun_dies_at_the_well() -> void:
	for fork in [[], ["n7_t_m1", "n7_x_m1", "n7_s1_t", "n7_s2_t", "n7_f_m1", "n7_b_l_m1"]]:
		var s := yecheng_save()
		var q := quest_by_id("yecheng")
		var p := walk(q, s, fork)
		for sid in ["n7_start", "n7_zangba", "n7_tiqin", "n7_wedding", "n7_yijing", "n7_shishi", "n7_beishang", "n7_heibing", "n7_fukou", "n7_yuye", "n7_shenrong", "n7_guotu",
				"n7_b_anmin", "n7_b_huijiu", "n7_b_tuwei", "n7_b_yanliang", "n7_b_qijin", "n7_b_wenchou", "n7_b_kujing"]:
			check(p.has(sid), "先稳后打 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n7_bieyuan", "n7_guotu_c", "n7_g_zhui", "n7_g_wenchou", "n7_g_end"]:
			check(not p.has(sid), "先稳后打 never reaches " + sid)
		check_eq(p[-1], "n7_b_kujing")
		check(s.has_card("mizhen") and s.has_card("guonvwang") and s.has_card("zhangyan"), "糜贞, 郭女王, 张燕 join")
		check(not s.has_card("chengong"), "陈宫 stays in his garden")
		check(s.run_relics.has("mijia_chuan"), "the wedding brings 糜家海船")  # a ？ event may trade it away later
		for line in ["赵云：成婚", "北线：义字旗", "邺城：先稳后打"]:
			check(s.run_records.has(line), "第七章 records " + line)
		finish(q, s)
		check(s.flags.has(E15))
		check(Quests.current_quest(s) == null, "the story stops at 结局十")


func test_north_chapter7_the_visit_is_shut_before_ending_fifteen_and_the_well_fight_cannot_be_won() -> void:
	var sq: Dictionary = quest_by_id("yecheng")["squares"]
	check(Quests.option_locked(yecheng_save(), sq["n7_shishi"]["choose"][1]), "去别苑拜访陈宫 is shut before 结局十")
	check(str(sq["n7_guotu_c"]["requires"]).contains("陈宫：入队"), "only 陈宫 sees 沮授 coming")
	check(Quests.option_locked(yecheng_save([E15]), sq["n7_g_dalao"]["choose"][1]), "去大牢请田丰 is shut before 结局十二")
	check_eq(sq["n7_b_wenchou"]["lose_goto"], "n7_b_kujing", "win or lose, the well")
	check_eq(sq["n7_b_wenchou"]["next"], ["n7_b_kujing"])


func test_north_chapter7_after_ending_fifteen_chen_gong_joins_and_zhao_yun_catches_guo_tu() -> void:
	for fork in [[], ["n7_g_l_m1", "n7_g_s2_t"]]:
		var s := yecheng_save([E15])
		var q := quest_by_id("yecheng")
		var p := walk(q, s, fork)
		for sid in ["n7_shishi", "n7_bieyuan", "n7_guotu_c", "n7_g_zhui", "n7_g_qin", "n7_g_jiyi", "n7_g_zhanghe", "n7_g_yanliang", "n7_g_juedi", "n7_g_wenchou", "n7_g_ouxue", "n7_g_dalao", "n7_g_zhaoxian", "n7_g_wuji", "n7_g_end"]:
			check(p.has(sid), "将计就计 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n7_beishang", "n7_guotu", "n7_b_anmin", "n7_b_qijin", "n7_b_kujing"]:
			check(not p.has(sid), "将计就计 never reaches " + sid)
		check_eq(p[-1], "n7_g_end")
		for c in ["mizhen", "chengong", "guonvwang", "zhanghe", "gaolan", "jushou", "tianyu", "baima_yicong"]:
			check(s.has_card(c), c + " joins")
		check(s.run_records.has("邺城：将计就计") and s.run_records.has("北线：夺邺城"))
		check(not s.has_card("tianfeng") and not s.run_records.has("田丰：入队"), "田丰 stays in his cell before 结局十二")
		finish(q, s)


func test_north_chapter7_after_ending_sixteen_tian_feng_comes_out_of_the_cell() -> void:
	var s := yecheng_save([E15, "结局十二 · 遗策"])
	var q := quest_by_id("yecheng")
	var p := walk(q, s, ["n7_g_s2_t"])
	for sid in ["n7_g_dalao", "n7_g_zhaoxian_t", "n7_g_wuji", "n7_g_end"]:
		check(p.has(sid), "请田丰 passes " + sid)
	check(not p.has("n7_g_zhaoxian"), "the plain 招贤馆 is the other version")
	check(s.has_card("tianfeng") and s.run_records.has("田丰：入队"), "田丰 joins")


# ---- 北线第八章 · 北海龙虎 ---------------------------------------------------------------

const E16 := "结局十二 · 遗策"


func longhu_save(flags := []) -> SaveData:
	var s := yecheng_save([E15, "赵云：成婚", "陈宫：入队", "北线：义字旗", "邺城：将计就计", "北线：夺邺城"] + flags)
	s.quests_cleared.append("yecheng")
	for c in ["mizhen", "chengong", "guonvwang", "zhanghe", "gaolan", "jushou", "tianyu"]:
		s.grant_card(c)
	return s


func test_north_chapter8_follows_yecheng() -> void:
	check_eq(Quests.current_quest(longhu_save())["id"], "longhu", "北线：夺邺城 → 第八章 · 北海龙虎")


func test_north_chapter8_without_tian_feng_guo_jia_stays_north_and_the_lord_falls_at_beihai() -> void:
	for fork in [[], ["n8_q_m1", "n8_y_m1", "n8_b_l_m1"]]:
		var s := longhu_save()
		var q := quest_by_id("longhu")
		var p := walk(q, s, fork)
		for sid in ["n8_start", "n8_yishi", "n8_weiping", "n8_yuantan", "n8_dumai", "n8_wuhuan", "n8_shenpei", "n8_chusai", "n8_dingbei",
				"n8_liushou", "n8_b_nan", "n8_b_xin", "n8_b_chengyu", "n8_b_end"]:
			check(p.has(sid), "郭嘉留守 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n8_yishi_t", "n8_liushou_t", "n8_g_nan", "n8_g_jincheng", "n8_g_end"]:
			check(not p.has(sid), "郭嘉留守 never reaches " + sid)
		check_eq(p[-1], "n8_b_end")
		check(s.run_records.has("北线：郭嘉留守"))
		finish(q, s)
		check(s.flags.has(E16))
		check(Quests.current_quest(s) == null, "the story stops at 结局十二")


func test_north_chapter8_the_ambush_cannot_be_won_without_the_letter() -> void:
	var sq: Dictionary = quest_by_id("longhu")["squares"]
	check_eq(sq["n8_b_chengyu"]["lose_goto"], "n8_b_end", "win or lose, the stray arrow")
	check_eq(sq["n8_b_chengyu"]["next"], ["n8_b_end"])
	check_eq(str(sq["n8_liushou_t"]["requires"]), "田丰：入队", "only 田丰 stays north in 郭嘉's place")


func test_north_chapter8_with_tian_feng_guo_jia_lives_and_beihai_holds() -> void:
	for fork in [[], ["n8_q_m1", "n8_y_m1", "n8_g_l_m1", "n8_g_c_m1", "n8_g_h_m1"]]:
		var s := longhu_save([E16, "田丰：入队"])
		var q := quest_by_id("longhu")
		var p := walk(q, s, fork)
		for sid in ["n8_yishi_t", "n8_liushou_t", "n8_g_nan", "n8_g_shipo", "n8_g_xiahoudun", "n8_g_jincheng", "n8_g_lvbu", "n8_g_zhanlv",
				"n8_g_zangba", "n8_g_tuijun", "n8_g_ma", "n8_g_mayunlu", "n8_g_machao", "n8_g_end", "n8_g_chendeng", "n8_g_fanjian"]:
			check(p.has(sid), "田丰在 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n8_yishi", "n8_liushou", "n8_b_nan", "n8_b_end"]:
			check(not p.has(sid), "田丰在 never reaches " + sid)
		check_eq(p[-1], "n8_g_fanjian", "before 结局十四 陈登's plan goes ahead")
		check(s.has_card("mizhu") and s.has_card("chendeng"), "糜竺, 陈登 join at 北海")
		for line in ["北线：郭嘉随军", "北线：郭嘉不死", "北线：北海守住", "北线：西凉默契", "北线：反间马腾"]:
			check(s.run_records.has(line), "第八章 records " + line)
		finish(q, s)


func test_north_chapter8_refusing_chen_dengs_plan_needs_ending_seventeen() -> void:
	var sq: Dictionary = quest_by_id("longhu")["squares"]
	check(Quests.option_locked(longhu_save([E16, "田丰：入队"]), sq["n8_g_chendeng"]["choose"][1]), "「不行，这会害了马家」 is shut before 结局十四")
	var s := longhu_save([E16, "田丰：入队", "结局十四 · 断弦"])
	var p := walk(quest_by_id("longhu"), s, [])
	check_eq(p[-1], "n8_g_bujian")
	check(s.run_records.has("北线：不害马家"))


# ---- 北线第九章 · 西凉喋血 ---------------------------------------------------------------

const E17 := "结局十四 · 断弦"


func xiliang_save(flags := []) -> SaveData:
	var s := longhu_save([E16, "田丰：入队", "北线：郭嘉随军", "北线：郭嘉不死", "北线：北海守住", "北线：西凉默契"] + flags)
	s.quests_cleared.append("longhu")
	for c in ["tianfeng", "mizhu", "chendeng"]:
		s.grant_card(c)
	return s


func test_north_chapter9_follows_longhu() -> void:
	check_eq(Quests.current_quest(xiliang_save(["北线：反间马腾"]))["id"], "xiliang", "北线：西凉默契 → 第九章 · 西凉喋血")


func test_north_chapter9_the_letters_get_ma_yunlu_and_the_lord_killed_at_the_ford() -> void:
	for fork in [[], ["n9_z_m1", "n9_n_m1", "n9_b_l_m1"]]:
		var s := xiliang_save(["北线：反间马腾"])
		var q := quest_by_id("xiliang")
		var p := walk(q, s, fork)
		for sid in ["n9_start", "n9_wuji", "n9_lunu", "n9_nanpi", "n9_haikou", "n9_yanjin_f", "n9_b_xunyu", "n9_b_lvbu", "n9_b_jiuren", "n9_b_xiahoudun", "n9_b_end"]:
			check(p.has(sid), "反间 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n9_yanjin_p", "n9_g_shi", "n9_g_end"]:
			check(not p.has(sid), "反间 never reaches " + sid)
		check(not s.has_card("pangde"), "庞德 never comes")
		finish(q, s)
		check(s.flags.has(E17))
		check(Quests.current_quest(s) == null, "the story stops at 结局十四")
	var sq: Dictionary = quest_by_id("xiliang")["squares"]
	check_eq(sq["n9_b_xiahoudun"]["lose_goto"], "n9_b_end", "win or lose, the broken string")


func test_north_chapter9_pang_de_brings_the_ma_family_across() -> void:
	for fork in [[], ["n9_z_m1", "n9_n_m1", "n9_g_l_m1", "n9_g_s_m1", "n9_g_d_m1"]]:
		var s := xiliang_save([E17, "北线：不害马家"])
		var q := quest_by_id("xiliang")
		var p := walk(q, s, fork)
		for sid in ["n9_yanjin_p", "n9_g_ludi", "n9_g_xiahoudun", "n9_g_xuezhan", "n9_g_lvbu", "n9_g_shi", "n9_g_yizheng", "n9_g_lulong", "n9_g_liucheng", "n9_g_tadun", "n9_g_zhanta", "n9_g_liaoshui", "n9_g_gaogouli", "n9_g_xiangping", "n9_g_end"]:
			check(p.has(sid), "不害马家 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n9_yanjin_f", "n9_b_xunyu", "n9_b_end"]:
			check(not p.has(sid), "不害马家 never reaches " + sid)
		for c in ["machao", "mayunlu", "madai", "pangde"]:
			check(s.has_card(c), c + " joins")
		check(s.run_records.has("北线：西凉归附") and s.run_records.has("北线：北方一统"))
		finish(q, s)


# ---- 北线第十章 · 再战虎牢 --------------------------------------------------------------

const E16_N := "结局十六 · 洛殇"


func sanfang_save(flags := []) -> SaveData:
	var s := xiliang_save([E17, "北线：不害马家", "北线：西凉归附", "北线：北方一统"] + flags)
	s.quests_cleared.append("xiliang")
	for c in ["machao", "mayunlu", "madai", "pangde"]:
		s.grant_card(c)
	return s


func test_north_chapter10_follows_xiliang() -> void:
	check_eq(Quests.current_quest(sanfang_save())["id"], "sanfang", "北线：北方一统 → 第十章 · 再战虎牢")


func test_north_chapter10_without_pang_tong_zhen_mi_falls_on_the_luo_river() -> void:
	for fork in [[], ["n10_a_m1", "n10_b_m1", "n10_c_m1", "n10_d_m1", "n10_bw_t1"]]:
		var s := sanfang_save()
		var q := quest_by_id("sanfang")
		var p := walk(q, s, fork)
		for sid in ["n10_start", "n10_xiahoudun", "n10_qiandu", "n10_xuchu", "n10_yujin", "n10_xudu", "n10_pangtong", "n10_pt_houqin",
				"n10_xiuzheng", "n10_caoren", "n10_hulao", "n10_shouzu", "n10_b_plan", "n10_b_luoshui", "n10_b_ambush", "n10_b_end"]:
			check(p.has(sid), "庞统管后勤 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n10_pt_take", "n10_g_plan", "n10_g_dukou", "n10_g_lvbu", "n10_g_end"]:
			check(not p.has(sid), "庞统管后勤 never reaches " + sid)
		check(s.has_card("yujin") and s.has_card("zhenmi"), "于禁, 甄宓 join")
		check(not s.has_card("pangtong"), "庞统 is sent to logistics")
		check(s.run_records.has("庞统：管后勤"))
		finish(q, s)
		check(s.flags.has(E16_N))
		check(Quests.current_quest(s) == null, "the story stops at 结局十六 · 洛殇")
	var sq: Dictionary = quest_by_id("sanfang")["squares"]
	check(Quests.option_locked(sanfang_save(), sq["n10_pangtong"]["choose"][1]), "留任军师，向他问计 is shut before 结局十六")
	check_eq(sq["n10_hulao"]["lose_goto"], "n10_shouzu", "win or lose at 虎牢关, the army stalls")
	check_eq(sq["n10_b_luoshui"]["lose_goto"], "n10_b_ambush", "win or lose on the Luo River, 洛殇")


func test_north_chapter10_with_pang_tong_the_fire_ships_take_hulao_pass() -> void:
	for fork in [[], ["n10_a_m1", "n10_b_m1", "n10_c_m1", "n10_d_m1", "n10_g_e_t1", "n10_g_f_m1"]]:
		var s := sanfang_save([E16_N])
		var q := quest_by_id("sanfang")
		var p := walk(q, s, fork)
		for sid in ["n10_start", "n10_xiahoudun", "n10_qiandu", "n10_xuchu", "n10_yujin", "n10_xudu", "n10_pangtong", "n10_pt_take",
				"n10_xiuzheng", "n10_caoren", "n10_hulao", "n10_shouzu", "n10_g_plan", "n10_g_dukou", "n10_g_shangchuan", "n10_g_lvbu", "n10_g_end"]:
			check(p.has(sid), "庞统入队 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n10_pt_houqin", "n10_b_plan", "n10_b_luoshui", "n10_b_ambush", "n10_b_end"]:
			check(not p.has(sid), "庞统入队 never reaches " + sid)
		for c in ["yujin", "pangtong", "zhenmi"]:
			check(s.has_card(c), c + " joins")
		check(s.run_records.has("庞统：入队") and s.run_records.has("北线：破虎牢"))
		finish(q, s)


# ---- 北线第十一章 · 洛阳天倾 ---------------------------------------------------------------

const E18_N := "结局十八 · 烛灭"


func tianqing_save(flags := []) -> SaveData:
	var s := sanfang_save([E16_N, "北线：破虎牢"] + flags)
	s.quests_cleared.append("sanfang")
	for c in ["yujin", "pangtong", "zhenmi"]:
		s.grant_card(c)
	return s


func test_north_chapter10_with_pang_tong_leads_on_to_luoyang() -> void:
	var s := sanfang_save([E16_N])
	var q := quest_by_id("sanfang")
	walk(q, s, [])
	finish(q, s)
	check_eq(Quests.current_quest(s)["id"], "tianqing", "北线：破虎牢 → 第十一章 · 洛阳天倾")


func test_north_chapter11_handing_over_the_seal_marches_south_with_zhuge_liang() -> void:
	for fork in [[], ["n11_a_m1", "n11_b_m1", "n11_c_m1", "n11_ad_m1", "n11_ae_m1"]]:
		var s := tianqing_save()
		var q := quest_by_id("tianqing")
		var p := walk(q, s, fork)
		for sid in ["n11_start", "n11_caoren", "n11_beidu", "n11_huishi", "n11_dianwei_du", "n11_gehe", "n11_qiye", "n11_kongming", "n11_choose", "n11_a_bai",
				"n11_dianwei", "n11_zhanli", "n11_a_xiaoxi", "n11_a_shoulian", "n11_a_jianlou", "n11_a_sunce", "n11_a_huangzhong", "n11_a_tang", "n11_a_end"]:
			check(p.has(sid), "交印 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n11_g_kou", "n11_gd_a1", "n11_g_lvbu", "n11_g_tuishou", "n11_g_guanzhang", "n11_g_end"]:
			check(not p.has(sid), "交印 never reaches " + sid)
		check(s.run_records.has("诸葛亮：拜军师") and s.run_records.has("北线：随诸葛南征"))
		check(not s.has_card("guanyu"), "关羽 does not join when 诸葛亮 holds the seal")
		finish(q, s)
		check(not s.flags.has(E18_N), "结局十八 · 烛灭 now comes in the final chapter")
	var sq: Dictionary = quest_by_id("tianqing")["squares"]
	check(Quests.option_locked(tianqing_save(), sq["n11_choose"]["choose"][1]), "先别交 is shut before 结局十八")
	check_eq(sq["n11_dianwei_du"]["lose_goto"], "n11_gehe", "win or lose, 典韦 holds the ferry the first time")
	check_eq(sq["n11_dianwei"]["lose_goto"], "n11_zhanli", "win or lose, 典韦 dies standing")


func test_north_chapter11_keeping_zhuge_liang_falls_back_to_xuchang() -> void:
	for fork in [[], ["n11_a_m1", "n11_b_m1", "n11_c_m1", "n11_gd_m1", "n11_ge_m1"]]:
		var s := tianqing_save([E18_N])
		var q := quest_by_id("tianqing")
		var p := walk(q, s, fork)
		for sid in ["n11_kongming", "n11_choose", "n11_g_kou", "n11_dianwei", "n11_zhanli", "n11_g_xiaoxi", "n11_g_lvbu", "n11_g_sunce", "n11_g_huangzhong",
				"n11_g_tuishou", "n11_g_guanzhang", "n11_g_end"]:
			check(p.has(sid), "扣下诸葛 passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["n11_a_bai", "n11_a_xiaoxi", "n11_a_shoulian", "n11_a_tang", "n11_a_end"]:
			check(not p.has(sid), "扣下诸葛 never reaches " + sid)
		check(s.run_records.has("北线：扣下诸葛") and s.run_records.has("北线：识破诸葛"))
		check(s.has_card("guanyu") and s.has_card("zhangfei"), "关羽、张飞 come over at 许昌")
		finish(q, s)


# ---- 终章 ---------------------------------------------------------------------------------------------

func finale(qid: String, s: SaveData, ending: String) -> Array:
	check_eq(Quests.current_quest(s)["id"], qid, "the story goes on to " + qid)
	var q := quest_by_id(qid)
	var p := walk(q, s, [])
	finish(q, s)
	check(s.flags.has(ending), qid + " ends at " + ending)
	check(Quests.current_quest(s) == null, "nothing after " + ending)
	return p


func test_finale_world_one_south_takes_lu_bu_and_dies_by_him() -> void:
	var s := ch11s_save()
	var q := quest_by_id("luoyang_s")
	walk(q, s, [], 1, 0, 0)
	finish(q, s)
	var p := finale("beifa", s, "结局十七 · 虎噬")
	for sid in ["s12w_yujin", "s12w_gaoshun", "s12w_zhaoyun", "s12w_meng", "s12w_hushi"]:
		check(p.has(sid), "北伐 passes " + sid)


func test_finale_world_two_south_falls_back_to_the_yangtze_and_burns_chibi() -> void:
	var s := ch11s_save(["结局十七 · 虎噬"])
	var q := quest_by_id("luoyang_s")
	walk(q, s, [], 1, 0, -1)
	finish(q, s)
	var p := finale("chibi", s, "南线结局 · 赤壁")
	for sid in ["s12c_machao", "s12c_sang", "s12c_pangtong", "s12c_kurou", "s12c_dongfeng", "s12c_lian", "s12c_kongming", "s12c_guan", "s12c_end"]:
		check(p.has(sid), "赤壁 passes " + sid)


func test_finale_world_one_north_holds_guandu_against_a_mad_lu_bu() -> void:
	var s := tianqing_save([E18_N])
	var q := quest_by_id("tianqing")
	walk(q, s, [])
	finish(q, s)
	var p := finale("guandu", s, "北线结局 · 官渡")
	for sid in ["n12g_xiahoudun", "n12g_caoren", "n12g_sunce", "n12g_huo", "n12g_lvbu", "n12g_jiaozhang", "n12g_end"]:
		check(p.has(sid), "官渡 passes " + sid)


func test_finale_world_two_north_crosses_with_zhuge_liang_and_the_candle_goes_out() -> void:
	var s := tianqing_save()
	var q := quest_by_id("tianqing")
	walk(q, s, [])
	finish(q, s)
	var p := finale("dujiang", s, E18_N)
	for sid in ["n12d_huangzhong", "n12d_guojia", "n12d_zhouyu", "n12d_qianye", "n12d_end"]:
		check(p.has(sid), "渡江 passes " + sid)


func test_finale_both_endings_open_the_way_into_the_city_from_either_side() -> void:
	var both := ["南线结局 · 赤壁", "北线结局 · 官渡"]
	var n := tianqing_save([E18_N] + both)
	var qn := quest_by_id("tianqing")
	var pn := walk(qn, n, ["n11_g_jin"])
	check_eq(pn[-1], "n11_g_jin", "北线：不退，进城 ends the chapter")
	finish(qn, n)
	finale("guiyi", n, "真结局 · 归一")
	var s := ch11s_save(["结局十七 · 虎噬"] + both)
	var qs := quest_by_id("luoyang_s")
	walk(qs, s, [], 1, 0, -1)
	finish(qs, s)
	var p := finale("guiyi", s, "真结局 · 归一")
	for sid in ["tm_zhangfei", "tm_xiangjian", "tm_guanyu", "tm_digong", "tm_jinggao", "tm_guiyi", "tm_end"]:
		check(p.has(sid), "归一 passes " + sid)
	check(not quest_by_id("tianqing")["squares"]["n11_g_jin"].is_empty())
	check(Quests.current_quest(tianqing_save([E18_N])) != null)


func test_endings_outside_the_numbered_ones_survive_a_new_lap() -> void:
	var s := SaveData.create()
	s.flags = ["南线结局 · 赤壁", "北线结局 · 官渡", "真结局 · 归一", "结局十七 · 虎噬", "南线：入主洛阳"]
	var t := s.new_lap()
	for f in ["南线结局 · 赤壁", "北线结局 · 官渡", "真结局 · 归一", "结局十七 · 虎噬"]:
		check(t.flags.has(f), f + " is remembered on the next lap")
	check(not t.flags.has("南线：入主洛阳"), "a route record is not")
