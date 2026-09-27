class_name Quests
extends RefCounted
## Rance X style quest maps (the run map). Pure logic over SaveData.
##
## A quest is a map of squares in columns (x) and rows (y). The party stands on one square, resolves it,
## then steps forward to one of its `next` squares — never back.
##   event    story text (+ portraits, + reward cards)
##   choose   pick one card; that card joins and the path continues at the option's `goto`
##   battle   must win to continue (`boss: true` marks the big one)
##   treasure a chest: several soldier cards shown, keep one
##   recover  restore the shared HP bar and reset cumulative AP costs / once-per-battle skills
##   recruit  a few unowned generals shown, keep one
##   mystery  ？: a random event from the quest's event_pool, rolled on arrival (a new roll every run).
##            Its options can fight (maybe an ambush), hurt, poison (lose a third of HP), heal, give cards or open a pick-one.
## Battle squares may be `elite` (精: tougher, always drops a 3-card chest) or `ambush` (enemy strikes first).
## Damage and cumulative skill costs carry from battle to battle within a quest; they reset at a recover
## square or when the quest ends. Losing restarts the quest; choices already made are remembered.

const TYPES := ["event", "choose", "battle", "treasure", "recover", "recruit", "mystery"]


static func validate(db: GameData) -> void:
	for q in db.quests:
		assert(q["squares"].has(q["start"]), "quest %s: unknown start" % q["id"])
		for s in q["squares"].values():
			var where: String = "quest %s square %s" % [q["id"], s["id"]]
			assert(s["type"] in TYPES, where + ": unknown type " + s["type"])
			var targets: Array = s["next"].duplicate()
			for o in s["choose"]:
				if o["locked"]:
					continue
				targets.append(o["goto"])
				assert(o["card"] == "" or db.cards.has(o["card"]), where + ": unknown card")
			for t in targets:
				assert(q["squares"].has(t), where + ": unknown next " + t)
				assert(q["squares"][t]["x"] > s["x"], where + ": next square must be further right")
			if s["type"] == "battle":
				assert(db.scenarios.has(s["battle"]), where + ": unknown battle")
			for c in s["cards"]:
				assert(db.cards.has(c), where + ": unknown card " + c)
		if q["squares"].values().any(func(s): return s["type"] == "mystery"):
			assert(not q["event_pool"].is_empty(), "quest %s: ？ squares need an event_pool" % q["id"])
		for eid in q["event_pool"]:
			assert(db.events.has(eid), "quest %s: unknown event %s" % [q["id"], eid])
	for ev in db.events.values():
		for o in ev["options"]:
			_validate_effects(db, o["effects"] + o["win"], "event " + ev["id"])


static func _validate_effects(db: GameData, effects: Array, where: String) -> void:
	for e in effects:
		if e.has("battle"):
			assert(db.scenarios.has(e["battle"]), where + ": unknown battle " + e["battle"])
		if e.has("card"):
			assert(db.cards.has(e["card"]), where + ": unknown card " + e["card"])
		if e.has("offer"):
			for c in e["offer"].get("from", []):
				assert(db.cards.has(c), where + ": unknown card " + c)
		if e.has("chance"):
			_validate_effects(db, e.get("then", []) + e.get("else", []), where)


static func current_quest(save: SaveData) -> Variant:
	for q in GameData.get_db().quests:
		if not save.quests_cleared.has(q["id"]):
			return q
	return null


static func ensure_started(save: SaveData) -> Variant:
	var q: Variant = current_quest(save)
	# a save from an older version of the story may stand on a square that no longer exists
	if q != null and (save.quest != q["id"] or not q["squares"].has(save.square)):
		begin(q, save)
	return q


static func begin(q: Dictionary, save: SaveData) -> void:
	save.quest = q["id"]
	save.square = q["start"]
	save.visited = [q["start"]]
	save.resolved = false
	save.offer = []
	save.events = {}
	save.event_battle = {}
	save.event_note = []
	reset_carry(save)
	_auto_resolve(q, save)


static func reset_carry(save: SaveData) -> void:
	save.damage = 0
	save.carry_extra = {}
	save.carry_uses = {}


static func here(q: Dictionary, save: SaveData) -> Dictionary:
	return q["squares"][save.square]


static func next_options(q: Dictionary, save: SaveData) -> Array:
	if not save.resolved:
		return []
	var s := here(q, save)
	if s["type"] == "choose":
		return [q["squares"][save.choices[s["id"]]]]
	return s["next"].map(func(n): return q["squares"][n])


