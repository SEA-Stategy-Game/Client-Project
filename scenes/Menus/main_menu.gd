extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LobbyClient.rooms_fetched.connect(_on_rooms_received)
	LobbyClient.request_failed.connect(_on_rooms_failed)
	Networking.game_load_ready.connect(_on_game_load_ready)
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	LobbyClient.list_game_rooms()
	print("Fetching rooms...")
	print(PlayerManager.player_uuid)

	pass

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/options_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit")
	pass # Replace with function body.

func _on_rooms_received(rooms: Array):
	if rooms.size() > 0:
		print("Connecting to server...")
		LobbyClient.join_room(rooms[0])
	else:
		print("No rooms available.")

func _on_game_load_ready() -> void:
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")

func _on_rooms_failed(error_message: String):
	print("Main Menu: Error fetching rooms -> ", error_message)


func _on_loadgames_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/load_games.tscn")
	pass # Replace with function body.
