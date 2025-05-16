class_name ExitPoint
extends Node2D

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter2D:
		ProjectEvents.player_exiting.emit()
