# Tree.gd attached to StaticBody2D
extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var tree_textures = [
	preload("res://assets/Tree1.png"),
	preload("res://assets/Tree2.png"),
	preload("res://assets/Tree3.png"),
]
var stump_texture = preload("res://assets/TreeStub.png")

func _ready():
	sprite.texture = tree_textures.pick_random()
	$Sprite2D.scale = Vector2(0.5, 0.5)
