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
var _bg: TextureRect
var _token: Control
var _nodes: Dictionary = {}  # square id -> Button
var _pulses: Array = []
var _sheet: PanelContainer
var _cg_view: TextureRect  # Rance X style: a story CG fills the screen, the text box sits over it
var _cg_tab: Button  # switch between the CG and the map
var _cg_mode := false
var _cg_bar: ColorRect  # keeps the top bar readable over a CG
# story text plays one line per click (visual-novel style); the buttons appear after the last line
var _dlg_lines: Array = []
var _dlg_i := -1
var _dlg_text: RichTextLabel
var _dlg_buttons: Control
var _dlg_tools: HBoxContainer  # 跳过 / 隐藏
var _dlg_recap := false  # a choice follows: once the lines are read, sum them up beside the options
var _dlg_face: TextureRect  # the speaker of the current line
var _dlg_raw: Array = []  # the lines before {lord} is filled in (for speaker lookup)
var _dlg_prompt := ""  # the one-line summary shown at the choice (square / event "prompt")
var _sheet_hidden := false
var _cg_square := ""  # the square whose CG was last shown (a new one switches to the CG again)
var _sheet_box: VBoxContainer
var _hp_bar: ProgressBar
var _hp_label: Label
var _run_box: HBoxContainer
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
	var party_btn := Kit.button("部队", "gold")
	party_btn.pressed.connect(_open_party)
	top.add_child(party_btn)
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
	_run_box = HBoxContainer.new()  # 宝物 and 险 this run
	_run_box.add_theme_constant_override("separation", 6)
	top.add_child(_run_box)
	top.move_child(_run_box, 1)

	# map
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(0, 70)
	_scroll.size = Vector2(1280, 372)
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)
	_layer = Control.new()
	_scroll.add_child(_layer)
	_bg = TextureRect.new()
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_bg)
	_lines = MapLines.new()
	_lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_lines)

	# story CG (behind the top bar and the text box)
	_cg_view = TextureRect.new()
	_cg_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cg_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cg_view.size = Vector2(1280, 720)
	_cg_view.mouse_filter = Control.MOUSE_FILTER_STOP
	_cg_view.gui_input.connect(_on_story_click)
	_cg_view.visible = false
	add_child(_cg_view)
	move_child(_cg_view, 0)
	_cg_bar = ColorRect.new()
	_cg_bar.color = Kit.c("bg")
	_cg_bar.color.a = 0.82
	_cg_bar.size = Vector2(1280, 70)
	_cg_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cg_bar.visible = false
	add_child(_cg_bar)
	move_child(_cg_bar, 1)
	_cg_tab = Kit.button("查看地图", "purple")
	_cg_tab.visible = false
	_cg_tab.pressed.connect(func():
		_cg_mode = not _cg_mode
		_apply_cg_mode())
	top.add_child(_cg_tab)
	top.move_child(_cg_tab, 2)

	# bottom panel
	_sheet = PanelContainer.new()
	_sheet.position = Vector2(24, 448)
	_sheet.size = Vector2(1232, 258)
	add_child(_sheet)
	_sheet_box = VBoxContainer.new()
	_sheet_box.add_theme_constant_override("separation", 10)
	_sheet.add_child(_sheet_box)
	_sheet.gui_input.connect(_on_story_click)
	_dlg_tools = HBoxContainer.new()  # sits at the text box's top-right corner
	_dlg_tools.position = Vector2(1040, 456)
	_dlg_tools.add_theme_constant_override("separation", 8)
	_dlg_tools.z_index = 5
	add_child(_dlg_tools)
	var skip := Kit.button("跳过", "gray", Kit.FONT_SMALL)
	skip.focus_mode = Control.FOCUS_NONE
	skip.pressed.connect(_dialog_skip)
	_dlg_tools.add_child(skip)
	var hide_btn := Kit.button("隐藏", "gray", Kit.FONT_SMALL)
	hide_btn.name = "Hide"
	hide_btn.focus_mode = Control.FOCUS_NONE
	hide_btn.pressed.connect(_hide_sheet)
	_dlg_tools.add_child(hide_btn)

	_rebuild_map()
	_refresh()
	if toast != "":
		_show_toast(toast)


# ---- map drawing ---------------------------------------------------------------

func _pos(s: Dictionary) -> Vector2:
	return Vector2(90 + s["x"] * COL_W, MAP_TOP + 50 + s["y"] * LANE_H)


