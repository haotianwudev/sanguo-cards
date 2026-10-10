extends Node
## Autoload "Bgm": Background music player with smooth crossfade and volume control.
## Volume is tied to Game.options["bgm_volume"] (0.0–1.0; 0 = muted).

var _player: AudioStreamPlayer
var _current_track: String = ""
var _tween: Tween

const TRACKS := {
	"battle": "res://data/audio/bgm/battle.ogg",
	"map": "res://data/audio/bgm/map.ogg",
	"title": "res://data/audio/bgm/title.ogg",
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	add_child(_player)


func play(track_name: String) -> void:
	if not TRACKS.has(track_name):
		return
	if _current_track == track_name and _player.playing:
		return
	_current_track = track_name
	var path: String = TRACKS[track_name]
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		stream.loop = true

	var target_vol := _get_target_db()
	if _player.playing:
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(_player, "volume_db", -60.0, 0.4)
		_tween.tween_callback(func():
			_player.stream = stream
			_player.play()
			_tween = create_tween()
			_tween.tween_property(_player, "volume_db", target_vol, 0.5)
		)
	else:
		_player.stream = stream
		_player.volume_db = -60.0
		_player.play()
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(_player, "volume_db", target_vol, 0.5)


func stop(fade_duration: float = 0.5) -> void:
	if not _player.playing:
		return
	_current_track = ""
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", -60.0, fade_duration)
	_tween.tween_callback(func(): _player.stop())


func update_volume() -> void:
	if not _player.playing:
		return
	_player.volume_db = _get_target_db()


func _get_target_db() -> float:
	var vol := 0.7
	var game = get_node_or_null("/root/Game")
	if game != null and "options" in game:
		vol = float(game.options.get("bgm_volume", 0.7))
	if vol <= 0.0:
		return -80.0
	# -6 dB so BGM stays comfortably behind sound effects and vocal shouts
	return linear_to_db(vol) - 6.0
