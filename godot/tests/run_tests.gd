extends SceneTree
## Headless test runner:  godot --headless --path godot --script res://tests/run_tests.gd
## Runs every test_* method in res://tests/test_*.gd. A test fails if a check() fails or if the engine
## reports any script error / failed assert while it runs.


class ErrorCatcher extends Logger:
	var errors: Array = []

	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, _error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		errors.append("%s:%d %s %s %s" % [file, line, function, code, rationale])

	func _log_message(_message: String, _error: bool) -> void:
		pass


func _init() -> void:
	var catcher := ErrorCatcher.new()
	OS.add_logger(catcher)
	var only := OS.get_environment("TEST_FILTER")
	var files: Array = []
	for f in DirAccess.get_files_at("res://tests"):
		if f.begins_with("test_") and f.ends_with(".gd"):
			files.append(f)
	files.sort()
	var total := 0
	var failed: Array = []
	var t0 := Time.get_ticks_msec()
	for f in files:
		var inst: Object = load("res://tests/" + f).new()
		for m in inst.get_method_list():
			var name: String = m["name"]
			if not name.begins_with("test_") or (only != "" and not name.contains(only)):
				continue
			total += 1
			inst.set("failures", [])
			catcher.errors.clear()
			inst.call(name)
			var problems: Array = inst.get("failures") + catcher.errors
			if problems.is_empty():
				print("  ok    %s  %s" % [f.get_basename(), name])
			else:
				failed.append(name)
				print("  FAIL  %s  %s" % [f.get_basename(), name])
				for p in problems:
					print("        " + str(p))
	print("\n%d passed, %d failed in %.1fs" % [total - failed.size(), failed.size(), (Time.get_ticks_msec() - t0) / 1000.0])
	quit(1 if not failed.is_empty() else 0)
