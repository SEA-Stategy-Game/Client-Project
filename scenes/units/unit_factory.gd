extends Node

const UNIT_SCENES: Dictionary = {
	"normal": preload("res://scenes/units/NormalUnit.tscn"),
	"enemy": preload("res://scenes/units/EnemyUnit.tscn")
}

func create(unit_name: String, obj: Dictionary) -> WorldUnit:
	if not UNIT_SCENES.has(unit_name):
		push_error("UnitFactory: unknown unit type: " + unit_name)
		return null
	name = unit_name
	if int(obj.meta_values.player_id) != PlayerManager.player_local_id:
		name = "enemy"
	var unit: WorldUnit = UNIT_SCENES[name].instantiate()
	unit.entity_id = int(obj.meta_values.entity_id)
	unit.player_id = int(obj.meta_values.player_id)
	unit.position = _parse_vec2(obj.meta_values.position)
	return unit

func _parse_vec2(s: String) -> Vector2:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(", ")
	return Vector2(float(parts[0]), float(parts[1]))
