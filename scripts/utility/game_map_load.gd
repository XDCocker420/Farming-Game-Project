extends Node2D

func _ready() -> void:
	SaveGame.update_player()
	SaveGame.load_game()
	
