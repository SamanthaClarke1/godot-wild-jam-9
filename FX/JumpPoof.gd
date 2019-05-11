extends Node2D

func emitAt(pos: Vector2) -> void:
	position = pos
	$Particles2D.emitting = true
	$Particles2D2.emitting = true
	$Timer.start()

func _on_Timer_timeout():
	queue_free()