extends Node

# Hilfsskript für das Markt-System (Timer werden im Hintergrund verwaltet)

func _ready():
	# Warte einen Frame, damit die UI vollständig initialisiert ist
	await get_tree().process_frame
	
	# Verbinde mit SaveGame-Signalen
	SaveGame.items_added_to_market.connect(_on_market_item_added)
	SaveGame.market_item_sold.connect(_on_market_item_sold)

# Utility-Funktion, um die ui_markt Instanz zu finden
func get_ui_markt():
	var parent = get_parent()
	while parent:
		if parent.has_node("CanvasLayer/ui_markt"):
			return parent.get_node("CanvasLayer/ui_markt")
		parent = parent.get_parent()
	return null

# Signal-Handler für hinzugefügte Markt-Items
func _on_market_item_added(_item_name):
	# Nur noch für Debug-Zwecke
	pass

# Signal-Handler für verkaufte Markt-Items
func _on_market_item_sold(item_name, count, total_price):
	# Aktualisiere die UI, nachdem ein Item verkauft wurde
	var ui_markt = get_ui_markt()
	if ui_markt and ui_markt.has_node("MarginContainer/slots"):
		var slots_container = ui_markt.get_node("MarginContainer/slots")
		
		# Durchlaufe alle Slots
		for slot in slots_container.get_children():
			if not (slot is PanelContainer):
				continue
				
			# Wenn der Slot das verkaufte Item enthält
			if slot.get("item_name") == item_name:
				# Leere den Slot manuell (ohne clear zu verwenden, da es Probleme geben könnte)
				if slot.has_node("MarginContainer/item"):
					slot.get_node("MarginContainer/item").texture = null
				if slot.has_node("amount"):
					slot.get_node("amount").text = ""
					slot.get_node("amount").hide()
				
				# Wichtig: Setze alle relevanten Eigenschaften zurück
				slot.set("item_name", "")
				slot.set("price", 0)
	
	print("Verkauft: %d x %s für %d$" % [count, item_name, total_price]) 