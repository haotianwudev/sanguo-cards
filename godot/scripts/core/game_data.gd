class_name GameData
extends RefCounted
## All game content, loaded once from res://data/*.json. Records are plain Dictionaries.
## Stats follow Rance X: each card has only HP and AT. A troop type (兵种) is a unit; the card chosen
## to lead it gets  AT = leader_mult × own AT + the rest of that troop's cards  (HP likewise).

const DATA_DIR := "res://data"
const DATA_PARTS := ["enemies.json", "scenarios.json", "skills.json", "relics.json", "battle.json"]  # split off cards.json (same top-level keys, merged on load)

static var _inst: GameData

var gacha: Dictionary
var battle: Dictionary
var troops: Dictionary  # id -> {id, name, short, hp, at} (stats only — skills come from kits)
var kits: Dictionary  # id -> {id, name, normal, special}: the default skills of normal / special units (cards.json kits)
var lord_forms: Dictionary  # id -> {id, name, route, bonus, skills, art}: the lord's extra cards (cards.json lord_forms)
var lord_form_default := ""  # the lord card the first chapter's first step gives (the plain lord, with his own default face)
var lord_form_fixed: Dictionary  # chapter id -> the lord card that chapter always gives (the SSR ones; they are not in the random draw)
var lord_form_grants: Array  # form ids, handed out one per chapter cleared (in order, for the route that matches)
var endings: Dictionary  # id -> {id, title, route, chapter, kind, who, quest, built, trigger, hint, unlock, cg, text} (data/endings.json)
var ending_order: Array  # ending ids in file order
var card_chapters: Dictionary  # card id -> [quest ids] that give it out (story gifts, 招贤 lists, a battle's enemy card); a card in no chapter is 公共
var kit_default: Dictionary  # troop id -> the kit a card of that troop uses unless it names its own `kit`
var skills: Dictionary  # id -> {id, name, cost, cumulative, uses (int or null), effects}
var cards: Dictionary  # id -> {id, name, rarity, troop, bonus, skills, in_pool, person, weight, soldier}
var enemies: Dictionary  # id -> {id, name, hp, at, actions, moves, phys_resist, magic_resist, portrait}
var scenarios: Dictionary  # id -> {id, name, turn_limit, enemy, art}
var quests: Array  # [{id, title, start, squares: {id -> square}, soldier_pool, recruit_pool, event_pool}]
var events: Dictionary  # random events for ？ squares: id -> {id, title, glyph, text, portraits, options}
var relics: Dictionary  # 宝物: id -> {id, name, icon, rarity, desc, mods, after_win}
var relic_pick: Dictionary  # boss reward: {n, weights by rarity}
var skill_budget: Dictionary  # what an attack skill of each AP cost should be worth (cards.json skill_budget; checked by the tests)
var _raw_top: Dictionary = {}
var fates: Dictionary  # 天命: id -> {id, name, icon, rarity, desc, mods} (one picked per run)
var side_stories: Dictionary  # quest id -> [？小故事 opened from 整备 once that chapter is done: {id, title, portraits, text, cg, requires, unless, reward}]
var chapter_pages: Dictionary = {}  # quest id -> [{cg, requires, unless}]: the chapter-end page's picture (its card comes from a ？小故事)
var side_cost := 10  # 战功 to open a ？小故事 the first time in a 周目, unless it names its own cost
var ui: Dictionary


static func get_db() -> GameData:
	if _inst == null:
		_inst = GameData.new()
		_inst._load(DATA_DIR)
	return _inst


static func read_json(path: String) -> Variant:
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	assert(parsed != null, "could not parse %s" % path)
	return parsed


