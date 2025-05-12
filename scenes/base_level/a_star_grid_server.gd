extends Node2D
class_name AStarGridServer

var astar : AStarGrid2D
@export var region : Rect2i = Rect2i(0, 0, 32, 32)
@export var cell_size : Vector2i = Vector2i(16, 16)
@export var exclude_tilemaps : Array[TileMapLayer]
@export var collision_groups : Array[String]
@export_category("Debugging")
@export var debug_cell_texture : Texture2D
@export var debug_update_time : float = 0
var current_debug_update_time : float = 0
var dynamic_solid_points = {} # dictionary containing the point made solid by dynamic obstacle, each key is a collision group name
var static_solid_points = [] #array containing each cellID of the astar point made solid by tiles such as walls on the

func set_path_length(point_path: Array, max_distance: int) -> Array:
	if max_distance < 0:
		return point_path
	point_path.resize(min(point_path.size(), max_distance))
	return point_path

func exclude_tilemap(tilemap : TileMapLayer):
	var excluded_tiles : Array[Vector2i] = []
	var x_size = region.size.x
	var y_size = region.size.y
	for x in range(x_size):
		for y in range(y_size):
			var astar_vector = Vector2i(x, y) + region.position
			var ratio = Vector2(cell_size) / Vector2(tilemap.tile_set.tile_size)
			var x_total = floor(astar_vector.x * ratio.x)
			var y_total = floor(astar_vector.y * ratio.y)
			var coord2i = Vector2i(x_total, y_total)
			var results = tilemap.get_cell_source_id(coord2i)
			if results > -1:
				astar.set_point_solid(astar_vector, true)
				static_solid_points.append(astar_vector)

func _process_debug(delta):
	if not get_tree().debug_navigation_hint:
		return
	if debug_update_time <= 0:
		return
	current_debug_update_time += delta
	if current_debug_update_time < debug_update_time:
		return
	current_debug_update_time = debug_update_time - current_debug_update_time
	queue_redraw()

func _process(delta):
	_process_debug(delta)

func _ready_astargrid():
	astar = AStarGrid2D.new()
	astar.region = region
	astar.cell_size = Vector2(cell_size)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar.jumping_enabled = true
	astar.update()

func _ready_wall_points():
	for tilemap in exclude_tilemaps:
		exclude_tilemap(tilemap)

func connect_dynamic_node(node : Node2D):
	node.path_blocking_changed.connect(_on_node_path_blocking_changed)
	if node.get_node("CollisionShape2D").disabled == false:
		_on_node_path_blocking_changed(node, true)

func _ready_dynamic_nodes():
	for group_name in collision_groups:
		dynamic_solid_points[group_name] = [] # init an array for each group name
		# connect nodes signal and block the path if the collision of the node is activated
		var group_nodes = get_tree().get_nodes_in_group(group_name)
		for node in group_nodes:
			connect_dynamic_node(node)

func _ready() -> void:
	_ready_astargrid()
	_ready_wall_points()
	_ready_dynamic_nodes()

func _draw():
	if not get_tree().debug_navigation_hint:
		return
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			var draw_coords = Vector2(x, y) * Vector2(cell_size) - debug_cell_texture.get_size()/2
			draw_coords += Vector2(get_half_cell_size())
			if astar.is_point_solid(Vector2i(x, y)):
				draw_texture(debug_cell_texture, draw_coords, Color.RED)
			else:
				draw_texture(debug_cell_texture, draw_coords)

