class_name MapScreen
extends Control
## Landscape quest map: squares left → right in three lanes, links between them, a token for the party.
## Reachable squares glow; tap one and the token walks there. The panel at the bottom shows the square.

const COL_W := 150.0
const LANE_H := 104.0
const SQ := 74.0
const MAP_TOP := 6.0

var toast := ""
var q: Dictionary
var _scroll: ScrollContainer
var _layer: Control
var _lines: MapLines
var _token: Panel
var _nodes: Dictionary = {}  # square id -> Button
var _pulses: Array = []
var _sheet: PanelContainer
var _sheet_box: VBoxContainer
var _hp_bar: ProgressBar
var _hp_label: Label
var _title: Label
var _busy := false


class MapLines extends Control:
	var segs: Array = []  # [from, to, color, width]

	func _draw() -> void:
		for s in segs:
			draw_line(s[0], s[1], s[2], s[3], true)


func _ready() -> void:
	# top bar
	var top := HBoxContainer.new()
	top.position = Vector2(24, 14)
	top.size = Vector2(1232, 48)
	top.add_theme_constant_override("separation", 18)
	add_child(top)
	_title = Kit.label("", Kit.FONT_BIG, "gold")
	top.add_child(_title)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	top.add_child(Kit.label("体力", Kit.FONT_BODY, "muted"))
	_hp_bar = Kit.bar(1, 1, "green", 22)
	_hp_bar.custom_minimum_size = Vector2(300, 22)
	_hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_hp_bar)
	_hp_label = Kit.label("", Kit.FONT_BODY)
	top.add_child(_hp_label)

	# map
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(0, 70)
	_scroll.size = Vector2(1280, 372)
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)
	_layer = Control.new()
	_scroll.add_child(_layer)
	_lines = MapLines.new()
	_lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_lines)

	# bottom panel
	_sheet = PanelContainer.new()
	_sheet.position = Vector2(24, 448)
	_sheet.size = Vector2(1232, 258)
	add_child(_sheet)
	_sheet_box = VBoxContainer.new()
	_sheet_box.add_theme_constant_override("separation", 10)
	_sheet.add_child(_sheet_box)

	_rebuild_map()
	_refresh()
	if toast != "":
		_show_toast(toast)


# ---- map drawing ---------------------------------------------------------------

func _pos(s: Dictionary) -> Vector2:
	return Vector2(90 + s["x"] * COL_W, MAP_TOP + 50 + s["y"] * LANE_H)


func _rebuild_map() -> void:
	q = Quests.ensure_started(Game.save)
	Game.persist()
	for n in _nodes.values():
		n.queue_free()
	_nodes.clear()
	if q == null:
		return
	var max_x := 0
	for s in q["squares"].values():
		max_x = maxi(max_x, s["x"])
	_layer.custom_minimum_size = Vector2(180 + max_x * COL_W + 60, 360)
	_lines.size = _layer.custom_minimum_size
	for s in q["squares"].values():
		var b := Button.new()
		b.text = _glyph(s)
		b.add_theme_font_size_override("font_size", 30)
		b.size = Vector2(SQ, SQ)
		b.position = _pos(s) - Vector2(SQ, SQ) / 2
		b.pivot_offset = Vector2(SQ, SQ) / 2
		b.pressed.connect(_on_square.bind(s["id"]))
		_layer.add_child(b)
		var lbl := Kit.label(s["label"] if s["label"] != "" else _type_name(s), 16, "muted")
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.position = _pos(s) + Vector2(-60, SQ / 2 + 2)
		lbl.size = Vector2(120, 22)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layer.add_child(lbl)
		_nodes[s["id"]] = b
	_token = Panel.new()
	_token.add_theme_stylebox_override("panel", Kit.box(Kit.c("red"), 14, 3, Color.WHITE, 0))
	_token.size = Vector2(28, 28)
	_token.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_token.z_index = 5
	_layer.add_child(_token)