func _load(dir: String) -> void:
	var raw: Dictionary = read_json(dir + "/cards.json")
	for part in DATA_PARTS:  # the rest of the game data lives in a few files beside it
		var more: Dictionary = read_json(dir + "/" + part)
		for k in more:
			assert(not raw.has(k), "%s repeats %s" % [part, k])
			raw[k] = more[k]
	gacha = raw["gacha"]
	battle = raw["battle"]
	skill_budget = raw.get("skill_budget", {})
	for sid in raw["skills"]:
		var s: Dictionary = raw["skills"][sid]
		# power per AP: an effect with a `rate` hits for rate × AP cost in total (split over its hits), `hit_rate` gives each hit
		# hit_rate × AP; so a 3 AP skill at rate 1.2 is worth 3.6, a hero's 3 AP at rate 2.0 is worth 6. An attack / magic effect
		# with neither (nor a literal `power`) takes the default for its AP tier from skill_budget: rate_by_ap (dearer = more
		# per AP), multi_hit_rate for each hit of a multi-hit skill, × ultimate_mult for a once-only 大招.
		for e in s["effects"]:
			var cost := int(s["cost"])
			var hits := int(e.get("hits", 1))
			if e["type"] in ["attack", "magic"] and cost > 0 and not (e.has("power") or e.has("rate") or e.has("hit_rate")):
				var ult := float(skill_budget.get("ultimate_mult", 1.0)) if s.get("uses") != null or s.get("per_battle", false) else 1.0
				if hits > 1:
					e["hit_rate"] = float(skill_budget["multi_hit_rate"]) * ult
				else:
					var tiers: Dictionary = skill_budget["rate_by_ap"]
					e["rate"] = float(tiers.get(str(cost), tiers[str(tiers.size())])) * ult
			if e.has("hit_rate"):
				e["power"] = float(e["hit_rate"]) * cost
			elif e.has("rate"):
				e["power"] = float(e["rate"]) * cost / hits
		skills[sid] = {"id": sid, "name": s["name"], "cost": int(s["cost"]),
			"cumulative": s.get("cumulative", false),
			"uses": null if s.get("uses") == null else int(s["uses"]),  # 本章限 N 次（休整格恢复）
			"per_battle": bool(s.get("per_battle", false)),  # 每场限 1 次（下一场自动恢复）
			"special": s.get("special", false), "free": s.get("free", false),
			"effects": s["effects"]}
	for tid in raw["troops"]:
		var t: Dictionary = raw["troops"][tid]
		troops[tid] = {"id": tid, "name": t["name"], "short": t["short"], "hp": int(t["hp"]),
			"at": int(t["at"])}
	for kid in raw["kits"]:
		kits[kid] = {"id": kid, "name": raw["kits"][kid]["name"], "normal": raw["kits"][kid]["normal"], "special": raw["kits"][kid]["special"]}
	kit_default = raw["kit_default"]
	for fid in raw.get("lord_forms", {}).get("forms", {}):
		var f: Dictionary = raw["lord_forms"]["forms"][fid]
		lord_forms[fid] = {"id": fid, "name": f["name"], "route": f.get("route", ""), "rarity": str(f.get("rarity", raw["gacha"].get("lord_rarity", "R"))), "hp": int(f.get("hp", 0)), "at": int(f.get("at", 0)),
			"skills": f.get("skills", []), "art": f.get("art", false) or ResourceLoader.exists("res://data/portraits/%s.jpg" % fid)}  # its own face once that portrait is delivered
	lord_form_grants = raw.get("lord_forms", {}).get("grants", [])
	lord_form_fixed = raw.get("lord_forms", {}).get("fixed", {})
	lord_form_default = raw.get("lord_forms", {}).get("default", "")
	for cid in raw["cards"]:
		var c: Dictionary = raw["cards"][cid]
		cards[cid] = {"id": cid, "name": c["name"], "rarity": c["rarity"], "troop": c["troop"],
			"hp": int(c["hp"]), "at": int(c["at"]), "skills": c.get("skills", []), "in_pool": c.get("pool", true),
			"troop_skills": c.get("troop_skills", true), "kit": c.get("kit", ""),
			"person": c.get("person", cid.trim_suffix("_card") if cid.ends_with("_card") else cid), "weight": int(c.get("weight", 1)), "scope": c.get("scope", ""),
			"soldier": c["rarity"] == "N", "elite": c.get("elite", false), "veteran": c.get("veteran", false), "faction": c.get("faction", ""), "public": c.get("public", false), "beast": c.get("beast", false), "first_win": c.get("first_win", false), "voice": c.get("voice", "")}
	for eid in raw["enemies"]:
		var e: Dictionary = raw["enemies"][eid]
		var foe_card: Dictionary = cards.get(str(e.get("card", "")), {}) if not e.has("hp") else {}  # its stats are its card's face numbers (battle.enemy_from_card converts them); an enemy that writes its own hp / at (野猪, 吕布 and the other hand-tuned showpieces) keeps them
		var fc: Dictionary = battle.get("enemy_from_card", {"hp": 1.0, "at": 1.0})
		enemies[eid] = {"id": eid, "name": e["name"],
			"hp": int(round(float(foe_card["hp"]) * float(fc["hp"]))) if not foe_card.is_empty() else int(e["hp"]),
			"at": int(round(float(foe_card["at"]) * float(fc["at"]))) if not foe_card.is_empty() else int(e["at"]),
			"actions": int(e["actions"]), "moves": e["moves"],
			"phys_resist": float(e.get("phys_resist", 0.0)), "magic_resist": float(e.get("magic_resist", 0.0)), "armor": str(e.get("armor", "")),
			"portrait": e.get("portrait", ""), "card": e.get("card", ""), "drop": e.get("drop", e.get("card", "")), "card_public": e.get("card_public", false)}
		if e.has("armor"):  # 护甲类型 (battle.armors): its resists replace the enemy's own
			assert(battle.get("armors", {}).has(e["armor"]), "enemy %s: unknown armor %s" % [eid, e["armor"]])
			var arm: Dictionary = battle["armors"][e["armor"]]
			enemies[eid]["phys_resist"] = float(arm["phys"])
			enemies[eid]["magic_resist"] = float(arm["magic"])
	for rid in raw.get("relics", {}):
		var r: Dictionary = raw["relics"][rid]
		relics[rid] = {"id": rid, "name": r["name"], "icon": r.get("icon", r["name"].left(1)),
			"rarity": r.get("rarity", "common"), "troop": r.get("troop", "lord"), "desc": r.get("desc", ""), "mods": r.get("mods", {}),
			"after_win": float(r.get("after_win", 0.0))}
	relic_pick = raw.get("relic_pick", {"n": 3, "weights": {"common": 1}})
	_raw_top = {"fate_offer": raw.get("fate_offer", 3)}
	for fid in raw.get("fates", {}):
		var f: Dictionary = raw["fates"][fid]
		fates[fid] = {"id": fid, "name": f["name"], "icon": f.get("icon", f["name"].left(1)), "rarity": f.get("rarity", "common"),
			"desc": f.get("desc", ""), "mods": f.get("mods", {}), "troop": "lord", "after_win": 0.0}
	for sid in raw["scenarios"]:
		var sc: Dictionary = raw["scenarios"][sid]
		scenarios[sid] = {"id": sid, "name": sc["name"], "turn_limit": int(sc["turn_limit"]), "enemy": sc["enemy"],
			"art": sc.get("art", sid)}  # battle CG: soldier battles of one type share one
	_validate()
	# the lord cards are cards in the same draw pool as the generals of their route (rarity gacha.lord_rarity, `scope` = the card's route);
	# another copy raises that card's 铜/银/金 tier like a general's. Their fighter always comes from SaveData.lord_with_form.
	cards["lord"] = {"id": "lord", "name": "主公", "rarity": str(gacha.get("lord_rarity", "SR")), "troop": "lord",
		"hp": int(troops["lord"]["hp"]), "at": int(troops["lord"]["at"]), "skills": [], "in_pool": true, "troop_skills": true, "person": "lord", "weight": 1, "soldier": false}
	# every other lord card (版本) is a card too, id "lord:<form id>": the same card as any general (its own copies, tier, 点化, draws),
	# only its fighter comes from SaveData.lord_with_form and it always leads the lord's unit when picked in 整备
	for fid in lord_forms:
		if fid != lord_form_default:
			cards["lord:" + fid] = cards["lord"].merged({"id": "lord:" + fid, "name": lord_forms[fid]["name"], "lord_form": fid, "scope": lord_forms[fid]["route"], "rarity": lord_forms[fid]["rarity"]}, true)

	var en: Dictionary = read_json(dir + "/endings.json")
	for eid in en["endings"]:
		endings[eid] = en["endings"][eid].merged({"id": eid})
		ending_order.append(eid)
	var story: Dictionary = read_json(dir + "/story.json")
	for q in story["quests"]:
		var squares := {}
		for sq_id in q["squares"]:
			var s: Dictionary = q["squares"][sq_id]
			squares[sq_id] = {"id": sq_id, "x": int(s["x"]), "y": int(s["y"]), "type": s["type"],
				"next": s.get("next", []), "text": s.get("text", []), "portraits": s.get("portraits", []),
				"cards": s.get("cards", []), "cards_public": s.get("cards_public", false), "relics": s.get("relics", []), "difficulty": int(s.get("difficulty", 0)), "damage": float(s.get("damage", 0.0)), "choose": s.get("choose", []).map(_choose_option), "battle": s.get("battle", ""),
				"boss": s.get("boss", false), "elite": s.get("elite", false), "ambush": s.get("ambush", false),
				"event": s.get("event", ""), "lose_goto": s.get("lose_goto", ""), "beatable": s.get("beatable", false),
				"label": s.get("label", ""), "record": s.get("record", ""), "record_win": s.get("record_win", ""),
				"record_lose": s.get("record_lose", ""), "requires": s.get("requires", ""), "unless": s.get("unless", ""),
				"soldier_pool": s.get("soldier_pool", []), "recruit_pool": s.get("recruit_pool", []), "cg": s.get("cg", ""), "prompt": s.get("prompt", ""), "card_unless": s.get("card_unless", {}), "ghost": s.get("ghost", false), "ghost_requires": s.get("ghost_requires", "")}
		quests.append({"id": q["id"], "title": q["title"], "start": q["start"], "squares": squares,
			"soldier_pool": q.get("soldier_pool", []), "soldier_scope": q.get("soldier_scope", ""), "recruit_pool": q.get("recruit_pool", []),
			"subtitle": q.get("subtitle", ""), "ending": _ending_card(q.get("ending", "")), "requires": q.get("requires", ""), "unless": q.get("unless", ""),
			"event_pool": q.get("event_pool", []), "event_scope": q.get("event_scope", "south"), "shuffle": q.get("shuffle", []),
				"pool_overrides": q.get("pool_overrides", []).map(func(o): return {"requires": o.get("requires", ""),
					"unless": o.get("unless", ""), "soldier_scope": o.get("soldier_scope", ""),
					"recruit_pool": o.get("recruit_pool", []), "event_scope": o.get("event_scope", "")}),
				"title_overrides": q.get("title_overrides", []).map(func(o): return {"requires": o.get("requires", ""),
					"unless": o.get("unless", ""), "title": o.get("title", "")}),
				"map_overrides": q.get("map_overrides", []).map(func(o): return {"requires": o.get("requires", ""),
					"unless": o.get("unless", ""), "map": o.get("map", "")})})
	for eid in story.get("events", {}):
		var ev: Dictionary = story["events"][eid]
		events[eid] = {"id": eid, "title": ev["title"], "glyph": ev.get("glyph", "？"), "color": ev.get("color", "blue"),
			"text": ev.get("text", []), "cg": ev.get("cg", ""), "prompt": ev.get("prompt", ""), "scope": ev.get("scope", "south"), "route": ev.get("route", ""),
			"portraits": ev.get("portraits", []), "options": ev["options"].map(func(o): return {
				"label": o["label"], "effects": o.get("effects", []), "win": o.get("win", []), "needs": o.get("needs", {}), "weight": float(o.get("weight", 1.0))})}
	_index_card_chapters()
	Quests.validate(self)

	ui = read_json(dir + "/ui.json")
	if FileAccess.file_exists(dir + "/side_stories.json"):
		var ss: Dictionary = read_json(dir + "/side_stories.json")
		side_stories = ss.get("after", {})
		side_cost = int(ss.get("cost", 10))
		chapter_pages = ss.get("chapters", {})
		for qid in chapter_pages:
			for pg in chapter_pages[qid]:
				assert(pg.get("card", "") == "" or cards.has(pg["card"]), "chapter page %s: unknown card %s" % [qid, pg.get("card")])
		var ids := {}
		var qids: Array = quests.map(func(q): return q["id"])
		for qid in side_stories:
			assert(qids.has(qid), "side_stories: unknown quest %s" % qid)
			for st in side_stories[qid]:
				assert(not ids.has(st["id"]), "side_stories: id %s used twice" % st["id"])
				ids[st["id"]] = true
				assert(not st.get("text", []).is_empty(), "side story %s: no text" % st["id"])
				var rw: Dictionary = st.get("reward", {})
				assert(not rw.is_empty(), "side story %s: no reward" % st["id"])
				for cid in rw.get("cards", []) + rw.get("upgrade", {}).keys():
					assert(cards.has(cid), "side story %s: unknown card %s" % [st["id"], cid])
				for rid in rw.get("relics", []):
					assert(relics.has(rid), "side story %s: unknown relic %s" % [st["id"], rid])


