extends TextureRect

func _on_player_1_health_changed(new_health: int):
		if new_health >= 100:
			texture = load("res://assets/ui/health-bar/health-bar-100-player.png")
		else:
			texture = load("res://assets/ui/health-bar/health-bar-" + str(new_health) + "-player.png")
