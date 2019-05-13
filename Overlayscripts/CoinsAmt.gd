extends Label

const SPEED = 1.5

var targetOpacity = 0
var targetAmt = 0
var amt = 0
var desiredScale = Vector2()
var ctr = 0

func _ready():
	pass

func appear(): 
	targetOpacity = 1
	desiredScale = Vector2(1, 1)

func dissapear(): 
	targetOpacity = 0
	desiredScale = Vector2()

func changeAmt(amt): targetAmt = amt

func _process(delta):
	modulate.a = lerp(modulate.a, targetOpacity, delta * SPEED)
	amt = lerp(amt, targetAmt, delta * SPEED * 2)
	text = "Coins: " + str(round(amt))
	
	if targetOpacity != 0: desiredScale += Vector2(sin(ctr)*0.001, sin(ctr+0.5)*0.001)
	
	rect_scale = lerp(rect_scale, desiredScale, delta * SPEED)
	ctr += 1
