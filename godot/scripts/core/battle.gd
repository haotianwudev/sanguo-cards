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
var guarded_this_round := false  # a 防御 skill was played this round: the round counts as a defend for the 连续防御 streak (user rule)
var result := ""  # "" | "win" | "lose"
var lose_reason := ""  # why it was lost: "wiped" (party HP gone) | "turns" (round limit up, HP left) | "retreat"
var overkill := 0.0  # excess damage on the killing blow, as a share of the enemy's max HP
var opening: Array = []  # log lines from the first round start
var mods: Dictionary = {}  # 宝物 / 险 (see cards.json relics) + enemy (险: enemy strength)
var turn_limit := 0
var first_hit_done := false
var loot_chest := 0.0  # 劫掠: chance of a second chest after this win, +chest per use
var loot_card := 0.0  # 劫掠: chance of one more card to pick from in the chests, +card per use
var party_burn := {}  # the enemy's fire on us: {dmg, turns}
var party_poison := {}  # the enemy's poison on us: {layers, pct (of our MAX HP a layer a turn), turns}
var ap_drain := 0  # AP the enemy takes away at the next round start
var roster: Array = []  # leader dicts that can be tagged in mid-battle (SaveData.swap_roster): any owned card not leading
var bench_states: Dictionary = {}  # card id -> {uses_left, extra_cost}: the skill state of cards swapped out (only handed on to the next fight)
var swaps_done := 0  # this round
var _carry_extra: Dictionary = {}
var _carry_uses: Dictionary = {}
var buff := {"layers": 0, "turns": 0, "atk": 0.0, "def": 0.0, "magic": 0.0}  # 战意 (军师): stacked layers, rounds left, summed attack bonus / damage cut / magic rider on physical blows
var seal := {}  # 封技 on us: {name, kind (ultimate / magic / attack), turns (player rounds left)}
var _absorbed := 0  # what the 护盾 soaked up of the last blow put down
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
	e = Quests.with_armor(e, str(mods.get("armor", "")))  # a late elite / boss's 护甲 (battle.late_armor)
	var afx: Dictionary = mods.get("affix", {})  # 词缀 on an elite / boss (see Quests.affix_here)
	e["phys_resist"] = minf(0.8, float(e["phys_resist"]) + float(afx.get("phys_resist", 0.0)))
	e["magic_resist"] = minf(0.8, float(e["magic_resist"]) + float(afx.get("magic_resist", 0.0)))
	e["actions"] = int(e["actions"]) + int(afx.get("actions", 0))
	var tough := (1.0 + float(mods.get("enemy", 0.0))) * float(mods.get("enemy_scale", 1.0))
	var tough_at := (1.0 + float(mods.get("enemy", 0.0))) * float(mods.get("enemy_scale_at", mods.get("enemy_scale", 1.0)))  # attack grows only by the root of the tier coefficient
	var unit: Dictionary = b.db.battle.get("unit", {"hp": 1.0, "at": 1.0})  # the enemy table is in the old magnitude; cards are in card-face numbers
	e["hp"] = float(e["hp"]) / float(unit["hp"])
	e["at"] = float(e["at"]) / float(unit["at"])
	var max_hp := int(round(e["hp"] * float(b.db.battle.get("enemy_hp_mult", 1.0)) * float(b.db.battle.get("hp_mult", 1.0)) * tough * (1.0 + float(afx.get("hp", 0.0)))
		* (1.0 + float(b.db.battle["enemy_hp_per_extra_leader"]) * (party.size() - 1))))
	b.enemy = {"data": e, "hp": max_hp, "max_hp": max_hp, "at": e["at"] * float(b.db.battle.get("attack_mult", 1.0)) * tough_at * (1.0 + float(afx.get("at", 0.0))),
		"regen": float(afx.get("regen", 0.0)), "stunned": false,
		"break_amount": 0.0, "break_turns": 0, "resist_down": 0.0, "resist_turns": 0, "burn_dmg": 0, "burn_pct": 0.0, "burn_turns": 0, "poison": 0, "poison_pct": 0.0, "poison_turns": 0, "charging": "", "charge_ready": false, "used": [],
		"intents": [], "stance": {}, "guard": {},
		"mark": {}, "shield": {}, "form": {}}  # v3: this round's planned moves (意图), 反击架势 {name, power, turns}, 前卫 {name, hp, max_hp, strike};
		# 点名 {card, who, move}, 护盾 {name, hp, max_hp}, 阵 {name, vs (attack / magic), cut, turns}
	b.party_burn = {"dmg": 0, "turns": 0}
	b.party_poison = {"layers": 0, "pct": 0.0, "turns": 0}
	b.roster = roster.duplicate()
	b._carry_extra = extra
	b._carry_uses = uses
	for ld in party:
		b.leaders.append(b._make_unit(ld))
	var hp := b._leaders_hp()
	b.party_max = b._max_hp_for(hp)
	b.party_hp = maxi(1, hp - damage)
	b.ap = int(b.db.battle["ap_start"]) - int(b.db.battle["ap_per_round"]) + int(mods.get("ap_start", 0))
	b.turn_limit = turns_for(b.db, b.scenario, str(mods.get("enemy_tier", ""))) + int(mods.get("turns", 0))
	b.opening = []
	if ambush and mods.get("no_ambush", 0) > 0:
		b.opening.append("锦帆铃叮当一响——识破了埋伏！")
	elif ambush:
		b.opening = b._ambush()
	b.party_hp = mini(b.party_max, b.party_hp + int(round(b.party_max * float(mods.get("start_heal", 0.0)) * float(b.db.battle.get("heal_mult", 1.0)))))
	if mods.get("boost_start", 0) > 0:
		for u in b.leaders:
			u["boosted"] = true
		b.opening.append("战鼓擂响，全军 BOOST！")
	var daze := float(mods.get("stun_start", 0.0))  # 赤帻: a chance, not a sure thing (roll only when held, so other fights keep their dice)
	if daze > 0.0 and b.rng.randf() < daze:
		b.enemy["stunned"] = true
		b.opening.append("%s 盯着赤帻发愣——第一回合无法行动" % e["name"])
	b.opening.append_array(b._start_round())
	return b


static func turns_for(gd: GameData, sc: Dictionary, tier: String) -> int:
	## a fight's round limit: the scenario's own + battle.turn_bonus (every fight) + battle.tier_extra_turns[tier] (精英 / 首领); 宝物 come on top
	return int(sc["turn_limit"]) + int(gd.battle.get("turn_bonus", 0)) + int(gd.battle.get("tier_extra_turns", {}).get(tier, 0))


func _make_unit(ld: Dictionary) -> Dictionary:
	## a leader's battle state; wear comes from this battle's bench, else from the quest's carry-over
	var cid: String = ld["card"]["id"]
	var st: Dictionary = bench_states.get(swap_key(ld), {})
	var u_left := {}
	var u_extra := {}
	for s in ld["card"]["skills"]:
		if db.skills[s]["per_battle"]:  # 每场限 1 次: fresh every fight (a swap within the fight keeps what the bench saved)
			u_left[s] = st["uses_left"].get(s, 1) if st.has("uses_left") else 1
		elif st.has("uses_left"):
			u_left[s] = st["uses_left"].get(s, db.skills[s]["uses"])
		else:
			u_left[s] = _carry_uses.get(cid, {}).get(s, db.skills[s]["uses"])
		u_extra[s] = st["extra_cost"].get(s, 0) if st.has("extra_cost") else _carry_extra.get(cid, {}).get(s, 0)
	return {"leader": ld, "uses_left": u_left, "extra_cost": u_extra, "acted": false,
		"idle_rounds": 0, "boosted": false, "confused": false, "confuse_next": false, "slain": false}  # slain: 点名 landed on him — grey, out of action this fight (swap him out)


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


static func swap_key(ld: Dictionary) -> String:
	## what a 换人 candidate is called: its card id, or lordform:<form> (base = the plain lord) for a lord card — every lord card has the id "lord"
	var c: Dictionary = ld["card"]
	if str(c["troop"]) == "lord":
		return "lordform:" + (str(c.get("form", "")) if str(c.get("form", "")) != "" else "base")
	return str(c["id"])


func swap_options(i: int) -> Array:
	## leader dicts that could replace slot i: any troop (the slot takes the newcomer's troop), but never a troop another
	## slot already leads, never one already out, never two versions of one person; the lord swaps for another of his lord cards (user call)
	if leaders[i]["leader"]["card"]["troop"] == "lord":
		var here := swap_key(leaders[i]["leader"])
		return roster.filter(func(ld): return str(ld["card"]["troop"]) == "lord" and swap_key(ld) != here)
	var out_ids: Array = leaders.map(func(u): return u["leader"]["card"]["id"])
	var people := {}
	var troops := {}
	for k in leaders.size():
		if k != i:
			people[leaders[k]["leader"]["card"]["person"]] = true
			troops[leaders[k]["leader"]["card"]["troop"]] = true
	return roster.filter(func(ld): return str(ld["card"]["troop"]) != "lord" and not out_ids.has(ld["card"]["id"]) and not people.has(ld["card"]["person"]) \
			and not troops.has(ld["card"]["troop"]))


func swap_from_round() -> int:
	return int(db.battle.get("swap_from_round", 3))


func can_swap(i: int) -> bool:
	## a confused leader (or one about to be) cannot be pulled out: swapping is no way to shake the status
	## and only a leader who has not acted this round: the newcomer may act at once, so an acted slot would get two turns
	return result == "" and not leaders[i]["acted"] and not leaders[i]["confused"] and not leaders[i]["confuse_next"] and round_no >= swap_from_round() and ap >= swap_cost() and swaps_done < int(db.battle.get("swap_per_round", 1)) and not swap_options(i).is_empty()


