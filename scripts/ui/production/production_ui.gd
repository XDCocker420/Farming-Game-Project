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
	# Connect button signals for both slots
	for slot in [input_slot, output_slot]:
		if slot:
			# Enable input processing
			slot.mouse_filter = Control.MOUSE_FILTER_STOP
			slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			
			# Connect button signal if it exists
			if slot.has_node("button"):
				var button = slot.get_node("button")
				# Disconnect any existing connections first
				if button.pressed.is_connected(_on_slot_pressed.bind(slot)):
					button.pressed.disconnect(_on_slot_pressed.bind(slot))
				# Connect the signal
				button.pressed.connect(_on_slot_pressed.bind(slot))
			
			# For output slot, also connect direct input handling
			if slot == output_slot:
				if slot.gui_input.is_connected(_on_output_slot_input):
					slot.gui_input.disconnect(_on_output_slot_input)
				slot.gui_input.connect(_on_output_slot_input)
				# Also connect to the button if it exists
				if slot.has_node("button"):
					var button = slot.get_node("button")
					if button.pressed.is_connected(_on_output_slot_input):
						button.pressed.disconnect(_on_output_slot_input)
					button.pressed.connect(_on_output_slot_input)
	
	# Try multiple possible paths for the produce button
	var possible_button_paths = [
		"Control/produce_button",
		"produce_button",
		"/Control/produce_button",
		"../Control/produce_button",
		"../../Control/produce_button"
	]
	
	var button_found = false
	for path in possible_button_paths:
		var button = get_node_or_null(path)
		if button:
			produce_button = button
			button_found = true
			break
	
	if not button_found:
		# Try to find the button by name
		var found_button = find_button_by_name()
		if found_button:
			produce_button = found_button
			button_found = true
		else:
			# Try to find the button in the scene tree
			found_button = find_button_in_tree()
			if found_button:
				produce_button = found_button
				button_found = true
	
	if button_found:
		# Make sure the button is properly set up
		produce_button.mouse_filter = Control.MOUSE_FILTER_STOP
		produce_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		# Disconnect any existing connections
		if produce_button.pressed.is_connected(_on_produce_button_pressed):
			produce_button.pressed.disconnect(_on_produce_button_pressed)
		
		# Connect to the pressed signal
		produce_button.pressed.connect(_on_produce_button_pressed)
		
		# Make sure button is visible and enabled
		produce_button.visible = true
		produce_button.disabled = false
		
		# Add direct input handling as a fallback
		if produce_button.gui_input.is_connected(_on_produce_button_input):
			produce_button.gui_input.disconnect(_on_produce_button_input)
		produce_button.gui_input.connect(_on_produce_button_input)
	else:
		# Try to find any button in the scene that might be the produce button
		var parent_buttons = find_buttons_in_parent()
		if parent_buttons.size() > 0:
			# Use the first button as a fallback
			produce_button = parent_buttons[0]
			produce_button.pressed.connect(_on_produce_button_pressed)

# Helper function to find buttons in the parent nodes
func find_buttons_in_parent():
	var buttons = []
	var parent = get_parent()
	
	while parent:
		for child in parent.get_children():
			if child is Button or child is TextureButton:
				buttons.append(child)
				
		parent = parent.get_parent()
	
	return buttons

# Helper function to find the button by name
func find_button_by_name():
	var root = get_tree().root
	var possible_names = ["produce_button", "start_button", "start", "produce"]
	
	var stack = [root]
	while stack.size() > 0:
		var node = stack.pop_front()
		
		# Check if this node's name matches any of our possible names
		if node is Button or node is TextureButton:
			for name in possible_names:
				if name.to_lower() in node.name.to_lower():
					return node
		
		# Add children to the stack
		for child in node.get_children():
			stack.append(child)
	
	return null

# Helper function to find the button in the scene tree
func find_button_in_tree():
	var root = get_tree().root
	var search_queue = [root]
	
	while search_queue.size() > 0:
		var node = search_queue.pop_front()
		if node.name == "produce_button" or (node is Button or node is TextureButton):
			return node
		for child in node.get_children():
			search_queue.push_back(child)
	return null

