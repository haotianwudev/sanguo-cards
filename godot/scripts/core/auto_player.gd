class_name AutoPlayer
extends RefCounted
## 自动战斗 + 军令 (v3, docs/battle-v3.md). Each step picks one action for the player's side, in this order:
##   1. 破招 — the enemy is winding up and someone can play an 打断 skill (preset `interrupt`);
##   2. 个人军令 — each leader's own rows `[skill, condition, reserve]` (Game.options.tactics.rows[card id]), first row that holds;
##   3. 自动换人 (tactics.auto_swap) — 架势 on the enemy and nobody fields magic → bring in a 策士; our fire / poison / confusion
##      with no cleanse on the field → bring in a 后勤;
##   4. 留气 — a reserve row whose skill only lacks AP keeps the others to 0 AP / AP-giving skills;
##   5. the old greedy pick (best value per AP), adjusted for 架势 / 前卫 / 打断;
##   6. nothing worth doing → defend when a charged blow is coming (preset `defend_charge`) or AP is full, else end the round.
## `tactics` = {"preset": "smart" | "aggro" | "save", "auto_swap": bool, "rows": {card id: [{skill, cond, reserve}]}}; presets
## and the condition list live in battle.json `tactics`.


static func value(b: Battle, u: Dictionary, sk: Dictionary) -> float:
	var v := 0.0
	var at: float = u["leader"]["at"]
	for e in sk["effects"]:
		match e["type"]:
			"attack", "magic":
				var hit := at * float(e["power"]) * int(e.get("hits", 1)) * b.vs_mult(e)
				if b.crit_if_holds(e):
					hit *= 1.6
				if e["type"] == "attack" and b.enemy_state("stance"):
					hit *= 0.4  # 架势: the blow is answered
				if (e["type"] == "magic" or e.get("pierce", false)) and b.enemy_state("guarded"):
					hit *= 1.5  # over the 前卫, straight at the boss
				v += hit
			"heal":
				v += at * float(e["power"]) * (1.5 if b.party_hp < 0.4 * b.party_max else 0.0)  # healing only pays when hurt
			"stun":
				v += float(e["chance"]) * b.enemy["data"]["at"] * 2 * (2.0 if b.enemy_state("stance") else 1.0)
			"interrupt":  # 打断: worth a lot while the enemy winds up, nothing otherwise
				v += float(b.enemy["at"]) * 4.0 if b.enemy_state("charging") else 0.0
			"poison":  # what the new layers take over the turns left, while there is room to stack
				var room := mini(int(e.get("stacks", 1)), int(e.get("max", 5)) - int(b.enemy["poison"]))
				v += float(b.enemy["max_hp"]) * float(e["pct"]) * maxi(0, room) * int(e.get("turns", 3)) * 0.5
			"boost":  # BOOST on a waiting ally: its next skill hits boost_mult times as hard
				var best_ally := 0.0
				for t in b.leaders:
					if t != u and not t["acted"] and not t["boosted"] and not t["confused"]:
						best_ally = maxf(best_ally, float(t["leader"]["at"]))
				v += (float(b.db.battle["boost_mult"]) - 1.0) * best_ally * 2.0
			"shred":  # 射穿甲缝: the party's blows over its turns hit that much harder (until the cap)
				var room := maxf(0.0, float(b.db.battle.get("archer_resist", {}).get("max", 0.5)) - float(b.enemy["resist_down"]))
				var pat := 0.0
				for t in b.leaders:
					pat += float(t["leader"]["at"])
				v += minf(room, float(e.get("amount", 0.1))) * pat * int(e.get("turns", 3)) * 0.5
			"buff":  # 战意 (军师 1 AP): what the whole party gains over the rounds it lasts — more damage dealt (atk + magic rider) and less taken (def)
				var turns := mini(int(e.get("turns", 3)), maxi(1, b.turn_limit - b.round_no + 1))
				var share := 1.0 if b.buff["layers"] < int(e.get("max", 4)) else (1.0 if int(b.buff["turns"]) <= 1 else 0.0)  # at max layers only a refresh before it runs out is worth anything
				if b.buff["layers"] >= int(e.get("max", 4)):
					share *= 0.5  # a refresh adds no layer
				var party_at := 0.0
				for t in b.leaders:
					party_at += float(t["leader"]["at"])
				var hit := float(e.get("atk", 0.0)) + float(e.get("magic", 0.0))
				var guard := float(e.get("def", 0.0)) * float(b.enemy["data"]["at"]) * int(b.enemy["data"].get("actions", 1))
				var waiting := 0  # cast before the others move, their blows this very round take it too: 自动 plays it first
				for t in b.leaders:
					if t != u and not t["acted"]:
						waiting += 1
				v += share * turns * (hit * party_at + guard) * (1.0 + 0.25 * waiting)
			"cleanse":
				var bad := int(b.party_burn.get("turns", 0)) > 0 or int(b.party_poison.get("turns", 0)) > 0 or b.ap_drain > 0 \
					or b.leaders.any(func(t): return t["confused"] or t["confuse_next"])
				v += 0.6 * at if bad else 0.0
			_:
				v += 0.2 * at
	if u["boosted"]:  # a boosted unit's next skill is worth boost_mult times (the boost is spent on whatever it plays)
		v *= float(b.db.battle["boost_mult"])
	return v


