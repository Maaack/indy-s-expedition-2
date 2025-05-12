class_name BaseLevel
extends Node2D

signal level_completed
signal player_dashed(cooldown : float)
signal player_health_changed(health : float, max_health : float)
signal player_interactable_access_changed(has_access : bool)
signal player_died
signal player_teleported(player_node, new_position)
signal monster_mode_activation_changed(activated : bool)

enum ChildSceneType{
	NONE = -1,
	PROJECTILE,
	COLLECTIBLE,
	CHARACTER,
	INTERACTABLE,
	SPAWNER,
	RUBBISH,
}

@onready var character_container = $CharacterContainer
@onready var projectile_container = $ProjectileContainer
@onready var rubbish_container = $RubbishContainer
@onready var collectible_container = $CollectibleContainer
@onready var spawner_container = $SpawnerContainer
@onready var text_container = $TextContainer
var pc_node : CharacterBody2D
var pc_monster_node : CharacterBody2D
var enemy_host_node : CharacterBody2D
var floating_text_scene = preload("res://scenes/floating_text/floating_text_2d.tscn")

func add_player(player : PlayerCharacter2D):
	pc_node = player
	pc_node.dash.connect(_on_player_character_dash)
	pc_node.interactable_access_changed.connect(_on_player_character_interactable_access_changed)
	pc_node.new_weapon.connect(_on_player_character_new_weapon)
	pc_node.health_changed.connect(_on_player_character_health_changed)
	pc_node.died.connect(_on_player_character_died)
	pc_node.ready.connect(_on_player_ready)

	pc_node.position = $PlayerSpawnPoint.position
	$CharacterContainer.add_child(pc_node)

func remove_player():
	$CharacterContainer.remove_child(pc_node)
	pc_node = null

func _on_player_ready():
	set_pc_direction(Vector2(1,0))

func spawn_projectile(projectile_scene : PackedScene, projectile_position : Vector2, projectile_velocity : Vector2, team : Constants.Teams):
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.position = projectile_position
	projectile_instance.velocity = projectile_velocity
	projectile_instance.team = team
	if projectile_instance.has_signal("spawned_projectile"):
		projectile_instance.spawned_projectile.connect(spawn_projectile)
	if projectile_instance.has_signal("spawned_effect"):
		projectile_instance.spawned_effect.connect(spawn_effect)
	projectile_container.call_deferred("add_child", projectile_instance)
	return projectile_instance

func spawn_effect(effect_scene : PackedScene, effect_position : Vector2, effect_rotation : float = 0):
	var effect_scene_instance = effect_scene.instantiate()
	effect_scene_instance.position = effect_position
	effect_scene_instance.rotation = effect_rotation
	projectile_container.call_deferred("add_child", effect_scene_instance)

func spawn_floating_text(text_position : Vector2, text_value : String):
	var floating_text_instance = floating_text_scene.instantiate()
	floating_text_instance.position = text_position
	floating_text_instance.text = text_value
	text_container.call_deferred("add_child", floating_text_instance)
	return floating_text_instance

func _on_player_character_dash(cooldown):
	emit_signal("player_dashed", cooldown)

func _on_player_character_health_changed(health : float, max_health : float):
	emit_signal("player_health_changed", health, max_health)

func _on_player_character_died():
	emit_signal("player_died")

func _on_player_character_interactable_access_changed(has_access_flag : bool):
	emit_signal("player_interactable_access_changed", has_access_flag)

func _on_player_monster_jumped(cooldown):
	emit_signal("player_dashed", cooldown)

func _on_player_teleported(player_node : Node2D, new_position : Vector2):
	emit_signal("player_teleported", player_node, new_position)

func _on_body_teleported(node_2d : Node2D, new_position : Vector2):
	if node_2d.is_in_group(Constants.PLAYER_GROUP):
		_on_player_teleported(node_2d, new_position)

func set_pc_shooting(shooting_flag : bool = true):
	pc_node.is_shooting = shooting_flag

func set_pc_direction(facing_direction : Vector2):
	pc_node.face_direction(facing_direction)

func set_pc_cycle_next():
	pc_node.cycle_next()

func set_pc_cycle_prev():
	pc_node.cycle_prev()

func set_pc_dashing(dashing_flag : bool):
	pc_node.is_dashing = dashing_flag

func set_pc_outfit(sprite_stack : Texture2D):
	if pc_node == null:
		return
	#pc_node.set_body_sprite(sprite_stack)

func set_pc_monster_attacking(attacking_flag : bool = true):
	pc_monster_node.is_attacking = attacking_flag

func set_pc_monster_jumping(jumping_flag : bool = true):
	pc_monster_node.is_jumping = jumping_flag

func _on_enemy_damage_taken(enemy_position : Vector2, damage : float):
	var floating_text_node = spawn_floating_text(enemy_position, str(damage))
	var scale_factor = 0.5 + (max(1, damage) / 80)
	floating_text_node.scale = Vector2(scale_factor, scale_factor)

func _on_enemy_died(enemy_node):
	if not enemy_node.is_in_group(Constants.ENEMY_GROUP):
		return
	enemy_node.call_deferred("reparent", rubbish_container)

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
	if enemy_node.has_signal("damage_taken"):
		enemy_node.damage_taken.connect(_on_enemy_damage_taken)
	if enemy_node.has_signal("died"):
		enemy_node.died.connect(_on_enemy_died.bind(enemy_node))
	if enemy_node.has_signal("pathing"):
		enemy_node.pathing.connect(_on_enemy_pathing.bind(enemy_node))

func _on_spawner_enemy_spawned(node, spawner_node):
	_attach_enemy_signals(node)
	character_container.call_deferred("add_child", node)
	character_container.remove_child(spawner_node)
	rubbish_container.call_deferred("add_child", spawner_node)

func _connect_all_enemy_signals():
	for child in character_container.get_children():
		_attach_enemy_signals(child)

func _attach_spawners_signals():
	for child in $SpawnerContainer.get_children():
		child.enemy_spawned.connect(_on_spawner_enemy_spawned.bind(child))

func _ready():
	print("this was erady")
	_connect_all_enemy_signals()
	_attach_spawners_signals()
	
func _on_player_character_new_weapon(weapon_name):
	emit_signal("player_new_weapon", weapon_name)

func instantiate_scene_type(packed_scene : PackedScene, scene_type : ChildSceneType = ChildSceneType.PROJECTILE, scene_data : Dictionary = {}) -> void:
	match(scene_type):
		ChildSceneType.PROJECTILE:
			if not scene_data.has(&"position"):
				push_warning("projectile data must contain position")
				return
			if not scene_data.has(&"velocity"):
				push_warning("projectile data must contain velocity")
				return
			if not scene_data.has(&"team"):
				push_warning("projectile data must contain team")
				return
			spawn_projectile(packed_scene, scene_data.position, scene_data.velocity, scene_data.team)
