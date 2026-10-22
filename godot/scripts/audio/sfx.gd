extends Node
## Autoload "Sfx": sound effects. data/audio.json maps an event name ("hit", "act_cavalry", "step" …) to one or more
## files (one is picked at random), a volume offset and a pitch range — swap or retune sounds there, not here.
## Volume is the player option Game.options["sfx_volume"] (0–1; 0 = muted).

const VOICES := 10  # sounds that may overlap (a 3-hit combo plus the enemy's answer)
const MOMENTS := ["attack", "ultimate", "heal", "roar", "intro", "guard"]  # guard: 防御 / a defence-only skill

var _entries: Dictionary = {}
var voice_defaults: Dictionary = {}  # audio.json voice_defaults: role (lord / strategist / female / male / enemy_*) → profile
var female_names: Array = []
var troop_voices: Dictionary = {}  # audio.json troop_voices: troop → profile (e.g. 枪兵「看枪！」), for men only
var _voice_vol: Dictionary = {}  # profile → volume_db
var _voice_streams: Dictionary = {}  # "profile/moment" → Array[AudioStream]
var _intro_text: Dictionary = {}  # profile → the words of his entrance line, without punctuation (to find it in a scene)
var _speaker_voice: Dictionary = {}  # story speaker key (card id / person) → his own voice profile (the card's `voice`)
var _cg_wait: Dictionary = {}  # the CG on screen: line index → profile, said when that line (his first) comes up
var _cg_on := ""
var _cg_said: Dictionary = {}  # profiles whose CG entrance line was said this game: once is enough
var _card_pl: AudioStreamPlayer  # the line a tapped card is saying (cut off by the next tap)
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
		for moment in MOMENTS:
			var list: Array = []
			for line in p.get(moment, []):
				var path := voice_file(prof, moment, line, p)
				if ResourceLoader.exists(path):
					list.append(load(path))
			if not list.is_empty():
				_voice_streams["%s/%s" % [prof, moment]] = list
				if moment == "intro":
					var l: Variant = p["intro"][0]
					_intro_text[prof] = _bare(l if l is String else str(l["text"]))


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
				if not force and _intro_at.has(prof) and now - int(_intro_at[prof]) < INTRO_GAP_MS:
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


func card_voice(card: Dictionary) -> void:
	## a card tapped in 整备 says his line: his own entrance line, else what he shouts in battle — the same voice
	## the battle screen gives him (his own → his troop's, men only → the default for his role)
	var troop := str(card.get("troop", ""))
	var role := "lord" if troop == "lord" or str(card.get("id", "")) == "lord" else "female" if is_female(card) 		else "strategist" if troop == "strategist" else "male"
	var moments: Array = ["intro", "ultimate", "attack"]
	for sid in card.get("skills", []):
		for eff in GameData.get_db().skills.get(sid, {}).get("effects", []):
			if eff.get("type", "") == "heal":
				moments = ["intro", "heal", "ultimate", "attack"]
	if _card_pl != null:
		_card_pl.stop()
	var troop_voice := str(troop_voices.get(troop, "")) if role == "male" else ""
	if voice([str(card.get("voice", "")), troop_voice, str(voice_defaults.get(role, role))], moments) > 0.0:
		_card_pl = _players[(_next + _players.size() - 1) % _players.size()]


func is_female(card: Dictionary) -> bool:
	var cname: String = card.get("name", "")
	for f in female_names:
		if cname.contains(f):
			return true
	return false


func cg_voice(cg_key: String, lines: Array, speakers: Array, stepped := true) -> void:
	## a story CG just came up (`lines` and their `speakers`, from Kit.speakers). Everyone in it with a voice of his own
	## says his entrance line on the line where he says those very words, else on his own first line — now if that is
	## the first line, or if the lines show all at once (`stepped` false).
	_cg_on = cg_key
	_cg_wait = {}
	var at := {}  # profile → line index
	for i in speakers.size():
		var prof := speaker_voice(str(speakers[i]))
		if prof == "":
			continue
		if not at.has(prof):
			at[prof] = i
		elif i < lines.size() and _bare(str(lines[i])).contains(_intro_text.get(prof, "?")) 				and not _bare(str(lines[at[prof]])).contains(_intro_text.get(prof, "?")):
			at[prof] = i
	for prof in at:
		if at[prof] == 0 or not stepped:
			_cg_say(prof)
		else:
			_cg_wait[at[prof]] = prof


static func _bare(t: String) -> String:
	for c in "，。！？、…—「」：；　 ":
		t = t.replace(c, "")
	return t


func _cg_say(prof: String) -> void:
	## a CG's entrance line, once per game
	if not _cg_said.has(prof) and voice([prof], ["intro"]) > 0.0:
		_cg_said[prof] = true


func cg_line(cg_key: String, i: int) -> void:
	## line `i` of the CG's scene is on screen: the entrance line of whoever speaks first there
	if cg_key != "" and cg_key == _cg_on and _cg_wait.has(i):
		_cg_say(_cg_wait[i])
		_cg_wait.erase(i)


func speaker_voice(key: String) -> String:
	## the voice profile with an entrance line that a story speaker has of his own ("" = none)
	if _speaker_voice.is_empty():
		var cards: Dictionary = GameData.get_db().cards
		for cid in cards:
			var v := str(cards[cid].get("voice", ""))
			if v != "" and _voice_streams.has("%s/intro" % v):
				_speaker_voice[cid] = v
				_speaker_voice[str(cards[cid].get("person", cid))] = v
				_speaker_voice[str(cid).trim_suffix("_card")] = v  # huaxiong_card speaks in the story as huaxiong
	return str(_speaker_voice.get(key, ""))


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
