class_name DefeatOverlay
extends Control
## 阵亡: the lord falls and the run fails — one still picture (defeat_south / defeat_north, built from pics/source/cg), the words 「阵　亡」,
## a click to go on. Shown by Game.battle_finished only when the run really ends (not for a story loss like 吕布's chase).

signal done

var cg_key := ""
var line := ""
var _ready_to_close := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var pic := TextureRect.new()
	pic.texture = Kit.cg(cg_key)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.set_anchors_preset(Control.PRESET_FULL_RECT)
	pic.modulate = Color(0.78, 0.74, 0.74, 0.0)  # a little desaturated, fades in from black
	add_child(pic)
	var title := Kit.label("阵　亡", 84, "red")
	title.add_theme_color_override("font_color", Color(0.93, 0.86, 0.8))
	title.add_theme_color_override("font_outline_color", Color(0.1, 0, 0, 0.9))
	title.add_theme_constant_override("outline_size", 14)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 470)
	title.size = Vector2(1280, 110)
	title.modulate.a = 0.0
	add_child(title)
	var sub := Kit.label(line, Kit.FONT_BIG, "muted")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 590)
	sub.size = Vector2(1280, 50)
	sub.modulate.a = 0.0
	add_child(sub)
	var hint := Kit.label("点击继续", Kit.FONT_BODY, "muted")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, 660)
	hint.size = Vector2(1280, 40)
	hint.modulate.a = 0.0
	add_child(hint)
	var tw := create_tween()
	tw.tween_property(pic, "modulate:a", 1.0, 0.9)
	tw.tween_property(title, "modulate:a", 1.0, 0.5)
	tw.tween_property(sub, "modulate:a", 1.0, 0.5)
	tw.tween_property(hint, "modulate:a", 0.8, 0.4)
	tw.tween_callback(func(): _ready_to_close = true)


func _gui_input(e: InputEvent) -> void:
	if _ready_to_close and ((e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed)):
		_close()


func _unhandled_input(e: InputEvent) -> void:
	if _ready_to_close and e.is_pressed() and (e is InputEventKey or e is InputEventJoypadButton):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	_ready_to_close = false
	done.emit()
	queue_free()
