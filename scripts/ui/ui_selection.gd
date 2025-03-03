extends PanelContainer


signal put_item(item: Texture2D)
signal accept

@onready var slots: GridContainer = $HBoxContainer/MarginContainer/ScrollContainer/slots
@onready var accept_button: TextureButton = $HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/HBoxContainer/accept
@onready var cancel_button: TextureButton = $HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/HBoxContainer/cancel

var slot_list: Array
var slot_scenen = preload("res://scenes/ui/ui_slot.tscn")


func _ready() -> void:
    accept_button.pressed.connect(_on_accept)
    cancel_button.pressed.connect(_on_cancel)
    
    load_slots()
    
    for slot: PanelContainer in slot_list:
        slot.item_selection.connect(_on_item_selected)
    

func add_slot(item: String, amount: int) -> void:
    var slot: PanelContainer = slot_scenen.instantiate()
    var slot_item: TextureRect = slot.get_node("MarginContainer/item")
    var slot_amount: Label = slot.get_node("amount")
    
    slot_item.texture = load("res://assets/ui/icons/" + item + ".png")
    slot_amount.text = str(amount)
    
    slots.add_child(slot)
    slot_list.append(slot)


func load_slots() -> void:
    var inventory = SaveGame.get_inventory()
    
    for item in inventory.keys():
        add_slot(item, inventory[item])


func _on_item_selected(item: Texture2D) -> void:
    put_item.emit(item)
    
    
func _on_cancel() -> void:
    hide()
    
    
func _on_accept() -> void:
    accept.emit()
    hide()
