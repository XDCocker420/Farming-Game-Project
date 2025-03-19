extends PanelContainer


@onready var slots: GridContainer = $MarginContainer/ScrollContainer/slots

var slot_scenen = preload("res://scenes/ui/general/ui_slot.tscn")
var slot_list: Array
var current_filter: Array = []

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
        # If we have a filter active, only show matching items
        if current_filter.is_empty() or item in current_filter:
            add_slot(item, inventory[item])
        
    
func reload_slots() -> void:
    slot_list = []
    
    for slot in slots.get_children():
        slot.queue_free()
    
    load_slots()


func _on_visibility_changed():
    if visible == true:
        reload_slots()

# New function to set filter based on workstation
func set_workstation_filter(workstation: String) -> void:
    # Clear any existing filter first
    current_filter.clear()
    
    # Set the filter based on workstation
    match workstation:
        "butterchurn", "press_cheese":
            current_filter = ["milk"]
        "mayomaker":
            current_filter = ["egg"]
        "clothmaker", "spindle":
            current_filter = ["white_wool"]
        "feed_mill":
            current_filter = ["wheat"]
        _:
            # Default case - no filter
            current_filter = []
    
    # If already visible, reload the slots with the new filter
    if visible:
        reload_slots()

# Method to both set filter and show UI
func setup_and_show(workstation: String) -> void:
    set_workstation_filter(workstation)
    visible = true
    # visibility_changed signal will trigger reload_slots