func swap(i: int, card_id: String) -> Array:
	## pay swap_ap, put the card in slot i. The card that came off is out for the rest of the battle; the slot fights with the
	## newcomer's own attack and unit (his troop), the shared HP bar resizes and keeps its share (50 % stays 50 %), and (swap_ready)
	## the newcomer can only act from the next round (swap_ready = true lets it act at once). Not before swap_from_round.
	var new_ld: Dictionary = {}
	for ld in swap_options(i):
		if swap_key(ld) == card_id:
			new_ld = ld
	assert(can_swap(i) and not new_ld.is_empty(), "cannot swap %s into slot %d" % [card_id, i])
	ap -= swap_cost()
	swaps_done += 1
	var old: Dictionary = leaders[i]
	var old_ld: Dictionary = old["leader"]
	bench_states[swap_key(old_ld)] = {"uses_left": old["uses_left"].duplicate(), "extra_cost": old["extra_cost"].duplicate()}
	if str(old_ld["card"]["troop"]) == "lord" and not old.get("slain", false):
		roster.append(old_ld)  # a lord card swapped out can come back (he never leaves the field, only changes card)
	var u := _make_unit(new_ld)  # the newcomer's own attack and unit
	var share := float(party_hp) / maxf(1.0, float(party_max))
	var was_max := party_max
	u["confused"] = old["confused"]
	u["confuse_next"] = old["confuse_next"]
	u["acted"] = not bool(db.battle.get("swap_ready", false))  # by default the newcomer waits for next round
	leaders[i] = u
	roster.erase(new_ld)
	party_max = _max_hp_for(_leaders_hp())  # the bar resizes with who is out, keeping its share
	party_hp = clampi(int(round(share * party_max)), 1, party_max)
	if party_max != was_max:
		party_burn["dmg"] = int(round(int(party_burn.get("dmg", 0)) * float(party_max) / maxf(1.0, float(was_max))))  # a burn on the bar is a share of it too
	_ev({"t": "swap", "unit": i, "card": card_id, "hp": party_hp, "max": party_max})
	var log: Array = ["%s 换下 %s%s" % [new_ld["card"]["name"], old_ld["card"]["name"], "（AP -%d）" % swap_cost() if swap_cost() > 0 else ""]]
	log.append_array(_entry_trick(i))
	_check_end()
	return log


func _entry_trick(k: int) -> Array:
	## 登场: the newcomer's troop trick fires for sure — the same trick and formula as the small per-round chance (`_troop_trick` / `_raid`),
	## the spear's is a sure counter for the rest of this round
	var u: Dictionary = leaders[k]
	match str(u["leader"]["card"]["troop"]):
		"cavalry":
			return _raid(k, "登场！")
		"spear":
			u["sure_counter"] = true
			_ev({"t": "passive", "unit": k, "name": unit_name(u), "text": "严阵以待"})
			return ["登场！%s 严阵以待：本回合敌人每打中一次必定还击" % unit_name(u)]
		_:
			var log := _troop_trick(k)
			return log.map(func(l): return "登场！" + str(l).strip_edges())


func carry_out() -> Array:
	## [damage taken, 累积 increments, uses left] keyed by card id — for the next battle in a quest.
	var extra := {}
	var uses := {}
	for cid in bench_states:  # swapped out: the wear they were pulled out with
		if str(cid).begins_with("lordform:"):
			continue  # a lord card swapped out: the lord's wear is the card in use at the end (keyed "lord")
		extra[cid] = bench_states[cid]["extra_cost"].duplicate()
		var left := {}
		for s in bench_states[cid]["uses_left"]:
			if bench_states[cid]["uses_left"][s] != null and not db.skills[s]["per_battle"]:
				left[s] = bench_states[cid]["uses_left"][s]
		uses[cid] = left
	for u in leaders:
		var cid: String = u["leader"]["card"]["id"]
		extra[cid] = u["extra_cost"].duplicate()
		var left := {}
		for s in u["uses_left"]:
			if u["uses_left"][s] != null and not db.skills[s]["per_battle"]:  # 每场限 1 次 doesn't carry
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


func sealed(sk: Dictionary) -> bool:
	## 封技: the enemy has locked this kind of skill for the round (ultimate = 大招, magic = any magic / fire / poison, attack = any physical blow)
	if seal.is_empty():
		return false
	var types: Array = sk["effects"].map(func(e): return e["type"])
	match str(seal["kind"]):
		"ultimate":
			return is_ult(sk)
		"magic":
			return types.has("magic") or types.has("burn") or types.has("poison")
		"attack":
			return types.has("attack")
	return false


static func is_ult(sk: Dictionary) -> bool:
	return sk.get("uses") != null or sk.get("per_battle", false)


static func play_effects(sk: Dictionary) -> Array:
	## the effects a skill really plays: one with a 眩晕 (any chance) breaks a wind-up for sure (battle.stun_interrupts, user rule 2026-11-07),
	## so an 打断 goes in just before its first stun when it has none of its own
	var effs: Array = sk.get("effects", [])
	if not bool(GameData.get_db().battle.get("stun_interrupts", false)) or effs.any(func(e): return e["type"] == "interrupt"):
		return effs
	var at := -1
	for k in effs.size():
		if effs[k]["type"] == "stun":
			at = k
			break
	if at < 0:
		return effs
	var out := effs.duplicate()
	out.insert(at, {"type": "interrupt"})
	return out


static func can_interrupt(sk: Dictionary) -> bool:
	return play_effects(sk).any(func(e): return e["type"] == "interrupt")


func usable(u: Dictionary, sk: Dictionary) -> bool:
	if sealed(sk):
		return false
	var left: Variant = u["uses_left"][sk["id"]]
	if left != null and left == 0:
		return false
	return cost(u, sk) <= ap


func can_act(i: int) -> bool:
	var u: Dictionary = leaders[i]
	if result != "" or u["acted"] or u["confused"] or u.get("slain", false):
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
	for eff in play_effects(sk):
		if eff["type"] == "interrupt" and enemy["charging"] == "" and not sk["effects"].has(eff):
			continue  # the 眩晕's own 打断 says nothing when there is no wind-up
		if enemy["hp"] <= 0 and eff["type"] != "loot":
			continue  # that blow ended it: the rest of the skill never happens (only 劫掠's odds, they count towards the win)
		log.append_array(_apply(u, eff, mult))
	if enemy["hp"] > 0 and sk["effects"].any(func(e): return e["type"] == "attack"):
		log.append_array(_stance_strike(i))  # 反击架势: a physical skill is answered once
	_check_end()
	return log


func end_round() -> Array:
	defend_streak = defend_streak + 1 if guarded_this_round else 0  # a round with a 防御 skill keeps the 连续防御 going
	return _enemy_phase(0.0)


func defend_cut() -> float:
	## what the 防御 button cuts now: battle.defend_cuts by the 连续防御 streak (+ 宝物)
	var cuts: Array = db.battle["defend_cuts"]
	return minf(0.95, float(cuts[mini(defend_streak, cuts.size() - 1)]) + float(mods.get("defend", 0.0)))


func streak_bonus() -> float:
	## 连续防御 lifts 防御 skills too: the streak's step over the first defend (0 / +10% / +20% / +30% with the default cuts)
	var cuts: Array = db.battle["defend_cuts"]
	return float(cuts[mini(defend_streak, cuts.size() - 1)]) - float(cuts[0])


func defend_cost() -> int:
	return int(db.battle.get("defend_ap", 0))


func can_defend() -> bool:
	return ap >= defend_cost()


func defend() -> Array:
	## like Rance X, guarding isn't free: it costs AP (battle.defend_ap), then ends the round with the damage cut
	if not can_defend():
		return ["AP 不够，无法防御（需要 %d）" % defend_cost()]
	ap -= defend_cost()
	var cut := defend_cut()
	defend_streak += 1
	_ev({"t": "defend", "cut": cut})
	var log: Array = ["全军防御（伤害 -%d%%）" % int(round(cut * 100))]
	log.append_array(_enemy_phase(cut))
	return log


func retreat() -> Array:
	result = "lose"
	lose_reason = "retreat"
	return ["全军撤退！"]


# ---- v3: 追击 / 必暴 / 前卫 / 反击架势 ------------------------------------------------

func enemy_state(cond: String) -> bool:
	## the enemy conditions skills (vs / crit_if) and 军令 read
	match cond:
		"broken":
			return int(enemy["break_turns"]) > 0
		"burning":
			return int(enemy["burn_turns"]) > 0
		"poisoned":
			return int(enemy["poison_turns"]) > 0
		"stunned":
			return bool(enemy["stunned"])
		"charging":
			return str(enemy["charging"]) != ""
		"guarded":
			return not enemy["guard"].is_empty()
		"stance":
			return not enemy["stance"].is_empty()
		"marking":
			return not enemy["mark"].is_empty()
		"shielded":
			return not enemy["shield"].is_empty()
		"formation":
			return not enemy["form"].is_empty()
	return false


func vs_mult(eff: Dictionary) -> float:
	## 追击: `vs` {condition: ×} multiplies the blow for every condition that holds; the old `burning_mult` reads as vs.burning
	var m := 1.0
	var vs: Dictionary = eff.get("vs", {})
	if eff.has("burning_mult") and not vs.has("burning"):
		vs = vs.duplicate()
		vs["burning"] = eff["burning_mult"]
	for cond in vs:
		if enemy_state(str(cond)):
			m *= float(vs[cond])
	return m


func crit_if_holds(eff: Dictionary) -> bool:
	return eff.has("crit_if") and enemy_state(str(eff["crit_if"]))


func guard_takes(kind: String, pierce: bool) -> bool:
	## 前卫 (summon) in the way: a plain physical blow lands on it; magic and 穿甲 go over it to the boss
	return not enemy["guard"].is_empty() and kind == "attack" and not pierce


