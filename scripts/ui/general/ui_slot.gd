extends PanelContainer


signal slot_selection(slot: PanelContainer)
signal item_selection(item_name: String, price: int, item_texture: Texture2D)
signal slot_unlock(slot: PanelContainer, price: int)

@onready var button: TextureButton = $button
@onready var item_texture: TextureRect = $MarginContainer/item
@onready var amount_label: Label = $amount

@export var editable: bool = false

@export var id: int
@export var item_name: String

@export var locked: bool = false
@export var price: int

@export var def_texture: Texture2D

var production_ui = null
var click_cooldown = false  # To prevent double processing of same click
var cooldown_time = 0.12    # Moderate cooldown similar to output slot clicks


func _ready() -> void:
	# Make sure the button is configured properly
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	if button.pressed.is_connected(_on_button_pressed):
		button.pressed.disconnect(_on_button_pressed)
	button.pressed.connect(_on_button_pressed)
	
	# Make the item texture clickable
	item_texture.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Configure the rest
	if locked:
		lock()
		
	if def_texture != null:
		item_texture.texture = def_texture
		
	# Connect the direct item input handling
	if gui_input.is_connected(_on_slot_gui_input):
		gui_input.disconnect(_on_slot_gui_input)
	gui_input.connect(_on_slot_gui_input)
	
	# Make sure we're visible
	visible = true
	
	# Make sure our mouse detection works
	mouse_filter = MOUSE_FILTER_STOP
	
	# Debug
	print("Slot ready with item: ", item_name)


func _process(_delta):
	# Add direct click detection for debugging
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and visible:
		var mouse_pos = get_global_mouse_position()
		if get_global_rect().has_point(mouse_pos):
			# This will fire continuously while button is held, so add a cooldown
			if Engine.get_physics_frames() % 15 == 0: # Moderate pace (~1/4 second)
				print("Continuous click detection on slot with item: ", item_name)
				_handle_click()


func _on_button_pressed() -> void:
	print("Button pressed in slot with item: ", item_name)
	
	if item_texture.texture != null and editable:
		button.button_pressed = false
		return
	
	if locked:
		slot_unlock.emit(self, price)
	else:
		# Always trigger signals
		if item_name != "":
			print("Emitting item selection signal for: ", item_name)
			slot_selection.emit(self)
			item_selection.emit(item_name, price, item_texture.texture)


# Centralized click handler
func _handle_click() -> void:
	if locked or item_name == "" or click_cooldown:
		return
		
	print("Handle click for item: ", item_name)
	
	# Set cooldown to prevent processing the same click multiple times
	click_cooldown = true
	
	# Only emit signals
	slot_selection.emit(self)
	item_selection.emit(item_name, price, item_texture.texture)
	
	# Reset cooldown after a short delay - much shorter to allow rapid clicks
	await get_tree().create_timer(cooldown_time).timeout
	click_cooldown = false


# Handle direct GUI input on the slot
func _on_slot_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("GUI input on slot: ", item_name)
		if not locked and item_name != "" and not click_cooldown:
			# Handle the click directly
			_handle_click()
			
			# Only set the button pressed state for visual feedback
			button.button_pressed = true
			await get_tree().create_timer(0.05).timeout
			button.button_pressed = false

# Add direct click handling as a fallback
func _input(event: InputEvent) -> void:
	if not visible or click_cooldown:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var global_rect = get_global_rect()
		var mouse_pos = get_global_mouse_position()
		
		if global_rect.has_point(mouse_pos) and item_name != "" and not locked:
			_handle_click()


func lock() -> void:
	button.texture_normal = load("res://assets/ui/general/slot_locked.png")
	button.texture_pressed = null
	

func unlock() -> void:
	locked = false
	button.texture_normal = load("res://assets/ui/general/slot.png")
	button.texture_pressed = load("res://assets/ui/general/slot_pressed.png")

# Function to store a reference to the production UI
func set_production_ui(ui) -> void:
	production_ui = ui

# Add the missing setup function that's called in production_ui.gd
func setup(new_item_name: String, new_texture_path: String = "", show_amount: bool = true, amount: int = 1) -> void:
	# Set the item name
	item_name = new_item_name
	
	# Set the texture if provided, otherwise try to load from the standard path
	if new_texture_path != "":
		item_texture.texture = load(new_texture_path)
	else:
		# Load the texture from the standard icons path
		item_texture.texture = load("res://assets/ui/icons/" + new_item_name + ".png")
	
	# Set the amount if needed
	if show_amount and amount > 0:
		amount_label.text = str(amount)
		amount_label.show()
	else:
		amount_label.text = ""
		amount_label.hide()
	
	# Make sure the slot is visible
	visible = true

# Add a clear function to reset the slot
func clear() -> void:
	item_name = ""
	item_texture.texture = null
	amount_label.text = ""
	amount_label.hide()
