extends Node

# A helper script to add price hover labels to all market slots

# Called when the node enters the scene tree for the first time
func _ready():
	# Wait for a frame to ensure UI is fully initialized
	await get_tree().process_frame
	
	# Find the ui_markt instance
	var ui_markt = null
	var parent = get_parent()
	while parent:
		if parent.has_node("CanvasLayer/ui_markt"):
			ui_markt = parent.get_node("CanvasLayer/ui_markt")
			break
		parent = parent.get_parent()
	
	if not ui_markt:
		return
	
	# Find all slots
	if not ui_markt.has_node("MarginContainer/slots"):
		return
		
	var slots_container = ui_markt.get_node("MarginContainer/slots")
	var price_label_scene = preload("res://scenes/ui/general/price_hover_label.tscn")
	
	# Add the price hover label to each slot
	for slot in slots_container.get_children():
		if slot.get_class() == "PanelContainer":
			# Check if it already has a price label
			if not slot.has_node("PriceHoverLabel"):
				var price_label = price_label_scene.instantiate()
				slot.add_child(price_label)
				# Position the label at the top of the slot
                               price_label.position = Vector2(0, -10)
                               price_label.size.x = slot.size.x
