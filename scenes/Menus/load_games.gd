extends Control

# Drag and drop your room_item.tscn into this variable in the Godot Inspector
@export var room_item_scene: PackedScene

@onready var active_games_list = $VBoxContainer/ActiveScroll/ActiveGames
@onready var available_games_list = $VBoxContainer/AvailableScroll/AvailableGames

func _ready() -> void:
	# MOCK DATA FOR UI TESTING
	var mock_active = [
		{"id": "game-123", "player_count": 2, "start_time": "10 mins ago"}
	]
	var mock_available = [
		{"id": "game-456", "player_count": 1, "start_time": "Just now"},
		{"id": "game-789", "player_count": 3, "start_time": "2 hrs ago"}
	]
	update_room_lists(mock_active, mock_available)
	# Multiplayer may need to adjust this

	# LobbyClient.list_game_rooms()
	pass

# ---------------------------------------------------------
# PUBLIC API FOR THE OTHER DEV
# They just need to call this function and pass the dictionaries
# ---------------------------------------------------------
func update_room_lists(active_rooms: Array, available_rooms: Array) -> void:
	_clear_list(active_games_list)
	_clear_list(available_games_list)
	
	for room_data in active_rooms:
		_create_room_item(room_data, active_games_list, true)
		
	for room_data in available_rooms:
		_create_room_item(room_data, available_games_list, false)

# ---------------------------------------------------------
# INTERNAL UI LOGIC
# ---------------------------------------------------------
func _create_room_item(room_data: Dictionary, container: Control, is_active: bool) -> void:
	if not room_item_scene:
		push_error("Room Item Scene is not assigned!")
		return
		
	var item = room_item_scene.instantiate()
	container.add_child(item)
	
	# Multiplayer may need to adjust this
	var r_id = room_data.get("id", "Unknown")
	var r_players = room_data.get("player_count", 0)
	var r_time = room_data.get("start_time", "N/A")
	
	item.setup(r_id, r_players, r_time, is_active)
	item.join_requested.connect(_on_join_requested)

func _clear_list(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

# Handles the signal emitted from the room_item.tscn
func _on_join_requested(room_id: String) -> void:
	print("User requested to join room: ", room_id)
	# Multiplayer may need to adjust this
	# LobbyClient.join_room(room_id)

# Connect this to the BackButton's 'pressed' signal in the editor


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
