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
var troop_voices: Dictionary = {}  # audio.json troop_voices: troop → profile (e.g. 枪兵「看枪！」), for men only
var _voice_vol: Dictionary = {}  # profile → volume_db
var _voice_streams: Dictionary = {}  # "profile/moment" → Array[AudioStream]
var _cg_voice: Dictionary = {}  # CG key → profiles whose intro that picture plays (each profile's `cgs`)
var _people: Dictionary = {}  # profile → story speaker keys that are him (the cards and persons carrying that voice)
var _cg_wait: Dictionary = {}  # the CG on screen: line index → profile, said when that line (his first) comes up
var _cg_on := ""
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


static func voice_file(profile: String, moment: String, line: Variant, p: Dictionary) -> String:
	## res:// path of one voice line — the same name tools/gen_voices.py writes: a hash of voice|rate|pitch|text (edge-tts)
	## indextts|ref|emo|text (IndexTTS 2) or minimax|voice|emotion|speed|pitch|text (`p.engine`), with |tempoNN before the text
	## when the profile sets `tempo`; a recording, {"src": "x.wav"}, is x.ogg
	var d: Dictionary = line if line is Dictionary else {}
	if d.has("src"):
		return "res://data/audio/voice/%s.ogg" % str(d["src"]).get_basename()
	var text: String = line if line is String else str(d["text"])
	var parts := PackedStringArray()
	if str(p.get("engine", "edge")) == "minimax":
		parts = PackedStringArray(["minimax", str(p["voice"]), str(d.get("emotion", p.get("emotion", "auto"))),
			str(int(p.get("speed", 100))), str(int(p.get("pitch", 0)))])
	elif str(p.get("engine", "edge")) == "indextts":
		var emo := PackedStringArray()
		for x in d.get("emo", p.get("emo", [0, 0, 0, 0, 0, 0, 0, 0])):
			emo.append(str(int(x)))
		parts = PackedStringArray(["indextts", str(p["ref"]), ",".join(emo)])
	else:
		var t: Array = d.get("tts", p.get("tts", []))
		parts = PackedStringArray([str(t[0]), str(t[1]), str(t[2])])
	if int(p.get("tempo", 100)) != 100:  # stretched afterwards (82 = 0.82×), part of what made it
		parts.append("tempo%d" % int(p["tempo"]))
	parts.append(text)
	return "res://data/audio/voice/%s_%s_%s.ogg" % [profile, moment, "|".join(parts).md5_text().left(10)]


func _load_voices(data: Dictionary) -> void:
	voice_defaults = data.get("voice_defaults", {})
	female_names = data.get("female_names", [])
	troop_voices = data.get("troop_voices", {})
	var profiles: Dictionary = data.get("voices", {})
	for prof in profiles:
		var p: Dictionary = profiles[prof]
		_voice_vol[prof] = float(p.get("volume_db", 0.0))
		for key in p.get("cgs", []):
			if not _cg_voice.has(key):
				_cg_voice[key] = []
			_cg_voice[key].append(prof)
		for moment in MOMENTS:
			var list: Array = []
			for line in p.get(moment, []):
				var path := voice_file(prof, moment, line, p)
				if ResourceLoader.exists(path):
					list.append(load(path))
			if not list.is_empty():
				_voice_streams["%s/%s" % [prof, moment]] = list


func _volume() -> float:
	## the player's sfx volume; looked up at runtime (not the `Game` identifier) so tests can load this script on its own
	var game := get_node_or_null("/root/Game") if is_inside_tree() else null
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


func cg_voice(cg_key: String, speakers: Array = []) -> void:
	## a story CG just came up (`speakers`: Kit.speakers of its lines, [] when they show all at once). Whoever it
	## introduces (audio.json voices.<profile>.cgs) says their entrance line on their own first line of it — now, if
	## that is the first line or they never speak there.
	_cg_on = cg_key
	_cg_wait = {}
	for prof in _cg_voice.get(cg_key, []):
		var at := -1
		for i in speakers.size():
			if str(speakers[i]) in _speakers_of(prof):
				at = i
				break
		if at <= 0:
			voice([prof], ["intro"])
		else:
			_cg_wait[at] = prof


func cg_line(cg_key: String, i: int) -> void:
	## line `i` of the CG's scene is on screen: the entrance line of whoever speaks first there
	if cg_key == _cg_on and _cg_wait.has(i):
		voice([_cg_wait[i]], ["intro"])
		_cg_wait.erase(i)


func _speakers_of(prof: String) -> Array:
	if _people.is_empty():
		var cards: Dictionary = GameData.get_db().cards
		for cid in cards:
			var v := str(cards[cid].get("voice", ""))
			if v != "":
				if not _people.has(v):
					_people[v] = []
				_people[v].append_array([cid, str(cards[cid].get("person", cid))])
	return _people.get(prof, [])


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
