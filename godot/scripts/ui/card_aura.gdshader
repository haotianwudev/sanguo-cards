shader_type canvas_item;
// The rarity aura round a card (CardView._sync_aura sets the uniforms from ui.json card.glows). It used to be redrawn from
// script every frame (eight style boxes + sparkles per card); here the GPU does the same picture and TIME animates it.
//   eight soft rounded rings spreading `reach` px past the frame, breathing (0.75–1.0) when `breathe`;
//   `rainbow` (ssr): every ring a different hue, the whole aura turning; a thin bright rim on the frame;
//   ssr also: ten four-pointed stars running round the frame, each twinkling.

uniform vec4 col : source_color = vec4(1.0);
uniform float k = 1.0;          // strength (glows[1] × glow_boost)
uniform float breathe = 0.0;    // 1 = slowly pulses
uniform float rainbow = 0.0;    // 1 = ssr
uniform float reach = 20.0;     // px the light spreads past the frame
uniform vec2 card = vec2(180.0, 252.0);  // the framed card's size, px
uniform float pad = 40.0;       // px this rect reaches past the card on every side
uniform float phase = 0.0;      // per card, so cards don't pulse in step
uniform float star_scale = 1.0;

vec3 hsv(float h, float s, float v) {
	vec3 p = abs(fract(vec3(h) + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
	return v * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), s);
}

float round_box(vec2 p, vec2 half_size, float r) {
	// signed distance to a rounded rectangle centred on 0
	vec2 q = abs(p) - half_size + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec2 perimeter(vec2 lo, vec2 sz, float d) {
	// the point d px clockwise round the rect from its top-left corner
	if (d < sz.x) return lo + vec2(d, 0.0);
	if (d < sz.x + sz.y) return lo + vec2(sz.x, d - sz.x);
	if (d < 2.0 * sz.x + sz.y) return lo + vec2(sz.x - (d - sz.x - sz.y), sz.y);
	return lo + vec2(0.0, 2.0 * (sz.x + sz.y) - d);
}

void fragment() {
	vec2 rect = card + 2.0 * pad;
	vec2 px = UV * rect - pad;          // pixel position in card space (0,0 = the card's top-left)
	vec2 c = px - card * 0.5;
	float t = TIME + phase;
	float kk = k * mix(1.0, 0.75 + 0.25 * sin(t * 2.4), breathe);
	vec3 pm = vec3(0.0);  // premultiplied colour, painted "over" in the old draw order
	float al = 0.0;

	// the rings, innermost first (as the old style boxes were drawn): ring i covers up to reach·f_i past the frame
	for (int i = 0; i < 8; i++) {
		float f = float(i + 1) / 8.0;
		float grow = reach * f;
		if (round_box(c, card * 0.5 + grow, 8.0 + grow) <= 0.0) {
			vec3 rc = mix(col.rgb, hsv(fract(t * 0.12 + f * 0.35), 0.7, 1.0), rainbow);
			float a = min(0.42 * kk, 0.5) * pow(1.0 - f + 1.0 / 8.0, 1.4);
			pm = pm * (1.0 - a) + rc * a;
			al = al * (1.0 - a) + a;
		}
	}
	// the rim: a 2 px (ssr 3 px) bright edge just outside the frame
	float edge = round_box(c, card * 0.5 + 2.0, 8.0);
	float w = mix(2.0, 3.0, rainbow);
	if (edge <= 0.0 && edge > -w) {
		vec3 rim = mix(col.rgb, hsv(fract(t * 0.12), 0.35, 1.0), rainbow);
		float a = min(0.85 * kk, 1.0);
		pm = pm * (1.0 - a) + rim * a;
		al = al * (1.0 - a) + a;
	}
	// ssr: four-pointed stars running round the frame (an astroid: tips on the axes, waist ≈ 0.25 of the size)
	if (rainbow > 0.5) {
		vec2 lo = vec2(-3.0);
		vec2 sz = card + 6.0;
		float per = 2.0 * (sz.x + sz.y);
		for (int i = 0; i < 10; i++) {
			float tw = max(0.0, sin(t * 3.1 + float(i) * 1.7));
			if (tw < 0.05) continue;
			vec2 p = perimeter(lo, sz, mod(t * 34.0 + per * float(i) / 10.0, per));
			float s = (5.0 + 7.0 * tw) * star_scale;
			vec2 v = abs(px - p) / s;
			float star = 1.0 - smoothstep(0.92, 1.0, sqrt(v.x) + sqrt(v.y));
			float dot_ = 1.0 - smoothstep(0.2, 0.25, length(px - p) / s);
			vec3 sc = mix(hsv(fract(t * 0.12 + float(i) / 10.0), 0.25, 1.0), vec3(1.0), dot_);
			float a = max(star, dot_) * tw;
			pm = pm * (1.0 - a) + sc * a;
			al = al * (1.0 - a) + a;
		}
	}
	COLOR = vec4(al > 0.0 ? pm / al : vec3(0.0), al);
}
