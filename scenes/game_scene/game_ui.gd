extends Control

@onready var score_ui : ScoreUI = %ScoreUI
@onready var health_ui : HealthUI = %HealthUI

@export var exit_confirmation_screen : PackedScene 

var score : int = 0 :
	set(value):
		score = value
		if is_inside_tree():
			score_ui.score = score

var health : float = 0 :
	set(value):
		health = value
		if is_inside_tree():
			health_ui.health = health

func _on_player_exiting():
	var instance := exit_confirmation_screen.instantiate()
	add_child(instance)
	if instance.has_signal(&"exit_confirmed"):
		instance.connect(&"exit_confirmed", func() -> void: $LevelListManager._on_level_won())

func _on_treasure_picked_up(add_score : int, _treasure_position : Vector2) -> void:
	score += add_score

func _on_player_health_changed(new_health : float, delta : float) -> void:
	health = new_health

func _ready():
	ProjectEvents.player_exiting.connect(_on_player_exiting)
	ProjectEvents.treasure_picked_up.connect(_on_treasure_picked_up)
	ProjectEvents.player_health_changed.connect(_on_player_health_changed)
