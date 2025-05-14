@tool
class_name HealthUI
extends HBoxContainer

@export var health : float = 0 :
	set(value):
		health = value
		if is_inside_tree():
			label.text = "%.1f" % health

@onready var label : Label = %Label