func _index_card_chapters() -> void:
	## a card is chapter-specific when a chapter hands it out: a square's `cards` / a choice's `card`, a quest's 招贤 list, or the
	## `card` of an enemy fought on one of its squares (unless that enemy says `card_public`: a famous general met as a sparring
	## opponent — 比武 关羽 / 张飞 — drops his own card but stays in both routes' public pool; likewise a square with `cards_public`).
	## Everything else is 公共.
	card_chapters = {}
	var add := func(cid: String, qid: String):
		if cid != "" and cards.has(cid):
			if not card_chapters.has(cid):
				card_chapters[cid] = []
			if not card_chapters[cid].has(qid):
				card_chapters[cid].append(qid)
	for q in quests:
		for c in q["recruit_pool"]:
			add.call(c, q["id"])
		for o in q["pool_overrides"]:
			for c in o["recruit_pool"]:
				add.call(c, q["id"])
		for s in q["squares"].values():
			if not s.get("cards_public", false):  # 关张来投：名将入队，但两线的公共池里照样有
				for c in s["cards"]:
					add.call(c, q["id"])
			for o in s["choose"]:
				add.call(o["card"], q["id"])
			if s["type"] == "battle" and scenarios.has(s["battle"]):
				var foe: Dictionary = enemies[scenarios[s["battle"]]["enemy"]]
				if not foe["card_public"]:
					add.call(foe["card"], q["id"])
					add.call(foe["drop"], q["id"])  # what beating it actually hands over (先登营 → 先登死士)


