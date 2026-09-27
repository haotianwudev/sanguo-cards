class_name Battle
extends RefCounted
## Rance X battle engine. Pure logic, no nodes — every call returns log lines (Array of String).
##
## One shared party HP bar (sum of the leaders' HP) against one enemy with one HP bar.
## Round flow:
##   1. Round start: AP += ap_per_round (max ap_max); leaders idle for boost_idle_rounds may get BOOST;
##      troop members may interrupt with a free attack.
##   2. Player phase: spend AP on leader skills. Each leader acts at most once per round.
##      累积 skills cost +1 AP after every use; 1回制限 skills can be used once per battle.
##      Every hit raises the combo; each combo step adds combo_bonus damage.
##   3. End the round (or defend: end it with a growing damage cut); the enemy attacks the shared HP bar.
## Win: enemy HP 0. Lose: party HP 0, the round limit runs out, or retreat.

var db: GameData
var scenario: Dictionary
var rng := RandomNumberGenerator.new()
## Each unit: {leader, uses_left, extra_cost, acted, idle_rounds, boosted, confused, confuse_next}
var leaders: Array = []
## {data, hp, max_hp, stunned, break_amount, break_turns}
var enemy: Dictionary
var party_hp := 0
var party_max := 0
var round_no := 0
var ap := 0
var combo := 0
var guard_cut := 0.0
var defend_streak := 0
var result := ""  # "" | "win" | "lose"
var overkill := 0.0  # excess damage on the killing blow, as a share of the enemy's max HP
var opening: Array = []  # log lines from the first round start
## Structured events for the UI to animate, appended as things happen; the UI drains them with take_events().
## {"t": "act"|"hit"|"heal"|"guard"|"boost"|"stun"|"break"|"ap"|"defend"|"enemy_turn"|"enemy_stunned"|
##       "enemy_hit"|"confuse"|"round"|"interrupt", ...}
var events: Array = []


func take_events() -> Array:
	var out := events
	events = []
	return out


func _ev(e: Dictionary) -> void:
	events.append(e)


static func start(scenario_id: String, party: Array, seed_value: int = -1, damage: int = 0,
		extra: Dictionary = {}, uses: Dictionary = {}, ambush := false) -> Battle:
	## damage / extra / uses carry a quest's wear from earlier battles.
	## ambush: the enemy strikes once before the first round.
	var b := Battle.new()
	b.db = GameData.get_db()
	if seed_value >= 0:
		b.rng.seed = seed_value
	else:
		b.rng.randomize()
	b.scenario = b.db.scenarios[scenario_id]
	var e: Dictionary = b.db.enemies[b.scenario["enemy"]]
	var max_hp := int(round(e["hp"] * (1.0 + float(b.db.battle["enemy_hp_per_extra_leader"]) * (party.size() - 1))))
	b.enemy = {"data": e, "hp": max_hp, "max_hp": max_hp, "stunned": false, "break_amount": 0.0, "break_turns": 0}
	var hp := 0
	for ld in party:
		var cid: String = ld["card"]["id"]
		var u_left := {}
		var u_extra := {}
		for s in ld["card"]["skills"]:
			u_left[s] = uses.get(cid, {}).get(s, b.db.skills[s]["uses"])
			u_extra[s] = extra.get(cid, {}).get(s, 0)
		b.leaders.append({"leader": ld, "uses_left": u_left, "extra_cost": u_extra, "acted": false,
			"idle_rounds": 0, "boosted": false, "confused": false, "confuse_next": false})
		hp += ld["hp"]
	b.party_max = hp
	b.party_hp = maxi(1, hp - damage)
	b.ap = int(b.db.battle["ap_start"]) - int(b.db.battle["ap_per_round"])
	b.opening = b._ambush() if ambush else []
	b.opening.append_array(b._start_round())
	return b


func carry_out() -> Array:
	## [damage taken, 累积 increments, uses left] keyed by card id — for the next battle in a quest.
	var extra := {}
	var uses := {}
	for u in leaders:
		var cid: String = u["leader"]["card"]["id"]
		extra[cid] = u["extra_cost"].duplicate()
		var left := {}
		for s in u["uses_left"]:
			if u["uses_left"][s] != null:
				left[s] = u["uses_left"][s]
		uses[cid] = left
	return [party_max - party_hp, extra, uses]


# ---- queries -----------------------------------------------------------------

static func unit_name(u: Dictionary) -> String:
	return u["leader"]["card"]["name"]


func cost(u: Dictionary, sk: Dictionary) -> int:
	return sk["cost"] + u["extra_cost"][sk["id"]]


func skills_of(u: Dictionary) -> Array:
	return u["leader"]["card"]["skills"].map(func(s): return db.skills[s])


func usable(u: Dictionary, sk: Dictionary) -> bool:
	var left: Variant = u["uses_left"][sk["id"]]
	if left != null and left == 0:
		return false
	return cost(u, sk) <= ap


