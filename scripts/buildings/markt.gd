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
		
	# Save the selected slot for later
	selected_slot = slot
	
	# Show the selection UI
	ui_selection.show()
	ui_selection.z_index = 1001
	
	# Check if this slot already has an item assigned
	if slot.has_node("MarginContainer/item") and slot.get_node("MarginContainer/item").texture != null:
		# We could implement removing/modifying existing items here
		# But for now we'll just allow adding new items
		pass
		

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
		
		SaveGame.remove_from_inventory(selected_name, amount)
		
		selected_texture = null
		ui_selection.hide()
		
		SaveGame.add_market_slot(0, selected_name, amount, price)
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
