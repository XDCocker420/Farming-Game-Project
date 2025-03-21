extends PanelContainer

# Signal to notify when processing is complete
signal process_complete

# References to all slots
@onready var input_slot = $MarginContainer/slots/ui_slot
@onready var output_slot = $MarginContainer/slots/ui_slot2

# Current workstation information
var current_workstation: String = ""
var input_items = []
var output_items = []

func _ready():
	# Connect button signals for both slots
	for slot in [input_slot, output_slot]:
		if slot and slot.has_node("button"):
			var button = slot.get_node("button")
			# Disconnect any existing connections first
			if button.pressed.is_connected(_on_slot_pressed.bind(slot)):
				button.pressed.disconnect(_on_slot_pressed.bind(slot))
			# Connect the signal
			button.pressed.connect(_on_slot_pressed.bind(slot))
			print("Connected button signal for slot: " + str(slot.name))
	
	# Debug check to verify this object has the required methods
	print("PRODUCTION UI: Method check - has_method('add_input_item'): ", has_method("add_input_item"))
	print("PRODUCTION UI: Method check - has_method('_process_single_item'): ", has_method("_process_single_item"))
	print("PRODUCTION UI: Method check - has_method('_on_slot_pressed'): ", has_method("_on_slot_pressed"))

func setup(workstation_name: String):
	print("Setting up production UI for workstation: " + workstation_name)
	current_workstation = workstation_name
	
	# Set production UI reference for both slots
	if input_slot and input_slot.has_method("set_production_ui"):
		input_slot.set_production_ui(self)
		print("Set production UI reference for input slot")
	
	if output_slot and output_slot.has_method("set_production_ui"):
		output_slot.set_production_ui(self)
		print("Set production UI reference for output slot")
	
	# Clear all slots
	if input_slot and input_slot.has_method("clear"):
		input_slot.clear()
	
	if output_slot and output_slot.has_method("clear"):
		output_slot.clear()
	
	# Reset our stored items
	input_items.clear()
	output_items.clear()
	
	# Set up recipes based on workstation
	match workstation_name:
		"butterchurn":
			input_items = ["milk"]
			output_items = ["butter"]
		"press_cheese":
			input_items = ["milk"]
			output_items = ["cheese"]
		"mayomaker":
			input_items = ["egg"]
			output_items = ["mayo"]
		"clothmaker":
			input_items = ["white_wool"]
			output_items = ["white_cloth"]
		"spindle":
			input_items = ["white_wool"]
			output_items = ["white_string"]
		"feed_mill":
			input_items = ["wheat"]
			output_items = ["feed"]
	
	# Reconnect button signals for both slots
	for slot in [input_slot, output_slot]:
		if slot and slot.has_node("button"):
			var button = slot.get_node("button")
			# Disconnect any existing connections first
			if button.pressed.is_connected(_on_slot_pressed.bind(slot)):
				button.pressed.disconnect(_on_slot_pressed.bind(slot))
			# Connect the signal
			button.pressed.connect(_on_slot_pressed.bind(slot))
	
	print("Recipe: " + str(input_items) + " -> " + str(output_items))
	
	# Debug print to verify setup
	print("Production UI setup complete for " + workstation_name)
	print("Input items: " + str(input_items))
	print("Output items: " + str(output_items))

func _on_slot_pressed(slot):
	print("=== SLOT PRESSED ===")
	print("Slot name: " + str(slot.name))
	print("Is input slot: " + str(slot == input_slot))
	print("Is output slot: " + str(slot == output_slot))
	
	if slot == input_slot:
		print("Input slot clicked: (ignored)")
		return
	elif slot == output_slot:
		print("Output slot clicked")
		
		# Check if this is a processed item
		var item_count = 0
		if slot.amount_label.text != "":
			item_count = int(slot.amount_label.text)
		
		if item_count > 0:
			print("Transferring 1 " + output_items[0] + " back to inventory")
			# Add just one item to inventory
			SaveGame.add_to_inventory(output_items[0], 1)
			
			# Update the slot with one less item, or clear if it was the last one
			if item_count > 1:
				slot.setup(output_items[0], "", true, item_count - 1)
				print("Updated output slot, remaining: " + str(item_count - 1))
			else:
				# Clear the output slot if this was the last item
				slot.clear()
				print("Cleared output slot (last item taken)")
			
			# Find and update Scheune UI if it exists
			var scheune_ui = _find_scheune_ui()
			if scheune_ui and scheune_ui.has_method("reload_slots"):
				# Force a complete slot refresh
				for slot_item in scheune_ui.slot_list:
					slot_item.queue_free()
				scheune_ui.slot_list.clear()
				
				# Now reload with fresh data from SaveGame
				scheune_ui.current_filter.clear()
				scheune_ui.reload_slots(false)
				
				# Restore the correct filter
				scheune_ui.set_workstation_filter(current_workstation)
				print("Completely refreshed Scheune UI after item transfer")
			else:
				print("WARNING: Could not find or update Scheune UI")
				
			# Save game to persist inventory changes
			SaveGame.save_game()
			print("Saved game after inventory update")
		else:
			print("Processing output")
			_process_single_item()
			# Don't transfer items immediately, let them stay in the output slot

