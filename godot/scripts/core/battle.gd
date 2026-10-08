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
##   3. End the round (or defend: pay defend_ap AP to end it with a growing damage cut); the enemy attacks the shared HP bar.
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
var mods: Dictionary = {}  # 宝物 / 险 (see cards.json relics) + enemy (险: enemy strength)
var turn_limit := 0
var first_hit_done := false
var party_burn := {}  # the enemy's fire on us: {dmg, turns}
var ap_drain := 0  # AP the enemy takes away at the next round start
var roster: Array = []  # leader dicts that can be tagged in mid-battle (SaveData.swap_roster): any owned card not leading
var bench_states: Dictionary = {}  # card id -> {uses_left, extra_cost}: the skill state of cards swapped out (only handed on to the next fight)
var swaps_done := 0  # this round
var _carry_extra: Dictionary = {}
var _carry_uses: Dictionary = {}
var buff := {"layers": 0, "turns": 0, "atk": 0.0, "def": 0.0}  # 战意 (军师): stacked layers, rounds left, summed attack bonus / damage cut
var counters: Array = []  # 反击 (枪兵): [{name, at, power}] — each enemy hit this round is answered by every entry
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
		extra: Dictionary = {}, uses: Dictionary = {}, ambush := false, mods := {}, roster := []) -> Battle:
	## damage / extra / uses carry a quest's wear from earlier battles.  roster: cards that can be swapped in (换人).
	## ambush: the enemy strikes once before the first round.  mods: the run's 宝物 and 险 (Quests.mods).
	var b := Battle.new()
	b.db = GameData.get_db()
	if seed_value >= 0:
		b.rng.seed = seed_value
	else:
		b.rng.randomize()
	b.scenario = b.db.scenarios[scenario_id]
	var e: Dictionary = b.db.enemies[b.scenario["enemy"]].duplicate(true)
	b.mods = mods
	var afx: Dictionary = mods.get("affix", {})  # 词缀 on an elite / boss (see Quests.affix_here)
	e["phys_resist"] = minf(0.8, float(e["phys_resist"]) + float(afx.get("phys_resist", 0.0)))
	e["magic_resist"] = minf(0.8, float(e["magic_resist"]) + float(afx.get("magic_resist", 0.0)))
	e["actions"] = int(e["actions"]) + int(afx.get("actions", 0))
	var tough := 1.0 + float(mods.get("enemy", 0.0))
	var max_hp := int(round(e["hp"] * float(b.db.battle.get("enemy_hp_mult", 1.0)) * tough * (1.0 + float(afx.get("hp", 0.0)))
		* (1.0 + float(b.db.battle["enemy_hp_per_extra_leader"]) * (party.size() - 1))))
	b.enemy = {"data": e, "hp": max_hp, "max_hp": max_hp, "at": e["at"] * tough * (1.0 + float(afx.get("at", 0.0))),
		"regen": float(afx.get("regen", 0.0)), "stunned": false,
		"break_amount": 0.0, "break_turns": 0, "burn_dmg": 0, "burn_pct": 0.0, "burn_turns": 0, "charging": "", "charge_ready": false, "used": []}
	b.party_burn = {"dmg": 0, "turns": 0}
	b.roster = roster.duplicate()
	b._carry_extra = extra
	b._carry_uses = uses
	for ld in party:
		b.leaders.append(b._make_unit(ld))
	var hp := b._leaders_hp()
	b.party_max = b._max_hp_for(hp)
	b.party_hp = maxi(1, hp - damage)
	b.ap = int(b.db.battle["ap_start"]) - int(b.db.battle["ap_per_round"]) + int(mods.get("ap_start", 0))
	b.turn_limit = int(b.scenario["turn_limit"]) + int(mods.get("turns", 0))
	b.opening = []
	if ambush and mods.get("no_ambush", 0) > 0:
		b.opening.append("锦帆铃叮当一响——识破了埋伏！")
	elif ambush:
		b.opening = b._ambush()
	b.party_hp = mini(b.party_max, b.party_hp + int(round(b.party_max * float(mods.get("start_heal", 0.0)))))
	if mods.get("boost_start", 0) > 0:
		for u in b.leaders:
			u["boosted"] = true
		b.opening.append("战鼓擂响，全军 BOOST！")
	if mods.get("stun_start", 0) > 0:
		b.enemy["stunned"] = true
		b.opening.append("%s 盯着赤帻发愣——第一回合无法行动" % e["name"])
	b.opening.append_array(b._start_round())
	return b


