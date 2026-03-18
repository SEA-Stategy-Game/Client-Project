extends Area2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var flash_animation: AnimationPlayer = $Sprite2D/FlashAnimation

@export var spawnParticle : PackedScene
@export var enemy_scene : PackedScene   # 👈 assign Enemy scene in inspector

var hp = 50

# ------------------------
# READY
# ------------------------
func _ready() -> void:
	health_bar.value = hp


# ------------------------
# SPAWN FUNCTION
# ------------------------
func Spawn():
	flash_animation.play("flash")
	await get_tree().create_timer(0.45).timeout

	# Spawn particle
	if spawnParticle:
		var particle = spawnParticle.instantiate()
		particle.position = global_position
		particle.rotation = global_rotation
		particle.emitting = true
		get_tree().current_scene.add_child(particle)

	# 🔥 Spawn enemy
	if enemy_scene:
		var enemy = enemy_scene.instantiate()

		# Set spawn offset: 32px right (+x), 32px up (-y)
		var spawn_offset = Vector2(20, -16)
		enemy.global_position = global_position + spawn_offset

		# Snap to grid (important for your movement system)
		enemy.grid_position = Vector2i(
			int(enemy.global_position.x / 32),
			int(enemy.global_position.y / 32)
		)

		# Assign tilemap layers (adjust paths if needed!)
		enemy.rocks_layer = get_parent().get_node("Rocks")
		enemy.trees_layer = get_parent().get_node("Trees")

		# Add to scene
		get_tree().current_scene.add_child(enemy)


# ------------------------
# CLICK HANDLING
# ------------------------
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		hp -= 1
		health_bar.value = hp

		Spawn()
