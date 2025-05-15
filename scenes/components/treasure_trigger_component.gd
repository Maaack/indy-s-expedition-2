extends ComponentBase

@export var target_components : Array[ComponentBase]
@export var target_components_2d : Array[ComponentBase2D]



func _on_treasure_picked_up(_score : float, _treasure_position : Vector2):
	for component in target_components:
		component.enabled = true
	for component in target_components_2d:
		component.enabled = true

func _ready():
	ProjectEvents.treasure_picked_up.connect(_on_treasure_picked_up)
