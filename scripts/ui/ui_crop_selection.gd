extends Control

signal crop_selected(crop_type: String)

@onready var slots = $Menu/ScrollContainer/VBoxContainer/GridContainer

func _ready() -> void:
	visible = false
	load_available_crops()

func load_available_crops() -> void:
	for slot in slots.get_children():
		slot.queue_free()
		
	var inventory = SaveGame.get_inventory()
	var keys = inventory.keys()
	keys.sort_custom(func(x:String, y:String) -> bool: return inventory[x] > inventory[y])
	
	for item in keys:
		if item in ["carrot", "wheat", "corn", "cauliflower", "berry", "onion", "bean", "grape"]:
			var count = SaveGame.get_item_count(item)
			if count > 0:
				_add_crop_slot(item, count)

func _add_crop_slot(crop_type: String, count: int) -> void:
	var slot = preload("res://scenes/ui/ui_slot.tscn").instantiate()
	slot.set_script(load("res://scripts/ui/ui_crop_selection_slot.gd"))
	
	if slot.has_node("Icon"):
		var icon = slot.get_node("Icon")
		icon.texture = load("res://assets/gui/icons/" + crop_type + ".png")
		slots.add_child(slot)
		
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		icon.gui_input.connect(func(event): _on_crop_clicked(event, crop_type))
		
		slot.show()
		
		var amount_label = slot.get_node("Node2D/amount")
		
		if count >= 1:
			amount_label.text = str(count)
			amount_label.show()
		else:
			amount_label.hide()

func _on_crop_clicked(event: InputEvent, crop_type: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("crop_selected", crop_type)
		hide()

func show_ui() -> void:
	SaveGame.add_to_inventory("carrot", 10)
	SaveGame.add_to_inventory("wheat", 10)
	SaveGame.add_to_inventory("corn", 10)
	SaveGame.add_to_inventory("cauliflower", 10)
	SaveGame.add_to_inventory("berry", 10)
	SaveGame.add_to_inventory("onion", 10)
	SaveGame.add_to_inventory("bean", 10)
	SaveGame.add_to_inventory("grape", 10)
	SaveGame.save_game()
	
	load_available_crops()
	visible = true

func hide_ui() -> void:
	visible = false 