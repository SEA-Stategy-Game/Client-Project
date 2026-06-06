extends Control

@export var room_item_scene: PackedScene

@onready var rooms_list = $VBoxContainer/RoomsScroll/RoomsList

var _rooms_by_id: Dictionary = {}
var _joining: bool = false

func _ready() -> void:
	#Listen for fetch and erros
	LobbyClient.rooms_fetched.connect(_on_rooms_received)
	LobbyClient.request_failed.connect(_on_rooms_failed)
	Networking.game_load_ready.connect(_on_game_load_ready)
	LobbyClient.list_all_game_rooms()

func _on_rooms_received(rooms: Array) -> void:
	_rooms_by_id.clear()

	# Only READY and RUNNING rooms are joinable, so only those are cached
	var active_rooms: Array = []
	var available_rooms: Array = []
	for room in rooms:
		match room.state:
			"running":
				_rooms_by_id[room.room_id] = room
				active_rooms.append(_room_to_dict(room))
			"ready":
				_rooms_by_id[room.room_id] = room
				available_rooms.append(_room_to_dict(room))

	update_room_lists(active_rooms, available_rooms)

func _on_rooms_failed(error_message: String) -> void:
	push_error("Failed to fetch rooms: " + error_message)
	_rooms_by_id.clear()
	update_room_lists([], [])


func _room_to_dict(room: GameRoom) -> Dictionary:
	return {
		"roomId": room.room_id,
		"players": room.players,
		"maxNumberOfPlayers": room.max_number_of_player,
		"startedAt": room.started_at,
		"createdAt": room.created_at,
	}

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
	if _joining:
		return  
	print("User requested to join room: ", room_id)
	var room: GameRoom = _rooms_by_id.get(room_id)
	if room == null:
		push_error("Cannot join: no cached GameRoom for id " + room_id)
		return
	if room.state != "ready" and room.state != "running":
		push_error("Cannot join room in state '%s' (only ready/running)" % room.state)
		return
	_joining = true
	LobbyClient.join_room(room)

func _on_game_load_ready() -> void:
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")

# Connect this to the BackButton's 'pressed' signal in the editor
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
