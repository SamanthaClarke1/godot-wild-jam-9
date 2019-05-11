extends Particles2D

func emitAt(pos: Vector2, dir: Vector2):
	self.position = pos
	self.scale.x = dir.x
	self.emitting = true
	print(pos, dir)
	$Timer.start()

func _on_Timer_timeout():
	queue_free()
