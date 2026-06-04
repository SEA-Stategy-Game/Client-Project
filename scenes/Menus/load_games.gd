extends Control

@export var room_item_scene: PackedScene

@onready var rooms_list = $VBoxContainer/RoomsScroll/RoomsList

func _ready() -> void:
	# MOCK DATA FOR UI TESTING
	var mock_active = [
		{"roomId": "game-123", "players": ["Davide", "Flavia"], "maxNumberOfPlayers": 4, "startedAt": "10 mins ago", "createdAt": "20 mins ago"}
	]
	var mock_available = [
		{"roomId": "game-456", "players": ["Thomas"], "maxNumberOfPlayers": 2, "startedAt": "", "createdAt": "Just now"},
		{"roomId": "game-789", "players": ["Martin", "Gustav", "Magnus"], "maxNumberOfPlayers": 8, "startedAt": "2 hrs ago", "createdAt": "3 hrs ago"}
	]
	update_room_lists(mock_active, mock_available)

# ---------------------------------------------------------
# PUBLIC API FOR THE OTHER DEV
# ---------------------------------------------------------
func update_room_lists(active_rooms: Array, available_rooms: Array) -> void:
	_clear_list(rooms_list)
	
	for room_data in active_rooms:
		_create_room_item(room_data, rooms_list, true)
		
	for room_data in available_rooms:
		_create_room_item(room_data, rooms_list, false)

# ---------------------------------------------------------
# INTERNAL UI LOGIC
# ---------------------------------------------------------
func _create_room_item(room_data: Dictionary, container: Control, is_active: bool) -> void:
	if not room_item_scene:
		push_error("Room Item Scene is not assigned!")
		return
		
	var item = room_item_scene.instantiate()
	container.add_child(item)
	
	var r_id = room_data.get("roomId", "Unknown")
	var players_array = room_data.get("players", [])
	var max_players = room_data.get("maxNumberOfPlayers", 0)
	
	# Handle missing startedAt by falling back to createdAt
	var r_time = room_data.get("startedAt", "")
	if r_time == null or r_time == "":
		r_time = "Created: " + room_data.get("createdAt", "N/A")
	else:
		r_time = "Started: " + r_time
	
	item.setup(r_id, players_array, max_players, r_time, is_active)
	item.join_requested.connect(_on_join_requested)

func _clear_list(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

# Handles the signal emitted from the room_item.tscn
func _on_join_requested(room_id: String) -> void:
	print("User requested to join room: ", room_id)
	# LobbyClient.join_room(room_id)

# Connect this to the BackButton's 'pressed' signal in the editor
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
