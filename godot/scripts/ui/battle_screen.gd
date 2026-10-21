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
var _skill_popup: Control  # open skill-picker for whichever leader was last tapped, or null
var _skill_popup_at := 0  # msec it opened: the finger-lift from the tap that opened it must not close it
var _defend: Button
var _retreat: Button
var _end: Button
var _auto_btn: Button
static var auto_on := false  # 自动战斗: stays on from battle to battle until switched off
var _auto_waiting := false
var _party_box: Control
var _row: HBoxContainer  # the leader cards (换人 swaps one in place)
var _card_size := Vector2(240, 336)
var _has_cg := false
var _fx := {}  # persistent status effects on screen: key -> node (see _sync_fx)
var _badges: Array = []  # corner badges currently on screen (freed and rebuilt on every refresh)
var _boost_hits := false  # the blows now landing come from a BOOSTed leader
var _intro_wait := 0.0  # seconds of the enemy's entrance line, so 自动 doesn't talk over it
var _enemy_shouted_this_turn := false  # 敌人本回合是否已经战吼过（防止多段行动或灼烧连喊）


func _ready() -> void:
	Bgm.play("battle")
	var save := Game.save
	if carry:
		var m := Quests.mods(save)
		var afx := Quests.affix_here(save)
		if not afx.is_empty():
			m["affix"] = afx
		b = Battle.start(scenario_id, save.party_leaders(), Game.rng.randi(), save.damage, save.carry_extra, save.carry_uses,
			ambush, m, save.swap_roster())
	else:
		b = Battle.start(scenario_id, save.party_leaders(), Game.rng.randi(), 0, {}, {}, ambush, {}, save.swap_roster())
	_build()
	_apply_speed()
	_log_lines(["[b]【%s】[/b] %d 回合内击破 %s。" % [b.scenario["name"], b.turn_limit, b.enemy["data"]["name"]]])
	if b.mods.has("affix"):
		_log_lines(["[color=red]【词缀·%s】%s[/color]" % [b.mods["affix"]["name"], b.mods["affix"]["desc"]]])
	_log_lines(b.opening)
	b.take_events()
	_refresh()
	if b.result != "":  # decided before anyone moved (round 1's 插入 finished a weak enemy): every button is shut, so settle it here
		_busy = true
		_finish_at_start.call_deferred()
	elif auto_on:
		_auto_step.call_deferred()
	_intro_wait = Sfx.voice(_enemy_voices(), ["intro"])  # a named foe's entrance line (吕布「谁敢与我一战！」); generic enemies have none
	if ambush and not b.opening.is_empty() and str(b.opening[0]).contains("埋伏"):
		_banner("埋伏！%s 抢先出手" % b.enemy["data"]["name"], Kit.c("red"))
	if save.cleared.is_empty() and not carry or (carry and save.visited.size() <= 4):
		_tip("点队长卡选技能出手 · AP 每回合 +%d（最多 %d）· 每位队长每回合行动一次 · 全军共用一条体力" % [
			int(GameData.get_db().battle["ap_per_round"]), b.ap_max()])


# ---- layout ------------------------------------------------------------------

func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _open_settings() -> void:
	if get_node_or_null("Settings") != null:
		return
	var o := SettingsOverlay.new()
	o.name = "Settings"
	o.in_battle = true
	add_child(o)


func _build() -> void:
	var e: Dictionary = b.enemy["data"]
	# battle background: data/art/battle/<scenario id>.jpg (built by `sanguo-art` from pics/art.json "battles")
	var bg_path := "res://data/art/battle/%s.jpg" % str(b.scenario["art"])  # soldier battles of one type share a picture
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
	enemy_panel.size = Vector2(760, 250) if not has_cg else Vector2(560, 0)
	# a max height of 0 is not "unlimited": with clip_contents it cut the whole CG-mode panel (name, HP bar) away
	enemy_panel.custom_maximum_size = Vector2(760, 250) if not has_cg else Vector2(560, 200)
	enemy_panel.clip_contents = true
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
	info.add_theme_constant_override("separation", 6 if not has_cg else 4)
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
	if not has_cg:  # HP and attack share a line: the status list below needs the height
		var hp_row := HBoxContainer.new()
		hp_row.add_theme_constant_override("separation", 18)
		hp_row.add_child(_enemy_hp_label)
		hp_row.add_child(Kit.label("攻击 %d · 每回合行动 %d 次" % [e["at"], e["actions"]], Kit.FONT_SMALL, "muted"))
		info.add_child(hp_row)
	else:
		info.add_child(_enemy_hp_label)
	_enemy_status = Kit.label("", Kit.FONT_SMALL, "purple")
	# a long list of statuses must wrap, never widen the panel (it stretched the enemy HP bar behind the log)
	_enemy_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_enemy_status.custom_minimum_size = Vector2(10, 0)
	_enemy_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_enemy_status.max_lines_visible = 3
	info.add_child(_enemy_status)

	# log (top-right)
	var log_panel := PanelContainer.new()
	log_panel.position = Vector2(796, 56) if not has_cg else Vector2(890, 56)  # below the 设置 button (top-right corner)
	log_panel.size = Vector2(464, 208) if not has_cg else Vector2(370, 150)
	if has_cg:  # a small see-through log so the painting shows
		log_panel.add_theme_stylebox_override("panel", Kit.box(Color(0, 0, 0, 0.45), 10, 0, Color.TRANSPARENT, 8))
	add_child(log_panel)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.add_theme_font_size_override("normal_font_size", 21 if not has_cg else 18)
	_log.add_theme_font_size_override("bold_font_size", 21 if not has_cg else 18)
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
	_party_hp.custom_minimum_size = Vector2(120, 26)  # the bar gives way: AP pips, round and combo must always fit
	_party_hp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	_combo_label.custom_minimum_size = Vector2(170, 0)  # room for 「N 连击 +NN%」 so it is never pushed off screen
	pr.add_child(_combo_label)

	# leaders (bottom-left) — skills live in a popup now (tap the card), not stacked buttons under it,
	# so the card itself can run much bigger; the 5th "locked" slot is a slim strip, not full card width,
	# so it doesn't eat into the 4 real cards' size (a future 5-member chapter can revisit this split)
	var row := HBoxContainer.new()
	_row = row
	_has_cg = has_cg
	row.position = Vector2(20, 340) if not has_cg else Vector2(20, 440)
	row.add_theme_constant_override("separation", 2)
	add_child(row)
	var card_size := Vector2(240, 336) if not has_cg else Vector2(190, 266)
	_card_size = card_size
	var locked_w := 70.0
	for i in b.leaders.size():
		var v := _make_card(i)
		row.add_child(v)
		_cards.append(v)
	var locked := PanelContainer.new()  # one slim slot for a future 5th party member
	locked.custom_minimum_size = Vector2(locked_w, card_size.y)
	locked.add_theme_stylebox_override("panel", Kit.box(Kit.c("card").darkened(0.5), 10, 2, Kit.c("gray"), 0))
	var lbl := Kit.label("第五人\n敬请\n期待", 12, "gray")
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	locked.add_child(lbl)
	row.add_child(locked)

	# actions (bottom-right) — narrower than before so the leader cards (left) can run bigger
	var acts := VBoxContainer.new()
	acts.position = Vector2(1070, 380) if not has_cg else Vector2(1090, 456)
	acts.size = Vector2(190, 320) if not has_cg else Vector2(170, 220)
	acts.add_theme_constant_override("separation", 14 if not has_cg else 10)
	add_child(acts)
	_end = Kit.button("回合结束", "red", Kit.FONT_BIG)
	_end.custom_minimum_size = Vector2(190, 70) if not has_cg else Vector2(170, 60)
	_end.pressed.connect(_on_end_round)
	acts.add_child(_end)
	_defend = Kit.button("防御", "blue", Kit.FONT_BIG)
	_defend.custom_minimum_size = Vector2(190, 62) if not has_cg else Vector2(170, 52)
	_defend.pressed.connect(_on_defend)
	acts.add_child(_defend)
	var low := HBoxContainer.new()
	low.add_theme_constant_override("separation", 8)
	acts.add_child(low)
	_retreat = Kit.button("撤退", "gray", Kit.FONT_BODY)
	var retreat := _retreat
	retreat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	retreat.pressed.connect(_on_retreat)
	low.add_child(retreat)
	_auto_btn = Kit.button("自动", "purple", Kit.FONT_BODY)
	_auto_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_auto_btn.pressed.connect(_toggle_auto)
	low.add_child(_auto_btn)
	_sync_auto_btn()
	var menu_btn := Kit.button("设置", "gray", Kit.FONT_SMALL)
	menu_btn.custom_minimum_size = Vector2(84, 40)
	menu_btn.position = Vector2(1186, 8)
	menu_btn.z_index = 5
	menu_btn.pressed.connect(_open_settings)
	add_child(menu_btn)


