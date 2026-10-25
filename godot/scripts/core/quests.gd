class_name Quests
extends RefCounted
## Rance X style quest maps (the run map). Pure logic over SaveData.
##
## A quest is a map of squares in columns (x) and rows (y). The party stands on one square, resolves it,
## then steps forward to one of its `next` squares — never back.
##   event    story text (+ portraits, + reward cards / relics, + `difficulty` raised on arrival)
##   choose   pick one card; that card joins and the path continues at the option's `goto`
##   battle   must win to continue (`boss: true` marks the big one)
##   treasure a chest: several soldier cards shown, keep one
##   recover  restore the shared HP bar and reset cumulative AP costs / once-per-battle skills
##   recruit  a few unowned generals shown, keep one (the square may have lines of its own first, and its own recruit_pool / prompt)
##   mystery  ？: a random event from the quest's event_pool, rolled on arrival (a new roll every run).
##            Its options can fight (maybe an ambush), hurt, poison (lose a third of HP), heal, give cards or open a pick-one.
## Battle squares may be `elite` (精: tougher, always drops a 3-card chest and a 宝物) or `ambush` (enemy strikes first).
## A ？ square with a fixed `event` always holds that event (only the designed 高级宝箱 now; story beats are plain `event` squares).
## Rogue runs: every attempt at a quest is a run. 宝物 and 险 last for the run; `shuffle` groups of squares
## trade contents at the start of each run (the paths stay, what's on them moves).

const CONTENT := ["type", "label", "battle", "boss", "elite", "ambush", "event", "text", "portraits", "cg", "prompt", "soldier_pool", "recruit_pool"]  # what a shuffle moves (a square's own pools belong to its place)
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
			for r in s["relics"]:
				assert(db.relics.has(r), where + ": unknown relic " + r)
		for eid in q["event_pool"]:
			assert(db.events.has(eid), "quest %s: unknown event %s" % [q["id"], eid])
		var scopes: Array = [q["event_scope"], q["id"]] + q["pool_overrides"].map(func(o): return o["event_scope"]).filter(func(s): return s != "")
		if q["squares"].values().any(func(s): return s["type"] == "mystery" and s["event"] == ""):
			var covered: bool = not q["event_pool"].is_empty() or db.events.values().any(func(e): return e["scope"] in scopes)
			assert(covered, "quest %s: ？ squares need an event_pool/event_scope" % q["id"])
		for o in q["pool_overrides"]:
			for c in o["recruit_pool"]:
				assert(db.cards.has(c), "quest %s: unknown card %s in a pool override" % [q["id"], c])
			assert(o["soldier_scope"] == "" or o["soldier_scope"] in ["south", "north"], "quest %s: unknown soldier_scope in a pool override" % q["id"])
		assert(q["soldier_scope"] == "" or q["soldier_scope"] in ["south", "north"], "quest %s: unknown soldier_scope" % q["id"])
	var quest_ids: Array = db.quests.map(func(q): return q["id"])
	for eid in db.events:
		var scope: String = db.events[eid]["scope"]
		assert(scope in ["universal", "south", "north"] or scope in quest_ids, "event %s: unknown scope" % eid)
	for cid in db.cards:
		var cscope: String = db.cards[cid].get("scope", "")
		assert(cscope in ["", "south", "north"], "card %s: unknown scope" % cid)
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
		# a chapter with requires only comes on the route that earned it (story flags from earlier chapters);
		# unless hides it on a route that earned something else (e.g. the other birthplace)
		if not save.quests_cleared.has(q["id"]) and _flags_hold(q.get("requires", ""), save, false) \
				and not (q.get("unless", "") != "" and _flags_hold(q["unless"], save, false)):
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
	save.steps = []
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
	save.ambushes = {}
	if rng != null:
		var db := GameData.get_db()
		var fs: Array = db.fates.keys().filter(func(f): return not db.fates[f]["rarity"] in ["bad", "divine"])  # 凶 / 天授 fates only come from events
		for _i in mini(int(db.raw_int("fate_offer", 3)), fs.size()):
			save.fate_offer.append(fs.pop_at(rng.randi_range(0, fs.size() - 1)))
		var afx: Array = db.battle.get("affixes", {}).keys()
		if not afx.is_empty():
			var laid: Dictionary = view(q, save)["squares"]
			for sid in laid:
				if laid[sid]["boss"] or laid[sid]["elite"]:
					save.affixes[sid] = afx[rng.randi_range(0, afx.size() - 1)]
		var chance := float(db.battle.get("ambush_chance", 0.5))  # ordinary fights: about half are an 埋伏, different every run
		var laid2: Dictionary = view(q, save)["squares"]
		for sid in laid2:
			var sq: Dictionary = laid2[sid]
			if sq["type"] == "battle" and not sq["boss"] and not sq["elite"] and rng.randf() < chance:
				save.ambushes[sid] = true
	save.resolved = false
	save.offer = []
	save.events = {}
	save.event_rolls = {}
	save.event_battle = {}
	save.event_note = []
	if rng != null:
		_roll_events(q, save, rng)  # which ？ event waits where is known from the start (the map names it); how it turns out is chance
	reset_carry(save)
	_auto_resolve(q, save)
	# remember how the chapter began (once per chapter: a lost first square calls begin again and must not overwrite it)
	if str(save.chapter_start.get("quest", "")) != q["id"] or str(save.chapter_start.get("replay", "")) != save.replay:
		save.chapter_start = save.snapshot()


