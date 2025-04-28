extends Node2D

## TODO: Add all interior scenes here
@onready var trans_screen = $TransitionScreen

@onready var current_scene:Node2D = $CurrentScene

## TODO: Refactor all to Node2D
const main_map = preload("res://scenes/maps/game_map.tscn")

const weberei = preload("res://scenes/buildings/Weberei_interior.tscn")
const molkerei = preload("res://scenes/buildings/Molkerei_interior.tscn")
const pub = preload("res://scenes/buildings/pub_interior.tscn")
const start_screen = preload("res://scenes/maps/start_screen.tscn")
const intro = preload("res://scenes/maps/intro.tscn")

var next_name:String = ""

func _ready() -> void:
	SceneSwitcher.set_current_scene_name("start_screen")
	trans_screen.transitioned.connect(_on_transition_finished)
	SceneSwitcher.transition_to_new_scene.connect(_on_transition_to_new_scene)
	SceneSwitcher.transition_to_main.connect(_transiton_to_game_map)

func _on_transition_to_new_scene(new_scene_name:String, global_player_pos:Vector2):
	SceneSwitcher.set_current_scene_name(new_scene_name)
	SceneSwitcher.player_position = global_player_pos
	next_name = new_scene_name
	#SaveGame.save_game()
	trans_screen.transition()
	
func _transiton_to_game_map():
	next_name = "game_map"
	if SceneSwitcher.current_scene not in ["intro", "start_screen"]:
		SaveGame.save_exp_lvl()
	SceneSwitcher.set_current_scene_name("game_map")
	trans_screen.transition()
	
func _on_transition_finished():
	current_scene.get_child(0).queue_free()
	await get_tree().process_frame
	match next_name:
		"weberei":
			current_scene.add_child(weberei.instantiate())
		"molkerei":
			current_scene.add_child(molkerei.instantiate())
		"pub":
			current_scene.add_child(pub.instantiate())
		"game_map":
			current_scene.add_child(main_map.instantiate())
		"start_screen":
			current_scene.add_child(start_screen.instantiate())
		"intro":
			current_scene.add_child(intro.instantiate())
