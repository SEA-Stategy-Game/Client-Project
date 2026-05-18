extends CharacterBody2D
class_name Unit

@export var entity_id: int = -1
@export var player_id: int = 0
@export var max_health: int = 100

var current_health: int
var _server_pos: Vector2 = Vector2.ZERO
var _server_path: Array = []
var _server_speed: float = 3000.0
var _has_server_state: bool = false
var _path_index: int = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	current_health = max_health
	add_to_group("units", true)

func update_from_server(server_pos: Vector2, path: Array, spd: float) -> void:
	_server_pos = server_pos
	_server_path = path
	_server_speed = spd
	_has_server_state = true
	_path_index = 0

func _physics_process(delta) -> void:
	if not _has_server_state:
		animated_sprite.stop()
		return

	var target: Vector2

	if _server_path.size() > 0 and _path_index < _server_path.size():
		target = _server_path[_path_index]
		if global_position.distance_to(target) < 1.0:
			_path_index += 1
			return
	else:
		target = _server_pos
		if global_position.distance_to(target) < 1.0:
			animated_sprite.stop()
			return

	var direction = (target - global_position).normalized()
	velocity = direction * _server_speed * delta
	move_and_slide()
	_update_movement_animation(direction)

func _update_movement_animation(direction: Vector2) -> void:
	var anim: String

	if abs(direction.x) >= abs(direction.y):
		# Moving horizontally — use run_side, flip for left
		anim = "run_side"
		animated_sprite.flip_h = direction.x < 0
	elif direction.y < 0:
		# Moving up
		anim = "run_up"
		animated_sprite.flip_h = false
	else:
		# Moving down
		anim = "run_down"
		animated_sprite.flip_h = false

	if animated_sprite.animation != anim:
		animated_sprite.play(anim)

func get_player_id() -> int:
	return player_id
