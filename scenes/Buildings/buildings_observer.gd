extends Node2D

@onready var objects_node = $"../../Objects"
@onready var tilemap = $"../../Terrain/tilemap"

func _ready():
	Networking.dynamic_state_received.connect(_on_dynamic_state)

func initialize(state: Dictionary):
	# TODO: Implement logic to spawn initial buildings from the static state.
	pass

func _on_dynamic_state(state: Dictionary):
	# Delta updates — handle destroyed objects etc.
	pass
