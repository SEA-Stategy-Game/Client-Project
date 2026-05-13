extends Node2D

@onready var tilemap = $"../../Terrain/tilemap"
@onready var client = $"../../ClientGateway"

const TERRAIN_ATLAS = {
	0: [  # plains variants
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(0, 1),
	],

	1: Vector2i(1, 1),  # fores
	2: Vector2i(0, 2),  # hills
	3: [  # water variants
		Vector2i(2, 2),
		Vector2i(1, 2),
	],
}

func _ready():
	client.static_state_received.connect(_on_static_state)

func _on_static_state(state: Dictionary):
	tilemap.clear()
	
	# Store terrain types by position for neighbor lookup
	var terrain_map: Dictionary = {}
	for tile in state.get("map", []):
		terrain_map[Vector2i(int(tile.x), int(tile.y))] = int(tile.terrain_type)
	
	# Place all tiles
	for pos in terrain_map:
		var terrain_type = terrain_map[pos]
		if terrain_type == 0:
			var plains_variants = TERRAIN_ATLAS[0]
			var atlas = plains_variants[randi() % plains_variants.size()]
			tilemap.set_cell(pos, 0, atlas)
		elif terrain_type == 3:
			# Check if any neighbor is plains (type 0)
			var neighbors = [
				pos + Vector2i(1, 0), pos + Vector2i(-1, 0),
				pos + Vector2i(0, 1), pos + Vector2i(0, -1),
			]
			#var next_to_non_water = false
			#for dx in range(-2, 3):
				#for dy in range(-2, 3):
					#if dx == 0 and dy == 0:
						#continue
					#var neighbor = pos + Vector2i(dx, dy)
					#if terrain_map.has(neighbor) and terrain_map[neighbor] != 3:
						#next_to_non_water = true
						#break
			var atlas = TERRAIN_ATLAS[3][1]
			tilemap.set_cell(pos, 0, atlas)
		else:
			tilemap.set_cell(pos, 0, TERRAIN_ATLAS.get(terrain_type))
		
