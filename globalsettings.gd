extends Node

# Default values
var gamesettings = {
	"colorblind": false, 
	"volume": 0, 
	"brightness": 5
}

var fullscreen: bool = false

func _ready():
	apply_settings()

func apply_settings():
	# 1. Handle Fullscreen
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	
	# 2. Handle Volume (Converting 0-10 scale to Decibels)
	# 0 is usually -80db (mute), 10 is 0db (full)
	var volume_value = clamp(gamesettings["volume"], 0.001, 1.0)
	var db_volume = linear_to_db(volume_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db_volume)
	
	# 3. Handle Brightness/Colorblind
	# These usually require a WorldEnvironment or a Shader. 
	# For now, we just ensure the data is saved.
	var world_env = get_tree().root.find_child("WorldEnvironment", true, false)   
	if world_env and world_env.environment:       
		world_env.environment.adjustment_enabled = true        
		# Map your 0-10 scale to a brightness range (e.g., 0.5 to 1.5)    
		world_env.environment.adjustment_brightness = (gamesettings["brightness"] / 10.0) * 2.0
	print("Settings Applied: ", gamesettings)
