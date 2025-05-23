extends Node

var _level:int = 1
var _exp_level:int = 0
signal exp_changed(exp_count:int, exp_sum:int)
signal level_changed(level:int)
signal not_unlocked(level_needed:int)


func get_current_level() -> int:
	return _level
	
func set_player_level(level:int) -> int:
	_level = level
	return _level

func get_experience_in_current_level() -> int:
	return _exp_level
	
func set_experience_in_current_level(exp_point:int) -> int:
	_exp_level = exp_point
	return _exp_level
	
func is_item_unlocked(item_name:String) -> bool:
	return ConfigReader.has_reached_level(item_name)
	
func is_building_unlocked(building_name:String) -> bool:
	if not ConfigReader.has_reached_level_building(building_name):
		not_unlocked.emit(ConfigReader.get_level_needed_building(building_name))
		return false
	return true

func get_building_level_needed(building_name: String) -> int:
	return ConfigReader.get_level_needed_building(building_name)
	
func get_all_unlocked_buildings() -> Array[String]:
	return ConfigReader.get_all_buildings_for_level()
	
func get_all_unlocked_items() -> Array[String]:
	return ConfigReader.get_all_items_for_level()

func add_experience_points(count:int=1) -> void:
	if count < 1:
		push_error("count musst be bigger or equal 1")
		get_tree().quit()
	_exp_level += count
	_check_new_level(count)

func _check_new_level(added_exp:int) -> void:
	var xp_needed = xp_for_level(_level)
	if(_exp_level >= xp_needed):
		_level += 1
		_exp_level -= xp_needed
		if(_exp_level < 0):
			_exp_level = 0
		level_changed.emit(_level)
	exp_changed.emit(added_exp, _exp_level)
	
func xp_for_level(level: int) -> float:
	if level < 1:
		return 0.0
	var exponent: float = 1.0 + (5.0 * (level - 1)) / 99.0
	return 60.0 * pow(level, exponent)