func _land(d: int, kind: String, pierce: bool) -> int:
	## put a computed blow on whoever takes it (the 前卫, or the enemy itself); returns the damage dealt
	if guard_takes(kind, pierce):
		var g: Dictionary = enemy["guard"]
		var dealt := mini(d, int(g["hp"]))
		g["hp"] = int(g["hp"]) - dealt
		_ev({"t": "guard_hit", "dmg": dealt, "hp": g["hp"], "max": g["max_hp"]})
		if int(g["hp"]) <= 0:
			_ev({"t": "guard_down", "name": g["name"]})
			enemy["guard"] = {}
		return dealt
	_absorbed = 0
	if shield_takes(kind):  # 护盾 (user rule): a 兵刃 blow that can't break it is swallowed whole; one that breaks it lands in full, as if no shield
		var s: Dictionary = enemy["shield"]
		if d >= int(s["hp"]):
			s["hp"] = 0
		else:
			_absorbed = d
			s["hp"] = int(s["hp"]) - d
			d = 0
		s["hit"] = true  # touched this round: no 回盾 at the round's end
		_ev({"t": "shield_hit", "dmg": _absorbed, "hp": s["hp"], "max": s["max_hp"]})
		if int(s["hp"]) <= 0:
			_ev({"t": "shield_down", "name": s["name"]})
			enemy["shield"] = {}
	enemy["hp"] = maxi(0, int(enemy["hp"]) - d)
	return d


func shield_takes(kind: String) -> bool:
	## 护盾: every 兵刃 blow (穿甲, 弓兵 and 大招 included) meets it; only 谋略 goes over it (user rule 2026-11-07)
	return not enemy["shield"].is_empty() and kind == "attack"


func _player_cut() -> float:
	## our whole damage cut this round outside a defend: guards, 宝物, 战意
	return 1.0 - (1.0 - guard_cut) * (1.0 - float(mods.get("guard", 0.0))) * (1.0 - minf(0.9, float(buff["def"])))


func _stance_strike(k: int) -> Array:
	## 反击架势: the enemy answers a physical skill with one blow of power × its attack (our guards cut it)
	if enemy["stance"].is_empty() or party_hp <= 0:
		return []
	var st: Dictionary = enemy["stance"]
	var d := maxi(1, int(round(float(enemy["at"]) * float(db.battle.get("damage_mult", 1.0)) * float(st["power"]) * _variance() * (1.0 - _player_cut()))))
	party_hp = maxi(0, party_hp - d)
	_ev({"t": "stance_hit", "unit": k, "dmg": d, "hp": party_hp, "move": st["name"]})
	return ["[color=red]  %s【%s】迎面反击，我军受到 %d 伤害[/color]" % [enemy["data"]["name"], st["name"], d]]


func _drop_stance() -> Array:
	if enemy["stance"].is_empty():
		return []
	var nm := str(enemy["stance"]["name"])
	enemy["stance"] = {}
	_ev({"t": "stance_off", "broken": true})
	return ["  [color=gold]%s 的【%s】被打散了[/color]" % [enemy["data"]["name"], nm]]


# ---- v3: 意图 (the enemy's moves for this round, planned at its start) and the smart pick ----

func _move_named(nm: String) -> Dictionary:
	for m in enemy["data"]["moves"]:
		if m["name"] == nm:
			return m
	return {}


func charge_target(mv: Dictionary) -> Dictionary:
	## the move a wind-up (`charge`) announces
	return _move_named(str(mv["charge"])) if mv.has("charge") else {}


func smart() -> bool:
	## elites, bosses and the 必败 showpieces read the fight; plain enemies only keep the common sense
	return str(mods.get("enemy_tier", "normal")) in ["elite", "boss", "lose"]


func party_interrupts_left() -> int:
	## how many 打断 skills the party still has a use of (for the enemy's read and for 军令)
	var n := 0
	for u in leaders:
		for sk in skills_of(u):
			if can_interrupt(sk):
				var left: Variant = u["uses_left"][sk["id"]]
				if left == null or int(left) > 0:
					n += 1
	return n


func prefer_holds(cond: String) -> bool:
	match cond:
		"player_high_ap":
			return ap >= 6
		"player_buffed":
			return int(buff["layers"]) >= 2 or leaders.filter(func(u): return u["boosted"]).size() >= 2
		"player_low_hp":
			return party_hp * 100 < party_max * 45
		"party_burning":
			return int(party_burn.get("turns", 0)) > 0
		"party_poisoned":
			return int(party_poison.get("turns", 0)) > 0
		"first_round":
			return round_no <= 1
		"self_low_hp":
			return int(enemy["hp"]) * 2 < int(enemy["max_hp"])
	return false


const PREFERS := ["player_high_ap", "player_buffed", "player_low_hp", "party_burning", "party_poisoned", "first_round", "self_low_hp"]


func _move_weight(m: Dictionary, planned: Array) -> float:
	## weight × common sense (every enemy) × reading the fight (elites / bosses: prefer, the player's 打断)
	var w := float(m["weight"])
	if w <= 0.0:
		return 0.0
	if m.get("when", "") == "half" and int(enemy["hp"]) * 2 >= int(enemy["max_hp"]):
		return 0.0
	if m.get("once", false) and (enemy["used"].has(m["name"]) or planned.any(func(p): return p["name"] == m["name"])):
		return 0.0
	var winding: bool = str(enemy["charging"]) != "" or not enemy["mark"].is_empty() or planned.any(func(p): return p.has("charge") or p.has("mark"))
	if (m.has("charge") or m.has("mark")) and winding:  # one wind-up (蓄力 or 点名) at a time
		return 0.0
	if m.has("seal") and (not seal.is_empty() or planned.any(func(p): return p.has("seal"))):
		return 0.0
	if m.has("shield") and (not enemy["shield"].is_empty() or planned.any(func(p): return p.has("shield"))):
		return 0.0
	if m.has("formation") and (planned.any(func(p): return p.has("formation")) or (not enemy["form"].is_empty() and str(enemy["form"]["vs"]) == str(m["formation"]["vs"]))):
		return 0.0  # never the formation already up (flipping to the other one is fine)
	var eff: Dictionary = charge_target(m) if m.has("charge") else m  # a wind-up is judged by what it winds up to
	var hp_share := float(enemy["hp"]) / maxf(1.0, float(enemy["max_hp"]))
	if eff.has("heal") and float(eff.get("power", 0.0)) <= 0.0 and hp_share > 0.8:
		return 0.0  # never heals at (near) full HP
	if eff.has("stance") and not enemy["stance"].is_empty():
		return 0.0
	if eff.has("summon") and not enemy["guard"].is_empty():
		return 0.0
	if eff.has("burn_party") and int(party_burn.get("turns", 0)) >= 2:
		w *= 0.15
	if eff.has("poison_party") and int(party_poison.get("layers", 0)) >= int(eff.get("poison_max", 3)) and int(party_poison.get("turns", 0)) >= 2:
		w *= 0.15
	if eff.has("ap_drain") and ap <= 1:
		w *= 0.2
	if float(eff.get("power", 0.0)) <= 0.0 and planned.any(func(p): return p["name"] == m["name"]):
		w *= 0.2  # no two of the same pure status move in one round
	if not smart():
		return w
	if eff.has("heal") and hp_share < 0.35:
		w *= 3.0
	if eff.has("ap_drain") and prefer_holds("player_high_ap"):
		w *= 2.0  # the player is saving up for a 大招: take the AP away
	if eff.has("confuse") and prefer_holds("player_buffed"):
		w *= 2.0
	if (eff.get("pierce", false) or float(eff.get("power", 0.0)) >= 1.5) and prefer_holds("player_low_hp"):
		w *= 2.0  # goes for the kill
	var pref: Variant = m.get("prefer", [])
	for cond in (pref if pref is Array else [pref]):
		if prefer_holds(str(cond)):
			w *= 3.0
	if m.has("seal") and str(m["seal"]) == "ultimate" and leaders.any(func(u): return skills_of(u).any(func(sk): return is_ult(sk) and (u["uses_left"][sk["id"]] == null or int(u["uses_left"][sk["id"]]) > 0))):
		w *= 2.0  # locks the 大招 while some are still in hand
	if m.has("formation") and not enemy["form"].is_empty():
		w *= 2.0  # flips the formation once the player has adapted
	if m.has("charge"):  # reads the player's 打断: holds a wind-up while one is ready, winds up when none is left
		w *= 0.5 if party_interrupts_left() > 0 else 1.8
	return w


const SEAL_NAMES := {"ultimate": "大招", "magic": "谋略", "attack": "兵刃技能"}


func mark_pick() -> int:
	## 点名: the hardest hitter on the field (a smart enemy) or anyone — never one already slain (-1: nobody left to mark)
	var alive: Array = range(leaders.size()).filter(func(k): return not leaders[k].get("slain", false))
	if alive.is_empty():
		return -1
	if not smart():
		return alive[rng.randi_range(0, alive.size() - 1)]
	var best: int = alive[0]
	for k in alive:
		if float(leaders[k]["leader"]["at"]) > float(leaders[best]["leader"]["at"]):
			best = k
	return best


