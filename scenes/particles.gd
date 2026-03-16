extends CPUParticles2D

@onready var timeCreated = Time.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Time.get_ticks_msec() - timeCreated > 10000:
		queue_free()
