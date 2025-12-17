extends CharacterBody2D

@export var speed: float = 80.0
@export var base_speed: float = 80.0
var target_position: Vector2
var is_wrapped: bool = false
var wrap_slowdown: float = 1.0  # 1.0 = full speed, 0.0 = stopped

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
		randf_range(200, 950),
		randf_range(200, 450)
	)
	
	add_to_group("zombies")
	base_speed = speed

func _physics_process(delta):
	# Apply speed reduction if wrapped
	var current_speed = base_speed * wrap_slowdown
	
	var direction = (target_position - global_position).normalized()
	velocity = direction * current_speed
	move_and_slide()
	
	# Stop when close to target
	if global_position.distance_to(target_position) < 10:
		velocity = Vector2.ZERO
	
	# Visual feedback when wrapped
	if is_wrapped:
		$Polygon2D.color = Color.DARK_RED
	else:
		$Polygon2D.color = Color.GREEN

func set_wrapped(wrapped: bool, slowdown: float = 0.3):
	is_wrapped = wrapped
	wrap_slowdown = slowdown if wrapped else 1.0

func is_inside_chain_loop(chain_points: Array) -> bool:
	# Use ray casting method to determine if point is inside polygon
	if chain_points.size() < 3:
		return false
	
	var point = global_position
	var intersections = 0
	
	for i in range(chain_points.size()):
		var p1 = chain_points[i]
		var p2 = chain_points[(i + 1) % chain_points.size()]
		
		# Ray casting to the right
		if ((p1.y > point.y) != (p2.y > point.y)) and \
		   (point.x < (p2.x - p1.x) * (point.y - p1.y) / (p2.y - p1.y) + p1.x):
			intersections += 1
	
	return intersections % 2 == 1

func explode():
	# Add a simple visual effect before dying
	$Polygon2D.color = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	queue_free()
