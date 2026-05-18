extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LobbyClient.rooms_fetched.connect(_on_rooms_received)
	LobbyClient.request_failed.connect(_on_rooms_failed)
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	LobbyClient.list_game_rooms()
	print("Fetching rooms...")

	pass

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit")
	pass # Replace with function body.

func _on_rooms_received(rooms: Array):
	if rooms.size() > 0:
		LobbyClient.selected_room = rooms[0]
		print("Selected Room: ", LobbyClient.selected_room)
	
		get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
	else:
		print("No rooms available.")



func _on_rooms_failed(error_message: String):
	print("Main Menu: Error fetching rooms -> ", error_message)
