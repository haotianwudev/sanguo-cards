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
## Battle squares may be `elite` (精: tougher, always drops a 3-card chest and a 宝物) or `ambush` (enemy strikes first).
## A ？ square with a fixed `event` always holds that event (险 squares).
## Rogue runs: every attempt at a quest is a run. 宝物 and 险 last for the run; `shuffle` groups of squares
## trade contents at the start of each run (the paths stay, what's on them moves).

const CONTENT := ["type", "label", "battle", "boss", "elite", "ambush", "event"]  # what a shuffle moves
static var _views := {}
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
			if s["lose_goto"] != "":
				targets.append(s["lose_goto"])
			for t in targets:
				assert(q["squares"].has(t), where + ": unknown next " + t)
				assert(q["squares"][t]["x"] > s["x"], where + ": next square must be further right")
			if s["type"] == "battle":
				assert(db.scenarios.has(s["battle"]), where + ": unknown battle")
			if s["event"] != "":
				assert(db.events.has(s["event"]), where + ": unknown event " + s["event"])
			for c in s["cards"]:
				assert(db.cards.has(c), where + ": unknown card " + c)
		if q["squares"].values().any(func(s): return s["type"] == "mystery" and s["event"] == ""):
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
		if e.has("relic") and e["relic"] is String:
			assert(db.relics.has(e["relic"]), where + ": unknown relic " + e["relic"])
		if e.has("chance"):
			_validate_effects(db, e.get("then", []) + e.get("else", []), where)


static func current_quest(save: SaveData) -> Variant:
	if save.replay != "":
		for q in GameData.get_db().quests:
			if q["id"] == save.replay:
				return q
	for q in GameData.get_db().quests:
		# a chapter with requires only comes on the route that earned it (story flags from earlier chapters)
		if not save.quests_cleared.has(q["id"]) and _flags_hold(q.get("requires", ""), save, false):
			return q
	return null


static func ensure_started(save: SaveData, rng: RandomNumberGenerator = null) -> Variant:
	## The quest in progress, laid out for this run (see view()).
	var q: Variant = current_quest(save)
	# a save from an older version of the story may stand on a square that no longer exists
	if q != null and (save.quest != q["id"] or not q["squares"].has(save.square)):
		begin(q, save, rng)
	return view(q, save) if q != null else null


static func begin(q: Dictionary, save: SaveData, rng: RandomNumberGenerator = null) -> void:
	## Start a run. With an rng the shuffle groups are dealt anew; without one the map is as written (tests).
	q = q.get("_raw", q)
	# relics brought from finished chapters start every run; ones found in this chapter reset on a restart
	save.relics = save.kept_relics.filter(func(r): return GameData.get_db().relics.has(r))
	save.danger = int(save.clears.get(q["id"], 0)) if save.replay == q["id"] else 0  # 进阶: replays get harder
	save.run_start = collection(save)
	save.run_battles = 0
	save.run_bosses = 0
	save.run_relics = []
	save.run_records = []
	save.layout = {}
	if rng != null:
		for group in q["shuffle"]:
			var dealt: Array = group.duplicate()
			for i in range(dealt.size() - 1, 0, -1):
				var j := rng.randi_range(0, i)
				var tmp = dealt[i]
				dealt[i] = dealt[j]
				dealt[j] = tmp
			for i in group.size():
				if dealt[i] != group[i]:
					save.layout[group[i]] = dealt[i]
	save.quest = q["id"]
	save.square = q["start"]
	save.visited = [q["start"]]
	# rogue: pick a 天命 for this run, and every elite / boss gets a random 词缀 (only with an rng: tests stay fixed)
	save.fate = ""
	save.fate_offer = []
	save.affixes = {}
	if rng != null:
		var db := GameData.get_db()
		var fs: Array = db.fates.keys()
		for _i in mini(int(db.raw_int("fate_offer", 3)), fs.size()):
			save.fate_offer.append(fs.pop_at(rng.randi_range(0, fs.size() - 1)))
		var afx: Array = db.battle.get("affixes", {}).keys()
		if not afx.is_empty():
			var laid: Dictionary = view(q, save)["squares"]
			for sid in laid:
				if laid[sid]["boss"] or laid[sid]["elite"]:
					save.affixes[sid] = afx[rng.randi_range(0, afx.size() - 1)]
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