func can_act(i: int) -> bool:
	var u: Dictionary = leaders[i]
	if result != "" or u["acted"] or u["confused"]:
		return false
	for sk in skills_of(u):
		if usable(u, sk):
			return true
	return false


# ---- player actions ----------------------------------------------------------

func act(i: int, skill_id: String) -> Array:
	var u: Dictionary = leaders[i]
	var sk: Dictionary = db.skills[skill_id]
	assert(can_act(i) and u["leader"]["card"]["skills"].has(skill_id) and usable(u, sk),
		"%s cannot use %s now" % [unit_name(u), sk["name"]])
	ap -= cost(u, sk)
	if sk["cumulative"]:
		u["extra_cost"][skill_id] += 1
	if u["uses_left"][skill_id] != null:
		u["uses_left"][skill_id] -= 1
	u["acted"] = true
	u["idle_rounds"] = 0
	var mult: float = float(db.battle["boost_mult"]) if u["boosted"] else 1.0
	_ev({"t": "act", "unit": i, "skill": skill_id, "boost": u["boosted"]})
	var log: Array = ["%s【%s】%s" % [unit_name(u), sk["name"], "（BOOST）" if u["boosted"] else ""]]
	u["boosted"] = false
	for eff in sk["effects"]:
		log.append_array(_apply(u, eff, mult))
	_check_end()
	return log


func end_round() -> Array:
	defend_streak = 0
	return _enemy_phase(0.0)


func defend() -> Array:
	var cuts: Array = db.battle["defend_cuts"]
	var cut: float = cuts[mini(defend_streak, cuts.size() - 1)]
	defend_streak += 1
	_ev({"t": "defend", "cut": cut})
	var log: Array = ["全军防御（伤害 -%d%%）" % int(round(cut * 100))]
	log.append_array(_enemy_phase(cut))
	return log


func retreat() -> Array:
	result = "lose"
	return ["全军撤退！"]


# ---- internals ---------------------------------------------------------------

func _variance() -> float:
	var v := float(db.battle["variance"])
	return rng.randf_range(1.0 - v, 1.0 + v)


func _dmg(base: float, kind: String) -> int:
	var data: Dictionary = enemy["data"]
	var resist: float = data["phys_resist"] if kind == "attack" else data["magic_resist"]
	var d: float = base * (1.0 + float(db.battle["combo_bonus"]) * combo) * (1.0 + enemy["break_amount"]) * (1.0 - resist)
	return maxi(1, int(round(d * _variance())))


func _apply(u: Dictionary, eff: Dictionary, mult: float) -> Array:
	var kind: String = eff["type"]
	var at: int = u["leader"]["at"]
	var ename: String = enemy["data"]["name"]
	match kind:
		"attack", "magic":
			var log: Array = []
			for _h in int(eff.get("hits", 1)):
				if enemy["hp"] <= 0:
					break
				var d := _dmg(at * float(eff["power"]) * mult, kind)
				if d > enemy["hp"]:
					overkill = float(d - enemy["hp"]) / enemy["max_hp"]
				enemy["hp"] = maxi(0, enemy["hp"] - d)
				combo += 1
				_ev({"t": "hit", "dmg": d, "combo": combo, "kind": kind, "hp": enemy["hp"]})
				log.append("  %s 受到 %d 伤害（%d 连击）" % [ename, d, combo])
			return log
		"heal":
			var amt := mini(int(round(at * float(eff["power"]) * mult)), party_max - party_hp)
			party_hp += amt
			_ev({"t": "heal", "amt": amt, "hp": party_hp})
			return ["  体力恢复 %d" % amt]
		"guard":
			guard_cut = 1.0 - (1.0 - guard_cut) * (1.0 - float(eff["cut"]))
			_ev({"t": "guard", "cut": guard_cut})
			return ["  本回合受到伤害 -%d%%" % int(round(guard_cut * 100))]
		"boost":
			var bm := str(db.battle["boost_mult"])
			if eff["target"] == "all":
				var who: Array = []
				for t in leaders:
					if t != u:
						t["boosted"] = true
						who.append(leaders.find(t))
				_ev({"t": "boost", "units": who})
				return ["  全军进入 BOOST（下次行动 ×%s）" % bm]
			u["boosted"] = true
			_ev({"t": "boost", "units": [leaders.find(u)]})
			return ["  %s 进入 BOOST（下次行动 ×%s）" % [unit_name(u), bm]]
		"stun":
			if rng.randf() < float(eff["chance"]):
				enemy["stunned"] = true
				_ev({"t": "stun", "ok": true})
				return ["  %s 陷入混乱！下回合无法行动" % ename]
			_ev({"t": "stun", "ok": false})
			return ["  %s 未受影响" % ename]
		"break":
			enemy["break_amount"] = maxf(enemy["break_amount"], float(eff["amount"]))
			enemy["break_turns"] = maxi(enemy["break_turns"], int(eff["turns"]))
			_ev({"t": "break", "amount": enemy["break_amount"], "turns": enemy["break_turns"]})
			return ["  %s 破防：受到伤害 +%d%%（%d 回合）" % [ename, int(round(float(eff["amount"]) * 100)), int(eff["turns"])]]
		"ap":
			ap = mini(int(db.battle["ap_max"]), ap + int(eff["amount"]))
			_ev({"t": "ap", "amount": int(eff["amount"]), "ap": ap})
			return ["  AP +%d" % int(eff["amount"])]
	assert(false, "unknown effect " + kind)
	return []


