extends Node2D

# The % symbol tells Godot to look for the Unique Name
@onready var soundtrack = %SoundTrack

@onready var unit_observer = $Observers/UnitObserver
@onready var buildings_observer = $Observers/BuildingsObserver
@onready var terrain_manager = $Observers/TerrainObserver
@onready var resource_observer = $Observers/ResourceObserver

func _ready() -> void:
	_initialize_world_state()
	apply_audio_settings()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")

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

func _initialize_world_state():
	# This node acts as a director for scene initialization.
	# 1. Pull the state from the cache in the Networking node.
	var state = Networking.static_state_cache

	if state.is_empty():
		print("FATAL: Game scene loaded but no static state was found in the cache!")
		# Handle this gracefully, e.g., return to the main menu.
		get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
		return

	print("DEBUG: node_2d is ready. Initializing observers with cached state.")

	# 2. Pass the state to all interested observers via an 'initialize' method.
	unit_observer.initialize(state)
	buildings_observer.initialize(state)
	terrain_manager.initialize(state)
	resource_observer.initialize(state)


	# 3. Clear the cache now that it has been consumed to free memory.
	print("DEBUG: Clearing static state cache.")
	Networking.static_state_cache = {}
