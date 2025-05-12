class_name TargetLOSComponent
extends ComponentBase

@export var check_los_component : CheckLOSComponent2D :
	set(value):
		check_los_component = value
		if not check_los_component.los_updated.is_connected(_update_target_to_los_position):
			check_los_component.los_updated.connect(_update_target_to_los_position)

@export var target_components : Array[ComponentBase]
@export var target_components_2d : Array[ComponentBase2D]
@export var target_variable : StringName
@export var enabled : bool = true

func _update_target_variable_on_array(_components : Array, new_position : Vector2):
	for _component in _components:
		if _component.get(target_variable) != null:
			_component.set(target_variable, new_position)

func _update_target_to_los_position(new_position : Vector2):
	if not enabled:
		return
	if not target_components.is_empty():
		_update_target_variable_on_array(target_components, new_position)
	if not target_components_2d.is_empty():
		_update_target_variable_on_array(target_components_2d, new_position)
