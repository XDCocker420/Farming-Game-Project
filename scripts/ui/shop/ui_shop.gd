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
	slot_list = slots.get_children()
	
	for slot in slot_list:
		slot.item_selection.connect(_on_item_selected)
		
	accept.pressed.connect(_on_accept)
	cancel.pressed.connect(_on_cancel)
	amount_spinbox.value_changed.connect(_on_amount_changed)
	
	# Connect visibility changed signal to handle UI state
	visibility_changed.connect(_on_visibility_changed)


func _on_item_selected(item_name: String, price: int, texture: Texture2D) -> void:
	selected_item = item_name
	selected_price = price
	price_label.text = str(price) + "$"
	total_price = price
	amount_spinbox.value = 1
	amount = 1
	

func _on_amount_changed(value: float) -> void:
	if selected_item == "":
		return
		
	amount = int(value)
	
	# Sicherstellen, dass selected_price gültig ist, bevor wir es verwenden
	if selected_price <= 0:
		# Preisfehler erkannt, nach dem richtigen Preis im Slot-Grid suchen
		for slot in slot_list:
			if slot.item_name == selected_item:
				selected_price = slot.price
				break
	
	# Berechnung des Gesamtpreises
	total_price = selected_price * amount
	
	# Aktualisierung des Preislabels
	price_label.text = str(total_price) + "$"


func _on_accept() -> void:
	if selected_item == "":
		return
	
	if SaveGame.get_money() >= total_price:
		# Add the "_seed" suffix to item names as these are seed items
		var item_to_add = selected_item + "_seed"
		
		# Verify the item texture exists
		if verify_item_path(item_to_add):
			SaveGame.add_to_inventory(item_to_add, amount)
			SaveGame.remove_money(total_price)
			hide()
			reset()
		else:
			# Fallback - try adding without _seed suffix as a fallback
			if verify_item_path(selected_item):
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
	selected_price = 0
	total_price = 0
	amount = 1
	amount_spinbox.value = 1
	price_label.text = ""


func _on_visibility_changed() -> void:
	if visible:
		# Vollständige Initialisierung aller Variablen beim Anzeigen
		selected_item = ""
		selected_price = 0
		total_price = 0
		amount = 1
		amount_spinbox.value = 1
		price_label.text = ""
		
		# UI-Elemente zurücksetzen
		for slot in slot_list:
			slot.get_node("button").button_pressed = false


# Verify the item exists in the assets folder
func verify_item_path(item_name: String) -> bool:
	var file_path = "res://assets/ui/icons/" + item_name + ".png"
	var file = FileAccess.open(file_path, FileAccess.READ)
	return file != null
