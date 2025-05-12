class_name AttackDelayComponent
extends ComponentBase

@export var attack_component : AttackComponent2D
@export var attack_animation_component : AttackAnimationComponent

func _call_attack_on_component():
	if not attack_component and not attack_animation_component:
		push_warning("no attack component set")
		return
	if attack_component:
		attack_component.attack()
	if attack_animation_component:
		attack_animation_component.attack()

func _ready():
	connect("timeout", _call_attack_on_component)
