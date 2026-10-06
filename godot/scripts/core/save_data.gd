class_name SaveData
extends RefCounted
## Player progress: cards, party, quest position. Also the rules for getting cards and building the party.
##
## Two kinds of card:
##   generals (R/SR/SSR) — unique; come from recruiting (pick 1 of a few) and the story.
##   soldiers (N, 兵卡)  — stackable; come from battle chests (pick 1 of a few). Copies of the same soldier
##                         card back their troop with diminishing returns (×soldier_decay per extra copy).

const SAVE_PATH := "user://save.json"

var owned: Array = []  # general card ids, no duplicates
var dupes: Dictionary = {}  # general card id -> copies owned when more than one (铜 1 / 银 2 / 金 4)
var soldiers: Dictionary = {}  # soldier card id -> copies
var party: Array = []  # leader card ids; the lord is implicit and always first
var cleared: Array = []  # scenario ids won at least once
# quest map progress (see Quests)
var quest := ""
var square := ""
var visited: Array = []
var resolved := false
var damage := 0  # shared-HP damage carried between battles in this quest
var carry_extra: Dictionary = {}  # card id -> {skill: 累积 increments}
var carry_uses: Dictionary = {}  # card id -> {skill: uses left}
var choices: Dictionary = {}  # choose-square id -> goto (remembered across retries)
var offer: Array = []  # cards shown on the current recruit/treasure square
var events: Dictionary = {}  # ？ square id -> event id rolled for it this run
var event_battle: Dictionary = {}  # a fight an event started: {battle, ambush, win: [effects on victory]}
var event_note: Array = []  # what the last event did, shown on its square
var offer_kind := ""  # "upgrade": the offer lists your own generals, the pick goes up a tier
var relics: Array = []  # 宝物 held this run
var danger := 0  # 险 accepted this run: enemies get stronger
var difficulty := 0  # 难度 above 1 (shown as 难度 difficulty + 1): permanent, every level makes all enemies stronger
                    # and chests give more generals (beating 吕布 at 虎牢关 → 难度 2)
var picks_left := 0  # more pick-ones to come after this one (三连抽)
var offer_rates: Dictionary = {}  # rarity weights for those picks
var run_start: Dictionary = {}  # card id -> copies owned when this run began (for the chapter recap)
var run_battles := 0  # battles won this run
var run_relics: Array = []  # every 宝物 picked up this run, even ones traded away
var merit := 0  # 战功: earned per chapter, kept across chapters, spent between chapters
var merit_paid := ""  # quest id whose 战功 has been paid out (so a reopened recap doesn't pay twice)
var run_bosses := 0  # bosses and elites beaten this run
var kept_relics: Array = []  # 宝物 brought from finished chapters: every run starts with them
var clears: Dictionary = {}  # quest id -> times cleared (replays get harder: 进阶)
var replay := ""  # quest id being replayed ("" = the main story)
var stash: Dictionary = {}  # the main story's run, parked while replaying
var flags: Array = []  # every recorded line from finished chapters (cross-chapter story branching)
var run_records: Array = []  # key choices and outcomes this run, as short lines (「董白：留下」)
var layout: Dictionary = {}  # this run's shuffled squares: square id -> the square whose contents it shows
var quests_cleared: Array = []
var lord_name := "主公"
var fate := ""  # 天命 picked for this run ("" = not yet)
var fate_offer: Array = []  # the fates to pick from at the start of a run
var affixes: Dictionary = {}  # square id -> 词缀 id for this run's elites and bosses
var unworn: Array = []  # 宝物 left in the card pool (not worn: no effect)
var benched: Array = []  # cards left behind: not in any unit (never a leader)
var seen: Array = []  # every general ever owned, across 周目: they can all be drawn again
var lap := 1  # 周目: how many times the story has been started with the collection carried over
var lord_forms: Array = []  # the lord's extra cards (versions) handed out so far (cards.json lord_forms)
var lord_form_paid := ""  # quest id whose lord card has been handed out (a reopened recap doesn't give twice)
var lord_copies := 1  # the lord's card starts 铜 like everyone; drawing it again (or upgrade("lord")) raises the tier
var party_slots := 4  # including the lord
var theme := "light"

