@tool
class_name SpikeTrap
extends Node2D


@onready var animation_player : AnimationPlayer = $AnimationPlayer
@export_enum("FIRST", "SECOND", "THIRD", "FOURTH") var rhythm : int


@export var enabled : bool = false :
	set(value):
		var changed = enabled != value
		enabled = value
		if changed and is_inside_tree():
			if enabled:
				var custom_start = float(rhythm)
				animation_player.play(&"ACTIVE")
				animation_player.seek(custom_start)
			else:
				animation_player.play(&"NORMAL")

func _on_treasure_picked_up(_score : float, _treasure_position : Vector2):
	enabled = true

func _ready():
	enabled = enabled
	ProjectEvents.treasure_picked_up.connect(_on_treasure_picked_up)
