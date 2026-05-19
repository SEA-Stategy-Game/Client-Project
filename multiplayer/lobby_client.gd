extends Node

# Signal emitted when the room list is successfully fetched
signal rooms_fetched(rooms: Array[GameRoom])
signal request_failed(error_message: String)
signal room_created(room: GameRoom)

const BASE_URL = "http://localhost:8080"
var selected_room: GameRoom

# Internal HTTPRequest node
var _http_request: HTTPRequest
var _pending_action: String = ""

func _ready():
	# Setup the HTTPRequest node dynamically
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

## Calls /rooms to get the list of available rooms
func list_game_rooms():
	_pending_action = "list"
	var url = BASE_URL + "/rooms"
	var err = _http_request.request(url)
	if err != OK:
		_pending_action = ""
		request_failed.emit("Failed to initiate HTTP request to GameRoomManager.")

## Create a new room on the Game Room Manager via POST /rooms
func create_room(name: String = "LocalGame") -> void:
	_pending_action = "create"
	var url: String = BASE_URL + "/rooms"
	var payload: Dictionary = {"name": name}
	var body_str: String = JSON.stringify(payload)
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	var err: int = _http_request.request(url, headers, HTTPClient.METHOD_POST, body_str)
	if err != OK:
		_pending_action = ""
		request_failed.emit("Failed to initiate room creation request.")

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("Network error occurred connecting to GameRoomManager.")
		_pending_action = ""
		return
	
	if response_code < 200 or response_code >= 300:
		request_failed.emit("GameRoomManager returned error: " + str(response_code))
		_pending_action = ""
		return

	# Parse JSON body
	var json = JSON.new()
	var parse_err = json.parse(body.get_string_from_utf8())
	
	if parse_err != OK:
		request_failed.emit("Failed to parse JSON response from GameRoomManager.")
		return
		
	var data = json.get_data()
	if _pending_action == "list":
		if typeof(data) == TYPE_ARRAY:
			var room_objects: Array[GameRoom] = []
			for item in data:
				if typeof(item) == TYPE_DICTIONARY:
					room_objects.append(GameRoom.from_dict(item))
			_pending_action = ""
			rooms_fetched.emit(room_objects)
			return
		_pending_action = ""
		request_failed.emit("Unexpected data format from server.")
		return

	if _pending_action == "create":
		if typeof(data) == TYPE_DICTIONARY:
			var room = GameRoom.from_dict(data)
			selected_room = room
			_pending_action = ""
			room_created.emit(room)
			return
		_pending_action = ""
		request_failed.emit("Unexpected data format from create_room response.")
		return

## Helper method to join a specific room based on the GameRoom object
func join_room(room: GameRoom):
	if room.port == 0:
		print("Error: GameRoom has no valid port.")
		return
		
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(room.address, room.port)
	
	if err == OK:
		multiplayer.multiplayer_peer = peer
		print("Connecting to %s (%s:%d)..." % [room.name, room.address, room.port])
	else:
		print("Failed to create client: ", err)
