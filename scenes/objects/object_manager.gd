extends Node2D
@onready var objects_node = $"../../Objects"
@onready var client = $"../../ClientGateway"
@onready var tilemap = $"../../Terrain/tilemap"
const TREE_SCENE = preload("res://scenes/objects/Tree.tscn")
const ROCK_SCENE = preload("res://scenes/objects/Rock.tscn")
var spawned_objects := {}  # key: Vector2 position -> value: Node

func _ready():
	client.static_state_received.connect(_on_static_state)
	client.dynamic_state_received.connect(_on_dynamic_state)

func _on_static_state(state: Dictionary):
	for obj in state.get("objects", []):
		var world_pos = _parse_to_world(obj.meta_values.position)
		var instance: Node2D = null
		match obj.resource_name:
			"ressource_tree":
				instance = TREE_SCENE.instantiate()
			"ressource_stone":
				instance = ROCK_SCENE.instantiate()
		if instance:
			instance.position = world_pos
			objects_node.add_child(instance)
			spawned_objects[world_pos] = instance

func _on_dynamic_state(state: Dictionary):
	for obj in state.get("modified_objects", []):
		var world_pos = _parse_to_world(obj.meta_values.position)
		if obj.get("destroyed", false):
			if spawned_objects.has(world_pos):
				spawned_objects[world_pos].queue_free()
				spawned_objects.erase(world_pos)


func _parse_to_world(s: String) -> Vector2:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(", ")
	return Vector2(int(parts[0]), int(parts[1]))
