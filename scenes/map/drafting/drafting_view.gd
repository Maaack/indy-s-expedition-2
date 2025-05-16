@tool
class_name DraftingView
extends Control

signal room_option_drafted(room_data : RoomData)

@onready var drafting_manager : DraftingManager = $DraftingManager

func draft(from_room : Vector2i, direction : Vector2i, draftable_map : DraftableMap) -> void:
	drafting_manager.draft(from_room, direction, draftable_map)

func _on_drafting_manager_room_drafted(room_data : RoomData) -> void:
	room_option_drafted.emit(room_data)

func enable() -> void:
	drafting_manager.enable()
