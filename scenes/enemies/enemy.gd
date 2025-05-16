@tool
class_name Enemy
extends CharacterBody2D

signal health_changed(new_value)
signal max_health_changed(new_value)
signal died

@onready var sprite_2d : Sprite2D = $Sprite2D
@export var flip_h : bool = false :
	set(value):
		flip_h = value
		if sprite_2d:
			sprite_2d.flip_h = flip_h

func _ready():
	flip_h = flip_h
	for child in get_children():
		if child is HealthComponent:
			child.health_changed.connect(func(new_value) : health_changed.emit(new_value))
			child.max_health_changed.connect(func(new_value) : max_health_changed.emit(new_value))
			child.died.connect(die)

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
