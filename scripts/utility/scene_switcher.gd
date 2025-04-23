extends Node

signal transition_to_new_scene(new_scene_name:String, global_player_pos:Vector2)
signal transition_to_main

var player_position:Vector2 = Vector2.ZERO
var current_scene:String = ""

func get_current_scene_name():
	return current_scene

func set_current_scene_name(new_name:String):
	current_scene = new_name