func _pick_move(planned: Array) -> Dictionary:
	## one move for the next action: the charged move first, then a 连段 (chain) the last planned move names, else a weighted smart pick
	var moves: Array = enemy["data"]["moves"]
	if planned.is_empty() and str(enemy["charging"]) != "":
		var cm := _move_named(str(enemy["charging"]))
		if not cm.is_empty():
			return cm
	if not enemy["mark"].is_empty() and not planned.any(func(p): return p["name"] == enemy["mark"]["move"]):
		var sm := _move_named(str(enemy["mark"]["move"]))  # 点名: the blow at the marked leader
		if not sm.is_empty():
			return sm
	if not planned.is_empty() and planned[-1].has("chain"):
		var nx := _move_named(str(planned[-1]["chain"]))
		if not nx.is_empty():
			return nx
	var ws: Array = moves.map(func(m): return _move_weight(m, planned))
	if ws.all(func(x): return x <= 0.0):
		var plain: Array = moves.filter(func(m): return float(m["weight"]) > 0.0 and not m.has("charge"))
		return plain[0] if not plain.is_empty() else moves[0]
	return GameData.weighted_pick(rng, moves, ws)


func _plan_intents() -> void:
	## 意图: the enemy's moves for its next turn, shown to the player; a stunned enemy plans nothing (it skips its turn)
	var planned: Array = []
	if not enemy["stunned"] and int(enemy["hp"]) > 0:
		for _a in int(enemy["data"]["actions"]):
			planned.append(_pick_move(planned))
	enemy["intents"] = planned


func intent_label(mv: Dictionary, first := false) -> String:
	## a short word for a planned move: 绝招【X】 / 蓄力·回血 / 重击+施毒 …
	if first and str(enemy["charging"]) != "" and mv["name"] == enemy["charging"]:
		return "绝招【%s】" % mv["name"]
	if not enemy["mark"].is_empty() and mv["name"] == enemy["mark"]["move"]:
		return "斩将【%s】→%s" % [mv["name"], enemy["mark"]["who"]]
	if mv.has("mark"):
		return "点名"
	if mv.has("charge"):
		var t := charge_target(mv)
		var kind := "杀招"
		if t.has("summon"):
			kind = "叫援"
		elif t.has("heal") and float(t.get("power", 0.0)) <= 0.0:
			kind = "回血"
		elif t.has("rage") and float(t.get("power", 0.0)) <= 0.0:
			kind = "狂暴"
		return "蓄力·" + kind
	var parts: Array = []
	if mv.has("stance"):
		parts.append("架势")
	if mv.has("summon"):
		parts.append("唤援")
	if mv.has("shield"):
		parts.append("护盾")
	if mv.has("formation"):
		parts.append("变阵·" + ("挡兵刃" if str(mv["formation"]["vs"]) == "attack" else "挡谋略"))
	if mv.has("seal"):
		parts.append("封" + str(SEAL_NAMES.get(str(mv["seal"]), "技")))
	var p := float(mv.get("power", 0.0))
	if p >= 1.5 or mv.get("pierce", false) or mv.has("pct"):
		parts.append("重击")
	elif p > 0.0:
		parts.append("攻击")
	for pair in [["poison_party", "施毒"], ["burn_party", "烈火"], ["confuse", "惑乱"], ["ap_drain", "夺气"], ["heal", "回血"], ["rage", "狂暴"]]:
		if mv.has(pair[0]):
			parts.append(pair[1])
	return "+".join(parts) if not parts.is_empty() else mv["name"]


func intent_text() -> String:
	var out: Array = []
	if enemy["stunned"]:
		out.append("眩晕")
	else:
		for k in enemy["intents"].size():
			out.append(intent_label(enemy["intents"][k], k == 0))
	if not enemy["guard"].is_empty():  # the 前卫 swings a 普通攻击 every enemy turn, even with its boss stunned
		out.append("%s·普攻" % enemy["guard"]["name"])
	return " · ".join(out)


# ---- internals ---------------------------------------------------------------

func _variance() -> float:
	var v := float(db.battle["variance"])
	return rng.randf_range(1.0 - v, 1.0 + v)


func _crit_roll(side: String) -> float:
	## 暴击 (battle.crit in cards.json): returns the damage multiplier — 1.0 for no crit. `player_*` for our hits, `enemy_*` for theirs;
	## mods.crit / mods.crit_mult (宝物) add to ours
	var cfg: Dictionary = db.battle.get("crit", {})
	var raw: Variant = cfg.get(side + "_chance", 0.0)
	if raw is Dictionary:  # per fight tier: normal / elite / boss / lose
		raw = raw.get(str(mods.get("enemy_tier", "normal")), 0.0)
	var chance := float(raw)
	var mult := float(cfg.get(side + "_mult", 1.0))
	if side == "player":
		chance += float(mods.get("crit", 0.0))
		mult += float(mods.get("crit_mult", 0.0))
	return mult if chance > 0.0 and rng.randf() < chance else 1.0


func _dot_resist() -> float:
	## 灼烧 and 中毒 share one resist, the enemy's magic resist (a weakness below 0 makes them bite harder); 宝物 pierce eats into it
	return _cut(float(enemy["data"]["magic_resist"]) * (1.0 - minf(1.0, float(mods.get("pierce", 0.0)))))


func _resist_cut() -> float:
	## 弓兵: both resists (兵刃抗性 and 谋略抗性) are lowered — by the archers' own 破甲 for a few turns, and for good by 宝物 (mods.resist_cut)
	return float(enemy.get("resist_down", 0.0)) + float(mods.get("resist_cut", 0.0))


func _cut(resist: float) -> float:
	## a resist after the archers' cut: never pushed below battle.archer_resist.floor (-0.25, user rule); a weakness already deeper than that stays as it is
	var floor_v := float(db.battle.get("archer_resist", {}).get("floor", -0.25))
	return minf(resist, maxf(resist - _resist_cut(), floor_v))


func split_share(u: Dictionary) -> float:
	## 弓兵 / 贼 (battle.split_troops): the 谋略 share of each of their blows; 0 for everyone else
	return float(db.battle.get("split_troops", {}).get(str(u["leader"]["card"]["troop"]), 0.0))


func _split_blow(base: float, mult: float, share: float, pierce: bool, crit_mult := 1.0, magic_extra := 0.0) -> Dictionary:
	## one blow cut in two: the 兵刃 part meets the 兵刃抗性 (and the 前卫 / 护盾 first), the 谋略 part the 谋略抗性 and goes over them.
	## Returns {d: what the enemy itself lost, soaked: the 护盾's take, note: the log's breakdown}
	var da := int(round(_dmg(base * (1.0 - share) * mult, "attack", pierce) * crit_mult))
	var dm := int(round(_dmg(base * share * (mult + float(mods.get("magic", 0.0)) + magic_extra), "magic", pierce) * crit_mult))
	var on_guard := guard_takes("attack", pierce)
	var shielded := not on_guard and shield_takes("attack")
	var boss_part := dm + (0 if on_guard else da)
	if boss_part > enemy["hp"]:
		overkill = float(boss_part - enemy["hp"]) / enemy["max_hp"]
	var gname := str(enemy["guard"].get("name", ""))
	var dealt_a := _land(da, "attack", pierce)
	var soaked := _absorbed if shielded else 0
	var dealt_m := _land(dm, "magic", pierce)
	var note := "　兵刃 %d · 谋略 %d" % [dealt_a, dealt_m]
	if on_guard:
		note = "　谋略 %d；兵刃 %d 打在 %s 身上%s" % [dealt_m, dealt_a, gname, "，[color=gold]前卫被击溃！[/color]" if enemy["guard"].is_empty() else ""]
	elif soaked > 0:
		note += "　护盾挡下 %d" % soaked
	return {"d": dealt_m + (0 if on_guard else dealt_a), "soaked": soaked, "note": note}


func _dmg(base: float, kind: String, pierce := false) -> int:
	## pierce (弓兵 穿甲): this hit ignores the enemy's resist altogether
	var data: Dictionary = enemy["data"]
	var resist: float = data["phys_resist"] if kind == "attack" else data["magic_resist"]
	resist = 0.0 if pierce else _cut(resist * (1.0 - minf(1.0, float(mods.get("pierce", 0.0)))))
	var d: float = base * float(db.battle.get("damage_mult", 1.0)) * (1.0 + (float(db.battle["combo_bonus"]) + float(mods.get("combo", 0.0))) * combo) * (1.0 + enemy["break_amount"]) * (1.0 - resist)
	d *= form_mult(kind)
	return maxi(1, int(round(d * _variance())))


func form_mult(kind: String) -> float:
	## 变阵: the formation up shuts out most of one kind of damage (attack / magic); the other kind goes in full
	if enemy["form"].is_empty() or str(enemy["form"]["vs"]) != kind:
		return 1.0
	return 1.0 - float(enemy["form"]["cut"])


