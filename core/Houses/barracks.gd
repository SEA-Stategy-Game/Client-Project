extends StaticBody2D

## -----------------------------------------------------------------------
## Barracks -- player home base.  Units return here after composite tasks.
## Implements IDamageable contract for universal combat targeting.
## -----------------------------------------------------------------------

@export var entity_id: int = -1
@export var player_id: int = 0
@export var max_health: int = 500
var current_health: int

@onready var select = get_node("Selected")
var selected = false
var _mouse_entered: bool = false

func _ready() -> void:
	current_health = max_health
	add_to_group("buildings")
	add_to_group("barracks")

	var enter_callable := Callable(self, "_on_mouse_entered")
	if not is_connected("mouse_entered", enter_callable):
		connect("mouse_entered", enter_callable)
	var exit_callable := Callable(self, "_on_mouse_exited")
	if not is_connected("mouse_exited", exit_callable):
		connect("mouse_exited", exit_callable)

func _process(delta) -> void:
	select.visible = selected

func _unhandled_input(event: InputEvent) -> void:
	# Use project InputMap action "click" (not LeftClick)
	if event.is_action_pressed("click"):
		print("click! mouse_entered=", _mouse_entered, " allow=", _allow_spawn_ui())
		if _mouse_entered == true and _allow_spawn_ui():
			selected = !selected
			if selected == true:
				var adapter = null
				if get_tree().get_root().has_node("AdapterGame"):
					adapter = get_node_or_null("/root/AdapterGame")
				if adapter != null and adapter.has_method("spawn_unit"):
					adapter.spawn_unit(global_position)
				elif Engine.has_singleton("Game"):
					Game.spawn_unit(global_position)

func _on_mouse_entered() -> void:
	print(_mouse_entered)
	_mouse_entered = true

func _on_mouse_exited():
	_mouse_entered = false

# -----------------------------------------------------------------
# IDamageable contract
# -----------------------------------------------------------------

func take_damage(amount: int) -> void:
	current_health -= amount
	print("[COMBAT_LOG] Barracks ", entity_id, " (player ", player_id, ") took ", amount, " damage. HP: ", current_health, "/", max_health)
	if current_health <= 0:
		die()

func get_current_health() -> int:
	return current_health

func is_alive() -> bool:
	return current_health > 0

func get_player_id() -> int:
	return player_id

func die() -> void:
	print("[COMBAT_LOG] Barracks ", entity_id, " (player ", player_id, ") destroyed.")
	queue_free()

func _allow_spawn_ui() -> bool:
	var session = get_node_or_null("/root/NetSession")
	if session and session.is_scenario_active():
		return false

	return true
