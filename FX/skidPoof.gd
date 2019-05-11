extends AnimatedSprite

func summon_at_pos(pos: Vector2, flipped: bool, isUpsideDown: bool):
	flip_h = flipped
	flip_v = isUpsideDown
	position = pos
	play("default")

func _on_skidPoof_animation_finished():
	queue_free()
