extends Control


func _ready() -> void:
	SaveGame.add_to_inventory("carrot", 5)
	SaveGame.add_to_inventory("wheat", 2)
	SaveGame.add_to_inventory("corn", 30)
	load_inventory()
	visible = false



func _process(delta: float) -> void:
	pass


func load_inventory() -> void:
	#var vbox = $Menu/ScrollContainer/VBoxContainer
	#var slots = $Menu/ScrollContainer/VBoxContainer/GridContainer
	var vbox = $Menu/ScrollContainer/VBoxContainer
	var slots = $Menu/ScrollContainer/VBoxContainer/GridContainer
	var slot = preload("res://scenes/ui/ui_slot.tscn")
	
	var inventory = SaveGame.get_inventory()
	var count = 0

	var keys = inventory.keys()
	keys.sort_custom(func(x:String, y:String) -> bool: return inventory[x] > inventory[y])

	for item in keys:
		var new_slot = slot.instantiate()

		if new_slot.has_node("Icon"):
			new_slot.get_node("Icon").texture = load("res://assets/gui/icons/" + item + ".png")
			
		slots.add_child(new_slot)
		
		new_slot.show()
		count = SaveGame.get_item_count(str(item))

		if count >= 1:
			new_slot.get_node("Node2D/amount").text = str(count)
			new_slot.get_node("Node2D/amount").show()
		else:
			new_slot.get_node("Node2D/amount").hide()
	
