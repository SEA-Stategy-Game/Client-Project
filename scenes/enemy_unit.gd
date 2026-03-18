extends Node2D

const TILE_SIZE := 32

@export var speed := 100.0

var grid_position: Vector2i
var target_tile: Vector2i
var moving := false

var last_direction := Vector2.DOWN

# TileMapLayers
@onready var rocks_layer = $"../Rocks"   # adjust if needed
@onready var trees_layer = $"../Trees"   # adjust if needed

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer


func _ready():
	# Snap to grid
	global_position = grid_to_world(grid_position)
	target_tile = grid_position

	timer.timeout.connect(_on_timer_timeout)
	
	# Add to the "enemies" group so player can hit them
	add_to_group("enemies")


func _process(delta):
	handle_movement(delta)
	handle_animation()


# ------------------------
# RANDOM AI
# ------------------------

func _on_timer_timeout():
	if moving:
		return

	# Optional idle chance
	if randf() < 0.3:
		return

	var directions = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]

	directions.shuffle()

	for dir in directions:
		var next_tile = grid_position + dir
		
		if can_move_to(next_tile):
			try_move(dir)
			return


# ------------------------
# MOVEMENT
# ------------------------

func try_move(dir: Vector2i):
	if moving:
		return

	var next_tile = grid_position + dir

	if can_move_to(next_tile):
		target_tile = next_tile
		last_direction = Vector2(dir)
		moving = true


func handle_movement(delta):
	if not moving:
		return

	var target_pos = grid_to_world(target_tile)
	var direction = target_pos - global_position

	if direction.length() < 2:
		global_position = target_pos
		grid_position = target_tile
		moving = false
		return

	global_position += direction.normalized() * speed * delta


# ------------------------
# ANIMATION
# ------------------------

func handle_animation():
	if not moving:
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
# TILE COLLISION
# ------------------------

func can_move_to(tile: Vector2i) -> bool:
	if rocks_layer and rocks_layer.get_cell_source_id(tile) != -1:
		return false

	if trees_layer and trees_layer.get_cell_source_id(tile) != -1:
		return false

	return true


# ------------------------
# HELPERS
# ------------------------

func grid_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
