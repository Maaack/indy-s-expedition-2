class_name Hurtbox2D
extends Area2D

const AREA_FLAG = 1
const BODY_FLAG = 2
@export_flags("Area", "Body") var _type : int = AREA_FLAG
@export var enabled : bool = true
@export var _components : Array[ComponentBase]
@export var _max_damage : float = 0.0

func _get_final_damage(incoming_damage : float):
	var final_damage : float = incoming_damage
	if _max_damage != 0:
		final_damage = min(_max_damage, final_damage)
	return final_damage

func knockback(knockback_position : Vector2, force : float):
	if not enabled: return
	for component in _components:
		if component.has_method(&"knockback"):
			component.knockback(knockback_position, force)

func stun(duration : float):
	if not enabled: return
	for component in _components:
		if component.has_method(&"stun"):
			component.stun(duration)

func damage(incoming_damage : float):
	if not enabled: return
	var final_damage = _get_final_damage(incoming_damage)
	for component in _components:
		if component.has_method(&"damage"):
			component.damage(final_damage)
