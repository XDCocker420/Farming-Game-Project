extends Node2D

@onready var anim_pl:AnimationPlayer = $AnimationPlayer
@onready var marth_meet:Area2D = $MarthaMeet
@onready var player:CharacterBody2D = $CutPlayer
@onready var player_collison:CollisionShape2D = $CutPlayer/CollisionShape2D
@onready var camera:Camera2D = $Camera2D
@onready var martha:CharacterBody2D = $Martha

@onready var player_camera:Camera2D = %CutPlayer/Camera2D
@onready var exit_farming:Area2D = $ExitFarming

@onready var arrow:Sprite2D = $DirectionArrow
@onready var controls_label:Label = $Controls
@onready var anti_raus:StaticBody2D = $AntiRauslaufen

var new_camera:Camera2D = Camera2D.new()

var once1:bool = false
var farming_end:bool = false

func _ready() -> void:
	marth_meet.body_exited.connect(_on_to_meet_martha)
	
	exit_farming.body_entered.connect(_on_farming_enter)
	
	TutorialHelper.farming_ended.connect(_on_farming_ended)
	
	anim_pl.animation_finished.connect(_anim_finished)
	anim_pl.speed_scale = 3
	anim_pl.play("driving_farm")


func _anim_finished(anim_name):
	if anim_name == "driving_farm":
		anim_pl.speed_scale = 1
		_set_collision(true)
		anim_pl.play("exit_car")
		
	if anim_name == "exit_car":
		#player.add_child(new_camera)
		player_camera.enabled = true
		player_camera.make_current()
		camera.queue_free()
		player_collison.disabled = false
		player.cant_move = false
		#controls_label.show()
		_set_collision(false)
		arrow.show()
		anim_pl.play("text_fade_in")
		
	if anim_name == "text_fade_in":
		anim_pl.play("arrow_blink")
		
func _on_to_meet_martha(body:Node2D):
	if body.is_in_group("Player") && !once1:
		_set_collision(true)
		controls_label.hide()
		arrow.hide()
		anim_pl.stop()
		once1 = true
		player.cant_move = true
		martha.to_player()

		
func _on_farming_enter(body:Node2D):
	if body.is_in_group("Player") && farming_end:
		player.follow_martha(true)
		martha.to_scheune()
	
func _on_farming_ended():
	farming_end = true
		
func _set_collision(val:bool):
	for i in anti_raus.get_children():
		i.set_deferred("disabled", val)
