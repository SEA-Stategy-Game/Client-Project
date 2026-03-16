extends TileMapLayer

@export var reference_layer: TileMapLayer

# Tree tiles (3 out of your 4)
@export var tree_tiles: Array[Vector2i] = [
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(0,1)
]

@export var forest_threshold: float = 0.3
@export var noise_scale: float = 0.1
@export var temporary_tile: Vector2i = Vector2i(1, 1)
@export var duration: float = 5.0


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		var mouse_pos = get_global_mouse_position()
		var cell = local_to_map(to_local(mouse_pos))
		
		if get_cell_source_id(cell) != -1:
			change_tile_temporarily(cell)


func change_tile_temporarily(cell: Vector2i) -> void:
	
	var source_id = get_cell_source_id(cell)
	var atlas_coords = get_cell_atlas_coords(cell)
	var alternative = get_cell_alternative_tile(cell)

	# change tile
	set_cell(cell, source_id, temporary_tile, 0)

	restore_tile_after_delay(cell, source_id, atlas_coords, alternative)


func restore_tile_after_delay(cell, source_id, atlas_coords, alternative):
	await get_tree().create_timer(duration).timeout
	
	set_cell(cell, source_id, atlas_coords, alternative)
var noise := FastNoiseLite.new()

func _ready() -> void:
	randomize()

	noise.seed = randi()
	noise.frequency = noise_scale

	fill_forest()


func fill_forest() -> void:
	if reference_layer == null:
		print("Reference layer not set!")
		return

	clear()

	for cell in reference_layer.get_used_cells():

		var n = noise.get_noise_2d(cell.x, cell.y)

		# Only place trees in forest areas
		if n > forest_threshold:
			set_cell(cell, 0, tree_tiles.pick_random(), 0)
