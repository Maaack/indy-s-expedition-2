class_name BossHealthStagesComponent
extends BossComponent

signal stage_changed(new_stage : int)

@export var _health_component : HealthComponent :
	set(value):
		_health_component = value
		if not _health_component.health_changed.is_connected(_on_health_changed):
			_health_component.health_changed.connect(_on_health_changed)
@export var _health_stage_levels : Array[float] = []
var stage : int = 0 :
	set(value):
		stage = value
		stage_changed.emit(stage)

func _on_health_changed(new_health : float) -> void:
	if _health_stage_levels.is_empty():
		return
	var _last_health_stage_level = _health_stage_levels.back()
	var _last_health_amount = _health_component.max_health * _last_health_stage_level
	if new_health < _last_health_amount:
		stage += 1
		_health_stage_levels.pop_back()

func _ready():
	_health_stage_levels.sort()

func initialize():
	stage = stage
	_health_stage_levels = _health_stage_levels.duplicate()
