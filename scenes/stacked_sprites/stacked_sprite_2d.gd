@tool
class_name StackedSprite2D
extends Sprite2D

@export var show_sprites : bool = false : set = set_show_sprites
@export var y_separation : float = 1.0
@export var y_offset : float = 0.0

@export_range(-180, 180, 0.01, "radians_as_degrees") var sprite_rotation : float = 0 : set = set_sprite_rotation
@export_range(-180, 180, 0.01, "radians_as_degrees") var sprite_rotation_offset : float = 0

func set_show_sprites(_show_sprites):
	show_sprites = _show_sprites
	if show_sprites:
		render_sprites()
	else:
		clear_sprites()

func _update_sprite_rotations():
	for sprite in get_children():
		if sprite is Sprite2D:
			sprite.rotation = sprite_rotation + sprite_rotation_offset

func set_sprite_rotation(value):
	sprite_rotation = value
	_update_sprite_rotations()

func clear_sprites():
	for sprite in get_children():
		sprite.queue_free()

func _ready():
	render_sprites()

func render_sprites():
	clear_sprites()
	for i in range(0, hframes):
		var next_sprite = Sprite2D.new()
		next_sprite.texture = texture
		next_sprite.hframes = hframes
		next_sprite.frame = i
		next_sprite.position.y = (-i * y_separation) + y_offset
		add_child(next_sprite)

func _on_texture_changed():
	render_sprites()
	set_sprite_rotation(sprite_rotation)
