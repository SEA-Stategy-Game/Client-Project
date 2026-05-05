extends Node

const SCENE := preload("res://scenes/PlanEditor/planning.tscn")

var _panel: Control

func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	_panel = SCENE.instantiate()
	layer.add_child(_panel)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_plan"):
		_panel.toggle()
		get_viewport().set_input_as_handled()
