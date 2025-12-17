extends Node2D

@export var zombie_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var zombies_per_wave: int = 1

var spawn_timer: float = 0.0
var play_area: Rect2

func _ready():
	# Define the actual play area (not viewport size)
	play_area = Rect2(0, 0, 1152, 648)

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_wave()

func spawn_wave():
	for i in range(zombies_per_wave):
		spawn_zombie()

func spawn_zombie():
	if not zombie_scene:
		return
	
	var zombie = zombie_scene.instantiate()
	
	# Spawn from random side of the play area
	var side = randi() % 4
	match side:
		0:  # Top
			zombie.global_position = Vector2(randf_range(0, play_area.size.x), -30)
		1:  # Bottom
			zombie.global_position = Vector2(randf_range(0, play_area.size.x), play_area.size.y + 30)
		2:  # Left
			zombie.global_position = Vector2(-30, randf_range(0, play_area.size.y))
		3:  # Right
			zombie.global_position = Vector2(play_area.size.x + 30, randf_range(0, play_area.size.y))
	
	get_parent().add_child(zombie)
