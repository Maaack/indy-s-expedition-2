extends Object
class_name Constants

enum Teams{ PLAYER, ENEMY }
enum Layers{ PLAYER = 3, LOW_ENTITIES = 4, HIGH_ENTITIES = 5, PLAYER_HIT = 7 }

enum Direction{
	NORTH,
	SOUTH,
	EAST,
	WEST
}

const PLAYER_GROUP = "player"
const ENEMY_GROUP = "enemies"
const DESTRUCTIBLE_GROUP = "destructible"
const DOORS_GROUP = "doors"
const HEART := &"heart"
const TREASURE := &"treasure"

const ROOM_SIZE : Vector2i = Vector2i(768, 768)

static func get_direction_vector(direction : Direction) -> Vector2i:
	var direction_vector := Vector2.UP
	match direction:
		Constants.Direction.SOUTH:
			direction_vector = Vector2.DOWN
		Constants.Direction.EAST:
			direction_vector = Vector2.LEFT
		Constants.Direction.WEST:
			direction_vector = Vector2.RIGHT
	return direction_vector
