class_name WorldObject
extends StaticBody2D

var world_position: Vector2

func initialise(obj: Dictionary) -> void:
	world_position = _parse_to_world(obj.meta_values.position)
	position = world_position

func _parse_to_world(s: String) -> Vector2:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(", ")
	return Vector2(int(parts[0]), int(parts[1]))
