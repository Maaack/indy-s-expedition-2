class_name JumpComponent
extends ComponentBase

@export var player_character : PlayerCharacter2D
@export var action_name : StringName
@export var hang_time : float = 1.0
@export var animation_tree : AnimationTree
@export var audio_stream_player : AudioStreamPlayer
@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var is_jumping : bool = false

func jump() -> void:
	if is_jumping: return
	is_jumping = true
	player_character.is_on_ground = false
	if audio_stream_player:
		audio_stream_player.play()
	if animation_state:
		animation_state.travel(&"JUMP")
	await get_tree().create_timer(hang_time, false, true).timeout
	player_character.is_on_ground = true
	is_jumping = false

func _input(event):
	if action_name:
		if event.is_action_pressed(action_name):
			jump()
