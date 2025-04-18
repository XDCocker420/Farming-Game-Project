extends AnimatedSprite2D


@onready var timer: Timer = $Timer

# Set by Node name
var crop_type: String = "wheat"

var time_left: int = 0
var is_watered: bool = false
var default_time: float = 0.0


func _ready() -> void:
	z_index = 1
		
	default_time = ConfigReader.get_time(crop_type)
	
	if is_watered:
		animation = "grow_wet"
	else:
		animation = "grow"
	
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
	if frame == 0:
		if !is_watered:
			frame = 0
			#timer.paused = true
		else: 
			frame += 1
			timer.start(get_growth_time())
	
	elif frame != 5:
		frame += 1
		timer.start(get_growth_time())
		
	if frame == 1:
		position.y -= 8
		
	if frame == 5:
		TutorialHelper.crop_is_growed.emit()


func water() -> bool:
	if not is_watered && frame == 0:
		is_watered = true
		var progress_ratio = timer.time_left / timer.wait_time
		animation = "grow_wet"
		#timer.paused = false
		timer.start(get_growth_time() * progress_ratio)
		print(timer.time_left)
		
		return true
	return false


func can_harvest() -> bool:
	return frame == 5


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
	
	LevelingHandler.add_experience_points(ConfigReader.get_exp(crop_type))
	SaveGame.add_to_inventory(crop_type, crop_count)
	SaveGame.save_game()
	queue_free()
