extends Node
## Keeps the phone cool (autoload `Power`). A card game sits still most of the time, but Godot renders every frame at
## the screen's refresh rate (90 / 120 Hz phones) unless told otherwise. Settings: ui.json "power".
##   awake  — fps_active while there is input or something animates (poke() from battle events, map walks …)
##   idle   — fps_idle once nothing has happened for idle_after seconds
##   省电模式 (Game.options.power_saver) — fps_saver always, low-processor rendering (nothing redrawn while nothing
##            changes) and decorative loops play once instead of forever (Kit.loop)
## Headless (tests) it does nothing.

var saver := false
var _cfg: Dictionary = {}
var _idle_for := 0.0
var _awake := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		set_process(false)
		set_process_input(false)
		return
	_cfg = GameData.get_db().ui.get("power", {})
	apply(bool(Game.options.get("power_saver", false)))


func apply(on: bool) -> void:
	## switch 省电模式 (the settings toggle calls this through Game.set_option)
	saver = on
	OS.low_processor_usage_mode = on
	_set_awake(true)


func poke() -> void:
	## something is moving that the player is watching without touching anything (auto battle, a walk): stay smooth
	_idle_for = 0.0
	if not _awake:
		_set_awake(true)


func _input(_e: InputEvent) -> void:
	poke()


func _process(delta: float) -> void:
	if not _awake:
		return
	_idle_for += delta
	if _idle_for >= float(_cfg.get("idle_after", 3.0)):
		_set_awake(false)


func _set_awake(on: bool) -> void:
	_awake = on
	_idle_for = 0.0
	var key := "fps_saver" if saver else ("fps_active" if on else "fps_idle")
	Engine.max_fps = int(_cfg.get(key, 60 if on else 30))
