extends PanelContainer

signal item_selected(item_name: String)

@onready var slots: GridContainer = $MarginContainer/ScrollContainer/slots

var slot_scenen = preload("res://scenes/ui/general/ui_slot.tscn")
var slot_list: Array
var current_filter: Array = []
var active_production_ui = null

# Add a flag to track if we're refreshing during active production
var _refresh_during_production: bool = false

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	
	# Connect direct input handling for the entire slots container
	slots.gui_input.connect(_on_slots_gui_input)
	
	# Fix the layout mode for slots
	slots.layout_mode = 2  # Very important! This needs to match the scene's layout
	
	# Ensure ScrollContainer can receive scroll events
	var scroll_container = $MarginContainer/ScrollContainer
	scroll_container.mouse_filter = Control.MOUSE_FILTER_STOP # CRITICAL: Use STOP to process all inputs
	scroll_container.follow_focus = true
	
	# CRITICAL FIX: Make sure the slots are actually a direct child of ScrollContainer
	# with proper container layout mode relationship
	if slots.get_parent() != scroll_container:
		print("WARNING: Slots not directly parented to ScrollContainer. This is likely the root cause.")
	
	# SET THE SAME EXACT VALUES AS IN THE SCENE FILE
	# vertical_scroll_mode = 3 (ALWAYS_ENABLED) - scene shows this value specifically
	# horizontal_scroll_mode = 0 (DISABLED)
	scroll_container.vertical_scroll_mode = 3
	scroll_container.horizontal_scroll_mode = 0
	
	# Make sure content can be larger than visible area
	scroll_container.clip_contents = true
	
	# Set minimum size to match the scene value (62, 78)
	scroll_container.custom_minimum_size = Vector2(47, 23)
	
	# CRITICAL: Set actual scrollbar properties directly
	var v_scrollbar = scroll_container.get_v_scroll_bar()
	if v_scrollbar:
		v_scrollbar.visible = true
		v_scrollbar.min_value = 0
		v_scrollbar.max_value = 1000
		v_scrollbar.value = 0
		v_scrollbar.custom_minimum_size = Vector2(6, 0)
		v_scrollbar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Make sure slots grid doesn't consume scroll events
	slots.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Configure the slots grid to grow vertically but FORCE A MINIMUM SIZE
	# This is crucial - without a minimum size larger than the container,
	# the ScrollContainer won't scroll
	slots.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slots.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# CRITICAL: We need to set a minimum size on the grid that's LARGER than
	# the scroll container to force scrolling to activate
	slots.custom_minimum_size = Vector2(0, 300)  # Force much taller than container
	
	# FINAL CRITICAL FIX: Connect scroll signals
	if v_scrollbar:
		if not v_scrollbar.value_changed.is_connected(_on_scroll_value_changed):
			v_scrollbar.value_changed.connect(_on_scroll_value_changed)
			
	# Since we're setting scroll container's mouse_filter to STOP,
	# make sure we connect to gui_input to capture mouse wheel events
	scroll_container.gui_input.connect(_on_scroll_container_gui_input)
	
	load_slots()

func add_slot(item: String, amount: int, is_part_of_active_filter: bool = false) -> void:
	# Don't add slots for empty items
	if item.strip_edges() == "":
		return
		
	# If this item is part of an active filter, we *always* want to show it, even if amount is 0.
	# If it's NOT part of an active filter, then we only show it if amount > 0.
	if not is_part_of_active_filter and amount <= 0:
		return
		
	var slot: PanelContainer = slot_scenen.instantiate()
	var slot_item: TextureRect = slot.get_node("MarginContainer/item")
	var slot_amount: Label = slot.get_node("amount")
	
	# Initial setup of item data before connecting signals
	slot.item_name = item
	slot_item.texture = load("res://assets/ui/icons/" + item + ".png")
	slot_amount.text = str(amount)
	
	# Ensure proper cursor shape for better UX
	slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Set specific size constraints to ensure reliable layout
	slot.custom_minimum_size = Vector2(20, 20)  # Smaller slot size
	slot.size_flags_horizontal = Control.SIZE_FILL
	slot.size_flags_vertical = Control.SIZE_FILL
	
	# Make sure mouse filtering is correct for scrolling
	slot.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# IMPORTANT: Make sure layout mode matches the grid
	slot.layout_mode = 2
	
	# Make sure the slot is fully configured before adding signals
	slots.add_child(slot)
	slot_list.append(slot)
	
	# Get button reference once for both branches
	var button = slot.get_node("button")
	
	# Connect the slot's signals after adding to the tree to avoid lifecycle issues
	if not _refresh_during_production:
		if slot.has_signal("item_selection"):
			if slot.item_selection.is_connected(_on_item_selected):
				slot.item_selection.disconnect(_on_item_selected)
			slot.item_selection.connect(_on_item_selected)
		
		# Ensure the button uses the proper mouse filter for input
		if button:
			# Use STOP for the button so it captures clicks but not scroll events
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			
			# Make sure button is visible and enabled
			button.visible = true
			button.disabled = false
			button.toggle_mode = true
			
			# Directly connect the button press event
			if button.pressed.is_connected(_on_slot_button_pressed.bind(slot, item)):
				button.pressed.disconnect(_on_slot_button_pressed.bind(slot, item))
			button.pressed.connect(_on_slot_button_pressed.bind(slot, item))
	else:
		# During production refresh, still set up the button UI properly but don't connect signals
		if button:
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.visible = true
			button.disabled = false
			button.toggle_mode = true
	
	# Set the production UI reference if we have one
	if active_production_ui:
		if slot.has_method("set_production_ui"):
			slot.set_production_ui(active_production_ui)
	
	# If we've added lots of slots, ensure scroll container works
	var scroll_container = $MarginContainer/ScrollContainer
	
	# Force immediate update of scroll container
	scroll_container.queue_sort()
	
	# Call the update function to ensure everything is properly configured
	call_deferred("_ensure_scroll_updated")

