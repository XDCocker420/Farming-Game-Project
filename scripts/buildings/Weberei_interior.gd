extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var clothmaker_area = $clothmakerArea
@onready var spindle_area = $spindleArea
@onready var clothmaker_ui = $production_ui_clothmaker
@onready var spindle_ui = $production_ui_spindle
@onready var inventory_ui_clothmaker = $inventory_ui_clothmaker
@onready var inventory_ui_spindle = $inventory_ui_spindle

var player_in_workstation_area = false
var current_workstation = null
var current_ui = null
var current_inventory_ui = null

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	
	# Connect signals for both workstations
	if clothmaker_area:
		clothmaker_area.body_entered.connect(_on_workstation_area_body_entered.bind("clothmaker"))
		clothmaker_area.body_exited.connect(_on_workstation_area_body_exited)
	
	if spindle_area:
		spindle_area.body_entered.connect(_on_workstation_area_body_entered.bind("spindle"))
		spindle_area.body_exited.connect(_on_workstation_area_body_exited)
	
	# Hide all production UIs initially
	if clothmaker_ui:
		clothmaker_ui.hide()
	if spindle_ui:
		spindle_ui.hide()
	
	# Hide all inventory UIs initially
	if inventory_ui_clothmaker:
		inventory_ui_clothmaker.hide()
	if inventory_ui_spindle:
		inventory_ui_spindle.hide()

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
		
		# Set the current UI based on workstation
		match workstation_name:
			"clothmaker":
				current_ui = clothmaker_ui
				current_inventory_ui = inventory_ui_clothmaker
			"spindle":
				current_ui = spindle_ui
				current_inventory_ui = inventory_ui_spindle
				
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
		
		# Hide current UIs if any
		if current_ui:
			current_ui.hide()
		if current_inventory_ui:
			current_inventory_ui.hide()
			
		current_workstation = null
		current_ui = null
		current_inventory_ui = null
		
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()

func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_in_workstation_area and current_ui and current_inventory_ui:
		# Show UIs
		current_ui.show()
		current_inventory_ui.show()
		
		# Debug print to verify the UI is being shown
		print("Showing inventory UI for " + current_workstation)
		
		if current_ui.visible:
			current_ui.setup(current_workstation)
		# Optionally pause player movement when UI is open
		# get_tree().get_first_node_in_group("Player").set_physics_process(!current_ui.visible)