extends PanelContainer

# Signal to notify when processing is complete
signal process_complete
signal production_started

# References to all slots
@onready var input_slot = $MarginContainer/slots/ui_slot
@onready var input_slot2 = $MarginContainer/slots/ui_slot2  # Zweiter Input-Slot für später
@onready var output_slot = $MarginContainer/slots/ui_slot3  # Neuer Output-Slot
# Reference to the new production button
@onready var produce_button = $Control/PanelContainer/produce_button
# Progress tracking
@onready var progress_bar: ProgressBar = $Control/ProgressBar

# Current workstation information
var current_workstation: String = ""
var input_items = []
var output_items = []
# Add a properly declared variable for tracking last add time
var last_add_time: int = 0
var production_in_progress: bool = false
var production_timer: float = 0.0
var production_duration: float = 0.0
var item_config: ConfigFile

func _ready():
	# Initialize our cooldown tracker
	last_add_time = 0
	
	# Connect button signals for all slots
	for slot in [input_slot, input_slot2, output_slot]:
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
	
	# VERBESSERT: Direkterer und einfacherer Weg, den Produktion-Button zu finden
	produce_button = $Control/PanelContainer/produce_button
	
	# Wenn der Button nicht direkt gefunden wurde, suche ihn
	if not produce_button:
		produce_button = find_child("produce_button", true)
	
	# Wenn wir den Button gefunden haben, konfiguriere ihn
	if produce_button:
		# Make sure the button is properly set up with better visual feedback
		produce_button.mouse_filter = Control.MOUSE_FILTER_STOP
		produce_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		produce_button.focus_mode = Control.FOCUS_ALL
		
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
	
	# Load item configuration for production durations
	item_config = ConfigFile.new()
	var err = item_config.load("res://scripts/config/item_config.cfg")
	if err != OK:
		push_error("Failed to load item_config.cfg: %s" % err)
	
	# Hide progress bar at start
	progress_bar.hide()

# Neue Hilfsfunktion, um rekursiv alle Kinder zu erhalten
func get_children_recursive(node):
	var children = []
	for child in node.get_children():
		children.append(child)
		children.append_array(get_children_recursive(child))
	return children

# Direct input handler for produce button as a fallback
func _on_produce_button_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_produce_button_pressed()

# Handler for the produce button
func _on_produce_button_pressed():
	# Sicherstellen, dass der Button nur einmal pro Klick ausgelöst wird
	if (Time.get_ticks_msec() - last_add_time) < 150:
		return

	last_add_time = Time.get_ticks_msec()

	# Check if we have valid input items visually present and not already producing
	if not production_in_progress and _has_required_inputs_visual():
		
		# --- START: Item Removal Logic ---
		# Remove items from SaveGame *before* starting production
		var items_removed_successfully = true
		var item_that_failed = "" # Variable to store the item causing failure
		
		for required_item in input_items:
			# Find which slot holds the item
			var slot_to_remove_from = null
			if input_slot and input_slot.item_name == required_item:
				slot_to_remove_from = input_slot
			elif input_slot2 and input_slot2.item_name == required_item:
				slot_to_remove_from = input_slot2

			if slot_to_remove_from:
				# Check inventory count *before* attempting removal
				if SaveGame.get_item_count(required_item) > 0:
					SaveGame.remove_from_inventory(required_item, 1)
					# Update the visual count in the input slot immediately after removal
					var current_count = 0
					var amount_label = _get_amount_label(slot_to_remove_from)
					if amount_label and amount_label.text.strip_edges() != "":
						current_count = int(amount_label.text)
					
					if current_count > 1:
						_update_input_slot_with_target(slot_to_remove_from, required_item, current_count - 1)
					else:
						slot_to_remove_from.clear() # Clear slot if it was the last one visually

				else:
					# This case should ideally not happen if UI is consistent, but good to handle
					push_warning("Attempted to start production but SaveGame inventory count for %s was 0." % required_item)
					items_removed_successfully = false
					item_that_failed = required_item # Store the failing item
					break # Stop processing if an item is missing
			else:
				# This also shouldn't happen if _has_required_inputs_visual is correct
				push_warning("Attempted to start production but couldn't find visual slot for %s." % required_item)
				items_removed_successfully = false
				item_that_failed = required_item # Store the failing item
				break

		if not items_removed_successfully:
			# Refresh UI to reflect actual SaveGame state if removal failed
			# This time, visually ADD BACK the item that failed removal
			if item_that_failed != "": # Ensure we have a valid item name
				_refresh_targeted_inventory_ui(current_workstation, item_that_failed, 1)
			# Optionally, also trigger a full refresh for the production UI itself to be safe
			# setup(current_workstation) # Uncomment if needed
			return # Don't start production

		# Save game *after* successfully removing all items
		SaveGame.save_game()
		# --- END: Item Removal Logic ---

		# Read duration from config (default to 1s)
		var out_item = output_items[0] if output_items.size() > 0 else ""
		production_duration = float(item_config.get_value(out_item, "time")) if item_config and item_config.has_section(out_item) else 1.0
		production_timer = 0.0
		production_in_progress = true
		
		# Setup progress bar
		progress_bar.min_value = 0
		progress_bar.max_value = production_duration
		progress_bar.value = 0
		progress_bar.show()
		
		# Disable interactions during production
		produce_button.disabled = true
		input_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE # Disable clicking input slots
		if input_slot2: input_slot2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		output_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE # Disable clicking output slot during production

		# Notify that production has started so the tool animation can play
		emit_signal("production_started")
		
		# Refresh inventory UI one last time after SaveGame changes
		_refresh_targeted_inventory_ui(current_workstation)

