class_name ResourceContainer
extends ResourceUnit

@export var contents : Array[ResourceUnit] :
	set = set_contents

var _quantity_property_key: StringName = ResourceUnitPropertyQuantity.KEY_NAME
var total_quantity : ResourceUnitPropertyQuantity

func _to_string() -> String:
	var to_string := "%s: [" % name
	for content in contents:
		to_string += str(content) + ","
	return to_string + "]"

func set_contents(value:Array) -> void:
	if value == null:
		return
	contents = _return_valid_array(value)
	update_quantities()

func _return_valid_array(array:Array) -> Array:
	var final_array : Array = []
	for unit : Variant in array:
		if unit is ResourceUnit:
			final_array.append(unit.duplicate())
	return final_array

func _reset_quantities() -> void:
	if total_quantity == null:
		total_quantity = ResourceUnitPropertyQuantity.new()
	total_quantity.quantity = 0

func update_quantities() -> void:
	_reset_quantities()
	for content in contents:
		if content is ResourceUnit:
			add_to_total(content)

func _get_item_quantity_property(item:ResourceUnit) -> ResourceUnitPropertyQuantity:
	if item.has_property(_quantity_property_key):
		return item.get_property(_quantity_property_key)
	return null

func _get_item_quantity(item:ResourceUnit) -> float:
	if item == null: return 0.0
	if item.has_property(_quantity_property_key):
		var _quantity := item.get_property(_quantity_property_key)
		if _quantity is ResourceUnitPropertyQuantity:
			return _quantity.quantity
	return 1.0

func add_to_total(item:ResourceUnit) -> void:
	total_quantity.quantity += _get_item_quantity(item)

func add_items(values : Variant) -> Array[ResourceUnit]:
	if values == null:
		return []
	if not values is Array:
		values = [values]
	for value : Variant in values:
		add(value)
	return contents

func _add_quantity_to_item(item:ResourceUnit, quantity:float = 1.0) -> void:
	if item.has_property(_quantity_property_key):
		var _quantity := item.get_property(_quantity_property_key)
		if _quantity is ResourceUnitPropertyQuantity:
			_quantity.quantity += quantity
			return
	var _quantity := ResourceUnitPropertyQuantity.new()
	_quantity.quantity += quantity
	item.set_property(_quantity)

func add(item:ResourceUnit) -> Array[ResourceUnit]:
	if item == null:
		return []
	var current_unit := find(item.name)
	if current_unit is ResourceUnit:
		var item_quantity := _get_item_quantity(item)
		_add_quantity_to_item(current_unit, item_quantity)
	else:
		var item_copy := item.duplicate()
		contents.append(item_copy)
	update_quantities()
	return contents

func remove_items(values : Variant) -> void:
	if values == null:
		return
	if not values is Array:
		values = [values]
	for value : Variant in values:
		remove(value)

func has(unit_name:String) -> bool:
	return find(unit_name) != null

func has_quantity(unit_name:String, target_quantity:float = 1) -> bool:
	var content := find(unit_name)
	var item_quantity := _get_item_quantity(content)
	return item_quantity >= target_quantity

func get_item_quantity(unit_name:String) -> float:
	var item_quantity : float = 0
	for item in find_all(unit_name):
		item_quantity += _get_item_quantity(item)
	return item_quantity

func remove(value:ResourceUnit, quantity: float = 1) -> void:
	if value is ResourceUnit:
		var content := find(value.name)
		var _quantity := _get_item_quantity_property(content)
		if _quantity != null:
			_quantity.quantity -= quantity
			if _quantity.quantity == 0:
				contents.erase(content)
		else:
			contents.erase(content)
	update_quantities()

func find(name_query:String) -> ResourceUnit:
	for content in contents:
		if content is ResourceUnit and content.name == name_query:
			return content
	return null

func find_all(name_query:String) -> Array[ResourceUnit]:
	var all_matched : Array[ResourceUnit]
	for content in contents:
		if content is ResourceUnit and content.name == name_query:
			all_matched.append(content)
	return all_matched

func clear() -> void:
	contents.clear()
	_reset_quantities()
