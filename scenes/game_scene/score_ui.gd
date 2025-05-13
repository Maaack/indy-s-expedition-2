@tool
class_name ScoreUI
extends HBoxContainer

@export var score : int = 0 :
	set(value):
		score = value
		if is_inside_tree():
			label.text = "%08d" % score

@onready var label : Label = %Label