# Direct input handler for produce button as a fallback
func _on_produce_button_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_produce_button_pressed()

# Handler for the produce button
func _on_produce_button_pressed():
	# Check if we have valid input
	if input_slot and input_slot.item_name:
		# Process the input items into output
		_process_single_item()

# Direct input handler for output slot
func _on_output_slot_input(event):
	if event is InputEventMouseButton:
		# Nur bei Mouse-Down (pressed=true) die Aktion ausführen, nicht bei Mouse-Up
		# UND nur bei linker Maustaste (MOUSE_BUTTON_LEFT)
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Wir brauchen diese Aktion nicht auszuführen, da _on_slot_pressed sie bereits ausführt
			_handle_output_slot_click()

func _on_slot_pressed(slot):
	if slot == input_slot:
		return
	elif slot == output_slot:
		_handle_output_slot_click()

# New consolidated function to handle output slot clicks
func _handle_output_slot_click():
	# Get the correct amount label
	var amount_label = _get_amount_label(output_slot)
	if not amount_label:
		return
		
	var item_count = 0
	if amount_label.text.strip_edges() != "":
		item_count = int(amount_label.text)
	
	if item_count > 0 and output_items.size() > 0:
		# Add just one item to inventory
		SaveGame.add_to_inventory(output_items[0], 1)
		
		# Update the slot with one less item, or clear if it was the last one
		if item_count > 1:
			output_slot.setup(output_items[0], "", true, item_count - 1)
		else:
			# Clear the output slot if this was the last item
			output_slot.clear()
		
		# Use the optimized refresh method
		_refresh_targeted_inventory_ui(current_workstation)
			
		# Save game to persist inventory changes - but deferred for better performance
		call_deferred("_save_game_deferred")

# Helper function to get the amount label from a slot
func _get_amount_label(slot) -> Label:
	if not slot:
		return null
		
	# Try direct path first
	if slot.has_node("amount"):
		var label = slot.get_node("amount")
		if label is Label:
			return label
		
	# Try alternative paths
	var possible_paths = ["MarginContainer/amount", "amount_label", "MarginContainer/amount_label"]
	for path in possible_paths:
		if slot.has_node(path):
			var label = slot.get_node(path)
			if label is Label:
				return label
				
	# Try accessing the property directly if it exists
	if "amount_label" in slot and slot.amount_label != null:
		if slot.amount_label is Label:
			return slot.amount_label
			
	return null

func setup(workstation_name: String):
	current_workstation = workstation_name
	
	# Set production UI reference for both slots
	if input_slot and input_slot.has_method("set_production_ui"):
		input_slot.set_production_ui(self)
	
	if output_slot and output_slot.has_method("set_production_ui"):
		output_slot.set_production_ui(self)
	
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
	
	# Reconnect the direct input handling for output slot
	if output_slot:
		if output_slot.gui_input.is_connected(_on_output_slot_input):
			output_slot.gui_input.disconnect(_on_output_slot_input)
		output_slot.gui_input.connect(_on_output_slot_input)
	
	# Update produce button state - enable only if there are valid recipes
	if produce_button:
		produce_button.disabled = (input_items.size() == 0 or output_items.size() == 0)

