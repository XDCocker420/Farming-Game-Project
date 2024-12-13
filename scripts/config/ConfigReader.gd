extends Node

var config = ConfigFile.new()

var display_names = {
	"cauliflower": "Cauli",
	"aubergine": "Eggplant"
}

func _ready() -> void:
	var err = config.load("res://scripts/config/crops_config.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return

func get_display_name(crop_name: String) -> String:
	if crop_name in display_names:
		return display_names[crop_name]
	return crop_name[0].to_upper() + crop_name.substr(1,-1)

func get_crop_time(crop_name:String) -> int:
	return config.get_value(crop_name, 'time')

func get_crop_value(crop_name:String) -> int:
	return config.get_value(crop_name, 'value')

func get_crop_exp(crop_name:String) -> int:
	return config.get_value(crop_name, 'xp')

func get_max_price(crop_name:String) -> int:
	return config.get_value(crop_name, "maxPrice")

func has_reached_level(crop_name:String) -> bool:
	return SaveGame.get_current_level() >= config.get_value(crop_name, "level_needed")
	
func get_all_level() -> Array[String]:
	var items:Array[String] = []
	for i in config.get_sections():
		if has_reached_level(i):
			items.append(i)
	return items
