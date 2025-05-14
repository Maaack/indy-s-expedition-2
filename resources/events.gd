class_name Events
extends Node

signal player_exiting
signal player_health_changed(health : float, delta : float)
signal player_max_health_changed(max_health : float, delta : float)
signal treasure_picked_up(score : int, position : Vector2)
