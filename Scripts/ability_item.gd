extends Area2D

@export_enum("wall_jump", "double_jump", "dash") var ability_name: String = "wall_jump"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.unlock_ability(ability_name)
		queue_free()
