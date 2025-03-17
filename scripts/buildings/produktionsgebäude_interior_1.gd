extends StaticBody2D

@onready var exit_area = $ExitArea

var player_ref = null

func _ready():
	print("ProduktionsgebäudeInterior1: Ready function called")
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	
	# Check if Player exists in the scene
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player_ref = player
		print("ProduktionsgebäudeInterior1: Player found in scene")
		
		# Update camera to follow player
		call_deferred("update_camera")
	else:
		print("ProduktionsgebäudeInterior1: Player not found, instantiating...")
		var player_scene = load("res://scenes/characters/player.tscn")
		if player_scene:
			var player_instance = player_scene.instantiate()
			get_tree().current_scene.add_child(player_instance)
			player_ref = player_instance
			print("ProduktionsgebäudeInterior1: Player instantiated")
			
			# Update camera to follow player
			call_deferred("update_camera")
		else:
			print("ProduktionsgebäudeInterior1: ERROR - Could not load Player scene!")

func update_camera():
	await get_tree().process_frame
	if player_ref:
		var viewport = get_viewport()
		if viewport:
			viewport.canvas_transform.origin = -player_ref.global_position + Vector2(viewport.size) / 2
			print("ProduktionsgebäudeInterior1: Camera updated to follow player")

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		print("ProduktionsgebäudeInterior1: Player entered exit area")
		# Switch back to main scene
		get_tree().change_scene_to_file("res://scenes/maps/game_map.tscn")
	else:
		print("ProduktionsgebäudeInterior1: Non-player body entered exit area: ", body.name) 