# Direct input handler for output slot
func _on_output_slot_input(event):
	# Allow clicking output slot ONLY if production is NOT in progress
	if not production_in_progress and event is InputEventMouseButton:
		# Nur bei Mouse-Down (pressed=true) die Aktion ausführen, nicht bei Mouse-Up
		# UND nur bei linker Maustaste (MOUSE_BUTTON_LEFT)
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Wir brauchen diese Aktion nicht auszuführen, da _on_slot_pressed sie bereits ausführt
			_handle_output_slot_click()

func _on_slot_pressed(slot):
	# Allow clicking slots ONLY if production is NOT in progress
	if production_in_progress:
		return
		
	if slot == input_slot:
		# Allow removing items from input slots maybe? (Future feature)
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
	
	# Set production UI reference for all slots
	if input_slot and input_slot.has_method("set_production_ui"):
		input_slot.set_production_ui(self)
	
	if input_slot2 and input_slot2.has_method("set_production_ui"):
		input_slot2.set_production_ui(self)
	
	if output_slot and output_slot.has_method("set_production_ui"):
		output_slot.set_production_ui(self)
	
	# Clear INPUT slots only
	if input_slot and input_slot.has_method("clear"):
		input_slot.clear()
	
	if input_slot2 and input_slot2.has_method("clear"):
		input_slot2.clear()
	
	# Reset our stored items *before* checking output slot
	var previous_output_items = output_items.duplicate()
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
			input_items = ["milk", "egg"]
			output_items = ["mayo"]
		"clothmaker":
			input_items = ["white_wool", "white_string"]
			output_items = ["white_cloth"]
		"spindle":
			input_items = ["white_wool"]
			output_items = ["white_string"]
		"feed_mill":
			input_items = ["corn"]
			output_items = ["feed"]
	
	# Check OUTPUT slot: Clear it ONLY if it doesn't contain the correct output item
	if output_slot and output_slot.has_method("clear"):
		var expected_output = output_items[0] if not output_items.is_empty() else ""
		if output_slot.item_name != expected_output:
			output_slot.clear()
		# If item_name is correct, leave the output slot as is.
	
	# Reconnect button signals for all slots
	for slot in [input_slot, input_slot2, output_slot]:
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
	# Get corresponding output item
	if output_items.size() == 0:
		push_warning("Production complete but no output item defined for %s" % current_workstation)
		# Still emit complete signal so animation stops etc.
		process_complete.emit()
		return
	
	var output_item = output_items[0]
	
	# Check if the output slot already has items of the same type
	var current_output_count = 0
	if output_slot.item_name == output_item:
		var amount_label = _get_amount_label(output_slot)
		if amount_label and amount_label.text.strip_edges() != "":
			current_output_count = int(amount_label.text)
		elif output_slot.item_name != "": # Assume 1 if item name is set but label empty
			current_output_count = 1
			
	# Update the output slot's visual state
	output_slot.setup(output_item, "", true, current_output_count + 1)
	
	# --- We already removed input items from SaveGame in _on_produce_button_pressed ---
	# --- We already updated the visual input slots there too ---
	
	# Use the optimized refresh method for better performance (might not be needed here)
	# _refresh_targeted_inventory_ui(current_workstation) 
	
	# --- No need to save game here, was saved when production started ---
	# call_deferred("_save_game_deferred")
	
	# Disable the produce button until more input is added VISUALLY
	if produce_button:
		produce_button.disabled = not _has_required_inputs_visual()
	
	# Emit signal that processing is complete
	process_complete.emit()

