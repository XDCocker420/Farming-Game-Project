extends Node

# File path for saving and loading
const SAVE_FILE_PATH: String = "user://savegame.tres"

# Auto-save interval in seconds
const AUTO_SAVE_INTERVAL: float = 60.0  # Save every 60 seconds

var inventory:Inventory = Inventory.new()
var con_sav:Array[SavedContracts] = []
var market_sav:Array[SavedMarket] = []
# Dictionary to hold the state of items left in workstation output slots
var workstation_output_states: Dictionary = {}
# Dictionary to hold the state of ongoing productions
var workstation_production_states: Dictionary = {}

var map = null
@onready var player = get_tree().get_first_node_in_group("Player")

var new_game:bool = false

signal money_added(money:int, added_value:int)
signal money_removed(money:int, removed_value:int)
signal market_bought(item_name:String)
signal loaded_game
signal items_added_to_market
signal market_item_sold(item_name: String, count: int, total_price: int)

func _ready() -> void:
	var map_nodes = get_tree().get_nodes_in_group("game_map")
	if map_nodes.size() > 0:
		map = map_nodes[0]

	start_auto_save_timer()
	start_market_check_timer() # Markt-Timer starten
	# Attempt to load existing game data
	if SceneSwitcher.get_current_scene_name() not in ["start_screen", "intro"]:
		load_game()

	# Start global production check timer
	var production_check_timer = Timer.new()
	production_check_timer.name = "ProductionCheckTimer"
	production_check_timer.wait_time = 1.0 # Check every second
	production_check_timer.autostart = true
	production_check_timer.timeout.connect(_check_finished_productions)
	add_child(production_check_timer)


func save_game() -> void:
	var save := SavedData.new()
	#update_player()
	if player:
		if SceneSwitcher.player_position != Vector2.ZERO:
			save.player_position = SceneSwitcher.player_position
		else:
			save.player_position = player.global_position

	save.player_name = Dialogic.VAR.global.player_name
	save.done_tutorial = Dialogic.VAR.global.done_tutorial
	save.player_level = LevelingHandler.get_current_level()
	save.player_experience_per_level = LevelingHandler.get_experience_in_current_level()
	save.contracts = con_sav
	save.market_items = market_sav

	var saved_data:Array[ItemSaves] = []
	get_tree().call_group("dynamic_elements", "on_save_game", saved_data)

	save.saved_data = saved_data
	save.inventory = inventory
	# Save workstation output states
	save.workstation_output_states = workstation_output_states
	# Save workstation production states
	save.workstation_production_states = workstation_production_states

	ResourceSaver.save(save, SAVE_FILE_PATH)

func save_exp_lvl() -> void:
	var saved_game:SavedData = ResourceLoader.load(SAVE_FILE_PATH)

	saved_game.player_level = LevelingHandler.get_current_level()
	saved_game.player_experience_per_level = LevelingHandler.get_experience_in_current_level()
	ResourceSaver.save(saved_game, SAVE_FILE_PATH)

func load_game() -> void:
	var saved_game:SavedData = ResourceLoader.load(SAVE_FILE_PATH)
	if saved_game == null:
	# For testing
		LevelingHandler.set_player_level(15)
		inventory.money = 1000000
		new_game = true
		if player:
			player.do_set_level()
			player.do_set_money()
			return

	if player:
		get_tree().call_group("dynamic_elements", "on_before_load_game")

		# Sichern einer Kopie des alten Inventars zum Vergleich
		var old_inventory = {}
		if inventory and inventory.data:
			old_inventory = inventory.data.duplicate()

		inventory = saved_game.inventory
		# Load workstation output states
		workstation_output_states = saved_game.workstation_output_states
		# Load workstation production states
		workstation_production_states = saved_game.workstation_production_states

		#await get_tree().process_frame
		LevelingHandler.set_player_level(saved_game.player_level)
		LevelingHandler.set_experience_in_current_level(saved_game.player_experience_per_level)
		player.global_position = saved_game.player_position
		con_sav = saved_game.contracts
		market_sav = saved_game.market_items
		if player.has_method("do_set_level"):
			player.do_set_level()
			player.do_set_money()

	await get_tree().process_frame

	Dialogic.VAR.global.player_name = saved_game.player_name
	Dialogic.VAR.global.done_tutorial = saved_game.done_tutorial

	for item in saved_game.saved_data:
		var scene := load(item.scene_path) as PackedScene
		if not scene:
			continue

		var restored_node = scene.instantiate()
		if not restored_node:
			continue

		if item is CropSaves:
			var parent = get_node_or_null(item.parent_path)
			if parent:
				parent.add_child(restored_node)
				if restored_node.has_method("on_load_game"):
					restored_node.on_load_game(item)
		else:
			map.add_child(restored_node)
			if restored_node.has_method("on_load_game"):
				restored_node.on_load_game(item)
	# for correct loading
	loaded_game.emit()

