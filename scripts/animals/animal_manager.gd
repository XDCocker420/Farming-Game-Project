extends Node


var config = ConfigFile.new()


func _ready() -> void:
	var err = config.load("res://scripts/config/animal_config.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return


func get_produce_time(animal_name:String) -> int:
	return config.get_value(animal_name, 'produce_time')

func get_product_value(animal_name:String) -> int:
	return config.get_value(animal_name, 'product_value')

func get_animal_exp(animal_name:String) -> int:
	return config.get_value(animal_name, 'xp')

func get_product_max_price(animal_name:String) -> int:
	return config.get_value(animal_name, "product_maxPrice")

func get_meat_value(animal_name:String):
	return config.get_value(animal_name, "meat_value")

func get_meat_max_price(animal_name:String):
	return config.get_value(animal_name, "meat_maxPrice")

func has_reached_level(animal_name:String) -> bool:
	return SaveGame.get_current_level() >= config.get_value(animal_name, "level_needed")