func is_public(card_id: String) -> bool:
	return not card_chapters.has(card_id)


func _ending_card(id: Variant) -> Dictionary:
	## a quest's `ending` is an id in data/endings.json; the screens that show it read {title, text, cg}
	if id is Dictionary:
		return id
	if str(id) == "":
		return {}
	assert(endings.has(str(id)), "unknown ending %s" % str(id))
	var e: Dictionary = endings[str(id)]
	return {"id": str(id), "title": e["title"], "text": e["text"], "cg": e["cg"]}


func endings_reached(flags: Array) -> Array:
	## ids of the endings whose title is among a save's lasting story flags (the title is the flag)
	return ending_order.filter(func(id): return flags.has(endings[id]["title"]))


static func _choose_option(o: Dictionary) -> Dictionary:
	## A choice on a choose square. `card` (optional) joins the party; `locked` options are shown but can't be picked; `requires` (a story flag, e.g. an ending that has to have happened before) keeps one locked until the save has it.
	return {"card": o.get("card", ""), "label": o.get("label", ""), "goto": o.get("goto", ""), "locked": o.get("locked", false),
		"record": o.get("record", ""), "requires": o.get("requires", "")}


func _validate() -> void:
	for en in enemies.values():
		assert(en["drop"] == "" or cards.has(en["drop"]), "enemy %s: unknown drop %s" % [en["id"], en["drop"]])
	for sk in skills.values():
		for e in sk["effects"]:
			assert(e["type"] in ["attack", "magic", "heal", "guard", "boost", "stun", "break", "ap", "burn", "counter", "hurt", "cleanse", "buff", "poison", "loot"],
				"skill %s: unknown effect %s" % [sk["id"], e["type"]])
	for c in cards.values():
		assert(troops.has(c["troop"]), "card %s: bad troop" % c["id"])
		assert(c["troop"] != "lord" or c["soldier"], "card %s: only soldier cards can be of the lord's own troop (亲卫 / 侍从)" % c["id"])
		for s in c["skills"]:
			assert(skills.has(s), "card %s: unknown skill %s" % [c["id"], s])
	for k in kits.values():
		assert(not k["normal"].is_empty() and not k["special"].is_empty(), "kit %s: needs normal and special skills" % k["id"])
		for s in k["normal"] + k["special"]:
			assert(skills.has(s), "kit %s: unknown skill %s" % [k["id"], s])
	for tid in troops:
		assert(kits.has(kit_default.get(tid, "")), "troop %s: no default kit" % tid)
	for c in cards.values():
		assert(c["kit"] == "" or kits.has(c["kit"]), "card %s: unknown kit %s" % [c["id"], c["kit"]])
	for sc in scenarios.values():
		assert(enemies.has(sc["enemy"]), "scenario %s: unknown enemy" % sc["id"])
	for e in enemies.values():
		assert(e["card"] == "" or cards.has(e["card"]), "enemy %s: unknown card %s" % [e["id"], e["card"]])
		var names: Array = e["moves"].map(func(m): return m["name"])
		for m in e["moves"]:
			assert(not m.has("charge") or names.has(m["charge"]), "enemy %s: charges an unknown move" % e["id"])


