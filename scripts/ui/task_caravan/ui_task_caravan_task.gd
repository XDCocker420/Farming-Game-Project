extends PanelContainer


@onready var slot_container: GridContainer = get_parent().get_node("GridContainer")
@onready var titel_label: Label = $VBoxContainer2/MarginContainer/titel_label
@onready var item_1_icon: TextureRect = $VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer/item1_icon
@onready var item_1_label: Label = $VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer/item1_label
@onready var item_2_icon: TextureRect = $VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer2/item2_icon
@onready var item_2_label: Label = $VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer2/item2_label
@onready var item_3_icon: TextureRect = $VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer3/item3_icon
@onready var item_3_label: Label = $VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer3/item3_label

var slot_list: Array


func _ready() -> void:
	slot_list = slot_container.get_children()
	
	for slot: PanelContainer in slot_list:
		slot.task_selected.connect(_on_task_selected)


func _on_task_selected(id: int, item1: Array, item2: Array, item3: Array) -> void:
	titel_label.text = "Auftrag " + str(id)
	
	item_1_icon.texture = load("res://assets/ui/icons/" + item1[0] + ".png")
	item_1_label.text = str(item1[1])
	
	item_2_icon.texture = null
	item_2_label.text = ""
	item_3_icon.texture = null
	item_3_label.text = ""
	
	if id > 3:
		item_2_icon.texture = load("res://assets/ui/icons/" + item2[0] + ".png")
		item_2_label.text = str(item2[1])
		
	if id > 6:
		item_3_icon.texture = load("res://assets/ui/icons/" + item3[0] + ".png")
		item_3_label.text = str(item3[1])
