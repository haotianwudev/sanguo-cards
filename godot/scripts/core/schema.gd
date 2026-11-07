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
## starts with "/" is read from the top instead; "why" is printed with every failure):
##   {"refs": <path>, "to": <path or [paths]>, "also": [..]}   (a "to" entry may be {"path", "prefix"})   every string found must be one of the values the "to"
##                                               paths find (or one of "also")
##   {"enum": <path>, "values": [..]}            every value found must be one of these
##   {"required": <path>}                        (with each) every node has a non-empty value there
##   {"forbid": <path>, "matching": <regex>}     nothing may be found there (or nothing matching the regex)
##   {"unique": <path>}                          no value is found twice


static func check(root: Dictionary, schema: Dictionary) -> Array:
	## A rule that reaches nothing at all is an error too (a misspelt path would pass forever) — except "forbid", and
	## rules marked "optional": true (a field no data uses yet, kept so its first use is checked).
	var errors: Array = []
	for rule in schema.get("rules", []):
		var items: Array = [[root, ""]] if not rule.has("each") else walk(root, rule["each"])
		var reached := 0
		for it in items:
			reached += _rule(root, rule, it[0], it[1], errors)
		if reached == 0 and not rule.has("forbid") and not rule.get("optional", false):
			errors.append("schema rule reaches nothing (misspelt path?): %s" % JSON.stringify(rule))
	return errors


static func _rule(root: Dictionary, rule: Dictionary, node: Variant, at: String, errors: Array) -> int:
	## checks one node; returns how many values the rule looked at
	var why: String = (" — " + str(rule["why"])) if rule.has("why") else ""
	if rule.has("refs"):
		var allowed := {}
		var tos: Array = rule["to"] if rule["to"] is Array else [rule["to"]]
		for p in tos:  # a path, or {"path": .., "prefix": ..} for ids built at load (lord:<form>)
			var pre: String = p.get("prefix", "") if p is Dictionary else ""
			for hit in _read(root, node, p["path"] if p is Dictionary else p):
				allowed[pre + str(hit[0])] = true
		for v in rule.get("also", []):
			allowed[v] = true
		var hits := walk(node, rule["refs"], at)
		for hit in hits:
			if hit[0] is String and hit[0] != "" and not allowed.has(hit[0]):
				errors.append("%s = %s: not in %s%s" % [hit[1], hit[0], str(tos), why])
		return hits.size()
	if rule.has("enum"):
		var hits := walk(node, rule["enum"], at)
		for hit in hits:
			if not rule["values"].has(hit[0]):
				errors.append("%s = %s: not one of %s%s" % [hit[1], str(hit[0]), str(rule["values"]), why])
		return hits.size()
	if rule.has("required"):
		var hits := walk(node, rule["required"], at)
		if hits.is_empty() or hits.all(func(h): return h[0] == null or ((h[0] is String or h[0] is Array or h[0] is Dictionary) and h[0].is_empty())):
			errors.append("%s: needs %s%s" % [at, rule["required"], why])
		return 1
	if rule.has("forbid"):
		var re: RegEx = null
		if rule.has("matching"):
			re = RegEx.create_from_string(rule["matching"])
		for hit in walk(node, rule["forbid"], at):
			if re == null or (hit[0] is String and re.search(hit[0]) != null):
				errors.append("%s = %s: not allowed%s" % [hit[1], str(hit[0]), why])
		return 0
	if rule.has("unique"):
		var seen := {}
		var hits := walk(node, rule["unique"], at)
		for hit in hits:
			if seen.has(hit[0]):
				errors.append("%s = %s: also at %s%s" % [hit[1], str(hit[0]), seen[hit[0]], why])
			seen[hit[0]] = hit[1]
		return hits.size()
	errors.append("schema rule of unknown kind: %s" % JSON.stringify(rule))
	return 1


static func _read(root: Dictionary, node: Variant, path: String) -> Array:
	return walk(root, path.substr(1)) if path.begins_with("/") else walk(node, path)


static func walk(node: Variant, path: String, at := "") -> Array:
	## every [value, breadcrumb] the path reaches from node
	var out: Array = [[node, at]]
	for step in path.split(".", false):
		var nxt: Array = []
		for hit in out:
			_step(hit[0], step, hit[1], nxt)
		out = nxt
	return out


static func _step(v: Variant, step: String, at: String, out: Array) -> void:
	match step:
		"*":
			if v is Dictionary:
				for k in v:
					out.append([v[k], ("%s.%s" % [at, k]).trim_prefix(".")])
			elif v is Array:
				for i in v.size():
					out.append([v[i], "%s[%d]" % [at, i]])
			elif v != null:
				out.append([v, at])
		"**":
			out.append([v, at])
			if v is Dictionary or v is Array:
				var kids: Array = []
				_step(v, "*", at, kids)
				for k in kids:
					_step(k[0], "**", k[1], out)
		"@keys":
			if v is Dictionary:
				for k in v:
					out.append([k, ("%s.%s" % [at, k]).trim_prefix(".")])
		_:
			if v is Dictionary and v.has(step):
				out.append([v[step], ("%s.%s" % [at, step]).trim_prefix(".")])
