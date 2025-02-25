extends Control


@onready var upper_box: HBoxContainer = $VBoxContainer/HBoxContainer
@onready var lower_box: HBoxContainer = $VBoxContainer/HBoxContainer2

var upper_slots = []
var lower_slots = []
var all_slots = []

signal markt_select(slot)


func _ready() -> void:
    load_slots()
    
    for slot in all_slots:
        slot.slot_select.connect(_select_item)


func _select_item(slot):
    markt_select.emit(slot)


func load_slots():
    for slot in upper_box.get_children():
        upper_slots.append(slot)
        all_slots.append(slot)
        
    for slot in lower_box.get_children():
        lower_slots.append(slot)
        all_slots.append(slot)
        
    var i = 0
    for slot in all_slots:
        if i < 2:
            slot.unlock()
        
        i += 1
        if i == 4:
            i = 0
