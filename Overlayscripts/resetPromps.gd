extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var opacity = 0.0
var targetopacity = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func appear():
	targetopacity = 1
	pass
func dissapear():
	pass
	targetopacity = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	opacity = lerp(opacity,targetopacity,delta*0.5);
	self.modulate.a = opacity
