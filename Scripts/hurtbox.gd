extends Area2D
class_name Hurtbox

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		if health_component:
			health_component.take_damage(area.damage)
