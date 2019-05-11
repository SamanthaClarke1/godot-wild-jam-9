extends KinematicBody2D

export(float) var FRICTION = 0.1

var opos = Vector2()
var target = Vector2()
var vision = 200.0
var velocity = Vector2()
var force = Vector2()
var enthusiasm = 0.003
var mass = 1
var totaltime = 0.0;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	opos = position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	totaltime += delta
	velocity = move_and_slide(velocity)
	
	velocity += force/mass
	velocity = lerp(velocity, Vector2(), FRICTION)
	target = get_viewport().get_mouse_position();
	
	pass
	
