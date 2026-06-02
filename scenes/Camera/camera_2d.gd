extends Camera2D

@export var CamSpeed = 20.0
@export var ZoomSpeed = 20.0
@export var ZoomMargin = 0.1
@export var ZoomMax = 3.0

var ZoomFactor = 1.0
var Zooming = false

var map_min = Vector2.ZERO
var map_max = Vector2.ZERO

@onready var tilemap = get_parent().get_node("Terrain/tilemap")
@onready var terrain_manager = get_parent().get_node("Observers/TerrainObserver")
@onready var unit_observer = get_parent().get_node("Observers/UnitObserver")

func _ready():
	limit_left = -10000000
	limit_right = 10000000
	limit_top = -10000000
	limit_bottom = 10000000
	terrain_manager.terrain_ready.connect(update_map_bounds)
	unit_observer.units_ready.connect(_on_units_ready)
	
func _on_units_ready() -> void:
	_spawn_on_player_unit()

func _spawn_on_player_unit() -> void:
	if str(PlayerManager.player_local_id) == "-1" or str(PlayerManager.player_local_id) == "":
		return
		
	var all_units = unit_observer._units.values()
	var player_units = all_units.filter(func(u):
		var uid = u.player_id if "player_id" in u else null
		return str(uid) == str(PlayerManager.player_local_id)
	)
	
	if player_units.is_empty():
		return
		
	var target = player_units[randi() % player_units.size()]
	
	# Ensure this camera is the active one in the main viewport
	make_current()
	
	# Snap to the target unit
	zoom = Vector2(3.0, 3.0)
	global_position = target.global_position
	

func update_map_bounds():
	var used = tilemap.get_used_rect()
	var cell = Vector2(tilemap.tile_set.tile_size) if tilemap.tile_set else Vector2i(16, 16)
	
	var min_cell = used.position
	var max_cell = used.position + used.size

	map_min = tilemap.to_global(Vector2(min_cell) * cell)
	map_max = tilemap.to_global(Vector2(max_cell) * cell)

	print("map_min:", map_min, "map_max:", map_max)
	
	# === ADD THIS LINE AT THE BOTTOM ===
	# Change the path below to match where your minimap camera actually is!
	get_node("../CanvasLayer/Control/SubViewportContainer/SubViewport/MinimapCamera2D").update_minimap_view()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			ZoomFactor = 1.0 + ZoomMargin
			Zooming = true

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			ZoomFactor = 1.0 - ZoomMargin
			Zooming = true

		else:
			Zooming = false

func _process(delta):

	# =========================
	# CAMERA MOVEMENT
	# =========================

	var inputX = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var inputY = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	global_position.x = lerp(
		global_position.x,
		global_position.x + inputX * CamSpeed * (1.0 / zoom.x),
		clamp(CamSpeed * delta, 0.0, 1.0)
	)

	global_position.y = lerp(
		global_position.y,
		global_position.y + inputY * CamSpeed * (1.0 / zoom.y),
		clamp(CamSpeed * delta, 0.0, 1.0)
	)

	# =========================
	# ZOOM
	# =========================

	zoom.x = lerp(
		zoom.x,
		zoom.x * ZoomFactor,
		clamp(ZoomSpeed * delta, 0.0, 1.0)
	)

	zoom.y = lerp(
		zoom.y,
		zoom.y * ZoomFactor,
		clamp(ZoomSpeed * delta, 0.0, 1.0)
	)

	# Prevent zooming out farther than map size
	var viewport_size = get_viewport_rect().size
	var map_size = map_max - map_min

	var min_zoom_x = viewport_size.x / map_size.x
	var min_zoom_y = viewport_size.y / map_size.y

	var dynamic_min_zoom = max(min_zoom_x, min_zoom_y)

	zoom.x = clamp(zoom.x, dynamic_min_zoom, ZoomMax)
	zoom.y = clamp(zoom.y, dynamic_min_zoom, ZoomMax)

	if not Zooming:
		ZoomFactor = 1.0

	# =========================
	# CAMERA CLAMP
	# =========================

	if map_max != Vector2.ZERO:

		var half_screen = Vector2(
			viewport_size.x * 0.5 / zoom.x,
			viewport_size.y * 0.5 / zoom.y
		)

		# actual visible world bounds
		var left = map_min.x + half_screen.x
		var right = map_max.x - half_screen.x
		var top = map_min.y + half_screen.y
		var bottom = map_max.y - half_screen.y

		# if map is smaller than screen OR zoomed out too far
		if left > right:
			global_position.x = (map_min.x + map_max.x) * 0.5
		else:
			global_position.x = clamp(global_position.x, left, right)

		if top > bottom:
			global_position.y = (map_min.y + map_max.y) * 0.5
		else:
			global_position.y = clamp(global_position.y, top, bottom)
