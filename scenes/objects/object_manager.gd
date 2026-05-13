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
	for obj in state.get("objects", []):
		match obj.resource_name:
			"ressource_tree":
				var tree = TREE_SCENE.instantiate()
				tree.position = _parse_to_world(obj.meta_values.position)
				objects_node.add_child(tree)
			"ressource_stone":
				var rock = ROCK_SCENE.instantiate()
				rock.position = _parse_to_world(obj.meta_values.position)
				objects_node.add_child(rock)

func _parse_to_world(s: String) -> Vector2:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(", ")
	return Vector2(float(parts[0]), float(parts[1]))

func _on_dynamic_state(state: Dictionary):
	pass
