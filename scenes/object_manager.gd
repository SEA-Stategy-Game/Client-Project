extends Node2D

@onready var objects_node = $"../../Objects"
@onready var client = $"../../ClientGateway"
@onready var tilemap = $"../../Terrain/Grass"

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
				var tile_pos = _parse_to_tile(obj.meta_values.position)
				tree.position = tilemap.map_to_local(tile_pos)
				objects_node.add_child(tree)
			"ressource_stone":
				var rock = ROCK_SCENE.instantiate()
				var tile_pos = _parse_to_tile(obj.meta_values.position)
				rock.position = tilemap.map_to_local(tile_pos)
				objects_node.add_child(rock)

func _parse_to_tile(s: String) -> Vector2i:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(", ")
	var x = roundi(float(parts[0]) / 32.0)
	var y = roundi(float(parts[1]) / 32.0)
	return Vector2i(x, y)

func _on_dynamic_state(state: Dictionary):
	# Delta updates — handle destroyed objects etc.
	pass