static func _roll_events(q: Dictionary, save: SaveData, rng: RandomNumberGenerator) -> void:
	## deal this run's ？ squares their events up front, none twice
	var v: Dictionary = view(q, save)
	var pool: Array = pools(v, save)["event_pool"]
	var seen: Array = []
	for s in v["squares"].values():
		if s["event"] != "":
			seen.append(s["event"])
	var ids: Array = v["squares"].values().filter(func(s): return s["type"] == "mystery" and s["event"] == "")
	ids.sort_custom(func(a, b): return a["x"] < b["x"] or (a["x"] == b["x"] and a["y"] < b["y"]))
	for s in ids:
		var fresh: Array = pool.filter(func(e): return not seen.has(e))
		if fresh.is_empty():
			fresh = pool
		if fresh.is_empty():
			return
		var pick: String = fresh[rng.randi_range(0, fresh.size() - 1)]
		save.events[s["id"]] = pick
		seen.append(pick)


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


static func ramp(save: SaveData) -> float:
	## the climb in enemy strength: every chapter finished this lap (battle.chapter_step; not while replaying an old chapter, which
	## has its own 进阶) plus a step for every 难度 level above 1 that is being played (battle.ending_step; the level is capped per
	## route by the endings it has unlocked — south and north count apart)
	var db := GameData.get_db()
	var chapters := 0 if save.replay != "" else save.quests_cleared.size()
	return chapters * float(db.battle.get("chapter_step", 0.0)) + (save.effective_level() - 1) * float(db.battle.get("ending_step", 0.0))


static func _enemy_power(battle_id: String) -> float:
	var db := GameData.get_db()
	var e: Dictionary = db.enemies[db.scenarios[battle_id]["enemy"]]
	return float(e["hp"]) * float(e["at"]) * float(e["actions"])


static func _chapter_power(order: float, qid: String) -> float:
	var cfg: Dictionary = GameData.get_db().battle.get("scaling", {})
	return 1000000.0 * float(cfg["strength"]) * float(cfg["base"]) * pow(order + float(cfg.get("offset", 1.0)), float(cfg["exponent"])) * float(cfg.get("chapter", {}).get(qid, cfg.get("chapter_default", 1.0)))


static func target_power(qid: String, t := 0.0) -> float:
	## battle.scaling — the one formula, which only sets the overall difficulty: a chapter's first column sits on 1e6 × `strength` × `base` × (chapter order + `offset`)^`exponent`
	## (× the chapter's coefficient), its last column on the same formula one chapter later, and the columns between them are interpolated (`t` = 0..1 along the chapter),
	## so a chapter ends where the next one begins (the 序章 climbs too). 0 = no curve for this chapter
	var cfg: Dictionary = GameData.get_db().battle.get("scaling", {})
	if not cfg.get("order", {}).has(qid):
		return 0.0
	var n := float(cfg["order"][qid])
	return lerpf(_chapter_power(n, qid), _chapter_power(n + 1.0, qid), clampf(t, 0.0, 1.0))


static func _position_t(q: Dictionary, x: int) -> float:
	## how far along the chapter column `x` is, 0 (first column) .. 1 (last)
	var raw: Dictionary = q.get("_raw", q)
	var max_x := 1
	for s in raw["squares"].values():
		max_x = maxi(max_x, int(s["x"]))
	return clampf(float(x) / float(max_x), 0.0, 1.0)


static func _scale_for(qid: String, t: float, own: float) -> float:
	## the multiplier on an enemy's hp and attack (power goes with its square) that puts its strength (hp × attack × actions) on the curve at this column: the card
	## itself and the tier (battle.enemy_coef, applied on top) are not part of the formula
	var target := target_power(qid, t)
	if target <= 0.0 or own <= 0.0:
		return 1.0
	return sqrt(target / own)


static func _is_lose_fight(sq: Dictionary, foe_card: String) -> bool:
	var db := GameData.get_db()
	return (sq["lose_goto"] != "" and not sq["beatable"]) or (foe_card != "" and db.cards[foe_card].get("first_win", false))


static func enemy_scales(save: SaveData) -> Array:
	## [hp, attack] coefficients of the fight on the current square: the chapter / position scaling (see _scale_for) times battle.enemy_coef
	## of its tier — 普通 / 精英 / 首领 / 必败 (lose_goto, and every 吕布 fight). hp and attack both take the whole tier coefficient, except 必败 / 吕布 (attack only its square root).
	## [1.0, 1.0] off a battle square
	var db := GameData.get_db()
	if save.quest == "" or db.battle.get("scaling", {}).is_empty():
		return [1.0, 1.0]
	for q in db.quests:
		if q["id"] != save.quest:
			continue
		var sq: Dictionary = view(q, save)["squares"].get(save.square, {})
		if sq.is_empty():
			return [1.0, 1.0]
		var bid: String = sq["battle"] if sq["battle"] != "" else str(save.event_battle.get("battle", ""))
		if bid == "" or not db.scenarios.has(bid):
			return [1.0, 1.0]
		var tier := "boss" if sq["boss"] else ("elite" if sq["elite"] else "normal")
		var coef: Dictionary = db.battle.get("enemy_coef", {})
		var foe_card: String = str(db.enemies[db.scenarios[bid]["enemy"]].get("card", ""))
		if _is_lose_fight(sq, foe_card):  # an unwinnable showpiece, and every fight against 吕布 (a first_win card), is tuned by hand and may be as strong as it likes
			var lc := float(coef.get("lose", 1.0))
			return [lc, sqrt(lc)]
		var c := float(coef.get(tier, 1.0))
		var base := _scale_for(q["id"], _position_t(q, int(sq["x"])), _enemy_power(bid))
		return [base * c, base * c]  # hp and attack both take the tier coefficient: 精英 / 首领 hit as hard as they are tough
	return [1.0, 1.0]


