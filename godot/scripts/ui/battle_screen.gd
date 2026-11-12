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
const BADGE_SIZE := 34.0  # BattleFx.badge
const BADGE_STEP := 38.0  # one badge and the gap to the next
const BAND_ALPHA := 0.5  # how much the dark band under our cards hides the battle CG
var _enemy_art: Control
var _enemy_hp: ProgressBar
var _enemy_hp_label: Label
var _enemy_panel: PanelContainer
var _enemy_name: Control
var _intent_label: Label  # v3 意图
var _guard_row: HBoxContainer  # v3 前卫
var _guard_label: Label
var _guard_bar: ProgressBar
var _party_hp: ProgressBar
var _party_hp_label: Label
var _ap_row: HBoxContainer
var _round_label: Label
var _combo_label: Label
var _log: RichTextLabel
var _cards: Array = []  # CardView per leader
var _skill_popup: Control  # open skill-picker for whichever leader was last tapped, or null
var _skill_layer: Control  # the skill buttons laid over each leader who can act (tap one to play it straight away)
var _skill_hide_btn: Button  # 隐藏技能 / 显示技能
var _bar_open := -1  # with 隐藏技能 on: the leader whose skill column was summoned by tapping his card (-1 = none)
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
var _laid_out := false  # the card row has its real positions (the first _refresh runs before the containers sort, every card at one spot)
var _ult_hits := false  # the blows of a physical 大招 play as the big curved cut (BattleFx.ult_slash)
var _intro_wait := 0.0  # seconds of the enemy's entrance line, so 自动 doesn't talk over it
var _enemy_shouted_this_turn := false  # 敌人本回合是否已经战吼过（防止多段行动或灼烧连喊）


func _ready() -> void:
	Bgm.play("boss" if boss else ("ambush" if ambush else "battle"), true)
	var save := Game.save
	if carry:
		var m := Quests.mods(save)
		var afx := Quests.affix_here(save)
		if not afx.is_empty():
			m["affix"] = afx
		b = Battle.start(scenario_id, save.field_leaders(), Game.rng.randi(), save.damage, save.carry_extra, save.carry_uses,
			ambush, m, save.swap_roster())
	else:
		b = Battle.start(scenario_id, save.field_leaders(), Game.rng.randi(), 0, {}, {}, ambush, {}, save.swap_roster())
	_build()
	_apply_speed()
	_log_lines(["[b]【%s】[/b] %d 回合内击破 %s。" % [b.scenario["name"], b.turn_limit, b.enemy["data"]["name"]]])
	if b.mods.has("affix"):
		_log_lines(["[color=red]【词缀·%s】%s[/color]" % [b.mods["affix"]["name"], b.mods["affix"]["desc"]]])
	_log_lines(b.opening)
	b.take_events()
	_refresh()
	_after_layout()
	if b.result != "":  # decided before anyone moved (round 1's 插入 finished a weak enemy): every button is shut, so settle it here
		_busy = true
		_finish_at_start.call_deferred()
	elif auto_on:
		_auto_step.call_deferred()
	_intro_wait = Sfx.voice(_enemy_voices(), ["intro"])  # a named foe's entrance line (吕布「谁敢与我一战！」); generic enemies have none
	if ambush and not b.opening.is_empty() and str(b.opening[0]).contains("埋伏"):
		_banner("埋伏！%s 抢先出手" % b.enemy["data"]["name"], Kit.c("red"))
	if save.cleared.is_empty() and not carry or (carry and save.visited.size() <= 4):
		_tip("点卡上方的技能直接出手（换人也在那一列）· AP 每回合 +%d（最多 %d）· 每位队长每回合行动一次 · 全军共用一条体力" % [
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
	o.tree_exited.connect(func():  # 自动战斗的快慢 is set there
		if is_inside_tree():
			_apply_speed()
			_sync_auto_btn())
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
	enemy_panel.position = Vector2(20, 26)  # the status badges sit on its top edge, like ours on the party bar: they need the screen above it
	enemy_panel.size = Vector2(760, 244) if not has_cg else Vector2(560, 0)
	# a max height of 0 is not "unlimited": with clip_contents it cut the whole CG-mode panel (name, HP bar) away
	enemy_panel.custom_maximum_size = Vector2(760, 244) if not has_cg else Vector2(560, 240)
	enemy_panel.clip_contents = true
	var ebg := Kit.c("enemy_bg")
	if has_cg:
		ebg.a = 0.72
	enemy_panel.add_theme_stylebox_override("panel", Kit.box(ebg, 16, 3 if not has_cg else 2, Kit.c("enemy_border"), 10))
	add_child(enemy_panel)
	_enemy_panel = enemy_panel
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
	info.add_theme_constant_override("separation", 4)
	er.add_child(info)
	_enemy_name = Kit.title_label(e["name"], Kit.FONT_BIG + 2, "red")
	info.add_child(_enemy_name)
	_enemy_hp = Kit.bar(b.enemy["hp"], b.enemy["max_hp"], "red", 26)
	_enemy_hp_label = Kit.bar_text(_enemy_hp)
	info.add_child(_enemy_hp)
	_guard_row = HBoxContainer.new()  # 前卫 (summon): a thin second bar under the boss's, hidden while there is none
	_guard_row.add_theme_constant_override("separation", 10)
	_guard_label = Kit.label("", Kit.FONT_SMALL, "amber")
	_guard_bar = Kit.bar(1, 1, "amber", 12)
	_guard_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_guard_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_guard_row.add_child(_guard_label)
	_guard_row.add_child(_guard_bar)
	_guard_row.visible = false
	info.add_child(_guard_row)
	_intent_label = Kit.label("", Kit.FONT_SMALL, "red")  # 意图: what the enemy will do this round; a long one wraps, it never widens the panel
	_intent_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intent_label.custom_minimum_size = Vector2(10, 0)
	_intent_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_intent_label.max_lines_visible = 2
	info.add_child(_intent_label)
	var stats_row := HBoxContainer.new()  # attack and 护甲 share a line
	stats_row.add_theme_constant_override("separation", 16)
	stats_row.add_child(Kit.label("攻击 %d · 每回合 %d 次" % [e["at"], e["actions"]], Kit.FONT_SMALL, "muted"))
	var arm_l := _armor_label(e)
	if arm_l != null:
		stats_row.add_child(arm_l)
	info.add_child(stats_row)

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
	_party_hp_label = Kit.bar_text(_party_hp)
	pr.add_child(_party_hp)
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
	# so the card itself can run much bigger
	var row := HBoxContainer.new()
	_row = row
	_has_cg = has_cg
	row.position = Vector2(20, 340) if not has_cg else Vector2(20, 440)
	row.add_theme_constant_override("separation", 2)
	add_child(row)
	var card_size := Vector2(240, 336) if not has_cg else Vector2(190, 266)
	# 猛将如云 fields a 5th leader: shrink every card so the row still ends before the action column
	var room := (1060.0 if not has_cg else 1080.0) - row.position.x
	var n := maxi(b.leaders.size(), 1)
	var fit := (room - 2.0 * (n - 1)) / n
	if fit < card_size.x:
		card_size *= fit / card_size.x
	_card_size = card_size
	for i in b.leaders.size():
		var v := _make_card(i)
		row.add_child(v)
		_cards.append(v)
	_skill_layer = Control.new()
	_skill_layer.z_index = 70  # over the opening tip and the enemy's side
	_skill_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_skill_layer)

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
	_defend.add_theme_font_size_override("font_size", Kit.FONT_BODY)  # two lines: AP, then the cut (连续防御 raises it)
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
	_skill_hide_btn = Kit.button("隐藏技能", "gray", Kit.FONT_SMALL)  # next to 设置: the strips float over the cards, this clears them away
	_skill_hide_btn.focus_mode = Control.FOCUS_NONE
	_skill_hide_btn.custom_minimum_size = Vector2(112, 40)
	_skill_hide_btn.position = Vector2(1066, 8)
	_skill_hide_btn.z_index = 5
	_skill_hide_btn.pressed.connect(_toggle_skill_bars)
	add_child(_skill_hide_btn)
	var menu_btn := Kit.button("设置", "gray", Kit.FONT_SMALL)
	menu_btn.custom_minimum_size = Vector2(84, 40)
	menu_btn.position = Vector2(1186, 8)
	menu_btn.z_index = 5
	menu_btn.pressed.connect(_open_settings)
	add_child(menu_btn)


func _make_card(i: int) -> CardView:
	var u: Dictionary = b.leaders[i]
	var opts := {"leader": u["leader"], "skills": false, "lord_name": Game.save.lord_name}
	if str(u["leader"]["card"]["troop"]) == "lord":
		opts["form"] = str(u["leader"]["card"].get("form", ""))  # whichever lord card he fights with (换人 can change it)
	var v := CardView.make(u["leader"]["card"]["id"], _card_size, opts)
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
	var e := _view("e", b.enemy)
	if not _busy:  # while a move plays, each hit / heal event sets the HP numbers itself
		_enemy_hp_label.text = "%d / %d" % [e["hp"], e["max_hp"]]
	var it := b.intent_text() if b.result == "" else ""
	if not _held.has("intent"):  # the old 意图 stays up until the event that changes it plays
		_intent_label.text = ("意图：" + it) if it != "" else ""
		_intent_label.visible = it != ""
		if it != "":
			_tip_on(_intent_label, "敌人意图", _intent_tip())
	_guard_row.visible = not e["guard"].is_empty()
	if _guard_row.visible:
		_guard_label.text = "前卫：%s %d/%d" % [e["guard"]["name"], e["guard"]["hp"], e["guard"]["max_hp"]]
		_guard_bar.max_value = e["guard"]["max_hp"]
		_guard_bar.value = e["guard"]["hp"]
		_tip_on(_guard_row, "前卫：%s" % e["guard"]["name"], "%d/%d，普攻 = 首领攻击 ×%s\n%s" % [e["guard"]["hp"], e["guard"]["max_hp"], str(e["guard"]["strike"]), _status_help("status", "guard")])
	if not _busy:
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
	if not _held.has("round"):  # the round number turns over with its banner, not when the enemy starts to act
		_round_label.text = "最后回合！" if left <= 0 else "第 %d/%d 回合" % [b.round_no, b.turn_limit]
	_round_label.add_theme_color_override("font_color", Kit.c("red") if left <= 1 else Kit.c("text"))
	_combo_label.text = "%d 连击 +%d%%" % [b.combo, b.combo * 10] if b.combo > 0 else ""
	for i in b.leaders.size():
		var u: Dictionary = b.leaders[i]
		var v: CardView = _cards[i]
		v.set_state(u["acted"] or u["confused"] or not b.can_act(i), false)
		v.focus_mode = Control.FOCUS_NONE if (_busy or not b.can_act(i)) else Control.FOCUS_ALL
	_end.disabled = _busy or b.result != ""
	_defend.text = ("防御 AP%d" % b.defend_cost() if b.defend_cost() > 0 else "防御") + ("\n减伤 %d%%" % int(round(b.defend_cut() * 100)))  # the cut grows with 连续防御
	_defend.disabled = _busy or not b.can_defend() or b.result != ""
	_retreat.disabled = _busy or b.result != ""
	_sync_fx()
	_sync_skill_bars.call_deferred()  # after the row has laid itself out
	if not _busy:
		_snap()  # what a coming move's events start from
	if not _busy and b.result == "":  # the fight is over: nothing to press (the 胜利 / 战败 plaque is up)
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


func _sync_skill_bars() -> void:
	## every leader who can act shows his skills as a column of wide buttons in his card's column, stacked up from just above the party bar (the cards keep
	## their place and size, the enemy's side may be covered): one tap plays it.
	## Hidden while anything plays out, in 自动, and once the fight is decided; 换人 is the column's last button
	if _skill_layer == null:
		return
	for ch in _skill_layer.get_children():
		ch.queue_free()
	if _skill_hide_btn != null:
		_skill_hide_btn.text = "显示技能" if _skills_hidden() else "隐藏技能"
	if _busy or auto_on or b.result != "":
		_bar_open = -1
		return
	if not _skills_hidden():
		_bar_open = -1
	var small := _has_cg
	for i in b.leaders.size():
		if i >= _cards.size():
			continue
		if _skills_hidden():  # 隐藏技能: only the column of the leader whose card was just tapped, the same strip as when shown
			if i != _bar_open or not (b.can_act(i) or b.can_swap(i)):
				continue
		elif not (b.can_act(i) or (b.leaders[i].get("slain", false) and b.can_swap(i))):  # 被点名打倒: only 换人 is left in his column
			continue
		var v: CardView = _cards[i]
		var u: Dictionary = b.leaders[i]
		var r := v.get_global_rect()
		var bar := VBoxContainer.new()  # stacked, one wide button per skill, in this leader's column
		bar.add_theme_constant_override("separation", 5)
		var bh := 62.0 if small else 72.0  # big for a thumb; the column sits on the card and reaches up over the HP bar and the enemy, which is fine (user call)
		var skills: Array = [] if u.get("slain", false) else u["leader"]["card"]["skills"]
		for sid in skills:
			var sk: Dictionary = GameData.get_db().skills[sid]
			var ult: bool = _is_ult(sk) or (b.enemy_state("charging") and Battle.can_interrupt(sk))  # 打断 lights up while the enemy winds up
			var btn := Button.new()
			var tag := Kit.skill_tag(sk)
			btn.text = "%s  AP%d%s" % [sk["name"], b.cost(u, sk), (" " + tag) if tag != "" else ""]
			var long_name: bool = str(sk["name"]).length() >= 5  # 「小霸王渡江」 still shows its AP
			btn.add_theme_font_size_override("font_size", (16 if long_name else 20) if small else (20 if long_name else 24))
			btn.icon = Kit.skill_icon(sk)
			btn.expand_icon = true
			btn.add_theme_constant_override("icon_max_width", 28 if small else 32)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.clip_text = true
			btn.focus_mode = Control.FOCUS_NONE
			btn.custom_minimum_size = Vector2(0, bh)
			var edge: Color = Kit.c("gold") if ult else Color(1, 1, 1, 0.35)
			btn.add_theme_stylebox_override("normal", Kit.box(Color(0.07, 0.05, 0.04, 0.82), 8, 2 if ult else 1, edge, 10))
			btn.add_theme_stylebox_override("hover", Kit.box(Color(0.2, 0.14, 0.08, 0.88), 8, 2, Kit.c("gold"), 10))
			btn.add_theme_stylebox_override("pressed", Kit.box(Color(0.3, 0.2, 0.08, 0.88), 8, 2, Kit.c("gold"), 10))
			btn.add_theme_stylebox_override("disabled", Kit.box(Color(0.1, 0.09, 0.08, 0.82), 8, 1, Color(1, 1, 1, 0.15), 10))  # a little see-through (user call): the card and the fight stay visible behind
			btn.add_theme_color_override("font_color", Kit.c("gold") if ult else Color(1, 1, 1))
			btn.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.4))
			btn.disabled = not b.usable(u, sk)
			btn.pressed.connect(func():
				if _held_skill:
					_held_skill = false
					return
				_close_skill_popup()
				_bar_open = -1
				_on_skill(i, sid))
			var split_note := _split_note(u, sk)
			_hold_detail(btn, sk, split_note)
			btn.tooltip_text = "%s　AP%d\n%s%s" % [sk["name"], b.cost(u, sk), Kit.skill_desc(sk), split_note]  # mouse hover shows what it does; on a phone hold it (_hold_detail)
			bar.add_child(btn)
		if not b.swap_options(i).is_empty():  # 换人 is the last button of the column (nearest the card), shown or summoned
			var sw := Button.new()
			sw.text = "换人" + (("  AP%d" % b.swap_cost()) if b.swap_cost() > 0 else "") + ("" if b.round_no >= b.swap_from_round() else " · 第%d回合起" % b.swap_from_round())  # short: it has to fit one card's column
			sw.clip_text = true
			sw.alignment = HORIZONTAL_ALIGNMENT_CENTER
			sw.add_theme_font_size_override("font_size", 16 if small else 20)
			sw.focus_mode = Control.FOCUS_NONE
			sw.custom_minimum_size = Vector2(0, bh)
			sw.add_theme_stylebox_override("normal", Kit.box(Color(0.16, 0.11, 0.03, 0.5), 8, 1, Kit.c("gold").darkened(0.15), 10))  # a shade apart from the skills and more see-through
			sw.add_theme_stylebox_override("hover", Kit.box(Color(0.28, 0.2, 0.06, 0.62), 8, 2, Kit.c("gold"), 10))
			sw.add_theme_stylebox_override("pressed", Kit.box(Color(0.36, 0.25, 0.08, 0.7), 8, 2, Kit.c("gold"), 10))
			sw.add_theme_stylebox_override("disabled", Kit.box(Color(0.1, 0.09, 0.08, 0.45), 8, 1, Color(1, 1, 1, 0.12), 10))
			sw.add_theme_color_override("font_color", Kit.c("gold"))
			sw.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.4))
			sw.disabled = not b.can_swap(i)
			sw.pressed.connect(func():
				_bar_open = -1
				_sync_skill_bars()
				_open_swap(i))
			bar.add_child(sw)  # last, right above the card
		# in the card's column, stacked up from the card's top edge (the card itself stays clear; the HP bar and the enemy may be covered)
		var n := bar.get_child_count()
		var h := n * bh + (n - 1) * 5.0
		bar.position = Vector2(r.position.x - global_position.x, r.position.y - global_position.y - h - 2)
		bar.size = Vector2(r.size.x, h)
		_skill_layer.add_child(bar)


