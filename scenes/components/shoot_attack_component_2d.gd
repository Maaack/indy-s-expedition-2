class_name ShootAttackComponent2D
extends AttackComponent2D

@export var projectile_scene : PackedScene
@export var projectile_speed : float = 200.0
@export var attack_target : Vector2 = Vector2.ZERO : 
	set(value):
		if lock_target : return
		attack_target = value
		_update_attack_direction_from_target()
@export var attack_direction : float = 0 : 
	set(value):
		if lock_direction : return
		attack_direction = value

@export var team : Constants.Teams

@export var lock_target : bool = false
@export var lock_direction : bool = false

func _shoot_projectile_from_position(projectile_vector : Vector2, projectile_position : Vector2):
	var scene_data : Dictionary = {
		"velocity" = projectile_vector,
		"position" = projectile_position,
		"team" = team
	}
	# new_scene_queued.emit(projectile_scene, BaseLevel.ChildSceneType.PROJECTILE, scene_data)

func shoot_projectile(projectile_vector : Vector2):
	for child in get_children():
		if child is Marker2D:
			_shoot_projectile_from_position(projectile_vector, child.global_position)

func _update_attack_direction_from_target():
	if attack_target.is_zero_approx():
		attack_direction = 0
		return
	attack_direction = attack_target.angle()

func _get_attack_vector_from_direction() -> Vector2:
	return Vector2.from_angle(attack_direction)

func _get_projectile_vector_from_direction() -> Vector2:
	return _get_attack_vector_from_direction() * projectile_speed

func attack():
	if not enabled:
		return
	_update_attack_direction_from_target()
	var projectile_vector : Vector2 = _get_projectile_vector_from_direction()
	shoot_projectile(projectile_vector)