const FIELDS := ["owned", "dupes", "soldiers", "party", "cleared", "quest", "square", "visited", "resolved", "damage",
	"carry_extra", "carry_uses", "choices", "offer", "quests_cleared", "lord_name", "lord_forms", "lord_form_paid", "lord_copies", "lap", "seen", "unworn", "benched", "fate", "fate_offer", "affixes", "party_slots", "theme",
	"events", "event_battle", "event_note", "offer_kind", "relics", "danger", "layout", "difficulty", "picks_left", "offer_rates", "run_start", "run_battles", "run_relics", "run_records", "merit", "merit_paid", "run_bosses", "flags", "kept_relics", "clears", "replay", "stash"]


static func create() -> SaveData:
	var s := SaveData.new()
	s.party_slots = int(GameData.get_db().gacha["party_slots"])
	return s


# the fields that make up one run of a quest (parked while a finished chapter is replayed)
const RUN_FIELDS := ["quest", "square", "visited", "resolved", "damage", "carry_extra", "carry_uses", "offer", "events",
	"event_battle", "event_note", "offer_kind", "relics", "danger", "picks_left", "offer_rates", "run_start",
	"run_battles", "run_relics", "run_bosses", "run_records", "layout", "merit_paid", "unworn", "fate", "fate_offer", "affixes"]


func stash_run() -> void:
	stash = {}
	for f in RUN_FIELDS:
		var v: Variant = get(f)
		stash[f] = v.duplicate(true) if v is Dictionary or v is Array else v


func restore_run() -> void:
	for f in stash:
		set(f, stash[f])
	stash = {}
	damage = int(damage)
	danger = int(danger)


func new_lap() -> SaveData:
	## 新周目: the story starts over; the whole collection (tiers as they are), the lord, the name and 战功 come
	## along. No gifts, no other rule changes; the recruit pool also holds every general ever had (recruit_pool).
	_sync()
	var s := SaveData.create()
	s.lap = lap + 1
	s.lord_name = lord_name
	s.merit = merit
	s.owned = owned.duplicate()
	s.soldiers = soldiers.duplicate()
	s.party = party.duplicate()
	s.clears = clears.duplicate()
	s.seen = seen.duplicate()
	s.flags = flags.filter(func(f): return str(f).begins_with("结局"))  # endings reached stay known (later 周目 may branch on them)
	for c in owned:
		if not s.seen.has(c):
			s.seen.append(c)
	s.theme = theme
	s.dupes = dupes.duplicate()
	s.lord_copies = lord_copies
	s.lord_forms = lord_forms.duplicate()
	return s


func to_dict() -> Dictionary:
	var d := {}
	for f in FIELDS:
		d[f] = get(f)
	return d


static func from_dict(d: Dictionary) -> SaveData:
	var s := SaveData.new()
	for f in FIELDS:
		if d.has(f):
			s.set(f, d[f])
	# JSON has no ints: restore them
	s.damage = int(s.damage)
	s.danger = int(s.danger)
	s.run_battles = int(s.run_battles)
	s.merit = int(s.merit)
	s.run_bosses = int(s.run_bosses)
	s.difficulty = int(s.difficulty)
	s.picks_left = int(s.picks_left)
	s.party_slots = int(s.party_slots)
	s.lord_copies = int(s.lord_copies)
	s.lap = int(s.lap)
	for k in s.soldiers:
		s.soldiers[k] = int(s.soldiers[k])
	for k in s.dupes:
		s.dupes[k] = int(s.dupes[k])
	for table in [s.carry_extra, s.carry_uses]:
		for cid in table:
			for sk in table[cid]:
				table[cid][sk] = int(table[cid][sk])
	s._sync()
	return s


func write(path: String = SAVE_PATH) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(to_dict(), " "))


static func read(path: String = SAVE_PATH) -> SaveData:
	if not FileAccess.file_exists(path):
		return null
	return from_dict(GameData.read_json(path))


func _db() -> GameData:
	return GameData.get_db()


func _sync() -> void:
	## Drop cards that no longer exist; soldier ids found in `owned` become soldier copies.
	var db := _db()
	owned = owned.filter(func(c): return db.cards.has(c))
	party = party.filter(func(c): return db.cards.has(c))
	for c in soldiers.keys():
		if not db.cards.has(c):
			soldiers.erase(c)
	for c in owned.filter(func(c): return db.cards[c]["soldier"]):
		soldiers[c] = soldiers.get(c, 0) + 1
	owned = owned.filter(func(c): return not db.cards[c]["soldier"])


func has_card(card_id: String) -> bool:
	_sync()
	if _db().cards[card_id]["soldier"]:
		return soldiers.get(card_id, 0) > 0
	return owned.has(card_id)