func _drop_form() -> Array:
	if enemy["form"].is_empty():
		return []
	var nm := str(enemy["form"]["name"])
	enemy["form"] = {}
	_ev({"t": "form_off", "broken": true})
	return ["  [color=gold]%s 的【%s】被打乱了[/color]" % [enemy["data"]["name"], nm]]


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
				var share := split_share(u)  # 弓兵 / 贼: this share of every blow is 谋略, the rest 兵刃, whatever the skill's type (user rule)
				var buff_m := float(buff["atk"]) * (float(db.battle.get("buff_magic_mult", 1.0)) - 1.0)  # 战意 (献策): its attack bonus counts this many times over on 谋略 damage (user rule)
				if kind == "magic" and share <= 0.0:
					bonus += float(mods.get("magic", 0.0)) + buff_m
				if party_hp * 2 < party_max:
					bonus += float(mods.get("desperate", 0.0))
				if not first_hit_done:  # 七星宝刀
					bonus += float(mods.get("first_hit", 0.0))
					first_hit_done = true
				var fire := vs_mult(eff)  # 火上浇油 (burning_mult) and every other 追击 (vs: broken / burning / poisoned / stunned / guarded)
				var power: float = float(eff["power"]) + float(eff.get("per_combo", 0.0)) * combo  # 收尾 (骑兵)
				var pierce := bool(eff.get("pierce", false))
				var crit_mult := _crit_roll("player")
				if crit_if_holds(eff):  # 破绽必暴: the condition holds, the blow is a crit for sure
					crit_mult = maxf(crit_mult, float(db.battle.get("crit", {}).get("player_mult", 1.6)) + float(mods.get("crit_mult", 0.0)))
				var crit := crit_mult > 1.0
				if share > 0.0:
					var sb := _split_blow(at * power * mult * fire, 1.0 + bonus, share, pierce, crit_mult, buff_m)
					combo += 1
					_ev({"t": "hit", "dmg": sb["d"], "combo": combo, "kind": kind, "hp": enemy["hp"], "pierce": pierce, "crit": crit, "guard": false, "vs": fire, "shield": sb["soaked"], "split": true})
					log.append("  %s 受到 %d 伤害（%d 连击）%s%s" % [ename, sb["d"], combo, sb["note"], "[color=gold]　暴击！[/color]" if crit else ""])
					continue
				var d := _dmg(at * power * mult * (1.0 + bonus) * fire, kind, pierce)
				if crit:
					d = int(round(d * crit_mult))
				var on_guard := guard_takes(kind, pierce)
				var target_name: String = str(enemy["guard"]["name"]) if on_guard else ename
				if not on_guard and d > enemy["hp"]:
					overkill = float(d - enemy["hp"]) / enemy["max_hp"]
				var shielded := not on_guard and shield_takes(kind)
				d = _land(d, kind, pierce)
				var soaked := _absorbed if shielded else 0
				combo += 1
				_ev({"t": "hit", "dmg": d, "combo": combo, "kind": kind, "hp": enemy["hp"], "pierce": pierce, "crit": crit, "guard": on_guard, "vs": fire, "shield": soaked})
				if d == 0 and soaked > 0:
					log.append("  %s 的护盾挡下 %d（%d 连击）" % [target_name, soaked, combo])
				else:
					log.append("  %s 受到 %d 伤害（%d 连击）%s%s" % [target_name, d, combo, ("　护盾挡下 %d" % soaked) if soaked > 0 else "", "[color=gold]　暴击！[/color]" if crit else ""])
				if on_guard and enemy["guard"].is_empty():
					log.append("  [color=gold]前卫被击溃！[/color]")
				if kind == "attack" and float(buff.get("magic", 0.0)) > 0.0 and enemy["hp"] > 0:  # 战意: each layer adds a share of the blow as magic (magic resist applies)
					var md := _dmg(at * power * mult * (1.0 + bonus) * fire * float(buff["magic"]), "magic")
					enemy["hp"] = maxi(0, enemy["hp"] - md)
					_ev({"t": "hit", "dmg": md, "combo": combo, "kind": "magic", "hp": enemy["hp"], "pierce": false, "crit": false, "rider": true})
					log.append("  [color=#c9a2ff]战意附带谋略 %d[/color]" % md)
			return log
		"heal":
			var amt := mini(int(round(at * float(eff["power"]) * mult * (1.0 + float(mods.get("heal", 0.0))) * float(db.battle.get("heal_mult", 1.0)))),
				party_max - party_hp)
			party_hp += amt
			_ev({"t": "heal", "amt": amt, "hp": party_hp})
			return ["  体力恢复 %d" % amt]
		"guard":
			var sbon := streak_bonus()
			guard_cut = 1.0 - (1.0 - guard_cut) * (1.0 - minf(0.9, (float(eff["cut"]) + sbon) * mult))
			guarded_this_round = true
			_ev({"t": "guard", "cut": guard_cut})
			return ["  本回合受到伤害 -%d%%%s" % [int(round(guard_cut * 100)), ("（连续防御 +%d%%）" % int(round(sbon * 100))) if sbon > 0.0 else ""]]
		"boost":
			var bm := str(db.battle["boost_mult"])
			if eff["target"] == "all":
				var who: Array = []
				for t in leaders:
					if t != u and not t.get("slain", false):
						t["boosted"] = true
						who.append(leaders.find(t))
				_ev({"t": "boost", "units": who})
				return ["  全军进入 BOOST（下次行动 ×%s）" % bm]
			if eff["target"] == "random_idle":  # 鼓舞一个还没出手的友军
				var idle: Array = leaders.filter(func(t): return t != u and not t["acted"] and not t["boosted"] and not t["confused"] and not t.get("slain", false))
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
			if rng.randf() < (float(eff["chance"]) + float(mods.get("stun", 0.0))) * mult:
				enemy["stunned"] = true
				_ev({"t": "stun", "ok": true})
				var slog: Array = ["  %s 陷入眩晕！下回合无法行动%s" % [ename, "（蓄力顺延）" if enemy["charging"] != "" else ""]]
				slog.append_array(_drop_stance())
				slog.append_array(_drop_form())  # 眩晕 throws the formation into disorder too
				_plan_intents()
				return slog
			_ev({"t": "stun", "ok": false})
			return ["  %s 未受影响" % ename]
		"shred":  # 弓兵 射穿甲缝: both resists down, stacking with every use (and with the passive) up to battle.archer_resist.max; the count restarts
			var cap := float(db.battle.get("archer_resist", {}).get("max", 0.5))
			enemy["resist_down"] = minf(cap, float(enemy["resist_down"]) + float(eff.get("amount", 0.1)) * mult)
			enemy["resist_turns"] = maxi(int(enemy["resist_turns"]), int(eff.get("turns", 3)))
			_ev({"t": "resist_down", "amount": enemy["resist_down"], "turns": enemy["resist_turns"]})
			return ["  射穿甲缝：%s 的兵刃、谋略抗性累计 -%d%%（%d 回合）" % [ename, int(round(enemy["resist_down"] * 100)), enemy["resist_turns"]]]
		"break":
			var broke := float(eff["amount"]) * mult
			enemy["break_amount"] = maxf(enemy["break_amount"], broke)
			enemy["break_turns"] = maxi(enemy["break_turns"], int(eff["turns"]))
			_ev({"t": "break", "amount": enemy["break_amount"], "turns": enemy["break_turns"]})
			return ["  %s 破防：受到伤害 +%d%%（%d 回合）" % [ename, int(round(broke * 100)), int(eff["turns"])]]
		"burn":  # 火攻: the enemy loses HP before each of its turns; one fire at a time — a new one keeps the bigger, restarts the count
			# "pct": a share of the enemy's CURRENT HP each turn (so it eases off as it burns); "power": a flat amount,
			# × the caster's attack. Fire and poison share the magic resist, taken when they tick (`_dot_resist`). Either way the fire never takes the last HP.
			var bonus := float(mods.get("at", 0.0)) + float(mods.get("magic", 0.0))
			enemy["burn_turns"] = maxi(enemy["burn_turns"], int(eff["turns"]))
			if eff.has("pct"):
				enemy["burn_pct"] = maxf(enemy["burn_pct"], float(eff["pct"]) * mult)
				_ev({"t": "burn_on", "pct": enemy["burn_pct"], "turns": enemy["burn_turns"]})
				return ["  %s 陷入灼烧！每回合烧掉现有体力的 %d%%（%d 回合）" % [ename, int(round(enemy["burn_pct"] * 100)), enemy["burn_turns"]]]
			var per := maxi(1, int(round(at * float(db.battle.get("damage_mult", 1.0)) * float(eff.get("power", 0.0)) * mult * (1.0 + bonus))))
			enemy["burn_dmg"] = maxi(enemy["burn_dmg"], per)
			_ev({"t": "burn_on", "dmg": enemy["burn_dmg"], "turns": enemy["burn_turns"]})
			return ["  %s 陷入灼烧！每回合结算 -%d（%d 回合）" % [ename, enemy["burn_dmg"], enemy["burn_turns"]]]
		"poison":  # 中毒 (贾诩): +stacks layers (up to max), each takes pct of the enemy's MAX HP before its turn; ignores every resist; refreshes the count
			enemy["poison"] = mini(int(eff.get("max", 5)), int(enemy["poison"]) + int(eff.get("stacks", 1)))
			enemy["poison_pct"] = maxf(float(enemy["poison_pct"]), float(eff["pct"]) * mult)
			enemy["poison_turns"] = maxi(int(enemy["poison_turns"]), int(eff.get("turns", 3)))
			_ev({"t": "poison_on", "layers": enemy["poison"], "turns": enemy["poison_turns"]})
			return ["  %s 中毒 ×%d：每回合损失最大体力的 %d%%（%d 回合）" % [ename, enemy["poison"],
				int(round(enemy["poison_pct"] * enemy["poison"] * 100)), enemy["poison_turns"]]]
		"counter":  # 反击: until the round ends, every hit the enemy lands is answered with ×power of this leader's attack
			var slot := leaders.find(u)
			counters.append({"name": unit_name(u), "at": at * mult, "power": float(eff["power"]), "unit": slot})
			_ev({"t": "counter_on", "unit": slot, "power": float(eff["power"])})
			return ["  %s 架起拒马：本回合敌人每打中一次，还击 ×%s" % [unit_name(u), str(eff["power"])]]
		"buff":  # 战意: +1 layer (up to max) of attack and damage-taken cut for the whole party; recasting refreshes the timer
			if buff["layers"] < int(eff.get("max", 4)):
				buff["layers"] += 1
				buff["atk"] += float(eff.get("atk", 0.0)) * mult
				buff["def"] += float(eff.get("def", 0.0)) * mult
				buff["magic"] = float(buff.get("magic", 0.0)) + float(eff.get("magic", 0.0)) * mult
			buff["turns"] = int(eff.get("turns", 3))
			_ev({"t": "buff", "layers": buff["layers"], "atk": buff["atk"], "def": buff["def"]})
			return ["  战意 ×%d：全军攻击 +%d%%%s%s（%d 回合）" % [buff["layers"], int(round(buff["atk"] * 100)), ("，受到伤害 -%d%%" % int(round(buff["def"] * 100))) if buff["def"] > 0.0 else "",
				("，兵刃攻击附带 %d%% 谋略伤害" % int(round(buff["magic"] * 100))) if buff["magic"] > 0.0 else "", buff["turns"]]]
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
			if party_poison["turns"] > 0:
				n += 1
				party_poison = {"layers": 0, "pct": 0.0, "turns": 0}
			if ap_drain > 0:
				n += 1
				ap_drain = 0
			if not seal.is_empty():
				n += 1
				seal = {}
				_ev({"t": "seal_off"})
			_ev({"t": "cleanse", "n": n})
			return ["  我军的异常状态解除了" if n > 0 else "  没有需要解除的状态"]
		"hurt":  # 苦肉: the party pays a share of its max HP (never to death)
			var lost := clampi(int(round(party_max * float(eff["pct"]))), 0, party_hp - 1)
			party_hp -= lost
			_ev({"t": "hurt", "dmg": lost, "hp": party_hp})
			return ["  我军折损 %d 体力" % lost]
		"loot":  # 劫掠: every use raises the odds of a bigger haul when the fight is won
			loot_chest = minf(1.0, loot_chest + float(eff["chest"]) * mult)
			loot_card = minf(1.0, loot_card + float(eff["card"]) * mult)
			_ev({"t": "loot", "chest": loot_chest, "card": loot_card})
			return ["  战利品：多一个宝箱 %d%%，宝箱多一张卡 %d%%" % [int(round(loot_chest * 100)), int(round(loot_card * 100))]]
		"ap":
			var gained := int(ceil(float(eff["amount"]) * mult))  # BOOST rounds up: 1 AP becomes 2
			ap = mini(ap_max(), ap + gained)
			_ev({"t": "ap", "amount": gained, "ap": ap})
			return ["  AP +%d" % gained]
		"interrupt":  # 打断 (扔刀 / 回马枪 …): a charge in progress is spent for nothing; AP back and an opening (battle.charge_break)
			if enemy["charging"] == "":
				return ["  （%s 没有在蓄力）" % ename]
			var cname: String = enemy["charging"]
			enemy["charging"] = ""
			enemy["charge_ready"] = false
			var cb: Dictionary = db.battle.get("charge_break", {})
			var gain := mini(int(cb.get("ap_reward", 1)), ap_max() - ap)
			ap += gain
			enemy["break_amount"] = maxf(float(enemy["break_amount"]), float(cb.get("break_bonus", 0.25)))
			enemy["break_turns"] = maxi(int(enemy["break_turns"]), int(cb.get("break_turns", 2)))
			_ev({"t": "charge_break", "move": cname, "ap": ap, "gain": gain})
			var ilog: Array = ["  [color=gold]破招！%s 的【%s】被打断，AP +%d，破绽大开：受到伤害 +%d%%（%d 回合）[/color]" % [ename, cname, gain,
				int(round(float(enemy["break_amount"]) * 100)), enemy["break_turns"]]]
			ilog.append_array(_drop_stance())
			_plan_intents()
			return ilog
	assert(false, "unknown effect " + kind)
	return []