func _make_card(i: int) -> CardView:
	var u: Dictionary = b.leaders[i]
	var v := CardView.make(u["leader"]["card"]["id"], _card_size, {"leader": u["leader"], "skills": false,
		"lord_name": Game.save.lord_name})
	if _has_cg:
		v.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.focus_mode = Control.FOCUS_NONE
	v.pressed.connect(_open_skills.bind(i))
	return v


func _rebuild_card(i: int) -> void:
	## 换人: the slot's card is a different one now
	var old: CardView = _cards[i]
	var v := _make_card(i)
	_row.add_child(v)
	_row.move_child(v, old.get_index())
	old.queue_free()
	_cards[i] = v


func _refresh() -> void:
	var e := b.enemy
	_enemy_hp_label.text = "%d / %d" % [e["hp"], e["max_hp"]]
	var st: Array = []
	if e["stunned"]:
		st.append("混乱：下回合无法行动")
	if e["break_turns"] > 0:
		st.append("破防 +%d%%（%d 回合）" % [int(round(e["break_amount"] * 100)), e["break_turns"]])
	if e["burn_turns"] > 0:
		if e["burn_pct"] > 0.0:
			st.append("🔥 灼烧 现有体力 -%d%%/回合（%d 回合）" % [int(round(e["burn_pct"] * 100)), e["burn_turns"]])
		else:
			st.append("🔥 灼烧 -%d/回合（%d 回合）" % [e["burn_dmg"], e["burn_turns"]])
	if e["charging"] != "":
		st.append("⚠ 蓄力中：下回合【%s】！" % e["charging"])
	if e["at"] > e["data"]["at"] * 1.01:
		st.append("狂暴 攻击 %d" % int(round(e["at"])))
	if b.buff["layers"] > 0:
		st.append("战意 ×%d：攻击 +%d%% 受伤 -%d%%（%d 回合）" % [b.buff["layers"], int(round(b.buff["atk"] * 100)), int(round(b.buff["def"] * 100)), b.buff["turns"]])
	if b.party_burn["turns"] > 0:
		st.append("我军灼烧 -%d（%d 回合）" % [b.party_burn["dmg"], b.party_burn["turns"]])
	if b.ap_drain > 0:
		st.append("下回合 AP -%d" % b.ap_drain)
	_enemy_status.text = "　".join(st)
	_enemy_status.visible = not st.is_empty()  # no empty line under the enemy bar
	_party_hp_label.text = "%d / %d" % [b.party_hp, b.party_max]
	for ch in _ap_row.get_children():
		ch.queue_free()
	var pips: int = b.ap_max()
	var ps := 22 if pips <= 8 else maxi(10, int(22.0 * 8.0 / pips))  # more AP than 8: smaller pips, same total width
	for k in pips:
		var pip := Panel.new()
		pip.custom_minimum_size = Vector2(ps, ps)
		pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pip.add_theme_stylebox_override("panel", Kit.box(Kit.c("gold") if k < b.ap else Kit.c("track"), 11, 2, Kit.c("gold"), 0))
		_ap_row.add_child(pip)
	if b.ap_drain > 0:  # 夺气: the enemy will take AP next round
		_ap_row.add_child(Kit.label("夺气 -%d" % b.ap_drain, Kit.FONT_BODY, "red"))
	var left := b.turn_limit - b.round_no
	_round_label.text = "最后回合！" if left <= 0 else "第 %d/%d 回合" % [b.round_no, b.turn_limit]
	_round_label.add_theme_color_override("font_color", Kit.c("red") if left <= 1 else Kit.c("text"))
	_combo_label.text = "%d 连击 +%d%%" % [b.combo, b.combo * 10] if b.combo > 0 else ""
	for i in b.leaders.size():
		var u: Dictionary = b.leaders[i]
		var v: CardView = _cards[i]
		v.set_state(u["acted"] or u["confused"] or not b.can_act(i), false)
		v.focus_mode = Control.FOCUS_NONE if (_busy or not b.can_act(i)) else Control.FOCUS_ALL
	_end.disabled = _busy
	_defend.text = "防御  AP%d" % b.defend_cost() if b.defend_cost() > 0 else "防御"
	_defend.disabled = _busy or not b.can_defend()
	_retreat.disabled = _busy
	_sync_fx()
	if not _busy:
		var first_card: CardView = _cards.filter(func(v): return v.focus_mode == Control.FOCUS_ALL).front() if _cards.any(func(v): return v.focus_mode == Control.FOCUS_ALL) else null
		Kit.focus(first_card if first_card != null else _end)


