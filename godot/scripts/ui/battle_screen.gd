class_name BattleScreen
extends Control
## Rance X battle, landscape: enemy + its HP bar on top, the shared party HP / AP bar in the middle,
## a row of leader cards (each with its skills) at the bottom, actions on the right.
## The engine runs instantly; this screen replays its events as animations.

var scenario_id := "hulao"
var carry := false  # quest battle: start with the quest's wear, hand it back afterwards
var boss := false  # boss or elite: the chest always drops, with more cards
var ambush := false

var b: Battle
var _busy := false
const BAND_ALPHA := 0.5  # how much the dark band under our cards hides the battle CG
var _enemy_art: Control
var _enemy_hp: ProgressBar
var _enemy_hp_label: Label
var _enemy_status: Label
var _party_hp: ProgressBar
var _party_hp_label: Label
var _ap_row: HBoxContainer
var _round_label: Label
var _combo_label: Label
var _log: RichTextLabel
var _cards: Array = []  # CardView per leader
var _skill_buttons: Array = []  # [leader index, skill id, Button]
var _defend: Button
var _retreat: Button
var _end: Button
var _party_box: Control


func _ready() -> void:
	var save := Game.save
	if carry:
		var m := Quests.mods(save)
		var afx := Quests.affix_here(save)
		if not afx.is_empty():
			m["affix"] = afx
		b = Battle.start(scenario_id, save.party_leaders(), Game.rng.randi(), save.damage, save.carry_extra, save.carry_uses,
			ambush, m)
	else:
		b = Battle.start(scenario_id, save.party_leaders(), Game.rng.randi())
	_build()
	_log_lines(["[b]【%s】[/b] %d 回合内击破 %s。" % [b.scenario["name"], b.turn_limit, b.enemy["data"]["name"]]])
	if b.mods.has("affix"):
		_log_lines(["[color=red]【词缀·%s】%s[/color]" % [b.mods["affix"]["name"], b.mods["affix"]["desc"]]])
	_log_lines(b.opening)
	b.take_events()
	_refresh()
	if save.cleared.is_empty() and not carry or (carry and save.visited.size() <= 4):
		_tip("点队长卡下的技能出手 · AP 每回合 +%d（最多 %d）· 每位队长每回合行动一次 · 全军共用一条体力" % [
			int(GameData.get_db().battle["ap_per_round"]), b.ap_max()])


# ---- layout ------------------------------------------------------------------