# New handler for direct button press as fallback
func _on_slot_button_pressed(slot, item_name) -> void:
	# Only emit the signal, don't call directly to avoid double addition
	item_selected.emit(item_name)

func load_slots() -> void:
	var inventory = SaveGame.get_inventory()
	
	if not current_filter.is_empty():
		# Filter is active, show all filter items, with 0 count if not in inventory
		for item_in_filter in current_filter:
			var count = inventory.get(item_in_filter, 0)
			add_slot(item_in_filter, count, true) # Pass true for is_part_of_active_filter
	else:
		# No filter active, show items from inventory with count > 0
		for item in inventory.keys():
			if inventory[item] > 0:
				add_slot(item, inventory[item], false) # Pass false
		
	# After adding all slots, only connect signals if not during production refresh
	if not _refresh_during_production:
		for slot: PanelContainer in slot_list:
			if slot.item_selection.is_connected(_on_item_selected):
				slot.item_selection.disconnect(_on_item_selected)
			slot.item_selection.connect(_on_item_selected)
	
	call_deferred("_ensure_scroll_updated")

func reload_slots(apply_filter: bool = true) -> void:
	# CRITICAL FIX: Always get a fresh copy of inventory data directly from SaveGame
	# This ensures we never work with stale data
	var inventory_data = SaveGame.get_inventory().duplicate()
	
	# Log inventory state for debugging
	print("INVENTORY UI RELOAD: Current SaveGame state: ", inventory_data)
	
	# Check for _refresh_during_production at the beginning
	var suppress_signals = _refresh_during_production
	
	# Store current production UI reference
	var current_production_ui = active_production_ui
	
	# CRITICAL: Clear all existing slots first to prevent any lingering visual state
	slot_list.clear()
	for slot in slots.get_children():
		slot.queue_free()
	await get_tree().process_frame  # Wait for slots to be fully removed
	
	# Build the slots using the fresh inventory data we captured
	if apply_filter and not current_filter.is_empty():
		# For filtered reloads, add each filtered item
		for item_name in current_filter:
			var item_count = inventory_data.get(item_name, 0) 
			add_slot(item_name, item_count, true)
	else:
		# No filter, add items with quantity > 0
		for item_name in inventory_data:
			if inventory_data[item_name] > 0:
				add_slot(item_name, inventory_data[item_name], false)
	
	# Re-establish production UI reference if it exists
	if current_production_ui:
		set_active_production_ui(current_production_ui)
	
	# Ensure scroll container updates after rebuilding slots
	call_deferred("_ensure_scroll_updated")
	
	# Make sure the refresh state is cleared
	_refresh_during_production = false