# ---- input -------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if _busy or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_E:
			_on_end_round()
		KEY_D:
			_on_defend()


func _close_skill_popup() -> void:
	if _skill_popup != null:
		_skill_popup.queue_free()
		_skill_popup = null


func _open_skills(i: int) -> void:
	if _busy or b.result != "" or not (b.can_act(i) or b.can_swap(i)):
		return
	_close_skill_popup()
	var u: Dictionary = b.leaders[i]
	var overlay := Control.new()
	overlay.z_index = 60
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := Button.new()  # a borderless full-screen button: click anywhere outside the panel to cancel
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.focus_mode = Control.FOCUS_NONE
	for st in ["normal", "hover", "pressed", "focus"]:  # not flat: a flat Button skips its stylebox, so nothing dims
		dim.add_theme_stylebox_override(st, Kit.box(Color(0, 0, 0, 0.55), 0, 0, Color.TRANSPARENT, 0))
	dim.button_down.connect(func():  # a fresh touch-down only: the lift from the tap that opened it must not close it
		if Time.get_ticks_msec() - _skill_popup_at > 350:
			_close_skill_popup())
	overlay.add_child(dim)
	var card_x: float = _cards[i].global_position.x
	var card_top: float = _cards[i].global_position.y
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 14, 3, Kit.c("gold"), 14))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)
	col.add_child(Kit.label(u["leader"]["card"]["name"], Kit.FONT_BODY + 2, "gold"))
	for sid in u["leader"]["card"]["skills"]:
		var sk: Dictionary = GameData.get_db().skills[sid]
		var tag := "限1" if sk["uses"] == 1 else ("累积" if sk["cumulative"] else "")
		var btn := Kit.button("%s  AP%d%s" % [sk["name"], b.cost(u, sk), (" " + tag) if tag != "" else ""], "blue", Kit.FONT_BODY)
		btn.icon = Kit.skill_icon(sk)
		btn.expand_icon = false
		btn.add_theme_constant_override("icon_max_width", 28)
		btn.custom_minimum_size = Vector2(260, 48)
		btn.disabled = not b.usable(u, sk)
		btn.pressed.connect(func():
			_close_skill_popup()
			_on_skill(i, sid))
		col.add_child(btn)
	if not b.swap_options(i).is_empty():
		var sw := Kit.button("换人%s%s" % [("  AP%d" % b.swap_cost()) if b.swap_cost() > 0 else "（不费 AP）", "" if b.round_no >= b.swap_from_round() else "（第 %d 回合起）" % b.swap_from_round()], "gold", Kit.FONT_BODY)
		sw.custom_minimum_size = Vector2(260, 48)
		sw.disabled = not b.can_swap(i)
		sw.pressed.connect(func():
			_close_skill_popup()
			_open_swap(i))
		col.add_child(sw)
	overlay.add_child(panel)
	add_child(overlay)
	panel.position = Vector2(clampf(card_x, 10, 1280 - 280), clampf(card_top - 10, 10, 720) - panel.size.y if card_top > 300 else card_top + _cards[i].size.y + 10)
	_skill_popup = overlay
	_skill_popup_at = Time.get_ticks_msec()
	Kit.focus(col.get_child(1) if col.get_child_count() > 1 else null)


func _open_swap(i: int) -> void:
	## 换人: the same pick-a-card screen as recruiting; whoever comes off is out for the rest of the battle
	_close_skill_popup()
	var opts: Array = b.swap_options(i)
	opts.sort_custom(func(x, y): return SaveData.leader_power(x) > SaveData.leader_power(y))
	opts = opts.slice(0, 5)  # five cards fit across the screen
	var ids: Array = opts.map(func(ld): return ld["card"]["id"])
	var o := PickOverlay.new()
	o.title = "换谁上场？（%s · 攻击体力不变 · 换下的人本场不能再上）" % (("AP%d" % b.swap_cost()) if b.swap_cost() > 0 else "不费 AP")
	o.card_ids = ids
	o.captions = opts.map(func(ld): return "%s · %s" % [GameData.get_db().troops[ld["card"]["troop"]]["name"],
		"、".join(ld["card"]["skills"].map(func(s): return GameData.get_db().skills[s]["name"]))])
	o.confirm_text = "上场"
	o.cancelable = true
	o.z_index = 70
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.picked.connect(func(k):
		o.queue_free()
		_on_swap(i, ids[k]))
	o.cancelled.connect(func(): o.queue_free())
	add_child(o)


func _on_swap(i: int, card_id: String) -> void:
	if _busy or b.result != "" or not b.can_swap(i):
		return
	_log_lines(b.swap(i, card_id))
	await _play(b.take_events())


func _toggle_auto() -> void:
	## the 自动 button cycles 关 → 快 → 慢 → 关 (the speed is kept in options.cfg)
	if not auto_on:
		auto_on = true
		Game.set_option("auto_speed", "fast")
	elif str(Game.options.get("auto_speed", "fast")) == "fast":
		Game.set_option("auto_speed", "slow")
	else:
		auto_on = false
	_apply_speed()
	_sync_auto_btn()
	if auto_on:
		_close_skill_popup()
		_auto_step()


func _auto_slow() -> bool:
	return auto_on and str(Game.options.get("auto_speed", "fast")) == "slow"


func _apply_speed() -> void:
	## 慢速自动: animations at plain speed (even with 快速 on) and a long beat between actions, to watch the fight
	Engine.time_scale = 1.0 if _auto_slow() else Game.battle_speed()


func _sync_auto_btn() -> void:
	_auto_btn.text = ("自动：慢" if _auto_slow() else "自动：快") if auto_on else "自动"
	_auto_btn.add_theme_color_override("font_color", Kit.c("gold") if auto_on else Kit.c("text"))


func _auto_step() -> void:
	## 自动战斗: one action (or the end of the round) at a time, after the last one has played out
	if _auto_waiting:
		return
	_auto_waiting = true
	while auto_on and _busy and is_inside_tree():
		await get_tree().process_frame
	if auto_on and is_inside_tree():
		await get_tree().create_timer(maxf(_intro_wait, 1.3 if _auto_slow() else 0.35)).timeout
		_intro_wait = 0.0  # the first move waits for the enemy's entrance line to finish  # a beat to see the board — and to switch it off
	_auto_waiting = false
	if not (auto_on and is_inside_tree()) or _busy or b.result != "":
		return
	var act := AutoPlayer.next(b)
	if act.is_empty():
		await _on_end_round()
	else:
		await _on_skill(act[0], act[1])


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

func _enemy_fx_scale() -> float:
	return clampf(_enemy_art.size.x / 340.0, 0.5, 1.5)


