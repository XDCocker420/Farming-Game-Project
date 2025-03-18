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
			input_items = ["Milk"]
			output_items = ["Butter"]
		"press_cheese":
			input_items = ["Milk"]
			output_items = ["Cheese"]
		"mayomaker":
			input_items = ["Egg"]
			output_items = ["Mayo"]
		"clothmaker":
			input_items = ["Wool"]
			output_items = ["Cloth"]
		"spindle":
			input_items = ["Wool"]
			output_items = ["String"]
		"feed_mill":
			input_items = ["Wheat"]
			output_items = ["Feed"]
	
	# Set up input slots
	for i in range(min(input_items.size(), input_slots.size())):
		if input_slots[i].has_method("setup"):
			input_slots[i].setup(input_items[i], "", true, 1)
	
	# Set up output slots
	for i in range(min(output_items.size(), output_slots.size())):
		if output_slots[i].has_method("setup"):
			output_slots[i].setup(output_items[i], "", true, 1)

func _on_slot_pressed(slot):
	if slot in input_slots:
		print("Input slot clicked: " + str(input_slots.find(slot)))
		# Handle input slot interaction
	elif slot in output_slots:
		print("Output slot clicked: " + str(output_slots.find(slot)))
		# Handle output slot interaction
		_try_produce()

func _try_produce():
	# Here you would check if the player has enough input items
	# and then give them the output item
	print("Trying to produce " + str(output_items) + " from " + str(input_items)) 