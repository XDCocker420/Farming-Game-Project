extends PanelContainer

# Signal to notify when processing is complete
signal process_complete

# References to all slots
@onready var input_slot = $MarginContainer/slots/ui_slot
@onready var output_slot = $MarginContainer/slots/ui_slot2
# Reference to the new production button
@onready var produce_button = $Control/produce_button

# Current workstation information
var current_workstation: String = ""
var input_items = []
var output_items = []

func _ready():
	print("=== PRODUCTION UI READY ===")
	print("Checking button path: $MarginContainer/produce_button")
	
	# Debug print the node tree
	var node = get_node("MarginContainer")
	if node:
		print("Found MarginContainer")
		for child in node.get_children():
			print("Child of MarginContainer: " + child.name)
			# Also print children of children to find the button
			for grandchild in child.get_children():
				print("  - Grandchild: " + grandchild.name)
	else:
		print("WARNING: MarginContainer not found!")
	
	# Connect button signals for both slots
	for slot in [input_slot, output_slot]:
		if slot:
			print("Setting up slot: " + str(slot.name))
			# Enable input processing
			slot.mouse_filter = Control.MOUSE_FILTER_STOP
			slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			
			# Connect button signal if it exists
			if slot.has_node("button"):
				var button = slot.get_node("button")
				print("Found button for slot: " + str(slot.name))
				# Disconnect any existing connections first
				if button.pressed.is_connected(_on_slot_pressed.bind(slot)):
					button.pressed.disconnect(_on_slot_pressed.bind(slot))
				# Connect the signal
				button.pressed.connect(_on_slot_pressed.bind(slot))
				print("Connected button signal for slot: " + str(slot.name))
			else:
				print("WARNING: No button found for slot: " + str(slot.name))
			
			# For output slot, also connect direct input handling
			if slot == output_slot:
				print("Setting up direct input handling for output slot")
				if slot.gui_input.is_connected(_on_output_slot_input):
					slot.gui_input.disconnect(_on_output_slot_input)
				slot.gui_input.connect(_on_output_slot_input)
				# Also connect to the button if it exists
				if slot.has_node("button"):
					var button = slot.get_node("button")
					if button.pressed.is_connected(_on_output_slot_input):
						button.pressed.disconnect(_on_output_slot_input)
					button.pressed.connect(_on_output_slot_input)
		else:
			print("WARNING: Slot is null")
	
	# Try multiple possible paths for the produce button
	var possible_button_paths = [
		"Control/produce_button",
		"produce_button"
	]
	
	var button_found = false
	for path in possible_button_paths:
		var button = get_node_or_null(path)
		if button:
			print("Found produce button at path: " + path)
			produce_button = button
			button_found = true
			break
	
	if not button_found:
		print("WARNING: Produce button not found at any expected path")
		# Try to find the button in the scene tree
		var found_button = find_button_in_tree()
		if found_button:
			print("Found button at alternative path: " + str(found_button.get_path()))
			produce_button = found_button
			button_found = true
	
	if button_found:
		if not produce_button.pressed.is_connected(_on_produce_button_pressed):
			produce_button.pressed.connect(_on_produce_button_pressed)
			print("Connected production button signal")
		else:
			print("Production button signal already connected")
	else:
		print("ERROR: Could not find produce button anywhere in the scene!")
	
	# Debug check to verify this object has the required methods
	print("PRODUCTION UI: Method check - has_method('add_input_item'): ", has_method("add_input_item"))
	print("PRODUCTION UI: Method check - has_method('_process_single_item'): ", has_method("_process_single_item"))
	print("PRODUCTION UI: Method check - has_method('_on_slot_pressed'): ", has_method("_on_slot_pressed"))

# Helper function to find the button in the scene tree
func find_button_in_tree():
	var root = get_tree().root
	var search_queue = [root]
	
	while search_queue.size() > 0:
		var node = search_queue.pop_front()
		if node.name == "produce_button":
			print("Found button in scene tree at: " + str(node.get_path()))
			return node
		for child in node.get_children():
			search_queue.push_back(child)
	return null

