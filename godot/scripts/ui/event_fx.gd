class_name EventFx
extends Control
## The outcome of a ？ event, animated: every change `Quests._apply` lists in `out["fx"]` (体力, 难度, 险, 战功, 天命, 升阶 / 降阶,
## 失去兵卡 / 宝物, 埋伏, 技能重置 / 休整) gets a card of its own that pops in one after another and plays its own little
## animation (numbers counting, the 天命 flipping, a card cracking …). Cards and 宝物 gained keep their own reveals
## (CardReveal / RelicReveal). Tap to go on. Emits closed.

signal closed

var fx: Array = []
var _ready_to_close := false
var _row: HBoxContainer

const GOOD := "gold"
const BAD := "red"
const CELL := Vector2(232, 318)


static func merged(list: Array) -> Array:
	## several 失去兵卡 of one event become one card; what shows nothing (an empty heal) is dropped already by Quests
	var out: Array = []
	var lost: Array = []
	for f in list:
		if f["k"] == "lose_soldier":
			lost.append(f["card"])
		else:
			out.append(f)
	if not lost.is_empty():
		out.append({"k": "lose_soldier", "cards": lost})
	return out


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 66
	position = Vector2.ZERO
	size = Vector2(1280, 720)  # full screen (the map screen is not a container)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.size = size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var col := VBoxContainer.new()
	col.position = Vector2(20, 40)
	col.size = Vector2(1240, 640)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 22)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	var head := Kit.label("事件结果", Kit.FONT_TITLE, "gold")
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(head)
	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.add_theme_constant_override("separation", 20)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_row)
	var hint := Kit.label("点击继续", Kit.FONT_BODY)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)
	gui_input.connect(func(e):
		if _ready_to_close and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_close())
	_play()


func _unhandled_input(e: InputEvent) -> void:
	if _ready_to_close and e.is_action_pressed("ui_accept"):
		_close()


func _close() -> void:
	_ready_to_close = false
	closed.emit()
	queue_free()


# ---- one card per change ---------------------------------------------------------

func _cell(tone: String) -> Dictionary:
	var cell := PanelContainer.new()
	cell.custom_minimum_size = CELL
	cell.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 18, 5, Kit.c(tone), 16))
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.modulate.a = 0.0
	_row.add_child(cell)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(box)
	var holder := CenterContainer.new()
	holder.custom_minimum_size = Vector2(190, 170)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(holder)
	var title := Kit.label("", Kit.FONT_BIG, tone)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var detail := Kit.label("", Kit.FONT_BODY - 2)
	detail.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size = Vector2(200, 0)
	box.add_child(detail)
	return {"cell": cell, "holder": holder, "title": title, "detail": detail, "tone": tone}


func _glyph(text: String, tone: String, size := 92) -> Label:
	var g := Kit.label(text, size, tone)
	g.add_theme_stylebox_override("normal", Kit.box(Kit.c(tone).darkened(0.55), 80, 4, Kit.c(tone), 10))
	g.add_theme_color_override("font_color", Color.WHITE)
	g.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	g.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	g.custom_minimum_size = Vector2(150, 150)
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return g


func _picture(tex: Texture2D, side := 160.0) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.custom_minimum_size = Vector2(side, side)
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr


func _centre(c: Control) -> Vector2:
	return c.global_position - global_position + c.size / 2


func _rect(c: Control) -> Rect2:
	return Rect2(c.global_position - global_position, c.size)