func _process_single_item() -> void:
	# Get corresponding input/output items
	if input_items.size() == 0 or output_items.size() == 0:
		if produce_button:
			produce_button.disabled = true
		return
		
	var input_item = input_items[0]
	var output_item = output_items[0]
	
	# Check if there's an item in the input slot
	var input_count = 0
	if input_slot.item_name == input_item:
		if "amount_label" in input_slot and input_slot.amount_label and input_slot.amount_label.text != "":
			input_count = int(input_slot.amount_label.text)
		elif input_slot.has_node("amount"):
			var amount_label = input_slot.get_node("amount")
			if amount_label.text != "":
				input_count = int(amount_label.text)
		else:
			input_count = 1
	
	if input_count <= 0:
		return
	
	# Check if the output slot already has items
	var current_output_count = 0
	if output_slot.item_name == output_item:
		if "amount_label" in output_slot and output_slot.amount_label and output_slot.amount_label.text != "":
			current_output_count = int(output_slot.amount_label.text)
		elif output_slot.has_node("amount"):
			var amount_label = output_slot.get_node("amount")
			if amount_label.text != "":
				current_output_count = int(amount_label.text)
	
	# Update the output slot visually
	# Direct manipulation first
	output_slot.item_name = output_item
	if output_slot.has_node("MarginContainer/item"):
		var texture_path = "res://assets/ui/icons/" + output_item + ".png"
		output_slot.get_node("MarginContainer/item").texture = load(texture_path)
	
	if output_slot.has_node("amount"):
		output_slot.get_node("amount").text = str(current_output_count + input_count)
		output_slot.get_node("amount").show()
	
	# Also try the method
	if output_slot.has_method("setup"):
		output_slot.setup(output_item, "", true, current_output_count + input_count)
	
	# Clear the input slot - both directly and via method
	input_slot.item_name = ""
	if input_slot.has_node("MarginContainer/item"):
		input_slot.get_node("MarginContainer/item").texture = null
	
	if input_slot.has_node("amount"):
		input_slot.get_node("amount").text = ""
		input_slot.get_node("amount").hide()
	
	# Also try the method
	if input_slot.has_method("clear"):
		input_slot.clear()
	
	# Use the optimized refresh method for better performance
	_refresh_targeted_inventory_ui(current_workstation)
	
	# Save just to be safe - but deferred for better performance
	call_deferred("_save_game_deferred")
	
	# Disable the produce button until more input is added
	if produce_button:
		produce_button.disabled = true
	
	# Emit signal that processing is complete
	process_complete.emit()

# New function to receive items from inventory UI
func add_input_item(item_name: String) -> void:
	# Check if this item is valid for this workstation
	if not (item_name in input_items):
		return
		
	# Make sure we have this item in inventory - do this FIRST to avoid race conditions
	var inventory_count = SaveGame.get_item_count(item_name)
	
	if inventory_count <= 0:
		return
		
	# Verify input_slot is properly initialized
	if not input_slot:
		return
	
	# Get current count if the slot already has this item
	var current_count = 0
	if input_slot.item_name == item_name:
		if input_slot.has_node("amount"):
			var amount_label = input_slot.get_node("amount")
			if amount_label.text.strip_edges() != "":
				current_count = int(amount_label.text)
		elif "amount_label" in input_slot and input_slot.amount_label:
			if input_slot.amount_label.text.strip_edges() != "":
				current_count = int(input_slot.amount_label.text)
		else:
			current_count = 1
	
	# Calculate new count
	var new_count = current_count + 1
	
	# Remove the item from inventory FIRST - this must be done before updating UI
	# to avoid race conditions with reload_slots
	SaveGame.remove_from_inventory(item_name, 1)
	
	# IMPORTANT: Save game IMMEDIATELY after inventory modification to prevent
	# race conditions with reload_slots
	SaveGame.save_game()
	
	# Update the UI immediately for better responsiveness with rapid clicks
	_update_input_slot(item_name, new_count)
	
	# Enable the produce button since we now have valid input
	if produce_button:
		produce_button.disabled = false
	
	# Use a very short timer to refresh inventory UI to handle rapid clicks better
	var refresh_timer = get_tree().create_timer(0.12)
	refresh_timer.timeout.connect(func(): _refresh_targeted_inventory_ui(current_workstation))

