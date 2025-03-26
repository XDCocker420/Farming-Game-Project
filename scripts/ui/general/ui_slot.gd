extends PanelContainer


signal slot_selection(slot: PanelContainer)
signal item_selection(item_name: String, item_texture: Texture2D)
signal slot_unlock(slot: PanelContainer, price: int)

@onready var button: TextureButton = $button
@onready var item_texture: TextureRect = $MarginContainer/item

var item_name: String
var id: int

var editable: bool = false
@export var locked: bool = false
@export var price: int


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	if locked:
		lock()


func _on_button_pressed() -> void:
	if item_texture.texture != null and editable:
		button.button_pressed = false
		return
	
	if locked:
		slot_unlock.emit(self, price)
	else:
		slot_selection.emit(self)
		item_selection.emit(item_name, item_texture.texture)
		

func lock() -> void:
	button.texture_normal = load("res://assets/ui/general/slot_locked.png")
	button.texture_pressed = null
	

func unlock() -> void:
	locked = false
	button.texture_normal = load("res://assets/ui/general/slot.png")
	button.texture_pressed = load("res://assets/ui/general/slot_pressed.png")
