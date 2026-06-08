extends Node

# Default values
var gamesettings = {
	"colorblind": false, 
	"volume": 0, 
	"brightness": 5
}
var world_environment: WorldEnvironment = null

var fullscreen: bool = false

func _ready():
	apply_settings()

func apply_settings():
	# 1. Handle Fullscreen
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	
	# 2. Handle Volume (Converting 0-10 scale to Decibels)
	# 0 is usually -80db (mute), 10 is 0db (full)
	var db_volume = linear_to_db(gamesettings["volume"] / 10.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db_volume)
	
	
	# 3. DIRECTLY change brightness and contrast of the registered environment
	if is_instance_valid(world_environment) and world_environment.environment:
		# Maps 0-10 slider scale to 0.5x - 1.5x brightness multiplier (5 = 1.0 normal)
		world_environment.environment.adjustment_brightness = 0.5 + (gamesettings["brightness"] / 10.0)
			
		# High contrast toggle used as an instant lightweight colorblind accessibility mode
		world_environment.environment.adjustment_contrast = 1.5 if gamesettings["colorblind"] else 1.0
		# 3. Handle Brightness/Colorblind
	# These usually require a WorldEnvironment or a Shader. 
	# For now, we just ensure the data is saved.
	print("Settings Applied: ", gamesettings)
