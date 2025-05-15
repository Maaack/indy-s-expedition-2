class_name ProjectileBase
extends CharacterBody2D

@onready var collision_shape_2d : CollisionShape2D = $CollisionShape2D
@onready var hitbox_2d : Hitbox2D = $Hitbox2D


func _physics_process(delta):
	var collided := move_and_slide()
	if collided:
		hitbox_2d.hit()
		queue_free()

func _on_timer_timeout():
	collision_shape_2d.disabled = false
