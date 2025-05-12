class_name AttackAnimationComponent
extends AnimationPlayer

const ATTACK_ANIMATION = &"ATTACK"

@export var enabled : bool = true :
	set(value):
		enabled = value
		play("RESET")

func attack():
	if not enabled:
		return
	if not has_animation(ATTACK_ANIMATION):
		return
	play(ATTACK_ANIMATION)