# Helper method for selective slot updates
func _selective_slot_update(inventory_data): 
	# CRITICAL FIX: Always work with a fresh copy of the inventory data
	var current_inventory = inventory_data.duplicate()
	print("SELECTIVE UPDATE: Current inventory state: ", current_inventory)
	
	var items_processed_from_filter = {}
	
	# First pass: Update existing slots or remove if no longer in current_filter
	for slot_idx in range(slots.get_child_count() - 1, -1, -1): # Iterate backwards for safe removal
		var slot = slots.get_child(slot_idx)
		if is_instance_valid(slot) and "item_name" in slot and slot.item_name != "":
			var slot_item_name = slot.item_name
			
			if current_filter.has(slot_item_name):
				# Item is in the current filter, update it from current inventory
				var inv_count = current_inventory.get(slot_item_name, 0)
				var amount_label = slot.get_node_or_null("amount")
				if amount_label is Label:
					# CRITICAL: Always update with fresh count
					amount_label.text = str(inv_count)
					amount_label.show()
				slot.show()
				items_processed_from_filter[slot_item_name] = true
			else:
				# Item is not in the current filter, remove it
				slot_list.erase(slot)
				slot.queue_free()
	
	# Second pass: Add new slots for current_filter items not already shown/processed
	for item_in_filter in current_filter:
		if not items_processed_from_filter.has(item_in_filter):
			var inv_count = current_inventory.get(item_in_filter, 0)
			add_slot(item_in_filter, inv_count, true)

# NEW: Function to find a specific slot by item name
func find_slot_by_item_name(item_name: String):
	for slot in slot_list:
		if is_instance_valid(slot) and "item_name" in slot and slot.item_name == item_name:
			return slot
	return null

# IMPORTANT: Override adjust_visual_count to ensure it directly updates SaveGame
func adjust_visual_count(item_name: String, adjustment: int):
	print("ADJUST VISUAL: Item: ", item_name, " adjustment: ", adjustment)
	
	# Find the slot for this item
	var slot = find_slot_by_item_name(item_name)
	if slot:
		var amount_label = slot.get_node_or_null("amount")
		if amount_label is Label:
			# CRITICAL FIX: Always get the current count directly from SaveGame
			var current_count = SaveGame.get_item_count(item_name)
			print("ADJUST VISUAL: SaveGame count for ", item_name, ": ", current_count)
			
			if current_count > 0:
				amount_label.text = str(current_count)
				amount_label.show()
				slot.show()
			else: # count is 0
				amount_label.text = "0"
				if not current_filter.has(item_name):
					slot.hide()
				else:
					slot.show()
		else:
			push_warning("Could not find amount Label in slot for visual adjustment: %s" % item_name)
	else:
		# If item's slot doesn't exist but should be displayed, reload slots
		if current_filter.has(item_name) or SaveGame.get_item_count(item_name) > 0:
			update_visuals()  # Full refresh with fresh SaveGame data

# Update the visual count in the UI - completely rewritten to always use fresh SaveGame data
func update_visuals():
	# Get fresh inventory data
	var inventory = SaveGame.get_inventory()
	print("UPDATE VISUALS: Fresh SaveGame inventory: ", inventory)
	
	# Loop through existing slots and update their visibility/count directly from SaveGame
	for slot in slot_list:
		if is_instance_valid(slot) and "item_name" in slot and slot.item_name != "":
			var item_name = slot.item_name
			var count = inventory.get(item_name, 0)  # Get count directly from SaveGame
			
			var amount_label = slot.get_node_or_null("amount")
			if amount_label is Label:
				# ALWAYS update with fresh count from SaveGame
				amount_label.text = str(count)
				if count > 0:
					amount_label.show()
					slot.show()
				else: # count is 0
					if not current_filter.has(item_name):
						slot.hide()
					else:
						slot.show()  # Show it anyway if part of filter
	
	# Check for any items in SaveGame that aren't shown but should be
	var slots_to_add = []
	for item_name in inventory:
		if inventory[item_name] > 0 and not find_slot_by_item_name(item_name):
			if current_filter.is_empty() or current_filter.has(item_name):
				slots_to_add.append([item_name, inventory[item_name]])
	
	# Add any missing slots in a second pass
	for item_data in slots_to_add:
		add_slot(item_data[0], item_data[1], current_filter.has(item_data[0]))
	
	# Make sure the UI layout is updated
	call_deferred("_ensure_scroll_updated")

func _on_visibility_changed() -> void:
	if visible:
		# Ensure ScrollContainer is set up for scrolling
		var scroll_container = $MarginContainer/ScrollContainer
		scroll_container.vertical_scroll_mode = 3
		
		# Only store current_filter if it's not empty
		var current_filter_copy = current_filter.duplicate() if not current_filter.is_empty() else []
		
		# Only temporarily clear filter if we have one
		var had_filter = not current_filter.is_empty()
		if had_filter:
			current_filter.clear()
		
		# Clear existing slots and completely rebuild from SaveGame
		slot_list.clear()
		for slot in slots.get_children():
			slot.queue_free()
		
		# Load fresh inventory data
		load_slots()
		
		# Restore filter if needed
		if had_filter and not current_filter_copy.is_empty():
			current_filter = current_filter_copy
			reload_slots(true)
			
		# Always ensure scroll is updated after becoming visible
		call_deferred("_ensure_scroll_updated")

