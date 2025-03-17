extends StaticBody2D

@onready var exit_area = $ExitArea

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		# Store building ID to spawn at correct location
		SaveGame.last_building_entered = 3
		
		# Switch back to main scene
		get_tree().change_scene_to_file("res://scenes/maps/game_map.tscn")
	else:
		print("MolkereiInterior: Non-player body entered exit area: ", body.name) 