extends State
class_name  AnimalHungry

var move_direction:Vector2
var eat_time:float
@export var animal:CharacterBody2D
@export var move_speed := 50.0
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var area:Area2D = $"../../InteractionRange"
@onready var machine = $".."

var in_area:bool = false
var cur_state:bool = false


func _ready() -> void:
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)
	
func enter():
	if animal:
		player.play("hungry")

func process_input(_event: InputEvent):
	if _event.is_action_pressed("interact") && in_area:
		if SaveGame.get_item_count(animal.name.to_lower() + "_food") > 0:
			SaveGame.remove_from_inventory(animal.name.to_lower() + "_food")
			transitioned.emit(self, "fed")
		else:
			SaveGame.add_to_inventory(animal.name.to_lower() + "_food", 2)
			print(SaveGame.get_inventory())
			print("Not enough food")

func on_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		in_area = true

func on_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		in_area = false
