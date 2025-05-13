extends Control

@export var exit_confirmation_screen : PackedScene 

func _on_player_exiting():
	var instance := exit_confirmation_screen.instantiate()
	add_child(instance)
	if instance.has_signal(&"exit_confirmed"):
		instance.connect(&"exit_confirmed", func() -> void: $LevelListManager._on_level_won())


func _ready():
	ProjectEvents.player_exiting.connect(_on_player_exiting)
