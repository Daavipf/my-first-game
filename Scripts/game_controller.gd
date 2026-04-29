extends Node2D

@export var gravity = 1500.0
@export var player: Node2D
@export var hud: CanvasLayer
@export var height_ratio = 120

var score = 0

func _ready():
	if player.health_component != null:
		# Conectando o sinal de vida que você já tem no Player
		player.health_component.health_changed.connect(_on_player_health_changed)
		hud.update_health(player.health_component.current_health, player.health_component.max_health)
	
	# Inicializa a UI
	hud.update_score(score)

func _physics_process(delta: float) -> void:
	var height = (position.y - player.position.y) / height_ratio
	hud.update_height(height)

func add_score(amount: int):
	score += amount
	hud.update_score(score)

func _on_player_health_changed(current: float, _max: float):
	hud.update_health(current, _max)
