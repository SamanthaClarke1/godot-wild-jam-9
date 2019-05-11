extends KinematicBody2D

onready var SPRITE = get_node("Sprite")
var LineScn = preload("res://Actors/Moving-Platform-Line.tscn")

export(bool) var auto_enable = true
export(bool) var can_be_seen = true
export(float) var is_circular = true
export(float) var cpos = 0
export(float) var speed = 25

var is_enabled = false

var points = []
var toLengths = []

var dir = 1
var lenCap = 0

func makeLines(posArr, isCircular = false):
	var tx = LineScn.instance()
	
	for pos in posArr:
		tx.add_point(pos)
	
	if isCircular:
		tx.add_point(posArr[0])
	
	get_parent().get_node("Points").add_child(tx)

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
	load_points()

func _physics_process(delta):
	if is_enabled:
		var cSpeed = speed * delta
		if is_circular:
			if cpos >= lenCap-cSpeed: cpos = 0
		else:
			if cpos >= lenCap-cSpeed: dir = -1
			if cpos <= 0+cSpeed: dir = 1
		
		cpos += cSpeed * dir
		
		var toPos = getPositionAlongPoints(cpos)
		position = toPos

func enable():
	SPRITE.play("land")

func _on_Sprite_animation_finished():
	if SPRITE.animation == "land":
		is_enabled = true
		SPRITE.play("idle")

func _on_Area2D_body_entered(body):
	if 'Player' in body.name:
		if not auto_enable or is_enabled:
			enable()
