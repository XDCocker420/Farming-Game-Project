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
		
		# Connect production start signal to play animation
		var prod_cb = Callable(self, "_on_production_started")
		if current_ui and not current_ui.is_connected("production_started", prod_cb):
			current_ui.connect("production_started", prod_cb)
		
		# Connect production complete signal to stop animation
		var finish_cb = Callable(self, "_on_production_complete")
		if current_ui and not current_ui.is_connected("process_complete", finish_cb):
			current_ui.connect("process_complete", finish_cb)
		
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
	
	# Stop current animation if any
	if current_animation:
		current_animation.stop()
	
	# Disconnect production_started to avoid leaks
	var prod_cb = Callable(self, "_on_production_started")
	if current_ui and current_ui.is_connected("production_started", prod_cb):
		current_ui.disconnect("production_started", prod_cb)
	
	# Disconnect production_complete to avoid leaks
	var finish_cb = Callable(self, "_on_production_complete")
	if current_ui and current_ui.is_connected("process_complete", finish_cb):
		current_ui.disconnect("process_complete", finish_cb)
	
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
		# --- SAVE WORKSTATION OUTPUTS BEFORE LEAVING ---
		_save_all_workstation_outputs()
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

func _on_production_started():
	# Play workstation animation when production actually starts
	if current_animation and current_workstation:
		var animation_name = current_workstation
		if current_animation.sprite_frames and current_animation.sprite_frames.has_animation(animation_name):
			current_animation.play(animation_name)

func _on_production_complete():
	# Stop tool animation when production finishes
	if current_animation:
		current_animation.stop()

func _process(delta):
	# auto-hide UI if player leaves area without firing exit signal
	if current_ui and current_ui.visible and current_area_node and player_body:
		if not current_area_node.get_overlapping_bodies().has(player_body):
			_cleanup_current()

# NEW function to save output slot states for all workstations in this interior
func _save_all_workstation_outputs():
	var uis_to_check = {
		"molkerei_butterchurn": butterchurn_ui,
		"molkerei_press_cheese": press_cheese_ui,
		"molkerei_mayomaker": mayomaker_ui
	}
	
	for workstation_id in uis_to_check:
		var ui_node = uis_to_check[workstation_id]
		# Check if UI node and output slot exist and are valid
		if is_instance_valid(ui_node) and is_instance_valid(ui_node.output_slot):
			var output_slot = ui_node.output_slot
			var item_name = output_slot.item_name
			var count = 0
			
			# Get count safely from label
			if item_name != "":
				var amount_label = ui_node._get_amount_label(output_slot)
				if amount_label and amount_label.text.is_valid_int():
					count = int(amount_label.text)
				else:
					# If label invalid but item exists, assume 1? Or maybe 0 is safer?
					count = 1 # Assuming 1 if item present but label missing/invalid
			
			# Save if item exists and count > 0
			if item_name != "" and count > 0:
				SaveGame.set_workstation_output(workstation_id, {"item": item_name, "count": count})
			else:
				# Ensure state is cleared if slot is empty or invalid
				SaveGame.clear_workstation_output(workstation_id)
		else:
			# If UI or slot doesn't exist, clear any potentially stale saved state
			SaveGame.clear_workstation_output(workstation_id)
			
	# Save the game immediately after updating states
	SaveGame.save_game()
