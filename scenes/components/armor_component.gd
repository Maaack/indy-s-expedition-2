class_name ArmorComponent2D
extends Area2D

@export var _deflect_audio_player_2d : AudioStreamPlayer2D

func _on_area_entered(area):
	if area is Hitbox2D:
		pass
	if area is AreaProjectile:
		area._on_projectile_expired()
		if _deflect_audio_player_2d != null:
			_deflect_audio_player_2d.play()

func _ready():
	connect("area_entered", _on_area_entered)
