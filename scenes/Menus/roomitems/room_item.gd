extends PanelContainer

# Custom signal to tell the parent scene which room we want to join
signal join_requested(room_id: String)

@onready var room_id_label = $HBoxContainer/RoomIdLabel
@onready var players_label = $HBoxContainer/PlayersLabel
@onready var time_label = $HBoxContainer/TimeLabel
@onready var join_button = $HBoxContainer/JoinButton

var current_room_id: String = ""

# Setup function called by the parent to populate the row
func setup(room_id: String, players: Array, max_players: int, start_time: String, is_active: bool) -> void:
	current_room_id = room_id
	
	# Set labels without prefixes for table format
	room_id_label.text = room_id
	
	# Join the array names into a single comma-separated string
	var player_names_string = ", ".join(PackedStringArray(players))
	if players.size() == 0:
		player_names_string = "Empty"
		
	# Format the text: e.g., "2/4 (Thomas, Martin)"
	players_label.text = "%d/%d (%s)" % [players.size(), max_players, player_names_string]
	
	time_label.text = start_time
	
	if is_active:
		join_button.text = "Rejoin"
	else:
		join_button.text = "Join"

# Handles the join button press
func _on_joinbutton_pressed() -> void:
	join_requested.emit(current_room_id)
