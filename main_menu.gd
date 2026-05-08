extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dict = {
	  "current_tick": 16,
	  "units": [
		{
		  "meta_values": {
			"entity_id": -1,
			"max_health": 100,
			"player_id": 0,
			"position": [-114.4198, -130.1099]
		  },
		  "path": [
			[-129.8199, -39.1828],
			[-114.8059, -127.8304],
			[-113.368, -136.3203]
		  ],
		  "speed": 2000
		}
	  ],
	  "modified_objects": [
		{
		  "meta_values": {
			"entity_id": -1,
			"max_health": 100,
			"player_id": -1,
			"position": [-128.0, -136.0]
		  },
		  "destroyed": true,
		  "amount_left": 0
		}
	  ]
	} 
	dict = JSON.stringify(dict)
	var dict_data = JSON.parse_string(dict)
	_on_start_pressed(dict_data)
	#pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed(dict_data: Dictionary) -> void:
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn") # I don't know how to use this - Josiaht
	var tick = dict_data["current_tick"]
	var unit_info = dict_data["units"][0]["meta_values"]
	var mod_objs = dict_data["modified_objects"][0]["meta_values"] 
	var place_trees = TreePlacer.new() 
	place_trees.fill_from_reference(mod_objs) 
	#pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit")
	pass # Replace with function body.
