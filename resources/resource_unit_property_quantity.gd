class_name ResourceUnitPropertyQuantity 
extends ResourceUnitProperty

const KEY_NAME : StringName = &"quantity"

enum NumericalUnitSetting{ CONTINUOUS, DISCRETE }
@export var numerical_unit : NumericalUnitSetting = NumericalUnitSetting.CONTINUOUS
@export var quantity: float = 1.0

func _init() -> void:
	key = KEY_NAME
