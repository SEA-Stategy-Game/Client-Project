class_name Rock
extends WorldResource

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var rock_textures = [
	preload("res://assets/Rock1.png"),
	preload("res://assets/Rock2.png"),
	preload("res://assets/Rock3.png"),
]

func _ready():
	sprite.texture = rock_textures.pick_random()

func initialise(obj: Dictionary) -> void:
	super(obj)
