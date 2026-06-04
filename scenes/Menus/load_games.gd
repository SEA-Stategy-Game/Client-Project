extends Control

@export var room_item_scene: PackedScene

# Aggiorna questo percorso in base alla nuova struttura dell'albero descritta sopra
@onready var rooms_list = $VBoxContainer/RoomsScroll/RoomsList

func _ready() -> void:
	# MOCK DATA FOR UI TESTING
	var mock_active = [
		{"roomId": "game-123", "players": ["p1", "p2"], "startedAt": "10 mins ago"}
	]
	var mock_available = [
		{"roomId": "game-456", "players": ["p3"], "startedAt": "Just now"},
		{"roomId": "game-789", "players": ["p4", "p5", "p6"], "startedAt": "2 hrs ago"}
	]
	update_room_lists(mock_active, mock_available)

# ---------------------------------------------------------
# PUBLIC API FOR THE OTHER DEV
# ---------------------------------------------------------
func update_room_lists(active_rooms: Array, available_rooms: Array) -> void:
	_clear_list(rooms_list)
	
	# Popola la singola lista con le stanze attive (is_active = true)
	for room_data in active_rooms:
		_create_room_item(room_data, rooms_list, true)
		
	# Aggiunge alla stessa lista le stanze disponibili (is_active = false)
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
	
	# Mappatura aggiornata ai tag JSON della struct Room in Go
	var r_id = room_data.get("roomId", "Unknown")
	
	# 'players' è un array di stringhe, quindi ne prendiamo la dimensione
	var players_array = room_data.get("players", [])
	var r_players = players_array.size()
	
	var r_time = room_data.get("startedAt", "N/A")
	
	item.setup(r_id, r_players, r_time, is_active)
	item.join_requested.connect(_on_join_requested)

func _clear_list(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

func _on_join_requested(room_id: String) -> void:
	print("User requested to join room: ", room_id)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
