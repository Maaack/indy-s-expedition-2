extends AttackComponent2D


@onready var ray_cast : RayCast2D = $RayCast2D
@onready var line : Line2D = $Line2D
@export var character_body : PhysicsBody2D
@export var attachable_groups : Array[StringName]
@export var hurtable_groups : Array[StringName]
@export var action_name : StringName
@export var whip_pull_force : float = 100
@export var whip_speed : float = 8.0

var attached_global_point : Vector2
var is_attached : bool
var _tween_target : Vector2

func move_whip_tip(target_position : Vector2) -> void:
	line.set_point_position(1, target_position)

func extend_whip_to_target(amount : float) -> void:
	var final_point := _tween_target - global_position
	final_point = final_point.rotated(-global_rotation)
	move_whip_tip(lerp(Vector2.ZERO, final_point, amount))

func tween_whip_to_global_point(target_position : Vector2, time : float) -> Tween:
	_tween_target = target_position
	var tween := create_tween()
	tween.tween_method(extend_whip_to_target, 0.0, 1.0, time)
	return tween

func attach_whip_to_point(target_position : Vector2) -> void:
	line.show()
	var tween := tween_whip_to_global_point(target_position, 1.0/whip_speed)
	await tween.finished
	attached_global_point = target_position
	is_attached = true

func detach_whip() -> void:
	is_attached = false
	line.hide()

func whip_to_object(target_position : Vector2, object : Object) -> void:
	if object is Node:
		for group_name in attachable_groups:
			if object.is_in_group(group_name):
				attach_whip_to_point(target_position)
		for group_name in hurtable_groups:
			if object.is_in_group(group_name):
				animate_whip_attack(target_position)

func animate_whip_attack(target_position : Vector2):
	var whip_vector := target_position - global_position
	var final_point := whip_vector.rotated(-global_rotation)
	line.show()
	var tween := create_tween()
	tween.tween_method(move_whip_tip, Vector2.ZERO, final_point, 0.5/whip_speed)
	tween.tween_method(move_whip_tip, final_point, Vector2.ZERO, 0.5/whip_speed)

func attack():
	if ray_cast.is_colliding():
		whip_to_object(ray_cast.get_collision_point(), ray_cast.get_collider())

func _input(event):
	if action_name:
		if event.is_action_pressed(action_name):
			attack()
		elif event.is_action_released(action_name):
			detach_whip()

func get_attach_vector() -> Vector2:
	return attached_global_point - global_position

func _drag_to_attached_point(delta : float) -> void:
	if not is_attached: return
	if not character_body: return
	var whip_vector := get_attach_vector()
	var final_point := whip_vector.rotated(-global_rotation)
	line.set_point_position(1, final_point)
	var whip_length := whip_vector.length()
	character_body.velocity += whip_vector.normalized() * delta * whip_pull_force

func _physics_process(delta : float) -> void:
	_drag_to_attached_point(delta)
