class_name HealthComponent
extends ComponentBase

signal health_changed(new_value : float, delta : float)
signal max_health_changed(new_value : float, delta : float)
signal died

@export_range(0, 1000, 1, "or_greater") var starting_health : float = 100
@export_range(0, 1000, 1, "or_greater") var max_health : float = 100 :
	set(value):
		var delta := value - max_health
		max_health = value
		max_health_changed.emit(max_health, delta)
@export var enabled : bool = true
var dead : bool = false

func _die():
	if dead:
		return
	dead = true
	emit_signal("died")

var health : float :
	set(value):
		if not enabled:
			return
		var delta := value - health
		health = value
		if health < 0:
			health = 0
		health_changed.emit(health, delta)
		if not dead and health == 0:
			_die()

func heal(amount : float):
	if amount < 0:
		push_warning("cannot heal a negative amount")
	health += amount

func damage(amount : float):
	if amount < 0:
		push_warning("cannot damage a negative amount")
	health -= amount

func initialize():
	health = starting_health
	max_health = max_health
