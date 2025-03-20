extends PanelContainer


signal slot_selection(slot: PanelContainer)
signal item_selection(item_name: String, item_texture: Texture2D)

@onready var button: TextureButton = $button
@onready var item_texture: TextureRect = $MarginContainer/item
@onready var amount_label: Label = $amount
var item_name: String = ""

var editable: bool = false
var production_ui = null  # Reference to the production UI


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	if item_texture.texture != null and editable:
		button.button_pressed = false
		return
	
	print("Slot pressed with item: " + item_name)
	
	# Add some visual feedback
	button.modulate = Color(1.5, 1.5, 1.5, 1)  # Make it brighter when clicked
	# Reset after a short delay using a safe approach
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): 
		if is_instance_valid(button): 
			button.modulate = Color(1, 1, 1, 1)
	)
	
	# First, emit the signals for compatibility
	slot_selection.emit(self)
	item_selection.emit(item_name, item_texture.texture)
	
	# Check if we have a valid production UI reference and item
	if production_ui != null:
		print("Production UI reference exists: ", production_ui)
		if item_name != "":
			print("DIRECT CALL: Slot calling add_input_item on production UI with " + item_name)
			# First, try the direct method call
			if production_ui.has_method("add_input_item"):
				print("Using direct method call to add_input_item")
				production_ui.add_input_item(item_name)
			# If that fails, try the call method which is more flexible
			else:
				print("Using call method to add_input_item")
				production_ui.call("add_input_item", item_name)
		else:
			print("ERROR: No item_name in this slot")
	else:
		print("ERROR: No production_ui reference in slot")

# Setup the slot with an item
func setup(item: String, description: String = "", is_enabled: bool = true, item_count: int = 0) -> void:
	item_name = item
	
	# Load the texture if item is provided
	if item != "":
		item_texture.texture = load("res://assets/ui/icons/" + item + ".png")
	else:
		item_texture.texture = null
	
	# Set amount if provided and enhance visibility
	if item_count > 0:
		amount_label.text = str(item_count)
		# Make the count more visible
		amount_label.add_theme_color_override("font_color", Color(1, 1, 1, 1)) # White text
		amount_label.add_theme_font_size_override("font_size", 14) # Slightly larger font
	else:
		amount_label.text = ""
	
	# Enable/disable the button
	button.disabled = !is_enabled

# Clear the slot
func clear() -> void:
	print("Clearing slot with item_name: " + item_name)
	item_name = ""
	item_texture.texture = null
	amount_label.text = ""
	button.disabled = false
	# Don't clear the production UI reference when clearing the slot
	# This ensures we maintain the reference for future operations

# Set the reference to the production UI
func set_production_ui(ui) -> void:
	production_ui = ui
	print("Slot now has reference to production UI: ", production_ui)
