extends PanelContainer


signal select_item(slot: PanelContainer)

@onready var slots: GridContainer = $MarginContainer/slots
@onready var ui_slot_buy: PanelContainer = $CenterContainer/ui_slot_buy
@onready var center_container: CenterContainer = $CenterContainer

# WICHTIG: Passe diesen Pfad ggf. an deine Szenenstruktur an!
# Annahme: ui_selection ist ein Geschwisterknoten oder hat einen bekannten relativen Pfad.
@onready var ui_selection_node: PanelContainer = get_node("../ui_selection") if has_node("../ui_selection") else null


var current_buy_slot: PanelContainer
var slot_list: Array # Behältst du diese Variable für etwas bei? Sie wird im Original _ready initialisiert aber nicht überall verwendet.


func _ready() -> void:
	# Set up basic UI configuration
	mouse_filter = Control.MOUSE_FILTER_STOP
	slots.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Critical: This ensures the UI is always clickable
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Get UI elements
	# slot_list = slots.get_children() # Wird diese Zuweisung noch so benötigt?

	# Connect buy button signal from ui_slot_buy (for purchasing market slots/unlocks)
	if ui_slot_buy and ui_slot_buy.has_signal("buy"): # Check if ui_slot_buy is valid
		if ui_slot_buy.buy.is_connected(_buy_slot):
			ui_slot_buy.buy.disconnect(_buy_slot)
		ui_slot_buy.buy.connect(_buy_slot)
	
	# Connect slot signals for existing market slots (e.g., for player to buy from market)
	for slot_node: PanelContainer in slots.get_children():
		if not (slot_node is PanelContainer): # Sicherstellen, dass es ein PanelContainer ist
			continue
		# Connect the slot selection signal - for choosing items
		if slot_node.has_signal("slot_selection"):
			if slot_node.slot_selection.is_connected(_on_slot_selected):
				slot_node.slot_selection.disconnect(_on_slot_selected)
			slot_node.slot_selection.connect(_on_slot_selected)
			
		# Connect the slot unlock signal - for locked slots
		if slot_node.has_signal("slot_unlock"):
			if slot_node.slot_unlock.is_connected(_on_slot_unlock):
				slot_node.slot_unlock.disconnect(_on_slot_unlock)
			slot_node.slot_unlock.connect(_on_slot_unlock)
	
	# Connect to the accept signal from ui_selection (player wants to sell an item)
	if ui_selection_node:
		if ui_selection_node.has_signal("accept"):
			if ui_selection_node.accept.is_connected(_on_ui_selection_accept):
				ui_selection_node.accept.disconnect(_on_ui_selection_accept)
			ui_selection_node.accept.connect(_on_ui_selection_accept)
		else:
			printerr("ui_markt.gd: ui_selection_node ('%s') does not have 'accept' signal." % ui_selection_node.name)
	else:
		printerr("ui_markt.gd: ui_selection_node not found (path: '../ui_selection'). Cannot connect to 'accept' signal. Bitte Pfad prüfen!")

	# The visibility_changed connection
	if visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.disconnect(_on_visibility_changed)
	visibility_changed.connect(_on_visibility_changed)


