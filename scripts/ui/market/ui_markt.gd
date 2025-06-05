extends PanelContainer


signal select_item(slot: PanelContainer)

@onready var slots: GridContainer = $MarginContainer/slots
@onready var ui_slot_buy: PanelContainer = $CenterContainer/ui_slot_buy
@onready var center_container: CenterContainer = $CenterContainer

# WICHTIG: Passe diesen Pfad ggf. an deine Szenenstruktur an!
# Annahme: ui_selection ist ein Geschwisterknoten oder hat einen bekannten relativen Pfad.
@onready var ui_selection_node: PanelContainer = get_node("../ui_selection") if has_node("../ui_selection") else null

# Variablen für die neue CanvasLayer-Lösung
var temp_canvas_layer: CanvasLayer
var selection_parent: Node

var _currently_targeted_slot_for_selling: PanelContainer = null # WIEDER EINGEFÜHRT
var current_buy_slot: PanelContainer
var slot_list: Array # Behältst du diese Variable für etwas bei? Sie wird im Original _ready initialisiert aber nicht überall verwendet.


func _ready() -> void:
	# Set up basic UI configuration
	mouse_filter = Control.MOUSE_FILTER_STOP
	slots.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Critical: This ensures the UI is always clickable
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Füge dieses UI zur market_ui-Gruppe hinzu, damit es von ui_selection gefunden werden kann
	add_to_group("market_ui")
	
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
		else:
			# Fallback: Wenn kein "slot_selection" Signal da ist, verbinde mit "gui_input" und prüfe auf Klick.
			# Dies ist weniger ideal als ein dediziertes Signal vom Slot selbst.
			if not slot_node.is_connected("gui_input", Callable(self, "_on_slot_gui_input").bind(slot_node)):
				slot_node.connect("gui_input", Callable(self, "_on_slot_gui_input").bind(slot_node))
			
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


# Fallback GUI Input Handler, falls Slots kein "slot_selection" Signal haben
func _on_slot_gui_input(event: InputEvent, slot_node: PanelContainer):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_slot_selected(slot_node)


# WIEDERHERGESTELLT und angepasst: Diese Funktion wird jetzt verwendet, um einen Slot als Verkaufsziel zu markieren.
# ANMERKUNG: In Godot 4 heißt die Methode zum Verschieben eines Nodes nach vorn "move_to_front()" (statt "raise()" in Godot 3)
func _on_slot_selected(slot: PanelContainer) -> void:
	var item_in_slot = slot.get("item_name")
	var is_empty = (item_in_slot == null or item_in_slot == "")
	var is_locked = slot.get("locked") if slot.has_meta("locked") else false

	if is_empty and not is_locked:
		_currently_targeted_slot_for_selling = slot
		# Highlight-Logik könnte hierhin (optional)

		if ui_selection_node:
			if ui_selection_node.has_method("reset_ui"): 
				ui_selection_node.reset_ui()
			
			# NEUE RADIKALE LÖSUNG: ui_selection in einen eigenen temporären CanvasLayer setzen
			# Speichere den aktuellen Parent für die spätere Wiederherstellung
			selection_parent = ui_selection_node.get_parent()
			
			# Erstelle einen neuen temporären CanvasLayer mit hoher Layer-Nummer
			temp_canvas_layer = CanvasLayer.new()
			temp_canvas_layer.layer = 100  # Sehr hohe Ebene, garantiert über allem anderen
			get_tree().root.add_child(temp_canvas_layer)
			
			# Entferne ui_selection vom aktuellen Parent
			if selection_parent:
				selection_parent.remove_child(ui_selection_node)
			
			# Füge ui_selection zum neuen CanvasLayer hinzu
			temp_canvas_layer.add_child(ui_selection_node)
			
			# Position auf der Bildschirmmitte (oder an der gewünschten Position)
			ui_selection_node.global_position = Vector2(
				get_viewport_rect().size.x / 2 - ui_selection_node.size.x / 2,
				get_viewport_rect().size.y / 2 - ui_selection_node.size.y / 2
			)
			
			# Zeige das ui_selection-Panel
			ui_selection_node.show()
	else:
		# Das alte `select_item.emit(slot)` wird hier nicht mehr benötigt, wenn der Klick nur für die Auswahl des Verkaufs-Slots ist.
		# Wenn der Klick auf einen belegten Slot eine andere Aktion auslösen soll (z.B. Item kaufen), muss das separat gehandhabt werden.
		var reason = "nicht leer" if not is_empty else "gesperrt"


