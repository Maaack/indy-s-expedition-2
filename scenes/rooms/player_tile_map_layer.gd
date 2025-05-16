class_name PlayerTileMapLayer
extends TileMapLayer

@export var pc_tile_source_id : int = -1
@export var pc_tile_atlas_coord : Vector2i = Vector2.ONE * -1

var pc_tile : Vector2i :
	set(value):
		pc_tile = value
		if is_inside_tree():
			clear()
			set_cell(pc_tile, pc_tile_source_id, pc_tile_atlas_coord)
