class_name MoveToTargetComponent
extends ComponentBase

signal move_target_changed(target_vector)
signal direction_changed(new_direction)
signal slide_collision_detected(colliding_object)

@export var character_2D : CharacterBody2D
@export var move_target : Vector2 = Vector2.ZERO :
	set(value):
		move_target = value
		move_target_changed.emit(move_target)

@export var movement_speed = 4000
@export var friction : float = 1000
@export var stopped : bool = false :
	set(value):
		stopped = value
		_update_move_sounds()

@export var enabled : bool = true :
	set(value):
		enabled = value
		_update_move_sounds()

@export_group("Navigation Extras")
@export var nav_point_min_distance : float = 3
@export var move_sound_repeat_delay : float = 2.0
@export var move_sound_player_2d : AudioStreamPlayer2D


func _can_update():
	return not stopped and enabled

func _update_move_sounds():
	if not _can_update():
		$SoundDelayTimer.stop()

var direction : Vector2 :
	set(value):
		direction = value
		direction_changed.emit(direction)
var next_navigation_points : Array[Vector2] = [] 

func _get_movement_speed():
	return movement_speed

func _play_move_sound():
	if move_sound_player_2d == null:
		return
	if not _can_update():
		$SoundDelayTimer.stop()
	move_sound_player_2d.play()
	$SoundDelayTimer.start()

func _queue_move_sound():
	if move_sound_player_2d != null and $SoundDelayTimer.is_stopped():
		$SoundDelayTimer.start(move_sound_repeat_delay)

func _move_to_target(target : Vector2, speed : float, delta : float):
	var current_direction = target.normalized()
	character_2D.velocity = character_2D.velocity.move_toward(current_direction * speed, friction * delta)
	if direction != current_direction:
		direction = current_direction

func _process_movement(target : Vector2, speed : float, delta : float):
	if not _can_update() or target.is_zero_approx():
		character_2D.velocity = character_2D.velocity.move_toward(Vector2.ZERO, friction * delta)
		$SoundDelayTimer.stop()
	else:
		_move_to_target(target, speed, delta)
		_queue_move_sound()
	character_2D.move_and_slide()

func _process_impacts():
	for i in range(character_2D.get_slide_collision_count()):
		var collider = character_2D.get_slide_collision(i).get_collider()
		slide_collision_detected.emit(collider)
	character_2D.velocity = character_2D.get_real_velocity()

func _get_navigation_point():
	if next_navigation_points.is_empty():
		return move_target
	var next_navigation_point = next_navigation_points[0]
	if next_navigation_points.size() > 1 and (next_navigation_point - character_2D.position).length_squared() < pow(nav_point_min_distance,2):
		next_navigation_points = next_navigation_points.slice(1)
		next_navigation_point = next_navigation_points[0]
	return next_navigation_point

func _physics_process(delta):
	var next_navigation_point = _get_navigation_point()
	_process_movement(next_navigation_point, _get_movement_speed(), delta)
	if not _can_update():
		return
	_process_impacts()

func _on_sound_delay_timer_timeout():
	_play_move_sound()
