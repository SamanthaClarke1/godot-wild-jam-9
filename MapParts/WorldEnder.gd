extends Area2D

export(String, FILE, "*.tscn") var MAP_PATH = ""

func _on_WorldEnder_body_entered(body):
	if body.name == "Player" and not body.IS_RESPAWNING and not body.IS_DEAD:
		print("WORLD ENDER HIT PLAYER -> ", MAP_PATH)
		body.IS_RESPAWNING = true
		Transition.fade_to_map(MAP_PATH)
