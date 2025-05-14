class_name KnockbackComponent
extends ComponentBase

@export var character_2D : CharacterBody2D

func knockback(direction : Vector2, force : float) -> void:
	print(force)
	var knockback_direction := character_2D.global_position - direction
	character_2D.velocity += knockback_direction.normalized() * force
