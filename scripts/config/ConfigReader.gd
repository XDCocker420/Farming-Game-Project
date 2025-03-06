extends Node

var config = ConfigFile.new()

var display_names = {
	"cauliflower": "Cauli",
	"aubergine": "Eggplant"
}

func _ready() -> void:
	var err = config.load("res://scripts/config/item_config.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
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
	return SaveGame.get_current_level() >= config.get_value(item_name, "level_needed")
	
func get_all_level() -> Array[String]:
	var items:Array[String] = []
	for i in config.get_sections():
		if has_reached_level(i):
			items.append(i)
	return items
	
func get_api_key() -> String:
	var env = FileAccess.open("res://.env", FileAccess.READ)
	return env.get_as_text().split("=")[1]
