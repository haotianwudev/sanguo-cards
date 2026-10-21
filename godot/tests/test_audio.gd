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
				var path := SfxScript.voice_file(prof, moment, line, voices[prof])
				if not ResourceLoader.exists(path):
					missing.append("%s/%s %s" % [prof, moment, str(line)])
		for key in voices[prof]:
			check(key in SfxScript.MOMENTS or key in ["name", "tts", "volume_db", "engine", "ref", "emo", "source", "voice", "emotion", "speed", "pitch", "tempo"], "voice %s: unknown field %s" % [prof, key])
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
	for troop in data.get("troop_voices", {}):  # a troop voice names a real profile and a real troop
		check(data["voices"].has(str(data["troop_voices"][troop])), "troop_voices.%s names no profile" % troop)
		check(GameData.get_db().troops.has(troop), "troop_voices: no troop %s" % troop)
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



func test_every_fight_against_a_voiced_general_uses_his_voice() -> void:
	## a general with his own voice (吕布, 赵云 …) sounds like himself in every fight against him — every enemy drawn
	## with his face resolves to his voice, even one that drops a soldier card (吕布 dropping 并州兵, 赵云 常山亲卫)
	var db := GameData.get_db()
	var bad: Array = []
	var checked := 0
	for eid in db.enemies:
		var e: Dictionary = db.enemies[eid]
		var face: Dictionary = db.cards.get(str(e.get("portrait", "")), {})
		if str(face.get("voice", "")) == "":
			continue
		checked += 1
		var card: Dictionary = db.cards.get(str(e.get("card", "")), {})
		var own := ""
		for v in [e.get("voice", ""), card.get("voice", ""), face.get("voice", "")]:
			if str(v) != "" and own == "":
				own = str(v)
		if own != str(face["voice"]):
			bad.append("%s → %s" % [eid, own])
	check(checked >= 12, "expected the 吕布 / 赵云 fights to be found (%d)" % checked)
	check(bad.is_empty(), "enemies not using their general's voice: %s" % str(bad))


func test_a_cg_voice_waits_for_its_speakers_first_line() -> void:
	## 「凤仪亭」: 吕布 and 貂蝉 (everyone with a voice of his own, no list) each say their entrance line on their own first line of the scene, not when the picture comes up
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio.json"))
	var sq: Dictionary = {}
	for q in GameData.get_db().quests:
		for sid in q["squares"]:
			if str(q["squares"][sid].get("cg", "")) == "c5_fengyi":
				sq = q["squares"][sid]
	check(not sq.is_empty(), "the 凤仪亭 square is gone")
	var keys := Kit.speakers(sq.get("text", []), sq.get("portraits", []))
	var sfx: Node = SfxScript.new()
	sfx._load_voices(data)
	sfx.cg_voice("c5_fengyi", keys)
	check(sfx._cg_wait.values().has("lvbu") or keys.find("lvbu") == 0, "吕布 too: %s" % str(sfx._cg_wait))
	check(keys.find("diaochan") > 0 and sfx._cg_wait.get(keys.find("diaochan"), "") == "diaochan", "貂蝉 waits for her first line: %s" % str(sfx._cg_wait))
	sfx.cg_line("c5_fengyi", keys.find("diaochan"))
	check(not sfx._cg_wait.values().has("diaochan"), "said once her line is up")
	sfx.free()
