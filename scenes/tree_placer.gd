extends TileMapLayer

@export var reference_layer: TileMapLayer
@export var random_tiles = [1, 2, 3]

func _ready() -> void:
	randomize()
	fill_from_reference()

func fill_from_reference() -> void:
	if reference_layer == null:
		print("Reference layer not set!")
		return
	
	var rect = reference_layer.get_used_rect()
	
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			var ref_tile = reference_layer.get_cell(Vector2i(x, y))
			
			if ref_tile != -1:
				var tile_id = random_tiles[randi() % random_tiles.size()]
				set_cell(Vector2i(x, y), tile_id)
