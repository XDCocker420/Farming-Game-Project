extends PanelContainer


signal select_item(slot: PanelContainer)

@onready var slots: GridContainer = $MarginContainer/slots
@onready var ui_slot_buy: PanelContainer = $CenterContainer/ui_slot_buy
@onready var center_container: CenterContainer = $CenterContainer

var current_buy_slot: PanelContainer
var slot_list: Array


func _ready() -> void:
	slot_list = slots.get_children()
	
	ui_slot_buy.buy.connect(_buy_slot)
	for slot: PanelContainer in slot_list:
		slot.slot_selection.connect(_on_slot_selected)
		slot.slot_unlock.connect(_on_slot_unlock)


func _on_slot_selected(slot: PanelContainer) -> void:
	select_item.emit(slot)
	var slot_button: TextureButton = slot.get_node("button")
	slot_button.button_pressed = false
	

func _on_slot_unlock(slot: PanelContainer, price: int):
	center_container.show()
	var price_label: Label = ui_slot_buy.get_node("MarginContainer/VBoxContainer/Label")
	price_label.text = str(price) + "$"
	current_buy_slot = slot
	

func _buy_slot():
	current_buy_slot.set("locked", false)
	var slot_button: TextureButton = current_buy_slot.get_node("button")
	slot_button.texture_normal = load("res://assets/ui/general/slot.png")
	slot_button.texture_pressed = load("res://assets/ui/general/slot_pressed.png")
	slot_button.button_pressed = false