func _enemy_phase(defend_cut: float) -> Array:
	if result != "":
		return []
	var data: Dictionary = enemy["data"]
	var log: Array = []
	if enemy["poison_turns"] > 0:  # 中毒 first: it can finish the enemy off, unlike the fire
		enemy["poison_turns"] -= 1
		var pd: int = clampi(int(round(enemy["max_hp"] * enemy["poison_pct"] * enemy["poison"] * (1.0 - _dot_resist()))), 1, enemy["hp"])
		enemy["hp"] -= pd
		_ev({"t": "poison", "dmg": pd, "hp": enemy["hp"], "turns": enemy["poison_turns"]})
		log.append("%s 毒发，损失 %d 体力" % [data["name"], pd])
		if enemy["poison_turns"] == 0:
			enemy["poison"] = 0
			enemy["poison_pct"] = 0.0
		_check_end()
		if result != "":
			return log
	if enemy["burn_turns"] > 0:
		enemy["burn_turns"] -= 1
		var d: int = clampi(int(round(maxf(float(enemy["burn_dmg"]), enemy["hp"] * enemy["burn_pct"]) * (1.0 - _dot_resist()))), 0, enemy["hp"] - 1)  # never lethal
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
	if party_poison["turns"] > 0:  # 中毒 on us: every layer takes its share of our MAX HP, so a bigger bar does not shrug it off
		party_poison["turns"] -= 1
		var pd := int(round(party_max * float(party_poison["pct"]) * int(party_poison["layers"])))
		party_hp = maxi(0, party_hp - pd)
		_ev({"t": "enemy_hit", "dmg": pd, "move": "毒", "cut": 0.0, "hp": party_hp})
		log.append("[color=red]我军中毒 ×%d，损失 %d 体力[/color]" % [party_poison["layers"], pd])
		if party_poison["turns"] == 0:
			party_poison = {"layers": 0, "pct": 0.0, "turns": 0}
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
	if not seal.is_empty():  # 封技 was on through the player's round
		seal["turns"] = int(seal["turns"]) - 1
		if int(seal["turns"]) <= 0:
			seal = {}
			_ev({"t": "seal_off"})
	if not enemy["form"].is_empty():  # 变阵 runs out
		enemy["form"]["turns"] = int(enemy["form"]["turns"]) - 1
		if int(enemy["form"]["turns"]) <= 0:
			enemy["form"] = {}
			_ev({"t": "form_off"})
	if not enemy["stance"].is_empty():  # 反击架势 runs out (it was up through the player's round)
		enemy["stance"]["turns"] = int(enemy["stance"]["turns"]) - 1
		if int(enemy["stance"]["turns"]) <= 0:
			enemy["stance"] = {}
			_ev({"t": "stance_off"})
	var was_stunned: bool = enemy["stunned"]
	var cut := 1.0 - (1.0 - guard_cut) * (1.0 - defend_cut) * (1.0 - float(mods.get("guard", 0.0))) * (1.0 - minf(0.9, float(buff["def"])))
	if enemy["stunned"]:
		enemy["stunned"] = false
		_ev({"t": "enemy_stunned"})
		log.append("%s 眩晕中，无法行动" % data["name"])
	else:
		var queue: Array = enemy["intents"].duplicate()
		if str(enemy["charging"]) != "" and (queue.is_empty() or queue[0]["name"] != enemy["charging"]):
			queue = []  # a charge set from outside the plan (demos, tests): plan again so it lands first
		if queue.any(func(m): return not data["moves"].has(m)):
			queue = []  # the move list changed under the plan (tests, demos)
		if queue.is_empty():
			for _a in int(data["actions"]):
				queue.append(_pick_move(queue))
		for mv in queue:
			if mv.has("charge"):  # winds up: next turn opens with the big one
				enemy["charging"] = mv["charge"]
				_ev({"t": "enemy_charge", "move": mv["charge"], "kind": intent_label(mv)})
				log.append("[color=red]%s 正在蓄力……下回合【%s】！[/color]" % [data["name"], mv["charge"]])
				continue  # the wind-up costs this action only
			if mv.has("mark"):  # 点名: picks one of our leaders; next turn opens with the blow at him (换下他 = it misses; else battle.mark_pct of our max HP, no guard cuts it)
				var tk := mark_pick()
				if tk < 0:
					continue
				var tu: Dictionary = leaders[tk]
				enemy["mark"] = {"card": swap_key(tu["leader"]), "who": unit_name(tu), "move": str(mv["mark"])}  # swap_key: a lord swapping to another lord card dodges too
				_ev({"t": "mark_on", "unit": tk, "move": mv["mark"]})
				log.append("[color=red]%s【%s】点名 %s……下回合【%s】！（换下他就扑空；不换，他被打倒、本场不能再行动，我军还损失体力上限的 1/4）[/color]" % [data["name"], mv["name"], unit_name(tu), mv["mark"]])
				continue
			var marked_k := -2  # -2: not the 点名 blow
			if not enemy["mark"].is_empty() and mv["name"] == enemy["mark"]["move"]:
				var mk: Dictionary = enemy["mark"]
				enemy["mark"] = {}
				marked_k = -1
				for k in leaders.size():
					if swap_key(leaders[k]["leader"]) == mk["card"] and not leaders[k].get("slain", false):
						marked_k = k
				if marked_k < 0:  # the marked one was swapped out
					_ev({"t": "mark_miss", "move": mv["name"], "who": mk["who"]})
					log.append("[color=gold]%s【%s】扑了个空——%s 已经不在阵上！[/color]" % [data["name"], mv["name"], mk["who"]])
					continue
			if str(enemy["charging"]) != "" and mv["name"] == enemy["charging"]:
				enemy["charging"] = ""  # the charged move lands
				enemy["charge_ready"] = false
			if mv.get("once", false):
				enemy["used"].append(mv["name"])
			if mv.has("stance"):  # 反击架势: physical skills get answered until it runs out (or a stun / 打断 breaks it)
				var st: Dictionary = mv["stance"]
				enemy["stance"] = {"name": str(st.get("name", mv["name"])), "power": float(st.get("power", 0.8)), "turns": int(st.get("turns", 1))}
				_ev({"t": "stance_on", "move": mv["name"]})
				log.append("[color=red]  %s 摆开【%s】：兵刃攻击会被反击（谋略、毒火不会）[/color]" % [data["name"], enemy["stance"]["name"]])
			if mv.has("seal"):  # 封技: a kind of our skills is locked for the next round(s) (解状态 lifts it)
				seal = {"name": str(mv["name"]), "kind": str(mv["seal"]), "turns": int(mv.get("seal_turns", 1))}
				_ev({"t": "seal_on", "kind": seal["kind"], "turns": seal["turns"], "move": mv["name"]})
				log.append("[color=red]  %s【%s】：我军%s被封 %d 回合（解除状态可解）[/color]" % [data["name"], mv["name"], SEAL_NAMES.get(seal["kind"], "技能"), seal["turns"]])
			if mv.has("formation"):  # 变阵: one kind of damage mostly shut out for a few turns (眩晕 breaks it)
				var fm: Dictionary = mv["formation"]
				enemy["form"] = {"name": str(fm.get("name", mv["name"])), "vs": str(fm["vs"]), "cut": float(fm.get("cut", 0.6)), "turns": int(fm.get("turns", 2))}
				_ev({"t": "form_on", "name": enemy["form"]["name"], "vs": enemy["form"]["vs"]})
				log.append("[color=red]  %s 变阵【%s】：%s伤害 -%d%%（%d 回合，眩晕可破）[/color]" % [data["name"], enemy["form"]["name"],
					"兵刃" if enemy["form"]["vs"] == "attack" else "谋略", int(round(enemy["form"]["cut"] * 100)), enemy["form"]["turns"]])
			if mv.has("shield"):  # 护盾: a 兵刃 blow under its HP is swallowed, the one that breaks it lands in full; 谋略 goes over
				var sh: Dictionary = mv["shield"]
				var shp := maxi(1, int(round(float(enemy["max_hp"]) * float(sh.get("hp_pct", 0.2)))))
				enemy["shield"] = {"name": str(sh.get("name", mv["name"])), "hp": shp, "max_hp": shp}
				_ev({"t": "shield_on", "name": enemy["shield"]["name"], "hp": shp})
				log.append("[color=red]  %s【%s】：护盾 %d（打不破它的兵刃整下被挡；一下打破就伤害全中；谋略直接越过）[/color]" % [data["name"], enemy["shield"]["name"], shp])
			if mv.has("summon"):  # 前卫: plain physical blows land on it until it falls
				var sm: Dictionary = mv["summon"]
				var ghp := maxi(1, int(round(float(enemy["max_hp"]) * float(sm.get("hp_pct", 0.15)))))
				enemy["guard"] = {"name": str(sm["name"]), "hp": ghp, "max_hp": ghp, "strike": float(sm.get("strike", 0.5))}
				_ev({"t": "guard_on", "name": sm["name"], "hp": ghp})
				log.append("[color=red]  %s 唤来【%s】挡在身前（兵刃攻击先打它；谋略、穿甲可以越过）[/color]" % [data["name"], sm["name"]])
			if marked_k >= 0:  # 点名 lands on the one still standing there: a fixed share of our max HP, nothing cuts it
				var md := maxi(1, int(round(party_max * float(db.battle.get("mark_pct", 0.25)))))
				party_hp = maxi(0, party_hp - md)
				_ev({"t": "enemy_hit", "dmg": md, "move": mv["name"], "cut": 0.0, "hp": party_hp, "mark": marked_k})
				var su: Dictionary = leaders[marked_k]
				su["slain"] = true  # 被斩: grey for the rest of the fight (he can still be swapped out)
				su["boosted"] = false
				su["confused"] = false
				su["confuse_next"] = false
				_ev({"t": "slain", "unit": marked_k, "move": mv["name"]})
				log.append("[color=red]%s【%s】直取 %s！%s 被打倒，本场不能再行动；我军受到 %d 伤害（体力上限的 1/4）[/color]" % [data["name"], mv["name"], unit_name(su), unit_name(su), md])
			elif float(mv["power"]) > 0.0 or mv.has("pct"):
				var c: float = 0.0 if mv.get("pierce", false) else cut
				# pct: the blow also takes that share of our MAX HP (a 大招 that keeps hurting however big the party grows); the guard cuts it too
				var d := maxi(1, int(round((enemy["at"] * float(db.battle.get("damage_mult", 1.0)) * float(mv["power"]) * _variance()
					+ party_max * float(mv.get("pct", 0.0))) * (1.0 - c))))
				var ecrit := _crit_roll("enemy")
				if ecrit > 1.0:
					d = int(round(d * ecrit))
				party_hp = maxi(0, party_hp - d)
				_ev({"t": "enemy_hit", "dmg": d, "move": mv["name"], "cut": c, "hp": party_hp, "crit": ecrit > 1.0})
				log.append("%s【%s】 我军受到 %d 伤害%s%s%s" % [data["name"], mv["name"], d,
					("（减伤 %d%%）" % int(round(c * 100))) if c > 0.0 else "", "（无视防御！）" if mv.get("pierce", false) else "",
					"[color=red]　暴击！[/color]" if ecrit > 1.0 else ""])

				if party_hp > 0:
					log.append_array(_counter_strike())
			else:
				_ev({"t": "enemy_move", "move": mv["name"]})
				log.append("%s【%s】" % [data["name"], mv["name"]])
			_check_end()  # either side at 0 HP (a counter can kill it too): the rest of the move never happens
			if result != "":
				return log
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
				_ev({"t": "enemy_ap_drain", "amount": int(mv["ap_drain"])})
				log.append("[color=red]  下回合我军 AP -%d[/color]" % int(mv["ap_drain"]))
			if mv.has("burn_party"):
				party_burn = {"dmg": int(round(party_max * float(mv["burn_party"]))), "turns": int(mv.get("turns", 3))}
				_ev({"t": "enemy_burn_party", "dmg": party_burn["dmg"], "turns": party_burn["turns"]})
				log.append("[color=red]  我军陷入灼烧！每回合 -%d（%d 回合）[/color]" % [party_burn["dmg"], party_burn["turns"]])
			if mv.has("poison_party"):  # stacks up to poison_max layers; a new dose refreshes the count
				party_poison["layers"] = mini(int(mv.get("poison_max", 3)), int(party_poison["layers"]) + 1)
				party_poison["pct"] = maxf(float(party_poison["pct"]), float(mv["poison_party"]))
				party_poison["turns"] = maxi(int(party_poison["turns"]), int(mv.get("turns", 3)))
				_ev({"t": "enemy_poison_party", "layers": party_poison["layers"], "turns": party_poison["turns"]})
				log.append("[color=red]  我军中毒 ×%d！每回合 -%d%% 最大体力（%d 回合）[/color]" % [party_poison["layers"],
					int(round(float(party_poison["pct"]) * party_poison["layers"] * 100)), party_poison["turns"]])
			if mv.has("confuse") and mods.get("calm", 0) <= 0 and rng.randf() < float(mv["confuse"]):
				var victim: Dictionary = leaders[rng.randi_range(0, leaders.size() - 1)]
				victim["confuse_next"] = true
				_ev({"t": "confuse", "unit": leaders.find(victim)})
				log.append("  %s 陷入混乱，下回合无法行动" % unit_name(victim))
	enemy["intents"] = []
	if not enemy["guard"].is_empty() and result == "":  # the 前卫 strikes too, every enemy turn (even with its boss stunned)
		var g: Dictionary = enemy["guard"]
		var gd := maxi(1, int(round(float(enemy["at"]) * float(db.battle.get("damage_mult", 1.0)) * float(g["strike"]) * _variance() * (1.0 - cut))))
		party_hp = maxi(0, party_hp - gd)
		_ev({"t": "enemy_hit", "dmg": gd, "move": "%s·普攻" % g["name"], "cut": cut, "hp": party_hp, "guard": true})
		log.append("%s 普通攻击，我军受到 %d 伤害" % [g["name"], gd])
		if party_hp > 0:
			log.append_array(_counter_strike())
		_check_end()
		if result != "":
			return log
	if not was_stunned and result == "":
		log.append_array(_affix_status())
	if not enemy["shield"].is_empty() and result == "":  # 回盾 (user rule): a shield nobody hit this round mends battle.shield_regen of the enemy's max HP
		var sd: Dictionary = enemy["shield"]
		if not sd.get("hit", false) and int(sd["hp"]) < int(sd["max_hp"]):
			var add := mini(int(sd["max_hp"]) - int(sd["hp"]), maxi(1, int(round(float(enemy["max_hp"]) * float(db.battle.get("shield_regen", 0.0))))))
			if add > 0 and float(db.battle.get("shield_regen", 0.0)) > 0.0:
				sd["hp"] = int(sd["hp"]) + add
				_ev({"t": "shield_regen", "add": add, "hp": sd["hp"], "max": sd["max_hp"]})
				log.append("  %s 的护盾没挨打，回复 %d（%d/%d）" % [enemy["data"]["name"], add, sd["hp"], sd["max_hp"]])
		sd["hit"] = false
	if enemy["break_turns"] > 0:
		enemy["break_turns"] -= 1
		if enemy["break_turns"] == 0:
			enemy["break_amount"] = 0.0
	if enemy["resist_turns"] > 0:
		enemy["resist_turns"] -= 1
		if enemy["resist_turns"] == 0:
			enemy["resist_down"] = 0.0
	if round_no >= turn_limit:
		result = "lose"
		lose_reason = "turns"
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
			_ev({"t": "enemy_burn_party", "dmg": dmg, "turns": party_burn["turns"]})
			log.append("[color=red]  【%s】我军灼烧！每回合 -%d（%d 回合）[/color]" % [nm, dmg, party_burn["turns"]])
	if afx.has("ap_drain"):
		ap_drain += int(afx["ap_drain"])
		_ev({"t": "enemy_ap_drain", "amount": int(afx["ap_drain"])})
		log.append("[color=red]  【%s】下回合我军 AP -%d[/color]" % [nm, int(afx["ap_drain"])])
	return log