# New function to receive items from inventory UI
func add_input_item(item_name: String) -> void:
	# Check if this item is valid for this workstation
	if not (item_name in input_items):
		# print("Item %s not valid for workstation %s" % [item_name, current_workstation])
		return

	# Make sure we have this item in inventory - check this FIRST
	var inventory_count = SaveGame.get_item_count(item_name)
	if inventory_count <= 0:
		# print("No %s in SaveGame inventory." % item_name)
		return

	# Add cooldown check to prevent multiple calls
	if (Time.get_ticks_msec() - last_add_time) < 100:
		# print("Cooldown active, skipping add_input_item")
		return

	# Store the current time
	last_add_time = Time.get_ticks_msec()

	# Determine which slot to use
	var target_slot = null
	var other_slot = null

	# First check if either slot already has this item
	if input_slot and input_slot.item_name == item_name:
		target_slot = input_slot
		other_slot = input_slot2
	elif input_slot2 and input_slot2.item_name == item_name:
		target_slot = input_slot2
		other_slot = input_slot
	else:
		# If neither slot has this item, use the first empty slot we find
		if input_slot and input_slot.item_name == "":
			target_slot = input_slot
			other_slot = input_slot2
		elif input_slot2 and input_slot2.item_name == "":
			target_slot = input_slot2
			other_slot = input_slot
		else:
			# If both slots are full but one has a different item, use the first slot
			# This logic might need refinement depending on desired behavior for replacing items
			target_slot = input_slot 
			other_slot = input_slot2

	if not target_slot:
		# print("No target slot found.")
		return

	# Get current count if the slot already has this item
	var current_count = 0
	if target_slot.item_name == item_name:
		var amount_label = _get_amount_label(target_slot)
		if amount_label and amount_label.text.strip_edges() != "":
			current_count = int(amount_label.text)
		# If label is empty but item name is set, assume count is 1 (visual only)
		elif target_slot.item_name != "": 
			current_count = 1 
			
	# Calculate new count - only add one at a time
	var new_count = current_count + 1

	# --- REMOVED SaveGame modifications ---
	# # Remove the item from inventory FIRST - this must be done before updating UI
	# # to avoid race conditions with reload_slots
	# SaveGame.remove_from_inventory(item_name, 1)
	#
	# # IMPORTANT: Save game IMMEDIATELY after inventory modification to prevent
	# # race conditions with reload_slots
	# SaveGame.save_game()
	# --- END REMOVED ---

	# Update the UI immediately for better responsiveness with rapid clicks
	_update_input_slot_with_target(target_slot, item_name, new_count)
	
	# Enable the produce button if we have all required inputs VISUALLY
	if produce_button:
		produce_button.disabled = not _has_required_inputs_visual()

	# Use a very short timer to refresh inventory UI to handle rapid clicks better
	# This refresh is important to show the *actual* inventory count from SaveGame
	# NO LONGER USING TIMER FOR THIS - DIRECT VISUAL UPDATE NOW
	# var refresh_timer = get_tree().create_timer(0.08) # Schnellere Aktualisierung
	# refresh_timer.timeout.connect(func(): _refresh_targeted_inventory_ui(current_workstation))

	# INSTEAD: Directly tell the inventory UI to visually decrement the count
	print("[ProductionUI] Calling refresh to visually adjust item: ", item_name, " by -1")
	_refresh_targeted_inventory_ui(current_workstation, item_name, -1)

# New helper function to update a specific input slot
func _update_input_slot_with_target(target_slot, item_name, new_count):
	# Use the setup method whenever possible as it's most reliable
	if target_slot.has_method("setup"):
		target_slot.setup(item_name, "", true, new_count)
	else:
		# Fallback to direct property updates
		target_slot.item_name = item_name
		
		# Try multiple paths to update the texture
		var texture_path = "res://assets/ui/icons/" + item_name + ".png"
		var texture = load(texture_path)
		
		if target_slot.has_node("MarginContainer/item"):
			target_slot.get_node("MarginContainer/item").texture = texture
		
		# Try multiple paths to update the amount label
		var amount_updated = false
		
		var amount_label = _get_amount_label(target_slot)
		if amount_label:
			amount_label.text = str(new_count)
			amount_label.show()
			amount_updated = true

