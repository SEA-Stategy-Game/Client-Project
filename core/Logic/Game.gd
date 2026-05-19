extends Node

signal world_ready(world: Node)

@onready var _spawn_scene: PackedScene = preload("res://scenes/units/Unit.tscn")
@onready var _default_world_scene: PackedScene = preload("res://scenes/test_world.tscn")

var world: Node = null
var Wood: int = 0
var Stone: int = 0

func _ready() -> void:
	# Do not auto-instantiate the world when the launcher is the main scene.
	# The launcher controls when and where the deterministic test world appears.
	pass

func ensure_world(parent: Node = null) -> Node:
	if is_instance_valid(world):
		return world

	var scene := _default_world_scene
	if scene == null:
		push_error("[GAME] Unable to load deterministic test world.")
		return null

	world = scene.instantiate()

	if parent == null:
		parent = get_tree().current_scene if get_tree().current_scene != null else get_tree().root

	parent.add_child(world)
	world_ready.emit(world)
	return world

func set_world(new_world: Node) -> void:
	world = new_world
	if is_instance_valid(world):
		world_ready.emit(world)

func reset_resources() -> void:
	Wood = 0
	Stone = 0

func spawn_unit(position: Vector2) -> int:
	if not is_instance_valid(world):
		push_warning("[GAME] Cannot spawn unit because world is not ready.")
		return -1

	var units_node := world.get_node_or_null("Units")
	if units_node == null:
		push_warning("[GAME] World Units node not found.")
		return -1

	var unit_instance = _spawn_scene.instantiate()
	unit_instance.global_position = position
	if unit_instance.get("entity_id") == null:
		unit_instance.entity_id = int(unit_instance.get_instance_id())
	if unit_instance.get("player_id") == null:
		unit_instance.player_id = 0

	units_node.add_child(unit_instance)

	return int(unit_instance.entity_id)
