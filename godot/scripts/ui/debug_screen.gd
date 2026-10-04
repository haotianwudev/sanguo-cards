class_name DebugScreen
extends Control
## QA / test tool, not for players: jump straight into any chapter (bypassing normal progress), browse every
## card or every story CG regardless of what the current save owns or has seen, or quit the app outright.
## Entry point: a small button on the title screen (debug exports only — see TitleScreen._ready()).

signal closed

var _view: Control

const _CHAPTER_JUMPS := [
	{"label": "第一章 · 南线（富春）", "cleared": [], "flags": []},
	{"label": "第一章 · 北线（冀州风云）", "cleared": [], "flags": ["出生：冀州无极"]},
	{"label": "第二章 · 南线（讨伐董卓）", "cleared": ["prologue"], "flags": []},
	{"label": "第二章 · 北线（洛阳烟云）", "cleared": ["prologue"], "flags": ["出生：冀州无极"]},
	{"label": "第三章 · 传国玉玺", "cleared": ["prologue", "taodong"], "flags": []},
	{"label": "第三章 · 驻守洛阳", "cleared": ["prologue", "taodong", "yuxi"],
		"flags": ["董白：留下", "结局一 · 玉碎", "路线：守洛阳"]},
	{"label": "第三章 · 长安", "cleared": ["prologue", "taodong", "yuxi", "shouluoyang"],
		"flags": ["董白：留下", "结局一 · 玉碎", "路线：守洛阳", "路线：长安"]},
	{"label": "第四章 · 挟天子", "cleared": ["prologue", "taodong", "yuxi", "shouluoyang", "changan"],
		"flags": ["董白：留下", "结局一 · 玉碎", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"]},
	{"label": "第五章 · 荆襄风云", "cleared": ["prologue", "taodong", "yuxi", "shouluoyang", "changan", "dongui"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓", "南阳：袁术东逃"]},
]


func _ready() -> void:
	z_index = 60
	size = Vector2(1280, 720)
	var bg := ColorRect.new()
	bg.color = Kit.c("bg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var title := Kit.label("测试工具（不给玩家看）", Kit.FONT_BIG + 2, "gold")
	title.position = Vector2(28, 14)
	add_child(title)
	var done := Kit.button("关闭", "gray", Kit.FONT_BODY)
	done.position = Vector2(1130, 10)
	done.custom_minimum_size = Vector2(130, 48)
	done.pressed.connect(func():
		closed.emit()
		queue_free())
	add_child(done)

	var tabs := HBoxContainer.new()
	tabs.position = Vector2(28, 64)
	tabs.add_theme_constant_override("separation", 10)
	add_child(tabs)
	for t in [["jump", "跳到某关"], ["cards", "查看所有卡牌"], ["cgs", "查看所有 CG"], ["quit", "退出游戏"]]:
		var b := Kit.button(t[1], "red" if t[0] == "quit" else "blue", Kit.FONT_BODY)
		b.custom_minimum_size = Vector2(0, 46)
		b.pressed.connect(_show.bind(t[0]))
		tabs.add_child(b)

	_show("jump")


func _show(which: String) -> void:
	if which == "quit":
		get_tree().quit()
		return
	if _view != null:
		_view.queue_free()
		_view = null
	match which:
		"jump":
			_view = _jump_panel()
		"cards":
			_view = _cards_panel()
		"cgs":
			_view = _cgs_panel()
	_view.position = Vector2(28, 122)
	add_child(_view)


func _jump_panel() -> Control:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 580)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	col.custom_minimum_size = Vector2(1200, 0)
	scroll.add_child(col)
	for jump in _CHAPTER_JUMPS:
		var b := Kit.button(jump["label"], "gold", Kit.FONT_BODY)
		b.custom_minimum_size = Vector2(0, 52)
		b.pressed.connect(_do_jump.bind(jump))
		col.add_child(b)
	var hint := Kit.label("直接跳章节：按最常见的那条线路设置 quests_cleared / flags，不保证覆盖每一条岔路（比如董白的另一种结局）。"
		+ "想测具体某一格，跳到章节后用地图上的格子走过去，或者命令行 --demo=cg_north/ln2 --at=<格子id> 更精确。", 14, "muted")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(1180, 0)
	col.add_child(hint)
	return scroll


func _do_jump(jump: Dictionary) -> void:
	Game.persist_enabled = false
	var save := SaveData.create()
	save.quests_cleared = jump["cleared"].duplicate()
	save.flags = jump["flags"].duplicate()
	Game.save = save
	Quests.ensure_started(save, Game.rng)
	Game.show_screen(MapScreen.new())


func _cards_panel() -> Control:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 580)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var grid := GridContainer.new()
	grid.columns = 9
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(grid)
	var db := GameData.get_db()
	var ids: Array = db.cards.keys()
	ids.sort()
	for cid in ids:
		if cid == "lord":
			continue
		var v := CardView.make(cid, Vector2(126, 176), {"skills": false})
		grid.add_child(v)
	return scroll


func _cgs_panel() -> Control:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1224, 580)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)
	var dir := DirAccess.open("res://data/art/cg")
	var keys: Array = []
	if dir != null:
		dir.list_dir_begin()
		var f := dir.get_next()
		while f != "":
			if f.ends_with(".jpg"):
				keys.append(f.trim_suffix(".jpg"))
			f = dir.get_next()
	keys.sort()
	for key in keys:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 2)
		var btn := TextureButton.new()
		btn.texture_normal = Kit.cg(key)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
		btn.custom_minimum_size = Vector2(228, 128)
		btn.pressed.connect(_preview_cg.bind(key))
		col.add_child(btn)
		var lbl := Kit.label(key, 13, "muted")
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(228, 0)
		col.add_child(lbl)
		grid.add_child(col)
	return scroll


func _preview_cg(key: String) -> void:
	var overlay := Control.new()
	overlay.z_index = 80
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := Button.new()
	dim.flat = true
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.add_theme_stylebox_override("normal", Kit.box(Color(0, 0, 0, 0.88), 0, 0, Color.TRANSPARENT, 0))
	dim.add_theme_stylebox_override("hover", Kit.box(Color(0, 0, 0, 0.88), 0, 0, Color.TRANSPARENT, 0))
	dim.add_theme_stylebox_override("pressed", Kit.box(Color(0, 0, 0, 0.88), 0, 0, Color.TRANSPARENT, 0))
	dim.pressed.connect(overlay.queue_free)
	overlay.add_child(dim)
	var pic := TextureRect.new()
	pic.texture = Kit.cg(key)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.set_anchors_preset(Control.PRESET_FULL_RECT)
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(pic)
	var lbl := Kit.label(key, Kit.FONT_BODY, "gold")
	lbl.position = Vector2(20, 14)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(lbl)
	add_child(overlay)
