extends Area2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var flash_animation: AnimationPlayer = $Sprite2D/FlashAnimation
@export var spawnParticle : PackedScene

var hp = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.value = hp

func Spawn():
	flash_animation.play("flash")
	await get_tree().create_timer(0.45).timeout
	var _particle = spawnParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		hp -= 1
		health_bar.value = hp
		Spawn()
		
		
		#health_bar.visible = !health_bar.visible