# ---- 军令 ---------------------------------------------------------------------

static func default_tactics() -> Dictionary:
	return {"preset": "smart", "auto_swap": false, "rows": {}}


static func preset(b: Battle, tactics: Dictionary) -> Dictionary:
	var all: Dictionary = b.db.battle.get("tactics", {}).get("presets", {})
	return all.get(str(tactics.get("preset", "smart")), all.get("smart", {}))


static func is_boss(b: Battle) -> bool:
	return str(b.mods.get("enemy_tier", "normal")) in ["boss", "lose"]


static func charged_blow_coming(b: Battle) -> bool:
	## this round's plan opens with a wound-up move that hits
	if b.enemy["intents"].is_empty() or str(b.enemy["charging"]) == "":
		return false
	var mv: Dictionary = b.enemy["intents"][0]
	return mv["name"] == b.enemy["charging"] and (float(mv.get("power", 0.0)) > 0.0 or mv.has("pct"))


static func cond_holds(b: Battle, cond: String) -> bool:
	## the 军令 conditions (battle.json tactics.conditions)
	var ct: Dictionary = b.charge_target({"charge": b.enemy["charging"]}) if str(b.enemy["charging"]) != "" else {}
	match cond:
		"always", "":
			return true
		"enemy_charging":
			return b.enemy_state("charging")
		"enemy_charging_heal":
			return ct.has("heal")
		"enemy_charging_summon":
			return ct.has("summon")
		"enemy_stance":
			return b.enemy_state("stance")
		"enemy_guard":
			return b.enemy_state("guarded")
		"enemy_stunned":
			return b.enemy_state("stunned")
		"enemy_broken":
			return b.enemy_state("broken")
		"enemy_low_hp":
			return int(b.enemy["hp"]) * 10 < int(b.enemy["max_hp"]) * 3
		"boss_fight":
			return is_boss(b)
		"party_low_hp":
			return b.party_hp * 10 < b.party_max * 4
		"party_status":
			return int(b.party_burn.get("turns", 0)) > 0 or int(b.party_poison.get("turns", 0)) > 0 \
				or b.leaders.any(func(t): return t["confused"] or t["confuse_next"])
		"ap_full":
			return b.ap >= b.ap_max()
		"ap_6":
			return b.ap >= 6
	return false


static func _is_ult(sk: Dictionary) -> bool:
	return sk["uses"] == 1 or sk["per_battle"]


static func _allowed(b: Battle, sk: Dictionary, pre: Dictionary) -> bool:
	## 省技: once-only skills only in a boss fight
	if str(pre.get("ults", "always")) == "boss" and sk["uses"] == 1 and not is_boss(b):
		return false
	return true


static func _held_interrupt(b: Battle, sk: Dictionary, pre: Dictionary) -> bool:
	## an 打断 skill kept back for the enemy's wind-up: under a preset that interrupts, against an enemy that can wind up at all,
	## while it isn't winding up and isn't nearly dead (then it is just a blow — spend it)
	if not pre.get("interrupt", true) or b.enemy_state("charging") or not sk["effects"].any(func(e): return e["type"] == "interrupt"):
		return false
	if int(b.enemy["hp"]) * 4 < int(b.enemy["max_hp"]):
		return false
	return b.enemy["data"]["moves"].any(func(m): return m.has("charge"))


static func _interrupt_act(b: Battle) -> Array:
	if not b.enemy_state("charging"):
		return []
	for i in b.leaders.size():
		if not b.can_act(i):
			continue
		var u: Dictionary = b.leaders[i]
		for sk in b.skills_of(u):
			if b.usable(u, sk) and sk["effects"].any(func(e): return e["type"] == "interrupt"):
				return [i, sk["id"]]
	return []


static func _reserve_need(b: Battle, tactics: Dictionary) -> int:
	## 留气: the AP a reserve row's skill still lacks while everything else about it holds (0 = nothing held back)
	var rows: Dictionary = tactics.get("rows", {})
	for i in b.leaders.size():
		var u: Dictionary = b.leaders[i]
		if u["acted"] or u["confused"]:
			continue
		for row in rows.get(str(u["leader"]["card"]["id"]), []):
			if not row.get("reserve", false) or not u["leader"]["card"]["skills"].has(row.get("skill", "")):
				continue
			var sk: Dictionary = b.db.skills[row["skill"]]
			var left: Variant = u["uses_left"][sk["id"]]
			if left != null and int(left) == 0:
				continue
			var c := b.cost(u, sk)
			if c > b.ap and c <= b.ap_max() and cond_holds(b, str(row.get("cond", "always"))):
				return c
	return 0


