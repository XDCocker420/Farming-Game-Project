extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var door: AnimatedSprite2D = $Area2D/door
@onready var door_area: Area2D = $Area2D
@onready var wall: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var e_btn: AnimatedSprite2D = $AnimatedSprite2D3
@onready var interaction_range:Area2D = $Range
@onready var ft = $FeedingThrough/Area2D
@onready var mode = $HarvestAnimals

var in_area = false
var open = false
var in_interaction:bool = false
var ui_open:bool = false
var in_ft:bool = false

signal want_to_interact(begin:bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.interact.connect(_on_player_interact)
	interaction_range.body_entered.connect(on_interaction_enter)
	interaction_range.body_exited.connect(on_interaction_exit)
	ft.body_entered.connect(on_ft_enter)
	ft.body_exited.connect(on_ft_exit)
	
	e_btn.visible = false
	

func _on_player_interact():
	if in_interaction && !in_ft && !in_area:
		if !ui_open:
			ui_open = true
			#player.cant_move = true
			want_to_interact.emit(true)
			mode.show()
		else:
			mode.hide()
			want_to_interact.emit(false)
			#player.cant_move = false
			ui_open = false
	if in_area:
		if not open:
			door.play("open")
			open = true
			wall.disabled = true
		else:
			door.play_backwards("open")
			open = false
			wall.disabled = false


func _on_area_2d_body_entered(body:Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = true
		e_btn.visible = true


func _on_area_2d_body_exited(body:Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = false
		e_btn.visible = false
		
func on_interaction_enter(body:Node2D):
	if body.is_in_group("Player"):
		in_interaction = true
		
func on_interaction_exit(body:Node2D):
	if body.is_in_group("Player"):
		want_to_interact.emit(false)
		mode.hide()
		in_interaction = false	
		
func on_ft_enter(body:Node2D):
	if body.is_in_group("Player"):
		in_ft = true

func on_ft_exit(body:Node2D):
	if body.is_in_group("Player"):
		in_ft = false
	
