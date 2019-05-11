extends KinematicBody2D

onready var SPRITE = get_node("Sprite")

const COYOTE_TIME = 0.1
const JUMP_GRACE_TIME = 0.1 
const MAX_SPEED = 900
const MAX_FALL_SPEED = 500
const GRAVITY = 13
const ACCEL = 9
const FRICTION = 0.14
const SCALE_RET_SPEED = 0.1
const JUMP_HEIGHT = -300
const UP = Vector2(0, -1)

var WallJumpDustScn = preload('res://FX/WallJumpDust.tscn')
var JumpPoofScn = preload('res://FX/JumpPoof.tscn')
var skidPoofScn = preload('res://FX/skidPoof.tscn')

var hasSkidded = [0,0]

var facing = 1
var jumpGrace = 0
var tGrav = GRAVITY
var motion = Vector2()
var isOnFloor = 0
var ctr = 0

func _ready():
	pass

func _physics_process(delta):
	SPRITE.scale = lerp(SPRITE.scale, Vector2(1,1), SCALE_RET_SPEED)
	var tAccel = ACCEL
	tGrav = GRAVITY
	
	if motion.x < 0: hasSkidded[1] = 0
	if motion.x > 0: hasSkidded[0] = 0
	
	if jumpGrace > 0: jumpGrace -= delta
	if Input.is_action_just_pressed("jump"): jumpGrace = JUMP_GRACE_TIME
	
	if isOnFloor >= COYOTE_TIME:
		tAccel *= 3
	
	if Input.is_action_pressed("run_right"):
		motion.x += tAccel
		if motion.x + 100 < 0: summonSkid(position-Vector2(22,-10), motion.x)
		facing = 1
	if Input.is_action_pressed("run_left"):
		motion.x -= tAccel
		if motion.x - 100 > 0: summonSkid(position+Vector2(22, 10), motion.x)
		facing = -1

	SPRITE.flip_h = true if facing < 0 else false

	updateIsOnFloor(delta)
	
	if isOnFloor >= COYOTE_TIME and jumpGrace > 0:
		makeJumpPoof()
		motion.y = JUMP_HEIGHT

	fallAndSlide(delta)

	#if position.y > 400:
		#Transition.fade_to(world_scene)
	#	respawn()

	ctr += 1

func makeJumpPoof() -> void:
	var tFX = JumpPoofScn.instance()
	tFX.emitAt(position + Vector2(0, 10))
	get_parent().add_child(tFX)

func summonSkid(pos, dir):
	if isOnFloor == COYOTE_TIME:
		var ti = 0 if dir < 0 else 1
		if hasSkidded[ti] == 0:
			hasSkidded[ti] = 1
			var tskid = skidPoofScn.instance()
			tskid.summon_at_pos(pos, sign(dir)==-1)
			get_parent().add_child(tskid)
			print('summoned poof at ', pos, ' going dir ', dir)

func updateIsOnFloor(delta):
	if is_on_floor():
		isOnFloor = COYOTE_TIME
	elif isOnFloor > 0:
		isOnFloor -= delta

func fallAndSlide(delta):
	if isOnFloor >= COYOTE_TIME:
		motion.y = min(3, motion.y) # dont build up grav into floors, but keep 3 so is_on_floor stays true :)
		motion.x = lerp(motion.x, 0, FRICTION)
	else:
		motion.x = lerp(motion.x, 0, FRICTION/3)

	motion.x = max(-MAX_SPEED, min(motion.x, MAX_SPEED))

	if motion.y < 0 && Input.is_action_pressed("jump"):
		tGrav = GRAVITY * 0.75

	if(motion.y < MAX_FALL_SPEED):
		motion.y += tGrav

	motion = move_and_slide(motion, UP)