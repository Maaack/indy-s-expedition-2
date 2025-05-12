class_name MultiShootAttackComponent2D
extends ShootAttackComponent2D

@export var projectile_count : int = 1
@export_range(0, 360) var spread_degrees : float = 0.0 :
	set(value):
		spread_degrees = value
		spread_angle = deg_to_rad(spread_degrees)

var spread_angle
@export var use_own_rotation : bool = false


func attack():
	if not enabled:
		return
	if projectile_count < 1:
		return
	var min_angle : float = -(spread_angle/2)
	var shot_angle : float = spread_angle/float(projectile_count-1) if projectile_count > 1 else spread_angle/2
	_update_attack_direction_from_target()
	for count in projectile_count:
		var projectile_angle : float = (count * shot_angle) + min_angle
		if use_own_rotation:
			projectile_angle += global_rotation
		var projectile_vector : Vector2 = _get_projectile_vector_from_direction().rotated(projectile_angle)
		shoot_projectile(projectile_vector)
