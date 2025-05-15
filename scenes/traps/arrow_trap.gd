@tool
class_name ArrowTrap
extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var timer : Timer = $Timer
@onready var collision_shape_2d : CollisionShape2D = $StaticBody2D/CollisionShape2D

enum Direction{
	NORTH,
	SOUTH,
	EAST,
	WEST
}

@export var arrow_scene : PackedScene
@export var spawn_offset : float = 4.0
@export var spawn_velocity : float = 100.0
@export_enum("FIRST", "SECOND", "THIRD", "FOURTH") var rhythm : int
@export var directions : Array[Direction]
@export var physically_visible : bool = true :
	set(value):
		physically_visible = value
		sprite.visible = physically_visible
		collision_shape_2d.disabled = !(physically_visible)

@export var enabled : bool = false :
	set(value):
		var changed = enabled != value
		enabled = value
		if changed and is_inside_tree():
			if enabled:
				var custom_start = float(rhythm)
				timer.start(custom_start)
			else:
				timer.stop()

func _on_treasure_picked_up(_score : float, _treasure_position : Vector2):
	enabled = true

func _ready():
	enabled = enabled
	ProjectEvents.treasure_picked_up.connect(_on_treasure_picked_up)

func fire_arrows():
	for direction in directions:
		var offset_direction := Vector2.UP
		var spawn_rotation := 0.0
		match direction:
			Direction.SOUTH:
				offset_direction = Vector2.DOWN
				spawn_rotation = PI
			Direction.EAST:
				offset_direction = Vector2.LEFT
				spawn_rotation = -PI/2
			Direction.WEST:
				offset_direction = Vector2.RIGHT
				spawn_rotation = PI/2
		var spawn_position := global_position + (offset_direction * spawn_offset)
		var spawn_velocity := offset_direction * spawn_velocity
		var scene_data := {
			"rotation": spawn_rotation,
			"position": spawn_position,
			"velocity": spawn_velocity
		}
		ProjectEvents.queue_spawn.emit(arrow_scene, scene_data)

func _on_timer_timeout():
	fire_arrows()