func _build() -> void:
	var e: Dictionary = b.enemy["data"]
	# battle background: data/art/battle/<scenario id>.jpg (built by `sanguo-art` from pics/art.json "battles")
	var bg_path := "res://data/art/battle/%s.jpg" % scenario_id
	# Rance X style: with a battle CG the painting owns the top of the screen (it is the enemy: it shakes and
	# flashes when hit), the enemy's name and HP sit in a slim strip over it, and our side lives in a dark band below
	var has_cg := ResourceLoader.exists(bg_path)
	if has_cg:
		var bg := TextureRect.new()
		bg.texture = load(bg_path)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.position = Vector2(0, -20)
		bg.size = Vector2(1280, 740)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
		_enemy_art = bg
		var band_col := Kit.c("bg")
		var grad := Gradient.new()
		grad.set_color(0, Color(band_col, 0.0))
		grad.set_color(1, Color(band_col, BAND_ALPHA))
		var gt := GradientTexture2D.new()
		gt.gradient = grad
		gt.fill_from = Vector2(0, 0)
		gt.fill_to = Vector2(0, 1)
		var fade := TextureRect.new()  # the painting fades into the band where our cards are
		fade.texture = gt
		fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fade.stretch_mode = TextureRect.STRETCH_SCALE
		fade.position = Vector2(0, 300)
		fade.size = Vector2(1280, 90)
		fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fade)
		var band := ColorRect.new()
		band.color = Color(band_col, BAND_ALPHA)
		band.position = Vector2(0, 390)
		band.size = Vector2(1280, 330)
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(band)
	# enemy (top-left)
	var enemy_panel := PanelContainer.new()
	enemy_panel.position = Vector2(20, 14)
	enemy_panel.size = Vector2(880, 250) if not has_cg else Vector2(560, 0)
	var ebg := Kit.c("enemy_bg")
	if has_cg:
		ebg.a = 0.72
	enemy_panel.add_theme_stylebox_override("panel", Kit.box(ebg, 16, 3 if not has_cg else 2, Kit.c("enemy_border"), 14 if not has_cg else 10))
	add_child(enemy_panel)
	var er := HBoxContainer.new()
	er.add_theme_constant_override("separation", 22)
	enemy_panel.add_child(er)
	var key := Kit.enemy_portrait_key(e)
	var fr := Kit.frame("enemy")
	if has_cg:
		pass  # the CG is the enemy
	elif key != "" and not fr.is_empty():
		var holder := Control.new()  # portrait inside the enemy frame (iron by default, see ui.json)
		var sz := Vector2(160, 224)
		holder.custom_minimum_size = sz
		var r: Rect2 = fr["window"]
		var win := Rect2(r.position * sz, r.size * sz)
		var art := TextureRect.new()
		art.texture = Kit.portrait(key, win.size.x / win.size.y, 3.5)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.position = win.position
		art.size = win.size
		holder.add_child(art)
		var frame := TextureRect.new()
		frame.texture = fr["texture"]
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame.stretch_mode = TextureRect.STRETCH_SCALE
		frame.size = sz
		holder.add_child(frame)
		_enemy_art = holder
	elif key != "":
		var tr := TextureRect.new()
		tr.texture = Kit.portrait(key, 0.75, 3.5)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tr.custom_minimum_size = Vector2(165, 220)
		_enemy_art = tr
	else:
		var ph := Label.new()
		ph.text = e["name"].substr(0, 1)
		ph.add_theme_font_size_override("font_size", 110)
		ph.add_theme_color_override("font_color", Kit.c("enemy_border"))
		ph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ph.add_theme_stylebox_override("normal", Kit.box(Kit.c("card"), 12, 0, Color.TRANSPARENT, 0))
		ph.custom_minimum_size = Vector2(165, 220)
		_enemy_art = ph
	if not has_cg:
		er.add_child(_enemy_art)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", 10 if not has_cg else 4)
	er.add_child(info)
	if has_cg:  # one line: name and stats, then the bar
		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 14)
		top.add_child(Kit.label(e["name"], Kit.FONT_BIG, "red"))
		var st := Kit.label("攻击 %d · 每回合 %d 次" % [e["at"], e["actions"]], Kit.FONT_SMALL, "muted")
		st.size_flags_vertical = Control.SIZE_SHRINK_END
		top.add_child(st)
		info.add_child(top)
	else:
		info.add_child(Kit.label(e["name"], Kit.FONT_TITLE, "red"))
	_enemy_hp = Kit.bar(b.enemy["hp"], b.enemy["max_hp"], "red", 30 if not has_cg else 20)
	info.add_child(_enemy_hp)
	_enemy_hp_label = Kit.label("", Kit.FONT_BODY if not has_cg else Kit.FONT_SMALL)
	info.add_child(_enemy_hp_label)
	if not has_cg:
		info.add_child(Kit.label("攻击 %d · 每回合行动 %d 次" % [e["at"], e["actions"]], Kit.FONT_SMALL, "muted"))
	_enemy_status = Kit.label("", Kit.FONT_BODY if not has_cg else Kit.FONT_SMALL, "purple")
	info.add_child(_enemy_status)

	# log (top-right)
	var log_panel := PanelContainer.new()
	log_panel.position = Vector2(916, 14) if not has_cg else Vector2(950, 14)
	log_panel.size = Vector2(344, 250) if not has_cg else Vector2(310, 180)
	if has_cg:  # a small see-through log so the painting shows
		log_panel.add_theme_stylebox_override("panel", Kit.box(Color(0, 0, 0, 0.45), 10, 0, Color.TRANSPARENT, 8))
	add_child(log_panel)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.add_theme_font_size_override("normal_font_size", 16 if not has_cg else 14)
	_log.add_theme_font_size_override("bold_font_size", 16 if not has_cg else 14)
	log_panel.add_child(_log)

	# party bar
	_party_box = PanelContainer.new()
	_party_box.position = Vector2(20, 276) if not has_cg else Vector2(20, 390)
	_party_box.size = Vector2(1240, 70) if not has_cg else Vector2(1240, 48)
	var pbg := Kit.c("party_bg")
	if has_cg:
		pbg.a = 0.7
	_party_box.add_theme_stylebox_override("panel", Kit.box(pbg, 14, 2, Kit.c("green"), 12 if not has_cg else 7))
	add_child(_party_box)
	var pr := HBoxContainer.new()
	pr.add_theme_constant_override("separation", 18)
	_party_box.add_child(pr)
	pr.add_child(Kit.label("全军体力", Kit.FONT_BODY))
	_party_hp = Kit.bar(b.party_hp, b.party_max, "green", 26)
	_party_hp.custom_minimum_size = Vector2(420, 26)
	_party_hp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pr.add_child(_party_hp)
	_party_hp_label = Kit.label("", Kit.FONT_BODY)
	_party_hp_label.custom_minimum_size = Vector2(130, 0)
	pr.add_child(_party_hp_label)
	pr.add_child(Kit.label("AP", Kit.FONT_BODY, "gold"))
	_ap_row = HBoxContainer.new()
	_ap_row.add_theme_constant_override("separation", 6)
	pr.add_child(_ap_row)
	_round_label = Kit.label("", Kit.FONT_BODY)
	pr.add_child(_round_label)
	_combo_label = Kit.label("", Kit.FONT_BODY, "amber")
	pr.add_child(_combo_label)

	# leaders (bottom-left)
	var row := HBoxContainer.new()
	row.position = Vector2(20, 358) if not has_cg else Vector2(20, 448)
	row.add_theme_constant_override("separation", 16)
	add_child(row)
	# three skills under a card only fit if the cards shrink a little
	var most := 0
	for u in b.leaders:
		most = maxi(most, u["leader"]["card"]["skills"].size())
	var card_size := Vector2(180, 252) if most <= 2 else Vector2(150, 210)
	var btn_h := 44 if most <= 2 else 34
	if has_cg:  # the band is shorter: smaller cards
		card_size = Vector2(124, 174) if most <= 2 else Vector2(118, 150)
		btn_h = 26
	for i in b.leaders.size():
		var u: Dictionary = b.leaders[i]
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 6)
		row.add_child(col)
		var card_id: String = u["leader"]["card"]["id"]
		var v := CardView.make(card_id, card_size, {"leader": u["leader"], "skills": false,
			"lord_name": Game.save.lord_name})
		if has_cg:
			v.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.focus_mode = Control.FOCUS_NONE
		col.add_child(v)
		_cards.append(v)
		for sid in u["leader"]["card"]["skills"]:
			var btn := Kit.button("", "blue", Kit.FONT_SMALL if not has_cg else 14)
			btn.custom_minimum_size = Vector2(card_size.x, btn_h)
			if has_cg:  # slim buttons a bit wider than the small card, label cut rather than widening the column
				btn.custom_minimum_size = Vector2(card_size.x + 32, btn_h)
				btn.clip_text = true
				btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
				var base := Kit.c("blue")
				for st in ["normal", "hover", "pressed", "disabled", "focus"]:
					var bgc := base.lightened(0.12) if st == "hover" else (base.darkened(0.15) if st == "pressed" else base)
					if st == "disabled":
						bgc = Color(base.darkened(0.45), 0.8)
					btn.add_theme_stylebox_override(st, Kit.box(bgc, 8, 2 if st == "focus" else 0, Kit.c("gold"), 3))
			btn.pressed.connect(_on_skill.bind(i, sid))
			col.add_child(btn)
			_skill_buttons.append([i, sid, btn])

	# actions (bottom-right)
	var acts := VBoxContainer.new()
	acts.position = Vector2(1010, 380) if not has_cg else Vector2(1040, 456)
	acts.size = Vector2(250, 320) if not has_cg else Vector2(220, 220)
	acts.add_theme_constant_override("separation", 14 if not has_cg else 10)
	add_child(acts)
	_end = Kit.button("回合结束", "red", Kit.FONT_BIG)
	_end.custom_minimum_size = Vector2(250, 70) if not has_cg else Vector2(220, 60)
	_end.pressed.connect(_on_end_round)
	acts.add_child(_end)
	_defend = Kit.button("防御", "blue", Kit.FONT_BIG)
	_defend.custom_minimum_size = Vector2(250, 62) if not has_cg else Vector2(220, 52)
	_defend.pressed.connect(_on_defend)
	acts.add_child(_defend)
	_retreat = Kit.button("撤退", "gray", Kit.FONT_BODY)
	var retreat := _retreat
	retreat.pressed.connect(_on_retreat)
	acts.add_child(retreat)


