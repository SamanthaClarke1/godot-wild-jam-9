extends CanvasLayer

onready var ANIM_PLAYER = get_node("AnimationPlayer")

var scnPath = ""
var tScene = null
var mapPath = ""
var changingSceneTo = null

func fade_to_scene(scn_path):
	scnPath = scn_path
	changingSceneTo = load(scnPath)
	ANIM_PLAYER.play("changescene")

func change_scene():
	if mapPath != "":
		get_tree().change_scene(changingSceneTo)

func fade_to_map(scn_path):
	mapPath = scn_path
	tScene = load(mapPath)
	ANIM_PLAYER.play("changemap")

func change_map():
	if mapPath != "":
		print('changemapcalled')
		get_node("/root/Node2D").remove_child(get_node("/root/Node2D/Map"))
		get_node("/root/Node2D").add_child(tScene.instance(), true)
		get_node("/root/Node2D").map_changed(mapPath)