# Function to set filter based on workstation
func set_workstation_filter(workstation: String) -> void:
	# Clear any existing filter
	current_filter.clear()
	
	# Set up filters based on workstation type
	match workstation:
		"butterchurn":
			current_filter.append("milk")
		"press_cheese":
			current_filter.append("milk")
		"mayomaker":
			# Mayo braucht jetzt beide Zutaten
			current_filter.append("milk")
			current_filter.append("egg")
		"clothmaker":
			# Beide Items die für Stoff benötigt werden
			current_filter.append("white_wool")
			current_filter.append("white_string")
		"spindle":
			current_filter.append("white_wool")
		"feed_mill":
			current_filter.append("corn")
			current_filter.append("wheat")
	
	# Reload slots with new filter
	reload_slots()

# Method to both set filter and show UI
func setup_and_show(workstation: String) -> void:
	# Set the filter based on workstation
	set_workstation_filter(workstation)
	
	# Force visibility
	visible = true
	
	# Let visibility_changed signal trigger the reload to maintain proper state
	# Note: Don't force a manual reload here as it can interfere with the visibility handling

# Set the production UI reference for all slots
func set_active_production_ui(ui) -> void:
	if ui == null:
		return
		
	active_production_ui = ui
	
	# Update all existing slots in the slot_list
	for slot in slot_list:
		if slot.has_method("set_production_ui"):
			slot.set_production_ui(active_production_ui)
		else:
			pass
	
	# Also update all slots directly in the slots container
	# This ensures we catch any slots that might have been added
	# but not yet added to slot_list
	for slot in slots.get_children():
		if slot.has_method("set_production_ui"):
			slot.set_production_ui(active_production_ui)
			
	# Directly connect the production UI's add_input_item method to our item_selected signal
	if ui.has_method("add_input_item"):
		# Disconnect any existing connection first
		if item_selected.is_connected(ui.add_input_item):
			item_selected.disconnect(ui.add_input_item)
		# Connect the signal
		item_selected.connect(ui.add_input_item)

# Handle item selection from a slot
func _on_item_selected(item_name: String, _price: int, _item_texture: Texture2D) -> void:
	# Only emit the signal, don't call directly to avoid double addition
	item_selected.emit(item_name)

# Direct input handler for slots container
func _on_slots_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Convert click position to find which slot was clicked
		var click_pos = slots.get_local_mouse_position()
		
		# Check each slot to see if it was clicked
		for slot in slots.get_children():
			if slot.get_rect().has_point(click_pos):
				# Get the item name from the slot
				if "item_name" in slot and slot.item_name != "":
					# Only emit the signal, don't call directly to avoid double addition
					item_selected.emit(slot.item_name)
					break

# Helper function to ensure scroll container updates properly
func _ensure_scroll_updated() -> void:
	# Get the scroll container and force it to update its minimum size
	var scroll_container = $MarginContainer/ScrollContainer
	
	# Set scroll mode again to ensure it's correct
	scroll_container.vertical_scroll_mode = 3
	scroll_container.horizontal_scroll_mode = 0
	
	# Make sure the slots grid is set up for scrolling
	slots.size_flags_vertical = Control.SIZE_EXPAND_FILL
	slots.layout_mode = 2  # Very important! This must match the scene's layout_mode
	slots.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# CRITICAL: Keep minimum size LARGER than container to force scrolling
	var rows = ceil(slots.get_child_count() / float(slots.columns))
	var estimated_height = max(300, rows * 30.0)  # Ensure much larger minimum height
	slots.custom_minimum_size = Vector2(0, estimated_height)
	
	# Force scrollbar visibility
	var v_scrollbar = scroll_container.get_v_scroll_bar()
	if v_scrollbar:
		v_scrollbar.visible = true
		
		# Debug testing - set size to ensure visibility
		v_scrollbar.custom_minimum_size = Vector2(6, scroll_container.size.y)
		v_scrollbar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Make sure slots have consistent sizes and proper filters
	for slot in slots.get_children():
		if slot is Control:
			# Ensure consistent size for all slots - keep them small
			slot.custom_minimum_size = Vector2(22, 23)  # Original slot size
			
			# These ensure proper alignment in the grid
			slot.size_flags_horizontal = Control.SIZE_FILL
			slot.size_flags_vertical = Control.SIZE_FILL
			
			# Make sure mouse event filtering is correct
			slot.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Force layout update
	scroll_container.queue_sort()
	slots.queue_sort()
	
	# Reset scroll position to top
	scroll_container.scroll_vertical = 0
	
	# Delay a frame to allow the container to finish updating
	await get_tree().process_frame

