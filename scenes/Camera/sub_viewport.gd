extends SubViewport

func _ready():
	# Wait one frame to ensure the main game world is fully initialized
	await get_tree().process_frame
	
	# Force this viewport to mirror the main game's 2D world space
	world_2d = get_tree().root.get_viewport().world_2d
