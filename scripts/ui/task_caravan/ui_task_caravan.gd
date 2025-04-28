extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/HBoxContainer/GridContainer
@onready var ui_task_caravan_task: PanelContainer = $MarginContainer/HBoxContainer/ui_task_caravan_task
var slot_array: Array

# Store details of the currently selected task
var current_selected_id: int = -1
var current_selected_items: Dictionary = {}
var current_selected_money: int = 0
var current_selected_xp: int = 0

@onready var item1_amount_label: Label
@onready var item1_icon_texture: TextureRect
@onready var item2_amount_label: Label
@onready var item2_icon_texture: TextureRect
@onready var item3_amount_label: Label
@onready var item3_icon_texture: TextureRect

@onready var task_label: Label


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


func _on_slot_selected(id: int, items_dict: Dictionary, money_reward: int, xp_reward: int) -> void:
	clear()
	
	# Store current task details
	current_selected_id = id
	current_selected_items = items_dict
	current_selected_money = money_reward
	current_selected_xp = xp_reward
	
	task_label.text = "Task " + str(id)
	
	# Update display labels (using the passed items_dict)
	item1_amount_label.text = str(items_dict["item1"][1])
	item1_icon_texture.texture = items_dict["item1"][2]
	
	if items_dict.has("item2") and items_dict["item2"][0] != "":
		item2_amount_label.text = str(items_dict["item2"][1])
		item2_icon_texture.texture = items_dict["item2"][2]
	else:
		item2_amount_label.text = ""
		item2_icon_texture.texture = null
		
	if items_dict.has("item3") and items_dict["item3"][0] != "":
		item3_amount_label.text = str(items_dict["item3"][1])
		item3_icon_texture.texture = items_dict["item3"][2]
	else:
		item3_amount_label.text = ""
		item3_icon_texture.texture = null
		
	# Pass data to the task details panel
	if ui_task_caravan_task.has_method("set_current_task"):
		ui_task_caravan_task.set_current_task(current_selected_id, current_selected_items, current_selected_money, current_selected_xp)


func _on_task_done(task_id: int) -> void:
	# Find the slot that corresponds to the completed task id
	for slot: PanelContainer in slot_array:
		if slot.id == task_id:
			if slot.has_method("regenerate_task"):
				slot.regenerate_task()
				# Clear the detailed view and reset stored selection
				clear()
				task_label.text = ""
				current_selected_id = -1
				current_selected_items = {}
				current_selected_money = 0
				current_selected_xp = 0
				# Maybe disable the button in ui_task_caravan_task until a new task is selected
				if ui_task_caravan_task.has_method("disable_button"):
					ui_task_caravan_task.disable_button()
				break # Exit loop once found and regenerated
	

func clear() -> void:
	item1_amount_label.text = ""
	item1_icon_texture.texture = null
	item2_amount_label.text = ""
	item2_icon_texture.texture = null
	item3_amount_label.text = ""
	item3_icon_texture.texture = null
