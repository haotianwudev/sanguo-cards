class_name SideStoryList
extends Control
## ？小故事 (like Rance's 整备 ？ events): short side stories, often nothing to do with the main plot, that open once their
## chapter is done (data/side_stories.json). Opened from 整备 and from the chapter recap; unread ones show as a big ？,
## read ones by their title (they can be read again). The first read in a 周目 pays a little (side_stories.json reward).

signal changed  # something was read: the opener refreshes (战功, the unread count)

var also := ""  # the chapter whose recap is showing (not in quests_cleared yet)
var _grid: GridContainer
var _note: Label


class SideButton extends Button:
	## the ？ button: its text carries the unread count; it pulses while any are unread and hides while there are none at all
	var also := ""
	var on_change: Callable
	var _tw: Tween

	func refresh() -> void:
		var all := Quests.side_stories(Game.save, also)
		visible = not all.is_empty()
		var n := all.filter(func(s): return not s["read"]).size()
		text = "？ 小故事" + (" (%d)" % n if n > 0 else "")
		if _tw != null:
			_tw.kill()
			_tw = null
		scale = Vector2.ONE
		if n > 0 and is_inside_tree():
			pivot_offset = size / 2
			_tw = create_tween().set_loops()
			_tw.tween_property(self, "scale", Vector2.ONE * 1.06, 0.6).set_trans(Tween.TRANS_SINE)
			_tw.tween_property(self, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE)

	func _ready() -> void:
		refresh()


static func button(pos: Vector2, on_change: Callable, also_quest := "") -> SideButton:
	var b := SideButton.new()
	b.also = also_quest
	b.on_change = on_change
	b.text = "？ 小故事"
	b.add_theme_font_size_override("font_size", Kit.FONT_BODY + 2)
	var base := Kit.c("gold")
	b.add_theme_stylebox_override("normal", Kit.box(base, 10, 0, Color.TRANSPARENT, 14))
	b.add_theme_stylebox_override("hover", Kit.box(base.lightened(0.12), 10, 0, Color.TRANSPARENT, 14))
	b.add_theme_stylebox_override("pressed", Kit.box(base.darkened(0.15), 10, 0, Color.TRANSPARENT, 14))
	for st in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(st, Color(0.1, 0.07, 0.04))
	b.custom_minimum_size = Vector2(140, 46)
	b.position = pos
	b.pressed.connect(func():
		var o := SideStoryList.new()
		o.also = b.also
		o.changed.connect(func():
			b.refresh()
			if b.on_change.is_valid():
				b.on_change.call())
		b.get_tree().root.add_child(o))
	return b


func _ready() -> void:
	z_index = 85  # above 整备 (60) and the recap (60)
	size = Vector2(1280, 720)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.04, 0.03, 0.94)
	bg.size = size
	add_child(bg)
	var title := Kit.label("？ 小故事", Kit.FONT_BIG + 8, "gold")
	title.position = Vector2(40, 22)
	add_child(title)
	var hint := Kit.label("各章打完以后的小插曲，和主线不一定有关。第一次看有一点战功。", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	hint.position = Vector2(250, 34)
	add_child(hint)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, 96)
	scroll.size = Vector2(1200, 530)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 16)
	scroll.add_child(_grid)
	_note = Kit.label("", Kit.FONT_BODY, "amber")
	_note.position = Vector2(40, 650)
	add_child(_note)
	var close := Kit.button("返回", "green", Kit.FONT_BODY + 2)
	close.position = Vector2(1060, 644)
	close.custom_minimum_size = Vector2(180, 56)
	close.pressed.connect(queue_free)
	add_child(close)
	Kit.focus(close)
	_fill()


func _fill() -> void:
	for ch in _grid.get_children():
		ch.queue_free()
	var db := GameData.get_db()
	var titles := {}
	for q in db.quests:
		titles[q["id"]] = str(q["title"]).split(" · ")[0]
	for st in Quests.side_stories(Game.save, also):
		var tile := Button.new()
		tile.custom_minimum_size = Vector2(286, 128)
		var unread: bool = not st["read"]
		var edge := Kit.c("gold") if unread else Kit.c("border")
		tile.add_theme_stylebox_override("normal", Kit.box(Kit.c("panel"), 12, 3 if unread else 2, edge, 10))
		tile.add_theme_stylebox_override("hover", Kit.box(Kit.c("panel").lightened(0.08), 12, 3, Kit.c("gold"), 10))
		tile.add_theme_stylebox_override("pressed", Kit.box(Kit.c("panel").darkened(0.1), 12, 3, Kit.c("gold"), 10))
		var col := VBoxContainer.new()
		col.set_anchors_preset(Control.PRESET_FULL_RECT)
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(col)
		var big := Kit.label("？" if unread else str(st["title"]), (Kit.FONT_BIG + 22) if unread else (Kit.FONT_BODY + 4), "gold" if unread else "text")
		big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		big.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(big)
		var sub := Kit.label(titles.get(st["quest"], "") + ("　· 新" if unread else "　· 已读"), Kit.FONT_BODY - 2)
		sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(sub)
		tile.pressed.connect(_play.bind(st))
		_grid.add_child(tile)


func _play(st: Dictionary) -> void:
	var o := InterludeOverlay.new()
	o.scenes = [st]
	o.same_chapter = true  # no chapter title card afterwards
	o.z_index = 90
	o.finished.connect(func():
		var got := Quests.read_side(Game.save, st["id"])
		Game.persist()
		_note.text = "「%s」%s" % [st["title"], "：" + got if got != "" else "读完了"]
		_fill()
		changed.emit())
	add_child(o)
