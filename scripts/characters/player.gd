extends CharacterBody2D

signal interact
signal interact2

@onready var body: AnimatedSprite2D = $AnimationBody
@onready var lvl_bar:TextureProgressBar = $CanvasLayer/TextureProgressBar
@onready var lvl_label:Label = $CanvasLayer/TextureProgressBar/Label

@onready var money_label:Label = $CanvasLayer/TextureRect/Money
@onready var exit_menu:Control = $CanvasLayer/ExitMenu

@onready var money_animation:AnimationPlayer = $CanvasLayer/TextureRect/MoneyAnim/AnimationPlayer
@onready var money_animation_val:Label = $CanvasLayer/TextureRect/MoneyAnim/Amount
@onready var money_animation_control:Control = $CanvasLayer/TextureRect/MoneyAnim

@onready var exp_animation:AnimationPlayer = $CanvasLayer/TextureProgressBar/ExpAdded/AnimationPlayer
@onready var exp_animation_val:Label = $CanvasLayer/TextureProgressBar/ExpAdded/Amount
@onready var exp_animation_control:Control = $CanvasLayer/TextureProgressBar/ExpAdded

@onready var new_lvl_anim:AnimationPlayer = $CanvasLayer/NewLevelReached/AnimationPlayer
@onready var new_lvl_anim_val:Label = $CanvasLayer/NewLevelReached/TextureRect/LevelVal
@onready var new_lvl_anim_control:Control = $CanvasLayer/NewLevelReached

@onready var player_animplayer:AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var player_center_label:Label = $CanvasLayer/NotUnlocked
@onready var player_center_label_timer:Timer = $CanvasLayer/NotUnlockedTimer

@onready var camera:Camera2D = $Camera2D

@export var normal_speed: float = 50.0
@export var sprint_speed: float = 100.0
@export var cant_move: bool = false
@export var no_ui:bool = false

var selected_crop: String = "carrot"  # Default crop
var looking_direction: String = "down"
var current_speed: float

var follow_mouse:bool = false

var temp_money:int


func _ready() -> void:
	LevelingHandler.exp_changed.connect(_on_exp_changed)
	LevelingHandler.level_changed.connect(_on_level_changed)
	LevelingHandler.not_unlocked.connect(_on_building_not_unlocked)
	
	SaveGame.money_added.connect(_on_money_added)
	SaveGame.money_removed.connect(_on_money_removed)
	
	money_animation.animation_finished.connect(_on_money_anim_finished)
	exp_animation.animation_finished.connect(_on_exp_anim_finished)
	new_lvl_anim.animation_finished.connect(_on_new_lvl_finished)
	player_animplayer.animation_finished.connect(_on_player_anim_finished)
	
	body.animation_finished.connect(_on_anim_end)
	
	$CanvasLayer.visible = !no_ui
	
	current_speed = normal_speed
	
	if SceneSwitcher.player_position != Vector2.ZERO:
		call_deferred("_check_position_after_building_exit")
	
	# Update money display immediately on ready
	do_set_money()
	
	# Nur initialisieren, wenn das Inventar leer ist (neues Spiel)
	if SaveGame.get_inventory().size() == 0:
		SaveGame.add_to_inventory("carrot", 20)
		SaveGame.add_to_inventory("corn", 20)
		SaveGame.add_to_inventory("eggplant", 20)
		SaveGame.add_to_inventory("potatoe", 20)
		
		# Add input materials for production testing
		SaveGame.add_to_inventory("milk", 20)
		SaveGame.add_to_inventory("egg", 20)
		SaveGame.add_to_inventory("white_wool", 20)
		SaveGame.add_to_inventory("wheat", 20)
		
		# Add output products for production testing
		SaveGame.add_to_inventory("butter", 20)
		SaveGame.add_to_inventory("cheese", 20)
		SaveGame.add_to_inventory("mayo", 20)
		SaveGame.add_to_inventory("white_cloth", 20)
		SaveGame.add_to_inventory("white_string", 20)
		SaveGame.add_to_inventory("feed", 20)
		
		#if SaveGame.get_money() <= 0:
			#SaveGame.add_money(5000)


# Überprüft die Position nach dem Verlassen eines Gebäudes
func _check_position_after_building_exit() -> void:
	# Wenn die aktuelle Position (0,0) oder nahe daran ist, verwende die gespeicherte Position
	if global_position.length() < 1.0:  # Nahe am Ursprung (0,0)
		set_position_from_exterior(SceneSwitcher.player_position)


func _input(event: InputEvent) -> void:
	# Check if the interaction key is pressed
	if event.is_action_pressed("interact"):
		interact.emit()
		
	if event.is_action_pressed("interact2"):
		print(global_position)
		interact2.emit()
		
	if event.is_action_pressed("jump"):
		body.play("jump_" + looking_direction)