func _enemy_phase(defend_cut: float) -> Array:
	if result != "":
		return []
	var data: Dictionary = enemy["data"]
	_ev({"t": "enemy_turn"})
	var log: Array = ["—— %s 的行动 ——" % data["name"]]
	if enemy["stunned"]:
		enemy["stunned"] = false
		_ev({"t": "enemy_stunned"})
		log.append("%s 混乱中，无法行动" % data["name"])
	else:
		var cut := 1.0 - (1.0 - guard_cut) * (1.0 - defend_cut)
		var moves: Array = data["moves"]
		for _a in int(data["actions"]):
			var mv: Dictionary = GameData.weighted_pick(rng, moves, moves.map(func(m): return float(m["weight"])))
			var d := maxi(1, int(round(data["at"] * float(mv["power"]) * _variance() * (1.0 - cut))))
			party_hp = maxi(0, party_hp - d)
			_ev({"t": "enemy_hit", "dmg": d, "move": mv["name"], "cut": cut, "hp": party_hp})
			log.append("%s【%s】 我军受到 %d 伤害%s" % [data["name"], mv["name"], d,
				("（减伤 %d%%）" % int(round(cut * 100))) if cut > 0.0 else ""])
			if mv.has("confuse") and rng.randf() < float(mv["confuse"]):
				var victim: Dictionary = leaders[rng.randi_range(0, leaders.size() - 1)]
				victim["confuse_next"] = true
				_ev({"t": "confuse", "unit": leaders.find(victim)})
				log.append("  %s 陷入混乱，下回合无法行动" % unit_name(victim))
			_check_end()
			if result != "":
				return log
	if enemy["break_turns"] > 0:
		enemy["break_turns"] -= 1
		if enemy["break_turns"] == 0:
			enemy["break_amount"] = 0.0
	if round_no >= scenario["turn_limit"]:
		result = "lose"
		log.append("已到第 %d 回合上限 —— 撤退！" % round_no)
		return log
	log.append_array(_start_round())
	return log


func _ambush() -> Array:
	## 埋伏: every enemy action lands once before the party can move (never kills outright).
	var data: Dictionary = enemy["data"]
	var log: Array = ["[color=red]埋伏！%s 抢先出手[/color]" % data["name"]]
	for _a in int(data["actions"]):
		var mv: Dictionary = data["moves"][0]
		var d := maxi(1, int(round(data["at"] * float(mv["power"]) * _variance())))
		party_hp = maxi(1, party_hp - d)
		_ev({"t": "enemy_hit", "dmg": d, "move": mv["name"], "cut": 0.0, "hp": party_hp})
		log.append("%s【%s】 我军受到 %d 伤害" % [data["name"], mv["name"], d])
	return log


func _start_round() -> Array:
	var cfg := db.battle
	if round_no > 0:
		for u in leaders:
			if not u["acted"]:
				u["idle_rounds"] += 1
	round_no += 1
	ap = mini(int(cfg["ap_max"]), ap + int(cfg["ap_per_round"]))
	combo = 0
	guard_cut = 0.0
	_ev({"t": "round", "n": round_no, "ap": ap})
	var log: Array = ["─── 第 %d 回合 ───" % round_no]
	for u in leaders:
		u["acted"] = false
		u["confused"] = u["confuse_next"]
		u["confuse_next"] = false
		if not u["boosted"] and u["idle_rounds"] >= int(cfg["boost_idle_rounds"]) and rng.randf() < float(cfg["boost_chance"]):
			u["boosted"] = true
			_ev({"t": "boost", "units": [leaders.find(u)], "idle": true})
			log.append("%s 蓄势已久 —— BOOST！" % unit_name(u))
	for u in leaders:
		var members: Array = u["leader"]["members"]
		if not members.is_empty() and enemy["hp"] > 0 and rng.randf() < float(cfg["interrupt_chance"]):
			var m: Dictionary = members[rng.randi_range(0, members.size() - 1)]
			var d := _dmg(m["at"] * float(cfg["interrupt_power"]), "attack")
			enemy["hp"] = maxi(0, enemy["hp"] - d)
			combo += 1
			_ev({"t": "interrupt", "unit": leaders.find(u), "member": m["name"], "dmg": d, "hp": enemy["hp"]})
			log.append("插入！%s部队的 %s 突袭，造成 %d 伤害" % [unit_name(u), m["name"], d])
	_check_end()
	return log


func _check_end() -> void:
	if enemy["hp"] <= 0:
		result = "win"
	elif party_hp <= 0:
		result = "lose"
