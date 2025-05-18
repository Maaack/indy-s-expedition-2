@tool
class_name HealthUI
extends HBoxContainer

@export var heart_texture_scene : PackedScene

@export var health : float = 0 :
	set(value):
		health = value
		if is_inside_tree():
			label.text = "%.1f" % health
			_refresh_hearts()
			
@export var health_per_heart : float = 2.0
@export var max_health : float = 6.0

@onready var label : Label = %Label

var heart_instances : Array[HealthTextureRect]

func _refresh_hearts():
	var remaining_health := health
	print(remaining_health)
	for heart_instance in heart_instances:
		if remaining_health >= health_per_heart:
			heart_instance.state = HealthTextureRect.State.FULL
		elif remaining_health > 0:
			heart_instance.state = HealthTextureRect.State.HALF
		else:
			heart_instance.state = HealthTextureRect.State.EMPTY
		remaining_health -= health_per_heart
		print(" : ", remaining_health)

func _ready():
	var heart_count := max_health / health_per_heart
	for i in range(heart_count):
		var heart_instance : HealthTextureRect = heart_texture_scene.instantiate()
		heart_instance.state = HealthTextureRect.State.FULL
		add_child(heart_instance)
		heart_instances.append(heart_instance)
