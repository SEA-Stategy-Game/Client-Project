extends Node

@onready var login_box: LineEdit = $PlayerIdEdit 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_login_pressed() -> void:
	# 1. Capture the text and save it to the Autoload
	if login_box.text != "":
		PlayerManager.player_uuid = login_box.text

	# 2. Change the scene
		get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
	else:
		print("Please enter a Player UUID")
