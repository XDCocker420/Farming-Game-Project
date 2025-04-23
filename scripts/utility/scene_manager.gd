extends Node2D

## TODO: Add all interior scenes here
@onready var trans_screen = $TransitionScreen

@onready var current_scene:Node2D = $CurrentScene

## TODO: Refactor all to Node2D
const main_map = preload("res://scenes/maps/game_map.tscn")

const weberei = preload("res://scenes/buildings/Weberei_interior.tscn")
const molkerei = preload("res://scenes/buildings/Molkerei_interior.tscn")
const pub = preload("res://scenes/buildings/Pub_interior.tscn")
const start_screen = preload("res://scenes/maps/start_screen.tscn")

var next_name:String = ""

func _ready() -> void:
	trans_screen.transitioned.connect(_on_transition_finished)
	SceneSwitcher.transition_to_new_scene.connect(_on_transition_to_new_scene)
	SceneSwitcher.transition_to_main.connect(_transiton_to_game_map)

func _on_transition_to_new_scene(new_scene_name:String, global_player_pos:Vector2):
	SceneSwitcher.player_position = global_player_pos
	next_name = new_scene_name
	SaveGame.save_game()
	trans_screen.transition()
	
func _transiton_to_game_map():
	next_name = "game_map"
	SaveGame.save_exp_lvl()
	trans_screen.transition()
	
func _on_transition_finished():
	current_scene.get_child(0).queue_free()
	
	match next_name:
		"weberei":
			current_scene.add_child(weberei.instantiate())
		"molkerei":
			current_scene.add_child(molkerei.instantiate())
		"pub":
			current_scene.add_child(pub.instantiate())
		"game_map":
			current_scene.add_child(main_map.instantiate())