# Helper function to check if required inputs are visually present in slots
func _has_required_inputs_visual() -> bool:
	var present_inputs = {}
	
	# Check first input slot
	if input_slot and input_slot.item_name != "":
		present_inputs[input_slot.item_name] = true
		
	# Check second input slot (if it exists and is used)
	if input_slot2 and input_slot2.item_name != "":
		present_inputs[input_slot2.item_name] = true

	# Verify all required inputs are present visually
	for required_item in input_items:
		if not present_inputs.has(required_item):
			return false
			
	return true

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
# OR adjust visual count for a specific item
func _refresh_targeted_inventory_ui(workstation: String, item_to_adjust: String = "", adjustment: int = 0):
	# First try to find the inventory UI directly - prioritize exact match
	var scheune_ui = null
	
	# Get parent node
	var parent = get_parent()
	if parent:
		# First try exact match with workstation name
		for child in parent.get_children():
			if workstation in child.name and "inventory_ui" in child.name and child.has_method("reload_slots"): # Check for reload_slots for safety
				scheune_ui = child
				break
				
		# If not found, try any inventory UI that looks like a scheune
		if not scheune_ui:
			for child in parent.get_children():
				if "scheune" in child.name and child.has_method("reload_slots"):
					scheune_ui = child
					break
		
		# Fallback to generic inventory_ui name
		if not scheune_ui:
			for child in parent.get_children():
				if "inventory_ui" in child.name and child.has_method("reload_slots"):
					scheune_ui = child
					break

	if scheune_ui:
		if item_to_adjust != "" and adjustment != 0 and scheune_ui.has_method("adjust_visual_count"):
			# Adjust visual count directly if requested
			print("[ProductionUI] Found scheune UI (", scheune_ui.name, "), calling adjust_visual_count(", item_to_adjust, ", ", adjustment, ")")
			scheune_ui.adjust_visual_count(item_to_adjust, adjustment)
			return # <--- ADD RETURN HERE to stop execution after visual adjustment
		elif scheune_ui.has_method("reload_slots"): # Check again for safety
			# Otherwise, do a full reload (e.g., when production finishes or fails)
			print("[ProductionUI] Found scheune UI (", scheune_ui.name, "), calling reload_slots")
			if scheune_ui.has_method("set_workstation_filter"): # Check method existence
				scheune_ui.set_workstation_filter(workstation)
			scheune_ui.reload_slots(true)
		else:
			push_warning("Found Scheune UI, but it's missing required methods (reload_slots or adjust_visual_count).")
			return
	
	# Fallback method - use find_scheune_ui as backup IF FULL RELOAD NEEDED
	if item_to_adjust == "" and adjustment == 0:
		scheune_ui = _find_scheune_ui() # This finds any inventory_ui
		if scheune_ui and scheune_ui.has_method("reload_slots"): 
			if scheune_ui.has_method("set_workstation_filter"): # Check method existence
				scheune_ui.set_workstation_filter(workstation)
			scheune_ui.reload_slots(true)
		# else: 
		#	 push_warning("Targeted inventory UI refresh failed: Could not find a suitable inventory UI.")

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
		# Zuerst prüfen, ob auf den Output-Slot geklickt wurde
		var clicked_on_output = false
		if output_slot:
			# Output-Slot Position und Größe
			var slot_global_pos = output_slot.global_position
			var slot_size = output_slot.size
			var mouse_pos = output_slot.get_global_mouse_position()
			
			# Prüfen, ob Klick innerhalb des Output-Slots ist
			if mouse_pos.x >= slot_global_pos.x and mouse_pos.x < slot_global_pos.x + slot_size.x and \
			   mouse_pos.y >= slot_global_pos.y and mouse_pos.y < slot_global_pos.y + slot_size.y:
				clicked_on_output = true
				_handle_output_slot_click()
		
		# Nur den Produce-Button-Klick überprüfen, wenn NICHT auf den Output-Slot geklickt wurde
		if not clicked_on_output and produce_button:
			var button_global_pos = produce_button.global_position
			var button_size = produce_button.size
			var mouse_pos = produce_button.get_global_mouse_position()
			
			# Prüfen, ob Klick innerhalb der Button-Grenzen ist
			if mouse_pos.x >= button_global_pos.x and mouse_pos.x < button_global_pos.x + button_size.x and \
			   mouse_pos.y >= button_global_pos.y and mouse_pos.y < button_global_pos.y + button_size.y:
				_on_produce_button_pressed()

func _process(delta: float) -> void:
	# existing process logic for UI clicks - MOVED INPUT CHECKING HERE
	# ... existing input handling for clicks on slots/button (now checks production_in_progress)...

	if production_in_progress:
		production_timer += delta
		progress_bar.value = production_timer
		if production_timer >= production_duration:
			production_in_progress = false
			progress_bar.hide()
			# Complete production and update slots
			_process_single_item() 
			# Re-enable produce button if inputs remain VISUALLY
			produce_button.disabled = not _has_required_inputs_visual()
			# Re-enable interactions after production
			input_slot.mouse_filter = Control.MOUSE_FILTER_STOP
			if input_slot2: input_slot2.mouse_filter = Control.MOUSE_FILTER_STOP
			output_slot.mouse_filter = Control.MOUSE_FILTER_STOP
			
# ... existing code ...
