class_name SlashAttackComponent2D
extends AttackComponent2D

const ATTACK_ANIMATION = &"SlashAttack"

@export var detector_2d : DetectorBox2D :
	set(value):
		detector_2d = value
		if detector_2d and not detector_2d.object_detected.is_connected(_on_object_detected):
			detector_2d.object_detected.connect(_on_object_detected)

func _on_object_detected(_target_node : Node2D) -> void:
	attack()

func attack():
	if not enabled:
		return
	$AttackAnimationPlayer.play(ATTACK_ANIMATION)
