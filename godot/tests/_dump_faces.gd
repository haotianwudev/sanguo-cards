extends SceneTree
## dev tool: print every dialogue line with the face Kit.speakers gives it
func _init() -> void:
	var s: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/story.json"))
	var out := []
	for q in s["quests"]:
		var sq: Dictionary = q["squares"]
		var ids := sq.keys()
		ids.sort_custom(func(a, b): return sq[a]["x"] < sq[b]["x"])
		for sid in ids:
			var lines: Array = sq[sid].get("text", [])
			var keys := Kit.speakers(lines, sq[sid].get("portraits", []))
			for i in lines.size():
				if str(lines[i]).contains("「") or str(lines[i]).contains("："):
					out.append("%s/%s\t[%s]\t%s" % [q["id"], sid, keys[i], str(lines[i]).substr(0, 70)])
	for eid in s["events"]:
		var lines: Array = s["events"][eid].get("text", [])
		var keys := Kit.speakers(lines, s["events"][eid].get("portraits", []))
		for i in lines.size():
			if str(lines[i]).contains("「"):
				out.append("event/%s\t[%s]\t%s" % [eid, keys[i], str(lines[i]).substr(0, 70)])
	var f := FileAccess.open("user://faces.txt", FileAccess.WRITE)
	f.store_string("\n".join(out))
	print(ProjectSettings.globalize_path("user://faces.txt"))
	quit()
