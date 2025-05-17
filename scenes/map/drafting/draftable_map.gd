class_name DraftableMap
extends Node2D

const TREASURE = preload("res://resources/items/treasure.tres")
const HEART = preload("res://resources/items/heart.tres")

@export var treasure_rooms : Array[PackedScene]
@export var heart_rooms : Array[PackedScene]
@export var hallways : Array[PackedScene]

var drafted_rooms : Dictionary[Vector2i, RoomData]
@onready var draftable_layer : TileMapLayer = %DraftableLayer
@onready var treasure_layer : TileMapLayer = %TreasureLayer
@onready var heart_layer : TileMapLayer = %HealthLayer
@onready var drafted_tile_map_data : PackedByteArray = draftable_layer.tile_map_data.duplicate()
@onready var treasure_tile_map_data : PackedByteArray = treasure_layer.tile_map_data.duplicate()
@onready var heart_tile_map_data : PackedByteArray = heart_layer.tile_map_data.duplicate()

func get_draftable_rooms() -> Array[RoomData]:
	var draftable_rooms : Array[RoomData] = []
	for used_cell in draftable_layer.get_used_cells():
		var room_data := RoomData.new()
		room_data.atlas_coord = draftable_layer.get_cell_atlas_coords(used_cell)
		room_data.draft_tile_coord = used_cell
		var tile_data := draftable_layer.get_cell_tile_data(used_cell)
		room_data.door_up = tile_data.get_custom_data("door_up")
		room_data.door_down = tile_data.get_custom_data("door_down")
		room_data.door_left = tile_data.get_custom_data("door_left")
		room_data.door_right = tile_data.get_custom_data("door_right")
		if used_cell in treasure_layer.get_used_cells():
			room_data.inventory.add(TREASURE.duplicate())
			room_data.room_scene = treasure_rooms.pick_random()
		elif used_cell in heart_layer.get_used_cells():
			room_data.inventory.add(HEART.duplicate())
			room_data.room_scene = heart_rooms.pick_random()
		else:
			room_data.room_scene = hallways.pick_random()
		draftable_rooms.append(room_data)
	return draftable_rooms

func mark_drafted(room_data : RoomData) -> void:
	drafted_rooms[room_data.draft_tile_coord] = room_data
	draftable_layer.set_cell(room_data.draft_tile_coord)
	treasure_layer.set_cell(room_data.draft_tile_coord)
	heart_layer.set_cell(room_data.draft_tile_coord)
	if room_data.room_scene in treasure_rooms:
		treasure_rooms.erase(room_data.room_scene)
	elif room_data.room_scene in heart_rooms:
		heart_rooms.erase(room_data.room_scene)
	elif room_data.room_scene in hallways:
		hallways.erase(room_data.room_scene)

func reset() -> void:
	draftable_layer.tile_map_data = drafted_tile_map_data.duplicate()
	treasure_layer.tile_map_data = treasure_tile_map_data.duplicate()
	heart_layer.tile_map_data = heart_tile_map_data.duplicate()
	drafted_rooms.clear()
