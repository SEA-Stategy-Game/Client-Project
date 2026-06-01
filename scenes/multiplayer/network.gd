extends Node

# Signals for static and dynamic states. Subsribed to by Managers
signal dynamic_state_received(state: Dictionary)
signal game_load_ready

## Client-side network gateway. Manages the connection to the authoritative
## server and handles receiving and deserialising state updates.

## Caches the static state received from the server until the game scene requests it.
var static_state_cache: Dictionary = {}

func _ready():
	return
	

## Initialises the ENet client and connects to a specific server
## Binds connection lifecycle signals for logging and post-connect logic.
func connect_to_server(address: String, port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, port)
	print("create_client result: ", err)  # 0 = OK, anything else is an error
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(func(): _on_connected())
	multiplayer.connection_failed.connect(func(): print("Connection FAILED"))
	multiplayer.server_disconnected.connect(func(): print("Server disconnected"))
	

## Called when the client successfully establishes a connection to the server.
func _on_connected():
	print("Connected to server. Sending Player ID: ", PlayerManager.player_uuid)
	register_player(PlayerManager.player_uuid)
	


# -----------------------------------------------------------------------
# Static state sync
# -----------------------------------------------------------------------

@rpc("authority", "call_remote", "reliable")
func register_player(player_uuid: String) -> void:
	rpc_id(1, "on_player_registered", player_uuid)  # 1 is always the server's peer ID

## Requests the full static world state from the server.
@rpc("authority", "call_remote", "reliable")
func request_static_state() -> void:
	print("request_static_state")
	rpc_id(1, "on_static_state_requested")  # 1 is always the server's peer ID


@rpc("authority", "call_remote", "reliable")
func receive_player_registration(player_local_id: int, game_room_id: String) -> void:
	print("Player registered with local ID: ", player_local_id, " in room: ", game_room_id)
	# Emit the signal so other parts of your game can use the ID
	PlayerManager.player_local_id = player_local_id
	LobbyClient.game_room_id = game_room_id
	request_static_state()

# -----------------------------------------------------------------------
# Receiving state from server
# -----------------------------------------------------------------------

## Receives a dynamic state delta broadcast from the server.
## This function is invoked every tick by broadcasting from the server.
## [param state] Dictionary containing the delta world state.
@rpc("any_peer", "call_remote", "unreliable")
func receive_state(data: PackedByteArray):
	var decompressed = data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	var state = JSON.parse_string(decompressed.get_string_from_utf8())
	dynamic_state_received.emit(state)
	
## Receives the compressed static world state from the 
## [param data] GZIP-compressed UTF-8 encoded JSON as a PackedByteArray.
@rpc("authority", "call_remote", "reliable")
func receive_static_state(data: PackedByteArray):
	print("DEBUG: receive_static_state called.")
	var decompressed = data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	var state = JSON.parse_string(decompressed.get_string_from_utf8())

	if state == null:
		print("ERROR: Failed to parse static state JSON.")
		return
		
	print("DEBUG: State decompressed and parsed. Caching in Networking node.")
	static_state_cache = state
	
	print("DEBUG: Emitting game_load_ready to switch scenes.")
	game_load_ready.emit()
	
## Stubs: server-side handler for server functions.
## Never executed on the client — exists only so Godot can compute.
## a matching RPC checksum between client and server.

@rpc("any_peer", "call_remote", "reliable")
func on_player_registered(player_uuid: String) -> void:
	pass


@rpc("any_peer", "call_remote", "reliable")
func on_static_state_requested() -> void:
	pass
