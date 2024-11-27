extends Node

# Dictionary to store game state data
#var data: Dictionary = {'player':{}, 'crops':{}, 'inventory':{}}

# File path for saving and loading
const SAVE_FILE_PATH: String = "user://savegame.tres"

# Auto-save interval in seconds
const AUTO_SAVE_INTERVAL: float = 60.0  # Save every 60 seconds

var inventory:Inventory

@onready var map = get_tree().get_first_node_in_group("Map")
@onready var player = get_tree().get_first_node_in_group("Player")
#@onready var test = %Player

func _ready() -> void:
	# Start the auto-save timer
	start_auto_save_timer()
	# Attempt to load existing game data
	load_game()


func save_game() -> void:
	var save := SavedData.new()
	save.player_position = player.global_position

	var saved_data:Array[ItemSaves] = []
	get_tree().call_group("game_events", "on_save_game", saved_data)
	
	save.saved_data = saved_data
	save.inventory = inventory
	
	ResourceSaver.save(save, SAVE_FILE_PATH)
	"""
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE_READ)
	if file:
		var json_data = JSON.stringify(data)
		file.store_string(json_data)
		file.close()
		print("Game saved successfully.")
	else:
		print("Failed to save game.")
	"""


func load_game() -> void:
	var saved_game:SavedData = ResourceLoader.load(SAVE_FILE_PATH)
	if saved_game == null:
		return
	
	get_tree().call_group("game_events", "on_before_load_game")
	inventory = saved_game.inventory
	player.global_position = saved_game.player_position
	
	for item in saved_game.saved_data:
		var scene := load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		map.add_child(restored_node)
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
	"""
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var json_data = file.get_as_text()
		var error = json.parse(json_data)
		if error == OK:
			data = JSON.parse_string(json_data)
			print("Game loaded successfully.")
		else:
			print("Error parsing save file: ", error,)
		file.close()
	else:
		print("No save file found. Starting new game.")
	"""

func add_to_inventory(item:String, count:int=1) -> void:
	if inventory == null:
		inventory = Inventory.new()
	
	if inventory.data.has(item):
		inventory.data[item] += count
	else:
		inventory.data[item] = count

# removes something
func remove_from_inventory(item: String, count:int=1, remove_completly:bool=false) -> void:
	if inventory == null or not inventory.data.has(item):
		return
	if remove_completly:
		inventory.data.erase(item)
		return

	inventory.data[item] -= count
	if inventory.data[item] <= 0:
		inventory.data.erase(item)
		
func get_inventory() -> Dictionary:
	if inventory == null:
		return {}
	return inventory.data
	
func get_item_count(item:String) -> int:
	if inventory == null or not inventory.data.has(item):
		return 0
	return inventory.data[item]

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
