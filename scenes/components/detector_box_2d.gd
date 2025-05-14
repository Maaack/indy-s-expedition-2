class_name DetectorBox2D
extends Area2D

signal object_detected(node : Node2D)

const AREA_FLAG = 1
const BODY_FLAG = 2
@export_flags("Area", "Body") var _type : int = AREA_FLAG

func _on_area_entered(area):
	object_detected.emit(area)

func _on_body_entered(body):
	object_detected.emit(body)

func _ready():
	if _type & AREA_FLAG:
		connect("area_entered", _on_area_entered)
	if _type & BODY_FLAG:
		connect("body_entered", _on_body_entered)
		
