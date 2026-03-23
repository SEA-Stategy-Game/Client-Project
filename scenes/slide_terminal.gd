extends Control

@onready var editor_panel = $EditorPanel
@onready var toggle_button = $ToggleButton

var is_open = false

func _ready():
	# Start hidden
	editor_panel.visible = false


func _on_toggle_button_pressed():
	is_open = !is_open
	
	if is_open:
		# Center the panel on the screen without resizing
		var screen_size = get_viewport_rect().size
		editor_panel.position = (screen_size - editor_panel.size) / 2
		editor_panel.visible = true
	else:
		editor_panel.visible = false
