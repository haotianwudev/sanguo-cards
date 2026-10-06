class_name BattleFx
extends RefCounted
## 战斗特效：打击（斩击 / 法术 / 穿甲 / 反击 / 敌人的爪击）和异常状态（混乱 / 灼烧 / 破防 / 眩晕 / 夺气 / 战意 / 解除）。
## 全部是程序画的（Polygon2D / Line2D / Panel / CPUParticles2D），不需要美术资源；每个函数在 parent 的局部坐标 `at` 处生成节点，
## 一次性的自己消失，持续的（orbit / embers / cracks / glow）返回节点，由调用者在状态结束时 queue_free。

static var scale := 1.0  # shrinks / grows every effect (the enemy portrait is small, a cg is big); the screen sets it around each call
const GOLD := Color(1.0, 0.82, 0.35)
const EMBER := Color(1.0, 0.45, 0.12, 0.95)
const VIOLET := Color(0.72, 0.5, 1.0)
const STEEL := Color(0.82, 0.92, 1.0)
const GREEN := Color(0.45, 1.0, 0.62)
const BLOOD := Color(1.0, 0.25, 0.25)


static func _free_after(node: Node, secs: float) -> void:
	var tw := node.create_tween()
	tw.tween_interval(secs)
	tw.tween_callback(node.queue_free)


static func _star(r_out: float, r_in: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var r := r_out if i % 2 == 0 else r_in
		pts.append(Vector2.from_angle(-PI / 2 + TAU * i / 10.0) * r)
	return pts


# ---- 打击 -------------------------------------------------------------------------------------------------------

static func slash(parent: Control, at: Vector2, color: Color, angle_deg := -35.0, length := 240.0, width := 12.0, delay := 0.0) -> void:
	## a blade-shaped streak that snaps open and fades
	length *= scale
	width *= scale
	var s := Polygon2D.new()
	s.polygon = PackedVector2Array([Vector2(-length / 2, 0), Vector2(0, -width / 2), Vector2(length / 2, 0), Vector2(0, width / 2)])
	s.color = color
	s.position = at
	s.rotation_degrees = angle_deg
	s.scale = Vector2(0.1, 0.5)
	s.modulate.a = 0.0
	s.z_index = 45
	parent.add_child(s)
	var tw := s.create_tween()
	tw.tween_interval(delay)
	tw.tween_property(s, "modulate:a", 1.0, 0.01)
	tw.tween_property(s, "scale", Vector2.ONE, 0.07).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "modulate:a", 0.0, 0.17)
	tw.tween_callback(s.queue_free)


static func burst(parent: Control, at: Vector2, color: Color, rays := 10, r0 := 16.0, r1 := 110.0, width := 5.0, secs := 0.28) -> void:
	## spark rays flying outward
	r0 *= scale
	r1 *= scale
	var holder := Node2D.new()
	holder.position = at
	holder.z_index = 46
	parent.add_child(holder)
	for i in rays:
		var dir := Vector2.from_angle(TAU * i / rays + randf_range(-0.18, 0.18))
		var ln := Line2D.new()
		ln.width = width
		ln.default_color = color
		ln.points = PackedVector2Array([dir * r0, dir * (r0 + 18.0)])
		holder.add_child(ln)
		var tw := ln.create_tween().set_parallel(true)
		tw.tween_property(ln, "position", dir * (r1 - r0), secs).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(ln, "modulate:a", 0.0, secs)
	_free_after(holder, secs + 0.05)


static func ring(parent: Control, at: Vector2, color: Color, r0 := 12.0, r1 := 90.0, secs := 0.3, width := 5) -> void:
	## an expanding shockwave
	r0 *= scale
	r1 *= scale
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = color
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(int(r1))
	p.add_theme_stylebox_override("panel", sb)
	p.size = Vector2(r1, r1) * 2.0
	p.position = at - Vector2(r1, r1)
	p.pivot_offset = Vector2(r1, r1)
	p.scale = Vector2.ONE * (r0 / r1)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.z_index = 44
	parent.add_child(p)
	var tw := p.create_tween().set_parallel(true)
	tw.tween_property(p, "scale", Vector2.ONE, secs).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "modulate:a", 0.0, secs)
	_free_after(p, secs + 0.05)


