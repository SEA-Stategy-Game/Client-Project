extends CharacterBody2D

# ------------------------
# EXPORTS
# ------------------------
@export var speed := 100

# Tile size for your grid
const TILE_SIZE := 32

# ------------------------
# STATE
# ------------------------
var is_attacking := false
var last_direction := Vector2.DOWN
var input_vector := Vector2.ZERO

# ------------------------
# NODES
# ------------------------
@onready var rocks_layer = $"../Rocks"   # adjust path if needed
@onready var trees_layer = $"../Trees"   # adjust path if needed
@onready var sprite = $AnimatedSprite2D

# ------------------------
# MAIN LOOP
# ------------------------
func _physics_process(delta):
	handle_input()
	handle_movement(delta)
	handle_animation()

# ------------------------
# INPUT
# ------------------------
func handle_input():
	input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	# Snap to 4 directions
	input_vector.x = sign(input_vector.x)
	input_vector.y = sign(input_vector.y)

	if input_vector != Vector2.ZERO:
		last_direction = input_vector

	if Input.is_action_just_pressed("click") and not is_attacking:
		attack()

# ------------------------
# MOVEMENT
# ------------------------
func handle_movement(delta):
	velocity = input_vector.normalized() * speed
	move_and_slide()

# ------------------------
# ANIMATION
# ------------------------
func handle_animation():
	if is_attacking:
		return  # keep attack animation playing

	if input_vector == Vector2.ZERO:
		sprite.stop()
		return

	var dir = last_direction

	if abs(dir.y) > abs(dir.x):
		if dir.y > 0:
			sprite.play("run_down")
		else:
			sprite.play("run_up")
	else:
		sprite.play("run_side")
		sprite.flip_h = dir.x < 0

# ------------------------
# ATTACK
# ------------------------
func attack():
	is_attacking = true

	# Remove tiles in front
	remove_tile_in_front()

	# Remove enemies in front
	remove_enemy_in_front()

	# Play attack animation
	var dir = last_direction
	if abs(dir.y) > abs(dir.x):
		if dir.y > 0:
			sprite.play("hit_down")
		else:
			sprite.play("hit_up")
	else:
		sprite.play("hit_side")
		sprite.flip_h = dir.x < 0

	# Wait until animation finishes
	await sprite.animation_finished
	is_attacking = false

# ------------------------
# TILE REMOVAL
# ------------------------
func remove_tile_in_front():
	var layers = [rocks_layer, trees_layer]

	for layer in layers:
		if not layer:
			continue

		# Convert player global position to layer local coordinates
		var local_pos = layer.to_local(global_position)

		# Player tile
		var player_tile = layer.local_to_map(local_pos)

		# Tile in front
		var target_tile = Vector2i(player_tile.x + int(last_direction.x),
								   player_tile.y + int(last_direction.y))

		layer.set_cell(target_tile, -1)  # erase the tile

# ------------------------
# ENEMY REMOVAL
# ------------------------
func remove_enemy_in_front():
	var attack_center = global_position + last_direction * TILE_SIZE
	var attack_size = Vector2(TILE_SIZE * 1.2, TILE_SIZE * 1.2) # slightly bigger

	var attack_rect = Rect2(attack_center - attack_size/2, attack_size)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if attack_rect.has_point(enemy.global_position):
			enemy.queue_free()
