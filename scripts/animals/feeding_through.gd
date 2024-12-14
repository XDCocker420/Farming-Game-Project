extends Node2D

@onready var area:Area2D = $Area2D
var in_area:bool = false
var ui_is_open:bool = false
var is_full:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(on_body_enter)
	area.body_exited.connect(on_body_exit)
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && in_area:
		if !is_full:
			if ui_is_open:
				#ui.hide()
				ui_is_open = false
			else:
				#ui.show()
				ui_is_open = true
	
func on_body_enter(body:Node2D):
	if body.is_in_group("Player"):
		in_area = true
	
func on_body_exit(body:Node2D):
	if body.is_in_group("Player"):
		in_area = false
		ui_is_open = false
