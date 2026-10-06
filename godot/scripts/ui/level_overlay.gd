class_name LevelOverlay
extends Control
## 难度选择: shown right after the birthplace is chosen, because south and north count apart — each route offers difficulty 1 and one more
## level per ending of its own that has been reached (data/endings.json `level`). Choosing lower than the top is allowed, but the story an
## ending opens only runs at its level or above, so a lower choice meets the same badend again.

signal picked(level: int)

var route := "south"
var top := 1
var reached: Array = []  # ending ids this save has reached


func _ready() -> void:
	z_index = 75
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("panel"), 16, 2, Kit.c("border"), 24))
	panel.position = Vector2(250, 120)
	panel.size = Vector2(780, 0)
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	col.custom_minimum_size = Vector2(730, 0)
	panel.add_child(col)
	var t := Kit.label("选择难度（%s，最高 %d）" % ["北线" if route == "north" else "南线", top], Kit.FONT_BIG, "gold")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)
	var tip := Kit.label("每解锁这条线的一个新结局，可选的最高难度 +1。可以选低的，但选得比某个结局的等级低，它解锁的后续剧情就不会触发——会再走到同样的 badend。", 15, "muted")
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(tip)
	var db := GameData.get_db()
	var step := float(db.battle.get("ending_step", 0.0))
	for k in range(top, 0, -1):
		var opens: Array = []
		for id in reached:
			var e: Dictionary = db.endings[id]
			if e["route"] in [route, "both"] and int(e["level"]) <= k:
				opens.append(e["title"])
		var line := "敌人 +%d%%　%s" % [int(round((k - 1) * step * 100)),
			("开启：" + "、".join(opens) + " 解锁的剧情") if not opens.is_empty() else "不触发任何结局解锁的剧情"]
		var b := Kit.button("难度 %d" % k, "gold" if k == top else "blue", Kit.FONT_BIG)
		b.custom_minimum_size = Vector2(0, 56)
		b.pressed.connect(func():
			picked.emit(k)
			queue_free())
		col.add_child(b)
		var d := Kit.label(line, 14, "muted")
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(d)
		if k == top:
			Kit.focus(b)
