@tool
class_name GameMap
extends Node2D

@onready var room_tile_layer : RoomTileMapLayer = $RoomsLayer
@onready var pc_layer : PlayerTileMapLayer = $PlayerLayer
@onready var drafted_layer : DraftedTileMapLayer = $DraftedLayer
@onready var heart_layer : TileMapLayer = $HeartLayer
@onready var treasure_layer : TileMapLayer = $TreasureLayer
@onready var room_tile_map_data : PackedByteArray = room_tile_layer.tile_map_data.duplicate()

@export var _entrance_room_data : RoomData

var entrance_room : RoomData
var current_room : RoomData

var tile_offset : Vector2i
var current_tile : Vector2i :
	set(value):
		current_tile = value
		if is_inside_tree():
			pc_layer.pc_tile = get_current_map_tile()
			current_room = drafted_layer.get_drafted_tile(get_current_map_tile())

func reset() -> void:
	room_tile_layer.tile_map_data = room_tile_map_data.duplicate()
	pc_layer.clear()
	heart_layer.clear()
	treasure_layer.clear()
	drafted_layer.reset()
	setup()

func get_current_map_tile() -> Vector2i:
	return current_tile + tile_offset

func setup() -> void:
	current_tile = Vector2i.ZERO
	tile_offset = room_tile_layer.get_start_tile()
	pc_layer.pc_tile = get_current_map_tile()
	entrance_room = _entrance_room_data.duplicate()
	entrance_room.map_tile_coord = get_current_map_tile()
	draft_room(entrance_room)
	var end_tile_coord := room_tile_layer.get_end_tile()

func get_current_tile() -> Vector2i:
	return current_tile

func get_neighboring_tiles() -> Array[Vector2i]:
	return room_tile_layer.get_surrounding_cells(get_current_map_tile())

func _room_has_door(room_data : RoomData, direction : Vector2i) -> bool:
	var doors := room_data.get_rotated_doors()
	return direction in doors

func have_match_doors(direction : Vector2i, starting_point : Vector2i) -> bool:
	var starting_tile := starting_point + tile_offset
	var destination_tile := starting_tile + direction
	var current_room_data := drafted_layer.get_drafted_tile(starting_tile)
	var destination_room_data := drafted_layer.get_drafted_tile(destination_tile)
	var _current_has_door := _room_has_door(current_room_data, direction)
	var _destination_has_door := destination_room_data == null or _room_has_door(destination_room_data, -direction)
	return _current_has_door and _destination_has_door

func has_door_from_current_tile(tile : Vector2i) -> bool:
	var direction := tile - get_current_tile()
	return have_match_doors(direction, get_current_tile())

func is_navigable_tile(tile : Vector2i) -> bool:
	if not has_door_from_current_tile(tile): return false
	return room_tile_layer.is_navigable_tile(tile)

func is_blank_tile(tile : Vector2i) -> bool:
	return room_tile_layer.is_blank_tile(tile)

func is_outer_tile(tile : Vector2i) -> bool:
	return room_tile_layer.is_outer_tile(tile)

func is_draftable_tile(tile : Vector2i) -> bool:
	var map_tile = tile + tile_offset
	if not has_door_from_current_tile(tile): return false
	return room_tile_layer.is_draftable_tile(map_tile)

func get_navigable_tiles() -> Array[Vector2i]:
	var neighboring_tiles := get_neighboring_tiles()
	neighboring_tiles = neighboring_tiles.filter(has_door_from_current_tile)
	return neighboring_tiles.filter(is_navigable_tile)

func get_draftable_tiles() -> Array[Vector2i]:
	var neighboring_tiles := get_neighboring_tiles()
	neighboring_tiles = neighboring_tiles.filter(has_door_from_current_tile)
	return neighboring_tiles.filter(is_draftable_tile)

func draft_room(room_data : RoomData) -> void:
	var draft_room_map_tile = room_data.map_tile_coord
	room_tile_layer.draft_tile(draft_room_map_tile, Vector2i.ONE)
	drafted_layer.draft_room(room_data, tile_offset)
	if room_data.inventory.has(Constants.HEART):
		heart_layer.set_cell(draft_room_map_tile, 0, Vector2i(0, 2))
	if room_data.inventory.has(Constants.TREASURE):
		treasure_layer.set_cell(draft_room_map_tile, 0, Vector2i(1, 0))

func has_item(item_name : StringName) -> bool:
	if current_room == null: return false
	return current_room.inventory.has(item_name)

func has_items() -> bool:
	if current_room == null: return false
	return current_room.inventory.contents.size() > 0

func pickup(item_name : StringName) -> ResourceUnit:
	var item := current_room.inventory.find(item_name)
	if not item : return
	current_room.inventory.remove(item)
	if item.name == Constants.HEART:
		heart_layer.set_cell(current_tile)
	if item.name == Constants.TREASURE:
		treasure_layer.set_cell(current_tile)
	return item

func _ready() -> void:
	setup()