# Method to update the input slot safely in deferred context
func _update_input_slot(item_name, new_count):
	# Use the setup method whenever possible as it's most reliable
	if input_slot.has_method("setup"):
		input_slot.setup(item_name, "", true, new_count)
	else:
		# Fallback to direct property updates
		input_slot.item_name = item_name
		
		# Try multiple paths to update the texture
		var texture_path = "res://assets/ui/icons/" + item_name + ".png"
		var texture = load(texture_path)
		
		if input_slot.has_node("MarginContainer/item"):
			input_slot.get_node("MarginContainer/item").texture = texture
		
		# Try multiple paths to update the amount label
		var amount_updated = false
		
		if input_slot.has_node("amount"):
			var amount_label = input_slot.get_node("amount")
			amount_label.text = str(new_count)
			amount_label.show()
			amount_updated = true
		
		if not amount_updated and "amount_label" in input_slot and input_slot.amount_label:
			input_slot.amount_label.text = str(new_count)
			input_slot.amount_label.show()

# Helper function to find all Scheune UIs in the scene
func _find_scheune_ui():
	# First look for direct siblings with priority for ones matching the workstation name
	var parent = get_parent()
	if parent:
		# First look for inventory UIs that match our current workstation
		for child in parent.get_children():
			if current_workstation in child.name and "inventory_ui" in child.name and child.has_method("reload_slots"):
				return child
				
		# If not found, look for any inventory UI
		for child in parent.get_children():
			if "inventory_ui" in child.name and child.has_method("reload_slots"):
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
		
	return ui_found

# More efficient function to refresh just the relevant inventory UI
func _refresh_targeted_inventory_ui(workstation: String):
	# First try to find the inventory UI directly - prioritize exact match
	var scheune_ui = null
	
	# Get parent node
	var parent = get_parent()
	if parent:
		# First try exact match with workstation name
		for child in parent.get_children():
			if workstation in child.name and "inventory_ui" in child.name and child.has_method("reload_slots"):
				scheune_ui = child
				break
				
		# If not found, try any inventory UI
		if not scheune_ui:
			for child in parent.get_children():
				if "inventory_ui" in child.name and child.has_method("reload_slots"):
					scheune_ui = child
					break
	
	if scheune_ui and scheune_ui.has_method("reload_slots"):
		# Update this specific inventory UI
		if scheune_ui.has_method("set_workstation_filter"):
			scheune_ui.set_workstation_filter(workstation)
		scheune_ui.reload_slots(true)
		return
	
	# Fallback method - use find_scheune_ui as backup
	scheune_ui = _find_scheune_ui()
	if scheune_ui and scheune_ui.has_method("reload_slots"):
		if scheune_ui.has_method("set_workstation_filter"):
			scheune_ui.set_workstation_filter(workstation)
		scheune_ui.reload_slots(true)

# Deferred save game function to improve performance
func _save_game_deferred():
	SaveGame.save_game()

# New function to refresh ALL inventory UIs in the scene
func _refresh_all_inventory_uis(workstation: String):
	var all_nodes = []
	_find_all_nodes(get_tree().root, all_nodes)
	
	for node in all_nodes:
		if "inventory_ui" in node.name and node.has_method("reload_slots"):
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
	
	# Force UI update
	call_deferred("_force_ui_update")

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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# First, check for clicks on the produce button
		if produce_button:
			var button_global_pos = produce_button.global_position
			var button_size = produce_button.size
			var mouse_pos = produce_button.get_global_mouse_position()
			
			# Check if click is within button bounds
			if mouse_pos.x >= button_global_pos.x and mouse_pos.x < button_global_pos.x + button_size.x and \
			   mouse_pos.y >= button_global_pos.y and mouse_pos.y < button_global_pos.y + button_size.y:
				_on_produce_button_pressed()
		
		# Check if the click is within the output slot's bounds
		if output_slot:
			# Get the output slot's global position and size
			var slot_global_pos = output_slot.global_position
			var slot_size = output_slot.size
			
			# Convert global click position to local position relative to the slot
			var local_pos = output_slot.get_global_mouse_position() - slot_global_pos
			
			# Check if the click is within the slot's bounds
			if local_pos.x >= 0 and local_pos.x < slot_size.x and local_pos.y >= 0 and local_pos.y < slot_size.y:
				_handle_output_slot_click()
