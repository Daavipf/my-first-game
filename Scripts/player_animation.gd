extends AnimatedSprite2D

func get_facing(velocity: float):
	if velocity != 0:
		flip_h = velocity < 0

func update_animation(player: CharacterBody2D):
	if player.is_on_wall() and not player.is_on_floor():
		if Global.unlocked_abilites["wall_jump"]:
			play("wall_slide")
	elif not player.is_on_floor():
		if player.velocity.y > 0:
			play("fall")
		else:
			play("jump")
	else:
		if player.velocity.x != 0:
			play("run")
		else:
			play("idle")
