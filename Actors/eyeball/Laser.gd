extends Node2D

onready var PLAYER = get_node("/root/Node2D/Player")
onready var SPRITE = get_node("AnimatedSprite")
onready var RAY = get_node("RayCast2D")
onready var LASER = get_node("Line2D")
onready var SHAKER = PLAYER.get_node("Camera2D/ScreenShake")

export(int) var LOOK_LENGTH = 250
export(float) var SECS_TO_BLAST = 1.5
export(float) var SPEED = 0.33
export(float) var SPEED_PENALTY = 9

var canSeePlayer = false
var timeSeeingPlayer = 0
var toPlayer = Vector2()

func _ready():
	pass

func prepBlast():
	timeSeeingPlayer = 0
	SPRITE.play("prepblast")

func startBlast():
	timeSeeingPlayer = 0
	SPRITE.play("blast")
	# func start(dur=0.2, freq=15, amp=5, priority=0):
	SHAKER.start(0.25, 15, 6)
	LASER.visible = true

func endBlast():
	timeSeeingPlayer = 0
	SPRITE.play("idle")
	LASER.visible = false

func lookTowardsPlayer():
	RAY.cast_to = (toPlayer).normalized() * LOOK_LENGTH
	RAY.force_raycast_update()
	
	SPRITE.rotation = toPlayer.angle() - PI / 2
	$LightOccluder2D.rotation = toPlayer.angle() - PI / 2
	
	if RAY.is_colliding():
		LASER.set_point_position(1, RAY.get_collision_point()-global_position)
	else:
		LASER.set_point_position(1, RAY.cast_to)

func _physics_process(delta):
	canSeePlayer = false
	var tSpeed = SPEED
	if "blast" in SPRITE.animation:
		tSpeed /= SPEED_PENALTY
	
	toPlayer = lerp(toPlayer, (PLAYER.global_position - global_position).normalized(), tSpeed)
	
	lookTowardsPlayer()
	
	if RAY.is_colliding():
		var collider = RAY.get_collider()
		if "Player" in collider.name:
			canSeePlayer = true
			if SPRITE.animation == "blast":
				if not collider.IS_DEAD and not collider.IS_RESPAWNING:
					collider.die()
	
	if canSeePlayer:
		timeSeeingPlayer += delta
	else:
		timeSeeingPlayer = 0

func _on_AnimatedSprite_animation_finished():
	if SPRITE.animation == "prepblast":
		startBlast()
	elif timeSeeingPlayer > SECS_TO_BLAST:
		prepBlast()
	elif SPRITE.animation == "blast":
		endBlast()
	elif not canSeePlayer:
		SPRITE.play("relaxed")
	else:
		SPRITE.play("idle")
