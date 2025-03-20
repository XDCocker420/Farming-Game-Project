extends PanelContainer

# Signal to notify when processing is complete
signal process_complete

# References to all slots
@onready var input_slots = [
	$MarginContainer/slots/ui_slot,
	$MarginContainer/slots/ui_slot2,
	$MarginContainer/slots/ui_slot3,
	$MarginContainer/slots/ui_slot4
]

@onready var output_slots = [
	$MarginContainer/slots/ui_slot5,
	$MarginContainer/slots/ui_slot6,
	$MarginContainer/slots/ui_slot7,
	$MarginContainer/slots/ui_slot8
]

# Current workstation information
var current_workstation: String = ""
var input_items = []
var output_items = []

func _ready():
	# You might want to connect the slot buttons to handle clicks
	for slot in input_slots + output_slots:
		if slot.has_node("button"):
			slot.get_node("button").pressed.connect(_on_slot_pressed.bind(slot))
	
	# Debug check to verify this object has the add_input_item method
	print("PRODUCTION UI: Method check - has_method('add_input_item'): ", has_method("add_input_item"))

func setup(workstation_name: String):
	print("Setting up production UI for workstation: " + workstation_name)
	current_workstation = workstation_name
	
	# Clear all slots
	for slot in input_slots + output_slots:
		if slot.has_method("clear"):
			slot.clear()
			print("Cleared slot")
			
			# Maintain production UI reference after clearing
			if slot.has_method("set_production_ui"):
				slot.set_production_ui(self)
	
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
	
	print("Recipe: " + str(input_items) + " -> " + str(output_items))
	
	# Keep input slots empty initially
	for i in range(min(input_items.size(), input_slots.size())):
		if input_slots[i].has_method("clear"):
			input_slots[i].clear()
			print("Input slot " + str(i) + " cleared and ready for " + input_items[i])
	
	# Set up output slots (completely empty initially)
	for i in range(min(output_items.size(), output_slots.size())):
		if output_slots[i].has_method("clear"):
			output_slots[i].clear()
			print("Output slot " + str(i) + " cleared")

func _on_slot_pressed(slot):
	if slot in input_slots:
		# Input slots should not be clickable to prevent item duplication
		print("Input slot clicked: " + str(input_slots.find(slot)) + " (ignored)")
		return
	elif slot in output_slots:
		print("==== OUTPUT SLOT CLICKED: " + str(output_slots.find(slot)) + " ====")
		var output_index = output_slots.find(slot)
		if output_index >= 0 and output_index < output_items.size():
			var output_item = output_items[output_index]
			print("Output slot clicked for item: " + output_item)
			
			# Check if this is a processed item (not just a preview)
			var item_count = 0
			if slot.amount_label.text != "":
				item_count = int(slot.amount_label.text)
			
			if item_count > 0:
				# This is a processed item that can be transferred back to inventory
				print("Transferring " + str(item_count) + " " + output_item + " back to inventory")
				
				# We don't need to change the inventory as items are already there
				# Just update the display to show 0 and clear the slot
				slot.clear()
				print("Reset output slot to empty state")
			else:
				# This is an empty slot, try to process
				print("Processing output at index " + str(output_index) + " for item " + output_items[output_index])
				_process_single_item(output_index)
		else:
			print("Invalid output index: " + str(output_index))

