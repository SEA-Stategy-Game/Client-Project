extends Node2D
@onready var objects_node = $"../../Objects"
@onready var tilemap = $"../../Terrain/tilemap"

var spawned_objects := {}  # key: Vector2 position -> value: Node

func _ready():
	Networking.static_state_received.connect(_on_static_state)
	Networking.dynamic_state_received.connect(_on_dynamic_state)

func _on_static_state(state: Dictionary):
	for obj in state.get("objects", []):
		var instance: WorldObject = ObjectFactory.create(obj.resource_name, obj)
		if instance:
			objects_node.add_child(instance)
			spawned_objects[instance.world_position] = instance
			
			
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
