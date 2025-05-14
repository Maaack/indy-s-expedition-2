class_name Hurtbox2D
extends Area2D

const AREA_FLAG = 1
const BODY_FLAG = 2
@export_flags("Area", "Body") var _type : int = AREA_FLAG
@export var _components : Array[ComponentBase]
@export var _hurt_audio_player_2d : AudioStreamPlayer2D
@export var _max_damage : float = 0.0

func _get_final_damage(incoming_damage : float):
	var final_damage : float = incoming_damage
	if _max_damage != 0:
		final_damage = min(_max_damage, final_damage)
	return final_damage

func knockback(direction : Vector2, force : float):
	for component in _components:
		if component.has_method(&"knockback"):
			component.knockback(direction, force)

func stun(duration : float):
	for component in _components:
		if component.has_method(&"stun"):
			component.stun(duration)

func damage(incoming_damage : float):
	var final_damage = _get_final_damage(incoming_damage)
	for component in _components:
		if component.has_method(&"damage"):
			component.damage(final_damage)

func _on_area_entered(area):
	if area is Hitbox2D:
		damage(area.damage)
	if area is AreaProjectile:
		var final_damage = _get_final_damage(area.shot_data.damage)
		damage(area.shot_data.damage)
		if _hurt_audio_player_2d != null:
			_hurt_audio_player_2d.play()
		area.queue_free()
	if area is TriggerArea2D:
		area.trigger()
		
func _on_body_entered(_body):
	pass

func _ready():
	if _type & AREA_FLAG:
		connect("area_entered", _on_area_entered)
	if _type & BODY_FLAG:
		connect("body_entered", _on_body_entered)
		
