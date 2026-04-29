extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var animated_sprite = $AnimatedSprite2D

@export var speed = 300.0

var is_dead = false

func _ready() -> void:
	health_component.died.connect(on_died)
	health_component.health_changed.connect(health_changed)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	animated_sprite.play("idle")
	move_and_slide()

func on_died():
	is_dead = true
	animated_sprite.scale = Vector2(4,4)
	animated_sprite.play("die")
	
	await animated_sprite.animation_finished
	queue_free()

func take_damage(amount: float):
	health_component.take_damage(amount)

func health_changed(current: float, max: float):
	print("Vida atual do inimigo: %.0f / %.0f" % [current, max])