# Handler for the produce button
func _on_produce_button_pressed():
	print("=== PRODUCE BUTTON PRESSED ===")
	print("Current workstation: " + current_workstation)
	print("Input items: " + str(input_items))
	print("Output items: " + str(output_items))
	
	# Check if we have valid input
	if input_slot and input_slot.item_name:
		print("Input slot has item: " + input_slot.item_name)
		if input_slot.amount_label.text != "":
			print("Input slot amount: " + input_slot.amount_label.text)
	else:
		print("No item in input slot")
	
	# Process the input items into output
	_process_single_item()

# Direct input handler for output slot
func _on_output_slot_input(event):
	print("=== OUTPUT SLOT INPUT EVENT ===")
	print("Event type: " + str(event.get_class()))
	if event is InputEventMouseButton:
		print("Mouse button event:")
		print("- Button index: " + str(event.button_index))
		print("- Pressed: " + str(event.pressed))
		print("- Position: " + str(event.position))
		print("- Global position: " + str(event.global_position))
		
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("=== DIRECT OUTPUT SLOT CLICK DETECTED ===")
			print("Output slot state:")
			print("- Item name: " + str(output_slot.item_name))
			print("- Has amount label: " + str(output_slot.has_node("amount")))
			if output_slot.has_node("amount"):
				print("- Amount label text: " + str(output_slot.get_node("amount").text))
			_handle_output_slot_click()

func _on_slot_pressed(slot):
	print("=== SLOT PRESSED ===")
	print("Slot name: " + str(slot.name))
	print("Is input slot: " + str(slot == input_slot))
	print("Is output slot: " + str(slot == output_slot))
	print("Slot state:")
	print("- Item name: " + str(slot.item_name))
	print("- Has amount label: " + str(slot.has_node("amount")))
	if slot.has_node("amount"):
		print("- Amount label text: " + str(slot.get_node("amount").text))
	
	if slot == input_slot:
		print("Input slot clicked: (ignored)")
		return
	elif slot == output_slot:
		print("Output slot clicked")
		_handle_output_slot_click()

# New consolidated function to handle output slot clicks
func _handle_output_slot_click():
	print("=== HANDLING OUTPUT SLOT CLICK ===")
	print("Output slot state:")
	print("- Item name: " + str(output_slot.item_name))
	print("- Has amount label: " + str(output_slot.has_node("amount")))
	
	# Get the correct amount label
	var amount_label = _get_amount_label(output_slot)
	if not amount_label:
		print("ERROR: Could not find amount label for output slot")
		return
		
	var item_count = 0
	if amount_label.text.strip_edges() != "":
		item_count = int(amount_label.text)
		print("Found amount label with text: " + amount_label.text)
	else:
		print("No amount found in output slot")
	
	if item_count > 0 and output_items.size() > 0:
		print("Transferring 1 " + output_items[0] + " back to inventory")
		# Add just one item to inventory
		SaveGame.add_to_inventory(output_items[0], 1)
		
		# Update the slot with one less item, or clear if it was the last one
		if item_count > 1:
			output_slot.setup(output_items[0], "", true, item_count - 1)
			print("Updated output slot, remaining: " + str(item_count - 1))
		else:
			# Clear the output slot if this was the last item
			output_slot.clear()
			print("Cleared output slot (last item taken)")
		
		# Refresh all inventory UIs to show the updated inventory
		_refresh_all_inventory_uis(current_workstation)
			
		# Save game to persist inventory changes
		SaveGame.save_game()
		print("Saved game after inventory update")
	else:
		print("Output slot is empty or no output items defined")

