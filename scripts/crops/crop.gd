extends AnimatedSprite2D


@onready var timer: Timer = $Timer
# @onready var field: Area2D = get_parent()

# Must be set in editor for each crop scene
@export var crop_type: String = ""

var time_left: int = 0
var is_watered: bool = false
var default_time: float


func _ready() -> void:
    z_index = 1
    
    # Verify that crop_type is set
    if crop_type.is_empty():
        push_error("Crop type not set in editor!")
        return
        
    # default_time = ConfigReader.get_time(crop_type)
    
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
    if frame != 5:
        frame += 1
        timer.start(get_growth_time())
        
    if frame == 1:
        position.y -= 8


func water() -> bool:
    if not is_watered && frame == 0:
        is_watered = true
        var progress_ratio = timer.time_left / timer.wait_time
        timer.start(get_growth_time() * progress_ratio)
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
    
    SaveGame.add_experience_points(ConfigReader.get_exp(crop_type))
    SaveGame.add_to_inventory(crop_type, crop_count)
    SaveGame.save_game()
    queue_free()


func on_save_game(saved_data:Array[ItemSaves]):
    var data = CropSaves.new()
    data.scene_path = scene_file_path
    data.time_left = timer.time_left
    data.animation = animation
    data.frame = frame
    data.parent_path = get_parent().get_path()
    data.is_watered = is_watered
    saved_data.append(data)


func on_before_load():
    queue_free()


func on_load_game(saved_data):
    if saved_data is CropSaves:
        var data = saved_data as CropSaves
        is_watered = data.is_watered
        animation = data.animation
        frame = data.frame
        time_left = data.time_left
