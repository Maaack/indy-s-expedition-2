extends Camera2D


@export var decay : float = 0.8
@export var max_roll : float = 0.1
@export var max_offset = Vector2(36, 64) # display ratio is 16 : 9
var trauma = 0.0
var trauma_power = 2
var amount = 0.0

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		rough_shake()

func rough_shake():
	amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

func set_shake(add_trauma = 0.5):
	var screenshake_mod = Config.get_config(AppSettings.VIDEO_SECTION, "CameraShake", 1.0)
	add_trauma *= screenshake_mod
	trauma = min(trauma + add_trauma, screenshake_mod)