func _skills_hidden() -> bool:
	return bool(Game.options.get("hide_skill_bars", false))


func _toggle_skill_bars() -> void:
	## 隐藏技能: the strips go away to show the whole cards (tap a card for its skills); kept in options.cfg
	Game.set_option("hide_skill_bars", not _skills_hidden())
	_sync_skill_bars()


func _close_skill_popup() -> void:
	if _skill_popup != null:
		_skill_popup.queue_free()
		_skill_popup = null


var _held_skill := false  # a long press just showed the detail: the release that follows must not play the skill


func _split_note(u: Dictionary, sk: Dictionary) -> String:
	## 弓兵 / 贼 (battle.split_troops): their damage skills land half 兵刃 half 谋略 whatever the skill says
	var share := b.split_share(u)
	if share <= 0.0 or not sk["effects"].any(func(e): return e["type"] in ["attack", "magic"]):
		return ""
	return "\n（%s：伤害 %d%% 兵刃 + %d%% 谋略）" % [GameData.get_db().troops[str(u["leader"]["card"]["troop"])]["name"], int(round((1.0 - share) * 100)), int(round(share * 100))]


func _hold_detail(btn: Button, sk: Dictionary, note := "") -> void:
	## hold a skill button for 0.45 s to read what it does (Kit.skill_desc) instead of playing it
	btn.button_down.connect(func():
		_held_skill = false
		await get_tree().create_timer(0.45).timeout
		if is_instance_valid(btn) and btn.button_pressed:
			_held_skill = true
			_show_skill_detail(sk, note))


func _show_skill_detail(sk: Dictionary, note := "") -> void:
	var tag := Kit.skill_tag(sk)
	_show_info("%s　AP%d%s" % [sk["name"], int(sk["cost"]), ("　［%s］" % tag) if tag != "" else ""], Kit.skill_desc(sk) + note)


func _show_info(title: String, body: String) -> void:
	## a dimmed overlay with a gold-edged panel: a skill's description, or what a status / the 意图 means; a fresh touch closes it
	_close_skill_popup()
	var overlay := Control.new()
	overlay.z_index = 75  # above the skill strip (_skill_layer, 70): at 65 its buttons were drawn over this panel
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := Button.new()  # a fresh touch-down anywhere closes it
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.focus_mode = Control.FOCUS_NONE
	for st in ["normal", "hover", "pressed", "focus"]:
		dim.add_theme_stylebox_override(st, Kit.box(Color(0, 0, 0, 0.55), 0, 0, Color.TRANSPARENT, 0))
	dim.button_down.connect(func():
		if Time.get_ticks_msec() - _skill_popup_at > 350:
			_close_skill_popup())
	overlay.add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Kit.box(Kit.c("card"), 14, 3, Kit.c("gold"), 16))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	col.custom_minimum_size = Vector2(460, 0)
	panel.add_child(col)
	col.add_child(Kit.label(title, Kit.FONT_BODY + 2, "gold"))
	var d := Kit.label(body, Kit.FONT_BODY)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.custom_minimum_size = Vector2(460, 0)
	col.add_child(d)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay.add_child(panel)
	add_child(overlay)
	_skill_popup = overlay
	_skill_popup_at = Time.get_ticks_msec()


func _open_skills(i: int) -> void:
	## tapping a card: with 隐藏技能 on it summons that card's column (tap again to put it away); with the skills shown the
	## column is already there (skills + 换人), so the tap does nothing — the old popup only repeated it (user call)
	if _busy or b.result != "" or not (b.can_act(i) or b.can_swap(i)) or not _skills_hidden():
		return
	_close_skill_popup()
	_bar_open = -1 if _bar_open == i else i
	_sync_skill_bars()


func _open_swap(i: int) -> void:
	## 换人: opens the 整备 screen in swap mode (the same cards, details and sorting); whoever comes off is out for the rest of the battle
	_close_skill_popup()
	var opts: Array = b.swap_options(i)
	opts.sort_custom(func(x, y): return SaveData.leader_power(x) > SaveData.leader_power(y))
	var o := PartyOverlay.new()
	o.swap_mode = true
	o.swap_slot = i
	o.swap_field = b.leaders.map(func(u): return "lord" if u["leader"]["card"]["troop"] == "lord" else u["leader"]["card"]["id"])
	o.swap_ids = opts.map(func(ld): return Battle.swap_key(ld))  # a lord card is lordform:<form>
	o.swap_note = (("AP%d" % b.swap_cost()) if b.swap_cost() > 0 else "不费 AP") + "，登场必定触发兵种小技，当回合可出手"
	for k in b.leaders.size():  # a card dragged onto another leader replaces that one instead
		if b.can_swap(k):
			o.swap_ok[k] = b.swap_options(k).map(func(ld): return Battle.swap_key(ld))
	o.swap_picked.connect(func(cid, k): _on_swap(k, cid))
	add_child(o)


func _on_swap(i: int, card_id: String) -> void:
	if _busy or b.result != "" or not b.can_swap(i):
		return
	_log_lines(b.swap(i, card_id))
	await _play(b.take_events())


func _open_tactics() -> void:
	## 军令 over a battle (only the --tactics screenshot demo now: players set 军令 in 整备)
	_close_skill_popup()
	var cards: Array = b.leaders.map(func(u): return u["leader"]["card"])
	cards.append_array(b.roster.map(func(ld): return ld["card"]))
	var o := TacticsOverlay.new()
	o.cards = cards
	add_child(o)


func _toggle_auto() -> void:
	## the 自动 button is on / off; how fast it plays is a setting (设置 → 选项 → 自动战斗慢速)
	auto_on = not auto_on
	_apply_speed()
	_sync_auto_btn()
	_sync_skill_bars()
	if auto_on:
		_close_skill_popup()
		_auto_step()


func _auto_slow() -> bool:
	return auto_on and str(Game.options.get("auto_speed", "fast")) == "slow"


func _apply_speed() -> void:
	## 慢速自动: animations at plain speed (even with 快速 on) and a long beat between actions, to watch the fight
	Engine.time_scale = 1.0 if _auto_slow() else Game.battle_speed()


func _sync_auto_btn() -> void:
	_auto_btn.text = "自动中" if auto_on else "自动"
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
	var step := AutoPlayer.plan(b, AutoPlayer.with_defaults(Game.options.get("tactics", {})))  # 军令
	match str(step["kind"]):
		"act":
			await _on_skill(int(step["unit"]), str(step["skill"]))
		"swap":
			await _on_swap(int(step["unit"]), str(step["card"]))
		"defend":
			await _on_defend()
		_:
			await _on_end_round()


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

