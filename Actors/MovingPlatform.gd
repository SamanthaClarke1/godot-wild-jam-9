extends KinematicBody2D

#settings set from moving platform node2d parent
var auto_enable
var can_be_seen
var is_circular
var cpos
var speed

onready var SPRITE = get_node("Sprite")
onready var DETECTOR = get_node("Detector")
var LineScn = preload("res://Actors/Moving-Platform-Line.tscn")

var is_enabled = false setget set_is_enabled
func set_is_enabled(f):
	is_enabled = f

var points = []
var toLengths = []

var dir = 1
var lenCap = 0

onready var PARENT = get_parent()

func makeLines(posArr, isCircular = false):
	var tx = LineScn.instance()
	
	for pos in posArr:
		tx.add_point(pos)
	
	if isCircular:
		tx.add_point(posArr[0])
	
	get_parent().get_node("Points").add_child(tx)

func load_settings():
	auto_enable = PARENT.auto_enable
	can_be_seen = PARENT.can_be_seen
	is_circular = PARENT.is_circular
	cpos = PARENT.cpos
	speed = PARENT.speed
	SPRITE.flip_v = PARENT.flipv

func load_points():
	points = []
	toLengths = []
	lenCap = 0
	
	for f in get_parent().get_node("Points").get_children():
		points.push_back(f.position)
	for i in range(len(points) - 1):
		lenCap += (points[i+1] - points[i]).length()
		toLengths.push_back(lenCap)
	
	if is_circular:
		lenCap += (points[len(points)-1] - points[0]).length()
		toLengths.push_back(lenCap)
	
	if can_be_seen:
		makeLines(points, is_circular)
	
	dir = 1
	if auto_enable:
		is_enabled = true
	
	position = getPositionAlongPoints(cpos)

func getPositionAlongLine(pos, lineNum):
	pos -= toLengths[lineNum]
	var startPos = points[lineNum]
	var endPos = points[(lineNum+1)%len(points)]
	return ((endPos - startPos).normalized() * pos) + endPos

func getPositionAlongPoints(cpos):
	for i in range(len(toLengths)):
		if cpos <= toLengths[i]:
			return getPositionAlongLine(cpos, i)

func _ready():
	load_settings()
	load_points()

func _physics_process(delta):
	var bodies = DETECTOR.get_overlapping_bodies()
	for body in bodies:
		if "Player" in body.name:
			enable()
	
	if is_enabled:
		var cSpeed = speed * delta
		if is_circular:
			if cpos >= lenCap-cSpeed: cpos = 0
		else:
			if cpos >= lenCap-cSpeed: dir = -1
			if cpos <= 0+cSpeed: dir = 1
		
		cpos += cSpeed * dir
		
		var motion = getPositionAlongPoints(cpos) - position
		motion = move_and_slide(motion)
		
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if "MovingPlatform" in collision.collider.name:
				collision.collider.set_is_enabled(true)

func enable():
	if not auto_enable and not is_enabled:
		SPRITE.play("land")

func _on_Sprite_animation_finished():
	if SPRITE.animation == "land":
		is_enabled = true
		SPRITE.play("idle")
