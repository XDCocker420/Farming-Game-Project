extends Area2D

@onready var player:CharacterBody2D = %Player
@onready var canvas_group: CanvasGroup = $CanvasGroup
@onready var ui_farming: PanelContainer = $CanvasLayer/ui_farming
@onready var camera:Camera2D = $Camera2D
@onready var colision:StaticBody2D = $PlayerInside
@onready var state_label:Label = $CanvasLayer/State


var field_list: Array

var player_in_area: bool

# False for harvesting / True for watering
var state:bool = false


func _ready() -> void:
	field_list = canvas_group.get_children()
	
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	
	for field: Area2D in field_list:
		field.field_clicked.connect(_on_field_clicked)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && player_in_area:
		state = !state
		
		if state:
			state_label.text = "Watering"
		else:
			state_label.text = "Harvesting"

			
	if event.is_action_pressed("interact3") && player_in_area:
		_set_collision(true)
		if player:
			player.normal_speed = 50
			player.camera.make_current()
			player._follow_mouse(false)
		

func _on_field_clicked(field:Area2D) -> void:
	if field.get_child_count() > 2:
		if field.get_child(2).can_harvest() && !state:
			field.get_child(2).harvest()
			
		if state:
			if player:
				player.do_water()
			field.get_child(2).water()
	else:
		if ui_farming.selection != '' && SaveGame.get_item_count(ui_farming.selection) > 0:
			if player:
				player.do_harvest()
			var crop:AnimatedSprite2D = load("res://scenes/crops/" + ui_farming.selection.split("_")[0] +".tscn").instantiate()
			field.add_child(crop)
	
	
func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && LevelingHandler.is_building_unlocked(name.to_lower()):
		player_in_area = true
		ui_farming.show()
		state_label.show()
		
		if state:
			state_label.text = "Watering"
		else:
			state_label.text = "Harvesting"
			
		if player:
			await get_tree().create_timer(0.2).timeout
			player.normal_speed = 100
			camera.make_current()
			player._follow_mouse(true)
			_set_collision(false)
			player._follow_mouse(true)
			
		

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		state_label.hide()
		ui_farming.hide()
		if player:
			player.camera.make_current()
			
	
func _set_collision(val:bool):
	for i in colision.get_children():
		i.set_deferred("disabled", val)
