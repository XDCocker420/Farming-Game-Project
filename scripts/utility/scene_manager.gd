extends Node2D

## TODO: Add all interior scenes here
@onready var trans_screen = $TransitionScreen

@onready var current_scene:Node2D = $CurrentScene

## TODO: Refactor all to Node2D
const main_map = preload("res://scenes/maps/game_map.tscn")

const weberei = preload("res://scenes/buildings/Weberei_interior.tscn")
const molkerei = preload("res://scenes/buildings/Molkerei_interior.tscn")
const futterhaus = preload("res://scenes/buildings/Futterhaus_interior.tscn")

var next_name:String = ""

func _ready() -> void:
	trans_screen.transitioned.connect(_on_transition_finished)
	SceneSwitcher.transition_to_new_scene.connect(_on_transition_to_new_scene)
	SceneSwitcher.transition_to_main.connect(_transiton_to_game_map)

func _on_transition_to_new_scene(new_scene_name:String, global_player_pos:Vector2):
	SceneSwitcher.player_position = global_player_pos
	next_name = new_scene_name
	trans_screen.transition()
	
func _transiton_to_game_map():
	next_name = "game_map"
	trans_screen.transition()
	
func _on_transition_finished():
	current_scene.get_child(0).queue_free()
	
	match next_name:
		"weberei":
			current_scene.add_child(weberei.instantiate())
		"futterhaus":
			current_scene.add_child(futterhaus.instantiate())
		"molkerei":
			current_scene.add_child(molkerei.instantiate())
		"game_map":
			current_scene.add_child(main_map.instantiate())
			