static func view(q: Dictionary, save: SaveData) -> Dictionary:
	## The quest as this run sees it: squares in a shuffle group show the contents dealt to them.
	var raw: Dictionary = q.get("_raw", q)
	if save.layout.is_empty() or save.quest != raw["id"]:
		return raw
	var key: String = raw["id"] + JSON.stringify(save.layout)
	if not _views.has(key):
		var v := raw.duplicate()
		v["_raw"] = raw
		v["squares"] = raw["squares"].duplicate()
		for sid in save.layout:
			var s: Dictionary = raw["squares"][sid].duplicate()
			var src: Dictionary = raw["squares"][save.layout[sid]]
			for f in CONTENT:
				s[f] = src[f]
			v["squares"][sid] = s
		_views[key] = v
	return _views[key]


static func mods(save: SaveData) -> Dictionary:
	## Battle modifiers for this run: every 宝物 carried by a unit, plus 险.
	var db := GameData.get_db()
	var out := {"enemy": save.danger * float(db.battle["danger_step"]) + save.difficulty * float(db.battle["difficulty_step"])}
	var sources: Array = save.active_relics().map(func(r): return db.relics[r])
	if save.fate != "" and db.fates.has(save.fate):
		sources.append(db.fates[save.fate])  # 天命 of this run
	for src in sources:
		var m: Dictionary = src["mods"]
		for k in m:
			if m[k] is Dictionary:  # troop_at / troop_hp: {troop: share}
				var sub: Dictionary = out.get(k, {})
				for troop in m[k]:
					sub[troop] = sub.get(troop, 0.0) + float(m[k][troop])
				out[k] = sub
			else:
				out[k] = out.get(k, 0.0) + float(m[k])
	return out


static func pick_fate(save: SaveData, i: int) -> Dictionary:
	## take one of this run's offered 天命
	save.fate = save.fate_offer[i]
	save.fate_offer = []
	return GameData.get_db().fates[save.fate]


static func affix_here(save: SaveData) -> Dictionary:
	## the 词缀 on the current square's enemy ({} if none)
	var id: String = save.affixes.get(save.square, "")
	var all: Dictionary = GameData.get_db().battle.get("affixes", {})
	return all.get(id, {}).merged({"id": id}) if id != "" else {}


static func here(q: Dictionary, save: SaveData) -> Dictionary:
	return view(q, save)["squares"][save.square]


static func next_options(q: Dictionary, save: SaveData) -> Array:
	if not save.resolved:
		return []
	q = view(q, save)
	var s := here(q, save)
	if s["type"] == "choose":
		return [q["squares"][save.choices[s["id"]]]]
	return s["next"].map(func(n): return q["squares"][n]).filter(func(n): return is_open(n, save))


static func is_open(s: Dictionary, save: SaveData) -> bool:
	## A square with requires / unless only exists when the flag says so: a story flag from an earlier chapter, or a
	## line recorded earlier in this run (a choice made in this chapter).
	## Either may be a list: requires needs all of them, unless hides the square when all of them hold.
	return _flags_hold(s["requires"], save, true) and (_as_list(s["unless"]).is_empty() or not _flags_hold(s["unless"], save, true))


static func _as_list(v: Variant) -> Array:
	if v is Array:
		return v
	return [] if str(v) == "" else [str(v)]


static func _flags_hold(v: Variant, save: SaveData, this_run := true) -> bool:
	## every line in v is a story flag (or, with this_run, a line recorded earlier in this run)
	for line in _as_list(v):
		if not (save.flags.has(line) or (this_run and save.run_records.has(line))):
			return false
	return true


