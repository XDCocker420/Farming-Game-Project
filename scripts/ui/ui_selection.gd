extends PanelContainer


@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer

const slot_scene = preload("res://scenes/ui/ui_selection_slot.tscn")


func _ready() -> void:
    load_inventory()


func load_inventory() -> void:
    var inventory = SaveGame.get_inventory()
    var current_hbox: HBoxContainer = add_h_box()
    
    for item in inventory.keys():
        if inventory[item] == 0:
            continue
        
        if current_hbox.get_child_count() == 3:
            current_hbox = add_h_box()
        
        add_slot(current_hbox, item)


func add_h_box() -> HBoxContainer:
    var hbox = HBoxContainer.new()
    v_box_container.add_child(hbox)    
    return hbox


func add_slot(hbox: HBoxContainer, item: String) -> void:
    var slot = slot_scene.instantiate()
    
    slot.item_name = item
    var slot_texture = slot.get_node("MarginContainer/TextureRect")
    slot_texture.texture = load("res://assets/gui/icons/" + item + ".png")
    
    hbox.add_child(slot)