func _refresh() -> void:
	var e := b.enemy
	_enemy_hp_label.text = "%d / %d" % [e["hp"], e["max_hp"]]
	var st: Array = []
	if e["stunned"]:
		st.append("混乱：下回合无法行动")
	if e["break_turns"] > 0:
		st.append("破防 +%d%%（%d 回合）" % [int(round(e["break_amount"] * 100)), e["break_turns"]])
	if e["burn_turns"] > 0:
		st.append("🔥 着火 -%d/回合（%d 回合）" % [e["burn_dmg"], e["burn_turns"]])
	if e["charging"] != "":
		st.append("⚠ 蓄力中：下回合【%s】！" % e["charging"])
	if e["at"] > e["data"]["at"] * 1.01:
		st.append("狂暴 攻击 %d" % int(round(e["at"])))
	if b.party_burn["turns"] > 0:
		st.append("我军着火 -%d（%d 回合）" % [b.party_burn["dmg"], b.party_burn["turns"]])
	if b.ap_drain > 0:
		st.append("下回合 AP -%d" % b.ap_drain)
	_enemy_status.text = "　".join(st)
	_enemy_status.visible = not st.is_empty()  # no empty line under the enemy bar
	_party_hp_label.text = "%d / %d" % [b.party_hp, b.party_max]
	for ch in _ap_row.get_children():
		ch.queue_free()
	for k in b.ap_max():
		var pip := Panel.new()
		pip.custom_minimum_size = Vector2(22, 22)
		pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pip.add_theme_stylebox_override("panel", Kit.box(Kit.c("gold") if k < b.ap else Kit.c("track"), 11, 2, Kit.c("gold"), 0))
		_ap_row.add_child(pip)
	_round_label.text = "第 %d/%d 回合" % [b.round_no, b.turn_limit]
	_combo_label.text = "%d 连击 +%d%%" % [b.combo, b.combo * 10] if b.combo > 0 else ""
	for i in b.leaders.size():
		var u: Dictionary = b.leaders[i]
		var v: CardView = _cards[i]
		v.set_state(u["acted"] or u["confused"] or not b.can_act(i), false)
	var first_focus: Button = null
	for entry in _skill_buttons:
		var i: int = entry[0]
		var u: Dictionary = b.leaders[i]
		var sk: Dictionary = GameData.get_db().skills[entry[1]]
		var btn: Button = entry[2]
		var tag := "限1" if sk["uses"] == 1 else ("累积" if sk["cumulative"] else "")
		btn.text = "%s  AP%d%s" % [sk["name"], b.cost(u, sk), (" " + tag) if tag != "" else ""]
		btn.icon = Kit.skill_icon(sk)
		btn.expand_icon = false
		btn.add_theme_constant_override("icon_max_width", 24)
		btn.disabled = _busy or not (b.can_act(i) and b.usable(u, sk))
		btn.focus_mode = Control.FOCUS_NONE if btn.disabled else Control.FOCUS_ALL
		if not btn.disabled and first_focus == null:
			first_focus = btn
	_end.disabled = _busy
	_defend.text = "防御  AP%d" % b.defend_cost() if b.defend_cost() > 0 else "防御"
	_defend.disabled = _busy or not b.can_defend()
	_retreat.disabled = _busy
	if not _busy:
		Kit.focus(first_focus if first_focus != null else _end)


