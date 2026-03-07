extends Node

# Autoload this as "LobbyClient" in Project Settings

func getAvailableRooms() -> Array[RoomInfo]:
		var http = HTTPRequest.new()
		add_child(http)
		var url = Config.BASE_URL
		http.request(url + "/available_games")
		var response = await http.request_completed  # just wait here
		
		http.queue_free()
		
		var body = response[3]  # request_completed passes [result, code, headers, body]
		return _parseAvailableRooms(body.get_string_from_utf8())


func _parseAvailableRooms(body: String) -> Array[RoomInfo]:
	var json = JSON.parse_string(body)
	
	var rooms: Array[RoomInfo] = []
	for item in json:
		var room = RoomInfo.new(item["roomId"], item["capacity"], item["players"])
		rooms.append(room)
	
	return rooms


class RoomInfo:
	var roomId: String
	var capacity: int
	var players: int
	
	func _init(id: String, cap: int, p: int) -> void:
		roomId = id
		capacity = cap
		players = p

	func to_dict() -> Dictionary:
		return {
			"roomId": roomId,
			"capacity": capacity,
			"players": players
		}