func _rebuild_map() -> void:
	q = Quests.ensure_started(Game.save, Game.rng)
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
	# chapter background: data/art/map/<quest id>.jpg (built by `sanguo-art` from pics/art.json "maps")
	var bg_path: String = "res://data/art/map/%s.jpg" % q["id"]
	_bg.texture = load(bg_path) if ResourceLoader.exists(bg_path) else null
	_bg.size = _layer.custom_minimum_size
	for s in q["squares"].values():
		if not Quests.is_open(s, Game.save):  # hidden by an earlier chapter's choices
			continue
		var b := Button.new()
		var icon_tex: Texture2D = Kit.map_icon(_icon_key(s))
		if icon_tex != null:
			b.icon = icon_tex
			b.expand_icon = true
			b.flat = true
		else:
			b.text = _glyph(s)
			b.add_theme_font_size_override("font_size", 30)
		b.size = Vector2(SQ, SQ)
		b.position = _pos(s) - Vector2(SQ, SQ) / 2
		b.pivot_offset = Vector2(SQ, SQ) / 2
		b.pressed.connect(_on_square.bind(s["id"]))
		_layer.add_child(b)
		var lbl := Kit.label(s["label"] if s["label"] != "" else _type_name(s), 16, "text")
		var pill := Kit.box(Kit.c("card").lerp(Color.TRANSPARENT, 0.15), 8, 0, Color.TRANSPARENT, 0)
		pill.content_margin_left = 8
		pill.content_margin_right = 8
		lbl.add_theme_stylebox_override("normal", pill)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var w := lbl.get_theme_font("font").get_string_size(lbl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x + 16
		lbl.position = _pos(s) + Vector2(-w / 2, SQ / 2 + 2)
		lbl.size = Vector2(w, 22)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layer.add_child(lbl)
		_nodes[s["id"]] = b
	var token_tex: Texture2D = Kit.token_icon()
	if token_tex != null:
		var tr := TextureRect.new()
		tr.texture = token_tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.size = Vector2(34, 34)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.z_index = 5
		_token = tr
	else:
		var p := Panel.new()
		p.add_theme_stylebox_override("panel", Kit.box(Kit.c("red"), 14, 3, Color.WHITE, 0))
		p.size = Vector2(28, 28)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.z_index = 5
		_token = p
	_layer.add_child(_token)


func _glyph(s: Dictionary) -> String:
	var glyphs: Dictionary = GameData.get_db().ui["map"]["glyphs"]
	return _fixed_event(s).get("glyph", glyphs[_kind(s)])


func _kind(s: Dictionary) -> String:
	## glyph / colour key: boss and elite battles have their own
	return "boss" if s["boss"] else ("elite" if s["elite"] else s["type"])


func _icon_key(s: Dictionary) -> String:
	var fe: Dictionary = _fixed_event(s)
	if fe.has("glyph"):
		match fe["glyph"]:
			"险": return "hazard"
			"威": return "glory"
			"庙": return "temple"
			"医": return "physician"
			"凶": return "curse"
			"赤": return "red_turban"
			"宝": return "treasure"
			"将": return "boss"
			_: return ""  # no icon drawn for this glyph (交、甲、寨): the square shows the glyph itself
	return _kind(s)


func _fixed_event(s: Dictionary) -> Dictionary:
	## a ？ square holding a set event (险) shows that event's glyph and colour
	return GameData.get_db().events[s["event"]] if s["event"] != "" else {}


func _type_name(s: Dictionary) -> String:
	return GameData.get_db().ui["map"]["type_names"][s["type"]]


func _type_color(s: Dictionary) -> Color:
	var names: Dictionary = GameData.get_db().ui["map"]["type_colors"]
	return Kit.c(_fixed_event(s).get("color", names[_kind(s)]))


func _style_square(b: Button, s: Dictionary, state: String) -> void:
	if b.icon != null:
		var empty_sb := StyleBoxEmpty.new()
		for st in ["normal", "hover", "pressed", "disabled"]:
			b.add_theme_stylebox_override(st, empty_sb)
		var focus_sb := Kit.box(Color.TRANSPARENT, int(SQ / 2), 3, Kit.c("amber"), 0)
		b.add_theme_stylebox_override("focus", focus_sb)
		for st in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color", "icon_disabled_color"]:
			b.add_theme_color_override(st, Color.WHITE)  # a disabled button would fade its icon to 40%
		match state:
			"current":
				b.modulate = Color(1.15, 1.1, 0.95)
			"reachable":
				b.modulate = Color.WHITE
			"visited":  # been there: greyed
				b.modulate = Color(0.6, 0.6, 0.6)
			"closed":  # not reachable yet: still readable
				b.modulate = Color(0.92, 0.92, 0.92)
		return
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
	_title.text = q["title"] + ("　（重玩 · 进阶 +%d%%）" % int(round(save.danger * float(GameData.get_db().battle["danger_step"]) * 100)) if save.replay != "" else "")
	var party := save.party_leaders()
	var hp_max := Quests.party_max(save)
	var hp := maxi(1, hp_max - save.damage)
	_hp_bar.max_value = hp_max
	Kit.tween_bar(_hp_bar, hp)
	_hp_label.text = "%d / %d" % [hp, hp_max]
	_show_run()

	var reachable := {}
	for s in Quests.next_options(q, save):
		reachable[s["id"]] = true
	# squares still ahead of the party (anything else unvisited is out of reach now)
	var ahead := {}
	var frontier: Array = [save.square]
	while not frontier.is_empty():
		var cur: Dictionary = q["squares"][frontier.pop_back()]
		var nexts: Array = cur["next"].duplicate()
		if cur["lose_goto"] != "":
			nexts.append(cur["lose_goto"])
		if cur["type"] == "choose":
			if save.choices.has(cur["id"]):
				nexts = [save.choices[cur["id"]]]
			else:
				nexts = cur["choose"].filter(func(o): return not o["locked"]).map(func(o): return o["goto"])
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
			if not o["locked"]:
				targets.append(o["goto"])
		if s["lose_goto"] != "":
			targets.append(s["lose_goto"])
		for t in targets:
			if not _nodes.has(s["id"]) or not _nodes.has(t):
				continue
			var walked: bool = path.has(s["id"] + ">" + t)
			var a := _pos(s)
			var b := _pos(q["squares"][t])
			_lines.segs.append([a, b, Color(0.12, 0.09, 0.06, 0.55), 9.0 if walked else 6.0])
			_lines.segs.append([a, b, Kit.c("gold") if walked else Color(0.96, 0.93, 0.85, 0.9), 5.0 if walked else 2.5])
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
	_token.position = _pos(here) - Vector2(_token.size.x / 2.0, SQ / 2.0 + _token.size.y - 8)
	_center_on(here)
	_show_square(here)
	if save.offer_kind == "relic" and not save.offer.is_empty():
		_open_relics.call_deferred()


func _show_run() -> void:
	for ch in _run_box.get_children():
		ch.queue_free()
	var db := GameData.get_db()
	var save := Game.save
	if save.difficulty > 0:
		var h := _chip("难度 +%d%%" % int(round(save.difficulty * float(db.battle["difficulty_step"]) * 100)), "purple")
		h.tooltip_text = "打赢了虎牢关的吕布，天下都盯上了你：今后所有敌人都更强"
		_run_box.add_child(h)
	if save.danger > 0:
		var d := _chip("险 +%d%%" % int(round(save.danger * float(db.battle["danger_step"]) * 100)), "red")
		d.tooltip_text = "本轮的敌人体力和攻击都变强了"
		_run_box.add_child(d)
	for rid in save.relics:
		var r: Dictionary = db.relics[rid]
		var c := _chip(r["icon"] + " " + r["name"], {"rare": "purple", "curse": "red"}.get(r["rarity"], "gold"))
		c.tooltip_text = r["desc"]
		if save.relic_unit(rid) == "":  # not worn, or its team isn't out: greyed
			c.modulate = Color(1, 1, 1, 0.45)
			c.tooltip_text += "（没生效：没装或队伍没出阵，去整备里看看）"
		_run_box.add_child(c)


func _chip(text: String, color: String) -> Label:
	var l := Kit.label(text, 16)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_stylebox_override("normal", Kit.box(Kit.c(color), 8, 0, Color.TRANSPARENT, 6))
	l.mouse_filter = Control.MOUSE_FILTER_STOP
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


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
	var dest := _pos(target) - Vector2(_token.size.x / 2.0, SQ / 2.0 + _token.size.y - 8)
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
	var ev: Dictionary = {}
	if s["type"] == "mystery" and s["id"] == save.square:
		ev = Quests.event_here(q, save, Game.rng)
		Game.persist()
	var title: String = ev.get("title", s["label"] if s["label"] != "" else _type_name(s))
	# [speaker face | title over (text, buttons)]: the face spans the panel's full height
	var outer := HBoxContainer.new()
	outer.add_theme_constant_override("separation", 16)
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sheet_box.add_child(outer)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var head := Kit.label("%s  %s" % [_glyph(s), title], Kit.FONT_BIG)
	col.add_child(head)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(row)

	var art := Kit.cg(ev.get("cg", s["cg"]))
	_cg_view.texture = art
	_cg_tab.visible = art != null
	if art == null:
		_cg_mode = false
	elif _cg_square != s["id"]:  # arriving at a square with a CG: the CG takes the screen
		_cg_square = s["id"]
		_cg_mode = true
	_apply_cg_mode()
	var raw_lines: Array = ev.get("text", s["text"])
	var talking: bool = not save.resolved and raw_lines.size() > 1 and (s["type"] in ["event", "choose"] \
		or (s["type"] == "mystery" and save.event_battle.is_empty() and save.offer.is_empty()))
	_dlg_face = null
	if talking:  # a face for whoever is speaking, changed line by line
		_dlg_face = TextureRect.new()
		_dlg_face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_dlg_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_dlg_face.custom_minimum_size = Vector2(128, 128) if art != null else Vector2(172, 230)
		_dlg_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outer.add_child(_dlg_face)
	outer.add_child(col)
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
	buttons.alignment = BoxContainer.ALIGNMENT_BEGIN  # top-down, so several options always fit
	row.add_child(buttons)

	var lines: Array = []
	for t in ev.get("text", s["text"]):
		lines.append(t.replace("{lord}", "[color=%s][b]%s[/b][/color]" % [Kit.c("red").to_html(), save.lord_name]))
	var body := "\n\n".join(lines)
	_dlg_lines = []
	_dlg_i = -1
	_update_tools()
	var prompt: String = ev.get("prompt", s["prompt"]).replace("{lord}", save.lord_name)

	if save.resolved:
		var opts := Quests.next_options(q, save)
		if s["type"] == "battle":
			body = "[color=%s]已击破。[/color]" % Kit.c("green").to_html()
		elif s["type"] == "recover":
			body = "休整完毕，体力全满。"
		elif s["type"] == "choose":
			body = "已做出选择。"
		elif s["type"] == "mystery":
			body = "\n".join(save.event_note)
		elif s["type"] == "event":  # already read: a summary, never the scene again
			body = prompt if prompt != "" else "这一段已经看完了。"
		else:
			body = "已完成。"
		if opts.is_empty():
			text.text = body
			var done := Kit.button("完成本章 ▶", "green")
			done.pressed.connect(_complete)
			buttons.add_child(done)
			Kit.focus(done)
		elif opts.size() == 1:  # one way on: just carry on
			text.text = body
			var go := Kit.button("继续 ▶", "blue")
			go.pressed.connect(_advance)
			buttons.add_child(go)
			Kit.focus(go)
		else:
			# a fork: sum it up instead of replaying the scene
			text.text = (prompt if prompt != "" else "前面有几条路，选一条走。") + "\n\n[color=%s]点击发光的格子前进[/color]" % Kit.c("green").to_html()
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
			if s["choose"].any(func(o): return o["card"] == ""):
				# choices without cards (a destination, a plan): one button each, locked ones greyed out
				var first := true
				for i in s["choose"].size():
					var o: Dictionary = s["choose"][i]
					var b := Kit.button(o["label"], "gold")
					b.disabled = o["locked"]
					b.pressed.connect(_resolve.bind(i))
					buttons.add_child(b)
					if first and not o["locked"]:
						Kit.focus(b)
						first = false
			else:
				var open := Kit.button("做出选择", "gold")
				open.pressed.connect(_open_choose.bind(s))
				buttons.add_child(open)
				Kit.focus(open)
				if body == "":  # nothing to read first
					_open_choose(s)
		"battle":
			text.text = _battle_info(s, Quests.battle_here(q, save))
			_fight_button(s, buttons)
		"mystery":
			if not save.event_battle.is_empty():
				text.text = "\n".join(save.event_note) + "\n\n" + _battle_info(s, Quests.battle_here(q, save))
				_fight_button(s, buttons)
			elif not save.offer.is_empty():
				text.text = "\n".join(save.event_note)  # the outcome, not the event again
				var open := Kit.button("挑选", "gold")
				open.pressed.connect(_open_offer.bind(s))
				buttons.add_child(open)
				Kit.focus(open)
			else:
				text.text = body
				var many: bool = ev["options"].size() > 3  # two columns so every option fits
				var grid := GridContainer.new()
				grid.columns = 2 if many else 1
				grid.add_theme_constant_override("h_separation", 10)
				grid.add_theme_constant_override("v_separation", 10)
				buttons.add_child(grid)
				if many:
					buttons.custom_minimum_size.x = 380
				for i in ev["options"].size():
					var b := Kit.button(ev["options"][i]["label"], "gold")
					b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					b.pressed.connect(_choose_event.bind(i))
					grid.add_child(b)
					if i == 0:
						Kit.focus(b)
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
	# narrative text: one line per click, then the buttons
	var narrative: bool = s["type"] in ["event", "choose"] or (s["type"] == "mystery" and save.event_battle.is_empty() and save.offer.is_empty())
	if narrative and lines.size() > 1:
		_dlg_lines = lines
		_dlg_raw = raw_lines
		_dlg_text = text
		_dlg_buttons = buttons
		_dlg_recap = s["type"] == "choose" or s["type"] == "mystery"
		_dlg_prompt = prompt
		_dlg_i = 0
		text.scroll_active = false
		text.add_theme_font_size_override("normal_font_size", Kit.FONT_BODY + 4)
		text.add_theme_font_size_override("bold_font_size", Kit.FONT_BODY + 4)
		text.mouse_filter = Control.MOUSE_FILTER_PASS
		buttons.visible = false
		_dialog_show()
	_update_tools()


func _dialog_show() -> void:
	var last := _dlg_i >= _dlg_lines.size() - 1
	var hint := "" if last else "　[color=%s]▼[/color]" % Kit.c("gold").to_html()
	_dlg_text.text = str(_dlg_lines[_dlg_i]) + hint
	if _dlg_face != null:
		var key := Kit.speaker_key(str(_dlg_raw[_dlg_i]))  # narration: no face
		_dlg_face.texture = null if key == "" else (Kit.portrait(key, 1.0, 2.4) if _cg_mode else Kit.portrait(key, 0.75, 5.0))
		_dlg_face.visible = _dlg_face.texture != null
	if last:
		if _dlg_recap:  # choosing: keep the whole setup in view next to the options
			_dialog_skip()
			return
		_dlg_buttons.visible = true
		_dlg_i = -1
		for b in _dlg_buttons.find_children("*", "Button", true, false):
			Kit.focus(b)
			break
	_update_tools()


func _dialog_skip() -> void:
	if _dlg_i < 0:
		return
	if _dlg_recap and _dlg_prompt != "":  # at a choice: the summary, not the scene again
		_dlg_text.text = _dlg_prompt
	elif _dlg_recap:  # no summary written: the last line (it usually poses the choice)
		_dlg_text.text = str(_dlg_lines[-1])
	else:
		_dlg_text.text = "\n".join(_dlg_lines) if _dlg_recap else "\n\n".join(_dlg_lines)
	_dlg_text.scroll_active = true
	_dlg_text.scroll_following = true  # land on the last lines — the ones that set up the choice
	_dlg_text.add_theme_font_size_override("normal_font_size", Kit.FONT_BODY)
	_dlg_text.add_theme_font_size_override("bold_font_size", Kit.FONT_BODY)
	_dlg_i = _dlg_lines.size() - 1
	_dlg_buttons.visible = true
	_dlg_i = -1
	_update_tools()


func _on_story_click(e: InputEvent) -> void:
	if not (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		return
	if _sheet_hidden:  # a click on the picture brings the text back
		_sheet_hidden = false
		_sheet.visible = true
		_update_tools()
		return
	if _dlg_i >= 0:
		_dlg_i += 1
		_dialog_show()


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_accept") and (_dlg_i >= 0 or _sheet_hidden):
		get_viewport().set_input_as_handled()
		_on_story_click(_fake_click())


func _fake_click() -> InputEventMouseButton:
	var ev := InputEventMouseButton.new()
	ev.pressed = true
	ev.button_index = MOUSE_BUTTON_LEFT
	return ev


func _hide_sheet() -> void:
	## Rance X style: hide the text box to look at the whole CG; any click brings it back
	_sheet_hidden = true
	_sheet.visible = false
	_update_tools()


func _update_tools() -> void:
	_dlg_tools.visible = not _sheet_hidden and (_dlg_i >= 0 or _cg_mode)
	_dlg_tools.get_child(0).visible = _dlg_i >= 0
	_dlg_tools.get_node("Hide").visible = _cg_mode


func _battle_info(s: Dictionary, fight: Dictionary) -> String:
	var db := GameData.get_db()
	var sc: Dictionary = db.scenarios[fight["battle"]]
	var e: Dictionary = db.enemies[sc["enemy"]]
	var tags := ""
	if s["boss"]:
		tags += "[color=%s][b]首领战[/b][/color]　" % Kit.c("purple").to_html()
	if s["lose_goto"] != "":
		tags += "[color=%s]打不赢也不会失败[/color]　" % Kit.c("green").to_html()
	elif s["elite"]:
		tags += "[color=%s][b]精英战[/b]（必掉宝箱，三选一）[/color]　" % Kit.c("red").to_html()
	if fight["ambush"]:
		tags += "[color=%s][b]埋伏！敌人先手[/b][/color]　" % Kit.c("red").to_html()
	return "%s敌军：[b]%s[/b]\n体力 %d　攻击 %d　每回合行动 %d 次%s\n招式：%s\n%d 回合内击破。任务中体力不会自动回满。" % [
		tags, e["name"], e["hp"], e["at"], e["actions"], _resists(e), _moves_text(e), sc["turn_limit"]]


func _resists(e: Dictionary) -> String:
	var r := ""
	if e["phys_resist"] > 0.0:
		r += "　物理抗性 %d%%" % int(round(e["phys_resist"] * 100))
	if e["magic_resist"] > 0.0:
		r += "　法术抗性 %d%%" % int(round(e["magic_resist"] * 100))
	return r


func _moves_text(e: Dictionary) -> String:
	## the enemy's moves with what makes them dangerous, so the player can plan (the wind-up itself is skipped)
	var parts: Array = []
	var charged: Array = e["moves"].filter(func(m): return m.has("charge")).map(func(m): return m["charge"])
	for m in e["moves"]:
		if m.has("charge"):
			continue
		var tags: Array = []
		if charged.has(m["name"]):
			tags.append("蓄力大招")
		if m.get("pierce", false):
			tags.append("无视防御")
		if m.has("confuse"):
			tags.append("混乱")
		if m.has("rage"):
			tags.append("狂暴" + ("·残血" if m.get("when", "") == "half" else ""))
		if m.has("heal"):
			tags.append("回复")
		if m.has("ap_drain"):
			tags.append("夺AP")
		if m.has("burn_party"):
			tags.append("火烧全军")
		parts.append(m["name"] + ("（%s）" % "·".join(tags) if not tags.is_empty() else ""))
	return " · ".join(parts)


func _fight_button(s: Dictionary, buttons: Control) -> void:
	var fight := Kit.button("⚔ 出战", "red", Kit.FONT_BIG)
	fight.pressed.connect(func(): Game.start_quest_battle(q, s))
	buttons.add_child(fight)
	Kit.focus(fight)


func _choose_event(i: int) -> void:
	var out := Quests.choose_event(q, Game.save, Game.rng, i)
	Game.persist()
	_refresh()
	for c in out["gained"]:
		_show_toast("获得：" + c["name"])
	if not Game.save.offer.is_empty():
		_open_offer(Quests.here(q, Game.save))


func _resolve(choice := -1) -> void:
	## resolve the square, then go straight on (no replay of what was just read)
	var kind: String = Quests.here(q, Game.save)["type"]
	var gained := Quests.resolve(q, Game.save, Game.rng, choice)
	Game.persist()
	for c in gained:
		_show_toast("获得：" + c["name"])
	if kind == "mystery" or not Game.save.offer.is_empty():  # an event's outcome / a pick still to make: show it first
		_refresh()
		return
	_advance()


func _advance() -> void:
	## one way on: walk there; several: back to the map to choose; none: the chapter's end panel
	var opts := Quests.next_options(q, Game.save)
	if opts.size() == 1:
		_on_square(opts[0]["id"])
		return
	if opts.size() > 1:
		_cg_mode = false
	_refresh()


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
	o.title = {"treasure": "宝箱 —— 选一张兵卡", "recruit": "豪杰来投 —— 选一位"}.get(s["type"], "选一张带走")
	o.card_ids = cards.map(func(c): return c["id"])
	o.counts = cards.map(func(c): return Game.save.copies(c["id"]) if c["soldier"] else 0)
	o.captions = cards.map(func(c): return _offer_caption(c))
	if Game.save.offer_kind == "upgrade":
		o.title = "仙人点化 —— 选一位武将升级"
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.picked.connect(func(i): o.queue_free(); _resolve(i))
	add_child(o)


func _apply_cg_mode() -> void:
	## CG mode: the illustration fills the screen, the map hides, the text box turns translucent over the picture
	_cg_view.visible = _cg_mode
	_cg_bar.visible = _cg_mode
	if not _cg_mode and _sheet_hidden:
		_sheet_hidden = false
		_sheet.visible = true
	_scroll.visible = not _cg_mode
	_cg_tab.text = "查看地图" if _cg_mode else "查看 CG"
	# a CG gets the screen: the text box shrinks to a subtitle strip at the bottom
	_sheet.position = Vector2(24, 552) if _cg_mode else Vector2(24, 448)
	_sheet.size = Vector2(1232, 156) if _cg_mode else Vector2(1232, 258)
	_dlg_tools.position = Vector2(1040, _sheet.position.y + 8)
	var bg := Kit.c("card")
	if _cg_mode:
		bg.a = 0.86
	_sheet.add_theme_stylebox_override("panel", Kit.box(bg, 14, 2, Kit.c("gold") if _cg_mode else Kit.c("border"), 14))


func _open_party() -> void:
	if get_node_or_null("Party") != null:
		return
	var o := PartyOverlay.new()
	o.name = "Party"
	o.closed.connect(func(): _refresh())
	add_child(o)


func _open_relics() -> void:
	if get_node_or_null("RelicPick") != null:
		return
	var o := RelicPick.new()
	o.name = "RelicPick"
	o.title = "战利品 —— 选一件宝物（本轮有效）"
	o.relic_ids = Game.save.offer.duplicate()
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.picked.connect(func(i):
		var got := Quests.take_relic(Game.save, o.relic_ids[i])
		Game.persist()
		o.queue_free()
		_refresh()
		_show_toast("获得：" + got["name"]))
	add_child(o)


func _offer_caption(c: Dictionary) -> String:
	## what taking this card does to your collection
	var save := Game.save
	var tiers: Array = GameData.get_db().gacha["tiers"]
	if c["soldier"]:
		return ""
	var have := save.copies(c["id"])
	if save.offer_kind == "upgrade":
		return "%s → %s" % [tiers[save.tier(c["id"])]["name"], tiers[mini(save.tier(c["id"]) + 1, tiers.size() - 1)]["name"]]
	if have == 0:
		return "新武将"
	var after := save.tier(c["id"], have + 1)
	if after > save.tier(c["id"]):
		return "已有 %d 张 · 升%s！" % [have, tiers[after]["name"]]
	return "已有 %d 张 · 再 %d 张升%s" % [have, int(tiers[after + 1]["copies"]) - have - 1, tiers[after + 1]["name"]]


func _complete() -> void:
	## the chapter recap first, then on to the next chapter
	if get_node_or_null("Recap") != null:
		return
	var db := GameData.get_db()
	var r := Quests.recap(Game.save)
	var earned := Quests.pay_merit(q, Game.save)
	Game.persist()
	var panel := PanelContainer.new()
	panel.name = "Recap"
	panel.z_index = 60
	panel.position = Vector2(190, 60)
	panel.size = Vector2(900, 600)
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 18, 3, Kit.c("gold"), 28))
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)
	var title := Kit.label("「%s」回顾" % q["title"], Kit.FONT_BIG + 6, "gold")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.scroll_active = true
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("normal_font_size", Kit.FONT_BODY)
	text.add_theme_font_size_override("bold_font_size", Kit.FONT_BODY)
	text.add_theme_color_override("default_color", Kit.c("text"))
	col.add_child(text)
	var gold := Kit.c("gold").to_html()
	var lines: Array = ["[color=%s][b]战斗[/b][/color]　打赢了 %d 场" % [gold, r["battles"]]]
	var cards: Array = r["cards"].map(func(c): return db.cards[c[0]]["name"] + ("×%d" % c[1] if c[1] > 1 else ""))
	lines.append("[color=%s][b]新得卡牌[/b][/color]　%s" % [gold, "、".join(cards) if not cards.is_empty() else "无"])
	var relics: Array = r["relics"].map(func(x): return db.relics[x]["name"])
	lines.append("[color=%s][b]宝物[/b][/color]　%s" % [gold, "、".join(relics) if not relics.is_empty() else "无"])
	lines.append("[color=%s][b]关键选择[/b][/color]" % gold)
	for rec in r["records"]:
		lines.append("　· " + rec)
	if r["records"].is_empty():
		lines.append("　· （一路平安，无事发生）")
	var hard: Array = []
	if r["danger"] > 0:
		hard.append("险 +%d%%" % int(round(r["danger"] * float(db.battle["danger_step"]) * 100)))
	if r["difficulty"] > 0:
		hard.append("难度 +%d%%（永久）" % int(round(r["difficulty"] * float(db.battle["difficulty_step"]) * 100)))
	if not hard.is_empty():
		lines.append("[color=%s][b]难度[/b][/color]　%s" % [gold, "　".join(hard)])
	lines.append("[color=%s][b]战功[/b][/color]　本章 +%d（打赢一场 +%d，首领和精英再 +%d）" % [gold, Quests.merit_earned(Game.save),
		int(db.gacha["merit"]["per_battle"]), int(db.gacha["merit"]["per_boss"])])
	if Game.save.replay != "":
		lines.append("\n这是重玩：卡牌和战功保留，打完回到主线原来的进度。")
	else:
		lines.append("\n宝物、卡牌、战功、难度和你的选择都会带到下一章。")
	text.text = "\n".join(lines)
	var spend := HBoxContainer.new()
	spend.alignment = BoxContainer.ALIGNMENT_CENTER
	spend.add_theme_constant_override("separation", 16)
	col.add_child(spend)
	var have := Kit.label("", Kit.FONT_BIG, "gold")
	spend.add_child(have)
	var draw := Kit.button("抽一次卡（%d 战功）" % int(db.gacha["merit"]["draw"]), "blue")
	var up := Kit.button("点化一位武将（%d 战功）" % int(db.gacha["merit"]["upgrade"]), "purple")
	spend.add_child(draw)
	spend.add_child(up)
	var refresh_spend := func():
		var s := Game.save
		have.text = "战功 %d" % s.merit
		draw.disabled = s.merit < int(db.gacha["merit"]["draw"]) or s.pool_left() == 0
		up.disabled = s.merit < int(db.gacha["merit"]["upgrade"]) or not s.owned.any(func(c): return not s.maxed(c))
	refresh_spend.call()
	draw.pressed.connect(func():
		if not Quests.spend_merit(Game.save, "draw"):
			return
		var drawn := Game.save.recruit_offer(Game.rng)
		Game.persist()
		_pick_then(drawn.map(func(c): return c["id"]), "用战功招募 —— 选一位", "draw", refresh_spend))
	up.pressed.connect(func():
		if not Quests.spend_merit(Game.save, "upgrade"):
			return
		var mine: Array = Game.save.owned.filter(func(c): return not Game.save.maxed(c))
		mine.shuffle()
		Game.persist()
		_pick_then(mine.slice(0, 3), "用战功点化 —— 选一位武将升级", "upgrade", refresh_spend))
	var go := Kit.button("进入下一章 ▶", "green", Kit.FONT_BIG)
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	go.custom_minimum_size = Vector2(320, 60)
	go.pressed.connect(func():
		panel.queue_free()
		_finish_chapter())
	col.add_child(go)
	Kit.focus(go)