func add_to_inventory(item:String, count:int=1) -> void:
	if count < 1:
		push_error("count musst be bigger or equal 1")
		get_tree().quit()

	if count > 99:
		count = 99

	if inventory.data.has(item):
		inventory.data[item] += count
		if inventory.data[item] > 99:
			inventory.data[item] = 99
	else:
		inventory.data[item] = count

# removes something
func remove_from_inventory(item: String, count:int=1, remove_completly:bool=false) -> void:
	if count < 1:
		push_error("count musst be bigger or equal 1")
		get_tree().quit()
	if inventory == null or not inventory.data.has(item):
		push_error("Item not found in Inventory. Add it first")
		get_tree().quit()

	if remove_completly:
		inventory.data.erase(item)
		return

	inventory.data[item] -= count
	if inventory.data[item] <= 0:
		inventory.data.erase(item)

func get_inventory() -> Dictionary:
	return inventory.data

func get_item_count(item:String) -> int:
	if inventory == null or not inventory.data.has(item):
		return 0
	return inventory.data[item]

func add_money(count:int=1) -> void:
	if count < 1:
		push_error("count musst be bigger or equal 1")
		get_tree().quit()
	inventory.money += count
	money_added.emit(inventory.money, count)

func remove_money(count:int=1) -> bool:
	if count < 1:
		push_error("count musst be bigger or equal 1")
		get_tree().quit()
	if inventory.money - count < 0:
		return false
	inventory.money -= count
	money_removed.emit(inventory.money, count)
	return true

func get_money() -> int:
	return inventory.money

func add_contract(id:int, exp_val:int, money:int, items:Dictionary) -> SavedContracts:
	var temp:SavedContracts = SavedContracts.new()
	temp.id = id
	temp.exp_val = exp_val
	temp.currency = money
	temp.req_res = items
	con_sav.append(temp)
	return temp

func remove_contract(con:SavedContracts) -> SavedContracts:
	con_sav.remove_at(con_sav.find(con))
	return con

func get_contracts() -> Array[SavedContracts]:
	return con_sav

func get_contract_by_id(id:int) -> SavedContracts:
	for i:SavedContracts in con_sav:
		if i.id == id:
			return i
	return null

func add_market_slot(id:int, item:String, count:int=1, amount_to_sell:int=1) -> SavedMarket:
       items_added_to_market.emit(item)
       var temp:SavedMarket = SavedMarket.new()
       temp.id = id
       temp.item = item
       temp.count = count
       temp.price = amount_to_sell

       # Verkaufszeit wird anhand des Gesamtpreises (Preis * Menge)
       # linear zwischen 30 Sekunden und 30 Minuten berechnet.
       var total_price = amount_to_sell * count
       var MIN_PRICE = 1
       var MAX_PRICE_TOTAL = 990
       var MIN_TIME = 30    # Sekunden
       var MAX_TIME = 1800  # 30 Minuten in Sekunden

       var clamped_price = clamp(total_price, MIN_PRICE, MAX_PRICE_TOTAL)
       var price_factor = float(clamped_price - MIN_PRICE) / float(MAX_PRICE_TOTAL - MIN_PRICE)
       var sell_time = MIN_TIME + int(round((MAX_TIME - MIN_TIME) * price_factor))

       temp.sell_time_seconds = sell_time
       temp.start_time_ms = Time.get_ticks_msec()
       temp.end_time_ms = temp.start_time_ms + (temp.sell_time_seconds * 1000)

       market_sav.append(temp)
       return temp

func remove_market_item(item:SavedMarket) -> SavedMarket:
	market_sav.remove_at(market_sav.find(item))
	return item

func get_market_by_id(id:int) -> SavedMarket:
	for i:SavedMarket in market_sav:
		if i.id == id:
			return i
	return null

func get_market() -> Array[SavedMarket]:
	return market_sav

func clear_inventory() -> void:
	inventory.data = {}

# --- Workstation Output State Management ---
func set_workstation_output(workstation_id: String, item_data: Dictionary) -> void:
	if item_data.has("item") and item_data.has("count") and item_data.item != "" and item_data.count > 0:
		workstation_output_states[workstation_id] = item_data
		# print("Saved output state for ", workstation_id, ": ", item_data)
	else:
		# If data is invalid or count is 0, clear any existing state
		if workstation_output_states.has(workstation_id):
			workstation_output_states.erase(workstation_id)
			# print("Cleared invalid/empty output state for ", workstation_id)

