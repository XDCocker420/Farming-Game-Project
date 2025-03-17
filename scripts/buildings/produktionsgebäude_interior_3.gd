extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var spawn_point = $SpawnPoint

var player_ref = null

func _ready():
	print("ProduktionsgebäudeInterior3: Ready function called")
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	
	# Check if Player exists in the scene
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player_ref = player
		print("ProduktionsgebäudeInterior3: Player found in scene")
	else:
		print("ProduktionsgebäudeInterior3: Player not found, instantiating...")
		var player_scene = load("res://scenes/characters/player.tscn")
		if player_scene:
			var player_instance = player_scene.instantiate()
			get_tree().current_scene.add_child(player_instance)
			player_ref = player_instance
			
			# Position player at spawn point
			if spawn_point:
				player_ref.global_position = spawn_point.global_position
				print("ProduktionsgebäudeInterior3: Positioned player at spawn point: ", spawn_point.global_position)
				
				# Aktualisiere die Kamera
				await get_tree().process_frame
				var viewport = get_viewport()
				if viewport:
					viewport.canvas_transform.origin = -player_ref.global_position + Vector2(viewport.size) / 2
			else:
				print("ProduktionsgebäudeInterior3: ERROR - SpawnPoint node not found!")
		else:
			print("ProduktionsgebäudeInterior3: ERROR - Could not load Player scene!")

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		print("ProduktionsgebäudeInterior3: Player entered exit area")
		# Switch back to main scene
		get_tree().change_scene_to_file("res://scenes/maps/game_map.tscn")
	else:
		print("ProduktionsgebäudeInterior3: Non-player body entered exit area: ", body.name) 