func _pick_then(ids: Array, title: String, kind: String, after: Callable) -> void:
	## a pick-one over the recap: "draw" takes the card, "upgrade" raises its tier
	var tiers: Array = GameData.get_db().gacha["tiers"]
	var o := PickOverlay.new()
	o.title = title
	o.card_ids = ids
	if kind == "upgrade":
		o.captions = ids.map(func(c): return "%s → %s" % [tiers[Game.save.tier(c)]["name"],
			tiers[mini(Game.save.tier(c) + 1, tiers.size() - 1)]["name"]])
	else:
		o.captions = ids.map(func(c): return _offer_caption(GameData.get_db().cards[c]))
	o.z_index = 70
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.picked.connect(func(i):
		var cid: String = ids[i]
		if kind == "upgrade":
			Game.save.upgrade(cid)
			_show_toast("%s 升为%s卡！" % [GameData.get_db().cards[cid]["name"], tiers[Game.save.tier(cid)]["name"]])
		else:
			Game.save.take(cid)
			_show_toast("获得：" + GameData.get_db().cards[cid]["name"])
		Game.persist()
		o.queue_free()
		after.call())
	add_child(o)


func _finish_chapter() -> void:
	## flags saved, then the interlude and the next chapter's title card, then the next chapter's map
	var done_id: String = q.get("_raw", q)["id"]
	var was_replay: bool = Game.save.replay != ""
	Quests.complete(q, Game.save)
	Game.persist()
	if was_replay:
		_show_toast("重玩完成，回到主线")
		_rebuild_map()
		_refresh()
		return
	var nxt: Variant = Quests.current_quest(Game.save)
	var o := InterludeOverlay.new()
	o.scenes = Quests.interlude(done_id, Game.save)
	o.next_title = nxt["title"] if nxt != null else ""
	o.next_subtitle = nxt.get("subtitle", "") if nxt != null else ""
	o.ending = q.get("_raw", q).get("ending", {})
	if o.ending.is_empty():
		o.finished.connect(_after_interlude)
	else:  # an ending: back to the title screen, where a new 周目 can start
		o.finished.connect(func(): Game.show_screen(TitleScreen.new()))
	add_child(o)


func _after_interlude() -> void:
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
