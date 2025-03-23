extends Control

@onready var title = $Panel/VBoxContainer/Title
@onready var input_slot = $Panel/VBoxContainer/InputContainer/InputSlot
@onready var input_label = $Panel/VBoxContainer/InputContainer/InputLabel
@onready var output_slot = $Panel/VBoxContainer/OutputContainer/OutputSlot
@onready var output_label = $Panel/VBoxContainer/OutputContainer/OutputLabel
@onready var produce_button = $Panel/VBoxContainer/ProduceButton

var input_item: String = ""
var output_item: String = ""
var input_texture: Texture2D
var output_texture: Texture2D

func _ready():
	produce_button.pressed.connect(_on_produce_button_pressed)
	
	# Configure UI for very compact panel
	title.add_theme_font_size_override("font_size", 8)
	input_label.add_theme_font_size_override("font_size", 7)
	output_label.add_theme_font_size_override("font_size", 7)
	produce_button.add_theme_font_size_override("font_size", 8)
	
	# Adjust spacing
	var vbox = $Panel/VBoxContainer
	vbox.add_theme_constant_override("separation", 3)
	
	# Adjust layout for compact display
	$Panel/VBoxContainer/InputContainer.add_theme_constant_override("separation", 3)
	$Panel/VBoxContainer/OutputContainer.add_theme_constant_override("separation", 3)
	
	# Set minimum sizes
	produce_button.custom_minimum_size.y = 15

func setup(workstation_name: String):
	match workstation_name:
		"butterchurn":
			title.text = "Butter"
			input_item = "Milk"
			output_item = "Butter"
		"press_cheese":
			title.text = "Cheese"
			input_item = "Milk"
			output_item = "Cheese"
		"mayomaker":
			title.text = "Mayo"
			input_item = "Egg"
			output_item = "Mayo"
		"clothmaker":
			title.text = "Cloth"
			input_item = "Wool"
			output_item = "Cloth"
		"spindle":
			title.text = "Spindle"
			input_item = "Wool"
			output_item = "String"
		"feed_mill":
			title.text = "Feed"
			input_item = "Wheat"
			output_item = "Feed"
	
	# Ultra compact labels
	input_label.text = "In: " + input_item
	output_label.text = "Out: " + output_item

func _on_produce_button_pressed():
	# Here you would check if the player has enough input items
	# and then give them the output item
	print("Producing " + output_item + " from " + input_item) 