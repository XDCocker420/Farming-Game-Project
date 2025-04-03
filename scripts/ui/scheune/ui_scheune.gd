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
	var slot: PanelContainer = slot_scenen.instantiate()
	var slot_item: TextureRect = slot.get_node("MarginContainer/item")
	var slot_amount: Label = slot.get_node("amount")
	
	# Connect the slot's signals - disconnect first to avoid duplicates
	if slot.has_signal("item_selection"):
		if slot.item_selection.is_connected(_on_item_selected):
			slot.item_selection.disconnect(_on_item_selected)
		slot.item_selection.connect(_on_item_selected)
	else:
		pass
	
	# Ensure the button uses the proper mouse filter for input
	var button = slot.get_node("button")
	if button:
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Make sure button is visible and enabled
		button.visible = true
		button.disabled = false
		button.toggle_mode = true
		
		# Directly connect the button press event as a fallback
		if button.pressed.is_connected(_on_slot_button_pressed.bind(slot, item)):
			button.pressed.disconnect(_on_slot_button_pressed.bind(slot, item))
		button.pressed.connect(_on_slot_button_pressed.bind(slot, item))
	else:
		pass
	
	# Setup slot
	slot.item_name = item
	slot_item.texture = load("res://assets/ui/icons/" + item + ".png")
	slot_amount.text = str(amount)
	
	# Ensure proper cursor shape for better UX
	slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Set the production UI reference if we have one
	if active_production_ui:
		if slot.has_method("set_production_ui"):
			slot.set_production_ui(active_production_ui)
		else:
			pass
	
	slots.add_child(slot)
	slot_list.append(slot)

# New handler for direct button press as fallback
func _on_slot_button_pressed(slot, item_name) -> void:
	if active_production_ui and active_production_ui.has_method("add_input_item"):
		active_production_ui.call_deferred("add_input_item", item_name)
	else:
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
	
	# Clear existing slots
	slot_list.clear()
	for slot in slots.get_children():
		slot.queue_free()
	
	# Add slots for all items if no filter
	if not apply_filter or current_filter.is_empty():
		for item in inventory_data:
			add_slot(item, inventory_data[item])
	else:
		# Add slots only for filtered items
		for item in inventory_data:
			if current_filter.has(item):
				add_slot(item, inventory_data[item])
	
	# Re-establish production UI reference if it exists
	if current_production_ui:
		set_active_production_ui(current_production_ui)


func _on_visibility_changed() -> void:
	if visible:
		# Force a fresh reload from SaveGame
		
		# Clear filter temporarily to show all items
		var current_filter_copy = current_filter.duplicate()
		current_filter.clear()
		
		# Force a complete reload of slots
		reload_slots(false)
		
		# Restore filter if needed
		if not current_filter_copy.is_empty():
			current_filter = current_filter_copy
			reload_slots(true)

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
	set_workstation_filter(workstation)
	visible = true
	# visibility_changed signal will trigger reload_slots

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
	# Direct call to production UI if available
	if active_production_ui and active_production_ui.has_method("add_input_item"):
		active_production_ui.add_input_item(item_name)
	else:
		# Still emit the signal in case it's connected elsewhere
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
					# Call add_input_item directly on production UI
					if active_production_ui and active_production_ui.has_method("add_input_item"):
						active_production_ui.add_input_item(slot.item_name)
					break
