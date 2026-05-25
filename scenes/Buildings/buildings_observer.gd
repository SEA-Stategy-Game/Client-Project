extends Node2D

@onready var objects_node = $"../../Objects"
@onready var tilemap = $"../../Terrain/tilemap"

func _ready():
	Networking.static_state_received.connect(_on_static_state)
	Networking.dynamic_state_received.connect(_on_dynamic_state)

func _on_static_state(state: Dictionary):
	for obj in state.get("buildings", []):
		print(obj)

func _on_dynamic_state(state: Dictionary):
	# Delta updates — handle destroyed objects etc.
	pass
