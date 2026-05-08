extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var health_component = $HealthComponent
@onready var stomp_hitbox = $Hitbox

@export_category("Movement")
@export var speed = 300.0
@export var jump_speed = -400.0
@export var jump_cut_multiplier = 0.5
@export var bounce_force = -350

@export_category("Advanced Jump")
@export var jump_buffer_time = 0.05
@export var coyote_time = 0.1
@export var wall_jump_push = 400.0
@export var wall_jump_lockout = 0.08
@export var wall_slide_speed = 120

@export_category("Combat & Feedback")
@export var fall_damage_threshold: float = 700.0
@export var fall_damage_multiplier: float = 0.05
@export var invincibility_duration: float = 1.2
@export var knockback_force: Vector2 = Vector2(300, -250)
@export var stun_duration: float = 0.3

var _coyote_timer = 0.0
var _walljump_lock_movement_timer = 0.0 
var _jump_buffer_timer = 0.0
var _pre_impact_velocity_y: float = 0.0

var was_on_floor: bool = true
var is_invincible: bool = false
var is_stunned: bool = false
var spawn_point: Vector2
var is_dead: bool = false

func _ready() -> void:
	spawn_point = global_position
	health_component.died.connect(on_died)
	stomp_hitbox.area_entered.connect(_on_stomp_hitbox_entered)

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	apply_gravity(delta)
	handle_wall_slide()
	update_timers(delta)
	handle_jump()
	handle_horizontal_movement(delta)
	
	_pre_impact_velocity_y = velocity.y
	move_and_slide()
	
	check_fall_damage()
	update_viuals()
	was_on_floor = is_on_floor()

func apply_gravity(delta: float):
	velocity.y += Global.gravity * delta

func handle_wall_slide():
	if is_on_wall() and Global.unlocked_abilites["wall_jump"]:
		velocity.y = wall_slide_speed

func update_timers(delta: float):
	if _walljump_lock_movement_timer > 0: _walljump_lock_movement_timer -= delta
	if _jump_buffer_timer > 0: _jump_buffer_timer -= delta
	
	if is_on_floor():
		_coyote_timer = coyote_time
	elif _coyote_timer > 0:
			_coyote_timer -= delta

func handle_jump():
	if Input.is_action_just_pressed("ui_up"):
		_jump_buffer_timer = jump_buffer_time
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
	
	if _jump_buffer_timer <= 0: return
	
	if _coyote_timer > 0:
		execute_jump()
	elif is_on_wall() and Global.unlocked_abilites["wall_jump"]:
		execute_wall_jump()

func execute_jump():
	velocity.y = jump_speed
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0

func execute_wall_jump():
	velocity.y = jump_speed
	velocity.x = get_wall_normal().x * wall_jump_push
	_walljump_lock_movement_timer = wall_jump_lockout
	_jump_buffer_timer = 0.0

func handle_horizontal_movement(delta: float):
	var input_direction = Input.get_axis("ui_left", "ui_right")
	var can_move = not is_stunned and _walljump_lock_movement_timer <= 0
	
	if can_move:
		if input_direction != 0:
			velocity.x = input_direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)

func check_fall_damage():
	var just_landed = is_on_floor() and not was_on_floor
	if just_landed and _pre_impact_velocity_y >= fall_damage_threshold:
			var excess_speed = _pre_impact_velocity_y - fall_damage_threshold
			var fall_damage = excess_speed * fall_damage_multiplier
			take_damage(max(round(fall_damage), 1.0))

func update_viuals():
	if not is_stunned:
		_animated_sprite.get_facing(velocity.x)
	_animated_sprite.update_animation(self)

func take_damage(amount: float, damage_source_x: float = global_position.x):
	if is_invincible: return
	
	health_component.take_damage(amount)
	apply_knockback(damage_source_x)
	trigger_invincibility()

func apply_knockback(damage_source_x: float):
	is_stunned = true
	velocity.y = knockback_force.y
	var push_direction = -1 if damage_source_x > global_position.x else 1
	if damage_source_x == global_position.x:
		push_direction = 1 if _animated_sprite.flip_h else -1
	velocity.x = knockback_force.x * push_direction
	get_tree().create_timer(stun_duration).timeout.connect(func(): is_stunned = false)

func trigger_invincibility():
	is_invincible = true
	_animated_sprite.flash(invincibility_duration)
	get_tree().create_timer(invincibility_duration).timeout.connect(func(): is_invincible = false)

func on_died():
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO
	_animated_sprite.play("die")
	
	collision_layer = 0
	collision_mask = 0
	await _animated_sprite.animation_finished
	get_tree().reload_current_scene()

func _on_stomp_hitbox_entered(area: Area2D) -> void:
	if area is Hurtbox:
		velocity.y = bounce_force
