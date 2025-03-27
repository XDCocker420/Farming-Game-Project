extends CharacterBody2D


signal interact
signal interact2

@onready var body: AnimatedSprite2D = $AnimationBody

@export var normal_speed: float = 50.0
@export var sprint_speed: float = 100.0
@export var cant_move: bool = false

var selected_crop: String = "carrot"  # Default crop
var looking_direction: String = "down"
var current_speed: float
var is_jump: bool


func _ready() -> void:
	current_speed = normal_speed
	
	# Überprüfe, ob wir aus einem Gebäude kommen
	if SaveGame.last_exterior_position != Vector2.ZERO:
		# Direktes Setzen der Position im Ready, wenn eine gespeicherte Position vorhanden ist
		call_deferred("_check_position_after_building_exit")
	
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
		
		if SaveGame.get_money() <= 0:
			SaveGame.add_money(5000)
		
		# Speichere das initialisierte Inventar
		SaveGame.save_game()
	
	# Registriere Signal für Änderungen der Außenposition
	if SaveGame.has_signal("exterior_position_changed"):
		SaveGame.exterior_position_changed.connect(_on_exterior_position_changed)

func _on_exterior_position_changed(pos: Vector2) -> void:
	pass

# Überprüft die Position nach dem Verlassen eines Gebäudes
func _check_position_after_building_exit() -> void:
	# Wenn die aktuelle Position (0,0) oder nahe daran ist, verwende die gespeicherte Position
	if global_position.length() < 1.0:  # Nahe am Ursprung (0,0)
		set_position_from_exterior(SaveGame.last_exterior_position)

	$CanvasLayer/TextureRect/Money.text = str(SaveGame.get_money())


func _input(event: InputEvent) -> void:
	# Check if the interaction key is pressed
	if event.is_action_pressed("interact"):
		interact.emit()
		
	if event.is_action_pressed("interact2"):
		interact2.emit()
		
	if event.is_action_pressed("jump"):
		body.play("jump_" + looking_direction)
		

	# exit game on esc
	'''if event.is_action_pressed("ui_cancel"):
		get_tree().quit()'''


func set_selected_crop(crop_name: String) -> void:
	selected_crop = crop_name

	
func _physics_process(delta: float) -> void:
	if !cant_move:
		current_speed = sprint_speed if Input.is_action_pressed("sprint") else normal_speed
		
		var direction = Vector2.ZERO
		direction.x = Input.get_axis("move_left", "move_right")
		direction.y = Input.get_axis("move_up", "move_down")
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
