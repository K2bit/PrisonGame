extends TextureRect

func _ready():
	visible = false # Ensure it's hidden when game starts

func _on_player_died():
	# 1. Show the "Game Over" image
	visible = true
	
	# 2. Pause the game (stops zombies/players moving)
	get_tree().paused = true
	
	# 3. Wait 3 seconds (allows player to see the image)
	# We create a timer that ignores the pause state
	await get_tree().create_timer(3.0).timeout
	
	# 4. Unpause and Restart
	get_tree().paused = false
	get_tree().reload_current_scene()
