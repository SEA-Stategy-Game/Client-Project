class_name TreeObject
extends WorldObject

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

func initialise(obj: Dictionary) -> void:
	super(obj)

func show_stump() -> void:
	sprite.texture = stump_texture
	collision.disabled = true
