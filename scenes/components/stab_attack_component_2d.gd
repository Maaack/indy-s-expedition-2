class_name StabAttackComponent
extends AttackComponent2D

const ATTACK_ANIMATION = &"StabAttack"

func attack():
	if not enabled:
		return
	$AttackAnimationPlayer.play(ATTACK_ANIMATION)