func _armor_label(e: Dictionary) -> Label:
	## the enemy's 护甲 and resists in one short line (「藤甲：兵刃抗性 80%　谋略弱点 +100%」), or null when it has neither
	var res := Kit.resist_text(e, false, true)
	var arm := Kit.armor_of(e)
	if res == "" and arm.is_empty():
		return null
	var l := Kit.label(("%s：" % arm["name"] if not arm.is_empty() else "") + res, Kit.FONT_SMALL, "amber")
	if not arm.is_empty():
		_tip_on(l, str(arm["name"]), str(arm["hint"]))
	return l


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


func _after_layout() -> void:
	## the auras, ribbons and badges sit on the cards' rects: draw them once the row has been laid out, or a fight that opens
	## with statuses (先声夺人's 全军 BOOST) piles every card's 「强化」 onto the first card until the next refresh
	await get_tree().process_frame
	_laid_out = true
	if is_inside_tree():
		_sync_fx()


func _sync_fx() -> void:
	## the statuses that last (灼烧 / 破防 / 眩晕 on the enemy, 灼烧 on us, 混乱 / BOOST / 战意 on the cards)
	if b == null or _cards.is_empty() or b.result != "" or not _laid_out:
		return
	var want := {}
	var e := _view("e", b.enemy)
	var pv := _party_view()
	if e["burn_turns"] > 0:
		want["e_burn"] = func(): return BattleFx.embers(self, _enemy_rect(), BattleFx.EMBER, 22, 70.0)
	if e["poison_turns"] > 0:
		want["e_poison"] = func(): return BattleFx.embers(self, _enemy_rect(), Color(0.45, 0.95, 0.35, 0.85), 18, 40.0)
	if e["break_turns"] > 0:
		want["e_break"] = func(): return BattleFx.cracks(self, _enemy_rect(), Color(1.0, 0.82, 0.35, 0.8))
	if e["stunned"]:
		want["e_stun"] = func(): return BattleFx.orbit(self, _enemy_center() + Vector2(0, -80), 80.0, 22.0, 4, BattleFx.GOLD, 11.0)
	if e["charging"] != "":
		var cr := _enemy_rect() if _has_cg else Rect2(_enemy_art.global_position - global_position, _enemy_art.size)
		want["e_charge"] = func(): return BattleFx.charge_aura(self, cr, not _has_cg)
	if not e["stance"].is_empty():
		want["e_stance"] = func(): return BattleFx.glow(self, _enemy_rect(), Color(0.45, 0.95, 0.9, 0.8))
	if b.party_hp * 4 < b.party_max:  # 残血: the party bar pulses red until healed
		want["p_low"] = func(): return BattleFx.glow(self, _party_rect(), Color(1.0, 0.2, 0.15))
	if pv["party_burn"]["turns"] > 0:
		want["p_burn"] = func(): return BattleFx.embers(self, _party_rect(), BattleFx.EMBER, 26, 50.0)
	if pv["party_poison"]["turns"] > 0:
		want["p_poison"] = func(): return BattleFx.embers(self, _party_rect(), Color(0.45, 0.95, 0.35, 0.85), 18, 40.0)
	for i in b.leaders.size():
		var u: Dictionary = _view("u", b.leaders[i], i)
		var id: String = u["leader"]["card"]["id"]
		var r := _card_rect(i)
		if u["confused"]:
			want["conf_%s" % id] = func(): return BattleFx.orbit(self, r.position + Vector2(r.size.x / 2, 8), 56.0, 14.0, 3, BattleFx.VIOLET, 10.0)
		if u["boosted"]:
			want["boost_%s" % id] = func(): return BattleFx.boost_aura(self, r)
		var key := Battle.swap_key(u["leader"])
		if not e["mark"].is_empty() and key == str(e["mark"]["card"]) and not u.get("slain", false):  # 点名: the marked card burns red until the blow comes
			want["mark_%s" % key] = func(): return BattleFx.charge_aura(self, r)
		if u.get("slain", false):  # 被斩: cracked and dark for the rest of the fight
			want["slain_%s" % key] = func(): return BattleFx.cracks(self, r, Color(0.9, 0.2, 0.15, 0.85), 6, true)
		if pv["buff"]["layers"] > 0:
			want["buff_%s" % id] = func(): return BattleFx.glow(self, r, BattleFx.GOLD)
		var tint := Color(0.78, 0.68, 1.0) if u["confused"] else Color.WHITE  # a card that can't act stays grey (set_state dimmed it)
		_cards[i].modulate = Color(0.3, 0.3, 0.3) if u.get("slain", false) else (tint * Color(0.55, 0.55, 0.55) if _cards[i].dimmed else tint)
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
	var tw := Kit.loop(card)
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
	## 角标: a small round badge per status or buff — enemy (灼 破 晕 怒 蓄) on its panel's top edge, party-wide (战 灼 夺) on the party bar's,
	## and per card (混 强) in its top-right corner; the little number is the turns / layers left
	_clear_badges()
	var e := _view("e", b.enemy)
	var pv := _party_view()
	var row: Array = []  # most urgent first, rightmost
	if not e["mark"].is_empty():
		row.append(_tipped(BattleFx.badge("斩", Color(0.9, 0.2, 0.2), -1, false), "点名", "%s，下回合【%s】" % [e["mark"]["who"], e["mark"]["move"]], "mark"))
	if e["charging"] != "":
		row.append(_tipped(BattleFx.badge("蓄", Color(0.9, 0.2, 0.2), -1, false), "蓄力", "下回合【%s】" % e["charging"], "charge"))
	if e["stunned"]:
		row.append(_tipped(BattleFx.badge("晕", Color(0.62, 0.42, 0.95)), "眩晕", "", "stun"))
	if not e["stance"].is_empty():
		row.append(_tipped(BattleFx.badge("反", Color(0.25, 0.78, 0.78), int(e["stance"].get("turns", -1))), "反击架势", "【%s】" % e["stance"]["name"], "stance"))
	if not e["shield"].is_empty():
		row.append(_tipped(BattleFx.badge("盾", Color(0.55, 0.62, 0.72)), "护盾", "%s %d/%d" % [e["shield"]["name"], e["shield"]["hp"], e["shield"]["max_hp"]], "shield"))
	if not e["form"].is_empty():
		row.append(_tipped(BattleFx.badge("阵", Color(0.3, 0.55, 0.95) if e["form"]["vs"] == "magic" else Color(0.85, 0.55, 0.2), int(e["form"]["turns"])), "阵型",
			"%s：%s伤害 -%d%%，剩 %d 回合" % [e["form"]["name"], "兵刃" if e["form"]["vs"] == "attack" else "谋略", int(round(float(e["form"]["cut"]) * 100)), e["form"]["turns"]], "form"))
	if e["at"] > e["data"]["at"] * 1.01:
		row.append(_tipped(BattleFx.badge("怒", Color(0.9, 0.2, 0.2)), "狂暴", "攻击 %d（原本 %d）" % [int(round(e["at"])), int(round(e["data"]["at"]))], "rage"))
	if e["break_turns"] > 0:
		row.append(_tipped(BattleFx.badge("破", Color(0.95, 0.72, 0.2), e["break_turns"]), "破防", "受到伤害 +%d%%，剩 %d 回合" % [int(round(e["break_amount"] * 100)), e["break_turns"]], "break"))
	if e["resist_turns"] > 0:
		row.append(_tipped(BattleFx.badge("抗", Color(0.45, 0.8, 0.95), e["resist_turns"]), "降抗", "双抗 -%d%%，剩 %d 回合" % [int(round(e["resist_down"] * 100)), e["resist_turns"]], "resist"))
	if e["burn_turns"] > 0:
		row.append(_tipped(BattleFx.badge("灼", Color(1.0, 0.5, 0.15), e["burn_turns"]), "灼烧", ("现有体力 -%d%%/回合" % int(round(e["burn_pct"] * 100)) if e["burn_pct"] > 0.0 else "-%d/回合" % e["burn_dmg"]) + "，剩 %d 回合" % e["burn_turns"], "burn"))
	if e["poison_turns"] > 0:
		row.append(_tipped(BattleFx.badge("毒", Color(0.35, 0.8, 0.3), e["poison"]), "中毒", "×%d 层，最大体力 -%d%%/回合，剩 %d 回合" % [e["poison"], int(round(e["poison_pct"] * e["poison"] * 100)), e["poison_turns"]], "poison"))
	var er := Rect2(_enemy_panel.position, _enemy_panel.size)
	_lay_badges(row, Vector2(er.end.x - 6.0, er.position.y - 20.0), er.size.x - 12.0)
	var party: Array = []
	if pv["buff"]["layers"] > 0:
		party.append(_tipped(BattleFx.badge("战", Color(0.95, 0.75, 0.25), pv["buff"]["layers"]), "战意", "×%d 层：攻击 +%d%%%s，剩 %d 回合" % [pv["buff"]["layers"], int(round(pv["buff"]["atk"] * 100)), ("，受伤 -%d%%" % int(round(pv["buff"]["def"] * 100))) if pv["buff"]["def"] > 0.0 else "", pv["buff"]["turns"]], "buff"))
	if pv["party_burn"]["turns"] > 0:
		party.append(_tipped(BattleFx.badge("灼", Color(0.9, 0.3, 0.15), pv["party_burn"]["turns"]), "我军灼烧", "-%d/回合，剩 %d 回合" % [pv["party_burn"]["dmg"], pv["party_burn"]["turns"]], "party_burn"))
	if pv["party_poison"]["turns"] > 0:
		party.append(_tipped(BattleFx.badge("毒", Color(0.35, 0.8, 0.3), pv["party_poison"]["layers"]), "我军中毒", "×%d 层，最大体力 -%d%%/回合，剩 %d 回合" % [pv["party_poison"]["layers"], int(round(pv["party_poison"]["pct"] * pv["party_poison"]["layers"] * 100)), pv["party_poison"]["turns"]], "party_poison"))
	if b.defend_streak > 0 or b.guarded_this_round:  # 连续防御: rounds in a row of 防御 (button or skill)
		var sk_n := b.defend_streak + (1 if b.guarded_this_round else 0)
		party.append(_tipped(BattleFx.badge("守", Color(0.45, 0.62, 0.85), sk_n), "连续防御",
			"已连续 %d 回合：防御按钮 -%d%%，防御技能 +%d%%" % [b.defend_streak, int(round(b.defend_cut() * 100)), int(round(b.streak_bonus() * 100))], "defend_streak"))
	if pv["ap_drain"] > 0:
		party.append(_tipped(BattleFx.badge("夺", Color(0.75, 0.2, 0.3), pv["ap_drain"]), "夺气", "下回合 AP -%d" % pv["ap_drain"], "ap_drain"))
	if not pv["seal"].is_empty():
		party.append(_tipped(BattleFx.badge("封", Color(0.45, 0.3, 0.6), int(pv["seal"]["turns"])), "封技", "我军%s被封，剩 %d 回合" % [Battle.SEAL_NAMES.get(pv["seal"]["kind"], "技能"), pv["seal"]["turns"]], "seal"))
	if pv["loot_chest"] > 0.0:  # 劫掠: the chance of a second chest so far (%)
		party.append(_tipped(BattleFx.badge("掠", Color(0.95, 0.75, 0.25), int(round(pv["loot_chest"] * 100))), "劫掠", "现在 %d%%" % int(round(pv["loot_chest"] * 100)), "loot"))
	var pr := _party_rect()
	_lay_badges(party, Vector2(pr.end.x - 6.0, pr.position.y - 20.0), pr.size.x * 0.5)
	for i in b.leaders.size():
		var u: Dictionary = _view("u", b.leaders[i], i)
		var rr := _card_rect(i)
		var mine: Array = []
		if u["confused"]:
			mine.append(_tipped(BattleFx.badge("混", Color(0.62, 0.42, 0.95)), "混乱", "", "confused"))
		elif u["confuse_next"]:
			mine.append(_tipped(BattleFx.badge("混", Color(0.62, 0.42, 0.95), -1, true), "将要混乱", "", "confuse_next"))
		if u["boosted"]:
			mine.append(_tipped(BattleFx.badge("强", Color(1.0, 0.5, 0.15)), "BOOST", "下次出手 ×%s" % str(GameData.get_db().battle["boost_mult"]), "boosted"))
			var rib := _boost_ribbon(rr)
			_badge_add(rib)
		if pv["counters"].any(func(c): return int(c.get("unit", -1)) == i):
			mine.append(_tipped(BattleFx.badge("反", Color(0.25, 0.78, 0.78)), "反击", "", "counter"))
		if u.get("slain", false):
			mine.append(_tipped(BattleFx.badge("倒", Color(0.45, 0.45, 0.45)), "被斩", "", "slain"))
		elif not e["mark"].is_empty() and Battle.swap_key(u["leader"]) == str(e["mark"]["card"]):
			mine.append(_tipped(BattleFx.badge("点", Color(0.9, 0.15, 0.15)), "被点名", "下回合【%s】" % e["mark"]["move"], "marked"))
		_lay_badges(mine, Vector2(rr.end.x - 6.0, rr.position.y + 6.0), rr.size.x - 40.0)


