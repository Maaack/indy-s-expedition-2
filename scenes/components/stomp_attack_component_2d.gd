class_name StompAttackComponent2D
extends AttackComponent2D

const ATTACK_ANIMATION = &"StompAttack"

func attack():
	if not enabled:
		return
	$AttackAnimationPlayer.play(ATTACK_ANIMATION)
