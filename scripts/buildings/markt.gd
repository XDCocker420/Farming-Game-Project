extends StaticBody2D


@onready var player: CharacterBody2D = %Player
@onready var ui_markt: PanelContainer = $CanvasLayer/ui_markt
@onready var ui_selection: PanelContainer = $CanvasLayer/ui_selection
@onready var interact_area: Area2D = $interact_area
@onready var door: AnimatedSprite2D = $door
@onready var canvas_layer: CanvasLayer = $CanvasLayer  # Direct reference to CanvasLayer

var selected_texture: Texture2D
var selected_slot: PanelContainer
var selected_name: String

var player_in_area: bool = false


func _ready() -> void:
	# CRITICAL FIX: Set CanvasLayer to handle inputs properly
	canvas_layer.layer = 100  # Put it on top of other layers
	
	# Ensure UI elements are hidden at start
	ui_markt.hide()
	ui_selection.hide()
	
	# Connect signals
	if player:
		player.interact.connect(_on_player_interact)
	interact_area.body_entered.connect(_on_player_entered)
	interact_area.body_exited.connect(_on_player_exited)
	ui_markt.select_item.connect(_on_select)
	ui_selection.put_item.connect(_on_put)
	ui_selection.accept.connect(_on_accept)
	
	# Verbinde mit dem market_item_sold Signal, um die UI zu aktualisieren
	SaveGame.market_item_sold.connect(_on_market_item_sold)


func _on_player_interact() -> void:
	if player_in_area:
		if ui_markt.visible:
			ui_markt.hide()
			ui_selection.hide()
		else:
			# Force the UI to have clean state
			ui_markt.process_mode = Node.PROCESS_MODE_ALWAYS
			ui_markt.mouse_filter = Control.MOUSE_FILTER_STOP
			
			# Force UI to visible state
			ui_markt.show()
			ui_markt.grab_focus()
			
			# Make it truly forward-facing
			ui_markt.z_index = 1000
			
			# Force input processing to ensure clicks are recognized
			get_viewport().set_input_as_handled()
			
			# Optionally test by simulating a click on a slot
			if ui_markt.slot_list.size() > 0:
				var test_slot = ui_markt.slot_list[0]
				if test_slot.has_node("button"):
					var test_button = test_slot.get_node("button")
					# This should trigger the button press signal
					test_button.grab_focus()


func _on_select(slot: PanelContainer) -> void:
	# CRITICAL FIX: Only continue if the slot is not locked
	if slot.get("locked"):
		return
	
	# Wenn der Slot bereits ein Item enthält, ignorieren wir die Auswahl
	if slot.item_name != "" && slot.item_name != null:
		return
	
	# Oder alternativ prüfen, ob ein Item-Texture vorhanden ist
	if slot.has_node("MarginContainer/item") && slot.get_node("MarginContainer/item").texture != null:
		return
		
	# Save the selected slot for later
	selected_slot = slot
	
	# Show the selection UI
	ui_selection.show()
	ui_selection.z_index = 1001


func _on_put(item_name: String, item_texture: Texture2D) -> void:
	selected_texture = item_texture
	selected_name = item_name
		

func _on_accept(amount: int, price: int) -> void:
	if selected_texture == null:
		return
	
	# Check if the necessary nodes exist
	if selected_slot.has_node("MarginContainer/item") && selected_slot.has_node("amount"):
		var current_texture: TextureRect = selected_slot.get_node("MarginContainer/item")
		var current_amount_label: Label = selected_slot.get_node("amount")
		
		current_texture.texture = selected_texture
		current_amount_label.text = str(amount)
		
		# Verwende den vom Spieler angegebenen Preis
		selected_slot.price = price
		selected_slot.item_name = selected_name
		
		# Die Slot-ID abrufen, um das Markt-Item korrekt zu identifizieren
		var slot_id = 0
		if selected_slot.get("id") != null:
			slot_id = selected_slot.get("id")
		
		SaveGame.remove_from_inventory(selected_name, amount)
		
		selected_texture = null
		ui_selection.hide()
		
		# Erstelle das Market-Item mit der richtigen Slot-ID
		SaveGame.add_market_slot(slot_id, selected_name, amount, price)
	else:
		# Could not find required nodes
		pass


func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && LevelingHandler.is_building_unlocked("markt"):
		player_in_area = true
		door.play("open")
	
	
func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		ui_markt.hide()
		ui_selection.hide()
		door.play_backwards("open")


# Neuer Signal-Handler: Entfernt das Item aus dem UI-Slot, wenn es verkauft wurde
func _on_market_item_sold(item_name: String, count: int, total_price: int) -> void:
	print("Markt: Verkauft - %d x %s für %d$" % [count, item_name, total_price])
	
	if not ui_markt or not ui_markt.has_node("MarginContainer/slots"):
		return
		
	# Finde alle Slots, die das verkaufte Item enthalten könnten
	var slots_container = ui_markt.get_node("MarginContainer/slots")
	for slot in slots_container.get_children():
		if not (slot is PanelContainer):
			continue
			
		# Prüfe, ob der Slot das verkaufte Item enthält
		if slot.get("item_name") == item_name:
			print("Slot mit verkauftem Item gefunden - leere Slot %s" % slot.get("id"))
			
			# Direkte manuelle Leerung des Slots
			if slot.has_node("MarginContainer/item"):
				slot.get_node("MarginContainer/item").texture = null
			if slot.has_node("amount"):
				slot.get_node("amount").text = ""
				slot.get_node("amount").hide()
			
			# Setze Eigenschaften direkt zurück
			slot.set("item_name", "")
			slot.set("price", 0)
			
			# Falls der Slot eine clear() Methode hat, rufe sie zusätzlich auf
			if slot.has_method("clear"):
				slot.clear()
			
	# Aktualisiere die UI nach dem Verkauf
	if ui_markt.visible:
		ui_markt.hide()
		ui_markt.show()  # Erzwinge eine Neuzeichnung
