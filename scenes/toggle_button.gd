extends TextureButton

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_mouse_entered():
	modulate = Color(1.2, 1.2, 1.2) # brighter

func _on_mouse_exited():
	modulate = Color(1, 1, 1) # normal
