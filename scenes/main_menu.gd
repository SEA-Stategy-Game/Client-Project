extends Control

@onready var room_list := $RoomListPanel/ScrollContainer/RoomList
@onready var room_list_panel := $RoomListPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LobbyClient.rooms_fetched.connect(_on_rooms_received)
	LobbyClient.request_failed.connect(_on_rooms_failed)
	room_list_panel.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	# New Game: create a room on the Game Room Manager, then enter the scene when created
	room_list_panel.visible = false
	LobbyClient.selected_room = null
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit")
	pass # Replace with function body.

func _on_rooms_received(rooms: Array) -> void:
	_clear_room_list()

	if rooms.is_empty():
		var label := Label.new()
		label.text = "No ongoing games found."
		room_list.add_child(label)
		return

	for room in rooms:
		var button := Button.new()
		button.text = "%s  [%s:%d]  players: %d  state: %s" % [
			room.room_id,
			room.address,
			room.port,
			room.participants,
			room.state
		]
		button.pressed.connect(func():
			LobbyClient.selected_room = room
			get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
		)
		room_list.add_child(button)

func _clear_room_list() -> void:
	for child in room_list.get_children():
		child.queue_free()

func _on_rooms_failed(error_message: String) -> void:
	_clear_room_list()
	var label := Label.new()
	label.text = "Failed to load games: %s" % error_message
	room_list.add_child(label)

func _on_load_game_pressed() -> void:
	room_list_panel.visible = true
	_clear_room_list()
	LobbyClient.list_game_rooms()
	print("Fetching rooms...")