# ---- cards -------------------------------------------------------------------

func pool(rarity: String) -> Array:
	## Generals the recruit offer can give at this rarity (soldiers come from chests instead).
	return cards.values().filter(func(c): return c["rarity"] == rarity and c["in_pool"] and not c["soldier"])


func soldier_cards() -> Array:
	return cards.values().filter(func(c): return c["soldier"] and not c["beast"] and c.get("faction", "") == "")  # 野兽卡 never come in chests; a faction's own troops (汉军) only from fighting it


func kit_of(card: Dictionary) -> Dictionary:
	## the kit a card draws its default skills from: its own `kit`, else the default for its troop
	return kits[card["kit"] if card.get("kit", "") != "" else kit_default[card["troop"]]]


func default_kit(troop_id: String, special := false) -> Array:
	## a troop's default skills: normal units, or (special) 精兵 and generals without a skill of their own
	return kits[kit_default[troop_id]]["special" if special else "normal"]


func build_fighter(card_id: String, mult := 1.0) -> Dictionary:
	## 兵种基础 + 武将自身能力 (× mult: the 铜/银/金 tier). Skills: a soldier has its troop's plain move (精兵 also the
	## troop's signature; "troop_skills": false on either = its own `skills` only); a general has the plain move plus its own signature, or the troop's signature if it has
	## none ("troop_skills": false = own skills only).
	var c: Dictionary = cards[card_id]
	var t: Dictionary = troops[c["troop"]]
	var kit: Dictionary = kit_of(c)
	var sk: Array = []
	if c["troop"] == "lord":
		pass  # the lord's retinue never acts: it only makes his unit stronger
	elif c["soldier"]:
		if c["troop_skills"]:  # "troop_skills": false = own skills only (e.g. a shield-bearer that shoots)
			sk = kit["special" if c["elite"] else "normal"].duplicate()
	elif c["troop_skills"]:
		sk = kit["normal" if not c["skills"].is_empty() else "special"].duplicate()
	for s in c["skills"]:
		if not sk.has(s):
			sk.append(s)
	# the card's face numbers are its stats at 铜; the tier multiplies both (rarity is only where hp + at falls: cards.json gacha.rarity_bands)
	return {"id": card_id, "name": c["name"], "troop": c["troop"], "person": c["person"],
		"hp": int(round(c["hp"] * mult)), "at": int(round(c["at"] * mult)), "base_hp": c["hp"], "base_at": c["at"], "skills": sk, "rarity": c["rarity"], "voice": c.get("voice", "")}


