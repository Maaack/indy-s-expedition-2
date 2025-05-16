extends Control

@onready var score_ui : ScoreUI = %ScoreUI
@onready var health_ui : HealthUI = %HealthUI
@onready var drafting_view : DraftingView = $DraftingView
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var game_map_sub_viewport : Viewport = %GameMapSubViewport
@onready var level_loader : LevelListLoader = $LevelLoader


@export var exit_confirmation_screen : PackedScene 
var current_level : BaseLevel
var current_game_map : GameMap
var current_tile : Vector2i

var score : int = 0 :
	set(value):
		score = value
		if is_inside_tree():
			score_ui.score = score

var health : float = 0 :
	set(value):
		health = value
		if is_inside_tree():
			health_ui.health = health

func _on_player_exiting():
	var instance := exit_confirmation_screen.instantiate()
	add_child(instance)
	if instance.has_signal(&"exit_confirmed"):
		instance.connect(&"exit_confirmed", func() -> void: $LevelListManager._on_level_won())

func _on_treasure_picked_up(add_score : int, _treasure_position : Vector2) -> void:
	score += add_score

func _on_player_health_changed(new_health : float, delta : float) -> void:
	health = new_health

func _on_level_drafting_room(current_tile : Vector2i, direction : Vector2i, game_map : GameMap, draftable_map : DraftableMap) -> void:
	game_map.current_tile = current_tile
	var drafting_tile := current_tile + direction
	get_tree().paused = true
	drafting_view.draft(current_tile, direction, draftable_map)
	animation_player.play("OPEN_DRAFTING", -1, 2.0)
	await animation_player.animation_finished
	drafting_view.enable()

func _on_drafting_view_room_option_drafted(room_data):
	animation_player.play("CLOSE_DRAFTING", -1, 2.0)
	get_tree().paused = false
	ProjectEvents.room_drafted.emit(room_data)

func _on_player_moved(player_global_position : Vector2):
	if not current_game_map: return
	current_game_map.current_tile = round(player_global_position / Vector2(Constants.ROOM_SIZE))

func _ready():
	ProjectEvents.player_exiting.connect(_on_player_exiting)
	ProjectEvents.treasure_picked_up.connect(_on_treasure_picked_up)
	ProjectEvents.player_health_changed.connect(_on_player_health_changed)
	ProjectEvents.level_drafting_room.connect(_on_level_drafting_room)
	ProjectEvents.player_moved.connect(_on_player_moved)

func _on_level_loader_level_loaded():
	if current_game_map:
		current_game_map.queue_free()
		current_game_map = null
	current_level = level_loader.current_level
	await current_level.ready
	current_game_map = current_level.game_map
	current_game_map.reparent(game_map_sub_viewport)
	current_game_map.show()
	
