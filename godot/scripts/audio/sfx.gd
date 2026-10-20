extends Node
## Autoload "Sfx": sound effects. data/audio.json maps an event name ("hit", "act_cavalry", "step" …) to one or more
## files (one is picked at random), a volume offset and a pitch range — swap or retune sounds there, not here.
## Volume is the player option Game.options["sfx_volume"] (0–1; 0 = muted).

const VOICES := 10  # sounds that may overlap (a 3-hit combo plus the enemy's answer)
const MOMENTS := ["attack", "ultimate", "heal", "roar", "intro"]
const INTRO_GAP_MS := 20000  # an entrance line (CG, then the fight right after it) isn't said twice in a row

var _entries: Dictionary = {}
var voice_defaults: Dictionary = {}  # audio.json voice_defaults: role (lord / strategist / female / male / enemy_*) → profile
var female_names: Array = []
var _voice_vol: Dictionary = {}  # profile → volume_db
var _voice_streams: Dictionary = {}  # "profile/moment" → Array[AudioStream]
var _cg_voice: Dictionary = {}  # CG key → profile whose intro plays when that picture comes up (the profile's `cgs`)
var _intro_at: Dictionary = {}  # profile → Time.get_ticks_msec() of its last intro
var _streams: Dictionary = {}  # event → Array[AudioStream], loaded once up front (no first-play lag on phones)
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var f := FileAccess.open("res://data/audio.json", FileAccess.READ)
	if f == null:
		return
	var data: Variant = JSON.parse_string(f.get_as_text())
	if not data is Dictionary:
		return
	_entries = data.get("sfx", {})
	_load_voices(data)
	for key in _entries:
		var list: Array = []
		for path in _entries[key].get("files", []):
			var p := "res://data/audio/%s" % path
			if ResourceLoader.exists(p):
				list.append(load(p))
		_streams[key] = list
	for i in VOICES:
		var pl := AudioStreamPlayer.new()
		add_child(pl)
		_players.append(pl)


static func voice_file(profile: String, moment: String, line: Variant, tts: Array) -> String:
	## res:// path of one voice line — the same name tools/gen_voices.py writes (hash of voice|rate|pitch|text;
	## a line made from a recording, {"src": "x.wav"}, is x.ogg)
	if line is Dictionary and line.has("src"):
		return "res://data/audio/voice/%s.ogg" % str(line["src"]).get_basename()
	var text: String = line if line is String else str(line["text"])
	var t: Array = tts if line is String else line.get("tts", tts)
	var h := "|".join(PackedStringArray([str(t[0]), str(t[1]), str(t[2]), text])).md5_text().left(10)
	return "res://data/audio/voice/%s_%s_%s.ogg" % [profile, moment, h]


func _load_voices(data: Dictionary) -> void:
	voice_defaults = data.get("voice_defaults", {})
	female_names = data.get("female_names", [])
	var profiles: Dictionary = data.get("voices", {})
	for prof in profiles:
		var p: Dictionary = profiles[prof]
		_voice_vol[prof] = float(p.get("volume_db", 0.0))
		for key in p.get("cgs", []):
			_cg_voice[key] = prof
		for moment in MOMENTS:
			var list: Array = []
			for line in p.get(moment, []):
				var path := voice_file(prof, moment, line, p.get("tts", []))
				if ResourceLoader.exists(path):
					list.append(load(path))
			if not list.is_empty():
				_voice_streams["%s/%s" % [prof, moment]] = list


func _volume() -> float:
	## the player's sfx volume; looked up at runtime (not the `Game` identifier) so tests can load this script on its own
	var game := get_node_or_null("/root/Game")
	return float(game.options.get("sfx_volume", 0.8)) if game else 0.8


func has_voice(profile: String, moment: String) -> bool:
	return _voice_streams.has("%s/%s" % [profile, moment])


func voice(profiles: Array, moments: Array) -> float:
	## Say one line: the first moment (in order) that any profile (in order) has — e.g. [own, default] × [heal, attack].
	## Returns how long it runs (0 = nothing said).
	var vol := _volume()
	if vol <= 0.0 or _players.is_empty():
		return 0.0
	for m in moments:
		for prof in profiles:
			var list: Array = _voice_streams.get("%s/%s" % [prof, m], [])
			if list.is_empty():
				continue
			if m == "intro":
				var now := Time.get_ticks_msec()
				if _intro_at.has(prof) and now - int(_intro_at[prof]) < INTRO_GAP_MS:
					return 0.0
				_intro_at[prof] = now
			var pl := _players[_next]
			_next = (_next + 1) % _players.size()
			pl.stream = list[randi() % list.size()]
			pl.pitch_scale = randf_range(0.98, 1.02)
			pl.volume_db = linear_to_db(vol) + float(_voice_vol.get(prof, 0.0))
			pl.play()
			return pl.stream.get_length()
	return 0.0


func cg_voice(cg_key: String) -> void:
	## a story CG just came up: whoever it introduces (audio.json voices.<profile>.cgs) says their entrance line
	if _cg_voice.has(cg_key):
		voice([_cg_voice[cg_key]], ["intro"])


func has(key: String) -> bool:
	return not _streams.get(key, []).is_empty()


func play(key: String, pitch := 1.0) -> void:
	var list: Array = _streams.get(key, [])
	if list.is_empty() or _players.is_empty():
		return
	var vol := _volume()
	if vol <= 0.0:
		return
	var e: Dictionary = _entries[key]
	var pl := _players[_next]
	_next = (_next + 1) % _players.size()
	pl.stream = list[randi() % list.size()]
	var pr: Array = e.get("pitch", [1.0, 1.0])
	pl.pitch_scale = pitch * randf_range(float(pr[0]), float(pr[1]))
	pl.volume_db = linear_to_db(vol) + float(e.get("volume_db", 0.0))
	pl.play()
