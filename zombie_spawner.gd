extends Node2D

@export var zombie_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var zombies_per_wave: int = 3

var spawn_timer: float = 0.0
var screen_size: Vector2

func _ready():
	screen_size = get_viewport_rect().size

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
	
	# Spawn from random side
	var side = randi() % 4
	match side:
		0:  # Top
			zombie.global_position = Vector2(randf_range(0, screen_size.x), -30)
		1:  # Bottom
			zombie.global_position = Vector2(randf_range(0, screen_size.x), screen_size.y + 30)
		2:  # Left
			zombie.global_position = Vector2(-30, randf_range(0, screen_size.y))
		3:  # Right
			zombie.global_position = Vector2(screen_size.x + 30, randf_range(0, screen_size.y))
	
	get_parent().add_child(zombie)