static func offer(q: Dictionary, save: SaveData, rng: RandomNumberGenerator) -> Array:
	## Cards shown on the current recruit (generals) or treasure (soldiers) square — rolled once, then kept.
	var kind: String = here(q, save)["type"]
	var db := GameData.get_db()
	if kind == "mystery" and not save.resolved:
		return save.offer.map(func(c): return db.cards[c])
	if not (kind in ["recruit", "treasure"]) or save.resolved:
		return []
	if save.offer.is_empty():
		var cards: Array
		if kind == "recruit" and not q["recruit_pool"].is_empty():
			cards = q["recruit_pool"].map(func(c): return db.cards[c]).filter(
				func(c): return c["soldier"] or not save.owned.has(c["id"]))
		elif kind == "recruit":
			cards = save.recruit_offer(rng)
		else:
			cards = SaveData.chest_offer(rng, int(db.gacha["chest_cards"]), q["soldier_pool"])
		save.offer = cards.map(func(c): return c["id"])
	return save.offer.map(func(c): return db.cards[c])


static func resolve(q: Dictionary, save: SaveData, rng: RandomNumberGenerator, choice: int = -1) -> Array:
	## Resolve the current square (battles: only after a win). Returns the cards gained.
	var db := GameData.get_db()
	var s := here(q, save)
	var gained: Array = []
	if save.resolved:
		return gained
	match s["type"]:
		"event":
			for cid in s["cards"]:
				gained.append(db.cards[cid])
				save.grant_card(cid)
		"choose":
			var opt: Dictionary = s["choose"][choice]
			assert(not opt["locked"], "locked choice")
			save.choices[s["id"]] = opt["goto"]
			if opt["card"] != "":
				if not save.has_card(opt["card"]):
					gained.append(db.cards[opt["card"]])
				save.grant_card(opt["card"])
		"treasure", "recruit":
			if not save.offer.is_empty() and choice >= 0:
				gained.append(save.take(save.offer[choice]))
			save.offer = []
		"mystery":
			# called after the event's fight was won, or with the pick from the pick-one it opened
			if not save.event_battle.is_empty():
				var won: Dictionary = save.event_battle
				save.event_battle = {}
				var out := _apply(won["win"], q, save, rng)
				gained.append_array(out["gained"])
				save.event_note.append_array(out["log"])
				if not save.offer.is_empty():
					return gained  # the victory opened a pick-one: resolved once it's taken
			if not save.offer.is_empty() and choice >= 0:
				var got := save.take(save.offer[choice])
				gained.append(got)
				save.event_note.append("获得：" + got["name"])
			save.offer = []
		"recover":
			reset_carry(save)
	save.resolved = true
	return gained


static func move(q: Dictionary, save: SaveData, square_id: String) -> void:
	var ok := next_options(q, save).any(func(s): return s["id"] == square_id)
	assert(ok, "cannot move to " + square_id)
	save.square = square_id
	save.visited.append(square_id)
	save.resolved = false
	save.offer = []
	save.event_battle = {}
	save.event_note = []
	_auto_resolve(q, save)


# ---- ？ squares ------------------------------------------------------------------

static func event_here(q: Dictionary, save: SaveData, rng: RandomNumberGenerator) -> Dictionary:
	## The event on the current ？ square: rolled on arrival, kept for the run, never one already met this run.
	var s := here(q, save)
	if s["type"] != "mystery":
		return {}
	if not save.events.has(s["id"]):
		var seen: Array = save.events.values()
		var fresh: Array = q["event_pool"].filter(func(e): return not seen.has(e))
		if fresh.is_empty():
			fresh = q["event_pool"]
		save.events[s["id"]] = fresh[rng.randi_range(0, fresh.size() - 1)]
	return GameData.get_db().events[save.events[s["id"]]]


static func choose_event(q: Dictionary, save: SaveData, rng: RandomNumberGenerator, i: int) -> Dictionary:
	## Take option i of the current event. Returns {gained, log}. Afterwards the square is either resolved,
	## waiting for a fight (save.event_battle) or waiting for a pick (save.offer).
	var ev := event_here(q, save, rng)
	var opt: Dictionary = ev["options"][i]
	save.event_note = ["你选择了：" + opt["label"]]
	var out := _apply(opt["effects"], q, save, rng)
	save.event_note.append_array(out["log"])
	if not save.event_battle.is_empty():
		save.event_battle["win"] = opt["win"]
	elif save.offer.is_empty():
		save.resolved = true
	return out


