extends Node

var all_player_ids: Array = []

var player_uuid: String = ""

signal player_id_ready

var player_local_id: int = -1 : set = _set_player_local_id


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _set_player_local_id(value: int) -> void:
	player_local_id = value
	player_id_ready.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
