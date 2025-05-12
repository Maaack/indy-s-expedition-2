extends AttackComponent2D


@onready var ray_cast : RayCast2D = $RayCast2D
@onready var line : Line2D = $Line2D
@export var character_body : PhysicsBody2D
@export var attachable_groups : Array[StringName]
@export var hurtable_groups : Array[StringName]
@export var action_name : StringName
@export var whip_pull_force : float = 100

var attached_global_point : Vector2
var is_attached : bool

func attach_whip_to_point(target_position : Vector2) -> void:
	attached_global_point = target_position
	is_attached = true
	line.show()

func detach_whip() -> void:
	is_attached = false
	line.hide()

func whip_to_object(target_position : Vector2, object : Object) -> void:
	if object is Node:
		for group_name in attachable_groups:
			if object.is_in_group(group_name):
				attach_whip_to_point(target_position)

func attack():
	if ray_cast.is_colliding():
		whip_to_object(ray_cast.get_collision_point(), ray_cast.get_collider())

func _input(event):
	if action_name:
		if event.is_action_pressed(action_name):
			attack()
		elif event.is_action_released(action_name):
			detach_whip()

func get_whip_vector() -> Vector2:
	if not is_attached:
		return Vector2.ZERO
	return attached_global_point - global_position

func _drag_to_attached_point(delta : float) -> void:
	if not is_attached: return
	if not character_body: return
	var whip_vector := get_whip_vector()
	line.remove_point(1)
	line.add_point(whip_vector.rotated(-global_rotation))
	var whip_length := whip_vector.length()
	character_body.velocity += whip_vector.normalized() * delta * whip_pull_force

func _physics_process(delta : float) -> void:
	_drag_to_attached_point(delta)
