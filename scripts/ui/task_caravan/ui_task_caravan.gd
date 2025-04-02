extends PanelContainer


@onready var grid_container: GridContainer = $MarginContainer/HBoxContainer/GridContainer
var slot_array: Array


func _ready() -> void:
	slot_array = grid_container.get_children()
	
	for slot: PanelContainer in slot_array:
		slot.task_selected.connect(_on_task_selected)
	
	hidden.connect(_on_hidden)


func _on_hidden() -> void:
	for slot: PanelContainer in slot_array:
		var slot_button: TextureButton = slot.get_node("TextureButton")
		slot_button.button_pressed = false


func _on_task_selected(id: int, item1: int, item2: int, item3: int) -> void:
	pass
