class_name InterludeOverlay
extends Control
## Between chapters: the interlude scenes (portraits + text, one page each), then a title card for the next chapter.

signal finished

var scenes: Array = []
var next_title := ""  # "" when there is no next chapter yet
var ending: Dictionary = {}  # {title, text}: an ending card instead of the next chapter's title
var same_chapter := false  # the next map is the same 第N章 (a route that goes on): no title card
var next_subtitle := ""  # time and place under the title (「半年后」)
var _page := -1
var _line := 0  # lines of the current scene shown so far
var _scene_lines: Array = []
var _scene_text: RichTextLabel
var _scene_cg := ""  # the scene's CG ("" = none): its entrance lines wait for the speaker's first line
var _box: Control
# the same reading tools as the map's story box (跳过 / 隐藏 / 记录), a name plate, and the speaker lit up among the portraits
var _tools: HBoxContainer
var _menu_btn: Button
var _scene_keys: Array = []  # Kit.speakers of the current scene, one per line
var _pics: Dictionary = {}  # portrait key -> its TextureRect (scenes without a CG)
var _name_lbl: Label
var _hidden := false  # 隐藏: only the CG shows; any tap brings the text back
var _log: Control  # 记录 open: the lines read so far


func _ready() -> void:
	z_index = 80
	size = Vector2(1280, 720)
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.07, 0.06, 1.0)
	bg.size = size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE  # clicks go to the overlay, which turns the page
	add_child(bg)
	gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_tap())
	var menu_btn := Kit.button("设置", "gray")  # the pause menu reaches over a CG too (user rule), same place as on the map
	menu_btn.position = Vector2(1180, 14)
	menu_btn.z_index = 1  # above the scene pages added later
	menu_btn.focus_mode = Control.FOCUS_NONE
	menu_btn.pressed.connect(_open_settings)
	add_child(menu_btn)
	_menu_btn = menu_btn
	_tools = HBoxContainer.new()
	_tools.add_theme_constant_override("separation", 8)
	_tools.z_index = 1
	add_child(_tools)
	for spec in [["跳过", "Skip", _skip_scene], ["隐藏", "Hide", _hide_text], ["记录", "Log", _toggle_log]]:
		var b := Kit.tool_button(spec[0])
		b.name = spec[1]
		b.pressed.connect(spec[2])
		_tools.add_child(b)
	_tools.visible = false
	_next()


func _open_settings() -> void:
	if get_node_or_null("Settings") != null:
		return
	var o := SettingsOverlay.new()
	o.name = "Settings"
	add_child(o)


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_accept") and get_node_or_null("Settings") == null:
		_tap()


func _tap() -> void:
	## a tap on the page: closes 记录 / brings back a hidden text first, else turns to the next line
	if is_instance_valid(_log):
		_toggle_log()
	elif _hidden:
		_set_hidden(false)
	else:
		_next()


func _skip_scene() -> void:
	## 跳过: the rest of this scene at once, on to the next one (or the title card)
	if _scene_text == null:
		return
	if is_instance_valid(_log):
		_toggle_log()
	_line = _scene_lines.size() - 1
	_next()


func _hide_text() -> void:
	_set_hidden(true)


func _set_hidden(on: bool) -> void:
	## 隐藏 (CG scenes): only the picture; the band, the text, the plate and the tools go until the next tap
	_hidden = on
	if _box != null:
		for n in _box.get_children():
			if n.has_meta("text_layer"):
				n.visible = not on
	_menu_btn.visible = not on
	_update_tools()


func _toggle_log() -> void:
	## 记录: this scene's lines read so far, the speakers named, narration dimmed; a tap (or 记录 again) closes it
	if is_instance_valid(_log):
		_log.queue_free()
		_log = null
		_update_tools()
		return
	if _scene_text == null:
		return
	_log = PanelContainer.new()
	_log.add_theme_stylebox_override("panel", Kit.box(Color(0.06, 0.05, 0.04, 0.94), 14, 2, Kit.c("gold"), 18))
	_log.position = Vector2(60, 80)
	_log.size = Vector2(1160, 600)
	_log.z_index = 2
	_log.mouse_filter = Control.MOUSE_FILTER_IGNORE  # taps reach the overlay, which closes it
	add_child(_log)
	var txt := RichTextLabel.new()
	txt.bbcode_enabled = true
	txt.scroll_active = true
	txt.scroll_following = true
	txt.mouse_filter = Control.MOUSE_FILTER_PASS
	txt.add_theme_font_size_override("normal_font_size", Kit.FONT_BODY)
	txt.add_theme_font_size_override("bold_font_size", Kit.FONT_BODY)
	txt.add_theme_color_override("default_color", Color(0.95, 0.92, 0.85))
	var dim := Kit.c("dim").lightened(0.2).to_html()
	var out: Array = []
	for i in mini(_line + 1, _scene_lines.size()):
		var key: String = str(_scene_keys[i]) if i < _scene_keys.size() else ""
		out.append(Kit.named_line(str(_scene_lines[i]), key, Game.save.lord_name) if key != "" else "[color=%s]%s[/color]" % [dim, _scene_lines[i]])
	txt.text = "\n\n".join(out)
	_log.add_child(txt)
	_update_tools()


