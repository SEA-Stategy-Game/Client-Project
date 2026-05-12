extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn") # I don't know how to use this - Josiaht

	pass

func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit")
	pass # Replace with function body.
