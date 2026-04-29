extends Node
class_name HealthComponent

signal health_changed(current_health, max_health)
signal died

@export var max_health: float = 10
var current_health: float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0:
		return
		
	current_health -= amount
	current_health = max(current_health, 0) 
	
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		died.emit()

func heal(amount: float) -> void:
	if current_health <= 0:
		return
		
	current_health += amount
	current_health = min(current_health, max_health)
	
	health_changed.emit(current_health, max_health)
