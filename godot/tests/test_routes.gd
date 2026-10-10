extends TestCase
## Chapters 3 to 5 walked end to end on every 周目 route: which squares come up, what gets recorded,
## which chapter follows, which ending (if any) the run reaches.

const E1 := "结局一 · 玉碎"
const E2 := "结局二 · 同归"
const E3 := "结局三 · 恨海"
const JX := "贾诩：入队"


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
			Quests.choose_event(q, s, r, ok[0])
		Quests.offer(q, s, r)
		Quests.resolve(q, s, r, choose_idx if sq["type"] == "choose" else (pick_offer if not s.offer.is_empty() else -1))
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
	var p3 := walk(yuxi, s, [])
	check(p3.has("wenji_seen") and p3.has("wenji_fight"), "二周目: 董白 spots 蔡文姬")
	check_eq(p3[-1], "wenji_join", "saving her ends chapter 3 early")
	check(s.has_card("caiwenji"), "蔡文姬 joins")
	check(not s.run_records.has(E1), "no 玉碎 on this road")
	finish(yuxi, s)
	check(s.flags.has("路线：守洛阳"))

	var luo := quest_by_id("shouluoyang")
	check_eq(Quests.current_quest(s)["id"], "shouluoyang")
	var p4 := walk(luo, s, [])
	for sid in ["wenji_tale", "plan", "guosi4", "grain", "settle", "zhujun", "xizi", "peace", "betroth", "mangshan", "farewell"]:
		check(p4.has(sid), "驻守洛阳 passes " + sid)
	check(s.has_card("zhujun"), "朱儁 joins")
	finish(luo, s)

	var ca := quest_by_id("changan")
	check_eq(Quests.current_quest(s)["id"], "changan")
	var p5 := walk(ca, s, [])
	for sid in ["enter", "feast", "bw3", "passed", "chaojian", "caiyong", "wangyun", "diaochan", "xuhun", "yuexia", "xian",
			"fengyi", "chuxi", "eve", "xueye", "wedding", "hall", "huzhen", "dongzhuo5", "kill_all", "death"]:
		check(p5.has(sid), "长安 passes " + sid)
	check(s.has_card("huangfusong"), "皇甫嵩 joins at 格杀勿论")
	finish(ca, s)
	check(s.flags.has("长安：吕布杀了董卓"))

	var d := quest_by_id("dongui")
	check_eq(Quests.current_quest(s)["id"], "dongui", "then 第四章")
	var p6 := walk(d, s, [])
	for sid in ["yizu", "qingsun", "fenghou", "xunyou", "zhongyao", "chaohui", "gaoshun4", "tuwei", "langqi4", "pozi",
			"dongjia", "lvbu4", "tonggui"]:
		check(p6.has(sid), "二周目 passes " + sid)
	for sid in ["mimou", "luan", "gong", "huihe", "dongtao"]:
		check(not p6.has(sid), "二周目 never reaches " + sid)
	check(s.has_card("xunyou") and s.has_card("zhongyao"), "荀攸 and 钟繇 both join")
	check(s.run_records.has(E2), "the run reaches 结局二")
	finish(d, s)
	check(s.flags.has(E2))
	check(Quests.current_quest(s) == null, "the story stops at 结局二")
	s.new_lap()
	check(s.flags.has(E1) and s.flags.has(E2), "both endings survive into the next 周目")


