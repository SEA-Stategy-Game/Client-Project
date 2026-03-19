extends Control

@onready var editor_panel = $EditorPanel

var is_open = false

func _ready():
	var screen_size = get_viewport_rect().size
	
	# Make panel half screen
	editor_panel.size.x = screen_size.x / 2
	editor_panel.size.y = screen_size.y
	
	# Start OFF SCREEN (hidden to the right)
	editor_panel.position.x = screen_size.x

func _on_toggle_button_pressed():
	var screen_width = get_viewport_rect().size.x
	var target_x

	if is_open:
		# Slide OUT
		target_x = screen_width
	else:
		# Slide IN (half screen visible)
		target_x = screen_width / 2

	is_open = !is_open

	var tween = create_tween()
	tween.tween_property(editor_panel, "position:x", target_x, 0.3)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
