class_name GameRoom
extends RefCounted

enum RoomState { StateIniting, StateReady, StateRunning, StateEnded, StateCrashed }

var room_id: String
var state: String
var address: String
var port: int
var players: Array[String] = []
var max_number_of_player: int
var winner: String
var started_at: String
var ended_at: String

# Factory method to create a Room object from the Server's Dictionary
static func from_dict(data: Dictionary) -> GameRoom:
	var room = GameRoom.new()
	room.room_id = data.get("roomId", "")
	room.state = data.get("state", "crashed")
	room.address = data.get("address", "127.0.0.1")
	room.port = int(data.get("port", 0))
	if data.has("players") and data["players"] is Array:
		room.players.assign(data["players"])
	room.max_number_of_player = int(data.get("maxNumberOfPlayers", 0))
	room.winner = data.get("winner", "")
	room.started_at = data.get("startedAt", "")
	room.ended_at = data.get("endedAt", "")

	return room
