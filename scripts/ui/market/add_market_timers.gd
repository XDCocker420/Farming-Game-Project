extends Node

# Hilfsskript, das Timer-Labels zu allen Markt-Slots hinzufügt

func _ready():
	# Warte einen Frame, damit die UI vollständig initialisiert ist
	await get_tree().process_frame
	
	# Finde ui_markt in der Hierarchie
	var ui_markt = get_ui_markt()
	if not ui_markt:
		print("Konnte ui_markt nicht finden")
		return
	
	# Verbinde mit SaveGame-Signalen
	SaveGame.items_added_to_market.connect(_on_market_item_added)
	SaveGame.market_item_sold.connect(_on_market_item_sold)
	
	# Füge Timer zu allen Slots hinzu
	add_timers_to_slots(ui_markt)

# Utility-Funktion, um die ui_markt Instanz zu finden
func get_ui_markt():
	var parent = get_parent()
	while parent:
		if parent.has_node("CanvasLayer/ui_markt"):
			return parent.get_node("CanvasLayer/ui_markt")
		parent = parent.get_parent()
	return null

# Fügt Timer-Labels zu allen Markt-Slots hinzu
func add_timers_to_slots(ui_markt):
	if not ui_markt.has_node("MarginContainer/slots"):
		print("Konnte slots-Container nicht finden")
		return
	
	var slots_container = ui_markt.get_node("MarginContainer/slots")
	var timer_scene = preload("res://scenes/ui/market/market_timer_label.tscn")
	
	for slot in slots_container.get_children():
		# Wenn es ein PanelContainer Objekt ist (Typ-Check statt "is")
		if slot is PanelContainer:
			# Wenn noch kein Timer-Label existiert, füge eines hinzu
			if not slot.has_node("MarketTimerLabel"):
				var timer_label = timer_scene.instantiate()
				slot.add_child(timer_label)
				# Positioniere das Label am oberen Rand des Slots
				timer_label.position = Vector2(0, 0)
				timer_label.size.x = slot.size.x

# Signal-Handler für hinzugefügte Markt-Items
func _on_market_item_added(_item_name):
	# Aktualisiere die Anzeige, wenn ein neues Item zum Markt hinzugefügt wurde
	var ui_markt = get_ui_markt()
	if ui_markt:
		add_timers_to_slots(ui_markt)

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
				
				# Verstecke das Timer-Label, falls vorhanden
				if slot.has_node("MarketTimerLabel"):
					slot.get_node("MarketTimerLabel").visible = false
	
	print("Verkauft: %d x %s für %d$" % [count, item_name, total_price]) 