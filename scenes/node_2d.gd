extends Node2D

# The % symbol tells Godot to look for the Unique Name
@onready var soundtrack = %SoundTrack 

func _ready() -> void:
	apply_audio_settings()

func apply_audio_settings() -> void:
	# Use the 'is_instance_valid' check for extra safety
	if is_instance_valid(soundtrack):
		var volume_value = Globalsettings.gamesettings["volume"]
		
		# Convert 0-10 scale to 0.0-1.0
		var linear_volume = volume_value / 10.0
		
		# linear_to_db converts 0.0..1.0 into -80db..0db
		soundtrack.volume_db = linear_to_db(linear_volume)
		
		if not soundtrack.playing:
			soundtrack.play()
	else:
		print("Error: The script still can't find the SoundTrack node!")