func _make_unit(ld: Dictionary) -> Dictionary:
	## a leader's battle state; wear comes from this battle's bench, else from the quest's carry-over
	var cid: String = ld["card"]["id"]
	var st: Dictionary = bench_states.get(cid, {})
	var u_left := {}
	var u_extra := {}
	for s in ld["card"]["skills"]:
		u_left[s] = st["uses_left"].get(s, db.skills[s]["uses"]) if st.has("uses_left") else _carry_uses.get(cid, {}).get(s, db.skills[s]["uses"])
		u_extra[s] = st["extra_cost"].get(s, 0) if st.has("extra_cost") else _carry_extra.get(cid, {}).get(s, 0)
	return {"leader": ld, "uses_left": u_left, "extra_cost": u_extra, "acted": false,
		"idle_rounds": 0, "boosted": false, "confused": false, "confuse_next": false}


func _leaders_hp() -> int:
	var hp := 0
	for u in leaders:
		var ld: Dictionary = u["leader"]
		hp += int(round(ld["hp"] * (1.0 + float(mods.get("troop_hp", {}).get(ld["card"]["troop"], 0.0)))))
	return hp


func _max_hp_for(hp: int) -> int:
	return int(round(hp * (1.0 + float(mods.get("hp", 0.0)))))


# ---- 换人: tag a card of the same troop in mid-battle ------------------------------------

func swap_cost() -> int:
	return int(db.battle.get("swap_ap", 1))


func swap_options(i: int) -> Array:
	## leader dicts that could replace slot i: any troop (the slot takes the newcomer's troop), but never a troop another
	## slot already leads, never one already out, never two versions of one person; the lord has no stand-in
	if leaders[i]["leader"]["card"]["troop"] == "lord":
		return []
	var out_ids: Array = leaders.map(func(u): return u["leader"]["card"]["id"])
	var people := {}
	var troops := {}
	for k in leaders.size():
		if k != i:
			people[leaders[k]["leader"]["card"]["person"]] = true
			troops[leaders[k]["leader"]["card"]["troop"]] = true
	return roster.filter(func(ld): return not out_ids.has(ld["card"]["id"]) and not people.has(ld["card"]["person"]) \
			and not troops.has(ld["card"]["troop"]))


func swap_from_round() -> int:
	return int(db.battle.get("swap_from_round", 3))


func can_swap(i: int) -> bool:
	## a confused leader (or one about to be) cannot be pulled out: swapping is no way to shake the status
	return result == "" and not leaders[i]["confused"] and not leaders[i]["confuse_next"] and round_no >= swap_from_round() and ap >= swap_cost() and swaps_done < int(db.battle.get("swap_per_round", 1)) and not swap_options(i).is_empty()


