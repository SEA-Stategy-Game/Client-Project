extends CharacterBody2D

@export var speed := 100

func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	velocity = input_vector * speed
	move_and_slide()

	update_animation(input_vector)


func update_animation(dir: Vector2):
	var sprite = $AnimatedSprite2D

	if dir == Vector2.ZERO:
		sprite.stop()
		return

	if abs(dir.x) > abs(dir.y):
		sprite.play("run_side")
		sprite.flip_h = dir.x < 0
	elif dir.y > 0:
		sprite.play("run_down")
	else:
		sprite.play("run_up")
