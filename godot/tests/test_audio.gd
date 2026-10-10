class_name TestAudio
extends TestCase


func test_bgm_tracks_exist() -> void:
	var bgm_script: GDScript = load("res://scripts/audio/bgm.gd")
	check(bgm_script != null, "bgm.gd should load")
	var inst = bgm_script.new()
	for track in inst.TRACKS:
		var path: String = inst.TRACKS[track]
		check(ResourceLoader.exists(path), "BGM track file must exist: " + path)
	inst.free()


func test_sfx_battle_shouts_exist() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio.json"))
	var sfx: Dictionary = data.get("sfx", {})
	for k in [
		"shout_male", "shout_female", "shout_male_ultimate", "shout_female_ultimate",
		"shout_enemy", "shout_enemy_roar", "shout_enemy_female", "shout_enemy_female_roar"
	]:
		check(sfx.has(k), "audio.json must have shout: " + k)
		for path in sfx[k]["files"]:
			var full_path: String = "res://data/audio/%s" % str(path)
			check(ResourceLoader.exists(full_path), "%s file exists: %s" % [k, full_path])
