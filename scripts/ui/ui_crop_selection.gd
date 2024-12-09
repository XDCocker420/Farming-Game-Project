extends Control

signal crop_selected(crop_type: String)

@onready var slots = $Menu/ScrollContainer/VBoxContainer/GridContainer

func _ready() -> void:
	visible = false
	load_available_crops()

func load_available_crops() -> void:
	# Clear existing slots
	for slot in slots.get_children():
		slot.queue_free()
		
	var inventory = SaveGame.get_inventory()
	var keys = inventory.keys()
	keys.sort_custom(func(x:String, y:String) -> bool: return inventory[x] > inventory[y])
	
	for item in keys:
		if _is_crop(item):
			var count = SaveGame.get_item_count(item)
			if count > 0:
				_add_crop_slot(item, count)

func _is_crop(item: String) -> bool:
	# Add all plantable items here
	return item in ["carrot", "wheat"]

func _add_crop_slot(crop_type: String, count: int) -> void:
	var slot = preload("res://scenes/ui/ui_slot.tscn").instantiate()
	
	# Set up the slot
	if slot.has_node("Icon"):
		var icon = slot.get_node("Icon")
		icon.texture = load("res://assets/gui/icons/" + crop_type + ".png")
		icon.custom_minimum_size = Vector2(64, 64)
		slot.custom_minimum_size = Vector2(70, 70)
		slots.add_child(slot)
		
		# Make the icon clickable
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		icon.gui_input.connect(func(event): _on_crop_clicked(event, crop_type))
		
		slot.show()
		count = SaveGame.get_item_count(str(crop_type))
		
		# Show amount with adjusted position and scale
		var amount_label = slot.get_node("Node2D/amount")
		amount_label.scale = Vector2(0.25, 0.25)
		amount_label.position = Vector2(42, 45)
		
		# Adjust name label
		var name_label = slot.get_node("Node2D/name")
		name_label.scale = Vector2(0.2, 0.2)
		name_label.position = Vector2(0, -15)
		
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
	# Füge Testsamen hinzu
	SaveGame.add_to_inventory("carrot", 10)
	SaveGame.add_to_inventory("wheat", 10)
	SaveGame.save_game()
	
	load_available_crops()  # Aktualisiere die Liste
	visible = true

func hide_ui() -> void:
	visible = false 