extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var clothmaker_area = $clothmakerArea
@onready var spindle_area = $spindleArea
@onready var production_ui = $ProductionUI

var player_in_workstation_area = false
var current_workstation = null

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	
	# Connect signals for both workstations
	if clothmaker_area:
		clothmaker_area.body_entered.connect(_on_workstation_area_body_entered.bind("clothmaker"))
		clothmaker_area.body_exited.connect(_on_workstation_area_body_exited)
	
	if spindle_area:
		spindle_area.body_entered.connect(_on_workstation_area_body_entered.bind("spindle"))
		spindle_area.body_exited.connect(_on_workstation_area_body_exited)
	
	# Hide production UI initially
	if production_ui:
		production_ui.visible = false

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		# Store building ID to spawn at correct location
		SaveGame.last_building_entered = 2
		
		# Switch back to main scene using call_deferred to avoid physics callback issues
		get_tree().call_deferred("change_scene_to_file", "res://scenes/maps/game_map.tscn")
	else:
		print("WebereiInterior: Non-player body entered exit area: ", body.name)

func _on_workstation_area_body_entered(body, workstation_name):
	if body.is_in_group("Player"):
		player_in_workstation_area = true
		current_workstation = workstation_name
		if body.has_method("show_interaction_prompt"):
			var prompt_text = "Press E to use "
			match workstation_name:
				"clothmaker":
					prompt_text += "Cloth Maker"
				"spindle":
					prompt_text += "Spinning Wheel"
			body.show_interaction_prompt(prompt_text)
		
func _on_workstation_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_workstation_area = false
		current_workstation = null
		if production_ui:
			production_ui.visible = false
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()

func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_in_workstation_area:
		if production_ui:
			production_ui.visible = !production_ui.visible
			if production_ui.visible and current_workstation:
				production_ui.setup(current_workstation)
			# Optionally pause player movement when UI is open
			# get_tree().get_first_node_in_group("Player").set_physics_process(!production_ui.visible)