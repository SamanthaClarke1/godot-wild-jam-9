extends KinematicBody2D

onready var SPRITE = get_node("Sprite")
onready var ROOTNODE = get_node("/root/Node2D")
onready var DEATHTIMER = get_node("DeathTimer")
onready var COLLISIONSHAPE = get_node("CollisionShape2D")
onready var RESPAWN_BUFFER = get_node("RespawnBuffer")
onready var LIGHTOCCLUDER = get_node("LightOccluder2D")

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
const TIME_SINCE_TOUCHED_FLOOR_FOR_RECOM = 7.5

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
var mMap = ""
var pMap = ""

var MAPFROMCOLOR: Color
var MAPLIGHTCOLOR: Color
var MAPDARKCOLOR: Color
var MAPFLIPCOLOR_DEADZONE = 0.1
var MAPFLIPCOLOR_SCALE = 300.0

var IS_DEAD = false
var IS_RESPAWNING = false

var ownedCoins = {}
var tempCoins = {}

func updateCoinsCollected(deep=false):
	Overlay.COINSAMT.changeAmt(getTotalOwnedCoins())

func on_map_changed(map):
	pMap = mMap
	mMap = map
	oPosition = get_node("/root/Node2D/Map/PlayerSpawn").position
	position = oPosition
	motion = Vector2()
	isUpsideDown = false
	MAPFROMCOLOR = ROOTNODE.tcolor
	MAPDARKCOLOR = MAPFROMCOLOR.darkened(0.3)
	MAPLIGHTCOLOR = MAPFROMCOLOR.lightened(0.3)
	desiredScale = Vector2(1, 1)
	IS_DEAD = false
	timeSinceTouchedFloor = 0
	RESPAWN_BUFFER.start()
	
	if not ownedCoins.get(pMap): ownedCoins[pMap] = {}
	
	for key in tempCoins:
		if tempCoins[key]:
			ownedCoins[pMap][key] = true
			
	if ownedCoins.get(mMap):
		for key in ownedCoins[mMap]:
			if ownedCoins[mMap][key]:
				var tc = get_node("/root/Node2D/Map/Coins/"+key)
				if tc: tc.modulate.a = 0.1
			
	resetTempCoins()
	
	updateCoinsCollected()
	saveCoins()

func saveCoins():
	var tf = File.new()
	if tf.open("user://coins.json", File.WRITE) != 0:
		print("could not save!")
	else:
		tf.store_line(to_json(ownedCoins))
	tf.close()

func getTotalOwnedCoins():
	var total = 0
	for key in tempCoins: if tempCoins[key]: total += 1
	for map in ownedCoins: if map != mMap:
		for key in ownedCoins[map]: if ownedCoins[map][key]: total += 1
	return total

func die(): # called by multiple objects when you die
	if not IS_DEAD and not IS_RESPAWNING:
		IS_DEAD = true
		resetTempCoins()
		updateCoinsCollected()
		DEATHTIMER.start()

func collectCoin(coinName): # called by coins when you collect them
	tempCoins[coinName] = true
	updateCoinsCollected()

func respawn():
	IS_RESPAWNING = true
	Transition.fade_to_map(mMap)
	
func resetTempCoins():
	for key in tempCoins:
		tempCoins[key] = false
	if ownedCoins.get(mMap):
		for key in ownedCoins[mMap]: tempCoins[key] = ownedCoins[mMap][key]

func _ready():
	Overlay.COINSAMT.appear()
	
	var tf = File.new()
	if tf.open("user://coins.json", File.READ) != 0:
		print("could not load coin file!")
	else:
		var tdata = parse_json(tf.get_line())
		if tdata:
			ownedCoins = tdata
			updateCoinsCollected()
		else:
			print("couldn't parse coin file")
	tf.close()

func _physics_process(delta):
	updateIsOnFloor(delta)
	
	#print(IS_RESPAWNING, IS_DEAD)
	
	var tlerp = clamp((position.y/MAPFLIPCOLOR_SCALE)+0.5, 0, 1)
	#if tlerp > 0.5: tlerp = max(0.5+MAPFLIPCOLOR_DEADZONE, tlerp)
	#if tlerp < 0.5: tlerp = min(0.5-MAPFLIPCOLOR_DEADZONE, tlerp)
	ROOTNODE.applyModulate(lerp(MAPLIGHTCOLOR, MAPDARKCOLOR, tlerp))
	
	if isOnFloor >= COYOTE_TIME and not wasOnFloor:
		desiredScaleAdditive = Vector2(0.05, 0)
	
	if position.y > FLIP_LINE_Y: isUpsideDown = true
	if position.y < FLIP_LINE_Y: isUpsideDown = false
	
	if abs(motion.y) < 5: isJumping = false # works for both peaks of the jump ;)
	
	yMotFlip = -1 if isUpsideDown else 1
	desiredScale = Vector2(1, yMotFlip)
	if IS_DEAD:
		desiredScale = Vector2(0,0)
	
	desiredScaleAdditive = lerp(desiredScaleAdditive, Vector2(0, 0), SCALE_FX_RET_SPEED)
	SPRITE.scale = lerp(SPRITE.scale, desiredScale, SCALE_RET_SPEED) + desiredScaleAdditive
	COLLISIONSHAPE.scale = SPRITE.scale
	LIGHTOCCLUDER.scale = SPRITE.scale
	
	var tAccel = ACCEL
	tGrav = GRAVITY * yMotFlip
	
	if motion.x < 0: hasSkidded[1] = 0
	if motion.x > 0: hasSkidded[0] = 0
	
	if not IS_DEAD and not IS_RESPAWNING:
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
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if "Spike" in collision.collider.name:
			die()
	
	#if position.y > 400:
		#Transition.fade_to(world_scene)
	#	respawn()
	
	if Input.is_action_just_pressed("reset"):
		resetTempCoins()
		respawn()

	wasOnFloor = isOnFloor == COYOTE_TIME
	if isOnFloor == COYOTE_TIME: timeSinceTouchedFloor = 0
	timeSinceTouchedFloor += delta
	
	if timeSinceTouchedFloor >= TIME_SINCE_TOUCHED_FLOOR_FOR_RECOM and not IS_DEAD and not IS_RESPAWNING:
		Overlay.RESETPROMPT.appear()
	else:
		Overlay.RESETPROMPT.dissapear()
	
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

func _on_DeathTimer_timeout():
	respawn()

func _on_RespawnBuffer_timeout():
	IS_RESPAWNING = false
