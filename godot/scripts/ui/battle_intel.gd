class_name BattleIntel
extends RefCounted
## What the map shows before a fight (the 出战 sheet): rich-text tags for the fight's kind, the enemy's numbers, its
## armor / resists (through Kit.resist_parts, the one place that reads them) and its moves.


static func info(s: Dictionary, fight: Dictionary) -> String:
	## the intel before a fight, three short lines of tags instead of a wall of text:
	## 1 what kind of fight + the enemy's numbers; 2 its armor, resists and weaknesses; 3 its moves (a charged one says: bring an interrupt)
	var db := GameData.get_db()
	var sc: Dictionary = db.scenarios[fight["battle"]]
	var e: Dictionary = Quests.with_armor(db.enemies[sc["enemy"]], Quests.late_armor(Game.save.quest, s, sc["enemy"]))
	var tags: Array = []
	if s["boss"]:
		tags.append(chip("首领", "purple"))
	if s["lose_goto"] != "":
		tags.append(chip("输了也能过", "green") if s["lose_tag"] == "" else chip(s["lose_tag"], "red"))  # lose_tag: the story goes on, but losing costs something
	elif s["elite"]:
		tags.append(chip("精英", "red"))
	if fight["ambush"]:
		tags.append(chip("埋伏", "red"))
	var afx_id: String = Game.save.affixes.get(s["id"], "")
	if afx_id != "" and db.battle.get("affixes", {}).has(afx_id):  # this run's 词缀
		var afx: Dictionary = db.battle["affixes"][afx_id]
		var afx_img := Kit.affix_icon_path(afx_id)
		tags.append(("[img=26]%s[/img]" % afx_img if afx_img != "" else "") + chip("%s：%s" % [afx["name"], afx["desc"]], "amber"))
	var turns := Battle.turns_for(db, sc, "boss" if s["boss"] else ("elite" if s["elite"] else "normal"))
	var head := ("　".join(tags) + "　" if not tags.is_empty() else "") + "体力 %d · 攻 %d · %d 动 · %d 回合" % [e["hp"], e["at"], e["actions"], turns]
	var res := resists(e)
	return "[font_size=%d]%s%s\n%s[/font_size]" % [Kit.FONT_SMALL, head, ("\n" + res if res != "" else ""), moves(e)]


static func chip(text: String, color_name: String) -> String:
	## a coloured tag inside rich text (the intel's badges)
	var bg := Kit.c(color_name)
	var fg := Color(0.1, 0.07, 0.04) if bg.get_luminance() > 0.55 else Color(1, 1, 1)
	bg.a = 0.85
	return "[bgcolor=%s][color=%s] %s [/color][/bgcolor]" % [bg.to_html(), fg.to_html(), text]


static func resists(e: Dictionary) -> String:
	## the 护甲 and both resists as tags — a weakness (negative resist) in red, so a 谋略弱点 jumps out: 「藤甲（刀枪不入，一点就着）」「兵刃抗性 80%」「谋略弱点 +100%」
	var out: Array = []
	var arm := Kit.armor_of(e)
	if not arm.is_empty():
		out.append(chip(str(arm["name"]), "amber"))
	for r in Kit.resist_parts(e):
		out.append(chip("%s%s %s%d%%" % [r["kind"].left(1), "弱" if r["weak"] else "抗", "+" if r["weak"] else "", r["pct"]], "red" if r["weak"] else "gray"))
	return "　".join(out)


static func moves(e: Dictionary) -> String:
	## the enemy's moves with what makes them dangerous, so the player can plan (the wind-up itself is skipped);
	## the charged move is a gold tag that says what answers it: an interrupt (扔刀、回马枪 …)
	var parts: Array = []
	var charged: Array = e["moves"].filter(func(m): return m.has("charge")).map(func(m): return m["charge"])
	for m in e["moves"]:
		if m.has("charge"):
			continue
		var tags: Array = []
		if m.get("pierce", false):
			tags.append("无视防御")
		if m.has("confuse"):
			tags.append("混乱")
		if m.has("rage"):
			tags.append("狂暴" + ("·残血" if m.get("when", "") == "half" else ""))
		if m.has("heal"):
			tags.append("回复")
		if m.has("ap_drain"):
			tags.append("夺AP")
		if m.has("burn_party"):
			tags.append("火烧")
		if m.has("summon"):
			tags.append("叫援")
		if m.has("stance"):
			tags.append("架势")
		var label: String = m["name"] + ("·%s" % "·".join(tags) if not tags.is_empty() else "")
		if charged.has(m["name"]):
			parts.append(chip("蓄力 " + label, "gold"))
		else:
			parts.append(chip(label, "red" if not tags.is_empty() else "blue"))
	return " ".join(parts)
