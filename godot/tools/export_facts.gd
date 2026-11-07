extends SceneTree
## Export what the game itself says about every chapter on every route, for the doc generators (tools/*.py read it through
## tools/facts.py — they never re-derive a game rule):
##     godot --headless --path godot --script res://tools/export_facts.gd -- --out=<file.json>
##
## A chapter-on-a-route is a quest the route can play (its event_scope, or a pool_override's, names the route; "universal" =
## every route). Which of its squares belong to the route comes from Quests.gate3 with only what the route itself decides
## known: its own birth line holds, the other routes' birth lines don't, and (second pass) a line that only squares of
## the other routes record doesn't either — except an ending, which both routes' saves share (shared.json). Everything else is "maybe" — a square a later 周目 opens still counts.


func _init() -> void:
	var out_path := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)
	var db := GameData.get_db()
	var routes: Array = db.routes.keys()
	# pass 1: squares per route knowing only births and endings; collect the lines each route can record
	var recorded := {}
	for r in routes:
		recorded[r] = {}
		for q in db.quests:
			if _on_route(q, r):
				for line in _records(q, _squares(q, _truth(db, r, {})), _truth(db, r, {})):
					recorded[r][line] = true
	var chapters: Array = []
	for q in db.quests:
		# a "universal" quest is one chapter both routes share (route ""): known as neither route's
		var on: Array = [""] if q["event_scope"] == "universal" else routes.filter(func(r): return _on_route(q, r))
		for r in on:
			var truth := _truth(db, r, recorded)
			var save := SaveData.new()
			save.flags = [db.routes[r]] if r != "" else []
			var p := Quests.pools(q, save)
			chapters.append({
				"key": q["id"] if on.size() == 1 else "%s_%s" % [q["id"], r.substr(0, 1)],
				"quest": q["id"], "route": r, "title": Quests.title(q, save), "map": Quests.map_key(q, save),
				"squares": _squares(q, truth),
				"recruit_pool": p["recruit_pool"], "soldier_pool": q["soldier_pool"], "event_pool": p["event_pool"],
				"soldier_scope": p["soldier_scope"], "event_scope": p["event_scope"],
				"own_events": p["event_pool"].filter(func(e): return Quests.event_source(q, e) == "chapter"),
				"side_stories": db.side_stories.get(q["id"], []).filter(func(st): return Quests.gate3(st, truth) != 0).map(func(st): return st["id"]),
				"chapter_pages": db.chapter_pages.get(q["id"], []).filter(func(pg): return Quests.gate3(pg, truth) != 0).map(func(pg): return pg["cg"]),
				"ending": _ending_id(db, q, r)})
	var public := {}
	for r in routes:
		var s := SaveData.new()
		s.flags = [db.routes[r]]
		public[r] = s.chest_pools()["public"]["soldier"].map(func(c): return c["id"])
	var facts := {"routes": db.routes, "chapters": chapters, "card_chapters": db.card_chapters, "public_soldiers": public, "errors": GameData.check_schema()}
	var f := FileAccess.open(out_path, FileAccess.WRITE) if out_path != "" else null
	if f == null:
		print(JSON.stringify(facts))
	else:
		f.store_string(JSON.stringify(facts, " ", false))
		f.close()
	quit(0)


func _on_route(q: Dictionary, r: String) -> bool:
	var scopes: Array = [q["event_scope"]] + q["pool_overrides"].map(func(o): return o["event_scope"])
	return scopes.has("universal") or scopes.has(r)


func _truth(db: GameData, r: String, recorded: Dictionary) -> Callable:
	## what route r knows about a line: 1 its own birth, 0 another route's birth or a line only the others record, else -1
	return func(line: String) -> int:
		if r == "":
			return -1
		for other in db.routes:
			if db.routes[other] == line:
				return 1 if other == r else 0
		if db.endings.values().any(func(e): return e["title"] == line):
			return -1  # endings are shared by both routes' saves (shared.json): the other route's can open this one's story
		if not recorded.is_empty() and not recorded[r].has(line) and recorded.values().any(func(d): return d.has(line)):
			return 0
		return -1


func _squares(q: Dictionary, truth: Callable) -> Array:
	## the squares route `truth` can reach from the start: next, every choice it could take, a lost fight's lose_goto
	var seen := {}
	var todo: Array = [q["start"]]
	while not todo.is_empty():
		var sid: String = todo.pop_back()
		if seen.has(sid) or not q["squares"].has(sid):
			continue
		var s: Dictionary = q["squares"][sid]
		if Quests.gate3(s, truth) == 0:
			continue
		seen[sid] = true
		todo.append_array(s["next"])
		for o in s["choose"]:
			if Quests.gate3(o, truth) != 0 and (o["record"] == "" or truth.call(o["record"]) != 0):
				todo.append(o["goto"])
		if s["lose_goto"] != "":
			todo.append(s["lose_goto"])
	var ids: Array = seen.keys()
	ids.sort_custom(func(a, b):
		var sa: Dictionary = q["squares"][a]
		var sb: Dictionary = q["squares"][b]
		return [sa["x"], sa["y"], a] < [sb["x"], sb["y"], b])
	return ids


func _records(q: Dictionary, ids: Array, truth: Callable) -> Array:
	var out: Array = []
	for sid in ids:
		var s: Dictionary = q["squares"][sid]
		out += [s["record"], s["record_win"], s["record_lose"]]
		for o in s["choose"]:
			if o["record"] != "" and truth.call(o["record"]) != 0:
				out.append(o["record"])
	return out.filter(func(l): return l != "")


func _ending_id(db: GameData, q: Dictionary, r: String) -> String:
	## the quest's ending, when it is this route's (endings.json route: south / north / both; a shared chapter (r "") shows any)
	var eid: String = q["ending"].get("id", "")
	return eid if eid != "" and (r == "" or str(db.endings[eid].get("route", "")) in ["both", r]) else ""