static func enemy_tier(save: SaveData) -> String:
	## "normal" / "elite" / "boss" / "lose" (same rule as enemy_scales) of the fight on the current square; "normal" off a battle square
	var db := GameData.get_db()
	for q in db.quests:
		if q["id"] != save.quest:
			continue
		var sq: Dictionary = view(q, save)["squares"].get(save.square, {})
		if sq.is_empty():
			return "normal"
		var bid: String = sq["battle"] if sq["battle"] != "" else str(save.event_battle.get("battle", ""))
		if bid == "" or not db.scenarios.has(bid):
			return "normal"
		var foe_card: String = str(db.enemies[db.scenarios[bid]["enemy"]].get("card", ""))
		if _is_lose_fight(sq, foe_card):
			return "lose"
		return "boss" if sq["boss"] else ("elite" if sq["elite"] else "normal")
	return "normal"


static func enemy_scale(save: SaveData) -> float:
	return float(enemy_scales(save)[0])


static func mods(save: SaveData) -> Dictionary:
	## Battle modifiers for this run: every 宝物 carried by a unit, plus 险.
	var db := GameData.get_db()
	var out := {"enemy": save.danger * float(db.battle["danger_step"]) + save.difficulty * float(db.battle["difficulty_step"]) + ramp(save),
		"enemy_scale": enemy_scales(save)[0], "enemy_scale_at": enemy_scales(save)[1],
		"enemy_tier": enemy_tier(save)}
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


static func is_ghost(s: Dictionary, save: SaveData) -> bool:
	## a square of a route not taken (or not yet) that the map still draws, greyed, so the fork is visible;
	## ghost_requires (story flags) keeps a route the player has not unlocked from showing at all
	return s["ghost"] and not is_open(s, save) and _flags_hold(s["ghost_requires"], save, false)


static func _as_list(v: Variant) -> Array:
	if v is Array:
		return v
	return [] if str(v) == "" else [str(v)]


static func _ending_active(title: String, save: SaveData) -> bool:
	## an ending's follow-up story only runs at a 难度 at or above the level that ending opens (cards.json endings.*.level)
	for e in GameData.get_db().endings.values():
		if e["title"] == title:
			return save.effective_level() >= int(e["level"])
	return true


static func _flags_hold(v: Variant, save: SaveData, this_run := true) -> bool:
	## every line in v is a story flag (or, with this_run, a line recorded earlier in this run)
	for line in _as_list(v):
		if str(line).contains("结局") and not _ending_active(str(line), save):
			return false  # played below the 难度 this ending opens: what it unlocks stays shut
		if not (save.flags.has(line) or (this_run and save.run_records.has(line))):
			return false
	return true


static func pools(q: Dictionary, save: SaveData, sq: Dictionary = {}) -> Dictionary:
	## `sq` = the square the player stands on: its own soldier_pool / recruit_pool (a place's local cards) win over the chapter's.
	## recruit_pool is swapped by the first matching entry in pool_overrides (requires / unless checked against
	## this run's own records, e.g. a birthplace choice) — so one quest shared by two routes (south/north
	## prologue) doesn't hand out the other route's generals. soldier_pool and event_pool resolve by scope
	## instead: a card/event's own "scope" field ("universal" only for events, "south"/"north", or — events
	## only — the owning quest's own id for a one-off cameo like qiao/yuji) is matched against the quest's
	## soldier_scope/event_scope (also override-able). An empty soldier_scope keeps the legacy behaviour: the
	## quest's own literal soldier_pool list (or, if that's empty too, every soldier card — see save_data.gd's
	## chest_mix/recruit_offer fallback) — see the "_events" note in story.json for why this exists.
	var out := {"recruit_pool": q["recruit_pool"]}
	var soldier_scope: String = q["soldier_scope"]
	var event_scope: String = q["event_scope"]
	for o in q["pool_overrides"]:
		if _flags_hold(o["requires"], save) and not (o["unless"] != "" and _flags_hold(o["unless"], save)):
			if not o["recruit_pool"].is_empty():
				out["recruit_pool"] = o["recruit_pool"]
			if o["soldier_scope"] != "":
				soldier_scope = o["soldier_scope"]
			if o["event_scope"] != "":
				event_scope = o["event_scope"]
	var db := GameData.get_db()
	if soldier_scope != "":  # this route's soldiers that may show up here: the public ones (no faction, no chapter) and this chapter's own
		out["soldier_pool"] = db.cards.values().filter(func(c): return c["soldier"] and not c["beast"] and c.get("scope", "") in ["", soldier_scope] 				and (db.card_chapters.get(c["id"], []).has(q["id"]) or (c.get("faction", "") == "" and (db.is_public(c["id"]) or c.get("public", false))))).map(func(c): return c["id"])
	else:
		out["soldier_pool"] = q["soldier_pool"]
	var event_pool: Array = []
	for eid in db.events:
		# a chapter-only event in a quest both routes share (prologue) also names its route: 二乔 must not turn up after the north birth
		if db.events[eid]["scope"] in ["universal", event_scope, q["id"]] and db.events[eid]["route"] in ["", event_scope]:
			event_pool.append(eid)
	out["event_pool"] = event_pool
	if not sq.is_empty():
		if not sq.get("recruit_pool", []).is_empty():
			out["recruit_pool"] = sq["recruit_pool"]
		if not sq.get("soldier_pool", []).is_empty():
			out["soldier_pool"] = sq["soldier_pool"]
	return out


static func title(q: Dictionary, save: SaveData) -> String:
	## q["title"], swapped by the first matching entry in title_overrides — same reasoning as pools(): a
	## quest shared by two routes (south/north prologue) shouldn't keep showing the other route's chapter name.
	for o in q["title_overrides"]:
		if _flags_hold(o["requires"], save) and not (o["unless"] != "" and _flags_hold(o["unless"], save)):
			return o["title"]
	return q["title"]


