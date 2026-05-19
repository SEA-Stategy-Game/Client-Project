extends Node2D

@onready var soundtrack: AudioStreamPlayer = get_node_or_null("SoundTrack")

func _ready() -> void:
    if soundtrack != null:
        apply_audio_settings()
    else:
        print("Warning: SoundTrack node not found in this instance (continuing).")
    # Ensure the deterministic world exists before any network connections
    Game.ensure_world(self)

    # If no room was selected from the lobby, start a local server (host)
    if LobbyClient.selected_room == null:
        Server.start_server()

    # Now connect using any selected room (client) if present
    _connect_lobby_room_if_present()

func apply_audio_settings() -> void:
    if is_instance_valid(soundtrack):
        var volume_value = Globalsettings.gamesettings["volume"]
        var linear_volume = volume_value / 10.0
        soundtrack.volume_db = linear_to_db(linear_volume)

        if not soundtrack.playing:
            soundtrack.play()

func _connect_lobby_room_if_present() -> void:
    var gateway = get_node_or_null("ClientGateway")
    if gateway == null:
        return
    if LobbyClient == null or LobbyClient.selected_room == null:
        return
    gateway.connect_to_server(LobbyClient.selected_room.address, LobbyClient.selected_room.port)

func end_game_and_return_to_menu() -> void:
    # Disconnect server/network (if hosting)
    if Server != null:
        Server.disconnect_network()
    # Remove the world instance
    if Game != null:
        Game.set_world(null)
    # Go back to main menu
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
