extends CanvasLayer

@onready var score_label = $Control/MarginContainer/VBoxContainer/ScoreLabel
@onready var height_label = $Control/MarginContainer/VBoxContainer/HeightLabel
@onready var hearts_container = $Control/MarginContainer/VBoxContainer/HBoxContainer

# Exportamos 3 texturas diferentes para receberem os recortes do spritesheet
@export var heart_full: Texture2D 
@export var heart_half: Texture2D 
@export var heart_empty: Texture2D 

func update_score(new_score: int):
	score_label.text = "Pontos: %d" % new_score

func update_height(new_height: float):
	height_label.text = "Altura: %.1f m" % abs(new_height)

# LÓGICA NOVA: Agora precisamos da vida atual e da vida máxima
func update_health(current_health: float, max_health: float):
	# Limpa os corações que já estavam na tela
	for child in hearts_container.get_children():
		child.queue_free()
	
	# O número total de ícones na tela é baseado na vida máxima
	var total_hearts = int(max_health)
	
	for i in range(total_hearts):
		var heart = TextureRect.new()
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Lógica para decidir qual sprite exibir:
		if current_health >= i + 1.0:
			# Se a vida atual for maior ou igual ao índice + 1, coração cheio
			# Ex: Se current_health é 3, os índices 0, 1 e 2 receberão cheio.
			heart.texture = heart_full
		elif current_health > i:
			# Se for maior que o índice mas não encheu um inteiro (ex: 2.5 > 2), meio coração
			heart.texture = heart_half
		else:
			# Caso contrário, coração vazio
			heart.texture = heart_empty
			
		hearts_container.add_child(heart)
