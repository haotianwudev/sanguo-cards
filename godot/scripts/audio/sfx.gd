extends Node
## Autoload "Sfx": sound effects. data/audio.json maps an event name ("hit", "act_cavalry", "step" …) to one or more
## files (one is picked at random), a volume offset and a pitch range — swap or retune sounds there, not here.
## Volume is the player option Game.options["sfx_volume"] (0–1; 0 = muted).

const VOICES := 10  # sounds that may overlap (a 3-hit combo plus the enemy's answer)

var _entries: Dictionary = {}
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


func has(key: String) -> bool:
	return not _streams.get(key, []).is_empty()


func play(key: String, pitch := 1.0) -> void:
	var list: Array = _streams.get(key, [])
	if list.is_empty() or _players.is_empty():
		return
	var vol := float(Game.options.get("sfx_volume", 0.8))
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