static func hit(parent: Control, at: Vector2, kind: String, combo: int, dmg_ratio: float, pierce := false, boosted := false) -> void:
	## our blow landing on the enemy: 物理 = crossing slashes (the combo adds the cross), 法术 = violet burst + rune ring,
	## 穿甲 = one long thin lance streak; a big hit (share of the enemy's max HP) adds a shockwave
	var p := at + Vector2(randf_range(-34, 34), randf_range(-26, 26))
	if kind == "magic":
		burst(parent, p, VIOLET, 12, 14.0, 100.0, 4.0)
		ring(parent, p, Color(0.85, 0.75, 1.0), 10.0, 78.0, 0.32, 4)
		ring(parent, p, VIOLET, 6.0, 52.0, 0.22, 3)
	elif pierce:
		slash(parent, p, STEEL, randf_range(-10.0, 10.0), 360.0, 7.0)
		burst(parent, p, STEEL, 8, 10.0, 72.0, 3.0, 0.22)
	else:
		var ang := -35.0 if combo % 2 == 1 else 35.0
		slash(parent, p, Color(1.0, 0.93, 0.72), ang, 230.0, 13.0)
		if combo >= 3:
			slash(parent, p, Color(1.0, 0.7, 0.3), -ang, 210.0, 10.0, 0.05)
		burst(parent, p, Color(1.0, 0.82, 0.42), 8, 12.0, 82.0, 4.0)
	if boosted:  # a BOOSTed blow: wider, golden, with its own shockwave
		slash(parent, p, GOLD, -62.0, 300.0, 18.0, 0.02)
		burst(parent, p, GOLD, 14, 16.0, 130.0, 6.0, 0.34)
		ring(parent, p, Color(1.0, 0.9, 0.45), 10.0, 120.0, 0.3, 8)
	if dmg_ratio > 0.08:
		ring(parent, p, Color(1.0, 0.55, 0.3), 14.0, 150.0, 0.36, 7)


static func counter(parent: Control, at: Vector2) -> void:
	## 反击: a cold teal cut, thrown back
	slash(parent, at, Color(0.45, 0.95, 0.9), 20.0, 260.0, 12.0)
	slash(parent, at, Color(0.8, 1.0, 0.98), -15.0, 200.0, 7.0, 0.05)
	burst(parent, at, Color(0.5, 0.95, 0.9), 8, 12.0, 78.0, 4.0)


static func claw(parent: Control, at: Vector2, dmg_ratio: float, blocked: float) -> void:
	## the enemy's blow on us: three red claw marks; a guard (减伤) also raises a blue shield ring
	for i in 3:
		slash(parent, at + Vector2((i - 1) * 46.0, (i - 1) * -8.0), BLOOD, 62.0, 170.0, 9.0, i * 0.045)
	burst(parent, at, Color(1.0, 0.5, 0.35), 8, 14.0, 90.0, 4.0)
	if blocked > 0.05:
		ring(parent, at, Color(0.55, 0.78, 1.0), 20.0, 120.0 + 80.0 * blocked, 0.34, 6)
	if dmg_ratio > 0.1:
		ring(parent, at, BLOOD, 16.0, 190.0, 0.4, 8)


# ---- 异常状态：一次性 ---------------------------------------------------------------------------------------------

