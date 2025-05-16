class_name PlayerCharacter2D
extends CharacterBody2D

signal died

@export var update_component_directions : Array[ComponentBase2D]
@export_group("Movement")
@export var ground_acceleration : float = 800
@export var air_acceleration : float = 300
@export var max_ground_speed : float = 120
@export var max_air_speed : float = 240
@export var ground_friction : float = 600
@export var air_friction : float = 50

@onready var health_component : HealthComponent = $HealthComponent
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_tree = $CharacterAnimationTree
@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var facing_direction : Vector2
var can_take_damage : bool = true
var is_on_ground : bool = true
var is_running : bool = false

var external_force : Vector2 = Vector2.ZERO
var move_tick_distance_squared : float = 1
var move_distance_squared : float

func face_direction(new_direction : Vector2):
	facing_direction = new_direction.normalized()
	var facing_angle = facing_direction.angle()
	for component_2d in update_component_directions:
		component_2d.rotation = facing_angle
	if facing_direction.x > 0:
		$Sprite2D.scale.x = 1.0
		$GPUParticles2D.scale.x = 1.0
	else:
		$Sprite2D.scale.x = -1.0
		$GPUParticles2D.scale.x = -1.0

func get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return input_vector.normalized()

func animate_run():
	if is_running: return
	is_running = true
	$WalkingStreamRepeater2D.play_loop()
	animation_state.travel("RUN")

func animate_idle():
	if not is_running: return
	is_running = false
	$WalkingStreamRepeater2D.stop_loop()
	animation_state.travel("IDLE")

func animate_sliding():
	$GPUParticles2D.emitting = true

func animate_not_sliding():
	$GPUParticles2D.emitting = false

func move_tick():
	ProjectEvents.player_moved.emit(global_position)

func move_state(delta):
	var input_vector := get_input_vector()
	var target_speed = input_vector * max_ground_speed
	var friction := ground_friction
	var acceleration := ground_acceleration
	if not is_on_ground:
		target_speed = input_vector * max_air_speed
		friction = air_friction
		acceleration = air_acceleration
	var should_accelerate = target_speed.length_squared() > velocity.length_squared()
	if should_accelerate:
		velocity = velocity.move_toward(target_speed, acceleration * delta)
		animate_run()
	else:
		velocity = velocity.move_toward(target_speed, friction * delta)
	if target_speed.length_squared() * 1.25 < velocity.length_squared() and is_on_ground:
		animate_sliding()
	else:
		animate_not_sliding()
	if target_speed.is_zero_approx():
		animate_idle()
	move_and_slide()
	velocity = get_real_velocity()
	move_distance_squared += (velocity * delta).length_squared() * delta
	if move_distance_squared > move_tick_distance_squared:
		move_distance_squared = 0
		move_tick()

func _physics_process(delta):
	move_state(delta)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		var current_window := get_window()
		var window_size := current_window.content_scale_size
		var mouse_position = event.position - Vector2(window_size / 2)
		face_direction(mouse_position)

func start_death():
	died.emit()

func _ready():
	await get_tree().create_timer(0.05).timeout
	initialize()

func _on_pickup_collector_pickup_collected(pickup):
	if pickup is Heart:
		health_component.heal(pickup.health)

func initialize():
	for child in get_children():
		if child is ComponentBase:
			child.initialize()
		if child is ComponentBase2D:
			child.initialize()

func _on_health_component_health_changed(new_value : float, delta : float):
	ProjectEvents.player_health_changed.emit(new_value, delta)

func _on_health_component_died():
	died.emit()
