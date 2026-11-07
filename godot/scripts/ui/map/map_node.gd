class_name MapNode
extends Control
## High-fidelity Rance X style battlefield token:
## Distinct die-cut icons (martial shield, spiked crest, boss warlord mask, gilded chest, camp tent, bamboo scroll...),
## with atmospheric aura for elite/boss, smooth interaction states,
## and authentic cinnabar seal on victory.
var icon_tex: Texture2D = null
var glyph := ""
var col := Color.WHITE
var kind := ""  # boss / elite / …
var state := "open"
var show_glyph_on_icon := false

func _draw() -> void:
	var big := kind == "boss" or kind == "elite"
	var s := size
	var center := s / 2.0
	
	# 1. Atmospheric Back Aura for Boss / Elite
	if kind == "boss" and state != "visited":
		var aura_rad := s.x * 0.60
		draw_circle(center, aura_rad + 4.0, Color(0.75, 0.12, 0.10, 0.35))
		draw_circle(center, aura_rad, Color(0.95, 0.35, 0.10, 0.25))
		draw_arc(center, aura_rad + 2.0, 0, TAU, 32, Color(1.0, 0.85, 0.40, 0.65), 2.2, true)
	elif kind == "elite" and state != "visited":
		var aura_rad := s.x * 0.52
		draw_circle(center, aura_rad, Color(0.95, 0.45, 0.05, 0.28))
		draw_arc(center, aura_rad + 1.0, 0, TAU, 28, Color(1.0, 0.75, 0.25, 0.55), 1.5, true)
	
	# 2. Render Icon Texture
	if icon_tex != null:
		var icon_size := s.x if not big else (s.x * 1.18)
		var rect := Rect2(center - Vector2(icon_size, icon_size) * 0.5, Vector2(icon_size, icon_size))
		
		var icon_mod := Color.WHITE
		match state:
			"visited":
				icon_mod = Color(0.62, 0.58, 0.55, 0.85)  # Historical muted ink/sepia
			"closed":
				icon_mod = Color(0.40, 0.40, 0.45, 0.55)  # Faint closed path
			"reachable":
				icon_mod = Color(1.08, 1.05, 1.0)        # Crisp glowing active
			"current":
				icon_mod = Color(1.15, 1.10, 0.95)       # Heroic highlight
		
		draw_texture_rect(icon_tex, rect, false, icon_mod)

		# If this node displays a glyph over the icon (e.g. random_event jade plaque)
		if show_glyph_on_icon and glyph != "":
			var font_size := 22
			var f: Font = Kit.name_font(font_size, 0)
			var gs := f.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			# Center of the cream jade medallion is at center.y + s.y * 0.065
			var text_center := center + Vector2(0, s.y * 0.065)
			var at := Vector2(text_center.x - gs.x * 0.5, text_center.y + font_size * 0.35)
			
			# Engraved ambient shadow
			var shadow_ink := Color(0.72, 0.62, 0.50, 0.85) if state != "visited" else Color(0.35, 0.32, 0.30, 0.5)
			draw_string(f, at + Vector2(0, 1.2), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, shadow_ink)
			
			# Deep calligraphy ink
			var text_ink := Color(0.16, 0.10, 0.06) if state != "visited" else Color(0.42, 0.38, 0.35)
			if state == "closed":
				text_ink = Color(0.35, 0.32, 0.30, 0.6)
			draw_string(f, at, glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_ink)
	else:
		# Custom Glyph Medallion (e.g. 马, 沼, 寨, 甲):
		# Rich dark lacquer disc with gold bezel and 3D carved calligraphy
		var radius := s.x * 0.44
		# Drop shadow
		draw_circle(center + Vector2(0, 4), radius + 2.0, Color(0, 0, 0, 0.45))
		# Outer gold bezel
		draw_circle(center, radius, Color(0.85, 0.70, 0.38))
		draw_circle(center, radius - 2.5, Color(0.14, 0.10, 0.08))
		# Inner lacquer disc with faction/event tint
		var disc_col := col.darkened(0.65)
		if disc_col.get_luminance() < 0.08:
			disc_col = Color(0.12, 0.10, 0.09)
		if state == "visited":
			disc_col = Color(0.18, 0.16, 0.15)
		elif state == "closed":
			disc_col = disc_col.darkened(0.4)
		draw_circle(center, radius - 4.5, disc_col)
		# Top specular highlight
		draw_arc(center, radius - 3.5, -PI * 0.75, -PI * 0.25, 16, Color(1, 1, 1, 0.25 if state != "visited" else 0.08), 1.2, true)
		# 3D carved calligraphy
		var f: Font = Kit.name_font(30, 0)
		var gs := f.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 30)
		var at := Vector2(center.x - gs.x * 0.5, center.y + 30 * 0.35)
		draw_string(f, at + Vector2(0, 2), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0, 0, 0, 0.85))
		var glyph_ink := Color(1.0, 0.94, 0.82) if state != "visited" else Color(0.65, 0.62, 0.58)
		draw_string(f, at, glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, glyph_ink)

	# 3. Victory stamp: a cinnabar 胜 seal on won battles only (a passed story square is just greyed)
	if state == "visited" and kind in ["boss", "elite", "battle"]:
		var c := center + Vector2(s.x * 0.28, s.y * 0.28)
		draw_circle(c, 11, Color(0.82, 0.18, 0.12, 0.95))
		draw_arc(c, 11, 0, TAU, 24, Color(1, 0.88, 0.78, 0.9), 1.2, true)
		var sf: Font = Kit.name_font(13, 0)
		var seal_txt := "胜"
		var ss := sf.get_string_size(seal_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
		draw_string(sf, c + Vector2(-ss.x * 0.5, 4.5), seal_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 0.96, 0.9))