func swap(i: int, card_id: String) -> Array:
	## pay swap_ap, put the card in slot i. The card that came off is out for the rest of the battle, the shared HP bar and the slot's
	## attack stay as they were, and (swap_ready) the newcomer can only act from the next round (swap_ready = true lets it act at once). Not before swap_from_round.
	var new_ld: Dictionary = {}
	for ld in swap_options(i):
		if ld["card"]["id"] == card_id:
			new_ld = ld
	assert(can_swap(i) and not new_ld.is_empty(), "cannot swap %s into slot %d" % [card_id, i])
	ap -= swap_cost()
	swaps_done += 1
	var old: Dictionary = leaders[i]
	var old_ld: Dictionary = old["leader"]
	bench_states[old_ld["card"]["id"]] = {"uses_left": old["uses_left"].duplicate(), "extra_cost": old["extra_cost"].duplicate()}
	var stand_in: Dictionary = new_ld.duplicate()  # the slot keeps its attack and HP: a swap changes who fights, not how hard
	stand_in["at"] = old_ld["at"]
	stand_in["hp"] = old_ld["hp"]
	var u := _make_unit(stand_in)
	u["confused"] = old["confused"]
	u["confuse_next"] = old["confuse_next"]
	u["acted"] = not bool(db.battle.get("swap_ready", false))  # by default the newcomer waits for next round
	leaders[i] = u
	roster.erase(new_ld)
	_ev({"t": "swap", "unit": i, "card": card_id, "hp": party_hp, "max": party_max})
	return ["%s 换下 %s%s" % [new_ld["card"]["name"], old_ld["card"]["name"], "（AP -%d）" % swap_cost() if swap_cost() > 0 else ""]]


func carry_out() -> Array:
	## [damage taken, 累积 increments, uses left] keyed by card id — for the next battle in a quest.
	var extra := {}
	var uses := {}
	for cid in bench_states:  # swapped out: the wear they were pulled out with
		extra[cid] = bench_states[cid]["extra_cost"].duplicate()
		var left := {}
		for s in bench_states[cid]["uses_left"]:
			if bench_states[cid]["uses_left"][s] != null:
				left[s] = bench_states[cid]["uses_left"][s]
		uses[cid] = left
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


func ap_max() -> int:
	return int(db.battle["ap_max"]) + int(mods.get("ap_max", 0))


func cost(u: Dictionary, sk: Dictionary) -> int:
	## troop_cost (孟德新书): that troop's skills cost less, but a paid skill never drops below 1 AP
	var c: int = sk["cost"] + u["extra_cost"][sk["id"]]
	var cut := int(mods.get("troop_cost", {}).get(u["leader"]["card"]["troop"], 0))
	return c if cut == 0 or sk["cost"] == 0 else maxi(1, c - cut)


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


func defend_cost() -> int:
	return int(db.battle.get("defend_ap", 0))


func can_defend() -> bool:
	return ap >= defend_cost()


func defend() -> Array:
	## like Rance X, guarding isn't free: it costs AP (battle.defend_ap), then ends the round with the damage cut
	if not can_defend():
		return ["AP 不够，无法防御（需要 %d）" % defend_cost()]
	ap -= defend_cost()
	var cuts: Array = db.battle["defend_cuts"]
	var cut: float = minf(0.95, float(cuts[mini(defend_streak, cuts.size() - 1)]) + float(mods.get("defend", 0.0)))
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


