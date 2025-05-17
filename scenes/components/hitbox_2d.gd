class_name Hitbox2D
extends Area2D

@export_range(0, 10, 0.01, "or_greater") var damage : float = 1
@export_range(0, 10, 0.01, "or_greater") var stun_duration : float = 0.0
@export_range(0, 1000, 1.0, "or_greater") var knockback_force : float = 0.0

var hurt_boxes : Array[Hurtbox2D]

func hit() -> void:
	for hurtbox in hurt_boxes:
		if stun_duration > 0:
			hurtbox.stun(stun_duration)
		if knockback_force > 0:
			hurtbox.knockback(global_position, knockback_force)
		if damage > 0:
			hurtbox.damage(damage)

func _on_area_entered(area):
	if area is Hurtbox2D:
		hurt_boxes.append(area)

func _on_area_exited(area):
	if area is Hurtbox2D and area in hurt_boxes:
		hurt_boxes.erase(area)

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
