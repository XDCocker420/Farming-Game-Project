extends PanelContainer


@onready var texture_button: TextureButton = $TextureButton
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect

signal markt_slot_select(slot)

var item: String
var amount: int


func _ready() -> void:
	texture_button.pressed.connect(_on_pressed)
	texture_button.disabled = true
	
	
func set_item(item: String, amount: int) -> void:
	self.item = item
	self.amount = amount


func unlock():
	texture_button.disabled = false


func _on_pressed():
	markt_slot_select.emit(self)
