class_name ScriptCheck
extends RefCounted
## `godot --headless --path godot -- --check-scripts` (tools/check.sh, CI): compile every script under res://scripts with
## the autoloads in place. The test runner only compiles what the tests touch, and has no autoloads — a UI script that
## doesn't parse, or trips a warning project.godot treats as an error (unused variables / parameters …), would pass unseen.


static func run() -> int:
	var bad: Array = []
	for path in _scripts_under("res://scripts"):
		var s: Script = load(path)
		if s == null or not s.can_instantiate():
			bad.append(path)
	print("check-scripts: %d broken%s" % [bad.size(), (": " + ", ".join(bad)) if not bad.is_empty() else ""])
	return 1 if not bad.is_empty() else 0


static func _scripts_under(dir: String) -> Array:
	var out: Array = []
	for f in ResourceLoader.list_directory(dir):
		if f.ends_with("/"):
			out += _scripts_under(dir + "/" + f.trim_suffix("/"))
		elif f.ends_with(".gd"):
			out.append(dir + "/" + f)
	return out
