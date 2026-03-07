extends Node


var BASE_URL: String
var IS_DEBUG: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var config = ConfigFile.new()
	
	var is_dev = OS.has_feature("editor")
	
	var config_file = "res://config/config.dev.cfg" if is_dev else "res://config/config.prod.cfg"
	config.load(config_file)
	
	BASE_URL = config.get_value("server", "base_url", "http://localhost:8080")
	IS_DEBUG = config.get_value("server", "debug", true)
