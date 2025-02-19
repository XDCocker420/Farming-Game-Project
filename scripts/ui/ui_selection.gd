extends PanelContainer


@onready var v_box_container: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer

const slot_scene = preload("res://scenes/ui/ui_selection_slot.tscn")
var inventory = SaveGame.get_inventory()


func _ready() -> void:
    load_inventory()


func load_inventory() -> void:
    var inventory = SaveGame.get_inventory()
    var i = 0
    var current_hbox
    
    var keys = inventory.keys()
    keys.sort_custom(func(x:String, y:String) -> bool: return inventory[x] > inventory[y])
        
    for item in keys:
        if i == 0:
            current_hbox = HBoxContainer.new()
            v_box_container.add_child(current_hbox)
        
        var slot_instance = slot_scene.instantiate()
        slot_instance.get_node("MarginContainer/TextureRect").texture = load("res://assets/gui/icons/" + item + ".png")
        
        current_hbox.add_child(slot_instance)
        
        if i == 2:
            i = 0
        else:
            i += 1