func _pop(c: Control) -> void:
	c.pivot_offset = c.size / 2
	c.scale = Vector2(0.2, 0.2)
	var tw := c.create_tween()
	tw.tween_property(c, "modulate:a", 1.0, 0.06)
	tw.parallel().tween_property(c, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished


func _shake(c: Control, power := 10.0, secs := 0.35) -> void:
	var base := c.position
	var tw := c.create_tween()
	var steps := 7
	for i in steps:
		var k := power * (1.0 - float(i) / steps)
		tw.tween_property(c, "position", base + Vector2(randf_range(-k, k), randf_range(-k * 0.5, k * 0.5)), secs / steps)
	tw.tween_property(c, "position", base, 0.04)


func _count(l: Label, from: int, to: int, fmt: String, secs := 0.6) -> void:
	var tw := l.create_tween()
	tw.tween_method(func(v: float): l.text = fmt % int(round(v)), float(from), float(to), secs).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished


func _good_burst(c: Control, color := BattleFx.GOLD) -> void:
	BattleFx.ring(self, _centre(c), color, 30.0, 210.0, 0.5, 7)
	BattleFx.burst(self, _centre(c), color, 14, 40.0, 230.0, 6.0, 0.45)
	BattleFx.embers(self, _rect(c), color, 20, 90.0, true)


func _bad_hit(cell: Control, holder: Control) -> void:
	BattleFx.flash(self, Color(0.8, 0.05, 0.05, 0.35), 0.22)
	var cr := BattleFx.cracks(self, _rect(holder).grow(-30), BattleFx.BLOOD, 4)  # cracks stay drawn until freed: fade them out
	var tw := cr.create_tween()
	tw.tween_interval(0.35)
	tw.tween_property(cr, "modulate:a", 0.0, 0.35)
	tw.tween_callback(cr.queue_free)
	_shake(cell, 14.0)


func _play() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for f in merged(fx):
		await _one(f)
		await get_tree().create_timer(0.15).timeout
	_ready_to_close = true


func _one(f: Dictionary) -> void:
	var db := GameData.get_db()
	var tiers: Array = db.gacha["tiers"]
	match str(f["k"]):
		"hp":
			var n: int = f["n"]
			var c := _cell(GOOD if n > 0 else BAD)
			var num := Kit.label("0", 84, "green" if n > 0 else "red")
			num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			c["holder"].add_child(num)
			c["title"].text = "中毒" if f.get("poison", false) else ("体力回复" if n > 0 else "体力受损")
			c["detail"].text = "现在 %d / %d" % [f["left"], f["top"]]
			await _pop(c["cell"])
			if n > 0:
				BattleFx.heal_wave(self, _rect(c["holder"]))
			elif f.get("poison", false):
				BattleFx.poison_cloud(self, _rect(c["holder"]))
				_bad_hit(c["cell"], c["holder"])
			else:
				_bad_hit(c["cell"], c["holder"])
			await _count(num, 0, n, "%+d")
		"difficulty", "danger":
			var hard: bool = int(f["to"]) > int(f["from"])
			var c := _cell(BAD if hard else "green")
			var is_diff: bool = f["k"] == "difficulty"
			var g := _glyph("难" if is_diff else "险", c["tone"])
			c["holder"].add_child(g)
			c["title"].text = ("难度上升" if hard else "难度下降") if is_diff else ("险情加重" if hard else "险情缓解")
			c["detail"].text = ("今后所有敌人 %+d%%" if is_diff else "本章敌人 +%d%%") % int(f["pct"])
			await _pop(c["cell"])
			var arrow := Kit.label("▲" if hard else "▼", 64, c["tone"])
			arrow.position = _centre(g) + Vector2(60, -40) - Vector2(20, 40)
			arrow.z_index = 47
			add_child(arrow)
			var tw := arrow.create_tween()
			tw.tween_property(arrow, "position:y", arrow.position.y + (-50.0 if hard else 50.0), 0.5).set_trans(Tween.TRANS_QUAD)
			tw.parallel().tween_property(arrow, "modulate:a", 0.0, 0.5).set_delay(0.2)
			tw.tween_callback(arrow.queue_free)
			if hard:
				_bad_hit(c["cell"], c["holder"])
			else:
				_good_burst(c["cell"], BattleFx.GREEN)
			g.text = ("难 %d" if is_diff else "险 %d") % int(f["from"])
			g.add_theme_font_size_override("font_size", 52)
			await get_tree().create_timer(0.25).timeout
			var flip := g.create_tween()
			g.pivot_offset = g.size / 2
			flip.tween_property(g, "scale:y", 0.0, 0.12)
			flip.tween_callback(func(): g.text = ("难 %d" if is_diff else "险 %d") % int(f["to"]))
			flip.tween_property(g, "scale:y", 1.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			await flip.finished
		"merit":
			var n: int = f["n"]
			var c := _cell(GOOD if n > 0 else BAD)
			var g := _glyph("功", c["tone"])
			c["holder"].add_child(g)
			c["title"].text = "战功 %+d" % n
			c["detail"].text = "现有战功 %d" % int(f["total"])
			await _pop(c["cell"])
			if n > 0:
				_good_burst(c["cell"])
			else:
				_bad_hit(c["cell"], c["holder"])
			g.add_theme_font_size_override("font_size", 52)
			await _count(g, int(f["total"]) - n, int(f["total"]), "功 %d")
		"fate":
			var nf: Dictionary = db.fates[f["to"]]
			var rar := str(nf["rarity"])
			var tone: String = {"divine": GOOD, "bad": BAD, "curse": BAD, "rare": "purple"}.get(rar, "blue")
			var c := _cell(tone)
			var was: String = f.get("from", "")
			var tex_old: Texture2D = Kit.fate_icon(was) if was != "" else null
			var pic: Control = _picture(tex_old) if tex_old != null else _glyph(db.fates[was]["icon"] if db.fates.has(was) else "命", "gray")
			c["holder"].add_child(pic)
			c["title"].text = "天命变了"
			c["detail"].text = "「%s」" % db.fates[was]["name"] if db.fates.has(was) else "……"
			await _pop(c["cell"])
			await get_tree().create_timer(0.3).timeout
			pic.pivot_offset = pic.size / 2
			var tw := pic.create_tween()
			tw.tween_property(pic, "scale:x", 0.0, 0.16)
			await tw.finished
			var tex_new: Texture2D = Kit.fate_icon(f["to"])
			var neu: Control = _picture(tex_new) if tex_new != null else _glyph(nf["icon"], tone)
			pic.queue_free()
			c["holder"].add_child(neu)
			await get_tree().process_frame
			neu.pivot_offset = neu.size / 2
			neu.scale = Vector2(0.0, 1.0)
			var tw2 := neu.create_tween()
			tw2.tween_property(neu, "scale:x", 1.0, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			c["title"].text = "%s「%s」" % [{"divine": "天授", "bad": "凶", "curse": "险中求", "rare": "大吉"}.get(rar, "吉"), nf["name"]]
			c["detail"].text = nf["desc"]
			if rar == "divine":  # the big one: the whole screen lights up
				BattleFx.flash(self, Color(1.0, 0.9, 0.5, 0.7), 0.5)
				_good_burst(c["cell"])
				BattleFx.ring(self, _centre(c["cell"]), BattleFx.GOLD, 60.0, 520.0, 0.8, 10)
				BattleFx.embers(self, Rect2(Vector2.ZERO, size), BattleFx.GOLD, 60, 160.0, true)
			elif rar in ["bad", "curse"]:
				_bad_hit(c["cell"], c["holder"])
			else:
				_good_burst(c["cell"], BattleFx.VIOLET if rar == "rare" else BattleFx.STEEL)
			await tw2.finished
		"tier":
			var up: bool = int(f["to"]) > int(f["from"])
			var lv_drop: bool = f.has("lv_to") and int(f["lv_to"]) < int(f["lv_from"])  # 降级: levels lost, the tier may stay
			var c := _cell(GOOD if up else BAD)
			var v := CardView.make(f["card"], Vector2(96, 170))
			v.mouse_filter = Control.MOUSE_FILTER_IGNORE
			c["holder"].add_child(v)
			c["title"].text = "升　阶" if up else ("降　级" if lv_drop else "降　阶")
			c["detail"].text = "%s\n%s → %s" % [str(db.cards[f["card"]]["name"]), tiers[int(f["from"])]["name"], tiers[int(f["to"])]["name"]]
			if lv_drop:
				c["detail"].text = "%s
%d 级 → %d 级" % [str(db.cards[f["card"]]["name"]), int(f["lv_from"]), int(f["lv_to"])]
			await _pop(c["cell"])
			if up:
				_good_burst(c["cell"])
				var tw := v.create_tween()
				tw.tween_property(v, "modulate", Color(1.9, 1.7, 0.9), 0.1)
				tw.tween_property(v, "modulate", Color.WHITE, 0.45)
				await tw.finished
			else:
				_bad_hit(c["cell"], c["holder"])
				var tw := v.create_tween()
				tw.tween_property(v, "modulate", Color(1.6, 0.4, 0.4), 0.08)
				tw.tween_property(v, "modulate", Color(0.7, 0.7, 0.75), 0.5)
				await tw.finished
		"lose_soldier", "lose_relic":
			var c := _cell(BAD)
			var pic: Control
			if f["k"] == "lose_relic":
				var tex: Texture2D = Kit.relic_icon(f["id"])
				pic = _picture(tex, 140) if tex != null else _glyph(db.relics[f["id"]]["icon"], BAD)
				c["title"].text = "失去宝物"
				c["detail"].text = str(db.relics[f["id"]]["name"])
			else:
				var cards: Array = f["cards"]
				pic = CardView.make(cards[0], Vector2(96, 170))
				c["title"].text = "失去兵卡 ×%d" % cards.size()
				var names: Array = []
				for cid in cards:
					names.append(str(db.cards[cid]["name"]))
				c["detail"].text = "、".join(names)
			pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			c["holder"].add_child(pic)
			await _pop(c["cell"])
			_bad_hit(c["cell"], c["holder"])
			var tw := pic.create_tween()
			tw.tween_property(pic, "modulate", Color(1, 0.3, 0.3, 1), 0.1)
			tw.tween_property(pic, "modulate", Color(0.4, 0.4, 0.4, 0.35), 0.6)
			await tw.finished
		"ambush":
			var on: bool = f["on"]
			var c := _cell(BAD if on else "green")
			var g := _glyph("伏", c["tone"], 100)
			c["holder"].add_child(g)
			c["title"].text = "必被埋伏" if on else "不再被埋伏"
			c["detail"].text = "本章之后的战斗，敌人全都先手" if on else "斥候得力，本章之后的战斗不会被偷袭"
			await _pop(c["cell"])
			g.pivot_offset = g.size / 2
			if on:  # the seal stamps down
				g.scale = Vector2(2.6, 2.6)
				g.modulate.a = 0.0
				var tw := g.create_tween()
				tw.tween_property(g, "modulate:a", 1.0, 0.05)
				tw.parallel().tween_property(g, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				await tw.finished
				_bad_hit(c["cell"], c["holder"])
				BattleFx.slash(self, _centre(g), BattleFx.BLOOD, -35.0, 220.0, 10.0)
			else:  # the seal is struck out
				BattleFx.slash(self, _centre(g), BattleFx.STEEL, -35.0, 200.0, 10.0)
				var tw := g.create_tween()
				tw.tween_property(g, "modulate", Color(1, 1, 1, 0.35), 0.4)
				await tw.finished
				_good_burst(c["cell"], BattleFx.GREEN)
		"refresh", "rest":
			var c := _cell("green")
			var g := _glyph("技" if f["k"] == "refresh" else "休", "green")
			c["holder"].add_child(g)
			c["title"].text = "技能重置" if f["k"] == "refresh" else "休整完毕"
			c["detail"].text = "累积加价清零，限 1 次技能可以再用" if f["k"] == "refresh" else "体力全满，技能次数恢复"
			await _pop(c["cell"])
			BattleFx.heal_wave(self, _rect(c["holder"]))
			_good_burst(c["cell"], BattleFx.GREEN)
			await get_tree().create_timer(0.4).timeout
