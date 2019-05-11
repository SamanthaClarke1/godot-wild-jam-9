extends Area2D

export(String) var MAP_PATH = ""

func _on_WorldEnder_body_entered(body):
	if body.name == "Player":
		Transition.fade_to_map(MAP_PATH)
