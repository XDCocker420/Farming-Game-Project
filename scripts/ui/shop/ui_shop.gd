extends PanelContainer


@onready var slots: GridContainer = $HBoxContainer/MarginContainer/GridContainer
@onready var price_label: Label = $HBoxContainer/MarginContainer2/VBoxContainer/Label2
@onready var accept: TextureButton = $HBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/TextureButton
@onready var cancel: TextureButton = $HBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/TextureButton2
@onready var amount_spinbox: SpinBox = $HBoxContainer/MarginContainer2/VBoxContainer/SpinBox

var slot_list: Array

var selected_item: String
var selected_price: int
var total_price: int
var amount: int


func _ready() -> void:
	for slot in slots.get_children():
		slot_list.append(slot)
	
	for slot in slot_list:
		slot.item_selection.connect(_on_item_selected)
		
	accept.pressed.connect(_on_accept)
	cancel.pressed.connect(_on_cancel)
	amount_spinbox.value_changed.connect(_on_amount_changed)
	
	
func _on_item_selected(item_name: String, price: int, texture: Texture2D) -> void:
	selected_item = item_name
	price_label.text = str(price) + "$"
	selected_price = price
	total_price = price
	amount_spinbox.value = 1
	amount = 1
	

func _on_amount_changed(value: float) -> void:
	amount = int(value)
	total_price = selected_price * amount
	
	price_label.text = str(total_price) + "$"


func _on_accept() -> void:
	if selected_item == "":
		return
	
	if SaveGame.get_money() >= total_price:
		SaveGame.add_to_inventory(selected_item, amount)
		SaveGame.remove_money(total_price)
		hide()
		reset()
	
	
func _on_cancel() -> void:
	hide()
	reset()


func reset() -> void:
	for slot in slot_list:
		slot.get_node("button").button_pressed = false
	
	selected_item = ""
	amount_spinbox.value = 1
	price_label.text = ""
