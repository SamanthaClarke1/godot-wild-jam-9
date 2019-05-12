extends LineEdit

func _ready():
	pass


func _on_Syladex_pressed():
	var num = 0
	var MAX_LEVELS = 10
	
	for i in text.length():
		num += 1
		if text[i] in "aeiou":
			num += 2
	
	var levelNum = num % MAX_LEVELS
	var worldNum = floor(num / MAX_LEVELS)
	
	var dir = "res://Maps/World"+str(worldNum)+"/"+str(levelNum)+".tscn"
	get_tree().change_scene("res://Root.tscn");
	Transition.fade_to_map(dir)