func _enemy_rect() -> Rect2:
	return Rect2(_enemy_center() - Vector2(170, 110) * _enemy_fx_scale(), Vector2(340, 220) * _enemy_fx_scale())


func _card_rect(i: int) -> Rect2:
	return Rect2(_cards[i].global_position - global_position, _cards[i].size)


func _cards_rect() -> Rect2:
	var r: Rect2 = _card_rect(0)
	for i in range(1, _cards.size()):
		r = r.merge(_card_rect(i))
	return r


func _party_rect() -> Rect2:
	return Rect2(_party_box.global_position - global_position, _party_box.size)


func _fx_set(want: Dictionary) -> void:
	## keep exactly the persistent effects in `want` ({key: Callable that makes the node}) on screen
	for key in _fx.keys():
		if not want.has(key) or not is_instance_valid(_fx[key]):
			if is_instance_valid(_fx[key]):
				_fx[key].queue_free()
			_fx.erase(key)
	for key in want:
		if not _fx.has(key):
			_fx[key] = want[key].call()


func _sync_fx() -> void:
	## the statuses that last (灼烧 / 破防 / 眩晕 on the enemy, 灼烧 on us, 混乱 / BOOST / 战意 on the cards)
	if b == null or _cards.is_empty() or b.result != "":
		return
	var want := {}
	var e := b.enemy
	if e["burn_turns"] > 0:
		want["e_burn"] = func(): return BattleFx.embers(self, _enemy_rect(), BattleFx.EMBER, 22, 70.0)
	if e["break_turns"] > 0:
		want["e_break"] = func(): return BattleFx.cracks(self, _enemy_rect(), Color(1.0, 0.82, 0.35, 0.8))
	if e["stunned"]:
		want["e_stun"] = func(): return BattleFx.orbit(self, _enemy_center() + Vector2(0, -80), 80.0, 22.0, 4, BattleFx.GOLD, 11.0)
	if b.party_burn["turns"] > 0:
		want["p_burn"] = func(): return BattleFx.embers(self, _party_rect(), BattleFx.EMBER, 26, 50.0)
	for i in b.leaders.size():
		var u: Dictionary = b.leaders[i]
		var id: String = u["leader"]["card"]["id"]
		var r := _card_rect(i)
		if u["confused"]:
			want["conf_%s" % id] = func(): return BattleFx.orbit(self, r.position + Vector2(r.size.x / 2, 8), 56.0, 14.0, 3, BattleFx.VIOLET, 10.0)
		if u["boosted"]:
			want["boost_%s" % id] = func(): return BattleFx.boost_aura(self, r)
		if b.buff["layers"] > 0:
			want["buff_%s" % id] = func(): return BattleFx.glow(self, r, BattleFx.GOLD)
		var tint := Color(0.78, 0.68, 1.0) if u["confused"] else Color.WHITE  # a card that can't act stays grey (set_state dimmed it)
		_cards[i].modulate = tint * Color(0.55, 0.55, 0.55) if _cards[i].dimmed else tint
		_boost_pop(_cards[i], u["boosted"])
	_fx_set(want)
	_sync_badges()


func _boost_pop(card: CardView, on: bool) -> void:
	## a BOOSTed (strengthened) card takes the front: drawn over its neighbours, a little bigger, breathing — until it has acted
	var old: Variant = card.get_meta("boost_tw") if card.has_meta("boost_tw") else null
	if old is Tween and (old as Tween).is_valid():
		(old as Tween).kill()
	card.pivot_offset = card.size / 2
	if not on:
		card.set_meta("boost_tw", null)
		card.z_index = 0
		card.scale = Vector2.ONE
		return
	card.z_index = 20  # over its neighbours (0), under banners (40) and every overlay (60+)
	var tw := card.create_tween().set_loops()
	tw.tween_property(card, "scale", Vector2(1.07, 1.07), 0.55).set_trans(Tween.TRANS_SINE)
	tw.tween_property(card, "scale", Vector2(1.03, 1.03), 0.55).set_trans(Tween.TRANS_SINE)
	card.set_meta("boost_tw", tw)


func _boost_ribbon(rr: Rect2) -> Control:
	## 「强化 ×1.5」 across the top of a boosted card, so nobody has to find the small corner badge
	var l := Kit.label("强化 ×%s" % str(GameData.get_db().battle["boost_mult"]), Kit.FONT_BODY, "gold")
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_stylebox_override("normal", Kit.box(Color(0.95, 0.45, 0.1, 0.95), 8, 2, Color(1.0, 0.85, 0.4), 4))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size = Vector2(rr.size.x - 24.0, 30.0)
	l.position = Vector2(rr.position.x + 12.0, rr.position.y + rr.size.y * 0.42)
	return l


func _sync_badges() -> void:
	## 角标: a small round badge per status or buff — enemy (灼 破 晕 怒 蓄) above its HP bar, party-wide (战 灼 夺) over the party bar,
	## and per card (混 强) in its top-right corner; the little number is the turns / layers left
	for n in _badges:
		if is_instance_valid(n):
			n.queue_free()
	_badges.clear()
	var e := b.enemy
	var row: Array = []
	if e["burn_turns"] > 0:
		row.append(BattleFx.badge("灼", Color(1.0, 0.5, 0.15), e["burn_turns"]))
	if e["break_turns"] > 0:
		row.append(BattleFx.badge("破", Color(0.95, 0.72, 0.2), e["break_turns"]))
	if e["stunned"]:
		row.append(BattleFx.badge("晕", Color(0.62, 0.42, 0.95)))
	if e["at"] > e["data"]["at"] * 1.01:
		row.append(BattleFx.badge("怒", Color(0.9, 0.2, 0.2)))
	if e["charging"] != "":
		row.append(BattleFx.badge("蓄", Color(0.9, 0.2, 0.2), -1, false))
	var at := _enemy_hp.global_position - global_position + Vector2(_enemy_hp.size.x - 40.0, -40.0)
	for k in row.size():
		row[k].position = at - Vector2(k * 38.0, 0)
		_badge_add(row[k])
	var party: Array = []
	if b.buff["layers"] > 0:
		party.append(BattleFx.badge("战", Color(0.95, 0.75, 0.25), b.buff["layers"]))
	if b.party_burn["turns"] > 0:
		party.append(BattleFx.badge("灼", Color(0.9, 0.3, 0.15), b.party_burn["turns"]))
	if b.ap_drain > 0:
		party.append(BattleFx.badge("夺", Color(0.75, 0.2, 0.3), b.ap_drain))
	var pr := _party_rect()
	for k in party.size():
		party[k].position = Vector2(pr.end.x - 40.0 - k * 38.0, pr.position.y - 20.0)
		_badge_add(party[k])
	for i in b.leaders.size():
		var u: Dictionary = b.leaders[i]
		var rr := _card_rect(i)
		var mine: Array = []
		if u["confused"]:
			mine.append(BattleFx.badge("混", Color(0.62, 0.42, 0.95)))
		elif u["confuse_next"]:
			mine.append(BattleFx.badge("混", Color(0.62, 0.42, 0.95), -1, true))
		if u["boosted"]:
			mine.append(BattleFx.badge("强", Color(1.0, 0.5, 0.15)))
			var rib := _boost_ribbon(rr)
			_badge_add(rib)
		for k in mine.size():
			mine[k].position = Vector2(rr.end.x - 40.0 - k * 36.0, rr.position.y + 6.0)
			_badge_add(mine[k])


