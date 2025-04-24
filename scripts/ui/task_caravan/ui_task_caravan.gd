extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/HBoxContainer/GridContainer
@onready var ui_task_caravan_task: PanelContainer = $MarginContainer/HBoxContainer/ui_task_caravan_task
var slot_array: Array

@onready var item1_amount_label: Label
@onready var item1_icon_texture: TextureRect
@onready var item2_amount_label: Label
@onready var item2_icon_texture: TextureRect
@onready var item3_amount_label: Label
@onready var item3_icon_texture: TextureRect

@onready var task_label: Label

var item1_current: Dictionary = {
	"name": "",
	"amount": 0
}

var item2_current: Dictionary = {
	"name": "",
	"amount": 0
}

var item3_current: Dictionary = {
	"name": "",
	"amount": 0
}


func _ready() -> void:
	slot_array = grid_container.get_children()
	for slot: PanelContainer in slot_array:
		#slot.selected_slot.connect(_on_slot_selected)
		slot.selected.connect(_on_slot_selected)
		
	ui_task_caravan_task.task_done.connect(_on_task_done)
	
	item1_amount_label = ui_task_caravan_task.get_node("VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer/item1_label")
	item1_icon_texture = ui_task_caravan_task.get_node("VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer/item1_icon")
	item2_amount_label = ui_task_caravan_task.get_node("VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer2/item2_label")
	item2_icon_texture = ui_task_caravan_task.get_node("VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer2/item2_icon")
	item3_amount_label = ui_task_caravan_task.get_node("VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer3/item3_label")
	item3_icon_texture = ui_task_caravan_task.get_node("VBoxContainer2/MarginContainer2/ScrollContainer/VBoxContainer/HBoxContainer3/item3_icon")
	
	task_label = ui_task_caravan_task.get_node("VBoxContainer2/MarginContainer/titel_label")
	
	hidden.connect(_on_hidden)


func _on_hidden() -> void:
	for slot: PanelContainer in slot_array:
		var slot_button: TextureButton = slot.get_node("TextureButton")
		slot_button.button_pressed = false
		
	clear()
	task_label.text = ""


func _on_slot_selected(id: int, items_dict: Dictionary) -> void:
	clear()
	
	task_label.text = "Auftrag " + str(id)
	
	item1_amount_label.text = str(items_dict["item1"][1])
	item1_icon_texture.texture = items_dict["item1"][2]
	
	if items_dict["item2"][0] != "":
		item2_amount_label.text = str(items_dict["item2"][1])
		item2_icon_texture.texture = items_dict["item2"][2]
		
	if items_dict["item3"][0] != "":
		item3_amount_label.text = str(items_dict["item3"][1])
		item3_icon_texture.texture = items_dict["item3"][2]


func _on_task_done() -> void:
	pass
	

func clear() -> void:
	item1_amount_label.text = ""
	item1_icon_texture.texture = null
	item2_amount_label.text = ""
	item2_icon_texture.texture = null
	item3_amount_label.text = ""
	item3_icon_texture.texture = null
	
	item1_current = {
		"name": "",
		"amount": 0
	}

	item2_current = {
		"name": "",
		"amount": 0
	}

	item3_current = {
		"name": "",
		"amount": 0
	}