func _process_single_item() -> void:
	print("=== PROCESSING ITEM ===")
	print("Workstation: " + current_workstation)
	
	# Get corresponding input/output items
	if input_items.size() == 0 or output_items.size() == 0:
		print("ERROR: No recipe defined")
		return
		
	var input_item = input_items[0]
	var output_item = output_items[0]
	
	print("Recipe: " + input_item + " -> " + output_item)
	
	# Check if there's an item in the input slot
	var input_count = 0
	if input_slot.item_name == input_item:
		if input_slot.amount_label.text != "":
			input_count = int(input_slot.amount_label.text)
		else:
			input_count = 1
		print("Found " + str(input_count) + " " + input_item + " in input slot")
	
	if input_count <= 0:
		print("ERROR: No input items available")
		return
	
	# Process the items
	print("Processing " + str(input_count) + " " + input_item + " into " + output_item)
	
	# Update the output slot visually first
	if output_slot.has_method("setup"):
		output_slot.setup(output_item, "", true, input_count)
		print("Updated output slot with " + str(input_count) + " " + output_item)
	else:
		print("ERROR: Output slot missing setup method")
	
	# Update the input slot - clear it since we've processed its contents
	if input_slot.has_method("clear"):
		input_slot.clear()
		print("Cleared input slot")
	else:
		print("ERROR: Input slot missing clear method")
	
	# Save just to be safe
	SaveGame.save_game()
	print("Processing complete and game saved")
	
	# Emit signal that processing is complete
	process_complete.emit()

# New function to receive items from inventory UI
func add_input_item(item_name: String) -> void:
	print("====== PRODUCTION UI ADD_INPUT_ITEM CALLED WITH: " + item_name + " ======")
	
	# Check if this item is valid for this workstation
	if item_name in input_items:
		# Make sure we have this item in inventory
		if SaveGame.get_item_count(item_name) <= 0:
			print("Not enough " + item_name + " in inventory")
			return
		
		# Get current count if the slot already has this item
		var current_count = 0
		if input_slot.item_name == item_name and input_slot.amount_label.text != "":
			current_count = int(input_slot.amount_label.text)
		
		# Update the slot with the item and increment count
		input_slot.setup(item_name, "", true, current_count + 1)
		
		# Remove the item from inventory
		SaveGame.remove_from_inventory(item_name, 1)
		
		# Update the inventory UI - find ALL inventory UIs in the scene
		print("=== REFRESHING ALL INVENTORY UIs ===")
		
		# First find the Scheune UI
		var scheune_ui = _find_scheune_ui()
		if scheune_ui and scheune_ui.has_method("reload_slots"):
			print("Refreshing primary Scheune UI: " + str(scheune_ui.name))
			
			# Force complete rebuild of slots
			for slot_item in scheune_ui.slot_list:
				slot_item.queue_free()
			scheune_ui.slot_list.clear()
			scheune_ui.current_filter.clear()
			scheune_ui.reload_slots(false)
			scheune_ui.set_workstation_filter(current_workstation)
		
		# Save game to persist inventory changes
		SaveGame.save_game()
		print("Saved game after inventory update")
	else:
		print("Item " + item_name + " not valid for " + current_workstation)

# Helper function to find all Scheune UIs in the scene
func _find_scheune_ui():
	# First look for direct siblings
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if "inventory_ui" in child.name and child.has_method("reload_slots"):
				print("Found inventory UI as sibling: " + child.name)
				return child
	
	# If not found, look more broadly in the scene
	var root = get_tree().root
	var ui_found = null
	
	var search_queue = [root]
	while search_queue.size() > 0:
		var node = search_queue.pop_front()
		
		if "inventory_ui" in node.name and node.has_method("reload_slots"):
			ui_found = node
			break
			
		for child in node.get_children():
			search_queue.push_back(child)
	
	if ui_found:
		print("Found inventory UI in scene: " + ui_found.name)
	else:
		print("No inventory UI found in scene")
		
	return ui_found

# Helper function to find all nodes in the scene
func _find_all_nodes(node, result_array):
	result_array.push_back(node)
	for child in node.get_children():
		_find_all_nodes(child, result_array)
