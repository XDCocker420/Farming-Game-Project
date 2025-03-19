extends PanelContainer

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

func setup(workstation_name: String):
	current_workstation = workstation_name
	
	# Clear all slots
	for slot in input_slots + output_slots:
		if slot.has_method("clear"):
			slot.clear()
	
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
	
	# Set up input slots
	for i in range(min(input_items.size(), input_slots.size())):
		if input_slots[i].has_method("setup"):
			# Get the actual inventory count
			var count = SaveGame.get_item_count(input_items[i])
			input_slots[i].setup(input_items[i], "", count > 0, count)
	
	# Set up output slots
	for i in range(min(output_items.size(), output_slots.size())):
		if output_slots[i].has_method("setup"):
			output_slots[i].setup(output_items[i], "", true, 0)

func _on_slot_pressed(slot):
	if slot in input_slots:
		print("Input slot clicked: " + str(input_slots.find(slot)))
		# Handle input slot interaction
	elif slot in output_slots:
		print("Output slot clicked: " + str(output_slots.find(slot)))
		# Handle output slot interaction
		_try_produce()

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