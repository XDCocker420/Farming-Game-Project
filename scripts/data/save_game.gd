extends Node

# File path for saving and loading
const SAVE_FILE_PATH: String = "user://savegame.tres"

# Auto-save interval in seconds
const AUTO_SAVE_INTERVAL: float = 60.0  # Save every 60 seconds

var inventory:Inventory = Inventory.new()
var con_sav:Array[SavedContracts] = []
var market_sav:Array[SavedMarket] = []

var map = null
@onready var player = get_tree().get_first_node_in_group("Player")

var new_game:bool = false

signal money_added(money:int, added_value:int)
signal money_removed(money:int, removed_value:int)

func _ready() -> void:
	var map_nodes = get_tree().get_nodes_in_group("game_map")
	if map_nodes.size() > 0:
		map = map_nodes[0]

	start_auto_save_timer()
	# Attempt to load existing game data
	if SceneSwitcher.get_current_scene_name() not in ["start_screen", "intro"]:
		load_game()


func save_game() -> void:
	var save := SavedData.new()
	update_player()
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
	
	ResourceSaver.save(save, SAVE_FILE_PATH)

func save_exp_lvl() -> void:
	var saved_game:SavedData = ResourceLoader.load(SAVE_FILE_PATH)
		
	saved_game.player_level = LevelingHandler.get_current_level()
	saved_game.player_experience_per_level = LevelingHandler.get_experience_in_current_level()
	ResourceSaver.save(saved_game, SAVE_FILE_PATH)

func load_game() -> void:
	var saved_game:SavedData = ResourceLoader.load(SAVE_FILE_PATH)
	if saved_game == null:
		#print("nene nix safe")
		# For testing
		LevelingHandler.set_player_level(10)
		# For production
		#LevelingHandler.set_player_level(1)
		inventory.money = 100
		new_game = true
		return
	
	if player:
		get_tree().call_group("dynamic_elements", "on_before_load_game")
		
		# Sichern einer Kopie des alten Inventars zum Vergleich
		var old_inventory = {}
		if inventory and inventory.data:
			old_inventory = inventory.data.duplicate()
		
		inventory = saved_game.inventory
		print(saved_game.player_level)
		LevelingHandler.set_player_level(saved_game.player_level)
		LevelingHandler.set_experience_in_current_level(saved_game.player_experience_per_level)
		player.global_position = saved_game.player_position
		con_sav = saved_game.contracts
		market_sav = saved_game.market_items
	
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

signal items_added_to_market

func add_market_slot(id:int, item:String, count:int=1, amount_to_sell:int=1) -> SavedMarket:
	items_added_to_market.emit(item)
	var temp:SavedMarket = SavedMarket.new()
	temp.id = id
	temp.item = item
	temp.count = count
	temp.price = amount_to_sell
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


func _on_auto_save_timeout() -> void:
	if SceneSwitcher.get_current_scene_name() not in ["start_screen", "intro"]:
		save_game()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Defer the save to ensure other nodes have saved their state
		call_deferred("save_game")
		# Allow the application to quit
		get_tree().quit()
