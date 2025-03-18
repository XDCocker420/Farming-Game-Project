extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var butterchurn_area = $butterchurnArea
@onready var press_cheese_area = $press_cheeseArea
@onready var mayomaker_area = $mayomakerArea
@onready var butterchurn_ui = $production_ui_butterchurn
@onready var press_cheese_ui = $production_ui_press_cheese
@onready var mayomaker_ui = $production_ui_mayomaker

var player_in_workstation_area = false
var current_workstation = null
var current_ui = null

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	
	# Connect signals for all workstations
	if butterchurn_area:
		butterchurn_area.body_entered.connect(_on_workstation_area_body_entered.bind("butterchurn"))
		butterchurn_area.body_exited.connect(_on_workstation_area_body_exited)
	
	if press_cheese_area:
		press_cheese_area.body_entered.connect(_on_workstation_area_body_entered.bind("press_cheese"))
		press_cheese_area.body_exited.connect(_on_workstation_area_body_exited)
	
	if mayomaker_area:
		mayomaker_area.body_entered.connect(_on_workstation_area_body_entered.bind("mayomaker"))
		mayomaker_area.body_exited.connect(_on_workstation_area_body_exited)
	
	# Hide all production UIs initially
	if butterchurn_ui:
		butterchurn_ui.visible = false
	if press_cheese_ui:
		press_cheese_ui.visible = false
	if mayomaker_ui:
		mayomaker_ui.visible = false

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		# Store building ID to spawn at correct location
		SaveGame.last_building_entered = 3
		
		# Switch back to main scene using call_deferred to avoid physics callback issues
		get_tree().call_deferred("change_scene_to_file", "res://scenes/maps/game_map.tscn")
	else:
		print("MolkereiInterior: Non-player body entered exit area: ", body.name) 

func _on_workstation_area_body_entered(body, workstation_name):
	if body.is_in_group("Player"):
		player_in_workstation_area = true
		current_workstation = workstation_name
		
		# Set the current UI based on workstation
		match workstation_name:
			"butterchurn":
				current_ui = butterchurn_ui
			"press_cheese":
				current_ui = press_cheese_ui
			"mayomaker":
				current_ui = mayomaker_ui
		
		if body.has_method("show_interaction_prompt"):
			var prompt_text = "Press E to use "
			match workstation_name:
				"butterchurn":
					prompt_text += "Butter Churn"
				"press_cheese":
					prompt_text += "Cheese Press"
				"mayomaker":
					prompt_text += "Mayo Maker"
			body.show_interaction_prompt(prompt_text)
		
func _on_workstation_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_workstation_area = false
		
		# Hide current UI if any
		if current_ui:
			current_ui.visible = false
		
		current_workstation = null
		current_ui = null
		
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()

func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_in_workstation_area and current_ui:
		current_ui.visible = !current_ui.visible
		if current_ui.visible:
			current_ui.setup(current_workstation)
		# Optionally pause player movement when UI is open
		# get_tree().get_first_node_in_group("Player").set_physics_process(!current_ui.visible) 
