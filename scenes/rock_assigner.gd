extends TileMapLayer

@export var reference_layer: TileMapLayer
@export var tree_layer: TileMapLayer

@export var rock_tiles: Array[Vector2i] = [
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(0,1)
]

@export var rock_threshold: float = 0.45
@export var noise_scale: float = 0.15

var noise := FastNoiseLite.new()


func _ready():

	if reference_layer == null or tree_layer == null:
		print("Reference or tree layer not assigned!")
		return

	randomize()

	noise.seed = randi()
	noise.frequency = noise_scale

	generate_rocks()


func generate_rocks():

	clear()

	var placed := 0

	for cell in reference_layer.get_used_cells():

		# skip if tree exists
		if tree_layer.get_cell_source_id(cell) != -1:
			continue

		var n = noise.get_noise_2d(cell.x, cell.y)

		if n > rock_threshold:
			set_cell(cell, 0, rock_tiles.pick_random(), 0)
			placed += 1

	print("Rocks placed: ", placed)