func copies(card_id: String) -> int:
	_sync()
	if card_id == "lord":
		return lord_copies
	if _db().cards[card_id]["soldier"]:
		return soldiers.get(card_id, 0)
	return dupes.get(card_id, 1) if owned.has(card_id) else 0


func tier(card_id: String, n := -1) -> int:
	## 0 铜 / 1 银 / 2 金 for a general (or the lord) with n copies (default: the copies owned).
	if n < 0:
		n = copies(card_id)
	var t := 0
	var tiers: Array = _db().gacha["tiers"]
	for i in tiers.size():
		if n >= int(tiers[i]["copies"]):
			t = i
	return t


func maxed(card_id: String) -> bool:
	var tiers: Array = _db().gacha["tiers"]
	return not _db().cards[card_id]["soldier"] and copies(card_id) >= int(tiers[-1]["copies"])


func fighter(card_id: String) -> Dictionary:
	## The card's fighter at the tier it's owned at.
	var db := _db()
	if db.cards[card_id]["soldier"]:
		return db.build_fighter(card_id)
	return db.build_fighter(card_id, float(db.gacha["tiers"][tier(card_id)]["mult"]))


func endings_reached() -> Array:
	## ending ids this save has reached (flags are kept across 周目; this run's own records count too)
	return _db().endings_reached(flags + run_records)


func is_north() -> bool:
	## the north-route lord: the birth record is in this run's records during chapter one and in the lasting flags after it
	return run_records.has("出生：冀州无极") or flags.has("出生：冀州无极")


func lord_form() -> String:
	## the lord card in play: the newest one handed out for this route ("" = the base lord)
	var route := "north" if is_north() else "south"
	var db := _db()
	for i in range(lord_forms.size() - 1, -1, -1):
		var f: Dictionary = db.lord_forms.get(lord_forms[i], {})
		if not f.is_empty() and (f["route"] == "" or f["route"] == route):
			return lord_forms[i]
	return ""


func lord() -> Dictionary:
	## the lord's fighter at its tier; the north route starts in a different host body (own hair, no armor)
	var db := _db()
	return db.build_lord(lord_name, float(db.gacha["tiers"][tier("lord")]["mult"]), is_north(), lord_form())


func upgrade(card_id: String) -> void:
	## 升级: straight to the next tier's copy count.
	var tiers: Array = _db().gacha["tiers"]
	if card_id == "lord":
		lord_copies = maxi(lord_copies, int(tiers[mini(tier("lord") + 1, tiers.size() - 1)]["copies"]))
		return
	var nxt := mini(tier(card_id) + 1, tiers.size() - 1)
	dupes[card_id] = maxi(copies(card_id), int(tiers[nxt]["copies"]))


# ---- getting cards -------------------------------------------------------------

func recruit_offer(rng: RandomNumberGenerator, n: int = 0, rates: Dictionary = {}) -> Array:
	## A few generals (rarity rolled per card); the player keeps one with take(). Owned ones can come again
	## (another copy raises their tier) until they're 金.
	_sync()
	var db := _db()
	if n <= 0:
		n = int(db.gacha["offer_size"]) + offer_extra()
	if rates.is_empty():
		rates = db.gacha["rates"]
	var result: Array = []
	for _i in n:
		if not maxed("lord") and not result.has(db.cards["lord"]) and rng.randf() < float(db.gacha.get("lord_rate", 0.0)):
			result.append(db.cards["lord"])  # now and then the lord's own card turns up
			continue
		var live: Array = []
		var pools := {}
		for r in rates:
			pools[r] = recruit_pool(r).filter(func(c): return not maxed(c["id"]) and not result.has(c))
			if not pools[r].is_empty():
				live.append(r)
		if live.is_empty():
			break
		var rarity: String = GameData.weighted_pick(rng, live, live.map(func(r): return float(rates[r])))
		var p: Array = pools[rarity]
		result.append(p[rng.randi_range(0, p.size() - 1)])
	return result


func recruit_pool(rarity: String) -> Array:
	## the normal pool, plus any general you've had before (story-only ones too, like 董白 or 孙坚)
	var db := _db()
	var p: Array = db.pool(rarity)
	for cid in seen + owned:
		var c: Dictionary = db.cards.get(cid, {})
		if not c.is_empty() and c["rarity"] == rarity and not c["soldier"] and not p.has(c):
			p.append(c)
	return p


