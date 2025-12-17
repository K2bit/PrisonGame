extends Node2D

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D
@export var min_chain_length: float = 50.0
@export var max_chain_length: float = 400.0
@export var reel_speed: float = 100.0

var current_max_length: float = 200.0
var chain_segments: Array = []
var is_player1_reeling: bool = false
var is_player2_reeling: bool = false

func _ready():
	if player1:
		player1.reel_pressed.connect(_on_player_reel)
	if player2:
		player2.reel_pressed.connect(_on_player_reel)

func _process(delta):
	if not player1 or not player2:
		return
	
	# Handle reeling
	if is_player1_reeling or is_player2_reeling:
		current_max_length = max(min_chain_length, current_max_length - reel_speed * delta)
	
	# Expand chain as players move apart
	var distance = player1.global_position.distance_to(player2.global_position)
	if distance > current_max_length:
		current_max_length = min(max_chain_length, distance)
	
	queue_redraw()

func _draw():
	if not player1 or not player2:
		return
	
	var p1_pos = player1.global_position
	var p2_pos = player2.global_position
	var distance = p1_pos.distance_to(p2_pos)
	
	# Draw the chain
	draw_line(to_local(p1_pos), to_local(p2_pos), Color.YELLOW, 3.0)
	
	# Draw segments along the chain
	var num_segments = int(distance / 20.0)
	for i in range(1, num_segments):
		var t = i / float(num_segments)
		var pos = p1_pos.lerp(p2_pos, t)
		draw_circle(to_local(pos), 4, Color.ORANGE)

func _on_player_reel(player_id: int):
	if player_id == 1:
		is_player1_reeling = true
	else:
		is_player2_reeling = true

func _physics_process(delta):
	# Reset reeling flags each frame
	is_player1_reeling = false
	is_player2_reeling = false
