extends WorldObserver

@export var resource_node: Node
@export var tilemap: TileMapLayer
var spawned_objects := {}

func initialize(state: Dictionary) -> void:
	print("DEBUG: ResourceObserver initializing...")
	for child in resource_node.get_children():
		child.queue_free()
	spawned_objects.clear()
	for obj in state.get("objects", []):
		var instance: WorldResource = ObjectFactory.create(obj.resource_name, obj)
		if instance:
			resource_node.add_child(instance)
			spawned_objects[instance.world_position] = instance

func _on_dynamic_state(state: Dictionary) -> void:
	for obj in state.get("modified_objects", []):
		var world_pos = _parse_vec2(obj.meta_values.position)
		if obj.get("destroyed", false):
			if spawned_objects.has(world_pos):
				spawned_objects[world_pos].queue_free()
				spawned_objects.erase(world_pos)
