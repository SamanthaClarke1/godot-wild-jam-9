extends AnimatedSprite

func summon_at_pos(pos: Vector2, flipped: bool):
	flip_h = flipped
	position = pos
	play("default")

func _on_skidPoof_animation_finished():
	queue_free()