func pool_left() -> int:
	var db := _db()
	var n := 0
	for r in db.gacha["rates"]:
		n += recruit_pool(r).filter(func(c): return not maxed(c["id"])).size()
	return n


static func chest_offer(rng: RandomNumberGenerator, n: int, only: Array = []) -> Array:
	## A chest shows n different soldier cards (weighted by how common each is); the player keeps one.
	## `only` limits the pool (a chapter's soldier_pool).
	var db := GameData.get_db()
	var pool: Array = db.soldier_cards() if only.is_empty() else only.map(func(c): return db.cards[c])
	var result: Array = []
	for _i in mini(n, pool.size()):
		var c: Dictionary = GameData.weighted_pick(rng, pool, pool.map(func(x): return float(x["weight"])))
		result.append(c)
		pool.erase(c)
	return result


func chest_chance(overkill: float, boss: bool, bonus := 0.0) -> float:
	## Rance X: bosses always drop a chest; otherwise 50% + half the overkill (100% overkill = certain) + 宝物 bonus.
	var g: Dictionary = _db().gacha
	if boss:
		return 1.0
	return clampf(float(g["chest_base"]) + float(g.get("chest_overkill", 0.5)) * overkill + bonus, 0.0, 1.0)


func chest_after_battle(rng: RandomNumberGenerator, overkill: float, boss: bool, only: Array = [],
		enemy_card := "", bonus := 0.0) -> Array:
	var g: Dictionary = _db().gacha
	if rng.randf() >= chest_chance(overkill, boss, bonus):
		return []
	var cards := chest_mix(rng, int(g["chest_cards_boss"] if boss else g["chest_cards"]) + offer_extra(), only)
	# the beaten enemy's own card may be in there (bosses and elites more often)
	var db := _db()
	var card_chance := float(db.battle["enemy_card_chance_boss" if boss else "enemy_card_chance"])
	if enemy_card != "" and not maxed(enemy_card) and not cards.has(db.cards[enemy_card]) and rng.randf() < card_chance:
		cards[cards.size() - 1] = db.cards[enemy_card]
	return cards


func level() -> int:
	## 难度 as the player sees it: starts at 1
	return difficulty + 1


func chest_general_chance() -> float:
	var cg: Dictionary = _db().gacha.get("chest_general", {})
	return minf(0.9, float(cg.get("base", 0.0)) + float(cg.get("per_level", 0.0)) * difficulty)


func chest_mix(rng: RandomNumberGenerator, n: int, only: Array = []) -> Array:
	## a chest's cards: soldiers, each of which may turn into a general (more often at a higher 难度)
	var cards := chest_offer(rng, n, only)
	var chance := chest_general_chance()
	for i in cards.size():
		if rng.randf() < chance:
			var g := recruit_offer(rng, 1)
			if not g.is_empty() and not cards.has(g[0]):
				cards[i] = g[0]
	return cards


func offer_extra() -> int:
	## 招贤榜: one more card on every pick-one
	var n := 0
	for rid in active_relics():
		n += int(_db().relics[rid]["mods"].get("offer_extra", 0))
	return n


func take(card_id: String) -> Dictionary:
	## Keep the one card picked from a recruit offer (a general: another copy if owned) or a chest (a soldier).
	var card: Dictionary = _db().cards[card_id]
	grant_card(card_id)
	return card


func grant_card(card_id: String) -> void:
	## Give a card (story / pick). Slots it into the party if there's room for its troop.
	_sync()
	if card_id == "lord":  # another copy of the lord: maybe a higher tier
		lord_copies += 1
		return
	if _db().cards[card_id]["soldier"]:
		soldiers[card_id] = soldiers.get(card_id, 0) + 1
	elif not owned.has(card_id):
		owned.append(card_id)
		if not seen.has(card_id):
			seen.append(card_id)
	else:
		dupes[card_id] = copies(card_id) + 1
	if not party.has(card_id) and validate_party(party + [card_id]) == "":
		party.append(card_id)


# ---- 宝物 in units (Rance X items) --------------------------------------------------

func units() -> Array:
	## the fielded units: the lord's, then each leader's
	return ["lord"] + party


func unit_troop(unit: String) -> String:
	return "lord" if unit == "lord" else _db().cards[unit]["troop"]


func relic_unit(rid: String) -> String:
	## the unit a worn 宝物 sits in (its troop's leader, or the lord); "" when it's left in the pool or its troop
	## isn't out
	if unworn.has(rid):
		return ""
	var troop: String = _db().relics[rid]["troop"]
	for u in units():
		if unit_troop(u) == troop:
			return u
	return ""


