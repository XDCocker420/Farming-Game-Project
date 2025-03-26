extends PanelContainer

signal item_selected(item_name: String)

@onready var slots: GridContainer = $MarginContainer/ScrollContainer/slots

var slot_scenen = preload("res://scenes/ui/general/ui_slot.tscn")
var slot_list: Array
var current_filter: Array = []
var active_production_ui = null

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	load_slots()


func add_slot(item: String, amount: int) -> void:
	var slot: PanelContainer = slot_scenen.instantiate()
	var slot_item: TextureRect = slot.get_node("MarginContainer/item")
	var slot_amount: Label = slot.get_node("amount")
	
	# Connect the slot's signals
	slot.item_selection.connect(_on_item_selected)
	
	# Setup slot
	slot.item_name = item
	slot_item.texture = load("res://assets/ui/icons/" + item + ".png")
	slot_amount.text = str(amount)
	
	# Set the production UI reference if we have one
	if active_production_ui:
		slot.set_production_ui(active_production_ui)
	
	slots.add_child(slot)
	slot_list.append(slot)


func load_slots() -> void:
	var inventory = SaveGame.get_inventory()
	
	for item in inventory.keys():
		# If we have a filter active, only show matching items
		if current_filter.is_empty() or item in current_filter:
			add_slot(item, inventory[item])
		
	
func reload_slots(apply_filter: bool = true) -> void:
	print("Reloading slots with filter: ", current_filter if apply_filter else "no filter")
	
	# Store current production UI reference
	var current_production_ui = active_production_ui
	
	# Get fresh inventory data
	var inventory_data = SaveGame.get_inventory()
	print("Current inventory state: ", inventory_data)
	
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
	
	print("Finished reloading slots. Total slots: ", slot_list.size())


func _on_visibility_changed():
	if visible:
		print("Scheune UI became visible, reloading slots...")
		
		# Force a fresh reload from SaveGame
		print("Current SaveGame inventory state: ", SaveGame.get_inventory())
		
		# Clear filter temporarily to show all items
		var current_filter_copy = current_filter.duplicate()
		current_filter.clear()
		
		# Force a complete reload of slots
		reload_slots(false)
		
		# Restore filter if needed
		if not current_filter_copy.is_empty():
			current_filter = current_filter_copy
			print("Restoring filter after visibility change: ", current_filter)
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
	print("Setting active production UI for inventory: ", ui)
	active_production_ui = ui
	
	# Update all existing slots in the slot_list
	print("Setting production UI for " + str(slot_list.size()) + " slots in slot_list")
	for slot in slot_list:
		if slot.has_method("set_production_ui"):
			slot.set_production_ui(active_production_ui)
			print("Set production UI for slot in slot_list")
	
	# Also update all slots directly in the slots container
	# This ensures we catch any slots that might have been added
	# but not yet added to slot_list
	print("Setting production UI for " + str(slots.get_child_count()) + " slots in slots container")
	for slot in slots.get_children():
		if slot.has_method("set_production_ui"):
			slot.set_production_ui(active_production_ui)
			print("Set production UI for slot in slots container")

# Handle item selection from a slot
func _on_item_selected(item_name: String, _item_texture: Texture2D) -> void:
	print("Item selected in inventory: " + item_name)
	# This signal will be connected to production UI's add_input_item method
	item_selected.emit(item_name)
	
	# Reload slots to reflect any inventory changes
	reload_slots(true)