func set_selected_crop(crop_name: String) -> void:
	selected_crop = crop_name

	
func _physics_process(delta: float) -> void:
	if !cant_move && body.animation in ["right", "left", "up", "down"]:
		current_speed = sprint_speed if Input.is_action_pressed("sprint") else normal_speed
		
		
		var direction = Vector2.ZERO
		if !follow_mouse:
			direction.x = Input.get_axis("move_left", "move_right")
			direction.y = Input.get_axis("move_up", "move_down")
		else:
			direction = get_global_mouse_position() - global_position
			if direction.length() <= 1.0:
				direction = Vector2.ZERO
		direction = direction.normalized()
		
		velocity = direction * current_speed

		if direction.x > 0:
			looking_direction = "right"
		elif direction.x < 0:
			looking_direction = "left"
		elif direction.y > 0:
			looking_direction = "down"
		elif direction.y < 0:
			looking_direction = "up"

		update_animation(direction)
		move_and_slide()


func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if current_speed == normal_speed:
			body.play(looking_direction)
		else:
			body.play(looking_direction, 1.5)
	else:
		body.stop()

# Hilfsfunktion, die von der game_map aufgerufen werden kann, um die Position zu setzen
func set_position_from_exterior(pos: Vector2) -> void:
	# Setze sowohl die globale als auch die lokale Position
	global_position = pos
	position = pos
	SceneSwitcher.player_position = Vector2.ZERO
	
func _format_level(level:int) -> String:
	if level < 10:
		return "0" + str(level)
	else:
		return str(level)


func _on_settings_btn_pressed() -> void:
	if exit_menu.visible:
		exit_menu.visible = false
		get_tree().paused = false
	else:
		exit_menu.visible = true
		get_tree().paused = true


func _on_exit_btn_pressed() -> void:
	SaveGame.save_game()
	get_tree().quit()


func _on_back_btn_pressed() -> void:
	exit_menu.visible = false
	get_tree().paused = false
	
func _on_level_changed(level:int):
	new_lvl_anim_val.text = _format_level(level)
	new_lvl_anim_control.show()
	new_lvl_anim.play("fade_in")
	lvl_label.text = _format_level(level)
	lvl_bar.min_value = 0
	lvl_bar.value = LevelingHandler.get_experience_in_current_level()
	lvl_bar.max_value = LevelingHandler.xp_for_level(level)

	
func _on_exp_changed(exp_count:int, sum_exp:int):
	exp_animation_control.show()
	exp_animation_val.text = "+" + str(exp_count)
	exp_animation.play("fade_up")
	lvl_bar.value = sum_exp
	
	
func _on_money_added(money:int, added_value:int):
	temp_money = money
	money_label.hide()
	money_animation_control.show()
	money_animation_val.text = "+" + str(added_value)
	money_animation.play("fade_up")
	
	
func _on_money_removed(money:int, removed_value:int):
	temp_money = money
	money_label.hide()
	money_animation_control.show()
	money_animation_val.text = "-" + str(removed_value)
	money_animation.play("fade_down")
	
func _on_money_anim_finished(anim_name):
	money_label.show()
	money_animation_control.hide()
	money_label.text = str(temp_money)

func _on_exp_anim_finished(anim_name):
	exp_animation_control.hide()
	
func _on_new_lvl_finished(anim_name):
	if anim_name == "fade_in":
		await get_tree().create_timer(1.5).timeout
		new_lvl_anim.play("fade_out")
		
	if anim_name == "fade_out":
		new_lvl_anim_control.hide()
		
func _on_building_not_unlocked(level: int) -> void:
	player_center_label.text = "Unlocks at Level " + str(level)
	player_center_label.visible = true
	player_center_label_timer.start()
	player_animplayer.play("show_up")
	
func _on_player_anim_finished(anim_name):
	if anim_name == "show_up":
		await get_tree().create_timer(1.5).timeout
		player_animplayer.play("not_show")
		
func do_harvest():
	#cant_move = true
	body.play("hoe_"+looking_direction)
	
func do_water():
	body.play("water_"+looking_direction)
		
func _on_anim_end():
	body.animation = looking_direction
	
func _follow_mouse(val:bool):
	get_viewport().warp_mouse(get_viewport_rect().size / 2.0)
	follow_mouse = val

func do_set_level():	
	lvl_label.text = _format_level(LevelingHandler.get_current_level())
	lvl_bar.min_value = 0
	lvl_bar.value = LevelingHandler.get_experience_in_current_level()
	lvl_bar.max_value = LevelingHandler.xp_for_level(LevelingHandler.get_current_level())

func do_set_money():
	money_label.text = str(SaveGame.get_money())

# Function to get the player's current money from SaveGame
func get_money() -> int:
	return SaveGame.get_money()
