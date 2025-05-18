class_name Events
extends Node

signal player_exiting
signal player_drafting_room(current_tile : Vector2i, direction : Vector2i)
signal level_drafting_room(current_tile : Vector2i, direction : Vector2i, draftable_map : DraftableMap)
signal player_health_changed(health : float, delta : float)
signal player_max_health_changed(max_health : float, delta : float)
signal player_moved(player_global_position : Vector2)
signal treasure_picked_up(score : int, position : Vector2)
signal treasure_added(score : int)
signal heart_picked_up(health : float, position : Vector2)
signal queue_spawn(packed_scene : PackedScene, scene_data : Dictionary)
signal room_drafted(room_data : RoomData)
signal player_died
signal player_aggro
