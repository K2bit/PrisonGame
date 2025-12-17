extends CharacterBody2D

@export var player_id: int = 1  # 1 or 2
@export var speed: float = 200.0
@export var color: Color = Color.BLUE

var input_up: String
var input_down: String
var input_left: String
var input_right: String
var input_reel: String

signal reel_pressed(player_id: int)

func _ready():
	# Set up input keys based on player ID
	if player_id == 1:
		input_up = "w"
		input_down = "s"
		input_left = "a"
		input_right = "d"
		input_reel = "r"
		color = Color.BLUE
	else:
		input_up = "i"
		input_down = "k"
		input_left = "j"
		input_right = "l"
		input_reel = "p"
		color = Color.RED
	
	# Create circle visual
	var polygon = $Polygon2D
	polygon.color = color
	var points = []
	var num_points = 32
	for i in range(num_points):
		var angle = (i / float(num_points)) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * 20)
	polygon.polygon = PackedVector2Array(points)

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	# Use match statement with player_id for cleaner input handling
	if player_id == 1:
		if Input.is_physical_key_pressed(KEY_W):
			input_vector.y -= 1
		if Input.is_physical_key_pressed(KEY_S):
			input_vector.y += 1
		if Input.is_physical_key_pressed(KEY_A):
			input_vector.x -= 1
		if Input.is_physical_key_pressed(KEY_D):
			input_vector.x += 1
		if Input.is_physical_key_pressed(KEY_R):
			reel_pressed.emit(player_id)
	else:  # player_id == 2
		if Input.is_physical_key_pressed(KEY_I):
			input_vector.y -= 1
		if Input.is_physical_key_pressed(KEY_K):
			input_vector.y += 1
		if Input.is_physical_key_pressed(KEY_J):
			input_vector.x -= 1
		if Input.is_physical_key_pressed(KEY_L):
			input_vector.x += 1
		if Input.is_physical_key_pressed(KEY_P):
			reel_pressed.emit(player_id)
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	move_and_slide()
	
	# Check for zombie collisions
	check_zombie_collision()

func check_zombie_collision():
	var zombies = get_tree().get_nodes_in_group("zombies")
	for zombie in zombies:
		if global_position.distance_to(zombie.global_position) < 35:  # 20 + 15 radius
			# Handle player damage here later
			# For now, just visual feedback
			$Polygon2D.modulate = Color(1, 0.5, 0.5)
			await get_tree().create_timer(0.1).timeout
			$Polygon2D.modulate = Color.WHITE
			break
