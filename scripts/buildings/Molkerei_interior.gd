extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var butterchurn_area = $butterchurn/butterchurnArea
@onready var press_cheese_area = $press_cheese/press_cheeseArea
@onready var mayomaker_area = $mayomaker/mayomakerArea
@onready var butterchurn_ui = $production_ui_butterchurn
@onready var press_cheese_ui = $production_ui_press_cheese
@onready var mayomaker_ui = $production_ui_mayomaker
@onready var inventory_ui_butterchurn = $inventory_ui_butterchurn
@onready var inventory_ui_press_cheese = $inventory_ui_press_cheese
@onready var inventory_ui_mayomaker = $inventory_ui_mayomaker
# Animation references
@onready var butterchurn_anim = $butterchurn
@onready var press_cheese_anim = $press_cheese
@onready var mayomaker_anim = $mayomaker

var player_in_workstation_area = false
var current_workstation = null
var current_ui = null
var current_inventory_ui = null
var current_animation = null
var in_exit_area: bool = false
var player_body = null
var current_area_node = null

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	exit_area.body_exited.connect(_on_exit_area_body_exited)
	
	# Connect signals for all workstations
	if butterchurn_area:
		butterchurn_area.body_entered.connect(_on_workstation_area_body_entered.bind("butterchurn"))
		butterchurn_area.body_exited.connect(_on_workstation_area_body_exited.bind("butterchurn"))
	
	if press_cheese_area:
		press_cheese_area.body_entered.connect(_on_workstation_area_body_entered.bind("press_cheese"))
		press_cheese_area.body_exited.connect(_on_workstation_area_body_exited.bind("press_cheese"))
	
	if mayomaker_area:
		mayomaker_area.body_entered.connect(_on_workstation_area_body_entered.bind("mayomaker"))
		mayomaker_area.body_exited.connect(_on_workstation_area_body_exited.bind("mayomaker"))
	
	# Hide all production UIs initially
	if butterchurn_ui:
		butterchurn_ui.hide()
	if press_cheese_ui:
		press_cheese_ui.hide()
	if mayomaker_ui:
		mayomaker_ui.hide()
	
	# Hide all inventory UIs initially
	if inventory_ui_butterchurn:
		inventory_ui_butterchurn.hide()
	if inventory_ui_press_cheese:
		inventory_ui_press_cheese.hide()
	if inventory_ui_mayomaker:
		inventory_ui_mayomaker.hide()
	
	# Stop all animations initially
	if butterchurn_anim:
		butterchurn_anim.stop()
	if press_cheese_anim:
		press_cheese_anim.stop()
	if mayomaker_anim:
		mayomaker_anim.stop()

	# Allow this node to receive unhandled inputs
	set_process_unhandled_input(true)

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		in_exit_area = true
		if body.has_method("show_interaction_prompt"):
			body.show_interaction_prompt("Press E to exit interior")

func _on_exit_area_body_exited(body):
	if body.is_in_group("Player"):
		in_exit_area = false
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()

func _on_workstation_area_body_entered(body, workstation_name):
	if body.is_in_group("Player"):
		player_body = body
		# assign current_area_node based on workstation_name
		match workstation_name:
			"butterchurn": current_area_node = butterchurn_area
			"press_cheese": current_area_node = press_cheese_area
			"mayomaker": current_area_node = mayomaker_area

		player_in_workstation_area = true
		# Use full unique ID for current_workstation
		var full_workstation_id = "molkerei_" + workstation_name 
		current_workstation = full_workstation_id
		
		# Set the current UI based on workstation
		match workstation_name: # Match base name for UI nodes
			"butterchurn":
				current_ui = butterchurn_ui
				current_inventory_ui = inventory_ui_butterchurn
				current_animation = butterchurn_anim
			"press_cheese":
				current_ui = press_cheese_ui
				current_inventory_ui = inventory_ui_press_cheese
				current_animation = press_cheese_anim
			"mayomaker":
				current_ui = mayomaker_ui
				current_inventory_ui = inventory_ui_mayomaker
				current_animation = mayomaker_anim
		
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
		
