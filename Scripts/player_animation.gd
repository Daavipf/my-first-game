extends AnimatedSprite2D

func get_facing(velocity: float):
	if velocity != 0:
		flip_h = velocity < 0

func update_animation(player: CharacterBody2D):
	if player.has_method("is_dead") and player.is_dead: return
	
	if player.is_on_wall() and not player.is_on_floor():
		if Global.unlocked_abilities["wall_jump"]:
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

func flash(duration: float):
	var tween = create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.3, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	await get_tree().create_timer(duration).timeout
	
	tween.kill()
	modulate.a = 1.0
