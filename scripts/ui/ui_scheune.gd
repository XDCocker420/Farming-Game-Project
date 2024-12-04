extends Control


func _ready() -> void:
	SaveGame.add_to_inventory("carrot", 5)
	SaveGame.add_to_inventory("wheat", 2)
	SaveGame.add_to_inventory("corn", 3)
	load_inventory()



func _process(delta: float) -> void:
	pass


func load_inventory() -> void:
	var vbox = $Menu/ScrollContainer/VBoxContainer
	var slots = $Menu/ScrollContainer/VBoxContainer/GridContainer
	var slot = load("res://scenes/ui/slot.tscn")
	var inventory = SaveGame.get_inventory()
	var count = 0

	for item in inventory.keys():
		var new_slot = slot.instance()
		new_slot.item = item
		slots.add_child(new_slot)
		new_slot.show()
		count = SaveGame.get_item_count(str(item))

		if count > 1:
			new_slot.get_node("amount").text = str(count)
		else:
			new_slot.get_node("amount").hide()
	