class_name TestAudio
extends TestCase

const SfxScript := preload("res://scripts/audio/sfx.gd")


func test_bgm_tracks_exist() -> void:
	var bgm_script: GDScript = load("res://scripts/audio/bgm.gd")
	check(bgm_script != null, "bgm.gd should load")
	var inst = bgm_script.new()
	for track in inst.TRACKS:
		var path: String = inst.TRACKS[track]
		check(ResourceLoader.exists(path), "BGM track file must exist: " + path)
	inst.free()


func test_every_voice_line_has_its_file() -> void:
	## audio.json voices → audio/voice/*.ogg (tools/gen_voices.py); a missing file means the generator wasn't rerun
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio.json"))
	var voices: Dictionary = data.get("voices", {})
	var missing: Array = []
	for prof in voices:
		for moment in SfxScript.MOMENTS:
			for line in voices[prof].get(moment, []):
				var path := SfxScript.voice_file(prof, moment, line, voices[prof].get("tts", []))
				if not ResourceLoader.exists(path):
					missing.append("%s/%s %s" % [prof, moment, str(line)])
		for key in voices[prof]:
			check(key in SfxScript.MOMENTS or key in ["name", "tts", "volume_db", "cgs"], "voice %s: unknown field %s" % [prof, key])
	check(missing.is_empty(), "voice lines without a file (run python tools/gen_voices.py, then --import): %s" % str(missing.slice(0, 6)))


func test_default_voices_cover_every_role() -> void:
	## every role has a profile, and each has the moments the battle screen falls back to
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio.json"))
	var defaults: Dictionary = data.get("voice_defaults", {})
	var sfx: Node = SfxScript.new()
	sfx._load_voices(data)
	for role in ["lord", "strategist", "female", "male", "enemy_female", "enemy_male"]:
		var prof := str(defaults.get(role, ""))
		check(data["voices"].has(prof), "voice_defaults.%s names no profile" % role)
		check(sfx.has_voice(prof, "attack"), "default voice %s has no attack line" % prof)
	check(sfx.has_voice(str(defaults["female"]), "heal"), "the female default keeps the healing lines")
	for role in ["enemy_female", "enemy_male"]:
		check(sfx.has_voice(str(defaults[role]), "roar"), "%s needs a roar (charge / rage)" % role)
	sfx.free()


func test_cards_and_enemies_name_existing_voices() -> void:
	## a card's or enemy's `voice` must be a profile in audio.json
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio.json"))
	var voices: Dictionary = data.get("voices", {})
	var db := GameData.get_db()
	var bad: Array = []
	for cid in db.cards:
		var v := str(db.cards[cid].get("voice", ""))
		if v != "" and not voices.has(v):
			bad.append("card %s: %s" % [cid, v])
	for eid in db.enemies:
		var v := str(db.enemies[eid].get("voice", ""))
		if v != "" and not voices.has(v):
			bad.append("enemy %s: %s" % [eid, v])
	check(bad.is_empty(), "voice that names no profile: %s" % str(bad))



func test_a_voices_cgs_are_real_story_pictures() -> void:
	## voices.<profile>.cgs: every key is a CG some square, event or interlude actually shows (so the line can play)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio.json"))
	var used := {}
	var db := GameData.get_db()
	for q in db.quests:
		for sid in q["squares"]:
			used[str(q["squares"][sid].get("cg", ""))] = true
	for eid in db.events:
		used[str(db.events[eid].get("cg", ""))] = true
	for k in db.interludes:
		for sc in db.interludes[k]:
			used[str(sc.get("cg", ""))] = true
	var bad: Array = []
	for prof in data["voices"]:
		var p: Dictionary = data["voices"][prof]
		for key in p.get("cgs", []):
			if not used.has(key):
				bad.append("%s: %s" % [prof, key])
		check(p.get("cgs", []).is_empty() or p.has("intro"), "voice %s lists cgs but has no intro line" % prof)
	check(bad.is_empty(), "voices.cgs naming a CG no scene shows: %s" % str(bad))


func test_every_lvbu_fight_has_his_entrance_line() -> void:
	## 吕布 says 「谁敢与我一战！」 when the fight starts — every enemy drawn with his face resolves to the lvbu voice
	var db := GameData.get_db()
	var bad: Array = []
	for eid in db.enemies:
		var e: Dictionary = db.enemies[eid]
		if str(e.get("portrait", "")) != "lvbu":
			continue
		var card: Dictionary = db.cards.get(str(e.get("card", "")), {})
		var face: Dictionary = db.cards.get(str(e.get("portrait", "")), {})
		var own := ""
		for v in [e.get("voice", ""), card.get("voice", ""), face.get("voice", "")]:
			if str(v) != "" and own == "":
				own = str(v)
		if own != "lvbu":
			bad.append(eid)
	check(bad.is_empty(), "吕布 enemies without his voice: %s" % str(bad))