func _dmg(base: float, kind: String, pierce := false) -> int:
	## pierce (弓兵 穿甲): this hit ignores the enemy's resist altogether
	var data: Dictionary = enemy["data"]
	var resist: float = data["phys_resist"] if kind == "attack" else data["magic_resist"]
	resist *= 0.0 if pierce else 1.0 - minf(1.0, float(mods.get("pierce", 0.0)))
	var d: float = base * (1.0 + (float(db.battle["combo_bonus"]) + float(mods.get("combo", 0.0))) * combo) * (1.0 + enemy["break_amount"]) * (1.0 - resist)
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
				var bonus := float(mods.get("at", 0.0)) + float(mods.get("troop_at", {}).get(u["leader"]["card"]["troop"], 0.0)) + float(buff["atk"])
				if kind == "magic":
					bonus += float(mods.get("magic", 0.0))
				if party_hp * 2 < party_max:
					bonus += float(mods.get("desperate", 0.0))
				if not first_hit_done:  # 七星宝刀
					bonus += float(mods.get("first_hit", 0.0))
					first_hit_done = true
				var fire := float(eff.get("burning_mult", 1.0)) if enemy["burn_turns"] > 0 else 1.0  # 火上浇油
				var power: float = float(eff["power"]) + float(eff.get("per_combo", 0.0)) * combo  # 收尾 (骑兵)
				var d := _dmg(at * power * mult * (1.0 + bonus) * fire, kind, bool(eff.get("pierce", false)))
				if d > enemy["hp"]:
					overkill = float(d - enemy["hp"]) / enemy["max_hp"]
				enemy["hp"] = maxi(0, enemy["hp"] - d)
				combo += 1
				_ev({"t": "hit", "dmg": d, "combo": combo, "kind": kind, "hp": enemy["hp"], "pierce": bool(eff.get("pierce", false))})
				log.append("  %s 受到 %d 伤害（%d 连击）" % [ename, d, combo])
			return log
		"heal":
			var amt := mini(int(round(at * float(eff["power"]) * mult * (1.0 + float(mods.get("heal", 0.0))))),
				party_max - party_hp)
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
			if eff["target"] == "random_idle":  # 鼓舞一个还没出手的友军
				var idle: Array = leaders.filter(func(t): return t != u and not t["acted"] and not t["boosted"] and not t["confused"])
				if idle.is_empty():
					return ["  没有可以鼓舞的人"]
				var pick: Dictionary = idle[rng.randi_range(0, idle.size() - 1)]
				pick["boosted"] = true
				_ev({"t": "boost", "units": [leaders.find(pick)]})
				return ["  %s 受到鼓舞，进入 BOOST（下次行动 ×%s）" % [unit_name(pick), bm]]
			u["boosted"] = true
			_ev({"t": "boost", "units": [leaders.find(u)]})
			return ["  %s 进入 BOOST（下次行动 ×%s）" % [unit_name(u), bm]]
		"stun":
			if rng.randf() < float(eff["chance"]) + float(mods.get("stun", 0.0)):
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
		"burn":  # 火攻: the enemy loses HP before each of its turns; one fire at a time — a new one keeps the bigger, restarts the count
			# "pct": a share of the enemy's CURRENT HP each turn (so it eases off as it burns); "power": a flat amount,
			# × the caster's attack (magic resist applies). Either way the fire never takes the last HP.
			var bonus := float(mods.get("at", 0.0)) + float(mods.get("magic", 0.0))
			var resist: float = enemy["data"]["magic_resist"] * (1.0 - minf(1.0, float(mods.get("pierce", 0.0))))
			enemy["burn_turns"] = maxi(enemy["burn_turns"], int(eff["turns"]))
			if eff.has("pct"):
				enemy["burn_pct"] = maxf(enemy["burn_pct"], float(eff["pct"]) * mult)
				_ev({"t": "burn_on", "pct": enemy["burn_pct"], "turns": enemy["burn_turns"]})
				return ["  %s 陷入灼烧！每回合烧掉现有体力的 %d%%（%d 回合）" % [ename, int(round(enemy["burn_pct"] * 100)), enemy["burn_turns"]]]
			var per := maxi(1, int(round(at * float(eff.get("power", 0.0)) * mult * (1.0 + bonus) * (1.0 - resist))))
			enemy["burn_dmg"] = maxi(enemy["burn_dmg"], per)
			_ev({"t": "burn_on", "dmg": enemy["burn_dmg"], "turns": enemy["burn_turns"]})
			return ["  %s 陷入灼烧！每回合结算 -%d（%d 回合）" % [ename, enemy["burn_dmg"], enemy["burn_turns"]]]
		"counter":  # 反击: until the round ends, every hit the enemy lands is answered with ×power of this leader's attack
			counters.append({"name": unit_name(u), "at": at * mult, "power": float(eff["power"])})
			return ["  %s 架起拒马：本回合敌人每打中一次，还击 ×%s" % [unit_name(u), str(eff["power"])]]
		"buff":  # 战意: +1 layer (up to max) of attack and damage-taken cut for the whole party; recasting refreshes the timer
			if buff["layers"] < int(eff.get("max", 4)):
				buff["layers"] += 1
				buff["atk"] += float(eff.get("atk", 0.0))
				buff["def"] += float(eff.get("def", 0.0))
			buff["turns"] = int(eff.get("turns", 3))
			_ev({"t": "buff", "layers": buff["layers"], "atk": buff["atk"], "def": buff["def"]})
			return ["  战意 ×%d：全军攻击 +%d%%，受到伤害 -%d%%（%d 回合）" % [buff["layers"], int(round(buff["atk"] * 100)), int(round(buff["def"] * 100)), buff["turns"]]]
		"cleanse":  # 解状态: confusion, the enemy's fire on us and the AP it drained are all lifted
			var n := 0
			for t in leaders:
				if t["confused"] or t["confuse_next"]:
					n += 1
				t["confused"] = false
				t["confuse_next"] = false
			if party_burn["turns"] > 0:
				n += 1
				party_burn = {"dmg": 0, "turns": 0}
			if ap_drain > 0:
				n += 1
				ap_drain = 0
			_ev({"t": "cleanse", "n": n})
			return ["  我军的异常状态解除了" if n > 0 else "  没有需要解除的状态"]
		"hurt":  # 苦肉: the party pays a share of its max HP (never to death)
			var lost := clampi(int(round(party_max * float(eff["pct"]))), 0, party_hp - 1)
			party_hp -= lost
			_ev({"t": "hurt", "dmg": lost, "hp": party_hp})
			return ["  我军折损 %d 体力" % lost]
		"ap":
			ap = mini(ap_max(), ap + int(eff["amount"]))
			_ev({"t": "ap", "amount": int(eff["amount"]), "ap": ap})
			return ["  AP +%d" % int(eff["amount"])]
	assert(false, "unknown effect " + kind)
	return []