func passive_scale(u: Dictionary) -> float:
	## a troop trick is as big as the card behind it: 1.0 at battle.passive_ref_power (攻 + 体力 / 2), in proportion above and below
	var ref := maxf(1.0, float(db.battle.get("passive_ref_power", 500)))
	return clampf(float(SaveData.leader_power(u["leader"])) / ref, 0.4, 2.5)


func proc_chance(troop: String) -> float:
	## a troop's own small chance (battle.passive_chance) plus what 宝物 add for it (mods.proc {troop: share})
	return float(db.battle.get("passive_chance", 0.15)) + float(mods.get("proc", {}).get(troop, 0.0))


func _counter_strike() -> Array:
	## 反击: answer one enemy hit with every counter set up this round
	var log: Array = []
	for c in counters:
		if enemy["hp"] <= 0:
			break
		var d := _land(_dmg(float(c["at"]) * float(c["power"]) * (1.0 + float(buff["atk"])), "attack"), "attack", false)
		_ev({"t": "counter", "unit": c["name"], "slot": int(c.get("unit", -1)), "dmg": d, "hp": enemy["hp"]})
		log.append("  %s 反击，造成 %d 伤害" % [c["name"], d])
	for k in leaders.size():  # 枪兵: a spear leader sometimes hits back by itself (宝物 raise the chance), no AP
		var u: Dictionary = leaders[k]
		if enemy["hp"] <= 0:
			break
		if u["leader"]["card"]["troop"] == "spear" and not u["confused"] and not u.get("slain", false) and (u.get("sure_counter", false) or rng.randf() < proc_chance("spear")):
			_ev({"t": "passive", "unit": k, "name": unit_name(u), "text": "顺势反击"})
			var d2 := _land(_dmg(float(SaveData.leader_power(u["leader"])) * float(db.battle.get("counter_power", 0.3)) * (1.0 + float(buff["atk"])), "attack"), "attack", false)
			_ev({"t": "counter", "unit": unit_name(u), "slot": k, "dmg": d2, "hp": enemy["hp"]})
			log.append("  %s 顺势反击，造成 %d 伤害" % [unit_name(u), d2])
	_check_end()
	return log


