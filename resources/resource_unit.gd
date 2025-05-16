class_name ResourceUnit
extends Resource

@export var name : StringName
@export var icon : Texture

@export var initial_properties : Array[ResourceUnitProperty]

var properties : Dictionary[StringName, ResourceUnitProperty]

func _to_string() -> String:
	return "%s (%d)" % [name, get_instance_id()]

func copy_from(value:ResourceUnit) -> void:
	if value == null:
		return
	name = value.name
	icon = value.icon
	properties = value.properties.duplicate()

func has_property(property_key: StringName) -> bool:
	return properties.has(property_key)

func set_property(property: ResourceUnitProperty) -> void:
	properties[property.key] = property

func get_property(property_key: StringName) -> ResourceUnitProperty:
	if not property_key in properties: return
	return properties[property_key]

func _ready() -> void:
	for property in initial_properties:
		set_property(property)