func _enemy_phase(defend_cut: float) -> Array:
	if result != "":
		return []
	var data: Dictionary = enemy["data"]
	var log: Array = []
	if enemy["burn_turns"] > 0:
		enemy["burn_turns"] -= 1
		var d: int = clampi(maxi(enemy["burn_dmg"], int(round(enemy["hp"] * enemy["burn_pct"]))), 0, enemy["hp"] - 1)  # never lethal
		enemy["hp"] -= d
		_ev({"t": "burn", "dmg": d, "hp": enemy["hp"], "turns": enemy["burn_turns"]})
		log.append("%s 灼烧结算，损失 %d 体力" % [data["name"], d])
		if enemy["burn_turns"] == 0:
			enemy["burn_dmg"] = 0
			enemy["burn_pct"] = 0.0
		_check_end()
		if result != "":
			return log
	if party_burn["turns"] > 0:
		party_burn["turns"] -= 1
		party_hp = maxi(0, party_hp - party_burn["dmg"])
		_ev({"t": "enemy_hit", "dmg": party_burn["dmg"], "move": "火", "cut": 0.0, "hp": party_hp})
		log.append("[color=red]我军被火烧，损失 %d 体力[/color]" % party_burn["dmg"])
		_check_end()
		if result != "":
			return log
	_ev({"t": "enemy_turn"})
	log.append("—— %s 的行动 ——" % data["name"])
	if enemy.get("regen", 0.0) > 0.0 and enemy["hp"] < enemy["max_hp"]:  # 词缀·再生
		var h := mini(int(round(enemy["max_hp"] * enemy["regen"])), enemy["max_hp"] - enemy["hp"])
		enemy["hp"] += h
		_ev({"t": "enemy_heal", "amt": h, "hp": enemy["hp"]})
		log.append("[color=red]  %s 再生，回复 %d 体力[/color]" % [data["name"], h])
	enemy["charge_ready"] = enemy["charging"] != ""  # wound up last turn: it lands now
	var was_stunned: bool = enemy["stunned"]
	if enemy["stunned"]:
		enemy["stunned"] = false
		_ev({"t": "enemy_stunned"})
		log.append("%s 混乱中，无法行动" % data["name"])
	else:
		var cut := 1.0 - (1.0 - guard_cut) * (1.0 - defend_cut) * (1.0 - float(mods.get("guard", 0.0))) * (1.0 - minf(0.9, float(buff["def"])))
		for _a in int(data["actions"]):
			var mv := _enemy_move()
			if mv.has("charge"):  # winds up: next turn opens with the big one
				enemy["charging"] = mv["charge"]
				_ev({"t": "enemy_charge", "move": mv["charge"]})
				log.append("[color=red]%s 正在蓄力……下回合【%s】！[/color]" % [data["name"], mv["charge"]])
				continue  # the wind-up costs this action only
			if mv.get("once", false):
				enemy["used"].append(mv["name"])
			if float(mv["power"]) > 0.0:
				var c: float = 0.0 if mv.get("pierce", false) else cut
				var d := maxi(1, int(round(enemy["at"] * float(mv["power"]) * _variance() * (1.0 - c))))
				party_hp = maxi(0, party_hp - d)
				_ev({"t": "enemy_hit", "dmg": d, "move": mv["name"], "cut": c, "hp": party_hp})
				log.append("%s【%s】 我军受到 %d 伤害%s%s" % [data["name"], mv["name"], d,
					("（减伤 %d%%）" % int(round(c * 100))) if c > 0.0 else "", "（无视防御！）" if mv.get("pierce", false) else ""])
				if party_hp > 0:
					log.append_array(_counter_strike())
			else:
				log.append("%s【%s】" % [data["name"], mv["name"]])
			if mv.has("rage"):
				enemy["at"] *= 1.0 + float(mv["rage"])
				_ev({"t": "enemy_rage", "amount": float(mv["rage"])})
				log.append("[color=red]  %s 狂暴了！攻击 +%d%%[/color]" % [data["name"], int(round(float(mv["rage"]) * 100))])
			if mv.has("heal"):
				var h := mini(int(round(enemy["max_hp"] * float(mv["heal"]))), enemy["max_hp"] - enemy["hp"])
				enemy["hp"] += h
				_ev({"t": "enemy_heal", "amt": h, "hp": enemy["hp"]})
				log.append("  %s 回复了 %d 体力" % [data["name"], h])
			if mv.has("ap_drain"):
				ap_drain += int(mv["ap_drain"])
				log.append("[color=red]  下回合我军 AP -%d[/color]" % int(mv["ap_drain"]))
			if mv.has("burn_party"):
				party_burn = {"dmg": int(round(party_max * float(mv["burn_party"]))), "turns": int(mv.get("turns", 3))}
				log.append("[color=red]  我军陷入灼烧！每回合 -%d（%d 回合）[/color]" % [party_burn["dmg"], party_burn["turns"]])
			if mv.has("confuse") and mods.get("calm", 0) <= 0 and rng.randf() < float(mv["confuse"]):
				var victim: Dictionary = leaders[rng.randi_range(0, leaders.size() - 1)]
				victim["confuse_next"] = true
				_ev({"t": "confuse", "unit": leaders.find(victim)})
				log.append("  %s 陷入混乱，下回合无法行动" % unit_name(victim))
			_check_end()
			if result != "":
				return log
	if not was_stunned and result == "":
		log.append_array(_affix_status())
	if enemy["break_turns"] > 0:
		enemy["break_turns"] -= 1
		if enemy["break_turns"] == 0:
			enemy["break_amount"] = 0.0
	if round_no >= turn_limit:
		result = "lose"
		log.append("已到第 %d 回合上限 —— 撤退！" % round_no)
		return log
	log.append_array(_start_round())
	return log