# ---- input -------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if _busy or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_E:
			_on_end_round()
		KEY_D:
			_on_defend()


func _on_skill(i: int, sid: String) -> void:
	if _busy or b.result != "":
		return
	_log_lines(b.act(i, sid))
	await _play(b.take_events())


func _on_end_round() -> void:
	if _busy or b.result != "":
		return
	_log_lines(b.end_round())
	await _play(b.take_events())


func _on_defend() -> void:
	if _busy or b.result != "" or not b.can_defend():
		return
	_log_lines(b.defend())
	await _play(b.take_events())


func _on_retreat() -> void:
	if _busy or b.result != "":
		return
	_log_lines(b.retreat())
	await _play([])


# ---- animation ---------------------------------------------------------------

func _enemy_center() -> Vector2:
	return _enemy_art.global_position + _enemy_art.size / 2 - global_position


func _party_center() -> Vector2:
	return _party_hp.global_position + _party_hp.size / 2 - global_position


func _play(events: Array) -> void:
	_busy = true
	_refresh()
	for ev in events:
		match ev["t"]:
			"act":
				var v: CardView = _cards[ev["unit"]]
				var y := v.position.y
				var tw := v.create_tween()
				tw.tween_property(v, "position:y", y - 26, 0.1).set_trans(Tween.TRANS_QUAD)
				tw.tween_property(v, "position:y", y, 0.14)
				await get_tree().create_timer(0.12).timeout
			"hit", "interrupt", "burn":
				Kit.shake(_enemy_art, 9.0, 0.2)
				_flash(_enemy_art, Color(1.6, 0.6, 0.6))
				var big: bool = ev["dmg"] > b.enemy["max_hp"] * 0.08
				Kit.float_text(self, _enemy_center() + Vector2(0, -30), str(ev["dmg"]),
					{"hit": Kit.c("amber"), "burn": Kit.c("red")}.get(ev["t"], Kit.c("purple")), 52 if big else 40)
				Kit.tween_bar(_enemy_hp, ev["hp"])
				_enemy_hp_label.text = "%d / %d" % [ev["hp"], b.enemy["max_hp"]]
				if ev["t"] == "hit" and ev["combo"] >= 2:
					_combo_label.text = "%d 连击 +%d%%" % [ev["combo"], ev["combo"] * 10]
					Kit.pop(_combo_label, 1.3)
				if big:
					Kit.shake(self, 6.0, 0.18)
				await get_tree().create_timer(0.16).timeout
			"heal":
				Kit.float_text(self, _party_center(), "+%d" % ev["amt"], Kit.c("green"))
				Kit.tween_bar(_party_hp, ev["hp"])
				await get_tree().create_timer(0.3).timeout
			"guard", "defend":
				Kit.float_text(self, _party_center(), "减伤 %d%%" % int(round(ev["cut"] * 100)), Kit.c("blue"), 32)
				await get_tree().create_timer(0.3).timeout
			"boost":
				for k in ev["units"]:
					Kit.pop(_cards[k], 1.08)
					_flash(_cards[k], Color(1.5, 1.35, 0.7))
				Kit.float_text(self, _party_center(), "BOOST", Kit.c("gold"), 34)
				await get_tree().create_timer(0.3).timeout
			"stun":
				Kit.float_text(self, _enemy_center(), "混乱！" if ev["ok"] else "未生效", Kit.c("purple"), 36)
				await get_tree().create_timer(0.3).timeout
			"break":
				Kit.float_text(self, _enemy_center(), "破防 +%d%%" % int(round(ev["amount"] * 100)), Kit.c("amber"), 34)
				await get_tree().create_timer(0.3).timeout
			"ap":
				Kit.float_text(self, _party_center() + Vector2(300, 0), "AP +%d" % ev["amount"], Kit.c("gold"), 34)
				await get_tree().create_timer(0.25).timeout
			"enemy_turn":
				await _banner("%s 的行动" % b.enemy["data"]["name"], Kit.c("red"))
			"enemy_stunned":
				Kit.float_text(self, _enemy_center(), "混乱中，无法行动", Kit.c("purple"), 32)
				await get_tree().create_timer(0.45).timeout
			"enemy_hit":
				var x := _enemy_art.position.y
				var tw := _enemy_art.create_tween()
				tw.tween_property(_enemy_art, "position:y", x + 28, 0.09).set_trans(Tween.TRANS_QUAD)
				tw.tween_property(_enemy_art, "position:y", x, 0.16)
				await get_tree().create_timer(0.09).timeout
				Kit.shake(self, 10.0, 0.22)
				_flash(_party_box, Color(1.6, 0.6, 0.6))
				Kit.float_text(self, _party_center(), "-%d" % ev["dmg"], Kit.c("red"), 44)
				Kit.tween_bar(_party_hp, ev["hp"])
				_party_hp_label.text = "%d / %d" % [ev["hp"], b.party_max]
				await get_tree().create_timer(0.4).timeout
			"enemy_charge":
				Kit.float_text(self, _enemy_center() + Vector2(0, -40), "蓄力！", Kit.c("red"), 44)
				Kit.shake(_enemy_art, 5.0, 0.4)
				_refresh()
				await get_tree().create_timer(0.5).timeout
			"enemy_rage":
				Kit.float_text(self, _enemy_center() + Vector2(0, -40), "狂暴！", Kit.c("red"), 44)
				_flash(_enemy_art, Color(1.8, 0.5, 0.5))
				await get_tree().create_timer(0.4).timeout
			"enemy_heal":
				Kit.float_text(self, _enemy_center(), "+%d" % ev["amt"], Kit.c("green"), 40)
				Kit.tween_bar(_enemy_hp, ev["hp"])
				await get_tree().create_timer(0.35).timeout
			"confuse":
				Kit.pop(_cards[ev["unit"]], 1.06)
				Kit.float_text(self, _cards[ev["unit"]].global_position - global_position + Vector2(100, 60),
					"混乱", Kit.c("purple"), 32)
				await get_tree().create_timer(0.3).timeout
			"round":
				await _banner("第 %d 回合" % ev["n"], Kit.c("gold"))
	_busy = false
	_refresh()
	if b.result != "":
		await get_tree().create_timer(0.4).timeout
		_finish()