static func map_key(q: Dictionary, save: SaveData) -> String:
	## the map background file is normally data/art/map/<quest id>.jpg; map_overrides (same shape as
	## title_overrides) swaps in a different file key for a route that needs its own separate map image
	## instead of sharing the other route's — e.g. prologue's south/north halves are different enough
	## (river town vs. snowy mountains) that one stretched image can't cover both well.
	for o in q["map_overrides"]:
		if _flags_hold(o["requires"], save) and not (o["unless"] != "" and _flags_hold(o["unless"], save)):
			return o["map"]
	return q["id"]


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
		var sq: Dictionary = here(q, save)
		var p := pools(q, save, sq)
		var cards: Array
		if kind == "recruit" and not p["recruit_pool"].is_empty():
			var left: Array = p["recruit_pool"].map(func(c): return db.cards[c]).filter(
				func(c): return not save.maxed(c["id"]))
			cards = []
			if sq["recruit_pool"].is_empty():  # the chapter's whole list is shown (it is short)
				cards = left
			else:  # a place's own list: a few of them each visit
				var n := int(db.gacha["offer_size"]) + save.offer_extra()
				while not left.is_empty() and cards.size() < n:
					cards.append(left.pop_at(rng.randi_range(0, left.size() - 1)))
		elif kind == "recruit":
			cards = save.recruit_offer(rng)
		elif not sq["soldier_pool"].is_empty():  # a place's own soldiers
			cards = SaveData.chest_offer(rng, int(db.gacha["chest_cards"]) + save.offer_extra(), sq["soldier_pool"])
		else:
			cards = save.chest_mix(rng, int(db.gacha["chest_cards"]) + save.offer_extra(), [], q["id"])
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
				if s["card_unless"].has(cid) and _flags_hold(s["card_unless"][cid], save, true):
					continue  # already joined earlier through a choice (e.g. 定计 in 第一章)
				gained.append(db.cards[cid])
				save.grant_card(cid, true)
			for rid in s["relics"]:
				if not save.relics.has(rid):
					save.relics.append(rid)
					save.run_relics.append(rid)
					gained.append({"id": rid, "name": "宝物·" + db.relics[rid]["name"], "relic": true})
			if s["damage"] > 0.0:  # 借粮: a share of the party's full HP lost on arrival (like an event's `damage`)
				var top := party_max(save)
				save.damage += mini(int(round(top * s["damage"])), maxi(0, top - 1 - save.damage))
			save.difficulty += int(s["difficulty"])  # 威震诸侯 / 惊退温侯: beating 吕布 makes the rest harder, no choice
		"choose":
			var opt: Dictionary = s["choose"][choice]
			assert(not option_locked(save, opt), "locked choice")
			save.choices[s["id"]] = opt["goto"]
			record(save, opt["record"])
			for cid in s["cards"]:  # the square's own joiners come whichever way you choose (居巢: 鲁肃)
				gained.append(db.cards[cid])
				save.grant_card(cid, true)
			if opt["card"] != "":
				gained.append(db.cards[opt["card"]])
				save.grant_card(opt["card"], true)
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
			if s["boss"]:  # only a boss drops 宝物: pick one of a few (the map opens the pick); elites and normal fights never do
				save.offer = relic_offer(save, rng)
				save.offer_kind = "relic"
	save.resolved = true
	return gained


static func move(q: Dictionary, save: SaveData, square_id: String, rng: RandomNumberGenerator = null) -> Array:
	## returns the lord cards handed out by this step, each {form, dupe (the lord's level went up), fresh (a card it did not hold)}: a chapter's first step gives its card (grant_lord_form) —
	## the first chapter's is the route's fixed default (every 周目), later chapters' are random; before it the lord has no card
	q = view(q, save)
	var ok := next_options(q, save).any(func(s): return s["id"] == square_id)
	assert(ok, "cannot move to " + square_id)
	save.steps.append(save.snapshot())
	save.square = square_id
	save.visited.append(square_id)
	save.resolved = false
	save.offer = []
	save.event_battle = {}
	save.event_note = []
	_auto_resolve(q, save)
	# only in play (rng given, like the other rogue rolls): the route is known once the start square's birth choice is in
	var given: Array = []
	if rng != null and save.visited.size() == 2:
		var form := grant_lord_form(q, save, rng, q["id"] == GameData.get_db().quests[0]["id"])
		if form != "":
			given.append({"form": form, "dupe": save.lord_form_dupe, "fresh": save.lord_form_fresh})
	return given


static func start_grant(q: Dictionary, save: SaveData, rng: RandomNumberGenerator = null) -> Array:
	## the lord card of a chapter from the second on is handed out on arrival at its first square (the first chapter's comes with its first
	## story square, after the birth choice — see move()); same shape as move()'s result; once per chapter (lord_form_paid)
	q = view(q, save)
	var db := GameData.get_db()
	if rng == null or save.visited.size() != 1 or q["id"] == db.quests[0]["id"]:
		return []
	var form := grant_lord_form(q, save, rng, false)
	return [] if form == "" else [{"form": form, "dupe": save.lord_form_dupe, "fresh": save.lord_form_fresh}]


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
		var ev_pool: Array = pools(q, save)["event_pool"]
		var fresh: Array = ev_pool.filter(func(e): return not seen.has(e))
		if fresh.is_empty():
			fresh = ev_pool
		save.events[s["id"]] = pick_event(q, fresh, rng)
	return GameData.get_db().events[save.events[s["id"]]]


static func event_source(q: Dictionary, eid: String) -> String:
	## which pool a ？ event comes from: this chapter's own (scope = the quest id), the route's (north / south), or the shared one
	var scope: String = GameData.get_db().events[eid]["scope"]
	if scope == q["id"]:
		return "chapter"
	return "universal" if scope == "universal" else "route"