func _glyph(s: Dictionary) -> String:
	var glyphs: Dictionary = GameData.get_db().ui["map"]["glyphs"]
	return glyphs["boss"] if s["boss"] else glyphs[s["type"]]


func _type_name(s: Dictionary) -> String:
	return GameData.get_db().ui["map"]["type_names"][s["type"]]


func _type_color(s: Dictionary) -> Color:
	var names: Dictionary = GameData.get_db().ui["map"]["type_colors"]
	return Kit.c(names["boss" if s["boss"] else s["type"]])


func _style_square(b: Button, s: Dictionary, state: String) -> void:
	var r := int(SQ / 2)
	var bg := Kit.c("card")
	var fg := _type_color(s)
	var border := _type_color(s)
	match state:
		"current":
			bg = Kit.c("gold")
			fg = Color.WHITE
			border = Color.WHITE
		"reachable":
			bg = Kit.c("green")
			fg = Color.WHITE
			border = Color.WHITE
		"visited":
			bg = Kit.c("track")
			fg = Kit.c("dim")
			border = Kit.c("track")
		"closed":
			bg = Kit.c("panel")
			fg = Kit.c("dim")
			border = Kit.c("border")
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb := Kit.box(bg if st != "hover" else bg.lightened(0.1), r, 4, border, 0)
		if st == "focus":
			sb = Kit.box(bg, r, 5, Kit.c("amber"), 0)
		b.add_theme_stylebox_override(st, sb)
	for fc in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		b.add_theme_color_override(fc, fg)