func get_workstation_output(workstation_id: String) -> Dictionary:
	return workstation_output_states.get(workstation_id, {})

func clear_workstation_output(workstation_id: String) -> void:
	if workstation_output_states.has(workstation_id):
		workstation_output_states.erase(workstation_id)
		# print("Cleared output state for ", workstation_id)
# --- End Workstation Output State Management ---

# --- Workstation Production State Management ---
func set_production_state(workstation_id: String, production_data: Dictionary) -> void:
	if production_data.has("output_item") and production_data.has("end_time_ms") and production_data.output_item != "":
		workstation_production_states[workstation_id] = production_data
		# print("[SaveGame] Set production state for ", workstation_id, ": ", production_data)
	else:
		if workstation_production_states.has(workstation_id):
			workstation_production_states.erase(workstation_id)

func get_production_state(workstation_id: String) -> Dictionary:
	return workstation_production_states.get(workstation_id, {})

func clear_production_state(workstation_id: String) -> void:
	if workstation_production_states.has(workstation_id):
		workstation_production_states.erase(workstation_id)
		# print("[SaveGame] Cleared production state for ", workstation_id)
# --- End Workstation Production State Management ---

# --- Global Production Check ---
func _check_finished_productions():
	var current_time_ms = Time.get_ticks_msec()
	var needs_save = false
	# Iterate over a copy of the keys, as we might modify the dictionary during iteration
	var production_ids = workstation_production_states.keys()

	for id in production_ids:
		# Ensure the state still exists (might have been cleared elsewhere)
		if not workstation_production_states.has(id):
			continue

		var state = workstation_production_states[id]
		if current_time_ms >= state.end_time_ms:
			# Production finished!
			var output_item = state.output_item

			# Add to saved output slot state
			var current_output_state = get_workstation_output(id)
			var new_count = 1
			if not current_output_state.is_empty() and current_output_state.item == output_item:
				new_count = current_output_state.count + 1

			set_workstation_output(id, {"item": output_item, "count": new_count})
			# print("[SaveGame] Production finished for ", id, ". Added ", output_item, " to output state.")

			# Clear the production state
			clear_production_state(id)

			needs_save = true

	if needs_save:
		save_game()
# --- End Global Production Check ---

func start_auto_save_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = AUTO_SAVE_INTERVAL
	timer.autostart = true
	timer.timeout.connect(_on_auto_save_timeout)
	add_child(timer)

func update_player() -> void:
	player = get_tree().get_first_node_in_group("Player")


func check_new_game():
	return new_game

func create_new_game():
	DirAccess.remove_absolute(SAVE_FILE_PATH)
	inventory = Inventory.new()
	inventory.money = 1000000
	LevelingHandler.set_player_level(15)
	LevelingHandler.set_experience_in_current_level(0)


func _on_auto_save_timeout() -> void:
	if SceneSwitcher.get_current_scene_name() not in ["start_screen", "intro"]:
		save_game()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Defer the save to ensure other nodes have saved their state
		call_deferred("save_game")
		# Allow the application to quit
		get_tree().quit()

# --- Marktverkauf-System ---
func check_market_sales() -> bool:
	var current_time_ms = Time.get_ticks_msec()
	var sales_occurred = false
	var items_to_remove = []

	# Überprüfe alle Markt-Items
	for market_item in market_sav:
		# Überprüfe, ob die Verkaufszeit abgelaufen ist
		if market_item.end_time_ms > 0 && current_time_ms >= market_item.end_time_ms:
			# Zeit abgelaufen - Verkauf durchführen
			var total_price = market_item.price * market_item.count

			# Füge Geld zum Spieler-Inventar hinzu
			add_money(total_price)

			# Wichtig: Zuerst das Signal senden, bevor das Item entfernt wird
			# So können die UI-Handler noch auf die Daten zugreifen
			market_item_sold.emit(market_item.item, market_item.count, total_price)

			# Markiere das Item zum Entfernen
			items_to_remove.append(market_item)

			sales_occurred = true

	# Entferne verkaufte Items
	for item in items_to_remove:
		remove_market_item(item)

	return sales_occurred

# Starte einen Timer für regelmäßige Überprüfung der Verkäufe
func start_market_check_timer() -> void:
	var timer = Timer.new()
	timer.name = "MarketSaleTimer"
	timer.wait_time = 1.0 # Überprüfe jede Sekunde
	timer.autostart = true
	timer.timeout.connect(_on_market_check_timeout)
	add_child(timer)

func _on_market_check_timeout() -> void:
	if check_market_sales():
		# Wenn Verkäufe stattgefunden haben, speichere das Spiel
		save_game()
# --- Ende des Marktverkauf-Systems ---
