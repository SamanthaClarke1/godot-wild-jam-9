extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target = Vector2(0.0, 0.0)
var vision = 200.0
var velocity = Vector2(0, 0)
var force = Vector2(0, 0)
var enthusiasm = 0.003
var mass = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var temp = velocity;
	var res = move_and_collide(velocity)
	if(res!=null):
		velocity = res.get_remainder().reflect(res.get_normal());
	else:
		velocity = temp
	#position += velocity
	velocity += force/mass
	velocity = lerp(velocity, Vector2(), 0.01)
	target = get_viewport().get_mouse_position();
	force =(( target - position )*enthusiasm)
	pass
	
