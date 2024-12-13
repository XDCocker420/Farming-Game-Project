extends Node2D

@onready var area:Area2D = $TileMapLayer/Area2D
@onready var ui = $ContractBoardUI
@onready var player: CharacterBody2D = %Player



var in_area:bool = false
var ui_is_open:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(_on_area_entered)
	area.body_exited.connect(_on_area_exited)

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && in_area:
		if ui_is_open:
			ui.hide()
			ui_is_open = false
		else:
			ui.show()
			ui_is_open = true
			

func _on_area_entered(body:Node2D):
	if body.is_in_group("Player"):
		in_area = true
	
	
func _on_area_exited(body:Node2D):
	if body.is_in_group("Player"):
		in_area = false
		ui.hide()
		ui_is_open = false
