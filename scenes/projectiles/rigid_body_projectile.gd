extends RigidBody2D
class_name RigidBodyProjectile

@export var team : Constants.Teams
@export var velocity_mod : float = 10
var velocity : Vector2
var time_since_spawn : float = 0
var collided_bodies : Array = []

func _calculate_initial_force():
	var force : Vector2 = velocity * mass * velocity_mod
	rotation = velocity.angle()
	apply_central_force(force)

func _activate_collision_mask(layer):
	set_collision_mask_value(layer, true)

func _ready():
	_calculate_initial_force()

func _on_projectile_expired():
	pass

func _on_kill_timer_timeout():
	_on_projectile_expired()

func _on_new_body_collided(_body_node):
	pass

func _on_body_collided(body_node):
	if body_node in collided_bodies:
		return
	collided_bodies.append(body_node)
	_on_new_body_collided(body_node)

func _on_body_entered(body):
	_on_body_collided(body)
