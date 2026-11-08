class_name MapLines
extends Control
## Rance X style roads: gently curved paths (walked = solid gold, ahead = marching ivory dashes, routes not taken = faint),
## a pulsing halo under every square you can step onto, a turning ring under the current square.
## Nothing here runs per frame in script: the roads are drawn once per rebuild(), the marching dashes are Line2Ds whose
## dash texture a tiny shader scrolls, and the halos / ring are small nodes a Kit.loop tween scales or turns (in 省电模式
## those rest after one pass). It used to redraw every road of the chapter every frame from GDScript.

var segs: Array = []  # [from, to, kind] kind: "walked" / "ahead" / "closed" / "ghost"
var halos: Array = []  # reachable square centres
var here := Vector2(-999, -999)
var _anim: Node2D  # the moving bits, rebuilt with the roads

const MARCH_SHADER := """
shader_type canvas_item;
uniform float speed = 0.9;  // dash periods per second, towards the next squares
void fragment() {
	COLOR = texture(TEXTURE, vec2(UV.x - TIME * speed, UV.y)) * COLOR;
}
"""
static var _march_mat: ShaderMaterial
static var _dash_tex: ImageTexture


static func _curve(a: Vector2, b: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var dy := b.y - a.y
	for i in 17:
		var k := i / 16.0
		var e := k * k * (3.0 - 2.0 * k)  # smoothstep: lanes bend like a road, not a zigzag
		pts.append(Vector2(lerpf(a.x, b.x, k), a.y + dy * e))
	return pts


func rebuild() -> void:
	## the map changed (a step, a choice, a new chapter): draw the roads again and set up what moves
	queue_redraw()
	if _anim != null:
		_anim.queue_free()
	_anim = Node2D.new()
	add_child(_anim)
	for s in segs:
		if s[2] == "ahead":
			_anim.add_child(_marching(_curve(s[0], s[1])))
	for c in halos:
		_anim.add_child(_pulse(c))
	if here.x > -900:
		_anim.add_child(_ring(here))


func _marching(pts: PackedVector2Array) -> Line2D:
	## ivory dashes marching along the road: one dash texture (12 px on, 8 off) tiled along the line, scrolled by the GPU
	if _march_mat == null:
		_march_mat = ShaderMaterial.new()
		var sh := Shader.new()
		sh.code = MARCH_SHADER
		_march_mat.shader = sh
		var img := Image.create(20, 4, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		img.fill_rect(Rect2i(0, 0, 12, 4), Color(0.98, 0.95, 0.86, 0.95))
		_dash_tex = ImageTexture.create_from_image(img)
	var l := Line2D.new()
	l.points = pts
	l.width = 3.5
	l.texture = _dash_tex
	l.texture_mode = Line2D.LINE_TEXTURE_TILE
	l.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	l.antialiased = true
	l.material = _march_mat
	return l


func _pulse(c: Vector2) -> Node2D:
	## the halo under a square you can step onto, breathing
	var n := _Halo.new()
	n.position = c
	var tw := Kit.loop(n)
	tw.tween_property(n, "scale", Vector2.ONE * 1.14, 0.55).set_trans(Tween.TRANS_SINE)
	tw.tween_property(n, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_SINE)
	return n


func _ring(c: Vector2) -> Node2D:
	## the ring under the current square, slowly turning
	var n := _Ring.new()
	n.position = c
	var tw := Kit.loop(n)
	tw.tween_property(n, "rotation", TAU, 4.2).from(0.0)
	return n


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
			_:  # ahead: the dark bed here; the marching dashes on top are a Line2D (_marching)
				draw_polyline(pts, Color(0.1, 0.07, 0.05, 0.5), 8.0, true)


func _dashed(pts: PackedVector2Array, col: Color, w: float, dash := 10.0, gap := 8.0) -> void:
	var on := true
	var left := dash
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


class _Halo extends Node2D:
	func _draw() -> void:
		draw_circle(Vector2.ZERO, 49.0, Color(1.0, 0.85, 0.4, 0.15))
		draw_arc(Vector2.ZERO, 45.0, 0, TAU, 48, Color(1.0, 0.88, 0.5, 0.4), 3.0, true)


class _Ring extends Node2D:
	func _draw() -> void:
		draw_circle(Vector2.ZERO, 44.0, Color(0.9, 0.2, 0.15, 0.18))
		draw_arc(Vector2.ZERO, 44.0, 0.0, TAU * 0.8, 40, Color(1.0, 0.8, 0.4, 0.9), 3.0, true)
