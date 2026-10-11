extends SceneTree
## Balance simulation (not a test): plays whole first-lap runs with the bot — real quest flow, real fights, the wear carried between
## battles, the best chest card taken, 战功 spent on 点化 between chapters — and reports per chapter and tier how the fights go.
##   SIM_RUNS=20 SIM_ROUTE=south godot --headless --path godot --script res://tests/sim_balance.gd
## Reading it: win% (per attempt), hp% = the party's HP left when a won fight ends, wear% = HP already lost going in,
## turns = rounds used of the limit. A healthy curve: normal ~85-95% win, elite ~70-85%, boss ~50-75%, and no chapter much easier than the one before.

const TC := preload("res://tests/test_case.gd")

var stats := {}  # "<order>|<quest>|<tier>" -> {n, wins, hp, wear, turns, limit}
var stuck := {}
var finished := 0
var stuck_at := ""
var order: Array = []


func _init() -> void:
	var runs := int(OS.get_environment("SIM_RUNS")) if OS.get_environment("SIM_RUNS") != "" else 10
	var route := OS.get_environment("SIM_ROUTE") if OS.get_environment("SIM_ROUTE") != "" else "south"
	if OS.get_environment("SIM_GROWTH") != "":
		GameData.get_db().battle["scaling"]["growth"] = float(OS.get_environment("SIM_GROWTH"))
	if OS.get_environment("SIM_BASE") != "":
		GameData.get_db().battle["scaling"]["base"] = float(OS.get_environment("SIM_BASE"))
	if OS.get_environment("SIM_STRENGTH") != "":
		GameData.get_db().battle["scaling"]["strength"] = float(OS.get_environment("SIM_STRENGTH"))
	for i in runs:
		_run(i + 1, route)
	_report(runs, route)
	quit()