static func stun_burst(parent: Control, at: Vector2) -> void:
	for i in 5:
		var s := Polygon2D.new()
		s.polygon = _star(11.0, 5.0)
		s.color = GOLD
		s.position = at
		s.z_index = 47
		parent.add_child(s)
		var a := TAU * i / 5.0
		var tw := s.create_tween().set_parallel(true)
		tw.tween_property(s, "position", at + Vector2(cos(a) * 80.0, sin(a) * 30.0 - 36.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(s, "rotation", TAU, 0.4)
		tw.chain().tween_property(s, "modulate:a", 0.0, 0.2)
		tw.chain().tween_callback(s.queue_free)


static func break_flash(parent: Control, rect: Rect2) -> Node2D:
	## 破防: cracks run across the enemy (and stay while the status lasts — the caller keeps the node)
	var c := cracks(parent, rect, Color(1.0, 0.82, 0.35, 0.9))
	c.modulate = Color(1, 1, 1, 0)
	var tw := c.create_tween()
	tw.tween_property(c, "modulate:a", 1.0, 0.05)
	tw.tween_property(c, "modulate", Color(2.2, 2.0, 1.2, 1.0), 0.08)
	tw.tween_property(c, "modulate", Color(1, 1, 1, 0.7), 0.3)
	return c


static func drain_shatter(parent: Control, pips: Array, amount: int) -> void:
	## 夺气: the pips the enemy took blink dark red and drop
	for k in mini(amount, pips.size()):
		var pip: Control = pips[k]
		if not is_instance_valid(pip):
			continue
		var tw := pip.create_tween()
		tw.tween_property(pip, "self_modulate", Color(1.0, 0.2, 0.2), 0.08)
		tw.tween_property(pip, "self_modulate", Color.WHITE, 0.08)
		tw.tween_property(pip, "self_modulate", Color(1.0, 0.2, 0.2), 0.08)
		tw.tween_property(pip, "position:y", pip.position.y + 18.0, 0.18)
		var at := pip.global_position - parent.global_position + pip.size / 2
		burst(parent, at, BLOOD, 6, 4.0, 36.0, 3.0, 0.3)


static func buff_cast(parent: Control, centers: Array) -> void:
	## 战意: golden rings and little arrows rising off every card
	for c in centers:
		ring(parent, c, GOLD, 20.0, 120.0, 0.45, 5)
		for i in 4:
			var a := Polygon2D.new()
			a.polygon = PackedVector2Array([Vector2(0, -12), Vector2(10, 4), Vector2(3, 4), Vector2(3, 14), Vector2(-3, 14), Vector2(-3, 4), Vector2(-10, 4)])
			a.color = GOLD
			a.position = c + Vector2((i - 1.5) * 34.0, 70.0)
			a.z_index = 47
			parent.add_child(a)
			var tw := a.create_tween().set_parallel(true)
			tw.tween_property(a, "position:y", a.position.y - 150.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(i * 0.06)
			tw.tween_property(a, "modulate:a", 0.0, 0.7).set_delay(i * 0.06)
			tw.chain().tween_callback(a.queue_free)


static func cleanse_wave(parent: Control, rect: Rect2) -> void:
	## 解除: a green wave sweeps the row and sparkles
	var w := ColorRect.new()
	w.color = Color(GREEN, 0.0)
	w.position = rect.position
	w.size = Vector2(90.0, rect.size.y)
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	w.z_index = 45
	parent.add_child(w)
	var grad := Gradient.new()
	grad.set_color(0, Color(GREEN, 0.0))
	grad.set_color(1, Color(GREEN, 0.0))
	grad.add_point(0.5, Color(GREEN, 0.55))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0.5)
	gt.fill_to = Vector2(1, 0.5)
	var tr := TextureRect.new()
	tr.texture = gt
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.size = w.size
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	w.add_child(tr)
	var tw := w.create_tween()
	tw.tween_property(w, "position:x", rect.position.x + rect.size.x - 60.0, 0.55).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(w.queue_free)
	embers(parent, rect, Color(GREEN, 0.9), 26, 40.0, true)


static func flame_lick(parent: Control, rect: Rect2) -> void:
	## a burn tick: a quick gust of flame over whatever is burning
	embers(parent, rect, EMBER, 30, 90.0, true)
	ring(parent, rect.position + rect.size / 2, Color(1.0, 0.55, 0.15, 0.9), 16.0, minf(rect.size.x, 220.0) * 0.5, 0.3, 4)


static func boost_cast(parent: Control, rect: Rect2) -> void:
	## BOOST given: a flame column roars up off the card and a gold-red ring flares
	var c := rect.position + rect.size * 0.5
	ring(parent, c, Color(1.0, 0.55, 0.2), 20.0, 150.0, 0.4, 8)
	ring(parent, c, GOLD, 10.0, 100.0, 0.3, 5)
	embers(parent, Rect2(rect.position + Vector2(0, rect.size.y * 0.55), Vector2(rect.size.x, rect.size.y * 0.45)), Color(1.0, 0.6, 0.15, 0.95), 34, 160.0, true)
	burst(parent, c, GOLD, 12, 20.0, 120.0, 5.0, 0.32)


static func boost_aura(parent: Control, rect: Rect2) -> Node2D:
	## a BOOSTed leader: flames licking up the card and an orange pulse, until it has acted
	var holder := Node2D.new()
	holder.z_index = 44
	parent.add_child(holder)
	glow(holder, rect, Color(1.0, 0.55, 0.15))
	embers(holder, Rect2(rect.position + Vector2(8, rect.size.y * 0.6), Vector2(rect.size.x - 16, rect.size.y * 0.4)), Color(1.0, 0.62, 0.18, 0.9), 20, 120.0)
	return holder


static func badge(text: String, color: Color, num := -1, faint := false) -> Control:
	## a round corner badge: one character for the status, a small number for its turns / layers
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color.darkened(0.25)
	sb.border_color = Color(1, 1, 1, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(17)
	p.add_theme_stylebox_override("panel", sb)
	p.custom_minimum_size = Vector2(34, 34)
	p.size = Vector2(34, 34)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Kit.label(text, 19, "text")
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	l.add_theme_constant_override("outline_size", 5)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size = Vector2(34, 34)
	p.add_child(l)
	if num >= 0:
		var n := Kit.label(str(num), 14, "text")
		n.add_theme_color_override("font_color", Color.WHITE)
		n.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		n.add_theme_constant_override("outline_size", 5)
		n.position = Vector2(22, 17)
		p.add_child(n)
	if faint:
		p.modulate.a = 0.55
	return p


# ---- 异常状态：持续（返回节点，状态结束时 queue_free） ---------------------------------------------------------------

static func embers(parent: Node, rect: Rect2, color: Color, amount := 24, rise := 60.0, one_shot := false) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = rect.position + rect.size * 0.5
	p.z_index = 46
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = rect.size * 0.5
	p.amount = amount
	p.lifetime = 1.1
	p.one_shot = one_shot
	p.explosiveness = 0.9 if one_shot else 0.0
	p.direction = Vector2(0, -1)
	p.spread = 20.0
	p.gravity = Vector2(0, -rise)
	p.initial_velocity_min = 10.0
	p.initial_velocity_max = 40.0
	p.scale_amount_min = 2.5
	p.scale_amount_max = 6.0
	var g := Gradient.new()
	g.set_color(0, color)
	g.set_color(1, Color(color, 0.0))
	p.color_ramp = g
	parent.add_child(p)
	p.emitting = true
	if one_shot:
		_free_after(p, 1.6)
	return p


static func orbit(parent: Control, center: Vector2, rx := 60.0, ry := 18.0, n := 3, color := GOLD, size := 9.0) -> Node2D:
	## stars circling above a head (混乱 / 眩晕)
	var holder := Node2D.new()
	holder.position = center
	holder.z_index = 47
	parent.add_child(holder)
	var stars: Array = []
	for i in n:
		var s := Polygon2D.new()
		s.polygon = _star(size, size * 0.45)
		s.color = color
		holder.add_child(s)
		stars.append(s)
	var tw := holder.create_tween().set_loops()
	tw.tween_method(func(a: float):
		for i in stars.size():
			stars[i].position = Vector2(cos(a + TAU * i / n) * rx, sin(a + TAU * i / n) * ry)
			stars[i].rotation = a * 2.0, 0.0, TAU, 1.4)
	return holder


static func cracks(parent: Control, rect: Rect2, color: Color, n := 5) -> Node2D:
	var holder := Node2D.new()
	holder.z_index = 46
	parent.add_child(holder)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for k in n:
		var ln := Line2D.new()
		ln.width = 3.0
		ln.default_color = color
		var pt := rect.position + Vector2(rng.randf_range(0.25, 0.75) * rect.size.x, rng.randf_range(0.2, 0.5) * rect.size.y)
		var dir := Vector2.from_angle(rng.randf_range(0.0, TAU))
		var pts := PackedVector2Array([pt])
		for s in 5:
			dir = dir.rotated(rng.randf_range(-0.7, 0.7))
			pt += dir * rng.randf_range(24.0, 46.0)
			pts.append(pt)
		ln.points = pts
		holder.add_child(ln)
	return holder


static func glow(parent: Node, rect: Rect2, color: Color) -> Panel:
	## a pulsing hollow frame (战意 / BOOST on a card): an inner bright border and a wider soft one, nothing filled
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.draw_center = false
	sb.border_color = color
	sb.set_border_width_all(5)
	sb.set_corner_radius_all(16)
	p.add_theme_stylebox_override("panel", sb)
	p.position = rect.position
	p.size = rect.size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.z_index = 44
	var outer := Panel.new()
	var sb2 := StyleBoxFlat.new()
	sb2.draw_center = false
	sb2.border_color = Color(color, 0.4)
	sb2.set_border_width_all(4)
	sb2.set_corner_radius_all(20)
	outer.add_theme_stylebox_override("panel", sb2)
	outer.position = Vector2(-7, -7)
	outer.size = rect.size + Vector2(14, 14)
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(outer)
	parent.add_child(p)
	var tw := p.create_tween().set_loops()
	tw.tween_property(p, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
	tw.tween_property(p, "modulate:a", 0.4, 0.8).set_trans(Tween.TRANS_SINE)
	return p
