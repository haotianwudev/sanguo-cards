class_name InterludeOverlay
extends Control
## Between chapters: the interlude scenes (portraits + text, one page each), then a title card for the next chapter.

signal finished

var scenes: Array = []
var next_title := ""  # "" when there is no next chapter yet
var _page := -1
var _box: Control


func _ready() -> void:
	z_index = 80
	size = Vector2(1280, 720)
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.07, 0.06, 1.0)
	bg.size = size
	add_child(bg)
	gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_next())
	_next()


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_accept"):
		_next()


func _next() -> void:
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
	var x := 60.0
	for key in sc.get("portraits", []):
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
	text.text = "\n".join(sc.get("text", []).map(func(t): return t.replace("{lord}", lord)))
	_box.add_child(text)
	var hint := Kit.label("点击继续 ▶", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.position = Vector2(1100, 680)
	_box.add_child(hint)
	_box.modulate.a = 0.0
	_box.create_tween().tween_property(_box, "modulate:a", 1.0, 0.35)


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
	var sub := Kit.label("后续章节开发中" if next_title == "" else "点击开始", Kit.FONT_BODY)
	sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 420)
	sub.size = Vector2(1280, 40)
	_box.add_child(sub)
	_box.modulate.a = 0.0
	var tw := _box.create_tween()
	tw.tween_property(_box, "modulate:a", 1.0, 0.8)
