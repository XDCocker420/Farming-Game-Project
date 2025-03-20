extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var clothmaker_area = $clothmakerArea
@onready var spindle_area = $spindleArea
@onready var clothmaker_ui = $production_ui_clothmaker
@onready var spindle_ui = $production_ui_spindle
@onready var inventory_ui_clothmaker = $inventory_ui_clothmaker
@onready var inventory_ui_spindle = $inventory_ui_spindle
# Animation references
@onready var clothmaker_anim = $clothmaker
@onready var spindle_anim = $spindle

var player_in_workstation_area = false
var current_workstation = null
var current_ui = null
var current_inventory_ui = null
var current_animation = null

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
		
	# Stop all animations initially
	if clothmaker_anim:
		clothmaker_anim.stop()
	if spindle_anim:
		spindle_anim.stop()

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
				current_animation = clothmaker_anim
			"spindle":
				current_ui = spindle_ui
				current_inventory_ui = inventory_ui_spindle
				current_animation = spindle_anim
				
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
		
		# Stop current animation if any
		if current_animation:
			current_animation.stop()
			
		current_workstation = null
		current_ui = null
		current_inventory_ui = null
		current_animation = null
		
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()

func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_in_workstation_area and current_ui and current_inventory_ui:
		# Show both UIs
		current_ui.show()
		current_inventory_ui.show()
		
		# Set up the production UI first
		current_ui.setup(current_workstation)
		print("Production UI set up for: " + current_workstation)
		
		# Setup inventory UI with filtered items for this workstation
		print("Setting up inventory UI with filter")
		current_inventory_ui.setup_and_show(current_workstation)
		
		# Set the active production UI in the inventory UI AFTER setting up the inventory UI
		# This is critical because setup_and_show recreates all the slots
		print("Setting active production UI in inventory UI AFTER inventory setup")
		if current_inventory_ui.has_method("set_active_production_ui"):
			current_inventory_ui.set_active_production_ui(current_ui)
			print("Active production UI set in inventory UI")
		else:
			print("ERROR: inventory UI doesn't have set_active_production_ui method")
		
		# Start the animation for the current workstation
		if current_animation:
			var animation_name = current_workstation 
			if current_animation.sprite_frames and current_animation.sprite_frames.has_animation(animation_name):
				current_animation.play(animation_name)
				print("Started animation for: " + current_workstation)
			else:
				print("ERROR: No animation found for " + current_workstation)
				
		# Debug print to verify the UI is being shown
		print("Both UIs now visible and connected for " + current_workstation)
	
	# Close UIs and stop animation when ESC is pressed
	if event.is_action_pressed("ui_cancel") and current_ui and current_ui.visible:
		current_ui.hide()
		current_inventory_ui.hide()
		
		# Stop current animation
		if current_animation:
			current_animation.stop()