func _on_ui_selection_accept(item_name: String, amount_to_sell: int, total_price: int):
	# 1. Remove item from player inventory
	var removed_successfully = false
	# KORREKTUR: Funktionsname in SaveGame ist remove_from_inventory und gibt void zurück.
	# Wir prüfen den Erfolg, indem wir die Item-Anzahl vor und nach dem Aufruf vergleichen.
	if SaveGame.has_method("remove_from_inventory") and SaveGame.has_method("get_item_count"):
		var count_before_removal = SaveGame.get_item_count(item_name)
		
		# Stelle sicher, dass genug Items vorhanden sind, bevor der Versuch unternommen wird.
		if count_before_removal < amount_to_sell:
			printerr("ui_markt.gd: Nicht genug Items von '%s' im Inventar (Benötigt: %d, Vorhanden: %d)." % [item_name, amount_to_sell, count_before_removal])
			if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
			return

		SaveGame.remove_from_inventory(item_name, amount_to_sell)
		var count_after_removal = SaveGame.get_item_count(item_name)

		# Erfolgsprüfung:
		# 1. Wenn die vorherige Menge >= der zu entfernenden Menge war, dann muss die neue Menge (alt - entfernt) sein.
		# 2. Wenn die vorherige Menge < der zu entfernenden Menge war (dieser Fall wird oben abgefangen, aber zur Sicherheit),
		#    und remove_from_inventory das Item komplett entfernt, dann sollte die neue Menge 0 sein.
		#    Da remove_from_inventory bei Fehlern abbricht oder das Item entfernt, wenn count <= 0 wird,
		#    ist eine einfache Prüfung (alt - neu == verkauft) ausreichend, wenn alt >= verkauft war.
		if count_before_removal >= amount_to_sell and count_after_removal == count_before_removal - amount_to_sell:
			removed_successfully = true
		# Fall: Item wurde komplett entfernt, weil count_before_removal == amount_to_sell
		elif count_before_removal == amount_to_sell and count_after_removal == 0 and not SaveGame.get_inventory().has(item_name):
			removed_successfully = true
		# Fall: Weniger als amount_to_sell war da, aber remove_from_inventory hat alles entfernt was da war (bis zu amount_to_sell)
		# Dies wird durch die Logik in remove_from_inventory abgedeckt, die das Item entfernt, wenn data[item] <= 0.
		# Die obige Prüfung (count_before_removal < amount_to_sell) sollte dies aber schon verhindern.

		if not removed_successfully:
			# Dies sollte nur passieren, wenn remove_from_inventory nicht wie erwartet funktioniert
			# oder das Spiel nicht beendet hat, obwohl es sollte (laut push_error, get_tree().quit() in SaveGame).
			printerr("ui_markt.gd: Item-Anzahl von '%s' nach remove_from_inventory inkonsistent. Vorher: %d, Nachher: %d, Versuch zu entfernen: %d" % [item_name, count_before_removal, count_after_removal, amount_to_sell])
			# Item potenziell zurückgeben oder zumindest UI neu laden, um Diskrepanz zu zeigen
			if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
			return
	else:
		printerr("ui_markt.gd: SaveGame.remove_from_inventory oder SaveGame.get_item_count Methode nicht gefunden.")
		return

	# 2. Find an empty slot in ui_markt.gd's 'slots' GridContainer
	var target_slot: PanelContainer = null
	for slot_candidate in slots.get_children():
		if slot_candidate is PanelContainer:
			var current_slot_item_name = slot_candidate.get("item_name") 
			if current_slot_item_name == null or current_slot_item_name == "":
				target_slot = slot_candidate
				break
	
	if not target_slot:
		printerr("ui_markt.gd: Kein freier Markt-Slot verfügbar für Item %s." % item_name)
		# Item zurückgeben, da kein Platz
		if SaveGame.has_method("add_to_inventory"): # KORREKTUR: Funktionsname in SaveGame ist add_to_inventory
			SaveGame.add_to_inventory(item_name, amount_to_sell)
			printerr("ui_markt.gd: Item %s (Menge: %d) wurde dem Inventar zurückgegeben." % [item_name, amount_to_sell])
		# Inventar-UI nach fehlgeschlagenem Verkauf neu laden, um den zurückgegebenen Artikel anzuzeigen
		if ui_selection_node and ui_selection_node.has_method("reload_slots"):
			ui_selection_node.reload_slots()
		return

	# 3. Populate this market slot (visuelle Darstellung)
	var item_icon_path = "res://assets/ui/icons/" + item_name + ".png"
	var item_texture = load(item_icon_path) if FileAccess.file_exists(item_icon_path) else null

	if target_slot.has_node("MarginContainer/item"):
		target_slot.get_node("MarginContainer/item").texture = item_texture
	else:
		printerr("ui_markt.gd: Ziel-Slot fehlt Node 'MarginContainer/item'.")
		if SaveGame.has_method("add_to_inventory"): SaveGame.add_to_inventory(item_name, amount_to_sell)
		if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
		return

	if target_slot.has_node("amount"):
		var amount_label = target_slot.get_node("amount")
		amount_label.text = str(amount_to_sell)
		amount_label.show()
	else:
		printerr("ui_markt.gd: Ziel-Slot fehlt Label-Node 'amount'.")
		if SaveGame.has_method("add_to_inventory"): SaveGame.add_to_inventory(item_name, amount_to_sell)
		if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
		return
		
	target_slot.set("item_name", item_name)
	target_slot.set("price", total_price) # Gesamtpreis für den Stapel
	target_slot.set("amount_in_slot", amount_to_sell) # Menge im Slot für spätere Identifizierung durch clear_market_slot_for_item

	# 4. Add item to SaveGame's market tracking (this will handle timers and persistence)
	# KORREKTUR: Verwende SaveGame.add_market_slot
	# Die 'id' für add_market_slot muss eindeutig sein. Wir verwenden die Instance ID des UI-Slots.
	# Beachte: SaveGame.add_market_slot erwartet 'price' als Preis pro Stück, wenn es intern zur Berechnung der Verkaufszeit verwendet wird.
	# Das Signal 'accept' von ui_selection liefert aber 'total_price'.
	# Wir müssen hier ggf. den Preis pro Stück berechnen, wenn SaveGame.add_market_slot dies für die Timer-Logik so erwartet.
	# Laut SaveGame.add_market_slot(id:int, item:String, count:int=1, amount_to_sell:int=1), scheint 'amount_to_sell' der Preis zu sein (ggf. pro Stück).
	# Das 'accept' Signal in ui_selection.gd wurde zu accept(item_name: String, amount: int, price: int) geändert,
	# wobei 'price' der Gesamtpreis ist.
	# Wir nehmen an, 'total_price' ist der Gesamtpreis des Stapels.
	# SaveGame.add_market_slot erwartet 'amount_to_sell' als Parameter, der dem Preis entspricht.
	# Wenn dies der Preis pro Stück sein soll, muss es hier berechnet werden.
	# Die Implementierung in SaveGame.add_market_slot: temp.price = amount_to_sell
	# Und in SaveGame.check_market_sales: var total_price_calculated = market_item.price * market_item.count
	# Das bedeutet, der 'amount_to_sell' Parameter in add_market_slot MUSS der Preis PRO STÜCK sein.
	
	var price_per_item: int
	if amount_to_sell > 0:
		price_per_item = int(round(float(total_price) / amount_to_sell))
	else:
		# Wenn amount_to_sell 0 ist, kann price_per_item nicht sinnvoll berechnet werden.
		# Wenn total_price auch 0 ist, ist price_per_item = 0 korrekt.
		# Wenn total_price > 0 ist (ungewöhnlicher Fall), wird dies unten korrigiert.
		price_per_item = 0
		
	# Sicherstellen, dass price_per_item mindestens 1 ist, wenn der Gesamtpreis positiv war,
	# um Probleme mit Timer-Berechnungen in SaveGame zu vermeiden, die einen Preis > 0 erwarten könnten.
	if price_per_item <= 0 and total_price > 0:
		price_per_item = 1

	var market_slot_id = target_slot.get_instance_id() # Eindeutige ID für den Markt-Slot

	if SaveGame.has_method("add_market_slot"):
		# Parameter für add_market_slot: (id: int, item: String, count: int, price_per_item: int)
		var saved_market_item_ref = SaveGame.add_market_slot(market_slot_id, item_name, amount_to_sell, price_per_item)
		if saved_market_item_ref == null:
			printerr("ui_markt.gd: SaveGame.add_market_slot hat null zurückgegeben. Fehler beim Hinzufügen zum Markt.")
			# Item zurückgeben und UI-Slot leeren
			if SaveGame.has_method("add_to_inventory"): SaveGame.add_to_inventory(item_name, amount_to_sell)
			if target_slot.has_node("MarginContainer/item"): target_slot.get_node("MarginContainer/item").texture = null
			if target_slot.has_node("amount"): target_slot.get_node("amount").text = ""
			target_slot.set("item_name", "")
			target_slot.set("price", 0)
			target_slot.set("amount_in_slot", 0)
			if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
			return
		# Speichere die ID des SaveGame-Markt-Items im UI-Slot, falls wir sie später brauchen
		target_slot.set("save_game_market_id", market_slot_id)

	else:
		printerr("ui_markt.gd: SaveGame hat keine Methode 'add_market_slot'.")
		# Item zurückgeben und UI-Slot leeren etc. (wie oben)
		if SaveGame.has_method("add_to_inventory"): SaveGame.add_to_inventory(item_name, amount_to_sell)
		if target_slot.has_node("MarginContainer/item"): target_slot.get_node("MarginContainer/item").texture = null
		if target_slot.has_node("amount"): target_slot.get_node("amount").text = ""
		target_slot.set("item_name", "")
		target_slot.set("price", 0)
		target_slot.set("amount_in_slot", 0)
		if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
		return

	# 5. Refresh ui_selection's player inventory display
	if ui_selection_node and ui_selection_node.has_method("reload_slots"):
		ui_selection_node.reload_slots()

	# NEU: Schließe die ui_selection Ansicht nach erfolgreicher Aktion
	if ui_selection_node and ui_selection_node.has_method("hide"):
		ui_selection_node.hide()
		# Optional: Wenn die ui_selection auch input blockiert, könnte man hier set_process_input(false) aufrufen
		# ui_selection_node.set_process_input(false) 
	# Optional: Fokus zurück auf ui_markt geben, falls nötig
	# self.grab_focus()
		
	print("Item %s (Menge: %d, Preis pro Stk.: %d, Gesamt: %d) in Markt-Slot %s (ID: %d) platziert. Verkauf durch SaveGame initiiert. UI Selection geschlossen." % [item_name, amount_to_sell, price_per_item, total_price, target_slot.name, market_slot_id])