static func offer(q: Dictionary, save: SaveData, rng: RandomNumberGenerator) -> Array:
	## Cards shown on the current recruit (generals) or treasure (soldiers) square — rolled once, then kept.
	q = view(q, save)
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
				func(c): return not save.maxed(c["id"]))
		elif kind == "recruit":
			cards = save.recruit_offer(rng)
		else:
			cards = save.chest_mix(rng, int(db.gacha["chest_cards"]) + save.offer_extra(), q["soldier_pool"])
		save.offer = cards.map(func(c): return c["id"])
	return save.offer.map(func(c): return db.cards[c])


static func resolve(q: Dictionary, save: SaveData, rng: RandomNumberGenerator, choice: int = -1) -> Array:
	## Resolve the current square (battles: only after a win). Returns the cards gained.
	q = view(q, save)
	var db := GameData.get_db()
	var s := here(q, save)
	var gained: Array = []
	if save.resolved:
		return gained
	record(save, s["record"])
	match s["type"]:
		"event":
			for cid in s["cards"]:
				if db.cards[cid]["soldier"] or not save.has_card(cid):  # story cards don't stack
					gained.append(db.cards[cid])
					save.grant_card(cid)
		"choose":
			var opt: Dictionary = s["choose"][choice]
			assert(not opt["locked"], "locked choice")
			save.choices[s["id"]] = opt["goto"]
			record(save, opt["record"])
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
				after_win(save)
				var out := _apply(won["win"], q, save, rng)
				gained.append_array(out["gained"])
				save.event_note.append_array(out["log"])
				if not save.offer.is_empty():
					return gained  # the victory opened a pick-one: resolved once it's taken
			if not save.offer.is_empty() and choice >= 0:
				var cid: String = save.offer[choice]
				if save.offer_kind == "upgrade":
					save.upgrade(cid)
					save.event_note.append("%s 升为%s卡！" % [db.cards[cid]["name"], db.gacha["tiers"][save.tier(cid)]["name"]])
				else:
					gained.append(save.take(cid))
					save.event_note.append("获得：" + db.cards[cid]["name"])
				if save.picks_left > 0:  # 三连抽: another pick-one straight away
					save.picks_left -= 1
					save.offer = save.recruit_offer(rng, 0, save.offer_rates).map(func(c): return c["id"])
					if not save.offer.is_empty():
						return gained
			save.offer = []
			save.offer_kind = ""
			save.picks_left = 0
		"recover":
			reset_carry(save)
		"battle":  # called after a win
			after_win(save)
			if s["boss"] or s["elite"]:
				save.run_bosses += 1
			record(save, s["record_win"])
			if s["elite"]:  # pick one of a few 宝物 (the map opens the pick)
				save.offer = relic_offer(save, rng)
				save.offer_kind = "relic"
			elif rng.randf() < float(db.relic_pick["chest_chance"]):  # Rance X: chests hold items too
				gained.append_array(_apply([{"relic": true}], q, save, rng)["gained"])
	save.resolved = true
	return gained


static func move(q: Dictionary, save: SaveData, square_id: String) -> void:
	q = view(q, save)
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
	if s["event"] != "":
		return GameData.get_db().events[s["event"]]
	if not save.events.has(s["id"]):
		var seen: Array = save.events.values()
		for other in q["squares"].values():  # events a square always holds don't come up at random too
			if other["event"] != "":
				seen.append(other["event"])
		var fresh: Array = q["event_pool"].filter(func(e): return not seen.has(e))
		if fresh.is_empty():
			fresh = q["event_pool"]
		save.events[s["id"]] = fresh[rng.randi_range(0, fresh.size() - 1)]
	return GameData.get_db().events[save.events[s["id"]]]


static func option_blocked(save: SaveData, opt: Dictionary) -> String:
	## "" if the event option can be taken, else what's missing (a trade needs something to trade)
	var needs: Dictionary = opt.get("needs", {})
	if save.relics.size() < int(needs.get("relics", 0)):
		return "没有宝物" if save.relics.is_empty() else "宝物不够"
	var soldiers := 0
	for c in save.soldiers:
		soldiers += int(save.soldiers[c])
	if soldiers < int(needs.get("soldiers", 0)):
		return "兵卡不够（要 %d 张）" % int(needs["soldiers"])
	return ""


