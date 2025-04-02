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


func _ready() -> void:
	# Make sure the button is configured properly
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(_on_button_pressed)
	
	# Configure the rest
	if locked:
		lock()
		
	if def_texture != null:
		item_texture.texture = def_texture


func _on_button_pressed() -> void:
	if item_texture.texture != null and editable:
		button.button_pressed = false
		return
	
	if locked:
		slot_unlock.emit(self, price)
	else:
		slot_selection.emit(self)
		item_selection.emit(item_name, price, item_texture.texture)
		

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
