class_name GameRoom
extends RefCounted

enum RoomState { StateActive, StateInactive }

var room_id: String
var connection_details: String
var state: String
var participants: int
var address: String
var port: int

# Factory method to create a Room object from the Server's Dictionary
static func from_dict(data: Dictionary) -> GameRoom:
	var room = GameRoom.new()
	room.room_id = data.get("roomId", "")
	room.connection_details = data.get("connectionDetails", "")
	room.state = data.get("state", "StateInactive")
	room.participants = int(data.get("participants", 0))
	room.address = data.get("address", "127.0.0.1")
	room.port = int(data.get("port", 0))
	return room