func test_lap2_losing_to_lvbu_still_reaches_ending_two() -> void:
	var s := lap_save(["董白：留下", E1, "长安：吕布杀了董卓"], ["prologue", "taodong", "yuxi", "shouluoyang", "changan"])
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
				["prologue", "taodong", "yuxi", "shouluoyang", "changan"])
		var d := quest_by_id("dongui")
		check_eq(Quests.current_quest(s)["id"], "dongui")
		var p := walk(d, s, fork)
		for sid in ["yizu", "fenghou", "xunyou", "zhongyao", "mimou", "luan", "gong", "shaoka", fork[0], "xuhuang", "lijue6",
				"huihe", "luoyang_rest", "fall", "seal", "paichi", "chuzheng", "qiao7", "huangzhong", "leibo7", "xingye", "chenlan7", "feng7",
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
	for id in ["yuxi", "shouluoyang", "changan", "beihai", "xuzhou", "dongui", "jingxiang", "huainan_s"]:
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
			for sid in seen:  # no square leads only into hidden squares
				var nexts: Array = sq[sid]["next"].filter(func(n): return Quests.is_open(sq[n], s))
				check(not (nexts.is_empty() and not sq[sid]["next"].is_empty()), "%s %s: stuck at %s" % [id, s.flags, sid])
		for sid in sq:
			check(covered.has(sid), "%s: square %s is never reachable" % [id, sid])


# ---- real fights: the 三周目 chapter 4 plays through without script errors ---------------------

func test_lap3_chapter4_plays_with_real_fights() -> void:
	var s := lap_save(["董白：留下", E1, E2, "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"],
			["prologue", "taodong", "yuxi", "shouluoyang", "changan"])
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
			Quests.choose_event(q, s, r, ok[0])
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
	for f in ["story.json", "cards.json", "interludes.json", "ui.json"]:
		var text := FileAccess.get_file_as_string("res://data/" + f)
		for i in text.length():
			var c := text.unicode_at(i)
			if c >= 0x3400 and not font.has_char(c):
				missing[String.chr(c)] = f
	check(missing.is_empty(), "not in the font (run tools/build_fonts.py): %s" % str(missing))


# ---- 第五章 · 荆襄风云: first time the banquet kills 貂蝉 (结局三); after it, 贾诩 (met in 长安, recruited in 第四章) breaks it ----

func ch5_save(flags: Array) -> SaveData:
	var s := lap_save(["董白：留下", E1, E2, "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓", "南阳：袁术东逃"] + flags,
			["prologue", "taodong", "yuxi", "shouluoyang", "changan", "dongui"])
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
		check(s.run_records.has(E3), "the run reaches 结局三")
		check(not s.has_card("kuaiyue"), "蒯越 never joins")
		finish(q, s)
		check(s.flags.has(E3))
		check(Quests.current_quest(s) == null, "the story stops at 结局三")


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
	var s := ch5_save([E3])  # 结局三 reached, but 贾诩 was passed by in 第四章
	var p := walk(quest_by_id("jingxiang"), s, [])
	check(p.has("jx_qinggong") and p.has("jx_a_fuyan") and not p.has("jx_meng") and not p.has("jx_b_dingce"), "no 贾诩, no way out")
	check_eq(p[-1], "jx_a_henhai")


# ---- 南线第六章 · 淮南折帝旗 ---------------------------------------------------------------

func ch6s_save() -> SaveData:
	var s := ch5_save([E3, JX, "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督", "貂蝉：全员生还"])
	s.quests_cleared.append("jingxiang")
	for c in ["jiaxu", "kuaiyue", "ganning"]:
		s.grant_card(c)
	return s


func test_south_chapter6_follows_the_good_jingxiang_ending_only() -> void:
	check_eq(Quests.current_quest(ch6s_save())["id"], "huainan_s")
	var bad := ch5_save([E3])
	bad.quests_cleared.append("jingxiang")
	check(Quests.current_quest(bad) == null, "恨海 stops the story: no 第六章")


func test_south_chapter6_walks_from_xiangyang_to_the_double_wedding() -> void:
	for fork in [[], ["hn_m1", "hn_m2", "hn_m3", "hn_m4"]]:
		var s := ch6s_save()
		var q := quest_by_id("huainan_s")
		var p := walk(q, s, fork)
		for sid in ["hn_years", "hn_letter", "hn_shu", "hn_zhoujia", "hn_luxun", "hn_lusu", "hn_liuxun", "hn_wan_rest",
				"hn_chenwu", "hn_qiao", "hn_huafang", "hn_zhengbao", "hn_leichen", "hn_zhangxun", "hn_shouchun", "hn_feng",
				"hn_bridge", "hn_feng2", "hn_wedding", "hn_end"]:
			check(p.has(sid), "第六章 passes %s (forks %s)" % [sid, str(fork)])
		check_eq(p[-1], "hn_end")
		for c in ["lusu", "chenwu", "daqiao"]:
			check(s.has_card(c), "%s joins in 第六章" % c)
		for r in ["wentai_shu", "zhou_pu", "weixi"]:
			check(s.relics.has(r), "第六章 hands over the 宝物 " + r)
		for line in ["南线：家书讨袁", "周家：解围", "鲁肃：指囷相赠", "陈武：入队", "二乔：解救", "冯夫人：交给吴夫人",
				"南线：浮桥一瞥", "庐江：双婚"]:
			check(s.run_records.has(line), "第六章 records " + line)
		finish(q, s)
		check(Quests.current_quest(s) == null, "未完待续 after 第六章")


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
	check_eq(s.square, "hn_end", "reached the end of 第六章")
	check(fights >= 8, "fought the chapter's battles (%d)" % fights)


func test_lap4_chapter4_beats_zhang_ji_and_zhang_xiu_and_jiaxu_joins() -> void:
	for flags in [[E3], []]:
		for fork in [["m2"], ["rest"]]:
			var s := lap_save(["董白：留下", E1, E2, "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"] + flags,
					["prologue", "taodong", "yuxi", "shouluoyang", "changan"])
			var p := walk(quest_by_id("dongui"), s, fork)
			for sid in ["zhangxiu6", "zhangji6", "jiaxu6"]:
				check_eq(p.has(sid), not flags.is_empty(), "%s only on 四周目 %s %s" % [sid, str(flags), fork[0]])
			if not flags.is_empty():
				check(not p.has("zhuibing") and not p.has("fanchou6"), "四周目 meets 张家 instead of the old pursuers")
			check_eq(s.has_card("jiaxu"), not flags.is_empty())
			check_eq(s.run_records.has(JX), not flags.is_empty())
			check(p.has(fork[0]) and p.has("shaoka") and p.has("xuhuang") and p[-1] == "dongtao", "reaches 南阳 via " + fork[0])


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
	check(s.run_records.has("结局八 · 失律"), "the run reaches 结局八")
	finish(q, s)
	check(s.flags.has("结局八 · 失律"))
	check(Quests.current_quest(s) == null, "the story stops at 结局八")


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
				"xz_beat", "xz_fu", "xz_langqi", "xz_xianzhen", "xz_lvbu", "xz_will", "xz_bingzhou", "xz_chengong", "xz_wedding", "xz_end"]:
			check(p.has(sid), "铁纪 route passes %s (forks %s)" % [sid, str(fork)])
		for sid in ["xz_muster", "xz_chaos", "xz_banquet", "xz_menhou"]:
			check(not p.has(sid), "铁纪 route never reaches " + sid)
		check_eq(p[-1], "xz_end")
		for c in ["zhangliao", "gaoshun"]:
			check(s.has_card(c), "%s joins in 第五章" % c)
		for r in ["xuzhou_yin", "mijia_chuan", "chen_mago"]:
			check(s.relics.has(r), "第五章 hands over the 宝物 " + r)
		for line in ["刘备：秒接徐州印", "陈家：倒向主角", "刘备：投曹", "徐州：接任徐州牧", "张辽高顺：入队", "陈宫：供起来了", "赵云：成婚"]:
			check(s.run_records.has(line), "第五章 records " + line)
		check(not s.run_records.has("结局八 · 失律"))
		finish(q, s)
		check_eq(Quests.current_quest(s)["id"], "huainan_n", "赵云：成婚 → 第六章 · 淮南折帝旗")


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


