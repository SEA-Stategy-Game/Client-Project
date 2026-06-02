extends Node2D
class_name WorldObserver

func _ready():
	Networking.dynamic_state_received.connect(_on_dynamic_state)

# This is a virtual function to be implemented by child observers.
# It's called by the scene director (node_2d.gd) to pass the initial world state.
func initialize(state: Dictionary) -> void:
	pass

func _on_dynamic_state(state: Dictionary) -> void:
	pass

func _parse_vec2(s: String) -> Vector2:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(", ")
	return Vector2(float(parts[0]), float(parts[1]))