func _status_help(group: String, key: String) -> String:
	return str(GameData.get_db().battle.get("status_help", {}).get(group, {}).get(key, ""))


func _tipped(n: Control, title: String, line: String, key: String) -> Control:
	## a status badge that explains itself (user call): hover with the mouse shows a tooltip, a tap opens the same text as a panel
	var body := "\n".join([line, _status_help("status", key)].filter(func(s): return s != ""))
	_tip_on(n, title, body)
	return n


func _tip_on(n: Control, title: String, body: String) -> void:
	n.mouse_filter = Control.MOUSE_FILTER_STOP
	n.tooltip_text = title + ("\n" + body if body != "" else "")
	n.set_meta("tip", [title, body])
	for ch in n.find_children("*", "Control", true, false):  # a bar inside (前卫) must not eat the tap
		(ch as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	if n.has_meta("tip_wired"):  # _refresh re-arms the same label every time
		return
	n.set_meta("tip_wired", true)
	n.gui_input.connect(_on_tip_input.bind(n))


func _on_tip_input(ev: InputEvent, n: Control) -> void:
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and not ev.pressed and n.has_meta("tip"):
		var tp: Array = n.get_meta("tip")
		_show_info(str(tp[0]), str(tp[1]))
		n.accept_event()


func _intent_tip() -> String:
	## the meaning of each word in the 意图 line (status_help.intent, matched by prefix; a 前卫's 「X·普攻」 by its suffix)
	var help: Dictionary = GameData.get_db().battle.get("status_help", {}).get("intent", {})
	var keys: Array = help.keys()
	keys.sort_custom(func(x, y): return str(x).length() > str(y).length())
	var lines: Array = []
	for part in b.intent_text().split(" · "):
		for word in part.split("+"):
			for key in keys:
				if word.begins_with(key) or (key == "普攻" and word.ends_with("·普攻")):
					var line := "%s：%s" % [word, help[key]]
					if not lines.has(line):
						lines.append(line)
					break
	return "\n".join(lines)


func _fold_badges(list: Array, room: float) -> Array:
	## as many as fit in `room` px; past that the last slot is 「+N」, and a tap on it lists the ones folded away
	var fit := maxi(1, int((room + BADGE_STEP - BADGE_SIZE) / BADGE_STEP))
	if list.size() <= fit:
		return list
	var lines: Array = []
	for n in list.slice(fit - 1):
		var tp: Array = n.get_meta("tip")
		lines.append("%s：%s" % [tp[0], str(tp[1]).get_slice("\n", 0)])
		n.free()
	var more := _tipped(BattleFx.badge("+%d" % lines.size(), Color(0.5, 0.5, 0.55)), "还有 %d 个状态" % lines.size(), "\n".join(lines), "")
	return list.slice(0, fit - 1) + [more]


func _lay_badges(list: Array, top_right: Vector2, room: float) -> void:
	## a line of badges placed on the screen itself, the first one rightmost
	var shown := _fold_badges(list, room)
	for k in shown.size():
		shown[k].position = top_right - Vector2(BADGE_SIZE + k * BADGE_STEP, 0)
		_badge_add(shown[k])


func _badge_add(n: Control) -> void:
	n.z_index = 48
	add_child(n)
	_badges.append(n)


func _clear_badges() -> void:
	for n in _badges:
		if is_instance_valid(n):
			n.queue_free()
	_badges.clear()


func _enemy_center() -> Vector2:
	## where blows land on the enemy: a battle CG fills the screen, so not its middle (that is behind the skill strip and
	## the cards) but the upper body in the open part above the party bar; a portrait box: a little above its middle (the chest)
	var r := Rect2(_enemy_art.global_position - global_position, _enemy_art.size)
	if _has_cg and _party_hp != null and _party_hp.is_inside_tree():
		var floor_y := _party_hp.global_position.y - global_position.y
		return Vector2(r.get_center().x, clampf(floor_y * 0.5, r.position.y + 60.0, r.end.y))
	return r.get_center() - Vector2(0, r.size.y * 0.12)


func _party_center() -> Vector2:
	return _party_hp.global_position + _party_hp.size / 2 - global_position


func _card_lunge(v: CardView, big := false) -> void:
	## 出招前冲: crouch slightly, spring up toward the enemy with a warm flash, then settle back into the row
	v.pivot_offset = v.size / 2
	var y0 := 0.0
	var jump := -44.0 if big else -32.0
	var sc := 1.14 if big else 1.08
	var tw := v.create_tween()
	tw.tween_property(v, "position:y", y0 + 8.0, 0.05)
	tw.parallel().tween_property(v, "scale", Vector2(0.95, 0.95), 0.05)
	tw.tween_property(v, "position:y", y0 + jump, 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(v, "scale", Vector2(sc, sc), 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(v, "position:y", y0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(v, "scale", Vector2.ONE, 0.16)
	_flash(v, Color(1.35, 1.28, 1.05))


func _enemy_move_tag(move_name: String) -> void:
	## 敌方招式条: a sleek crimson-bordered plaque popping up below the enemy so every move is readable without the log
	if move_name == "" or move_name == "火" or move_name == "毒":
		return
	var l := Kit.label("【%s】" % move_name, Kit.FONT_BIG)
	l.add_theme_color_override("font_color", Color(1.0, 0.92, 0.82))
	l.add_theme_stylebox_override("normal", Kit.box(Color(0.14, 0.03, 0.03, 0.92), 10, 2, Kit.c("red"), 10))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size = Vector2(260, 48)
	l.pivot_offset = l.size * 0.5
	l.position = Vector2(510, 260) if _has_cg else Vector2(270, 212)
	l.scale = Vector2(0.5, 0.5)
	l.z_index = 49
	add_child(l)
	var tw := l.create_tween()
	tw.tween_property(l, "scale", Vector2(1.08, 1.08), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "scale", Vector2.ONE, 0.08)
	tw.tween_interval(0.32)
	tw.tween_property(l, "modulate:a", 0.0, 0.18)
	tw.tween_callback(l.queue_free)


var _act_elem := ""  # the acting skill's element (fire / poison): its magic blows change colour
var _act_troop := ""  # the acting card's troop: its plain blows take that troop's shape (arrows, thrust, heavy arc, cross cut)


## The engine has already applied a whole move when its events start to play, so the screen would show every result
## (晕, 灼, 破, a shield gone, the next 意图, the HP numbers …) before the blow that causes it. Each status field below
## keeps the value shown before the move (`_shown`) until an event that changes it plays (`_held` → `_release`).
## e: = the enemy dict, p: = a battle field (b.buff …), u: = every leader's unit dict, intent = the 意图 line.
const SHOWN_BY := {
	"stun": ["e:stunned", "intent"], "enemy_stunned": ["e:stunned", "intent"],
	"break": ["e:break_turns", "e:break_amount"], "resist_down": ["e:resist_turns", "e:resist_down"],
	"burn_on": ["e:burn_turns", "e:burn_pct", "e:burn_dmg"], "poison_on": ["e:poison_turns", "e:poison", "e:poison_pct"],
	"enemy_charge": ["e:charging", "intent"], "charge_break": ["e:charging", "intent"], "enemy_rage": ["e:at"],
	"stance_on": ["e:stance"], "stance_off": ["e:stance"], "form_on": ["e:form"], "form_off": ["e:form"],
	"shield_on": ["e:shield"], "shield_hit": ["e:shield"], "shield_regen": ["e:shield"], "shield_down": ["e:shield"],
	"guard_on": ["e:guard", "intent"], "guard_hit": ["e:guard"], "guard_down": ["e:guard", "intent"],
	"mark_on": ["e:mark", "intent"], "mark_miss": ["e:mark"], "slain": ["e:mark", "u:slain"],
	"confuse": ["u:confused", "u:confuse_next"], "boost": ["u:boosted"], "counter_on": ["p:counters"],
	"cleanse": ["u:confused", "u:confuse_next", "p:party_poison", "p:party_burn"],
	"buff": ["p:buff"], "enemy_burn_party": ["p:party_burn"], "enemy_poison_party": ["p:party_poison"],
	"enemy_ap_drain": ["p:ap_drain"], "seal_on": ["p:seal"], "seal_off": ["p:seal"], "loot": ["p:loot_chest"],
	"round": ["intent", "round"],
}
const PARTY_FIELDS := ["buff", "party_burn", "party_poison", "ap_drain", "seal", "loot_chest", "counters"]
var _shown := {}  # the statuses as last shown with nothing playing
var _held := {}  # SHOWN_BY fields whose event hasn't played yet


func _snap() -> void:
	var p := {}
	for f in PARTY_FIELDS:
		p[f] = b.get(f).duplicate(true) if b.get(f) is Dictionary or b.get(f) is Array else b.get(f)
	_shown = {"e": b.enemy.duplicate(true), "p": p, "u": b.leaders.map(func(u): return u.duplicate())}


func _view(kind: String, live: Dictionary, i := -1) -> Dictionary:
	## the dict the status display reads: live values, except fields still held at what was shown before the move
	if _held.is_empty() or _shown.is_empty():
		return live
	var old: Dictionary = _shown[kind] if i < 0 else (_shown["u"][i] if i < _shown["u"].size() else {})
	var v := live.duplicate()
	for f in _held:
		if f.begins_with(kind + ":") and old.has(f.substr(2)):
			v[f.substr(2)] = old[f.substr(2)]
	return v


func _party_view() -> Dictionary:
	var live := {}
	for f in PARTY_FIELDS:
		live[f] = b.get(f)
	return _view("p", live)


func _release(ev: Dictionary) -> void:
	## an event plays: what it changes may now show its new value
	var hit := false
	for f in SHOWN_BY.get(ev["t"], []):
		hit = _held.erase(f) or hit
	if hit:
		_refresh()


func _play(events: Array) -> void:
	## plays the engine's events one after another; each kind of event has its own show (_ev_<kind> below)
	_busy = true
	_held = {}
	for ev in events:
		for f in SHOWN_BY.get(ev["t"], []):
			_held[f] = true
	_refresh()
	for ev in events:
		await _play_one(ev)
	_busy = false
	_held = {}
	_refresh()
	if b.result != "":
		await get_tree().create_timer(0.4).timeout
		_finish()
	elif auto_on:
		_auto_step.call_deferred()


func _play_one(ev: Dictionary) -> void:
	Kit.poke()  # an auto battle plays with nobody touching the screen: keep it at full frame rate
	if ev["t"] != "stun":  # 眩晕 waits a beat inside _ev_stun first
		_release(ev)
	match ev["t"]:
		"act":
			await _ev_act(ev)
		"passive":
			await _ev_passive(ev)
		"hit", "interrupt", "burn", "counter", "poison":
			await _ev_hit(ev)
		"resist_down":
			await _ev_resist_down(ev)
		"loot":
			await _ev_loot(ev)
		"burn_on":
			await _ev_burn_on(ev)
		"poison_on":
			await _ev_poison_on(ev)
		"counter_on":
			await _ev_counter_on(ev)
		"swap":
			await _ev_swap(ev)
		"buff":
			await _ev_buff(ev)
		"cleanse":
			await _ev_cleanse(ev)
		"ap_drain":
			await _ev_ap_drain(ev)
		"hurt":
			await _ev_hurt(ev)
		"heal":
			await _ev_heal(ev)
		"guard", "defend":
			await _ev_guard(ev)
		"boost":
			await _ev_boost(ev)
		"stun":
			await _ev_stun(ev)
		"break":
			await _ev_break(ev)
		"ap":
			await _ev_ap(ev)
		"enemy_turn":
			await _ev_enemy_turn(ev)
		"enemy_stunned":
			await _ev_enemy_stunned(ev)
		"enemy_move":
			await _ev_enemy_move(ev)
		"enemy_burn_party":
			await _ev_enemy_burn_party(ev)
		"enemy_poison_party":
			await _ev_enemy_poison_party(ev)
		"enemy_ap_drain":
			await _ev_enemy_ap_drain(ev)
		"enemy_hit":
			await _ev_enemy_hit(ev)
		"enemy_charge":
			await _ev_enemy_charge(ev)
		"enemy_rage":
			await _ev_enemy_rage(ev)
		"enemy_heal":
			await _ev_enemy_heal(ev)
		"confuse":
			await _ev_confuse(ev)
		"charge_break":
			await _ev_charge_break(ev)
		"stance_on":
			await _ev_stance_on(ev)
		"stance_hit":
			await _ev_stance_hit(ev)
		"stance_off":
			await _ev_stance_off(ev)
		"guard_on":
			await _ev_guard_on(ev)
		"guard_hit":
			_ev_guard_hit(ev)
		"mark_on":
			await _ev_mark_on(ev)
		"slain":
			await _ev_slain(ev)
		"mark_miss":
			await _ev_mark_miss(ev)
		"seal_on":
			await _ev_seal_on(ev)
		"seal_off":
			_ev_seal_off(ev)
		"form_on":
			await _ev_form_on(ev)
		"form_off":
			await _ev_form_off(ev)
		"shield_on":
			await _ev_shield_on(ev)
		"shield_hit":
			_ev_shield_hit(ev)
		"shield_regen":
			_ev_shield_regen(ev)
		"shield_down":
			_ev_shield_down(ev)
		"guard_down":
			await _ev_guard_down(ev)
		"round":
			await _ev_round(ev)


func _ev_act(ev: Dictionary) -> void:
	var v: CardView = _cards[ev["unit"]]
	_boost_hits = bool(ev.get("boost", false))
	var used: Dictionary = GameData.get_db().skills.get(str(ev.get("skill", "")), {})
	_card_lunge(v, _is_ult(used) or _boost_hits)
	_sfx_act(ev)
	var kinds: Array = used.get("effects", []).map(func(e): return str(e.get("type", "")))
	_act_troop = str(b.leaders[int(ev["unit"])].get("leader", {}).get("card", {}).get("troop", "")) if int(ev["unit"]) < b.leaders.size() else ""
	var uname := str(used.get("name", ""))
	_act_elem = "thunder" if (str(used.get("elem", "")) == "thunder" or "雷" in uname or "霹雳" in uname or "电" in uname) \
		else "fire" if ("burn" in kinds or "火" in uname) else "poison" if "poison" in kinds else ""
	_ult_hits = _is_ult(used) and used.get("effects", []).any(func(e): return e["type"] in ["attack", "magic"])  # 大招: physical or magic ultimate blows
	if _is_ult(used):
		await _ult_cutin(int(ev["unit"]), str(ev["skill"]))
	if _boost_hits:
		BattleFx.boost_cast(self, _card_rect(ev["unit"]))
		Kit.float_text(self, _card_rect(ev["unit"]).get_center() + Vector2(0, -60), "BOOST ×1.5", Kit.c("gold"), 34)
	await get_tree().create_timer(0.02).timeout


func _ev_passive(ev: Dictionary) -> void:
	## another card's own move (a troop's small-chance trick): its name over the card
	var pu: int = int(ev.get("unit", -1))
	if pu >= 0 and pu < _cards.size():
		_card_lunge(_cards[pu], false)
		Kit.float_text(self, _card_rect(pu).get_center() + Vector2(0, -70), "%s：%s！" % [str(ev["name"]).split("·")[0], str(ev["text"])], Kit.c("gold"), 28)
		await get_tree().create_timer(0.35).timeout


func _ev_hit(ev: Dictionary) -> void:
	var is_rider: bool = ev.get("rider", false)
	if ev["t"] == "interrupt" and int(ev.get("unit", -1)) >= 0 and int(ev["unit"]) < _cards.size():
		var iu: int = int(ev["unit"])
		_card_lunge(_cards[iu], false)
		Kit.float_text(self, _card_rect(iu).get_center() + Vector2(0, -54), "%s 突袭！" % str(ev.get("member", "部队")), Kit.c("gold"), 30)
		BattleFx.interrupt_slash(self, _card_rect(iu).get_center(), _enemy_center())
		await get_tree().create_timer(0.09).timeout
	elif ev["t"] == "counter" and int(ev.get("slot", -1)) >= 0 and int(ev["slot"]) < _cards.size():
		var cs: int = int(ev["slot"])
		_card_lunge(_cards[cs], false)
		Kit.float_text(self, _card_rect(cs).get_center() + Vector2(0, -54), "反击！", Color(0.45, 0.95, 0.9), 32)
	var on_guard: bool = ev.get("guard", false) and _guard_row.visible
	if on_guard:  # the 前卫 takes the blow: sparks on its bar, the boss stands still
		Kit.shake(_guard_row, 6.0, 0.16)
		BattleFx.guard_spark(self, _guard_row.global_position - global_position + _guard_row.size / 2.0)
	else:
		Kit.shake(_enemy_art, 5.0 if is_rider else 9.0, 0.14 if is_rider else 0.2)
		_flash(_enemy_art, Color(1.4, 0.9, 1.7) if is_rider else Color(1.6, 0.6, 0.6))
	var big: bool = not is_rider and ev["dmg"] > b.enemy["max_hp"] * 0.08
	var ratio := float(ev["dmg"]) / maxf(1.0, float(b.enemy["max_hp"]))
	_sfx_hit(ev, big)
	BattleFx.scale = _enemy_fx_scale()
	match ev["t"]:
		"hit":
			if is_rider:
				BattleFx.rider_hit(self, _enemy_center())
			elif _ult_hits:
				if ev["kind"] == "magic":
					BattleFx.ult_magic(self, _enemy_center(), ev["combo"], ratio)
				elif _act_troop == "archer":
					BattleFx.ult_arrow(self, _enemy_center())
				else:
					BattleFx.ult_slash(self, _enemy_center(), ev["combo"], ratio)
				Kit.shake(self, 22.0, 0.3)
			elif ev["kind"] == "magic" or _act_elem == "thunder" or _boost_hits or ev.get("pierce", false) or not BattleFx.troop_hit(self, _enemy_center(), _act_troop, int(ev["combo"])):
				BattleFx.hit(self, _enemy_center(), ev["kind"], ev["combo"], ratio, ev.get("pierce", false), _boost_hits, _act_elem)
			elif ratio > 0.08:
				BattleFx.ring(self, _enemy_center(), Color(1.0, 0.55, 0.3), 14.0, 150.0, 0.36, 7)
		"counter":
			BattleFx.counter(self, _enemy_center())
		"burn":
			BattleFx.flame_lick(self, _enemy_rect())
		"poison":
			BattleFx.poison_cloud(self, _enemy_rect())
		"interrupt":
			if ev.get("kind", "attack") == "magic":
				BattleFx.hit(self, _enemy_center(), "magic", 1, ratio)
			else:
				BattleFx.slash(self, _enemy_center() + Vector2(randf_range(-40, 40), randf_range(-30, 30)), Color(0.9, 0.95, 1.0), 25.0, 170.0, 8.0)
	BattleFx.scale = 1.0
	var crit_hit: bool = ev.get("crit", false)
	if is_rider:
		Kit.float_text(self, _enemy_center() + Vector2(54, -18), "战意 +%d" % ev["dmg"], Color(0.88, 0.72, 1.0), 36)
	elif not (int(ev["dmg"]) == 0 and int(ev.get("shield", 0)) > 0):  # all soaked by the 护盾: only its 「盾 -N」 shows
		var num_at := Vector2(0, -30)
		if ev["t"] == "interrupt":  # several 突袭 in a row: each number on its own spot, by the striking unit's place in the row
			num_at.x = (float(ev.get("unit", 0)) - (_cards.size() - 1) / 2.0) * 56.0
		Kit.float_text(self, _enemy_center() + num_at, ("暴击 " if crit_hit else "") + str(ev["dmg"]),
			Kit.c("gold") if crit_hit else {"hit": Kit.c("amber"), "burn": Kit.c("red"), "poison": Kit.c("green")}.get(ev["t"], Kit.c("purple")), 64 if crit_hit else (52 if big else 40))
	if crit_hit:
		Kit.shake(self, 14.0, 0.2)
		BattleFx.scale = _enemy_fx_scale()
		BattleFx.crit_star(self, _enemy_center())
		BattleFx.scale = 1.0
		await _hit_stop(0.05)
	if float(ev.get("vs", 1.0)) > 1.01 and not is_rider:  # 追击: the combo worked (vs broken / burning / stunned …)
		Kit.float_text(self, _enemy_center() + Vector2(0, -92), "破绽追击！×%s" % str(snappedf(float(ev["vs"]), 0.1)), Color(1.0, 0.6, 0.25), 32)
		BattleFx.ring(self, _enemy_center(), Color(1.0, 0.6, 0.25), 20.0, 170.0, 0.34, 4)
	Kit.tween_bar(_enemy_hp, ev["hp"])
	_enemy_hp_label.text = "%d / %d" % [ev["hp"], b.enemy["max_hp"]]
	if ev["t"] == "hit" and not is_rider and ev["combo"] >= 2:
		_combo_label.text = "%d 连击 +%d%%" % [ev["combo"], ev["combo"] * 10]
		_combo_heat(int(ev["combo"]))
		Kit.pop(_combo_label, 1.3 if ev["combo"] < 8 else 1.5)
	if int(ev.get("hp", 1)) <= 0:
		BattleFx.scale = _enemy_fx_scale()
		BattleFx.kill_blow(self, _enemy_center())
		BattleFx.scale = 1.0
		_flash(_enemy_art, Color(2.2, 2.0, 1.8))
		Kit.shake(self, 20.0, 0.32)
		await _kill_freeze()
	elif big:
		Kit.shake(self, 6.0 + 24.0 * minf(ratio, 0.3), 0.18)
		await get_tree().create_timer(0.06).timeout  # a beat of hit-stop on the heavy ones
	if _ult_hits and ev["t"] == "hit" and not is_rider:
		await get_tree().create_timer(0.22).timeout  # let the big cut finish before the next blow
	if ev["t"] == "interrupt" and int(ev.get("hp", 1)) > 0:
		await get_tree().create_timer(0.3).timeout  # 突袭 come one by one: each strike reads before the next (the killing one freezes instead)
	await get_tree().create_timer(0.07 if is_rider else 0.16).timeout


func _ev_resist_down(ev: Dictionary) -> void:
	## 射穿甲缝: a steel arrow streak through the armour, 双抗 down
	Sfx.play("break")
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.slash(self, _enemy_center(), BattleFx.STEEL, -12.0, 420.0, 6.0)
	BattleFx.burst(self, _enemy_center(), Color(0.45, 0.8, 0.95), 12, 10.0, 96.0, 3.0, 0.24)
	BattleFx.scale = 1.0
	_flash(_enemy_art, Color(0.8, 1.2, 1.6))
	Kit.float_text(self, _enemy_center() + Vector2(0, -40), "甲缝洞穿　双抗 -%d%%" % int(round(float(ev["amount"]) * 100)), Color(0.55, 0.85, 1.0), 34)
	_refresh()
	await get_tree().create_timer(0.3).timeout


func _ev_loot(ev: Dictionary) -> void:
	## 劫掠: gold scatters, the haul odds float up
	Sfx.play("buff")
	BattleFx.burst(self, _enemy_center(), BattleFx.GOLD, 16, 12.0, 130.0, 5.0, 0.32)
	BattleFx.embers(self, _enemy_rect(), BattleFx.GOLD, 18, 80.0, true)
	Kit.float_text(self, _enemy_center() + Vector2(0, -40), "劫掠！宝箱 %d%%　多卡 %d%%" % [int(round(float(ev["chest"]) * 100)), int(round(float(ev["card"]) * 100))], Kit.c("gold"), 32)
	_refresh()
	await get_tree().create_timer(0.3).timeout


func _ev_burn_on(_ev: Dictionary) -> void:
	Sfx.play("burn")
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.flame_lick(self, _enemy_rect())
	BattleFx.scale = 1.0
	_flash(_enemy_art, Color(1.8, 0.75, 0.35))
	Kit.float_text(self, _enemy_center() + Vector2(0, -30), "灼烧！", Kit.c("red"), 40)
	_refresh()
	await get_tree().create_timer(0.26).timeout


func _ev_poison_on(ev: Dictionary) -> void:
	Sfx.play("burn")
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.poison_cloud(self, _enemy_rect())
	BattleFx.scale = 1.0
	_flash(_enemy_art, Color(0.65, 1.5, 0.65))
	Kit.float_text(self, _enemy_center() + Vector2(0, -30), "中毒 ×%d" % int(ev.get("layers", 1)), Kit.c("green"), 40)
	_refresh()
	await get_tree().create_timer(0.26).timeout


func _ev_counter_on(ev: Dictionary) -> void:
	Sfx.play("guard")
	var cu: int = int(ev.get("unit", 0))
	BattleFx.counter_stance(self, _card_rect(cu))
	Kit.pop(_cards[cu], 1.08)
	Kit.float_text(self, _card_rect(cu).get_center() + Vector2(0, -40), "反击架势", Color(0.45, 0.95, 0.9), 34)
	_refresh()
	await get_tree().create_timer(0.26).timeout


func _ev_swap(ev: Dictionary) -> void:
	var leaving: CardView = _cards[ev["unit"]]
	var ot := leaving.create_tween().set_parallel()
	ot.tween_property(leaving, "modulate:a", 0.0, 0.18)
	ot.tween_property(leaving, "position:y", leaving.position.y + 40.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.18).timeout
	_rebuild_card(ev["unit"])
	await get_tree().process_frame  # the row lays the new card out first, then it leaps in from below
	var arriving: CardView = _cards[ev["unit"]]
	var home := arriving.position
	arriving.position.y = home.y + 140.0
	arriving.modulate.a = 0.0
	var nt := arriving.create_tween().set_parallel()
	nt.tween_property(arriving, "position:y", home.y, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	nt.tween_property(arriving, "modulate:a", 1.0, 0.12)
	await get_tree().create_timer(0.24).timeout
	Sfx.play("guard")
	var arc := _card_rect(ev["unit"])
	BattleFx.ring(self, arc.get_center(), BattleFx.GOLD, 20.0, 170.0, 0.34, 6)
	BattleFx.burst(self, Vector2(arc.get_center().x, arc.end.y - 20.0), BattleFx.GOLD, 12, 10.0, 110.0, 4.0, 0.3)
	Kit.shake(arriving, 4.0, 0.12)
	_party_hp.max_value = ev["max"]
	Kit.tween_bar(_party_hp, ev["hp"])
	_party_hp_label.text = "%d / %d" % [ev["hp"], ev["max"]]
	Kit.float_text(self, _cards[ev["unit"]].global_position - global_position + Vector2(100, 60), "登场！", Kit.c("gold"), 40)
	Kit.pop(_cards[ev["unit"]], 1.08)
	await get_tree().create_timer(0.35).timeout


func _ev_buff(ev: Dictionary) -> void:
	Sfx.play("buff")
	Kit.float_text(self, _party_center(), "战意 ×%d" % ev["layers"], Kit.c("gold"), 36)
	BattleFx.buff_cast(self, range(_cards.size()).map(func(i): return _card_rect(i).get_center()))
	_refresh()
	await get_tree().create_timer(0.3).timeout


func _ev_cleanse(ev: Dictionary) -> void:
	Kit.float_text(self, _party_center(), "状态解除" if ev["n"] > 0 else "无状态", Kit.c("green"), 34)
	BattleFx.cleanse_wave(self, _cards_rect())
	_refresh()
	await get_tree().create_timer(0.3).timeout


func _ev_ap_drain(ev: Dictionary) -> void:
	var pips: Array = _ap_row.get_children().filter(func(n): return n is Panel)
	var gone: Array = pips.slice(int(ev["ap"]), int(ev["ap"]) + int(ev["amount"]))
	BattleFx.drain_shatter(self, gone, gone.size())
	Kit.float_text(self, _party_center() + Vector2(300, 0), "AP -%d" % ev["amount"], Kit.c("red"), 34)
	await get_tree().create_timer(0.35).timeout


func _ev_hurt(ev: Dictionary) -> void:
	_flash(_party_box, Color(1.6, 0.5, 0.5))
	Kit.shake(_party_box, 7.0, 0.18)
	BattleFx.slash(self, _party_center(), BattleFx.BLOOD, -25.0, 180.0, 10.0)
	Kit.float_text(self, _party_center(), "-%d" % ev["dmg"], Kit.c("red"), 36)
	Kit.tween_bar(_party_hp, ev["hp"])
	_party_hp_label.text = "%d / %d" % [ev["hp"], b.party_max]
	await get_tree().create_timer(0.3).timeout


func _ev_heal(ev: Dictionary) -> void:
	Sfx.play("heal")
	BattleFx.heal_wave(self, _party_rect())
	Kit.float_text(self, _party_center(), "+%d" % ev["amt"], Kit.c("green"))
	Kit.tween_bar(_party_hp, ev["hp"])
	_party_hp_label.text = "%d / %d" % [ev["hp"], b.party_max]
	await get_tree().create_timer(0.3).timeout


func _ev_guard(ev: Dictionary) -> void:
	Sfx.play("guard")
	if ev["t"] == "defend":  # the 防御 button: the whole party raises shields (audio.json voice_defaults.guard)
		Sfx.voice([str(Sfx.voice_defaults.get("guard", ""))], ["guard"])
	BattleFx.shield_wall(self, _party_rect(), ev["t"] == "defend")
	Kit.float_text(self, _party_center(), "减伤 %d%%" % int(round(ev["cut"] * 100)), Kit.c("blue"), 32)
	await get_tree().create_timer(0.3).timeout


func _ev_boost(ev: Dictionary) -> void:
	Sfx.play("buff")
	for k in ev["units"]:
		Kit.pop(_cards[k], 1.08)
		_flash(_cards[k], Color(1.5, 1.35, 0.7))
		BattleFx.boost_cast(self, _card_rect(k))
	Kit.float_text(self, _party_center(), "BOOST", Kit.c("gold"), 34)
	await get_tree().create_timer(0.3).timeout


func _ev_stun(ev: Dictionary) -> void:
	await get_tree().create_timer(0.25).timeout  # the blow's numbers read first, then the enemy reels
	_release(ev)  # 晕 badge, the star ring and 意图：眩晕 come in now, with the burst
	Kit.float_text(self, _enemy_center(), "眩晕！" if ev["ok"] else "未生效", Kit.c("purple"), 36)
	if ev["ok"]:
		Sfx.play("stun")
		BattleFx.stun_burst(self, _enemy_center() + Vector2(0, -50))
	await get_tree().create_timer(0.3).timeout


func _ev_break(ev: Dictionary) -> void:
	Sfx.play("break")
	Kit.float_text(self, _enemy_center(), "破防 +%d%%" % int(round(ev["amount"] * 100)), Kit.c("amber"), 34)
	var crack := BattleFx.break_flash(self, _enemy_rect())
	crack.get_tree().create_timer(0.8).timeout.connect(crack.queue_free)
	await get_tree().create_timer(0.3).timeout


func _ev_ap(ev: Dictionary) -> void:
	_refresh()
	var all_pips: Array = _ap_row.get_children().filter(func(n): return n is Panel)
	var top_ap: int = int(ev.get("ap", b.ap))
	var gained: Array = all_pips.slice(maxi(0, top_ap - int(ev["amount"])), top_ap)
	BattleFx.ap_gain(self, gained)
	Kit.float_text(self, _party_center() + Vector2(300, 0), "AP +%d" % ev["amount"], Kit.c("gold"), 34)
	await get_tree().create_timer(0.25).timeout


func _ev_enemy_turn(_ev: Dictionary) -> void:
	_enemy_shouted_this_turn = false
	await _banner("%s 的行动" % b.enemy["data"]["name"], Kit.c("red"))


func _ev_enemy_stunned(_ev: Dictionary) -> void:
	Kit.float_text(self, _enemy_center(), "眩晕中，无法行动", Kit.c("purple"), 32)
	await get_tree().create_timer(0.45).timeout


func _ev_enemy_move(ev: Dictionary) -> void:
	_enemy_move_tag(str(ev.get("move", "")))
	await get_tree().create_timer(0.18).timeout


func _ev_enemy_burn_party(_ev: Dictionary) -> void:
	Sfx.play("burn")
	BattleFx.flame_lick(self, _party_rect())
	Kit.float_text(self, _party_center(), "我军灼烧！", Kit.c("red"), 38)
	_refresh()
	await get_tree().create_timer(0.28).timeout


func _ev_enemy_poison_party(ev: Dictionary) -> void:
	Sfx.play("burn")
	BattleFx.poison_cloud(self, _party_rect())
	Kit.float_text(self, _party_center(), "我军中毒 ×%d！" % int(ev.get("layers", 1)), Kit.c("green"), 38)
	_refresh()
	await get_tree().create_timer(0.28).timeout


func _ev_enemy_ap_drain(ev: Dictionary) -> void:
	Sfx.play("break")
	BattleFx.ring(self, _party_center() + Vector2(300, 0), BattleFx.BLOOD, 14.0, 95.0, 0.3, 5)
	Kit.float_text(self, _party_center() + Vector2(300, 0), "夺气 -%d" % int(ev.get("amount", 1)), Kit.c("red"), 36)
	_refresh()
	await get_tree().create_timer(0.26).timeout


func _ev_enemy_hit(ev: Dictionary) -> void:
	var mv_name := str(ev.get("move", ""))
	var is_fire: bool = mv_name in ["火", "毒"]  # a burn / poison tick on us: no move plaque, no lunge, no war cry
	if not is_fire and _enemy_big_move(mv_name):  # the wound-up 大招 lands: cut-in, and it roars
		var ed: Dictionary = b.enemy.get("data", {})
		Sfx.voice(_enemy_voices(), ["roar", "attack"])
		_enemy_shouted_this_turn = true
		await _cutin(str(ed.get("name", "")), str(ed.get("portrait", "")), mv_name, true)
	elif not is_fire:
		_enemy_move_tag(mv_name)
	var heavy_mv: Dictionary = b._move_named(mv_name)
	if not is_fire and (_enemy_big_move(mv_name) or float(heavy_mv.get("power", 0.0)) >= 1.5):  # a heavy blow: winds back, then lunges at the camera
		_enemy_art.pivot_offset = _enemy_art.size / 2.0
		var tws := _enemy_art.create_tween()
		tws.tween_property(_enemy_art, "scale", Vector2(0.93, 0.93), 0.12).set_trans(Tween.TRANS_QUAD)
		tws.tween_property(_enemy_art, "scale", Vector2(1.18, 1.18), 0.08).set_trans(Tween.TRANS_BACK)
		tws.tween_property(_enemy_art, "scale", Vector2.ONE, 0.18)
		await get_tree().create_timer(0.2).timeout
	else:
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
	if mv_name != "毒":
		_flash(_party_box, Color(1.6, 0.6, 0.6))
	if mv_name == "毒":
		BattleFx.poison_cloud(self, _party_rect())
		_flash(_party_box, Color(0.7, 1.5, 0.8))
	elif is_fire:
		BattleFx.flame_lick(self, _party_rect())
	elif _enemy_big_move(mv_name):
		BattleFx.enemy_ult_slash(self, _cards_rect())
		Kit.shake(self, 22.0, 0.4)
		for c in _cards:
			Kit.shake(c, 9.0, 0.3)
	elif int(ev.get("mark", -1)) >= 0 and int(ev["mark"]) < _cards.size():  # 点名 lands: an X cut across the marked card
		var mr := _card_rect(int(ev["mark"]))
		BattleFx.slash(self, mr.get_center(), Color(1.0, 0.15, 0.1), -40.0, mr.size.length() * 1.1, 16.0)
		BattleFx.slash(self, mr.get_center(), Color(1.0, 0.85, 0.75), 40.0, mr.size.length() * 1.1, 10.0, 0.1)
		BattleFx.burst(self, mr.get_center(), Color(1.0, 0.25, 0.15), 16, 20.0, 170.0, 6.0, 0.35)
		_flash(_cards[int(ev["mark"])], Color(2.2, 0.5, 0.45))
		Kit.shake(_cards[int(ev["mark"])], 16.0, 0.35)
		Kit.shake(self, 14.0, 0.3)
		BattleFx.vignette(self, Color(0.8, 0.0, 0.0, 0.5), 0.6)
	else:
		BattleFx.claw(self, _cards_rect().get_center(), float(ev["dmg"]) / maxf(1.0, float(b.party_max)), float(ev["cut"]))
		for c in _cards:
			Kit.shake(c, 5.0, 0.16)
	Kit.float_text(self, _party_center(), ("暴击 " if ev.get("crit", false) else "") + "-%d" % ev["dmg"], Kit.c("red"), 56 if ev.get("crit", false) else 44)
	Kit.tween_bar(_party_hp, ev["hp"])
	_party_hp_label.text = "%d / %d" % [ev["hp"], b.party_max]
	await get_tree().create_timer(0.35).timeout


func _ev_enemy_charge(_ev: Dictionary) -> void:
	if not _enemy_shouted_this_turn:
		Sfx.voice(_enemy_voices(), ["roar", "attack"])
		_enemy_shouted_this_turn = true
	Sfx.play("charge")
	Kit.float_text(self, _enemy_center() + Vector2(0, -40), "蓄力！", Kit.c("red"), 44)
	Kit.shake(_enemy_art, 5.0, 0.4)
	_refresh()
	await get_tree().create_timer(0.45).timeout


func _ev_enemy_rage(_ev: Dictionary) -> void:
	if not _enemy_shouted_this_turn:
		Sfx.voice(_enemy_voices(), ["roar", "attack"])
		_enemy_shouted_this_turn = true
	Kit.float_text(self, _enemy_center() + Vector2(0, -40), "狂暴！", Kit.c("red"), 44)
	_flash(_enemy_art, Color(1.8, 0.5, 0.5))
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.ring(self, _enemy_center(), BattleFx.BLOOD, 20.0, 200.0, 0.4, 7)
	BattleFx.embers(self, _enemy_rect(), Color(1.0, 0.25, 0.2, 0.9), 22, 90.0, true)
	BattleFx.scale = 1.0
	_refresh()
	await get_tree().create_timer(0.4).timeout


func _ev_enemy_heal(ev: Dictionary) -> void:
	Sfx.play("heal")
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.heal_wave(self, _enemy_rect())
	BattleFx.scale = 1.0
	Kit.float_text(self, _enemy_center(), "+%d" % ev["amt"], Kit.c("green"), 40)
	Kit.tween_bar(_enemy_hp, ev["hp"])
	_enemy_hp_label.text = "%d / %d" % [ev["hp"], b.enemy["max_hp"]]
	await get_tree().create_timer(0.35).timeout


func _ev_confuse(ev: Dictionary) -> void:
	Kit.pop(_cards[ev["unit"]], 1.06)
	Kit.float_text(self, _cards[ev["unit"]].global_position - global_position + Vector2(100, 60),
		"重创" if ev.get("mark", false) else "混乱", Kit.c("red") if ev.get("mark", false) else Kit.c("purple"), 32)
	BattleFx.stun_burst(self, _card_rect(ev["unit"]).position + Vector2(_card_rect(ev["unit"]).size.x / 2, 30))
	BattleFx.burst(self, _card_rect(ev["unit"]).get_center(), BattleFx.VIOLET, 10, 20.0, 110.0, 5.0)
	await get_tree().create_timer(0.3).timeout


func _ev_charge_break(ev: Dictionary) -> void:
	## 破招: the wind-up shatters, an AP flies back
	Sfx.play("break")
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.burst(self, _enemy_center(), Kit.c("gold"), 22, 30.0, 220.0, 6.0)
	BattleFx.scale = 1.0
	_flash(_enemy_art, Color(2.0, 1.8, 0.9))
	Kit.shake(self, 16.0, 0.26)
	await _alert("破招！", "【%s】被打断　AP +%d" % [ev["move"], int(ev.get("gain", 1))], Kit.c("gold"), 0.9)
	_refresh()
	var pips2: Array = _ap_row.get_children().filter(func(n): return n is Panel)
	var top2: int = int(ev.get("ap", b.ap))
	BattleFx.ap_gain(self, pips2.slice(maxi(0, top2 - int(ev.get("gain", 1))), top2))
	await get_tree().create_timer(0.2).timeout


func _ev_stance_on(_ev: Dictionary) -> void:
	Sfx.play("guard")
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.counter_stance(self, _enemy_rect())
	BattleFx.scale = 1.0
	Kit.float_text(self, _enemy_center() + Vector2(0, -40), "架势！兵刃会被反击", Kit.c("red"), 38)
	_refresh()
	await get_tree().create_timer(0.4).timeout


func _ev_stance_hit(ev: Dictionary) -> void:
	## the enemy answers the card that struck it
	var su: int = int(ev.get("unit", 0))
	Sfx.play("enemy_hit")
	if su >= 0 and su < _cards.size():
		BattleFx.claw(self, _card_rect(su).get_center(), float(ev["dmg"]) / maxf(1.0, float(b.party_max)), 0.0)
		Kit.shake(_cards[su], 8.0, 0.2)
	Kit.float_text(self, _party_center(), "反击 -%d" % ev["dmg"], Kit.c("red"), 40)
	Kit.tween_bar(_party_hp, ev["hp"])
	_party_hp_label.text = "%d / %d" % [ev["hp"], b.party_max]
	await get_tree().create_timer(0.3).timeout


func _ev_stance_off(ev: Dictionary) -> void:
	if ev.get("broken", false):  # 眩晕 / 破招 shattered it (not just run out)
		Sfx.play("break")
		BattleFx.scale = _enemy_fx_scale()
		BattleFx.slash(self, _enemy_center(), Color(0.45, 0.95, 0.9), -38.0, 260.0, 10.0)
		BattleFx.burst(self, _enemy_center(), Color(0.82, 1.0, 0.98), 16, 14.0, 150.0, 4.0, 0.3)
		BattleFx.scale = 1.0
		Kit.float_text(self, _enemy_center() + Vector2(0, -40), "架势击破！", Kit.c("gold"), 42)
		Kit.shake(self, 10.0, 0.2)
		await get_tree().create_timer(0.35).timeout
	_refresh()


func _ev_guard_on(ev: Dictionary) -> void:
	Sfx.play("charge")
	Kit.float_text(self, _enemy_center() + Vector2(0, -40), "前卫：%s！" % ev["name"], Kit.c("amber"), 40)
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.shield_wall(self, _enemy_rect())
	BattleFx.scale = 1.0
	_refresh()
	Kit.pop(_guard_row, 1.1)
	await get_tree().create_timer(0.45).timeout


func _ev_guard_hit(ev: Dictionary) -> void:
	_guard_bar.max_value = ev["max"]
	Kit.tween_bar(_guard_bar, ev["hp"])


func _ev_mark_on(ev: Dictionary) -> void:
	## 点名: a red line from the enemy to the marked card
	Sfx.play("charge")
	var mu: int = int(ev.get("unit", 0))
	if mu >= 0 and mu < _cards.size():
		BattleFx.arrow(self, _enemy_center(), _card_rect(mu).get_center(), Color(1.0, 0.25, 0.15), 0.0, 1.6)
		await get_tree().create_timer(0.18).timeout
		await _mark_stamp(mu)
	await _alert("点名", "下回合【%s】→ %s　换下他就扑空，不换就被打倒" % [ev["move"], b.unit_name(b.leaders[mu]) if mu < b.leaders.size() else ""], Kit.c("red"), 0.9)
	_refresh()


func _ev_slain(ev: Dictionary) -> void:
	## 点名 landed: the card goes dark and cracks, out of action this fight
	var xu: int = int(ev.get("unit", 0))
	if xu >= 0 and xu < _cards.size():
		Sfx.play("break")
		var xc: Control = _cards[xu]
		xc.create_tween().tween_property(xc, "modulate", Color(0.3, 0.3, 0.3), 0.45)
		BattleFx.burst(self, _card_rect(xu).get_center(), Color(0.55, 0.5, 0.5), 12, 20.0, 130.0, 4.0, 0.3)
		Kit.float_text(self, _card_rect(xu).get_center() + Vector2(0, -40), "被打倒！", Kit.c("red"), 44)
		await get_tree().create_timer(0.6).timeout
	_refresh()


func _ev_mark_miss(_ev: Dictionary) -> void:
	Sfx.play("guard")
	Kit.float_text(self, _party_center() + Vector2(0, -50), "扑空！", Kit.c("gold"), 44)
	await get_tree().create_timer(0.35).timeout


func _ev_seal_on(ev: Dictionary) -> void:
	Sfx.play("break")
	BattleFx.ring(self, _party_center(), Color(0.6, 0.4, 0.9), 20.0, 260.0, 0.4, 6)
	Kit.float_text(self, _party_center() + Vector2(0, -50), "%s被封！" % Battle.SEAL_NAMES.get(str(ev["kind"]), "技能"), Kit.c("purple"), 40)
	_refresh()
	await get_tree().create_timer(0.4).timeout


func _ev_seal_off(_ev: Dictionary) -> void:
	_refresh()


func _ev_form_on(ev: Dictionary) -> void:
	Sfx.play("guard")
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.ring(self, _enemy_center(), Color(0.3, 0.55, 0.95) if ev["vs"] == "magic" else Color(0.85, 0.55, 0.2), 30.0, 220.0, 0.45, 7)
	BattleFx.scale = 1.0
	Kit.float_text(self, _enemy_center() + Vector2(0, -40), "变阵【%s】：%s" % [ev["name"], "挡谋略" if ev["vs"] == "magic" else "挡兵刃"], Kit.c("amber"), 38)
	_refresh()
	await get_tree().create_timer(0.4).timeout


func _ev_form_off(ev: Dictionary) -> void:
	if ev.get("broken", false):
		Sfx.play("break")
		Kit.float_text(self, _enemy_center() + Vector2(0, -40), "阵型大乱！", Kit.c("gold"), 42)
		Kit.shake(self, 8.0, 0.18)
		await get_tree().create_timer(0.3).timeout
	_refresh()


func _ev_shield_on(ev: Dictionary) -> void:
	Sfx.play("guard")
	BattleFx.scale = _enemy_fx_scale()
	BattleFx.shield_wall(self, _enemy_rect(), true)
	BattleFx.scale = 1.0
	Kit.float_text(self, _enemy_center() + Vector2(0, -40), "护盾【%s】%d" % [ev["name"], ev["hp"]], Kit.c("amber"), 38)
	_refresh()
	await get_tree().create_timer(0.4).timeout


func _ev_shield_hit(ev: Dictionary) -> void:
	BattleFx.guard_spark(self, _enemy_center() + Vector2(randf_range(-40, 40), randf_range(-30, 30)))
	Kit.float_text(self, _enemy_center() + Vector2(70, -10), "盾 -%d" % ev["dmg"], Color(0.75, 0.82, 0.95), 28)


func _ev_shield_regen(ev: Dictionary) -> void:
	Kit.float_text(self, _enemy_center() + Vector2(70, -10), "盾 +%d" % ev["add"], Color(0.75, 0.82, 0.95), 30)
	_refresh()


func _ev_shield_down(_ev: Dictionary) -> void:
	Sfx.play("break")
	Kit.float_text(self, _enemy_center() + Vector2(0, 30), "护盾碎了！", Kit.c("gold"), 42)
	BattleFx.burst(self, _enemy_center(), Color(0.8, 0.88, 1.0), 16, 14.0, 170.0, 4.0, 0.3)
	Kit.shake(self, 8.0, 0.18)
	_refresh()


func _ev_guard_down(ev: Dictionary) -> void:
	Kit.float_text(self, _enemy_center() + Vector2(0, 30), "%s 溃散！" % ev["name"], Kit.c("gold"), 40)
	Kit.shake(self, 10.0, 0.2)
	var gc := _guard_row.global_position - global_position + _guard_row.size / 2.0
	BattleFx.ring(self, gc, BattleFx.STEEL, 10.0, 180.0, 0.36, 6)
	BattleFx.burst(self, gc, Color(1.0, 0.85, 0.4), 14, 10.0, 120.0, 4.0, 0.3)
	_refresh()
	await get_tree().create_timer(0.3).timeout


func _ev_round(ev: Dictionary) -> void:
	var left: int = b.turn_limit - int(ev["n"])
	if left <= 0:  # the last round: lose it and the run is lost — make it impossible to miss
		await _alert("最后回合！", "击破 %s，否则撤退" % b.enemy["data"]["name"], Kit.c("red"), 1.3)
	elif left == 1:
		await _alert("还剩 2 回合", "", Kit.c("orange") if Kit.pal().has("orange") else Kit.c("gold"), 0.8)
	else:
		await _banner("第 %d 回合" % ev["n"], Kit.c("gold"))


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
	return bool(skill.get("special", false)) or bool(skill.get("per_battle", false)) or (skill.get("uses", null) != null and int(skill["uses"]) == 1) or int(skill.get("cost", 0)) >= 3


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
	if pic.texture == null:  # no portrait drawn: no empty gold frame sliding across
		frame.visible = false
		pic.visible = false
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.size = Vector2(420, 525)
	pic.position = Vector2(xs[0] + 6, 150)
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(pic)
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
	Kit.calligraphy(name_l, 96, 4, 16)
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
	var sc := name_l.position + name_l.size / 2.0
	BattleFx.burst(layer, sc, Kit.c("gold"), 18, 40.0, 260.0, 4.0, 0.4)
	BattleFx.embers(layer, Rect2(sc - Vector2(300, 60), Vector2(600, 120)), BattleFx.EMBER, 30, 120.0, true)
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
	var kinds: Array = skill.get("effects", []).map(func(e): return str(e.get("type", "")))
	if "heal" in kinds or "cleanse" in kinds:  # 解毒 is a heal too; a heal that is itself a big move (金针度穴) shouts its ultimate line first
		if _is_ult(skill):
			moments.insert(1, "heal")
		else:
			moments.push_front("heal")
	elif "guard" in kinds and not "attack" in kinds:  # a defence-only skill (举盾, 守家 …): 「举盾！」, men only
		moments.push_front("guard")
	# own voice → the troop's (men only: 枪兵「看枪！」) → the guard voice (men) → the default for the role
	var troop_voice := str(Sfx.troop_voices.get(troop, "")) if role == "male" else ""
	var guard_voice := str(Sfx.voice_defaults.get("guard", "")) if role == "male" else ""
	Sfx.voice([str(leader_card.get("voice", "")), troop_voice, guard_voice, str(Sfx.voice_defaults.get(role, role))], moments)

	# 出招声按技能分：兵刃破风（攻击 / 打断）、治疗、守御、谋略（命中时另有谋略声）、其余增益
	if "attack" in kinds or "interrupt" in kinds:
		Sfx.play("slash")
	elif "heal" in kinds or "cleanse" in kinds:
		Sfx.play("heal")
	elif "guard" in kinds or "counter" in kinds:
		Sfx.play("guard")
	elif not "magic" in kinds:
		Sfx.play("buff")


func _sfx_hit(ev: Dictionary, big: bool) -> void:
	## 打击: magic / pierce / heavy / plain hits sound different; each step of a combo climbs a little in pitch
	match ev["t"]:
		"burn", "poison":
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


func _kill_freeze() -> void:
	## 击破: a beat of slow motion on the killing blow; the enemy darkens, cracks and sinks a little
	var art := _enemy_art
	BattleFx.cracks(self, _enemy_rect(), Color(1.0, 0.95, 0.85, 0.85), 7)
	var tw := art.create_tween().set_parallel()
	tw.tween_property(art, "modulate", Color(0.5, 0.45, 0.45), 0.5)
	tw.tween_property(art, "position:y", art.position.y + 14.0, 0.5).set_trans(Tween.TRANS_QUAD)
	if DisplayServer.get_name() != "headless":
		Engine.time_scale = 0.25
		await get_tree().create_timer(0.15, true, false, true).timeout
		Engine.time_scale = 1.0
	await get_tree().create_timer(0.18).timeout


func _victory_plaque(overkill: float) -> void:
	## 胜利: a gold-rimmed lacquer plaque in 文楷 pops in with gold sparks; a big overkill gets its own line
	var p := PanelContainer.new()
	var sb := Kit.box(Color(0.42, 0.07, 0.05, 0.96), 14, 3, Kit.c("gold"), 0)
	sb.content_margin_left = 80
	sb.content_margin_right = 80
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 12
	p.add_theme_stylebox_override("panel", sb)
	p.z_index = 50  # over the kill cracks (45)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	p.add_child(col)
	var t := Kit.title_label("胜　利", 84, "gold")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)
	if overkill > 0.05:
		var s := Kit.label("溢出伤害 %d%%　宝箱几率提升" % int(round(overkill * 100)), Kit.FONT_BODY, "gold")
		s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(s)
	add_child(p)
	p.reset_size()
	p.position = (Vector2(1280, 720) - p.size) / 2.0
	p.pivot_offset = p.size / 2.0
	p.scale = Vector2(1.6, 1.6)
	p.modulate.a = 0.0
	var tw := p.create_tween()
	tw.tween_property(p, "modulate:a", 1.0, 0.1)
	tw.parallel().tween_property(p, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.9)
	tw.tween_property(p, "modulate:a", 0.0, 0.25)
	tw.tween_callback(p.queue_free)
	await get_tree().create_timer(0.2).timeout
	BattleFx.burst(self, Vector2(640, 360), BattleFx.GOLD, 24, 60.0, 360.0, 5.0, 0.5)
	BattleFx.embers(self, Rect2(240, 260, 800, 200), BattleFx.GOLD, 40, 140.0, true)
	Kit.shake(self, 8.0, 0.2)
	await get_tree().create_timer(1.0).timeout


func _hit_stop(secs: float) -> void:
	## 顿帧: the world nearly freezes for a beat (skipped headless)
	if DisplayServer.get_name() == "headless":
		return
	Engine.time_scale = 0.05
	await get_tree().create_timer(secs, true, false, true).timeout
	Engine.time_scale = 1.0


func _combo_heat(n: int) -> void:
	## the combo counter warms up: amber → orange (5) → red-gold (8) → red with sparks (10+)
	var col := Kit.c("amber")
	if n >= 10:
		col = Color(1.0, 0.3, 0.2)
	elif n >= 8:
		col = Color(1.0, 0.5, 0.2)
	elif n >= 5:
		col = Color(1.0, 0.72, 0.25)
	_combo_label.add_theme_color_override("font_color", col)
	_combo_label.add_theme_constant_override("outline_size", 4 if n >= 5 else 0)
	_combo_label.add_theme_color_override("font_outline_color", Color(0.3, 0.05, 0.0))
	if n >= 8:
		var c := _combo_label.global_position - global_position + _combo_label.size / 2.0
		BattleFx.burst(self, c, Color(1.0, 0.6, 0.2), 8 if n < 10 else 12, 6.0, 50.0, 2.0, 0.22)


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


func _mark_stamp(i: int) -> void:
	## 点名: a big red 「点」 seal slams onto the card, the card jolts and flushes red
	var r := _card_rect(i)
	var l := Kit.label("点", 120, "red")
	l.add_theme_color_override("font_color", Color(1.0, 0.18, 0.12))
	l.add_theme_color_override("font_outline_color", Color(0.15, 0.0, 0.0))
	l.add_theme_constant_override("outline_size", 14)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size = Vector2(180, 180)
	l.position = r.get_center() - l.size / 2.0
	l.pivot_offset = l.size / 2.0
	l.scale = Vector2(3.0, 3.0)
	l.modulate.a = 0.0
	l.z_index = 60
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	var tw := l.create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.08)
	tw.parallel().tween_property(l, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished
	Sfx.play("enemy_hit")
	BattleFx.ring(self, r.get_center(), Color(1.0, 0.2, 0.15), 20.0, 170.0, 0.45, 7)
	_flash(_cards[i], Color(2.0, 0.6, 0.55))
	Kit.shake(_cards[i], 12.0, 0.3)
	var out := l.create_tween()
	out.tween_interval(0.45)
	out.tween_property(l, "modulate:a", 0.0, 0.3)
	out.tween_callback(l.queue_free)
	await get_tree().create_timer(0.35).timeout


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
	_clear_badges()
	for c in _cards:
		_boost_pop(c, false)
		c.modulate = Color.WHITE


func _finish_at_start() -> void:
	await get_tree().create_timer(1.0).timeout  # let the opening lines and HP bars show first
	_finish()


func _pick_chest(title: String, chest: Array) -> void:
	var o := PickOverlay.new()
	o.title = title
	o.chest = "grand" if boss else "normal"
	o.card_ids = chest.map(func(c): return c["id"])
	o.counts = chest.map(func(c): return Game.save.copies(c["id"]))
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(o)
	var i: int = await o.picked
	Game.save.take(chest[i]["id"])
	if Game.save.perk("pick_extra") > 0 and chest.size() > 1:  # 前尘整备「兼收并蓄」: one more from the same chest
		var rest := chest.duplicate()
		o.visible = false
		rest.remove_at(i)
		var o2 := PickOverlay.new()
		o2.title = "兼收并蓄 —— 再选一张"
		o2.chest = o.chest
		o2.card_ids = rest.map(func(c): return c["id"])
		o2.counts = rest.map(func(c): return Game.save.copies(c["id"]))
		o2.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(o2)
		var j: int = await o2.picked
		Game.save.take(rest[j]["id"])


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
			Quests.rescale_hp(save, b.party_max, Quests.party_max(save))  # a 换人 resized the bar: the map's bar keeps the share
			save.carry_extra.merge(out[1], true)
			save.carry_uses.merge(out[2], true)
		await _victory_plaque(b.overkill)
		var q: Dictionary = Game.battle_ctx.get("quest", {})
		var bonus := float(b.mods.get("chest", 0.0))
		var chance := save.chest_chance(b.overkill, boss, bonus)
		var extra_card := 1 if Game.rng.randf() < b.loot_card else 0  # 劫掠: one more card to pick from in every chest
		var chest := save.chest_after_battle(Game.rng, b.overkill, boss, [], b.enemy["data"]["drop"], bonus, str(q.get("id", "")), extra_card)
		var odds := "首领必掉" if boss else "溢出伤害 %d%% · 宝箱几率 %d%%" % [int(round(b.overkill * 100)), int(round(chance * 100))]
		if extra_card > 0:
			odds += " · 劫掠：多一张卡"
		if chest.is_empty():
			await _banner("%s —— 这次没有宝箱" % odds, Kit.c("gray"))
			await get_tree().create_timer(0.5).timeout
		else:
			await _pick_chest("宝箱！（%s）选一张卡带走" % odds, chest)
		if Game.rng.randf() < b.loot_chest:  # 劫掠: a second chest
			await _pick_chest("劫掠！多出一个宝箱，再选一张卡带走", save.bonus_chest(Game.rng, boss, [], str(q.get("id", "")), extra_card))
		Game.battle_finished(true)
	else:
		# say why: running out of rounds with HP left is not the same as being wiped out
		var why := {"turns": "回合用尽", "retreat": "全军撤退"}.get(b.lose_reason, "战　败") as String
		var q: Dictionary = Game.battle_ctx.get("quest", {})
		var again: bool = not q.is_empty() and Quests.holds_unless_beaten(q, save)  # a story fight: only a real defeat moves the story on
		var more := {"turns": "时间到了——敌人还剩 %d%% 体力" % int(ceil(100.0 * float(b.enemy["hp"]) / float(b.enemy["max_hp"]))),
				"retreat": "撤出战场，整备之后再打" if again else "撤出战场，这一轮重新来过"}.get(b.lose_reason, "全军体力耗尽") as String
		await _alert(why, more, Kit.c("red"), 1.6)
		await get_tree().create_timer(0.3).timeout
		Game.battle_finished(false, b.lose_reason != "retreat")

