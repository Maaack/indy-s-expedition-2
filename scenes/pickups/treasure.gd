class_name Treasure
extends Pickup

@onready var stacked_sprite : StackedSprite2D = %StackedSprite2D

@export var score : int = 0

func _ready():
	super._ready()
	stacked_sprite.sprite_rotation_offset = randf_range(-180, 180)

func _process_pickup():
	ProjectEvents.treasure_picked_up.emit(score, global_position)
	super._process_pickup()
