extends PanelContainer


signal select_item(slot: PanelContainer)

@onready var slots: GridContainer = $MarginContainer/slots
@onready var ui_slot_buy: PanelContainer = $CenterContainer/ui_slot_buy
@onready var center_container: CenterContainer = $CenterContainer

var current_buy_slot: PanelContainer
var slot_list: Array


func _ready() -> void:
	# Set up basic UI configuration
	mouse_filter = Control.MOUSE_FILTER_STOP
	slots.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Critical: This ensures the UI is always clickable
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Get UI elements
	slot_list = slots.get_children()
	
	# Debug output
	print("Market UI Ready with ", slot_list.size(), " slots")
	
	# Connect buy button signal
	if ui_slot_buy.has_signal("buy"):
		print("Buy signal exists")
		ui_slot_buy.buy.connect(_buy_slot)
	else:
		print("Buy signal doesn't exist")
	
	# Connect slot signals
	for slot: PanelContainer in slot_list:
		print("Connecting slot: ", slot.name)
		
		# Connect the slot selection signal - for choosing items
		if slot.has_signal("slot_selection"):
			print("Found slot_selection signal")
			if slot.slot_selection.is_connected(_on_slot_selected):
				slot.slot_selection.disconnect(_on_slot_selected)
			slot.slot_selection.connect(_on_slot_selected)
		else:
			print("slot_selection signal not found on slot")
			
		# Connect the slot unlock signal - for locked slots
		if slot.has_signal("slot_unlock"):
			print("Found slot_unlock signal")
			if slot.slot_unlock.is_connected(_on_slot_unlock):
				slot.slot_unlock.disconnect(_on_slot_unlock)
			slot.slot_unlock.connect(_on_slot_unlock)
		else:
			print("slot_unlock signal not found on slot")
	
	# The visibility_changed connection
	if visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.disconnect(_on_visibility_changed)
	visibility_changed.connect(_on_visibility_changed)


# Handle UI appearing
func _on_visibility_changed() -> void:
	if visible:
		print("Market UI shown and processing input enabled")
		set_process_input(true)


func _on_slot_selected(slot: PanelContainer) -> void:
	print("Slot selected: ", slot.name)
	select_item.emit(slot)


func _on_slot_unlock(slot: PanelContainer, price: int):
	print("Slot unlock: ", slot.name, " price: ", price)
	center_container.show()
	
	# Show the price
	if ui_slot_buy.has_node("MarginContainer/VBoxContainer/Label"):
		var price_label: Label = ui_slot_buy.get_node("MarginContainer/VBoxContainer/Label")
		price_label.text = str(price) + "$"
	
	current_buy_slot = slot


func _buy_slot():
	print("Buying slot: ", current_buy_slot.name)
	
	# Unlock the slot
	current_buy_slot.set("locked", false)
	current_buy_slot.unlock()
	
	# Hide the buy UI after transaction
	center_container.hide()


# Handle UI control
func _input(event: InputEvent):
	if visible and event.is_action_pressed("ui_cancel"):
		print("UI Cancel pressed - hiding market UI")
		hide()
		get_viewport().set_input_as_handled()
