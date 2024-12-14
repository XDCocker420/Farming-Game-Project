extends State
class_name  AnimalEating

var move_direction:Vector2
var eat_time:float
@export var animal:CharacterBody2D
@export var move_speed := 50.0

func eat():
	pass

func enter():
	eat()
	
func update(delta:float):
	pass
		
func physics_update(_delta:float):
	if animal:
		
		animal.velocity = move_direction * move_speed
