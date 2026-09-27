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
