extends AnimatedSprite2D

@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
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
		timer.wait_time = default_time
	timer.start()

func _on_timer_timeout() -> void:
	if state != 2:
		state += 1
		timer.start(default_time)
		
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
	if is_watered:
		if randf() > 0.78:
			carrot_count = 3
	else:
		if randf() > 0.90:
			carrot_count = 3
		elif randf() < 0.05:
			carrot_count = 1
	
	SaveGame.add_experience_points(CropManager.get_crop_exp("carrot"))
	SaveGame.add_to_inventory("carrot", carrot_count)
	SaveGame.add_money(CropManager.get_crop_value("carrot"))
	print("Harvested: ", carrot_count, " carrots")
	print("Inventory: ", SaveGame.get_inventory())
	print("Level: ", SaveGame.get_current_level())
	print("Money: ", SaveGame.get_money())
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
