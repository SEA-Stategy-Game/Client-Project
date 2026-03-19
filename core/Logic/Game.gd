extends Node

@onready var spawn = preload("res://core/Entities/Interfaces/spawn_unit.tscn")

var Wood = 0
var Stone = 0

func spawnUnit(position):
	var path = get_tree().get_root().get_node("World/UI")
	var hasSpawn = false
	for i in path.get_child_count():
		if "spawnUnit" in path.get_child(i).name:
			hasSpawn = true
	if hasSpawn == false:
		var spawn_unit = spawn.instantiate()
		spawn_unit.housePos = position
		path.add_child(spawn_unit)
