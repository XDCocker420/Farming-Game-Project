extends Node

# File path for saving and loading
const SAVE_FILE_PATH: String = "user://savegame.tres"

# Auto-save interval in seconds
const AUTO_SAVE_INTERVAL: float = 60.0  # Save every 60 seconds

const MAX_LEVEL:int = 6

var inventory:Inventory = Inventory.new()
var config = ConfigFile.new()
var level:int = 0
var exp_level:int = 0

@onready var map = get_tree().get_first_node_in_group("Map")
@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	# Start the auto-save timer
	start_auto_save_timer()
	# Attempt to load existing game data
	load_game()

	var err = config.load("res://scripts/config/level_config.cfg")
	if err != OK:
		return


func save_game() -> void:
	var save := SavedData.new()
	save.player_position = player.global_position
	save.player_level = level
	save.player_experience_per_level = exp_level

	var saved_data:Array[ItemSaves] = []
	get_tree().call_group("game_events", "on_save_game", saved_data)
	
	save.saved_data = saved_data
	save.inventory = inventory
	
	ResourceSaver.save(save, SAVE_FILE_PATH)


func load_game() -> void:
	var saved_game:SavedData = ResourceLoader.load(SAVE_FILE_PATH)
	if saved_game == null:
		level = 1
		inventory.money = 100
		return
	
	get_tree().call_group("game_events", "on_before_load_game")
	inventory = saved_game.inventory
	level = saved_game.player_level
	exp_level = saved_game.player_experience_per_level
	player.global_position = saved_game.player_position
	
	await get_tree().process_frame
	
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
	if inventory.data.has(item):
		inventory.data[item] += count
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

func get_current_level() -> int:
	return level

func get_experience_per_level() -> int:
	return exp_level

func add_experience_points(count:int) -> void:
	if count < 1:
		push_error("count musst be bigger or equal 1")
		get_tree().quit()
	exp_level += count
	_check_new_level()

func _check_new_level() -> void:
	if(level > MAX_LEVEL):
		return
	var xp_needed = config.get_value("Level" + str(level), "exp_needed")
	if(exp_level >= xp_needed):
		level += 1
		exp_level -= xp_needed
		if(exp_level < 0):
			exp_level = 0

func add_money(count:int=1) -> void:
	if count < 1:
		push_error("count musst be bigger or equal 1")
		get_tree().quit()
	inventory.money += count

func remove_money(count:int=1) -> bool:
	if count < 1:
		push_error("count musst be bigger or equal 1")
		get_tree().quit()
	if inventory.money - count < 0:
		return false
	inventory.money -= count
	return true

func get_money() -> int:
	return inventory.money

func start_auto_save_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = AUTO_SAVE_INTERVAL
	timer.autostart = true
	timer.timeout.connect(_on_auto_save_timeout)
	add_child(timer)


func _on_auto_save_timeout() -> void:
	save_game()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Defer the save to ensure other nodes have saved their state
		call_deferred("save_game")
		# Allow the application to quit
		get_tree().quit()
