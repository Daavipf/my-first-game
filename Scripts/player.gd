extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var health_component = $HealthComponent
@onready var stomp_hitbox = $Hitbox

@export var speed = 300.0
@export var jump_speed = -400.0
@export var jump_cut_multiplier = 0.5
@export var jump_buffer_time = 0.05
@export var coyote_time = 0.1
@export var bounce_force = -350
@export var wall_jump_push = 400.0
@export var wall_jump_lockout = 0.08
@export var wall_slide_speed = 120

var _lockout_timer = 0.0 
var _jump_buffer_timer = 0.0
var _coyote_timer = 0.0

func _ready() -> void:
	health_component.died.connect(on_died)
	health_component.health_changed.connect(health_changed)
	stomp_hitbox.area_entered.connect(_on_stomp_hitbox_entered)

func _physics_process(delta: float) -> void:
	velocity.y += Global.gravity * delta
	
	if is_on_wall() and Global.unlocked_abilites["wall_jump"]:
		velocity.y = wall_slide_speed
	
	if _lockout_timer > 0:
		_lockout_timer -= delta
	
	if _jump_buffer_timer > 0:
		_jump_buffer_timer -= delta
	
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		if _coyote_timer > 0:
			_coyote_timer -= delta
	
	if Input.is_action_just_pressed("ui_up"):
		_jump_buffer_timer = jump_buffer_time
		
	if _jump_buffer_timer > 0:
		if _coyote_timer > 0:
			velocity.y = jump_speed
			_jump_buffer_timer = 0.0
			_coyote_timer = 0.0
		elif is_on_wall() and Global.unlocked_abilites["wall_jump"]:
			velocity.y = jump_speed
			velocity.x = get_wall_normal().x * wall_jump_push
			_lockout_timer = wall_jump_lockout
			_jump_buffer_timer = 0.0
	
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
	
	var input_direction = Input.get_axis("ui_left", "ui_right")
	
	if _lockout_timer <= 0:
		if input_direction != 0:
			velocity.x = input_direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
	
	_animated_sprite.get_facing(velocity.x)
	_animated_sprite.update_animation(self)
	
	move_and_slide()

func on_died():
	print("Você morreu!")

func take_damage(amount: float):
	health_component.take_damage(amount)

func health_changed(current: float, max: float):
	print("Vida atual: %.0f / %.0f" % [current, max])

func _on_stomp_hitbox_entered(area: Area2D) -> void:
	if area is Hurtbox:
		velocity.y = bounce_force
