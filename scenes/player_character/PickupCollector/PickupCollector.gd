@tool
extends Node2D

signal pickup_collected(pickup)

@export var pull_area_force : float = 10
@export var pull_max_speed : float = 100
@export var pull_distance_exponent : float = 2.0
@export var pull_area_shape : Shape2D : 
	set(value):
		pull_area_shape = value
		_update_areas()

@export var collect_area_shape : Shape2D : 
	set(value):
		collect_area_shape = value
		_update_areas()
var pulling_pickups : Dictionary = {}

func _update_areas():
	if is_visible_in_tree():
		$PullArea2D/CollisionShape2D.shape = pull_area_shape
		$CollectArea2D/CollisionShape2D.shape = collect_area_shape

func _physics_process(delta):
	if pulling_pickups.size() == 0:
		return
	var shape_2d : CircleShape2D = $PullArea2D/CollisionShape2D.shape
	var pickups_array : Array = pulling_pickups.values()
	for pickup in pickups_array:
		if pickup is Pickup:
			var parent_position = get_parent().position
			var distance = pickup.position.distance_to(parent_position)
			var ratio = shape_2d.radius / (distance + 0.0001)
			var squared_ratio = pow(ratio, pull_distance_exponent)
			var direction = pickup.position.direction_to(parent_position)
			pickup.velocity = pickup.velocity.move_toward(direction * pull_max_speed, squared_ratio * pull_area_force * delta)

func _on_pull_area_2d_body_entered(body):
	if body is Pickup and not body.is_dragged:
		body.is_dragged = true
		pulling_pickups[body.get_instance_id()] = body

func _on_pull_area_2d_body_exited(body):
	if body is Pickup:
		body.is_dragged = false
		pulling_pickups.erase(body.get_instance_id())

func _on_collect_area_2d_body_entered(body):
	if body is Pickup:
		emit_signal("pickup_collected", body)
		body.pickup()

func _ready():
	_update_areas()
