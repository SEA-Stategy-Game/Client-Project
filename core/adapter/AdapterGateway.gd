extends Node

signal task_completed(unit_id: int, action_data: Dictionary)
signal task_failed(unit_id: int, action_data: Dictionary)
signal queue_empty(unit_id: int)

func _ready() -> void:
	var ag = _get_gateway()
	if ag:
		if not ag.is_connected("task_completed", Callable(self, "_on_task_completed")):
			ag.connect("task_completed", Callable(self, "_on_task_completed"))
		if not ag.is_connected("task_failed", Callable(self, "_on_task_failed")):
			ag.connect("task_failed", Callable(self, "_on_task_failed"))
		if ag.has_signal("queue_empty") and not ag.is_connected("queue_empty", Callable(self, "_on_queue_empty")):
			ag.connect("queue_empty", Callable(self, "_on_queue_empty"))

func _get_gateway():
	return get_node_or_null("/root/ActionGateway")

func sense():
	var ag = _get_gateway()
	if ag and ag.has_method("sense"):
		return ag.sense()
	return null

func set_active_player(player_id: int) -> void:
	var ag = _get_gateway()
	if ag and ag.has_method("set_active_player"):
		ag.set_active_player(player_id)

func move_unit(unit_id: int, destination: Vector2, requesting_player_id: int = -1, requesting_peer_id: int = -1) -> bool:
	var ag = _get_gateway()
	if ag and ag.has_method("move_unit"):
		return ag.move_unit(unit_id, destination, requesting_player_id, requesting_peer_id)
	push_warning("AdapterGateway: ActionGateway.move_unit not available")
	return false

func attack_target(unit_id: int, target_id: int, requesting_player_id: int = -1, requesting_peer_id: int = -1) -> bool:
	var ag = _get_gateway()
	if ag and ag.has_method("attack_target"):
		return ag.attack_target(unit_id, target_id, requesting_player_id, requesting_peer_id)
	push_warning("AdapterGateway: ActionGateway.attack_target not available")
	return false

func go_chop_tree_and_return(unit_id: int, tree_id: int, requesting_player_id: int = -1, requesting_peer_id: int = -1) -> bool:
	var ag = _get_gateway()
	if ag and ag.has_method("go_chop_tree_and_return"):
		return ag.go_chop_tree_and_return(unit_id, tree_id, requesting_player_id, requesting_peer_id)
	push_warning("AdapterGateway: ActionGateway.go_chop_tree_and_return not available")
	return false

func go_chop_tree(unit_id: int, tree_id: int, requesting_player_id: int = -1, requesting_peer_id: int = -1) -> bool:
	var ag = _get_gateway()
	if ag and ag.has_method("go_chop_tree"):
		return ag.go_chop_tree(unit_id, tree_id, requesting_player_id, requesting_peer_id)
	push_warning("AdapterGateway: ActionGateway.go_chop_tree not available")
	return false

func go_mine_stone(unit_id: int, stone_id: int, requesting_player_id: int = -1, requesting_peer_id: int = -1) -> bool:
	var ag = _get_gateway()
	if ag and ag.has_method("go_mine_stone"):
		return ag.go_mine_stone(unit_id, stone_id, requesting_player_id, requesting_peer_id)
	push_warning("AdapterGateway: ActionGateway.go_mine_stone not available")
	return false

func go_construct(unit_id: int, building_scene: String, build_pos: Vector2, duration: float = 10.0, requesting_player_id: int = -1, requesting_peer_id: int = -1) -> bool:
	var ag = _get_gateway()
	if ag and ag.has_method("go_construct"):
		return ag.go_construct(unit_id, building_scene, build_pos, duration, requesting_player_id, requesting_peer_id)
	push_warning("AdapterGateway: ActionGateway.go_construct not available")
	return false

func execute_plan(plan: Dictionary) -> bool:
	var ag = _get_gateway()
	if ag and ag.has_method("execute_plan"):
		return ag.execute_plan(plan)
	push_warning("AdapterGateway: ActionGateway.execute_plan not available")
	return false

func _on_task_completed(unit_id: int, action_data: Dictionary) -> void:
	emit_signal("task_completed", unit_id, action_data)

func _on_task_failed(unit_id: int, action_data: Dictionary) -> void:
	emit_signal("task_failed", unit_id, action_data)

func _on_queue_empty(unit_id: int) -> void:
	emit_signal("queue_empty", unit_id)
