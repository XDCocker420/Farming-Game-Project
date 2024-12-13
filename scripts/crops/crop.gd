extends AnimatedSprite2D

@onready var timer: Timer = $Timer
@onready var field = get_parent()

@export var crop_type: String = ""  # Must be set in editor for each crop scene
@export var state = 0

var time_left = 0
var is_watered = false
var default_time: float

func _ready() -> void:
	z_index = 2
	
	# Verify that crop_type is set
	if crop_type.is_empty():
		push_error("Crop type not set in editor!")
		return
		
	default_time = ConfigReader.get_crop_time(crop_type)
	_update_visual_state()
	
	if(time_left > 0):
		timer.wait_time = time_left
	else:
		timer.wait_time = get_growth_time()
	timer.start()

func _update_visual_state() -> void:
	if state >= 1:
		position.y -= 10
	play("grow " + str(state + 1))

func get_growth_time() -> float:
	if is_watered:
		return default_time * 0.8  # 20% faster if watered
	return default_time

func _on_timer_timeout() -> void:
	if state != 2:
		state += 1
		timer.start(get_growth_time())
		
	if state == 1:
		position.y -= 10
		play("grow 2")
	elif state == 2:
		play("grow 3")

func water() -> bool:
	if not is_watered && state != 2:
		is_watered = true
		var progress_ratio = timer.time_left / timer.wait_time
		timer.start(get_growth_time() * progress_ratio)
		return true
	return false

func can_harvest() -> bool:
	return state == 2

func harvest() -> void:
	if not can_harvest():
		return
		
	var crop_count = 2  # Default amount
	var chance = randf()
	
	if is_watered:
		crop_count = 3 if chance > 0.8 else 2  # 20% chance for 3 crops when watered
	else:
		if chance < 0.15:
			crop_count = 1  # 15% chance for 1 crop when not watered
		elif chance > 0.95:
			crop_count = 3  # 5% chance for 3 crops when not watered
	
	SaveGame.add_experience_points(ConfigReader.get_crop_exp(crop_type))
	SaveGame.add_to_inventory(crop_type, crop_count)
	print("Harvested: ", crop_count, " ", crop_type)
	print("Inventory: ", SaveGame.get_inventory())
	SaveGame.save_game()
	queue_free()

func on_save_game(saved_data:Array[ItemSaves]):
	var data = CropSaves.new()
	data.scene_path = scene_file_path
	data.time_left = timer.time_left
	data.state = state
	data.parent_path = get_parent().get_path()
	data.is_watered = is_watered
	saved_data.append(data)

func on_before_load():
	queue_free()

func on_load_game(saved_data):
	if saved_data is CropSaves:
		var data = saved_data as CropSaves
		is_watered = data.is_watered
		state = data.state
		time_left = data.time_left
		_update_visual_state()
