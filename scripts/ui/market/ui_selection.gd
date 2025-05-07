extends PanelContainer


signal put_item(item_name: String, item_texture: Texture2D)
signal accept(amount: int, price: int)

@onready var slots: GridContainer = $HBoxContainer/MarginContainer/ScrollContainer/slots
@onready var accept_button: TextureButton = $HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/HBoxContainer/accept
@onready var cancel_button: TextureButton = $HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/HBoxContainer/cancel
@onready var amount_spinbox: SpinBox = $HBoxContainer/MarginContainer2/VBoxContainer/amount_spinbox
@onready var price_spinbox: SpinBox = $HBoxContainer/MarginContainer2/VBoxContainer/price_spinbox

var slot_list: Array
var slot_scenen = preload("res://scenes/ui/general/ui_slot.tscn")
var current_item:String


func _ready() -> void:
	accept_button.pressed.connect(_on_accept)
	cancel_button.pressed.connect(_on_cancel)
	visibility_changed.connect(_on_visibility_changed)
	amount_spinbox.value_changed.connect(_on_amount_changed)
	
	load_slots()
	

func add_slot(item: String, amount: int) -> void:
	var slot: PanelContainer = slot_scenen.instantiate()
	var slot_item: TextureRect = slot.get_node("MarginContainer/item")
	var slot_amount: Label = slot.get_node("amount")
	
	slot_item.texture = load("res://assets/ui/icons/" + item + ".png")
	slot_amount.text = str(amount)
	slot.set("item_name", item)
	
	slots.add_child(slot)
	slot_list.append(slot)


func load_slots() -> void:
	var inventory = SaveGame.get_inventory()
	
	for item in inventory.keys():
		add_slot(item, inventory[item])
		
	for slot: PanelContainer in slot_list:
		slot.slot_selection.connect(_on_slot_selected)
		slot.item_selection.connect(_on_item_selected)
		

func reload_slots() -> void:
	slot_list = []
	
	for slot in slots.get_children():
		slot.queue_free()
	
	load_slots()


func _on_slot_selected(slot: PanelContainer) -> void:
	var max_amount: int = 10
	var slot_label: Label = slot.get_node("amount")
	
	if int(slot_label.text) < 10:
		max_amount = int(slot_label.text)
	
	amount_spinbox.max_value = max_amount
	amount_spinbox.value = 1
	
	if current_item != "":
		price_spinbox.value = 1


func _on_item_selected(item_name: String, price: int, item_texture: Texture2D) -> void:
	current_item = item_name
	
	var max_price = ConfigReader.get_max_price(item_name)
	price_spinbox.max_value = max_price
	
	price_spinbox.value = 1
	
	put_item.emit(item_name, item_texture)
	
	
func _on_cancel() -> void:
	reset_ui()
	hide()
	
	
func _on_accept() -> void:
	var amount: int = int(amount_spinbox.value)
	var price: int = int(price_spinbox.value)
	amount_spinbox.value = 1
	price_spinbox.value = 1
	accept.emit(amount, price)


func _on_visibility_changed():
	if visible == false:
		reset_ui()
		reload_slots()
	else:
		reset_ui()

func _on_amount_changed(value:float) -> void:
	price_spinbox.max_value = ConfigReader.get_max_price(current_item) * value

func reset_ui() -> void:
	amount_spinbox.value = 1
	price_spinbox.value = 1
	
	for slot in slot_list:
		if slot.has_method("deselect"):
			slot.deselect()
		elif slot.has_node("button"):
			slot.get_node("button").button_pressed = false