static func choose_event(q: Dictionary, save: SaveData, rng: RandomNumberGenerator, i: int) -> Dictionary:
	## Take option i of the current event. Returns {gained, log}. Afterwards the square is either resolved,
	## waiting for a fight (save.event_battle) or waiting for a pick (save.offer).
	q = view(q, save)
	var ev := event_here(q, save, rng)
	var opt: Dictionary = ev["options"][i]
	assert(option_blocked(save, opt) == "", "option %s is blocked: %s" % [opt["label"], option_blocked(save, opt)])
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
	q = view(q, save)
	var s := here(q, save)
	if s["type"] == "mystery":
		return {"battle": save.event_battle.get("battle", ""), "boss": false,
			"ambush": save.event_battle.get("ambush", false)}
	return {"battle": s["battle"], "boss": s["boss"] or s["elite"], "ambush": s["ambush"]}


static func record(save: SaveData, line: String) -> void:
	if line != "" and not save.run_records.has(line):
		save.run_records.append(line)


static func collection(save: SaveData) -> Dictionary:
	## card id -> copies owned (generals and soldiers)
	var out := {}
	for cid in save.owned:
		out[cid] = save.copies(cid)
	for cid in save.soldiers:
		out[cid] = int(save.soldiers[cid])
	return out


static func recap(save: SaveData) -> Dictionary:
	## What this run brought: {battles, cards: [[card id, copies gained]], relics, records, danger, difficulty}.
	var now := collection(save)
	var cards: Array = []
	for cid in now:
		var gained: int = now[cid] - int(save.run_start.get(cid, 0))
		if gained > 0:
			cards.append([cid, gained])
	return {"battles": save.run_battles, "cards": cards, "relics": save.run_relics.duplicate(),
		"records": save.run_records.duplicate(), "danger": save.danger, "difficulty": save.difficulty}


static func merit_earned(save: SaveData) -> int:
	var m: Dictionary = GameData.get_db().gacha["merit"]
	return save.run_battles * int(m["per_battle"]) + save.run_bosses * int(m["per_boss"])


static func pay_merit(q: Dictionary, save: SaveData) -> int:
	## Pay out this chapter's 战功 once. Returns what was added (0 if already paid).
	q = q.get("_raw", q)
	if save.merit_paid == q["id"]:
		return 0
	var n := merit_earned(save)
	save.merit += n
	save.merit_paid = q["id"]
	return n


static func spend_merit(save: SaveData, what: String) -> bool:
	## what: "draw" | "upgrade" (costs in gacha.merit)
	var cost: int = int(GameData.get_db().gacha["merit"][what])
	if save.merit < cost:
		return false
	save.merit -= cost
	return true


static func start_replay(q: Dictionary, save: SaveData, rng: RandomNumberGenerator = null) -> void:
	## Replay a finished chapter: the main story's run is parked and comes back when the replay ends.
	q = q.get("_raw", q)
	assert(save.quests_cleared.has(q["id"]), "only finished chapters can be replayed")
	if save.replay == "":
		save.stash_run()
	save.replay = q["id"]
	begin(q, save, rng)


static func stop_replay(save: SaveData) -> void:
	if save.replay != "":
		save.replay = ""
		save.restore_run()


static func interlude(quest_id: String, save: SaveData) -> Array:
	## The scenes to play after finishing a quest, filtered by the player's story flags.
	var scenes: Array = GameData.get_db().interludes.get(quest_id, [])
	return scenes.filter(func(sc):
		return (not sc.has("requires") or save.flags.has(sc["requires"])) \
			and not (sc.has("unless") and save.flags.has(sc["unless"])))


