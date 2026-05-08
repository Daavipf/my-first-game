extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

@export_enum("apple", "banana", "cherry", "kiwi", "melon", "orange", "pineapple", "strawberry") var item_type: String = "apple"
@export var points_value = 10

func _ready():
	body_entered.connect(_on_body_entered)
	animated_sprite.play(item_type + "_idle")

func _on_body_entered(body):
	if body.name == "Player":
		set_deferred("monitoring", false)
		var controller = get_tree().get_first_node_in_group("controller")
		if controller:
			controller.add_score(points_value)
			
		animated_sprite.play("collected")
		await animated_sprite.animation_finished
		queue_free()
