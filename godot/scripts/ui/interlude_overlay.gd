class_name InterludeOverlay
extends Control
## Between chapters: the interlude scenes (portraits + text, one page each), then a title card for the next chapter.

signal finished

var scenes: Array = []
var next_title := ""  # "" when there is no next chapter yet
var next_subtitle := ""  # time and place under the title (「半年后」)
var _page := -1
var _line := 0  # lines of the current scene shown so far
var _scene_lines: Array = []
var _scene_text: RichTextLabel
var _box: Control


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
			_next())
	_next()


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_accept"):
		_next()


func _next() -> void:
	if _scene_text != null and _line < _scene_lines.size() - 1:  # next line of the same scene
		_line += 1
		_show_line()
		return
	_scene_text = null
	_page += 1
	if _box != null:
		_box.queue_free()
	if _page < scenes.size():
		_show_scene(scenes[_page])
	elif _page == scenes.size():
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
	if art != null:  # full-screen illustration, text over a dark band at the bottom
		var pic := TextureRect.new()
		pic.texture = art
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		pic.size = size
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_box.add_child(pic)
		var band := ColorRect.new()
		band.color = Color(0, 0, 0, 0.62)
		band.position = Vector2(0, 400)
		band.size = Vector2(1280, 320)
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		_box.add_child(tr)
		x += 230
	var title := Kit.label(sc.get("title", ""), Kit.FONT_BIG + 8, "gold")
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
	var lord := "[color=#e06c5a][b]%s[/b][/color]" % Game.save.lord_name
	_scene_lines = sc.get("text", []).map(func(t): return t.replace("{lord}", lord))
	_scene_text = text
	_line = 0
	text.add_theme_font_size_override("normal_font_size", Kit.FONT_BODY + 6)
	text.add_theme_font_size_override("bold_font_size", Kit.FONT_BODY + 6)
	_box.add_child(text)
	_show_line()
	var hint := Kit.label("点击继续 ▶", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.position = Vector2(1100, 680)
	_box.add_child(hint)
	_box.modulate.a = 0.0
	_box.create_tween().tween_property(_box, "modulate:a", 1.0, 0.35)


func _show_line() -> void:
	if _scene_lines.is_empty():
		return
	var more := _line < _scene_lines.size() - 1
	_scene_text.text = str(_scene_lines[_line]) + ("　[color=#d9a441]▼[/color]" if more else "")


func _show_title() -> void:
	## the next chapter's title card: its name in big gold characters
	_box = Control.new()
	_box.size = size
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)
	var t := Kit.label(next_title if next_title != "" else "未完待续", 72, "gold")
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
