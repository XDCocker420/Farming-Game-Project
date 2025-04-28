extends PanelContainer

signal item_purchased(item, quantity)

@onready var buy_button = $Control/PanelContainer/buy_button
@onready var ui_slot = $MarginContainer/slots/ui_slot

const BEER_ITEM = "beer"
const BEER_PRICE = 100000  # Price per beer
var quantity = 1
var player_money = 0

func _ready():
	buy_button.pressed.connect(_on_buy_pressed)
	hide()
	
	# Update display when shown
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		update_display()

func update_display():
	# Setup the slot to display the beer item
	if ui_slot and ui_slot.has_method("setup"):
		ui_slot.setup(BEER_ITEM, "", false, 1) # Show beer icon, no text, not clickable, quantity 1
	
	# Get player reference and update money display
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("get_money"):
		player_money = player.get_money()
		# No money label in current scene, might want to add one later
	else:
		player_money = 0 # Default to 0 if player money can't be fetched
	
	# Update buy button state based on whether player can afford
	buy_button.disabled = player_money < BEER_PRICE * quantity

func _on_buy_pressed():
	# Get player money *before* purchase attempt
	var current_money = 0
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("get_money"):
		current_money = player.get_money()
	
	# Check if player has enough money using the fetched value
	if current_money >= BEER_PRICE * quantity:
		# Deduct money using SaveGame
		SaveGame.remove_money(BEER_PRICE * quantity)
		
		# Add beer to player inventory using SaveGame
		SaveGame.add_to_inventory(BEER_ITEM, quantity)
		
		# Update UI - This will fetch the new money value
		update_display()
		
		# Emit signal that item was purchased
		item_purchased.emit(BEER_ITEM, quantity)
		
		# Print game end message
		print("Spielende")
	

func _on_close_button_pressed():
	hide() 