# Helper function to get the amount label from a slot
func _get_amount_label(slot) -> Label:
	if not slot:
		print("ERROR: Slot is null")
		return null
		
	print("Getting amount label for slot:")
	# Try direct path first
	if slot.has_node("amount"):
		var label = slot.get_node("amount")
		if label is Label:
			print("Found amount label at direct path")
			return label
		else:
			print("Found amount node but it's not a Label")
		
	# Try alternative paths
	var possible_paths = ["MarginContainer/amount", "amount_label", "MarginContainer/amount_label"]
	for path in possible_paths:
		if slot.has_node(path):
			var label = slot.get_node(path)
			if label is Label:
				print("Found amount label at path: " + path)
				return label
			else:
				print("Found node at " + path + " but it's not a Label")
				
	# Try accessing the property directly if it exists
	if "amount_label" in slot and slot.amount_label != null:
		if slot.amount_label is Label:
			print("Found amount label as property")
			return slot.amount_label
		else:
			print("Found amount_label property but it's not a Label")
			
	print("ERROR: Could not find valid amount label")
	return null

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
			input_items = ["corn"]
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
			print("(Re)connected button signal for slot: " + str(slot.name))
		else:
			print("WARNING: Failed to reconnect button for slot: " + (str(slot.name) if slot else "null"))
	
	# Reconnect the direct input handling for output slot
	if output_slot:
		print("Reconnecting gui_input handling for output slot")
		if output_slot.gui_input.is_connected(_on_output_slot_input):
			output_slot.gui_input.disconnect(_on_output_slot_input)
		output_slot.gui_input.connect(_on_output_slot_input)
	
	# Update produce button state - enable only if there are valid recipes
	if produce_button:
		produce_button.disabled = (input_items.size() == 0 or output_items.size() == 0)
	
	print("Recipe: " + str(input_items) + " -> " + str(output_items))
	
	# Debug print to verify setup
	print("Production UI setup complete for " + workstation_name)
	print("Input items: " + str(input_items))
	print("Output items: " + str(output_items))

func _process_single_item() -> void:
	print("=== PROCESSING ITEM ===")
	print("Workstation: " + current_workstation)
	
	# Get corresponding input/output items
	if input_items.size() == 0 or output_items.size() == 0:
		print("ERROR: No recipe defined")
		if produce_button:
			produce_button.disabled = true
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
	else:
		print("Input slot has wrong item or is empty. Expected: " + input_item + ", Got: " + str(input_slot.item_name))
	
	if input_count <= 0:
		print("ERROR: No input items available")
		return
	
	# Check if the output slot already has items
	var current_output_count = 0
	if output_slot.item_name == output_item and output_slot.amount_label.text != "":
		current_output_count = int(output_slot.amount_label.text)
		print("Current output count: " + str(current_output_count))
	
	# Process the items
	print("Processing " + str(input_count) + " " + input_item + " into " + output_item)
	
	# Update the output slot visually
	if output_slot.has_method("setup"):
		output_slot.setup(output_item, "", true, current_output_count + input_count)
		print("Updated output slot with " + str(current_output_count + input_count) + " " + output_item)
	else:
		print("ERROR: Output slot missing setup method")
	
	# Update the input slot - clear it since we've processed its contents
	if input_slot.has_method("clear"):
		input_slot.clear()
		print("Cleared input slot")
	else:
		print("ERROR: Input slot missing clear method")
	
	# Make sure to update any inventory UIs to reflect these changes
	_refresh_all_inventory_uis(current_workstation)
	
	# Save just to be safe
	SaveGame.save_game()
	print("Processing complete and game saved")
	
	# Disable the produce button until more input is added
	if produce_button:
		produce_button.disabled = true
		print("Disabled produce button")
	
	# Emit signal that processing is complete
	process_complete.emit()