static func pick_event(q: Dictionary, candidates: Array, rng: RandomNumberGenerator) -> String:
	## battle.event_sources weights pick the pool first (chapter / route / universal), then one event in it at random;
	## a pool with nothing left drops out of the draw
	var by := {"chapter": [], "route": [], "universal": []}
	for eid in candidates:
		by[event_source(q, eid)].append(eid)
	var weights: Dictionary = GameData.get_db().battle.get("event_sources", {"chapter": 1, "route": 1, "universal": 1})
	var live: Array = by.keys().filter(func(k): return not by[k].is_empty() and float(weights.get(k, 0)) > 0)
	if live.is_empty():
		return candidates[rng.randi_range(0, candidates.size() - 1)]
	var src: String = GameData.weighted_pick(rng, live, live.map(func(k): return float(weights.get(k, 0))))
	return by[src][rng.randi_range(0, by[src].size() - 1)]


static func rolled_option(save: SaveData, ev: Dictionary, rng: RandomNumberGenerator) -> int:
	## the option the dice landed on for the ？ square the player stands on: rolled once when it is reached and kept, so the button can show it
	if not save.event_rolls.has(save.square):
		save.event_rolls[save.square] = random_option(save, ev, rng)
	return int(save.event_rolls[save.square])


static func random_option(save: SaveData, ev: Dictionary, rng: RandomNumberGenerator) -> int:
	## ？ events are pure chance (battle.event_random): fate picks one of the options that can be taken — each counts `weight` (default 1)
	var total := 0.0
	var open: Array = []
	for i in ev["options"].size():
		if option_blocked(save, ev["options"][i]) == "":
			var w := float(ev["options"][i].get("weight", 1.0))
			open.append([i, w])
			total += w
	if open.is_empty():
		return 0
	var r := rng.randf() * total
	for o in open:
		r -= float(o[1])
		if r < 0.0:
			return int(o[0])
	return int(open[-1][0])


static func option_locked(save: SaveData, o: Dictionary) -> bool:
	## a choose-square option that can't be picked: locked outright, or needing a lasting story flag (an ending reached earlier)
	return o["locked"] or (not _as_list(o["requires"]).is_empty() and not _flags_hold(o["requires"], save, false))


static func option_hint(save: SaveData, o: Dictionary) -> String:
	## why a gated option is greyed ("" when it isn't, or when it is simply locked)
	if _as_list(o["requires"]).is_empty() or not option_locked(save, o):
		return ""
	return "（需先触发「%s」）" % "」「".join(_as_list(o["requires"]).filter(func(l): return not _flags_hold(l, save, false)))


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


static func choose_event(q: Dictionary, save: SaveData, rng: RandomNumberGenerator, i: int, rolled := false) -> Dictionary:
	## Take option i of the current event (rolled: the dice picked it — random_option — and the note says so). Returns {gained, log}.
	## Afterwards the square is either resolved, waiting for a fight (save.event_battle) or waiting for a pick (save.offer).
	q = view(q, save)
	var ev := event_here(q, save, rng)
	var opt: Dictionary = ev["options"][i]
	assert(option_blocked(save, opt) == "", "option %s is blocked: %s" % [opt["label"], option_blocked(save, opt)])
	save.event_note = [("随机到了：" if rolled else "你选择了：") + opt["label"]]
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
	return {"battle": s["battle"], "boss": s["boss"] or s["elite"], "ambush": s["ambush"] or save.ambushes.has(s["id"])}


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


static func grant_lord_form(q: Dictionary, save: SaveData, rng: RandomNumberGenerator = null, default_pick := false) -> String:
	## each chapter hands out one lord card (version) at random from those of this route not yet had (all had: any of them, as another copy of the lord), once;
	## default_pick (the first chapter, every 周目) gives the fixed default card instead: the plain lord (lord_forms.default) (already held: another copy of the lord).
	## returns its id ("" = none left / already given). Without an rng (tests) the first one.
	q = q.get("_raw", q)
	if save.lord_form_paid == q["id"] or save.replay != "":
		return ""
	var db := GameData.get_db()
	var route := "north" if save.is_north() else "south"
	save.lord_form_paid = q["id"]
	var pool: Array = []
	var all: Array = []
	for fid in db.lord_form_grants:
		var f: Dictionary = db.lord_forms.get(fid, {})
		if f.is_empty() or (f["route"] != "" and f["route"] != route):
			continue
		all.append(fid)
		if not save.lord_forms.has(fid):
			pool.append(fid)
	if all.is_empty():
		return ""
	var pick: String = (db.lord_form_default if db.lord_form_default != "" else all[0]) if default_pick else ""
	if not default_pick:
		if pool.is_empty():  # every card of the route is held: a random one again
			pool = all
		pick = pool[rng.randi_range(0, pool.size() - 1)] if rng != null else pool[0]
	# same rule as every card: held now, or had in an earlier 周目 (only the level is kept) → getting it is one more copy for the lord (and a version never had before is one too)
	var held := save.lord_forms.has(pick)
	save.lord_form_fresh = not held
	# the usual rule, per card: a card never had starts at level 1 (铜); handed out again — held now, or had in an earlier 周目 (it comes back at
	# the level it was cleared at) — it gains one. The default card is the plain lord (lord_copies, 1 from the start).
	var had_before := held or save.cleared_forms.has(pick)
	if pick == db.lord_form_default:
		if had_before:
			save.lord_copies += 1
	else:
		save.form_copies[pick] = (int(save.form_copies.get(pick, 0)) if held else int(save.cleared_form_copies.get(pick, 0))) + 1
	save.lord_form_dupe = true
	if not held:
		save.lord_forms.append(pick)
	return pick


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


