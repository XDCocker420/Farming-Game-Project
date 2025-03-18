extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var exit_collision = $ExitArea/CollisionShape2D
@onready var player = $Player

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		# Store building ID to spawn at correct location
		SaveGame.last_building_entered = 2
		
		# Save the exit position using the CollisionShape2D's position
		SaveGame.last_exterior_position = exit_collision.global_position
		
		# Switch back to main scene
		get_tree().change_scene_to_file("res://scenes/maps/game_map.tscn")
	else:
		print("WebereiInterior: Non-player body entered exit area: ", body.name) 