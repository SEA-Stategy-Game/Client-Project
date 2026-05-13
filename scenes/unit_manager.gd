extends Node2D

@onready var units_node = $"../../Units"
@onready var client = $"../../ClientGateway"
@onready var tilemap = $"../../Terrain/tilemap"
const UNIT_SCENE = preload("res://scenes/units/Unit.tscn")

var _units: Dictionary = {}  # entity_id -> Unit node

func _ready():
	client.static_state_received.connect(_on_static_state)
	client.dynamic_state_received.connect(_on_dynamic_state)

func _on_static_state(state: Dictionary):
	for child in units_node.get_children():
		child.queue_free()
	_units.clear()
	for obj in state.get("units", []):
		_spawn_unit(obj)

func _on_dynamic_state(state: Dictionary):
	var live_ids: Array = []
	for obj in state.get("units", []):
		var id = int(obj.meta_values.entity_id)
		live_ids.append(id)
		if not _units.has(id):
			_spawn_unit(obj)
			continue
		var unit = _units[id]
		var pos = _parse_vec2(obj.meta_values.position)
		var path = _parse_path(obj.get("path", "[]"))
		var spd = obj.get("speed", 0.0)
		unit.update_from_server(pos, path, spd)
	# Clean up dead units
	for id in _units.keys():
		if id not in live_ids:
			_units[id].queue_free()
			_units.erase(id)

func _spawn_unit(obj: Dictionary) -> void:
	var id = int(obj.meta_values.entity_id)
	var unit = UNIT_SCENE.instantiate()
	unit.entity_id = id
	unit.player_id = int(obj.meta_values.player_id)
	unit.position = _parse_vec2(obj.meta_values.position)
	units_node.add_child(unit)
	_units[id] = unit

func _parse_vec2(s: String) -> Vector2:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(", ")
	return Vector2(float(parts[0]), float(parts[1]))

func _parse_path(s: String) -> Array:
	var result: Array = []
	s = s.trim_prefix("[").trim_suffix("]").strip_edges()
	if s.is_empty():
		return result
	var raw = s.replace("(", "").replace(")", "")
	var entries = raw.split(", ")
	var i = 0
	while i + 1 < entries.size():
		result.append(Vector2(float(entries[i]), float(entries[i + 1])))
		i += 2
	return result
