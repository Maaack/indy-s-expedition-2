class_name HealthTextureRect
extends TextureRect

enum State{
	EMPTY,
	HALF,
	FULL
}

@export var state : State = State.EMPTY :
	set(value):
		state = value
		if texture is AtlasTexture:
			match(state):
				State.EMPTY:
					texture.region.position.x = 320.0
				State.HALF:
					texture.region.position.x = 304.0
				State.FULL:
					texture.region.position.x = 288.0