func _run(seed_value: int, route: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value * 7919
	var s := SaveData.create()
	var db := GameData.get_db()
	var guard_q := 0
	var max_laps := int(OS.get_environment("SIM_LAPS")) if OS.get_environment("SIM_LAPS") != "" else 1
	while guard_q < 14 * max_laps:
		guard_q += 1
		var q: Variant = Quests.current_quest(s)
		if q == null:
			finished += 1
			if s.lap >= max_laps:
				return
			s.run_records.clear()
			s = s.new_lap()
			continue
		Quests.begin(q, s, rng)
		if not order.has(q["id"]):
			order.append(q["id"])
		var fails_here := {}
		for _step in 600:
			var sq := Quests.here(q, s)
			if sq["type"] == "mystery" and not s.resolved:
				var ev := Quests.event_here(q, s, rng)
				var ok: Array = range(ev["options"].size()).filter(func(i): return Quests.option_blocked(s, ev["options"][i]) == "")
				Quests.choose_event(q, s, rng, ok[rng.randi_range(0, ok.size() - 1)] if not ok.is_empty() else 0)
			if (sq["type"] == "battle" or not s.event_battle.is_empty()) and not s.resolved:
				var won: Variant = _fight(q, s, rng, fails_here)
				if won == null:
					stuck[stuck_at] = int(stuck.get(stuck_at, 0)) + 1
					return
				if not won:
					continue
			if not s.resolved or sq["type"] != "battle":
				Quests.offer(q, s, rng)
				var pick := -1
				if sq["type"] == "choose":
					var opts: Array = sq["choose"]
					var open_idx: Array = range(opts.size()).filter(func(i): return not Quests.option_locked(s, opts[i]))
					pick = open_idx[0] if route == "south" or sq["id"] != "era" else 1
					if sq["id"] == "era":
						pick = 0 if route == "south" else 1
					elif sq["id"] == "fate" and open_idx.size() > 1:
						pick = open_idx[1]  # keep 董白: the route that goes on to 长安
				elif not s.offer.is_empty():
					pick = 0
				Quests.resolve(q, s, rng, pick)
				s.offer = []
			s.resolved = true
			var nexts := Quests.next_options(q, s)
			if nexts.is_empty():
				break
			Quests.move(q, s, nexts[rng.randi_range(0, nexts.size() - 1)]["id"], rng)
		# the chapter is done: 战功 → 点化 (lord first), then on to the next
		Quests.pay_merit(q, s)
		var guard := 0
		while guard < 30 and s.merit >= int(db.gacha["merit"]["upgrade"]) and not s.upgradable().is_empty():
			guard += 1
			if Quests.spend_merit(s, "upgrade"):
				s.upgrade(s.upgradable()[0])
		Quests.complete(q, s)


func _fight(q: Dictionary, s: SaveData, rng: RandomNumberGenerator, fails_here: Variant) -> Variant:
	var db := GameData.get_db()
	var f := Quests.battle_here(q, s)
	var sq := Quests.here(q, s)
	s.party = s.auto_party()
	var m := Quests.mods(s)
	var afx := Quests.affix_here(s)
	if not afx.is_empty():
		m["affix"] = afx
	var tier := "boss" if sq["boss"] else ("elite" if sq["elite"] else "normal")
	if sq["lose_goto"] != "":
		tier = "showpiece"
	var wear := float(s.damage) / float(maxi(1, Quests.party_max(s)))
	var b := Battle.start(f["battle"], s.party_leaders(), rng.randi(), s.damage, s.carry_extra, s.carry_uses, f["ambush"], m, s.swap_roster())
	if OS.get_environment("SIM_DEBUG") != "" and tier != "normal":
		print("  [%s %s] party=%s hp=%d enemy=%s hp=%d at=%d relics=%s" % [q["id"], s.square, str(s.party), b.party_max, b.enemy["data"]["name"], b.enemy["max_hp"], int(b.enemy["at"]), str(s.active_relics())])
	TC.bot_fight(b)
	var key := "L%d %d|%s|%s" % [s.lap, order.find(q["id"]), q["id"], tier]
	var st: Dictionary = stats.get(key, {"n": 0, "wins": 0, "hp": 0.0, "wear": 0.0, "turns": 0.0, "limit": 0.0})
	st["n"] += 1
	st["wear"] += wear
	st["turns"] += b.round_no
	st["limit"] += b.turn_limit
	stats[key] = st
	if b.result == "win":
		st["wins"] += 1
		st["hp"] += float(b.party_hp) / float(maxi(1, b.party_max))
		s.record_win(f["battle"])
		var out := b.carry_out()
		s.damage = out[0]
		s.carry_extra.merge(out[1], true)
		s.carry_uses.merge(out[2], true)
		s.run_battles += 1
		if sq["boss"] or sq["elite"]:
			s.run_bosses += 1
		var chest := s.chest_after_battle(rng, b.overkill, sq["boss"] or sq["elite"], [], b.enemy["data"]["card"], float(b.mods.get("chest", 0.0)), q["id"])
		if not chest.is_empty():
			var best := 0
			var rank := {"SSR": 3, "SR": 2, "R": 1}
			for i in chest.size():
				if int(rank.get(chest[i].get("rarity", ""), 0)) > int(rank.get(chest[best].get("rarity", ""), 0)):
					best = i
			s.take(chest[best]["id"])
		Quests.after_win(s)
		return true
	var here_id: String = s.square
	fails_here[here_id] = int(fails_here.get(here_id, 0)) + 1
	if Quests.lose(q, s, rng):
		return true  # a showpiece loss carries the story on
	if int(fails_here[here_id]) > 12:
		stuck_at = q["id"] + ":" + here_id
		return null
	return false


func _report(runs: int, route: String) -> void:
	print("== sim_balance: %s route, %d runs, strength %s growth %s base %s, %d story ends reached" % [route, runs, str(GameData.get_db().battle["scaling"]["strength"]), str(GameData.get_db().battle["scaling"]["growth"]), str(GameData.get_db().battle["scaling"]["base"]), finished])
	var keys := stats.keys()
	keys.sort()
	for k in keys:
		var st: Dictionary = stats[k]
		var parts: PackedStringArray = k.split("|")
		var wins := maxi(1, int(st["wins"]))
		print("%s %-10s %-9s n=%-4d win=%3d%%  hp_left=%3d%%  wear_in=%3d%%  turns=%.1f/%.1f" % [parts[0], parts[1], parts[2], st["n"],
			int(round(100.0 * st["wins"] / st["n"])), int(round(100.0 * st["hp"] / wins)), int(round(100.0 * st["wear"] / st["n"])),
			st["turns"] / st["n"], st["limit"] / st["n"]])
	if not stuck.is_empty():
		print("runs given up (12 losses in a row on one square): " + str(stuck))