func _on_node_path_blocking_changed(node : Node, blocking : bool):
	# get the points in the collision shape's rect -> check only the points near the object instead of all
	var col_shape = node.get_node("CollisionShape2D")
	var shape_rect = col_shape.shape.get_rect()

	# to iterate using the same coordinate as tha astar region we need a translate vector, starting at its region x,y * cell_size
	# exemple with a region at 0,0 with cell size of 16,16, the first point will be at 0,0 ; then 16,0 ; 24,0 ... 0,16 ; 16,16
	var astar_region_translation = region.position * cell_size
	
	shape_rect.position += col_shape.global_position + Vector2(astar_region_translation) # apply node translation to the rect
	shape_rect.position -= Vector2(get_half_cell_size())
	
	# get the closest point inside the rect
	var closest_start_point = Vector2(
		ceil(round(shape_rect.position.x) / cell_size.x)*cell_size.x,
		ceil(round(shape_rect.position.y) / cell_size.y)*cell_size.y
	)
	var closest_end_point = Vector2(
		floor(round(shape_rect.end.x) / cell_size.x)*cell_size.x,
		floor(round(shape_rect.end.y) / cell_size.y)*cell_size.y
	)
	
	# start go from closest start point, to the end and set solid or not depending on the value emited by the node
	for y in range(closest_start_point.y, closest_end_point.y+1, cell_size.y): # the +1 is because the 2nd value of the range is exclusive so the loop stop at it
		for x in range(closest_start_point.x, closest_end_point.x+1, cell_size.x):
			var pointID = (Vector2i(x,y) - astar_region_translation) / cell_size # de-translate to get point id
			if pointID in static_solid_points or not astar.is_in_boundsv(pointID): # do not touch points made solid by walls
				continue
			astar.set_point_solid(pointID, blocking)
			# cache point ID
			for group in node.get_groups():
				if group in collision_groups:
					var index = dynamic_solid_points[group].find(pointID)
					# if point is cached and not blocking anymore -> remove it
					if index > -1 and not blocking:
						dynamic_solid_points[group].remove_at(index)
					# if point is not in cache and is now blocking -> add it to the cache
					elif index == -1 and blocking:
						dynamic_solid_points[group].append(pointID)


func set_points_disabled(points : Array, disabled : bool = true) -> void:
	for point_vector in points:
		point_vector = Vector2i(point_vector)
		if astar.is_in_boundsv(point_vector):
			astar.set_point_solid(point_vector, disabled)

func set_group_disabled(group_name : String, disabled : bool = true):
	if group_name not in dynamic_solid_points.keys():
		return
	for pointID in dynamic_solid_points[group_name]:
		astar.set_point_solid(pointID, disabled)

func get_astar_path(start_cell: Vector2, end_cell: Vector2, max_distance := -1) -> Array:
	if not astar.is_in_boundsv(start_cell) or not astar.is_in_boundsv(end_cell):
		return []
	var astar_path := astar.get_point_path(start_cell, end_cell)
	return set_path_length(astar_path, max_distance)

func get_astar_path_avoiding_points(start_cell: Vector2, end_cell: Vector2, avoid_cells : Array = [], max_distance := -1) -> Array:
	set_points_disabled(avoid_cells)
	var astar_path := get_astar_path(start_cell, end_cell, max_distance)
	set_points_disabled(avoid_cells, false)
	return astar_path
	
func get_half_cell_size() -> Vector2i:
	return cell_size / 2

func get_nearest_tile_position(check_position : Vector2) -> Vector2i :
	return (Vector2i(round(check_position))) / cell_size

func get_world_path_avoiding_points(start_position: Vector2, end_position: Vector2, avoid_positions : Array = [], max_distance := -1) -> Array:
	var start_cell := get_nearest_tile_position(start_position)
	var end_cell := get_nearest_tile_position(end_position)
	var avoid_cells := []
	for avoid_position in avoid_positions:
		avoid_cells.append(get_nearest_tile_position(avoid_position))
	var return_path = get_astar_path_avoiding_points(start_cell, end_cell, avoid_cells, max_distance)
	return add_half_cell_to_path(return_path)

func add_half_cell_to_path(path : Array) -> Array[Vector2]:
	var return_path : Array[Vector2] = []
	for cell_vector in path:
		return_path.append(cell_vector + Vector2(get_half_cell_size()))
	return return_path
