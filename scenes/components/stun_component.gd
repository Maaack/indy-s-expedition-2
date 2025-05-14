class_name StunComponent
extends ComponentBase

@onready var timer : Timer = $Timer
@export var move_to_target_component: MoveToTargetComponent

var is_stunned: bool = false

func stun(duration : float) -> void:
	is_stunned = true
	if move_to_target_component:
		move_to_target_component.stopped = true
	timer.start(duration)

func _on_stun_timeout() -> void:
	if not is_stunned: return
	is_stunned = false
	if move_to_target_component:
		move_to_target_component.stopped = false

func _on_timer_timeout():
	_on_stun_timeout()