func _badge_add(n: Control) -> void:
	n.z_index = 48
	add_child(n)
	_badges.append(n)


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
				_boost_hits = bool(ev.get("boost", false))
				_sfx_act(ev)
				if _is_ult(GameData.get_db().skills.get(str(ev.get("skill", "")), {})):
					await _ult_cutin(int(ev["unit"]), str(ev["skill"]))
				if _boost_hits:
					BattleFx.boost_cast(self, _card_rect(ev["unit"]))
					Kit.float_text(self, _card_rect(ev["unit"]).get_center() + Vector2(0, -60), "BOOST ×1.5", Kit.c("gold"), 34)
				await get_tree().create_timer(0.02).timeout
			"hit", "interrupt", "burn", "counter":
				Kit.shake(_enemy_art, 9.0, 0.2)
				_flash(_enemy_art, Color(1.6, 0.6, 0.6))
				var big: bool = ev["dmg"] > b.enemy["max_hp"] * 0.08
				var ratio := float(ev["dmg"]) / maxf(1.0, float(b.enemy["max_hp"]))
				_sfx_hit(ev, big)
				BattleFx.scale = _enemy_fx_scale()
				match ev["t"]:
					"hit":
						BattleFx.hit(self, _enemy_center(), ev["kind"], ev["combo"], ratio, ev.get("pierce", false), _boost_hits)
					"counter":
						BattleFx.counter(self, _enemy_center())
					"burn":
						BattleFx.flame_lick(self, _enemy_rect())
					"interrupt":
						BattleFx.slash(self, _enemy_center() + Vector2(randf_range(-40, 40), randf_range(-30, 30)), Color(0.9, 0.95, 1.0), 25.0, 170.0, 8.0)
				BattleFx.scale = 1.0
				var crit_hit: bool = ev.get("crit", false)
				Kit.float_text(self, _enemy_center() + Vector2(0, -30), ("暴击 " if crit_hit else "") + str(ev["dmg"]),
					Kit.c("gold") if crit_hit else {"hit": Kit.c("amber"), "burn": Kit.c("red")}.get(ev["t"], Kit.c("purple")), 64 if crit_hit else (52 if big else 40))
				if crit_hit:
					Kit.shake(self, 14.0, 0.2)
				Kit.tween_bar(_enemy_hp, ev["hp"])
				_enemy_hp_label.text = "%d / %d" % [ev["hp"], b.enemy["max_hp"]]
				if ev["t"] == "hit" and ev["combo"] >= 2:
					_combo_label.text = "%d 连击 +%d%%" % [ev["combo"], ev["combo"] * 10]
					Kit.pop(_combo_label, 1.3)
				if big:
					Kit.shake(self, 6.0 + 24.0 * minf(ratio, 0.3), 0.18)
					await get_tree().create_timer(0.06).timeout  # a beat of hit-stop on the heavy ones
				await get_tree().create_timer(0.16).timeout
			"swap":
				_rebuild_card(ev["unit"])
				_party_hp.max_value = ev["max"]
				Kit.tween_bar(_party_hp, ev["hp"])
				_party_hp_label.text = "%d / %d" % [ev["hp"], ev["max"]]
				Kit.float_text(self, _cards[ev["unit"]].global_position - global_position + Vector2(100, 60), "换人", Kit.c("gold"), 36)
				Kit.pop(_cards[ev["unit"]], 1.08)
				await get_tree().create_timer(0.35).timeout
			"buff":
				Sfx.play("buff")
				Kit.float_text(self, _party_center(), "战意 ×%d" % ev["layers"], Kit.c("gold"), 36)
				BattleFx.buff_cast(self, range(_cards.size()).map(func(i): return _card_rect(i).get_center()))
				_refresh()
				await get_tree().create_timer(0.3).timeout
			"cleanse":
				Kit.float_text(self, _party_center(), "状态解除" if ev["n"] > 0 else "无状态", Kit.c("green"), 34)
				BattleFx.cleanse_wave(self, _cards_rect())
				_refresh()
				await get_tree().create_timer(0.3).timeout
			"ap_drain":
				var pips: Array = _ap_row.get_children().filter(func(n): return n is Panel)
				var gone: Array = pips.slice(int(ev["ap"]), int(ev["ap"]) + int(ev["amount"]))
				BattleFx.drain_shatter(self, gone, gone.size())
				Kit.float_text(self, _party_center() + Vector2(300, 0), "AP -%d" % ev["amount"], Kit.c("red"), 34)
				await get_tree().create_timer(0.35).timeout
			"hurt":
				Kit.float_text(self, _party_center(), "-%d" % ev["dmg"], Kit.c("red"), 36)
				Kit.tween_bar(_party_hp, ev["hp"])
				_party_hp_label.text = "%d / %d" % [ev["hp"], b.party_max]
				await get_tree().create_timer(0.3).timeout
			"heal":
				Sfx.play("heal")
				Kit.float_text(self, _party_center(), "+%d" % ev["amt"], Kit.c("green"))
				Kit.tween_bar(_party_hp, ev["hp"])
				await get_tree().create_timer(0.3).timeout
			"guard", "defend":
				Sfx.play("guard")
				Kit.float_text(self, _party_center(), "减伤 %d%%" % int(round(ev["cut"] * 100)), Kit.c("blue"), 32)
				await get_tree().create_timer(0.3).timeout
			"boost":
				Sfx.play("buff")
				for k in ev["units"]:
					Kit.pop(_cards[k], 1.08)
					_flash(_cards[k], Color(1.5, 1.35, 0.7))
					BattleFx.boost_cast(self, _card_rect(k))
				Kit.float_text(self, _party_center(), "BOOST", Kit.c("gold"), 34)
				await get_tree().create_timer(0.3).timeout
			"stun":
				Kit.float_text(self, _enemy_center(), "眩晕！" if ev["ok"] else "未生效", Kit.c("purple"), 36)
				if ev["ok"]:
					Sfx.play("stun")
					BattleFx.stun_burst(self, _enemy_center() + Vector2(0, -50))
				await get_tree().create_timer(0.3).timeout
			"break":
				Sfx.play("break")
				Kit.float_text(self, _enemy_center(), "破防 +%d%%" % int(round(ev["amount"] * 100)), Kit.c("amber"), 34)
				var crack := BattleFx.break_flash(self, _enemy_rect())
				crack.get_tree().create_timer(0.8).timeout.connect(crack.queue_free)
				await get_tree().create_timer(0.3).timeout
			"ap":
				Kit.float_text(self, _party_center() + Vector2(300, 0), "AP +%d" % ev["amount"], Kit.c("gold"), 34)
				await get_tree().create_timer(0.25).timeout
			"enemy_turn":
				_enemy_shouted_this_turn = false
				await _banner("%s 的行动" % b.enemy["data"]["name"], Kit.c("red"))
			"enemy_stunned":
				Kit.float_text(self, _enemy_center(), "眩晕中，无法行动", Kit.c("purple"), 32)
				await get_tree().create_timer(0.45).timeout
			"enemy_hit":
				var is_fire: bool = ev.get("move", "") == "火"
				if not is_fire and _enemy_big_move(str(ev.get("move", ""))):  # the wound-up 大招 lands: cut-in, and it roars
					var ed: Dictionary = b.enemy.get("data", {})
					Sfx.voice(_enemy_voices(), ["roar", "attack"])
					_enemy_shouted_this_turn = true
					await _cutin(str(ed.get("name", "")), str(ed.get("portrait", "")), str(ev.get("move", "")), true)
				var x := _enemy_art.position.y
				var tw := _enemy_art.create_tween()
				tw.tween_property(_enemy_art, "position:y", x + 28, 0.08).set_trans(Tween.TRANS_QUAD)
				tw.tween_property(_enemy_art, "position:y", x, 0.16)
				# 敌人一回合只喊一次战吼，且灼烧掉血绝不喊叫
				if not is_fire and not _enemy_shouted_this_turn:
					Sfx.voice(_enemy_voices(), ["attack"])
					_enemy_shouted_this_turn = true
					await get_tree().create_timer(0.04).timeout
				Sfx.play("burn" if is_fire else "enemy_hit")
				Kit.shake(self, 10.0, 0.22)
				_flash(_party_box, Color(1.6, 0.6, 0.6))
				if is_fire:
					BattleFx.flame_lick(self, _party_rect())
				else:
					BattleFx.claw(self, _cards_rect().get_center(), float(ev["dmg"]) / maxf(1.0, float(b.party_max)), float(ev["cut"]))
				Kit.float_text(self, _party_center(), ("暴击 " if ev.get("crit", false) else "") + "-%d" % ev["dmg"], Kit.c("red"), 56 if ev.get("crit", false) else 44)
				Kit.tween_bar(_party_hp, ev["hp"])
				_party_hp_label.text = "%d / %d" % [ev["hp"], b.party_max]
				await get_tree().create_timer(0.35).timeout
			"enemy_charge":
				if not _enemy_shouted_this_turn:
					Sfx.voice(_enemy_voices(), ["roar", "attack"])
					_enemy_shouted_this_turn = true
				Sfx.play("charge")
				Kit.float_text(self, _enemy_center() + Vector2(0, -40), "蓄力！", Kit.c("red"), 44)
				Kit.shake(_enemy_art, 5.0, 0.4)
				_refresh()
				await get_tree().create_timer(0.45).timeout
			"enemy_rage":
				if not _enemy_shouted_this_turn:
					Sfx.voice(_enemy_voices(), ["roar", "attack"])
					_enemy_shouted_this_turn = true
				Kit.float_text(self, _enemy_center() + Vector2(0, -40), "狂暴！", Kit.c("red"), 44)
				_flash(_enemy_art, Color(1.8, 0.5, 0.5))
				await get_tree().create_timer(0.4).timeout
			"enemy_heal":
				Sfx.play("heal")
				Kit.float_text(self, _enemy_center(), "+%d" % ev["amt"], Kit.c("green"), 40)
				Kit.tween_bar(_enemy_hp, ev["hp"])
				await get_tree().create_timer(0.35).timeout
			"confuse":
				Kit.pop(_cards[ev["unit"]], 1.06)
				Kit.float_text(self, _cards[ev["unit"]].global_position - global_position + Vector2(100, 60),
					"混乱", Kit.c("purple"), 32)
				BattleFx.stun_burst(self, _card_rect(ev["unit"]).position + Vector2(_card_rect(ev["unit"]).size.x / 2, 30))
				BattleFx.burst(self, _card_rect(ev["unit"]).get_center(), BattleFx.VIOLET, 10, 20.0, 110.0, 5.0)
				await get_tree().create_timer(0.3).timeout
			"round":
				var left: int = b.turn_limit - int(ev["n"])
				if left <= 0:  # the last round: lose it and the run is lost — make it impossible to miss
					await _alert("最后回合！", "击破 %s，否则撤退" % b.enemy["data"]["name"], Kit.c("red"), 1.3)
				elif left == 1:
					await _alert("还剩 2 回合", "", Kit.c("orange") if Kit.pal().has("orange") else Kit.c("gold"), 0.8)
				else:
					await _banner("第 %d 回合" % ev["n"], Kit.c("gold"))
	_busy = false
	_refresh()
	if b.result != "":
		await get_tree().create_timer(0.4).timeout
		_finish()
	elif auto_on:
		_auto_step.call_deferred()


