extends Node

# Signal emitted when the room list is successfully fetched
signal rooms_fetched(rooms: Array[GameRoom])
signal request_failed(error_message: String)

const BASE_URL = "http://localhost:8080"
var game_room_id: String

# Internal HTTPRequest node
var _http_request: HTTPRequest

func _ready():
	# Setup the HTTPRequest node dynamically
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

## Calls /rooms to get the list of all available rooms.
func list_all_game_rooms():
	_fetch_rooms()


## Internal function to fetch rooms with optional query parameters.
func _fetch_rooms(query_params: Dictionary = {}):
	var url = BASE_URL + "/rooms"
	if not query_params.is_empty():
		var query_string_parts: Array[String] = []
		for key in query_params:
			var value = query_params[key]
			query_string_parts.append("%s=%s" % [String(key).uri_encode(), String(value).uri_encode()])
		url += "?" + "&".join(query_string_parts)

	var err = _http_request.request(url)
	if err != OK:
		request_failed.emit("Failed to initiate HTTP request to GameRoomManager.")

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("Network error occurred connecting to GameRoomManager.")
		return
	
	if response_code != 200:
		request_failed.emit("GameRoomManager returned error: " + str(response_code))
		return

	# Parse JSON body
	var json = JSON.new()
	var parse_err = json.parse(body.get_string_from_utf8())
	
	if parse_err != OK:
		request_failed.emit("Failed to parse JSON response from GameRoomManager.")
		return
		
	var data = json.get_data()
	if typeof(data) == TYPE_ARRAY:
		# Convert the raw array of dictionaries into an array of GameRoom objects
		var room_objects: Array[GameRoom] = []
		for item in data:
			if typeof(item) == TYPE_DICTIONARY:
				room_objects.append(GameRoom.from_dict(item))
		
		rooms_fetched.emit(room_objects)
	else:
		request_failed.emit("Unexpected data format from server.")

## Helper method to join a specific room based on the GameRoom object
func join_room(room: GameRoom):
	if room.port == 0:
		print("Error: GameRoom has no valid port.")
		return
		
	Networking.connect_to_server(room.address, room.port)

## Calls /rooms?player_id={player_id} to get the list of available rooms for a player
func list_rooms_by_player_id(player_id: String):
	_fetch_rooms({"player_id": player_id})

## Calls /rooms?status={status} to get the list of available rooms with a certain status
func list_rooms_by_status(status: String):
	_fetch_rooms({"status": status})
