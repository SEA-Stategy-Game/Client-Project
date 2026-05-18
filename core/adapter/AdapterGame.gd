extends Node

func _get_game():
	return get_node_or_null("/root/Game")

func spawn_unit(position: Vector2) -> int:
	var game = _get_game()
	if game and game.has_method("spawn_unit"):
		return game.spawn_unit(position)
	push_warning("AdapterGame: Game.spawn_unit not available")
	return -1

func get_wood() -> int:
	var game = _get_game()
	return game.Wood if game and game.has_method("_ready") and game.has_property("Wood") else 0

func set_wood(value: int) -> void:
	var game = _get_game()
	if game and game.has_property("Wood"):
		game.Wood = value

func get_stone() -> int:
	var game = _get_game()
	return game.Stone if game and game.has_property("Stone") else 0

func set_stone(value: int) -> void:
	var game = _get_game()
	if game and game.has_property("Stone"):
		game.Stone = value
