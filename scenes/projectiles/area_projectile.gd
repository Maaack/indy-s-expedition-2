extends Area2D
class_name AreaProjectile

@export var damage : float
@export var stun_duration : float

var velocity : Vector2
var time_since_spawn : float = 0
var collided_bodies : Array = []

func _physics_process(delta):
	time_since_spawn += delta
	position += velocity * delta
	rotation = velocity.angle()

func _activate_collision_mask(layer):
	set_collision_mask_value(layer, true)

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
	if body.is_in_group(Constants.PLAYER_GROUP) or body.is_in_group(Constants.DESTRUCTIBLE_GROUP):
		_on_body_collided(body)
	else:
		_on_projectile_expired()