static func after_win(save: SaveData) -> void:
	## 宝物 that act after every victory (酒囊: heal a share of HP).
	var db := GameData.get_db()
	for rid in save.active_relics():
		var share: float = db.relics[rid]["after_win"]
		if share > 0.0:
			save.damage = maxi(0, save.damage - int(round(party_max(save) * share)))


static func party_max(save: SaveData) -> int:
	## the shared HP bar's full size, 宝物 included (传国玉玺, troop items)
	var m := mods(save)
	var hp := 0
	for ld in save.party_leaders():
		hp += int(round(ld["hp"] * (1.0 + float(m.get("troop_hp", {}).get(ld["card"]["troop"], 0.0)))))
	return int(round(hp * (1.0 + float(m.get("hp", 0.0)))))


static func relic_offer(save: SaveData, rng: RandomNumberGenerator) -> Array:
	## A few 宝物 not held yet, drawn by rarity weight (relic_pick in cards.json).
	var db := GameData.get_db()
	var weights: Dictionary = db.relic_pick["weights"]
	var left: Array = db.relics.keys().filter(func(r): return not save.relics.has(r) and db.relics[r]["rarity"] != "story")
	var ids: Array = []
	while not left.is_empty() and ids.size() < int(db.relic_pick["n"]):
		var w: Array = left.map(func(r): return float(weights.get(db.relics[r]["rarity"], 0)))
		var r: String = GameData.weighted_pick(rng, left, w)
		ids.append(r)
		left.erase(r)
	return ids


static func take_relic(save: SaveData, rid: String) -> Dictionary:
	## Keep the picked 宝物 from a relic offer.
	var db := GameData.get_db()
	if not save.relics.has(rid):
		save.relics.append(rid)
	if not save.run_relics.has(rid):
		save.run_relics.append(rid)
	save.offer = []
	save.offer_kind = ""
	return {"id": rid, "name": "宝物·" + db.relics[rid]["name"], "relic": true}


