extends Node

# Signals for static and dynamic states. Subsribed to by Managers
signal static_state_received(state: Dictionary)
signal dynamic_state_received(state: Dictionary)

## Client-side network gateway. Manages the connection to the authoritative
## server and handles receiving and deserialising state updates.

## Initialises the ENet client and connects to a specific server
## Binds connection lifecycle signals for logging and post-connect logic.
func _ready():
	
	if LobbyClient.selected_room == null:
		print("Error: No room selected. Returning to menu.")
		return

	var address = LobbyClient.selected_room.address
	var port = LobbyClient.selected_room.port
	
	print(address)
	print(port)

	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, port)
	print("create_client result: ", err)  # 0 = OK, anything else is an error
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(func(): _on_connected())
	multiplayer.connection_failed.connect(func(): print("Connection FAILED"))
	multiplayer.server_disconnected.connect(func(): print("Server disconnected"))

## Called when the client successfully establishes a connection to the server.
func _on_connected():
	print("Connected to server")
	request_static_state()

# -----------------------------------------------------------------------
# Static state sync
# -----------------------------------------------------------------------

## Requests the full static world state from the server.
## Invokes [method on_static_state_requested] on the server (peer ID 1).
@rpc("any_peer", "call_remote", "reliable")
func request_static_state() -> void:
	print("request_static_state")
	rpc_id(1, "on_static_state_requested")  # 1 is always the server's peer ID

## Stub: server-side handler for static state requests.
## Never executed on the client — exists only so Godot can compute
## a matching RPC checksum between client and server.
@rpc("any_peer", "call_remote", "reliable")
func on_static_state_requested() -> void:
	pass

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
@rpc("any_peer", "call_remote", "unreliable")
func receive_static_state(data: PackedByteArray):
	var decompressed = data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	var state = JSON.parse_string(decompressed.get_string_from_utf8())
	static_state_received.emit(state)