# WIEDERHERGESTELLT und angepasst: Verwendet _currently_targeted_slot_for_selling
func _on_ui_selection_accept(item_name: String, amount_to_sell: int, price_per_item: int):
	# 1. Prüfen, ob ein Ziel-Slot für den Verkauf ausgewählt wurde
	if not _currently_targeted_slot_for_selling:
		printerr("ui_markt.gd: Kein Markt-Slot wurde für den Verkauf ausgewählt. Bitte zuerst einen leeren Slot im Markt anklicken.")
		return

	var target_slot: PanelContainer = _currently_targeted_slot_for_selling

	# 2. Validieren des Ziel-Slots (ist er immer noch leer und ungesperrt?)
	var target_slot_item_name = target_slot.get("item_name")
	var target_slot_is_locked = target_slot.get("locked") if target_slot.has_meta("locked") else false
	if not (target_slot_item_name == null or target_slot_item_name == "") or target_slot_is_locked:
		var reason = "nicht mehr leer" if not (target_slot_item_name == null or target_slot_item_name == "") else "jetzt gesperrt"
		printerr("ui_markt.gd: Der ausgewählte Ziel-Slot ('%s') ist %s. Bitte einen anderen leeren, ungesperrten Slot wählen." % [target_slot.name, reason])
		_currently_targeted_slot_for_selling = null 
		return

	# 3. Item aus dem Spieler-Inventar entfernen (Logik von vorheriger funktionierender Version beibehalten)
	var removed_successfully = false
	if SaveGame.has_method("remove_from_inventory") and SaveGame.has_method("get_item_count"):
		var count_before_removal = SaveGame.get_item_count(item_name)
		if count_before_removal < amount_to_sell:
			printerr("ui_markt.gd: Nicht genug Items von '%s' im Inventar (Benötigt: %d, Vorhanden: %d)." % [item_name, amount_to_sell, count_before_removal])
			if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
			return

		SaveGame.remove_from_inventory(item_name, amount_to_sell)
		var count_after_removal = SaveGame.get_item_count(item_name)
		if (count_before_removal >= amount_to_sell and count_after_removal == count_before_removal - amount_to_sell) or \
		   (count_before_removal == amount_to_sell and count_after_removal == 0 and not SaveGame.get_inventory().has(item_name)):
			removed_successfully = true
		
		if not removed_successfully:
			printerr("ui_markt.gd: Item-Anzahl von '%s' nach remove_from_inventory inkonsistent." % item_name)
			if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
			return
	else:
		printerr("ui_markt.gd: SaveGame.remove_from_inventory oder SaveGame.get_item_count Methode nicht gefunden.")
		_currently_targeted_slot_for_selling = null 
		return

	# 4. Visuellen Slot befüllen (Logik von vorheriger funktionierender Version beibehalten)
	var item_icon_path = "res://assets/ui/icons/" + item_name + ".png"
	var item_texture = load(item_icon_path) if FileAccess.file_exists(item_icon_path) else null
	if not target_slot.has_node("MarginContainer/item"):
		printerr("ui_markt.gd: Ziel-Slot '%s' fehlt Node 'MarginContainer/item'." % target_slot.name)
		if SaveGame.has_method("add_to_inventory"): SaveGame.add_to_inventory(item_name, amount_to_sell)
		if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
		_currently_targeted_slot_for_selling = null 
		return
	target_slot.get_node("MarginContainer/item").texture = item_texture
	if not target_slot.has_node("amount"):
		printerr("ui_markt.gd: Ziel-Slot '%s' fehlt Label-Node 'amount'." % target_slot.name)
		if SaveGame.has_method("add_to_inventory"): SaveGame.add_to_inventory(item_name, amount_to_sell)
		target_slot.get_node("MarginContainer/item").texture = null 
		if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
		_currently_targeted_slot_for_selling = null
		return
		var amount_label = target_slot.get_node("amount")
		amount_label.text = str(amount_to_sell)
		amount_label.show()
		target_slot.set("item_name", item_name)
		var total_price = price_per_item * amount_to_sell
		target_slot.set("price", total_price)
		target_slot.set("amount_in_slot", amount_to_sell)

       # 5. Item im SaveGame für den Markt registrieren (Logik von vorheriger funktionierender Version)
	var market_slot_id = target_slot.get_instance_id()
	if SaveGame.has_method("add_market_slot"):
		var saved_market_item_ref = SaveGame.add_market_slot(market_slot_id, item_name, amount_to_sell, price_per_item)
		if saved_market_item_ref == null:
			printerr("ui_markt.gd: SaveGame.add_market_slot hat null zurückgegeben für Slot '%s'." % target_slot.name)
			if SaveGame.has_method("add_to_inventory"): SaveGame.add_to_inventory(item_name, amount_to_sell)
			target_slot.get_node("MarginContainer/item").texture = null
			target_slot.get_node("amount").text = ""
			target_slot.set("item_name", ""); target_slot.set("price", 0); target_slot.set("amount_in_slot", 0)
			if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
			_currently_targeted_slot_for_selling = null 
			return
		target_slot.set("save_game_market_id", market_slot_id)
	else:
		printerr("ui_markt.gd: SaveGame hat keine Methode 'add_market_slot'.")
		if SaveGame.has_method("add_to_inventory"): SaveGame.add_to_inventory(item_name, amount_to_sell)
		target_slot.get_node("MarginContainer/item").texture = null
		target_slot.get_node("amount").text = ""
		target_slot.set("item_name", ""); target_slot.set("price", 0); target_slot.set("amount_in_slot", 0)
		if ui_selection_node and ui_selection_node.has_method("reload_slots"): ui_selection_node.reload_slots()
		_currently_targeted_slot_for_selling = null 
		return

	# 6. Erfolg - Aufräumen und UI-Feedback (Logik von vorheriger funktionierender Version)
	if ui_selection_node and ui_selection_node.has_method("reload_slots"):
		ui_selection_node.reload_slots()
	if ui_selection_node:
		# NEUE LÖSUNG: ui_selection vom temporären CanvasLayer zurück zum ursprünglichen Parent bewegen
		if temp_canvas_layer and is_instance_valid(temp_canvas_layer):
			# Entferne ui_selection vom temporären CanvasLayer
			temp_canvas_layer.remove_child(ui_selection_node)
			
			# Füge ui_selection wieder zum ursprünglichen Parent hinzu
			if selection_parent and is_instance_valid(selection_parent):
				selection_parent.add_child(ui_selection_node)
			
			# Entferne den temporären CanvasLayer
			temp_canvas_layer.queue_free()
			temp_canvas_layer = null
		
		# Verstecke ui_selection
		if ui_selection_node.has_method("hide"):
			ui_selection_node.hide()
	
	_currently_targeted_slot_for_selling = null


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
		# Wenn ui_selection in einem temporären CanvasLayer aktiv ist, diesen zuerst aufräumen
		if temp_canvas_layer and is_instance_valid(temp_canvas_layer):
			_cleanup_temporary_canvas()
		hide()
		get_viewport().set_input_as_handled()


# Cancel-Handler für den Fall, dass der Benutzer den Vorgang ohne Abschluss abbricht
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		# Aufräumen, falls das Fenster geschlossen wird, während ui_selection im temporären CanvasLayer ist
		_cleanup_temporary_canvas()
		
# Hilfsfunktion zum sicheren Aufräumen des temporären CanvasLayers
func _cleanup_temporary_canvas():
	if temp_canvas_layer and is_instance_valid(temp_canvas_layer):
		if ui_selection_node and is_instance_valid(ui_selection_node) and ui_selection_node.get_parent() == temp_canvas_layer:
			# Entferne ui_selection vom CanvasLayer
			temp_canvas_layer.remove_child(ui_selection_node)
			
			# Füge es wieder zum ursprünglichen Parent hinzu
			if selection_parent and is_instance_valid(selection_parent):
				selection_parent.add_child(ui_selection_node)
				ui_selection_node.hide()
		
		# Entferne den CanvasLayer
		temp_canvas_layer.queue_free()
		temp_canvas_layer = null
