class_name AutoPlayer
extends RefCounted
## 自动战斗: picks the next action for the player's side — the usable skill with the best value per AP, once-only skills a little
## less eagerly, a skill that would do nothing never. BOOST counts: a boosted unit's skills are worth boost_mult× (and lean towards its biggest), and a boost skill is worth what it adds to the best waiting ally. Nothing usable = the caller ends the round — or defends, when AP is already full (the round's AP would be wasted anyway: `ends_with_defend`). Never swaps.


static func value(b: Battle, u: Dictionary, sk: Dictionary) -> float:
	var v := 0.0
	var at: float = u["leader"]["at"]
	for e in sk["effects"]:
		match e["type"]:
			"attack", "magic":
				v += at * float(e["power"]) * int(e.get("hits", 1))
			"heal":
				v += at * float(e["power"]) * (1.5 if b.party_hp < 0.4 * b.party_max else 0.0)  # healing only pays when hurt
			"stun":
				v += float(e["chance"]) * b.enemy["data"]["at"] * 2
			"poison":  # what the new layers take over the turns left, while there is room to stack
				var room := mini(int(e.get("stacks", 1)), int(e.get("max", 5)) - int(b.enemy["poison"]))
				v += float(b.enemy["max_hp"]) * float(e["pct"]) * maxi(0, room) * int(e.get("turns", 3)) * 0.5
			"boost":  # BOOST on a waiting ally: its next skill hits boost_mult times as hard
				var best_ally := 0.0
				for t in b.leaders:
					if t != u and not t["acted"] and not t["boosted"] and not t["confused"]:
						best_ally = maxf(best_ally, float(t["leader"]["at"]))
				v += (float(b.db.battle["boost_mult"]) - 1.0) * best_ally * 2.0
			"shred":  # 射穿甲缝: the party's blows over its turns hit that much harder (until the cap)
				var room := maxf(0.0, float(b.db.battle.get("archer_resist", {}).get("max", 0.5)) - float(b.enemy["resist_down"]))
				var pat := 0.0
				for t in b.leaders:
					pat += float(t["leader"]["at"])
				v += minf(room, float(e.get("amount", 0.1))) * pat * int(e.get("turns", 3)) * 0.5
			"buff":  # 战意 (军师 1 AP): what the whole party gains over the rounds it lasts — more damage dealt (atk + magic rider) and less taken (def)
				var turns := mini(int(e.get("turns", 3)), maxi(1, b.turn_limit - b.round_no + 1))
				var share := 1.0 if b.buff["layers"] < int(e.get("max", 4)) else (1.0 if int(b.buff["turns"]) <= 1 else 0.0)  # at max layers only a refresh before it runs out is worth anything
				if b.buff["layers"] >= int(e.get("max", 4)):
					share *= 0.5  # a refresh adds no layer
				var party_at := 0.0
				for t in b.leaders:
					party_at += float(t["leader"]["at"])
				var hit := float(e.get("atk", 0.0)) + float(e.get("magic", 0.0))
				var guard := float(e.get("def", 0.0)) * float(b.enemy["data"]["at"]) * int(b.enemy["data"].get("actions", 1))
				var waiting := 0  # cast before the others move, their blows this very round take it too: 自动 plays it first
				for t in b.leaders:
					if t != u and not t["acted"]:
						waiting += 1
				v += share * turns * (hit * party_at + guard) * (1.0 + 0.25 * waiting)
			_:
				v += 0.2 * at
	if u["boosted"]:  # a boosted unit's next skill is worth boost_mult times (the boost is spent on whatever it plays)
		v *= float(b.db.battle["boost_mult"])
	return v


static func ends_with_defend(b: Battle) -> bool:
	## nothing left to play and AP at its cap: guard instead of a plain end of round (the AP the next round brings would only spill over)
	return b.ap >= b.ap_max() and b.can_defend()


static func next(b: Battle) -> Array:
	## [leader index, skill id], or [] when there is nothing worth doing
	var best: Array = []
	var best_score := 0.0
	for i in b.leaders.size():
		if not b.can_act(i):
			continue
		var u: Dictionary = b.leaders[i]
		for sk in b.skills_of(u):
			if not b.usable(u, sk):
				continue
			var score := value(b, u, sk) / (b.cost(u, sk) + 1)
			if u["boosted"]:
				score *= 1.0 + 0.1 * b.cost(u, sk)  # spend the boost on the biggest skill it can afford, not the cheapest per AP
			if sk["uses"] == 1:
				score *= 0.6  # a once-only skill stays spent until the next 休整: don't burn it on a whim
			if score > best_score:
				best_score = score
				best = [i, sk["id"]]
	return best