func _update_tools() -> void:
	var reading := _scene_text != null and not _hidden
	_tools.visible = reading
	_tools.get_node("Hide").visible = _box != null and _box.has_meta("cg") and not is_instance_valid(_log)
	_tools.get_node("Skip").visible = not is_instance_valid(_log)
	(_tools.get_node("Log") as Button).text = "返回" if is_instance_valid(_log) else "记录"
	_tools.reset_size()
	_tools.position = Vector2(1168 - _tools.get_combined_minimum_size().x, 26)


func _next() -> void:
	if _scene_text != null and _line < _scene_lines.size() - 1:  # next line of the same scene
		_line += 1
		_show_line()
		return
	_scene_text = null
	_page += 1
	if _box != null:
		_box.queue_free()
		_box = null
	_hidden = false
	_menu_btn.visible = true
	_update_tools()
	if _page < scenes.size():
		_show_scene(scenes[_page])
	elif _page == scenes.size() and not same_chapter:
		_show_title()
	else:
		finished.emit()
		queue_free()


func _show_scene(sc: Dictionary) -> void:
	_box = Control.new()
	_box.size = size
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)
	var art := Kit.cg(sc.get("cg", ""))
	_pics = {}
	if art != null:  # full-screen illustration, text over a dark band at the bottom
		_box.set_meta("cg", true)
		var pic := TextureRect.new()
		pic.texture = art
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		pic.size = size
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_box.add_child(pic)
		Kit.ken_burns(pic)
		var band := ColorRect.new()
		band.color = Color(0, 0, 0, 0.62)
		band.position = Vector2(0, 400)
		band.size = Vector2(1280, 320)
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.set_meta("text_layer", true)
		_box.add_child(band)
	var x := 60.0 if art == null else 9999.0
	for key in (sc.get("portraits", []) if art == null else []):
		var tex := Kit.portrait(key, 0.75, 5.0)
		if tex == null:
			continue
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tr.position = Vector2(x, 120)
		tr.size = Vector2(210, 280)
		tr.pivot_offset = tr.size / 2
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_box.add_child(tr)
		_pics[key] = tr
		x += 230
	var title := Kit.title_label(sc.get("title", ""), Kit.FONT_BIG + 10, "gold")
	title.position = Vector2(60, 40)
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_box.add_child(title)
	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.fit_content = true
	text.position = Vector2(60, 420 if x > 60 else 130)
	text.size = Vector2(1160, 260)
	text.add_theme_font_size_override("normal_font_size", Kit.FONT_BODY + 2)
	text.add_theme_color_override("default_color", Color(0.95, 0.92, 0.85))
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.set_meta("text_layer", true)
	_name_lbl = Kit.title_label("", Kit.FONT_BODY + 2, "gold")  # who is speaking, just above the line
	_name_lbl.position = Vector2(60, text.position.y - 38)
	_name_lbl.add_theme_constant_override("outline_size", 6)
	_name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_lbl.set_meta("text_layer", true)
	_box.add_child(_name_lbl)
	_scene_keys = Kit.speakers(sc.get("text", []), sc.get("portraits", []))
	var lord := "[color=#e06c5a][b]%s[/b][/color]" % Game.save.lord_name
	_scene_lines = sc.get("text", []).map(func(t): return Kit.strip_tag(t).replace("{lord}", lord))
	_scene_text = text
	_line = 0
	_scene_cg = str(sc.get("cg", "")) if art != null else ""
	if _scene_cg != "":
		Sfx.cg_voice(_scene_cg, sc.get("text", []), Kit.speakers(sc.get("text", []), sc.get("portraits", [])))
	text.add_theme_font_size_override("normal_font_size", Kit.FONT_BODY + 6)
	text.add_theme_font_size_override("bold_font_size", Kit.FONT_BODY + 6)
	_box.add_child(text)
	_show_line()
	var hint := Kit.label("点击继续 ▶", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.position = Vector2(1100, 680)
	hint.set_meta("text_layer", true)
	_box.add_child(hint)
	_update_tools()
	_box.modulate.a = 0.0
	_box.create_tween().tween_property(_box, "modulate:a", 1.0, 0.35)


func _show_line() -> void:
	if _scene_lines.is_empty():
		return
	var more := _line < _scene_lines.size() - 1
	_scene_text.text = str(_scene_lines[_line]) + ("　[color=#d9a441]▼[/color]" if more else "")
	Sfx.cg_line(_scene_cg, _line)
	var key: String = str(_scene_keys[_line]) if _line < _scene_keys.size() else ""
	if key == "lord":
		key = str(Game.save.lord()["person"])
	_name_lbl.text = Kit.speaker_name(key, Game.save.lord_name)
	_light_speaker(key)


func _light_speaker(key: String) -> void:
	## portraits side by side (no CG): the one speaking at full light with a little hop, the others dimmed to 0.55;
	## narration (or someone not on the page) leaves them all softly lit
	if key.begins_with("lord") and not _pics.has(key) and _pics.has("lord"):  # the north lord's face key, cast as plain "lord"
		key = "lord"
	var talking := _pics.has(key)
	for k in _pics:
		var tr: TextureRect = _pics[k]
		var on: bool = k == key
		var to := Color.WHITE if on else (Color(0.55, 0.55, 0.55) if talking else Color(0.85, 0.85, 0.85))
		tr.create_tween().tween_property(tr, "modulate", to, 0.15)
		if on:
			var hop := tr.create_tween()
			hop.tween_property(tr, "position:y", 108.0, 0.09).set_trans(Tween.TRANS_SINE)
			hop.tween_property(tr, "position:y", 120.0, 0.14).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _show_title() -> void:
	## the next chapter's title card: its name in big gold characters
	_tools.visible = false
	_box = Control.new()
	_box.size = size
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)
	if not ending.is_empty():  # 结局: its name, a line under it, then back to the title screen
		var bg := ColorRect.new()
		bg.color = Color(0, 0, 0, 1)
		bg.size = size
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_box.add_child(bg)
		var art := Kit.cg(ending.get("cg", ""))  # the ending's own picture, dimmed under the words
		if art != null:
			var pic := TextureRect.new()
			pic.texture = art
			pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			pic.size = size
			pic.modulate = Color(0.55, 0.55, 0.55)
			pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_box.add_child(pic)
		var e := Kit.title_label(ending.get("title", ""), 68, "gold")
		e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		e.position = Vector2(0, 250)
		e.size = Vector2(1280, 110)
		_box.add_child(e)
		var line := Kit.label(ending.get("text", ""), Kit.FONT_BIG)
		line.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85, 0.85))
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.position = Vector2(140, 380)
		line.size = Vector2(1000, 100)
		_box.add_child(line)
		var back := Kit.label("点击回到标题（可以新的开始）", Kit.FONT_BODY)
		back.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
		back.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		back.position = Vector2(0, 520)
		back.size = Vector2(1280, 40)
		_box.add_child(back)
		_box.modulate.a = 0.0
		_box.create_tween().tween_property(_box, "modulate:a", 1.0, 1.6)
		return
	var t := Kit.title_label(next_title if next_title != "" else "未完待续", 76, "gold")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.position = Vector2(0, 280)
	t.size = Vector2(1280, 120)
	_box.add_child(t)
	if next_subtitle != "":
		var when := Kit.label(next_subtitle, Kit.FONT_BIG + 6)
		when.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))
		when.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		when.position = Vector2(0, 220)
		when.size = Vector2(1280, 50)
		_box.add_child(when)
	var sub := Kit.label("后续章节开发中" if next_title == "" else "点击开始", Kit.FONT_BODY)
	sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 420)
	sub.size = Vector2(1280, 40)
	_box.add_child(sub)
	_box.modulate.a = 0.0
	var tw := _box.create_tween()
	tw.tween_property(_box, "modulate:a", 1.0, 0.8)
