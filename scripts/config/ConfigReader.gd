extends Node

var config = ConfigFile.new()
var lvl_config = ConfigFile.new()
var build_config = ConfigFile.new()

var display_names = {
	"cauliflower": "Cauli",
	"aubergine": "Eggplant",
	"white_wool": "Wool",
	"white_cloth": "Cloth",
	"white_string": "String",
	"butter": "Butter",
	"cheese": "Cheese",
	"mayo": "Mayonnaise",
	"feed": "Feed"
}

func _ready() -> void:
	var err = config.load("res://scripts/config/item_config.cfg")
	
	var err2 = lvl_config.load("res://scripts/config/level_config.cfg")
	
	var err3 = build_config.load("res://scripts/config/buildings.cfg")

	# If the file didn't load, ignore it.
	if err != OK or err2 != OK or err3 != OK:
		return

func get_display_name(item_name: String) -> String:
	if item_name in display_names:
		return display_names[item_name]
	return item_name[0].to_upper() + item_name.substr(1,-1)

func get_time(item_name:String) -> int:
	return config.get_value(item_name, 'time')

func get_value(item_name:String) -> int:
	return config.get_value(item_name, 'value')

func get_exp(item_name:String) -> int:
	return config.get_value(item_name, 'xp')

func get_max_price(item_name:String) -> int:
	return config.get_value(item_name, "maxPrice")

func has_reached_level(item_name:String) -> bool:
	return LevelingHandler.get_current_level() >= config.get_value(item_name, "level_needed")
	
func has_reached_level_building(building_name:String) -> bool:
	return LevelingHandler.get_current_level() >= build_config.get_value(building_name, "level_needed")
	
func get_all_items_for_level() -> Array[String]:
	var items:Array[String] = []
	for i in config.get_sections():
		if has_reached_level(i):
			items.append(i)
	return items
	
func get_all_buildings_for_level() -> Array[String]:
	var items:Array[String] = []
	for i in build_config.get_sections():
		if has_reached_level_building(i):
			items.append(i)
	return items

func get_api_key() -> String:
	var env = FileAccess.open("res://imp.env", FileAccess.READ)
	return env.get_as_text().split("=")[1]