func test_beihai_peace_route_wins_through_to_beihai() -> void:
	var s := beihai_save()
	var q := quest_by_id("beihai")
	var path := walk(q, s, [], 1, 0, 0)
	for sid in ["bh_zheng", "bh_jiang", "bh_zj_peace", "bh_zj_join", "bh_lubu", "bh_flee", "bh_guanhai", "bh_porridge", "bh_end"]:
		check(path.has(sid), "passes " + sid)
	check(not path.has("bh_escape") and not path.has("bh_bad_end"), "winning against 吕布 skips the retreat scenes")
	for c in ["zhenghao", "jiangqiao", "taishici", "beihai_tuntian"]:
		check(s.has_card(c), "got " + c)
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


func test_beihai_losing_to_lvbu_after_a_feud_is_ending_seven() -> void:
	var s := beihai_save()
	var q := quest_by_id("beihai")
	var path := walk(q, s, [], 1, 0, 1)
	check(path.has("bh_zj_fight") and path.has("bh_flee"), "feud route still wins through if you beat 吕布")
	Quests.begin(q, s)
	s.square = "bh_lubu"
	s.resolved = false
	Quests.lose(q, s)
	Quests.resolve(q, s, rng(1), -1)
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["bh_bad_end"])
	Quests.move(q, s, "bh_bad_end")
	Quests.resolve(q, s, rng(1), -1)
	check(not s.run_records.has("结局七 · 绝罚"), "the feud scene comes first")
	check_eq(Quests.next_options(q, s).map(func(x): return x["id"]), ["bh_bad_lingqi"])
	Quests.move(q, s, "bh_bad_lingqi")
	Quests.resolve(q, s, rng(1), -1)
	check(s.run_records.has("结局七 · 绝罚"), "ending seven recorded")
	check_eq(q["ending"]["title"], "结局七 · 绝罚")
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
	check(s.run_records.has("结局六 · 覆巢"), "the run reaches 结局六")
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
	var s := lap_save(["出生：冀州无极", "北线：班师冀州", "结局六 · 覆巢"], ["prologue", "luoyang_n"])  # 覆巢 seen once: the rescue option is open
	var q := quest_by_id("heishan")
	var r := rng(1)
	Quests.begin(q, s, r)
	var path: Array = [s.square]
	for _step in 200:
		var sq := Quests.here(q, s)
		if sq["type"] == "mystery" and not s.resolved:
			var ev := Quests.event_here(q, s, r)
			var ok: Array = range(ev["options"].size()).filter(func(i): return Quests.option_blocked(s, ev["options"][i]) == "")
			Quests.choose_event(q, s, r, ok[0])
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
	for sid in ["hs_timeskip", "hs_breakout", "hs_guotu_fight", "hs_em1"]:
		check(path.has(sid), "the rescue line passes " + sid)


