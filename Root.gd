extends Node2D

var mapColorDict = {
	'res://Maps/FirstLevel.tscn': Color(0.7, 0.4, 0.4, 1)
}


func _ready():
	onNewMap(get_node("Map").filename)

func onNewMap(path: String):
	if path in mapColorDict:
		applyModulate(mapColorDict[path])
	else:
		applyModulate(Color(1,1,1,1))

func applyModulate(color: Color):
	get_node("Player/ParallaxBackground/ParallaxLayer/Sprite").modulate = color
	get_node("Map/TileMap").modulate = color
	get_node("Map/WorldEnder").modulate = color