class_name TriggerArea2D
extends Area2D

@export var target_node : Node
@export var target_method : StringName

func trigger():
	if target_node == null:
		push_warning("no target node set")
		return
	if not target_node.has_method(target_method):
		push_warning("target method does not exist on target node")
		return
	target_node.call(target_method)