static func _apply(effects: Array, q: Dictionary, save: SaveData, rng: RandomNumberGenerator) -> Dictionary:
	## Event effects, in order. damage / heal are fractions of the party's full HP.
	var db := GameData.get_db()
	var out := {"gained": [], "log": []}
	var top := party_max(save)
	for e in effects:
		if e.has("record"):
			record(save, str(e["record"]))
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
		if e.has("refresh"):  # 重置技能: cumulative AP costs and once-per-battle skills, HP untouched
			save.carry_extra = {}
			save.carry_uses = {}
			out["log"].append("技能重置：累积加价清零，限 1 次技能可以再用")
		if e.has("upgrade") and str(e["upgrade"]) == "random":  # a random general of yours goes up a tier
			var pool: Array = save.owned.filter(func(c): return not save.maxed(c))
			if pool.is_empty():
				out["log"].append("……你还没有能升级的武将。")
			else:
				var cid: String = pool[rng.randi_range(0, pool.size() - 1)]
				save.upgrade(cid)
				out["log"].append("%s 升为%s卡！" % [db.cards[cid]["name"], db.gacha["tiers"][save.tier(cid)]["name"]])
		elif e.has("upgrade"):  # pick one of your generals (not yet 金) to go up a tier
			var mine: Array = save.owned.filter(func(c): return not save.maxed(c))
			var ids: Array = []
			while not mine.is_empty() and ids.size() < int(e.get("n", 3)):
				ids.append(mine.pop_at(rng.randi_range(0, mine.size() - 1)))
			save.offer = ids
			save.offer_kind = "upgrade"
			if ids.is_empty():
				out["log"].append("……你还没有能升级的武将。")
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
				var left: Array = o["from"].filter(func(c): return not save.maxed(c))
				while not left.is_empty() and ids.size() < int(o.get("n", 3)) + save.offer_extra():
					ids.append(left.pop_at(rng.randi_range(0, left.size() - 1)))
			elif o.has("generals"):
				ids = save.recruit_offer(rng, 0, o.get("rates", {})).map(func(c): return c["id"])
				save.picks_left = int(o.get("times", 1)) - 1
				save.offer_rates = o.get("rates", {})
			else:
				ids = SaveData.chest_offer(rng, int(o.get("soldiers", 3)) + save.offer_extra(), q["soldier_pool"]).map(
					func(c): return c["id"])
			save.offer = ids
			if ids.is_empty():
				out["log"].append("……可惜，什么也没有。")
		if e.has("battle"):
			save.event_battle = {"battle": e["battle"], "ambush": e.get("ambush", false), "win": []}
		if e.has("relic"):  # a named 宝物, or true for a random one not held yet
			var rid: String = ""
			if e["relic"] is String:
				rid = e["relic"]
			else:
				var left: Array = db.relics.keys().filter(func(r): return not save.relics.has(r) and db.relics[r]["rarity"] != "story")
				if not left.is_empty():
					rid = left[rng.randi_range(0, left.size() - 1)]
			if rid != "" and not save.relics.has(rid):
				save.relics.append(rid)
				if not save.run_relics.has(rid):
					save.run_relics.append(rid)
				var r: Dictionary = db.relics[rid]
				out["gained"].append({"id": rid, "name": "宝物·" + r["name"], "relic": true})
				out["log"].append("获得宝物：" + r["name"])
		if e.has("drop_relic") and not save.relics.is_empty():  # trade away a random 宝物
			var gone: String = save.relics.pop_at(rng.randi_range(0, save.relics.size() - 1))
			out["log"].append("失去宝物：" + db.relics[gone]["name"])
		if e.has("lose_soldier"):  # lose soldier copies at random
			for _n in int(e["lose_soldier"]):
				var have: Array = save.soldiers.keys().filter(func(c): return save.soldiers[c] > 0)
				if have.is_empty():
					break
				var cid: String = have[rng.randi_range(0, have.size() - 1)]
				save.soldiers[cid] -= 1
				if save.soldiers[cid] <= 0:
					save.soldiers.erase(cid)
					save.party.erase(cid)
				out["log"].append("失去兵卡：" + db.cards[cid]["name"])
		if e.has("difficulty"):
			save.difficulty += int(e["difficulty"])
			out["log"].append("难度上升到 %d！今后所有敌人 +%d%%，宝箱里的武将也更多了" % [save.level(),
				int(round(save.difficulty * float(db.battle["difficulty_step"]) * 100))])
		if e.has("danger"):
			save.danger += int(e["danger"])
			out["log"].append("险！本轮之后的敌人体力和攻击 +%d%%" % int(round(save.danger * float(db.battle["danger_step"]) * 100)))
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
	q = q.get("_raw", q)
	save.clears[q["id"]] = int(save.clears.get(q["id"], 0)) + 1
	if save.replay == q["id"]:  # a replay: cards and 战功 stay, the story carries on where it was
		save.replay = ""
		save.restore_run()
		return
	if not save.quests_cleared.has(q["id"]):
		save.quests_cleared.append(q["id"])
	for line in save.run_records:  # this run's choices become lasting story flags
		if not save.flags.has(line):
			save.flags.append(line)
	save.kept_relics = save.relics.duplicate()  # every 宝物 goes on to the next chapter
	save.quest = ""
	reset_carry(save)


static func lose(q: Dictionary, save: SaveData, rng: RandomNumberGenerator = null) -> bool:
	## Lost a battle. A square with lose_goto (虎牢关 吕布) isn't a defeat: the story carries on there, HP
	## restored. Otherwise the run fails. Returns true when the story carries on.
	q = view(q, save)
	var s := here(q, save)
	if s["lose_goto"] == "":
		fail(q, save, rng)
		return false
	record(save, s["record_lose"])
	reset_carry(save)
	save.square = s["lose_goto"]
	save.visited.append(s["lose_goto"])
	save.resolved = false
	save.offer = []
	return true


static func fail(q: Dictionary, save: SaveData, rng: RandomNumberGenerator = null) -> void:
	## Lost a battle: a new run from the start with full HP (宝物 and 险 gone, squares dealt again).
	## Cards and choices are kept.
	begin(q, save, rng)
