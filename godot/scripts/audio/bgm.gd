extends Node
## Autoload "Bgm": Background music player with scene pools, random track selection, smooth crossfade, and volume control.
## Volume is tied to Game.options["bgm_volume"] (0.0–1.0; 0 = muted).

signal track_changed(track_id: String)

var _player: AudioStreamPlayer
var _current_track: String = ""
var _current_scene: String = ""
var _tween: Tween
var _rng := RandomNumberGenerator.new()

const TRACKS := {
	"title": "res://data/audio/bgm/title.ogg",
	"map": "res://data/audio/bgm/map.ogg",
	"battle": "res://data/audio/bgm/battle.ogg",
	"wuxia": "res://data/audio/bgm/wuxia.ogg",
	"wuxia2": "res://data/audio/bgm/wuxia2.ogg",
	"wuxia3": "res://data/audio/bgm/wuxia3.ogg",
	"folk_chinese": "res://data/audio/bgm/folk_chinese.ogg",
	"kengeki": "res://data/audio/bgm/kengeki.ogg",
	"epic_battle_j": "res://data/audio/bgm/epic_battle_j.ogg",
	"amenoshita3": "res://data/audio/bgm/amenoshita3.ogg",
	"ametsuchi": "res://data/audio/bgm/ametsuchi.ogg",
	"battlefield5": "res://data/audio/bgm/battlefield5.ogg",
	"shenxian": "res://data/audio/bgm/shenxian.ogg",
	"numina": "res://data/audio/bgm/numina.ogg",
	"prairie5": "res://data/audio/bgm/prairie5.ogg",
	"taohua": "res://data/audio/bgm/taohua.ogg",
	"chinatown": "res://data/audio/bgm/chinatown.ogg",
	"sakuya4": "res://data/audio/bgm/sakuya4.ogg",
	"shenyang": "res://data/audio/bgm/shenyang.ogg",
	"asian_drums": "res://data/audio/bgm/asian_drums.ogg",
	"guzheng_city": "res://data/audio/bgm/guzheng_city.ogg",
	"heroic_age": "res://data/audio/bgm/heroic_age.ogg",
	"crusade": "res://data/audio/bgm/crusade.ogg",
	"five_armies": "res://data/audio/bgm/five_armies.ogg",
	"strength_of_titans": "res://data/audio/bgm/strength_of_titans.ogg",
	"achilles": "res://data/audio/bgm/achilles.ogg",
	"heavy_heart": "res://data/audio/bgm/heavy_heart.ogg",
	"the_pyre": "res://data/audio/bgm/the_pyre.ogg",
	"battlefield2": "res://data/audio/bgm/battlefield2.ogg",
	"battlefield3": "res://data/audio/bgm/battlefield3.ogg",
	"battlefield4": "res://data/audio/bgm/battlefield4.ogg",
	"dramatic2": "res://data/audio/bgm/dramatic2.ogg",
	"dramatic4": "res://data/audio/bgm/dramatic4.ogg",
	"shizima": "res://data/audio/bgm/shizima.ogg",
	"breeze2": "res://data/audio/bgm/breeze2.ogg",
	"harvest": "res://data/audio/bgm/harvest.ogg",
	"teller_of_the_tales": "res://data/audio/bgm/teller_of_the_tales.ogg",
	"eastern_thought": "res://data/audio/bgm/eastern_thought.ogg",
	"ishikari_lore": "res://data/audio/bgm/ishikari_lore.ogg",
}

