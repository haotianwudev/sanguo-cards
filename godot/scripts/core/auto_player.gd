class_name AutoPlayer
extends RefCounted
## 自动战斗: picks the next action for the player's side — the usable skill with the best value per AP, once-only skills a little
## less eagerly, a skill that would do nothing never. Nothing usable = the caller ends the round. Never defends or swaps.


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
			_:
				v += 0.2 * at
	return v


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
			if sk["uses"] == 1:
				score *= 0.6  # a once-only skill stays spent until the next 休整: don't burn it on a whim
			if score > best_score:
				best_score = score
				best = [i, sk["id"]]
	return best
