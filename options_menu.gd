extends Control

# Define a custom signal so the Main Menu knows when to come back
signal back_pressed

var settings = {"colorblind": false, "volume": 5, "brightness": 5}

func _on_check_box_pressed() -> void:
	settings["colorblind"] = true
	pass # Replace with function body.

func _on_h_slider_value_changed(value: float) -> void:
	settings["volume"] = value
	pass # Replace with function body.

func _on_h_slider_2_value_changed(value: float) -> void:
	settings["volume"] = value
	
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
	pass # Replace with function body.
