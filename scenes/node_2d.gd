extends Node2D

@onready var soundtrack: AudioStreamPlayer = get_node_or_null("SoundTrack")

func _ready() -> void:
    if soundtrack != null:
        apply_audio_settings()
    else:
        print("Warning: SoundTrack node not found in this instance (continuing).")
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
