class_name KineticScroll
extends Node
## Drag-to-scroll with momentum for a ScrollContainer (卡牌收藏, 结局图鉴): drag with a finger or the mouse, let go to
## coast, swipe sideways to turn a page. It only runs per frame while coasting (it used to tick every frame for as long
## as the screen was open).
##     _kin = KineticScroll.attach(scroll)   …   _kin.page(1)

const FRICTION := 8.0
const STOP_BELOW := 15.0  # px / s
const PAGE_SWIPE := 120.0  # px sideways, and clearly more sideways than down, to turn a page

var scroll: ScrollContainer
var _down := false
var _start := Vector2.ZERO
var _last_time := 0
var _velocity := 0.0


static func attach(sc: ScrollContainer) -> KineticScroll:
	var k := KineticScroll.new()
	k.scroll = sc
	sc.add_child(k)
	sc.gui_input.connect(k._on_input)
	k.set_process(false)
	return k


func top() -> void:
	## back to the top, stopped (a new tab / filter)
	_velocity = 0.0
	set_process(false)
	scroll.scroll_vertical = 0


func page(dir: int) -> void:
	## one screenful up (-1) or down (1)
	var vbar := scroll.get_v_scroll_bar()
	var max_val: int = int(vbar.max_value - scroll.size.y) if vbar != null else 10000
	var target := clampi(scroll.scroll_vertical + dir * int(scroll.size.y * 0.85), 0, maxi(0, max_val))
	create_tween().tween_property(scroll, "scroll_vertical", target, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if absf(_velocity) < STOP_BELOW:
		_velocity = 0.0
		set_process(false)
		return
	scroll.scroll_vertical += int(_velocity * delta)
	_velocity = lerpf(_velocity, 0.0, FRICTION * delta)


func _on_input(e: InputEvent) -> void:
	var press: bool = e is InputEventScreenTouch or (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT)
	var drag: bool = e is InputEventScreenDrag or (e is InputEventMouseMotion and _down)
	if press and e.pressed:
		_down = true
		_velocity = 0.0
		set_process(false)
		_start = e.position
		_last_time = Time.get_ticks_msec()
	elif press:
		_down = false
		var d: Vector2 = e.position - _start
		if absf(d.x) > PAGE_SWIPE and absf(d.x) > absf(d.y) * 1.5:
			page(1 if d.x < 0 else -1)
		else:
			set_process(true)  # coast
	elif drag:
		_down = true
		scroll.scroll_vertical -= int(e.relative.y)
		var now := Time.get_ticks_msec()
		_velocity = -e.relative.y / maxf(0.001, float(now - _last_time) / 1000.0)
		_last_time = now