func test_north_chapter5_sparing_xiahoudun_waits_for_ending_nine() -> void:
	## 下邳城外「放他回兖州」is greyed until 「结局九 · 断桥」; 咬住尾巴 is always open and is the default
	var q := quest_by_id("xuzhou")
	var opts: Array = q["squares"]["xz_xiapi"]["choose"]
	var s := xuzhou_save(["军纪：严明"])
	check(Quests.option_locked(s, opts[0]), "放他回兖州 greyed on a first run")
	check(not Quests.option_locked(s, opts[1]), "咬住尾巴 open")
	var p := walk(q, s, [])
	check(p.has("xz_bite") and p.has("xz_xiahoudun") and p.has("xz_rest1"), "the default bites the rear guard")
	check(s.run_records.has("夏侯惇：痛击殿后"))
	var s2 := xuzhou_save(["军纪：严明", "结局九 · 断桥"])
	check(not Quests.option_locked(s2, opts[0]), "断桥 opens 放他回兖州")
	var p2 := walk(q, s2, [], 1, 0, 0)
	for sid in ["xz_spare", "xz_xiahoudun_f", "xz_rest1_f", "xz_end"]:
		check(p2.has(sid), "the spare route passes " + sid)
	check(not p2.has("xz_xiahoudun") and not p2.has("xz_bite"))
	check(s2.run_records.has("夏侯惇：放他回兖州"))


# ---- 北线第六章 · 淮南折帝旗 ---------------------------------------------------------------

func huainan_n_save(flags: Array) -> SaveData:
	var s := xuzhou_save(["军纪：严明", "赵云：成婚"] + flags)
	s.quests_cleared.append("xuzhou")
	for c in ["zhangliao", "gaoshun", "xiahoulan"]:
		s.grant_card(c)
	return s


func test_north_chapter6_follows_xuzhou() -> void:
	check_eq(Quests.current_quest(huainan_n_save(["曹操：借粮", "夏侯惇：痛击殿后"]))["id"], "huainan_n", "赵云：成婚 → 第六章 · 淮南折帝旗")


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
			check(not s.run_records.has("结局九 · 断桥"))
			finish(q, s)
			check(Quests.current_quest(s) == null, "未完待续 after 淮南折帝旗")


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
	check(s.flags.has("结局九 · 断桥"))
	check(Quests.current_quest(s) == null, "the story stops at 结局九")


func test_north_chapter6_lost_fights_carry_the_story_on() -> void:
	for pair in [["hnn_bw3", "hnn_choose", ["曹操：借粮", "夏侯惇：放他回兖州"]], ["hnn_gongmen", "hnn_fire", ["曹操：没借", "夏侯惇：痛击殿后"]],
			["hnn_duanqiao", "hnn_caught", ["曹操：没借", "夏侯惇：痛击殿后"]]]:
		var s := huainan_n_save(pair[2])
		var q := quest_by_id("huainan_n")
		Quests.begin(q, s, rng(3))
		s.square = pair[0]
		check(Quests.lose(q, s, rng(3)), "losing %s is not a restart" % pair[0])
		check_eq(s.square, pair[1])
