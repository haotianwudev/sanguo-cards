class_name TestCase
extends RefCounted
## Base for test files. Call check(); failures are collected by run_tests.gd.

var failures: Array = []


func check(cond: bool, msg: String = "check failed") -> void:
	if not cond:
		failures.append(msg)


func check_eq(a: Variant, b: Variant, msg: String = "") -> void:
	if a != b:
		failures.append("%s expected %s == %s" % [msg, str(a), str(b)])


func check_between(x: float, lo: float, hi: float, msg: String = "") -> void:
	if x <= lo or x >= hi:
		failures.append("%s %.3f not in (%.2f, %.2f)" % [msg, x, lo, hi])


static func party(leaders: Array, extra: Array = []) -> Array:
	## Leaders plus extra owned cards (which back up their troop's leader).
	var s := SaveData.new()
	s.owned = leaders + extra
	s.party = leaders.duplicate()
	return s.party_leaders()


# ---- shared helpers (were copied in several test files) ----

func rng(seed_value: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r


func quest(i: int) -> Dictionary:
	return GameData.get_db().quests[i]


func walk_to(q: Dictionary, s: SaveData, ids: Array, choice := 0) -> void:
	for sid in ids:
		Quests.move(q, s, sid)
		Quests.resolve(q, s, rng(0), choice)


func _plain(d: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(d))  # ints and floats compare alike after a trip through a file


func event_on_road(eid: String, option: int, seed_value := 0) -> SaveData:
	var q := quest(0)
	var s := SaveData.create()
	Quests.begin(q, s)
	s.square = "road"
	s.resolved = false
	s.events = {"road": eid}
	Quests.choose_event(q, s, rng(seed_value), option)
	return s


# ---- naive bot, shared by the balance tests ----------------------------------------

static func expected_value(b: Battle, u: Dictionary, sk: Dictionary) -> float:
	var v := 0.0
	var at: float = u["leader"]["at"]
	for e in sk["effects"]:
		match e["type"]:
			"attack", "magic":
				v += at * float(e["power"]) * int(e.get("hits", 1))
			"heal":
				v += at * float(e["power"]) * (1.5 if b.party_hp < 0.4 * b.party_max else 0.0)
			"stun":
				v += float(e["chance"]) * b.enemy["data"]["at"] * 2
			_:
				v += 0.2 * at
	return v


static func bot_fight(b: Battle) -> String:
	## Spend AP on the best value-per-AP action until nothing is usable; never defends.
	## SIM_BOT=tactics plays under the 拆招 preset (interrupts, defends against charged blows) instead — to compare; + SIM_DEFAULTS=1 adds the default rows.
	if OS.get_environment("SIM_BOT") == "tactics":
		var t := {"preset": OS.get_environment("SIM_PRESET") if OS.get_environment("SIM_PRESET") != "" else "smart", "party_rows": [], "rows": {}}
		var only := OS.get_environment("SIM_DEFAULTS")  # 1: with the default 军令 rows (battle.json tactics.defaults); party_rows / troop_rows / rows: that layer only
		if only != "":
			var d := AutoPlayer.with_defaults({"preset": t["preset"]})
			for k in ["party_rows", "troop_rows", "rows"]:
				if only == "1" or k in only.split(","):
					t[k] = d[k]
			if OS.get_environment("SIM_TROOP") != "":  # SIM_TROOP=<troop>: of the 兵种 layer, only that troop's default rows
				t["troop_rows"] = {OS.get_environment("SIM_TROOP"): d["troop_rows"].get(OS.get_environment("SIM_TROOP"), [])}
		var steps := 0
		while b.result == "" and steps < 2000:
			steps += 1
			var p := AutoPlayer.plan(b, t)
			match str(p["kind"]):
				"act":
					b.act(p["unit"], p["skill"])
				"swap":
					b.swap(p["unit"], p["card"])
				"defend":
					b.defend()
				_:
					b.end_round()
		return b.result
	while b.result == "":
		while b.result == "":
			var best: Array = []
			var best_score := -1.0
			for i in b.leaders.size():
				if not b.can_act(i):
					continue
				var u: Dictionary = b.leaders[i]
				for sk in b.skills_of(u):
					if b.usable(u, sk):
						var score := expected_value(b, u, sk) / (b.cost(u, sk) + 1)
						if score > best_score:
							best_score = score
							best = [i, sk["id"]]
			if best.is_empty():
				break
			b.act(best[0], best[1])
		if b.result == "":
			b.end_round()
	return b.result
