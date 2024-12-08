extends AnimatedSprite2D

@onready var timer: Timer = $Timer
@onready var field = get_parent()
@onready var default_time = CropManager.get_crop_time('carrot')

@export var state = 0
var time_left = 0
var is_watered = false

func _ready() -> void:
	z_index = 2
	if state != 0:
		position.y -= 10
	play("grow " + str(state + 1))
	if(time_left > 0):
		timer.wait_time = time_left
	else:
		timer.wait_time = get_growth_time()
	timer.start()

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
	if not is_watered:
		is_watered = true
		return true
	return false

func can_harvest() -> bool:
	return state == 2

func harvest() -> void:
	if not can_harvest():
		return
		
	var carrot_count = 2
	var chance = randf()
	
	if is_watered:
		if chance > 0.8:
			carrot_count = 3
	else:
		if chance < 0.15:
			carrot_count = 1
		elif chance > 0.95:
			carrot_count = 3
	
	SaveGame.add_experience_points(CropManager.get_crop_exp("carrot"))
	SaveGame.add_to_inventory("carrot", carrot_count)
	print("Harvested: ", carrot_count, " carrots")
	print("Inventory: ", SaveGame.get_inventory())
	print("Level: ", SaveGame.get_current_level())
	SaveGame.save_game()
	queue_free()

func on_save_game(saved_data:Array[ItemSaves]):
	var data = CropSaves.new()
	data.scene_path = scene_file_path
	data.time_left = timer.time_left
	data.state = state
	data.parent_path = get_parent().get_path()
	saved_data.append(data)

func on_before_load():
	queue_free()

func on_load_game(saved_data):
	if saved_data is CropSaves:
		var data = saved_data as CropSaves
		print(data.state)
		state = data.state
		time_left = data.time_left
