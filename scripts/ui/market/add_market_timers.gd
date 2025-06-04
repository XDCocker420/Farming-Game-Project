extends Node

# Hilfsskript, um die Markt-UI zu aktualisieren, wenn Items über SaveGame verkauft wurden.

func _ready() -> void:
	# Warte einen Frame, damit die gesamte Szene (inkl. ui_markt) wahrscheinlich initialisiert ist.
	await get_tree().process_frame

	if SaveGame.has_signal("market_item_sold"):
		SaveGame.market_item_sold.connect(_on_save_game_market_item_sold)
	else:
		printerr("add_market_timers.gd: SaveGame hat kein Signal 'market_item_sold'. UI-Slot-Leerung nach Verkauf wird nicht funktionieren.")


# Utility-Funktion, um die ui_markt Instanz zu finden.
func get_ui_markt_instance():
       # Schnellster Weg: Suche nach einem Node in der Gruppe "market_ui".
       var group_nodes = get_tree().get_nodes_in_group("market_ui")
       if group_nodes.size() > 0:
               var grp_node = group_nodes[0]
               if grp_node is PanelContainer and grp_node.has_method("clear_market_slot_for_item"):
                       return grp_node

       var root_node = get_tree().current_scene
       if not root_node:
               printerr("add_market_timers.gd: Konnte keinen root_node (current_scene) finden.")
               return null

       # Versuch 1: Standardpfad über CanvasLayer (häufig für UI)
       var ui_markt_node = root_node.get_node_or_null("CanvasLayer/ui_markt")
       if ui_markt_node and ui_markt_node is PanelContainer and ui_markt_node.has_method("clear_market_slot_for_item"):
               return ui_markt_node

       # Versuch 2: Direkter Kindknoten des Root-Nodes mit dem Namen "ui_markt"
       ui_markt_node = root_node.get_node_or_null("ui_markt")
       if ui_markt_node and ui_markt_node is PanelContainer and ui_markt_node.has_method("clear_market_slot_for_item"):
               return ui_markt_node

       printerr("add_market_timers.gd: Konnte ui_markt Instanz nicht finden. Geprüfte Pfade: 'CanvasLayer/ui_markt', 'ui_markt' sowie Gruppe 'market_ui'. Stelle sicher, dass ui_markt geladen ist oder passe get_ui_markt_instance an.")
       return null


func _on_save_game_market_item_sold(item_name: String, amount_sold: int, total_price_for_stack: int):
	# Dieses Signal wird von SaveGame.gd ausgelöst, NACHDEM das Geld hinzugefügt wurde und das Item
	# aus der market_sav Liste entfernt wurde.
	# Die Aufgabe hier ist nur, den visuellen Slot in der UI zu leeren.


	var ui_markt_instance = get_ui_markt_instance()

	if ui_markt_instance:
		# Die Methode clear_market_slot_for_item in ui_markt.gd erwartet:
		# item_name_sold: String, amount_sold: int, price_sold_total: int
		# Das Signal von SaveGame.market_item_sold liefert genau diese Parameter.
		ui_markt_instance.clear_market_slot_for_item(item_name, amount_sold, total_price_for_stack)
	else:
		printerr("add_market_timers.gd: ui_markt Instanz nicht gefunden beim Versuch, Slot für verkauftes Item '%s' zu leeren." % item_name)