func build_lord(lord_name: String, mult := 1.0, north := false, form := "", forms: Array = [], form_mult := -1.0) -> Dictionary:
	## "id" stays "lord" everywhere (card/collection/leader lookups all key on it); "person" carries the
	## north-route portrait override so Kit.portrait_key can find lord_north without touching those checks.
	var t: Dictionary = troops["lord"]
	var skills: Array = kits["lord_north"]["special"] if north and kits.has("lord_north") else default_kit("lord", true)
	var f: Dictionary = lord_forms.get(form, {})  # the lord card in use: its own stats, skills and (once drawn) face
	var fm := form_mult if form_mult >= 0.0 else mult  # a lord card levels on its own (SaveData.form_tier); callers without one use the lord's tier
	var rar: String = str(f.get("rarity", gacha.get("lord_rarity", "R")))
	var extra: Array = f.get("skills", [])
	var person := "lord_north" if north else "lord"
	if not f.is_empty() and f["art"]:
		person = form
	var sk := skills.duplicate()
	for s in extra:
		if not sk.has(s):
			sk.append(s)
	return {"id": "lord", "person": person, "north": north, "form": form, "name": lord_name, "troop": "lord",
		"hp": int(round(float(f["hp"]) * fm)) if not f.is_empty() else int(round(t["hp"] * mult)),
		"at": int(round(float(f["at"]) * fm)) if not f.is_empty() else int(round(t["at"] * mult)),
		"base_hp": float(f["hp"]) if not f.is_empty() else float(t["hp"]), "base_at": float(f["at"]) if not f.is_empty() else float(t["at"]),
		"skills": sk, "rarity": rar}


