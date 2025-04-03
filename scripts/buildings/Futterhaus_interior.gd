extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var production_ui = $production_ui_feed
@onready var inventory_ui = $inventory_ui_feed
@onready var feed_area = $feedArea

var player_in_workstation_area = false
var current_ui = null
var current_inventory_ui = null

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	feed_area.body_entered.connect(_on_feed_area_body_entered)
	feed_area.body_exited.connect(_on_feed_area_body_exited)
	
	# Set up current references
	current_ui = production_ui
	current_inventory_ui = inventory_ui
	
	# Hide UIs initially
	if current_ui:
		current_ui.hide()
	if current_inventory_ui:
		current_inventory_ui.hide()

func _on_feed_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_workstation_area = true
		if body.has_method("show_interaction_prompt"):
			body.show_interaction_prompt("Press E to use Feed Mill")

func _on_feed_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_workstation_area = false
		
		# Hide current UIs if any
		if current_ui:
			current_ui.hide()
		if current_inventory_ui:
			current_inventory_ui.hide()
		
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		# Hide the interaction prompt before exiting
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()
		
		# Reset the workstation area flag
		player_in_workstation_area = false
		
		# Hide UIs if they're visible
		if current_ui and current_ui.visible:
			current_ui.hide()
		if current_inventory_ui and current_inventory_ui.visible:
			current_inventory_ui.hide()
		
		SceneSwitcher.transition_to_main.emit()
	else:
		print("FutterhausInterior: Non-player body entered exit area: ", body.name)

func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_in_workstation_area and current_ui and current_inventory_ui:
		# Show both UIs
		current_ui.show()
		current_inventory_ui.show()
		
		# Set up the production UI first
		current_ui.setup("feed_mill")
		print("Production UI set up for feed mill")
		
		# Setup inventory UI with filtered items for feed mill
		print("Setting up inventory UI with filter")
		current_inventory_ui.setup_and_show("feed_mill")
		
		# Set the active production UI in the inventory UI AFTER setting up the inventory UI
		print("Setting active production UI in inventory UI AFTER inventory setup")
		if current_inventory_ui.has_method("set_active_production_ui"):
			current_inventory_ui.set_active_production_ui(current_ui)
			print("Active production UI set in inventory UI")
		else:
			print("ERROR: inventory UI doesn't have set_active_production_ui method")
		
		# Debug print to verify the UI is being shown
		print("Both UIs now visible and connected for feed mill")
	
	# Close UIs when ESC is pressed
	if event.is_action_pressed("ui_cancel") and current_ui and current_ui.visible:
		current_ui.hide()
		current_inventory_ui.hide()
