class_name BossSpawnController
extends Node

signal boss_spawned(new_boss)
signal boss_list_emptied

@export var boss_container : Node2D
@export var boss_list : Array[PackedScene] :
	set(value):
		boss_list = value
		if boss_list is Array:
			_boss_list = boss_list.duplicate()
@export var current_boss : BossBase :
	set(value):
		current_boss = value
		if is_instance_valid(current_boss) and current_boss.has_signal(&"died"):
			current_boss.died.connect(_on_boss_died)
@export var spawn_marker : Node2D

var _boss_list : Array[PackedScene]

func spawn_next_boss():
	if _boss_list.size() < 1:
		boss_list_emptied.emit()
		return
	var next_boss_scene : PackedScene = _boss_list.pop_front()
	if is_instance_valid(current_boss):
		current_boss.queue_free()
	current_boss = next_boss_scene.instantiate()
	if is_instance_valid(spawn_marker):
		current_boss.position = spawn_marker.position
	boss_container.call_deferred("add_child", current_boss)
	boss_spawned.emit(current_boss)

func _on_boss_died():
	if is_instance_valid(current_boss):
		if current_boss is BossBase:
			if current_boss.died.is_connected(_on_boss_died):
				current_boss.died.disconnect(_on_boss_died)
	$NextBossDelayTimer.start()

func _on_next_boss_delay_timer_timeout():
	spawn_next_boss()
