extends Node

@onready var stone_scene = preload("res://core/Entities/Resource/Stone.tscn")
@onready var tree_scene = preload("res://core/Entities/Resource/Tree.tscn")
const MapTileScript = preload("res://core/Entities/Map/MapTile.gd")

var rng := RandomNumberGenerator.new()

var spawn_table = {
    MapTileScript.TerrainType.PLAINS: {"spawn_chance": 0.1, "resource_table": {"stone": 2, "tree": 5}},
    MapTileScript.TerrainType.FOREST: {"spawn_chance": 0.3, "resource_table": {"stone": 1, "tree": 5}},
    MapTileScript.TerrainType.HILLS: {"spawn_chance": 0.2, "resource_table": {"stone": 5, "tree": 1}},
    MapTileScript.TerrainType.WATER: {"spawn_chance": 0.0}
}

var _next_resource_id: int = 20000

func _allocate_resource_id() -> int:
    var id := _next_resource_id
    _next_resource_id += 1
    return id

func _ready() -> void:
    for type in spawn_table.values():
        var choice_array: Array[String] = []
        if "resource_table" in type:
            for resource in type["resource_table"]:
                for i in type["resource_table"][resource]:
                    choice_array.append(resource)
            type["choice_array"] = choice_array

func set_rng(_rng: RandomNumberGenerator) -> void:
    rng = _rng

func spawn_resource(type: int):
    var table_type = spawn_table[type]
    if rng.randf() <= table_type["spawn_chance"]:
        var picked_num = rng.randi_range(0, table_type["choice_array"].size() - 1)
        var objects := _get_objects_node()
        match table_type["choice_array"][picked_num]:
            "tree":
                var tree = tree_scene.instantiate()
                tree.entity_id = _allocate_resource_id()
                if objects == null:
                    tree.queue_free()
                    return null
                objects.add_child(tree)
                return tree
            "stone":
                var stone = stone_scene.instantiate()
                stone.entity_id = _allocate_resource_id()
                if objects == null:
                    stone.queue_free()
                    return null
                objects.add_child(stone)
                return stone
    return null

func _get_objects_node() -> Node:
    var root := get_tree().get_root()
    if root == null:
        return null
    return root.get_node_or_null("World/NavigationRegion2D/TileMapLayer/Objects")