static func side_stories(save: SaveData, also := "") -> Array:
	## The ？小故事 to list (user rule: each story appears in one chapter only — missed, it waits for the next 周目): those of
	## the chapter just finished (`also` on its end page, else the last chapter cleared — so through the next chapter's 整备).
	## Each comes back with "quest", "read" (opened this 周目: free to read again, no second reward) and "seen" (read in some 周目).
	var db := GameData.get_db()
	if save.ended and save.replay == "":  # an ending closed this 周目: its stories wait for the next one
		return []
	var now := also if also != "" else (str(save.quests_cleared[-1]) if not save.quests_cleared.is_empty() else "")
	var have: Array = save.flags + save.run_records
	var out: Array = []
	for qid in db.side_stories:
		for st in db.side_stories[qid]:
			if qid != now or not _story_open(st, have):
				continue
			var s: Dictionary = st.duplicate()
			s["quest"] = qid
			s["read"] = save.side_read.has(st["id"])
			s["seen"] = save.side_seen.has(st["id"])
			out.append(s)
	return out


static func _story_open(st: Dictionary, have: Array) -> bool:
	## requires: a recorded line, or a list of them (all must hold); unless: a line (or list) none of which may hold
	var req: Array = st["requires"] if st.get("requires") is Array else ([st["requires"]] if st.has("requires") else [])
	var bar: Array = st["unless"] if st.get("unless") is Array else ([st["unless"]] if st.has("unless") else [])
	return req.all(func(f): return have.has(f)) and not bar.any(func(f): return have.has(f))


static func side_unread(save: SaveData, also := "") -> int:
	return side_stories(save, also).filter(func(s): return not s["read"]).size()


static func chapter_page(quest_id: String, save: SaveData) -> Dictionary:
	## the chapter-end page's {cg} for this route ({} = none drawn yet)
	var have: Array = save.flags + save.run_records
	for pg in GameData.get_db().chapter_pages.get(quest_id, []):
		if not _story_open(pg, have):
			continue
		return pg
	return {}


static func side_cost(st: Dictionary) -> int:
	return int(st.get("cost", GameData.get_db().side_cost))


static func side_reward_text(st: Dictionary) -> String:
	## what opening it gives, shown on its tile before it is opened (「点化 孙策」「宝物 赤帻」「卡 王允」)
	var db := GameData.get_db()
	var rw: Dictionary = st.get("reward", {})
	var parts: Array = []
	for cid in rw.get("upgrade", {}):
		parts.append("点化 %s" % str(db.cards[cid]["name"]).split("·")[0])
	for rid in rw.get("relics", []):
		parts.append("宝物 %s" % db.relics[rid]["name"])
	for cid in rw.get("cards", []):
		parts.append("卡 %s" % str(db.cards[cid]["name"]).split("·")[0])
	if int(rw.get("merit", 0)) > 0:
		parts.append("战功 +%d" % int(rw["merit"]))
	return "、".join(parts)


static func open_side(save: SaveData, id: String) -> Dictionary:
	## Open a ？小故事: the first time in a 周目 it costs 战功 and pays its reward then and there (quitting mid-story loses
	## nothing); after that, while it is still listed, it is free and gives nothing (user rule). Returns {ok, got, cards, relics}:
	## ok false = not enough 战功.
	if save.side_read.has(id):
		return {"ok": true, "got": "", "cards": [], "relics": []}
	var db := GameData.get_db()
	var st: Dictionary = {}
	for list in db.side_stories.values():
		for x in list:
			if x["id"] == id:
				st = x
	var cost := side_cost(st)
	if save.merit < cost:
		return {"ok": false, "got": "", "cards": [], "relics": []}
	save.merit -= cost
	save.side_read.append(id)
	if not save.side_seen.has(id):
		save.side_seen.append(id)
	var rw: Dictionary = st.get("reward", {})
	var got: Array = []
	var shown_cards: Array = []  # for the reveal after the story: the same 入队 / 宝物 card moments as anywhere else
	var shown_relics: Array = []
	for cid in rw.get("upgrade", {}):  # 点化 the story's lead (handed over first if not held)
		var n := int(rw["upgrade"][cid])
		if not save.owned.has(cid):
			save.grant_card(cid, true)
			n -= 1
		if n > 0:
			save.upgrade(cid, n)
		got.append("%s +%d 张" % [str(db.cards[cid]["name"]).split("·")[0], int(rw["upgrade"][cid])])
		shown_cards.append(cid)
	for rid in rw.get("relics", []):  # kept for the rest of the 周目, like any 宝物 brought from a finished chapter
		if save.relics.has(rid) or save.kept_relics.has(rid):
			save.merit += cost
			got.append("「%s」已经有了，战功退回 %d" % [db.relics[rid]["name"], cost])
			continue
		save.relics.append(rid)
		save.kept_relics.append(rid)
		if not save.run_relics.has(rid):
			save.run_relics.append(rid)
		got.append("宝物「%s」" % db.relics[rid]["name"])
		shown_relics.append(rid)
	for cid in rw.get("cards", []):  # a card the story hands over (often one the pool never offers: 王允, 程昱 …)
		save.grant_card(cid, true)
		got.append("「%s」" % db.cards[cid]["name"])
		shown_cards.append(cid)
	if int(rw.get("merit", 0)) > 0:
		save.merit += int(rw["merit"])
		got.append("战功 +%d" % int(rw["merit"]))
	return {"ok": true, "got": "、".join(got), "cards": shown_cards, "relics": shown_relics}


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


