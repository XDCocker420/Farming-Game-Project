extends PanelContainer


@onready var slots: GridContainer = $MarginContainer/ScrollContainer/slots

var slot_scenen = preload("res://scenes/ui/ui_slot.tscn")
var slot_list: Array

func _ready() -> void:
    load_slots()


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
