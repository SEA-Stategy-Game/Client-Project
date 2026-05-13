extends Node2D

@onready var tilemap = $"../../Terrain/tilemap"
@onready var client = $"../../ClientGateway"

const TERRAIN_ATLAS = {
	0: [  # plains variants
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(0, 1),
	],

	1: Vector2i(0, 0),  # sand
	2: Vector2i(2, 1),  # hills
	3: Vector2i(0, 2),  # water
}

func _ready():
	client.static_state_received.connect(_on_static_state)

func _on_static_state(state: Dictionary):
	tilemap.clear()
	for tile in state.get("map", []):
		var pos = Vector2i(int(tile.x), int(tile.y))
		if (tile.terrain_type == 0):
			var plains_variants = TERRAIN_ATLAS[0]
			var atlas = plains_variants[randi() % plains_variants.size()]
			tilemap.set_cell(pos, 0, atlas)
		else:
			var atlas = TERRAIN_ATLAS.get(int(tile.terrain_type))
			tilemap.set_cell(pos, 0, atlas)
		