func _affix_status() -> Array:
	## 词缀 that put a status on us every time the elite / boss acts (cards.json battle.affixes: confuse, burn_party, ap_drain)
	var afx: Dictionary = mods.get("affix", {})
	var log: Array = []
	var nm := str(afx.get("name", ""))
	if afx.has("confuse") and mods.get("calm", 0) <= 0 and rng.randf() < float(afx["confuse"]):
		var victim: Dictionary = leaders[rng.randi_range(0, leaders.size() - 1)]
		victim["confuse_next"] = true
		_ev({"t": "confuse", "unit": leaders.find(victim)})
		log.append("[color=red]  【%s】%s 陷入混乱，下回合无法行动[/color]" % [nm, unit_name(victim)])
	if afx.has("burn_party"):
		var dmg := int(round(party_max * float(afx["burn_party"])))
		if party_burn["turns"] == 0 or dmg > party_burn["dmg"]:
			party_burn = {"dmg": dmg, "turns": int(afx.get("turns", 3))}
			log.append("[color=red]  【%s】我军灼烧！每回合 -%d（%d 回合）[/color]" % [nm, dmg, party_burn["turns"]])
	if afx.has("ap_drain"):
		ap_drain += int(afx["ap_drain"])
		log.append("[color=red]  【%s】下回合我军 AP -%d[/color]" % [nm, int(afx["ap_drain"])])
	return log