func _on_workstation_area_body_exited(body, workstation_name):
	if not body.is_in_group("Player"):
		return
	# Only clear when leaving the active workstation area
	if workstation_name != current_workstation:
		return
	_cleanup_current()
	if body.has_method("hide_interaction_prompt"):
		body.hide_interaction_prompt()

func _cleanup_current():
	player_in_workstation_area = false
	
	# Hide current UIs if any
	if current_ui:
		current_ui.hide()
	if current_inventory_ui:
		current_inventory_ui.hide()
	
	# --- Stop current animation if any (This might stop it prematurely, handled by _process now) ---
	# if current_animation:
	# 	 current_animation.stop()
	# --- END STOP --- 
	
	current_workstation = null
	current_ui = null
	current_inventory_ui = null
	current_animation = null

	# clear area and player ref
	current_area_node = null
	player_body = null

func _unhandled_input(event):
	# Exit interior when pressing interact in exit area
	if event.is_action_pressed("interact") and in_exit_area:
		# --- SAVE WORKSTATION OUTPUTS BEFORE LEAVING --- (REMOVED - Handled globally/on start)
		# _save_all_workstation_outputs()
		# --- END SAVE ---
		SceneSwitcher.transition_to_main.emit()
		return

	if event.is_action_pressed("interact") and player_in_workstation_area and current_ui and current_inventory_ui:
		# Toggle off if already visible
		if current_ui.visible:
			current_ui.hide()
			current_inventory_ui.hide()
			if current_animation:
				current_animation.stop()
			return
		# Show both UIs
		current_ui.show()
		current_inventory_ui.show()
		
		# Set up the production UI first, passing the inventory UI reference
		current_ui.setup(current_workstation, current_inventory_ui) 
		
		# Setup inventory UI with filtered items for this workstation
		var base_workstation_name = current_workstation.replace("molkerei_", "") # Extract base name
		current_inventory_ui.setup_and_show(base_workstation_name)
		
		# Set the active production UI in the inventory UI AFTER setting up the inventory UI
		# This is critical because setup_and_show recreates all the slots
		if current_inventory_ui.has_method("set_active_production_ui"):
			current_inventory_ui.set_active_production_ui(current_ui)
	
	# Close UIs and stop animation when ESC is pressed
	if event.is_action_pressed("ui_cancel") and current_ui and current_ui.visible:
		current_ui.hide()
		current_inventory_ui.hide()
		
		# Stop current animation
		if current_animation:
			current_animation.stop()

func _process(delta):
	# auto-hide UI if player leaves area without firing exit signal
	if current_ui and current_ui.visible and current_area_node and player_body:
		if not current_area_node.get_overlapping_bodies().has(player_body):
			_cleanup_current()
			# Don't return here, still need to check global animation state below
			
	# --- Global Animation State Check ---
	var workstations = {
		"molkerei_butterchurn": butterchurn_anim,
		"molkerei_press_cheese": press_cheese_anim,
		"molkerei_mayomaker": mayomaker_anim
	}
	
	for id in workstations:
		var anim_player = workstations[id]
		if not is_instance_valid(anim_player):
			continue
			
		var prod_state = SaveGame.get_production_state(id)
		var base_name = id.replace("molkerei_", "")
		
		if not prod_state.is_empty():
			# Production is active in SaveGame
			if not anim_player.is_playing() or anim_player.animation != base_name:
				# Start animation if not playing or wrong one is playing
				if anim_player.sprite_frames and anim_player.sprite_frames.has_animation(base_name):
					anim_player.play(base_name)
		else:
			# Production is NOT active in SaveGame
			if anim_player.is_playing():
				# Stop animation if it's running
				anim_player.stop()
	# --- End Global Animation State Check ---
