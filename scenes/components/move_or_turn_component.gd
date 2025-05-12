class_name MoveOrTurnComponent
extends ComponentBase

@export var target_position : Vector2 
@export var move_to_target_component : MoveToTargetComponent
@export var turn_to_target_components : Array[TurnToTargetComponent]
@export var rotation_reference : Node2D
@export var move_relative_to_rotation : bool = false

@export_range(0, 180, 0.5) var move_angle_max : float = 180.0 :
	set(value):
		move_angle_max = value
		_move_angle_max_radians = deg_to_rad(move_angle_max)
@export_range(0, 180, 0.5) var turn_angle_min : float = 0.0 :
	set(value):
		turn_angle_min = value
		_turn_angle_min_radians = deg_to_rad(turn_angle_min)
@export_range(0, 180, 0.5) var turn_angle_max : float = 180.0 :
	set(value):
		turn_angle_max = value
		_turn_angle_max_radians = deg_to_rad(turn_angle_max)

@export var enabled : bool = true

var _move_angle_max_radians : float
var _turn_angle_min_radians : float
var _turn_angle_max_radians : float

func _update_components():
	if not enabled:
		return
	var delta_angle = angle_difference(rotation_reference.global_rotation, target_position.angle())
	if move_to_target_component != null:
		if abs(delta_angle) <= _move_angle_max_radians:
			if move_relative_to_rotation:
				move_to_target_component.move_target = Vector2.from_angle(rotation_reference.global_rotation)
			else:
				move_to_target_component.move_target = target_position
		else:
			move_to_target_component.move_target = Vector2.ZERO
	if abs(delta_angle) <= _turn_angle_max_radians and \
	abs(delta_angle) >= _turn_angle_min_radians:
		for turn_to_target_component in turn_to_target_components:
			turn_to_target_component.rotation_target = target_position
			
func _physics_process(delta):
	_update_components()

func initialize():
	move_angle_max = move_angle_max
	turn_angle_max = turn_angle_max
	turn_angle_min = turn_angle_min
	
