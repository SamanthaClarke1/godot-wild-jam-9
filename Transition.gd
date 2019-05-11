extends CanvasLayer

onready var ANIM_PLAYER = get_node("AnimationPlayer")


var path = ""
var tScene
var mapPath = ""

func fade_to_map(scn_path):
	#print('fade_to_map(path) called')
	self.path = scn_path
	tScene = load(path)
	ANIM_PLAYER.play("changescene")
	get_node("/root/Node2D/Player").loaded()

func change_scene():
	print('change scene called')
	if path != "":
		get_node("/root/Node2D").remove_child(get_node("/root/Node2D/Map"))
		get_node("/root/Node2D").add_child(tScene.instance(), true)
		get_node("/root/Node2D").map_changed()
