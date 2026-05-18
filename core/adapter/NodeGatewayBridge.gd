extends Node2D

signal connection_changed(summary: Dictionary)
signal authoritative_state_applied(state: Dictionary)
signal command_sent(command: Dictionary)
signal command_rejected(reason: String)

func _ready() -> void:
    if Server != null and Server.has_signal("authoritative_state_applied"):
        if not Server.authoritative_state_applied.is_connected(_on_state):
            Server.authoritative_state_applied.connect(_on_state)

func connect_to_server(address: String, port: int) -> void:
    Server.connect_to_server(address, port)
    connection_changed.emit(Server.get_peer_summary())

func start_server(port: int = 24567) -> void:
    Server.start_server(port)
    connection_changed.emit(Server.get_peer_summary())

func disconnect_network() -> void:
    Server.disconnect_network()
    connection_changed.emit(Server.get_peer_summary())

func submit_player_command(command: Dictionary) -> bool:
    if command.is_empty():
        command_rejected.emit("Empty command.")
        return false
    var ok := Server.submit_player_command(command)
    if ok:
        command_sent.emit(command)
    else:
        command_rejected.emit("Rejected by Server.")
    return ok

func get_peer_summary() -> Dictionary:
    return Server.get_peer_summary()

func _on_state(state: Dictionary) -> void:
    authoritative_state_applied.emit(state)