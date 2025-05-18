class_name LevelState
extends Resource

@export var tutorial_read : bool = false
@export var stealing_tutorial_read : bool = false
@export var drafting_tutorial_read : bool = false
@export var artifacts_available : int = 0
@export var artifacts_stolen : int = 0
@export var culture_available : int = 0
@export var culture_scored : int = 0
@export var rooms_available : int = 0
@export var rooms_drafted : int = 0

func reset_level_score():
	artifacts_available = 0
	artifacts_stolen = 0
	culture_available = 0
	culture_scored = 0
	rooms_drafted = 0