func _is_female(card: Dictionary) -> bool:
	return Sfx.is_female(card)


func _enemy_voices() -> Array:
	## the enemy's voice profiles, most specific first: its own `voice`, its card's, the card its portrait belongs to (a 吕布
	## fight that drops 并州 soldiers is still 吕布), then the default by gender (audio.json)
	var e: Dictionary = b.enemy.get("data", {})
	var db := GameData.get_db()
	var card: Dictionary = db.cards.get(str(e.get("card", "")), {})
	var face: Dictionary = db.cards.get(str(e.get("portrait", "")), {})
	var own := ""
	for v in [e.get("voice", ""), card.get("voice", ""), face.get("voice", "")]:  # the first one that is set
		if str(v) != "":
			own = str(v)
			break
	var role := "enemy_female" if _is_female(e) or _is_female(card) else "enemy_male"
	return [own, str(Sfx.voice_defaults.get(role, role))]


static func _is_ult(skill: Dictionary) -> bool:
	## 大招: special, once per stretch (限1) or 3+ AP
	return bool(skill.get("special", false)) or (skill.get("uses", null) != null and int(skill["uses"]) == 1) or int(skill.get("cost", 0)) >= 3


func _ult_cutin(i: int, skill_id: String) -> void:
	var card: Dictionary = b.leaders[i].get("leader", {}).get("card", {})
	var skill: Dictionary = GameData.get_db().skills.get(skill_id, {})
	if not bool(skill.get("cutin", true)):  # skills.json "cutin": false = no cut-in for this one
		return
	await _cutin(str(card.get("name", "")).split("·")[0], Kit.portrait_key(str(card.get("person", card.get("id", "")))),
		str(skill.get("name", "")), false, str(skill.get("cutin_sfx", "ult_cutin")))


