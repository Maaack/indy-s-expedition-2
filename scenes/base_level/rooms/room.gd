class_name Room2D
extends Node2D


@onready var walls_north : TileMapLayer = $WallsNorth
@onready var walls_south : TileMapLayer = $WallsSouth
@onready var walls_east : TileMapLayer = $WallsEast
@onready var walls_west : TileMapLayer = $WallsWest

@onready var all_walls : Array[TileMapLayer] = [walls_north, walls_south, walls_east, walls_west]

@export var room_data : RoomData :
	set(value):
		room_data = value
		if is_inside_tree():
			_refresh_walls()

func _refresh_walls() -> void:
	if room_data == null: return
	for wall in all_walls:
		wall.show()
		wall.collision_enabled = true
	var doors = room_data.get_rotated_doors()
	for door in doors:
		match(door):
			Vector2i.UP:
				walls_north.hide()
				walls_north.collision_enabled = false
			Vector2i.DOWN:
				walls_south.hide()
				walls_south.collision_enabled = false
			Vector2i.LEFT:
				walls_west.hide()
				walls_west.collision_enabled = false
			Vector2i.RIGHT:
				walls_east.hide()
				walls_east.collision_enabled = false

func _ready():
	_refresh_walls()
