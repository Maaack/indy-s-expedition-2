class_name HurtAnimationComponent
extends AnimationPlayer

const HURT_ANIMATION : StringName = &"HURT"
const DEATH_ANIMATION : StringName = &"DEATH"

@export var _health_component : HealthComponent :
	set(value):
		_health_component = value
		if not _health_component.health_changed.is_connected(_on_health_changed):
			_health_component.health_changed.connect(_on_health_changed)
		if not _health_component.died.is_connected(_on_died):
			_health_component.died.connect(_on_died)
@export var enabled : bool = true :
	set(value):
		enabled = value
		if not enabled:
			play("RESET")
var last_health : float = 0.0

func _on_hurt():
	if not has_animation(HURT_ANIMATION):
		push_warning("no hurt animation defined")
		return
	play(HURT_ANIMATION)

func _on_health_changed(new_health : float, delta : float) -> void:
	if new_health < last_health:
		_on_hurt()
	last_health = new_health

func _on_died() -> void:
	if not has_animation(DEATH_ANIMATION):
		push_warning("no death animation defined")
		return
	play(DEATH_ANIMATION)