func _enemy_big_move(move_name: String) -> bool:
	## the enemy's 大招: a charged move (weight 0 — it only lands after a 蓄力 turn)
	for m in b.enemy.get("data", {}).get("moves", []):
		if str(m.get("name", "")) == move_name:
			return float(m.get("weight", 1.0)) <= 0.0
	return false


func _cutin(who_name: String, key: String, move_name: String, enemy_side: bool, sfx := "ult_cutin") -> void:
	## 大招 cut-in (Rance style, slow and loud): the screen darkens, speed lines, the portrait swings in big over a coloured
	## band, the move's name slams down with a flash and a shake, a slow drift — then everything sweeps off and the hits land.
	## Ours come in from the left on red; the enemy's mirror it from the right on near-black.
	var layer := Control.new()
	layer.size = Vector2(1280, 720)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.z_index = 60
	add_child(layer)
	if sfx != "":
		Sfx.play(sfx)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0)
	dim.size = layer.size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(dim)
	dim.create_tween().tween_property(dim, "color:a", 0.72, 0.25)
	# the band the portrait sits on: grows out from the left edge, gold rims chase it
	var band := ColorRect.new()
	band.color = Color(0.12, 0.03, 0.08, 0.97) if enemy_side else Color(0.42, 0.07, 0.05, 0.97)
	band.position = Vector2(0, 205)
	band.size = Vector2(1280, 310)
	band.scale = Vector2(0, 1)
	band.pivot_offset = Vector2(1280 if enemy_side else 0, 0)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(band)
	band.create_tween().tween_property(band, "scale:x", 1.0, 0.22).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	for y in [200, 515]:
		var rim := ColorRect.new()
		rim.color = Kit.c("gold")
		rim.size = Vector2(1280, 6)
		rim.position = Vector2(1280 if enemy_side else -1280, y)
		rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(rim)
		rim.create_tween().tween_property(rim, "position:x", 0.0, 0.26).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	# speed lines streaking across the band all through the cut-in
	for k in 18:
		var ln := ColorRect.new()
		ln.color = Color(1, 0.95, 0.8, randf_range(0.25, 0.6))
		ln.size = Vector2(randf_range(160, 420), randf_range(2, 5))
		ln.position = Vector2(1300 if enemy_side else -ln.size.x, randf_range(215, 505))
		ln.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(ln)
		var lt := ln.create_tween().set_loops(3)
		lt.tween_interval(randf_range(0.0, 0.4))
		if enemy_side:
			lt.tween_property(ln, "position:x", -ln.size.x, randf_range(0.22, 0.38)).from(1300.0)
		else:
			lt.tween_property(ln, "position:x", 1300.0, randf_range(0.22, 0.38)).from(-ln.size.x)
	# the portrait: swings in from the left, then drifts slowly (the slow-motion beat), then whips off to the right
	var frame := ColorRect.new()  # a gold frame that travels with the portrait
	frame.color = Kit.c("gold")
	frame.size = Vector2(432, 537)
	var xs: Array = [1326.0, 754.0, 704.0, -530.0] if enemy_side else [-526.0, 104.0, 154.0, 1394.0]  # off, in, drift, out
	frame.position = Vector2(xs[0], 144)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(frame)
	var pic := TextureRect.new()
	pic.texture = Kit.portrait(key, 0.8, 3.2) if key != "" else null
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.size = Vector2(420, 525)
	pic.position = Vector2(xs[0] + 6, 150)
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(pic)
	var pt := pic.create_tween()
	for node in [frame, pic]:
		var off: float = 0.0 if node == frame else 6.0
		var tw: Tween = node.create_tween()
		tw.tween_property(node, "position:x", xs[1] + off, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(node, "position:x", xs[2] + off, 1.05)
		tw.tween_property(node, "position:x", xs[3] + off, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# who, then the skill name slamming down from huge: gold with a thick black outline
	var who := Kit.label(who_name, Kit.FONT_BIG)
	who.add_theme_color_override("font_color", Color.WHITE)
	who.add_theme_constant_override("outline_size", 8)
	who.add_theme_color_override("font_outline_color", Color.BLACK)
	who.position = Vector2(60 if enemy_side else 600, 262)
	who.modulate.a = 0.0
	layer.add_child(who)
	who.create_tween().tween_property(who, "modulate:a", 1.0, 0.2).set_delay(0.2)
	var name_l := Kit.label(move_name, 96)
	name_l.add_theme_color_override("font_color", Color(1.0, 0.35, 0.3) if enemy_side else Kit.c("gold"))
	name_l.add_theme_constant_override("outline_size", 16)
	name_l.add_theme_color_override("font_outline_color", Color.BLACK)
	name_l.position = Vector2(40 if enemy_side else 580, 310)
	name_l.size = Vector2(660, 130)
	name_l.pivot_offset = name_l.size / 2
	name_l.scale = Vector2(2.8, 2.8)
	name_l.modulate.a = 0.0
	layer.add_child(name_l)
	var nt := name_l.create_tween()
	nt.tween_interval(0.28)
	nt.tween_property(name_l, "modulate:a", 1.0, 0.06)
	nt.parallel().tween_property(name_l, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	nt.tween_property(name_l, "scale", Vector2(1.08, 1.08), 0.9)
	await get_tree().create_timer(0.54).timeout
	# the slam: a white flash and a big shake
	var white := ColorRect.new()
	white.color = Color(1, 1, 1, 0.75)
	white.size = layer.size
	white.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(white)
	white.create_tween().tween_property(white, "color:a", 0.0, 0.3)
	Kit.shake(self, 16.0, 0.4)
	await get_tree().create_timer(0.85).timeout
	# sweep everything off; the hits start while it fades
	var out := layer.create_tween()
	out.tween_property(layer, "modulate:a", 0.0, 0.25)
	out.tween_callback(layer.queue_free)
	await get_tree().create_timer(0.12).timeout


func _sfx_act(ev: Dictionary) -> void:
	## 出招音效与角色台词：台词和声线全在 audio.json voices，这里只挑时机（heal / ultimate / attack）和声线（卡牌的 voice，再按身份兜底）
	var skill_id: String = str(ev.get("skill", ""))
	var skill: Dictionary = GameData.get_db().skills.get(skill_id, {})
	var is_big_move := _is_ult(skill) or bool(ev.get("boost", false))

	var u_idx: int = int(ev.get("unit", -1))
	var leader_card: Dictionary = {}
	if u_idx >= 0 and u_idx < b.leaders.size():
		leader_card = b.leaders[u_idx].get("leader", {}).get("card", {})

	var troop: String = leader_card.get("troop", "")
	var is_hero: bool = troop == "lord" or leader_card.get("id", "") == "lord" or u_idx == 0  # unit 0 is always the lord's own
	if is_hero and skill_id != "tuji" and skill_id != "tuci":
		is_big_move = true  # the lord has one plain move (突击 / 突刺); everything else he shouts as a big one
	var role := "lord" if is_hero else "female" if _is_female(leader_card) else "strategist" if troop == "strategist" else "male"  # 女策士（蔡文姬…）走女声

	var moments: Array = ["ultimate", "attack"] if is_big_move else ["attack"]
	for eff in skill.get("effects", []):
		if eff.get("type", "") == "heal":
			moments.push_front("heal")
			break
	# own voice → the troop's (men only: 枪兵「看枪！」) → the default for the role
	var troop_voice := str(Sfx.troop_voices.get(troop, "")) if role == "male" else ""
	Sfx.voice([str(leader_card.get("voice", "")), troop_voice, str(Sfx.voice_defaults.get(role, role))], moments)

	# 配合兵刃破风声，让打击手感扎实
	Sfx.play("slash")


func _sfx_hit(ev: Dictionary, big: bool) -> void:
	## 打击: magic / pierce / heavy / plain hits sound different; each step of a combo climbs a little in pitch
	match ev["t"]:
		"burn":
			Sfx.play("burn")
		"counter", "interrupt":
			Sfx.play("slash")
		_:
			var key := "hit"
			if ev.get("kind", "") == "magic":
				key = "hit_magic"
			elif ev.get("pierce", false):
				key = "hit_pierce"
			elif big:
				key = "hit_heavy"
			Sfx.play(key, 1.0 + 0.04 * minf(float(ev.get("combo", 1)) - 1.0, 8.0))


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


func _alert(title: String, sub: String, color: Color, hold: float) -> void:
	## a big centred warning: a coloured flash round the screen edge, a tall banner, a small line under the title
	var flash := ColorRect.new()
	flash.color = Color(color, 0.0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 38
	add_child(flash)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Color(color, 0.92), 0, 0, Color.TRANSPARENT, 12))
	panel.position = Vector2(0, 250)
	panel.size = Vector2(1280, 190 if sub != "" else 130)
	panel.z_index = 40
	panel.modulate.a = 0.0
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(col)
	var big := Kit.label(title, 72)
	big.add_theme_color_override("font_color", Color.WHITE)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(big)
	if sub != "":
		var small := Kit.label(sub, Kit.FONT_BIG)
		small.add_theme_color_override("font_color", Color.WHITE)
		small.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(small)
	add_child(panel)
	var tw := panel.create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.1)
	tw.tween_interval(hold)
	tw.tween_property(panel, "modulate:a", 0.0, 0.25)
	tw.tween_callback(panel.queue_free)
	var fw := flash.create_tween()
	fw.tween_property(flash, "color:a", 0.32, 0.12)
	fw.tween_property(flash, "color:a", 0.08, 0.2)
	fw.tween_property(flash, "color:a", 0.28, 0.2)
	fw.tween_property(flash, "color:a", 0.0, hold + 0.1)
	fw.tween_callback(flash.queue_free)
	await get_tree().create_timer(hold + 0.35).timeout


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

func _clear_marks() -> void:
	## the battle is over: every lasting effect (auras, status embers, corner badges, the boosted cards' lift) goes now,
	## so nothing keeps floating above the 胜利 banner or the chest pick
	_fx_set({})
	for n in _badges:
		if is_instance_valid(n):
			n.queue_free()
	_badges.clear()
	for c in _cards:
		_boost_pop(c, false)
		c.modulate = Color.WHITE


func _finish_at_start() -> void:
	await get_tree().create_timer(1.0).timeout  # let the opening lines and HP bars show first
	_finish()


func _finish() -> void:
	_busy = true
	_clear_marks()
	Bgm.stop(0.6)
	var save := Game.save
	var won := b.result == "win"
	Sfx.play("win" if won else "lose")
	if won:
		save.record_win(scenario_id)
		if carry:
			var out := b.carry_out()
			save.damage = out[0]
			save.carry_extra.merge(out[1], true)
			save.carry_uses.merge(out[2], true)
		await _banner("胜　利", Kit.c("gold"))
		var q: Dictionary = Game.battle_ctx.get("quest", {})
		var bonus := float(b.mods.get("chest", 0.0))
		var chance := save.chest_chance(b.overkill, boss, bonus)
		var chest := save.chest_after_battle(Game.rng, b.overkill, boss, [], b.enemy["data"]["card"], bonus, str(q.get("id", "")))
		var odds := "首领必掉" if boss else "溢出伤害 %d%% · 宝箱几率 %d%%" % [int(round(b.overkill * 100)), int(round(chance * 100))]
		if chest.is_empty():
			await _banner("%s —— 这次没有宝箱" % odds, Kit.c("gray"))
			await get_tree().create_timer(0.5).timeout
		else:
			var o := PickOverlay.new()
			o.title = "宝箱！（%s）选一张卡带走" % odds
			o.chest = "grand" if boss else "normal"
			o.card_ids = chest.map(func(c): return c["id"])
			o.counts = chest.map(func(c): return save.copies(c["id"]))
			o.set_anchors_preset(Control.PRESET_FULL_RECT)
			add_child(o)
			var i: int = await o.picked
			save.take(chest[i]["id"])
		Game.battle_finished(true)
	else:
		# say why: running out of rounds with HP left is not the same as being wiped out
		var why := {"turns": "回合用尽", "retreat": "全军撤退"}.get(b.lose_reason, "战　败") as String
		var more := {"turns": "时间到了——敌人还剩 %d%% 体力" % int(ceil(100.0 * float(b.enemy["hp"]) / float(b.enemy["max_hp"]))),
				"retreat": "撤出战场，这一轮重新来过"}.get(b.lose_reason, "全军体力耗尽") as String
		await _alert(why, more, Kit.c("red"), 1.6)
		await get_tree().create_timer(0.3).timeout
		Game.battle_finished(false)

