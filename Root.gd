extends Node2D

var mapColorArr = [
	['FirstWorld', Color(0.7, 0.4, 0.4, 1)],
	['SecondWorld', Color(0.4, 0.5, 0.7, 1)]
]

var tcolor = Color(1,1,1,1)

class MyCustomSorter:
	static func sortByDirAmt(a, b):
		return len(a[0].split('/')) > len(b[0].split('/'))

func _ready():
	var tfName = get_node("Map").filename
	mapColorArr.sort_custom(MyCustomSorter, 'sortByDirAmt')
	map_changed(tfName)

func map_changed(path: String):
	for arr in mapColorArr:
		if arr[0] in path:
			tcolor = arr[1]
			break
	
	applyModulate(tcolor)
	get_node("Player").on_map_changed(path)

func applyModulate(color: Color):
	get_node("Player/ParallaxBackground/ParallaxLayer/Sprite").modulate = color
	get_node("Map/TileMap").modulate = color
	get_node("Map/WorldEnder").modulate = color
	get_node("Map/FlipLine").modulate = color