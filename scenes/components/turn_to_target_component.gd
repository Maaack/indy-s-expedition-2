class_name TurnToTargetComponent
extends ComponentBase

@export var check_los_component : CheckLOSComponent2D :
	set(value):
		check_los_component = value
		if not check_los_component.los_updated.is_connected(_on_los_updated):
			check_los_component.los_updated.connect(_on_los_updated)

@export var rotation_target : Vector2 : 
	set(value):
		rotation_target = value
		rotation_angle = rotation_target.angle()
		
@export var target_nodes : Array[Node2D]
@export var target_stacked_sprites : Array[StackedSprite2D]
@export var rotation_reference : Node2D
@export_range(0, 180, 0.1) var rotation_speed : float = 0.0 :
	set(value):
		rotation_speed = value
		_rotation_speed_radians = deg_to_rad(rotation_speed)
@export var locked : bool = false
@export var enabled : bool = true

var _rotation_speed_radians : float
var rotation_angle : float

func _on_los_updated(new_position : Vector2):
	rotation_target = new_position

func _can_update():
	return not locked and enabled

func _get_target_rotation(target_rotation_angle : float, node_rotation : float, delta : float):
	var delta_angle : float = angle_difference(node_rotation, target_rotation_angle)
	if _rotation_speed_radians > 0 and \
	abs(delta_angle) >= _rotation_speed_radians * delta:
		var _new_rotation_speed = _rotation_speed_radians * delta
		if delta_angle < 0:
			_new_rotation_speed = -_new_rotation_speed
		return node_rotation + _new_rotation_speed
	return target_rotation_angle

func _update_rotation_angle(delta : float):
	if not _can_update():
		return
	for node in target_nodes:
		node.rotation = _get_target_rotation(rotation_angle, node.rotation, delta)
	for stacked_sprite in target_stacked_sprites:
		var total_rotation = rotation_angle
		if rotation_reference:
			total_rotation = angle_difference(rotation_reference.global_rotation, rotation_angle)
		stacked_sprite.sprite_rotation = _get_target_rotation(total_rotation, stacked_sprite.sprite_rotation, delta)

func _physics_process(delta):
	_update_rotation_angle(delta)

func initialize():
	rotation_target = rotation_target
