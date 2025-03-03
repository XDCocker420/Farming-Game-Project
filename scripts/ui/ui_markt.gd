extends Control


signal select_item(slot: PanelContainer)

@onready var slots: GridContainer = $MarginContainer/slots
var slot_list: Array


func _ready() -> void:
    slot_list = slots.get_children()
    
    for slot: PanelContainer in slot_list:
        slot.slot_selection.connect(_on_slot_selected)
        lock_slots()


func _on_slot_selected(slot: PanelContainer) -> void:
    select_item.emit(slot)


func lock_slots() -> void:
    var i = 0
    
    for slot: PanelContainer in slot_list:
        var slot_button: TextureButton = slot.get_node("button")
        
        if i > 1:
            slot_button.disabled = true
            
        if i == 3:
            i = 0
        else:
            i += 1
