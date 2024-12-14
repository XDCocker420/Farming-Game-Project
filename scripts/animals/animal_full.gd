extends State
class_name  AnimalFull

var move_direction:Vector2
var eat_time:float
@export var animal:CharacterBody2D
@export var move_speed := 50.0
@onready var interaction:AnimatedSprite2D = $"../../Action"
@onready var area:Area2D = $"../../InteractionRange"
@onready var ui:Control = $"../../FeedingUi"
@onready var kill_btn = $"../../FeedingUi/Menu/Schlachten"
@onready var interact_btn = $"../../FeedingUi/Menu/Melken"

var in_area:bool = false
var ui_shown:bool = false


func _ready() -> void:
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)
	kill_btn.pressed.connect(on_kill)
	interact_btn.pressed.connect(on_interaction)
	
func enter():
	interaction.visible = true
	interaction.play("full")

func process_input(_event: InputEvent):
	if _event.is_action_pressed("interact") && in_area:
		if ui_shown:
			ui.hide()
			ui_shown = false
		else:
			ui.show()
			ui_shown = true
			
func on_kill():
	SaveGame.add_to_inventory(animal.name.to_lower() + "_meat", 2)
	get_parent().get_parent().queue_free()
	
func on_interaction():
	SaveGame.add_to_inventory(animal.name.to_lower())
	print(SaveGame.get_inventory())
	transitioned.emit(self, "Hungry")
		
func exit():
	interaction.visible = false
	ui.hide()

func on_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		in_area = true

func on_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		in_area = false
		ui.hide()
		ui_shown = false
