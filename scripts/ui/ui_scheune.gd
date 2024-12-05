extends Control


func _ready() -> void:
	SaveGame.add_to_inventory("carrot", 5)
	SaveGame.add_to_inventory("wheat", 2)
	SaveGame.add_to_inventory("corn", 3)
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

	for item in inventory.keys():
		var new_slot = slot.instantiate()
		var temp = Sprite2D.new()
		temp.texture = load("res://assets/gui/icons/" + item + ".png")
		new_slot.add_child(temp)
		slots.add_child(new_slot)
		new_slot.show()
		count = SaveGame.get_item_count(str(item))

		if count > 1:
			new_slot.get_node("Node2D/amount").text = str(count)
		else:
			new_slot.get_node("Node2D/amount").hide()
	
