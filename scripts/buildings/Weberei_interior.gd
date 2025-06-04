extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var clothmaker_area = $clothmaker/clothmakerArea
@onready var spindle_area = $spindle/spindleArea
@onready var clothmaker_ui = $CanvasLayer/HBoxContainer/production_ui_clothmaker
@onready var spindle_ui = $CanvasLayer/HBoxContainer2/production_ui_spindle
@onready var inventory_ui_clothmaker = $CanvasLayer/HBoxContainer/inventory_ui_clothmaker
@onready var inventory_ui_spindle = $CanvasLayer/HBoxContainer2/inventory_ui_spindle
# Animation references
@onready var clothmaker_anim = $clothmaker
@onready var spindle_anim = $spindle

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
	
	# Connect signals for both workstations using FULL IDs
	if clothmaker_area:
		clothmaker_area.body_entered.connect(_on_workstation_area_body_entered.bind("weberei_clothmaker"))
		clothmaker_area.body_exited.connect(_on_workstation_area_body_exited)
	
	if spindle_area:
		spindle_area.body_entered.connect(_on_workstation_area_body_entered.bind("weberei_spindle"))
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
	
	# Allow this node to receive unhandled inputs
	set_process_unhandled_input(true)
	
	# Enable _process for overlap checks
	set_process(true)

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

func _on_workstation_area_body_entered(body, workstation_id):
	if body.is_in_group("Player"):
		# Track player and which area
		player_body = body
		# Assign area node based on the full ID
		match workstation_id:
			"weberei_clothmaker": current_area_node = clothmaker_area
			"weberei_spindle": current_area_node = spindle_area
		player_in_workstation_area = true
		current_workstation = workstation_id # Store the full ID
		
		# Set the current UI based on workstation ID
		match workstation_id:
			"weberei_clothmaker":
				current_ui = clothmaker_ui
				current_inventory_ui = inventory_ui_clothmaker
				current_animation = clothmaker_anim
			"weberei_spindle":
				current_ui = spindle_ui
				current_inventory_ui = inventory_ui_spindle
				current_animation = spindle_anim
				
		if body.has_method("show_interaction_prompt"):
			var prompt_text = "Press E to use "
			# Use base name for prompt text
			var base_name = workstation_id.replace("weberei_","")
			match base_name:
				"clothmaker":
					prompt_text += "Cloth Maker"
				"spindle":
					prompt_text += "Spinning Wheel"
			body.show_interaction_prompt(prompt_text)

func _on_workstation_area_body_exited(body):
	if body.is_in_group("Player"):
		# Immediately clear UI and animation when leaving the tool area
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
	
	# --- Stop current animation if any (Handled by _process now) ---
	# if current_animation:
	# 	 current_animation.stop()
	# --- END STOP --- 
		
	# --- REMOVED Signal Disconnections for Animation ---
	# Disconnect production_started to avoid leaks
	# var prod_cb = Callable(self, "_on_production_started")
	# if current_ui and current_ui.is_connected("production_started", prod_cb):
	# 	 current_ui.disconnect("production_started", prod_cb)
	# 
	# Disconnect production_complete to avoid leaks
	# var finish_cb = Callable(self, "_on_production_complete")
	# if current_ui and current_ui.is_connected("process_complete", finish_cb):
	# 	 current_ui.disconnect("process_complete", finish_cb)
	# --- END REMOVED ---
		
	current_workstation = null
	current_ui = null
	current_inventory_ui = null
	current_animation = null
	
	# Clear area and player refs
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
		
		# Set up the production UI first, passing the full workstation ID and inventory UI reference
		current_ui.setup(current_workstation, current_inventory_ui)
		
		# Setup inventory UI with filtered items for this workstation (use base name)
		var base_workstation_name = current_workstation.replace("weberei_", "") # Extract base name
		current_inventory_ui.setup_and_show(base_workstation_name)
		
		# Set the active production UI in the inventory UI AFTER setting up the inventory UI
		# This is critical because setup_and_show recreates all the slots
		if current_inventory_ui.has_method("set_active_production_ui"):
			current_inventory_ui.set_active_production_ui(current_ui)
		
		# Start the animation for the current workstation (This seems wrong, animation should start on production)
		# if current_animation:
		# 	 var animation_name = current_workstation 
		# 	 if current_animation.sprite_frames and current_animation.sprite_frames.has_animation(animation_name):
		# 		 current_animation.play(animation_name)
	
	# Close UIs and stop animation when ESC is pressed
	if event.is_action_pressed("ui_cancel") and current_ui and current_ui.visible:
		current_ui.hide()
		current_inventory_ui.hide()
		
		# Stop current animation
		if current_animation:
			current_animation.stop()

func _process(delta):
	# Auto-hide UI if player leaves specific workstation area
	if current_ui and current_ui.visible and current_area_node and player_body:
		if not current_area_node.get_overlapping_bodies().has(player_body):
			_cleanup_current()
			# Don't return here, still need to check global animation state below

	# --- Global Animation State Check ---
	var workstations = {
		"weberei_clothmaker": clothmaker_anim,
		"weberei_spindle": spindle_anim
	}
	
	for id in workstations:
		var anim_player = workstations[id]
		if not is_instance_valid(anim_player):
			continue
			
		var prod_state = SaveGame.get_production_state(id)
		# Base name for animation might be different from ID prefix
		var base_name = ""
		if id == "weberei_clothmaker": base_name = "clothmaker"
		elif id == "weberei_spindle": base_name = "spindle"
			
		if not prod_state.is_empty():
			# Production is active in SaveGame
			# Correct property check: Use .animation
			if not anim_player.is_playing() or anim_player.animation != base_name:
				# Start animation if not playing or wrong one is playing
				# Correct check: Access sprite_frames first
				if anim_player.sprite_frames and anim_player.sprite_frames.has_animation(base_name):
					anim_player.play(base_name)
		else:
			# Production is NOT active in SaveGame
			if anim_player.is_playing():
				# Stop animation if it's running
				anim_player.stop()
	# --- End Global Animation State Check ---
