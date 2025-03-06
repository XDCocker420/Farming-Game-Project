extends PanelContainer


@onready var slots: GridContainer = $MarginContainer/ScrollContainer/slots

var slot_scenen = preload("res://scenes/ui/general/ui_slot.tscn")
var slot_list: Array

func _ready() -> void:
    visibility_changed.connect(_on_visibility_changed)
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
        
    
func reload_slots() -> void:
    slot_list = []
    
    for slot in slots.get_children():
        slot.queue_free()
    
    load_slots()


func _on_visibility_changed():
    if visible == true:
        reload_slots()
