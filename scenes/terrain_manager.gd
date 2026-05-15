extends Node2D

@onready var tilemap = $"../../Terrain/tilemap"
@onready var client = $"../../ClientGateway"



const TERRAIN_ATLAS = {
	0: [  # plains variants
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(3, 0),
	],
	1: Vector2i(4, 0),  # fores
	2: Vector2i(6, 0),  # hills
	3: [
	Vector2i(0, 1), # [0] deep water
	Vector2i(1, 1), # [1] mid deep
	Vector2i(2, 1), # [2] shallow
	Vector2i(3, 1), # [3] very shallow
	]
}

func _ready():
	client.static_state_received.connect(_on_static_state)

func _on_static_state(state: Dictionary):
	tilemap.clear()
	
	var terrain_map: Dictionary = {}
	for tile in state.get("map", []):
		terrain_map[Vector2i(int(tile.x), int(tile.y))] = int(tile.terrain_type)
	
	# Separate cells by terrain
	var water_cells = []
	var land_cells = []
	
	for pos in terrain_map:
		if terrain_map[pos] == 3:
			water_cells.append(pos)
		else:
			land_cells.append(pos)
	
	# Place land first
	for pos in terrain_map:
		var terrain_type = terrain_map[pos]
		if terrain_type == 0:
			tilemap.set_cell(pos, 0, TERRAIN_ATLAS[0][0])
		elif terrain_type != 3:
			tilemap.set_cell(pos, 0, TERRAIN_ATLAS.get(terrain_type))
	
	tilemap.set_cells_terrain_connect(water_cells, 0, 0)
	# Second pass: depth-based tiles for water far from land
	for pos in water_cells:
		var N  = terrain_map.has(pos + Vector2i( 0, -1)) and terrain_map[pos + Vector2i( 0, -1)] != 3
		var S  = terrain_map.has(pos + Vector2i( 0,  1)) and terrain_map[pos + Vector2i( 0,  1)] != 3
		var W  = terrain_map.has(pos + Vector2i(-1,  0)) and terrain_map[pos + Vector2i(-1,  0)] != 3
		var E  = terrain_map.has(pos + Vector2i( 1,  0)) and terrain_map[pos + Vector2i( 1,  0)] != 3
		var NW = terrain_map.has(pos + Vector2i(-1, -1)) and terrain_map[pos + Vector2i(-1, -1)] != 3
		var NE = terrain_map.has(pos + Vector2i( 1, -1)) and terrain_map[pos + Vector2i( 1, -1)] != 3
		var SW = terrain_map.has(pos + Vector2i(-1,  1)) and terrain_map[pos + Vector2i(-1,  1)] != 3
		var SE = terrain_map.has(pos + Vector2i( 1,  1)) and terrain_map[pos + Vector2i( 1,  1)] != 3
		
		# Only replace if no land in any direction (true interior)
		if not N and not S and not W and not E and not NW and not NE and not SW and not SE:
			var min_dist = 999
			for dx in range(-4, 5):
				for dy in range(-4, 5):
					if dx == 0 and dy == 0:
						continue
					var neighbor = pos + Vector2i(dx, dy)
					if terrain_map.has(neighbor) and terrain_map[neighbor] != 3:
						min_dist = min(min_dist, abs(dx) + abs(dy))
			if min_dist <= 2:
				tilemap.set_cell(pos, 0, TERRAIN_ATLAS[3][2])  # shallow
			elif min_dist <= 4:
				tilemap.set_cell(pos, 0, TERRAIN_ATLAS[3][1])  # mid deep
			else:
				tilemap.set_cell(pos, 0, TERRAIN_ATLAS[3][0])  # deep

		
