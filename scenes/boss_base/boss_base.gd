class_name BossBase
extends CharacterBody2D

signal health_changed(new_value)
signal max_health_changed(new_value)
signal stage_changed(new_value)
signal new_scene_queued(packed_scene : PackedScene, scene_type : BaseLevel.ChildSceneType, scene_data : Dictionary)
signal died

@export var boss_name : String = ""

func _ready():
	for child in get_children():
		if child is HealthComponent:
			child.health_changed.connect(func(new_value) : health_changed.emit(new_value))
			child.max_health_changed.connect(func(new_value) : max_health_changed.emit(new_value))
			child.died.connect(die)
		if child is BossHealthStagesComponent:
			child.stage_changed.connect(func(new_value) : stage_changed.emit(new_value))
		if child is AttackComponent2D:
			if child.has_signal(&"new_scene_queued"):
				child.new_scene_queued.connect(func(packed_scene, scene_type, scene_data) : new_scene_queued.emit(packed_scene, scene_type, scene_data))

func initialize():
	for child in get_children():
		if child is ComponentBase:
			child.initialize()
		if child is ComponentBase2D:
			child.initialize()

func has_component(node_name : String):
	return has_node(node_name)

func get_component(node_name : String):
	return get_node(node_name)

func die():
	for child in get_children():
		if child is HurtAnimationComponent:
			continue
		if child.get(&"enabled") != null:
			child.set_deferred(&"enabled", false)
		if child.get(&"disabled") != null:
			child.set_deferred(&"disabled", true)
		if child.has_method(&"stop"):
			child.call_deferred(&"stop")
	died.emit()
