class_name ProjectileBase
extends CharacterBody2D

@export var team : Constants.Teams # legacy variable
var shot_data # legacy variable

func _physics_process(delta):
	move_and_slide()
