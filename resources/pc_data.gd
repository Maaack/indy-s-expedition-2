class_name PCData
extends Resource

@export var map_tile_coord : Vector2i
@export var inventory : ResourceContainer = ResourceContainer.new()

func reset() -> void:
	map_tile_coord = Vector2i.ZERO
	inventory.clear()
