class_name MapLines
extends Control
## Rance X style roads: gently curved paths (walked = solid gold, ahead = dashed ivory, routes not taken = faint),
## a pulsing halo under every square you can step onto, a soft ring under the current square
var segs: Array = []  # [from, to, kind] kind: "walked" / "ahead" / "closed" / "ghost"
var halos: Array = []  # reachable square centres
var here := Vector2(-999, -999)
var t := 0.0

func _process(delta: float) -> void:
	if not is_visible_in_tree():  # CG mode hides the map: don't redraw roads nobody sees
		return
	t += delta
	if not halos.is_empty() or here.x > -900:
		queue_redraw()

static func _curve(a: Vector2, b: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var dy := b.y - a.y
	for i in 17:
		var k := i / 16.0
		var e := k * k * (3.0 - 2.0 * k)  # smoothstep: lanes bend like a road, not a zigzag
		pts.append(Vector2(lerpf(a.x, b.x, k), a.y + dy * e))
	return pts

func _dashed(pts: PackedVector2Array, col: Color, w: float, dash := 10.0, gap := 8.0, phase := 0.0) -> void:
	var on := true
	var left := dash - fmod(phase, dash + gap)
	if left < 0.0:
		on = false
		left += gap
	for i in pts.size() - 1:
		var a := pts[i]
		var b := pts[i + 1]
		var seg := a.distance_to(b)
		var pos := 0.0
		while pos < seg:
			var step := minf(left, seg - pos)
			if on:
				draw_line(a.lerp(b, pos / seg), a.lerp(b, (pos + step) / seg), col, w, true)
			pos += step
			left -= step
			if left <= 0.0:
				on = not on
				left = dash if on else gap

func _draw() -> void:
	for s in segs:
		var pts := _curve(s[0], s[1])
		match s[2]:
			"ghost":
				_dashed(pts, Color(0.96, 0.93, 0.85, 0.22), 2.0, 6.0, 8.0)
			"closed":
				draw_polyline(pts, Color(0.1, 0.07, 0.05, 0.35), 6.0, true)
				_dashed(pts, Color(0.85, 0.8, 0.7, 0.45), 2.0, 6.0, 7.0)
			"walked":
				draw_polyline(pts, Color(0.12, 0.08, 0.04, 0.6), 11.0, true)
				draw_polyline(pts, Color(0.88, 0.7, 0.35), 6.0, true)
				draw_polyline(pts, Color(1.0, 0.92, 0.7, 0.8), 2.0, true)
			_:  # ahead: marching dashes towards the next squares
				draw_polyline(pts, Color(0.1, 0.07, 0.05, 0.5), 8.0, true)
				_dashed(pts, Color(0.98, 0.95, 0.86, 0.95), 3.5, 12.0, 8.0, -t * 18.0)
	var p := 0.5 + 0.5 * sin(t * 3.2)
	for c in halos:
		draw_circle(c, 46.0 + 6.0 * p, Color(1.0, 0.85, 0.4, 0.10 + 0.10 * p))
		draw_arc(c, 42.0 + 6.0 * p, 0, TAU, 48, Color(1.0, 0.88, 0.5, 0.55 - 0.3 * p), 3.0, true)
	if here.x > -900:
		draw_circle(here, 44.0, Color(0.9, 0.2, 0.15, 0.18))
		draw_arc(here, 44.0, t * 1.5, t * 1.5 + TAU * 0.8, 40, Color(1.0, 0.8, 0.4, 0.9), 3.0, true)
