extends LineEdit

var defaultMap = "res://Maps/World0/0.tscn"

var passwords = [
	'cxxl', 'leap', 'electric'
]

func getDir():
	var num = 0
	var MAX_LEVELS = 10
	
	var dir = defaultMap
	var ttext = text.to_lower()
	
	if ttext in passwords:
		for i in ttext.length():
			num += 1
			if ttext[i] in "q":
				num += 9
			if ttext[i] in "zmno":
				num += 4
			if ttext[i] in "aeiou":
				num += 1
		
		var levelNum = num % MAX_LEVELS
		var worldNum = floor(num / MAX_LEVELS)
		
		dir = "res://Maps/World"+str(worldNum)+"/"+str(levelNum)+".tscn"
	
	return dir

func _ready():
	pass

func _on_startbutton_pressed():
	Transition.fade_to_map(getDir())

func _on_LineEdit_text_entered(new_text):
	Transition.fade_to_map(getDir())
