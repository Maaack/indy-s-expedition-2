@tool
class_name DraftingManager
extends Node

signal room_drafted(room_data : RoomData)

@export var draft_option_count : int = 3
@export var room_options_container : BoxContainer
@export var room_draft_option_scene : PackedScene

var drafting_options : Array[RoomData]
var draftable_map : DraftableMap

func _clear_drafting_options() -> void:
	for option in room_options_container.get_children():
		option.queue_free()

func _refresh_drafting_options() -> void:
	if room_options_container == null or room_draft_option_scene == null: return
	_clear_drafting_options()
	for iter in range(draft_option_count):
		if drafting_options.is_empty(): return
		var room_draft_option := room_draft_option_scene.instantiate()
		room_options_container.add_child(room_draft_option)
		room_draft_option.room_data = drafting_options.pop_back()
		room_draft_option.disabled = true
		room_draft_option.pressed.connect(_on_room_option_pressed.bind(room_draft_option))

func enable() -> void:
	if room_options_container == null: return
	for option in room_options_container.get_children():
		if option is RoomDraftOption:
			option.disabled = false

func disable() -> void:
	if room_options_container == null: return
	for option in room_options_container.get_children():
		if option is RoomDraftOption:
			option.disabled = true

func draft_room(room_data : RoomData) -> void:
	draftable_map.mark_drafted(room_data)
	room_drafted.emit(room_data)
	disable()

func _on_room_option_pressed(selected_option : RoomDraftOption) -> void:
	draft_room(selected_option.room_data)

func draft(map_coord : Vector2i, map_tile_coord : Vector2i, direction : Vector2i, in_draftable_map : DraftableMap) -> void:
	draftable_map = in_draftable_map
	drafting_options.clear()
	var draftable_rooms := draftable_map.get_draftable_rooms()
	draftable_rooms.shuffle()
	for iter in range(draft_option_count):
		var next_room : RoomData = draftable_rooms.pop_back()
		if next_room == null: break
		var next_room_door := next_room.get_random_door()
		next_room.rotation = Vector2(next_room_door).angle_to(-direction)
		next_room.map_coord = map_coord + direction
		next_room.map_tile_coord = map_tile_coord + direction
		drafting_options.append(next_room)
	_refresh_drafting_options()
