extends Area2D

@onready var player:CharacterBody2D = %Player
@onready var canvas_group: CanvasGroup = $CanvasGroup
@onready var ui_farming: PanelContainer = $CanvasLayer/tutorial_farming_ui
@onready var camera:Camera2D = $Camera2D
@onready var colision:StaticBody2D = $PlayerInside
@onready var left_collison:CollisionShape2D = $PlayerInside/CollisionShape2D2
@onready var arrow:TextureRect = $CanvasLayer/Arrow
@onready var anim_player:AnimationPlayer = $AnimationPlayer

@onready var label:Label = $CanvasLayer/Label
@onready var state_label:Label = $CanvasLayer/State

var field_list: Array

var player_in_area: bool

# False for harvesting / True for watering
var state:bool = false
var once:bool = false
var once2:bool = false

var anbau_once:bool = false
var water_once:bool = false
var crop_growd:bool = false


func _ready() -> void:
	field_list = canvas_group.get_children()
	
	TutorialHelper.crop_is_growed.connect(_on_crop_growed)
	
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	
	ui_farming.right_pressed.connect(_on_right_pressed)
	
	for field: Area2D in field_list:
		field.field_clicked.connect(_on_field_clicked)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && player_in_area:
		if !once2:
			once2 = true
			label.text = "Now click on the same field again with the mouse"
		state = !state
		
		if state:
			state_label.text = "Watering"
		else:
			state_label.text = "Harvesting"

			
	if event.is_action_pressed("interact3") && player_in_area && crop_growd:
		## Follow Martha again to scheune
		TutorialHelper.farming_ended.emit()
		
		_set_collision(true)
		if player:
			player.normal_speed = 50
			player.camera.make_current()
			player._follow_mouse(false)
		

func _on_field_clicked(field:Area2D) -> void:
	if field.get_child_count() > 2:
		if field.get_child(2).can_harvest() && !state:
			field.get_child(2).harvest()
			await get_tree().create_timer(0.5).timeout
			label.text = "Now press F and leave the field again"
			
		if state:
			if player:
				player.do_water()

			if field.get_child(2).water():
				label.text = "Great! Now press E and wait until the plant has grown"
			
	else:
		if ui_farming.selection != '' && !anbau_once:
			anbau_once = true
			if player:
				player.do_harvest()
			var crop:AnimatedSprite2D = load("res://scenes/crops/tutorial_wheat.tscn").instantiate()
			field.add_child(crop)
			label.text = "Very good! Now press E"
	
	
func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		label.text = "Click on the wheat seeds"
		player_in_area = true
		ui_farming.show()
		arrow.show()
		anim_player.play("arrow_blink")
		label.show()
		
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
		
		ui_farming.hide()
		label.hide()
		state_label.hide()
		
		if player:
			player.camera.make_current()
			
	
func _set_collision(val:bool):
	left_collison.set_deferred("disabled", val)

		
func _on_right_pressed():
	if !once:
		anim_player.stop()
		arrow.hide()
		once = true
		label.text = "Very good, now click on a field"
		
func _on_crop_growed():
	crop_growd = true
	label.text = "Click on the field to harvest"
