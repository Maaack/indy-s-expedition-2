class_name SlashAttackComponent2D
extends AttackComponent2D

const ATTACK_ANIMATION = &"SlashAttack"

func attack():
	if not enabled:
		return
	$AttackAnimationPlayer.play(ATTACK_ANIMATION)
