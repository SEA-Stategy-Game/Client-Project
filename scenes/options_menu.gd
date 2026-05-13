extends Control

signal back_pressed

# References to UI nodes (Adjust these paths to match your scene tree!)
@onready var colorblind_check = $CheckBox
@onready var volume_slider = $HSlider
@onready var brightness_slider = $HSlider2







func _on_h_slider_value_changed(value: float) -> void:
	Globalsettings.gamesettings["volume"] = value
	Globalsettings.apply_settings()

func _on_h_slider_2_value_changed(value: float) -> void:
	Globalsettings.gamesettings["brightness"] = value
	Globalsettings.apply_settings()


func _on_colorblind_toggled(toggled_on: bool) -> void:
	Globalsettings.gamesettings["colorblind"] = toggled_on
	Globalsettings.apply_settings()
	pass # Replace with function body.
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass # Replace with function body.