func _counter_strike() -> Array:
	## 反击: answer one enemy hit with every counter set up this round
	var log: Array = []
	for c in counters:
		if enemy["hp"] <= 0:
			break
		var d := _dmg(float(c["at"]) * float(c["power"]) * (1.0 + float(buff["atk"])), "attack")
		enemy["hp"] = maxi(0, enemy["hp"] - d)
		_ev({"t": "counter", "unit": c["name"], "dmg": d, "hp": enemy["hp"]})
		log.append("  %s 反击，造成 %d 伤害" % [c["name"], d])
	_check_end()
	return log


func _ambush() -> Array:
	## 埋伏: every enemy action lands once before the party can move (never kills outright).
	var data: Dictionary = enemy["data"]
	var log: Array = ["[color=red]埋伏！%s 抢先出手[/color]" % data["name"]]
	for _a in int(data["actions"]):
		var mv: Dictionary = data["moves"][0]
		var d := maxi(1, int(round(enemy["at"] * float(mv["power"]) * _variance() * (1.0 - float(mods.get("guard", 0.0))))))
		party_hp = maxi(1, party_hp - d)
		_ev({"t": "enemy_hit", "dmg": d, "move": mv["name"], "cut": 0.0, "hp": party_hp})
		log.append("%s【%s】 我军受到 %d 伤害" % [data["name"], mv["name"], d])
	return log


func _enemy_move() -> Dictionary:
	## A charged move first; otherwise a weighted pick among the moves allowed now.
	var moves: Array = enemy["data"]["moves"]
	if enemy["charging"] != "" and enemy["charge_ready"]:
		enemy["charge_ready"] = false
		var name: String = enemy["charging"]
		enemy["charging"] = ""
		for m in moves:
			if m["name"] == name:
				return m
	var ok: Array = moves.filter(func(m):
		return float(m["weight"]) > 0.0 \
			and not (m.get("when", "") == "half" and enemy["hp"] * 2 >= enemy["max_hp"]) \
			and not (m.get("once", false) and enemy["used"].has(m["name"])) 			and not (m.has("charge") and enemy["charging"] != ""))
	return GameData.weighted_pick(rng, ok, ok.map(func(m): return float(m["weight"])))


func _start_round() -> Array:
	var cfg := db.battle
	if round_no > 0:
		for u in leaders:
			if not u["acted"]:
				u["idle_rounds"] += 1
	round_no += 1
	ap = mini(ap_max(), ap + int(cfg["ap_per_round"]) + int(mods.get("ap_round", 0)))
	if ap_drain > 0:
		_ev({"t": "ap_drain", "amount": mini(ap_drain, ap), "ap": maxi(0, ap - ap_drain)})
		ap = maxi(0, ap - ap_drain)
		ap_drain = 0
	combo = 0
	guard_cut = 0.0
	counters = []
	swaps_done = 0
	if buff["turns"] > 0:
		buff["turns"] -= 1
		if buff["turns"] == 0:
			buff = {"layers": 0, "turns": 0, "atk": 0.0, "def": 0.0}
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
