extends CharacterBody2D
class_name WorldUnit

@export var entity_id: int = -1
@export var player_id: int = 0
@export var max_health: int = 99
var current_health: int

var _server_pos: Vector2 = Vector2.ZERO
var _server_path: Array = []
var _server_speed: float = 3000.0
var _has_server_state: bool = false
var _path_index: int = 0

@onready var id_label: Label = $Label
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	
	current_health = max_health

	add_to_group("units", true)

	id_label.text = "ID: " + str(entity_id)

	health_bar.max_value = max_health
	health_bar.value = current_health

	update_ui()

func update_ui() -> void:
	# Always show ID for your units
	id_label.visible = player_id == PlayerManager.player_local_id

	# Show health only when damaged
	health_bar.visible = player_id == PlayerManager.player_local_id

	health_bar.value = current_health

func update_from_server(server_pos: Vector2, path: Array, spd: float) -> void:
	_server_pos = server_pos
	_server_path = path
	_server_speed = spd
	_has_server_state = true
	_path_index = 0

func get_player_id() -> int:
	return PlayerManager.player_local_id