func _flash(node: CanvasItem, color: Color) -> void:
	var tw := node.create_tween()
	tw.tween_property(node, "self_modulate", color, 0.06)
	tw.tween_property(node, "self_modulate", Color.WHITE, 0.18)


func _banner(text: String, color: Color) -> void:
	var l := Kit.label(text, Kit.FONT_TITLE)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_stylebox_override("normal", Kit.box(Color(color, 0.88), 0, 0, Color.TRANSPARENT, 12))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, 300)
	l.size = Vector2(1280, 80)
	l.z_index = 40
	l.modulate.a = 0.0
	add_child(l)
	var tw := l.create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.12)
	tw.tween_interval(0.45)
	tw.tween_property(l, "modulate:a", 0.0, 0.18)
	tw.tween_callback(l.queue_free)
	await get_tree().create_timer(0.55).timeout


func _tip(text: String) -> void:
	var l := Kit.label(text, Kit.FONT_SMALL)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_stylebox_override("normal", Kit.box(Color(0, 0, 0, 0.72), 10, 0, Color.TRANSPARENT, 10))
	l.position = Vector2(215, 218)
	l.size = Vector2(675, 36)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.z_index = 30
	add_child(l)
	var tw := l.create_tween()
	tw.tween_interval(6.0)
	tw.tween_property(l, "modulate:a", 0.0, 0.6)
	tw.tween_callback(l.queue_free)


