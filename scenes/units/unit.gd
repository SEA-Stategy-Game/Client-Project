extends CharacterBody2D
class_name WorldUnit

@export var entity_id: int = -1
@export var player_id: int = 0
@export var max_health: int = 100
var current_health: int

var _server_pos: Vector2 = Vector2.ZERO
var _server_path: Array = []
var _server_speed: float = 3000.0
var _has_server_state: bool = false
var _path_index: int = 0

func _ready() -> void:
	current_health = max_health
	add_to_group("units", true)

func update_from_server(server_pos: Vector2, path: Array, spd: float) -> void:
	_server_pos = server_pos
	_server_path = path
	_server_speed = spd
	_has_server_state = true
	_path_index = 0

func get_player_id() -> int:
	return player_id
