extends AnimatedSprite2D


@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
@onready var field: Area2D = get_parent()

var state = 0
var time_left = 0

func _ready() -> void:
	timer.wait_time = CropManager.get_crop_time('carrot')
	player.interact.connect(_on_player_interact)
	play("grow 1")
	timer.wait_time = time_left
	timer.start()


func _on_timer_timeout() -> void:
	if state != 2:
		state += 1
		timer.start()
		
	if state == 1:
		position.y -= 10
		play("grow 2")
	elif state == 2:
		play("grow 3")


func _on_player_interact():
	if state == 2 and field.player_in_area == true:
		SaveGame.add_to_inventory("carrot")
		queue_free()

func on_save_game(saved_data:Array[ItemSaves]):
	var data = CropSaves.new()
	data.position = global_position
	data.scene_path = scene_file_path
	data.time_left = timer.time_left
	saved_data.append(data)

func on_before_load():
	get_parent().remove_child(self)
	queue_free()

func on_load_game(saved_data):
	global_position = saved_data.position

	if saved_data is CropSaves:
		var data = saved_data as CropSaves
		time_left = data.time_left

"""
func add_inventory() -> void:
	if 'carrot' in SaveData.data['inventory']:
		SaveData.data['inventory']['carrot'] += 2
	else:
		SaveData.data['inventory']['carrot'] = 1
"""
