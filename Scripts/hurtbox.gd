extends Area2D
class_name Hurtbox

@export var entity: Node2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		if entity:
			entity.take_damage(area.damage)