func _refresh() -> void:
	for t in _pulses:
		t.kill()
	_pulses.clear()
	var save := Game.save
	if q == null:
		_title.text = "剧情"
		_show_end()
		return
	_title.text = q["title"]
	var party := save.party_leaders()
	var hp_max := 0
	for ld in party:
		hp_max += ld["hp"]
	var hp := maxi(1, hp_max - save.damage)
	_hp_bar.max_value = hp_max
	Kit.tween_bar(_hp_bar, hp)
	_hp_label.text = "%d / %d" % [hp, hp_max]

	var reachable := {}
	for s in Quests.next_options(q, save):
		reachable[s["id"]] = true
	# squares still ahead of the party (anything else unvisited is out of reach now)
	var ahead := {}
	var frontier: Array = [save.square]
	while not frontier.is_empty():
		var cur: Dictionary = q["squares"][frontier.pop_back()]
		var nexts: Array = cur["next"].duplicate()
		if cur["type"] == "choose":
			if save.choices.has(cur["id"]):
				nexts = [save.choices[cur["id"]]]
			else:
				nexts = cur["choose"].map(func(o): return o["goto"])
		for n in nexts:
			if not ahead.has(n):
				ahead[n] = true
				frontier.append(n)
	var path := {}
	for i in save.visited.size() - 1:
		path[save.visited[i] + ">" + save.visited[i + 1]] = true
	_lines.segs.clear()
	for s in q["squares"].values():
		var targets: Array = s["next"].duplicate()
		for o in s["choose"]:
			targets.append(o["goto"])
		for t in targets:
			var walked: bool = path.has(s["id"] + ">" + t)
			var col := Kit.c("gold") if walked else Kit.c("border")
			_lines.segs.append([_pos(s), _pos(q["squares"][t]), col, 6.0 if walked else 3.0])
	_lines.queue_redraw()

	for sid in _nodes:
		var s: Dictionary = q["squares"][sid]
		var b: Button = _nodes[sid]
		var state := "open"
		if sid == save.square:
			state = "current"
		elif reachable.has(sid):
			state = "reachable"
		elif save.visited.has(sid):
			state = "visited"
		elif not ahead.has(sid):
			state = "closed"
		_style_square(b, s, state)
		b.disabled = state != "reachable"
		b.focus_mode = Control.FOCUS_ALL if state == "reachable" else Control.FOCUS_NONE
		b.scale = Vector2.ONE
		if state == "reachable":
			var tw := b.create_tween().set_loops()
			tw.tween_property(b, "scale", Vector2(1.12, 1.12), 0.5).set_trans(Tween.TRANS_SINE)
			tw.tween_property(b, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
			_pulses.append(tw)
	var here: Dictionary = q["squares"][save.square]
	_token.position = _pos(here) - Vector2(14, SQ / 2 + 22)
	_center_on(here)
	_show_square(here)


func _center_on(s: Dictionary) -> void:
	await get_tree().process_frame
	var target := int(_pos(s).x - 640)
	var tw := create_tween()
	tw.tween_property(_scroll, "scroll_horizontal", maxi(0, target), 0.35).set_trans(Tween.TRANS_CUBIC)


# ---- moving --------------------------------------------------------------------

func _on_square(sid: String) -> void:
	if _busy:
		return
	_busy = true
	var target: Dictionary = q["squares"][sid]
	var tw := create_tween()
	var dest := _pos(target) - Vector2(14, SQ / 2 + 22)
	tw.tween_property(_token, "position", dest + Vector2(0, -18), 0.18).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(_token, "position", dest, 0.14).set_trans(Tween.TRANS_BOUNCE)
	await tw.finished
	Quests.move(q, Game.save, sid)
	Game.persist()
	_busy = false
	_refresh()


# ---- the bottom panel ------------------------------------------------------------

func _clear_sheet() -> void:
	for ch in _sheet_box.get_children():
		ch.queue_free()


func _show_square(s: Dictionary) -> void:
	_clear_sheet()
	var save := Game.save
	var db := GameData.get_db()
	var head := Kit.label("%s  %s" % [_glyph(s), s["label"] if s["label"] != "" else _type_name(s)], Kit.FONT_BIG)
	_sheet_box.add_child(head)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sheet_box.add_child(row)

	for key in s["portraits"]:
		var tex := Kit.portrait(key, 0.75, 5.0)
		if tex != null:
			var tr := TextureRect.new()
			tr.texture = tex
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			tr.custom_minimum_size = Vector2(135, 180)
			row.add_child(tr)
	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.fit_content = false
	text.scroll_active = true
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("normal_font_size", Kit.FONT_BODY)
	text.add_theme_font_size_override("bold_font_size", Kit.FONT_BODY)
	text.add_theme_color_override("default_color", Kit.c("text"))
	row.add_child(text)
	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.custom_minimum_size = Vector2(250, 0)
	buttons.alignment = BoxContainer.ALIGNMENT_END
	row.add_child(buttons)

	var lines: Array = []
	for t in s["text"]:
		lines.append(t.replace("{lord}", "[color=%s][b]%s[/b][/color]" % [Kit.c("red").to_html(), save.lord_name]))
	var body := "\n\n".join(lines)

	if save.resolved:
		var opts := Quests.next_options(q, save)
		if s["type"] == "battle":
			body = "[color=%s]已击破。[/color]" % Kit.c("green").to_html()
		elif s["type"] == "recover":
			body = "休整完毕，体力全满。"
		elif s["type"] == "choose":
			body = "已做出选择。"
		elif body == "":
			body = "已完成。"
		if opts.is_empty():
			text.text = body
			var done := Kit.button("完成本章 ▶", "green")
			done.pressed.connect(_complete)
			buttons.add_child(done)
			Kit.focus(done)
		else:
			text.text = body + "\n\n[color=%s]点击发光的格子前进[/color]" % Kit.c("green").to_html()
			var first := true
			for n in opts:
				var go := Kit.button("前往 %s %s" % [_glyph(n), n["label"] if n["label"] != "" else _type_name(n)])
				go.pressed.connect(_on_square.bind(n["id"]))
				buttons.add_child(go)
				if first:
					Kit.focus(go)
					first = false
		return

	match s["type"]:
		"event":
			text.text = body
			var next := Kit.button("继续 ▶", "blue")
			next.pressed.connect(_resolve)
			buttons.add_child(next)
			Kit.focus(next)
		"choose":
			text.text = body if body != "" else "选一人随你同行。"
			var open := Kit.button("做出选择", "gold")
			open.pressed.connect(_open_choose.bind(s))
			buttons.add_child(open)
			Kit.focus(open)
			_open_choose(s)
		"battle":
			var sc: Dictionary = db.scenarios[s["battle"]]
			var e: Dictionary = db.enemies[sc["enemy"]]
			var boss := "[color=%s][b]首领战[/b][/color]　" % Kit.c("purple").to_html() if s["boss"] else ""
			text.text = "%s敌军：[b]%s[/b]\n体力 %d　攻击 %d　每回合行动 %d 次\n%d 回合内击破。任务中体力不会自动回满。" % [
				boss, e["name"], e["hp"], e["at"], e["actions"], sc["turn_limit"]]
			var fight := Kit.button("⚔ 出战", "red", Kit.FONT_BIG)
			fight.pressed.connect(func(): Game.start_quest_battle(q, s))
			buttons.add_child(fight)
			Kit.focus(fight)
		"treasure", "recruit":
			var is_chest: bool = s["type"] == "treasure"
			text.text = "宝箱里有几张兵卡，只能拿一张。同种兵卡越多部队越强，但重复的会衰减——缺什么拿什么。" if is_chest \
				else "闻名而来的豪杰，只能收下一位。"
			var open := Kit.button("打开宝箱" if is_chest else "接见豪杰", "gold")
			open.pressed.connect(_open_offer.bind(s))
			buttons.add_child(open)
			Kit.focus(open)
		"recover":
			text.text = "可以在这里休整：体力回满，累积技能的 AP 加价和限 1 次技能全部重置。"
			var rest := Kit.button("休整", "blue")
			rest.pressed.connect(_resolve)
			buttons.add_child(rest)
			Kit.focus(rest)


func _resolve(choice := -1) -> void:
	var gained := Quests.resolve(q, Game.save, Game.rng, choice)
	Game.persist()
	_refresh()
	for c in gained:
		_show_toast("获得：" + c["name"])


func _open_choose(s: Dictionary) -> void:
	var o := PickOverlay.new()
	o.title = "选一人随你同行"
	o.card_ids = s["choose"].map(func(x): return x["card"])
	o.captions = s["choose"].map(func(x): return x["label"])
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.picked.connect(func(i): o.queue_free(); _resolve(i))
	add_child(o)


func _open_offer(s: Dictionary) -> void:
	var cards := Quests.offer(q, Game.save, Game.rng)
	Game.persist()
	if cards.is_empty():
		_resolve()
		return
	var o := PickOverlay.new()
	o.title = "宝箱 —— 选一张兵卡" if s["type"] == "treasure" else "豪杰来投 —— 选一位"
	o.card_ids = cards.map(func(c): return c["id"])
	o.counts = cards.map(func(c): return Game.save.copies(c["id"]) if c["soldier"] else 0)
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.picked.connect(func(i): o.queue_free(); _resolve(i))
	add_child(o)


func _complete() -> void:
	Quests.complete(q, Game.save)
	Game.persist()
	_show_toast("「%s」完成！" % q["title"])
	_rebuild_map()
	_refresh()


func _show_end() -> void:
	_clear_sheet()
	_sheet_box.add_child(Kit.label("剧情暂时到此为止。后续章节制作中。", Kit.FONT_BIG))


func _show_toast(msg: String) -> void:
	var l := Kit.label(msg, Kit.FONT_BIG)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_stylebox_override("normal", Kit.box(Color(0, 0, 0, 0.75), 12, 0, Color.TRANSPARENT, 14))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(340, 300)
	l.size = Vector2(600, 60)
	l.z_index = 60
	add_child(l)
	var tw := l.create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.4)
	tw.tween_callback(l.queue_free)
