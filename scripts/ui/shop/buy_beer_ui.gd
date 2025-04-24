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
	
	# Update buy button state based on whether player can afford
	buy_button.disabled = player_money < BEER_PRICE * quantity

func _on_buy_pressed():
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# Check if player has enough money
		if player_money >= BEER_PRICE * quantity:
			# Deduct money from player
			if player.has_method("change_money"):
				player.change_money(-BEER_PRICE * quantity)
			
			# Add beer to player inventory
			if player.has_method("add_item"):
				player.add_item(BEER_ITEM, quantity)
			
			# Update UI
			update_display()
			
			# Emit signal that item was purchased
			item_purchased.emit(BEER_ITEM, quantity)
		else:
			print("Not enough money to buy beer")

func _on_close_button_pressed():
	hide() 