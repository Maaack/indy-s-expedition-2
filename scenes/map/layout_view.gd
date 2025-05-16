extends Control

@onready var game_map : GameMap = %GameMap
@onready var current_tile_label : Label = %CurrentTileLabel
@onready var steps_taken_label : Label = %StepsTakenLabel
@onready var travel_up_button : Button = %TravelUpButton
@onready var travel_down_button : Button = %TravelDownButton
@onready var travel_left_button : Button = %TravelLeftButton
@onready var travel_right_button : Button = %TravelRightButton
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var drafting_view : DraftingView = $DraftingView
@onready var pickup_key_button := %PickupKeyButton
@onready var pickup_gem_button := %PickupGemButton
@onready var key_count_label := %KeyCountLabel
@onready var gem_count_label := %GemCountLabel

@onready var travel_button_map : Dictionary[Vector2i, Button] = {
	Vector2i.UP : travel_up_button,
	Vector2i.DOWN : travel_down_button,
	Vector2i.LEFT : travel_left_button,
	Vector2i.RIGHT : travel_right_button,
}

var pc_data : PCData = PCData.new()
var drafting_tile : Vector2i
var steps_taken : int = 0

func _refresh_current_tile() -> void:
	var current_tile := game_map.get_current_tile()
	current_tile_label.text = "%d x %d" % [current_tile.x, current_tile.y]

func _refresh_steps_taken() -> void:
	steps_taken_label.text = "%d" % [steps_taken]

func _refresh_travel_options() -> void:
	var navigable_tiles := game_map.get_navigable_tiles() + game_map.get_draftable_tiles()
	var current_tile := game_map.get_current_tile()
	for travel_vector in travel_button_map:
		var travel_button := travel_button_map[travel_vector]
		var travel_tile := travel_vector + current_tile
		travel_button.disabled = travel_tile not in navigable_tiles

func _refresh_inventory_options() -> void:
	pickup_key_button.disabled = !game_map.has_item(Constants.KEY)
	pickup_gem_button.disabled = !game_map.has_item(Constants.GEM)
	key_count_label.text = "Keys:\n%d" % pc_data.inventory.get_item_quantity(Constants.KEY)
	gem_count_label.text = "Gems:\n%d" % pc_data.inventory.get_item_quantity(Constants.GEM)

func _can_move_to_tile(tile : Vector2i) -> bool:
	var navigable_tiles := game_map.get_navigable_tiles() + game_map.get_draftable_tiles()
	return tile in navigable_tiles

func _open_tile_drafting(direction : Vector2i) -> void:
	drafting_view.draft(game_map.current_tile, direction)
	animation_player.play("OPEN_DRAFTING", -1, 2.0)
	await animation_player.animation_finished
	drafting_view.enable()

func _close_tile_drafting() -> void:
	animation_player.play("CLOSE_DRAFTING", -1, 2.0)

func _can_draft_tile(tile : Vector2i) -> bool:
	return tile in game_map.get_draftable_tiles()

func _move_current_tile(direction : Vector2i) -> void:
	var destination_tile := game_map.current_tile + direction
	if _can_draft_tile(destination_tile):
		_open_tile_drafting(direction)
		drafting_tile = destination_tile
		return
	if not _can_move_to_tile(destination_tile): return
	game_map.current_tile = destination_tile
	steps_taken += 1
	_refresh_current_tile()
	_refresh_steps_taken()
	_refresh_travel_options()
	_refresh_inventory_options()

func _connect_travel_button_signals() -> void:
	for travel_vector in travel_button_map:
		var travel_button := travel_button_map[travel_vector]
		var callable := _move_current_tile.bind(travel_vector)
		if travel_button.pressed.is_connected(callable): continue
		travel_button.pressed.connect(callable)

func _ready() -> void:
	_refresh_current_tile()
	_refresh_steps_taken()
	await get_tree().create_timer(0.1, false).timeout
	_refresh_travel_options()
	_connect_travel_button_signals()
	_refresh_inventory_options()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		_move_current_tile(Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		_move_current_tile(Vector2i.DOWN)
	elif event.is_action_pressed("move_left"):
		_move_current_tile(Vector2i.LEFT)
	elif event.is_action_pressed("move_right"	):
		_move_current_tile(Vector2i.RIGHT)

func _on_drafting_view_room_option_drafted(room_data : RoomData) -> void:
	_close_tile_drafting()
	game_map.draft_room(room_data)

func _on_pickup_key_button_pressed() -> void:
	var item := game_map.pickup(Constants.KEY)
	if item:
		pc_data.inventory.add(item)
	_refresh_inventory_options()

func _on_pickup_gem_button_pressed() -> void:
	var item := game_map.pickup(Constants.GEM)
	if item:
		pc_data.inventory.add(item)
	_refresh_inventory_options()