func _log_lines(lines: Array) -> void:
	for line in lines:
		var s: String = line
		var color := Kit.c("text")
		if s.begins_with("——"):
			color = Kit.c("red")
		elif s.begins_with("───"):
			color = Kit.c("dim")
		elif s.begins_with("插入"):
			color = Kit.c("purple")
		elif s.begins_with("  "):
			color = Kit.c("muted")
		_log.append_text("[color=%s]%s[/color]\n" % [color.to_html(), s])


# ---- end -----------------------------------------------------------------------

func _finish() -> void:
	var save := Game.save
	var won := b.result == "win"
	if won:
		save.record_win(scenario_id)
		if carry:
			var out := b.carry_out()
			save.damage = out[0]
			save.carry_extra.merge(out[1], true)
			save.carry_uses.merge(out[2], true)
		await _banner("胜　利", Kit.c("gold"))
		var q: Dictionary = Game.battle_ctx.get("quest", {})
		var chest := save.chest_after_battle(Game.rng, b.overkill + float(b.mods.get("chest", 0.0)), boss, q.get("soldier_pool", []),
			b.enemy["data"]["card"])
		if not chest.is_empty():
			var o := PickOverlay.new()
			o.title = "宝箱！（过量伤害 %d%%）选一张卡带走" % int(round(b.overkill * 100))
			o.chest = "grand" if boss else "normal"
			o.card_ids = chest.map(func(c): return c["id"])
			o.counts = chest.map(func(c): return save.copies(c["id"]))
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			add_child(o)
			var i: int = await o.picked
			save.take(chest[i]["id"])
		Game.battle_finished(true)
	else:
		await _banner("战　败", Kit.c("red"))
		await get_tree().create_timer(0.6).timeout
		Game.battle_finished(false)
