extends PanelContainer

signal item_selected(item_name: String)

@onready var slots: GridContainer = $MarginContainer/ScrollContainer/slots

var slot_scenen = preload("res://scenes/ui/general/ui_slot.tscn")
var slot_list: Array
var current_filter: Array = []
var active_production_ui = null

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	
	# Connect direct input handling for the entire slots container
	slots.gui_input.connect(_on_slots_gui_input)
	
	load_slots()

func add_slot(item: String, amount: int) -> void:
	# Don't add slots for empty items or with zero quantity
	if item.strip_edges() == "" or amount <= 0:
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
	
	# Make sure the slot is fully configured before adding signals
	slots.add_child(slot)
	slot_list.append(slot)
	
	# Connect the slot's signals after adding to the tree to avoid lifecycle issues
	if slot.has_signal("item_selection"):
		if slot.item_selection.is_connected(_on_item_selected):
			slot.item_selection.disconnect(_on_item_selected)
		slot.item_selection.connect(_on_item_selected)
	
	# Ensure the button uses the proper mouse filter for input
	var button = slot.get_node("button")
	if button:
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Make sure button is visible and enabled
		button.visible = true
		button.disabled = false
		button.toggle_mode = true
		
		# Directly connect the button press event
		if button.pressed.is_connected(_on_slot_button_pressed.bind(slot, item)):
			button.pressed.disconnect(_on_slot_button_pressed.bind(slot, item))
		button.pressed.connect(_on_slot_button_pressed.bind(slot, item))
	
	# Set the production UI reference if we have one
	if active_production_ui:
		if slot.has_method("set_production_ui"):
			slot.set_production_ui(active_production_ui)

# New handler for direct button press as fallback
func _on_slot_button_pressed(slot, item_name) -> void:
	print("Slot button pressed for item: ", item_name)
	# Only emit the signal, don't call directly to avoid double addition
	item_selected.emit(item_name)
	
	# Reload slots to reflect inventory changes
	reload_slots(true)

func load_slots() -> void:
	var inventory = SaveGame.get_inventory()
	
	for item in inventory.keys():
		# If we have a filter active, only show matching items
		if current_filter.is_empty() or item in current_filter:
			add_slot(item, inventory[item])
		
	
func reload_slots(apply_filter: bool = true) -> void:
	# Store current production UI reference
	var current_production_ui = active_production_ui
	
	# Get fresh inventory data
	var inventory_data = SaveGame.get_inventory()
	
	# Only rebuild slots if needed
	if apply_filter and not current_filter.is_empty():
		# For filtered reloads, more selective approach
		var filtered_items = []
		for item in inventory_data:
			if current_filter.has(item):
				filtered_items.append(item)
		
		# If we're only showing a few items, do a selective update
		if filtered_items.size() <= 6:
			_selective_slot_update(filtered_items, inventory_data)
			return
	
	# Standard rebuild approach for larger sets
	_full_slot_rebuild(inventory_data, apply_filter)
	
	# Re-establish production UI reference if it exists
	if current_production_ui:
		set_active_production_ui(current_production_ui)

# Helper method for selective slot updates (more efficient)
func _selective_slot_update(filtered_items, inventory_data):
	var updated_items = {}
	
	# First pass: Update existing slots or mark for removal
	for slot in slots.get_children():
		if "item_name" in slot and slot.item_name != "":
			var item_name = slot.item_name
			if item_name in filtered_items:
				# Get the current inventory count
				var inv_count = inventory_data.get(item_name, 0)
				
				# Update amount if needed
				var amount_label = slot.get_node("amount")
				if amount_label:
					if inv_count > 0:
						amount_label.text = str(inv_count)
						amount_label.show()
					else:
						# If item count is 0, don't show but don't remove either
						amount_label.text = "0"
						amount_label.show()
				
				# Mark as updated
				updated_items[item_name] = true
			else:
				# Not in filter, safely remove
				slot_list.erase(slot)
				slot.queue_free()
	
	# Second pass: Add new slots for filtered items not already shown
	for item in filtered_items:
		if not updated_items.has(item) and inventory_data.has(item) and inventory_data[item] > 0:
			add_slot(item, inventory_data[item])

# Helper method for full rebuild (original approach)
func _full_slot_rebuild(inventory_data, apply_filter):
	# Safety check for the slot container
	if not is_instance_valid(slots):
		push_error("Slots container is not valid during rebuild")
		return
		
	# Clear existing slots
	slot_list.clear()
	for slot in slots.get_children():
		slot.queue_free()
	
	# Add slots for all items if no filter
	if not apply_filter or current_filter.is_empty():
		for item in inventory_data:
			if inventory_data[item] > 0:  # Only show items with quantity > 0
				add_slot(item, inventory_data[item])
	else:
		# Add slots only for filtered items
		for item in inventory_data:
			if current_filter.has(item) and inventory_data[item] > 0:
				add_slot(item, inventory_data[item])

func _on_visibility_changed() -> void:
	if visible:
		print("UI became visible, reloading inventory")
		
		# Only store current_filter if it's not empty
		var current_filter_copy = current_filter.duplicate() if not current_filter.is_empty() else []
		
		# Only temporarily clear filter if we have one
		var had_filter = not current_filter.is_empty()
		if had_filter:
			current_filter.clear()
		
		# Force a reload with fresh data from SaveGame
		reload_slots(false)
		
		# Restore filter if needed
		if had_filter and not current_filter_copy.is_empty():
			current_filter = current_filter_copy
			reload_slots(true)
	else:
		print("UI became invisible")

# Function to set filter based on workstation
func set_workstation_filter(workstation: String) -> void:
	# Clear any existing filter first
	current_filter.clear()
	
	# Set the filter based on workstation
	match workstation:
		"butterchurn", "press_cheese":
			current_filter = ["milk"]
		"mayomaker":
			current_filter = ["egg"]
		"clothmaker", "spindle":
			current_filter = ["white_wool"]
		"feed_mill":
			current_filter = ["corn"]
		_:
			# Default case - no filter
			current_filter = []
	
	# If already visible, reload the slots with the new filter
	if visible:
		reload_slots(true)

# Method to both set filter and show UI
func setup_and_show(workstation: String) -> void:
	print("Setting up inventory UI for workstation: ", workstation)
	
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
		
	print("Setting active production UI reference")
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
		print("Connecting item_selected signal to production UI")
		item_selected.connect(ui.add_input_item)

# Handle item selection from a slot
func _on_item_selected(item_name: String, _price: int, _item_texture: Texture2D) -> void:
	# Only emit the signal, don't call directly to avoid double addition
	item_selected.emit(item_name)
	
	# Reload slots to reflect any inventory changes
	reload_slots(true)

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
					print("Slot clicked via gui_input for item: ", slot.item_name)
					# Only emit the signal, don't call directly to avoid double addition
					item_selected.emit(slot.item_name)
					break
