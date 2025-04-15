extends Node2D

@onready var anim_pl:AnimationPlayer = $AnimationPlayer
@onready var marth_meet:Area2D = $MarthaMeet
@onready var player:CharacterBody2D = $CutPlayer
@onready var player_collison:CollisionShape2D = $CutPlayer/CollisionShape2D
@onready var camera:Camera2D = $Camera2D
@onready var martha:CharacterBody2D = $Martha


var new_camera:Camera2D = Camera2D.new()

func _ready() -> void:
	marth_meet.body_exited.connect(_on_to_meet_martha)
	
	anim_pl.animation_finished.connect(_anim_finished)
	anim_pl.speed_scale = 3
	anim_pl.play("driving_farm")

func _anim_finished(anim_name):
	if anim_name == "driving_farm":
		anim_pl.speed_scale = 1
		anim_pl.play("exit_car")
		
	if anim_name == "exit_car":
		player.add_child(new_camera)
		new_camera.make_current()
		camera.queue_free()
		player_collison.disabled = false
		player.cant_move = false
		
func _on_to_meet_martha(body:Node2D):
	if body.is_in_group("Player"):
		player.cant_move = true

		print("no")