# New function to receive items from inventory UI
func add_input_item(item_name: String) -> void:
	print("====== PRODUCTION UI ADD_INPUT_ITEM CALLED WITH: " + item_name + " ======")
	print("Current workstation: " + current_workstation)
	print("Input items allowed: " + str(input_items))
	print("Input slot state:")
	if input_slot:
		print("- Current item: " + str(input_slot.item_name))
		print("- Current amount: " + str(input_slot.amount_label.text if input_slot.amount_label and input_slot.amount_label.text != "" else "0"))
	else:
		print("- Input slot is null!")
	
	# Check if this item is valid for this workstation
	if item_name in input_items:
		# Make sure we have this item in inventory
		var inventory_count = SaveGame.get_item_count(item_name)
		print("Inventory has " + str(inventory_count) + " of " + item_name)
		
		if inventory_count <= 0:
			print("Not enough " + item_name + " in inventory")
			return
		
		# Get current count if the slot already has this item
		var current_count = 0
		if input_slot.item_name == item_name and input_slot.amount_label.text != "":
			current_count = int(input_slot.amount_label.text)
		
		# Remove the item from inventory FIRST
		SaveGame.remove_from_inventory(item_name, 1)
		print("Removed 1 " + item_name + " from inventory")
		
		# Update the slot with the item and increment count
		input_slot.setup(item_name, "", true, current_count + 1)
		print("Added to input slot, new count: " + str(current_count + 1))
		
		# Enable the produce button since we now have valid input
		if produce_button:
			produce_button.disabled = false
		
		# Update the inventory UI - find ALL inventory UIs in the scene
		print("=== REFRESHING ALL INVENTORY UIs ===")
		
		# First find the Scheune UI through comprehensive search
		_refresh_all_inventory_uis(current_workstation)
		
		# Save game to persist inventory changes
		SaveGame.save_game()
		print("Saved game after inventory update")
	else:
		print("Item " + item_name + " not valid for " + current_workstation)

# New function to refresh ALL inventory UIs in the scene
func _refresh_all_inventory_uis(workstation: String):
	var all_nodes = []
	_find_all_nodes(get_tree().root, all_nodes)
	
	var found_any_ui = false
	
	for node in all_nodes:
		if "inventory_ui" in node.name and node.has_method("reload_slots"):
			print("Found inventory UI to refresh: " + node.name)
			found_any_ui = true
			
			# Force complete rebuild of slots
			if node.has_method("reload_slots"):
				# Check if it has slot_list property in a safe way
				if "slot_list" in node:
					for slot_item in node.slot_list:
						slot_item.queue_free()
					node.slot_list.clear()
				
				# Even if we couldn't clear slots individually, try to reload
				if "current_filter" in node:
					node.current_filter.clear()
				node.reload_slots(false) # First load all items
				
				# Then apply the filter if the method exists
				if node.has_method("set_workstation_filter"):
					node.set_workstation_filter(workstation)
	
	if !found_any_ui:
		print("WARNING: No inventory UIs found to refresh!")
	
	# Force UI update
	call_deferred("_force_ui_update")

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
		
# Helper function to force UI update
func _force_ui_update():
	# This empty method is called deferred to force the UI to update in the next frame
	pass

func _input(event):
	print("=== GLOBAL INPUT EVENT ===")
	print("Event type: " + str(event.get_class()))
	if event is InputEventMouseButton:
		print("Mouse button event:")
		print("- Button index: " + str(event.button_index))
		print("- Pressed: " + str(event.pressed))
		print("- Position: " + str(event.position))
		print("- Global position: " + str(event.global_position))
		
		# Check if the click is within the output slot's bounds
		if output_slot:
			# Get the output slot's global position and size
			var slot_global_pos = output_slot.global_position
			var slot_size = output_slot.size
			print("Output slot:")
			print("- Global position: " + str(slot_global_pos))
			print("- Size: " + str(slot_size))
			print("- Local position: " + str(output_slot.position))
			print("- Parent: " + str(output_slot.get_parent().name if output_slot.get_parent() else "none"))
			
			# Convert global click position to local position relative to the slot
			var local_pos = output_slot.get_global_mouse_position() - slot_global_pos
			print("Click local position: " + str(local_pos))
			
			# Check if the click is within the slot's bounds
			if local_pos.x >= 0 and local_pos.x < slot_size.x and local_pos.y >= 0 and local_pos.y < slot_size.y:
				print("Click is within output slot bounds!")
				_handle_output_slot_click()
			else:
				print("Click is outside output slot bounds")
				print("Bounds check:")
				print("- X: " + str(local_pos.x) + " >= 0 && " + str(local_pos.x) + " < " + str(slot_size.x))
				print("- Y: " + str(local_pos.y) + " >= 0 && " + str(local_pos.y) + " < " + str(slot_size.y))
