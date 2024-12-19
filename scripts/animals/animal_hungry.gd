extends State
class_name  AnimalHungry

@export var animal:CharacterBody2D
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"

	
func enter():
	if animal:
		player.play("hungry")
