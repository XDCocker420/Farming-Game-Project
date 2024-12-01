extends AnimatedSprite2D


@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
@onready var field = get_parent()
@onready var default_time = CropManager.get_crop_time('carrot')

@export var state = 0
var time_left = 0


func _ready() -> void:
	z_index = 2
	player.interact.connect(_on_player_interact)
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


func _on_player_interact():
	if state == 2 and field.player_in_area == true:
		SaveGame.add_experience_points(CropManager.get_crop_exp("carrot"))
		SaveGame.add_to_inventory("carrot", 2)
		SaveGame.add_money(CropManager.get_crop_value("carrot"))
		print(SaveGame.get_inventory())
		print(SaveGame.get_current_level())
		print(SaveGame.get_money())
		queue_free()

func on_save_game(saved_data:Array[ItemSaves]):
	var data = CropSaves.new()
	data.scene_path = scene_file_path
	data.time_left = timer.time_left
	data.state = state
	data.parent_path = get_parent().get_path()
	saved_data.append(data)

func on_before_load():
	#get_parent().remove_child(self)
	queue_free()

func on_load_game(saved_data):
	#position = saved_data.position

	if saved_data is CropSaves:
		var data = saved_data as CropSaves
		print(data.state)
		state = data.state
		time_left = data.time_left
