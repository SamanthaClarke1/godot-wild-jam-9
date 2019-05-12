extends Area2D

var ctr = 0
var WOBBLESPEED = 5
var WOBBLELENGTH = 0.15

func _ready():
	ctr = rand_range(0, 5)

func _physics_process(delta):
	ctr += delta
	position.y += sin(ctr*WOBBLESPEED)*WOBBLELENGTH

func _on_Coin_body_entered(body):
	if "Player" in body.name:
		body.collectCoin()
		queue_free()
