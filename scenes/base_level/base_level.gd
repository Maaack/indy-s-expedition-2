class_name BaseLevel
extends Node2D

signal level_lost
signal player_dashed(cooldown : float)
signal player_health_changed(health : float, max_health : float)
signal player_interactable_access_changed(has_access : bool)
signal player_teleported(player_node, new_position)
signal monster_mode_activation_changed(activated : bool)

@onready var room_container = $RoomContainer
@onready var character_container = $CharacterContainer
@onready var text_container = $TextContainer
@onready var tutorial_manager = %TutorialManager
@onready var stealing_tutorial_manager = $StealingTutorialManager
@onready var drafting_tutorial_manager = $DraftingTutorialManager
@onready var game_map : GameMap = $GameMap
@onready var draftable_map : DraftableMap = $DraftableMap

@export var rooms_available : int = 0

var pc_node : CharacterBody2D
var pc_monster_node : CharacterBody2D
var enemy_host_node : CharacterBody2D
var floating_text_scene = preload("res://scenes/floating_text/floating_text_2d.tscn")

var level_state : LevelState

func spawn_floating_text(text_position : Vector2, text_value : String):
	var floating_text_instance = floating_text_scene.instantiate()
	floating_text_instance.position = text_position
	floating_text_instance.text = text_value
	text_container.call_deferred("add_child", floating_text_instance)
	return floating_text_instance

func _on_enemy_pathing(move_target, enemy_node):
	for group in enemy_node.ignore_obstacle_groups:
		$AStarGridServer.set_group_disabled(group, false)
	
	var path_points = $AStarGridServer.get_world_path_avoiding_points(enemy_node.position, move_target)
	
	for group in enemy_node.ignore_obstacle_groups:
		$AStarGridServer.set_group_disabled(group, true)

	if path_points.size() < 2:
		return
	enemy_node.next_navigation_points = path_points.slice(1)

func _attach_enemy_signals(enemy_node : Node2D):
	if not enemy_node.is_in_group(Constants.ENEMY_GROUP):
		return
	if enemy_node.has_signal("pathing"):
		enemy_node.pathing.connect(_on_enemy_pathing.bind(enemy_node))

func _on_spawner_enemy_spawned(node, spawner_node):
	_attach_enemy_signals(node)
	character_container.call_deferred("add_child", node)
	character_container.remove_child(spawner_node)

func _connect_all_enemy_signals():
	for child in character_container.get_children():
		_attach_enemy_signals(child)

func _on_treasure_picked_up(add_score : int, treasure_position : Vector2) -> void:
	if level_state.artifacts_stolen == 0 and not level_state.stealing_tutorial_read:
		stealing_tutorial_manager.open_tutorials()
		level_state.stealing_tutorial_read = true
	level_state.artifacts_stolen += 1
	level_state.culture_scored += add_score
	GlobalState.save()
	spawn_floating_text(treasure_position, "+%d" % add_score)

func _on_treasure_added(add_score : int) -> void:
	level_state.artifacts_available += 1
	level_state.culture_available += add_score
	GlobalState.save()

func _on_player_drafting_room(current_tile : Vector2i, direction : Vector2i):
	if level_state.rooms_drafted == 0 and not level_state.drafting_tutorial_read:
		drafting_tutorial_manager.open_tutorials()
		level_state.drafting_tutorial_read = true
		GlobalState.save()
	ProjectEvents.level_drafting_room.emit(current_tile, direction, draftable_map)

func open_tutorials() -> void:
	tutorial_manager.open_tutorials()
	level_state.tutorial_read = true
	GlobalState.save()

func _on_player_died() -> void:
	level_lost.emit()

func _ready():
	_connect_all_enemy_signals()
	ProjectEvents.treasure_picked_up.connect(_on_treasure_picked_up)
	ProjectEvents.queue_spawn.connect(instantiate_scene_type)
	ProjectEvents.player_drafting_room.connect(_on_player_drafting_room)
	ProjectEvents.room_drafted.connect(add_room)
	ProjectEvents.player_died.connect(_on_player_died)
	ProjectEvents.treasure_added.connect(_on_treasure_added)
	level_state = GameState.get_level_state(scene_file_path)
	level_state.rooms_available = rooms_available
	level_state.reset_level_score()
	if not level_state.tutorial_read:
		open_tutorials()

func _on_player_character_new_weapon(weapon_name):
	emit_signal("player_new_weapon", weapon_name)

func instantiate_scene_type(packed_scene : PackedScene, scene_data : Dictionary = {}) -> void:
	var scene_instance = packed_scene.instantiate()
	for key in scene_data:
		var value = scene_data[key]
		if scene_instance.has_method("set_%s" % key):
			scene_instance.call("set_%s" % key, value)
	character_container.call_deferred("add_child", scene_instance)

func add_room(room_data : RoomData) -> void:
	var scene_instance = room_data.room_scene.instantiate()
	if scene_instance is Room2D:
		room_container.call_deferred("add_child", scene_instance)
		scene_instance.position = Constants.ROOM_SIZE * room_data.map_coord
		await scene_instance.ready
		scene_instance.room_data = room_data
		for object in scene_instance.character_container.get_children():
			object.reparent(character_container)
	if level_state.artifacts_stolen > 0:
		ProjectEvents.player_aggro.emit()
	level_state.rooms_drafted += 1
	GlobalState.save()
