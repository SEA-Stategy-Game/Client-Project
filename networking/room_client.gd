extends Node

var socket := WebSocketPeer.new()

signal game_state_updated(state)
signal connecting_to_game_room
signal connected_to_game_room
signal connection_lost

var _was_connected := false
var _was_connecting := false

func connect_to_game_room(url: String):
	socket.connect_to_url(url)

func _process(_delta):
	socket.poll()
	match socket.get_ready_state():
		WebSocketPeer.STATE_CONNECTING:
			if not _was_connecting:
				_was_connecting = true
				connecting_to_game_room.emit()
		WebSocketPeer.STATE_OPEN:
			if not _was_connected:
				_was_connected = true
				_was_connecting = false
				connected_to_game_room.emit()
			while socket.get_available_packet_count() > 0:
				var state = JSON.parse_string(socket.get_packet().get_string_from_utf8())
				game_state_updated.emit(state)
		WebSocketPeer.STATE_CLOSED, WebSocketPeer.STATE_CLOSING:
			if _was_connected or _was_connecting:
				_was_connected = false
				_was_connecting = false
				connection_lost.emit()
