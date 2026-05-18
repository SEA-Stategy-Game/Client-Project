extends Node2D

@onready var objects_node = $"../../Objects"
@onready var client = $"../../ClientGateway"
@onready var tilemap = $"../../Terrain/tilemap"

const TREE_SCENE = preload("res://scenes/objects/Tree.tscn")
const ROCK_SCENE = preload("res://scenes/objects/Rock.tscn")

func _ready():
	client.static_state_received.connect(_on_static_state)
	client.dynamic_state_received.connect(_on_dynamic_state)

func _on_static_state(state: Dictionary):
	for obj in state.get("buildings", []):
		print(obj)

func _on_dynamic_state(state: Dictionary):
	# Delta updates — handle destroyed objects etc.
	pass
