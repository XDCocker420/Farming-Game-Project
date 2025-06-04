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
	var group_nodes = get_tree().get_nodes_in_group("market_ui")
	if group_nodes.size() > 0:
		var grp_node = group_nodes[0]
		if grp_node is PanelContainer and grp_node.has_method("clear_market_slot_for_item"):
			return grp_node
	return null

func _on_save_game_market_item_sold(item_name: String, amount_sold: int, total_price_for_stack: int):
	# Dieses Signal wird von SaveGame.gd ausgelöst, NACHDEM das Geld hinzugefügt wurde und das Item
	# aus der market_sav Liste entfernt wurde.
	# Die Aufgabe hier ist nur, den visuellen Slot in der UI zu leeren.


	var ui_markt_instance = get_ui_markt_instance()

	if ui_markt_instance:
		ui_markt_instance.clear_market_slot_for_item(item_name, amount_sold, total_price_for_stack)
