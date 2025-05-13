extends OverlaidMenu

signal exit_confirmed

func _on_yes_button_pressed():
	get_tree().paused = false
	exit_confirmed.emit()
	queue_free()
