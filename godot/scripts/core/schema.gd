class_name Schema
extends RefCounted
## Data checks driven by data/schema.json — add a rule there, not an assert in code.
##
## A path walks the merged game data (cards.json + its parts, plus story / endings / ui / side_stories under their file
## names) one dot-separated step at a time:
##   name   that key of a dict (missing = nothing)
##   *      every value of a dict / element of an array; a plain value passes through as itself (fields that are
##          "a line or a list of lines" need no special case)
##   **     the node itself and everything under it, at any depth
##   @keys  a dict's keys
## Rules (each may carry "each": <path> — then its other paths are read from every node "each" finds, and a path that
## starts with "/" (in "refs" or "to") is read from the top instead; "why" is printed with every failure):
##   {"refs": <path>, "to": <path or [paths]>, "also": [..]}   every string found must be one of the values the "to"
##                                               paths find (or one of "also"); a "to" entry may be {"path", "prefix"}
##   {"enum": <path>, "values": [..]}            every value found must be one of these
##   {"required": <path>}                        (with each) every node has a non-empty value there
##   {"forbid": <path>, "matching": <regex>}     nothing may be found there (or nothing matching the regex)
##   {"unique": <path>}                          no value is found twice
## Speed (it is ~95 rules over 1600 squares): "to" sets and common path prefixes read from the top are kept in a memo,
## and a rule runs without breadcrumbs first — only a rule that finds something wrong runs again to say where.


static func check(root: Dictionary, schema: Dictionary) -> Array:
	## A rule that reaches nothing at all is an error too (a misspelt path would pass forever) — except "forbid", and
	## rules marked "optional": true (a field no data uses yet, kept so its first use is checked).
	var errors: Array = []
	var memo := {}
	for rule in schema.get("rules", []):
		var found: Array = []
		var reached := _run(root, rule, found, memo, false)
		if not found.is_empty():
			_run(root, rule, errors, memo, true)
		if reached == 0 and not rule.has("forbid") and not rule.get("optional", false):
			errors.append("schema rule reaches nothing (misspelt path?): %s" % JSON.stringify(rule))
	return errors


static func _run(root: Dictionary, rule: Dictionary, errors: Array, memo: Dictionary, crumbs: bool) -> int:
	var items: Array = [[root, ""]] if not rule.has("each") else walk(root, rule["each"], "", crumbs)
	var reached := 0
	for it in items:
		reached += _rule(root, rule, it[0], it[1], errors, memo, crumbs)
	return reached


static func _rule(root: Dictionary, rule: Dictionary, node: Variant, at: String, errors: Array, memo: Dictionary, crumbs: bool) -> int:
	## checks one node; returns how many values the rule looked at
	var why: String = (" — " + str(rule["why"])) if rule.has("why") else ""
	var top: Variant = memo if (not crumbs and is_same(node, root)) else null  # a walk from the top may reuse prefixes
	if rule.has("refs"):
		var allowed := {}
		var tos: Array = rule["to"] if rule["to"] is Array else [rule["to"]]
		for p in tos:
			var pre: String = p.get("prefix", "") if p is Dictionary else ""
			var path: String = p["path"] if p is Dictionary else p
			var shared := not rule.has("each") or path.begins_with("/")
			var key := "to|" + pre + "|" + path
			if shared and memo.has(key):
				allowed.merge(memo[key])
				continue
			var got := {}
			for hit in _read(root, node, path, memo):
				got[pre + str(hit[0])] = true
			if shared:
				memo[key] = got
			allowed.merge(got)
		for v in rule.get("also", []):
			allowed[v] = true
		var rp: String = rule["refs"]  # "/…" = read from the top even inside "each" (every theme checks every event)
		var hits := walk(root, rp.substr(1), "", crumbs, memo if not crumbs else null) if rp.begins_with("/") else walk(node, rp, at, crumbs, top)
		for hit in hits:
			if hit[0] is String and hit[0] != "" and not allowed.has(hit[0]):
				errors.append("%s = %s: not in %s%s" % [hit[1], hit[0], str(tos), why])
		return hits.size()
	if rule.has("enum"):
		var hits := walk(node, rule["enum"], at, crumbs, top)
		for hit in hits:
			if not rule["values"].has(hit[0]):
				errors.append("%s = %s: not one of %s%s" % [hit[1], str(hit[0]), str(rule["values"]), why])
		return hits.size()
	if rule.has("required"):
		var hits := walk(node, rule["required"], at, crumbs)
		if hits.is_empty() or hits.all(func(h): return h[0] == null or ((h[0] is String or h[0] is Array or h[0] is Dictionary) and h[0].is_empty())):
			errors.append("%s: needs %s%s" % [at, rule["required"], why])
		return 1
	if rule.has("forbid"):
		var re: RegEx = null
		if rule.has("matching"):
			re = RegEx.create_from_string(rule["matching"])
		for hit in walk(node, rule["forbid"], at, crumbs):
			if re == null or (hit[0] is String and re.search(hit[0]) != null):
				errors.append("%s = %s: not allowed%s" % [hit[1], str(hit[0]), why])
		return 0
	if rule.has("unique"):
		var seen := {}
		var hits := walk(node, rule["unique"], at, crumbs)
		for hit in hits:
			if seen.has(hit[0]):
				errors.append("%s = %s: also at %s%s" % [hit[1], str(hit[0]), seen[hit[0]], why])
			seen[hit[0]] = hit[1]
		return hits.size()
	errors.append("schema rule of unknown kind: %s" % JSON.stringify(rule))
	return 1


static func _read(root: Dictionary, node: Variant, path: String, memo: Dictionary) -> Array:
	if path.begins_with("/"):
		return walk(root, path.substr(1), "", false, memo)
	return walk(node, path, "", false, memo if is_same(node, root) else null)


static func walk(node: Variant, path: String, at := "", crumbs := true, memo: Variant = null) -> Array:
	## every [value, breadcrumb] the path reaches from node (crumbs false: no breadcrumbs). memo (only for walks from the
	## top without breadcrumbs): every prefix's result is kept and reused
	var steps := path.split(".", false)
	var out: Array = [[node, at]]
	var start := 0
	if memo != null:
		for i in range(steps.size(), 0, -1):
			var key := "walk|" + ".".join(steps.slice(0, i))
			if memo.has(key):
				out = memo[key]
				start = i
				break
	for i in range(start, steps.size()):
		var nxt: Array = []
		for hit in out:
			_step(hit[0], steps[i], hit[1], nxt, crumbs)
		out = nxt
		if memo != null:
			memo["walk|" + ".".join(steps.slice(0, i + 1))] = out
	return out


static func _step(v: Variant, step: String, at: String, out: Array, crumbs := true) -> void:
	match step:
		"*":
			if v is Dictionary:
				for k in v:
					out.append([v[k], ("%s.%s" % [at, k]).trim_prefix(".") if crumbs else ""])
			elif v is Array:
				for i in v.size():
					out.append([v[i], "%s[%d]" % [at, i] if crumbs else ""])
			elif v != null:
				out.append([v, at])
		"**":
			out.append([v, at])
			if v is Dictionary or v is Array:
				var kids: Array = []
				_step(v, "*", at, kids, crumbs)
				for k in kids:
					_step(k[0], "**", k[1], out, crumbs)
		"@keys":
			if v is Dictionary:
				for k in v:
					out.append([k, ("%s.%s" % [at, k]).trim_prefix(".") if crumbs else ""])
		_:
			if v is Dictionary and v.has(step):
				out.append([v[step], ("%s.%s" % [at, step]).trim_prefix(".") if crumbs else ""])
