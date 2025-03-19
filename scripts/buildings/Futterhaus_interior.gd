extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var production_ui = $ProductionUI

# Player is already inside the building when this scene is loaded
var player_inside = true

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	
	# Get the player reference
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("show_interaction_prompt"):
		player.show_interaction_prompt("Press E to use Feed Mill")
	
	# Hide production UI initially
	if production_ui:
		production_ui.visible = false

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		# Hide the interaction prompt before exiting
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()
			
		# Store building ID to spawn at correct location
		SaveGame.last_building_entered = 1
		
		# Switch back to main scene using call_deferred to avoid physics callback issues
		get_tree().call_deferred("change_scene_to_file", "res://scenes/maps/game_map.tscn")
	else:
		print("FutterhausInterior: Non-player body entered exit area: ", body.name)

func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_inside:
		if production_ui:
			production_ui.visible = !production_ui.visible
			if production_ui.visible:
				production_ui.setup("feed_mill")  # Still use feed_mill as the workstation type
