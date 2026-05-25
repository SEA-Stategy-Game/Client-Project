extends Node2D
class_name WorldObserver

func _ready():
	Networking.static_state_received.connect(_on_static_state)
	Networking.dynamic_state_received.connect(_on_dynamic_state)

func _on_static_state(state: Dictionary) -> void:
	pass

func _on_dynamic_state(state: Dictionary) -> void:
	pass

func _parse_vec2(s: String) -> Vector2:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(", ")
	return Vector2(float(parts[0]), float(parts[1]))