func _process_single_item(output_index: int) -> void:
	print("==== PROCESSING SINGLE ITEM FOR OUTPUT INDEX " + str(output_index) + " ====")
	
	# Get corresponding input/output items
	var input_item = ""
	var output_item = ""
	
	if output_index < output_items.size():
		output_item = output_items[output_index]
		
		# Find the matching input item based on workstation
		match current_workstation:
			"butterchurn":
				input_item = "milk"
			"press_cheese":
				input_item = "milk"
			"mayomaker":
				input_item = "egg"
			"clothmaker":
				input_item = "white_wool"
			"spindle":
				input_item = "white_wool"
			"feed_mill":
				input_item = "wheat"
		
		print("Recipe input: " + input_item + ", output: " + output_item)
	
	if input_item == "" or output_item == "":
		print("Invalid input/output combination")
		return
	
	# Check if there's an item in the input slot
	var found_input_slot = -1
	var input_count = 0
	for i in range(min(input_items.size(), input_slots.size())):
		print("Checking slot " + str(i) + " with item_name: " + str(input_slots[i].item_name))
		if input_slots[i].item_name == input_item:
			found_input_slot = i
			# Get the count of items in this slot
			if input_slots[i].amount_label.text != "":
				input_count = int(input_slots[i].amount_label.text)
			else:
				input_count = 1
			print("Found " + str(input_count) + " " + input_item + " in slot " + str(i))
			break
			
	if found_input_slot == -1 or input_count <= 0:
		print("No input items available to process")
		return
	
	print("Processing " + str(input_count) + " " + input_item + " from slot " + str(found_input_slot) + " into " + output_item)
	
	# Get current output count from inventory
	var current_output_count = SaveGame.get_item_count(output_item)
	
	# Add the output item to inventory
	SaveGame.add_to_inventory(output_item, input_count)
	
	# Update the output slot visually with the new count
	if output_slots[output_index].has_method("setup"):
		output_slots[output_index].setup(output_item, "", true, input_count)
		print("Updated output slot with count: " + str(input_count))
		
		# Ensure the production UI reference is maintained
		if output_slots[output_index].has_method("set_production_ui"):
			output_slots[output_index].set_production_ui(self)
			print("Maintained production UI reference for output slot after processing")
	
	print("Successfully processed " + str(input_count) + " " + input_item + " into " + str(input_count) + " " + output_item)
	print("New inventory count for " + output_item + ": " + str(current_output_count + input_count))
	
	# Clear the input slot
	print("Clearing input slot " + str(found_input_slot))
	if input_slots[found_input_slot].has_method("clear"):
		input_slots[found_input_slot].clear()
		print("Input slot cleared successfully")
	else:
		print("ERROR: input slot doesn't have clear method")
	
	# Emit signal to notify processing is complete
	print("Emitting process_complete signal")
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
			
		# Find a slot for this item type
		var slot_found = false
		for i in range(min(input_items.size(), input_slots.size())):
			if input_items[i] == item_name:
				# Found a matching slot for this item type
				print("Found slot for " + item_name + " at index " + str(i))
				slot_found = true
				
				# Get current count if the slot already has this item
				var current_count = 0
				if input_slots[i].item_name == item_name and input_slots[i].amount_label.text != "":
					current_count = int(input_slots[i].amount_label.text)
				
				# Update the slot with the item and increment count
				input_slots[i].setup(item_name, "", true, current_count + 1)
				
				# Remove the item from inventory
				SaveGame.remove_from_inventory(item_name, 1)
				
				print("Successfully added " + item_name + " to input slot " + str(i))
				print("New count in slot: " + str(current_count + 1))
				print("New inventory count: " + str(SaveGame.get_item_count(item_name)))
				return
		
		if not slot_found:
			print("No suitable slot found for " + item_name)
	else:
		print("Item " + item_name + " is not valid for this workstation")

# Process a specific item into its output
func _process_item(item_name: String) -> void:
	# Check if we have this item in inventory
	if SaveGame.get_item_count(item_name) <= 0:
		print("Not enough " + item_name + " in inventory")
		return
	
	# Get the corresponding output item
	var output_item = ""
	match current_workstation:
		"butterchurn":
			if item_name == "milk":
				output_item = "butter"
		"press_cheese":
			if item_name == "milk":
				output_item = "cheese"
		"mayomaker":
			if item_name == "egg":
				output_item = "mayo"
		"clothmaker":
			if item_name == "white_wool":
				output_item = "white_cloth"
		"spindle":
			if item_name == "white_wool":
				output_item = "white_string"
		"feed_mill":
			if item_name == "wheat":
				output_item = "feed"
	
	if output_item == "":
		print("No output recipe for " + item_name + " in " + current_workstation)
		return
	
	# Process the item
	SaveGame.remove_from_inventory(item_name, 1)
	SaveGame.add_to_inventory(output_item, 1)
	
	# Update the output slot visually
	for i in range(min(output_items.size(), output_slots.size())):
		if output_items[i] == output_item:
			if output_slots[i].has_method("setup"):
				output_slots[i].setup(output_item, "", true, 1)
	
	print("Successfully processed " + item_name + " into " + output_item)
	
	# Update the UI
	setup(current_workstation)

func _try_produce():
	# Check if player has all required input items
	var can_produce = true
	
	for item in input_items:
		if SaveGame.get_item_count(item) <= 0:
			can_produce = false
			break
	
	if can_produce:
		# Remove input items
		for item in input_items:
			SaveGame.remove_from_inventory(item, 1)
		
		# Add output items
		for item in output_items:
			SaveGame.add_to_inventory(item, 1)
			
		# Update UI
		setup(current_workstation)
		
		print("Successfully produced " + str(output_items) + " from " + str(input_items))
	else:
		print("Not enough resources to produce " + str(output_items))

# New function to test if the production UI is functional
func test_functionality() -> void:
	print("Production UI test_functionality called!")
	print("This object can process items: " + str(has_method("add_input_item")))
	add_input_item("milk")