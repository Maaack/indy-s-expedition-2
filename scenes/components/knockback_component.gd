class_name KnockbackComponent
extends ComponentBase

@export var character_2D : CharacterBody2D
@export var modifier : float = 1.0

func knockback(knockback_position : Vector2, force : float) -> void:
	var knockback_direction := character_2D.global_position - knockback_position
	character_2D.velocity += knockback_direction.normalized() * force * modifier