static func battle_here(q: Dictionary, save: SaveData) -> Dictionary:
	## What fighting on the current square means: {battle, boss (always a chest), ambush}.
	var s := here(q, save)
	if s["type"] == "mystery":
		return {"battle": save.event_battle.get("battle", ""), "boss": false,
			"ambush": save.event_battle.get("ambush", false)}
	return {"battle": s["battle"], "boss": s["boss"] or s["elite"], "ambush": s["ambush"]}


static func party_max(save: SaveData) -> int:
	var hp := 0
	for ld in save.party_leaders():
		hp += int(ld["hp"])
	return hp


static func _apply(effects: Array, q: Dictionary, save: SaveData, rng: RandomNumberGenerator) -> Dictionary:
	## Event effects, in order. damage / heal are fractions of the party's full HP.
	var db := GameData.get_db()
	var out := {"gained": [], "log": []}
	var top := party_max(save)
	for e in effects:
		if e.has("say"):
			out["log"].append(str(e["say"]).replace("{lord}", save.lord_name))
		if e.has("damage"):
			var d := mini(int(round(top * float(e["damage"]))), maxi(0, top - 1 - save.damage))
			save.damage += d
			out["log"].append("体力 -%d" % d)
		if e.has("heal"):
			var h := mini(save.damage, int(round(top * float(e["heal"]))))
			save.damage -= h
			out["log"].append("体力 +%d" % h)
		if e.has("rest"):
			reset_carry(save)
			out["log"].append("体力全满，技能次数恢复")
		if e.has("poison"):  # 中毒: lose a third of full HP
			var d := mini(int(round(top / 3.0)), maxi(0, top - 1 - save.damage))
			save.damage += d
			out["log"].append("中毒！体力 -%d" % d)
		if e.has("card"):
			var c: Dictionary = db.cards[e["card"]]
			if c["soldier"] or not save.has_card(c["id"]):
				save.grant_card(c["id"])
				out["gained"].append(c)
				out["log"].append("获得：" + c["name"])
		if e.has("soldier"):
			var pool: Array = q["soldier_pool"]
			if pool.is_empty():
				pool = db.soldier_cards().map(func(c): return c["id"])
			var c: Dictionary = db.cards[pool[rng.randi_range(0, pool.size() - 1)]]
			save.grant_card(c["id"])
			out["gained"].append(c)
			out["log"].append("获得：" + c["name"])
		if e.has("offer"):
			# pick one: {"from": [card ids], "n": 3} (owned generals left out), {"generals": true} (any unowned,
			# rolled like a recruit) or {"soldiers": n} from the chest pool
			var o: Dictionary = e["offer"]
			var ids: Array = []
			if o.has("from"):
				var left: Array = o["from"].filter(func(c): return db.cards[c]["soldier"] or not save.has_card(c))
				while not left.is_empty() and ids.size() < int(o.get("n", 3)):
					ids.append(left.pop_at(rng.randi_range(0, left.size() - 1)))
			elif o.has("generals"):
				ids = save.recruit_offer(rng).map(func(c): return c["id"])
			else:
				ids = SaveData.chest_offer(rng, int(o.get("soldiers", 3)), q["soldier_pool"]).map(func(c): return c["id"])
			save.offer = ids
			if ids.is_empty():
				out["log"].append("……可惜，什么也没有。")
		if e.has("battle"):
			save.event_battle = {"battle": e["battle"], "ambush": e.get("ambush", false), "win": []}
		if e.has("chance"):
			var branch: Array = e.get("then", []) if rng.randf() < float(e["chance"]) else e.get("else", [])
			var sub := _apply(branch, q, save, rng)
			out["gained"].append_array(sub["gained"])
			out["log"].append_array(sub["log"])
	return out


static func _auto_resolve(q: Dictionary, save: SaveData) -> void:
	var s := here(q, save)
	if s["type"] == "choose" and save.choices.has(s["id"]):
		save.resolved = true


static func complete(q: Dictionary, save: SaveData) -> void:
	if not save.quests_cleared.has(q["id"]):
		save.quests_cleared.append(q["id"])
	save.quest = ""
	reset_carry(save)


static func fail(q: Dictionary, save: SaveData) -> void:
	## Lost a battle: back to the start with full HP. Cards and choices are kept.
	begin(q, save)
