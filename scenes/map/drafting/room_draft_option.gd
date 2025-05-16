@tool
class_name RoomDraftOption
extends Button

@export var room_data : RoomData :
	set(value):
		room_data = value
		if room_data != null:
			set_room_rotation(room_data.rotation)
			set_atlas_coord(room_data.atlas_coord)
			set_contents(room_data)
		else:
			set_atlas_coord(Vector2i(0, 0))

@onready var sprite_node : Sprite2D = %Sprite2D
@onready var heart_sprite_2d : Sprite2D = %HeartSprite2D
@onready var treasure_sprite_2d : Sprite2D = %TreasureSprite2D

func set_room_rotation(rotation_delta : float) -> void:
	var tween := create_tween()
	tween.tween_property(sprite_node, ^"rotation", rotation_delta, 0.25)

func set_atlas_coord(new_atlas_coord : Vector2i) -> void:
	var texture := sprite_node.texture
	var texture_size : Vector2i = texture.get_size()
	if texture is AtlasTexture:
		texture.region.position = Vector2(new_atlas_coord * texture_size)

func set_contents(room_data : RoomData) -> void:
	if room_data.inventory.has(Constants.HEART):
		heart_sprite_2d.show()
	if room_data.inventory.has(Constants.TREASURE):
		treasure_sprite_2d.show()

func get_atlas_coord() -> Vector2i:
	var texture := sprite_node.texture
	var texture_size := texture.get_size()
	if texture is AtlasTexture:
		return Vector2i(texture.region.position / texture_size)
	return Vector2i.ZERO
