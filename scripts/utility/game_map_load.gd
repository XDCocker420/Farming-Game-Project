extends Node2D

func _ready() -> void:
	SaveGame.update_player()
	await get_tree().process_frame
	await SaveGame.load_game()
	
