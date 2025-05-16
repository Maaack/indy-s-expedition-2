class_name Heart
extends Pickup

@onready var stacked_sprite : StackedSprite2D = %StackedSprite2D

@export var health : float = 2.0

func _ready():
	super._ready()
	stacked_sprite.sprite_rotation_offset = randf_range(-180, 180)

func _process_pickup():
	ProjectEvents.heart_picked_up.emit(health, global_position)
	super._process_pickup()
