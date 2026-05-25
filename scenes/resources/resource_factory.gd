extends Node

const _REGISTRY = {
	"ressource_tree": preload("res://scenes/resources/Tree.tscn"),
	"ressource_stone": preload("res://scenes/resources/Rock.tscn"),
}

func create(resource_name: String, obj: Dictionary) -> WorldResource:
	if not _REGISTRY.has(resource_name):
		push_error("ObjectFactory: unknown resource '%s'" % resource_name)
		return null
	var instance = _REGISTRY[resource_name].instantiate() as WorldResource
	instance.initialise(obj)
	return instance
