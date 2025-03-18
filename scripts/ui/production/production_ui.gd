extends Control

@onready var title = $Menu/VBoxContainer/Title
@onready var input_slot = $Menu/VBoxContainer/InputContainer/InputSlot
@onready var input_label = $Menu/VBoxContainer/InputContainer/InputLabel
@onready var output_slot = $Menu/VBoxContainer/OutputContainer/OutputSlot
@onready var output_label = $Menu/VBoxContainer/OutputContainer/OutputLabel
@onready var produce_button = $Menu/VBoxContainer/ProduceButton

var input_item: String = ""
var output_item: String = ""
var input_texture: Texture2D
var output_texture: Texture2D

func _ready():
	produce_button.pressed.connect(_on_produce_button_pressed)
	
	# No need for font size overrides as we're using the theme directly in the scene

func setup(workstation_name: String):
	match workstation_name:
		"butterchurn":
			title.text = "Butter Churn"
			input_item = "Milk"
			output_item = "Butter"
		"press_cheese":
			title.text = "Cheese Press"
			input_item = "Milk"
			output_item = "Cheese"
		"mayomaker":
			title.text = "Mayo Maker"
			input_item = "Egg"
			output_item = "Mayo"
		"clothmaker":
			title.text = "Cloth Maker"
			input_item = "Wool"
			output_item = "Cloth"
		"spindle":
			title.text = "Spinning Wheel"
			input_item = "Wool"
			output_item = "String"
		"feed_mill":
			title.text = "Feed Mill"
			input_item = "Wheat"
			output_item = "Feed"
	
	input_label.text = "In: " + input_item
	output_label.text = "Out: " + output_item

func _on_produce_button_pressed():
	# Here you would check if the player has enough input items
	# and then give them the output item
	print("Producing " + output_item + " from " + input_item) 