# Check if we need to force the scroll container to update
func _process(_delta):
	if visible:
		var scroll_container = $MarginContainer/ScrollContainer
		
		# Make sure vertical scrolling is always enabled
		if scroll_container.vertical_scroll_mode != 3:  # Mode 3 = Always show scroll
			scroll_container.vertical_scroll_mode = 3
			
		# If we have more slots than can fit in the visible area, ensure they're scrollable
		if slots.get_child_count() > 9:  # 3 columns x 3 rows would need scrolling
			var first_slot_size = Vector2.ZERO
			if slots.get_child_count() > 0:
				first_slot_size = slots.get_child(0).size
				
			# Compute the total height needed for all slots
			var rows = ceil(slots.get_child_count() / 3.0)  # 3 columns per row
			var total_height_needed = rows * first_slot_size.y
			
			# If the slots need more space than available, ensure we can scroll
			if total_height_needed > scroll_container.size.y and Engine.get_process_frames() % 30 == 0:
				# Force the content to be larger than the scroll container
				slots.custom_minimum_size.y = max(140, total_height_needed + 10)
				
				# Force the ScrollContainer to acknowledge its actual content size
				slots.queue_sort()
				scroll_container.queue_sort()

# Handle ScrollContainer gui_input directly
func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		# Get the scroll container
		var scroll_container = $MarginContainer/ScrollContainer
		
		# Get current and max scroll values
		var current_scroll = scroll_container.scroll_vertical
		var v_scrollbar = scroll_container.get_v_scroll_bar()
		var max_scroll = v_scrollbar.max_value if v_scrollbar else 0
		
		# Directly modify scroll_vertical property
		var scroll_amount = 5  # Reduced from 15 to 5 for finer control
		var new_scroll = current_scroll
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Only scroll up if not at the top
			if current_scroll > 0:
				new_scroll = max(0, current_scroll - scroll_amount)
			else:
				# Already at top, don't try to scroll further
				new_scroll = 0
		else:  # MOUSE_BUTTON_WHEEL_DOWN
			# Only scroll down if not at the bottom
			if current_scroll < max_scroll:
				new_scroll = min(max_scroll, current_scroll + scroll_amount)
			else:
				# Already at bottom, don't try to scroll further
				new_scroll = max_scroll
		
		# Only update if the value actually changed
		if new_scroll != current_scroll:
			scroll_container.scroll_vertical = new_scroll
		
		# Make sure we don't propagate the event further
		get_viewport().set_input_as_handled()

# Handle scrollbar value changes - simplified to use scroll_vertical
func _on_scroll_value_changed(value: float) -> void:
	pass

# Override _input to ensure scroll wheel events are properly processed
func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	# Check for scroll wheel events
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		# Get the scroll container
		var scroll_container = $MarginContainer/ScrollContainer
		var scroll_container_rect = scroll_container.get_global_rect()
		
		# If mouse is over our scroll container, manually handle the scroll
		if scroll_container_rect.has_point(get_global_mouse_position()):
			# Get current and max scroll values
			var current_scroll = scroll_container.scroll_vertical
			var v_scrollbar = scroll_container.get_v_scroll_bar()
			var max_scroll = v_scrollbar.max_value if v_scrollbar else 0
			
			# Directly modify scroll_vertical property
			var scroll_amount = 5  # Reduced from 15 to 5 for finer control
			var new_scroll = current_scroll
			
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# Only scroll up if not at the top
				if current_scroll > 0:
					new_scroll = max(0, current_scroll - scroll_amount)
				else:
					# Already at top, don't try to scroll further
					new_scroll = 0
			else:  # MOUSE_BUTTON_WHEEL_DOWN
				# Only scroll down if not at the bottom
				if current_scroll < max_scroll:
					new_scroll = min(max_scroll, current_scroll + scroll_amount)
				else:
					# Already at bottom, don't try to scroll further
					new_scroll = max_scroll
			
			# Only update if the value actually changed
			if new_scroll != current_scroll:
				scroll_container.scroll_vertical = new_scroll
			
			# Make sure we don't propagate the event further
			get_viewport().set_input_as_handled()

# Function for production_ui to notify us that refresh is happening during production
func set_refresh_during_production(active: bool) -> void:
	_refresh_during_production = active
