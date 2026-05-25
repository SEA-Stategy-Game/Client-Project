extends WorldUnit
class_name NormalUnit

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()

func _physics_process(delta) -> void:
	if not _has_server_state:
		animated_sprite.stop()
		return
	var target: Vector2
	if _server_path.size() > 0 and _path_index < _server_path.size():
		target = _server_path[_path_index]
		if global_position.distance_to(target) < 1.0:
			_path_index += 1
			return
	else:
		target = _server_pos
		if global_position.distance_to(target) < 1.0:
			animated_sprite.stop()
			return
	var direction = (target - global_position).normalized()
	velocity = direction * _server_speed * delta
	move_and_slide()
	_update_movement_animation(direction)

func _update_movement_animation(direction: Vector2) -> void:
	var anim: String
	if abs(direction.x) >= abs(direction.y):
		anim = "run_side"
		animated_sprite.flip_h = direction.x < 0
	elif direction.y < 0:
		anim = "run_up"
		animated_sprite.flip_h = false
	else:
		anim = "run_down"
		animated_sprite.flip_h = false
	if animated_sprite.animation != anim:
		animated_sprite.play(anim)
