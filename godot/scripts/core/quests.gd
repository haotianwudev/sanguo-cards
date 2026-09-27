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
## Damage and cumulative skill costs carry from battle to battle within a quest; they reset at a recover
## square or when the quest ends. Losing restarts the quest; choices already made are remembered.

const TYPES := ["event", "choose", "battle", "treasure", "recover", "recruit"]


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
	if not (kind in ["recruit", "treasure"]) or save.resolved:
		return []
	var db := GameData.get_db()
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
	_auto_resolve(q, save)


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
