extends Node2D

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D
@export var min_chain_length: float = 50.0
@export var max_chain_length: float = 500.0
@export var reel_speed: float = 150.0
@export var chain_stiffness: float = 0.3
@export var num_chain_segments: int = 10
@export var chain_collision_radius: float = 25.0  # How close zombies need to be to "touch" chain

var current_max_length: float = 300.0
var chain_points: Array = []
var is_player1_reeling: bool = false
var is_player2_reeling: bool = false
var wrapped_zombies: Array = []

func _ready():
	if player1:
		player1.reel_pressed.connect(_on_player_reel)
	if player2:
		player2.reel_pressed.connect(_on_player_reel)
	
	# Initialize chain points
	if player1 and player2:
		for i in range(num_chain_segments + 1):
			var t = i / float(num_chain_segments)
			var pos = player1.global_position.lerp(player2.global_position, t)
			chain_points.append(pos)

func _process(delta):
	if not player1 or not player2:
		return
	
	# Handle reeling
	if is_player1_reeling or is_player2_reeling:
		current_max_length = max(min_chain_length, current_max_length - reel_speed * delta)
		check_for_kills()
	else:
		# Gradually expand max length when not reeling
		var distance = player1.global_position.distance_to(player2.global_position)
		if distance > current_max_length:
			current_max_length = min(max_chain_length, current_max_length + reel_speed * delta * 0.5)
	
	# Update chain physics
	update_chain_physics(delta)
	
	# Check for chain collisions with zombies
	check_chain_collisions()
	
	queue_redraw()

func update_chain_physics(delta):
	if chain_points.size() != num_chain_segments + 1:
		return
	
	# Lock first and last points to players
	chain_points[0] = player1.global_position
	chain_points[num_chain_segments] = player2.global_position
	
	# Simulate rope physics for middle points
	var segment_length = current_max_length / num_chain_segments
	
	# Multiple iterations for stability
	for iteration in range(3):
		# Move points toward their ideal positions
		for i in range(1, num_chain_segments):
			var prev = chain_points[i - 1]
			var curr = chain_points[i]
			var next = chain_points[i + 1]
			
			# Average between neighbors
			var ideal_pos = (prev + next) / 2.0
			chain_points[i] = curr.lerp(ideal_pos, chain_stiffness)
		
		# Constrain distances between segments
		for i in range(num_chain_segments):
			var p1 = chain_points[i]
			var p2 = chain_points[i + 1]
			var dist = p1.distance_to(p2)
			var diff = dist - segment_length
			
			if dist > 0:
				var direction = (p2 - p1).normalized()
				var correction = direction * diff * 0.5
				
				if i > 0:
					chain_points[i] += correction
				if i < num_chain_segments - 1:
					chain_points[i + 1] -= correction

func check_chain_collisions():
	var zombies = get_tree().get_nodes_in_group("zombies")
	wrapped_zombies.clear()
	
	for zombie in zombies:
		var is_touching_chain = false
		
		# Check if zombie is close to any chain segment
		for i in range(chain_points.size() - 1):
			var p1 = chain_points[i]
			var p2 = chain_points[i + 1]
			
			var closest_point = get_closest_point_on_segment(zombie.global_position, p1, p2)
			var distance = zombie.global_position.distance_to(closest_point)
			
			if distance < chain_collision_radius:
				is_touching_chain = true
				wrapped_zombies.append(zombie)
				break
		
		if is_touching_chain:
			# Zombie is wrapped, slow it down
			zombie.set_wrapped(true, 0.3)
		else:
			zombie.set_wrapped(false)

func get_closest_point_on_segment(point: Vector2, seg_start: Vector2, seg_end: Vector2) -> Vector2:
	var segment = seg_end - seg_start
	var segment_length_sq = segment.length_squared()
	
	if segment_length_sq == 0:
		return seg_start
	
	var t = clamp((point - seg_start).dot(segment) / segment_length_sq, 0.0, 1.0)
	return seg_start + segment * t

func check_for_kills():
	# Check if any wrapped zombies are inside the chain loop
	var zombies = get_tree().get_nodes_in_group("zombies")
	
	for zombie in zombies:
		if zombie.is_wrapped and is_chain_forming_loop():
			# Check if zombie is inside the loop
			if zombie.is_inside_chain_loop(chain_points):
				zombie.explode()

func is_chain_forming_loop() -> bool:
	# Check if the chain is tight enough to form a killing loop
	# The chain forms a loop when players are close enough and reeling
	var distance = player1.global_position.distance_to(player2.global_position)
	return distance < current_max_length * 0.7 and (is_player1_reeling or is_player2_reeling)

func _draw():
	if not player1 or not player2:
		return
	
	if chain_points.size() < 2:
		return
	
	# Draw the chain segments
	for i in range(chain_points.size() - 1):
		var p1 = to_local(chain_points[i])
		var p2 = to_local(chain_points[i + 1])
		
		# Make chain red when reeling
		var chain_color = Color.RED if (is_player1_reeling or is_player2_reeling) else Color.YELLOW
		draw_line(p1, p2, chain_color, 4.0)
	
	# Draw chain links
	for i in range(chain_points.size()):
		var pos = to_local(chain_points[i])
		draw_circle(pos, 5, Color.ORANGE)
	
	# Debug: Draw collision radius around chain (optional, comment out later)
	# for i in range(chain_points.size() - 1):
	# 	var p1 = to_local(chain_points[i])
	# 	draw_circle(p1, chain_collision_radius, Color(1, 1, 0, 0.1))

func _on_player_reel(player_id: int):
	if player_id == 1:
		is_player1_reeling = true
	else:
		is_player2_reeling = true

func _physics_process(delta):
	# Reset reeling flags each frame
	is_player1_reeling = false
	is_player2_reeling = false
	
	# Apply constraint to keep players within max chain length
	if player1 and player2:
		var distance = player1.global_position.distance_to(player2.global_position)
		if distance > current_max_length:
			var direction = (player2.global_position - player1.global_position).normalized()
			var overlap = distance - current_max_length
			
			player1.global_position += direction * overlap * 0.5
			player2.global_position -= direction * overlap * 0.5

func get_chain_points() -> Array:
	return chain_points
