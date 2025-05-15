@tool
class_name SpikeTrap
extends Node2D


@onready var animation_player : AnimationPlayer = $AnimationPlayer
@export_enum("FIRST", "SECOND", "THIRD", "FOURTH") var rhythm : int


@export var enabled : bool = false :
	set(value):
		enabled = value
		if is_inside_tree():
			if enabled:
				var custom_start = float(rhythm)
				animation_player.play(&"ACTIVE")
				animation_player.seek(custom_start)
			else:
				animation_player.play(&"NORMAL")

func _ready():
	enabled = enabled
