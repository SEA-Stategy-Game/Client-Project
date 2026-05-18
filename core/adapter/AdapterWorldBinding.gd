extends Node

func _ready() -> void:
    var root = get_tree().get_root()
    if root == null:
        return

    var world := root.get_node_or_null("World")
    if world == null:
        world = Node2D.new()
        world.name = "World"
        root.call_deferred("add_child", world)
        call_deferred("_deferred_populate_world")
        return

    _ensure_world_structure(world)

func _deferred_populate_world() -> void:
    var root = get_tree().get_root()
    if root == null:
        return
    var world := root.get_node_or_null("World")
    if world:
        _ensure_world_structure(world)

func _ensure_world_structure(world: Node) -> void:
    if world == null:
        return

    if not world.has_node("NavigationRegion2D"):
        var nav = NavigationRegion2D.new()
        nav.name = "NavigationRegion2D"
        world.call_deferred("add_child", nav)

    var nav_region := world.get_node_or_null("NavigationRegion2D")
    if nav_region:
        if not nav_region.has_node("TileMapLayer"):
            var tilemap = TileMapLayer.new()
            tilemap.name = "TileMapLayer"
            nav_region.call_deferred("add_child", tilemap)

        var tilemap_layer := nav_region.get_node_or_null("TileMapLayer")
        if tilemap_layer and not tilemap_layer.has_node("Objects"):
            var objects = Node2D.new()
            objects.name = "Objects"
            tilemap_layer.call_deferred("add_child", objects)

    if not world.has_node("Units"):
        var units = Node2D.new()
        units.name = "Units"
        world.call_deferred("add_child", units)

    if not world.has_node("Houses"):
        var houses = Node2D.new()
        houses.name = "Houses"
        world.call_deferred("add_child", houses)

func get_world() -> Node:
    return get_tree().get_root().get_node_or_null("World")

func get_tilemap_layer() -> Node:
    var w = get_world()
    if w:
        var nav := w.get_node_or_null("NavigationRegion2D")
        if nav:
            return nav.get_node_or_null("TileMapLayer")
    return null