class_name DraftPoint
extends Node2D

@export var direction : Constants.Direction
@export var disabled : bool = false 

func _on_area_2d_body_entered(body):
	if disabled: return
	var current_tile : Vector2i = round(global_position / Vector2(Constants.ROOM_SIZE))
	if body is PlayerCharacter2D:
		var direction_vector = Constants.get_direction_vector(direction)
		ProjectEvents.player_drafting_room.emit(current_tile, direction_vector)
		queue_free()
		