const INFO := {
	"title": {"name": "韦诺序曲 · 群雄并起", "src": "原曲保留", "desc": "庄严号角与古典弦乐，拉开乱世序幕"},
	"map": {"name": "漫游者 · 四方征途", "src": "原曲保留", "desc": "舒缓辽阔的行军旋律，踏遍州郡山川"},
	"battle": {"name": "北境战歌 · 两军交锋", "src": "原曲保留", "desc": "紧凑厚重的管弦交响，短兵相接"},
	"wuxia": {"name": "Wuxia · 武侠激战", "src": "PeriTune CC-BY", "desc": "古筝引子后转快节奏竹笛二胡激战"},
	"wuxia2": {"name": "Wuxia2 · 疾风激战", "src": "PeriTune CC-BY", "desc": "BPM 135 战鼓推进，琵琶激奏与二胡轮番出击"},
	"wuxia3": {"name": "Wuxia3 · 宿命决战", "src": "PeriTune CC-BY", "desc": "厚重低频管弦铺底，弦乐层层爆发的首领死斗"},
	"folk_chinese": {"name": "Folk_Chinese · 市井茶肆", "src": "PeriTune CC-BY", "desc": "清脆竹笛与古筝小打，轻松诙谐的城池奇遇"},
	"kengeki": {"name": "Kengeki · 剑戟死斗", "src": "PeriTune CC-BY", "desc": "硬派东方交响摇滚，白刃相接、刀光剑影"},
	"epic_battle_j": {"name": "EpicBattle_J · 强敌阻截", "src": "PeriTune CC-BY", "desc": "东方太鼓与紧迫弦乐交响，强敌压境的宿命感"},
	"amenoshita3": {"name": "Amenoshita3 · 天之下", "src": "PeriTune CC-BY", "desc": "豪迈东方交响与战鼓号角，诸侯大军正面冲锋"},
	"ametsuchi": {"name": "Ametsuchi · 天地破阵", "src": "PeriTune CC-BY", "desc": "激昂东方管弦与琵琶疾奏，短促凌厉的破城战"},
	"battlefield5": {"name": "BattleField5 · 铁血战棋", "src": "PeriTune CC-BY", "desc": "现代战棋交响配极速鼓点，推图连击爽感拉满"},
	"shenxian": {"name": "Shenxian · 军师奇谋", "src": "PeriTune CC-BY", "desc": "空灵缓慢的竹笛与古筝弦乐，羽扇纶巾、闲步山川"},
	"numina": {"name": "Numina · 暗影夜袭", "src": "PeriTune CC-BY", "desc": "冷峻东方快节奏律动，夜袭敌营、短兵突击"},
	"prairie5": {"name": "Prairie5 · 疾风原野", "src": "PeriTune CC-BY", "desc": "急促马蹄疾奏与笛声冲锋，骑兵突击、平原激战"},
	"taohua": {"name": "Taohua · 桃花结义", "src": "PeriTune CC-BY", "desc": "温润舒缓的二胡与古筝，桃园结义、漫步江南"},
	"chinatown": {"name": "Chinatown · 热闹集市", "src": "PeriTune CC-BY", "desc": "欢快古筝与轻巧打击乐，招贤纳士、宝箱整备"},
	"sakuya4": {"name": "Sakuya4 · 朔夜挽歌", "src": "PeriTune CC-BY", "desc": "凄美动人的东方交响挽歌，英雄壮志未酬"},
	"shenyang": {"name": "Shenyang · 塞外风云", "src": "Kevin MacLeod CC-BY", "desc": "舒缓二胡、琵琶与扬琴，塞外漫步与山河行旅"},
	"asian_drums": {"name": "Asian Drums · 东方战鼓", "src": "Kevin MacLeod CC-BY", "desc": "纯东方大鼓与紧张混响打击乐，阵前伏击压迫感"},
	"guzheng_city": {"name": "Guzheng City · 古筝之城", "src": "Kevin MacLeod CC-BY", "desc": "从容古筝与轻柔手鼓，城池漫步与谋士策问"},
	"heroic_age": {"name": "Heroic Age · 英雄纪元", "src": "Kevin MacLeod CC-BY", "desc": "古典铜管号角与恢弘弦乐序曲，与原主页曲同风"},
	"crusade": {"name": "Crusade · 军团会战", "src": "Kevin MacLeod CC-BY", "desc": "厚重战鼓与史诗管弦推进，两军主力正面交锋"},
	"five_armies": {"name": "Five Armies · 五军交锋", "src": "Kevin MacLeod CC-BY", "desc": "厚重管弦交响与定音鼓推进，主力兵团正面对决"},
	"strength_of_titans": {"name": "Strength of the Titans · 霸王军威", "src": "Kevin MacLeod CC-BY", "desc": "雄浑铜管与磅礴战鼓，首领压境与凯旋加冕"},
	"achilles": {"name": "Achilles · 破阵突击", "src": "Kevin MacLeod CC-BY", "desc": "凌厉急促的古典管弦冲锋，骑兵突袭、撕裂敌阵"},
	"heavy_heart": {"name": "Heavy Heart · 乱世悲歌", "src": "Kevin MacLeod CC-BY", "desc": "二胡与大提琴交织的苍凉挽歌，战火苍生、英雄饮恨"},
	"the_pyre": {"name": "The Pyre · 将星陨落", "src": "Kevin MacLeod CC-BY", "desc": "庄严肃穆的古典弦乐挽歌，名将凋零、壮志未酬"},
	"battlefield2": {"name": "BattleField2 · 旌旗蔽日", "src": "PeriTune CC-BY", "desc": "正统战棋古典管弦战斗曲，两军对垒、旌旗猎猎"},
	"battlefield3": {"name": "BattleField3 · 铁骑合围", "src": "PeriTune CC-BY", "desc": "恢弘管弦与急促军鼓交响，大兵团合围决战"},
	"battlefield4": {"name": "BattleField4 · 沙场点兵", "src": "PeriTune CC-BY", "desc": "高亢铜管号角与激昂弦乐，全军出击、势如破竹"},
	"dramatic2": {"name": "Dramatic2 · 强敌压境", "src": "PeriTune CC-BY", "desc": "厚重管弦与宿命感拉满的交响乐章，首领死斗"},
	"dramatic4": {"name": "Dramatic4 · 决胜千里", "src": "PeriTune CC-BY", "desc": "壮阔管弦交响与史诗高潮，乱世争锋、一战定鼎"},
	"shizima": {"name": "Shizima · 静寂山河", "src": "PeriTune CC-BY", "desc": "空灵缓慢的古筝与竹笛慢板，山水行旅、宁静致远"},
	"breeze2": {"name": "Breeze2 · 清风徐来", "src": "PeriTune CC-BY", "desc": "轻柔舒缓的木管与原声拨弦，微风拂面、漫步州郡"},
	"harvest": {"name": "Harvest · 沃野炊烟", "src": "PeriTune CC-BY", "desc": "温暖缓慢的田园原声慢曲，村落休整与大地图漫步"},
	"teller_of_the_tales": {"name": "Teller of the Tales · 行吟山水", "src": "Kevin MacLeod CC-BY", "desc": "古竖琴与木管舒缓慢板，与原大地图曲同风"},
	"eastern_thought": {"name": "Eastern Thought · 云水禅心", "src": "Kevin MacLeod CC-BY", "desc": "悠远长笛与东方拨弦慢曲，山林古道、心境澄明"},
	"ishikari_lore": {"name": "Ishikari Lore · 山林古道", "src": "Kevin MacLeod CC-BY", "desc": "幽静尺八竹笛与柔和弦乐铺底，苍茫群山行旅"},
}

