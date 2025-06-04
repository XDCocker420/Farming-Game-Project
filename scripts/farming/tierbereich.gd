extends Area2D

var player: CharacterBody2D
@onready var door: AnimatedSprite2D = $Area2D/door
@onready var door_area: Area2D = $Area2D
@onready var door_collision:CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var interact_range:Area2D = $InteractionArea
@onready var ui:PanelContainer = $FeedingUi
@onready var text:Label = $Mode

var in_interact_area:bool = false
var ui_open:bool = false

signal feeding_state
signal collecting_state

func _ready() -> void:
        player = get_tree().get_first_node_in_group("Player")
        if player:
                player.interact.connect(_on_player_interact)
	door_area.body_entered.connect(_on_door_entered)
	door_area.body_exited.connect(_on_door_exited)
	interact_range.body_entered.connect(_on_interact_entered)
	interact_range.body_exited.connect(_on_interact_exited)
	ui.collecting_state.connect(_on_collection)
	ui.feeding_state.connect(_on_feeding)
	
func _on_collection():
	SaveGame.add_to_inventory("pig_food", 10)
	SaveGame.add_to_inventory("cow_food", 10)
	SaveGame.add_to_inventory("sheep_food", 10)
	SaveGame.add_to_inventory("chicken_food", 10)
	
	collecting_state.emit()
	text.text = "Collect"
	text.show()
	text.modulate = Color.WHITE
	
func _on_feeding():
	feeding_state.emit()
	text.text = "Feed"
	text.show()
	text.modulate = Color.WHITE
	
func _on_door_entered(body:Node2D):
	if body.is_in_group("Player") && LevelingHandler.is_building_unlocked(name.to_lower()):
		door_collision.set_deferred("disabled", true)
		door.play("open")
		
func _on_door_exited(body:Node2D):
	if body.is_in_group("Player"):
		ui.hide()
		door_collision.set_deferred("disabled", false)
		door.play_backwards("open")
		
func _on_interact_entered(body:Node2D):
	if body.is_in_group("Player") && LevelingHandler.is_building_unlocked(name.to_lower()):
		in_interact_area = true
		
func _on_interact_exited(body:Node2D):
	if body.is_in_group("Player"):
		in_interact_area = false
		text.hide()
	
func _on_player_interact():
	if in_interact_area:
		if !ui_open:
			ui_open = true
			#player.cant_move = true
			ui.show()
		else:
			ui.hide()
			#player.cant_move = false
			ui_open = false
	#if in_area:
		#if not open:
			#door.play("open")
			#open = true
			#wall.disabled = true
		#else:
			#door.play_backwards("open")
			#open = false
			#wall.disabled = false

#@onready var wall: CollisionShape2D = $StaticBody2D/CollisionShape2D
#@onready var e_btn: AnimatedSprite2D = $AnimatedSprite2D3
#@onready var interaction_range:Area2D = $Range
#@onready var ft = $FeedingThrough/Area2D
#@onready var mode = $HarvestAnimals
#
#var in_area = false
#var open = false
#var in_interaction:bool = false
#var ui_open:bool = false
#var in_ft:bool = false
#
#signal want_to_interact(begin:bool)
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#player.interact.connect(_on_player_interact)
	#interaction_range.body_entered.connect(on_interaction_enter)
	#interaction_range.body_exited.connect(on_interaction_exit)
	#ft.body_entered.connect(on_ft_enter)
	#ft.body_exited.connect(on_ft_exit)
	#
	#e_btn.visible = false
	#
#
#
#
#func _on_area_2d_body_entered(body:Node2D) -> void:
	#if body.is_in_group("Player"):
		#in_area = true
		#e_btn.visible = true
#
#
#func _on_area_2d_body_exited(body:Node2D) -> void:
	#if body.is_in_group("Player"):
		#in_area = false
		#e_btn.visible = false
		#
#func on_interaction_enter(body:Node2D):
	#if body.is_in_group("Player"):
		#in_interaction = true
		#
#func on_interaction_exit(body:Node2D):
	#if body.is_in_group("Player"):
		#want_to_interact.emit(false)
		#mode.hide()
		#in_interaction = false	
		#
#func on_ft_enter(body:Node2D):
	#if body.is_in_group("Player"):
		#in_ft = true
#
#func on_ft_exit(body:Node2D):
	#if body.is_in_group("Player"):
		#in_ft = false
	#