func clear_market_slot_for_item(item_name_sold: String, amount_sold: int, price_sold_total: int): # price_sold ist hier der Gesamtpreis vom Signal
	# Finde den Slot basierend auf den Verkaufsdaten.
	# Die 'price_sold_total' vom Signal ist der Gesamtpreis des Verkaufs.
	# Die UI-Slots speichern 'price' (Gesamtpreis) und 'amount_in_slot'.
	# Die 'save_game_market_id' wäre ideal, wenn sie zuverlässig vom Signal käme oder wir sie hier mappen könnten.
	# Da das `market_item_sold`-Signal in SaveGame keine ID direkt mitliefert, müssen wir den Slot weiterhin
	# anhand von item_name, amount und total_price identifizieren.
	for slot_node in slots.get_children():
		if slot_node is PanelContainer:
			var slot_item_name = slot_node.get("item_name")
			# 'price' im UI slot ist der Gesamtpreis des Stacks, 'amount_in_slot' die Menge
			var slot_total_price = slot_node.get("price") 
			var slot_amount = slot_node.get("amount_in_slot")

			# Vergleiche mit den Daten aus dem Verkaufssignal
			if slot_item_name == item_name_sold and slot_amount == amount_sold and slot_total_price == price_sold_total:
				if slot_node.has_node("MarginContainer/item"):
					slot_node.get_node("MarginContainer/item").texture = null
				if slot_node.has_node("amount"):
					var amount_label = slot_node.get_node("amount")
					amount_label.text = ""
					amount_label.hide()
				
				slot_node.set("item_name", "")
				slot_node.set("price", 0)
				slot_node.set("amount_in_slot", 0) 
				slot_node.set("save_game_market_id", 0) # Zurücksetzen
				
				print("ui_markt.gd: Markt-Slot (Name: %s) für verkauftes Item geleert: %s, Menge: %d" % [slot_node.name, item_name_sold, amount_sold])
				return # Slot gefunden und geleert
				
	printerr("ui_markt.gd: Konnte passenden Markt-Slot zum Leeren nicht finden für: %s, Menge: %d, Gesamtpreis: %d" % [item_name_sold, amount_sold, price_sold_total])

# Handle UI appearing
func _on_visibility_changed() -> void:
	if visible:
		set_process_input(true)
		# Optional: Wenn ui_markt sichtbar wird, könnte man auch die ui_selection aktualisieren,
		# falls sie nicht ohnehin durch ihre eigene Logik aktuell gehalten wird.
		# if ui_selection_node and ui_selection_node.has_method("reload_slots"):
		#    ui_selection_node.reload_slots()


func _on_slot_selected(slot: PanelContainer) -> void:
	select_item.emit(slot)


func _on_slot_unlock(slot: PanelContainer, price: int):
	center_container.show()
	
	# Show the price
	if ui_slot_buy.has_node("MarginContainer/VBoxContainer/Label"): # Check if ui_slot_buy is valid and has node
		var price_label: Label = ui_slot_buy.get_node("MarginContainer/VBoxContainer/Label")
		price_label.text = str(price) + "$"
	
	current_buy_slot = slot


func _buy_slot():
	# Unlock the slot
	if current_buy_slot: # Check if current_buy_slot is valid
		current_buy_slot.set("locked", false)
		current_buy_slot.unlock()
	
	# Hide the buy UI after transaction
	center_container.hide()


# Handle UI control
func _input(event: InputEvent):
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()
