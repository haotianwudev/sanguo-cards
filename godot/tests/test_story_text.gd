extends TestCase
## Rules for story text (see the sanguo-dev skill, "Story text rules"): narration and speech never share a line,
## and in the north route the hero's followers call him 大哥, not 主公.

const SPEECH_MARKS := "，。！？…—~、；"
const NORTH_FOLLOWERS := ["zhaoyun", "guojia", "zhangliao", "pangde", "taishici", "machao", "zhangning", "lvlingqi", "guonvwang"]
const ADDRESS_EXCEPTIONS := ["yecheng/n7_g_s2_a"]  # 赵云: 「你们的主公已经走了」 = the enemy's lord


func _texts() -> Array:
	## [[where, line], ...] for every square's and every random event's text
	var out: Array = []
	var db := GameData.get_db()
	for q in db.quests:
		for sid in q["squares"]:
			for l in q["squares"][sid].get("text", []):
				out.append(["%s/%s" % [q["id"], sid], str(l), q.get("event_scope", "")])
	for eid in db.events:
		for l in db.events[eid].get("text", []):
			out.append(["event/%s" % eid, str(l), ""])
	return out


static func _strip_tag(line: String) -> String:
	if line.begins_with("@") and line.find(" ") > 0:
		return line.substr(line.find(" ") + 1)
	return line


static func _speech_quotes(line: String) -> Array:
	## [[start, end_exclusive], ...] of top-level 「…」 that are speech (they contain punctuation); 「借」粮 and the like are not
	var out: Array = []
	var depth := 0
	var st := -1
	for i in line.length():
		var ch := line[i]
		if ch == "「":
			if depth == 0:
				st = i
			depth += 1
		elif ch == "」" and depth > 0:
			depth -= 1
			if depth == 0:
				var inner := line.substr(st + 1, i - st - 1)
				for m in SPEECH_MARKS:
					if inner.contains(m):
						out.append([st, i + 1])
						break
	return out


func test_narration_and_speech_never_share_a_line() -> void:
	var label := RegEx.create_from_string("^(\\{lord\\}|[^，。！？「」：（）的了着你我他她]{1,6})(（[^）]{1,12}）)?：$")
	var inner := RegEx.create_from_string("^(\\{lord\\}|[^，。！？「」：（）]{1,6})（内心）：")
	var bad: Array = []
	for t in _texts():
		var line := _strip_tag(t[1])
		if inner.search(line) != null:
			continue
		var quotes := _speech_quotes(line)
		if quotes.is_empty():
			continue
		var lead := line.substr(0, quotes[0][0]).strip_edges()
		var tail := line.substr(quotes[-1][1]).strip_edges()
		var ok: bool = quotes.size() == 1 and tail == "" and (lead == "" or label.search(lead) != null)
		if not ok:
			bad.append("%s: %s" % [t[0], line.substr(0, 40)])
	check(bad.is_empty(), "lines mixing narration and speech (split them: narration on one line, each 「…」 on its own): %s" % str(bad.slice(0, 6)))


func test_every_tagged_line_names_a_known_portrait_or_no_face() -> void:
	var bad: Array = []
	for t in _texts():
		var l: String = t[1]
		if not l.begins_with("@"):
			continue
		var sp := l.find(" ")
		if sp < 2:
			continue  # the old bare "@ " (no face) form
		var key := l.substr(1, sp - 1)
		if key == "_" or key == "lord" or key == "lord_north":
			continue
		if Kit.portrait_key(key) == "" and not GameData.get_db().cards.has(key):
			bad.append("%s: @%s" % [t[0], key])
	check(bad.is_empty(), "speaker tags that match no portrait: %s" % str(bad.slice(0, 8)))


func test_grown_up_zhenmi_never_shows_the_young_face() -> void:
	## 甄宓 is an adult from 北线第七章 on: no @zhenmi_young there, and 「甄宓：」 lines resolve to the adult portrait
	var late := ["yecheng", "longhu", "xiliang", "sanfang", "tianqing", "guandu", "dujiang", "guiyi"]
	var bad: Array = []
	for q in GameData.get_db().quests:
		if not late.has(q["id"]):
			continue
		for sid in q["squares"]:
			var s: Dictionary = q["squares"][sid]
			var lines: Array = s.get("text", [])
			var who: Array = Kit.speakers(lines, s.get("portraits", []))
			for i in who.size():
				if who[i] == "zhenmi_young":
					bad.append("%s/%s: %s" % [q["id"], sid, str(lines[i]).left(20)])
	for eid in GameData.get_db().events:
		var e: Dictionary = GameData.get_db().events[eid]
		if late.has(str(e.get("scope", ""))) and str(e.get("text", [])).contains("@zhenmi_young "):
			bad.append("event/%s" % eid)
	check(bad.is_empty(), "adult 甄宓 shown with the young portrait: %s" % str(bad.slice(0, 8)))


func test_in_the_north_route_followers_call_the_hero_dage() -> void:
	var bad: Array = []
	for t in _texts():
		if t[2] != "north" or t[0] in ADDRESS_EXCEPTIONS:
			continue
		var l: String = t[1]
		if not l.begins_with("@") or not l.contains("主公"):
			continue
		var key := l.substr(1, l.find(" ") - 1)
		if key in NORTH_FOLLOWERS:
			bad.append("%s: %s" % [t[0], l.substr(0, 40)])
	check(bad.is_empty(), "北线里同伴称呼主角用「大哥」，不用「主公」: %s" % str(bad.slice(0, 6)))
