extends WorldObserver

@export var units_node: Node
var _units: Dictionary = {}

func _on_static_state(state: Dictionary) -> void:
	for child in units_node.get_children():
		child.queue_free()
	_units.clear()
	for obj in state.get("units", []):
		_spawn_unit(obj)

func _on_dynamic_state(state: Dictionary) -> void:
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
	for id in _units.keys():
		if id not in live_ids:
			_units[id].queue_free()
			_units.erase(id)

func _spawn_unit(obj: Dictionary) -> void:
	var unit: WorldUnit = UnitFactory.create("normal", obj)
	if unit:
		units_node.add_child(unit)
		_units[unit.entity_id] = unit

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
