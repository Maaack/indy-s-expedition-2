class_name RoomTileMapLayer
extends TileMapLayer

@export var blank_tile_source_id : int = -1
@export var blank_tile_atlas_coord : Vector2i = Vector2.ONE * -1
@export var start_tile_source_id : int = -1
@export var start_tile_atlas_coord : Vector2i = Vector2.ONE * -1
@export var end_tile_source_id : int = -1
@export var end_tile_atlas_coord : Vector2i = Vector2.ONE * -1

func is_blank_tile(tile : Vector2i) -> bool:
	return get_cell_atlas_coords(tile) == blank_tile_atlas_coord

func is_outer_tile(tile : Vector2i) -> bool:
	return get_cell_atlas_coords(tile) == -Vector2i.ONE

func get_blank_tiles() -> Array[Vector2i]:
	return get_used_cells_by_id(blank_tile_source_id, start_tile_atlas_coord)

func is_navigable_tile(tile : Vector2i) -> bool:
	var atlas_coords := get_cell_atlas_coords(tile)
	var outside_map := atlas_coords == (Vector2i.ONE * -1)
	var blank_tile := atlas_coords == blank_tile_atlas_coord
	return not (outside_map or blank_tile)

func is_draftable_tile(tile : Vector2i) -> bool:
	var atlas_coords := get_cell_atlas_coords(tile)
	var outside_map := atlas_coords == (Vector2i.ONE * -1)
	var blank_tile := atlas_coords == blank_tile_atlas_coord
	return blank_tile and not outside_map

func get_start_tile() -> Vector2i:
	var start_tile := Vector2i.ZERO
	var start_cells := get_used_cells_by_id(start_tile_source_id, start_tile_atlas_coord)
	if start_cells.is_empty():
		return start_tile
	return start_cells.front()

func get_end_tile() -> Vector2i:
	var end_tile := Vector2i.ZERO
	var end_cells := get_used_cells_by_id(end_tile_source_id, end_tile_atlas_coord)
	if end_cells.is_empty():
		return end_tile
	return end_cells.front()

func draft_tile(tile : Vector2i, atlas_coord : Vector2i = -Vector2i.ONE) -> void:
	set_cell(tile, start_tile_source_id, atlas_coord)
