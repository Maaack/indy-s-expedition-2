class_name StageAnimationComponent
extends AnimationPlayer

@export var boss_health_stages_component : BossHealthStagesComponent : 
	set(value):
		boss_health_stages_component = value
		if not boss_health_stages_component.stage_changed.is_connected(_on_stage_changed):
			boss_health_stages_component.stage_changed.connect(_on_stage_changed)

func _on_stage_changed(new_stage : int):
	var stage_name : StringName = "STAGE_%d" % (new_stage + 1)
	if not has_animation(stage_name):
		return
	play(stage_name)
