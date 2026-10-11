class_name ChapterJumps
extends RefCounted
## The debug tool's chapter jumps (按最常见的那条线路设置 quests_cleared / flags) and the save a jump starts from.
## Keep in sync with story.json: tests/test_quests.gd walks every entry.

const LIST := [
	{"label": "第一章 · 南线（富春）", "cleared": [], "flags": []},
	{"label": "第一章 · 北线（冀州风云）", "cleared": [], "flags": ["出生：冀州无极"]},
	{"label": "第二章 · 南线（讨伐董卓）", "cleared": ["prologue"], "flags": []},
	{"label": "第二章 · 北线（洛阳烟云）", "cleared": ["prologue"], "flags": ["出生：冀州无极"]},
	{"label": "第三章 · 北线（黑山风云）", "cleared": ["prologue", "luoyang_n"], "flags": ["出生：冀州无极", "北线：班师冀州"]},
	{"label": "第四章 · 北线（双凤乱太行）", "cleared": ["prologue", "luoyang_n", "heishan"],
		"flags": ["出生：冀州无极", "北线：班师冀州", "界桥：救下公孙瓒"]},
	{"label": "第五章 · 北线（铁纪徐州，军纪严明）", "cleared": ["prologue", "luoyang_n", "heishan", "beihai"],
		"flags": ["出生：冀州无极", "北线：班师冀州", "界桥：救下公孙瓒", "郑姜：和好", "北线：北海相", "军纪：严明"]},
	{"label": "第六章 · 北线（淮南折帝旗）", "cleared": ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou"],
		"flags": ["出生：冀州无极", "北线：班师冀州", "曹操：借粮", "界桥：救下公孙瓒", "郑姜：和好", "北线：北海相", "军纪：严明",
			"夏侯惇：痛击殿后", "徐州：接任徐州牧"]},
	{"label": "第六章 · 北线（结局九 · 断桥）", "cleared": ["prologue", "luoyang_n", "heishan", "beihai", "xuzhou"],
		"flags": ["出生：冀州无极", "北线：班师冀州", "曹操：没借", "界桥：救下公孙瓒", "郑姜：和好", "北线：北海相", "军纪：严明",
			"夏侯惇：痛击殿后", "徐州：接任徐州牧"]},
	{"label": "第三章 · 传国玉玺", "cleared": ["prologue", "taodong"], "flags": []},
	{"label": "第三章 · 驻守洛阳（第三章地图内）", "cleared": ["prologue", "taodong"], "flags": ["董白：留下", "结局一 · 玉碎"],
		"records": ["路线：守洛阳"], "at": "wenji_join"},
	{"label": "第三章 · 长安（第三章地图内）", "cleared": ["prologue", "taodong"], "flags": ["董白：留下", "结局一 · 玉碎"],
		"records": ["路线：守洛阳", "路线：长安"], "at": "lijue_test"},
	{"label": "第四章 · 挟天子", "cleared": ["prologue", "taodong", "yuxi"],
		"flags": ["董白：留下", "结局一 · 玉碎", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓"]},
	{"label": "第五章 · 荆襄风云", "cleared": ["prologue", "taodong", "yuxi", "dongui"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓", "南阳：袁术东逃"]},
	{"label": "第六章 · 淮南折帝旗（南线）", "cleared": ["prologue", "taodong", "yuxi", "dongui", "jingxiang"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "结局三 · 恨海", "路线：守洛阳", "路线：长安", "长安：吕布杀了董卓",
			"南阳：袁术东逃", "贾诩：入队", "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督"]},
	{"label": "第六章 · 淮南折帝旗（南线，结局十之后：刘晔线）", "cleared": ["prologue", "taodong", "yuxi", "dongui", "jingxiang"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "结局三 · 恨海", "结局十 · 深锁", "路线：守洛阳", "路线：长安",
			"长安：吕布杀了董卓", "南阳：袁术东逃", "贾诩：入队", "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督"]},
	{"label": "第七章 · 江东小霸王（南线）", "cleared": ["prologue", "taodong", "yuxi", "dongui", "jingxiang", "huainan_s"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "结局三 · 恨海", "结局十 · 深锁", "路线：守洛阳", "路线：长安",
			"长安：吕布杀了董卓", "南阳：袁术东逃", "贾诩：入队", "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督", "庐江：刘晔调停", "庐江：双婚"]},
	{"label": "第七章 · 江东小霸王（南线，结局十一之后：收服锦帆）", "cleared": ["prologue", "taodong", "yuxi", "dongui", "jingxiang", "huainan_s"],
		"flags": ["董白：留下", "结局一 · 玉碎", "结局二 · 同归", "结局三 · 恨海", "结局十 · 深锁", "结局十一 · 匹夫", "路线：守洛阳", "路线：长安",
			"长安：吕布杀了董卓", "南阳：袁术东逃", "贾诩：入队", "荆襄：联蒯灭蔡", "荆襄：督荆襄九郡大都督", "庐江：刘晔调停", "庐江：双婚"]},
]


static func jump_save(jump: Dictionary, base: SaveData = null, rng: RandomNumberGenerator = null) -> SaveData:
	## The save a chapter jump starts from: a COPY of the player's own save (cards, levels, 战功, remembered history all
	## kept) with only the story position changed. Nothing is written back — the file on disk is never touched.
	var save := SaveData.from_dict(base.to_dict()) if base != null else SaveData.create()
	save.quest = ""
	save.replay = ""
	save.ended = false
	save.quests_cleared = jump["cleared"].duplicate()
	save.flags = jump["flags"].duplicate()
	Quests.reset_carry(save)
	Quests.ensure_started(save, rng)
	if jump.has("at"):  # a stop inside a chapter: the records so far, standing on that square
		save.run_records = jump["records"].duplicate()
		save.square = jump["at"]
		save.resolved = true
		if not save.visited.has(jump["at"]):
			save.visited.append(jump["at"])
	return save
