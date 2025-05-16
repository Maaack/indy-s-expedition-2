class_name DraftedTileMapLayer
extends TileMapLayer

@export var draft_tile_source_id : int = -1

var drafted_tile_map : Dictionary[Vector2i, RoomData]

var _draft_queue : Array[RoomData]
var _drafting_room : bool = false

func draft_room(room_data : RoomData) -> void:
	_draft_queue.append(room_data)
	drafted_tile_map[room_data.map_tile_coord] = room_data

func reset() -> void:
	_draft_queue.clear()
	_drafting_room = false
	drafted_tile_map.clear()
	clear()

func _on_ready_update_room_data(room_data : RoomData) -> void:
	await child_entered_tree
	if not _drafting_room: return
	var last_child : Node = get_children().pop_back()
	await last_child.ready
	if not _drafting_room: return
	if last_child is RoomDraftedSlot:
		last_child.room_data = room_data
	_drafting_room = false

func _draft_tile(room_data : RoomData) -> void:
	if _drafting_room:
		push_warning("can only draft one room at a time")
		return
	_drafting_room = true
	set_cell(room_data.map_tile_coord, draft_tile_source_id, Vector2i.ZERO, 1)
	_on_ready_update_room_data(room_data)

func get_drafted_tile(coord : Vector2i) -> RoomData:
	if not coord in drafted_tile_map: return
	return drafted_tile_map[coord]

func _process(_delta : float) -> void:
	if (!_drafting_room) and (!_draft_queue.is_empty()):
		_draft_tile(_draft_queue.pop_front())
