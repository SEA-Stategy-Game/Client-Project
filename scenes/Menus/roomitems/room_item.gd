extends PanelContainer

# Custom signal to tell the parent scene which room we want to join
signal join_requested(room_id: String)

@onready var room_id_label = $HBoxContainer/RoomIdLabel
@onready var players_label = $HBoxContainer/PlayersLabel
@onready var time_label = $HBoxContainer/TimeLabel
@onready var join_button = $HBoxContainer/JoinButton

var current_room_id: String = ""

# The other dev will pass the data into this setup function
func setup(room_id: String, player_count: int, start_time: String, is_active: bool) -> void:
	current_room_id = room_id
	room_id_label.text = "Room: " + room_id
	players_label.text = "Players: " + str(player_count)
	time_label.text = "Started: " + start_time
	
	if is_active:
		join_button.text = "Rejoin"
	else:
		join_button.text = "Join"

# Connect this to the JoinButton's 'pressed' signal in the edito
	

func _on_joinbutton_pressed() -> void:
	join_requested.emit(current_room_id)
