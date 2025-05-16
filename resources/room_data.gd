class_name RoomData
extends Resource

@export var atlas_coord : Vector2i
@export var draft_tile_coord : Vector2i
@export var map_coord : Vector2i
@export var map_tile_coord : Vector2i
@export var door_up : bool
@export var door_down : bool
@export var door_left : bool
@export var door_right : bool
@export var rotation : float = 0.0
@export var inventory : ResourceContainer = ResourceContainer.new()
@export var room_scene : PackedScene

func get_doors() -> Array[Vector2i]:
	var doors : Array[Vector2i] = []
	if door_up:
		doors.append(Vector2i.UP)
	if door_down:
		doors.append(Vector2i.DOWN)
	if door_left:
		doors.append(Vector2i.LEFT)
	if door_right:
		doors.append(Vector2i.RIGHT)
	return doors

func get_random_door() -> Vector2i:
	var doors := get_doors()
	doors.shuffle()
	return doors.pop_back()

func get_rotated_doors() -> Array[Vector2i]:
	var rotated_doors : Array[Vector2i]
	for door in get_doors():
		var rotated_vector := Vector2i(Vector2(door).rotated(rotation).round())
		rotated_doors.append(rotated_vector)
	return rotated_doors
