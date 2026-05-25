extends Node

const _REGISTRY = {
	"ressource_tree": preload("res://scenes/objects/Tree.tscn"),
	"ressource_stone": preload("res://scenes/objects/Rock.tscn"),
}

func create(resource_name: String, obj: Dictionary) -> WorldObject:
	if not _REGISTRY.has(resource_name):
		push_error("ObjectFactory: unknown resource '%s'" % resource_name)
		return null
	var instance = _REGISTRY[resource_name].instantiate() as WorldObject
	instance.initialise(obj)
	return instance