const SCENE_NAMES := {
	"title": "主页标题",
	"map": "大地图行军",
	"battle": "常规战斗",
	"boss": "首领决战",
	"ambush": "阵前伏击",
	"leisure": "休整·奇遇·招贤",
	"strategy": "军师·抉择·整备",
	"victory": "凯旋·通关结局",
	"tragic": "悲歌·阵亡·败局",
}

const POOLS := {
	"title": ["title", "heroic_age", "dramatic4"],
	"map": [
		"map", "shenyang", "shenxian", "taohua", "shizima", "breeze2", "harvest",
		"teller_of_the_tales", "eastern_thought", "ishikari_lore",
	],
	"battle": [
		"battle", "wuxia", "wuxia2", "prairie5", "kengeki", "amenoshita3", "ametsuchi", "battlefield5",
		"five_armies", "crusade",
		"battlefield2", "battlefield3", "battlefield4",
	],
	"boss": ["wuxia3", "epic_battle_j", "five_armies", "crusade", "strength_of_titans", "dramatic2", "dramatic4", "battlefield3", "kengeki", "amenoshita3"],
	"ambush": ["asian_drums", "achilles", "prairie5", "kengeki", "numina", "wuxia2"],
	"leisure": ["folk_chinese", "chinatown", "taohua", "guzheng_city", "breeze2", "harvest"],
	"strategy": ["shenxian", "guzheng_city", "taohua", "shizima", "eastern_thought"],
	"victory": ["heroic_age", "strength_of_titans", "dramatic4", "battlefield4", "taohua"],
	"tragic": ["heavy_heart", "the_pyre", "sakuya4"],
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_player = AudioStreamPlayer.new()
	add_child(_player)


func play(scene_or_track: String, force_reroll: bool = false) -> void:
	## Play a random track from a scene pool (POOLS), or play a specific track id if not a pool.
	if POOLS.has(scene_or_track):
		if not force_reroll and _current_scene == scene_or_track and _player != null and _player.playing and _current_track != "":
			return
		_current_scene = scene_or_track
		var pool: Array = POOLS[scene_or_track]
		var choices: Array = pool.filter(func(t): return t != _current_track) if pool.size() > 1 else pool
		if choices.is_empty():
			choices = pool
		var picked: String = str(choices[_rng.randi_range(0, choices.size() - 1)])
		_start_track(picked)
	elif TRACKS.has(scene_or_track):
		_current_scene = ""
		play_track(scene_or_track)


func play_track(track_id: String, scene_id: String = "") -> void:
	## Play one specific track by id (used by the test tool and track switcher).
	if not TRACKS.has(track_id):
		return
	if scene_id != "":
		_current_scene = scene_id
	if _current_track == track_id and _player != null and _player.playing:
		return
	_start_track(track_id)


func next_in_scene() -> void:
	## Switch to another random track in the current scene pool (or across all tracks if no scene pool is active).
	if _current_scene != "" and POOLS.has(_current_scene):
		play(_current_scene, true)
		return
	var all_keys: Array = TRACKS.keys().filter(func(t): return t != _current_track)
	if not all_keys.is_empty():
		var picked: String = str(all_keys[_rng.randi_range(0, all_keys.size() - 1)])
		play_track(picked)


func _start_track(track_id: String) -> void:
	if _player == null:
		return
	var path: String = str(TRACKS.get(track_id, ""))
	if path == "" or not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	_current_track = track_id
	track_changed.emit(_current_track)

	var target_vol := _get_target_db()
	if _player.playing:
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(_player, "volume_db", -60.0, 0.35)
		_tween.tween_callback(func():
			_player.stream = stream
			_player.play()
			_tween = create_tween()
			_tween.tween_property(_player, "volume_db", target_vol, 0.45)
		)
	else:
		_player.stream = stream
		_player.volume_db = -60.0
		_player.play()
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(_player, "volume_db", target_vol, 0.45)


func stop(fade_duration: float = 0.5) -> void:
	_current_track = ""
	_current_scene = ""
	track_changed.emit("")
	if _player == null or not _player.playing:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", -60.0, fade_duration)
	_tween.tween_callback(func(): _player.stop())


func update_volume() -> void:
	if _player == null or not _player.playing:
		return
	_player.volume_db = _get_target_db()


func current_track_id() -> String:
	return _current_track


func current_scene_id() -> String:
	return _current_scene


func track_title(track_id: String = "") -> String:
	var tid: String = track_id if track_id != "" else _current_track
	if tid == "":
		return "未播放"
	var info: Dictionary = INFO.get(tid, {})
	return str(info.get("name", tid))


func current_display_text() -> String:
	if _current_track == "":
		return "未播放"
	var info: Dictionary = INFO.get(_current_track, {})
	var nm: String = str(info.get("name", _current_track))
	var src: String = str(info.get("src", ""))
	var sc: String = str(SCENE_NAMES.get(_current_scene, ""))
	var suffix := "（%s）" % src if src != "" else ""
	if sc != "":
		return "%s%s · %s" % [nm, suffix, sc]
	return "%s%s" % [nm, suffix]


func scenes_of(track_id: String) -> Array:
	var out: Array = []
	for sc in POOLS:
		var pool: Array = POOLS[sc]
		if pool.has(track_id):
			out.append(SCENE_NAMES.get(sc, sc))
	return out


func _get_target_db() -> float:
	var vol := 0.7
	var game = get_node_or_null("/root/Game")
	if game != null and "options" in game:
		vol = float(game.options.get("bgm_volume", 0.7))
	if vol <= 0.0:
		return -80.0
	# -6 dB so BGM stays comfortably behind sound effects and vocal shouts
	return linear_to_db(vol) - 6.0