func _ambush() -> Array:
	## 埋伏: every enemy action lands once before the party can move (never kills outright).
	var data: Dictionary = enemy["data"]
	var log: Array = ["[color=red]埋伏！%s 抢先出手[/color]" % data["name"]]
	for _a in int(data["actions"]):
		var mv: Dictionary = data["moves"][0]
		var d := maxi(1, int(round(enemy["at"] * float(db.battle.get("damage_mult", 1.0)) * float(mv["power"]) * _variance() * (1.0 - float(mods.get("guard", 0.0))))))
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
	ap = mini(ap_max(), ap + int(cfg["ap_per_round"]) + int(mods.get("ap_round", 0)))
	if ap_drain > 0:
		_ev({"t": "ap_drain", "amount": mini(ap_drain, ap), "ap": maxi(0, ap - ap_drain)})
		ap = maxi(0, ap - ap_drain)
		ap_drain = 0
	combo = 0
	guard_cut = 0.0
	guarded_this_round = false
	counters = []
	swaps_done = 0
	if buff["turns"] > 0:
		buff["turns"] -= 1
		if buff["turns"] == 0:
			buff = {"layers": 0, "turns": 0, "atk": 0.0, "def": 0.0, "magic": 0.0}
	_ev({"t": "round", "n": round_no, "ap": ap})
	var log: Array = ["─── 第 %d 回合 ───" % round_no]
	for k in leaders.size():  # each troop's own small-chance trick (battle.json passive_chance + 宝物), no AP
		var pu: Dictionary = leaders[k]
		var ptr: String = pu["leader"]["card"]["troop"]
		if ptr in ["lord", "cavalry", "spear"] or pu.get("slain", false) or rng.randf() >= proc_chance(ptr):
			continue
		log.append_array(_troop_trick(k))
	for u in leaders:
		u["acted"] = false
		u["sure_counter"] = false
		u["confused"] = u["confuse_next"]
		u["confuse_next"] = false
		if not u["boosted"] and not u.get("slain", false) and u["idle_rounds"] >= int(cfg["boost_idle_rounds"]) and rng.randf() < float(cfg["boost_chance"]):
			u["boosted"] = true
			_ev({"t": "boost", "units": [leaders.find(u)], "idle": true})
			log.append("%s 蓄势已久 —— BOOST！" % unit_name(u))
	for k in leaders.size():
		var u: Dictionary = leaders[k]
		var raid := float(cfg.get("interrupt_by_troop", {}).get(u["leader"]["card"]["troop"], cfg["interrupt_chance"])) + (float(mods.get("raid", 0.0)) if u["leader"]["card"]["troop"] == "cavalry" else 0.0)  # 突袭 (宝物 raise the cavalry's)
		if not u["leader"]["members"].is_empty() and not u.get("slain", false) and enemy["hp"] > 0 and rng.randf() < raid:
			log.append_array(_raid(k))
	_check_end()
	if result == "":
		_plan_intents()
	return log


func _raid(k: int, lead := "插入！") -> Array:
	## 突袭: one member of the unit (the leader himself when it has none) strikes for interrupt_power × its attack, +1 连击
	var u: Dictionary = leaders[k]
	if enemy["hp"] <= 0:
		return []
	var members: Array = u["leader"]["members"]
	var m: Dictionary = members[rng.randi_range(0, members.size() - 1)] if not members.is_empty() \
		else {"name": unit_name(u), "at": u["leader"]["at"]}
	var kind := "magic" if str(u["leader"]["card"]["troop"]) == "strategist" else "attack"  # 策士 strike with magic (user rule): magic resist, past the 前卫
	var d := 0
	if split_share(u) > 0.0:  # 弓兵 / 贼: half and half, like all their blows
		d = int(_split_blow(float(m["at"]) * float(db.battle["interrupt_power"]), 1.0, split_share(u), false)["d"])
	else:
		d = _land(_dmg(float(m["at"]) * float(db.battle["interrupt_power"]), kind), kind, false)
	combo += 1
	_ev({"t": "interrupt", "unit": k, "member": m["name"], "dmg": d, "hp": enemy["hp"], "kind": kind})
	return ["%s%s部队的 %s 突袭，造成 %d 伤害" % [lead, unit_name(u), m["name"], d]]


func _troop_trick(k: int) -> Array:
	## a troop's small trick (no AP): rolled each round by `_start_round`, sure on a 登场 (`_entry_trick`). Its size follows the card (passive_scale)
	var pu: Dictionary = leaders[k]
	var pname := unit_name(pu)
	var ps := passive_scale(pu)  # the card's whole strength (攻 + 体力) sets how much it does
	var log: Array = []
	match str(pu["leader"]["card"]["troop"]):
		"logistics":
			if party_hp > 0 and party_hp < party_max:
				var rh := mini(int(round(party_max * float(db.battle.get("regen_power", 0.03)) * ps * float(db.battle.get("heal_mult", 1.0)))), party_max - party_hp)
				_ev({"t": "passive", "unit": k, "name": pname, "text": "照料伤兵"})
				party_hp += rh
				_ev({"t": "heal", "amt": rh, "hp": party_hp})
				log.append("[color=#7fd88a]  %s 照料伤兵，回复 %d 体力[/color]" % [pname, rh])
		"infantry":
			var gc := minf(0.6, float(db.battle.get("guard_cut", 0.15)) * ps)
			_ev({"t": "passive", "unit": k, "name": pname, "text": "举盾列阵"})
			guard_cut = 1.0 - (1.0 - guard_cut) * (1.0 - gc)
			_ev({"t": "guard", "cut": guard_cut})
			log.append("  %s 举盾列阵：本回合受到伤害 -%d%%" % [pname, int(round(guard_cut * 100))])
		"bandit":
			if not pu["boosted"]:
				pu["boosted"] = true
				_ev({"t": "passive", "unit": k, "name": pname, "text": "一声唿哨"})
				_ev({"t": "boost", "units": [k], "idle": true})
				log.append("  %s 一声唿哨，BOOST！" % pname)
		"strategist":
			var sb: Dictionary = db.battle.get("strategist_buff", {})
			_ev({"t": "passive", "unit": k, "name": pname, "text": "出谋划策"})
			if buff["layers"] < 4:
				buff["layers"] += 1
				buff["atk"] += minf(0.2, float(sb.get("atk", 0.0)) * ps)
				buff["def"] += minf(0.2, float(sb.get("def", 0.0)) * ps)
			buff["turns"] = maxi(int(buff["turns"]), int(sb.get("turns", 2)))
			_ev({"t": "buff", "layers": buff["layers"], "atk": buff["atk"], "def": buff["def"]})
			log.append("  %s 出谋划策：全军攻击上升（战意 ×%d）" % [pname, buff["layers"]])
		"archer":
			var ab: Dictionary = db.battle.get("archer_resist", {})
			_ev({"t": "passive", "unit": k, "name": pname, "text": "射穿甲缝"})
			enemy["resist_down"] = minf(float(ab.get("max", 0.5)), float(enemy["resist_down"]) + float(ab.get("amount", 0.1)) * ps)  # stacks, like the archers' shred
			enemy["resist_turns"] = maxi(enemy["resist_turns"], int(ab.get("turns", 2)))
			_ev({"t": "resist_down", "amount": enemy["resist_down"], "turns": enemy["resist_turns"]})
			log.append("  %s 一箭射穿甲缝：%s 的兵刃、谋略抗性累计 -%d%%（%d 回合）" % [pname, enemy["data"]["name"], int(round(enemy["resist_down"] * 100)), enemy["resist_turns"]])
	return log


func _check_end() -> void:
	if enemy["hp"] <= 0:
		result = "win"
	elif party_hp <= 0:
		result = "lose"
		lose_reason = "wiped"
