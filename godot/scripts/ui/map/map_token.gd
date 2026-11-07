class_name MapToken
extends Control
## the hero's holder: draws a soft ground shadow under the feet (the sprite child bobs above it)
func _draw() -> void:
	var c := Vector2(size.x / 2.0, size.y - 3.0)
	draw_set_transform(c, 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, size.x * 0.30, Color(0, 0, 0, 0.38))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