func build_leader(card: Dictionary, members: Array, weights: Array = []) -> Dictionary:
	## unit stat = (leader_mult × leader's tier stat + the rest of the troop (weighted: duplicate soldiers decay))
	## × the leader's 铜 stat / leader_base — hp by its 铜 hp, attack by its 铜 attack
	var m: int = int(battle["lord_leader_mult"]) if card["troop"] == "lord" else int(battle["leader_mult"])  # 主角 ×5, everyone else ×3
	var hp := float(m * card["hp"])
	var at := float(m * card["at"])
	for i in members.size():
		var w: float = weights[i] if i < weights.size() else 1.0
		hp += members[i]["hp"] * w
		at += members[i]["at"] * w
	var lb := float(battle.get("leader_base", 60))
	hp *= float(card.get("base_hp", lb)) / lb
	at *= float(card.get("base_at", lb)) / lb
	hp *= float(battle.get("hp_mult", 1.0))  # global feel of the fights: more attack, less HP on both sides (battle.attack_mult / hp_mult)
	at *= float(battle.get("attack_mult", 1.0))
	return {"card": card, "members": members, "hp": int(round(hp)), "at": int(round(at))}


static func _power(hp: float, at: float, n_skills: int) -> int:
	return int(round(hp / 5.0 + at + 15 * n_skills))


func power(f: Dictionary) -> int:
	return _power(f["hp"], f["at"], f["skills"].size())


func power_split(f: Dictionary) -> Array:
	## [兵种战力, 武将战力]
	var t: Dictionary = troops[f["troop"]]
	var troop := _power(t["hp"], t["at"], default_kit(f["troop"], true).size())
	return [troop, power(f) - troop]


# ---- helpers -----------------------------------------------------------------

static func weighted_pick(rng: RandomNumberGenerator, items: Array, weights: Array) -> Variant:
	var total := 0.0
	for w in weights:
		total += w
	var r := rng.randf() * total
	for i in items.size():
		r -= weights[i]
		if r < 0.0:
			return items[i]
	return items[items.size() - 1]


func raw_int(key: String, default := 0) -> int:
	## a top-level number from cards.json (e.g. fate_offer)
	return int(_raw_top.get(key, default))
