extends Camera2D

@export var main_camera : Camera2D 

func update_minimap_view():
	if not main_camera or main_camera.map_max == Vector2.ZERO:
		return
		
	# 1. Center the camera perfectly in the middle of your map bounds
	var map_size = main_camera.map_max - main_camera.map_min
	global_position = main_camera.map_min + (map_size * 0.5)
	
	# FIX: Use get_viewport().get_visible_rect().size to get the 
	# actual, current pixel size of this specific minimap window box.
	var viewport_size = get_viewport().get_visible_rect().size
	
	# 2. Match the zoom so the full map fits the UI window perfectly
	var zoom_x = viewport_size.x / map_size.x
	var zoom_y = viewport_size.y / map_size.y
	
	# Take the smaller zoom factor to ensure no edges are cut off
	var final_zoom = min(zoom_x, zoom_y)
	zoom = Vector2(final_zoom, final_zoom)
