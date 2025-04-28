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
var click_cooldown = false  # Restored for production UI
var cooldown_time = 0.12    # Restored for production UI


func _ready() -> void:
	SaveGame.market_bought.connect(_on_buy)
	# CRITICAL FIX: Use the simplest approach to get input working
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Make button fully responsive to input
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_ALL
	
	# Restore toggle mode for production UI
	button.toggle_mode = true 
	button.action_mode = TextureButton.ACTION_MODE_BUTTON_PRESS
	
	# CRITICAL: Connect to the pressed signal
	if button.pressed.is_connected(_on_button_pressed):
		button.pressed.disconnect(_on_button_pressed)
	button.pressed.connect(_on_button_pressed)
	
	# Make the item texture pass clicks through to button
	item_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Configure the visual appearance
	if locked:
		button.texture_normal = load("res://assets/ui/general/slot_locked.png")
		button.texture_pressed = null
	else:
		button.texture_normal = load("res://assets/ui/general/slot.png")
		button.texture_pressed = load("res://assets/ui/general/slot_pressed.png")
		
	if def_texture != null:
		item_texture.texture = def_texture
	
	# Connect GUI input for production UI
	if gui_input.is_connected(_on_slot_gui_input):
		gui_input.disconnect(_on_slot_gui_input)
	gui_input.connect(_on_slot_gui_input)
		
	# Make sure we're visible
	visible = true


# Processing function restored for production UI
func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and visible:
		var mouse_pos = get_global_mouse_position()
		if get_global_rect().has_point(mouse_pos):
			# This will fire continuously while button is held, so add a cooldown
			if Engine.get_physics_frames() % 15 == 0: # Moderate pace (~1/4 second)
				_handle_click()


# Main button press handler
func _on_button_pressed() -> void:
	if item_texture.texture != null and editable:
		button.button_pressed = false
		return
	
	# For locked slots, emit unlock signal
	if locked:
		slot_unlock.emit(self, price)
		return
		
	# For non-locked slots, always emit slot_selection
	slot_selection.emit(self)
	
	# For slots with items, also emit the item selection signal
	if item_name != "":
		item_selection.emit(item_name, price, item_texture.texture)


# Centralized click handler restored for production UI
func _handle_click() -> void:
	if locked or item_name == "" or click_cooldown:
		return
		
	# Set cooldown to prevent processing the same click multiple times
	click_cooldown = true
	
	# Emit signals
	slot_selection.emit(self)
	if item_name != "":
		item_selection.emit(item_name, price, item_texture.texture)
	
	# Reset cooldown after a short delay
	await get_tree().create_timer(cooldown_time).timeout
	click_cooldown = false


# Handle direct GUI input on the slot - restored for production UI
func _on_slot_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not locked:
			# Force a button press when the container is clicked
			button.button_pressed = true
			
			# Only set the button pressed state for visual feedback
			await get_tree().create_timer(0.05).timeout
			button.button_pressed = false


# Keep _input method for keyboard handling
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Find parent market UI and hide it
		var parent = get_parent()
		while parent and not (parent.has_method("hide") and "ui_markt" in parent.name):
			parent = parent.get_parent()
		
		if parent:
			parent.hide()


func lock() -> void:
	locked = true
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


func _on_buy(item:String):
	print(item_name)
	if item == item_name:
		SaveGame.add_money(int(amount_label.text))
		clear()
