extends Node2D

@export var main_camera : Camera2D

func _process(_delta):
	queue_redraw()

func _draw():
	if not main_camera or main_camera.map_max == Vector2.ZERO:
		return
		
	# 1. Get the true world size of the whole map
	var map_size = main_camera.map_max - main_camera.map_min
	
	# 2. Get the current size of your small minimap container window
	var minimap_size = get_viewport().get_visible_rect().size
	
	# 3. Get the true screen size of your actual game window
	var game_screen_size = get_tree().root.get_visible_rect().size
	
	# 4. Calculate how big the main camera view is in the world
	var view_width = game_screen_size.x / main_camera.zoom.x
	var view_height = game_screen_size.y / main_camera.zoom.y
	
	# 5. Scale that world view down to match the minimap pixels
	var rect_w = (view_width / map_size.x) * minimap_size.x
	var rect_h = (view_height / map_size.y) * minimap_size.y
	
	# 6. Find where the main camera is relative to the map bounds (0.0 to 1.0 percentage)
	var pct_x = (main_camera.global_position.x - main_camera.map_min.x) / map_size.x
	var pct_y = (main_camera.global_position.y - main_camera.map_min.y) / map_size.y
	
	# 7. Convert that percentage to minimap screen coordinates (centered)
	var center_x = pct_x * minimap_size.x
	var center_y = pct_y * minimap_size.y
	
	var rect_x = center_x - (rect_w * 0.5)
	var rect_y = center_y - (rect_h * 0.5)
	
	# Draw it perfectly on the minimap layer
	draw_rect(Rect2(rect_x, rect_y, rect_w, rect_h), Color.YELLOW, false, 3.0)
