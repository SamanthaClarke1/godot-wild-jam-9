extends Label

var opacity = 0
var targetopacity = 0

var rotation = 0
var desiredScale = Vector2(0.1, 0.1)
var ctr = 0

export(float) var SPEED = 1.5

func _ready():
	pass # Replace with function body.

func appear():
	if targetopacity != 1:
		desiredScale = Vector2(1, 1)
		targetopacity = 1

func dissapear():
	if targetopacity != 0:
		targetopacity = 0
		desiredScale = Vector2(0.1, 0.1)

func _process(delta):
	ctr += delta
	if targetopacity != 0: desiredScale += Vector2(sin(ctr)*0.0015, sin(ctr+0.5)*0.0015)
	
	opacity = lerp(opacity, targetopacity, delta*SPEED)
	rect_scale = lerp(rect_scale, desiredScale, delta*SPEED)
	
	modulate.a = opacity