func relic_unit_for_troop(troop: String) -> String:
	## the fielded unit of a troop ("" if nobody leads it)
	for u in units():
		if unit_troop(u) == troop:
			return u
	return ""


func unit_relics(unit: String) -> Array:
	return relics.filter(func(r): return relic_unit(r) == unit)


func set_worn(rid: String, on: bool) -> void:
	## 装上 / 不装 (it stays in the pool, no effect)
	if on:
		unworn.erase(rid)
	elif not unworn.has(rid):
		unworn.append(rid)


func active_relics() -> Array:
	## the 宝物 that work: worn, and their unit is in the party
	return relics.filter(func(r): return relic_unit(r) != "")


func set_brought(card_id: String, on: bool) -> void:
	## 带上 / 不带: a card left behind joins no unit (a leader is always brought)
	if on:
		benched.erase(card_id)
	elif not benched.has(card_id) and not party.has(card_id):
		benched.append(card_id)


# ---- party ---------------------------------------------------------------------

func owned_ids() -> Array:
	_sync()
	var ids: Array = owned.duplicate()
	for c in soldiers:
		if soldiers[c] > 0:
			ids.append(c)
	return ids


func validate_party(card_ids: Array) -> String:
	## "" if the party is legal, otherwise the reason.
	var db := _db()
	if card_ids.size() > party_slots - 1:
		return "最多 %d 张卡（主公固定占一位）" % (party_slots - 1)
	var troops_seen := {}
	var people := {}
	for cid in card_ids:
		if not has_card(cid):
			return "未拥有卡牌 " + cid
		var c: Dictionary = db.cards[cid]
		if people.has(c["person"]):
			return "同一武将的不同版本不能同时上阵（%s）" % c["name"]
		if troops_seen.has(c["troop"]):
			return "兵种重复：%s 只能由一人指挥（%s）" % [db.troops[c["troop"]]["name"], c["name"]]
		troops_seen[c["troop"]] = true
		people[c["person"]] = true
	return ""


func troop_members(leader_id: String) -> Array:
	## [members, weights]: other generals of the troop count fully; each soldier card type counts
	## 1, decay, decay² … per copy (a soldier leader uses up one of its own copies).
	_sync()
	var db := _db()
	var troop: String = db.cards[leader_id]["troop"]
	var decay := float(db.gacha["soldier_decay"])
	var members: Array = []
	var weights: Array = []
	for c in owned:
		if c != leader_id and db.cards[c]["troop"] == troop and not benched.has(c):
			members.append(fighter(c))
			weights.append(1.0)
	for c in soldiers:
		if db.cards[c]["troop"] != troop or (benched.has(c) and c != leader_id):
			continue
		var n: int = soldiers[c] - (1 if c == leader_id else 0)
		var f := db.build_fighter(c)
		for i in n:
			members.append(f)
			weights.append(pow(decay, i))
	return [members, weights]


func leader_for(card_id: String) -> Dictionary:
	var mw := troop_members(card_id)
	return _db().build_leader(fighter(card_id), mw[0], mw[1])


static func leader_power(ld: Dictionary) -> int:
	return int(round(ld["at"] + ld["hp"] / 5.0))


func auto_party() -> Array:
	## Best leader per troop (the strongest card leads), then the strongest troops that fit.
	var ranked := owned_ids()
	var powers := {}
	for c in ranked:
		powers[c] = leader_power(leader_for(c))
	ranked.sort_custom(func(a, b): return powers[a] > powers[b])
	var picked: Array = []
	for cid in ranked:
		if picked.size() == party_slots - 1:
			break
		if validate_party(picked + [cid]) == "":
			picked.append(cid)
	return picked


func swap_roster() -> Array:
	## 换人: every owned card that is not leading (benched cards stay out), of any troop, built as the leader it would be —
	## the battle swaps these in mid-fight
	var out: Array = []
	for c in owned_ids():
		if not party.has(c) and not benched.has(c):
			out.append(leader_for(c))
	return out


func party_leaders() -> Array:
	## The lord (alone in its unit) plus one leader per chosen troop.
	var db := _db()
	var leaders: Array = [db.build_leader(lord(), [])]
	for cid in party:
		if has_card(cid):
			leaders.append(leader_for(cid))
	return leaders


func record_win(scenario_id: String) -> void:
	if not cleared.has(scenario_id):
		cleared.append(scenario_id)
