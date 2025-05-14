class_name StunComponent
extends ComponentBase

@export var move_to_target_component: MoveToTargetComponent

var is_stunned: bool = false

func stun(duration : float) -> void:
	if is_stunned: return
	is_stunned = true
	if move_to_target_component:
		move_to_target_component.stopped = true
	await get_tree().create_timer(duration, false).timeout
	_on_stun_timeout() 

func _on_stun_timeout() -> void:
	if not is_stunned: return
	is_stunned = false
	if move_to_target_component:
		move_to_target_component.stopped = false
