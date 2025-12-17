extends CharacterBody2D

@export var speed: float = 80.0
var target_position: Vector2
var wrapped_count: int = 0  # How many times the chain has wrapped around this zombie

func _ready():
	# Create circle visual
	var polygon = $Polygon2D
	polygon.color = Color.GREEN
	var points = []
	var num_points = 32
	for i in range(num_points):
		var angle = (i / float(num_points)) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * 15)
	polygon.polygon = PackedVector2Array(points)
	
	# Set random target in center of screen
	target_position = Vector2(
		randf_range(200, 600),
		randf_range(200, 400)
	)

func _physics_process(delta):
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Stop when close to target
	if global_position.distance_to(target_position) < 10:
		velocity = Vector2.ZERO

func check_chain_wrap(chain_pos1: Vector2, chain_pos2: Vector2):
	# Simple check if zombie is between the two chain positions
	var to_zombie = global_position - chain_pos1
	var chain_dir = (chain_pos2 - chain_pos1).normalized()
	var projection = to_zombie.dot(chain_dir)
	var chain_length = chain_pos1.distance_to(chain_pos2)
	
	if projection > 0 and projection < chain_length:
		var closest_point = chain_pos1 + chain_dir * projection
		if global_position.distance_to(closest_point) < 20:
			wrapped_count += 1
			return true
	return false

func explode():
	queue_free()
