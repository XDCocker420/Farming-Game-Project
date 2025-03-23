extends Node2D

# This script should be attached to the "Game" node in the game_map.tscn scene

@onready var player = $Map/Player

func _ready():
	# Add the Game node to a group so it can be found from other scripts
	add_to_group("game_map")
	
	# Position the player based on where they came from
	if SaveGame.last_exterior_position != Vector2.ZERO:
		# If we have a saved position (coming from a building), use it
		player.global_position = SaveGame.last_exterior_position
		print("Positioning player at: ", SaveGame.last_exterior_position)
		print("Last building entered: ", SaveGame.last_building_entered)
	else:
		print("No exterior position saved, using default position") 