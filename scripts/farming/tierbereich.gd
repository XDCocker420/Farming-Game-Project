extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var door: AnimatedSprite2D = $Area2D/door
@onready var door_area: Area2D = $Area2D
@onready var wall: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var e_btn: AnimatedSprite2D = $AnimatedSprite2D3

var in_area = false
var open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.interact.connect(_on_player_interact)
	e_btn.visible = false
	

func _on_player_interact():
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