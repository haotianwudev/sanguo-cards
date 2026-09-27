extends Control
## Root of the game. Command-line (after `--`):
##   --demo=title|map|choose|pick|battle   jump to a prepared state (no saving)
##   --shot=<file.png> [--wait=seconds]    save a screenshot and quit


func _ready() -> void:
	theme = Kit.make_theme()
	var bg := ColorRect.new()
	bg.color = Kit.c("bg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_parent().call_deferred("add_child", bg)
	get_parent().call_deferred("move_child", bg, 0)
	Game.root = self
	var args := {}
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--"):
			var kv := a.substr(2).split("=", true, 1)
			args[kv[0]] = kv[1] if kv.size() > 1 else ""
	if args.has("demo"):
		Game.demo(args["demo"])
	else:
		Game.show_screen(TitleScreen.new())
	if args.has("shot"):
		await get_tree().create_timer(float(args.get("wait", "1.5"))).timeout
		get_viewport().get_texture().get_image().save_png(args["shot"])
		get_tree().quit()
