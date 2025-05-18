@tool
extends CharacterBody2D
class_name Pickup

signal picked_up

var is_picked_up : bool = false

@export var texture : Texture :
	set(value):
		texture = value
		if is_visible_in_tree():
			$Sprite2D.texture = texture
@export var is_draggable : bool = true :
	set(value):
		is_draggable = value
		set_physics_process(is_draggable)
@export var friction : float = 300

var is_dragged : bool = false

func _physics_process(delta):
	if not is_dragged:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
	if get_position_delta().length_squared() < 1 and velocity < Vector2.ONE * 0.1:
		velocity = Vector2.ZERO

func _process_pickup():
	emit_signal("picked_up")
	queue_free()

func pickup():
	if is_picked_up:
		return
	is_picked_up = true
	_process_pickup()

func _ready():
	texture = texture
	is_draggable = is_draggable
