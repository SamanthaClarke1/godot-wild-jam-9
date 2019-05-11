extends KinematicBody2D

onready var SPRITE = get_node("Sprite")

const COYOTE_TIME = 0.1
const JUMP_GRACE_TIME = 0.1 
const MAX_SPEED = 900
const MAX_FALL_SPEED = 500
const GRAVITY = 13
const ACCEL = 9
const FRICTION = 0.14
const SCALE_RET_SPEED = 0.15
const SCALE_FX_RET_SPEED = 0.2
const JUMP_HEIGHT = -300
const TIME_SINCE_TOUCHED_FLOOR_FOR_RECOM = 10
var isUpsideDown = false
var yMotFlip = 1 # 1 if norm, -1 if not.
var isJumping = true

var WallJumpDustScn = preload('res://FX/WallJumpDust.tscn')
var JumpPoofScn = preload('res://FX/JumpPoof.tscn')
var skidPoofScn = preload('res://FX/skidPoof.tscn')

var hasSkidded = [0,0]

var facing = 1
var jumpGrace = 0
var tGrav = GRAVITY
var motion = Vector2()
var isOnFloor = 0
var timeSinceTouchedFloor = 0
var ctr = 0
onready var oPosition = Vector2()
var desiredScale = Vector2(1, 1)
var desiredScaleAdditive = Vector2(0, 0)
var FLIP_LINE_Y = 0
var wasOnFloor = false

func on_map_changed():
	oPosition = get_node("/root/Node2D/Map/PlayerSpawn").position
	position = oPosition
	isUpsideDown = false

func _ready():
	on_map_changed()

func _physics_process(delta):
	updateIsOnFloor(delta)
	
	if isOnFloor >= COYOTE_TIME and not wasOnFloor:
		desiredScaleAdditive = Vector2(0.05, 0)
	
	if position.y > FLIP_LINE_Y: isUpsideDown = true
	if position.y < FLIP_LINE_Y: isUpsideDown = false
	
	if abs(motion.y) < 5: isJumping = false # works for both peaks of the jump ;)
	
	yMotFlip = -1 if isUpsideDown else 1
	desiredScale = Vector2(1, yMotFlip)
	
	desiredScaleAdditive = lerp(desiredScaleAdditive, Vector2(0, 0), SCALE_FX_RET_SPEED)
	SPRITE.scale = lerp(SPRITE.scale, desiredScale, SCALE_RET_SPEED) + desiredScaleAdditive
	
	var tAccel = ACCEL
	tGrav = GRAVITY * yMotFlip
	
	if motion.x < 0: hasSkidded[1] = 0
	if motion.x > 0: hasSkidded[0] = 0
	
	if jumpGrace > 0: jumpGrace -= delta
	if Input.is_action_just_pressed("jump"): jumpGrace = JUMP_GRACE_TIME
	
	if isOnFloor >= COYOTE_TIME:
		tAccel *= 3
	
	if Input.is_action_pressed("run_right"):
		motion.x += tAccel
		if motion.x + 100 < 0: summonSkid(position-Vector2(22,-10*yMotFlip), motion.x)
		facing = 1
	if Input.is_action_pressed("run_left"):
		motion.x -= tAccel
		if motion.x - 100 > 0: summonSkid(position+Vector2(22, 10*yMotFlip), motion.x)
		facing = -1

	SPRITE.flip_h = true if facing < 0 else false
	
	if isOnFloor >= COYOTE_TIME and jumpGrace > 0:
		makeJumpPoof()
		motion.y = -300 * yMotFlip
		desiredScaleAdditive = Vector2(0.08, -0.08)
		isJumping = true

	fallAndSlide(delta)
	
	#if position.y > 400:
		#Transition.fade_to(world_scene)
	#	respawn()

	wasOnFloor = isOnFloor == COYOTE_TIME
	timeSinceTouchedFloor += delta
	ctr += 1

func makeJumpPoof() -> void:
	var tFX = JumpPoofScn.instance()
	tFX.emitAt(position + Vector2(0, 10*yMotFlip))
	get_parent().add_child(tFX)

func summonSkid(pos, dir):
	if isOnFloor == COYOTE_TIME:
		var ti = 0 if dir < 0 else 1
		if hasSkidded[ti] == 0:
			hasSkidded[ti] = 1
			var tskid = skidPoofScn.instance()
			tskid.summon_at_pos(pos, sign(dir)==-1, isUpsideDown)
			get_parent().add_child(tskid)
			print('summoned poof at ', pos, ' going dir ', dir)

func updateIsOnFloor(delta):
	if is_on_floor():
		isOnFloor = COYOTE_TIME
	elif isOnFloor > 0:
		isOnFloor -= delta

func fallAndSlide(delta):
	motion.y = lerp(motion.y, 0, 0.001)
	if isOnFloor >= COYOTE_TIME:
		#motion.y = min(3, motion.y) # dont build up grav into floors, but keep 3 so is_on_floor stays true :)
		motion.x = lerp(motion.x, 0, FRICTION)
	else:
		motion.x = lerp(motion.x, 0, FRICTION/3)

	motion.x = max(-MAX_SPEED, min(motion.x, MAX_SPEED))

	if isJumping && Input.is_action_pressed("jump"):
		tGrav *= 0.75

	motion.y += tGrav

	motion = move_and_slide(motion, Vector2(0, yMotFlip * -1))