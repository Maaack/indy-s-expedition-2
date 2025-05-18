extends ComponentBase

@export var target_components : Array[ComponentBase]
@export var target_components_2d : Array[ComponentBase2D]


func enable_components() -> void:
	for component in target_components:
		component.enabled = true
	for component in target_components_2d:
		component.enabled = true

func _on_treasure_picked_up(_score : float, _treasure_position : Vector2) -> void:
	enable_components()

func _on_heart_picked_up(_health : float, _heart_position : Vector2) -> void:
	enable_components()

func _ready():
	ProjectEvents.treasure_picked_up.connect(_on_treasure_picked_up)
	# ProjectEvents.heart_picked_up.connect(_on_heart_picked_up)
	ProjectEvents.player_aggro.connect(enable_components)