static func _row_act(b: Battle, tactics: Dictionary) -> Array:
	var rows: Dictionary = tactics.get("rows", {})
	for i in b.leaders.size():
		if not b.can_act(i):
			continue
		var u: Dictionary = b.leaders[i]
		for row in rows.get(str(u["leader"]["card"]["id"]), []):
			var sid := str(row.get("skill", ""))
			if not u["leader"]["card"]["skills"].has(sid):
				continue
			var sk: Dictionary = b.db.skills[sid]
			if b.usable(u, sk) and cond_holds(b, str(row.get("cond", "always"))):
				return [i, sid]
	return []


static func _swap_act(b: Battle, tactics: Dictionary) -> Array:
	## 自动换人: [slot, card id] or []
	if not tactics.get("auto_swap", false):
		return []
	var want := ""
	if b.enemy_state("stance") and not b.leaders.any(func(u): return b.skills_of(u).any(func(sk): return sk["effects"].any(func(e): return e["type"] == "magic"))):
		want = "strategist"
	elif cond_holds(b, "party_status") and not b.leaders.any(func(u): return not u["acted"] and b.skills_of(u).any(func(sk): return b.usable(u, sk) and sk["effects"].any(func(e): return e["type"] == "cleanse"))):
		want = "logistics"
	if want == "":
		return []
	var best: Array = []
	var weakest := INF
	for i in b.leaders.size():
		if not b.can_swap(i):
			continue
		for ld in b.swap_options(i):
			if str(ld["card"]["troop"]) == want and float(b.leaders[i]["leader"]["at"]) < weakest:
				weakest = float(b.leaders[i]["leader"]["at"])
				best = [i, ld["card"]["id"]]
	return best


static func _greedy(b: Battle, pre: Dictionary, reserve: int) -> Array:
	var best: Array = []
	var best_score := 0.0
	for i in b.leaders.size():
		if not b.can_act(i):
			continue
		var u: Dictionary = b.leaders[i]
		for sk in b.skills_of(u):
			if not b.usable(u, sk) or not _allowed(b, sk, pre):
				continue
			if _held_interrupt(b, sk, pre):
				continue  # 拆招: keep the 打断 for the wind-up
			var c := b.cost(u, sk)
			if reserve > 0 and c > 0 and not sk["effects"].any(func(e): return e["type"] == "ap"):
				continue  # 留气: keep the AP for the big one
			var score := value(b, u, sk) / (c + 1)
			if u["boosted"]:
				score *= 1.0 + 0.1 * c  # spend the boost on the biggest skill it can afford, not the cheapest per AP
			if sk["uses"] == 1 and not (is_boss(b) and str(pre.get("ults", "always")) == "always"):
				score *= 0.6  # a once-only skill stays spent until the next 休整: don't burn it on a whim
			if score > best_score:
				best_score = score
				best = [i, sk["id"]]
	return best


static func plan(b: Battle, tactics: Dictionary = {}) -> Dictionary:
	## one step of 自动 under 军令: {"kind": "act", "unit", "skill"} | {"kind": "swap", "unit", "card"} | {"kind": "defend"} | {"kind": "end"}
	if tactics.is_empty():
		tactics = default_tactics()
	var pre := preset(b, tactics)
	if pre.get("interrupt", true):
		var ia := _interrupt_act(b)
		if not ia.is_empty():
			return {"kind": "act", "unit": ia[0], "skill": ia[1]}
	var ra := _row_act(b, tactics)
	if not ra.is_empty():
		return {"kind": "act", "unit": ra[0], "skill": ra[1]}
	var sw := _swap_act(b, tactics)
	if not sw.is_empty():
		return {"kind": "swap", "unit": sw[0], "card": sw[1]}
	var reserve := _reserve_need(b, tactics) if pre.get("reserve", true) else 0
	var ga := _greedy(b, pre, reserve)
	if not ga.is_empty():
		return {"kind": "act", "unit": ga[0], "skill": ga[1]}
	if b.can_defend() and (ends_with_defend(b) or (pre.get("defend_charge", true) and charged_blow_coming(b))):
		return {"kind": "defend"}
	return {"kind": "end"}


static func ends_with_defend(b: Battle) -> bool:
	## nothing left to play and AP at its cap: guard instead of a plain end of round (the AP the next round brings would only spill over)
	return b.ap >= b.ap_max() and b.can_defend()


static func next(b: Battle, tactics: Dictionary = {}) -> Array:
	## [leader index, skill id], or [] when there is nothing worth playing (the old interface; swaps and defends are left to the caller)
	var p := plan(b, tactics)
	return [p["unit"], p["skill"]] if p["kind"] == "act" else []