static func rescale_hp(save: SaveData, old_top: int, new_top: int) -> void:
	## the party changed (整备): HP stays the same share of the bar, e.g. 50 / 100 → 75 / 150
	if old_top <= 0 or new_top <= 0:
		return
	var share := float(old_top - save.damage) / old_top
	save.damage = clampi(new_top - int(round(share * new_top)), 0, new_top - 1)


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
	var out := {"gained": [], "log": [], "fx": []}  # fx: what the map screen animates (EventFx), one entry per visible change
	var top := party_max(save)
	var scale: Dictionary = db.battle.get("event_scale", {})  # battle.json: makes every event hit harder
	for e in effects:
		if e.has("record"):
			record(save, str(e["record"]))
		if e.has("say"):
			out["log"].append(str(e["say"]).replace("{lord}", save.lord_name))
		if e.has("damage"):
			var d := mini(int(round(top * float(e["damage"]) * float(scale.get("damage", 1.0)))), maxi(0, top - 1 - save.damage))
			save.damage += d
			out["log"].append("体力 -%d" % d)
			out["fx"].append({"k": "hp", "n": -d, "left": top - save.damage, "top": top})
		if e.has("heal"):
			var h := mini(save.damage, int(round(top * float(e["heal"]) * float(scale.get("heal", 1.0)))))
			save.damage -= h
			out["log"].append("体力 +%d" % h)
			if h > 0:
				out["fx"].append({"k": "hp", "n": h, "left": top - save.damage, "top": top})
		if e.has("refresh"):  # 重置技能: cumulative AP costs and once-per-battle skills, HP untouched
			save.carry_extra = {}
			save.carry_uses = {}
			out["log"].append("技能重置：累积加价清零，限 1 次技能可以再用")
			out["fx"].append({"k": "refresh"})
		if e.has("upgrade") and str(e["upgrade"]) == "random":  # a random general of yours goes up a tier
			var pool: Array = save.upgradable()
			if pool.is_empty():
				out["log"].append("……你还没有能升级的武将。")
			else:
				var cid: String = pool[rng.randi_range(0, pool.size() - 1)]
				var t0 := save.tier(cid)
				save.upgrade(cid)
				out["fx"].append({"k": "tier", "card": cid, "from": t0, "to": save.tier(cid)})
				out["log"].append("%s 升为%s卡！" % [db.cards[cid]["name"], db.gacha["tiers"][save.tier(cid)]["name"]])
		elif e.has("upgrade"):  # pick one of a few random cards of yours (the lord too, not yet 金) to go up a tier
			var ids: Array = save.upgrade_offer(rng)
			save.offer = ids
			save.offer_kind = "upgrade"
			if ids.is_empty():
				out["log"].append("……你还没有能升级的武将。")
		if e.has("rest"):
			reset_carry(save)
			out["log"].append("体力全满，技能次数恢复")
			out["fx"].append({"k": "rest"})
		if e.has("poison"):  # 中毒: lose a share of full HP (battle.event_scale.poison)
			var d := mini(int(round(top * float(scale.get("poison", 1.0 / 3.0)))), maxi(0, top - 1 - save.damage))
			save.damage += d
			out["log"].append("中毒！体力 -%d" % d)
			out["fx"].append({"k": "hp", "n": -d, "left": top - save.damage, "top": top, "poison": true})
		if e.has("card"):
			var c: Dictionary = db.cards[e["card"]]
			save.grant_card(c["id"])
			out["gained"].append(c)
			out["log"].append("获得：" + c["name"])
		if e.has("soldier"):
			var pool: Array = pools(q, save, here(q, save))["soldier_pool"]
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
				ids = SaveData.chest_offer(rng, int(o.get("soldiers", 3)) + save.offer_extra(), pools(q, save, here(q, save))["soldier_pool"]).map(
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
			out["fx"].append({"k": "lose_relic", "id": gone})
		if e.has("lose_soldier"):  # lose soldier copies at random
			for _n in int(e["lose_soldier"]) * int(scale.get("lose_soldier", 1)):
				var have: Array = save.soldiers.keys().filter(func(c): return save.soldiers[c] > 0)
				if have.is_empty():
					break
				var cid: String = have[rng.randi_range(0, have.size() - 1)]
				save.soldiers[cid] -= 1
				if save.soldiers[cid] <= 0:
					save.soldiers.erase(cid)
					save.party.erase(cid)
				out["log"].append("失去兵卡：" + db.cards[cid]["name"])
				out["fx"].append({"k": "lose_soldier", "card": cid})
		if e.has("difficulty"):  # whole campaign; may go down, but not below battle.difficulty_min
			var was := save.difficulty
			save.difficulty = maxi(int(db.battle.get("difficulty_min", 0)), save.difficulty + int(e["difficulty"]))
			var pct := int(round(save.difficulty * float(db.battle["difficulty_step"]) * 100))
			if save.difficulty != was:
				out["fx"].append({"k": "difficulty", "from": save.effective_level() + was, "to": save.effective_level() + save.difficulty, "pct": pct})  # as the map's 难度 chip counts
			if save.difficulty > was:
				out["log"].append("难度上升到 %d！今后所有敌人 %+d%%，宝箱里的武将也更多了" % [save.level(), pct])
			elif save.difficulty < was:
				out["log"].append("难度下降到 %d！今后所有敌人 %+d%%，宝箱里的武将也少了些" % [save.level(), pct])
			else:
				out["log"].append("……难度已经到底了，没有变化。")
		if e.has("danger"):  # this chapter only; may go down to 0
			var was_d := save.danger
			save.danger = maxi(0, save.danger + int(e["danger"]))
			var pct_d := int(round(save.danger * float(db.battle["danger_step"]) * 100))
			if save.danger != was_d:
				out["fx"].append({"k": "danger", "from": was_d, "to": save.danger, "pct": pct_d})
			if save.danger > was_d:
				out["log"].append("险！本轮之后的敌人体力和攻击 +%d%%" % pct_d)
			elif save.danger < was_d:
				out["log"].append("险情缓解：本轮敌人加成降到 +%d%%" % pct_d)
			else:
				out["log"].append("……本轮没有险情可解。")
		if e.has("fate"):  # 天命 changes for the rest of the run: "good" (吉 / 大吉), "curse" (double-edged), "bad" (凶), "divine" (天授), or true (any other but 天授)
			var want := str(e["fate"])
			var kinds: Array = {"good": ["common", "rare"], "curse": ["curse"], "bad": ["bad"], "divine": ["divine"]}.get(want, ["common", "rare", "curse", "bad"])
			var fs: Array = db.fates.keys().filter(func(f): return f != save.fate and db.fates[f]["rarity"] in kinds)
			if fs.is_empty():
				out["log"].append("……天命没有变。")
			else:
				var was_f: String = save.fate
				save.fate = fs[rng.randi_range(0, fs.size() - 1)]
				save.fate_offer = []
				var nf: Dictionary = db.fates[save.fate]
				out["fx"].append({"k": "fate", "from": was_f, "to": save.fate})
				out["log"].append("天命变了！%s→「%s」：%s" % ["「%s」" % db.fates[was_f]["name"] if db.fates.has(was_f) else "", nf["name"], nf["desc"]])
		if e.has("downgrade"):  # n random generals of yours (not the lord) drop one tier, 银 → 铜, 金 → 银
			var tiers: Array = db.gacha["tiers"]
			for _n in int(e["downgrade"]):
				var pool: Array = save.owned.filter(func(c): return save.tier(c) > 0)
				if pool.is_empty():
					out["log"].append("……你的武将都还是铜卡，降无可降。")
					break
				var cid: String = pool[rng.randi_range(0, pool.size() - 1)]
				out["fx"].append({"k": "tier", "card": cid, "from": save.tier(cid), "to": save.tier(cid) - 1})
				save.dupes[cid] = int(tiers[save.tier(cid) - 1]["copies"])
				if save.dupes[cid] <= 1:
					save.dupes.erase(cid)
				out["log"].append("%s 降为%s卡……" % [db.cards[cid]["name"], tiers[save.tier(cid)]["name"]])
		if e.has("ambush_all"):  # true: every fight left in this chapter (bar bosses) is an 埋伏; false: none of them is
			var laid: Dictionary = view(q, save)["squares"]
			for sid in laid:
				if laid[sid]["type"] == "battle" and not laid[sid]["boss"] and not save.visited.has(sid):
					if e["ambush_all"]:
						save.ambushes[sid] = true
					else:
						save.ambushes.erase(sid)
			out["log"].append("本章之后的战斗全都会被埋伏！" if e["ambush_all"] else "戒备森严：本章之后的战斗不会再被埋伏。")
			out["fx"].append({"k": "ambush", "on": bool(e["ambush_all"])})
		if e.has("merit"):  # 战功 (spent between chapters), never below 0
			var m := maxi(-save.merit, int(e["merit"]))
			save.merit += m
			out["log"].append("战功 %+d（现有 %d）" % [m, save.merit])
			if m != 0:
				out["fx"].append({"k": "merit", "n": m, "total": save.merit})
		if e.has("chance"):
			var branch: Array = e.get("then", []) if rng.randf() < float(e["chance"]) else e.get("else", [])
			var sub := _apply(branch, q, save, rng)
			out["gained"].append_array(sub["gained"])
			out["log"].append_array(sub["log"])
			out["fx"].append_array(sub["fx"])
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
	if save.run_records.any(func(l): return str(l).contains("结局")):
		save.commit_history()  # an ending: what you hold (bar story gifts) can be drawn again next 周目
		save.ended = true
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


static func restart(save: SaveData, rng: RandomNumberGenerator = null) -> void:
	## 重打这一章 (设置): the save goes back to exactly how it stood when the chapter began (chapter_start: cards, copies,
	## 战功, 宝物, the dealt map). An old save without that snapshot gets its cards back from run_start and a fresh deal.
	var had := not save.chapter_start.is_empty()
	save.rewind()
	if not had:
		var q: Variant = current_quest(save)
		if q != null:
			begin(q, save, rng)


static func step_back(save: SaveData, rng: RandomNumberGenerator = null) -> void:
	## 重返上一格 (设置). A step's snapshot is the square before it, already resolved — a choice made there would stay made
	## (a choose square moves on by itself the moment you pick). So landing on a made choice goes back to just before it:
	## re-enter it from the square before (or, on a chapter's first square, from the chapter start) and pick again.
	save.rewind_step()
	reopen_choice(save, rng)


static func reopen_choice(save: SaveData, rng: RandomNumberGenerator = null) -> void:
	## Standing on a choose square whose pick is already made: undo the pick and enter the square again, unresolved.
	## Also what the map's 「重新选择」 button calls, for a save that was left sitting on a made choice.
	var q: Variant = current_quest(save)
	if q == null or not save.resolved or here(view(q, save), save)["type"] != "choose":
		return
	var sid: String = save.square
	if save.steps.is_empty():
		restart(save, rng)
		return
	save.rewind_step()
	move(q, save, sid, rng)


static func fail(q: Dictionary, save: SaveData, rng: RandomNumberGenerator = null) -> void:
	## Lost a battle: automatically jump back to the previous point, allowing the player to try again.
	## If at the first square, restart from the beginning. Either way the party comes back at full HP with fresh skill uses:
	## kept wear meant a party knocked to 1 HP walked back into the same fight and fell to the first blow, over and over.
	reset_carry(save)
	if save.visited.size() <= 1:
		begin(q, save, rng)
	else:
		save.visited.pop_back()
		save.square = save.visited[-1]
		if not save.steps.is_empty():
			save.steps.pop_back()  # that step is undone already
		save.resolved = true
		save.offer = []
		save.event_battle = {}
		save.event_note = []
