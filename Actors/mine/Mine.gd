extends Area2D

onready var SPRITE = get_node("AnimatedSprite")
onready var PLAYER = get_node("/root/Node2D/Player")

export(int) var SIGHT_RANGE = 150
export(int) var SPEED = 30

func _ready():
	pass

func _physics_process(delta):
	if SPRITE.animation != "death":
		var toDir = (PLAYER.global_position - global_position)
		if toDir.length() < SIGHT_RANGE:
			position += toDir.normalized() * SPEED * delta

func _on_Mine_body_entered(body):
	if "Player" in body.name:
		SPRITE.play("death")
		body.die() # kill the player

func _on_AnimatedSprite_animation_finished():
	if SPRITE.animation == "death":
		queue_free()